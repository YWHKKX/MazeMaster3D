extends Node
class_name MapGenerator

# 地牢迷宫生成器 - 参考random_room.gd的设计
# 生成随机房间并连接成地牢
# 日志管理器实例（全局变量）
# 地图类型枚举
enum MapType {
	STANDARD_DUNGEON, # 标准地牢
	COMPLEX_MAZE, # 复杂迷宫
	RESOURCE_RICH, # 资源丰富
	MILITARY_FOCUSED, # 军事重点
	EXPLORATION_HEAVY # 探索重型
}

# 地图配置
class MapConfig:
	var map_type: MapType
	var size: Vector3
	var max_room_count: int = 15
	var min_room_size: int = 6
	var max_room_size: int = 15
	var room_connection_attempts: int = 10
	var resource_density: float = 0.1
	var corridor_width: int = 3
	var complexity: float = 0.5

	func _init(type: MapType = MapType.STANDARD_DUNGEON, map_size: Vector3 = Vector3(100, 1, 100)):
		map_type = type
		size = map_size

# 房间数据结构
class Room:
	var position: Vector2i
	var size: Vector2i
	var center: Vector2i
	var connections: Array = [] # 连接的房间
	var room_id: int
	var room_type: String = "normal"
	
	func _init(pos: Vector2i, room_size: Vector2i, id: int):
		position = pos
		size = room_size
		center = pos + room_size / 2
		room_id = id
	
	func get_rect() -> Rect2i:
		return Rect2i(position, size)
	
	func overlaps(other_room: Room) -> bool:
		var rect1 = get_rect()
		var rect2 = other_room.get_rect()
		return rect1.intersects(rect2)
	
	func get_connection_points() -> Array:
		var points = []
		# 获取房间边缘的潜在连接点
		for x in range(position.x, position.x + size.x):
			points.append(Vector2i(x, position.y)) # 上边
			points.append(Vector2i(x, position.y + size.y - 1)) # 下边
		for y in range(position.y, position.y + size.y):
			points.append(Vector2i(position.x, y)) # 左边
			points.append(Vector2i(position.x + size.x - 1, y)) # 右边
		return points

# 地图生成器引用
var tile_manager: Node
var rooms: Array[Room] = []
var room_counter: int = 0

func _ready():
	"""初始化地图生成器"""
	LogManager.info("=== MapGenerator 初始化开始 ===")
	
	tile_manager = get_node("/root/Main/TileManager")
	if tile_manager:
		LogManager.info("TileManager 连接成功")
	else:
		LogManager.error("ERROR: TileManager 未找到")
	# RoomGenerator 已移除，直接在地图生成器中处理
	LogManager.info("=== MapGenerator 初始化完成 ===")

func generate_map(_config: MapConfig) -> void:
	"""生成地图 - 两步生成流程"""
	LogManager.info("=== 开始生成地牢地图 ===")

	# 确保 TileManager 已完全初始化
	if not tile_manager:
		LogManager.error("ERROR: TileManager 未找到，无法生成地图")
		return
	
	# 同步地图尺寸到 TileManager（若配置不同）
	if tile_manager.get_map_size and tile_manager.get_map_size() != _config.size:
		if tile_manager.set_map_size:
			tile_manager.set_map_size(_config.size)
			LogManager.info("已将地图尺寸同步到 TileManager: " + str(_config.size))

	# 等待一帧确保 TileManager 完全初始化
	await get_tree().process_frame
	
	# 第一步：初始化地图
	LogManager.info("=== 第一步：初始化地图 ===")
	_initialize_map(_config)
	
	# 第二步：生成房间
	LogManager.info("=== 第二步：生成房间 ===")
	_generate_rooms_on_map(_config)
	
	LogManager.info("=== 地牢地图生成完成 ===")
	
	# [关键] 发射地图生成完成事件（通知 NavigationManager 烘焙导航网格）
	GameEvents.map_generated.emit()
	LogManager.info("✅ 已发射 map_generated 事件")

