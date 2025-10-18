extends Node
# 地块管理器 - 负责管理地下世界的所有地块
# 基于MAP_DESIGN.md的设计理念实现多层次地下结构
# 使用新的模块化渲染系统

# 依赖注入 - 新的渲染系统
var tile_renderer: TileRenderer
# 🔧 [统一类型] 删除本地枚举，使用 TileTypes autoload

# 地块状态
enum TileState {
	NORMAL, # 正常状态
	HIGHLIGHTED, # 高亮显示
	SELECTED, # 选中状态
	INVALID, # 无效位置
	BUILDING # 建造中
}

# 瓦块高亮选项枚举
enum TileHighlightOption {
	NONE, # 无高亮
	GREEN, # 绿色 - 可以放置
	YELLOW, # 黄色 - 资源不足/空地
	CYAN, # 青色 - 可以挖掘
	RED, # 红色 - 地形问题/不可挖掘
	PURPLE, # 紫色 - 距离过远
	ORANGE, # 橙色 - 位置占用
	BROWN # 棕色 - 其他状态
}

# 地图层级
enum MapLevel {LEVEL_0_MAIN} # 主层 - 主要游戏区域


# 地块数据结构
class TileInfo:
	var type: int # 🔧 [统一类型] 使用 int 类型，对应 TileTypes 常量
	var state: TileState
	var position: Vector3
	var level: MapLevel
	var is_walkable: bool
	var is_buildable: bool
	var is_diggable: bool
	var is_building: bool # 新增：是否为建筑类型
	var is_reachable: bool = false # 🔧 新增：是否从地牢之心可达
	var resources: Dictionary = {}
	var building_data: Dictionary = {}
	var building_ref: Node = null # 🔧 2x2建筑：指向对应的Building对象（如DungeonHeart）
	var tile_object: MeshInstance3D = null # 对应的3D对象
	var highlight_option: TileHighlightOption = TileHighlightOption.NONE # 高亮选项

	func _init(
		pos: Vector3,
		tile_type: int = TileTypes.TileType.EMPTY, # 🔧 [统一类型] 使用 TileTypes 常量
		map_level: MapLevel = MapLevel.LEVEL_0_MAIN
	):
		position = pos
		type = tile_type
		level = map_level
		state = TileState.NORMAL
		is_walkable = false
		is_buildable = false
		is_diggable = false
		is_building = false
		_update_properties()

	func _update_properties():
		match type:
			TileTypes.TileType.EMPTY, \
			TileTypes.TileType.STONE_FLOOR, \
			TileTypes.TileType.DIRT_FLOOR, \
			TileTypes.TileType.MAGIC_FLOOR, \
			TileTypes.TileType.CORRIDOR:
				is_walkable = true
				is_buildable = true
				is_diggable = true
				is_building = false
			TileTypes.TileType.UNEXCAVATED:
				is_walkable = false
				is_buildable = false
				is_diggable = true
				is_building = false
			TileTypes.TileType.STONE_WALL:
				is_walkable = false
				is_buildable = false
				is_diggable = false
				is_building = false
			TileTypes.TileType.GOLD_MINE, \
			TileTypes.TileType.MANA_CRYSTAL:
				# 🔧 [关键修复] 金矿应该可通行！苦工需要站在金矿上挖掘
				is_walkable = true
				is_buildable = false
				is_diggable = false
				is_building = false
			TileTypes.TileType.FOOD_FARM:
				is_walkable = false
				is_buildable = false
				is_diggable = false
				is_building = true # 🔧 修复：食物农场是建筑类型，需要与_is_building_type()一致
			TileTypes.TileType.BARRACKS, \
			TileTypes.TileType.WORKSHOP, \
			TileTypes.TileType.MAGIC_LAB, \
			TileTypes.TileType.DEFENSE_TOWER, \
			TileTypes.TileType.DUNGEON_HEART:
				is_walkable = false
				is_buildable = false
				is_diggable = false
				is_building = true
			TileTypes.TileType.TRAP:
				is_walkable = true
				is_buildable = false
				is_diggable = true
				is_building = false
			TileTypes.TileType.SECRET_PASSAGE:
				is_walkable = true
				is_buildable = false
				is_diggable = true
				is_building = false
			TileTypes.TileType.FOREST, \
			TileTypes.TileType.WASTELAND, \
			TileTypes.TileType.SWAMP, \
			TileTypes.TileType.CAVE:
				# 生态系统类型：可行走，不可建造，不可挖掘，不是建筑
				is_walkable = true
				is_buildable = false
				is_diggable = false
				is_building = false


