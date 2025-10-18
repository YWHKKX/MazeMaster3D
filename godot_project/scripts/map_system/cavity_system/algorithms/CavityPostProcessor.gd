extends Node

## 🔧 空洞后处理器
## 对生成的空洞进行后处理：平滑边缘、清除过小空洞、优化形状

# ============================================================================
# 类型引用
# ============================================================================

const Cavity = preload("res://scripts/map_system/cavity_system/cavities/Cavity.gd")

# ============================================================================
# 属性
# ============================================================================

var min_cavity_size: int = 15 # 最小空洞大小
var connectivity_threshold: float = 0.8 # 连通性阈值
var smoothing_iterations: int = 2 # 平滑迭代次数
var edge_smoothing_factor: float = 0.3 # 边缘平滑因子

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	"""初始化后处理器"""
	name = "CavityPostProcessor"

# ============================================================================
# 核心后处理方法
# ============================================================================

func post_process_cavities(cavities: Array[Cavity]) -> Array[Cavity]:
	"""后处理空洞：平滑边缘、清除过小空洞、优化形状"""
	var processed_cavities: Array[Cavity] = []
	
	LogManager.info("CavityPostProcessor - 开始后处理 %d 个空洞" % cavities.size())
	
	for cavity in cavities:
		# 1. 过滤过小的空洞
		if cavity.positions.size() < min_cavity_size:
			LogManager.info("CavityPostProcessor - 移除过小空洞: %s (大小: %d)" % [cavity.id, cavity.positions.size()])
			continue
		
		# 2. 平滑空洞边缘
		_smooth_cavity_edges(cavity)
		
		# 3. 检查空洞连通性
		if not _check_cavity_connectivity(cavity):
			LogManager.warning("CavityPostProcessor - 移除不连通空洞: %s" % cavity.id)
			continue
		
		# 4. 优化空洞形状
		_optimize_cavity_shape(cavity)
		
		processed_cavities.append(cavity)
	
	# 5. 全局优化：确保空洞间距
	processed_cavities = _ensure_cavity_spacing(processed_cavities)
	
	LogManager.info("CavityPostProcessor - 后处理完成，保留 %d 个空洞" % processed_cavities.size())
	return processed_cavities

# ============================================================================
# 边缘平滑
# ============================================================================

func _smooth_cavity_edges(cavity: Cavity) -> void:
	"""平滑空洞边缘"""
	for iteration in range(smoothing_iterations):
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
			
			# 根据邻居比例决定是否保留此位置
			var neighbor_ratio = float(solid_neighbors) / total_neighbors
			if neighbor_ratio >= edge_smoothing_factor:
				smoothed_positions.append(pos)
		
		cavity.positions = smoothed_positions
		cavity._update_bounds()

func _smooth_cavity_boundary(cavity: Cavity) -> void:
	"""平滑空洞边界（更精细的边界处理）"""
	var boundary_positions = cavity.get_boundary_positions()
	var smoothed_boundary: Array[Vector3] = []
	
	for pos in boundary_positions:
		var smooth_score = _calculate_smooth_score(pos, cavity.positions)
		if smooth_score > 0.5: # 平滑度阈值
			smoothed_boundary.append(pos)
	
	# 更新空洞位置（这里需要更复杂的逻辑来保持空洞完整性）
	# 简化实现：保持原有逻辑

func _calculate_smooth_score(pos: Vector3, cavity_positions: Array[Vector3]) -> float:
	"""计算位置的平滑度分数"""
	var smooth_neighbors = 0
	var total_neighbors = 0
	
	# 检查周围邻居的平滑度
	for dx in range(-2, 3):
		for dz in range(-2, 3):
			if dx == 0 and dz == 0:
				continue
			
			var neighbor = pos + Vector3(dx, 0, dz)
			if neighbor in cavity_positions:
				smooth_neighbors += 1
			total_neighbors += 1
	
	return float(smooth_neighbors) / total_neighbors if total_neighbors > 0 else 0.0

# ============================================================================
# 连通性检查
# ============================================================================

func _check_cavity_connectivity(cavity: Cavity) -> bool:
	"""检查空洞连通性（使用洪水填充算法）"""
	if cavity.positions.is_empty():
		return false
	
	var visited = {}
	var queue = [cavity.positions[0]]
	var connected_count = 0
	
	while not queue.is_empty():
		var current = queue.pop_front()
		if current in visited:
			continue
		
		visited[current] = true
		connected_count += 1
		
		# 检查4个方向的邻居
		for dir in [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]:
			var neighbor = current + dir
			if neighbor in cavity.positions and neighbor not in visited:
				queue.append(neighbor)
	
	var connectivity_ratio = float(connected_count) / cavity.positions.size()
	cavity.is_connected = connectivity_ratio >= connectivity_threshold
	
	return cavity.is_connected

func _fix_cavity_connectivity(cavity: Cavity) -> bool:
	"""修复空洞连通性"""
	if cavity.is_connected:
		return true
	
	# 尝试连接分离的部分
	var components = _find_connected_components(cavity.positions)
	if components.size() <= 1:
		return true
	
	# 连接最大的两个组件
	var largest_component = components[0]
	var second_largest = components[1] if components.size() > 1 else null
	
	if second_largest and second_largest.size() > 0:
		_connect_components(largest_component, second_largest, cavity)
	
	return cavity.check_connectivity()

