extends Node

## ⛏️ 空洞挖掘器
## 集成泊松圆盘和噪声形状，将空洞应用到地图

# ============================================================================
# 类型引用
# ============================================================================

const Cavity = preload("res://scripts/map_system/cavity_system/cavities/Cavity.gd")
const CavityGenerator = preload("res://scripts/map_system/cavity_system/algorithms/CavityGenerator.gd")
const HoleShapeGenerator = preload("res://scripts/map_system/cavity_system/algorithms/HoleShapeGenerator.gd")

# ============================================================================
# 属性
# ============================================================================

var cavity_generator: CavityGenerator
var post_processor: Node
var tile_manager: Node
var map_width: int = 200
var map_height: int = 200

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	"""初始化空洞挖掘器"""
	name = "CavityExcavator"
	_initialize_components()

func _initialize_components() -> void:
	"""初始化组件"""
	cavity_generator = CavityGenerator.new()
	# post_processor 暂时注释掉，等待实现
	# post_processor = CavityPostProcessor.new()
	
	add_child(cavity_generator)
	# add_child(post_processor)

# ============================================================================
# 核心挖掘方法
# ============================================================================

func excavate_all_cavities() -> Array[Cavity]:
	"""挖掘所有空洞"""
	LogManager.info("CavityExcavator - 开始挖掘空洞")
	
	# 确保cavity_generator已初始化
	if cavity_generator == null:
		LogManager.info("CavityExcavator - 初始化组件...")
		_initialize_components()
	
	LogManager.info("CavityExcavator - 开始生成空洞...")
	# 1. 生成空洞
	var cavities = cavity_generator.generate_cavities_with_constraints()
	LogManager.info("CavityExcavator - 空洞生成完成，获得 %d 个空洞" % cavities.size())
	
	if cavities.size() == 0:
		LogManager.warning("⚠️ CavityGenerator 没有生成任何空洞！")
		return cavities
	
	# 打印每个空洞的详细信息
	for i in range(cavities.size()):
		var cavity = cavities[i]
		LogManager.info("空洞 %d: ID=%s, 类型=%s, 内容=%s, 中心=%s, 位置数=%d" % [i + 1, cavity.id, cavity.type, cavity.content_type, cavity.center, cavity.positions.size()])
	
	# 2. 后处理空洞（暂时跳过）
	# cavities = post_processor.post_process_cavities(cavities)
	
	# 3. 应用空洞到地图
	LogManager.info("CavityExcavator - 开始应用空洞到地图...")
	_apply_cavities_to_map(cavities)
	LogManager.info("CavityExcavator - 空洞已应用到地图")
	
	LogManager.info("CavityExcavator - 空洞挖掘完成，共 %d 个空洞" % cavities.size())
	return cavities

func excavate_cavities_by_type(cavity_type: String) -> Array[Cavity]:
	"""根据类型挖掘空洞"""
	LogManager.info("CavityExcavator - 开始挖掘 %s 类型空洞" % cavity_type)
	
	var cavities: Array[Cavity] = []
	var configs = CavityConfig.get_cavities_by_type(cavity_type)
	
	for config in configs:
		var cavity = _create_cavity_from_config(config)
		if cavity:
			cavities.append(cavity)
	
	# 后处理（暂时跳过）
	# cavities = post_processor.post_process_cavities(cavities)
	
	# 应用到地图
	_apply_cavities_to_map(cavities)
	
	LogManager.info("CavityExcavator - %s 类型空洞挖掘完成，共 %d 个" % [cavity_type, cavities.size()])
	return cavities

func excavate_critical_cavities() -> Array[Cavity]:
	"""挖掘关键空洞（地牢之心、传送门等）"""
	return excavate_cavities_by_type("critical")

func excavate_ecosystem_cavities() -> Array[Cavity]:
	"""挖掘生态系统空洞"""
	return excavate_cavities_by_type("ecosystem")

func excavate_functional_cavities() -> Array[Cavity]:
	"""挖掘功能空洞"""
	return excavate_cavities_by_type("functional")

# ============================================================================
# 空洞创建
# ============================================================================

