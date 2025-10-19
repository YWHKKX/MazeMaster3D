class_name SimpleRoomGenerator
extends Node

## 🏠 简化房间生成器
## 基于洪水填充的空洞约束，生成矩形房间系统

# ============================================================================
# 服务引用
# ============================================================================

var tile_manager: Node
var flood_fill_system: FloodFillSystem

# ============================================================================
# 配置参数
# ============================================================================

var min_room_size: Vector2i = Vector2i(4, 4)
var max_room_size: Vector2i = Vector2i(12, 12)
var min_room_area: int = 16
var max_rooms_per_cavity: int = 5

# ============================================================================
# 房间数据
# ============================================================================

var rooms: Array[SimpleRoom] = []
var room_counter: int = 0

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	"""初始化房间生成器"""
	name = "SimpleRoomGenerator"
	LogManager.info("SimpleRoomGenerator - 初始化完成")

func set_tile_manager(manager: Node) -> void:
	"""设置瓦片管理器"""
	tile_manager = manager
	LogManager.info("SimpleRoomGenerator - 瓦片管理器已设置")

func set_flood_fill_system(system: FloodFillSystem) -> void:
	"""设置洪水填充系统"""
	flood_fill_system = system
	LogManager.info("SimpleRoomGenerator - 洪水填充系统已设置")

# ============================================================================
# 主要生成方法
# ============================================================================

func generate_rooms_in_cavity(cavity) -> Array[SimpleRoom]:
	"""在空洞内生成简化房间 - 基于流程图的完整实现"""
	LogManager.info("=== 开始生成空洞 %s 的房间系统 ===" % cavity.id)
	
	# 清空全局房间列表（每次生成新房间时）
	rooms.clear()
	
	# 保存当前房间计数器
	var original_counter = room_counter
	
	# 步骤1: 洪水填充标记空洞区域
	var generation_areas = flood_fill_system.flood_fill_room_generation_areas(cavity, tile_manager)
	if generation_areas.is_empty():
		LogManager.warning("空洞 %s 内没有有效的房间生成区域" % cavity.id)
		return []
	
	# 步骤2: 为每个空洞动态规划房间
	_adjust_room_parameters_for_cavity(cavity)
	
	# 步骤3: 生成房间和走廊（不包含开口）
	var cavity_rooms: Array[SimpleRoom] = []
	var successful_rooms = _generate_rooms_and_corridors(generation_areas, cavity, cavity_rooms)
	
	# 步骤4: 生成内部结构（不包含开口）
	_add_room_internal_structures(cavity_rooms)
	
	# 步骤5: 统一生成开口
	_generate_unified_exits(cavity_rooms)
	
	LogManager.info("=== 空洞 %s 房间系统生成完成: 成功生成 %d 个房间 ===" % [cavity.id, successful_rooms])
	
	# 恢复房间计数器
	room_counter = original_counter
	
	return cavity_rooms

func _adjust_room_parameters_for_cavity(cavity) -> void:
	"""根据空洞大小动态调整房间参数"""
	var cavity_size = cavity.positions.size()
	
	# 根据空洞大小调整房间大小范围
	if cavity_size < 100:
		min_room_size = Vector2i(2, 2)
		max_room_size = Vector2i(4, 4)
		max_rooms_per_cavity = 2
	elif cavity_size < 200:
		min_room_size = Vector2i(2, 2)
		max_room_size = Vector2i(5, 5)
		max_rooms_per_cavity = 3
	elif cavity_size < 400:
		min_room_size = Vector2i(3, 3)
		max_room_size = Vector2i(6, 6)
		max_rooms_per_cavity = 4
	elif cavity_size < 600:
		min_room_size = Vector2i(3, 3)
		max_room_size = Vector2i(7, 7)
		max_rooms_per_cavity = 5
	else:
		min_room_size = Vector2i(4, 4)
		max_room_size = Vector2i(8, 8)
		max_rooms_per_cavity = 6
	
	LogManager.info("根据空洞大小调整参数: 房间大小 %dx%d 到 %dx%d, 最大房间数 %d" % [
		min_room_size.x, min_room_size.y, max_room_size.x, max_room_size.y, max_rooms_per_cavity
	])

func _generate_rooms_and_corridors(_generation_areas: Array, cavity, cavity_rooms: Array[SimpleRoom]) -> int:
	"""生成房间和走廊（不包含开口）"""
	LogManager.info("开始基于中心辐射的房间生成...")
	
	# 计算空洞中心
	var cavity_center = _calculate_cavity_center(cavity)
	
	# 创建主房间
	var main_room = _create_main_room_at_center(cavity_center, cavity)
	if main_room == null:
		LogManager.warning("无法在空洞中心创建主房间")
		return 0
	
	cavity_rooms.append(main_room)
	
	# 围绕主房间扩展
	var expansion_rooms = _expand_around_main_room(main_room, cavity, cavity_rooms)
	cavity_rooms.append_array(expansion_rooms)
	
	# 生成走廊连接所有房间
	_generate_corridors_for_rooms(cavity_rooms)
	
	# 将空洞内的房间添加到全局房间列表
	rooms.append_array(cavity_rooms)
	
	return cavity_rooms.size()

func _generate_corridors_for_rooms(rooms: Array[SimpleRoom]) -> void:
	"""为房间生成走廊连接"""
	if rooms.size() <= 1:
		return
	
	# 生成走廊连接房间
	
	# 以主房间为中心，连接所有其他房间
	var main_room = rooms[0]
	
	for i in range(1, rooms.size()):
		var target_room = rooms[i]
		_create_corridor_connection(main_room, target_room)
	
	LogManager.info("走廊生成完成")

func _add_room_internal_structures(rooms: Array[SimpleRoom]) -> void:
	"""为房间添加内部结构（不包含开口）"""
	LogManager.info("开始为 %d 个房间添加内部特征..." % rooms.size())
	
	for room in rooms:
		# 添加内部墙壁
		_add_internal_walls(room)
		
		# 添加破旧地板效果
		_add_floor_damage(room)
	
	LogManager.info("房间内部特征添加完成")

func _generate_unified_exits(rooms: Array[SimpleRoom]) -> void:
	"""统一生成房间开口 - 优化连通性"""
	LogManager.info("开始统一生成 %d 个房间的开口..." % rooms.size())
	
	# 第一步：为相邻房间创建共用出口
	_create_shared_exits_for_adjacent_rooms(rooms)
	
	# 第二步：为孤立房间添加必要出口
	_add_necessary_exits_for_isolated_rooms(rooms)
	
	# 第三步：确保整体连通性
	_ensure_overall_connectivity(rooms)
	
	LogManager.info("开口生成完成")

