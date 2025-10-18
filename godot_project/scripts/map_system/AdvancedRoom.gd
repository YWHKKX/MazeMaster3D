extends RefCounted
class_name AdvancedRoom

## 🏠 高级房间数据结构
## 支持多层地板、智能连接、墙壁轮廓等高级功能

# ============================================================================
# 基础属性
# ============================================================================

var position: Vector2i
var size: Vector2i
var center: Vector2i
var connections: Array = []
var room_id: int
var room_type: String = "normal"

# ============================================================================
# 高级属性
# ============================================================================

var floors: Array = [] # 支持多层地板
var connection_points: Array = [] # 预计算的连接点
var wall_outline: Array = [] # 墙壁轮廓

# ============================================================================
# 初始化
# ============================================================================

func _init(pos: Vector2i = Vector2i.ZERO, room_size: Vector2i = Vector2i(1, 1), id: int = 0):
	position = pos
	size = room_size
	center = pos + room_size / 2
	room_id = id

# ============================================================================
# 基础方法
# ============================================================================

func get_rect() -> Rect2i:
	"""获取房间矩形"""
	return Rect2i(position, size)

func overlaps(other_room) -> bool:
	"""检查是否与其他房间重叠"""
	var rect1 = get_rect()
	var rect2 = other_room.get_rect()
	return rect1.intersects(rect2)

func get_connection_points() -> Array:
	"""获取房间边缘的潜在连接点"""
	var points = []
	# 获取房间边缘的潜在连接点
	for x in range(position.x, position.x + size.x):
		points.append(Vector2i(x, position.y)) # 上边
		points.append(Vector2i(x, position.y + size.y - 1)) # 下边
	for y in range(position.y, position.y + size.y):
		points.append(Vector2i(position.x, y)) # 左边
		points.append(Vector2i(position.x + size.x - 1, y)) # 右边
	return points

# ============================================================================
# 高级方法
# ============================================================================

func get_overlapping_floors() -> Array:
	"""获取重叠的地板区域"""
	var overlapping = []
	
	for i in range(floors.size()):
		for j in range(i + 1, floors.size()):
			var floor1 = floors[i]
			var floor2 = floors[j]
			
			if floor1.intersects(floor2):
				var intersection = floor1.intersection(floor2)
				if intersection != Rect2(Vector2.ZERO, Vector2.ZERO):
					overlapping.append({
						"floor1_index": i,
						"floor2_index": j,
						"intersection": intersection
					})
	
	return overlapping

func get_connection_points_by_direction(direction: Vector3i) -> Array:
	"""根据方向获取连接点"""
	var points = []
	var directions = TileTypes.get_directions()
	
	if direction == directions["right"]:
		# 右边缘
		for y in range(position.y, position.y + size.y):
			points.append(Vector2i(position.x + size.x - 1, y))
	elif direction == directions["left"]:
		# 左边缘
		for y in range(position.y, position.y + size.y):
			points.append(Vector2i(position.x, y))
	elif direction == directions["bottom"]:
		# 底边缘
		for x in range(position.x, position.x + size.x):
			points.append(Vector2i(x, position.y + size.y - 1))
	elif direction == directions["top"]:
		# 顶边缘
		for x in range(position.x, position.x + size.x):
			points.append(Vector2i(x, position.y))
	
	return points

func create_door(connection_point: Vector3i, direction: Vector3i):
	"""创建门道"""
	# 这个方法将在房间生成器中实现
	# 这里只是接口定义
	pass

func calculate_total_floor_area() -> int:
	"""计算总地板面积（考虑重叠）"""
	if floors.is_empty():
		return size.x * size.y
	
	var total_area = 0
	var covered_positions = {}
	
	for floor in floors:
		var floor_rect = floor
		for x in range(floor_rect.position.x, floor_rect.position.x + floor_rect.size.x):
			for y in range(floor_rect.position.y, floor_rect.position.y + floor_rect.size.y):
				var pos_key = Vector2i(x, y)
				if not pos_key in covered_positions:
					covered_positions[pos_key] = true
					total_area += 1
	
	return total_area