func _create_cavity_from_config(config: Dictionary) -> Cavity:
	"""从配置创建空洞"""
	var cavity = Cavity.new(config.id, config.type, config.content_type)
	cavity.priority = config.get("priority", 0)
	cavity.highlight_color = _get_color_from_config(config.get("highlight_color", [1.0, 1.0, 1.0, 1.0]))
	
	var center = Vector2i(config.center[0], config.center[1])
	
	match config.get("shape", "circle"):
		"circle":
			var radius = config.get("radius", 10)
			cavity.generate_circular_shape(center, radius)
		"rectangle":
			var size = Vector2i(config.size[0], config.size[1])
			cavity.generate_rectangular_shape(center, size)
		"noise":
			var radius = config.get("radius", 10)
			var shape_points = _generate_noise_shape(center, radius)
			cavity.generate_noise_shape(center, shape_points)
		"maze":
			var size = Vector2i(config.size[0], config.size[1])
			cavity.generate_rectangular_shape(center, size)
		_:
			LogManager.warning("CavityExcavator - 未知形状类型: %s" % config.shape)
			return null
	
	return cavity

func _generate_noise_shape(center: Vector2i, radius: int) -> PackedVector2Array:
	"""生成噪声形状"""
	var shape_generator = HoleShapeGenerator.new()
	shape_generator.hole_radius = radius
	return shape_generator.generate_hole_shape(Vector2(center), map_width, map_height)

# ============================================================================
# 地图应用
# ============================================================================

func _apply_cavities_to_map(cavities: Array[Cavity]) -> void:
	"""将空洞应用到地图"""
	if not tile_manager:
		LogManager.error("CavityExcavator - 瓦片管理器未设置")
		return
	
	var total_excavated = 0
	
	for cavity in cavities:
		var excavated_count = _apply_cavity_to_map(cavity)
		total_excavated += excavated_count
		cavity.is_excavated = true
		
		LogManager.info("CavityExcavator - 挖掘空洞 %s: %d 个瓦片" % [cavity.id, excavated_count])
	
	LogManager.info("CavityExcavator - 总共挖掘了 %d 个瓦片" % total_excavated)

func _apply_cavity_to_map(cavity: Cavity) -> int:
	"""将单个空洞应用到地图"""
	var excavated_count = 0
	
	for pos in cavity.positions:
		# 检查位置是否在地图范围内
		if _is_position_in_bounds(pos):
			# 设置瓦片类型为空地
			tile_manager.set_tile_type(pos, TileTypes.TileType.EMPTY)
			excavated_count += 1
	
	return excavated_count

func _is_position_in_bounds(pos: Vector3) -> bool:
	"""检查位置是否在地图边界内"""
	return pos.x >= 0 and pos.x < map_width and pos.z >= 0 and pos.z < map_height

# ============================================================================
# 特殊空洞挖掘
# ============================================================================

func excavate_dungeon_heart() -> Cavity:
	"""挖掘地牢之心"""
	var config = CavityConfig.get_cavity_by_id("dungeon_heart")
	if config.is_empty():
		LogManager.error("CavityExcavator - 未找到地牢之心配置")
		return null
	
	var cavity = _create_cavity_from_config(config)
	if cavity:
		_apply_cavity_to_map(cavity)
		cavity.is_excavated = true
		LogManager.info("CavityExcavator - 地牢之心挖掘完成")
	
	return cavity

func excavate_portals() -> Array[Cavity]:
	"""挖掘传送门"""
	var portal_cavities: Array[Cavity] = []
	var portal_configs: Array[Dictionary] = []
	
	# 获取所有传送门配置
	for config in CavityConfig.get_all_cavities():
		if config.get("content_type") == "PORTAL":
			portal_configs.append(config)
	
	for config in portal_configs:
		var cavity = _create_cavity_from_config(config)
		if cavity:
			_apply_cavity_to_map(cavity)
			cavity.is_excavated = true
			portal_cavities.append(cavity)
	
	LogManager.info("CavityExcavator - 传送门挖掘完成，共 %d 个" % portal_cavities.size())
	return portal_cavities

func excavate_room_system() -> Array[Cavity]:
	"""挖掘房间系统空洞"""
	var room_cavities: Array[Cavity] = []
	var room_configs = CavityConfig.get_cavities_by_type("functional")
	
	for config in room_configs:
		if config.get("content_type") == "ROOM_SYSTEM":
			var cavity = _create_cavity_from_config(config)
			if cavity:
				_apply_cavity_to_map(cavity)
				cavity.is_excavated = true
				room_cavities.append(cavity)
	
	LogManager.info("CavityExcavator - 房间系统空洞挖掘完成，共 %d 个" % room_cavities.size())
	return room_cavities