func _create_shared_exits_for_adjacent_rooms(rooms: Array[SimpleRoom]) -> void:
	"""为相邻房间创建共用出口 - 限制每个房间最多1个出口"""
	LogManager.info("为相邻房间创建共用出口...")
	
	var processed_rooms: Array[int] = []
	
	for i in range(rooms.size()):
		var room1 = rooms[i]
		
		# 如果房间已经有出口，跳过
		if room1.exits.size() > 0 or processed_rooms.has(room1.room_id):
			continue
		
		# 寻找第一个相邻的房间
		for j in range(i + 1, rooms.size()):
			var room2 = rooms[j]
			
			# 如果房间已经有出口，跳过
			if room2.exits.size() > 0 or processed_rooms.has(room2.room_id):
				continue
			
			# 检查是否相邻
			if _are_rooms_adjacent(room1, room2):
				# 找到共用墙壁位置
				var shared_wall_pos = _find_shared_wall_position(room1, room2)
				if shared_wall_pos != Vector2i(-1, -1):
					# 创建共用出口
					room1.add_exit(shared_wall_pos)
					room2.add_exit(shared_wall_pos)
					
					# 记录连接关系
					room1.connect_to_room(room2.room_id)
					room2.connect_to_room(room1.room_id)
					
					# 标记为已处理
					processed_rooms.append(room1.room_id)
					processed_rooms.append(room2.room_id)
					
					LogManager.info("创建共用出口: 房间 %d 和 %d 在位置 (%d,%d)" % [room1.room_id, room2.room_id, shared_wall_pos.x, shared_wall_pos.y])
					break # 每个房间只创建一个出口

func _find_shared_wall_position(room1: SimpleRoom, room2: SimpleRoom) -> Vector2i:
	"""找到两个相邻房间的共用墙壁位置 - 调用统一的墙壁查找逻辑"""
	return _find_wall_position(room1, room2, "shared")

func _add_necessary_exits_for_isolated_rooms(rooms: Array[SimpleRoom]) -> void:
	"""为孤立房间添加必要出口"""
	LogManager.info("为孤立房间添加必要出口...")
	
	for room in rooms:
		# 如果房间没有出口，添加一个
		if room.exits.is_empty():
			var exit_pos = _find_best_exit_position(room)
			if exit_pos != Vector2i(-1, -1):
				room.add_exit(exit_pos)
				LogManager.info("为孤立房间 %d 添加出口: (%d,%d)" % [room.room_id, exit_pos.x, exit_pos.y])

func _find_best_exit_position(room: SimpleRoom) -> Vector2i:
	"""为房间找到最佳出口位置"""
	var rect = room.get_rect()
	var cavity_positions = room.cavity_positions
	
	# 尝试四个边的中心位置
	var candidates = [
		Vector2i(rect.position.x + rect.size.x / 2, rect.position.y - 1), # 上边
		Vector2i(rect.position.x + rect.size.x, rect.position.y + rect.size.y / 2), # 右边
		Vector2i(rect.position.x + rect.size.x / 2, rect.position.y + rect.size.y), # 下边
		Vector2i(rect.position.x - 1, rect.position.y + rect.size.y / 2) # 左边
	]
	
	# 选择第一个在空洞内的位置
	for pos in candidates:
		var world_pos = Vector3(pos.x, 0, pos.y)
		if cavity_positions.has(world_pos):
			return pos
	
	return Vector2i(-1, -1)

func _ensure_overall_connectivity(rooms: Array[SimpleRoom]) -> void:
	"""确保整体连通性 - 调用统一的连通性检查逻辑"""
	LogManager.info("确保整体连通性...")
	_ensure_connectivity(rooms)

func _generate_room_exits(room: SimpleRoom) -> void:
	"""为单个房间生成开口 - 调用统一的出口生成逻辑"""
	_add_room_exits(room)

func _ensure_room_connectivity(rooms: Array[SimpleRoom]) -> void:
	"""确保所有房间都连通"""
	if rooms.size() <= 1:
		return
	
	# 使用BFS检查连通性
	var visited: Array[bool] = []
	visited.resize(rooms.size())
	visited.fill(false)
	
	var queue: Array[int] = [0] # 从主房间开始
	visited[0] = true
	
	while not queue.is_empty():
		var current_room_id = queue.pop_front()
		var current_room = rooms[current_room_id]
		
		# 检查所有其他房间
		for i in range(rooms.size()):
			if visited[i]:
				continue
			
			var other_room = rooms[i]
			
			# 如果两个房间相邻，创建门连接
			if _are_rooms_adjacent(current_room, other_room):
				_create_door_connection(current_room, other_room)
				visited[i] = true
				queue.append(i)
			# 如果不相邻，创建走廊连接
			elif not _are_rooms_connected(current_room, other_room):
				_create_corridor_connection(current_room, other_room)
				visited[i] = true
				queue.append(i)

func _are_rooms_adjacent(room1: SimpleRoom, room2: SimpleRoom) -> bool:
	"""检查两个房间是否相邻"""
	var rect1 = room1.get_rect()
	var rect2 = room2.get_rect()
	
	# 检查是否在相邻位置（包括对角线）
	return (abs(rect1.position.x - rect2.position.x) <= rect1.size.x + 1 and
			abs(rect1.position.y - rect2.position.y) <= rect1.size.y + 1)

func _are_rooms_connected(room1: SimpleRoom, room2: SimpleRoom) -> bool:
	"""检查两个房间是否已经连接"""
	return room1.is_connected_to(room2.room_id) or room2.is_connected_to(room1.room_id)

func _create_door_connection(room1: SimpleRoom, room2: SimpleRoom) -> void:
	"""创建门连接两个相邻房间"""
	# 找到相邻的墙壁位置
	var connection_point = _find_adjacent_wall(room1, room2)
	if connection_point != Vector2i(-1, -1):
		# 在连接点创建门（EMPTY）
		var world_pos = Vector3(connection_point.x, 0, connection_point.y)
		tile_manager.set_tile_type(world_pos, TileTypes.TileType.EMPTY)
		
		# 记录连接关系
		room1.connect_to_room(room2.room_id)
		room2.connect_to_room(room1.room_id)
		
		LogManager.info("创建门连接房间 %d 和 %d 在位置 (%d,%d)" % [room1.room_id, room2.room_id, connection_point.x, connection_point.y])

func _find_adjacent_wall(room1: SimpleRoom, room2: SimpleRoom) -> Vector2i:
	"""找到两个相邻房间之间的墙壁位置 - 调用统一的墙壁查找逻辑"""
	return _find_wall_position(room1, room2, "adjacent")

func _find_wall_position(room1: SimpleRoom, room2: SimpleRoom, _wall_type: String = "shared") -> Vector2i:
	"""统一的墙壁位置查找逻辑"""
	var rect1 = room1.get_rect()
	var rect2 = room2.get_rect()
	
	# 检查各种相邻情况
	if rect1.position.x + rect1.size.x == rect2.position.x: # room1在room2左边
		var y = max(rect1.position.y, rect2.position.y)
		var max_y = min(rect1.position.y + rect1.size.y, rect2.position.y + rect2.size.y)
		if y < max_y:
			return Vector2i(rect1.position.x + rect1.size.x, (y + max_y) / 2)
	
	elif rect2.position.x + rect2.size.x == rect1.position.x: # room2在room1左边
		var y = max(rect1.position.y, rect2.position.y)
		var max_y = min(rect1.position.y + rect1.size.y, rect2.position.y + rect2.size.y)
		if y < max_y:
			return Vector2i(rect2.position.x + rect2.size.x, (y + max_y) / 2)
	
	elif rect1.position.y + rect1.size.y == rect2.position.y: # room1在room2上边
		var x = max(rect1.position.x, rect2.position.x)
		var max_x = min(rect1.position.x + rect1.size.x, rect2.position.x + rect2.size.x)
		if x < max_x:
			return Vector2i((x + max_x) / 2, rect1.position.y + rect1.size.y)
	
	elif rect2.position.y + rect2.size.y == rect1.position.y: # room2在room1上边
		var x = max(rect1.position.x, rect2.position.x)
		var max_x = min(rect1.position.x + rect1.size.x, rect2.position.x + rect2.size.x)
		if x < max_x:
			return Vector2i((x + max_x) / 2, rect2.position.y + rect2.size.y)
	
	return Vector2i(-1, -1) # 没有找到相邻位置

