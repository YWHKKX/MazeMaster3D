extends RefCounted

## 🕳️ 空洞数据结构
## 表示地图中的一个功能空洞，包含位置、类型、属性等信息

# ============================================================================
# 空洞属性
# ============================================================================

var id: String = ""
var type: String = "" # "ecosystem", "functional", "critical"
var content_type: String = "" # "FOREST", "LAKE", "ROOM_SYSTEM", "MAZE_SYSTEM", etc.
var center: Vector2i = Vector2i.ZERO
var size: Vector2i = Vector2i.ZERO
var radius: int = 0 # 圆形空洞使用
var positions: Array[Vector3] = []
var highlight_color: Color = Color.WHITE
var priority: int = 0
var shape_points: PackedVector2Array = [] # 噪声生成的形状点
var area: float = 0.0 # 空洞面积
var is_connected_cavity: bool = true # 连通性标记
var is_excavated: bool = false # 是否已挖掘

# ============================================================================
# 构造函数
# ============================================================================

func _init(cavity_id: String = "", cavity_type: String = "", content: String = ""):
	id = cavity_id
	type = cavity_type
	content_type = content
	highlight_color = _get_default_color_for_type(content_type)

# ============================================================================
# 核心方法
# ============================================================================

func add_position(pos: Vector3) -> void:
	"""添加位置到空洞"""
	if pos not in positions:
		positions.append(pos)
		_update_bounds()

func remove_position(pos: Vector3) -> void:
	"""从空洞移除位置"""
	var index = positions.find(pos)
	if index >= 0:
		positions.remove_at(index)
		_update_bounds()

func contains_position(pos: Vector3) -> bool:
	"""检查位置是否在空洞内"""
	return pos in positions

func get_position_count() -> int:
	"""获取位置数量"""
	return positions.size()

func is_empty() -> bool:
	"""检查空洞是否为空"""
	return positions.is_empty()

func clear() -> void:
	"""清空空洞"""
	positions.clear()
	center = Vector2i.ZERO
	size = Vector2i.ZERO
	area = 0.0

# ============================================================================
# 边界和形状方法
# ============================================================================

func get_boundary_positions() -> Array[Vector3]:
	"""获取空洞边界位置"""
	var boundary: Array[Vector3] = []
	if positions.is_empty():
		return boundary
	
	var min_x = positions[0].x
	var max_x = positions[0].x
	var min_z = positions[0].z
	var max_z = positions[0].z
	
	# 计算边界
	for pos in positions:
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_z = min(min_z, pos.z)
		max_z = max(max_z, pos.z)
	
	# 获取边界瓦片
	for x in range(min_x - 1, max_x + 2):
		for z in range(min_z - 1, max_z + 2):
			var pos = Vector3(x, 0, z)
			var is_boundary = _is_boundary_position(pos)
			if is_boundary:
				boundary.append(pos)
	
	return boundary

func get_center_position() -> Vector3:
	"""获取空洞中心位置（3D）"""
	return Vector3(center.x, 0, center.y)

func get_bounding_rect() -> Rect2i:
	"""获取空洞边界矩形"""
	if positions.is_empty():
		return Rect2i()
	
	var min_x = positions[0].x
	var max_x = positions[0].x
	var min_z = positions[0].z
	var max_z = positions[0].z
	
	for pos in positions:
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_z = min(min_z, pos.z)
		max_z = max(max_z, pos.z)
	
	return Rect2i(min_x, min_z, max_x - min_x + 1, max_z - min_z + 1)

# ============================================================================
# 连通性检查
# ============================================================================

func check_connectivity() -> bool:
	"""检查空洞连通性（使用洪水填充算法）"""
	if positions.is_empty():
		return false
	
	var visited = {}
	var queue = [positions[0]]
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
	
	is_connected_cavity = connected_count >= positions.size() * 0.8 # 80%以上连通
	return is_connected_cavity

# ============================================================================
# 形状生成
# ============================================================================

func generate_circular_shape(center_pos: Vector2i, _radius: int) -> void:
	"""生成圆形空洞形状"""
	clear()
	center = center_pos
	self.radius = _radius
	
	for x in range(center.x - _radius, center.x + _radius + 1):
		for z in range(center.y - _radius, center.y + _radius + 1):
			var pos = Vector2i(x, z)
			var distance = pos.distance_to(center)
			
			if distance <= _radius:
				add_position(Vector3(x, 0, z))

func generate_rectangular_shape(center_pos: Vector2i, rect_size: Vector2i) -> void:
	"""生成矩形空洞形状"""
	clear()
	center = center_pos
	size = rect_size
	
	var half_width = rect_size.x / 2.0
	var half_height = rect_size.y / 2.0
	
	for x in range(center.x - half_width, center.x + half_width + 1):
		for z in range(center.y - half_height, center.y + half_height + 1):
			add_position(Vector3(x, 0, z))

