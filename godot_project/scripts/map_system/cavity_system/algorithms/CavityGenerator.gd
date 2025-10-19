extends Node

## 🏗️ 空洞生成主控制器
## 使用泊松圆盘分布生成空洞，集成噪声形状生成

# ============================================================================
# 类型引用
# ============================================================================

const Cavity = preload("res://scripts/map_system/cavity_system/cavities/Cavity.gd")
const HoleShapeGenerator = preload("res://scripts/map_system/cavity_system/algorithms/HoleShapeGenerator.gd")
const CavityConfigManager = preload("res://scripts/map_system/cavity_system/config/CavityConfigManager.gd")

# ============================================================================
# 属性
# ============================================================================

var map_width: int = 200
var map_height: int = 200
var min_hole_distance: float = 25.0
var average_hole_radius: float = 12.0
var noise: FastNoiseLite

var poisson_sampler: PoissonDiskSampler
var shape_generator: HoleShapeGenerator
var tile_manager: Node
var config_manager: CavityConfigManager

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	"""初始化空洞生成器"""
	name = "CavityGenerator"
	_initialize_components()

func _initialize_components() -> void:
	"""初始化组件"""
	config_manager = CavityConfigManager.get_instance()
	poisson_sampler = PoissonDiskSampler.new()
	shape_generator = HoleShapeGenerator.new()
	
	# 初始化噪声
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = config_manager.get_config_value("noise_frequency", 0.1)
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	shape_generator.noise = noise
	shape_generator.hole_radius = config_manager.get_config_value("average_cavity_size", 12.0)

# 配置加载已移至 CavityConfigManager

# ============================================================================
# 核心生成方法
# ============================================================================

func generate_cavities() -> Array[Cavity]:
	"""生成所有空洞"""
	var cavities: Array[Cavity] = []
	
	# 1. 生成固定空洞（关键建筑）
	var fixed_cavities = _generate_fixed_cavities()
	cavities.append_array(fixed_cavities)
	
	# 2. 使用泊松圆盘采样生成随机空洞
	var random_cavities = _generate_random_cavities()
	cavities.append_array(random_cavities)
	
	# 3. 后处理：平滑边缘和清除过小空洞
	cavities = _post_process_cavities(cavities)
	
	LogManager.info("CavityGenerator - 生成了 %d 个空洞" % cavities.size())
	return cavities

func generate_cavities_with_constraints() -> Array[Cavity]:
	"""带约束条件的空洞生成"""
	LogManager.info("CavityGenerator - 开始生成约束空洞")
	var cavities: Array[Cavity] = []
	
	# 1. 生成固定空洞
	LogManager.info("CavityGenerator - 步骤1: 生成固定空洞...")
	var fixed_cavities = _generate_fixed_cavities()
	LogManager.info("CavityGenerator - 生成了 %d 个固定空洞" % fixed_cavities.size())
	cavities.append_array(fixed_cavities)
	
	# 2. 准备约束条件
	LogManager.info("CavityGenerator - 步骤2: 准备约束条件...")
	var constraints = _prepare_constraints(fixed_cavities)
	LogManager.info("CavityGenerator - 约束条件准备完成")
	
	# 3. 使用约束泊松圆盘采样生成随机空洞
	LogManager.info("CavityGenerator - 步骤3: 生成随机空洞...")
	var random_cavities = _generate_constrained_cavities(constraints)
	LogManager.info("CavityGenerator - 生成了 %d 个随机空洞" % random_cavities.size())
	cavities.append_array(random_cavities)
	
	# 4. 后处理
	LogManager.info("CavityGenerator - 步骤4: 后处理空洞...")
	cavities = _post_process_cavities(cavities)
	
	LogManager.info("CavityGenerator - 生成了 %d 个约束空洞" % cavities.size())
	return cavities

# ============================================================================
# 固定空洞生成
# ============================================================================

func _generate_fixed_cavities() -> Array[Cavity]:
	"""生成固定空洞（关键建筑）"""
	LogManager.info("CavityGenerator - 开始生成固定空洞")
	var cavities: Array[Cavity] = []
	
	LogManager.info("CavityGenerator - 获取关键空洞配置...")
	var fixed_configs = config_manager.get_type_config("critical")
	LogManager.info("CavityGenerator - 获得关键空洞配置")
	
	if fixed_configs.is_empty():
		LogManager.warning("⚠️ 没有找到任何关键空洞配置！")
		return cavities
	
	# 创建默认关键空洞
	var critical_cavities = _create_default_critical_cavities()
	cavities.append_array(critical_cavities)
	
	LogManager.info("CavityGenerator - 固定空洞生成完成: %d 个" % cavities.size())
	return cavities

