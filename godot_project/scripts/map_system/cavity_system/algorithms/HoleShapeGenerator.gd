extends Node

## 🎨 噪声形状空洞生成器
## 基于噪声为每个中心点生成不规则空洞形状

# ============================================================================
# 属性
# ============================================================================

var noise: FastNoiseLite
var hole_radius: float = 10.0
var noise_threshold: float = 0.3
var noise_scale: float = 0.1
var shape_detail: int = 24 # 增加形状细节，让边界更平滑
var irregularity_factor: float = 0.8 # 增加不规则程度

# 配置参数（从MapConfig加载）
var cavity_config: Dictionary = {}

# ============================================================================
# 初始化
# ============================================================================

func _init():
	"""初始化噪声生成器"""
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.1
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

func _ready():
	"""节点准备就绪"""
	name = "HoleShapeGenerator"
	_load_config_from_mapconfig()

func _load_config_from_mapconfig() -> void:
	"""从MapConfig加载配置参数"""
	if MapConfig:
		cavity_config = MapConfig.get_cavity_excavation_config()
		
		# 更新噪声参数
		noise.frequency = cavity_config.get("noise_frequency", 0.1)
		noise_scale = cavity_config.get("noise_amplitude", 0.5)
		irregularity_factor = cavity_config.get("shape_irregularity", 0.4)
		
		LogManager.info("HoleShapeGenerator - 已从MapConfig加载配置参数")
	else:
		LogManager.warning("HoleShapeGenerator - MapConfig未找到，使用默认配置")

# ============================================================================
# 核心方法
# ============================================================================

func generate_hole_shape(center: Vector2, map_width: int, map_height: int) -> PackedVector2Array:
	"""基于噪声为每个中心点生成不规则空洞形状
	
	Args:
		center: 空洞中心点
		map_width: 地图宽度
		map_height: 地图高度
		
	Returns:
		形状点数组
	"""
	var shape_points = PackedVector2Array()
	
	# 在圆周上采样并应用噪声扰动
	for i in range(shape_detail):
		var angle = 2 * PI * i / shape_detail
		var base_dir = Vector2(cos(angle), sin(angle))
		
		# 使用多层噪声扰动半径，增强不规则性
		var noise_value = 0.0
		# 添加多个频率的噪声
		noise_value += noise.get_noise_2d(center.x + base_dir.x * 3, center.y + base_dir.y * 3) * 0.5
		noise_value += noise.get_noise_2d(center.x + base_dir.x * 8, center.y + base_dir.y * 8) * 0.3
		noise_value += noise.get_noise_2d(center.x + base_dir.x * 15, center.y + base_dir.y * 15) * 0.2
		
		# 增加不规则因子
		var enhanced_irregularity = irregularity_factor * 1.5
		var perturbed_radius = hole_radius * (1.0 + noise_value * enhanced_irregularity)
		
		# 添加随机扰动
		var random_factor = randf_range(-0.15, 0.15)
		perturbed_radius += hole_radius * random_factor
		var point = center + base_dir * perturbed_radius
		
		# 确保点在地图范围内
		point.x = clamp(point.x, 0, map_width - 1)
		point.y = clamp(point.y, 0, map_height - 1)
		shape_points.append(point)
	
	return shape_points

func generate_organic_shape(center: Vector2, map_width: int, map_height: int) -> PackedVector2Array:
	"""生成有机形状（更复杂的噪声形状）
	
	Args:
		center: 空洞中心点
		map_width: 地图宽度
		map_height: 地图高度
		
	Returns:
		形状点数组
	"""
	var shape_points = PackedVector2Array()
	var num_layers = 5 # 增加噪声层数，让形状更复杂
	
	for i in range(shape_detail):
		var angle = 2 * PI * i / shape_detail
		var base_dir = Vector2(cos(angle), sin(angle))
		var total_radius = hole_radius
		
		# 多层噪声叠加，增强不规则性
		for layer in range(num_layers):
			var layer_scale = pow(1.5, layer) # 调整缩放因子，让变化更平滑
			var layer_noise = noise.get_noise_2d(
				center.x + base_dir.x * layer_scale * 2,
				center.y + base_dir.y * layer_scale * 2
			)
			# 增加噪声影响，让形状更不规则
			var noise_strength = hole_radius * (0.3 + 0.1 * layer) / layer_scale
			total_radius += layer_noise * noise_strength
		
		# 添加额外的随机扰动
		var random_perturbation = randf_range(-0.1, 0.1) * hole_radius
		total_radius += random_perturbation
		
		var point = center + base_dir * total_radius
		
		# 确保点在地图范围内
		point.x = clamp(point.x, 0, map_width - 1)
		point.y = clamp(point.y, 0, map_height - 1)
		shape_points.append(point)
	
	return shape_points


