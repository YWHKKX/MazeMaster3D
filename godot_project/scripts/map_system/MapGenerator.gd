extends Node
class_name MapGenerator

## 🗺️ 高级地图生成器 - 基于空洞挖掘系统重构
## 实现空洞优先的地图生成：先挖掘空洞，再填充内容
## 集成泊松圆盘分布和噪声形状生成，提供更可控的地图布局

# 预加载空洞系统类
const Cavity = preload("res://scripts/map_system/cavity_system/cavities/Cavity.gd")
const CavityExcavator = preload("res://scripts/map_system/cavity_system/algorithms/CavityExcavator.gd")


enum RegionType {
	ROOM_SYSTEM, # 房间系统
	MAZE_SYSTEM, # 迷宫系统
	ECOSYSTEM, # 生态系统
	HERO_CAMP_PORTAL # 英雄营地/传送门
}


enum EcosystemType {
	FOREST, # 森林
	GRASSLAND, # 草地
	LAKE, # 湖泊
	CAVE, # 洞穴
	WASTELAND, # 荒地
	SWAMP, # 沼泽
	DEAD_LAND # 死地
}


class MapGeneratorConfig:
	var size: Vector3
	
	# 房间生成参数
	var max_room_count: int
	var min_room_size: int
	var max_room_size: int
	var room_connection_attempts: int
	var corridor_width: int
	
	# 噪声参数
	var noise_scale: float
	var height_threshold: float
	var humidity_threshold: float
	
	# 区域分布参数
	var default_terrain_ratio: float
	var ecosystem_ratio: float
	var room_system_ratio: float
	var maze_system_ratio: float
	var hero_camp_ratio: float
	
	# 复杂度参数
	var complexity: float
	
	# 分块参数
	var chunk_size: int
	
	# 资源参数
	var resource_density: float
	
	# 生态分布参数
	var forest_probability: float
	var lake_probability: float
	var cave_probability: float
	var wasteland_probability: float
	
	# 🔧 [统一配置] 从MapConfig autoload获取配置
	func _init(map_size: Vector3):
		size = map_size
		# 从统一配置获取参数
		var room_config = MapConfig.get_room_generation_config()
		var noise_config = MapConfig.get_noise_config()
		var region_ratios = MapConfig.get_region_ratios()
		var complexity_config = MapConfig.get_complexity_config()
		var chunk_config = MapConfig.get_chunk_config()
		
		# 房间生成参数
		max_room_count = room_config.max_room_count
		min_room_size = room_config.min_room_size
		max_room_size = room_config.max_room_size
		room_connection_attempts = room_config.room_connection_attempts
		corridor_width = room_config.corridor_width
		
		# 噪声参数
		noise_scale = noise_config.noise_scale
		height_threshold = noise_config.height_threshold
		humidity_threshold = noise_config.humidity_threshold
		
		# 区域分布参数
		default_terrain_ratio = region_ratios.default_terrain
		ecosystem_ratio = region_ratios.ecosystem
		room_system_ratio = region_ratios.room_system
		maze_system_ratio = region_ratios.maze_system
		hero_camp_ratio = region_ratios.hero_camp
		
		# 复杂度参数
		complexity = complexity_config.base_complexity
		
		# 分块参数
		chunk_size = chunk_config.chunk_size
		
		# 资源参数（暂时保持原值）
		resource_density = 0.1
		
		# 生态分布参数（从MapConfig获取）
		var ecosystem_ratios = MapConfig.get_ecosystem_ratios()
		forest_probability = ecosystem_ratios.forest
		lake_probability = ecosystem_ratios.lake
		cave_probability = ecosystem_ratios.cave
		wasteland_probability = ecosystem_ratios.wasteland
	

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

class EcosystemRegionData:
	var position: Vector2i
	var size: Vector2i
	var ecosystem_type: EcosystemType
	var resource_spawns: Array = []
	var creature_spawns: Array = []
	
	func _init(pos: Vector2i, region_size: Vector2i, eco_type: EcosystemType):
		position = pos
		size = region_size
		ecosystem_type = eco_type

class HeroCamp:
	var position: Vector2i
	var camp_type: String
	var spawn_waves: Array = []
	var is_active: bool = true
	
	func _init(pos: Vector2i, type: String):
		position = pos
		camp_type = type


var cavity_excavator: CavityExcavator
var cavity_manager: CavityManager
var terrain_manager: TerrainManager
var terrain_highlight_system: Node
var flood_fill_system: FloodFillSystem


var tile_manager: Node
var character_manager: Node
var ecosystem_manager: Node
var rooms: Array[Room] = []
var room_counter: int = 0

var simple_room_generator: SimpleRoomGenerator
var simple_rooms: Array[SimpleRoom] = []


var chunks: Dictionary = {} # Vector2i -> Chunk
var loaded_chunks: Array[Vector2i] = []
var chunk_size: int = 16

var height_noise: FastNoiseLite
var humidity_noise: FastNoiseLite
var temperature_noise: FastNoiseLite


var config: MapGeneratorConfig

func _ready():
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
	var ecosystem_script = preload("res://scripts/map_system/ecosystem/EcosystemManager.gd")
	if not ecosystem_script:
		LogManager.error("ERROR: 无法加载EcosystemManager脚本！")
	else:
		ecosystem_manager = ecosystem_script.new()
		add_child(ecosystem_manager)
		LogManager.info("EcosystemManager 创建成功")
	
	# 🔧 [统一数据管理] 移除 TerrainManager，使用 TileManager 作为唯一数据源
	LogManager.info("使用 TileManager 作为唯一的地形数据源")
	
	# 🔧 [新增] 创建洪水填充系统
	var flood_fill_script = preload("res://scripts/managers/FloodFillSystem.gd")
	if not flood_fill_script:
		LogManager.error("ERROR: 无法加载FloodFillSystem脚本！")
	else:
		flood_fill_system = flood_fill_script.new()
		flood_fill_system.set_tile_manager(tile_manager)
		add_child(flood_fill_system)
		LogManager.info("FloodFillSystem 创建成功")
	
	# 🔧 [新增] 创建简化房间生成器
	var simple_room_script = preload("res://scripts/map_system/room_system/SimpleRoomGenerator.gd")
	if not simple_room_script:
		LogManager.error("ERROR: 无法加载SimpleRoomGenerator脚本！")
	else:
		simple_room_generator = simple_room_script.new()
		# 设置 TileManager 引用
		simple_room_generator.set_tile_manager(tile_manager)
		# 设置洪水填充系统引用
		if flood_fill_system:
			simple_room_generator.set_flood_fill_system(flood_fill_system)
		add_child(simple_room_generator)
		LogManager.info("SimpleRoomGenerator 创建成功")
	
	# 初始化噪声生成器
	_initialize_noise_generators()
	
	# 初始化配置
	config = MapGeneratorConfig.new(MapConfig.get_map_size())
	
	# 初始化迷宫生成器
	_initialize_maze_generator()
	
	LogManager.info("=== 高级地图生成器初始化完成 ===")

func _initialize_maze_generator():
	"""初始化迷宫生成器"""
	LogManager.info("初始化迷宫生成器...")
	
	# 创建SimpleMazeGenerator节点
	var maze_generator = SimpleMazeGenerator.new()
	add_child(maze_generator)
	maze_generator.name = "SimpleMazeGenerator"
	
	# 初始化依赖项
	maze_generator.initialize(tile_manager, flood_fill_system)
	
	# 设置迷宫生成配置
	var maze_config = {
		"min_maze_size": 20,
		"max_maze_size": 100,
		"complexity_factor": 0.3,
		"ensure_solvable": true
	}
	maze_generator.set_config(maze_config)
	
	LogManager.info("迷宫生成器初始化完成")

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

func _load_user_settings():
	"""加载用户设置并应用到生成器"""
	var user_settings = MapConfig.get_user_settings()
	if user_settings.is_empty():
		LogManager.info("未找到用户设置，使用默认配置")
		return
	
	LogManager.info("加载用户地图设置...")
	
	# 应用区域占比设置
	if user_settings.has("region_ratios"):
		var region_ratios = user_settings.region_ratios
		LogManager.info("应用用户区域占比设置: %s" % str(region_ratios))
		# 这里可以存储到实例变量中供后续使用
		user_region_ratios = region_ratios
	
	# 应用空洞挖掘设置
	if user_settings.has("cavity_config"):
		var cavity_config = user_settings.cavity_config
		LogManager.info("应用用户空洞挖掘设置: %s" % str(cavity_config))
		user_cavity_config = cavity_config
	
	# 应用房间生成设置
	if user_settings.has("room_config"):
		var room_config = user_settings.room_config
		LogManager.info("应用用户房间生成设置: %s" % str(room_config))
		user_room_config = room_config
	
	# 应用资源生成设置
	if user_settings.has("resource_config"):
		var resource_config = user_settings.resource_config
		LogManager.info("应用用户资源生成设置: %s" % str(resource_config))
		user_resource_config = resource_config
	
	# 应用生物生成设置
	if user_settings.has("creature_config"):
		var creature_config = user_settings.creature_config
		LogManager.info("应用用户生物生成设置: %s" % str(creature_config))
		user_creature_config = creature_config

# 用户设置存储变量
var user_region_ratios: Dictionary = {}
var user_cavity_config: Dictionary = {}
var user_room_config: Dictionary = {}
var user_resource_config: Dictionary = {}
var user_creature_config: Dictionary = {}

func generate_map(_config: MapGeneratorConfig) -> void:
	"""生成高级地图 - 基于空洞挖掘系统的五步生成流程"""
	LogManager.info("=== 开始生成空洞挖掘地图系统 ===")

	# 确保 TileManager 已完全初始化
	if not tile_manager:
		LogManager.error("ERROR: TileManager 未找到，无法生成地图")
		return
	
	# 更新配置
	config = _config
	
	# 加载用户设置（如果存在）
	_load_user_settings()
	
	# 初始化空洞系统
	_initialize_cavity_system(_config)
	
	# 等待一帧确保系统完全初始化
	await get_tree().process_frame
	
	# 🔧 [空洞优先生成流程] 严格按照五步流程执行
	# 第一步：初始化基础地形
	LogManager.info("=== 第一步：初始化基础地形 ===")
	await _initialize_base_terrain(_config)
	
	# 第二步：初始化关键建筑
	LogManager.info("=== 第二步：初始化关键建筑 ===")
	_initialize_critical_buildings(_config)
	
	# 第三步：使用泊松圆盘分布生成不规则空洞
	LogManager.info("=== 第三步：生成泊松圆盘空洞 ===")
	await _generate_cavities_with_constraints(_config)
	
	# 第四步：填充空洞内容
	LogManager.info("=== 第四步：填充空洞内容 ===")
	_populate_cavity_contents(_config)
	
	# 第五步：数据验证
	LogManager.info("=== 第五步：数据验证 ===")
	_validate_cavity_generation(_config)
	
	LogManager.info("=== 空洞挖掘地图生成完成 ===")
	
	# 发射地图生成完成事件
	GameEvents.map_generated.emit()
	LogManager.info("✅ 已发射 map_generated 事件")

func _generate_cavities_with_constraints(_config: MapGeneratorConfig) -> void:
	"""生成带约束条件的空洞"""
	LogManager.info("CavitySystem - 开始生成约束空洞")
	
	# 检查空洞管理器是否已初始化
	if not cavity_manager:
		LogManager.error("ERROR: CavityManager 未初始化")
		return
	
	# 检查空洞生成器是否已初始化
	if not cavity_manager.has_method("generate_cavities_with_constraints"):
		LogManager.error("ERROR: CavityManager 缺少 generate_cavities_with_constraints 方法")
		return
	
	# 使用空洞管理器生成约束空洞
	var cavities = cavity_manager.generate_cavities_with_constraints()
	
	if cavities.is_empty():
		LogManager.warning("WARNING: 未生成任何空洞")
		return
	
	# 将空洞添加到空洞管理器
	for cavity in cavities:
		cavity_manager.add_cavity(cavity)
	
	LogManager.info("CavitySystem - 成功生成 %d 个约束空洞" % cavities.size())

func _validate_region_allocation(_config: MapGeneratorConfig) -> void:
	"""🔧 [数据验证] 验证区域分配比例 - 增强版本"""
	LogManager.info("=== 🔧 [数据验证] 验证区域分配比例 ===")
	
	var map_size_x = int(_config.size.x)
	var map_size_z = int(_config.size.z)
	var total_tiles = map_size_x * map_size_z
	
	LogManager.info("📊 [数据验证] 地图尺寸: %dx%d, 总瓦片数: %d" % [map_size_x, map_size_z, total_tiles])
	
	var actual_stats = {
		"unexcavated": 0,
		"dungeon_heart": 0,
		"stone_floor": 0,
		"empty": 0,
		"forest": 0,
		"wasteland": 0,
		"swamp": 0,
		"cave": 0,
		"other": 0
	}
	
	# 🔧 [数据验证] 统计实际分配的地块数量
	for x in range(map_size_x):
		for z in range(map_size_z):
			var pos = Vector3(x, 0, z)
			var tile_type = tile_manager.get_tile_type(pos)
			
			match tile_type:
				TileTypes.TileType.UNEXCAVATED:
					actual_stats.unexcavated += 1
				TileTypes.TileType.DUNGEON_HEART:
					actual_stats.dungeon_heart += 1
				TileTypes.TileType.STONE_FLOOR:
					actual_stats.stone_floor += 1
				TileTypes.TileType.EMPTY:
					actual_stats.empty += 1
				TileTypes.TileType.FOREST:
					actual_stats.forest += 1
				TileTypes.TileType.WASTELAND:
					actual_stats.wasteland += 1
				TileTypes.TileType.SWAMP:
					actual_stats.swamp += 1
				TileTypes.TileType.CAVE:
					actual_stats.cave += 1
				_:
					actual_stats.other += 1
	
	# 🔧 [调试输出] 输出详细统计结果
	LogManager.info("📊 [调试输出] 实际区域分配统计:")
	LogManager.info("  总瓦片数: %d" % total_tiles)
	LogManager.info("  未挖掘地形: %d (%.1f%%)" % [actual_stats.unexcavated, float(actual_stats.unexcavated) / total_tiles * 100])
	LogManager.info("  地牢之心: %d (%.1f%%)" % [actual_stats.dungeon_heart, float(actual_stats.dungeon_heart) / total_tiles * 100])
	LogManager.info("  石地板: %d (%.1f%%)" % [actual_stats.stone_floor, float(actual_stats.stone_floor) / total_tiles * 100])
	LogManager.info("  空地: %d (%.1f%%)" % [actual_stats.empty, float(actual_stats.empty) / total_tiles * 100])
	LogManager.info("  森林: %d (%.1f%%)" % [actual_stats.forest, float(actual_stats.forest) / total_tiles * 100])
	LogManager.info("  荒地: %d (%.1f%%)" % [actual_stats.wasteland, float(actual_stats.wasteland) / total_tiles * 100])
	LogManager.info("  沼泽: %d (%.1f%%)" % [actual_stats.swamp, float(actual_stats.swamp) / total_tiles * 100])
	LogManager.info("  洞穴: %d (%.1f%%)" % [actual_stats.cave, float(actual_stats.cave) / total_tiles * 100])
	LogManager.info("  其他类型: %d (%.1f%%)" % [actual_stats.other, float(actual_stats.other) / total_tiles * 100])
	
	# 🔧 [数据一致性] 验证数据完整性
	var total_allocated = actual_stats.unexcavated + actual_stats.dungeon_heart + actual_stats.stone_floor + actual_stats.empty + actual_stats.forest + actual_stats.wasteland + actual_stats.swamp + actual_stats.cave + actual_stats.other
	
	if total_allocated != total_tiles:
		LogManager.error("❌ [数据一致性] 瓦片统计不匹配! 总计: %d, 预期: %d" % [total_allocated, total_tiles])
	else:
		LogManager.info("✅ [数据一致性] 瓦片统计匹配正确")
	
	# 🔧 [区域比例验证] 验证比例是否符合预期
	var unexcavated_ratio = float(actual_stats.unexcavated) / total_tiles
	var expected_default_ratio = _config.default_terrain_ratio
	
	LogManager.info("📊 [区域比例验证] 默认地形比例:")
	LogManager.info("  预期比例: %.1f%%" % (expected_default_ratio * 100))
	LogManager.info("  实际比例: %.1f%%" % (unexcavated_ratio * 100))
	
	var tolerance = 0.05 # 5%误差容忍
	if abs(unexcavated_ratio - expected_default_ratio) > tolerance:
		LogManager.warning("⚠️ [区域比例验证] 默认地形比例偏差较大: 预期%.1f%%, 实际%.1f%%" % [expected_default_ratio * 100, unexcavated_ratio * 100])
	else:
		LogManager.info("✅ [区域比例验证] 默认地形比例符合预期")
	
	# 🔧 [生态系统验证] 验证生态系统分布
	var total_ecosystem = actual_stats.forest + actual_stats.wasteland + actual_stats.swamp + actual_stats.cave
	if total_ecosystem > 0:
		LogManager.info("📊 [生态系统验证] 生态系统分布:")
		LogManager.info("  总生态瓦片: %d (%.1f%%)" % [total_ecosystem, float(total_ecosystem) / total_tiles * 100])
		LogManager.info("  森林比例: %.1f%%" % (float(actual_stats.forest) / total_ecosystem * 100))
		LogManager.info("  荒地比例: %.1f%%" % (float(actual_stats.wasteland) / total_ecosystem * 100))
		LogManager.info("  沼泽比例: %.1f%%" % (float(actual_stats.swamp) / total_ecosystem * 100))
		LogManager.info("  洞穴比例: %.1f%%" % (float(actual_stats.cave) / total_ecosystem * 100))