# 旧函数已删除 - 使用 _generate_rooms_and_corridors() 替代

# ============================================================================
# 中心辐射房间生成算法
# ============================================================================

func _calculate_cavity_center(cavity) -> Vector2i:
	"""计算空洞中心点"""
	if cavity.positions.is_empty():
		return Vector2i.ZERO
	
	var min_x = cavity.positions[0].x
	var max_x = cavity.positions[0].x
	var min_z = cavity.positions[0].z
	var max_z = cavity.positions[0].z
	
	for pos in cavity.positions:
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_z = min(min_z, pos.z)
		max_z = max(max_z, pos.z)
	
	return Vector2i((min_x + max_x) / 2, (min_z + max_z) / 2)

func _create_main_room_at_center(center: Vector2i, cavity) -> SimpleRoom:
	"""在空洞中心创建主房间"""
	# 根据空洞大小确定主房间大小
	var cavity_size = cavity.positions.size()
	var main_room_size: Vector2i
	
	if cavity_size < 200:
		main_room_size = Vector2i(6, 6)
	elif cavity_size < 400:
		main_room_size = Vector2i(8, 8)
	elif cavity_size < 600:
		main_room_size = Vector2i(10, 10)
	else:
		main_room_size = Vector2i(12, 12)
	
	# 尝试在中心创建房间
	var room = _try_create_room_at_position(center, main_room_size, cavity)
	if room:
		return room
	
	# 如果中心失败，尝试在中心附近寻找合适位置
	var search_radius = 3
	for radius in range(1, search_radius + 1):
		for dx in range(-radius, radius + 1):
			for dz in range(-radius, radius + 1):
				if abs(dx) == radius or abs(dz) == radius: # 只检查边界
					var test_pos = center + Vector2i(dx, dz)
					room = _try_create_room_at_position(test_pos, main_room_size, cavity)
					if room:
						return room
	
	return null

func _try_create_room_at_position(pos: Vector2i, size: Vector2i, cavity) -> SimpleRoom:
	"""在指定位置尝试创建房间"""
	# 计算房间边界（pos已经是左上角位置）
	var room_rect = Rect2i(pos, size)
	
	# 检查房间是否完全在空洞内
	if not _is_room_rect_in_cavity(room_rect, cavity):
		return null
	
	# 创建房间
	var room = SimpleRoom.new()
	room.room_id = room_counter
	room_counter += 1
	room.position = room_rect.position
	room.size = room_rect.size
	room.center = room.position + room.size / 2
	room.cavity_positions = cavity.positions
	
	# 添加出口
	_add_room_exits(room)
	
	return room

func _is_room_rect_in_cavity(rect: Rect2i, cavity) -> bool:
	"""检查房间矩形是否部分在空洞内（至少有一部分在空洞中）"""
	var cavity_positions = cavity.positions
	var total_tiles = rect.size.x * rect.size.y
	var cavity_tiles = 0
	
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			var pos = Vector3(x, 0, y)
			if cavity_positions.has(pos):
				cavity_tiles += 1
	
	# 至少要有50%的区域在空洞内才算合理
	var overlap_ratio = float(cavity_tiles) / float(total_tiles)
	return overlap_ratio >= 0.5

func _expand_around_main_room(main_room: SimpleRoom, cavity, existing_rooms: Array[SimpleRoom]) -> Array[SimpleRoom]:
	"""围绕主房间向四个边缘方向扩展"""
	var expansion_rooms: Array[SimpleRoom] = []
	var directions = [
		Vector2i(1, 0), # 右
		Vector2i(-1, 0), # 左
		Vector2i(0, 1), # 下
		Vector2i(0, -1) # 上
	]
	
	LogManager.info("开始围绕主房间扩展: 主房间位置(%d,%d) 大小(%dx%d)" % [
		main_room.position.x, main_room.position.y, main_room.size.x, main_room.size.y
	])
	
	# 为每个边缘方向尝试扩展
	for i in range(directions.size()):
		var direction = directions[i]
		# 尝试边缘方向
		
		# 智能选择扩展类型：房间或走廊
		var expansion_result = _try_expand_from_edge(main_room, direction, cavity, existing_rooms + expansion_rooms)
		if expansion_result:
			expansion_rooms.append(expansion_result)
			var type_name = "房间" if expansion_result.room_type == "normal" else "走廊"
			LogManager.info("扩展%s #%d: 位置(%d,%d) 大小(%dx%d) 方向(%d,%d)" % [
				type_name, expansion_result.room_id, expansion_result.position.x, expansion_result.position.y,
				expansion_result.size.x, expansion_result.size.y, direction.x, direction.y
			])
		# 扩展失败
	
	LogManager.info("扩展完成: 成功 %d 个扩展" % expansion_rooms.size())
	return expansion_rooms

func _try_expand_from_edge(main_room: SimpleRoom, direction: Vector2i, cavity, existing_rooms: Array[SimpleRoom]) -> SimpleRoom:
	"""从主房间边缘智能扩展（房间或走廊）"""
	# 分析扩展位置的空间情况
	var available_space = _analyze_edge_space(main_room, direction, cavity)
	
	if available_space.is_empty():
		return null
	
	# 根据可用空间决定扩展类型
	var should_create_room = _should_create_room_in_space(available_space, direction)
	
	if should_create_room:
		return _create_room_from_edge(main_room, direction, cavity, existing_rooms)
	else:
		return _create_corridor_from_edge(main_room, direction, cavity, existing_rooms)

func _analyze_edge_space(main_room: SimpleRoom, direction: Vector2i, cavity) -> Dictionary:
	"""分析边缘方向的可用空间"""
	var rect = main_room.get_rect()
	var cavity_positions = cavity.positions
	var available_positions: Array[Vector3] = []
	
	# 根据方向分析边缘外的空间
	if direction.x > 0: # 右边
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			var check_pos = Vector3(rect.position.x + rect.size.x + 1, 0, y)
			if cavity_positions.has(check_pos):
				available_positions.append(check_pos)
	elif direction.x < 0: # 左边
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			var check_pos = Vector3(rect.position.x - 1, 0, y)
			if cavity_positions.has(check_pos):
				available_positions.append(check_pos)
	elif direction.y > 0: # 下边
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			var check_pos = Vector3(x, 0, rect.position.y + rect.size.y + 1)
			if cavity_positions.has(check_pos):
				available_positions.append(check_pos)
	elif direction.y < 0: # 上边
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			var check_pos = Vector3(x, 0, rect.position.y - 1)
			if cavity_positions.has(check_pos):
				available_positions.append(check_pos)
	
	return {
		"positions": available_positions,
		"count": available_positions.size(),
		"direction": direction
	}

