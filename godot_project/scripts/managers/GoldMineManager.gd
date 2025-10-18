extends Node
class_name GoldMineManager

# 金矿管理器 - 管理所有金矿的生成、状态和挖掘逻辑
# 参考 MINING_SYSTEM.md

# LogManager 现在是 autoload，直接使用

# 金矿状态枚举
enum MineStatus {UNDISCOVERED, ACTIVE, BEING_MINED, EXHAUSTED} # 未发现  # 活跃中  # 正在挖掘  # 已枯竭

# 挖掘者状态
enum MiningStatus {AVAILABLE, BUSY, FULL} # 可挖掘  # 繁忙  # 满员

# 金矿数据结构
class GoldMine:
	var position: Vector3
	var gold_amount: int
	var max_gold: int
	var status: MineStatus
	var mining_status: MiningStatus
	var miners: Array = [] # 当前挖掘者列表
	var discovered: bool = false
	var mine_id: int
	
	# [策略3] 工作位置分配系统
	var work_slots: Array = [] # 可用的工作位置 Array[Vector3]
	var assigned_slots: Dictionary = {} # {worker_id: slot_index}

	func _init(pos: Vector3, amount: int = 500):
		position = pos
		gold_amount = amount
		max_gold = amount
		status = MineStatus.UNDISCOVERED
		mining_status = MiningStatus.AVAILABLE
		mine_id = randi()

	func get_mining_capacity() -> int:
		"""获取挖掘容量（最多3个挖掘者）"""
		return 3

	func can_accept_miner() -> bool:
		"""是否可以接受新的挖掘者"""
		return miners.size() < get_mining_capacity() and status == MineStatus.ACTIVE

	func add_miner(miner):
		"""添加挖掘者"""
		if can_accept_miner():
			miners.append(miner)
			_update_mining_status()
			return true
		return false

	func remove_miner(miner):
		"""移除挖掘者"""
		var index = miners.find(miner)
		if index >= 0:
			miners.remove_at(index)
			_update_mining_status()

	func _update_mining_status():
		"""更新挖掘状态"""
		match miners.size():
			0:
				mining_status = MiningStatus.AVAILABLE
			1:
				mining_status = MiningStatus.BUSY
			2, 3:
				mining_status = MiningStatus.FULL

	func mine_gold(amount: int) -> int:
		"""挖掘黄金，返回实际挖掘的数量"""
		var mined = min(amount, gold_amount)
		gold_amount -= mined

		if gold_amount <= 0:
			status = MineStatus.EXHAUSTED
			# 移除所有挖掘者
			for miner in miners:
				if miner.has_method("on_mine_exhausted"):
					miner.on_mine_exhausted()
			miners.clear()
			_update_mining_status()

		return mined

	func is_exhausted() -> bool:
		"""检查是否已枯竭"""
		return status == MineStatus.EXHAUSTED

	func get_visual_status() -> String:
		"""获取视觉状态"""
		match status:
			MineStatus.UNDISCOVERED:
				return "undiscovered"
			MineStatus.ACTIVE:
				match mining_status:
					MiningStatus.AVAILABLE:
						return "normal"
					MiningStatus.BUSY:
						return "busy"
					MiningStatus.FULL:
						return "full"
					_:
						return "normal"
			MineStatus.EXHAUSTED:
				return "exhausted"
			_:
				return "unknown"
			_:
				return "unknown"


# 配置参数
var config = {
	"discovery_chance": 0.08, # 8%概率发现金矿
	"initial_gold": 500, # 初始黄金储量
	"mining_rate": 2, # 每秒挖掘2金币
	"carry_capacity": 20, # 携带容量
	"mine_radius": 100.0, # 金矿检测半径
	"max_mines": 50 # 最大金矿数量
}

# 金矿存储
var gold_mines: Array[GoldMine] = []
var mine_counter: int = 0

# 可达金矿缓存（方案2：预计算+缓存）
var reachable_mines_cache: Dictionary = {} # {mine_id: bool} 金矿是否可达
var last_cache_update_time: float = 0.0
var cache_dirty: bool = true

# 节点引用
@onready var tile_manager = get_node("/root/Main/TileManager")
@onready var character_manager = get_node("/root/Main/CharacterManager")


func _ready():
	"""初始化金矿管理器"""
	# 延迟生成金矿，等待地图生成完成
	call_deferred("_initialize_mines")


func _initialize_mines():
	"""初始化金矿系统"""
	# 等待足够的时间确保地图生成完成
	# 地图生成是异步的，需要等待多帧
	for i in range(5):
		await get_tree().process_frame
	# 在现有地图上生成金矿
	_generate_initial_mines()


