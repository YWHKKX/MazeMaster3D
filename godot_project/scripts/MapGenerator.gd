extends Node
class_name MapGenerator

## 🗺️ 高级地图生成器 - 基于迷宫生成系统文档设计
## 实现分块系统、噪声生成、四大区域（房间、迷宫、生态、英雄营地）
## 集成autoload数据，消除硬编码，简化配置系统

# ============================================================================
# 区域类型枚举
# ============================================================================

enum RegionType {
	ROOM_SYSTEM, # 房间系统
	MAZE_SYSTEM, # 迷宫系统
	ECOSYSTEM, # 生态系统
	HERO_CAMP_PORTAL # 英雄营地/传送门
}

# ============================================================================
# 生态区域类型
# ============================================================================

enum EcosystemType {
	FOREST, # 森林
	GRASSLAND, # 草地
	LAKE, # 湖泊
	CAVE, # 洞穴
	WASTELAND, # 荒地
	DEAD_LAND # 死地
}

# ============================================================================
# 地图配置类
# ============================================================================

class MapConfig:
	var size: Vector3
	var chunk_size: int = 16 # 分块大小
	var max_room_count: int = 15
	var min_room_size: int = 6
	var max_room_size: int = 15
	var room_connection_attempts: int = 10
	var resource_density: float = 0.1
	var corridor_width: int = 3
	var complexity: float = 0.5

	# 噪声参数
	var noise_scale: float = 0.1
	var height_threshold: float = 0.5
	var humidity_threshold: float = 0.5
	
	# 生态分布参数
	var forest_probability: float = 0.3
	var lake_probability: float = 0.1
	var cave_probability: float = 0.2
	var wasteland_probability: float = 0.1

	func _init(map_size: Vector3 = Vector3(100, 1, 100)):
		size = map_size

# ============================================================================
# 数据结构类
# ============================================================================

## 房间数据结构
class Room:
	var position: Vector2i
	var size: Vector2i
	var center: Vector2i
	var connections: Array = [] # 连接的房间
	var room_id: int
	var room_type: String = "normal"
	var region_type: RegionType = RegionType.ROOM_SYSTEM
	
	func _init(pos: Vector2i, room_size: Vector2i, id: int, type: RegionType = RegionType.ROOM_SYSTEM):
		position = pos
		size = room_size
		center = pos + room_size / 2
		room_id = id
		region_type = type
	
	func get_rect() -> Rect2i:
		return Rect2i(position, size)
	
	func overlaps(other_room: Room) -> bool:
		var rect1 = get_rect()
		var rect2 = other_room.get_rect()
		return rect1.intersects(rect2)
	
	func get_connection_points() -> Array:
		var points = []
		# 获取房间边缘的潜在连接点
		for x in range(position.x, position.x + size.x):
			points.append(Vector2i(x, position.y)) # 上边
			points.append(Vector2i(x, position.y + size.y - 1)) # 下边
		for y in range(position.y, position.y + size.y):
			points.append(Vector2i(position.x, y)) # 左边
			points.append(Vector2i(position.x + size.x - 1, y)) # 右边
		return points

## 分块数据结构
class Chunk:
	var chunk_pos: Vector2i
	var world_pos: Vector2i
	var size: int
	var is_loaded: bool = false
	var tiles: Array = []
	var objects: Array = []
	
	func _init(pos: Vector2i, chunk_size: int):
		chunk_pos = pos
		world_pos = pos * chunk_size
		size = chunk_size

## 生态区域数据结构
class EcosystemRegion:
	var position: Vector2i
	var size: Vector2i
	var ecosystem_type: EcosystemType
	var resource_spawns: Array = []
	var creature_spawns: Array = []
	
	func _init(pos: Vector2i, region_size: Vector2i, eco_type: EcosystemType):
		position = pos
		size = region_size
		ecosystem_type = eco_type

## 英雄营地/传送门数据结构
class HeroCamp:
	var position: Vector2i
	var camp_type: String
	var spawn_waves: Array = []
	var is_active: bool = true
	
	func _init(pos: Vector2i, type: String):
		position = pos
		camp_type = type

# ============================================================================
# 地图生成器核心变量
# ============================================================================

var tile_manager: Node
var character_manager: Node
var ecosystem_manager: Node
var rooms: Array[Room] = []
var room_counter: int = 0

# 分块系统
var chunks: Dictionary = {} # Vector2i -> Chunk
var loaded_chunks: Array[Vector2i] = []
var chunk_size: int = 16

# 噪声生成器
var height_noise: FastNoiseLite
var humidity_noise: FastNoiseLite
var temperature_noise: FastNoiseLite