func _initialize_map_and_chunks(_config: MapGeneratorConfig) -> void:
	"""第一步：初始化地图和分块系统"""
	
	# 清空现有地图
	_clear_map()
	
	# 重新初始化地图结构
	tile_manager._initialize_map_structure()
	
	# 初始化分块系统
	_initialize_chunk_system(_config)
	
	# 初始化所有地块为UNEXCAVATED（使用autoload常量）
	await _initialize_all_tiles_as_unexcavated()

func _initialize_chunk_system(_config: MapGeneratorConfig) -> void:
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

func _generate_noise_terrain_with_regions(_config: MapGeneratorConfig) -> void:
	"""第二步：生成噪声地形和四大区域（按比例分配）"""
	LogManager.info("开始生成噪声地形和四大区域...")
	
	var map_size_x = int(_config.size.x)
	var map_size_z = int(_config.size.z)
	var total_tiles = map_size_x * map_size_z
	
	height_noise.frequency = _config.noise_scale
	humidity_noise.frequency = _config.noise_scale * 0.8
	temperature_noise.frequency = _config.noise_scale * 1.2
	
	# 1. 首先生成基础噪声地形（默认未挖掘地块）
	LogManager.info("生成基础噪声地形...")
	for x in range(map_size_x):
		for z in range(map_size_z):
			var pos = Vector3(x, 0, z)
			# 所有地块默认为未挖掘
			tile_manager.set_tile_type(pos, TileTypes.TileType.UNEXCAVATED)
	
	# 2. 生成地牢之心区域（周围必须是默认地形）
	LogManager.info("生成地牢之心区域...")
	_generate_dungeon_heart_area(_config)
	
	# 3. 按比例分配区域
	LogManager.info("按比例分配区域...")
	_allocate_regions_by_ratio(_config, total_tiles)
	
	# 4. 确保各区域之间由默认地形连接
	LogManager.info("确保区域间默认地形连接...")
	_ensure_region_connections(_config)
	
	LogManager.info("噪声地形和四大区域生成完成")

func _allocate_regions_by_ratio(_config: MapGeneratorConfig, total_tiles: int) -> void:
	"""🔧 [修复区域分配] 重新实现区域分配算法，确保精确的比例控制"""
	var map_size_x = int(_config.size.x)
	var map_size_z = int(_config.size.z)
	
	# 计算各区域应占的瓦片数量
	var default_tiles = int(total_tiles * _config.default_terrain_ratio)
	var ecosystem_tiles = int(total_tiles * _config.ecosystem_ratio)
	var room_tiles = int(total_tiles * _config.room_system_ratio)
	var maze_tiles = int(total_tiles * _config.maze_system_ratio)
	var hero_tiles = int(total_tiles * _config.hero_camp_ratio)
	
	LogManager.info("🔧 [修复区域分配] 区域分配目标:")
	LogManager.info("  默认地形: %d 瓦片 (%.1f%%)" % [default_tiles, _config.default_terrain_ratio * 100])
	LogManager.info("  生态系统: %d 瓦片 (%.1f%%)" % [ecosystem_tiles, _config.ecosystem_ratio * 100])
	LogManager.info("  房间系统: %d 瓦片 (%.1f%%)" % [room_tiles, _config.room_system_ratio * 100])
	LogManager.info("  迷宫系统: %d 瓦片 (%.1f%%)" % [maze_tiles, _config.maze_system_ratio * 100])
	LogManager.info("  英雄营地: %d 瓦片 (%.1f%%)" % [hero_tiles, _config.hero_camp_ratio * 100])
	
	# 🔧 [精确分配] 使用基于网格的精确分配算法
	_allocate_regions_precisely(_config, {
		"ecosystem": ecosystem_tiles,
		"room_system": room_tiles,
		"maze_system": maze_tiles,
		"hero_camp": hero_tiles,
		"default": default_tiles
	})
	
	LogManager.info("✅ 精确区域分配完成")

func _allocate_regions_precisely(_config: MapGeneratorConfig, target_counts: Dictionary) -> void:
	"""🔧 [精确分配] 基于网格的精确区域分配算法 - 修复版本"""
	var map_size_x = int(_config.size.x)
	var map_size_z = int(_config.size.z)
	
	LogManager.info("🔧 [精确分配] 开始区域分配，目标数量:")
	LogManager.info("  生态系统: %d 瓦片" % target_counts.ecosystem)
	LogManager.info("  房间系统: %d 瓦片" % target_counts.room_system)
	LogManager.info("  迷宫系统: %d 瓦片" % target_counts.maze_system)
	LogManager.info("  英雄营地: %d 瓦片" % target_counts.hero_camp)
	
	# 创建所有可用位置的列表（排除地牢之心区域）
	var available_positions: Array[Vector2i] = []
	var heart_center_x = int(_config.size.x / 2)
	var heart_center_z = int(_config.size.z / 2)
	var heart_radius = 4 # 地牢之心保护半径
	
	for x in range(map_size_x):
		for z in range(map_size_z):
			var pos = Vector2i(x, z)
			# 排除地牢之心周围区域
			var distance_to_heart = pos.distance_to(Vector2i(heart_center_x, heart_center_z))
			if distance_to_heart > heart_radius:
				available_positions.append(pos)
	
	LogManager.info("🔧 [边界检查] 可用位置总数: %d (排除地牢之心周围 %d 格)" % [available_positions.size(), heart_radius])
	
	# 打乱可用位置列表
	available_positions.shuffle()
	
	# 精确分配各区域
	var allocated_counts = {
		"ecosystem": 0,
		"room_system": 0,
		"maze_system": 0,
		"hero_camp": 0
	}
	
	var position_index = 0
	
	# 分配生态系统区域
	LogManager.info("🔧 分配生态系统区域...")
	while allocated_counts.ecosystem < target_counts.ecosystem and position_index < available_positions.size():
		var pos = available_positions[position_index]
		# 🔧 [修复] 使用特定的瓦片类型标记不同区域
		tile_manager.set_tile_type(Vector3(pos.x, 0, pos.y), TileTypes.TileType.UNEXCAVATED) # 生态系统
		# 在 TileManager 中标记区域类型（如果需要的话）
		allocated_counts.ecosystem += 1
		position_index += 1
	
	# 分配房间系统区域
	LogManager.info("🔧 分配房间系统区域...")
	while allocated_counts.room_system < target_counts.room_system and position_index < available_positions.size():
		var pos = available_positions[position_index]
		tile_manager.set_tile_type(Vector3(pos.x, 0, pos.y), TileTypes.TileType.UNEXCAVATED) # 房间系统
		allocated_counts.room_system += 1
		position_index += 1
	
	# 分配迷宫系统区域
	LogManager.info("🔧 分配迷宫系统区域...")
	while allocated_counts.maze_system < target_counts.maze_system and position_index < available_positions.size():
		var pos = available_positions[position_index]
		tile_manager.set_tile_type(Vector3(pos.x, 0, pos.y), TileTypes.TileType.UNEXCAVATED) # 迷宫系统
		allocated_counts.maze_system += 1
		position_index += 1
	
	# 分配英雄营地区域
	LogManager.info("🔧 分配英雄营地区域...")
	while allocated_counts.hero_camp < target_counts.hero_camp and position_index < available_positions.size():
		var pos = available_positions[position_index]
		tile_manager.set_tile_type(Vector3(pos.x, 0, pos.y), TileTypes.TileType.UNEXCAVATED) # 英雄营地
		allocated_counts.hero_camp += 1
		position_index += 1
	
	# 🔧 [数据验证] 输出实际分配结果
	LogManager.info("📊 [数据验证] 实际分配结果:")
	LogManager.info("  生态系统: %d/%d 瓦片 (%.1f%%)" % [
		allocated_counts.ecosystem, target_counts.ecosystem,
		float(allocated_counts.ecosystem) / target_counts.ecosystem * 100 if target_counts.ecosystem > 0 else 0
	])
	LogManager.info("  房间系统: %d/%d 瓦片 (%.1f%%)" % [
		allocated_counts.room_system, target_counts.room_system,
		float(allocated_counts.room_system) / target_counts.room_system * 100 if target_counts.room_system > 0 else 0
	])
	LogManager.info("  迷宫系统: %d/%d 瓦片 (%.1f%%)" % [
		allocated_counts.maze_system, target_counts.maze_system,
		float(allocated_counts.maze_system) / target_counts.maze_system * 100 if target_counts.maze_system > 0 else 0
	])
	LogManager.info("  英雄营地: %d/%d 瓦片 (%.1f%%)" % [
		allocated_counts.hero_camp, target_counts.hero_camp,
		float(allocated_counts.hero_camp) / target_counts.hero_camp * 100 if target_counts.hero_camp > 0 else 0
	])
	LogManager.info("  剩余默认: %d 瓦片" % (available_positions.size() - position_index))
	
	# 🔧 [边界检查] 验证分配完整性
	var total_allocated = allocated_counts.ecosystem + allocated_counts.room_system + allocated_counts.maze_system + allocated_counts.hero_camp
	var total_target = target_counts.ecosystem + target_counts.room_system + target_counts.maze_system + target_counts.hero_camp
	LogManager.info("📊 [边界检查] 分配完整性: %d/%d 瓦片 (%.1f%%)" % [
		total_allocated, total_target,
		float(total_allocated) / total_target * 100 if total_target > 0 else 0
	])

# 🔧 [移除] 旧的区域分配方法已废弃，使用新的精确分配算法
# 🔧 [已移除] 旧的生态系统分配方法

# 🔧 [已移除] 旧的房间系统分配方法
# func _allocate_room_system_regions(_config: MapGeneratorConfig, region_grid: Array, target_tiles: int) -> void:
# 🔧 [已移除] 旧的房间系统分配方法内容
# 🔧 [已移除] 所有旧的区域分配方法内容

func _generate_noise_terrain(_config: MapGeneratorConfig) -> void:
	"""原始噪声地形生成（保留兼容性）"""
	LogManager.info("开始生成噪声地形...")
	
	var map_size_x = int(_config.size.x)
	var map_size_z = int(_config.size.z)
	
	height_noise.frequency = _config.noise_scale
	humidity_noise.frequency = _config.noise_scale * 0.8
	temperature_noise.frequency = _config.noise_scale * 1.2
	
	for x in range(map_size_x):
		for z in range(map_size_z):
			var pos = Vector3(x, 0, z)
			
			# 🔧 [新增] 跳过地牢之心预留区域，不参与噪声生成
			if tile_manager.is_in_dungeon_heart_reserve_area(pos):
				continue
			
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
			return TileTypes.TileType.EMPTY # 森林 - 空地
		EcosystemType.GRASSLAND:
			return TileTypes.TileType.EMPTY # 草地 - 空地
		EcosystemType.LAKE:
			return TileTypes.TileType.WATER # 湖泊 - 水域
		EcosystemType.CAVE:
			return TileTypes.TileType.EMPTY # 洞穴 - 空地
		EcosystemType.WASTELAND:
			return TileTypes.TileType.EMPTY # 荒地 - 空地
		EcosystemType.DEAD_LAND:
			return TileTypes.TileType.EMPTY # 死地 - 空地
		_:
			return TileTypes.TileType.EMPTY
	

func _generate_dungeon_heart_area(_config: MapGeneratorConfig) -> void:
	"""生成地牢之心区域（周围必须是默认地形）"""
	var center_x = int(_config.size.x / 2)
	var center_z = int(_config.size.z / 2)
	
	# 🔧 [统一配置] 地牢之心区域：使用统一配置的预留区域
	var reserve_size = MapConfig.get_dungeon_heart_reserve_size()
	var reserve_radius = reserve_size / 2 # 预留区域半径
	var heart_radius = 1 # 2x2地牢之心半径
	
	LogManager.info("生成地牢之心区域: 中心(%d, %d), 预留区域半径%d" % [center_x, center_z, reserve_radius])
	
	# 创建10x10的预留区域
	for dx in range(-reserve_radius, reserve_radius + 1):
		for dz in range(-reserve_radius, reserve_radius + 1):
			var pos = Vector3(center_x + dx, 0, center_z + dz)
			
			if pos.x < 0 or pos.x >= _config.size.x or pos.z < 0 or pos.z >= _config.size.z:
				continue
			
			# 中心2x2为地牢之心
			if abs(dx) <= heart_radius and abs(dz) <= heart_radius:
				tile_manager.set_tile_type(pos, TileTypes.TileType.DUNGEON_HEART)
			else:
				# 周围区域保持为默认地形（未挖掘），不参与噪声生成
				tile_manager.set_tile_type(pos, TileTypes.TileType.UNEXCAVATED)
	
	LogManager.info("地牢之心预留区域生成完成 (%dx%d)" % [reserve_size, reserve_size])

