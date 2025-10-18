extends RefCounted
class_name PoissonDiskSampler

## 🎯 泊松圆盘采样器
## 使用泊松圆盘分布算法生成空洞中心点，确保空洞间最小距离

# ============================================================================
# 属性
# ============================================================================

var r: float = 20.0 # 最小间距
var k: int = 30 # 每个点的候选点数
var width: int = 200
var height: int = 200
var grid: Array = []
var cellsize: float = 0.0

# 配置参数（从MapConfig加载）
var cavity_config: Dictionary = {}

# ============================================================================
# 配置加载
# ============================================================================

func _load_config_from_mapconfig() -> void:
	"""从MapConfig加载配置参数"""
	if MapConfig:
		cavity_config = MapConfig.get_cavity_excavation_config()
		k = cavity_config.get("poisson_k_attempts", 30)
		LogManager.info("PoissonDiskSampler - 已从MapConfig加载配置参数")
	else:
		LogManager.warning("PoissonDiskSampler - MapConfig未找到，使用默认配置")

# ============================================================================
# 核心方法
# ============================================================================

func sample(radius: float, w: int, h: int) -> PackedVector2Array:
	"""使用泊松圆盘采样生成空洞中心点
	
	Args:
		radius: 最小间距
		w: 地图宽度
		h: 地图高度
		
	Returns:
		空洞中心点数组
	"""
	# 从MapConfig加载配置
	_load_config_from_mapconfig()
	
	r = radius
	width = w
	height = h
	cellsize = r / sqrt(2.0)
	_initialize_grid()
	
	var points = PackedVector2Array()
	var active_list = PackedVector2Array()
	
	# 1. 随机选择第一个点
	var first_point = Vector2(randf() * width, randf() * height)
	_grid_set(first_point, first_point)
	points.append(first_point)
	active_list.append(first_point)
	
	# 2. 迭代生成其他点
	while active_list.size() > 0:
		var current_index = randi() % active_list.size()
		var current_point = active_list[current_index]
		var found = false
		
		# 3. 在当前点周围环形区域生成k个候选点
		for i in range(k):
			var angle = randf() * 2 * PI
			var distance = randf_range(r, 2 * r)
			var candidate = current_point + Vector2(cos(angle), sin(angle)) * distance
			
			if _is_valid_candidate(candidate):
				_grid_set(candidate, candidate)
				points.append(candidate)
				active_list.append(candidate)
				found = true
		
		# 4. 如果找不到有效候选点，移除当前点
		if not found:
			active_list.remove_at(current_index)
	
	LogManager.info("PoissonDiskSampler - 生成了 %d 个空洞中心点" % points.size())
	return points

func sample_with_constraints(radius: float, w: int, h: int, constraints: Array[Dictionary]) -> PackedVector2Array:
	"""带约束条件的泊松圆盘采样
	
	Args:
		radius: 最小间距
		w: 地图宽度
		h: 地图高度
		constraints: 约束条件数组，每个约束包含type, center, size等
		
	Returns:
		空洞中心点数组
	"""
	r = radius
	width = w
	height = h
	cellsize = r / sqrt(2.0)
	_initialize_grid()
	
	var points = PackedVector2Array()
	var active_list = PackedVector2Array()
	
	# 1. 首先放置约束点（如地牢之心、传送门等）
	for constraint in constraints:
		var center = Vector2(constraint.center[0], constraint.center[1])
		if _is_point_in_bounds(center):
			_grid_set(center, center)
			points.append(center)
			active_list.append(center)
	
	# 2. 随机选择第一个点（如果约束点为空）
	if points.is_empty():
		var first_point = Vector2(randf() * width, randf() * height)
		_grid_set(first_point, first_point)
		points.append(first_point)
		active_list.append(first_point)
	
	# 3. 迭代生成其他点
	while active_list.size() > 0:
		var current_index = randi() % active_list.size()
		var current_point = active_list[current_index]
		var found = false
		
		# 4. 在当前点周围环形区域生成k个候选点
		for i in range(k):
			var angle = randf() * 2 * PI
			var distance = randf_range(r, 2 * r)
			var candidate = current_point + Vector2(cos(angle), sin(angle)) * distance
			
			if _is_valid_candidate_with_constraints(candidate, constraints):
				_grid_set(candidate, candidate)
				points.append(candidate)
				active_list.append(candidate)
				found = true
		
		# 5. 如果找不到有效候选点，移除当前点
		if not found:
			active_list.remove_at(current_index)
	
	LogManager.info("PoissonDiskSampler - 生成了 %d 个约束空洞中心点" % points.size())
	return points