# 区域管理
var ecosystem_regions: Array[EcosystemRegion] = []
var hero_camps: Array[HeroCamp] = []
var maze_rooms: Array[Room] = []

# 配置参数（从autoload获取）
var config: MapConfig

func _ready():
	"""初始化高级地图生成器"""
	LogManager.info("=== 高级地图生成器初始化开始 ===")
	
	# 获取管理器引用
	tile_manager = get_node("/root/Main/TileManager")
	if tile_manager:
		LogManager.info("TileManager 连接成功")
	else:
		LogManager.error("ERROR: TileManager 未找到")
	
	character_manager = get_node_or_null("/root/Main/CharacterManager")
	if character_manager:
		LogManager.info("CharacterManager 连接成功")
	else:
		LogManager.warning("CharacterManager 未找到，生物生成功能将受限")
	
	# 创建生态系统管理器
	var ecosystem_script = preload("res://scripts/ecosystem/EcosystemManager.gd")
	if not ecosystem_script:
		LogManager.error("ERROR: 无法加载EcosystemManager脚本！")
	else:
		ecosystem_manager = ecosystem_script.new()
		add_child(ecosystem_manager)
		LogManager.info("EcosystemManager 创建成功")
	
	# 初始化噪声生成器
	_initialize_noise_generators()
	
	# 初始化配置
	config = MapConfig.new()
	
	LogManager.info("=== 高级地图生成器初始化完成 ===")

func _initialize_noise_generators():
	"""初始化噪声生成器"""
	# 高度噪声
	height_noise = FastNoiseLite.new()
	height_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	height_noise.seed = randi()
	height_noise.frequency = 0.1
	
	# 湿度噪声
	humidity_noise = FastNoiseLite.new()
	humidity_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	humidity_noise.seed = randi()
	humidity_noise.frequency = 0.08
	
	# 温度噪声
	temperature_noise = FastNoiseLite.new()
	temperature_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	temperature_noise.seed = randi()
	temperature_noise.frequency = 0.12
	
	LogManager.info("噪声生成器初始化完成")

func generate_map(_config: MapConfig) -> void:
	"""生成高级地图 - 基于文档的四步生成流程"""
	LogManager.info("=== 开始生成高级地图系统 ===")

	# 确保 TileManager 已完全初始化
	if not tile_manager:
		LogManager.error("ERROR: TileManager 未找到，无法生成地图")
		return
	
	# 更新配置
	config = _config
	
	# 同步地图尺寸到 TileManager
	if tile_manager.get_map_size and tile_manager.get_map_size() != _config.size:
		if tile_manager.set_map_size:
			tile_manager.set_map_size(_config.size)
			LogManager.info("已将地图尺寸同步到 TileManager: " + str(_config.size))

	# 等待一帧确保 TileManager 完全初始化
	await get_tree().process_frame
	
	# 第一步：初始化地图和分块系统
	LogManager.info("=== 第一步：初始化地图和分块系统 ===")
	_initialize_map_and_chunks(_config)
	
	# 第二步：生成噪声地形
	LogManager.info("=== 第二步：生成噪声地形 ===")
	_generate_noise_terrain(_config)
	
	# 第三步：生成四大区域
	LogManager.info("=== 第三步：生成四大区域 ===")
	_generate_four_regions(_config)
	
	# 第四步：生成资源和生物
	LogManager.info("=== 第四步：生成资源和生物 ===")
	_generate_resources_and_creatures(_config)
	
	LogManager.info("=== 高级地图生成完成 ===")
	
	# 发射地图生成完成事件
	GameEvents.map_generated.emit()
	LogManager.info("✅ 已发射 map_generated 事件")

func _initialize_map_and_chunks(_config: MapConfig) -> void:
	"""第一步：初始化地图和分块系统"""
	
	# 清空现有地图
	_clear_map()
	
	# 重新初始化地图结构
	tile_manager._initialize_map_structure()
	
	# 初始化分块系统
	_initialize_chunk_system(_config)
	
	# 初始化所有地块为UNEXCAVATED（使用autoload常量）
	_initialize_all_tiles_as_unexcavated()

func _initialize_chunk_system(_config: MapConfig) -> void:
	"""初始化分块系统"""
	chunk_size = _config.chunk_size
	chunks.clear()
	loaded_chunks.clear()
	
	var chunk_count_x = int(_config.size.x / chunk_size) + 1
	var chunk_count_z = int(_config.size.z / chunk_size) + 1
	
	LogManager.info("初始化分块系统: %dx%d 分块，每分块 %dx%d" % [chunk_count_x, chunk_count_z, chunk_size, chunk_size])
	
	for x in range(chunk_count_x):
		for z in range(chunk_count_z):
			var chunk_pos = Vector2i(x, z)
			var chunk = Chunk.new(chunk_pos, chunk_size)
			chunks[chunk_pos] = chunk