func _create_default_critical_cavities() -> Array[Cavity]:
	"""创建默认关键空洞"""
	var cavities: Array[Cavity] = []
	
	# 创建地牢之心
	var dungeon_heart = Cavity.new("dungeon_heart", "critical", "DUNGEON_HEART")
	dungeon_heart.priority = 10
	dungeon_heart.highlight_color = Color(1.0, 0.0, 0.0, 0.8)
	var center = Vector2i(int(map_width / 2.0), int(map_height / 2.0))
	dungeon_heart.generate_circular_shape(center, 15)
	cavities.append(dungeon_heart)
	
	# 创建传送门
	var portal = Cavity.new("portal", "critical", "PORTAL")
	portal.priority = 9
	portal.highlight_color = Color(0.5, 0.0, 0.8, 0.9)
	var portal_center = Vector2i(int(map_width / 4.0), int(map_height / 4.0))
	portal.generate_circular_shape(portal_center, 8)
	cavities.append(portal)
	
	return cavities

func _create_cavity_from_config(config: Dictionary) -> Cavity:
	"""从配置创建空洞"""
	var cavity = Cavity.new(config.id, config.type, config.content_type)
	cavity.priority = config.get("priority", 0)
	cavity.highlight_color = _get_color_from_config(config.get("highlight_color", [1.0, 1.0, 1.0, 1.0]))
	
	var center = Vector2i(config.center[0], config.center[1])
	
	match config.get("shape", "circle"):
		"circle":
			var _radius = config.get("radius", 10)
			cavity.generate_circular_shape(center, _radius)
		"rectangle":
			var size = Vector2i(config.size[0], config.size[1])
			cavity.generate_rectangular_shape(center, size)
		"noise":
			var _radius = config.get("radius", 10)
			var shape_points = shape_generator.generate_hole_shape(Vector2(center), map_width, map_height)
			cavity.generate_noise_shape(center, shape_points)
		"maze":
			var size = Vector2i(config.size[0], config.size[1])
			cavity.generate_rectangular_shape(center, size)
		_:
			LogManager.warning("CavityGenerator - 未知形状类型: %s" % config.shape)
			return null
	
	return cavity

# ============================================================================
# 随机空洞生成
# ============================================================================

func _generate_random_cavities() -> Array[Cavity]:
	"""生成随机空洞"""
	var cavities: Array[Cavity] = []
	
	# 使用泊松圆盘采样生成空洞中心
	var hole_centers = poisson_sampler.sample(min_hole_distance, map_width, map_height)
	LogManager.info("CavityGenerator - 生成了 %d 个空洞中心点" % hole_centers.size())
	
	# 为每个中心生成空洞
	for i in range(hole_centers.size()):
		var center = hole_centers[i]
		var cavity = _create_random_cavity_from_center(center, i)
		if cavity:
			cavities.append(cavity)
	
	return cavities

func _generate_constrained_cavities(constraints: Array[Dictionary]) -> Array[Cavity]:
	"""生成约束空洞"""
	var cavities: Array[Cavity] = []
	
	# 使用约束泊松圆盘采样
	var hole_centers = poisson_sampler.sample_with_constraints(min_hole_distance, map_width, map_height, constraints)
	LogManager.info("CavityGenerator - 生成了 %d 个约束空洞中心点" % hole_centers.size())
	
	# 为每个中心生成空洞
	for i in range(hole_centers.size()):
		var center = hole_centers[i]
		var cavity = _create_random_cavity_from_center(center, i)
		if cavity:
			cavities.append(cavity)
	
	return cavities

func _create_random_cavity_from_center(center: Vector2, index: int) -> Cavity:
	"""从中心点创建随机空洞"""
	var cavity = Cavity.new()
	cavity.id = "cavity_%d" % index
	cavity.type = "functional"
	cavity.content_type = _get_random_content_type()
	cavity.center = Vector2i(int(center.x), int(center.y))
	cavity.priority = 3
	
	# 随机选择形状类型（移除星形，增强自然形状）
	var shape_types = ["noise", "organic", "organic", "noise"] # 增加有机形状权重
	var shape_type = shape_types[randi() % shape_types.size()]
	
	# 生成空洞形状
	var excavated_positions = shape_generator.generate_cavity_from_shape(
		center, shape_type, map_width, map_height
	)
	
	# 设置空洞位置
	for pos in excavated_positions:
		cavity.add_position(pos)
	
	# 设置空洞属性
	if cavity.positions.size() < 10: # 过小的空洞
		return null
	
	cavity.highlight_color = _get_random_cavity_color()
	cavity.area = cavity.positions.size()
	
	return cavity