# 🔧 [统一配置] 使用MapConfig统一配置
var map_size = MapConfig.get_map_size()
var tile_size = MapConfig.get_tile_size()

# 地牢之心配置（从统一配置获取）
var dungeon_heart_reserve_size = MapConfig.get_dungeon_heart_reserve_size()
var dungeon_heart_center_x = int(map_size.x / 2) # 地牢之心中心X坐标
var dungeon_heart_center_z = int(map_size.z / 2) # 地牢之心中心Z坐标

# 高亮颜色映射已移除，现在使用独立的高亮系统

# 地块存储
var tiles = [] # 三维数组 [level][x][z]
var tile_objects = [] # 对应的3D对象

# 节点引用
@onready var world: Node3D = get_node("/root/Main/World")
@onready var dungeon: Node3D = world.get_node("Environment/Dungeon")


func _ready():
	"""初始化地块管理器"""
	LogManager.info("TileManager - 初始化开始")
	
	# 初始化新的渲染系统
	_initialize_rendering_system()
	
	# 检查关键节点是否存在
	if world == null:
		LogManager.error("❌ [TileManager] world节点为空！路径: /root/Main/World")
	else:
		LogManager.info("✅ [TileManager] world节点已找到")
	
	if dungeon == null:
		LogManager.error("❌ [TileManager] dungeon节点为空！路径: /root/Main/World/Environment/Dungeon")
	else:
		LogManager.info("✅ [TileManager] dungeon节点已找到")
	
	_initialize_map_structure()
	# 注意：不在这里生成初始地图，由 MapGenerator 统一管理地图生成
	LogManager.info("TileManager - 初始化完成")

func _initialize_rendering_system():
	"""初始化渲染系统"""
	LogManager.info("🎨 [TileManager] 初始化新的渲染系统...")
	
	# 创建瓦片渲染器
	tile_renderer = TileRenderer.new()
	add_child(tile_renderer)
	
	LogManager.info("✅ [TileManager] 渲染系统初始化完成")

func set_map_size(new_size: Vector3) -> void:
	"""设置地图尺寸并重新初始化地图结构"""
	map_size = new_size
	LogManager.info("TileManager 地图尺寸设置为: " + str(map_size))
	_initialize_map_structure()


func _initialize_map_structure():
	"""初始化地图结构"""
	# 初始化三维数组
	tiles.clear()
	tile_objects.clear()

	for level in range(map_size.y):
		tiles.append([])
		tile_objects.append([])

		for x in range(map_size.x):
			tiles[level].append([])
			tile_objects[level].append([])

			for z in range(map_size.z):
				tiles[level][x].append(null)
				tile_objects[level][x].append(null)


func _generate_initial_map():
	"""生成初始地图"""
	LogManager.info("生成初始地下世界地图...")

	# 生成核心层 (Level 1)
	_generate_core_level()

	# 仅放置地牢之心（不生成通道与资源）
	_place_dungeon_heart()

	LogManager.info("地图生成完成")


func _generate_core_level():
	"""生成核心层地图
	
	🔧 [修改] 默认地块类型改为 EMPTY（而不是 UNEXCAVATED）
	"""
	var level = MapLevel.LEVEL_0_MAIN
	var level_index = int(level)

	LogManager.info("生成核心层地图...")

	for x in range(map_size.x):
		for z in range(map_size.z):
			var pos = Vector3(x, level_index, z)
			# 🔧 修改：默认为 EMPTY（空地），而不是 UNEXCAVATED（未挖掘）
			var tile_data = TileInfo.new(pos, TileTypes.TileType.EMPTY, level) # 🔧 [统一类型] 使用 TileTypes 常量

			tiles[level_index][x][z] = tile_data
			_create_tile_object(tile_data)


# 注意：以下生成函数已移除，因为当前使用单层模式
# 如需多层级支持，可以重新添加这些函数