func _initialize_map(_config: MapConfig) -> void:
	"""第一步：初始化地图"""
	
	# 清空现有地图
	_clear_map()
	
	# 重新初始化地图结构（所有地块为未挖掘状态）
	tile_manager._initialize_map_structure()
	
	# 初始化所有地块为UNEXCAVATED
	_initialize_all_tiles_as_unexcavated()
	

func _initialize_all_tiles_as_unexcavated() -> void:
	"""初始化所有地块为UNEXCAVATED（优化版本：使用简化渲染）"""
	
	for x in range(tile_manager.map_size.x):
		for z in range(tile_manager.map_size.z):
			var pos = Vector3(x, 0, z)
			# 创建TileInfo对象，并创建简化的3D对象
			var tile_data = tile_manager.TileInfo.new(pos, tile_manager.TileType.UNEXCAVATED, tile_manager.MapLevel.LEVEL_0_MAIN)
			var level_index = int(tile_data.level)
			tile_manager.tiles[level_index][x][z] = tile_data
			# 调用_create_tile_object，UNEXCAVATED现在使用简化渲染
			tile_manager._create_tile_object(tile_data)
			# 初始化资源字典（用于金矿等）
			tile_manager.tiles[level_index][x][z].resources = {}
	

func _place_dungeon_heart() -> void:
	"""放置地牢之心及其周围的初始区域（2x2建筑）"""
	var center_x = int(tile_manager.map_size.x / 2)
	var center_z = int(tile_manager.map_size.z / 2)
	var level_index = 0

	LogManager.info("放置地牢之心（2x2）在位置: (" + str(center_x) + ", " + str(center_z) + ")")

	# 🔧 放置2x2地牢之心瓦片
	var dungeon_heart_tiles = []
	for dx in range(2):
		for dz in range(2):
			var pos = Vector3(center_x + dx, level_index, center_z + dz)
			var success = tile_manager.set_tile_type(pos, tile_manager.TileType.DUNGEON_HEART)
			if success:
				dungeon_heart_tiles.append(pos)
	
	LogManager.info("✅ 地牢之心2x2瓦片放置成功，共 %d 个瓦片" % dungeon_heart_tiles.size())
	
	# 🔧 [修改] 移除地牢之心周围的 STONE_FLOOR 设置
	# 地牢之心周围将保持为 EMPTY 瓦片，允许苦工更接近
	LogManager.info("✅ 地牢之心周围保持为 EMPTY 瓦片，允许单位接近")

func _create_heart_clearing() -> void:
	"""创建地牢之心周围的清理区域，强制修改为EMPTY"""
	var center_x = int(tile_manager.map_size.x / 2)
	var center_z = int(tile_manager.map_size.z / 2)
	
	# 🔧 创建 7x7 的清理区域（2x2 地牢之心 + 周围一圈）
	var radius = 3 # 7x7 区域，半径 3
	for dx in range(-radius, radius + 1):
		for dz in range(-radius, radius + 1):
			var pos = Vector3(center_x + dx, 0, center_z + dz)
			
			# 跳过地牢之心占用的 2x2 区域
			if dx >= 0 and dx <= 1 and dz >= 0 and dz <= 1:
				continue
			
			# 强制设置为EMPTY，覆盖任何现有类型
			tile_manager.set_tile_type(pos, tile_manager.TileType.EMPTY)
	

func _generate_rooms_on_map(_config: MapConfig) -> void:
	"""第二步：在地图上生成房间"""
	
	# 根据地图类型调整参数
	_adjust_config_for_type(_config)
	
	# 清空房间列表
	rooms.clear()
	room_counter = 0
	
	# 在地图中心25x25区域内生成随机房间
	_generate_random_rooms(_config)
	
	# 连接所有房间
	_connect_rooms()
	
	# 最后生成地牢之心，并将周围区域强制修改为EMPTY
	_place_dungeon_heart()
	_create_heart_clearing()

	# 依据 MINING_SYSTEM.md：在未挖掘岩石中生成金矿（约1.6% 概率，每脉500单位）
	_generate_gold_veins(0.016, 500)
	