func _generate_noise_terrain(_config: MapConfig) -> void:
	"""第二步：生成噪声地形"""
	LogManager.info("开始生成噪声地形...")
	
	var map_size_x = int(_config.size.x)
	var map_size_z = int(_config.size.z)
	
	# 更新噪声参数
	height_noise.frequency = _config.noise_scale
	humidity_noise.frequency = _config.noise_scale * 0.8
	temperature_noise.frequency = _config.noise_scale * 1.2
	
	for x in range(map_size_x):
		for z in range(map_size_z):
			var pos = Vector3(x, 0, z)
			
			# 获取噪声值
			var height_value = height_noise.get_noise_2d(x, z)
			var humidity_value = humidity_noise.get_noise_2d(x, z)
			var temperature_value = temperature_noise.get_noise_2d(x, z)
			
			# 根据噪声值确定生态类型
			var ecosystem_type = _determine_ecosystem_type(height_value, humidity_value, temperature_value)
			
			# 设置对应的瓦片类型
			var tile_type = _get_tile_type_for_ecosystem(ecosystem_type)
			tile_manager.set_tile_type(pos, tile_type)
	
	LogManager.info("噪声地形生成完成")

func _determine_ecosystem_type(height: float, humidity: float, temperature: float) -> EcosystemType:
	"""根据噪声值确定生态类型"""
	# 使用文档中的生态分布规则
	if height > config.height_threshold:
		if humidity < config.humidity_threshold:
			return EcosystemType.WASTELAND
		else:
			return EcosystemType.FOREST
	else:
		if humidity < config.humidity_threshold:
			return EcosystemType.CAVE
		else:
			if temperature > 0.3:
				return EcosystemType.LAKE
			else:
				return EcosystemType.GRASSLAND

func _get_tile_type_for_ecosystem(eco_type: EcosystemType) -> int:
	"""根据生态类型获取对应的瓦片类型（使用autoload常量）"""
	match eco_type:
		EcosystemType.FOREST:
			return TileTypes.EMPTY  # 森林 - 空地
		EcosystemType.GRASSLAND:
			return TileTypes.EMPTY  # 草地 - 空地
		EcosystemType.LAKE:
			return TileTypes.WATER  # 湖泊 - 水域
		EcosystemType.CAVE:
			return TileTypes.EMPTY  # 洞穴 - 空地
		EcosystemType.WASTELAND:
			return TileTypes.EMPTY  # 荒地 - 空地
		EcosystemType.DEAD_LAND:
			return TileTypes.EMPTY  # 死地 - 空地
		_:
			return TileTypes.EMPTY
	

func _generate_four_regions(_config: MapConfig) -> void:
	"""第三步：生成四大区域"""
	LogManager.info("开始生成四大区域...")
	
	# 1. 生成房间系统
	_generate_room_system(_config)
	
	# 2. 生成迷宫系统
	_generate_maze_system(_config)
	
	# 3. 生成生态系统
	_generate_ecosystem_regions(_config)
	
	# 4. 生成英雄营地/传送门
	_generate_hero_camps(_config)
	
	LogManager.info("四大区域生成完成")

func _generate_room_system(_config: MapConfig) -> void:
	"""生成房间系统"""
	LogManager.info("生成房间系统...")
	
	# 清空房间列表
	rooms.clear()
	room_counter = 0
	
	# 在地图中心区域生成随机房间
	_generate_random_rooms(_config)
	
	# 连接所有房间
	_connect_rooms()
	
	# 生成地牢之心
	_place_dungeon_heart()
	_create_heart_clearing()

func _generate_maze_system(_config: MapConfig) -> void:
	"""生成迷宫系统"""
	LogManager.info("生成迷宫系统...")
	
	# 使用递归回溯算法生成迷宫
	_generate_maze_with_backtracking(_config)

func _generate_maze_with_backtracking(_config: MapConfig) -> void:
	"""使用递归回溯算法生成迷宫"""
	var maze_width = int(_config.size.x / 2)
	var maze_height = int(_config.size.z / 2)
	var maze_start_x = int(_config.size.x / 4)
	var maze_start_z = int(_config.size.z / 4)
	
	# 初始化迷宫网格
	var maze_grid = []
	for x in range(maze_width):
		maze_grid.append([])
		for z in range(maze_height):
			maze_grid[x].append(1)  # 1表示墙，0表示通道
	
	# 递归回溯算法
	var stack = []
	var start_pos = Vector2i(1, 1)
	stack.append(start_pos)
	maze_grid[start_pos.x][start_pos.y] = 0
	
	while not stack.is_empty():
		var current = stack[-1]
		var neighbors = _get_unvisited_neighbors(current, maze_grid, maze_width, maze_height)
		
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			# 打通墙壁
			var wall_x = current.x + (next.x - current.x) / 2
			var wall_z = current.y + (next.y - current.y) / 2
			maze_grid[wall_x][wall_z] = 0
			maze_grid[next.x][next.y] = 0
			stack.append(next)
		else:
			stack.pop_back()
	
	# 将迷宫应用到地图
	_apply_maze_to_map(maze_grid, maze_start_x, maze_start_z)