func _create_initial_corridors():
	"""创建初始通道系统"""
	LogManager.info("创建初始通道系统...")

	# 创建主干道
	_create_main_corridors()

	# 创建支线通道
	_create_branch_corridors()


func _create_main_corridors():
	"""创建主干道"""
	var center_x = int(map_size.x / 2)
	var center_z = int(map_size.z / 2)
	var level_index = int(MapLevel.LEVEL_0_MAIN)

	# 水平主干道
	for x in range(map_size.x):
		var pos = Vector3(x, center_z, level_index)
		_set_tile_type(pos, TileTypes.TileType.CORRIDOR)

	# 垂直主干道
	for z in range(map_size.z):
		var pos = Vector3(center_x, z, level_index)
		_set_tile_type(pos, TileTypes.TileType.CORRIDOR)


func _create_branch_corridors():
	"""创建支线通道"""
	var level_index = int(MapLevel.LEVEL_0_MAIN)

	# 创建一些随机的支线通道
	for i in range(10):
		var start_x = randi() % int(map_size.x)
		var start_z = randi() % int(map_size.z)
		var length = randi() % 8 + 3

		# 随机方向
		var direction = Vector2(randf() - 0.5, randf() - 0.5).normalized()

		for j in range(length):
			var x = int(start_x + direction.x * j)
			var z = int(start_z + direction.y * j)

			if x >= 0 and x < map_size.x and z >= 0 and z < map_size.z:
				var pos = Vector3(x, z, level_index)
				if _get_tile_type(pos) == TileTypes.TileType.STONE_WALL:
					_set_tile_type(pos, TileTypes.TileType.CORRIDOR)


func _place_dungeon_heart():
	"""放置地牢之心
	
	🔧 [修改] 只在地牢之心周围一圈（3x3 外围）设置为 STONE_FLOOR
	"""
	var center_x = int(map_size.x / 2)
	var center_z = int(map_size.z / 2)
	var level_index = int(MapLevel.LEVEL_0_MAIN)

	LogManager.info("放置地牢之心在位置: (" + str(center_x) + ", " + str(center_z) + ")")

	# 地牢之心本身是2x2：(50,50), (50,51), (51,50), (51,51)
	# 不设置瓦片类型，由 main.gd 创建 DungeonHeart 对象时设置
	
	# 🔧 修改：只在地牢之心周围一圈设置为 STONE_FLOOR
	# 3x3外围：从 (-1,-1) 到 (2,2)，排除地牢之心本身的 2x2 区域
	var floor_count = 0
	for dx in range(-1, 3):
		for dz in range(-1, 3):
			# 排除地牢之心本身的 2x2 区域 [(0,0), (0,1), (1,0), (1,1)]
			if dx >= 0 and dx <= 1 and dz >= 0 and dz <= 1:
				continue
			
			var floor_pos = Vector3(center_x + dx, level_index, center_z + dz)
			_set_tile_type(floor_pos, TileTypes.TileType.STONE_FLOOR)
			floor_count += 1
	
	LogManager.info("✅ 地牢之心周围一圈已设置为石质地面（共 %d 个地块）" % floor_count)


func _create_tile_object(tile_data: TileInfo):
	"""创建地块的3D对象（使用新的渲染系统）"""
	var level_index = int(tile_data.level)
	var x = int(tile_data.position.x)
	var z = int(tile_data.position.z)

	# 添加边界检查
	if level_index < 0 or level_index >= tile_objects.size():
		LogManager.warning("⚠️ [TileManager] 边界检查失败: level_index=%d, size=%d" % [level_index, tile_objects.size()])
		return
	if x < 0 or x >= tile_objects[level_index].size():
		LogManager.warning("⚠️ [TileManager] 边界检查失败: x=%d, size=%d" % [x, tile_objects[level_index].size()])
		return
	if z < 0 or z >= tile_objects[level_index][x].size():
		LogManager.warning("⚠️ [TileManager] 边界检查失败: z=%d, size=%d" % [z, tile_objects[level_index][x].size()])
		return

	# 如果已经有对象，先删除
	if tile_objects[level_index][x][z] != null:
		tile_objects[level_index][x][z].queue_free()

		# 检查dungeon节点是否存在
		if dungeon == null:
			LogManager.error("❌ [TileManager] dungeon节点为空！无法添加瓦片对象")
			return
		
	# 使用新的渲染系统创建瓦片对象
	var tile_object = tile_renderer.render_tile(tile_data, dungeon)
	
	if tile_object != null:
		tile_objects[level_index][x][z] = tile_object
		# 只记录前几个瓦片的创建
	else:
		LogManager.error("❌ [TileManager] 无法创建瓦片对象: (%d, %d) 类型: %s" % [x, z, _get_tile_type_name(tile_data.type)])


