extends Node
class_name MiningManager

# 预加载必要的类型
const TileManager = preload("res://scripts/managers/TileManager.gd")
const ResourceManagerClass = preload("res://scripts/managers/resource/ResourceManager.gd")

# 挖矿管理器 - 统一管理所有挖矿相关的操作
# 参考MINING_SYSTEM.md GOLD_SYSTEM.md 设计

# 挖矿状态枚举
enum MiningState {
	IDLE, # 空闲
	SEARCHING, # 寻找矿脉
	MOVING_TO_MINE, # 移动到矿脉
	MINING, # 挖掘
	RETURNING, # 返回基地
	STORING, # 存储资源
	FLEEING # 逃跑
}

# 矿脉类型枚举
enum MineType {
	GOLD, # 金矿
	STONE, # 石矿
	IRON, # 铁矿
	MANA_CRYSTAL # 法力水晶
}

# 矿脉数据结构
class MineNode:
	var position: Vector2i
	var mine_type: MineType
	var total_reserves: int
	var current_reserves: int
	var is_discovered: bool = false
	var is_being_mined: bool = false
	var mining_units: Array[int] = [] # 正在挖掘的单位ID
	var discovery_time: float = 0.0
	
	func _init(pos: Vector2i, type: MineType, reserves: int):
		position = pos
		mine_type = type
		total_reserves = reserves
		current_reserves = reserves
	
	func is_exhausted() -> bool:
		return current_reserves <= 0
	
	func get_mining_efficiency() -> float:
		# 根据挖掘单位数量计算效率（最多3个单位）
		var unit_count = mining_units.size()
		if unit_count == 0:
			return 0.0
		elif unit_count == 1:
			return 1.0
		elif unit_count == 2:
			return 1.5
		else:
			return 2.0 # 3个或更多单位时效率为2.0

# 单位挖矿数据
class UnitMiningData:
	var unit_id: int
	var character: CharacterBase # 新架构：直接使用 CharacterBase
	var mining_state: MiningState = MiningState.IDLE
	var current_mine: MineNode = null
	var carried_resources: Dictionary = {} # 携带的资源
	var mining_speed: float = 2.0 # 每秒挖掘数量
	var carry_capacity: int = 20 # 携带容量
	var search_radius: int = 50 # 搜索半径
	var last_activity_time: float = 0.0
	
	func _init(id: int, character_ref: CharacterBase):
		unit_id = id
		character = character_ref
		_initialize_carried_resources()
	
	func _initialize_carried_resources():
		"""初始化携带资源"""
		carried_resources = {
			MineType.GOLD: 0,
			MineType.STONE: 0,
			MineType.IRON: 0,
			MineType.MANA_CRYSTAL: 0
		}
	
	func get_total_carried() -> int:
		"""获取总携带量"""
		var total = 0
		for amount in carried_resources.values():
			total += amount
		return total
	
	func is_carrying_full() -> bool:
		"""检查是否携带满"""
		return get_total_carried() >= carry_capacity
	
	func can_carry_more(amount: int) -> bool:
		"""检查是否可以携带更多资源"""
		return get_total_carried() + amount <= carry_capacity

# 挖矿配置
var mining_config = {
	"gold_mine_probability": 0.016, # 1.6%概率生成金矿
	"gold_mine_reserves": 500, # 金矿储量
	"stone_mine_reserves": 1000, # 石矿储量
	"iron_mine_reserves": 300, # 铁矿储量
	"mana_crystal_reserves": 200, # 法力水晶储量
	"discovery_radius": 5, # 发现矿脉的搜索半径
	"max_mining_units_per_mine": 3, # 每个矿脉最多挖掘单位数
	"mining_efficiency_decay": 0.1 # 多人挖掘效率衰减
}

# 数据存储
var unit_mining_data: Dictionary = {} # 单位挖矿数据
var mine_nodes: Dictionary = {} # 矿脉节点
var resource_manager: ResourceManager = null
var tile_manager: TileManager = null

# 性能优化
var mining_update_queue: Array[UnitMiningData] = []
var max_updates_per_frame: int = 5


func _ready():
	"""初始化挖矿管理器"""
	LogManager.info("MiningManager - 挖矿管理器初始化")
	set_process(true)


func _process(delta: float):
	"""更新挖矿系统"""
	_update_mining_activities(delta)
	_process_mining_queue(delta)