func _generate_random_rooms(_config: MapConfig) -> void:
	"""在地图中心25x25区域内生成随机房间"""
	
	var room_count = randi_range(5, _config.max_room_count)
	var max_attempts = room_count * 20
	var attempts = 0
	
	
	for i in range(room_count):
		var room = _create_random_room(_config)
		if room:
			rooms.append(room)
			_generate_room_floor(room)
			_generate_room_walls(room)
			pass
		else:
			attempts += 1
			if attempts > max_attempts:
				pass
				break
	

func _generate_gold_veins(probability: float, vein_capacity: int) -> void:
	"""在未挖掘岩石中按概率生成金矿，并设置储量到 tile.resources.gold_amount
	使用聚集分布算法，让金矿集中在特定区域"""
	LogManager.info("=== 开始生成金矿 ===")
	LogManager.info("基础概率: " + str(probability * 100) + "% 储量: " + str(vein_capacity))
	
	var level_index = 0
	var map_size_x = int(tile_manager.map_size.x)
	var map_size_z = int(tile_manager.map_size.z)
	
	# 生成3-5个金矿聚集区域
	var cluster_count = randi_range(3, 5)
	var clusters = []
	
	LogManager.info("生成 " + str(cluster_count) + " 个金矿聚集区域")
	
	# 创建聚集中心点
	for i in range(cluster_count):
		var center_x = randi_range(10, map_size_x - 10)
		var center_z = randi_range(10, map_size_z - 10)
		clusters.append(Vector2(center_x, center_z))
		LogManager.info("  聚集区域 " + str(i + 1) + ": (" + str(center_x) + ", " + str(center_z) + ")")
	
	var generated_count = 0
	var unexcavated_count = 0
	
	# 遍历所有未挖掘地块，根据距离聚集中心的远近调整生成概率
	for x in range(map_size_x):
		for z in range(map_size_z):
			var pos = Vector3(x, level_index, z)
			var tile = tile_manager.get_tile_data(pos)
			if tile == null:
				continue
			
			# 仅在未挖掘岩石中生成
			if tile.type == tile_manager.TileType.UNEXCAVATED:
				unexcavated_count += 1
				# 计算到最近聚集中心的距离
				var min_distance = INF
				for cluster in clusters:
					var distance = Vector2(x, z).distance_to(cluster)
					min_distance = min(min_distance, distance)
				
				# 根据距离调整概率：距离越近概率越高
				var adjusted_probability = probability
				if min_distance < 15: # 在聚集中心15格范围内
					adjusted_probability *= 5.0 # 5倍概率
				elif min_distance < 25: # 在聚集中心25格范围内
					adjusted_probability *= 2.0 # 2倍概率
				else:
					adjusted_probability *= 0.1 # 远离聚集中心概率很低
				
				if randf() < adjusted_probability:
					# 设置为金矿并记录储量
					tile_manager.set_tile_type(pos, tile_manager.TileType.GOLD_MINE)
					var updated = tile_manager.get_tile_data(pos)
					if updated:
						updated.resources["gold_amount"] = vein_capacity
						updated.resources["is_gold_vein"] = true
						generated_count += 1
						if generated_count <= 5: # 只记录前5个
							LogManager.info("  生成金矿 #" + str(generated_count) + " 位置: (" + str(x) + ", " + str(z) + ")")
	
	LogManager.info("=== 金矿生成完成 ===")
	LogManager.info("扫描了 " + str(unexcavated_count) + " 个未挖掘地块")
	LogManager.info("成功生成 " + str(generated_count) + " 个金矿")
	
	# 🔧 通知 GoldMineManager 重新扫描金矿（内联）
	LogManager.info("MapGenerator - 通知 GoldMineManager 重新扫描")
	var gold_mine_manager = get_node_or_null("/root/Main/GoldMineManager")
	if gold_mine_manager and gold_mine_manager.has_method("rescan_gold_mines"):
		# 延迟一帧确保瓦片数据已更新
		gold_mine_manager.call_deferred("rescan_gold_mines")
	elif gold_mine_manager:
		LogManager.error("GoldMineManager 没有 rescan_gold_mines 方法")
	else:
		LogManager.error("未找到 GoldMineManager")