func apply_hole_to_map(hole_points: PackedVector2Array) -> Array[Vector3]:
	"""将空洞形状应用到地图网格
	
	Args:
		hole_points: 形状点数组
		
	Returns:
		挖掘位置数组
	"""
	var excavated_positions: Array[Vector3] = []
	var bounding_rect = _calculate_bounding_rect(hole_points)
	
	# 在包围盒内检查每个点是否在空洞内
	for x in range(int(bounding_rect.position.x), int(bounding_rect.end.x)):
		for z in range(int(bounding_rect.position.y), int(bounding_rect.end.y)):
			var point = Vector2(x, z)
			if _is_point_in_polygon(point, hole_points):
				excavated_positions.append(Vector3(x, 0, z))
	
	return excavated_positions

func generate_cavity_from_shape(center: Vector2, shape_type: String, map_width: int, map_height: int) -> Array[Vector3]:
	"""根据形状类型生成空洞
	
	Args:
		center: 空洞中心点
		shape_type: 形状类型 ("circle", "noise", "organic")
		map_width: 地图宽度
		map_height: 地图高度
		
	Returns:
		挖掘位置数组
	"""
	var shape_points = PackedVector2Array()
	
	match shape_type:
		"circle":
			shape_points = _generate_circle_points(center, hole_radius)
		"noise":
			shape_points = generate_hole_shape(center, map_width, map_height)
		"organic":
			shape_points = generate_organic_shape(center, map_width, map_height)
		_:
			LogManager.warning("HoleShapeGenerator - 未知形状类型: %s，使用噪声形状" % shape_type)
			shape_points = generate_hole_shape(center, map_width, map_height)
	
	return apply_hole_to_map(shape_points)

# ============================================================================
# 内部方法
# ============================================================================

func _generate_circle_points(center: Vector2, radius: float) -> PackedVector2Array:
	"""生成圆形点数组"""
	var points = PackedVector2Array()
	var num_points = max(8, int(radius * 2))
	
	for i in range(num_points):
		var angle = 2 * PI * i / num_points
		var point = center + Vector2(cos(angle), sin(angle)) * radius
		points.append(point)
	
	return points

func _calculate_bounding_rect(points: PackedVector2Array) -> Rect2:
	"""计算形状的边界矩形"""
	if points.is_empty():
		return Rect2()
	
	var min_x = points[0].x
	var max_x = points[0].x
	var min_y = points[0].y
	var max_y = points[0].y
	
	for point in points:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

func _is_point_in_polygon(point: Vector2, polygon: PackedVector2Array) -> bool:
	"""使用射线法判断点是否在多边形内"""
	var inside = false
	var j = polygon.size() - 1
	
	for i in range(polygon.size()):
		if ((polygon[i].y > point.y) != (polygon[j].y > point.y)) and \
		   (point.x < (polygon[j].x - polygon[i].x) * (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) + polygon[i].x):
			inside = not inside
		j = i
	
	return inside

# ============================================================================
# 配置方法
# ============================================================================

func set_noise_parameters(frequency: float, noise_type: FastNoiseLite.NoiseType, seed: int) -> void:
	"""设置噪声参数"""
	noise.frequency = frequency
	noise.noise_type = noise_type
	noise.seed = seed

func set_shape_parameters(radius: float, threshold: float, scale: float, detail: int, irregularity: float) -> void:
	"""设置形状参数"""
	hole_radius = radius
	noise_threshold = threshold
	noise_scale = scale
	shape_detail = detail
	irregularity_factor = irregularity

func get_shape_info() -> Dictionary:
	"""获取形状生成器信息"""
	return {
		"hole_radius": hole_radius,
		"noise_threshold": noise_threshold,
		"noise_scale": noise_scale,
		"shape_detail": shape_detail,
		"irregularity_factor": irregularity_factor,
		"noise_frequency": noise.frequency,
		"noise_type": noise.noise_type
	}