# 旧的渲染函数已被新的渲染系统替代

func _get_tile_type_name(tile_type: int) -> String:
	"""获取瓦块类型的可读名称（用于调试日志）"""
	# 🔧 [统一类型] 使用 TileTypes.get_tile_name 方法
	return TileTypes.get_tile_name(tile_type)

# 旧的辅助函数已被新的渲染系统替代


# 辅助函数
func _is_center_area(x: int, z: int, radius: int = 5) -> bool:
	"""检查是否是中心区域"""
	var center_x = int(map_size.x / 2)
	var center_z = int(map_size.z / 2)
	return abs(x - center_x) <= radius and abs(z - center_z) <= radius


func _is_border(x: int, z: int) -> bool:
	"""检查是否是边界"""
	return x == 0 or x == map_size.x - 1 or z == 0 or z == map_size.z - 1


func _is_valid_resource_position(pos: Vector3) -> bool:
	"""检查是否是有效的资源位置"""
	# 确保资源点之间有足够的距离
	var min_distance = 3 # 降低距离要求
	var level_index = int(pos.y)

	# 检查level_index是否有效
	if level_index < 0 or level_index >= tiles.size():
		return false

	for dx in range(-min_distance, min_distance + 1):
		for dz in range(-min_distance, min_distance + 1):
			var check_x = int(pos.x) + dx
			var check_z = int(pos.z) + dz

			if check_x >= 0 and check_x < map_size.x and check_z >= 0 and check_z < map_size.z:
				# 检查数组访问是否安全
				if check_x < tiles[level_index].size() and check_z < tiles[level_index][check_x].size():
					var check_tile = tiles[level_index][check_x][check_z]
					if (
						check_tile != null
						and (
							check_tile.type == TileTypes.TileType.GOLD_MINE
							or check_tile.type == TileTypes.TileType.MANA_CRYSTAL
							or check_tile.type == TileTypes.TileType.FOOD_FARM
						)
					):
						return false

	return true


# 公共接口函数
func get_tile_data(position: Vector3) -> TileInfo:
	"""获取指定位置的地块数据"""
	var level_index = int(position.y)
	var x = int(position.x)
	var z = int(position.z)

	if (
		level_index >= 0
		and level_index < map_size.y
		and x >= 0
		and x < map_size.x
		and z >= 0
		and z < map_size.z
	):
		return tiles[level_index][x][z]

	return null


func get_tile_type(position: Vector3) -> int:
	"""获取指定位置的地块类型"""
	var tile_data = get_tile_data(position)
	if tile_data != null:
		return tile_data.type
	return TileTypes.TileType.EMPTY


func set_tile_type(position: Vector3, tile_type: int) -> bool:
	"""设置指定位置的地块类型"""
	var level_index = int(position.y)
	var x = int(position.x)
	var z = int(position.z)

	if (
		level_index >= 0
		and level_index < map_size.y
		and x >= 0
		and x < map_size.x
		and z >= 0
		and z < map_size.z
	):
		var tile_data = tiles[level_index][x][z]
		
		# 🔧 修复：如果瓦片数据为null，创建新的瓦片数据
		if tile_data == null:
			tile_data = TileInfo.new(position, tile_type, MapLevel.LEVEL_0_MAIN)
			tiles[level_index][x][z] = tile_data
			_create_tile_object(tile_data)
			
			# 🔧 [AStarGrid重构] 通知GridPathFinder更新格子状态
			var grid_pos = Vector2i(x, z)
			if GridPathFinder and GridPathFinder.is_ready():
				GridPathFinder.set_cell_walkable(grid_pos, tile_data.is_walkable)
			return true
		
		# 检查是否需要更新类型，避免重复创建相同类型的瓦片
		if tile_data.type != tile_type:
			tile_data.type = tile_type
			tile_data._update_properties()
			_create_tile_object(tile_data)
			
			# 🔧 [AStarGrid重构] 通知GridPathFinder更新格子状态
			var grid_pos = Vector2i(x, z)
			if GridPathFinder and GridPathFinder.is_ready():
				GridPathFinder.set_cell_walkable(grid_pos, tile_data.is_walkable)
		return true

	return false