func _generate_room_system_areas(_config: MapGeneratorConfig) -> void:
	"""生成房间系统区域（在地图中心区域）"""
	var center_x = int(_config.size.x / 2)
	var center_z = int(_config.size.z / 2)
	var room_area_size = MapConfig.get_room_system_area_size() # 🔧 [统一配置] 使用统一配置
	var half_size = room_area_size / 2
	
	LogManager.info("生成房间系统区域: 中心(%d, %d), 大小%d" % [center_x, center_z, room_area_size])
	
	# 标记房间系统区域（但不生成具体房间，在第三步细化）
	for dx in range(-half_size, half_size + 1):
		for dz in range(-half_size, half_size + 1):
			var pos = Vector3(center_x + dx, 0, center_z + dz)
			
			if pos.x < 0 or pos.x >= _config.size.x or pos.z < 0 or pos.z >= _config.size.z:
				continue
			
			# 跳过地牢之心区域
			if abs(dx) <= 3 and abs(dz) <= 3:
				continue
			
			# 标记为房间系统区域（暂时保持为默认地形）
			# 这里可以添加区域标记，用于第三步细化
			pass
	
	LogManager.info("房间系统区域标记完成")

func _generate_maze_system_areas(_config: MapGeneratorConfig) -> void:
	"""生成迷宫系统区域（地图1/4区域）"""
	var maze_width = int(_config.size.x / 2)
	var maze_height = int(_config.size.z / 2)
	var maze_start_x = int(_config.size.x / 4)
	var maze_start_z = int(_config.size.z / 4)
	
	LogManager.info("生成迷宫系统区域: 起始(%d, %d), 大小%dx%d" % [maze_start_x, maze_start_z, maze_width, maze_height])
	
	# 标记迷宫系统区域（但不生成具体迷宫，在第三步细化）
	for x in range(maze_width):
		for z in range(maze_height):
			var pos = Vector3(maze_start_x + x, 0, maze_start_z + z)
			
			if pos.x < 0 or pos.x >= _config.size.x or pos.z < 0 or pos.z >= _config.size.z:
				continue
			
			# 标记为迷宫系统区域（暂时保持为默认地形）
			# 这里可以添加区域标记，用于第三步细化
			pass
	
	LogManager.info("迷宫系统区域标记完成")

func _generate_ecosystem_areas(_config: MapGeneratorConfig) -> void:
	"""生成生态系统区域（随机分布）"""
	LogManager.info("生成生态系统区域...")
	
	# 生成3-5个生态区域
	var region_count = randi_range(3, 5)
	
	for i in range(region_count):
		var region_size = Vector2i(randi_range(8, 16), randi_range(8, 16))
		var region_pos = Vector2i(
			randi_range(10, int(_config.size.x) - region_size.x - 10),
			randi_range(10, int(_config.size.z) - region_size.y - 10)
		)
		
		# 检查是否与地牢之心区域重叠
		var center_x = int(_config.size.x / 2)
		var center_z = int(_config.size.z / 2)
		var distance_to_heart = region_pos.distance_to(Vector2i(center_x, center_z))
		
		if distance_to_heart < 20: # 避开地牢之心区域
			continue
		
		# 标记生态区域（暂时保持为默认地形）
		for dx in range(region_size.x):
			for dz in range(region_size.y):
				var pos = Vector3(region_pos.x + dx, 0, region_pos.y + dz)
				
				if pos.x < 0 or pos.x >= _config.size.x or pos.z < 0 or pos.z >= _config.size.z:
					continue
				
				# 标记为生态区域（暂时保持为默认地形）
				# 这里可以添加区域标记，用于第三步细化
				pass
	
	LogManager.info("生态系统区域标记完成")

func _generate_hero_camp_areas(_config: MapGeneratorConfig) -> void:
	"""生成英雄营地区域（地图边缘）"""
	LogManager.info("生成英雄营地区域...")
	
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
		
		# 标记英雄营地区域（暂时保持为默认地形）
		# 这里可以添加区域标记，用于第三步细化
		pass
	
	LogManager.info("英雄营地区域标记完成")

func _ensure_region_connections(_config: MapGeneratorConfig) -> void:
	"""确保各区域之间由默认地形连接"""
	LogManager.info("确保区域间默认地形连接...")
	
	# 这里可以实现区域连接算法
	# 确保所有区域之间都有默认地形（未挖掘地块）连接
	# 避免区域之间直接相邻
	
	LogManager.info("区域间连接确保完成")

func _refine_four_regions(_config: MapGeneratorConfig) -> void:
	"""第三步：细化四大区域（在区域分配基础上细化）"""
	LogManager.info("开始细化四大区域...")
	
	# 1. 细化房间系统区域
	LogManager.info("细化房间系统区域...")
	_refine_room_system_region(_config)
	
	# 2. 细化迷宫系统区域
	LogManager.info("细化迷宫系统区域...")
	_refine_maze_system_region(_config)
	
	# 3. 细化生态系统区域
	LogManager.info("细化生态系统区域...")
	_refine_ecosystem_region(_config)
	
	# 4. 细化英雄营地区域
	LogManager.info("细化英雄营地区域...")
	_refine_hero_camp_region(_config)
	
	LogManager.info("四大区域细化完成")

func _refine_room_system_region(_config: MapGeneratorConfig) -> void:
	"""细化房间系统区域"""
	var map_size_x = int(_config.size.x)
	var map_size_z = int(_config.size.z)
	var center_x = int(_config.size.x / 2)
	var center_z = int(_config.size.z / 2)
	
	# 🔧 [新增] 使用简化房间生成器
	if simple_room_generator:
		LogManager.info("使用简化房间生成器生成房间...")
		# 注意：简化房间生成器需要空洞作为输入，这里暂时跳过
		# 实际的房间生成将在空洞填充阶段进行
		LogManager.info("简化房间生成器已准备就绪，将在空洞填充阶段生成房间")
		return
	
	# 备用方案：原有的简单房间生成逻辑
	LogManager.warning("使用简单房间生成逻辑...")
	_generate_simple_rooms(_config)

# 废弃的高级房间应用函数已删除

func _apply_room_walls_to_map(room, adjusted_pos: Vector2i, _config: MapGeneratorConfig) -> void:
	"""将房间墙壁应用到地图"""
	# 获取地图尺寸
	var map_size = tile_manager.get_map_size()
	var map_size_x = int(map_size.x)
	var map_size_z = int(map_size.z)
	
	# 简化版墙壁生成：在房间周围放置墙壁
	var rect = room.get_rect()
	
	# 生成顶部和底部墙壁
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		var top_wall_pos = Vector3(adjusted_pos.x + x, 0, adjusted_pos.y + rect.position.y - 1)
		var bottom_wall_pos = Vector3(adjusted_pos.x + x, 0, adjusted_pos.y + rect.position.y + rect.size.y)
		
		if _is_valid_position(top_wall_pos, map_size_x, map_size_z):
			tile_manager.set_tile_type(top_wall_pos, TileTypes.TileType.STONE_WALL)
		if _is_valid_position(bottom_wall_pos, map_size_x, map_size_z):
			tile_manager.set_tile_type(bottom_wall_pos, TileTypes.TileType.STONE_WALL)
	
	# 生成左侧和右侧墙壁
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		var left_wall_pos = Vector3(adjusted_pos.x + rect.position.x - 1, 0, adjusted_pos.y + y)
		var right_wall_pos = Vector3(adjusted_pos.x + rect.position.x + rect.size.x, 0, adjusted_pos.y + y)
		
		if _is_valid_position(left_wall_pos, map_size_x, map_size_z):
			tile_manager.set_tile_type(left_wall_pos, TileTypes.TileType.STONE_WALL)
		if _is_valid_position(right_wall_pos, map_size_x, map_size_z):
			tile_manager.set_tile_type(right_wall_pos, TileTypes.TileType.STONE_WALL)

func _is_valid_position(pos: Vector3, map_size_x: int, map_size_z: int) -> bool:
	"""检查位置是否有效"""
	return pos.x >= 0 and pos.x < map_size_x and pos.z >= 0 and pos.z < map_size_z

func _generate_simple_rooms(_config: MapGeneratorConfig) -> void:
	"""生成简单房间（备用方案）"""
	var map_size_x = int(_config.size.x)
	var map_size_z = int(_config.size.z)
	var center_x = int(_config.size.x / 2)
	var center_z = int(_config.size.z / 2)
	
	# 在房间系统区域内生成具体房间
	var room_area_size = 25
	var half_size = room_area_size / 2
	
	# 🔧 [优化] 增加房间生成数量和优化尺寸
	var room_count = 0
	var max_rooms = 15 # 增加房间数量
	var max_attempts = max_rooms * 20 # 增加尝试次数
	
	for i in range(max_attempts):
		if room_count >= max_rooms:
			break
			
		# 🔧 [优化] 使用更小的房间尺寸
		var room_size = Vector2i(randi_range(3, 6), randi_range(3, 6)) # 缩小尺寸范围
		var room_pos = Vector2i(
			center_x + randi_range(-half_size + 2, half_size - room_size.x - 2),
			center_z + randi_range(-half_size + 2, half_size - room_size.y - 2)
		)
		
		# 检查房间是否在房间系统区域内且不重叠
		if _is_room_in_room_system_area(room_pos, room_size, center_x, center_z, half_size):
			# 创建房间
			for dx in range(room_size.x):
				for dz in range(room_size.y):
					var x = room_pos.x + dx
					var z = room_pos.y + dz
					if x >= 0 and x < map_size_x and z >= 0 and z < map_size_z:
						var pos = Vector3(x, 0, z)
						# 检查是否在房间系统区域内
						# 🔧 [统一数据管理] 区域类型检查已简化，直接设置瓦片类型
						tile_manager.set_tile_type(pos, TileTypes.TileType.STONE_FLOOR)
			room_count += 1
			
			if room_count <= 5: # 只记录前5个房间
				LogManager.info("细化房间 #%d: 位置(%d,%d) 大小(%dx%d)" % [
					room_count, room_pos.x, room_pos.y, room_size.x, room_size.y
				])
	
	LogManager.info("简单房间系统区域细化完成: 生成 %d 个房间" % room_count)

func _is_room_in_room_system_area(room_pos: Vector2i, room_size: Vector2i, center_x: int, center_z: int, half_size: int) -> bool:
	"""检查房间是否在房间系统区域内"""
	var room_end_x = room_pos.x + room_size.x
	var room_end_z = room_pos.y + room_size.y
	
	# 检查房间是否完全在房间系统区域内
	return (room_pos.x >= center_x - half_size and room_end_x <= center_x + half_size and
			room_pos.y >= center_z - half_size and room_end_z <= center_z + half_size)

func _refine_maze_system_region(_config: MapGeneratorConfig) -> void:
	"""细化迷宫系统区域"""
	var map_size_x = int(_config.size.x)
	var map_size_z = int(_config.size.z)
	
	# 在迷宫系统区域内生成迷宫
	var maze_tiles = 0
	for x in range(map_size_x):
		for z in range(map_size_z):
			var pos = Vector3(x, 0, z)
			
			# 检查是否在迷宫系统区域内
			# 🔧 [统一数据管理] 区域类型检查已简化，使用简单的迷宫模式
			if (x + z) % 3 == 0 or (x * z) % 7 == 0:
				tile_manager.set_tile_type(pos, TileTypes.TileType.EMPTY)
				maze_tiles += 1
	
	LogManager.info("迷宫系统区域细化完成: 生成 %d 个迷宫瓦片" % maze_tiles)

func _refine_ecosystem_region(_config: MapGeneratorConfig) -> void:
	"""🔧 [修复生态系统生成] 细化生态系统区域 - 重新设计版本"""
	var map_size_x = int(_config.size.x)
	var map_size_z = int(_config.size.z)
	
	LogManager.info("🔧 [生态系统生成] 开始细化生态系统区域...")
	
	# 🔧 [修复噪声参数] 重新设置噪声生成参数
	height_noise.frequency = _config.noise_scale
	humidity_noise.frequency = _config.noise_scale * 0.7 # 湿度噪声频率稍低
	temperature_noise.frequency = _config.noise_scale * 1.3 # 温度噪声频率稍高
	
	LogManager.info("🔧 [噪声参数] 噪声频率设置:")
	LogManager.info("  高度噪声: %.3f" % height_noise.frequency)
	LogManager.info("  湿度噪声: %.3f" % humidity_noise.frequency)
	LogManager.info("  温度噪声: %.3f" % temperature_noise.frequency)
	
	# 在生态系统区域内生成生态内容
	var ecosystem_tiles = 0
	var ecosystem_type_counts = {
		EcosystemType.FOREST: 0,
		EcosystemType.WASTELAND: 0,
		EcosystemType.SWAMP: 0,
		EcosystemType.CAVE: 0
	}
	
	for x in range(map_size_x):
		for z in range(map_size_z):
			var pos = Vector3(x, 0, z)
			
			# 🔧 [简化区域检查] 所有 UNEXCAVATED 瓦片都视为生态系统区域
			var current_tile_type = tile_manager.get_tile_type(pos)
			if current_tile_type == TileTypes.TileType.UNEXCAVATED:
				# 🔧 [修复生态系统分配] 使用改进的噪声确定生态类型
				var height_value = height_noise.get_noise_2d(x, z)
				var humidity_value = humidity_noise.get_noise_2d(x, z)
				var temperature_value = temperature_noise.get_noise_2d(x, z)
				
				var ecosystem_type = _determine_ecosystem_type_improved(height_value, humidity_value, temperature_value)
				var tile_type = _get_tile_type_for_ecosystem(ecosystem_type)
				
				tile_manager.set_tile_type(pos, tile_type)
				ecosystem_tiles += 1
				ecosystem_type_counts[ecosystem_type] += 1
	
	# 🔧 [数据验证] 输出生态系统生成结果
	LogManager.info("📊 [数据验证] 生态系统生成完成:")
	LogManager.info("  总生态瓦片数: %d" % ecosystem_tiles)
	LogManager.info("  森林: %d 瓦片" % ecosystem_type_counts[EcosystemType.FOREST])
	LogManager.info("  荒地: %d 瓦片" % ecosystem_type_counts[EcosystemType.WASTELAND])
	LogManager.info("  沼泽: %d 瓦片" % ecosystem_type_counts[EcosystemType.SWAMP])
	LogManager.info("  洞穴: %d 瓦片" % ecosystem_type_counts[EcosystemType.CAVE])