func register_mining_unit(unit_id: int, character: CharacterBase, mining_speed: float = 2.0, carry_capacity: int = 20):
	"""注册挖矿单位"""
	if unit_id in unit_mining_data:
		LogManager.warning("单位 " + str(unit_id) + " 已存在于挖矿管理器中")
		return
	
	var mining_data = UnitMiningData.new(unit_id, character)
	mining_data.mining_speed = mining_speed
	mining_data.carry_capacity = carry_capacity
	unit_mining_data[unit_id] = mining_data
	
	
func unregister_mining_unit(unit_id: int):
	"""注销挖矿单位"""
	if unit_id in unit_mining_data:
		var mining_data = unit_mining_data[unit_id]
		
		# 如果正在挖掘，从矿脉中移除
		if mining_data.current_mine:
			mining_data.current_mine.mining_units.erase(unit_id)
			if mining_data.current_mine.mining_units.is_empty():
				mining_data.current_mine.is_being_mined = false
		
		unit_mining_data.erase(unit_id)
		

func start_mining(unit_id: int) -> bool:
	"""开始挖矿"""
	if not unit_id in unit_mining_data:
		LogManager.error("单位 " + str(unit_id) + " 未注册到挖矿管理器")
		return false
	
	var mining_data = unit_mining_data[unit_id]
	mining_data.mining_state = MiningState.SEARCHING
	mining_data.last_activity_time = Time.get_ticks_msec()
	
	# 添加到更新队列
	if mining_data not in mining_update_queue:
		mining_update_queue.append(mining_data)
	
	return true


func stop_mining(unit_id: int):
	"""停止挖矿"""
	if unit_id in unit_mining_data:
		var mining_data = unit_mining_data[unit_id]
		mining_data.mining_state = MiningState.IDLE
		
		# 从矿脉中移除
		if mining_data.current_mine:
			mining_data.current_mine.mining_units.erase(unit_id)
			if mining_data.current_mine.mining_units.is_empty():
				mining_data.current_mine.is_being_mined = false
			mining_data.current_mine = null


func discover_mine_at_position(position: Vector2i) -> MineNode:
	"""在指定位置发现矿脉"""
	# 检查是否已经存在矿脉
	if position in mine_nodes:
		return mine_nodes[position]
	
	# 根据概率生成矿脉
	var mine_type = _determine_mine_type(position)
	if mine_type == null:
		return null
	
	var reserves = _get_mine_reserves(mine_type)
	var mine_node = MineNode.new(position, mine_type, reserves)
	mine_node.is_discovered = true
	mine_node.discovery_time = Time.get_ticks_msec()
	
	mine_nodes[position] = mine_node
	LogManager.info("发现矿脉: " + str(mine_type) + " 位置: " + str(position) + " 储量: " + str(reserves))
	
	return mine_node


func _determine_mine_type(position: Vector2i):
	"""确定矿脉类型"""
	var rand_value = randf()
	
	# 根据概率分布确定矿脉类型
	if rand_value < mining_config.gold_mine_probability:
		return MineType.GOLD
	elif rand_value < mining_config.gold_mine_probability + 0.05: # 5%概率石矿
		return MineType.STONE
	elif rand_value < mining_config.gold_mine_probability + 0.06: # 1%概率铁矿
		return MineType.IRON
	elif rand_value < mining_config.gold_mine_probability + 0.07: # 1%概率法力水晶
		return MineType.MANA_CRYSTAL
	
	return null # 没有矿脉


func _get_mine_reserves(mine_type: MineType) -> int:
	"""获取矿脉储量"""
	match mine_type:
		MineType.GOLD:
			return mining_config.gold_mine_reserves
		MineType.STONE:
			return mining_config.stone_mine_reserves
		MineType.IRON:
			return mining_config.iron_mine_reserves
		MineType.MANA_CRYSTAL:
			return mining_config.mana_crystal_reserves
		_:
			return 0


func _update_mining_activities(delta: float):
	"""更新所有挖矿活动"""
	for unit_id in unit_mining_data:
		var mining_data = unit_mining_data[unit_id]
		_update_unit_mining(mining_data, delta)