func _set_tile_type(position: Vector3, tile_type: int):
	"""内部设置地块类型（不检查边界）"""
	var level_index = int(position.y)
	var x = int(position.x)
	var z = int(position.z)

	# 添加边界检查
	if level_index < 0 or level_index >= tiles.size():
		return
	if x < 0 or x >= tiles[level_index].size():
		return
	if z < 0 or z >= tiles[level_index][x].size():
		return

	if tiles[level_index][x][z] != null:
		# 检查是否需要更新类型，避免重复创建相同类型的瓦片
		if tiles[level_index][x][z].type != tile_type:
			tiles[level_index][x][z].type = tile_type
			tiles[level_index][x][z]._update_properties()
			_create_tile_object(tiles[level_index][x][z])


func clear_all_tiles():
	"""清除所有地块"""
	LogManager.info("清除所有地块...")
	
	# 收集所有瓦片数据
	var all_tiles = []
	for level in tiles:
		for row in level:
			for tile_data in row:
				if tile_data:
					all_tiles.append(tile_data)
	
	# 使用新的渲染系统清除所有瓦片
	if tile_renderer:
		tile_renderer.clear_all_tiles(all_tiles)
	
	# 重新初始化地图结构
	_initialize_map_structure()
	
	LogManager.info("所有地块已清除")


func _get_tile_type(position: Vector3) -> int:
	"""内部获取地块类型（不检查边界）"""
	var level_index = int(position.y)
	var x = int(position.x)
	var z = int(position.z)

	# 添加边界检查
	if level_index < 0 or level_index >= tiles.size():
		return TileTypes.TileType.EMPTY
	if x < 0 or x >= tiles[level_index].size():
		return TileTypes.TileType.EMPTY
	if z < 0 or z >= tiles[level_index][x].size():
		return TileTypes.TileType.EMPTY

	if tiles[level_index][x][z] != null:
		return tiles[level_index][x][z].type
	return TileTypes.TileType.EMPTY


func is_walkable(position: Vector3) -> bool:
	"""检查位置是否可通行"""
	var tile_data = get_tile_data(position)
	if tile_data != null:
		return tile_data.is_walkable
	return false

func is_reachable(position: Vector3) -> bool:
	"""检查位置是否从地牢之心可达"""
	var tile_data = get_tile_data(position)
	if tile_data != null:
		return tile_data.is_reachable
	return false

func debug_reachability_at(position: Vector3) -> void:
	"""调试：输出指定位置的可达性信息"""
	var tile_data = get_tile_data(position)
	# 检查地块可达性

func update_tile_reachability():
	"""更新所有地块的可达性标记（从地牢之心开始洪水填充）"""
	LogManager.info("🔄 [TileManager] 更新地块可达性...")
	
	# 1. 重置所有地块的可达性
	for level in tiles:
		for row in level:
			for tile_data in row:
				if tile_data:
					tile_data.is_reachable = false
	
	# 2. 从地牢之心开始洪水填充
	var reachable_positions = _flood_fill_from_dungeon_heart()
	
	# 3. 标记可达地块
	for grid_pos in reachable_positions:
		var world_pos = Vector3(grid_pos.x, 0, grid_pos.y)
		var tile_data = get_tile_data(world_pos)
		if tile_data:
			tile_data.is_reachable = true
	
	LogManager.info("✅ [TileManager] 可达性更新完成，可达地块数: %d" % reachable_positions.size())
	
	return reachable_positions.size()