func _generate_initial_mines():
	"""扫描现有金矿瓦片并创建对应的逻辑金矿对象"""
	# 🔧 [修复] 初始扫描前也要清空，避免重复
	gold_mines.clear()
	_scan_gold_mines()

func rescan_gold_mines():
	"""重新扫描金矿（地图生成完成后调用）"""
	# 🔧 [修复] 清空旧数据，避免重复注册
	gold_mines.clear()
	_scan_gold_mines()

func _scan_gold_mines():
	"""扫描金矿瓦片的核心逻辑"""
	if not tile_manager:
		LogManager.error("GoldMineManager - TileManager未初始化")
		return

	var map_size = tile_manager.get_map_size()
	var found_mines = 0
	var scanned_tiles = 0

	# 扫描整个地图寻找金矿瓦片（新坐标系：Y=0.05为地面表面）
	for x in range(int(map_size.x)):
		for z in range(int(map_size.z)):
			var pos = Vector3(x, 0.05, z) # 新坐标系
			var tile_data = tile_manager.get_tile_data(pos)
			scanned_tiles += 1
			
			if tile_data and tile_data.type == TileTypes.TileType.GOLD_MINE:
				# 找到金矿瓦片，创建对应的逻辑金矿对象
				_create_gold_mine_from_tile(pos, tile_data)
				found_mines += 1
	
	# 预计算金矿可达性
	_precompute_mine_reachability()


func _precompute_mine_reachability():
	"""预计算所有金矿的可达性（基于洪水填充算法）"""
	reachable_mines_cache.clear()
	
	# 1. 从地牢之心开始洪水填充，找到所有可达区域
	var reachable_positions = _flood_fill_from_dungeon_heart()
	
	var reachable_count = 0
	var unreachable_count = 0
	
	# 2. 检查每个金矿周围是否有至少一个可达位置
	for mine in gold_mines:
		var mine_x = int(mine.position.x)
		var mine_z = int(mine.position.z)
		var is_reachable = false
		
		# 检查金矿8个方向的相邻位置
		var adjacent_offsets = [
			Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1),
			Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)
		]
		
		for offset in adjacent_offsets:
			var adj_pos = Vector2i(mine_x + offset.x, mine_z + offset.y)
			if reachable_positions.has(adj_pos):
				is_reachable = true
				break
		
		reachable_mines_cache[mine.mine_id] = is_reachable
		
		if is_reachable:
			reachable_count += 1
		else:
			unreachable_count += 1
	
	cache_dirty = false
	last_cache_update_time = Time.get_ticks_msec()

func _flood_fill_from_dungeon_heart() -> Dictionary:
	"""从地牢之心开始洪水填充，返回所有可达位置（XZ平面）
	
	返回：Dictionary，key为Vector2i位置，value为true
	"""
	if not tile_manager:
		return {}
	
	# 1. 找到地牢之心位置（地图中心）
	var map_size = tile_manager.get_map_size()
	var dungeon_heart_x = int(map_size.x / 2)
	var dungeon_heart_z = int(map_size.z / 2)
	
	# 2. BFS洪水填充 - 从地牢之心周围的可通行位置开始
	var reachable: Dictionary = {} # Vector2i -> bool
	var queue: Array[Vector2i] = []
	
	# [修复] 地牢之心是2x2建筑，扫描周围更大范围（9x9）
	# 确保能覆盖所有可通行的相邻格子
	for dx in range(-4, 5):
		for dz in range(-4, 5):
			var start_pos = Vector2i(dungeon_heart_x + dx, dungeon_heart_z + dz)
			
			# 检查是否在地图范围内
			if start_pos.x < 0 or start_pos.x >= map_size.x:
				continue
			if start_pos.y < 0 or start_pos.y >= map_size.z:
				continue
			
			var world_pos = Vector3(start_pos.x, 0, start_pos.y)
			if tile_manager.is_walkable(world_pos):
				queue.append(start_pos)
				reachable[start_pos] = true
	
	# 8个方向
	var directions = [
		Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1),
		Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)
	]
	
	while not queue.is_empty():
		var current = queue.pop_front()
		
		# 检查8个相邻位置
		for dir in directions:
			var next_pos = current + dir
			
			# 跳过已访问的位置
			if reachable.has(next_pos):
				continue
			
			# 检查边界
			if next_pos.x < 0 or next_pos.x >= map_size.x or next_pos.y < 0 or next_pos.y >= map_size.z:
				continue
			
			# 检查是否可通行
			var world_pos = Vector3(next_pos.x, 0, next_pos.y)
			if tile_manager.is_walkable(world_pos):
				reachable[next_pos] = true
				queue.append(next_pos)
	
	return reachable

