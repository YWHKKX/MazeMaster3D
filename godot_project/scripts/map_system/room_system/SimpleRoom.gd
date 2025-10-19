class_name SimpleRoom
extends RefCounted

## 🏠 简化房间数据结构
## 基于矩形房间的简单设计，完全使用TileManager的瓦片类型

# ============================================================================
# 基础属性
# ============================================================================

var room_id: int
var position: Vector2i # 房间左上角位置
var size: Vector2i # 房间大小 (宽x高)
var center: Vector2i # 房间中心
var room_type: String = "normal"

# 空洞约束
var cavity_positions: Array[Vector3] # 洪水填充标记的空洞位置
var is_in_cavity: bool = true

# 连接信息
var exits: Array[Vector2i] # 出口位置列表
var connected_rooms: Array[int] # 连接的房间ID列表

# 内部布局
var internal_walls: Array[Vector2i] # 内部墙壁位置
var floor_variations: Array[Vector2i] # 地板变化位置（破旧效果）

# 瓦片类型映射
var tile_types = {
	"floor": TileTypes.TileType.STONE_FLOOR,
	"wall": TileTypes.TileType.STONE_WALL,
	"corridor": TileTypes.TileType.CORRIDOR,
	"exit": TileTypes.TileType.EMPTY
}

# ============================================================================
# 构造函数
# ============================================================================

func _init(room_id: int = 0, pos: Vector2i = Vector2i.ZERO, room_size: Vector2i = Vector2i(4, 4)):
	self.room_id = room_id
	self.position = pos
	self.size = room_size
	self.center = pos + room_size / 2
	self.exits = []
	self.connected_rooms = []
	self.internal_walls = []
	self.floor_variations = []

# ============================================================================
# 基础方法
# ============================================================================

func get_rect() -> Rect2i:
	"""获取房间矩形区域"""
	return Rect2i(position, size)

func contains_position(pos: Vector2i) -> bool:
	"""检查位置是否在房间内"""
	var rect = get_rect()
	return rect.has_point(pos)

func add_exit(pos: Vector2i):
	"""添加出口位置"""
	if not exits.has(pos):
		exits.append(pos)

func is_connected_to(room_id: int) -> bool:
	"""检查是否连接到指定房间"""
	return connected_rooms.has(room_id)

func get_area() -> int:
	"""获取房间面积"""
	return size.x * size.y

func get_perimeter() -> int:
	"""获取房间周长"""
	return 2 * (size.x + size.y)

# ============================================================================
# 房间布局方法
# ============================================================================

func add_internal_wall(pos: Vector2i):
	"""添加内部墙壁"""
	if not internal_walls.has(pos):
		internal_walls.append(pos)

func add_floor_variation(pos: Vector2i):
	"""添加地板变化（破旧效果）"""
	if not floor_variations.has(pos):
		floor_variations.append(pos)

func is_internal_wall(pos: Vector2i) -> bool:
	"""检查位置是否是内部墙壁"""
	return internal_walls.has(pos)

func is_floor_variation(pos: Vector2i) -> bool:
	"""检查位置是否是地板变化"""
	return floor_variations.has(pos)

# ============================================================================
# 房间连接方法
# ============================================================================

func connect_to_room(other_room_id: int):
	"""连接到另一个房间"""
	if not connected_rooms.has(other_room_id):
		connected_rooms.append(other_room_id)

func disconnect_from_room(other_room_id: int):
	"""断开与另一个房间的连接"""
	connected_rooms.erase(other_room_id)

func get_connection_count() -> int:
	"""获取连接数量"""
	return connected_rooms.size()

# ============================================================================
# 房间验证方法
# ============================================================================

func is_valid() -> bool:
	"""检查房间是否有效"""
	# 基本尺寸检查
	if size.x < 3 or size.y < 3:
		return false
	
	# 必须有至少一个出口
	if exits.is_empty():
		return false
	
	return true

func can_place_at(pos: Vector2i, room_size: Vector2i) -> bool:
	"""检查是否可以在指定位置放置房间"""
	# 检查边界
	if pos.x < 0 or pos.y < 0:
		return false
	
	# 检查尺寸
	if room_size.x < 3 or room_size.y < 3:
		return false
	
	return true

# ============================================================================
# 调试方法
# ============================================================================

func get_debug_info() -> String:
	"""获取调试信息"""
	return "Room #%d: pos(%d,%d) size(%dx%d) exits:%d connections:%d" % [
		room_id, position.x, position.y, size.x, size.y, exits.size(), connected_rooms.size()
	]

func print_debug_info():
	"""打印调试信息"""
	LogManager.info(get_debug_info())