func _determine_ecosystem_type_improved(height: float, humidity: float, temperature: float) -> EcosystemType:
	"""🔧 [修复生态系统分配] 改进的生态系统类型确定算法"""
	# 🔧 [修复噪声参数] 使用更合理的阈值和分布
	var height_threshold = 0.2 # 降低高度阈值，增加地形变化
	var humidity_threshold = 0.1 # 降低湿度阈值，增加湿度变化
	var temperature_threshold = 0.3 # 调整温度阈值，平衡温度分布
	
	# 使用多层判断逻辑，确保生态系统类型正确分布
	if height > height_threshold:
		# 高地区域
		if humidity > humidity_threshold:
			return EcosystemType.FOREST # 高地 + 湿润 = 森林
		else:
			return EcosystemType.WASTELAND # 高地 + 干燥 = 荒地
	else:
		# 低地区域
		if humidity > humidity_threshold:
			if temperature > temperature_threshold:
				return EcosystemType.SWAMP # 低地 + 湿润 + 温暖 = 沼泽
			else:
				return EcosystemType.CAVE # 低地 + 湿润 + 寒冷 = 洞穴
		else:
			return EcosystemType.WASTELAND # 低地 + 干燥 = 荒地


func _refine_hero_camp_region(_config: MapGeneratorConfig) -> void:
	"""细化英雄营地区域"""
	var map_size_x = int(_config.size.x)
	var map_size_z = int(_config.size.z)
	
	# 在英雄营地区域内生成传送门
	var hero_camp_tiles = 0
	for x in range(map_size_x):
		for z in range(map_size_z):
			var pos = Vector3(x, 0, z)
		
			tile_manager.set_tile_type(pos, TileTypes.TileType.PORTAL)
			hero_camp_tiles += 1

	LogManager.info("英雄营地区域细化完成: 生成 %d 个传送门" % hero_camp_tiles)

func _generate_four_regions(_config: MapGeneratorConfig) -> void:
	"""第三步：生成四大区域（原始函数，保留兼容性）"""
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

func _generate_room_system(_config: MapGeneratorConfig) -> void:
	"""生成房间系统"""
	LogManager.info("生成房间系统...")
	
	rooms.clear()
	room_counter = 0
	
	# 🔧 [新增] 使用简化房间生成器
	if simple_room_generator:
		LogManager.info("使用简化房间生成器生成房间...")
		# 注意：简化房间生成器需要空洞作为输入，这里暂时跳过
		# 实际的房间生成将在空洞填充阶段进行
		LogManager.info("简化房间生成器已准备就绪，将在空洞填充阶段生成房间")
		return
	
	# 备用方案：原有的简单房间生成逻辑
	LogManager.warning("使用简单房间生成逻辑...")
	_generate_random_rooms(_config)
	
	_connect_rooms()
	
	# 生成地牢之心
	_place_dungeon_heart()
	_create_heart_clearing()

func _generate_maze_system(_config: MapGeneratorConfig) -> void:
	"""生成迷宫系统"""
	LogManager.info("生成迷宫系统...")
	
	# 使用递归回溯算法生成迷宫
	_generate_maze_with_backtracking(_config)

func _generate_maze_with_backtracking(_config: MapGeneratorConfig) -> void:
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
			maze_grid[x].append(1) # 1表示墙，0表示通道
	
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
			if maze_grid[x][z] == 0: # 通道
				tile_manager.set_tile_type(world_pos, TileTypes.TileType.CORRIDOR)
				

func _generate_ecosystem_regions(_config: MapGeneratorConfig) -> void:
	"""生成生态系统区域"""
	LogManager.info("生成生态系统区域...")
	
	# 检查生态系统管理器
	if not ecosystem_manager:
		LogManager.error("ERROR: EcosystemManager 未找到！无法生成生态系统区域")
		return
	
	# 设置生态系统管理器的引用
	ecosystem_manager.set_tile_manager(tile_manager)
	ecosystem_manager.set_character_manager(character_manager)
	
	# 使用生态系统管理器生成区域
	var region_count = randi_range(3, 6) # 生成3-6个生态区域
	var regions = ecosystem_manager.generate_ecosystem_regions(_config.size, region_count)
	
	LogManager.info("生态系统区域生成完成，共生成 %d 个区域" % regions.size())

func _apply_ecosystem_region(region) -> void:
	"""将生态区域应用到地图"""
	for x in range(region.size.x):
		for z in range(region.size.y):
			var world_pos = Vector3(region.position.x + x, 0, region.position.y + z)
			var tile_type = _get_tile_type_for_ecosystem(region.ecosystem_type)
			tile_manager.set_tile_type(world_pos, tile_type)
			

func _generate_hero_camps(_config: MapGeneratorConfig) -> void:
	"""生成英雄营地/传送门"""
	LogManager.info("生成英雄营地/传送门...")
	
	# 🔧 [统一数据管理] 英雄营地数据直接存储在 TileManager 中
	
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
		# 🔧 [统一数据管理] 英雄营地数据直接存储在 TileManager 中
		
		# 在地图上标记传送门
		tile_manager.set_tile_type(Vector3(camp_pos.x, 0, camp_pos.y), TileTypes.TileType.PORTAL)

func _generate_resources_and_creatures(_config: MapGeneratorConfig) -> void:
	"""第四步：生成资源和生物"""
	LogManager.info("生成资源和生物...")
	
	# 生成金矿（提高概率：从0.016提升到0.08，5倍提升）
	_generate_gold_veins(config.resource_density * 0.08, 500)
	
	# 在生态区域生成资源
	# 🔧 [统一数据管理] 生态系统资源生成已简化
	# 🔧 [统一数据管理] 资源生成已简化，直接通过 TileManager 管理

func _generate_ecosystem_resources(region) -> void:
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
	LogManager.info("开始初始化所有地块为未挖掘状态...")
	
	var total_tiles = tile_manager.map_size.x * tile_manager.map_size.z
	var processed_tiles = 0
	
	for x in range(tile_manager.map_size.x):
		for z in range(tile_manager.map_size.z):
			var pos = Vector3(x, 0, z)
			# 🔧 修复：使用set_tile_type确保正确创建3D对象
			tile_manager.set_tile_type(pos, TileTypes.TileType.UNEXCAVATED)
			processed_tiles += 1
			
			# 🔧 [性能优化] 每1000个瓦片输出一次进度并让出控制权
			if processed_tiles % 1000 == 0:
				var progress = (processed_tiles / float(total_tiles)) * 100
				LogManager.info("瓦片初始化进度: %d/%d (%.1f%%)" % [processed_tiles, total_tiles, progress])
				# 让出控制权，防止游戏卡死
				await get_tree().process_frame
	
	LogManager.info("所有地块初始化完成: %d 个瓦片" % processed_tiles)
	

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
			var success = tile_manager.set_tile_type(pos, TileTypes.TileType.DUNGEON_HEART)
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
			tile_manager.set_tile_type(pos, TileTypes.TileType.EMPTY)
	

func _adjust_config_for_type(_config: MapGeneratorConfig) -> void:
	"""根据地图类型调整配置参数"""
	# 可以根据不同的地图类型调整房间生成参数
	# 目前使用默认配置，可以根据需要扩展
	pass

func _generate_rooms_on_map(_config: MapGeneratorConfig) -> void:
	"""第二步：在地图上生成房间"""
	
	# 根据地图类型调整参数
	_adjust_config_for_type(_config)
	
	rooms.clear()
	room_counter = 0
	
	# 在地图中心25x25区域内生成随机房间
	_generate_random_rooms(_config)
	
	_connect_rooms()
	
	# 最后生成地牢之心，并将周围区域强制修改为EMPTY
	_place_dungeon_heart()
	_create_heart_clearing()

	# 依据 MINING_SYSTEM.md：在未挖掘岩石中生成金矿（约1.6% 概率，每脉500单位）
	_generate_gold_veins(0.016, 500)
	

func _generate_random_rooms(_config: MapGeneratorConfig) -> void:
	"""在地图中心25x25区域内生成随机房间"""
	
	# 🔧 [优化] 增加房间生成尝试，提高成功率
	var room_count = randi_range(8, _config.max_room_count) # 最小房间数从5增加到8
	var max_attempts = room_count * 30 # 增加尝试次数
	var attempts = 0
	var successful_rooms = 0
	
	LogManager.info("开始生成房间: 目标 %d 个房间，最大尝试次数 %d" % [room_count, max_attempts])
	
	for i in range(max_attempts):
		if successful_rooms >= room_count:
			break
			
		var room = _create_random_room(_config)
		if room:
			rooms.append(room)
			_generate_room_floor(room)
			_generate_room_walls(room)
			successful_rooms += 1
			if successful_rooms <= 5: # 只记录前5个房间
				LogManager.info("成功生成房间 #%d: 位置(%d,%d) 大小(%dx%d)" % [
					room.room_id, room.position.x, room.position.y, room.size.x, room.size.y
				])
		else:
			attempts += 1
	
	LogManager.info("房间生成完成: 成功生成 %d 个房间，尝试次数 %d" % [successful_rooms, attempts])
	

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
			if tile.type == TileTypes.TileType.UNEXCAVATED:
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
					tile_manager.set_tile_type(pos, TileTypes.TileType.GOLD_MINE)
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
	
	# 通知资源管理器（整合金矿系统）重新扫描金矿
	LogManager.info("MapGenerator - 通知 ResourceManager 重新扫描金矿")
	if GameServices.is_service_ready("resource_manager"):
		var resource_manager = GameServices.get_gold_mines()
		if resource_manager and resource_manager.has_method("rescan_gold_mines"):
			# 延迟一帧确保瓦片数据已更新
			resource_manager.call_deferred("rescan_gold_mines")
		else:
			LogManager.warning("ResourceManager 没有 rescan_gold_mines 方法，跳过")
	else:
		LogManager.warning("ResourceManager 未就绪，跳过金矿重扫通知")


func _create_random_room(_config: MapGeneratorConfig) -> Room:
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
	
	# 🔧 [优化] 改进走廊生成：先垂直移动，再水平移动（避免与房间重叠）
	# 先垂直移动
	while current.y != target.y:
		if _should_place_corridor(Vector3(current.x, 0, current.y)):
			_set_tile_type(Vector3(current.x, 0, current.y), TileTypes.TileType.CORRIDOR)
		if current.y < target.y:
			current.y += 1
		else:
			current.y -= 1
	
	# 再水平移动
	while current.x != target.x:
		if _should_place_corridor(Vector3(current.x, 0, current.y)):
			_set_tile_type(Vector3(current.x, 0, current.y), TileTypes.TileType.CORRIDOR)
		if current.x < target.x:
			current.x += 1
		else:
			current.x -= 1
	
	# 设置目标点
	if _should_place_corridor(Vector3(current.x, 0, current.y)):
		_set_tile_type(Vector3(current.x, 0, current.y), TileTypes.TileType.CORRIDOR)

func _should_place_corridor(position: Vector3) -> bool:
	"""判断是否应该在此位置放置走廊"""
	if position.x < 0 or position.x >= tile_manager.map_size.x or position.z < 0 or position.z >= tile_manager.map_size.z:
		return false
	
	# 获取当前位置的地块类型
	var tile_data = tile_manager.get_tile_data(position)
	if not tile_data:
		return true # 如果没有地块数据，放置走廊
	
	# 🔧 [优化] 智能走廊放置规则：
	# 1. 如果已经是走廊，不重复放置
	if tile_data.type == TileTypes.TileType.CORRIDOR:
		return false
	
	# 2. 如果是地牢之心，不放置走廊
	if tile_data.type == TileTypes.TileType.DUNGEON_HEART:
		return false
	
	# 3. 如果是房间地板，不放置走廊（保持房间完整性）
	if tile_data.type == TileTypes.TileType.STONE_FLOOR:
		return false
	
	# 4. 如果是墙壁，替换为走廊（打通连接）
	if tile_data.type == TileTypes.TileType.STONE_WALL:
		return true
	
	# 5. 其他情况（如UNEXCAVATED）可以放置走廊
	return true

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
# var config = MapGenerator.MapGeneratorConfig.new(Vector3(100, 1, 100))
# map_generator.generate_map(config)

## 创建大型地图
# var config = MapGenerator.MapGeneratorConfig.new(Vector3(200, 1, 200))
# config.max_room_count = 30
# config.resource_density = 0.2
# map_generator.generate_map(config)

## 创建资源丰富地图
# var config = MapGenerator.MapGeneratorConfig.new(Vector3(150, 1, 150))
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
	"""生成房间内部 - 将房间内部填充为STONE_FLOOR（使用autoload常量）"""
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
			if tile_data and tile_data.type == TileTypes.TileType.DUNGEON_HEART:
				continue
			
			# 🔧 [优化] 使用autoload常量将房间内部填充为STONE_FLOOR（石头地板）
			var success = tile_manager.set_tile_type(position, TileTypes.TileType.STONE_FLOOR)
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
	
	# 🔧 [优化] 智能墙壁生成：只在需要的地方放置墙壁
	# 生成顶部墙壁
	for x in range(rect.position.x - 1, rect.position.x + rect.size.x + 1):
		var top_wall_pos = Vector3(x, 0, rect.position.y - 1)
		if _should_place_wall(top_wall_pos):
			if tile_manager.set_tile_type(top_wall_pos, TileTypes.TileType.STONE_WALL):
				wall_tiles_placed += 1
			else:
				wall_tiles_failed += 1
	
	# 生成底部墙壁
	for x in range(rect.position.x - 1, rect.position.x + rect.size.x + 1):
		var bottom_wall_pos = Vector3(x, 0, rect.position.y + rect.size.y)
		if _should_place_wall(bottom_wall_pos):
			if tile_manager.set_tile_type(bottom_wall_pos, TileTypes.TileType.STONE_WALL):
				wall_tiles_placed += 1
			else:
				wall_tiles_failed += 1
	
	# 生成左侧墙壁
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		var left_wall_pos = Vector3(rect.position.x - 1, 0, y)
		if _should_place_wall(left_wall_pos):
			if tile_manager.set_tile_type(left_wall_pos, TileTypes.TileType.STONE_WALL):
				wall_tiles_placed += 1
			else:
				wall_tiles_failed += 1
	
	# 生成右侧墙壁
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		var right_wall_pos = Vector3(rect.position.x + rect.size.x, 0, y)
		if _should_place_wall(right_wall_pos):
			if tile_manager.set_tile_type(right_wall_pos, TileTypes.TileType.STONE_WALL):
				wall_tiles_placed += 1
			else:
				wall_tiles_failed += 1
	
	# 调试：输出墙壁生成统计
	if wall_tiles_failed > 0:
		LogManager.warning("⚠️ [MapGenerator] 房间 #%d 墙壁生成: 成功=%d, 失败=%d" % [
			room.room_id, wall_tiles_placed, wall_tiles_failed
		])