func _check_mine_has_adjacent_walkable(mine: GoldMine) -> bool:
	"""检查金矿周围是否有可通行位置（XZ平面，检查8个方向）"""
	if not tile_manager:
		return false
	
	var mine_x = int(mine.position.x)
	var mine_z = int(mine.position.z)
	
	# 检查8个方向（上下左右+对角线）
	var adjacent_positions = [
		Vector2i(mine_x - 1, mine_z), # 左
		Vector2i(mine_x + 1, mine_z), # 右
		Vector2i(mine_x, mine_z - 1), # 上
		Vector2i(mine_x, mine_z + 1), # 下
		Vector2i(mine_x - 1, mine_z - 1), # 左上
		Vector2i(mine_x - 1, mine_z + 1), # 左下
		Vector2i(mine_x + 1, mine_z - 1), # 右上
		Vector2i(mine_x + 1, mine_z + 1) # 右下
	]
	
	for adj_pos in adjacent_positions:
		# XZ平面检查：Y坐标任意（这里用0）
		var check_pos = Vector3(adj_pos.x, 0, adj_pos.y)
		if tile_manager.is_walkable(check_pos):
			return true
	
	return false

func get_all_gold_mines() -> Array[GoldMine]:
	"""获取所有金矿列表"""
	return gold_mines

func get_reachable_mines_in_radius(center: Vector3, radius: float) -> Array[GoldMine]:
	"""获取指定半径内的可达金矿（使用缓存）"""
	var reachable_mines: Array[GoldMine] = []
	
	# 如果缓存脏了，重新计算
	if cache_dirty:
		_precompute_mine_reachability()
	
	for mine in gold_mines:
		# XZ平面距离
		var xz_distance = Vector2(center.x - mine.position.x, center.z - mine.position.z).length()
		if xz_distance <= radius:
			# 检查缓存：该金矿是否可达
			if reachable_mines_cache.get(mine.mine_id, false):
				reachable_mines.append(mine)
	
	return reachable_mines

func mark_cache_dirty():
	"""标记缓存为脏（地形变化时调用）"""
	cache_dirty = true

func is_mine_reachable(mine: GoldMine) -> bool:
	"""检查金矿是否可达（使用缓存）"""
	if cache_dirty:
		_precompute_mine_reachability()
	return reachable_mines_cache.get(mine.mine_id, false)

func _is_valid_mine_position(pos: Vector3) -> bool:
	"""检查是否是有效的金矿位置"""
	if not tile_manager:
		return false

	var tile_data = tile_manager.get_tile_data(pos)
	if not tile_data:
		# 静默跳过没有瓦块数据的位置，避免日志过多
		return false

	# 必须是石质地面或未挖掘区域
	if tile_data.type != TileTypes.TileType.STONE_FLOOR and tile_data.type != TileTypes.TileType.UNEXCAVATED:
		return false

	# 检查周围是否有其他金矿（最小距离）
	var min_distance = 5
	for mine in gold_mines:
		if pos.distance_to(mine.position) < min_distance:
			return false

	return true


func _create_gold_mine(pos: Vector3):
	"""创建金矿"""
	var mine = GoldMine.new(pos, config.initial_gold)
	gold_mines.append(mine)

	# 更新地块类型为金矿
	tile_manager.set_tile_type(pos, TileTypes.TileType.GOLD_MINE)

func _create_gold_mine_from_tile(pos: Vector3, tile_data):
	"""从现有金矿瓦片创建逻辑金矿对象"""
	# 获取瓦片中的黄金储量
	var gold_amount = config.initial_gold
	if tile_data.resources.has("gold_amount"):
		gold_amount = tile_data.resources["gold_amount"]
	
	var mine = GoldMine.new(pos, gold_amount)
	# 自动激活金矿（从瓦片创建的金矿默认已发现且激活）
	mine.discovered = true
	mine.status = MineStatus.ACTIVE
	gold_mines.append(mine)


func discover_mine(pos: Vector3) -> GoldMine:
	"""发现金矿"""
	for mine in gold_mines:
		if mine.position.distance_to(pos) < 1.0:
			if not mine.discovered:
				mine.discovered = true
				mine.status = MineStatus.ACTIVE
				return mine
	return null


func get_nearest_available_mine(position: Vector3, max_distance: float = 100.0) -> GoldMine:
	"""获取最近的可挖掘金矿"""
	var nearest_mine: GoldMine = null
	var min_distance = max_distance

	for mine in gold_mines:
		if mine.can_accept_miner():
			var distance = position.distance_to(mine.position)
			if distance < min_distance:
				min_distance = distance
				nearest_mine = mine

	return nearest_mine