func _should_create_room_in_space(space_info: Dictionary, direction: Vector2i) -> bool:
	"""根据空间情况决定是否创建房间"""
	var available_count = space_info.count
	
	# 如果可用空间太少，创建走廊
	if available_count < 4:
		return false
	
	# 如果可用空间充足，创建房间
	if available_count >= 12:
		return true
	
	# 中等空间，根据方向决定
	# 水平方向更容易创建房间
	if direction.x != 0:
		return available_count >= 8
	else:
		return available_count >= 6

func _create_room_from_edge(main_room: SimpleRoom, direction: Vector2i, cavity, existing_rooms: Array[SimpleRoom]) -> SimpleRoom:
	"""从边缘创建房间"""
	var rect = main_room.get_rect()
	
	# 随机确定房间大小
	var room_size = Vector2i(
		randi_range(min_room_size.x, min(max_room_size.x, 8)),
		randi_range(min_room_size.y, min(max_room_size.y, 8))
	)
	
	# 计算房间位置（与主房间相邻）
	var room_pos: Vector2i
	
	if direction.x > 0: # 右边
		room_pos.x = rect.position.x + rect.size.x
		var max_y_offset = max(0, rect.size.y - room_size.y)
		room_pos.y = rect.position.y + randi_range(0, max_y_offset)
	elif direction.x < 0: # 左边
		room_pos.x = rect.position.x - room_size.x
		var max_y_offset = max(0, rect.size.y - room_size.y)
		room_pos.y = rect.position.y + randi_range(0, max_y_offset)
	elif direction.y > 0: # 下边
		var max_x_offset = max(0, rect.size.x - room_size.x)
		room_pos.x = rect.position.x + randi_range(0, max_x_offset)
		room_pos.y = rect.position.y + rect.size.y
	elif direction.y < 0: # 上边
		var max_x_offset = max(0, rect.size.x - room_size.x)
		room_pos.x = rect.position.x + randi_range(0, max_x_offset)
		room_pos.y = rect.position.y - room_size.y
	
	# 创建房间
	var room = _try_create_room_at_position(room_pos, room_size, cavity)
	if room and _is_room_not_overlapping(room, existing_rooms):
		room.room_type = "normal"
		return room
	
	return null

func _create_corridor_from_edge(main_room: SimpleRoom, direction: Vector2i, cavity, existing_rooms: Array[SimpleRoom]) -> SimpleRoom:
	"""从边缘创建走廊"""
	var rect = main_room.get_rect()
	
	# 走廊大小：长条形
	var corridor_size: Vector2i
	var corridor_pos: Vector2i
	
	if direction.x != 0: # 水平走廊
		corridor_size = Vector2i(randi_range(3, 8), 1)
		corridor_pos.x = rect.position.x + rect.size.x if direction.x > 0 else rect.position.x - corridor_size.x
		corridor_pos.y = rect.position.y + randi_range(0, rect.size.y - 1)
	else: # 垂直走廊
		corridor_size = Vector2i(1, randi_range(3, 8))
		corridor_pos.x = rect.position.x + randi_range(0, rect.size.x - 1)
		corridor_pos.y = rect.position.y + rect.size.y if direction.y > 0 else rect.position.y - corridor_size.y
	
	# 创建走廊
	var corridor = _try_create_room_at_position(corridor_pos, corridor_size, cavity)
	if corridor and _is_room_not_overlapping(corridor, existing_rooms):
		corridor.room_type = "corridor"
		return corridor
	
	return null

func _try_expand_in_direction(main_room: SimpleRoom, direction: Vector2i, cavity, existing_rooms: Array[SimpleRoom]) -> SimpleRoom:
	"""在指定方向尝试扩展房间"""
	# 随机确定扩展房间大小
	var expansion_size = Vector2i(
		randi_range(min_room_size.x, min(max_room_size.x, 8)),
		randi_range(min_room_size.y, min(max_room_size.y, 8))
	)
	
	# 计算扩展位置（与主房间相邻）
	var expansion_pos: Vector2i
	
	# 调整位置以确保与主房间相邻
	if direction.x > 0: # 向右
		expansion_pos.x = main_room.position.x + main_room.size.x
		var max_y_offset = max(0, main_room.size.y - expansion_size.y)
		expansion_pos.y = main_room.position.y + randi_range(0, max_y_offset)
	elif direction.x < 0: # 向左
		expansion_pos.x = main_room.position.x - expansion_size.x
		var max_y_offset = max(0, main_room.size.y - expansion_size.y)
		expansion_pos.y = main_room.position.y + randi_range(0, max_y_offset)
	elif direction.y > 0: # 向下
		var max_x_offset = max(0, main_room.size.x - expansion_size.x)
		expansion_pos.x = main_room.position.x + randi_range(0, max_x_offset)
		expansion_pos.y = main_room.position.y + main_room.size.y
	elif direction.y < 0: # 向上
		var max_x_offset = max(0, main_room.size.x - expansion_size.x)
		expansion_pos.x = main_room.position.x + randi_range(0, max_x_offset)
		expansion_pos.y = main_room.position.y - expansion_size.y
	else:
		# 斜向扩展 - 需要更精确的位置计算
		if direction.x > 0 and direction.y > 0: # 右下
			expansion_pos.x = main_room.position.x + main_room.size.x
			expansion_pos.y = main_room.position.y + main_room.size.y
		elif direction.x < 0 and direction.y > 0: # 左下
			expansion_pos.x = main_room.position.x - expansion_size.x
			expansion_pos.y = main_room.position.y + main_room.size.y
		elif direction.x > 0 and direction.y < 0: # 右上
			expansion_pos.x = main_room.position.x + main_room.size.x
			expansion_pos.y = main_room.position.y - expansion_size.y
		elif direction.x < 0 and direction.y < 0: # 左上
			expansion_pos.x = main_room.position.x - expansion_size.x
			expansion_pos.y = main_room.position.y - expansion_size.y
	
	# 尝试创建扩展房间
	var room = _try_create_room_at_position(expansion_pos, expansion_size, cavity)
	if not room or not _is_room_not_overlapping(room, existing_rooms):
		return null
	
	return room

# 旧函数已删除 - 使用中心辐射算法替代

# 旧函数已删除 - 使用 _is_room_rect_in_cavity() 替代

func _is_room_not_overlapping(room: SimpleRoom, existing_rooms: Array[SimpleRoom]) -> bool:
	"""检查房间是否与现有房间重叠"""
	var room_rect = room.get_rect()
	
	for existing_room in existing_rooms:
		var existing_rect = existing_room.get_rect()
		if room_rect.intersects(existing_rect):
			return false
	
	return true

