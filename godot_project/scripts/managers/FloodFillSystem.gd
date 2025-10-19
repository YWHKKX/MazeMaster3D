extends Node
class_name FloodFillSystem

## 🌊 统一洪水填充系统
## 集成空洞系统的洪水填充功能，为房间生成提供统一API
## 基于空洞系统中现有的洪水填充算法，扩展为通用API

# ============================================================================
# 洪水填充类型枚举
# ============================================================================

enum FloodFillType {
	CONNECTIVITY_CHECK, # 连通性检查
	AREA_DETECTION, # 区域检测
	BOUNDARY_FINDING, # 边界查找
	POLYGON_FILLING, # 多边形填充
	CAVITY_VALIDATION, # 空洞验证
	ROOM_GENERATION, # 房间生成区域检测
	MAZE_GENERATION # 迷宫生成区域检测
}

# ============================================================================
# 属性
# ============================================================================

var tile_manager: Node
var map_size: Vector3

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	"""初始化洪水填充系统"""
	name = "FloodFillSystem"

func set_tile_manager(manager: Node) -> void:
	"""设置瓦片管理器"""
	tile_manager = manager
	if tile_manager and tile_manager.has_method("get_map_size"):
		map_size = tile_manager.get_map_size()

# ============================================================================
# 核心洪水填充方法
# ============================================================================

func flood_fill_area(start_pos: Vector3, target_tile_type: int) -> Array[Vector3]:
	"""洪水填充指定区域
	
	Args:
		start_pos: 起始位置
		target_tile_type: 目标瓦片类型
		
	Returns:
		填充的位置数组
	"""
	if not tile_manager:
		LogManager.error("FloodFillSystem - TileManager 未设置")
		return []
	
	var filled_positions: Array[Vector3] = []
	var visited: Dictionary = {}
	var queue: Array[Vector3] = [start_pos]
	
	while not queue.is_empty():
		var current = queue.pop_front()
		if current in visited:
			continue
		
		visited[current] = true
		
		# 检查当前位置是否为目标类型
		if tile_manager.get_tile_type(current) == target_tile_type:
			filled_positions.append(current)
			
			# 检查四个方向的邻居
			for dir in [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]:
				var neighbor = current + dir
				if neighbor not in visited and _is_valid_position(neighbor):
					queue.append(neighbor)
	
	LogManager.info("FloodFillSystem - 洪水填充完成: %d 个位置" % filled_positions.size())
	return filled_positions

func flood_fill_cavity_valid_area(cavity, tile_manager_ref: Node) -> Array[Vector3]:
	"""洪水填充空洞内的有效区域（用于房间生成）
	
	Args:
		cavity: 空洞对象
		tile_manager_ref: 瓦片管理器引用
		
	Returns:
		空洞内可用于生成房间的有效位置
	"""
	if not cavity or not tile_manager_ref:
		LogManager.error("FloodFillSystem - 无效的空洞或瓦片管理器")
		return []
	
	var valid_positions: Array[Vector3] = []
	var visited: Dictionary = {}
	
	# 从空洞中心开始洪水填充
	var center_pos = cavity.get_center_position()
	var queue: Array[Vector3] = [center_pos]
	
	LogManager.info("FloodFillSystem - 开始洪水填充空洞有效区域，中心: %s" % center_pos)
	
	while not queue.is_empty():
		var current = queue.pop_front()
		if current in visited:
			continue
		
		visited[current] = true
		
		# 检查当前位置是否在空洞内且可用于房间生成
		if cavity.contains_position(current) and _is_valid_for_room_generation(current, tile_manager_ref):
			valid_positions.append(current)
			
			# 检查四个方向的邻居
			for dir in [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]:
				var neighbor = current + dir
				if neighbor not in visited and cavity.contains_position(neighbor):
					queue.append(neighbor)
	
	LogManager.info("FloodFillSystem - 空洞有效区域填充完成: %d 个位置" % valid_positions.size())
	return valid_positions

