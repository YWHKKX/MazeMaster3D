extends Node
class_name AdvancedRoomGenerator

## 🏠 高级房间生成器
## 基于教程库的先进算法，实现智能房间生成系统
## 集成 GridMap 系统、多层地板、智能连接等功能

# ============================================================================
# 节点引用
# ============================================================================

@onready var floor_map: GridMap
@onready var wall_map: GridMap
@onready var collision_polygon_3d: CollisionPolygon3D

# ============================================================================
# 配置参数
# ============================================================================

var min_floor_width: int = TileTypes.get_min_room_size()
var min_floor_height: int = TileTypes.get_min_room_size()
var max_floor_width: int = TileTypes.get_max_room_size()
var max_floor_height: int = TileTypes.get_max_room_size()
var max_overlap_floors: int = TileTypes.get_max_overlap_floors()

# ============================================================================
# 瓦片映射和方向
# ============================================================================

var tiles: Dictionary = TileTypes.get_room_tile_mapping()
var directions: Dictionary = TileTypes.get_directions()

# ============================================================================
# 房间数据
# ============================================================================

var rooms: Array = []
var room_counter: int = 0

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	"""初始化高级房间生成器"""
	LogManager.info("=== 高级房间生成器初始化开始 ===")
	
	# 创建必要的节点
	_setup_nodes()
	
	LogManager.info("=== 高级房间生成器初始化完成 ===")

func _setup_nodes():
	"""设置必要的节点"""
	# 创建地板网格地图
	floor_map = GridMap.new()
	floor_map.name = "FloorMap"
	add_child(floor_map)
	
	# 创建墙壁网格地图
	wall_map = GridMap.new()
	wall_map.name = "WallMap"
	add_child(wall_map)
	
	# 创建碰撞多边形
	collision_polygon_3d = CollisionPolygon3D.new()
	collision_polygon_3d.name = "CollisionPolygon3D"
	add_child(collision_polygon_3d)

# ============================================================================
# 房间生成主流程
# ============================================================================

func generate_rooms(config) -> Array:
	"""生成房间系统"""
	LogManager.info("开始生成高级房间系统...")
	
	# 清空现有房间
	rooms.clear()
	room_counter = 0
	
	# 生成房间数量
	var room_count = randi_range(8, config.max_room_count)
	var max_attempts = room_count * 30
	var successful_rooms = 0
	
	LogManager.info("目标生成 %d 个房间，最大尝试次数 %d" % [room_count, max_attempts])
	
	# 🔧 [安全] 添加超时机制，防止无限循环
	var start_time = Time.get_ticks_msec()
	var timeout_ms = 5000 # 5秒超时
	
	# 生成房间
	for i in range(max_attempts):
		# 检查超时
		if Time.get_ticks_msec() - start_time > timeout_ms:
			LogManager.warning("房间生成超时，已生成 %d 个房间" % successful_rooms)
			break
		if successful_rooms >= room_count:
			break
			
		var room = _create_advanced_room()
		if room:
			rooms.append(room)
			_generate_room_content(room)
			successful_rooms += 1
			
			if successful_rooms <= 5: # 只记录前5个房间
				LogManager.info("成功生成房间 #%d: 位置(%d,%d) 大小(%dx%d)" % [
					room.room_id, room.position.x, room.position.y, room.size.x, room.size.y
				])
		
		# 🔧 [安全] 防止无限循环：每100次尝试输出一次进度
		if i % 100 == 0 and i > 0:
			LogManager.info("房间生成进度: %d/%d 尝试，已成功 %d 个房间" % [i, max_attempts, successful_rooms])
	
	# 连接所有房间
	_connect_all_rooms()
	
	LogManager.info("高级房间系统生成完成: 成功生成 %d 个房间" % successful_rooms)
	return rooms

# ============================================================================
# 高级房间创建
# ============================================================================

func _create_advanced_room():
	"""创建高级房间"""
	var room = AdvancedRoom.new()
	room.room_id = room_counter
	room_counter += 1
	
	# 生成多层地板
	room.floors = _get_new_floor()
	
	# 计算房间边界
	room.position = _calculate_room_position(room.floors)
	room.size = _calculate_room_size(room.floors)
	room.center = room.position + room.size / 2
	
	return room

func _get_new_floor() -> Array:
	"""生成多层重叠地板"""
	var floors = []
	var floor_count = randi_range(2, max_overlap_floors)
	
	for _floor in floor_count:
		floors.append(_create_floor())
	
	return floors

func _create_floor() -> Rect2:
	"""创建单个地板区域"""
	var start_point_range = 3
	var start_point = Vector2(
		randi_range(-start_point_range, start_point_range),
		randi_range(-start_point_range, start_point_range)
	)
	var width = randi_range(min_floor_width, max_floor_width)
	var height = randi_range(min_floor_height, max_floor_height)
	
	return Rect2(start_point, Vector2(width, height))

func _calculate_room_position(floors: Array) -> Vector2i:
	"""计算房间位置（基于所有地板的最小边界）"""
	if floors.is_empty():
		return Vector2i.ZERO
	
	var min_x = floors[0].position.x
	var min_y = floors[0].position.y
	
	for floor in floors:
		min_x = min(min_x, floor.position.x)
		min_y = min(min_y, floor.position.y)
	
	return Vector2i(min_x, min_y)