func _add_room_exits(room: SimpleRoom) -> void:
	"""为房间添加出口"""
	var rect = room.get_rect()
	
	# 确保房间至少有一个出口
	var exit_count = 1
	# 大房间可以有2个出口
	if room.size.x >= 5 or room.size.y >= 5:
		if randi() % 3 == 0: # 33%概率添加第二个出口
			exit_count = 2
	
	var used_sides: Array[int] = []
	
	for i in range(exit_count):
		var side: int
		var attempts = 0
		
		# 避免在同一侧添加多个出口
		side = randi() % 4 # 0=上, 1=右, 2=下, 3=左
		while used_sides.has(side) and attempts < 10:
			side = randi() % 4
			attempts += 1
		
		used_sides.append(side)
		var exit_pos: Vector2i
		
		match side:
			0: # 上边
				exit_pos = Vector2i(
					randi_range(rect.position.x + 1, rect.position.x + rect.size.x - 2),
					rect.position.y - 1
				)
			1: # 右边
				exit_pos = Vector2i(
					rect.position.x + rect.size.x,
					randi_range(rect.position.y + 1, rect.position.y + rect.size.y - 2)
				)
			2: # 下边
				exit_pos = Vector2i(
					randi_range(rect.position.x + 1, rect.position.x + rect.size.x - 2),
					rect.position.y + rect.size.y
				)
			3: # 左边
				exit_pos = Vector2i(
					rect.position.x - 1,
					randi_range(rect.position.y + 1, rect.position.y + rect.size.y - 2)
				)
		
		room.add_exit(exit_pos)

# ============================================================================
# 房间内部布局系统
# ============================================================================

# 旧函数已删除 - 使用 _add_room_internal_structures() 替代

# 旧函数已删除 - 使用 _add_room_internal_structures() 替代

func _add_internal_walls(room: SimpleRoom) -> void:
	"""添加内部墙壁分割"""
	var rect = room.get_rect()
	
	# 随机选择分割方式
	var split_type = randi() % 3
	
	match split_type:
		0: # 垂直分割
			if room.size.x > 8:
				var split_x = rect.position.x + room.size.x / 2
				for y in range(rect.position.y + 1, rect.position.y + room.size.y - 1):
					if randi() % 3 != 0: # 66% 概率放置墙壁
						room.add_internal_wall(Vector2i(split_x, y))
		
		1: # 水平分割
			if room.size.y > 8:
				var split_y = rect.position.y + room.size.y / 2
				for x in range(rect.position.x + 1, rect.position.x + room.size.x - 1):
					if randi() % 3 != 0: # 66% 概率放置墙壁
						room.add_internal_wall(Vector2i(x, split_y))
		
		2: # L型分割
			if room.size.x > 6 and room.size.y > 6:
				var split_x = rect.position.x + room.size.x / 2
				var split_y = rect.position.y + room.size.y / 2
				
				# 垂直部分
				for y in range(rect.position.y + 1, split_y):
					if randi() % 2 == 0:
						room.add_internal_wall(Vector2i(split_x, y))
				
				# 水平部分
				for x in range(split_x + 1, rect.position.x + room.size.x - 1):
					if randi() % 2 == 0:
						room.add_internal_wall(Vector2i(x, split_y))

func _add_floor_damage(room: SimpleRoom) -> void:
	"""添加地板破旧效果"""
	var rect = room.get_rect()
	var damage_count = randi_range(1, (room.size.x * room.size.y) / 8)
	
	for i in range(damage_count):
		var x = randi_range(rect.position.x + 1, rect.position.x + room.size.x - 2)
		var y = randi_range(rect.position.y + 1, rect.position.y + room.size.y - 2)
		room.add_floor_variation(Vector2i(x, y))

# ============================================================================
# 房间连接系统
# ============================================================================

func _connect_rooms_in_cavity(cavity_rooms: Array[SimpleRoom]) -> void:
	"""连接空洞内的房间 - 调用统一的房间连接逻辑"""
	LogManager.info("步骤5: 开始连接 %d 个房间..." % cavity_rooms.size())
	_connect_rooms(cavity_rooms)

func _ensure_adjacent_rooms_connected(room1: SimpleRoom, room2: SimpleRoom) -> void:
	"""确保相邻房间有门连接"""
	if _are_rooms_adjacent(room1, room2):
		_connect_adjacent_rooms(room1, room2)

func _connect_rooms(room_list: Array[SimpleRoom] = []) -> void:
	"""统一的房间连接逻辑"""
	var search_rooms = room_list if not room_list.is_empty() else rooms
	if search_rooms.size() < 2:
		return
	
	LogManager.info("开始连接 %d 个房间..." % search_rooms.size())
	
	# 确保每个房间至少有一个出口
	for room in search_rooms:
		if room.exits.is_empty():
			_add_room_exits(room)
	
	# 连接相邻的房间
	for i in range(search_rooms.size()):
		for j in range(i + 1, search_rooms.size()):
			if _are_rooms_adjacent(search_rooms[i], search_rooms[j]):
				_connect_adjacent_rooms(search_rooms[i], search_rooms[j])
	
	# 确保所有房间都可达
	_ensure_connectivity(search_rooms)


func _connect_adjacent_rooms(room1: SimpleRoom, room2: SimpleRoom) -> void:
	"""连接相邻的房间"""
	# 找到相邻的墙壁位置
	var connection_point = _find_connection_point(room1, room2)
	if connection_point != Vector2i(-1, -1):
		# 在连接点创建出口
		room1.add_exit(connection_point)
		room2.add_exit(connection_point)
		
		# 记录连接关系
		room1.connect_to_room(room2.room_id)
		room2.connect_to_room(room1.room_id)
		
		LogManager.info("连接房间 %d 和 %d 在位置 (%d,%d)" % [
			room1.room_id, room2.room_id, connection_point.x, connection_point.y
		])

func _find_connection_point(room1: SimpleRoom, room2: SimpleRoom) -> Vector2i:
	"""找到两个房间的连接点"""
	var rect1 = room1.get_rect()
	var rect2 = room2.get_rect()
	
	# 检查水平相邻
	if rect1.position.x + rect1.size.x == rect2.position.x:
		# room1在左，room2在右
		var overlap_start = max(rect1.position.y, rect2.position.y)
		var overlap_end = min(rect1.position.y + rect1.size.y, rect2.position.y + rect2.size.y)
		
		if overlap_end > overlap_start:
			var y = randi_range(overlap_start, overlap_end - 1)
			return Vector2i(rect1.position.x + rect1.size.x, y)
	
	elif rect2.position.x + rect2.size.x == rect1.position.x:
		# room2在左，room1在右
		var overlap_start = max(rect1.position.y, rect2.position.y)
		var overlap_end = min(rect1.position.y + rect1.size.y, rect2.position.y + rect2.size.y)
		
		if overlap_end > overlap_start:
			var y = randi_range(overlap_start, overlap_end - 1)
			return Vector2i(rect2.position.x + rect2.size.x, y)
	
	# 检查垂直相邻
	elif rect1.position.y + rect1.size.y == rect2.position.y:
		# room1在上，room2在下
		var overlap_start = max(rect1.position.x, rect2.position.x)
		var overlap_end = min(rect1.position.x + rect1.size.x, rect2.position.x + rect2.size.x)
		
		if overlap_end > overlap_start:
			var x = randi_range(overlap_start, overlap_end - 1)
			return Vector2i(x, rect1.position.y + rect1.size.y)
	
	elif rect2.position.y + rect2.size.y == rect1.position.y:
		# room2在上，room1在下
		var overlap_start = max(rect1.position.x, rect2.position.x)
		var overlap_end = min(rect1.position.x + rect1.size.x, rect2.position.x + rect2.size.x)
		
		if overlap_end > overlap_start:
			var x = randi_range(overlap_start, overlap_end - 1)
			return Vector2i(x, rect2.position.y + rect2.size.y)
	
	return Vector2i(-1, -1) # 没有找到连接点

