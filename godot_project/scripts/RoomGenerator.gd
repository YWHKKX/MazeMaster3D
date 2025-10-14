extends Node
class_name RoomGenerator

# 房间生成器 - 参考random_room.gd的设计
# 负责生成单个房间的地板、墙壁和碰撞
# 日志管理器实例（全局变量）
# 房间配置
var room_config = {
	"min_floor_width": 6,
	"min_floor_height": 6,
	"max_floor_width": 15,
	"max_floor_height": 15,
	"max_overlap_floors": 5,
	"fill_gap_size": 4,
	"wall_height": 4
}

# 方向定义
var directions = {
	"right": Vector2i(1, 0),
	"bottom": Vector2i(0, 1),
	"left": Vector2i(-1, 0),
	"top": Vector2i(0, -1)
}

# 地板和墙壁瓦片配置
var floor_tiles = {
	"default": Vector2i(1, 2),
	"corridor": Vector2i(0, 1)
}

var wall_tiles = {
	"left": Vector2i(2, 5),
	"right": Vector2i(0, 5),
	"bottom": Vector2i(1, 4),
	"top_left_corner": Vector2i(0, 7),
	"top_right_corner": Vector2i(1, 7),
	"bottom_left_corner": Vector2i(0, 8),
	"bottom_right_corner": Vector2i(1, 8),
	"top": Vector2i(1, 15),
	"top2": Vector2i(1, 14),
	"top3": Vector2i(1, 13),
	"top4": Vector2i(1, 6),
	"top_left_corner_reverse": Vector2i(2, 6),
	"top_right_corner_reverse": Vector2i(0, 6),
	"bottom_left_corner_reverse": Vector2i(2, 4),
	"bottom_right_corner_reverse": Vector2i(0, 4)
}

# 节点引用
@onready var tile_manager: Node = get_node("/root/Main/TileManager")

func generate_room(room, room_type: String = "normal") -> void:
	"""生成房间"""
	LogManager.log_map_static("生成房间: " + " " + str(room.room_id) + " 类型: " + str(room.room_id) + "room_type" + str(room.room_id))
	
	# 生成地板
	_generate_floor(room)
	
	# 填充间隙
	_fill_gaps(room)
	
	# 生成墙壁
	_generate_walls(room)
	
	# 生成门
	_generate_doors(room)

func _generate_floor(room) -> void:
	"""生成房间地板"""
	var rect = room.get_rect()
	
	for x in range(rect.size.x):
		for y in range(rect.size.y):
			var position = Vector3(rect.position.x + x, 0, rect.position.y + y)
			_set_tile_type(position, tile_manager.TileType.STONE_FLOOR)

func _fill_gaps(room) -> void:
	"""填充房间间隙"""
	var rect = room.get_rect()
	var change_list = []
	
	# 检查房间内部是否有需要填充的间隙
	for x in range(rect.size.x):
		for y in range(rect.size.y):
			var position = Vector2i(rect.position.x + x, rect.position.y + y)
			
			# 如果当前位置没有地板，检查是否需要填充
			if not _has_floor_at_position(position):
				var fill_points = _get_fill_points(position, room)
				change_list.append_array(fill_points)
	
	# 填充找到的间隙
	for point in change_list:
		var world_pos = Vector3(point.x, 0, point.y)
		_set_tile_type(world_pos, tile_manager.TileType.STONE_FLOOR)

func _get_fill_points(position: Vector2i, room) -> Array[Vector2i]:
	"""获取需要填充的点"""
	var list = []
	var surrounding = _get_surrounding_cells(position)
	
	for i in range(surrounding.size()):
		var counter_side = wrap(i + 2, 0, 4)
		
		if _has_floor_at_position(surrounding[i]):
			if _has_floor_at_position(surrounding[counter_side]):
				list.append(position)
			else:
				var buffer_list = [position]
				var current_pos = surrounding[counter_side]
				
				for j in range(room_config.fill_gap_size):
					buffer_list.append(current_pos)
					var new_surrounding = _get_surrounding_cells(current_pos)
					current_pos = new_surrounding[counter_side]
					
					if _has_floor_at_position(current_pos):
						list.append_array(buffer_list)
						break
	
	return list

func _get_surrounding_cells(position: Vector2i) -> Array[Vector2i]:
	"""获取周围的地块"""
	return [
		position + directions["right"],
		position + directions["bottom"],
		position + directions["left"],
		position + directions["top"]
	]