func _update_unit_mining(mining_data: UnitMiningData, delta: float):
	"""更新单个单位的挖矿活动"""
	if not is_instance_valid(mining_data.character):
		unregister_mining_unit(mining_data.unit_id)
		return
	
	match mining_data.mining_state:
		MiningState.SEARCHING:
			_handle_searching_state(mining_data)
		MiningState.MOVING_TO_MINE:
			_handle_moving_to_mine_state(mining_data, delta)
		MiningState.MINING:
			_handle_mining_state(mining_data, delta)
		MiningState.RETURNING:
			_handle_returning_state(mining_data, delta)
		MiningState.STORING:
			_handle_storing_state(mining_data)


func _handle_searching_state(mining_data: UnitMiningData):
	"""处理搜索状态"""
	var current_pos = mining_data.character.get_grid_position()
	var nearest_mine = _find_nearest_mine(current_pos, mining_data.search_radius)
	
	if nearest_mine:
		mining_data.current_mine = nearest_mine
		mining_data.mining_state = MiningState.MOVING_TO_MINE
		
	else:
		# 没有找到矿脉，继续游荡
		mining_data.mining_state = MiningState.IDLE


func _handle_moving_to_mine_state(mining_data: UnitMiningData, delta: float):
	"""处理移动到矿脉状态"""
	if not mining_data.current_mine:
		mining_data.mining_state = MiningState.SEARCHING
		return
	
	var target_pos = mining_data.current_mine.position
	var current_pos = mining_data.character.get_grid_position()
	
	# 检查是否到达矿脉
	if current_pos.distance_to(target_pos) < 1.0:
		# 检查矿脉是否可以挖掘
		if mining_data.current_mine.is_exhausted():
			mining_data.current_mine = null
			mining_data.mining_state = MiningState.SEARCHING
			return
		
		# 检查矿脉是否已满员
		if mining_data.current_mine.mining_units.size() >= mining_config.max_mining_units_per_mine:
			mining_data.current_mine = null
			mining_data.mining_state = MiningState.SEARCHING
			return
		
		# 开始挖掘
		mining_data.current_mine.mining_units.append(mining_data.unit_id)
		mining_data.current_mine.is_being_mined = true
		mining_data.mining_state = MiningState.MINING
		
	else:
		# 🔧 [修复] 使用统一的MovementHelper.process_navigation替代move_to_position
		var target_3d = Vector3(target_pos.x, 0.0, target_pos.y)
		var move_result = MovementHelper.process_navigation(
			mining_data.character,
			target_3d,
			delta,
			"MiningManager.MoveToMine"
		)
		
		# 根据移动结果处理状态
		match move_result:
			MovementHelper.MoveResult.FAILED_NO_PATH, MovementHelper.MoveResult.FAILED_STUCK:
				# 无法到达矿脉，重新搜索
				mining_data.current_mine = null
				mining_data.mining_state = MiningState.SEARCHING
			MovementHelper.MoveResult.REACHED:
				# 已到达矿脉，开始挖掘
				mining_data.mining_state = MiningState.MINING
			MovementHelper.MoveResult.MOVING:
				# 正在移动中
				pass


func _handle_mining_state(mining_data: UnitMiningData, delta: float):
	"""处理挖掘状态"""
	if not mining_data.current_mine or mining_data.current_mine.is_exhausted():
		mining_data.mining_state = MiningState.SEARCHING
		return
	
	# 检查是否携带满
	if mining_data.is_carrying_full():
		mining_data.mining_state = MiningState.RETURNING
		return
	
	# 计算挖掘数量
	var mining_efficiency = mining_data.current_mine.get_mining_efficiency()
	var mining_amount = int(mining_data.mining_speed * delta * mining_efficiency)
	mining_amount = min(mining_amount, mining_data.current_mine.current_reserves)
	mining_amount = min(mining_amount, mining_data.carry_capacity - mining_data.get_total_carried())
	
	if mining_amount > 0:
		# 执行挖掘
		mining_data.current_mine.current_reserves -= mining_amount
		var mine_type = mining_data.current_mine.mine_type
		mining_data.carried_resources[mine_type] += mining_amount
		
		
		# 检查矿脉是否枯竭
		if mining_data.current_mine.is_exhausted():
			LogManager.info("矿脉枯竭: " + str(mining_data.current_mine.position))
			mining_data.current_mine.mining_units.erase(mining_data.unit_id)
			mining_data.current_mine = null
			mining_data.mining_state = MiningState.RETURNING