func _ensure_connectivity_in_cavity(cavity_rooms: Array[SimpleRoom]) -> void:
	"""确保空洞内所有房间都可达 - 调用统一的连通性检查逻辑"""
	_ensure_connectivity(cavity_rooms)

func _ensure_connectivity(room_list: Array[SimpleRoom] = []) -> void:
	"""统一的连通性检查逻辑"""
	var search_rooms = room_list if not room_list.is_empty() else rooms
	if search_rooms.size() < 2:
		return
	
	# 使用BFS检查连通性
	var visited = {}
	var queue = [search_rooms[0].room_id]
	visited[search_rooms[0].room_id] = true
	
	while not queue.is_empty():
		var current_id = queue.pop_front()
		var current_room = _get_room_by_id(current_id, search_rooms)
		
		if current_room:
			for connected_id in current_room.connected_rooms:
				if not visited.has(connected_id):
					visited[connected_id] = true
					queue.append(connected_id)
	
	# 如果有未访问的房间，创建连接
	for room in search_rooms:
		if not visited.has(room.room_id):
			_create_connection_to_visited_room(room, visited, search_rooms)

func _get_room_by_id_in_cavity(room_id: int, cavity_rooms: Array[SimpleRoom]) -> SimpleRoom:
	"""根据ID在空洞内获取房间 - 调用统一的房间查找逻辑"""
	return _get_room_by_id(room_id, cavity_rooms)

func _get_room_by_id(room_id: int, room_list: Array[SimpleRoom] = []) -> SimpleRoom:
	"""统一的房间查找逻辑"""
	var search_rooms = room_list if not room_list.is_empty() else rooms
	for room in search_rooms:
		if room.room_id == room_id:
			return room
	return null

func _create_connection_to_visited_room_in_cavity(unvisited_room: SimpleRoom, visited: Dictionary, cavity_rooms: Array[SimpleRoom]) -> void:
	"""为未访问的房间创建到已访问房间的连接（空洞内） - 调用统一的连接创建逻辑"""
	_create_connection_to_visited_room(unvisited_room, visited, cavity_rooms)

func _create_connection_to_visited_room(unvisited_room: SimpleRoom, visited: Dictionary, room_list: Array[SimpleRoom] = []) -> void:
	"""统一的连接创建逻辑"""
	var closest_room = null
	var min_distance = INF
	var search_rooms = room_list if not room_list.is_empty() else rooms
	
	for room in search_rooms:
		if visited.has(room.room_id):
			var distance = unvisited_room.center.distance_to(room.center)
			if distance < min_distance:
				min_distance = distance
				closest_room = room
	
	if closest_room:
		# 创建走廊连接
		_create_corridor_connection(unvisited_room, closest_room)

# ============================================================================
# 最小生成树算法实现
# ============================================================================

func _build_room_graph(cavity_rooms: Array[SimpleRoom]) -> Array:
	"""构建房间连接图"""
	var graph = []
	
	for i in range(cavity_rooms.size()):
		for j in range(i + 1, cavity_rooms.size()):
			var room1 = cavity_rooms[i]
			var room2 = cavity_rooms[j]
			var distance = room1.center.distance_to(room2.center)
			
			graph.append({
				"roomA": room1,
				"roomB": room2,
				"distance": distance,
				"is_adjacent": _are_rooms_adjacent(room1, room2)
			})
	
	# 按距离排序
	graph.sort_custom(func(a, b): return a.distance < b.distance)
	return graph

func _prim_algorithm(graph: Array) -> Array:
	"""Prim算法计算最小生成树"""
	if graph.is_empty():
		return []
	
	var mst_connections = []
	var visited_rooms = {}
	
	# 从第一个房间开始
	var start_room = graph[0].roomA
	visited_rooms[start_room.room_id] = true
	
	while visited_rooms.size() < _get_unique_room_count(graph):
		var min_edge = null
		var min_distance = INF
		
		# 找到连接已访问和未访问房间的最小边
		for edge in graph:
			var roomA_visited = visited_rooms.has(edge.roomA.room_id)
			var roomB_visited = visited_rooms.has(edge.roomB.room_id)
			
			# 如果一边已访问，另一边未访问
			if roomA_visited != roomB_visited:
				if edge.distance < min_distance:
					min_distance = edge.distance
					min_edge = edge
		
		if min_edge:
			mst_connections.append(min_edge)
			# 标记新访问的房间
			if visited_rooms.has(min_edge.roomA.room_id):
				visited_rooms[min_edge.roomB.room_id] = true
			else:
				visited_rooms[min_edge.roomA.room_id] = true
		else:
			break
	
	return mst_connections

func _get_unique_room_count(graph: Array) -> int:
	"""获取图中唯一房间数量"""
	var room_ids = {}
	for edge in graph:
		room_ids[edge.roomA.room_id] = true
		room_ids[edge.roomB.room_id] = true
	return room_ids.size()

func _create_door_or_corridor(room1: SimpleRoom, room2: SimpleRoom) -> void:
	"""创建门或走廊连接两个房间"""
	# 如果房间相邻，创建门
	if _are_rooms_adjacent(room1, room2):
		_connect_adjacent_rooms(room1, room2)
	else:
		# 否则创建走廊
		_create_corridor_connection(room1, room2)

func _add_random_connections(graph: Array, mst_connections: Array) -> void:
	"""添加随机连接以避免线性结构"""
	var additional_connections = 0
	var max_additional = min(3, graph.size() - mst_connections.size()) # 最多添加3个额外连接
	
	for edge in graph:
		if additional_connections >= max_additional:
			break
		
		# 如果这个边不在MST中，且房间不相邻，随机决定是否添加
		if not _is_edge_in_mst(edge, mst_connections) and not edge.is_adjacent:
			if randi() % 4 == 0: # 25% 概率添加额外连接
				_create_corridor_connection(edge.roomA, edge.roomB)
				additional_connections += 1

func _is_edge_in_mst(edge, mst_connections: Array) -> bool:
	"""检查边是否在最小生成树中"""
	for mst_edge in mst_connections:
		if (mst_edge.roomA.room_id == edge.roomA.room_id and mst_edge.roomB.room_id == edge.roomB.room_id) or \
		   (mst_edge.roomA.room_id == edge.roomB.room_id and mst_edge.roomB.room_id == edge.roomA.room_id):
			return true
	return false