# ============================================================================
# 内部方法
# ============================================================================

func _initialize_grid() -> void:
	"""初始化网格"""
	var grid_width = int(ceil(width / cellsize))
	var grid_height = int(ceil(height / cellsize))
	
	grid.clear()
	for y in range(grid_height):
		var row: Array = []
		for x in range(grid_width):
			row.append(null)
		grid.append(row)

func _grid_set(point: Vector2, value: Vector2) -> void:
	"""在网格中设置值"""
	var cell_x = int(point.x / cellsize)
	var cell_y = int(point.y / cellsize)
	
	if _is_grid_position_valid(cell_x, cell_y):
		grid[cell_y][cell_x] = value

func _grid_get(point: Vector2) -> Vector2:
	"""从网格中获取值"""
	var cell_x = int(point.x / cellsize)
	var cell_y = int(point.y / cellsize)
	
	if _is_grid_position_valid(cell_x, cell_y):
		return grid[cell_y][cell_x]
	return Vector2.ZERO

func _is_grid_position_valid(x: int, y: int) -> bool:
	"""检查网格位置是否有效"""
	return x >= 0 and y >= 0 and y < grid.size() and x < grid[y].size()

func _is_point_in_bounds(point: Vector2) -> bool:
	"""检查点是否在地图边界内"""
	return point.x >= 0 and point.x < width and point.y >= 0 and point.y < height

func _is_valid_candidate(point: Vector2) -> bool:
	"""检查候选点是否有效（不与现有点冲突）"""
	if not _is_point_in_bounds(point):
		return false
	
	var cell_x = int(point.x / cellsize)
	var cell_y = int(point.y / cellsize)
	
	# 检查周围5x5网格区域
	for y in range(cell_y - 2, cell_y + 3):
		for x in range(cell_x - 2, cell_x + 3):
			if not _is_grid_position_valid(x, y):
				continue
			
			var existing_point = grid[y][x]
			if existing_point != null and point.distance_to(existing_point) < r:
				return false
	
	return true

func _is_valid_candidate_with_constraints(point: Vector2, constraints: Array[Dictionary]) -> bool:
	"""检查候选点是否有效（考虑约束条件）"""
	if not _is_valid_candidate(point):
		return false
	
	# 检查是否与约束区域冲突
	for constraint in constraints:
		if _is_point_in_constraint_area(point, constraint):
			return false
	
	return true

func _is_point_in_constraint_area(point: Vector2, constraint: Dictionary) -> bool:
	"""检查点是否在约束区域内"""
	var constraint_center = Vector2(constraint.center[0], constraint.center[1])
	var constraint_size = constraint.get("size", [0, 0])
	var constraint_radius = constraint.get("radius", 0)
	
	match constraint.get("shape", "circle"):
		"circle":
			return point.distance_to(constraint_center) <= constraint_radius
		"rectangle":
			var half_width = constraint_size[0] / 2
			var half_height = constraint_size[1] / 2
			return abs(point.x - constraint_center.x) <= half_width and \
				   abs(point.y - constraint_center.y) <= half_height
		_:
			return false

# ============================================================================
# 工具方法
# ============================================================================

func get_grid_info() -> Dictionary:
	"""获取网格信息（用于调试）"""
	var grid_width = 0
	if grid.size() > 0:
		grid_width = grid[0].size()
	
	return {
		"grid_width": grid_width,
		"grid_height": grid.size(),
		"cell_size": cellsize,
		"min_distance": r
	}

func clear_grid() -> void:
	"""清空网格"""
	grid.clear()