func flood_fill_room_generation_areas(cavity, tile_manager_ref: Node) -> Array:
	"""洪水填充空洞内的房间生成区域
	
	Args:
		cavity: 空洞对象
		tile_manager_ref: 瓦片管理器引用
		
	Returns:
		多个连续区域的数组，每个区域可用于生成一个房间
	"""
	if not cavity or not tile_manager_ref:
		LogManager.error("FloodFillSystem - 无效的空洞或瓦片管理器")
		return []
	
	var generation_areas = []
	var visited: Dictionary = {}
	
	LogManager.info("FloodFillSystem - 开始洪水填充房间生成区域...")
	
	# 遍历空洞内的所有位置
	for pos in cavity.positions:
		if pos in visited:
			continue
		
		# 检查是否可用于房间生成
		if _is_valid_for_room_generation(pos, tile_manager_ref):
			# 洪水填充这个区域
			var area = _flood_fill_single_area(pos, cavity, tile_manager_ref, visited)
			if area.size() >= 10: # 最小房间大小
				generation_areas.append(area)
				LogManager.info("FloodFillSystem - 找到房间生成区域: %d 个位置" % area.size())
	
	LogManager.info("FloodFillSystem - 房间生成区域填充完成: %d 个区域" % generation_areas.size())
	return generation_areas

func flood_fill_maze_generation_areas(cavity, tile_manager_ref: Node) -> Array:
	"""洪水填充空洞内的迷宫生成区域
	
	Args:
		cavity: 空洞对象
		tile_manager_ref: 瓦片管理器引用
		
	Returns:
		多个连续区域的数组，每个区域可用于生成一个迷宫
	"""
	if not cavity or not tile_manager_ref:
		LogManager.error("FloodFillSystem - 无效的空洞或瓦片管理器")
		return []
	
	var generation_areas = []
	var visited: Dictionary = {}
	
	LogManager.info("FloodFillSystem - 开始洪水填充迷宫生成区域...")
	
	# 遍历空洞内的所有位置
	for pos in cavity.positions:
		if pos in visited:
			continue
		
		# 检查是否可用于迷宫生成
		if _is_valid_for_maze_generation(pos, tile_manager_ref):
			# 洪水填充这个区域
			var area = _flood_fill_single_maze_area(pos, cavity, tile_manager_ref, visited)
			if area.size() >= 20: # 最小迷宫大小
				generation_areas.append(area)
				LogManager.info("FloodFillSystem - 找到迷宫生成区域: %d 个位置" % area.size())
	
	LogManager.info("FloodFillSystem - 迷宫生成区域填充完成: %d 个区域" % generation_areas.size())
	return generation_areas

func flood_fill_connectivity_check(positions: Array) -> bool:
	"""检查位置数组的连通性（基于Cavity.check_connectivity算法）
	
	Args:
		positions: 位置数组
		
	Returns:
		是否连通
	"""
	if positions.is_empty():
		return false
	
	var visited: Dictionary = {}
	var queue: Array[Vector3] = [positions[0]]
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
			if neighbor in positions and neighbor not in visited:
				queue.append(neighbor)
	
	var connectivity_ratio = float(connected_count) / positions.size()
	var is_connected_result = connectivity_ratio >= 0.8 # 80%以上连通
	
	LogManager.info("FloodFillSystem - 连通性检查: %d/%d (%.1f%%) - %s" % [
		connected_count, positions.size(), connectivity_ratio * 100,
		"连通" if is_connected_result else "不连通"
	])
	
	return is_connected_result

func flood_fill_polygon_area(polygon_points: PackedVector2Array, _map_width: int, _map_height: int) -> Array:
	"""洪水填充多边形区域（基于HoleShapeGenerator算法）
	
	Args:
		polygon_points: 多边形顶点数组
		map_width: 地图宽度
		map_height: 地图高度
		
	Returns:
		多边形内的位置数组
	"""
	var filled_positions: Array[Vector3] = []
	var bounding_rect = _calculate_bounding_rect(polygon_points)
	
	LogManager.info("FloodFillSystem - 开始洪水填充多边形区域...")
	
	# 在包围盒内检查每个点是否在多边形内
	for x in range(int(bounding_rect.position.x), int(bounding_rect.end.x)):
		for z in range(int(bounding_rect.position.y), int(bounding_rect.end.y)):
			var point = Vector2(x, z)
			if _is_point_in_polygon(point, polygon_points):
				filled_positions.append(Vector3(x, 0, z))
	
	LogManager.info("FloodFillSystem - 多边形区域填充完成: %d 个位置" % filled_positions.size())
	return filled_positions