func _flood_fill_from_dungeon_heart() -> Dictionary:
	"""从地牢之心开始洪水填充，返回所有可达位置
	
	返回：Dictionary {Vector2i -> true}
	"""
	var reachable: Dictionary = {}
	var queue: Array[Vector2i] = []
	
	# 找到地牢之心位置（地图中心）
	var dungeon_heart_x = int(map_size.x / 2)
	var dungeon_heart_z = int(map_size.z / 2)
	
	# 从地牢之心周围9x9区域开始（地牢之心是2x2建筑）
	for dx in range(-4, 5):
		for dz in range(-4, 5):
			var start_pos = Vector2i(dungeon_heart_x + dx, dungeon_heart_z + dz)
			
			# 检查边界
			if start_pos.x < 0 or start_pos.x >= map_size.x:
				continue
			if start_pos.y < 0 or start_pos.y >= map_size.z:
				continue
			
			# 检查是否可通行
			var world_pos = Vector3(start_pos.x, 0, start_pos.y)
			if is_walkable(world_pos):
				queue.append(start_pos)
				reachable[start_pos] = true
	
	# 8个方向
	var directions = [
		Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1),
		Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)
	]
	
	# BFS
	while not queue.is_empty():
		var current = queue.pop_front()
		
		for dir in directions:
			var next_pos = current + dir
			
			# 跳过已访问
			if reachable.has(next_pos):
				continue
			
			# 检查边界
			if next_pos.x < 0 or next_pos.x >= map_size.x or next_pos.y < 0 or next_pos.y >= map_size.z:
				continue
			
			# 检查可通行
			var world_pos = Vector3(next_pos.x, 0, next_pos.y)
			if is_walkable(world_pos):
				reachable[next_pos] = true
				queue.append(next_pos)
	
	return reachable


func is_buildable(position: Vector3) -> bool:
	"""检查位置是否可建造"""
	var tile_data = get_tile_data(position)
	if tile_data != null:
		return tile_data.is_buildable
	return false


func is_diggable(position: Vector3) -> bool:
	"""检查位置是否可挖掘"""
	var tile_data = get_tile_data(position)
	if tile_data != null:
		return tile_data.is_diggable
	return false


func is_summonable(position: Vector3) -> bool:
	"""检查位置是否可以召唤单位（怪物或后勤）"""
	var tile_data = get_tile_data(position)
	if tile_data == null:
		return false
	
	# 允许召唤的瓦片类型：EMPTY，STONE_FLOOR，DIRT_FLOOR，MAGIC_FLOOR
	match tile_data.type:
		TileTypes.TileType.EMPTY:
			return true
		TileTypes.TileType.STONE_FLOOR:
			return true
		TileTypes.TileType.DIRT_FLOOR:
			return true
		TileTypes.TileType.MAGIC_FLOOR:
			return true
		_:
			return false


func get_map_size() -> Vector3:
	"""获取地图尺寸"""
	return map_size


func get_tile_size() -> Vector3:
	"""获取地块尺寸"""
	return tile_size


func set_tile_highlight_option(position: Vector3, highlight_option: TileHighlightOption):
	"""设置瓦块的高亮选项"""
	var tile_data = get_tile_data(position)
	if tile_data != null:
		tile_data.highlight_option = highlight_option
		# 更新状态以保持兼容性
		tile_data.state = TileState.HIGHLIGHTED if highlight_option != TileHighlightOption.NONE else TileState.NORMAL
		_create_tile_object(tile_data) # 重新创建对象以应用高亮效果


func update_tile_highlight(position: Vector3, highlighted: bool):
	"""更新地块高亮状态（兼容性函数，内部调用set_tile_highlight_option）"""
	var highlight_option = TileHighlightOption.NONE if not highlighted else TileHighlightOption.GREEN
	set_tile_highlight_option(position, highlight_option)


func get_tile_highlight_option(position: Vector3) -> TileHighlightOption:
	"""获取瓦块的高亮选项"""
	var tile_data = get_tile_data(position)
	if tile_data != null:
		return tile_data.highlight_option
	return TileHighlightOption.NONE


func clear_tile_highlight(position: Vector3):
	"""清除瓦块的高亮效果"""
	set_tile_highlight_option(position, TileHighlightOption.NONE)


func clear_all_highlights():
	"""清除所有瓦块的高亮效果"""
	for _level in range(tiles.size()):
		for _x in range(tiles[_level].size()):
			for _z in range(tiles[_level][_x].size()):
				var tile_data = tiles[_level][_x][_z]
				if tile_data != null and tile_data.highlight_option != TileHighlightOption.NONE:
					tile_data.highlight_option = TileHighlightOption.NONE
					_create_tile_object(tile_data)