func _get_unvisited_neighbors(pos: Vector2i, grid: Array, width: int, height: int) -> Array:
	"""获取未访问的邻居"""
	var neighbors = []
	var directions = [Vector2i(0, 2), Vector2i(2, 0), Vector2i(0, -2), Vector2i(-2, 0)]
	
	for dir in directions:
		var neighbor = pos + dir
		if neighbor.x > 0 and neighbor.x < width - 1 and neighbor.y > 0 and neighbor.y < height - 1:
			if grid[neighbor.x][neighbor.y] == 1:
				neighbors.append(neighbor)
	
	return neighbors

func _apply_maze_to_map(maze_grid: Array, start_x: int, start_z: int) -> void:
	"""将迷宫应用到地图"""
	for x in range(maze_grid.size()):
		for z in range(maze_grid[x].size()):
			var world_pos = Vector3(start_x + x, 0, start_z + z)
			if maze_grid[x][z] == 0:  # 通道
				tile_manager.set_tile_type(world_pos, TileTypes.CORRIDOR)
			else:  # 墙壁
				tile_manager.set_tile_type(world_pos, TileTypes.STONE_WALL)

func _generate_ecosystem_regions(_config: MapConfig) -> void:
	"""生成生态系统区域"""
	LogManager.info("生成生态系统区域...")
	
	# 检查生态系统管理器
	if not ecosystem_manager:
		LogManager.error("ERROR: EcosystemManager 未找到！无法生成生态系统区域")
		return
	
	# 使用生态系统管理器生成区域
	ecosystem_regions = ecosystem_manager.generate_ecosystem_regions(_config.size, 5)
	LogManager.info("生态系统区域生成完成，共生成 %d 个区域" % ecosystem_regions.size())

func _apply_ecosystem_region(region: EcosystemRegion) -> void:
	"""将生态区域应用到地图"""
	for x in range(region.size.x):
		for z in range(region.size.y):
			var world_pos = Vector3(region.position.x + x, 0, region.position.y + z)
			var tile_type = _get_tile_type_for_ecosystem(region.ecosystem_type)
			tile_manager.set_tile_type(world_pos, tile_type)

func _generate_hero_camps(_config: MapConfig) -> void:
	"""生成英雄营地/传送门"""
	LogManager.info("生成英雄营地/传送门...")
	
	hero_camps.clear()
	
	# 在地图边缘和特定位置生成英雄营地
	var camp_count = randi_range(2, 4)
	for i in range(camp_count):
		var camp_pos = Vector2i(
			randi_range(5, int(_config.size.x) - 5),
			randi_range(5, int(_config.size.z) - 5)
		)
		
		# 确保不在中心区域（地牢之心附近）
		var center_x = int(_config.size.x / 2)
		var center_z = int(_config.size.z / 2)
		if camp_pos.distance_to(Vector2i(center_x, center_z)) < 20:
			continue
		
		var camp_type = "hero_camp_" + str(i)
		var camp = HeroCamp.new(camp_pos, camp_type)
		hero_camps.append(camp)
		
		# 在地图上标记传送门
		tile_manager.set_tile_type(Vector3(camp_pos.x, 0, camp_pos.y), TileTypes.PORTAL)

func _generate_resources_and_creatures(_config: MapConfig) -> void:
	"""第四步：生成资源和生物"""
	LogManager.info("生成资源和生物...")
	
	# 生成金矿（使用autoload中的概率和储量）
	_generate_gold_veins(config.resource_density * 0.016, 500)
	
	# 在生态区域生成资源
	for region in ecosystem_regions:
		_generate_ecosystem_resources(region)
	
	# 在英雄营地生成敌对生物
	for camp in hero_camps:
		_generate_hero_camp_creatures(camp)

func _generate_ecosystem_resources(region: EcosystemRegion) -> void:
	"""在生态区域生成资源"""
	match region.ecosystem_type:
		EcosystemType.FOREST:
			# 森林生成树木资源
			pass
		EcosystemType.LAKE:
			# 湖泊生成鱼类资源
			pass
		EcosystemType.CAVE:
			# 洞穴生成矿物资源
			pass

func _generate_hero_camp_creatures(camp: HeroCamp) -> void:
	"""在英雄营地生成敌对生物"""
	# 这里可以生成各种敌对生物
	pass