func assign_miner_to_mine(miner, mine: GoldMine) -> bool:
	"""将挖掘者分配到金矿"""
	if mine.add_miner(miner):
		return true
	return false


func remove_miner_from_mine(miner, mine: GoldMine):
	"""从金矿移除挖掘者"""
	mine.remove_miner(miner)


func mine_gold_at_position(position: Vector3, amount: int) -> int:
	"""在指定位置挖掘黄金"""
	for mine in gold_mines:
		if mine.position.distance_to(position) < 1.0:
			return mine.mine_gold(amount)
	return 0


func get_mine_at_position(position: Vector3) -> GoldMine:
	"""获取指定位置的金矿"""
	for mine in gold_mines:
		if mine.position.distance_to(position) < 1.0:
			return mine
	return null


func get_mine_statistics() -> Dictionary:
	"""获取金矿统计信息"""
	var stats = {
		"total_mines": gold_mines.size(),
		"discovered_mines": 0,
		"active_mines": 0,
		"exhausted_mines": 0,
		"total_gold": 0,
		"remaining_gold": 0
	}

	for mine in gold_mines:
		if mine.discovered:
			stats.discovered_mines += 1

		match mine.status:
			MineStatus.ACTIVE:
				stats.active_mines += 1
			MineStatus.EXHAUSTED:
				stats.exhausted_mines += 1

		stats.total_gold += mine.max_gold
		stats.remaining_gold += mine.gold_amount

	return stats


func get_mines_in_radius(center: Vector3, radius: float) -> Array[GoldMine]:
	"""获取指定半径内的金矿"""
	var nearby_mines: Array[GoldMine] = []

	for mine in gold_mines:
		if center.distance_to(mine.position) <= radius:
			nearby_mines.append(mine)

	return nearby_mines


func update_mine_visuals():
	"""更新金矿视觉效果"""
	for mine in gold_mines:
		_update_mine_visual(mine)


func _update_mine_visual(mine: GoldMine):
	"""更新单个金矿的视觉效果"""
	if not tile_manager:
		return

	var tile_data = tile_manager.get_tile_data(mine.position)
	if not tile_data:
		return

		# 根据状态更新地块外观
	match mine.status:
		MineStatus.UNDISCOVERED:
			# 未发现的金矿显示为普通石质地面
			tile_manager.set_tile_type(mine.position, TileTypes.TileType.STONE_FLOOR)
		MineStatus.ACTIVE:
			# 活跃的金矿显示为金矿地块
			tile_manager.set_tile_type(mine.position, TileTypes.TileType.GOLD_MINE)
		MineStatus.EXHAUSTED:
			# 枯竭的金矿显示为棕色地面
			tile_manager.set_tile_type(mine.position, TileTypes.TileType.DIRT_FLOOR)


func cleanup_exhausted_mines():
	"""清理已枯竭的金矿"""
	var active_mines: Array[GoldMine] = []

	for mine in gold_mines:
		if not mine.is_exhausted():
			active_mines.append(mine)

	gold_mines = active_mines


func _process(_delta):
	"""每帧更新"""
	# 定期清理枯竭的金矿
	if randf() < 0.001: # 0.1%概率每帧清理
		cleanup_exhausted_mines()


# 调试功能
func debug_print_mines():
	"""调试：打印所有金矿信息"""
	# 调试功能已移除，减少日志输出
	pass


func get_debug_info() -> String:
	"""获取调试信息"""
	var stats = get_mine_statistics()
	return (
		"金矿总数: "
		+ str(stats.total_mines)
		+" 已发现: "
		+ str(stats.discovered_mines)
		+" 活跃: "
		+ str(stats.active_mines)
		+" 枯竭: "
		+ str(stats.exhausted_mines)
		+" 剩余黄金: "
		+ str(stats.remaining_gold)
	)


# ==================== [策略3] 工作位置分配系统 ====================