func get_neighboring_tiles(position: Vector3, include_diagonal: bool = false) -> Array:
	"""获取相邻地块"""
	var neighbors = []
	# 注：坐标变量供后续调试使用（如需要）
	var _level_index = int(position.y)
	var _x = int(position.x)
	var _z = int(position.z)

	var directions = [Vector3(-1, 0, 0), Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(0, 0, 1)]

	if include_diagonal:
		directions.append_array(
			[Vector3(-1, 0, -1), Vector3(-1, 0, 1), Vector3(1, 0, -1), Vector3(1, 0, 1)]
		)

	for direction in directions:
		var neighbor_pos = position + direction
		var neighbor_tile = get_tile_data(neighbor_pos)
		if neighbor_tile != null:
			neighbors.append(neighbor_tile)

	return neighbors


func get_tiles_of_type(tile_type: int, level: MapLevel = MapLevel.LEVEL_0_MAIN) -> Array:
	"""获取指定类型的所有地块"""
	var result = []
	var level_index = int(level)

	for x in range(map_size.x):
		for z in range(map_size.z):
			var tile_data = tiles[level_index][x][z]
			if tile_data != null and tile_data.type == tile_type:
				result.append(tile_data)

	return result


func get_tiles_in_radius(
	center: Vector3, radius: int, level: MapLevel = MapLevel.LEVEL_0_MAIN
) -> Array:
	"""获取指定半径内的所有地块"""
	var result = []
	var _level_index = int(level)

	for dx in range(-radius, radius + 1):
		for dz in range(-radius, radius + 1):
			if dx * dx + dz * dz <= radius * radius:
				var pos = Vector3(center.x + dx, center.y, center.z + dz)
				var tile_data = get_tile_data(pos)
				if tile_data != null:
					result.append(tile_data)

	return result


func get_resource_manager() -> Node:
	"""获取资源管理器"""
	# 这里将返回资源管理器的引用
	# 暂时返回null，实际实现时需要正确获取引用
	return null


func cleanup():
	"""清理资源，防止内存泄漏"""
	LogManager.info("TileManager - 开始清理资源")
	
	# 使用新的渲染系统清理所有瓦片
	var all_tiles = []
	for level in tiles:
		for row in level:
			for tile_data in row:
				if tile_data:
					all_tiles.append(tile_data)
	
	if tile_renderer:
		tile_renderer.clear_all_tiles(all_tiles)
	
	# 清理渲染系统
	if tile_renderer:
		tile_renderer.cleanup()
	
	# 清空数组
	tile_objects.clear()
	tiles.clear()
	
	LogManager.info("TileManager - 资源清理完成")


func is_position_walkable(grid_position: Vector2i) -> bool:
	"""检查网格位置是否可通行（用于路径规划）"""
	# 检查是否在地图范围内
	if grid_position.x < 0 or grid_position.x >= map_size.x or grid_position.y < 0 or grid_position.y >= map_size.z:
		return false
	
	# 将Vector2i转换为Vector3进行检查
	var world_position = Vector3(grid_position.x, 0, grid_position.y)
	return is_walkable(world_position)


func get_walkable_neighbors(grid_position: Vector2i) -> Array[Vector2i]:
	"""获取可通行的相邻位置"""
	var neighbors: Array[Vector2i] = []
	var directions = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0), Vector2i(1, 0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)
	]
	
	for direction in directions:
		var neighbor_pos = grid_position + direction
		if is_position_walkable(neighbor_pos):
			neighbors.append(neighbor_pos)
	
	return neighbors


func set_tile_building_ref(position: Vector3, building: Node) -> bool:
	"""设置瓦片的建筑引用（用于2x2等多瓦片建筑）
	
	参数：
		position: 瓦片位置
		building: 建筑对象（如DungeonHeart）
	返回：
		是否设置成功
	"""
	var tile_data = get_tile_data(position)
	if tile_data:
		tile_data.building_ref = building
		return true
	return false