func _create_corridor_connection(room1: SimpleRoom, room2: SimpleRoom) -> void:
	"""创建走廊连接两个房间 - 真正的1格宽通道"""
	LogManager.info("创建走廊连接房间 %d 和 %d" % [room1.room_id, room2.room_id])
	
	# 计算两个房间的最近连接点
	var connection_points = _find_room_connection_points(room1, room2)
	if connection_points.is_empty():
		LogManager.warning("无法找到房间 %d 和 %d 的连接点" % [room1.room_id, room2.room_id])
		return
	
	var start_pos = connection_points[0]
	var end_pos = connection_points[1]
	
	# 创建L型走廊路径
	var corridor_path = _calculate_corridor_path(start_pos, end_pos)
	
	# 绘制走廊地板
	for pos in corridor_path:
		var world_pos = Vector3(pos.x, 0, pos.y)
		tile_manager.set_tile_type(world_pos, TileTypes.TileType.CORRIDOR)
	
	# 绘制走廊墙壁
	_draw_corridor_walls(corridor_path)
	
	# 创建走廊房间对象用于统计
	var corridor_room = SimpleRoom.new()
	corridor_room.room_id = room_counter
	room_counter += 1
	corridor_room.room_type = "corridor"
	corridor_room.position = start_pos
	corridor_room.size = Vector2i(1, 1) # 走廊是1格宽
	corridor_room.center = start_pos
	rooms.append(corridor_room)
	
	# 记录连接关系
	room1.connect_to_room(room2.room_id)
	room2.connect_to_room(room1.room_id)
	
	LogManager.info("走廊连接完成: 从(%d,%d)到(%d,%d)，路径长度: %d" % [start_pos.x, start_pos.y, end_pos.x, end_pos.y, corridor_path.size()])

func _find_room_connection_points(room1: SimpleRoom, room2: SimpleRoom) -> Array[Vector2i]:
	"""找到两个房间的最佳连接点"""
	var rect1 = room1.get_rect()
	var rect2 = room2.get_rect()
	
	# 找到两个房间最近的边缘点
	var best_points: Array[Vector2i] = []
	var min_distance = INF
	
	# 检查房间1的四个边缘
	var room1_edges = [
		Vector2i(rect1.position.x + rect1.size.x / 2, rect1.position.y - 1), # 上边
		Vector2i(rect1.position.x + rect1.size.x, rect1.position.y + rect1.size.y / 2), # 右边
		Vector2i(rect1.position.x + rect1.size.x / 2, rect1.position.y + rect1.size.y), # 下边
		Vector2i(rect1.position.x - 1, rect1.position.y + rect1.size.y / 2) # 左边
	]
	
	var room2_edges = [
		Vector2i(rect2.position.x + rect2.size.x / 2, rect2.position.y - 1), # 上边
		Vector2i(rect2.position.x + rect2.size.x, rect2.position.y + rect2.size.y / 2), # 右边
		Vector2i(rect2.position.x + rect2.size.x / 2, rect2.position.y + rect2.size.y), # 下边
		Vector2i(rect2.position.x - 1, rect2.position.y + rect2.size.y / 2) # 左边
	]
	
	# 找到最近的边缘点对
	for edge1 in room1_edges:
		for edge2 in room2_edges:
			var distance = edge1.distance_to(edge2)
			if distance < min_distance:
				min_distance = distance
				best_points = [edge1, edge2]
	
	return best_points

func _calculate_corridor_path(start_pos: Vector2i, end_pos: Vector2i) -> Array[Vector2i]:
	"""计算L型走廊路径 - 真正的1格宽通道"""
	var path: Array[Vector2i] = []
	var current_pos = start_pos
	
	# 水平移动
	while current_pos.x != end_pos.x:
		var next_pos = current_pos
		if current_pos.x < end_pos.x:
			next_pos.x += 1
		else:
			next_pos.x -= 1
		
		path.append(next_pos)
		current_pos = next_pos
	
	# 垂直移动
	while current_pos.y != end_pos.y:
		var next_pos = current_pos
		if current_pos.y < end_pos.y:
			next_pos.y += 1
		else:
			next_pos.y -= 1
		
		path.append(next_pos)
		current_pos = next_pos
	
	return path

func _draw_corridor_walls(corridor_positions: Array[Vector2i]) -> void:
	"""为走廊绘制墙壁 - 专门为长条形走廊优化"""
	if corridor_positions.is_empty():
		return
	
	# 创建走廊位置集合，提高查找效率
	var corridor_set: Dictionary = {}
	for pos in corridor_positions:
		corridor_set[pos] = true
	
	# 分析走廊方向（水平或垂直）
	var is_horizontal = _is_corridor_horizontal(corridor_positions)
	
	# 根据走廊方向绘制墙壁
	if is_horizontal:
		_draw_horizontal_corridor_walls(corridor_positions, corridor_set)
	else:
		_draw_vertical_corridor_walls(corridor_positions, corridor_set)

func _is_corridor_horizontal(corridor_positions: Array[Vector2i]) -> bool:
	"""判断走廊是否为水平方向"""
	if corridor_positions.size() <= 1:
		return true
	
	var first_pos = corridor_positions[0]
	var last_pos = corridor_positions[-1]
	
	# 如果Y坐标相同，则为水平走廊
	return first_pos.y == last_pos.y

func _draw_horizontal_corridor_walls(corridor_positions: Array[Vector2i], corridor_set: Dictionary) -> void:
	"""绘制水平走廊的墙壁"""
	var min_x = corridor_positions[0].x
	var max_x = corridor_positions[0].x
	var y = corridor_positions[0].y
	
	# 找到走廊的边界
	for pos in corridor_positions:
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
	
	# 绘制上下墙壁
	for x in range(min_x, max_x + 1):
		# 上墙壁
		var top_wall = Vector2i(x, y - 1)
		if not corridor_set.has(top_wall) and not _is_position_room_floor(top_wall):
			var world_pos = Vector3(top_wall.x, 0, top_wall.y)
			tile_manager.set_tile_type(world_pos, TileTypes.TileType.STONE_WALL)
		
		# 下墙壁
		var bottom_wall = Vector2i(x, y + 1)
		if not corridor_set.has(bottom_wall) and not _is_position_room_floor(bottom_wall):
			var world_pos = Vector3(bottom_wall.x, 0, bottom_wall.y)
			tile_manager.set_tile_type(world_pos, TileTypes.TileType.STONE_WALL)
	
	# 绘制左右端墙壁
	var left_wall = Vector2i(min_x - 1, y)
	if not corridor_set.has(left_wall) and not _is_position_room_floor(left_wall):
		var world_pos = Vector3(left_wall.x, 0, left_wall.y)
		tile_manager.set_tile_type(world_pos, TileTypes.TileType.STONE_WALL)
	
	var right_wall = Vector2i(max_x + 1, y)
	if not corridor_set.has(right_wall) and not _is_position_room_floor(right_wall):
		var world_pos = Vector3(right_wall.x, 0, right_wall.y)
		tile_manager.set_tile_type(world_pos, TileTypes.TileType.STONE_WALL)