# ============================================================================
# 约束条件处理
# ============================================================================

func _prepare_constraints(fixed_cavities: Array[Cavity]) -> Array[Dictionary]:
	"""准备约束条件"""
	var constraints: Array[Dictionary] = []
	
	for cavity in fixed_cavities:
		var constraint = {
			"type": "avoid",
			"center": [cavity.center.x, cavity.center.y],
			"shape": "circle",
			"radius": cavity.radius if cavity.radius > 0 else max(cavity.size.x, cavity.size.y) / 2 + 5
		}
		constraints.append(constraint)
	
	return constraints

# ============================================================================
# 后处理
# ============================================================================

func _post_process_cavities(cavities: Array[Cavity]) -> Array[Cavity]:
	"""后处理空洞：平滑边缘、清除过小空洞、优化形状"""
	var processed_cavities: Array[Cavity] = []
	
	for cavity in cavities:
		# 1. 过滤过小的空洞
		if cavity.positions.size() < 15:
			LogManager.info("CavityGenerator - 移除过小空洞: %s (大小: %d)" % [cavity.id, cavity.positions.size()])
			continue
		
		# 2. 检查空洞连通性
		if not cavity.check_connectivity():
			LogManager.warning("CavityGenerator - 移除不连通空洞: %s" % cavity.id)
			continue
		
		# 3. 平滑空洞边缘
		_smooth_cavity_edges(cavity)
		
		processed_cavities.append(cavity)
	
	# 4. 全局优化：确保空洞间距
	processed_cavities = _ensure_cavity_spacing(processed_cavities)
	
	return processed_cavities

func _smooth_cavity_edges(cavity: Cavity) -> void:
	"""平滑空洞边缘"""
	var smoothed_positions: Array[Vector3] = []
	
	for pos in cavity.positions:
		var solid_neighbors = 0
		var total_neighbors = 0
		
		# 检查周围8个邻居
		for dx in range(-1, 2):
			for dz in range(-1, 2):
				if dx == 0 and dz == 0:
					continue
				
				var neighbor_pos = pos + Vector3(dx, 0, dz)
				if neighbor_pos in cavity.positions:
					solid_neighbors += 1
				total_neighbors += 1
		
		# 如果周围大部分是空洞，保留此位置
		if solid_neighbors >= total_neighbors * 0.3:
			smoothed_positions.append(pos)
	
	cavity.positions = smoothed_positions
	cavity._update_bounds()

func _ensure_cavity_spacing(cavities: Array[Cavity]) -> Array[Cavity]:
	"""确保空洞间距"""
	var valid_cavities: Array[Cavity] = []
	
	for i in range(cavities.size()):
		var cavity = cavities[i]
		var is_valid = true
		
		# 检查与其他空洞的距离
		for j in range(i + 1, cavities.size()):
			var other_cavity = cavities[j]
			var distance = cavity.center.distance_to(other_cavity.center)
			
			if distance < min_hole_distance:
				is_valid = false
				LogManager.warning("CavityGenerator - 空洞间距过近: %s 和 %s" % [cavity.id, other_cavity.id])
				break
		
		if is_valid:
			valid_cavities.append(cavity)
	
	return valid_cavities

# ============================================================================
# 工具方法
# ============================================================================

func _get_random_content_type() -> String:
	"""获取随机内容类型"""
	var content_types = ["FOREST", "LAKE", "CAVE", "WASTELAND", "ROOM_SYSTEM", "MAZE_SYSTEM"]
	return content_types[randi() % content_types.size()]

func _get_random_cavity_color() -> Color:
	"""获取随机空洞颜色"""
	var colors = [
		Color(0.0, 0.8, 0.0, 0.6), # 绿色
		Color(0.0, 0.6, 1.0, 0.6), # 蓝色
		Color(0.8, 0.0, 0.8, 0.6), # 紫色
		Color(1.0, 0.5, 0.0, 0.6), # 橙色
		Color(0.8, 0.8, 0.0, 0.6), # 黄色
		Color(0.5, 0.3, 0.1, 0.6) # 棕色
	]
	return colors[randi() % colors.size()]

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

func set_generation_parameters(min_distance: float, avg_radius: float) -> void:
	"""设置生成参数"""
	min_hole_distance = min_distance
	average_hole_radius = avg_radius
	shape_generator.hole_radius = avg_radius

func get_generation_info() -> Dictionary:
	"""获取生成信息"""
	return {
		"map_size": Vector2i(map_width, map_height),
		"min_hole_distance": min_hole_distance,
		"average_hole_radius": average_hole_radius,
		"poisson_sampler": poisson_sampler.get_grid_info(),
		"shape_generator": shape_generator.get_shape_info()
	}