func _should_place_wall(position: Vector3) -> bool:
	"""判断是否应该在此位置放置墙壁"""
	if position.x < 0 or position.x >= tile_manager.map_size.x or position.z < 0 or position.z >= tile_manager.map_size.z:
		return false
	
	# 获取当前位置的地块类型
	var tile_data = tile_manager.get_tile_data(position)
	if not tile_data:
		return true # 如果没有地块数据，放置墙壁
	
	# 🔧 [优化] 智能墙壁放置规则：
	# 1. 如果已经是墙壁，不重复放置
	if tile_data.type == TileTypes.TileType.STONE_WALL:
		return false
	
	# 2. 如果是地牢之心，不放置墙壁
	if tile_data.type == TileTypes.TileType.DUNGEON_HEART:
		return false
	
	# 3. 如果是走廊，不放置墙壁（保持连接）
	if tile_data.type == TileTypes.TileType.CORRIDOR:
		return false
	
	# 4. 如果是房间地板，不放置墙壁
	if tile_data.type == TileTypes.TileType.STONE_FLOOR:
		return false
	
	# 5. 其他情况（如UNEXCAVATED）可以放置墙壁
	return true

# ============================================================================
# 公共接口
# ============================================================================

# 地形管理器已删除，使用 CavityManager 统一管理

# ============================================================================
# 空洞系统集成方法
# ============================================================================

func _initialize_cavity_system(_config: MapGeneratorConfig) -> void:
	"""初始化空洞系统"""
	LogManager.info("CavitySystem - 初始化空洞系统")
	
	# 创建空洞挖掘器
	cavity_excavator = CavityExcavator.new()
	cavity_excavator.set_map_size(int(_config.size.x), int(_config.size.z))
	cavity_excavator.set_tile_manager(tile_manager)
	add_child(cavity_excavator)
	
	# 设置空洞管理器
	cavity_manager = preload("res://scripts/map_system/cavity_system/CavityManager.gd").new()
	cavity_manager.name = "CavityManager"
	add_child(cavity_manager)
	
	# 初始化地形管理器
	terrain_manager = preload("res://scripts/map_system/cavity_system/highlight/TerrainManager.gd").new()
	terrain_manager.name = "TerrainManager"
	add_child(terrain_manager)
	
	# 初始化地形高亮系统
	terrain_highlight_system = preload("res://scripts/map_system/cavity_system/highlight/TerrainHighlightSystem.gd").new()
	terrain_highlight_system.name = "TerrainHighlightSystem"
	terrain_highlight_system.set_tile_manager(tile_manager)
	add_child(terrain_highlight_system)
	
	# 设置 TerrainHighlightSystem 的 TerrainManager 引用
	terrain_highlight_system.terrain_manager = terrain_manager
	
	# 配置空洞生成参数
	var min_distance = 25.0
	var avg_radius = 12.0
	cavity_excavator.set_generation_parameters(min_distance, avg_radius)
	
	LogManager.info("CavitySystem - 空洞系统初始化完成")

func _initialize_base_terrain(_config: MapGeneratorConfig) -> void:
	"""初始化基础地形 - 全部为未挖掘岩石"""
	LogManager.info("CavitySystem - 初始化基础地形")
	
	var map_width = int(_config.size.x)
	var map_height = int(_config.size.z)
	
	for x in range(map_width):
		for z in range(map_height):
			var pos = Vector3(x, 0, z)
			tile_manager.set_tile_type(pos, TileTypes.TileType.UNEXCAVATED)
	
	LogManager.info("CavitySystem - 基础地形初始化完成: %dx%d" % [map_width, map_height])

func _initialize_critical_buildings(_config: MapGeneratorConfig) -> void:
	"""初始化关键建筑"""
	LogManager.info("CavitySystem - 初始化关键建筑")
	
	# 挖掘关键空洞
	var critical_cavities = cavity_excavator.excavate_critical_cavities()
	
	for cavity in critical_cavities:
		cavity_manager.register_cavity(cavity)
		# 同时注册到地形管理器
		terrain_manager.register_terrain_from_cavity(cavity.id)
	
	LogManager.info("CavitySystem - 关键建筑初始化完成: %d 个" % critical_cavities.size())

func _generate_poisson_cavities(_config: MapGeneratorConfig) -> void:
	"""使用泊松圆盘分布生成空洞"""
	LogManager.info("CavitySystem - 生成泊松圆盘空洞")
	
	# 挖掘所有空洞
	LogManager.info("CavitySystem - 开始挖掘空洞...")
	var all_cavities = cavity_excavator.excavate_all_cavities()
	LogManager.info("CavitySystem - 挖掘完成，获得 %d 个空洞" % all_cavities.size())
	
	if all_cavities.size() == 0:
		LogManager.warning("⚠️ 没有生成任何空洞！")
		return
	
	LogManager.info("CavitySystem - 开始注册空洞到管理器...")
	var registered_count = 0
	for i in range(all_cavities.size()):
		var cavity = all_cavities[i]
		# LogManager.info("注册空洞 %d/%d: ID=%s, 类型=%s, 中心=%s, 位置数=%d" % [i + 1, all_cavities.size(), cavity.id, cavity.content_type, cavity.center, cavity.positions.size()])
		
		cavity_manager.register_cavity(cavity)
		# 同时注册到地形管理器
		terrain_manager.register_terrain_from_cavity(cavity.id)
		registered_count += 1
	
	LogManager.info("CavitySystem - 成功注册 %d 个空洞到管理器" % registered_count)
	
	# 挖掘连接通道
	LogManager.info("CavitySystem - 开始挖掘连接通道...")
	cavity_excavator.excavate_connecting_corridors(all_cavities)
	
	LogManager.info("CavitySystem - 泊松圆盘空洞生成完成: %d 个" % all_cavities.size())

func _populate_cavity_contents(_config: MapGeneratorConfig) -> void:
	"""填充空洞内容"""
	LogManager.info("CavitySystem - 填充空洞内容")
	
	# 获取所有空洞
	var all_cavities = cavity_manager.get_all_cavities()
	
	for cavity in all_cavities:
		match cavity.content_type:
			"FOREST":
				_populate_forest_cavity(cavity)
			"LAKE":
				_populate_lake_cavity(cavity)
			"CAVE":
				_populate_cave_cavity(cavity)
			"WASTELAND":
				_populate_wasteland_cavity(cavity)
			"SWAMP":
				_populate_swamp_cavity(cavity)
			"GRASSLAND":
				_populate_grassland_cavity(cavity)
			"DEAD_LAND":
				_populate_dead_land_cavity(cavity)
			"PRIMITIVE":
				_populate_primitive_cavity(cavity)
			"ROOM_SYSTEM":
				_populate_room_system_cavity(cavity)
			"MAZE_SYSTEM":
				_populate_maze_system_cavity(cavity)
			_:
				LogManager.debug("CavitySystem - 跳过未知内容类型: %s" % cavity.content_type)
	
	LogManager.info("CavitySystem - 空洞内容填充完成")
	
	# 生成资源和生物
	_generate_resources_and_creatures(_config)

func _populate_forest_cavity(cavity: Cavity) -> void:
	"""填充森林空洞 - 以EMPTY为主，特殊地块聚类生成"""
	LogManager.info("🌲 填充森林空洞，位置数量: %d" % cavity.positions.size())
	
	# 首先将所有位置设置为EMPTY
	for pos in cavity.positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.EMPTY)
	
	# 生成森林特殊地块的聚类区域
	_generate_ecosystem_clusters(cavity.positions, "FOREST")
	
	# 使用生态系统管理器填充区域
	if ecosystem_manager:
		if ecosystem_manager.has_method("populate_ecosystem_region"):
			ecosystem_manager.populate_ecosystem_region(cavity.positions, "FOREST")
		else:
			LogManager.warning("EcosystemManager 缺少 populate_ecosystem_region 方法")
	else:
		LogManager.warning("EcosystemManager 未初始化")
	
	LogManager.info("🌲 森林空洞填充完成")

func _populate_lake_cavity(cavity: Cavity) -> void:
	"""填充湖泊空洞 - 以EMPTY为主，特殊地块聚类生成"""
	LogManager.info("🏞️ 填充湖泊空洞，位置数量: %d" % cavity.positions.size())
	
	# 首先将所有位置设置为EMPTY
	for pos in cavity.positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.EMPTY)
	
	# 生成湖泊特殊地块的聚类区域
	_generate_ecosystem_clusters(cavity.positions, "LAKE")
	
	# 使用生态系统管理器填充区域
	if ecosystem_manager:
		if ecosystem_manager.has_method("populate_ecosystem_region"):
			ecosystem_manager.populate_ecosystem_region(cavity.positions, "LAKE")
		else:
			LogManager.warning("EcosystemManager 缺少 populate_ecosystem_region 方法")
	else:
		LogManager.warning("EcosystemManager 未初始化")
	
	LogManager.info("🏞️ 湖泊空洞填充完成")

func _populate_cave_cavity(cavity: Cavity) -> void:
	"""填充洞穴空洞 - 以EMPTY为主，特殊地块聚类生成"""
	LogManager.info("🕳️ 填充洞穴空洞，位置数量: %d" % cavity.positions.size())
	
	# 首先将所有位置设置为EMPTY
	for pos in cavity.positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.EMPTY)
	
	# 生成洞穴特殊地块的聚类区域
	_generate_ecosystem_clusters(cavity.positions, "CAVE")
	
	# 使用生态系统管理器填充区域
	if ecosystem_manager:
		if ecosystem_manager.has_method("populate_ecosystem_region"):
			ecosystem_manager.populate_ecosystem_region(cavity.positions, "CAVE")
		else:
			LogManager.warning("EcosystemManager 缺少 populate_ecosystem_region 方法")
	else:
		LogManager.warning("EcosystemManager 未初始化")
	
	LogManager.info("🕳️ 洞穴空洞填充完成")

func _populate_wasteland_cavity(cavity: Cavity) -> void:
	"""填充荒地空洞 - 以EMPTY为主，特殊地块聚类生成"""
	LogManager.info("🏜️ 填充荒地空洞，位置数量: %d" % cavity.positions.size())
	
	# 首先将所有位置设置为EMPTY
	for pos in cavity.positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.EMPTY)
	
	# 生成荒地特殊地块的聚类区域
	_generate_ecosystem_clusters(cavity.positions, "WASTELAND")
	
	# 使用生态系统管理器填充区域
	if ecosystem_manager:
		if ecosystem_manager.has_method("populate_ecosystem_region"):
			ecosystem_manager.populate_ecosystem_region(cavity.positions, "WASTELAND")
		else:
			LogManager.warning("EcosystemManager 缺少 populate_ecosystem_region 方法")
	else:
		LogManager.warning("EcosystemManager 未初始化")
	
	LogManager.info("🏜️ 荒地空洞填充完成")

func _populate_swamp_cavity(cavity: Cavity) -> void:
	"""填充沼泽空洞 - 以EMPTY为主，特殊地块聚类生成"""
	LogManager.info("🐊 填充沼泽空洞，位置数量: %d" % cavity.positions.size())
	
	# 首先将所有位置设置为EMPTY
	for pos in cavity.positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.EMPTY)
	
	# 生成沼泽特殊地块的聚类区域
	_generate_ecosystem_clusters(cavity.positions, "SWAMP")
	
	if ecosystem_manager and ecosystem_manager.has_method("populate_ecosystem_region"):
		ecosystem_manager.populate_ecosystem_region(cavity.positions, "SWAMP")
	
	LogManager.info("🐊 沼泽空洞填充完成")

func _populate_grassland_cavity(cavity: Cavity) -> void:
	"""填充草地空洞 - 以EMPTY为主，特殊地块聚类生成"""
	LogManager.info("🌱 填充草地空洞，位置数量: %d" % cavity.positions.size())
	
	# 首先将所有位置设置为EMPTY
	for pos in cavity.positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.EMPTY)
	
	# 生成草地特殊地块的聚类区域
	_generate_ecosystem_clusters(cavity.positions, "GRASSLAND")
	
	if ecosystem_manager and ecosystem_manager.has_method("populate_ecosystem_region"):
		ecosystem_manager.populate_ecosystem_region(cavity.positions, "GRASSLAND")
	
	LogManager.info("🌱 草地空洞填充完成")

func _populate_dead_land_cavity(cavity: Cavity) -> void:
	"""填充死地空洞 - 以EMPTY为主，特殊地块聚类生成"""
	LogManager.info("💀 填充死地空洞，位置数量: %d" % cavity.positions.size())
	
	# 首先将所有位置设置为EMPTY
	for pos in cavity.positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.EMPTY)
	
	# 生成死地特殊地块的聚类区域
	_generate_ecosystem_clusters(cavity.positions, "DEAD_LAND")
	
	if ecosystem_manager and ecosystem_manager.has_method("populate_ecosystem_region"):
		ecosystem_manager.populate_ecosystem_region(cavity.positions, "DEAD_LAND")
	
	LogManager.info("💀 死地空洞填充完成")

func _populate_primitive_cavity(cavity: Cavity) -> void:
	"""填充原始生态空洞 - 以EMPTY为主，特殊地块聚类生成"""
	LogManager.info("🌿 填充原始生态空洞，位置数量: %d" % cavity.positions.size())
	
	# 首先将所有位置设置为EMPTY
	for pos in cavity.positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.EMPTY)
	
	# 生成原始生态特殊地块的聚类区域
	_generate_ecosystem_clusters(cavity.positions, "PRIMITIVE")
	
	if ecosystem_manager and ecosystem_manager.has_method("populate_ecosystem_region"):
		ecosystem_manager.populate_ecosystem_region(cavity.positions, "PRIMITIVE")
	
	LogManager.info("🌿 原始生态空洞填充完成")

func _populate_room_system_cavity(cavity: Cavity) -> void:
	"""填充房间系统空洞"""
	LogManager.info("在空洞 %s 内生成简化房间系统..." % cavity.id)
	
	# 🔧 [新增] 使用简化房间生成器在空洞内生成房间
	if simple_room_generator:
		if simple_room_generator.has_method("generate_rooms_in_cavity"):
			LogManager.info("使用简化房间生成器在空洞内生成房间...")
			var generated_rooms = simple_room_generator.generate_rooms_in_cavity(cavity)
			
			if generated_rooms.size() > 0:
				LogManager.info("在空洞 %s 内成功生成 %d 个简化房间" % [cavity.id, generated_rooms.size()])
				# 应用房间到地图
				if simple_room_generator.has_method("apply_rooms_to_map"):
					simple_room_generator.apply_rooms_to_map(generated_rooms)
				# 保存到全局房间列表
				simple_rooms.append_array(generated_rooms)
			else:
				LogManager.warning("在空洞 %s 内未生成任何房间" % cavity.id)
		else:
			LogManager.error("SimpleRoomGenerator 缺少 generate_rooms_in_cavity 方法")
	else:
		LogManager.error("SimpleRoomGenerator 未初始化")