func _has_floor_at_position(position: Vector2i) -> bool:
	"""检查指定位置是否有地板"""
	var world_pos = Vector3(position.x, 0, position.y)
	var tile_data = tile_manager.get_tile_data(world_pos)
	return tile_data and tile_data.type == tile_manager.TileType.STONE_FLOOR

func _generate_walls(room) -> void:
	"""生成房间墙壁"""
	var rect = room.get_rect()
	var all_floor_tiles = []
	
	# 获取所有地板位置
	for x in range(rect.size.x):
		for y in range(rect.size.y):
			all_floor_tiles.append(Vector2i(rect.position.x + x, rect.position.y + y))
	
	# 按Y坐标排序
	all_floor_tiles.sort_custom(func(a, b): return a.y > b.y)
	
	# 为每个地板位置生成墙壁
	for floor_position in all_floor_tiles:
		_generate_walls_for_position(floor_position)

func _generate_walls_for_position(floor_position: Vector2i) -> void:
	"""为指定位置生成墙壁"""
	var top_end = not _has_floor_at_position(floor_position + directions["top"])
	var left_end = not _has_floor_at_position(floor_position + directions["left"])
	var bottom_end = not _has_floor_at_position(floor_position + directions["bottom"])
	var right_end = not _has_floor_at_position(floor_position + directions["right"])
	
	# 根据位置生成相应的墙壁
	if top_end and left_end:
		_create_top_left_corner(floor_position)
	elif top_end and right_end:
		_create_top_right_corner(floor_position)
	elif bottom_end and left_end:
		_create_bottom_left_corner(floor_position)
	elif bottom_end and right_end:
		_create_bottom_right_corner(floor_position)
	elif top_end:
		_create_top_wall(floor_position)
	elif left_end:
		_create_left_wall(floor_position)
	elif bottom_end:
		_create_bottom_wall(floor_position)
	elif right_end:
		_create_right_wall(floor_position)

func _create_top_left_corner(position: Vector2i) -> void:
	"""创建左上角墙壁"""
	_create_top_wall(position)
	_create_left_wall(position)

func _create_top_right_corner(position: Vector2i) -> void:
	"""创建右上角墙壁"""
	_create_top_wall(position)
	_create_right_wall(position)

func _create_bottom_left_corner(position: Vector2i) -> void:
	"""创建左下角墙壁"""
	_create_left_wall(position)
	_create_bottom_wall(position)

func _create_bottom_right_corner(position: Vector2i) -> void:
	"""创建右下角墙壁"""
	_create_right_wall(position)
	_create_bottom_wall(position)

func _create_left_wall(position: Vector2i) -> void:
	"""创建左侧墙壁"""
	var wall_pos = position + directions["left"]
	_set_tile_type(Vector3(wall_pos.x, 0, wall_pos.y), tile_manager.TileType.STONE_WALL)

func _create_right_wall(position: Vector2i) -> void:
	"""创建右侧墙壁"""
	var wall_pos = position + directions["right"]
	_set_tile_type(Vector3(wall_pos.x, 0, wall_pos.y), tile_manager.TileType.STONE_WALL)

func _create_bottom_wall(position: Vector2i) -> void:
	"""创建底部墙壁"""
	var wall_pos = position + directions["bottom"]
	_set_tile_type(Vector3(wall_pos.x, 0, wall_pos.y), tile_manager.TileType.STONE_WALL)

func _create_top_wall(position: Vector2i) -> void:
	"""创建顶部墙壁"""
	var wall_pos = position + directions["top"]
	_set_tile_type(Vector3(wall_pos.x, 0, wall_pos.y), tile_manager.TileType.STONE_WALL)

func _generate_doors(room) -> void:
	"""生成房间门"""
	# 这里可以根据房间连接情况生成门
	# 暂时留空，后续可以扩展
	pass

func _set_tile_type(position: Vector3, tile_type: int) -> void:
	"""设置地块类型"""
	if tile_manager:
		tile_manager.set_tile_type(position, tile_type)

# 调试功能
func debug_print_room_info(room) -> void:
	"""调试：打印房间信息"""
	LogManager.log_map_static("房间 " + " " + str(room.room_id) + " 信息:" + str(room.room_id))
	LogManager.log_map_static("  位置: " + " " + str(room.position))
	LogManager.log_map_static("  大小: " + " " + str(room.size))
	LogManager.log_map_static("  中心: " + " " + str(room.center))
	LogManager.log_map_static("  连接数: " + " " + str(room.connections.size()))