func _initialize_all_tiles_as_unexcavated() -> void:
	"""初始化所有地块为UNEXCAVATED（使用autoload常量）"""
	
	for x in range(tile_manager.map_size.x):
		for z in range(tile_manager.map_size.z):
			var pos = Vector3(x, 0, z)
			# 使用autoload常量
			var tile_data = tile_manager.TileInfo.new(pos, TileTypes.UNEXCAVATED, tile_manager.MapLevel.LEVEL_0_MAIN)
			var level_index = int(tile_data.level)
			tile_manager.tiles[level_index][x][z] = tile_data
			tile_manager._create_tile_object(tile_data)
			tile_manager.tiles[level_index][x][z].resources = {}
	

func _place_dungeon_heart() -> void:
	"""放置地牢之心及其周围的初始区域（2x2建筑）"""
	var center_x = int(tile_manager.map_size.x / 2)
	var center_z = int(tile_manager.map_size.z / 2)
	var level_index = 0

	LogManager.info("放置地牢之心（2x2）在位置: (" + str(center_x) + ", " + str(center_z) + ")")

	# 使用autoload常量放置2x2地牢之心瓦片
	var dungeon_heart_tiles = []
	for dx in range(2):
		for dz in range(2):
			var pos = Vector3(center_x + dx, level_index, center_z + dz)
			var success = tile_manager.set_tile_type(pos, TileTypes.DUNGEON_HEART)
			if success:
				dungeon_heart_tiles.append(pos)
	
	LogManager.info("✅ 地牢之心2x2瓦片放置成功，共 %d 个瓦片" % dungeon_heart_tiles.size())
	
	# 地牢之心周围保持为 EMPTY 瓦片，允许苦工更接近
	LogManager.info("✅ 地牢之心周围保持为 EMPTY 瓦片，允许单位接近")

func _create_heart_clearing() -> void:
	"""创建地牢之心周围的清理区域，强制修改为EMPTY"""
	var center_x = int(tile_manager.map_size.x / 2)
	var center_z = int(tile_manager.map_size.z / 2)
	
	# 创建 7x7 的清理区域（2x2 地牢之心 + 周围一圈）
	var radius = 3 # 7x7 区域，半径 3
	for dx in range(-radius, radius + 1):
		for dz in range(-radius, radius + 1):
			var pos = Vector3(center_x + dx, 0, center_z + dz)
			
			# 跳过地牢之心占用的 2x2 区域
			if dx >= 0 and dx <= 1 and dz >= 0 and dz <= 1:
				continue
			
			# 使用autoload常量强制设置为EMPTY
			tile_manager.set_tile_type(pos, TileTypes.EMPTY)
	

func _generate_rooms_on_map(_config: MapConfig) -> void:
	"""第二步：在地图上生成房间"""
	
	# 根据地图类型调整参数
	_adjust_config_for_type(_config)
	
	# 清空房间列表
	rooms.clear()
	room_counter = 0
	
	# 在地图中心25x25区域内生成随机房间
	_generate_random_rooms(_config)
	
	# 连接所有房间
	_connect_rooms()
	
	# 最后生成地牢之心，并将周围区域强制修改为EMPTY
	_place_dungeon_heart()
	_create_heart_clearing()

	# 依据 MINING_SYSTEM.md：在未挖掘岩石中生成金矿（约1.6% 概率，每脉500单位）
	_generate_gold_veins(0.016, 500)
	

func _generate_random_rooms(_config: MapConfig) -> void:
	"""在地图中心25x25区域内生成随机房间"""
	
	var room_count = randi_range(5, _config.max_room_count)
	var max_attempts = room_count * 20
	var attempts = 0
	
	
	for i in range(room_count):
		var room = _create_random_room(_config)
		if room:
			rooms.append(room)
			_generate_room_floor(room)
			_generate_room_walls(room)
			pass
		else:
			attempts += 1
			if attempts > max_attempts:
				pass
				break
	