func _handle_returning_state(mining_data: UnitMiningData, delta: float):
	"""处理返回状态 - 使用统一的MovementHelper API"""
	# 🔧 [修复] 使用统一的MovementHelper.process_navigation替代move_to_position
	var base_position = Vector2i(0, 0) # 地牢之心位置
	var base_3d = Vector3(base_position.x, 0.0, base_position.y)
	
	var move_result = MovementHelper.process_navigation(
		mining_data.character,
		base_3d,
		delta,
		"MiningManager.ReturnToBase"
	)
	
	# 根据移动结果处理状态
	match move_result:
		MovementHelper.MoveResult.FAILED_NO_PATH, MovementHelper.MoveResult.FAILED_STUCK:
			# 无法返回基地，可能基地被摧毁
			mining_data.mining_state = MiningState.SEARCHING
		MovementHelper.MoveResult.REACHED:
			# 已到达基地，开始存储
			mining_data.mining_state = MiningState.STORING
		MovementHelper.MoveResult.MOVING:
			# 正在返回基地
			pass


func _handle_storing_state(mining_data: UnitMiningData):
	"""处理存储状态"""
	# 将携带的资源存储到资源管理器
	if resource_manager:
		for mine_type in mining_data.carried_resources:
			var amount = mining_data.carried_resources[mine_type]
			if amount > 0:
				_store_resource_to_manager(mine_type, amount)
				mining_data.carried_resources[mine_type] = 0
		
		
	# 返回搜索状态
	mining_data.mining_state = MiningState.SEARCHING


func _find_nearest_mine(position: Vector2i, radius: int) -> MineNode:
	"""寻找最近的矿脉"""
	var nearest_mine: MineNode = null
	var nearest_distance = radius
	
	for mine_pos in mine_nodes:
		var mine_node = mine_nodes[mine_pos]
		if mine_node.is_exhausted() or mine_node.mining_units.size() >= mining_config.max_mining_units_per_mine:
			continue
		
		var distance = position.distance_to(mine_pos)
		if distance < nearest_distance:
			nearest_mine = mine_node
			nearest_distance = distance
	
	return nearest_mine


func _store_resource_to_manager(mine_type: MineType, amount: int):
	"""将资源存储到资源管理器"""
	if not resource_manager:
		return
	
	match mine_type:
		MineType.GOLD:
			resource_manager.add_resource(ResourceManagerClass.ResourceType.GOLD, amount)
		MineType.STONE:
			resource_manager.add_resource(ResourceManagerClass.ResourceType.STONE, amount)
		MineType.IRON:
			resource_manager.add_resource(ResourceManagerClass.ResourceType.IRON, amount)
		MineType.MANA_CRYSTAL:
			resource_manager.add_resource(ResourceManagerClass.ResourceType.MANA, amount)


func _process_mining_queue(delta: float):
	"""处理挖矿队列"""
	var processed_count = 0
	while not mining_update_queue.is_empty() and processed_count < max_updates_per_frame:
		var mining_data = mining_update_queue.pop_front()
		if is_instance_valid(mining_data.character_3d):
			_update_unit_mining(mining_data, delta)
		processed_count += 1


func set_resource_manager(rm: ResourceManager):
	"""设置资源管理器引用"""
	resource_manager = rm


func set_tile_manager(tm: TileManager):
	"""设置瓦片管理器引用"""
	tile_manager = tm


func get_mine_at_position(position: Vector2i) -> MineNode:
	"""获取指定位置的矿脉"""
	if position in mine_nodes:
		return mine_nodes[position]
	return null


func get_mining_config() -> Dictionary:
	"""获取挖矿配置"""
	return mining_config.duplicate()


func get_mining_statistics() -> Dictionary:
	"""获取挖矿统计信息"""
	var stats = {
		"total_units": unit_mining_data.size(),
		"active_mines": 0,
		"exhausted_mines": 0,
		"total_reserves": 0
	}
	
	for mine_node in mine_nodes.values():
		if not mine_node.is_exhausted():
			stats.active_mines += 1
		else:
			stats.exhausted_mines += 1
		stats.total_reserves += mine_node.current_reserves
	
	return stats


func cleanup():
	"""清理挖矿管理器"""
	unit_mining_data.clear()
	mine_nodes.clear()
	mining_update_queue.clear()
	LogManager.info("MiningManager - 挖矿管理器清理完成")