func get_tile_building_ref(position: Vector3) -> Node:
	"""获取瓦片的建筑引用
	
	参数：
		position: 瓦片位置
	返回：
		建筑对象，如果没有则返回null
	"""
	var tile_data = get_tile_data(position)
	if tile_data:
		return tile_data.building_ref
	return null

func debug_render_status() -> void:
	"""调试：检查渲染状态"""
	LogManager.info("=== TileManager 渲染状态调试 ===")
	
	var total_tiles = 0
	var rendered_tiles = 0
	var unexcavated_tiles = 0
	var empty_tiles = 0
	var other_tiles = 0
	
	for level in range(tiles.size()):
		for x in range(tiles[level].size()):
			for z in range(tiles[level][x].size()):
				var tile_data = tiles[level][x][z]
				if tile_data:
					total_tiles += 1
					
					# 检查是否有3D对象
					if tile_objects[level][x][z] != null:
						rendered_tiles += 1
					
					# 统计瓦片类型
					match tile_data.type:
						TileTypes.TileType.UNEXCAVATED:
							unexcavated_tiles += 1
						TileTypes.TileType.EMPTY:
							empty_tiles += 1
						_:
							other_tiles += 1
	
	LogManager.info("总瓦片数: %d" % total_tiles)
	LogManager.info("已渲染瓦片数: %d" % rendered_tiles)
	LogManager.info("未挖掘瓦片数: %d" % unexcavated_tiles)
	LogManager.info("空地瓦片数: %d" % empty_tiles)
	LogManager.info("其他瓦片数: %d" % other_tiles)
	LogManager.info("渲染率: %.1f%%" % ((rendered_tiles / float(total_tiles)) * 100))
	
	# 显示新渲染系统的统计信息
	if tile_renderer:
		var render_stats = tile_renderer.get_render_stats()
		LogManager.info("=== 新渲染系统统计 ===")
		LogManager.info("渲染器统计: %s" % str(render_stats))
		
		var performance_info = tile_renderer.get_performance_info()
		LogManager.info("性能信息: %s" % str(performance_info))
	
	LogManager.info("=== 调试完成 ===")

# ===== 新渲染系统公共接口 =====

func get_rendering_performance_info() -> Dictionary:
	"""获取渲染性能信息"""
	if tile_renderer:
		return tile_renderer.get_performance_info()
	return {}

func optimize_rendering_for_camera(camera_position: Vector3) -> void:
	"""为指定摄像机位置优化渲染"""
	if tile_renderer:
		var all_tiles = []
		for level in tiles:
			for row in level:
				for tile_data in row:
					if tile_data:
						all_tiles.append(tile_data)
		tile_renderer.optimize_rendering(camera_position, all_tiles)

func set_rendering_config(config_name: String, value) -> void:
	"""设置渲染配置"""
	if tile_renderer:
		tile_renderer.set_render_config(config_name, value)

func enable_rendering_debug_mode(enabled: bool) -> void:
	"""启用/禁用渲染调试模式"""
	if tile_renderer:
		tile_renderer.enable_debug_mode(enabled)

func _exit_tree():
	"""节点退出时自动清理"""
	cleanup()

# ============================================================================
# 🔧 [新增] 地牢之心预留区域管理
# ============================================================================

func is_in_dungeon_heart_reserve_area(position: Vector3) -> bool:
	"""检查位置是否在地牢之心预留区域内"""
	var half_reserve = dungeon_heart_reserve_size / 2
	var min_x = dungeon_heart_center_x - half_reserve
	var max_x = dungeon_heart_center_x + half_reserve
	var min_z = dungeon_heart_center_z - half_reserve
	var max_z = dungeon_heart_center_z + half_reserve
	
	return (position.x >= min_x and position.x <= max_x and
			position.z >= min_z and position.z <= max_z)

func get_dungeon_heart_center() -> Vector3:
	"""获取地牢之心中心位置"""
	return Vector3(dungeon_heart_center_x, 0, dungeon_heart_center_z)

func get_dungeon_heart_reserve_area() -> Rect2i:
	"""获取地牢之心预留区域的矩形范围"""
	var half_reserve = dungeon_heart_reserve_size / 2
	return Rect2i(
		dungeon_heart_center_x - half_reserve,
		dungeon_heart_center_z - half_reserve,
		dungeon_heart_reserve_size,
		dungeon_heart_reserve_size
	)