func _generate_gold_veins(probability: float, vein_capacity: int) -> void:
	"""在未挖掘岩石中按概率生成金矿，并设置储量到 tile.resources.gold_amount
	使用聚集分布算法，让金矿集中在特定区域（使用autoload常量）"""
	LogManager.info("=== 开始生成金矿 ===")
	LogManager.info("基础概率: " + str(probability * 100) + "% 储量: " + str(vein_capacity))
	
	var level_index = 0
	var map_size_x = int(tile_manager.map_size.x)
	var map_size_z = int(tile_manager.map_size.z)
	
	# 生成3-5个金矿聚集区域
	var cluster_count = randi_range(3, 5)
	var clusters = []
	
	LogManager.info("生成 " + str(cluster_count) + " 个金矿聚集区域")
	
	# 创建聚集中心点
	for i in range(cluster_count):
		var center_x = randi_range(10, map_size_x - 10)
		var center_z = randi_range(10, map_size_z - 10)
		clusters.append(Vector2(center_x, center_z))
		LogManager.info("  聚集区域 " + str(i + 1) + ": (" + str(center_x) + ", " + str(center_z) + ")")
	
	var generated_count = 0
	var unexcavated_count = 0
	
	# 遍历所有未挖掘地块，根据距离聚集中心的远近调整生成概率
	for x in range(map_size_x):
		for z in range(map_size_z):
			var pos = Vector3(x, level_index, z)
			var tile = tile_manager.get_tile_data(pos)
			if tile == null:
				continue
			
			# 仅在未挖掘岩石中生成（使用autoload常量）
			if tile.type == TileTypes.UNEXCAVATED:
				unexcavated_count += 1
				# 计算到最近聚集中心的距离
				var min_distance = INF
				for cluster in clusters:
					var distance = Vector2(x, z).distance_to(cluster)
					min_distance = min(min_distance, distance)
				
				# 根据距离调整概率：距离越近概率越高
				var adjusted_probability = probability
				if min_distance < 15: # 在聚集中心15格范围内
					adjusted_probability *= 5.0 # 5倍概率
				elif min_distance < 25: # 在聚集中心25格范围内
					adjusted_probability *= 2.0 # 2倍概率
				else:
					adjusted_probability *= 0.1 # 远离聚集中心概率很低
				
				if randf() < adjusted_probability:
					# 使用autoload常量设置为金矿并记录储量
					tile_manager.set_tile_type(pos, TileTypes.GOLD_MINE)
					var updated = tile_manager.get_tile_data(pos)
					if updated:
						updated.resources["gold_amount"] = vein_capacity
						updated.resources["is_gold_vein"] = true
						generated_count += 1
						if generated_count <= 5: # 只记录前5个
							LogManager.info("  生成金矿 #" + str(generated_count) + " 位置: (" + str(x) + ", " + str(z) + ")")
	
	LogManager.info("=== 金矿生成完成 ===")
	LogManager.info("扫描了 " + str(unexcavated_count) + " 个未挖掘地块")
	LogManager.info("成功生成 " + str(generated_count) + " 个金矿")
	
	# 通知 GoldMineManager 重新扫描金矿
	LogManager.info("MapGenerator - 通知 GoldMineManager 重新扫描")
	var gold_mine_manager = get_node_or_null("/root/Main/GoldMineManager")
	if gold_mine_manager and gold_mine_manager.has_method("rescan_gold_mines"):
		# 延迟一帧确保瓦片数据已更新
		gold_mine_manager.call_deferred("rescan_gold_mines")
	elif gold_mine_manager:
		LogManager.error("GoldMineManager 没有 rescan_gold_mines 方法")
	else:
		LogManager.error("未找到 GoldMineManager")



func _create_random_room(_config: MapConfig) -> Room:
	"""创建随机房间"""
	var room_size = Vector2i(
		randi_range(_config.min_room_size, _config.max_room_size),
		randi_range(_config.min_room_size, _config.max_room_size)
	)

	# 将房间生成限制在地图中心 25x25 区域
	var center_x = int(tile_manager.map_size.x) / 2
	var center_z = int(tile_manager.map_size.z) / 2
	var half = 12

	var min_x = center_x - half
	var min_z = center_z - half
	var max_x = center_x + half - room_size.x
	var max_z = center_z + half - room_size.y

	if max_x < min_x or max_z < min_z:
		return null

	var position = Vector2i(
		randi_range(min_x, max_x),
		randi_range(min_z, max_z)
	)
	
	var new_room = Room.new(position, room_size, room_counter)
	room_counter += 1
	
	# 检查是否与现有房间重叠
	for existing_room in rooms:
		if new_room.overlaps(existing_room):
			return null
	
	return new_room

func _connect_rooms() -> void:
	"""连接房间"""
	
	# 确保所有房间都连接
	var connected_rooms = []
	var unconnected_rooms = rooms.duplicate()
	
	if unconnected_rooms.is_empty():
		return
	
	# 从第一个房间开始
	connected_rooms.append(unconnected_rooms.pop_front())
	
	while not unconnected_rooms.is_empty():
		var room_to_connect = unconnected_rooms.pop_front()
		var success = false
		
		# 尝试连接到已连接的房间
		for connected_room in connected_rooms:
			if _try_connect_rooms(room_to_connect, connected_room):
				connected_rooms.append(room_to_connect)
				success = true
				break
		
		if not success:
			# 如果无法连接，重新放回未连接列表
			unconnected_rooms.append(room_to_connect)
			if unconnected_rooms.size() > 1:
				# 随机打乱顺序重试
				unconnected_rooms.shuffle()
			else:
				# 强制连接最后一个房间
				_force_connect_room(room_to_connect, connected_rooms[0])
				connected_rooms.append(room_to_connect)
				break