func _calculate_room_size(floors: Array) -> Vector2i:
	"""计算房间大小（基于所有地板的最大边界）"""
	if floors.is_empty():
		return Vector2i(1, 1)
	
	var min_x = floors[0].position.x
	var min_y = floors[0].position.y
	var max_x = floors[0].position.x + floors[0].size.x
	var max_y = floors[0].position.y + floors[0].size.y
	
	for floor in floors:
		min_x = min(min_x, floor.position.x)
		min_y = min(min_y, floor.position.y)
		max_x = max(max_x, floor.position.x + floor.size.x)
		max_y = max(max_y, floor.position.y + floor.size.y)
	
	return Vector2i(max_x - min_x, max_y - min_y)

# ============================================================================
# 房间内容生成
# ============================================================================

func _generate_room_content(room):
	"""生成房间内容"""
	# 清空房间
	_clear_room()
	
	# 绘制地板
	_draw_floor(room.floors)
	
	# 创建墙壁轮廓
	_create_wall_outline()
	
	# 创建碰撞形状
	_create_collision_shape()

func _clear_room():
	"""清空房间"""
	if floor_map:
		floor_map.clear()
	if wall_map:
		wall_map.clear()

func _draw_floor(floors: Array):
	"""绘制多层地板"""
	for dungeon_floor: Rect2 in floors:
		for x in dungeon_floor.size.x:
			for z in dungeon_floor.size.y:
				var floor_position = Vector3(dungeon_floor.position.x + x, 0, dungeon_floor.position.y + z)
				floor_map.set_cell_item(floor_position, tiles["floor"])

func _create_wall_outline():
	"""创建智能墙壁轮廓"""
	var all_floor_tiles = floor_map.get_used_cells()
	
	for floor_position in all_floor_tiles:
		var neighbors = _get_neighbor_floors(floor_position)
		
		# 根据邻居情况决定墙壁类型
		if neighbors["top"] and neighbors["left"]:
			wall_map.set_cell_item(floor_position, tiles["cornerWall"], 16)
		elif neighbors["top"] and neighbors["right"]:
			wall_map.set_cell_item(floor_position, tiles["cornerWall"])
		elif neighbors["bottom"] and neighbors["left"]:
			wall_map.set_cell_item(floor_position, tiles["cornerWall"], 10)
		elif neighbors["bottom"] and neighbors["right"]:
			wall_map.set_cell_item(floor_position, tiles["cornerWall"], 22)
		elif neighbors["top"]:
			wall_map.set_cell_item(floor_position, tiles["normalWall"])
		elif neighbors["left"]:
			wall_map.set_cell_item(floor_position, tiles["normalWall"], 16)
		elif neighbors["bottom"]:
			wall_map.set_cell_item(floor_position, tiles["normalWall"])
		elif neighbors["right"]:
			wall_map.set_cell_item(floor_position, tiles["normalWall"], 16)
		elif not _has_floor(floor_position + directions["top"] + directions["left"]):
			wall_map.set_cell_item(floor_position, tiles["cornerWall"], 22)
		elif not _has_floor(floor_position + directions["top"] + directions["right"]):
			wall_map.set_cell_item(floor_position, tiles["cornerWall"], 10)
		elif not _has_floor(floor_position + directions["bottom"] + directions["left"]):
			wall_map.set_cell_item(floor_position, tiles["cornerWall"])
		elif not _has_floor(floor_position + directions["bottom"] + directions["right"]):
			wall_map.set_cell_item(floor_position, tiles["cornerWall"], 16)

func _get_neighbor_floors(position: Vector3i) -> Dictionary:
	"""获取邻居地板状态"""
	return {
		"top": not _has_floor(position + directions["top"]),
		"bottom": not _has_floor(position + directions["bottom"]),
		"left": not _has_floor(position + directions["left"]),
		"right": not _has_floor(position + directions["right"])
	}

func _has_floor(look_position: Vector3i) -> bool:
	"""检查指定位置是否有地板"""
	return look_position in floor_map.get_used_cells()

func _create_collision_shape():
	"""创建碰撞形状"""
	var collision_points = []
	var used_walls = wall_map.get_used_cells()
	
	# 收集角落墙壁点
	for wall_position in used_walls:
		var wall_number = wall_map.get_cell_item(wall_position)
		if wall_number == tiles["cornerWall"]:
			var wall_global_position = wall_map.map_to_local(wall_position)
			collision_points.append(Vector2(wall_global_position.x, wall_global_position.z))
	
	# 排序点以形成多边形
	var sorted_points = _get_sorted_points(collision_points)
	collision_polygon_3d.set_polygon(sorted_points)

func _get_sorted_points(list: Array) -> Array:
	"""排序点以形成多边形"""
	var sorted_list = []
	
	for i in list.size():
		if i == 0:
			sorted_list.append(list[i])
			continue
		
		var last_point = sorted_list[i - 1]
		var options = _get_next_move_options(list, sorted_list, last_point)
		
		var selected_point = _get_nearest_point(options, last_point)
		sorted_list.append(selected_point)
	
	return sorted_list