func get_floor_density() -> float:
	"""获取地板密度（实际地板面积 / 房间总面积）"""
	var total_area = size.x * size.y
	if total_area == 0:
		return 0.0
	
	var actual_floor_area = calculate_total_floor_area()
	return float(actual_floor_area) / float(total_area)

func is_complex_room() -> bool:
	"""判断是否为复杂房间（有多层地板）"""
	return floors.size() > 1

func get_room_complexity() -> int:
	"""获取房间复杂度（地板数量）"""
	return floors.size()

func add_floor(floor_rect: Rect2):
	"""添加地板"""
	floors.append(floor_rect)
	_update_room_bounds()

func remove_floor(index: int):
	"""移除地板"""
	if index >= 0 and index < floors.size():
		floors.remove_at(index)
		_update_room_bounds()

func _update_room_bounds():
	"""更新房间边界"""
	if floors.is_empty():
		return
	
	var min_x = floors[0].position.x
	var min_y = floors[0].position.y
	var max_x = floors[0].position.x + floors[0].size.x
	var max_y = floors[0].position.y + floors[0].size.y
	
	for floor in floors:
		min_x = min(min_x, floor.position.x)
		min_y = min(min_y, floor.position.y)
		max_x = max(max_x, floor.position.x + floor.size.x)
		max_y = max(max_y, floor.position.y + floor.size.y)
	
	position = Vector2i(min_x, min_y)
	size = Vector2i(max_x - min_x, max_y - min_y)
	center = position + size / 2

# ============================================================================
# 调试和日志
# ============================================================================

func get_debug_info() -> String:
	"""获取调试信息"""
	var info = "房间 #%d:\n" % room_id
	info += "  位置: (%d, %d)\n" % [position.x, position.y]
	info += "  大小: %dx%d\n" % [size.x, size.y]
	info += "  中心: (%d, %d)\n" % [center.x, center.y]
	info += "  地板数量: %d\n" % floors.size()
	info += "  连接数量: %d\n" % connections.size()
	info += "  地板密度: %.2f\n" % get_floor_density()
	info += "  复杂度: %d\n" % get_room_complexity()
	
	if floors.size() > 0:
		info += "  地板详情:\n"
		for i in range(floors.size()):
			var floor = floors[i]
			info += "    地板 %d: 位置(%d,%d) 大小(%dx%d)\n" % [
				i, floor.position.x, floor.position.y, floor.size.x, floor.size.y
			]
	
	return info

func log_debug_info():
	"""输出调试信息"""
	LogManager.info(get_debug_info())

# ============================================================================
# 序列化和反序列化
# ============================================================================

func to_dict() -> Dictionary:
	"""转换为字典"""
	return {
		"position": {"x": position.x, "y": position.y},
		"size": {"x": size.x, "y": size.y},
		"center": {"x": center.x, "y": center.y},
		"connections": connections,
		"room_id": room_id,
		"room_type": room_type,
		"floors": floors.map(func(floor): return {
			"position": {"x": floor.position.x, "y": floor.position.y},
			"size": {"x": floor.size.x, "y": floor.size.y}
		})
	}

func from_dict(data: Dictionary):
	"""从字典恢复"""
	position = Vector2i(data.position.x, data.position.y)
	size = Vector2i(data.size.x, data.size.y)
	center = Vector2i(data.center.x, data.center.y)
	connections = data.connections
	room_id = data.room_id
	room_type = data.room_type
	
	floors.clear()
	for floor_data in data.floors:
		var floor = Rect2(
			Vector2(floor_data.position.x, floor_data.position.y),
			Vector2(floor_data.size.x, floor_data.size.y)
		)
		floors.append(floor)