func _try_connect_rooms(room1: Room, room2: Room) -> bool:
	"""尝试连接两个房间"""
	var connection_points1 = room1.get_connection_points()
	var connection_points2 = room2.get_connection_points()
	
	# 寻找最近的连接点
	var min_distance = INF
	var best_connection = null
	
	for point1 in connection_points1:
		for point2 in connection_points2:
			var distance = point1.distance_to(point2)
			if distance < min_distance and distance > 0:
				min_distance = distance
				best_connection = {"point1": point1, "point2": point2}
	
	if best_connection:
		# 创建连接
		room1.connections.append(room2.room_id)
		room2.connections.append(room1.room_id)
		
		# 在地图上标记连接
		_mark_connection(best_connection.point1, best_connection.point2)
		return true
	
	return false

func _force_connect_room(room: Room, target_room: Room) -> void:
	"""强制连接房间（用于确保所有房间都连接）"""
	var room1_center = room.center
	var room2_center = target_room.center
	
	# 创建从中心到中心的连接
	_mark_connection(room1_center, room2_center)
	
	room.connections.append(target_room.room_id)
	target_room.connections.append(room.room_id)

func _mark_connection(point1: Vector2i, point2: Vector2i) -> void:
	"""在地图上标记连接（使用autoload常量）"""
	# 创建从point1到point2的路径
	var current = point1
	var target = point2
	
	# 先水平移动，再垂直移动
	while current.x != target.x:
		_set_tile_type(Vector3(current.x, 0, current.y), TileTypes.CORRIDOR)
		if current.x < target.x:
			current.x += 1
		else:
			current.x -= 1
	
	while current.y != target.y:
		_set_tile_type(Vector3(current.x, 0, current.y), TileTypes.CORRIDOR)
		if current.y < target.y:
			current.y += 1
		else:
			current.y -= 1
	
	# 设置目标点
	_set_tile_type(Vector3(current.x, 0, current.y), TileTypes.CORRIDOR)

func _set_tile_type(position: Vector3, tile_type: int) -> void:
	"""设置地块类型"""
	if tile_manager:
		tile_manager.set_tile_type(position, tile_type)

# ============================================================================
# 性能优化功能
# ============================================================================

func load_chunk(chunk_pos: Vector2i) -> void:
	"""动态加载分块"""
	if chunk_pos in chunks:
		var chunk = chunks[chunk_pos]
		if not chunk.is_loaded:
			_generate_chunk_content(chunk)
			chunk.is_loaded = true
			loaded_chunks.append(chunk_pos)
			LogManager.info("分块已加载: " + str(chunk_pos))

func unload_chunk(chunk_pos: Vector2i) -> void:
	"""动态卸载分块"""
	if chunk_pos in chunks:
		var chunk = chunks[chunk_pos]
		if chunk.is_loaded:
			_clear_chunk_content(chunk)
			chunk.is_loaded = false
			loaded_chunks.erase(chunk_pos)
			LogManager.info("分块已卸载: " + str(chunk_pos))

func _generate_chunk_content(chunk: Chunk) -> void:
	"""生成分块内容"""
	# 这里可以实现分块的具体内容生成
	# 例如：生成该分块内的房间、资源、生物等
	pass

func _clear_chunk_content(chunk: Chunk) -> void:
	"""清空分块内容"""
	# 这里可以实现分块内容的清理
	# 例如：移除该分块内的3D对象、清理内存等
	pass

func update_chunk_loading(player_position: Vector3) -> void:
	"""根据玩家位置更新分块加载状态"""
	var player_chunk_x = int(player_position.x / chunk_size)
	var player_chunk_z = int(player_position.z / chunk_size)
	var player_chunk_pos = Vector2i(player_chunk_x, player_chunk_z)
	
	# 加载玩家周围的分块
	var load_radius = 2
	for x in range(player_chunk_x - load_radius, player_chunk_x + load_radius + 1):
		for z in range(player_chunk_z - load_radius, player_chunk_z + load_radius + 1):
			var chunk_pos = Vector2i(x, z)
			if chunk_pos in chunks:
				load_chunk(chunk_pos)
	
	# 卸载远离玩家的分块
	var chunks_to_unload = []
	for chunk_pos in loaded_chunks:
		var distance = chunk_pos.distance_to(player_chunk_pos)
		if distance > load_radius + 1:
			chunks_to_unload.append(chunk_pos)
	
	for chunk_pos in chunks_to_unload:
		unload_chunk(chunk_pos)