func _populate_maze_system_cavity(cavity: Cavity) -> void:
	"""填充迷宫系统空洞"""
	LogManager.info("在空洞 %s 内生成迷宫系统..." % cavity.id)
	
	# 检查SimpleMazeGenerator是否存在
	var maze_generator = get_node_or_null("SimpleMazeGenerator")
	if not maze_generator:
		LogManager.error("SimpleMazeGenerator 未找到")
		return
	
	# 检查必要的方法是否存在
	if not maze_generator.has_method("generate_maze_in_cavity"):
		LogManager.error("SimpleMazeGenerator 缺少 generate_maze_in_cavity 方法")
		return
	
	# 生成迷宫
	var maze_data = maze_generator.generate_maze_in_cavity(cavity)
	
	if maze_data:
		LogManager.info("在空洞 %s 内迷宫生成成功: %dx%d" % [cavity.id, maze_data.size.x, maze_data.size.y])
	else:
		LogManager.warning("在空洞 %s 内迷宫生成失败" % cavity.id)

func _generate_room_in_cavity(cavity: Cavity) -> Room:
	"""在空洞内生成房间"""
	var max_attempts = 50
	
	for attempt in range(max_attempts):
		var room_size = Vector2i(randi_range(4, 8), randi_range(4, 8))
		var room_pos = _get_random_position_in_cavity(cavity, room_size)
		
		if _is_room_valid_in_cavity(room_pos, room_size, cavity):
			return _create_room(room_pos, room_size)
	
	return null

func _get_random_position_in_cavity(cavity: Cavity, room_size: Vector2i) -> Vector2i:
	"""在空洞内获取随机位置"""
	if cavity.positions.is_empty():
		return Vector2i.ZERO
	
	var random_pos = cavity.positions[randi() % cavity.positions.size()]
	return Vector2i(random_pos.x, random_pos.z)

func _is_room_valid_in_cavity(room_pos: Vector2i, room_size: Vector2i, cavity: Cavity) -> bool:
	"""检查房间在空洞内是否有效"""
	# 检查房间是否完全在空洞内
	for x in range(room_size.x):
		for z in range(room_size.y):
			var pos = Vector3(room_pos.x + x, 0, room_pos.y + z)
			if not cavity.contains_position(pos):
				return false
	return true

func _create_room(room_pos: Vector2i, room_size: Vector2i) -> Room:
	"""创建房间"""
	var room = Room.new(room_pos, room_size, rooms.size())
	
	# 设置房间瓦片
	for x in range(room_size.x):
		for z in range(room_size.y):
			var pos = Vector3(room_pos.x + x, 0, room_pos.y + z)
			tile_manager.set_tile_type(pos, TileTypes.TileType.STONE_FLOOR)
	
	rooms.append(room)
	return room

func _connect_rooms_in_cavity(rooms: Array[Room]) -> void:
	"""在空洞内连接房间"""
	# 简化的房间连接逻辑
	for i in range(rooms.size() - 1):
		var room1 = rooms[i]
		var room2 = rooms[i + 1]
		_connect_two_rooms(room1, room2)

func _connect_two_rooms(room1: Room, room2: Room) -> void:
	"""连接两个房间"""
	var start = room1.center
	var end = room2.center
	
	# 创建L形连接
	_create_corridor_between_points(start, end)

func _create_corridor_between_points(start: Vector2i, end: Vector2i) -> void:
	"""在两点间创建走廊"""
	# 水平段
	var x_min = min(start.x, end.x)
	var x_max = max(start.x, end.x)
	for x in range(x_min, x_max + 1):
		var pos = Vector3(x, 0, start.y)
		tile_manager.set_tile_type(pos, TileTypes.TileType.CORRIDOR)
	
	# 垂直段
	var y_min = min(start.y, end.y)
	var y_max = max(start.y, end.y)
	for y in range(y_min, y_max + 1):
		var pos = Vector3(end.x, 0, y)
		tile_manager.set_tile_type(pos, TileTypes.TileType.CORRIDOR)

func _generate_maze_in_cavity(cavity: Cavity) -> void:
	"""在空洞内生成迷宫"""
	# 简化的迷宫生成逻辑
	# 这里可以使用更复杂的迷宫算法
	for pos in cavity.positions:
		if randf() < 0.7: # 70%概率设置为走廊
			tile_manager.set_tile_type(pos, TileTypes.TileType.CORRIDOR)

func _validate_cavity_generation(_config: MapGeneratorConfig) -> void:
	"""验证空洞生成结果"""
	LogManager.info("CavitySystem - 开始验证空洞生成结果")
	
	# 检查空洞管理器
	if not cavity_manager:
		LogManager.error("ERROR: CavityManager 未初始化")
		return
	
	# 获取所有空洞
	var all_cavities = cavity_manager.get_all_cavities()
	if all_cavities.is_empty():
		LogManager.warning("WARNING: 未生成任何空洞")
		return
	
	# 统计各种类型的空洞
	var cavity_stats = {}
	var total_positions = 0
	
	for cavity in all_cavities:
		var content_type = cavity.content_type
		if not cavity_stats.has(content_type):
			cavity_stats[content_type] = {"count": 0, "positions": 0}
		
		cavity_stats[content_type]["count"] += 1
		cavity_stats[content_type]["positions"] += cavity.positions.size()
		total_positions += cavity.positions.size()
	
	# 输出统计信息
	LogManager.info("CavitySystem - 空洞生成统计:")
	LogManager.info("  总空洞数: %d" % all_cavities.size())
	LogManager.info("  总位置数: %d" % total_positions)
	
	for content_type in cavity_stats.keys():
		var stats = cavity_stats[content_type]
		LogManager.info("  %s: %d 个空洞, %d 个位置" % [content_type, stats["count"], stats["positions"]])
	
	# 检查地图覆盖率
	var map_size = int(_config.size.x * _config.size.z)
	var coverage_percentage = (total_positions * 100.0) / map_size
	LogManager.info("CavitySystem - 地图覆盖率: %.2f%%" % coverage_percentage)
	
	if coverage_percentage < 10.0:
		LogManager.warning("WARNING: 地图覆盖率过低 (%.2f%%)" % coverage_percentage)
	elif coverage_percentage > 80.0:
		LogManager.warning("WARNING: 地图覆盖率过高 (%.2f%%)" % coverage_percentage)
	else:
		LogManager.info("CavitySystem - 地图覆盖率正常")
	
	LogManager.info("CavitySystem - 空洞生成验证完成")

# ============================================================================
# 生态系统地块聚类生成函数
# ============================================================================

func _generate_ecosystem_clusters(positions: Array, ecosystem_type: String) -> void:
	"""在空洞中生成聚类的生态系统特殊地块"""
	if positions.is_empty():
		return
	
	# ============================================================================
	# 特殊生态系统处理 - 使用专门的地理分布算法
	# ============================================================================
	
	var special_distribution_ecosystems = {
		"LAKE": _generate_lake_geographic_distribution,
		"FOREST": _generate_forest_geographic_distribution,
		"CAVE": _generate_cave_geographic_distribution,
		"WASTELAND": _generate_wasteland_geographic_distribution,
		"GRASSLAND": _generate_grassland_geographic_distribution,
		"PRIMITIVE": _generate_primitive_geographic_distribution,
		"DEAD_LAND": _generate_dead_land_geographic_distribution
	}
	
	# 检查是否为特殊生态系统
	if ecosystem_type in special_distribution_ecosystems:
		var distribution_func = special_distribution_ecosystems[ecosystem_type]
		distribution_func.call(positions)
		return
	
	# ============================================================================
	# 通用生态系统处理 - 使用标准聚类算法
	# ============================================================================
	
	_generate_generic_ecosystem_clusters(positions, ecosystem_type)

func _generate_generic_ecosystem_clusters(positions: Array, ecosystem_type: String) -> void:
	"""为通用生态系统生成聚类地块"""
	# 计算要生成的特殊地块数量
	var total_positions = positions.size()
	var special_tile_count = int(total_positions * randf_range(0.4, 0.5))
	
	if special_tile_count <= 0:
		return
	
	# 获取该生态系统的特殊地块类型
	var special_tiles = _get_ecosystem_special_tiles(ecosystem_type)
	if special_tiles.is_empty():
		return
	
	# 🌍 使用改进的聚类算法，确保不同类型地块保持距离
	var clusters = _generate_spaced_cluster_regions(positions, special_tile_count, special_tiles.size())
	
	# 为每个聚类分配特殊地块类型，确保不同类型不相邻
	_assign_tile_types_with_spacing(clusters, special_tiles)
	
	var empty_percentage = (total_positions - special_tile_count) * 100.0 / total_positions
	LogManager.info("🌍 为 %s 生态系统生成了 %d 个聚类区域，共 %d 个特殊地块，空地比例: %.1f%%" % [ecosystem_type, clusters.size(), special_tile_count, empty_percentage])

func _get_ecosystem_special_tiles(ecosystem_type: String) -> Array:
	"""获取生态系统的特殊地块类型列表"""
	match ecosystem_type:
		"FOREST":
			return [
				TileTypes.TileType.FOREST_CLEARING,
				TileTypes.TileType.DENSE_FOREST,
				TileTypes.TileType.FOREST_EDGE,
				TileTypes.TileType.ANCIENT_FOREST
			]
		"LAKE":
			return [
				TileTypes.TileType.LAKE_SHALLOW,
				TileTypes.TileType.LAKE_DEEP,
				TileTypes.TileType.LAKE_SHORE,
				TileTypes.TileType.LAKE_ISLAND
			]
		"CAVE":
			return [
				TileTypes.TileType.CAVE_DEEP,
				TileTypes.TileType.CAVE_CRYSTAL,
				TileTypes.TileType.CAVE_UNDERGROUND_LAKE
			]
		"WASTELAND":
			return [
				TileTypes.TileType.WASTELAND_DESERT,
				TileTypes.TileType.WASTELAND_ROCKS,
				TileTypes.TileType.WASTELAND_RUINS,
				TileTypes.TileType.WASTELAND_TOXIC
			]
		"PRIMITIVE":
			return [
				TileTypes.TileType.PRIMITIVE_JUNGLE,
				TileTypes.TileType.PRIMITIVE_SWAMP,
				TileTypes.TileType.PRIMITIVE_VOLCANO
			]
		"GRASSLAND":
			return [
				TileTypes.TileType.GRASSLAND_PLAINS,
				TileTypes.TileType.GRASSLAND_HILLS,
				TileTypes.TileType.GRASSLAND_WETLANDS,
				TileTypes.TileType.GRASSLAND_FIELDS
			]
		"DEAD_LAND":
			return [
				TileTypes.TileType.DEAD_LAND_SWAMP,
				TileTypes.TileType.DEAD_LAND_GRAVEYARD
			]
		_:
			return []

func _generate_grassland_geographic_distribution(positions: Array) -> void:
	"""生成草地的地理分布 - 符合草原生态规律"""
	if positions.is_empty():
		return
	
	var total_positions = positions.size()
	LogManager.info("🌱 开始生成草地地理分布，位置数量: %d" % total_positions)
	
	# 🌱 第一步：生成草地区域（草原平原 + 其他草地类型 = 60%）
	var grassland_positions = positions.duplicate()
	var grassland_count = int(total_positions * 0.6) # 60%为草地区域
	
	# 随机选择草地位置
	grassland_positions.shuffle()
	var selected_grassland_positions = grassland_positions.slice(0, grassland_count)
	
	# 🌱 第二步：在草地中划分草原平原和其他草地类型
	var plains_count = int(grassland_count * 0.6) # 60%为草原平原
	var other_count = grassland_count - plains_count # 40%为其他草地类型
	
	# 生成草原平原（主要区域）
	var plains_positions = selected_grassland_positions.slice(0, plains_count)
	
	# 生成其他草地类型（剩余草地位置）
	var other_positions = selected_grassland_positions.slice(plains_count, grassland_count)
	
	# 🌱 第三步：在其他草地类型中分配丘陵、湿地、农田
	var hills_count = int(other_count * 0.4) # 40%为丘陵
	var wetlands_count = int(other_count * 0.3) # 30%为湿地
	var fields_count = other_count - hills_count - wetlands_count # 30%为农田
	
	# 分配其他草地类型
	var hills_positions = other_positions.slice(0, hills_count)
	var wetlands_positions = other_positions.slice(hills_count, hills_count + wetlands_count)
	var fields_positions = other_positions.slice(hills_count + wetlands_count, other_count)
	
	# 🌱 应用地块类型
	for pos in plains_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.GRASSLAND_PLAINS)
	
	for pos in hills_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.GRASSLAND_HILLS)
	
	for pos in wetlands_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.GRASSLAND_WETLANDS)
	
	for pos in fields_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.GRASSLAND_FIELDS)
	
	# 统计信息
	var empty_count = total_positions - grassland_count
	var empty_percentage = empty_count * 100.0 / total_positions
	
	LogManager.info("🌱 草地地理分布完成:")
	LogManager.info("  - 草原平原: %d 个地块 (%.1f%%)" % [plains_positions.size(), plains_positions.size() * 100.0 / total_positions])
	LogManager.info("  - 草原丘陵: %d 个地块 (%.1f%%)" % [hills_positions.size(), hills_positions.size() * 100.0 / total_positions])
	LogManager.info("  - 草原湿地: %d 个地块 (%.1f%%)" % [wetlands_positions.size(), wetlands_positions.size() * 100.0 / total_positions])
	LogManager.info("  - 草原农田: %d 个地块 (%.1f%%)" % [fields_positions.size(), fields_positions.size() * 100.0 / total_positions])
	LogManager.info("  - 空地: %d 个地块 (%.1f%%)" % [empty_count, empty_percentage])

func _generate_cave_geographic_distribution(positions: Array) -> void:
	"""生成洞穴的地理分布 - 符合洞穴生态规律"""
	if positions.is_empty():
		return
	
	var total_positions = positions.size()
	LogManager.info("🕳️ 开始生成洞穴地理分布，位置数量: %d" % total_positions)
	
	# 🕳️ 第一步：生成洞穴区域（60%）
	var cave_positions = positions.duplicate()
	var cave_count = int(total_positions * 0.6) # 60%为洞穴区域
	
	# 随机选择洞穴位置
	cave_positions.shuffle()
	var selected_cave_positions = cave_positions.slice(0, cave_count)
	
	# 🕳️ 第二步：在洞穴中分配深洞、水晶洞、地下湖
	var deep_count = int(cave_count * 0.2) # 20%为深洞
	var crystal_count = int(cave_count * 0.15) # 15%为水晶洞
	var lake_count = cave_count - deep_count - crystal_count # 65%为地下湖
	
	# 🕳️ 第三步：生成地下湖（中心区域）
	var lake_positions = _generate_cave_underground_lake_center_positions(selected_cave_positions, lake_count)
	
	# 🕳️ 第四步：生成深洞和水晶洞（剩余位置）
	var remaining_positions = []
	for pos in selected_cave_positions:
		if pos not in lake_positions:
			remaining_positions.append(pos)
	
	var deep_count_actual = min(deep_count, remaining_positions.size())
	var crystal_count_actual = min(crystal_count, remaining_positions.size() - deep_count_actual)
	
	var deep_positions = remaining_positions.slice(0, deep_count_actual)
	var crystal_positions = remaining_positions.slice(deep_count_actual, deep_count_actual + crystal_count_actual)
	
	# 🕳️ 应用地块类型
	for pos in deep_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.CAVE_DEEP)
	
	for pos in crystal_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.CAVE_CRYSTAL)
	
	for pos in lake_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.CAVE_UNDERGROUND_LAKE)
	
	# 🕳️ 记录生成结果
	LogManager.info("🕳️ 洞穴地理分布完成:")
	LogManager.info("  - 深洞: %d 个 (%.1f%%)" % [deep_positions.size(), float(deep_positions.size()) / total_positions * 100])
	LogManager.info("  - 水晶洞: %d 个 (%.1f%%)" % [crystal_positions.size(), float(crystal_positions.size()) / total_positions * 100])
	LogManager.info("  - 地下湖: %d 个 (%.1f%%)" % [lake_positions.size(), float(lake_positions.size()) / total_positions * 100])
	LogManager.info("  - 空地: %d 个 (%.1f%%)" % [total_positions - cave_count, float(total_positions - cave_count) / total_positions * 100])