func _get_next_move_options(list: Array, sorted_list: Array, last_point: Vector2) -> Array:
	"""获取下一个移动选项"""
	var options = []
	
	for point in list:
		if point in sorted_list:
			continue
		
		var direction = (point - last_point).normalized() * 4
		
		var last_direction = Vector2.ZERO
		if sorted_list.size() > 1:
			last_direction = (sorted_list[-1] - sorted_list[-2]).normalized() * 4
		
		var allowed_direction = direction != last_direction and direction != -last_direction
		var same_axis = point.x == last_point.x or point.y == last_point.y
		
		if allowed_direction and same_axis:
			options.append(point)
	
	return options

func _get_nearest_point(list: Array, last_point: Vector2) -> Vector2:
	"""获取最近的点"""
	if list.is_empty():
		# 🔧 [修复] 如果列表为空，返回最后一个点的位置
		return last_point
	
	if list.size() == 1:
		return list[0]
	else:
		var selected_point: Vector2 = list[0] # 🔧 [修复] 初始化默认值
		var shortest_distance: float = list[0].distance_to(last_point) # 🔧 [修复] 初始化默认值
		
		for point in list:
			var distance = point.distance_to(last_point)
			
			if distance < shortest_distance:
				shortest_distance = distance
				selected_point = point
		
		return selected_point

# ============================================================================
# 房间连接系统
# ============================================================================

func _connect_all_rooms():
	"""连接所有房间"""
	if rooms.is_empty():
		return
	
	LogManager.info("开始连接房间...")
	
	# 确保所有房间都连接
	var connected_rooms = []
	var unconnected_rooms = rooms.duplicate()
	
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
	
	LogManager.info("房间连接完成")

func _try_connect_rooms(room1, room2) -> bool:
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

func _force_connect_room(room, target_room):
	"""强制连接房间"""
	var room1_center = room.center
	var room2_center = target_room.center
	
	# 创建从中心到中心的连接
	_mark_connection(room1_center, room2_center)
	
	room.connections.append(target_room.room_id)
	target_room.connections.append(room.room_id)

func _mark_connection(point1: Vector2i, point2: Vector2i):
	"""在地图上标记连接"""
	var current = point1
	var target = point2
	
	# 先垂直移动，再水平移动
	while current.y != target.y:
		_set_tile_type(Vector3(current.x, 0, current.y), TileTypes.TileType.CORRIDOR)
		if current.y < target.y:
			current.y += 1
		else:
			current.y -= 1
	
	while current.x != target.x:
		_set_tile_type(Vector3(current.x, 0, current.y), TileTypes.TileType.CORRIDOR)
		if current.x < target.x:
			current.x += 1
		else:
			current.x -= 1
	
	# 设置目标点
	_set_tile_type(Vector3(current.x, 0, current.y), TileTypes.TileType.CORRIDOR)

func _set_tile_type(position: Vector3, tile_type: int):
	"""设置地块类型"""
	# 这里需要与 TileManager 集成
	# 暂时使用 floor_map 进行测试
	floor_map.set_cell_item(position, tile_type)

# ============================================================================
# 工具函数
# ============================================================================

func get_used_rect(grid_map: GridMap) -> Rect2:
	"""获取网格地图的使用矩形"""
	var rect_position = Vector2.ZERO
	var rect_size = Vector2.ZERO
	
	var x_list: Array = []
	var z_list = []
	
	for tile_position in grid_map.get_used_cells():
		x_list.append(tile_position.x)
		z_list.append(tile_position.z)
	
	if x_list.is_empty():
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	
	rect_position = Vector2(x_list.min(), z_list.min())
	rect_size = Vector2(x_list.max() - rect_position.x + 1, z_list.max() - rect_position.y + 1)
	
	return Rect2(rect_position, rect_size)

func get_connection_point(direction: Vector3i) -> Dictionary:
	"""根据方向获取最佳连接点"""
	var rect = get_used_rect(floor_map)
	var all_cells = floor_map.get_used_cells()
	
	# 根据方向筛选边缘瓦片
	if direction == directions["right"]:
		var x = rect.position.x + rect.size.x - 1
		all_cells = all_cells.filter(func(element): return element.x == x)
	elif direction == directions["left"]:
		var x = rect.position.x
		all_cells = all_cells.filter(func(element): return element.x == x)
	elif direction == directions["bottom"]:
		var z = rect.position.y + rect.size.y - 1
		all_cells = all_cells.filter(func(element): return element.z == z)
	elif direction == directions["top"]:
		var z = rect.position.y
		all_cells = all_cells.filter(func(element): return element.z == z)
	
	# 过滤掉已有墙壁的位置
	all_cells = all_cells.filter(func(element):
		return wall_map.get_cell_item(element) != tiles["cornerWall"])
	
	if all_cells.is_empty():
		return {}
	
	# 随机选择一个连接点
	var selected_point = all_cells.pick_random()
	
	return {
		"map_point": selected_point,
		"global_position": floor_map.map_to_local(selected_point + direction)
	}