func get_chunk_at_position(world_pos: Vector3) -> Chunk:
	"""获取指定位置的分块"""
	var chunk_x = int(world_pos.x / chunk_size)
	var chunk_z = int(world_pos.z / chunk_size)
	var chunk_pos = Vector2i(chunk_x, chunk_z)
	
	if chunk_pos in chunks:
		return chunks[chunk_pos]
	return null

# ============================================================================
# 使用示例
# ============================================================================

## 创建标准地图
# var config = MapGenerator.MapConfig.new(Vector3(100, 1, 100))
# map_generator.generate_map(config)

## 创建大型地图
# var config = MapGenerator.MapConfig.new(Vector3(200, 1, 200))
# config.max_room_count = 30
# config.resource_density = 0.2
# map_generator.generate_map(config)

## 创建资源丰富地图
# var config = MapGenerator.MapConfig.new(Vector3(150, 1, 150))
# config.resource_density = 0.3
# config.forest_probability = 0.5
# config.lake_probability = 0.2
# map_generator.generate_map(config)

func _clear_map() -> void:
	"""清空现有地图"""
	if tile_manager:
		tile_manager.clear_all_tiles()
	else:
		LogManager.error("ERROR: TileManager 为空，无法清空地图")

func _generate_room_floor(room: Room) -> void:
	"""生成房间内部 - 将房间内部填充为UNEXCAVATED（使用autoload常量）"""
	var rect = room.get_rect()
	
	if not tile_manager:
		LogManager.error("ERROR: tile_manager 为空！")
		return
	
	var floor_tiles_placed = 0
	var max_tiles = rect.size.x * rect.size.y
	
	# 添加边界检查，防止无限循环
	if max_tiles > 1000:
		LogManager.warning("警告：房间太大，跳过地板生成")
		return
	
	for x in range(rect.size.x):
		for y in range(rect.size.y):
			# 添加额外的安全检查
			if floor_tiles_placed >= max_tiles:
				break
				
			var position = Vector3(rect.position.x + x, 0, rect.position.y + y)
			
			# 检查是否是地牢之心位置，如果是则跳过
			var tile_data = tile_manager.get_tile_data(position)
			if tile_data and tile_data.type == TileTypes.DUNGEON_HEART:
				continue
			
			# 使用autoload常量将房间内部填充为UNEXCAVATED
			var success = tile_manager.set_tile_type(position, TileTypes.UNEXCAVATED)
			if success:
				floor_tiles_placed += 1
			else:
				LogManager.error("设置房间内部瓦片失败，位置: " + str(position))
			
			# 添加安全检查，防止无限循环
			if floor_tiles_placed > 1000:
				break
		if floor_tiles_placed > 1000:
			break

func _generate_room_walls(room: Room) -> void:
	"""生成房间墙壁 - 在房间周围放置石墙（使用autoload常量）"""
	var rect = room.get_rect()
	var wall_tiles_placed = 0
	var wall_tiles_failed = 0
	
	if not tile_manager:
		LogManager.error("ERROR: tile_manager 为空！")
		return
	
	# 生成顶部和底部墙壁
	for x in range(rect.position.x - 1, rect.position.x + rect.size.x + 1):
		var top_wall_pos = Vector3(x, 0, rect.position.y - 1)
		var bottom_wall_pos = Vector3(x, 0, rect.position.y + rect.size.y)
		
		if tile_manager.set_tile_type(top_wall_pos, TileTypes.STONE_WALL):
			wall_tiles_placed += 1
		else:
			wall_tiles_failed += 1
		if tile_manager.set_tile_type(bottom_wall_pos, TileTypes.STONE_WALL):
			wall_tiles_placed += 1
		else:
			wall_tiles_failed += 1
	
	# 生成左侧和右侧墙壁
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		var left_wall_pos = Vector3(rect.position.x - 1, 0, y)
		var right_wall_pos = Vector3(rect.position.x + rect.size.x, 0, y)
		
		if tile_manager.set_tile_type(left_wall_pos, TileTypes.STONE_WALL):
			wall_tiles_placed += 1
		else:
			wall_tiles_failed += 1
		if tile_manager.set_tile_type(right_wall_pos, TileTypes.STONE_WALL):
			wall_tiles_placed += 1
		else:
			wall_tiles_failed += 1
	
	# 调试：输出墙壁生成统计
	if wall_tiles_failed > 0:
		LogManager.warning("⚠️ [MapGenerator] 房间 #%d 墙壁生成: 成功=%d, 失败=%d" % [
			room.room_id, wall_tiles_placed, wall_tiles_failed
		])