# ============================================================================
# 内部方法
# ============================================================================

func _flood_fill_single_area(start_pos: Vector3, cavity, tile_manager_ref: Node, visited: Dictionary) -> Array[Vector3]:
	"""洪水填充单个区域"""
	var area: Array[Vector3] = []
	var queue: Array[Vector3] = [start_pos]
	
	while not queue.is_empty():
		var current = queue.pop_front()
		if current in visited:
			continue
		
		visited[current] = true
		
		if cavity.contains_position(current) and _is_valid_for_room_generation(current, tile_manager_ref):
			area.append(current)
			
			# 检查四个方向的邻居
			for dir in [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]:
				var neighbor = current + dir
				if neighbor not in visited and cavity.contains_position(neighbor):
					queue.append(neighbor)
	
	return area

func _is_valid_for_room_generation(pos: Vector3, tile_manager_ref: Node) -> bool:
	"""检查位置是否可用于房间生成"""
	if not tile_manager_ref:
		return false
	
	var tile_type = tile_manager_ref.get_tile_type(pos)
	
	# 允许在未挖掘区域和空地上生成房间
	return tile_type == TileTypes.TileType.UNEXCAVATED or tile_type == TileTypes.TileType.EMPTY

func _is_valid_for_maze_generation(pos: Vector3, tile_manager_ref: Node) -> bool:
	"""检查位置是否可用于迷宫生成"""
	if not tile_manager_ref:
		return false
	
	var tile_type = tile_manager_ref.get_tile_type(pos)
	
	# 允许在未挖掘区域和空地上生成迷宫
	# 迷宫比房间更灵活，可以在更多类型的瓦片上生成
	return tile_type == TileTypes.TileType.UNEXCAVATED or tile_type == TileTypes.TileType.EMPTY or tile_type == TileTypes.TileType.CORRIDOR

func _flood_fill_single_maze_area(start_pos: Vector3, cavity, tile_manager_ref: Node, visited: Dictionary) -> Array[Vector3]:
	"""洪水填充单个迷宫区域"""
	var area: Array[Vector3] = []
	var queue: Array[Vector3] = [start_pos]
	
	while not queue.is_empty():
		var current = queue.pop_front()
		if current in visited:
			continue
		
		visited[current] = true
		
		if cavity.contains_position(current) and _is_valid_for_maze_generation(current, tile_manager_ref):
			area.append(current)
			
			# 检查四个方向的邻居
			for dir in [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]:
				var neighbor = current + dir
				if neighbor not in visited and cavity.contains_position(neighbor):
					queue.append(neighbor)
	
	return area

func _is_valid_position(pos: Vector3) -> bool:
	"""检查位置是否有效"""
	if not tile_manager or map_size == Vector3.ZERO:
		return false
	
	return pos.x >= 0 and pos.x < map_size.x and pos.z >= 0 and pos.z < map_size.z

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
# 工具方法
# ============================================================================

func get_flood_fill_info() -> Dictionary:
	"""获取洪水填充系统信息"""
	return {
		"tile_manager_ready": tile_manager != null,
		"map_size": map_size,
		"supported_types": [
			"CONNECTIVITY_CHECK",
			"AREA_DETECTION",
			"BOUNDARY_FINDING",
			"POLYGON_FILLING",
			"CAVITY_VALIDATION",
			"ROOM_GENERATION",
			"MAZE_GENERATION"
		]
	}

func clear_cache() -> void:
	"""清空缓存（如果需要）"""
	# 目前没有缓存，预留接口
	pass