func _adjust_config_for_type(_config: MapConfig) -> void:
	"""根据地图类型调整配置"""
	match _config.map_type:
		MapType.STANDARD_DUNGEON:
			_config.max_room_count = 15
			_config.min_room_size = 6
			_config.max_room_size = 12
		MapType.COMPLEX_MAZE:
			_config.max_room_count = 25
			_config.min_room_size = 4
			_config.max_room_size = 8
			_config.complexity = 0.8
		MapType.RESOURCE_RICH:
			_config.max_room_count = 20
			_config.resource_density = 0.3
		MapType.MILITARY_FOCUSED:
			_config.max_room_count = 12
			_config.min_room_size = 8
			_config.max_room_size = 15
		MapType.EXPLORATION_HEAVY:
			_config.max_room_count = 30
			_config.min_room_size = 5
			_config.max_room_size = 10


func _create_random_room(_config: MapConfig) -> Room:
	"""创建随机房间"""
	var room_size = Vector2i(
		randi_range(_config.min_room_size, _config.max_room_size),
		randi_range(_config.min_room_size, _config.max_room_size)
	)

	# 将房间生成限制在地图中心 25x25 区域
	var center_x = int(tile_manager.map_size.x) / 2
	var center_z = int(tile_manager.map_size.z) / 2
	var half = 12

	var min_x = center_x - half
	var min_z = center_z - half
	var max_x = center_x + half - room_size.x
	var max_z = center_z + half - room_size.y

	if max_x < min_x or max_z < min_z:
		return null

	var position = Vector2i(
		randi_range(min_x, max_x),
		randi_range(min_z, max_z)
	)
	
	var new_room = Room.new(position, room_size, room_counter)
	room_counter += 1
	
	# 检查是否与现有房间重叠
	for existing_room in rooms:
		if new_room.overlaps(existing_room):
			return null
	
	return new_room

func _connect_rooms() -> void:
	"""连接房间"""
	
	# 确保所有房间都连接
	var connected_rooms = []
	var unconnected_rooms = rooms.duplicate()
	
	if unconnected_rooms.is_empty():
		return
	
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

func _try_connect_rooms(room1: Room, room2: Room) -> bool:
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

func _force_connect_room(room: Room, target_room: Room) -> void:
	"""强制连接房间（用于确保所有房间都连接）"""
	var room1_center = room.center
	var room2_center = target_room.center
	
	# 创建从中心到中心的连接
	_mark_connection(room1_center, room2_center)
	
	room.connections.append(target_room.room_id)
	target_room.connections.append(room.room_id)

func _mark_connection(point1: Vector2i, point2: Vector2i) -> void:
	"""在地图上标记连接"""
	# 创建从point1到point2的路径
	var current = point1
	var target = point2
	
	# 先水平移动，再垂直移动
	while current.x != target.x:
		_set_tile_type(Vector3(current.x, 0, current.y), tile_manager.TileType.CORRIDOR)
		if current.x < target.x:
			current.x += 1
		else:
			current.x -= 1
	
	while current.y != target.y:
		_set_tile_type(Vector3(current.x, 0, current.y), tile_manager.TileType.CORRIDOR)
		if current.y < target.y:
			current.y += 1
		else:
			current.y -= 1
	
	# 设置目标点
	_set_tile_type(Vector3(current.x, 0, current.y), tile_manager.TileType.CORRIDOR)