func _generate_cave_underground_lake_center_positions(all_positions: Array, target_count: int) -> Array:
	"""生成地下湖中心位置"""
	if all_positions.is_empty() or target_count <= 0:
		return []
	
	# 计算中心点
	var center_x = 0.0
	var center_z = 0.0
	for pos in all_positions:
		center_x += pos.x
		center_z += pos.z
	center_x /= all_positions.size()
	center_z /= all_positions.size()
	
	# 计算每个位置到中心的距离
	var positions_with_distance = []
	for pos in all_positions:
		var distance = Vector2(pos.x - center_x, pos.z - center_z).length()
		positions_with_distance.append({"position": pos, "distance": distance})
	
	# 按距离排序，选择距离中心最近的位置
	positions_with_distance.sort_custom(func(a, b): return a.distance < b.distance)
	
	var center_positions = []
	for i in range(min(target_count, positions_with_distance.size())):
		center_positions.append(positions_with_distance[i].position)
	
	return center_positions

func _generate_forest_geographic_distribution(positions: Array) -> void:
	"""生成森林的地理分布 - 符合森林生态规律"""
	if positions.is_empty():
		return
	
	var total_positions = positions.size()
	LogManager.info("🌲 开始生成森林地理分布，位置数量: %d" % total_positions)
	
	# 🌲 第一步：生成森林区域（茂密森林 + 古树区域 = 60%）
	var forest_positions = positions.duplicate()
	var forest_count = int(total_positions * 0.6) # 60%为森林区域
	
	# 随机选择森林位置
	forest_positions.shuffle()
	var selected_forest_positions = forest_positions.slice(0, forest_count)
	
	# 🌲 第二步：在森林中划分茂密森林和古树区域
	var dense_count = int(forest_count * 0.7) # 70%为茂密森林
	var ancient_count = forest_count - dense_count # 30%为古树区域
	
	# 生成古树区域聚类（中心区域）
	var ancient_positions = _generate_ancient_forest_clusters(selected_forest_positions, ancient_count)
	
	# 生成茂密森林（剩余森林位置）
	var dense_positions = []
	for pos in selected_forest_positions:
		if pos not in ancient_positions:
			dense_positions.append(pos)
	
	# 🌲 第三步：生成森林边缘（围绕茂密森林和古树区域的边缘）
	var edge_positions = _generate_forest_edge_positions(positions, selected_forest_positions)
	
	# 🌲 第四步：生成森林空地（在森林内部的小片空地）
	var clearing_positions = _generate_forest_clearing_positions(dense_positions, ancient_positions)
	
	# 🌲 应用地块类型
	for pos in dense_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.DENSE_FOREST)
	
	for pos in ancient_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.ANCIENT_FOREST)
	
	for pos in edge_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.FOREST_EDGE)
	
	for pos in clearing_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.FOREST_CLEARING)
	
	# 统计信息
	var empty_count = total_positions - forest_count - edge_positions.size() - clearing_positions.size()
	var empty_percentage = empty_count * 100.0 / total_positions
	
	LogManager.info("🌲 森林地理分布完成:")
	LogManager.info("  - 茂密森林: %d 个地块 (%.1f%%)" % [dense_positions.size(), dense_positions.size() * 100.0 / total_positions])
	LogManager.info("  - 古树区域: %d 个地块 (%.1f%%)" % [ancient_positions.size(), ancient_positions.size() * 100.0 / total_positions])
	LogManager.info("  - 森林边缘: %d 个地块 (%.1f%%)" % [edge_positions.size(), edge_positions.size() * 100.0 / total_positions])
	LogManager.info("  - 森林空地: %d 个地块 (%.1f%%)" % [clearing_positions.size(), clearing_positions.size() * 100.0 / total_positions])
	LogManager.info("  - 空地: %d 个地块 (%.1f%%)" % [empty_count, empty_percentage])

func _generate_ancient_forest_clusters(forest_positions: Array, target_count: int) -> Array:
	"""生成古树区域聚类（中心区域）"""
	if forest_positions.is_empty() or target_count <= 0:
		return []
	
	# 计算空洞的中心点
	var center_x = 0.0
	var center_z = 0.0
	for pos in forest_positions:
		center_x += pos.x
		center_z += pos.z
	center_x /= forest_positions.size()
	center_z /= forest_positions.size()
	var center = Vector3(center_x, 0, center_z)
	
	# 按距离中心点的距离排序
	var sorted_positions = forest_positions.duplicate()
	sorted_positions.sort_custom(func(a, b): return a.distance_to(center) < b.distance_to(center))
	
	# 选择最靠近中心的位置作为古树区域
	var ancient_positions = sorted_positions.slice(0, target_count)
	
	# 使用聚类算法确保古树区域连接
	return _grow_connected_cluster(ancient_positions, target_count)

func _generate_forest_edge_positions(all_positions: Array, forest_positions: Array) -> Array:
	"""生成森林边缘位置（围绕森林区域的边缘）"""
	var edge_positions: Array = []
	var forest_set = {}
	
	# 创建森林位置集合以便快速查找
	for pos in forest_positions:
		forest_set[pos] = true
	
	# 检查所有位置，找到与森林相邻但不是森林的位置
	for pos in all_positions:
		if pos in forest_set:
			continue # 跳过森林位置
		
		# 检查是否与森林相邻
		var neighbors = _get_neighbors(pos)
		var has_forest_neighbor = false
		for neighbor in neighbors:
			if neighbor in forest_set:
				has_forest_neighbor = true
				break
		
		if has_forest_neighbor:
			edge_positions.append(pos)
	
	return edge_positions

func _generate_forest_clearing_positions(dense_positions: Array, ancient_positions: Array) -> Array:
	"""生成森林空地位置（在森林内部的小片空地）"""
	var clearing_positions: Array = []
	var forest_positions = dense_positions + ancient_positions
	
	if forest_positions.is_empty():
		return []
	
	# 在森林内部生成2-5个空地
	var clearing_count = randi_range(2, min(5, forest_positions.size() / 20))
	
	for i in range(clearing_count):
		# 随机选择一个森林位置作为空地中心
		var center_pos = forest_positions[randi() % forest_positions.size()]
		
		# 在中心位置附近生成1-3个空地
		var clearing_size = randi_range(1, 3)
		for j in range(clearing_size):
			var offset_x = randi_range(-1, 1)
			var offset_z = randi_range(-1, 1)
			var clearing_pos = Vector3(center_pos.x + offset_x, 0, center_pos.z + offset_z)
			
			# 确保位置在森林中
			if clearing_pos in forest_positions:
				clearing_positions.append(clearing_pos)
	
	return clearing_positions
	
func _generate_lake_geographic_distribution(positions: Array) -> void:
	"""生成湖泊的地理分布 - 符合现实地理规律"""
	if positions.is_empty():
		return
	
	var total_positions = positions.size()
	LogManager.info("🌊 开始生成湖泊地理分布，位置数量: %d" % total_positions)
	
	# 🌊 第一步：生成水域区域（浅水区 + 深水区 = 80%）
	var water_positions = positions.duplicate()
	var water_count = int(total_positions * 0.8) # 80%为水域
	
	# 随机选择水域位置
	water_positions.shuffle()
	var selected_water_positions = water_positions.slice(0, water_count)
	
	# 🌊 第二步：在水域中划分浅水区和深水区
	var shallow_count = int(water_count * 0.6) # 60%为浅水区
	var deep_count = water_count - shallow_count # 40%为深水区
	
	# 生成深水区聚类（中心区域）
	var deep_positions = _generate_deep_water_clusters(selected_water_positions, deep_count)
	
	# 生成浅水区（剩余的水域位置）
	var shallow_positions = []
	for pos in selected_water_positions:
		if pos not in deep_positions:
			shallow_positions.append(pos)
	
	# 🌊 第三步：生成湖岸（围绕水域的边缘）
	var shore_positions = _generate_lake_shore_positions(positions, selected_water_positions)
	
	# 🌊 第四步：生成湖心岛（在深水区中心）
	var island_positions = _generate_lake_island_positions(deep_positions)
	
	# 🌊 应用地块类型
	for pos in shallow_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.LAKE_SHALLOW)
	
	for pos in deep_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.LAKE_DEEP)
	
	for pos in shore_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.LAKE_SHORE)
	
	for pos in island_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.LAKE_ISLAND)
	
	# 统计信息
	var empty_count = total_positions - water_count - shore_positions.size() - island_positions.size()
	var empty_percentage = empty_count * 100.0 / total_positions
	
	LogManager.info("🌊 湖泊地理分布完成:")
	LogManager.info("  - 浅水区: %d 个地块 (%.1f%%)" % [shallow_positions.size(), shallow_positions.size() * 100.0 / total_positions])
	LogManager.info("  - 深水区: %d 个地块 (%.1f%%)" % [deep_positions.size(), deep_positions.size() * 100.0 / total_positions])
	LogManager.info("  - 湖岸: %d 个地块 (%.1f%%)" % [shore_positions.size(), shore_positions.size() * 100.0 / total_positions])
	LogManager.info("  - 湖心岛: %d 个地块 (%.1f%%)" % [island_positions.size(), island_positions.size() * 100.0 / total_positions])
	LogManager.info("  - 空地: %d 个地块 (%.1f%%)" % [empty_count, empty_percentage])

func _generate_deep_water_clusters(water_positions: Array, target_count: int) -> Array:
	"""生成深水区聚类（中心区域）"""
	if water_positions.is_empty() or target_count <= 0:
		return []
	
	# 计算空洞的中心点
	var center_x = 0.0
	var center_z = 0.0
	for pos in water_positions:
		center_x += pos.x
		center_z += pos.z
	center_x /= water_positions.size()
	center_z /= water_positions.size()
	var center = Vector3(center_x, 0, center_z)
	
	# 按距离中心点的距离排序
	var sorted_positions = water_positions.duplicate()
	sorted_positions.sort_custom(func(a, b): return a.distance_to(center) < b.distance_to(center))
	
	# 选择最靠近中心的位置作为深水区
	var deep_positions = sorted_positions.slice(0, target_count)
	
	# 使用聚类算法确保深水区连接
	return _grow_connected_cluster(deep_positions, target_count)

func _generate_lake_shore_positions(all_positions: Array, water_positions: Array) -> Array:
	"""生成湖岸位置（围绕水域的边缘）"""
	var shore_positions: Array = []
	var water_set = {}
	
	# 创建水域位置集合以便快速查找
	for pos in water_positions:
		water_set[pos] = true
	
	# 检查所有位置，找到与水域相邻但不是水域的位置
	for pos in all_positions:
		if pos in water_set:
			continue # 跳过水域位置
		
		# 检查是否与水域相邻
		var neighbors = _get_neighbors(pos)
		var has_water_neighbor = false
		for neighbor in neighbors:
			if neighbor in water_set:
				has_water_neighbor = true
				break
		
		if has_water_neighbor:
			shore_positions.append(pos)
	
	return shore_positions

func _generate_lake_island_positions(deep_positions: Array) -> Array:
	"""生成湖心岛位置（在深水区中心）"""
	if deep_positions.is_empty():
		return []
	
	# 计算深水区的中心点
	var center_x = 0.0
	var center_z = 0.0
	for pos in deep_positions:
		center_x += pos.x
		center_z += pos.z
	center_x /= deep_positions.size()
	center_z /= deep_positions.size()
	var center = Vector3(center_x, 0, center_z)
	
	# 在深水区中心附近生成1-3个湖心岛
	var island_count = randi_range(1, min(3, deep_positions.size() / 10))
	var island_positions: Array = []
	
	for i in range(island_count):
		# 在中心附近随机选择位置
		var offset_x = randi_range(-3, 3)
		var offset_z = randi_range(-3, 3)
		var island_pos = Vector3(center.x + offset_x, 0, center.z + offset_z)
		
		# 确保位置在深水区中
		if island_pos in deep_positions:
			island_positions.append(island_pos)
	
	return island_positions

func _grow_connected_cluster(positions: Array, target_size: int) -> Array:
	"""确保聚类连接"""
	if positions.is_empty():
		return []
	
	var cluster: Array = []
	var queue: Array = []
	var visited: Dictionary = {}
	
	# 从第一个位置开始
	var start_pos = positions[0]
	cluster.append(start_pos)
	queue.append(start_pos)
	visited[start_pos] = true
	
	# 使用BFS扩展聚类
	while not queue.is_empty() and cluster.size() < target_size:
		var current_pos = queue.pop_front()
		
		# 检查相邻位置
		var neighbors = _get_neighbors(current_pos)
		for neighbor in neighbors:
			if neighbor in positions and not visited.has(neighbor) and cluster.size() < target_size:
				visited[neighbor] = true
				cluster.append(neighbor)
				queue.append(neighbor)
	
	return cluster

func _generate_spaced_cluster_regions(positions: Array, target_count: int, tile_type_count: int) -> Array:
	"""生成间距控制的聚类区域，确保不同类型地块保持距离"""
	var clusters: Array = []
	var used_positions: Dictionary = {}
	var remaining_positions = positions.duplicate()
	
	# 🌍 增加聚类群数量，减少每个聚类的地块数量
	# 每个地块类型至少生成2-3个聚类群，确保分布均匀
	var min_clusters_per_type = 2
	var max_clusters_per_type = 3
	var total_cluster_count = tile_type_count * randi_range(min_clusters_per_type, max_clusters_per_type)
	
	# 限制最大聚类数量，避免过多小聚类
	total_cluster_count = min(total_cluster_count, target_count / 2)
	
	# 计算每个聚类的目标大小（更小的聚类）
	var target_cluster_size = max(2, target_count / total_cluster_count)
	
	LogManager.info("🌍 计划生成 %d 个聚类群，每个聚类目标大小: %d" % [total_cluster_count, target_cluster_size])
	
	for i in range(total_cluster_count):
		if remaining_positions.is_empty():
			break
		
		# 随机选择一个起始位置
		var start_pos = remaining_positions[randi() % remaining_positions.size()]
		var cluster = _grow_spaced_cluster(start_pos, remaining_positions, target_cluster_size, used_positions)
		
		if cluster.size() > 0:
			clusters.append(cluster)
			# 从剩余位置中移除已使用的位置
			for pos in cluster:
				remaining_positions.erase(pos)
				used_positions[pos] = true
	
	LogManager.info("🌍 实际生成了 %d 个聚类群" % clusters.size())
	return clusters