func generate_noise_shape(center_pos: Vector2i, _shape_points: PackedVector2Array) -> void:
	"""基于噪声形状生成空洞"""
	clear()
	center = center_pos
	self.shape_points = _shape_points
	
	# 使用射线法填充多边形
	var bounding_rect = _calculate_bounding_rect_from_points(_shape_points)
	
	for x in range(int(bounding_rect.position.x), int(bounding_rect.end.x)):
		for z in range(int(bounding_rect.position.y), int(bounding_rect.end.y)):
			var point = Vector2(x, z)
			if _is_point_in_polygon(point, _shape_points):
				add_position(Vector3(x, 0, z))

# ============================================================================
# 工具方法
# ============================================================================

func _update_bounds() -> void:
	"""更新边界信息"""
	if positions.is_empty():
		center = Vector2i.ZERO
		size = Vector2i.ZERO
		area = 0.0
		return
	
	var min_x = positions[0].x
	var max_x = positions[0].x
	var min_z = positions[0].z
	var max_z = positions[0].z
	
	for pos in positions:
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_z = min(min_z, pos.z)
		max_z = max(max_z, pos.z)
	
	center = Vector2i((min_x + max_x) / 2, (min_z + max_z) / 2)
	size = Vector2i(max_x - min_x + 1, max_z - min_z + 1)
	area = positions.size()

func _is_boundary_position(pos: Vector3) -> bool:
	"""检查位置是否为边界位置"""
	if not contains_position(pos):
		return false
	
	# 检查周围是否有非空洞位置
	for dx in range(-1, 2):
		for dz in range(-1, 2):
			if dx == 0 and dz == 0:
				continue
			
			var neighbor = pos + Vector3(dx, 0, dz)
			if not contains_position(neighbor):
				return true
	
	return false

func _calculate_bounding_rect_from_points(points: PackedVector2Array) -> Rect2:
	"""从形状点计算边界矩形"""
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

func _get_default_color_for_type(_content_type: String) -> Color:
	"""根据内容类型获取默认颜色"""
	match _content_type:
		"FOREST":
			return Color(0.0, 0.8, 0.0, 0.6)
		"LAKE":
			return Color(0.0, 0.6, 1.0, 0.6)
		"CAVE":
			return Color(0.5, 0.3, 0.1, 0.6)
		"WASTELAND":
			return Color(0.8, 0.8, 0.0, 0.6)
		"ROOM_SYSTEM":
			return Color(0.0, 0.0, 1.0, 0.6)
		"MAZE_SYSTEM":
			return Color(0.5, 0.0, 0.5, 0.6)
		"DUNGEON_HEART":
			return Color(1.0, 0.0, 0.0, 0.8)
		_:
			return Color(0.5, 0.5, 0.5, 0.6)

# ============================================================================
# 调试和序列化
# ============================================================================

func to_dictionary() -> Dictionary:
	"""转换为字典格式（用于序列化）"""
	return {
		"id": id,
		"type": type,
		"content_type": content_type,
		"center": [center.x, center.y],
		"size": [size.x, size.y],
		"radius": radius,
		"positions": positions,
		"highlight_color": [highlight_color.r, highlight_color.g, highlight_color.b, highlight_color.a],
		"priority": priority,
		"area": area,
		"is_connected": is_connected_cavity,
		"is_excavated": is_excavated
	}

func from_dictionary(data: Dictionary) -> void:
	"""从字典格式加载（用于反序列化）"""
	id = data.get("id", "")
	type = data.get("type", "")
	content_type = data.get("content_type", "")
	
	var center_data = data.get("center", [0, 0])
	center = Vector2i(center_data[0], center_data[1])
	
	var size_data = data.get("size", [0, 0])
	size = Vector2i(size_data[0], size_data[1])
	
	radius = data.get("radius", 0)
	var positions_data = data.get("positions", [])
	if positions_data is Array[Vector3]:
		positions = positions_data
	else:
		positions = []
	
	var color_data = data.get("highlight_color", [1.0, 1.0, 1.0, 1.0])
	highlight_color = Color(color_data[0], color_data[1], color_data[2], color_data[3])
	
	priority = data.get("priority", 0)
	area = data.get("area", 0.0)
	is_connected_cavity = data.get("is_connected", true)
	is_excavated = data.get("is_excavated", false)

func get_debug_info() -> String:
	"""获取调试信息"""
	return "Cavity[%s]: type=%s, content=%s, positions=%d, center=%s, size=%s" % [
		id, type, content_type, positions.size(), center, size
	]