func _set_tile_type(position: Vector3, tile_type: int) -> void:
	"""设置地块类型"""
	if tile_manager:
		tile_manager.set_tile_type(position, tile_type)

func _clear_map() -> void:
	"""清空现有地图"""
	if tile_manager:
		tile_manager.clear_all_tiles()
	else:
		LogManager.error("ERROR: TileManager 为空，无法清空地图")

func _generate_room_floor(room: Room) -> void:
	"""生成房间内部 - 将房间内部填充为UNEXCAVATED（优化版本：不创建3D对象）"""
	var rect = room.get_rect()
	
	if not tile_manager:
		LogManager.error("ERROR: tile_manager 为空！")
		return
	
	var floor_tiles_placed = 0
	var max_tiles = rect.size.x * rect.size.y
	
	# 添加边界检查，防止无限循环
	if max_tiles > 1000:
		LogManager.warning("警告：房间太大，跳过地板生成")
		return
	
	for x in range(rect.size.x):
		for y in range(rect.size.y):
			# 添加额外的安全检查
			if floor_tiles_placed >= max_tiles:
				break
				
			var position = Vector3(rect.position.x + x, 0, rect.position.y + y)
			
			# 检查是否是地牢之心位置，如果是则跳过
			var tile_data = tile_manager.get_tile_data(position)
			if tile_data and tile_data.type == tile_manager.TileType.DUNGEON_HEART:
				continue
			
			# 将房间内部填充为UNEXCAVATED（实心房间）
			# UNEXCAVATED类型现在会创建简化的墙体渲染
			var success = tile_manager.set_tile_type(position, tile_manager.TileType.UNEXCAVATED)
			if success:
				floor_tiles_placed += 1
				pass
			else:
				LogManager.error("设置房间内部瓦片失败，位置: " + str(position))
			
			# 添加安全检查，防止无限循环
			if floor_tiles_placed > 1000:
				break
		if floor_tiles_placed > 1000:
			break
	
	pass

func _generate_room_walls(room: Room) -> void:
	"""生成房间墙壁 - 在房间周围放置石墙"""
	var rect = room.get_rect()
	var wall_tiles_placed = 0
	var wall_tiles_failed = 0
	
	if not tile_manager:
		LogManager.error("ERROR: tile_manager 为空！")
		return
	
	# 生成顶部和底部墙壁
	for x in range(rect.position.x - 1, rect.position.x + rect.size.x + 1):
		var top_wall_pos = Vector3(x, 0, rect.position.y - 1)
		var bottom_wall_pos = Vector3(x, 0, rect.position.y + rect.size.y)
		
		if tile_manager.set_tile_type(top_wall_pos, tile_manager.TileType.STONE_WALL):
			wall_tiles_placed += 1
		else:
			wall_tiles_failed += 1
		if tile_manager.set_tile_type(bottom_wall_pos, tile_manager.TileType.STONE_WALL):
			wall_tiles_placed += 1
		else:
			wall_tiles_failed += 1
	
	# 生成左侧和右侧墙壁
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		var left_wall_pos = Vector3(rect.position.x - 1, 0, y)
		var right_wall_pos = Vector3(rect.position.x + rect.size.x, 0, y)
		
		if tile_manager.set_tile_type(left_wall_pos, tile_manager.TileType.STONE_WALL):
			wall_tiles_placed += 1
		else:
			wall_tiles_failed += 1
		if tile_manager.set_tile_type(right_wall_pos, tile_manager.TileType.STONE_WALL):
			wall_tiles_placed += 1
		else:
			wall_tiles_failed += 1
	
	# 🔍 调试：输出墙壁生成统计
	if wall_tiles_failed > 0:
		LogManager.warning("⚠️ [MapGenerator] 房间 #%d 墙壁生成: 成功=%d, 失败=%d" % [
			room.room_id, wall_tiles_placed, wall_tiles_failed
		])