func assign_mining_position(worker_id: int, mine: GoldMine, worker_position: Vector3) -> Vector3:
	"""为矿工分配采矿工作位置
	
	【目标分散系统】避免多个矿工挤在同一个采矿点
	
	参数：
		worker_id: 矿工的唯一ID（通常用instance_id）
		mine: 金矿对象
		worker_position: 矿工当前位置
	
	返回：
		分配的工作位置（格子中心坐标）
		如果没有空位，返回null
	"""
	if not mine:
		return Vector3.ZERO
	
	# 如果该矿工已经分配了位置，返回已有位置
	if mine.assigned_slots.has(worker_id):
		var slot_index = mine.assigned_slots[worker_id]
		if slot_index < mine.work_slots.size():
			return mine.work_slots[slot_index]
	
	# 初始化工作位置（如果还没有）
	if mine.work_slots.is_empty():
		mine.work_slots = _generate_work_slots(mine.position)
	
	# 找到未被占用的位置（优先分配最近的）
	var best_slot = null
	var best_slot_index = -1
	var min_distance = INF
	
	for i in range(mine.work_slots.size()):
		# 检查是否已被占用
		var is_occupied = false
		for assigned_worker_id in mine.assigned_slots.keys():
			if mine.assigned_slots[assigned_worker_id] == i:
				is_occupied = true
				break
		
		if not is_occupied:
			# 空位，计算距离
			var dist = worker_position.distance_to(mine.work_slots[i])
			if dist < min_distance:
				min_distance = dist
				best_slot = mine.work_slots[i]
				best_slot_index = i
	
	# 分配工作位置
	if best_slot and best_slot_index >= 0:
		mine.assigned_slots[worker_id] = best_slot_index
		return best_slot
	
	# 没有空位
	LogManager.warning("⚠️ [金矿管理器] 金矿(%s)没有空闲工作位置（%d/%d已占用）" % [
		str(mine.position),
		mine.assigned_slots.size(),
		mine.work_slots.size()
	])
	return Vector3.ZERO

func release_mining_position(worker_id: int, mine: GoldMine):
	"""释放矿工的工作位置
	
	参数：
		worker_id: 矿工ID
		mine: 金矿对象
	"""
	if not mine:
		return
	
	if mine.assigned_slots.has(worker_id):
		var slot_index = mine.assigned_slots[worker_id]
		mine.assigned_slots.erase(worker_id)

func _generate_work_slots(mine_pos: Vector3) -> Array:
	"""生成金矿周围的工作位置（最多8个）
	
	返回：可通行的工作位置数组
	"""
	var tm = GameServices.tile_manager
	if not tm:
		LogManager.warning("⚠️ [金矿管理器] TileManager未就绪，无法生成工作位置")
		return []
	
	var mine_x = int(round(mine_pos.x))
	var mine_z = int(round(mine_pos.z))
	
	# 8个方向（优先4个正方向）
	var offsets = [
		Vector2i(0, -1), # 上
		Vector2i(0, 1), # 下
		Vector2i(-1, 0), # 左
		Vector2i(1, 0), # 右
		Vector2i(-1, -1), # 左上
		Vector2i(-1, 1), # 左下
		Vector2i(1, -1), # 右上
		Vector2i(1, 1) # 右下
	]
	
	var slots = []
	for offset in offsets:
		var check_x = mine_x + offset.x
		var check_z = mine_z + offset.y
		var check_pos = Vector3(check_x, 0, check_z)
		
		# 检查该位置是否可通行
		if tm.is_walkable(check_pos):
			# [修复 V2] 工作位置应该在格子中心附近，略微朝向金矿
			# 策略：格子中心 + 朝向金矿的小偏移
			# 
			# 例如：金矿(50,50)，工作格(50,49)
			# - 格子中心：(50, 0.05, 49)
			# - 朝向金矿方向：(0, 0, 1)
			# - 工作位置：(50, 0.05, 49.3) ← 略微朝向金矿
			var cell_center_x = float(check_x)
			var cell_center_z = float(check_z)
			
			# 计算朝向金矿的方向（单位化）
			var direction_x = 0.0 if offset.x == 0 else float(offset.x)
			var direction_z = 0.0 if offset.y == 0 else float(offset.y)
			
			# 归一化方向（对角线）
			var dir_length = sqrt(direction_x * direction_x + direction_z * direction_z)
			if dir_length > 0:
				direction_x /= dir_length
				direction_z /= dir_length
			
			# 工作位置 = 格子中心 + 朝向金矿的小偏移（0.3格）
			var approach_distance = 0.3 # 朝向金矿靠近0.3格
			var work_x = cell_center_x + direction_x * approach_distance
			var work_z = cell_center_z + direction_z * approach_distance
			
			slots.append(Vector3(work_x, 0.05, work_z))
	
	return slots

func clear_all_mines():
	"""清空所有金矿"""
	LogManager.info("GoldMineManager - 清空所有金矿...")
	
	# 清空金矿列表
	gold_mines.clear()
	
	# 清空缓存
	reachable_mines_cache.clear()
	
	LogManager.info("GoldMineManager - 所有金矿已清空")