func _draw_vertical_corridor_walls(corridor_positions: Array[Vector2i], corridor_set: Dictionary) -> void:
	"""绘制垂直走廊的墙壁"""
	var x = corridor_positions[0].x
	var min_y = corridor_positions[0].y
	var max_y = corridor_positions[0].y
	
	# 找到走廊的边界
	for pos in corridor_positions:
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)
	
	# 绘制左右墙壁
	for y in range(min_y, max_y + 1):
		# 左墙壁
		var left_wall = Vector2i(x - 1, y)
		if not corridor_set.has(left_wall) and not _is_position_room_floor(left_wall):
			var world_pos = Vector3(left_wall.x, 0, left_wall.y)
			tile_manager.set_tile_type(world_pos, TileTypes.TileType.STONE_WALL)
		
		# 右墙壁
		var right_wall = Vector2i(x + 1, y)
		if not corridor_set.has(right_wall) and not _is_position_room_floor(right_wall):
			var world_pos = Vector3(right_wall.x, 0, right_wall.y)
			tile_manager.set_tile_type(world_pos, TileTypes.TileType.STONE_WALL)
	
	# 绘制上下端墙壁
	var top_wall = Vector2i(x, min_y - 1)
	if not corridor_set.has(top_wall) and not _is_position_room_floor(top_wall):
		var world_pos = Vector3(top_wall.x, 0, top_wall.y)
		tile_manager.set_tile_type(world_pos, TileTypes.TileType.STONE_WALL)
	
	var bottom_wall = Vector2i(x, max_y + 1)
	if not corridor_set.has(bottom_wall) and not _is_position_room_floor(bottom_wall):
		var world_pos = Vector3(bottom_wall.x, 0, bottom_wall.y)
		tile_manager.set_tile_type(world_pos, TileTypes.TileType.STONE_WALL)

func _is_position_room_floor(pos: Vector2i) -> bool:
	"""检查位置是否是房间地板"""
	var world_pos = Vector3(pos.x, 0, pos.y)
	var tile_type = tile_manager.get_tile_type(world_pos)
	return tile_type == TileTypes.TileType.STONE_FLOOR

# ============================================================================
# 房间墙壁绘制
# ============================================================================

func _draw_room_walls(room: SimpleRoom) -> void:
	"""绘制房间的外墙壁（包括四个角落）"""
	var rect = room.get_rect()
	var cavity_positions = room.cavity_positions
	
	# 绘制上墙壁
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		var wall_pos = Vector3(x, 0, rect.position.y - 1)
		# 检查是否是出口位置
		if not room.exits.has(Vector2i(x, rect.position.y - 1)):
			tile_manager.set_tile_type(wall_pos, TileTypes.TileType.STONE_WALL)
	
	# 绘制下墙壁
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		var wall_pos = Vector3(x, 0, rect.position.y + rect.size.y)
		# 检查是否是出口位置
		if not room.exits.has(Vector2i(x, rect.position.y + rect.size.y)):
			tile_manager.set_tile_type(wall_pos, TileTypes.TileType.STONE_WALL)
	
	# 绘制左墙壁
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		var wall_pos = Vector3(rect.position.x - 1, 0, y)
		# 检查是否是出口位置
		if not room.exits.has(Vector2i(rect.position.x - 1, y)):
			tile_manager.set_tile_type(wall_pos, TileTypes.TileType.STONE_WALL)
	
	# 绘制右墙壁
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		var wall_pos = Vector3(rect.position.x + rect.size.x, 0, y)
		# 检查是否是出口位置
		if not room.exits.has(Vector2i(rect.position.x + rect.size.x, y)):
			tile_manager.set_tile_type(wall_pos, TileTypes.TileType.STONE_WALL)
	
	# 绘制四个角落的墙壁
	_draw_room_corners(room, rect, cavity_positions)

func _draw_room_corners(_room: SimpleRoom, rect: Rect2i, _cavity_positions: Array) -> void:
	"""绘制房间的四个角落墙壁"""
	# 左上角
	var top_left = Vector3(rect.position.x - 1, 0, rect.position.y - 1)
	tile_manager.set_tile_type(top_left, TileTypes.TileType.STONE_WALL)
	
	# 右上角
	var top_right = Vector3(rect.position.x + rect.size.x, 0, rect.position.y - 1)
	tile_manager.set_tile_type(top_right, TileTypes.TileType.STONE_WALL)
	
	# 左下角
	var bottom_left = Vector3(rect.position.x - 1, 0, rect.position.y + rect.size.y)
	tile_manager.set_tile_type(bottom_left, TileTypes.TileType.STONE_WALL)
	
	# 右下角
	var bottom_right = Vector3(rect.position.x + rect.size.x, 0, rect.position.y + rect.size.y)
	tile_manager.set_tile_type(bottom_right, TileTypes.TileType.STONE_WALL)

# ============================================================================
# 房间应用到地图
# ============================================================================

func apply_rooms_to_map(room_list: Array[SimpleRoom]) -> void:
	"""将房间应用到地图"""
	LogManager.info("开始应用 %d 个房间到地图..." % room_list.size())
	
	for room in room_list:
		_apply_single_room_to_map(room)

func _apply_single_room_to_map(room: SimpleRoom) -> void:
	"""将单个房间应用到地图"""
	var rect = room.get_rect()
	var cavity_positions = room.cavity_positions
	
	# 绘制地板（只在空洞内的部分）
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			var pos = Vector3(x, 0, y)
			
			# 只绘制在空洞内的地板
			if cavity_positions.has(pos):
				# 检查是否是破旧地板
				if room.floor_variations.has(Vector2i(x, y)):
					# 随机决定是否绘制地板（破旧效果）
					if randi() % 3 != 0: # 66% 概率绘制地板
						tile_manager.set_tile_type(pos, TileTypes.TileType.STONE_FLOOR)
				else:
					tile_manager.set_tile_type(pos, TileTypes.TileType.STONE_FLOOR)
	
	# 绘制房间外墙壁
	_draw_room_walls(room)
	
	# 绘制内部墙壁（只在空洞内的部分）
	for wall_pos in room.internal_walls:
		var wall_world_pos = Vector3(wall_pos.x, 0, wall_pos.y)
		# 只绘制在空洞内的内部墙壁
		if cavity_positions.has(wall_world_pos):
			tile_manager.set_tile_type(wall_world_pos, TileTypes.TileType.STONE_WALL)
	
	# 绘制出口
	for exit_pos in room.exits:
		var exit_world_pos = Vector3(exit_pos.x, 0, exit_pos.y)
		tile_manager.set_tile_type(exit_world_pos, TileTypes.TileType.EMPTY)

# ============================================================================
# 📊 统计信息方法
# ============================================================================

func get_room_count() -> int:
	"""获取当前生成的房间数量"""
	return rooms.size()

func get_corridor_count() -> int:
	"""获取当前生成的走廊数量"""
	var corridor_count = 0
	for room in rooms:
		if room.room_type == "corridor":
			corridor_count += 1
	return corridor_count

func get_room_stats() -> Dictionary:
	"""获取房间系统统计信息"""
	var normal_rooms = 0
	var corridor_rooms = 0
	
	for room in rooms:
		if room.room_type == "normal":
			normal_rooms += 1
		elif room.room_type == "corridor":
			corridor_rooms += 1
	
	return {
		"total_rooms": rooms.size(),
		"normal_rooms": normal_rooms,
		"corridor_rooms": corridor_rooms,
		"room_counter": room_counter
	}