func excavate_maze_system() -> Array[Cavity]:
	"""挖掘迷宫系统空洞"""
	var maze_cavities: Array[Cavity] = []
	var maze_configs = CavityConfig.get_cavities_by_type("functional")
	
	for config in maze_configs:
		if config.get("content_type") == "MAZE_SYSTEM":
			var cavity = _create_cavity_from_config(config)
			if cavity:
				_apply_cavity_to_map(cavity)
				cavity.is_excavated = true
				maze_cavities.append(cavity)
	
	LogManager.info("CavityExcavator - 迷宫系统空洞挖掘完成，共 %d 个" % maze_cavities.size())
	return maze_cavities

# ============================================================================
# 连接通道挖掘
# ============================================================================

func excavate_connecting_corridors(cavities: Array[Cavity]) -> void:
	"""挖掘连接通道"""
	LogManager.info("CavityExcavator - 开始挖掘连接通道")
	
	var corridor_width = 3
	var connections = _calculate_connections(cavities)
	
	for connection in connections:
		_excavate_corridor(connection.from, connection.to, corridor_width)
	
	LogManager.info("CavityExcavator - 连接通道挖掘完成")

func _calculate_connections(cavities: Array[Cavity]) -> Array[Dictionary]:
	"""计算连接路径"""
	var connections: Array[Dictionary] = []
	
	# 找到地牢之心
	var dungeon_heart = null
	for cavity in cavities:
		if cavity.content_type == "DUNGEON_HEART":
			dungeon_heart = cavity
			break
	
	if not dungeon_heart:
		LogManager.warning("CavityExcavator - 未找到地牢之心，无法计算连接")
		return connections
	
	# 连接地牢之心到其他空洞
	for cavity in cavities:
		if cavity != dungeon_heart:
			var connection = {
				"from": dungeon_heart.center,
				"to": cavity.center
			}
			connections.append(connection)
	
	return connections

func _excavate_corridor(from: Vector2i, to: Vector2i, width: int) -> void:
	"""挖掘L形通道"""
	# 水平段
	var x_min = min(from.x, to.x)
	var x_max = max(from.x, to.x)
	for x in range(x_min, x_max + 1):
		for w in range(width):
			var pos = Vector3(x, 0, from.y + w - 1)
			if _is_position_in_bounds(pos):
				tile_manager.set_tile_type(pos, TileTypes.TileType.EMPTY)
	
	# 垂直段
	var y_min = min(from.y, to.y)
	var y_max = max(from.y, to.y)
	for y in range(y_min, y_max + 1):
		for w in range(width):
			var pos = Vector3(to.x + w - 1, 0, y)
			if _is_position_in_bounds(pos):
				tile_manager.set_tile_type(pos, TileTypes.TileType.EMPTY)

# ============================================================================
# 工具方法
# ============================================================================

func _get_color_from_config(color_array: Array) -> Color:
	"""从配置数组获取颜色"""
	if color_array.size() >= 4:
		return Color(color_array[0], color_array[1], color_array[2], color_array[3])
	elif color_array.size() >= 3:
		return Color(color_array[0], color_array[1], color_array[2], 1.0)
	else:
		return Color.WHITE

# ============================================================================
# 配置方法
# ============================================================================

func set_map_size(width: int, height: int) -> void:
	"""设置地图尺寸"""
	map_width = width
	map_height = height
	# 确保cavity_generator已初始化
	if cavity_generator == null:
		_initialize_components()
	cavity_generator.set_map_size(width, height)

func set_tile_manager(manager: Node) -> void:
	"""设置瓦片管理器"""
	tile_manager = manager

func set_generation_parameters(min_distance: float, avg_radius: float) -> void:
	"""设置生成参数"""
	# 确保cavity_generator已初始化
	if cavity_generator == null:
		_initialize_components()
	cavity_generator.set_generation_parameters(min_distance, avg_radius)

func get_excavation_info() -> Dictionary:
	"""获取挖掘信息"""
	# 确保cavity_generator已初始化
	if cavity_generator == null:
		_initialize_components()
	
	return {
		"map_size": Vector2i(map_width, map_height),
		"tile_manager_ready": tile_manager != null,
		"generator_info": cavity_generator.get_generation_info(),
		"processor_info": post_processor.get_processing_info() if post_processor != null else {}
	}