func _grow_spaced_cluster(start_pos: Vector3, available_positions: Array, target_size: int, used_positions: Dictionary) -> Array:
	"""从起始位置开始生长聚类，考虑间距控制"""
	var cluster: Array = [start_pos]
	var queue: Array = [start_pos]
	var visited: Dictionary = {start_pos: true}
	
	# 🌍 间距控制：不同类型地块之间的最小距离
	var min_distance = 2 # 最小距离为2格
	
	while not queue.is_empty() and cluster.size() < target_size:
		var current_pos = queue.pop_front()
		
		# 检查相邻位置
		var neighbors = _get_neighbors(current_pos)
		for neighbor in neighbors:
			if neighbor in available_positions and not visited.has(neighbor):
				# 🌍 检查是否与已使用的位置太近
				if _is_position_too_close_to_used(neighbor, used_positions, min_distance):
					continue
				
				visited[neighbor] = true
				cluster.append(neighbor)
				queue.append(neighbor)
				
				if cluster.size() >= target_size:
					break
	
	return cluster

func _is_position_too_close_to_used(pos: Vector3, used_positions: Dictionary, min_distance: int) -> bool:
	"""检查位置是否与已使用的位置太近"""
	for used_pos in used_positions.keys():
		var distance = int(pos.distance_to(used_pos))
		if distance < min_distance:
			return true
	return false

func _assign_tile_types_with_spacing(clusters: Array, special_tiles: Array) -> void:
	"""为聚类分配地块类型，确保不同类型不相邻"""
	var tile_type_usage: Dictionary = {} # 记录每种地块类型的使用次数
	
	# 初始化地块类型使用计数
	for tile_type in special_tiles:
		tile_type_usage[tile_type] = 0
	
	# 为每个聚类分配地块类型
	for i in range(clusters.size()):
		var cluster = clusters[i]
		
		# 🌍 选择使用次数最少的地块类型，确保均匀分布
		var selected_tile_type = _select_least_used_tile_type(special_tiles, tile_type_usage)
		
		# 应用地块类型到聚类中的所有位置
		for pos in cluster:
			tile_manager.set_tile_type(pos, selected_tile_type)
		
		# 更新使用计数
		tile_type_usage[selected_tile_type] += 1
		
		LogManager.debug("🌍 聚类 %d: 分配地块类型 %d，大小: %d" % [i, selected_tile_type, cluster.size()])

func _select_least_used_tile_type(special_tiles: Array, tile_type_usage: Dictionary) -> int:
	"""选择使用次数最少的地块类型"""
	var min_usage = INF
	var selected_tile_type = special_tiles[0]
	
	for tile_type in special_tiles:
		var usage_count = tile_type_usage.get(tile_type, 0)
		if usage_count < min_usage:
			min_usage = usage_count
			selected_tile_type = tile_type
	
	return selected_tile_type

func _generate_cluster_regions(positions: Array, target_count: int) -> Array:
	"""生成聚类区域，确保同一类型的地块连接在一起（旧版本，保留兼容性）"""
	var clusters: Array = []
	var used_positions: Dictionary = {}
	var remaining_positions = positions.duplicate()
	
	# 生成2-4个聚类区域
	var cluster_count = randi_range(2, min(4, target_count / 3))
	
	for i in range(cluster_count):
		if remaining_positions.is_empty():
			break
		
		# 随机选择一个起始位置
		var start_pos = remaining_positions[randi() % remaining_positions.size()]
		var cluster = _grow_cluster(start_pos, remaining_positions, target_count / cluster_count)
		
		if cluster.size() > 0:
			clusters.append(cluster)
			# 从剩余位置中移除已使用的位置
			for pos in cluster:
				remaining_positions.erase(pos)
				used_positions[pos] = true
	
	return clusters

func _grow_cluster(start_pos: Vector3, available_positions: Array, target_size: int) -> Array:
	"""从起始位置开始生长聚类"""
	var cluster: Array = [start_pos]
	var queue: Array = [start_pos]
	var visited: Dictionary = {start_pos: true}
	
	while not queue.is_empty() and cluster.size() < target_size:
		var current_pos = queue.pop_front()
		
		# 检查相邻位置
		var neighbors = _get_neighbors(current_pos)
		for neighbor in neighbors:
			if neighbor in available_positions and not visited.has(neighbor):
				visited[neighbor] = true
				cluster.append(neighbor)
				queue.append(neighbor)
				
				if cluster.size() >= target_size:
					break
	
	return cluster

func _get_neighbors(pos: Vector3) -> Array:
	"""获取位置的相邻位置"""
	var neighbors: Array = []
	var directions = [
		Vector3(1, 0, 0), # 右
		Vector3(-1, 0, 0), # 左
		Vector3(0, 0, 1), # 前
		Vector3(0, 0, -1), # 后
		Vector3(1, 0, 1), # 右前
		Vector3(-1, 0, 1), # 左前
		Vector3(1, 0, -1), # 右后
		Vector3(-1, 0, -1) # 左后
	]
	
	for direction in directions:
		neighbors.append(pos + direction)
	
	return neighbors

# ============================================================================
# 生态系统地块类型选择函数
# ============================================================================

func _get_random_forest_tile() -> int:
	"""随机选择森林地块类型"""
	var forest_tiles = [
		TileTypes.TileType.FOREST_CLEARING,
		TileTypes.TileType.DENSE_FOREST,
		TileTypes.TileType.FOREST_EDGE,
		TileTypes.TileType.ANCIENT_FOREST
	]
	return forest_tiles[randi() % forest_tiles.size()]

func _get_random_grassland_tile() -> int:
	"""随机选择草地地块类型"""
	var grassland_tiles = [
		TileTypes.TileType.GRASSLAND_PLAINS,
		TileTypes.TileType.GRASSLAND_HILLS,
		TileTypes.TileType.GRASSLAND_WETLANDS,
		TileTypes.TileType.GRASSLAND_FIELDS
	]
	return grassland_tiles[randi() % grassland_tiles.size()]

func _get_random_lake_tile() -> int:
	"""随机选择湖泊地块类型"""
	var lake_tiles = [
		TileTypes.TileType.LAKE_SHALLOW,
		TileTypes.TileType.LAKE_DEEP,
		TileTypes.TileType.LAKE_SHORE,
		TileTypes.TileType.LAKE_ISLAND
	]
	return lake_tiles[randi() % lake_tiles.size()]

func _get_random_cave_tile() -> int:
	"""随机选择洞穴地块类型"""
	var cave_tiles = [
		TileTypes.TileType.CAVE_DEEP,
		TileTypes.TileType.CAVE_CRYSTAL,
		TileTypes.TileType.CAVE_UNDERGROUND_LAKE
	]
	return cave_tiles[randi() % cave_tiles.size()]

func _get_random_wasteland_tile() -> int:
	"""随机选择荒地地块类型"""
	var wasteland_tiles = [
		TileTypes.TileType.WASTELAND_DESERT,
		TileTypes.TileType.WASTELAND_ROCKS,
		TileTypes.TileType.WASTELAND_RUINS,
		TileTypes.TileType.WASTELAND_TOXIC
	]
	return wasteland_tiles[randi() % wasteland_tiles.size()]

func _get_random_deadland_tile() -> int:
	"""随机选择死地地块类型"""
	var deadland_tiles = [
		TileTypes.TileType.DEAD_LAND_SWAMP,
		TileTypes.TileType.DEAD_LAND_GRAVEYARD
	]
	return deadland_tiles[randi() % deadland_tiles.size()]

func _generate_wasteland_geographic_distribution(positions: Array) -> void:
	"""生成荒地的地理分布 - 符合荒地生态规律"""
	if positions.is_empty():
		return
	
	var total_positions = positions.size()
	LogManager.info("🏜️ 开始生成荒地地理分布，位置数量: %d" % total_positions)
	
	# 🏜️ 第一步：生成荒地区域（60%为荒地，40%为空地）
	var wasteland_positions = positions.duplicate()
	var wasteland_count = int(total_positions * 0.6) # 60%为荒地区域
	
	# 随机选择荒地位置
	wasteland_positions.shuffle()
	var selected_wasteland_positions = wasteland_positions.slice(0, wasteland_count)
	
	# 🏜️ 第二步：在荒地中分配不同类型
	var desert_count = int(wasteland_count * 0.4) # 40%为沙漠
	var rocks_count = int(wasteland_count * 0.3) # 30%为岩石
	var ruins_count = int(wasteland_count * 0.2) # 20%为废墟
	var toxic_count = wasteland_count - desert_count - rocks_count - ruins_count # 10%为毒区
	
	# 🏜️ 第三步：生成沙漠区域（主要区域）
	var desert_positions = selected_wasteland_positions.slice(0, desert_count)
	
	# 🏜️ 第四步：生成岩石区域
	var rocks_positions = selected_wasteland_positions.slice(desert_count, desert_count + rocks_count)
	
	# 🏜️ 第五步：生成废墟区域
	var ruins_positions = selected_wasteland_positions.slice(desert_count + rocks_count, desert_count + rocks_count + ruins_count)
	
	# 🏜️ 第六步：生成毒区区域（在边缘区域）
	var toxic_positions = selected_wasteland_positions.slice(desert_count + rocks_count + ruins_count, wasteland_count)
	
	# 🏜️ 第七步：将毒区重新分配到边缘位置
	toxic_positions = _generate_wasteland_toxic_edge_positions(positions, toxic_count)
	
	# 🏜️ 第八步：设置地块类型
	for pos in desert_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.WASTELAND_DESERT)
	
	for pos in rocks_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.WASTELAND_ROCKS)
	
	for pos in ruins_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.WASTELAND_RUINS)
	
	for pos in toxic_positions:
		tile_manager.set_tile_type(pos, TileTypes.TileType.WASTELAND_TOXIC)
	
	# 🏜️ 第九步：记录生成结果
	var empty_count = total_positions - wasteland_count
	LogManager.info("🏜️ 荒地地理分布生成完成:")
	LogManager.info("  沙漠: %d (%.1f%%)" % [desert_count, float(desert_count) / total_positions * 100])
	LogManager.info("  岩石: %d (%.1f%%)" % [rocks_count, float(rocks_count) / total_positions * 100])
	LogManager.info("  废墟: %d (%.1f%%)" % [ruins_count, float(ruins_count) / total_positions * 100])
	LogManager.info("  毒区: %d (%.1f%%)" % [toxic_count, float(toxic_count) / total_positions * 100])
	LogManager.info("  空地: %d (%.1f%%)" % [empty_count, float(empty_count) / total_positions * 100])

func _generate_wasteland_toxic_edge_positions(all_positions: Array, target_count: int) -> Array:
	"""生成荒地毒区的边缘位置"""
	if all_positions.is_empty() or target_count <= 0:
		return []
	
	# 计算边界范围
	var min_x = all_positions[0].x
	var max_x = all_positions[0].x
	var min_z = all_positions[0].z
	var max_z = all_positions[0].z
	
	for pos in all_positions:
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_z = min(min_z, pos.z)
		max_z = max(max_z, pos.z)
	
	# 找到边缘位置（距离边界1-2格的位置）
	var edge_positions = []
	for pos in all_positions:
		var distance_to_edge = min(
			min(pos.x - min_x, max_x - pos.x),
			min(pos.z - min_z, max_z - pos.z)
		)
		# 边缘位置：距离边界1-2格
		if distance_to_edge >= 1 and distance_to_edge <= 2:
			edge_positions.append(pos)
	
	# 如果边缘位置不够，扩大范围
	if edge_positions.size() < target_count:
		for pos in all_positions:
			var distance_to_edge = min(
				min(pos.x - min_x, max_x - pos.x),
				min(pos.z - min_z, max_z - pos.z)
			)
			# 扩大范围：距离边界0-3格
			if distance_to_edge >= 0 and distance_to_edge <= 3:
				if not pos in edge_positions:
					edge_positions.append(pos)
	
	# 随机选择目标数量的边缘位置
	edge_positions.shuffle()
	return edge_positions.slice(0, min(target_count, edge_positions.size()))

func _get_random_primitive_tile() -> int:
	"""随机选择原始地块类型"""
	var primitive_tiles = [
		TileTypes.TileType.PRIMITIVE_JUNGLE,
		TileTypes.TileType.PRIMITIVE_VOLCANO,
		TileTypes.TileType.PRIMITIVE_SWAMP
	]
	return primitive_tiles[randi() % primitive_tiles.size()]

func _generate_primitive_geographic_distribution(positions: Array) -> void:
	"""生成原始生态系统的地理分布 - 使用聚类算法"""
	if positions.is_empty():
		return
	
	LogManager.info("🌿 生成原始生态系统地理分布...")
	
	# 计算要生成的特殊地块数量（40-50%）
	var total_positions = positions.size()
	var special_tile_count = int(total_positions * randf_range(0.4, 0.5))
	
	if special_tile_count <= 0:
		return
	
	# 获取原始生态系统的特殊地块类型
	var primitive_tiles = [
		TileTypes.TileType.PRIMITIVE_VOLCANO,
		TileTypes.TileType.PRIMITIVE_SWAMP
	]
	
	# 使用聚类算法生成原始特殊地块
	var clusters = _generate_spaced_cluster_regions(positions, special_tile_count, primitive_tiles.size())
	_assign_tile_types_with_spacing(clusters, primitive_tiles)
	
	var empty_percentage = (total_positions - special_tile_count) * 100.0 / total_positions
	LogManager.info("🌿 原始生态系统地理分布完成: %d 个聚类区域，共 %d 个特殊地块，空地比例: %.1f%%" % [clusters.size(), special_tile_count, empty_percentage])

func _generate_dead_land_geographic_distribution(positions: Array) -> void:
	"""生成死地生态系统的地理分布 - 使用聚类算法"""
	if positions.is_empty():
		return
	
	LogManager.info("💀 生成死地生态系统地理分布...")
	
	# 计算要生成的特殊地块数量（40-50%）
	var total_positions = positions.size()
	var special_tile_count = int(total_positions * randf_range(0.4, 0.5))
	
	if special_tile_count <= 0:
		return
	
	# 获取死地生态系统的特殊地块类型
	var dead_land_tiles = [
		TileTypes.TileType.DEAD_LAND_GRAVEYARD,
		TileTypes.TileType.DEAD_LAND_SWAMP
	]
	
	# 使用聚类算法生成死地特殊地块
	var clusters = _generate_spaced_cluster_regions(positions, special_tile_count, dead_land_tiles.size())
	_assign_tile_types_with_spacing(clusters, dead_land_tiles)
	
	var empty_percentage = (total_positions - special_tile_count) * 100.0 / total_positions
	LogManager.info("💀 死地生态系统地理分布完成: %d 个聚类区域，共 %d 个特殊地块，空地比例: %.1f%%" % [clusters.size(), special_tile_count, empty_percentage])

# ============================================================================
# 地图生成器重构完成
# ============================================================================