func _find_connected_components(positions: Array[Vector3]) -> Array:
	"""找到连通组件"""
	var components: Array = []
	var visited = {}
	
	for pos in positions:
		if pos in visited:
			continue
		
		var component: Array[Vector3] = []
		var queue = [pos]
		
		while not queue.is_empty():
			var current = queue.pop_front()
			if current in visited:
				continue
			
			visited[current] = true
			component.append(current)
			
			# 检查4个方向的邻居
			for dir in [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]:
				var neighbor = current + dir
				if neighbor in positions and neighbor not in visited:
					queue.append(neighbor)
		
		components.append(component)
	
	# 按大小排序
	components.sort_custom(func(a, b): return a.size() > b.size())
	return components

func _connect_components(component1: Array[Vector3], component2: Array[Vector3], cavity: Cavity) -> void:
	"""连接两个组件"""
	# 找到两个组件中最近的点
	var min_distance = INF
	var point1 = Vector3.ZERO
	var point2 = Vector3.ZERO
	
	for pos1 in component1:
		for pos2 in component2:
			var distance = pos1.distance_to(pos2)
			if distance < min_distance:
				min_distance = distance
				point1 = pos1
				point2 = pos2
	
	# 在两点之间创建连接路径
	var path = _create_connection_path(point1, point2)
	for pos in path:
		if pos not in cavity.positions:
			cavity.add_position(pos)

func _create_connection_path(from: Vector3, to: Vector3) -> Array[Vector3]:
	"""创建连接路径"""
	var path: Array[Vector3] = []
	var current = from
	
	while current != to:
		path.append(current)
		
		# 向目标方向移动
		var direction = (to - current).normalized()
		var next = current + Vector3(round(direction.x), 0, round(direction.z))
		
		# 确保不超出目标
		if next.distance_to(to) >= current.distance_to(to):
			break
		
		current = next
	
	path.append(to)
	return path

# ============================================================================
# 形状优化
# ============================================================================

func _optimize_cavity_shape(cavity: Cavity) -> void:
	"""优化空洞形状"""
	# 1. 移除孤立的点
	_remove_isolated_points(cavity)
	
	# 2. 填充小洞
	_fill_small_holes(cavity)
	
	# 3. 更新边界信息
	cavity._update_bounds()

func _remove_isolated_points(cavity: Cavity) -> void:
	"""移除孤立的点"""
	var valid_positions: Array[Vector3] = []
	
	for pos in cavity.positions:
		var neighbor_count = 0
		
		# 检查周围8个邻居
		for dx in range(-1, 2):
			for dz in range(-1, 2):
				if dx == 0 and dz == 0:
					continue
				
				var neighbor = pos + Vector3(dx, 0, dz)
				if neighbor in cavity.positions:
					neighbor_count += 1
		
		# 如果邻居数量太少，移除此点
		if neighbor_count >= 2:
			valid_positions.append(pos)
	
	cavity.positions = valid_positions

func _fill_small_holes(cavity: Cavity) -> void:
	"""填充小洞"""
	var bounding_rect = cavity.get_bounding_rect()
	var filled_positions: Array[Vector3] = []
	
	# 在边界矩形内查找小洞
	for x in range(int(bounding_rect.position.x), int(bounding_rect.end.x)):
		for z in range(int(bounding_rect.position.y), int(bounding_rect.end.y)):
			var pos = Vector3(x, 0, z)
			
			# 如果位置不在空洞内，检查是否应该填充
			if pos not in cavity.positions:
				if _should_fill_position(pos, cavity.positions):
					filled_positions.append(pos)
	
	# 添加填充的位置
	for pos in filled_positions:
		cavity.add_position(pos)

func _should_fill_position(pos: Vector3, cavity_positions: Array[Vector3]) -> bool:
	"""检查位置是否应该被填充"""
	var cavity_neighbors = 0
	var total_neighbors = 0
	
	# 检查周围8个邻居
	for dx in range(-1, 2):
		for dz in range(-1, 2):
			if dx == 0 and dz == 0:
				continue
			
			var neighbor = pos + Vector3(dx, 0, dz)
			if neighbor in cavity_positions:
				cavity_neighbors += 1
			total_neighbors += 1
	
	# 如果大部分邻居都是空洞，则填充此位置
	return cavity_neighbors >= total_neighbors * 0.6

# ============================================================================
# 间距优化
# ============================================================================

func _ensure_cavity_spacing(cavities: Array[Cavity]) -> Array[Cavity]:
	"""确保空洞间距"""
	var valid_cavities: Array[Cavity] = []
	var min_distance = 20.0 # 最小间距
	
	for i in range(cavities.size()):
		var cavity = cavities[i]
		var is_valid = true
		
		# 检查与其他空洞的距离
		for j in range(i + 1, cavities.size()):
			var other_cavity = cavities[j]
			var distance = cavity.center.distance_to(other_cavity.center)
			
			if distance < min_distance:
				is_valid = false
				LogManager.warning("CavityPostProcessor - 空洞间距过近: %s 和 %s (距离: %.2f)" % [cavity.id, other_cavity.id, distance])
				break
		
		if is_valid:
			valid_cavities.append(cavity)
	
	return valid_cavities

# ============================================================================
# 配置方法
# ============================================================================

func set_processing_parameters(min_size: int, connectivity: float, smoothing: int, edge_factor: float) -> void:
	"""设置处理参数"""
	min_cavity_size = min_size
	connectivity_threshold = connectivity
	smoothing_iterations = smoothing
	edge_smoothing_factor = edge_factor

func get_processing_info() -> Dictionary:
	"""获取处理信息"""
	return {
		"min_cavity_size": min_cavity_size,
		"connectivity_threshold": connectivity_threshold,
		"smoothing_iterations": smoothing_iterations,
		"edge_smoothing_factor": edge_smoothing_factor
	}
