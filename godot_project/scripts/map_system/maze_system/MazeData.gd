class_name MazeData
extends RefCounted

## 🌀 迷宫数据结构
## 用于存储迷宫的基础属性和数据

# ============================================================================
# 迷宫基础属性
# ============================================================================

var maze_id: int
var position: Vector2i # 迷宫左上角位置
var size: Vector2i # 迷宫大小 (宽x高)
var center: Vector2i # 迷宫中心

# ============================================================================
# 洪水填充约束
# ============================================================================

var cavity_positions: Array[Vector3] # 洪水填充标记的位置
var is_in_cavity: bool = true

# ============================================================================
# 迷宫数据
# ============================================================================

var maze_grid: Array # 迷宫网格数据（支持不规则区域）
var visited: Array # 访问标记（支持不规则区域）
var walls: Array[Vector2i] # 墙壁位置列表
var paths: Array[Vector2i] # 路径位置列表

# 不规则区域支持
var position_map: Dictionary # 位置到索引的映射
var index_map: Dictionary # 索引到位置的映射

# ============================================================================
# 瓦片类型映射
# ============================================================================

var tile_types = {
	"wall": TileTypes.TileType.STONE_WALL,
	"path": TileTypes.TileType.EMPTY,
	"visited": TileTypes.TileType.EMPTY
}

# ============================================================================
# 基础方法
# ============================================================================

func get_rect() -> Rect2i:
	"""获取迷宫矩形区域"""
	return Rect2i(position, size)

func contains_position(pos: Vector2i) -> bool:
	"""检查位置是否在迷宫内"""
	var rect = get_rect()
	return rect.has_point(pos)

func is_wall(pos: Vector2i) -> bool:
	"""检查位置是否为墙壁"""
	# 支持不规则区域
	if position_map.has(pos):
		var index = position_map[pos]
		return maze_grid[index] == 1
	
	# 支持矩形区域（向后兼容）
	if not contains_position(pos):
		return true
	var local_pos = pos - position
	if local_pos.x >= 0 and local_pos.x < size.x and local_pos.y >= 0 and local_pos.y < size.y:
		return maze_grid[local_pos.x][local_pos.y] == 1
	return true

func is_path(pos: Vector2i) -> bool:
	"""检查位置是否为路径"""
	# 支持不规则区域
	if position_map.has(pos):
		var index = position_map[pos]
		return maze_grid[index] == 0
	
	# 支持矩形区域（向后兼容）
	if not contains_position(pos):
		return false
	var local_pos = pos - position
	if local_pos.x >= 0 and local_pos.x < size.x and local_pos.y >= 0 and local_pos.y < size.y:
		return maze_grid[local_pos.x][local_pos.y] == 0
	return false

func get_wall_count() -> int:
	"""获取墙壁数量"""
	return walls.size()

func get_path_count() -> int:
	"""获取路径数量"""
	return paths.size()

func get_complexity() -> float:
	"""获取迷宫复杂度（路径数/总格子数）"""
	var total_cells = size.x * size.y
	if total_cells == 0:
		return 0.0
	return float(paths.size()) / float(total_cells)

func is_valid() -> bool:
	"""检查迷宫数据是否有效"""
	return maze_id >= 0 and size.x > 0 and size.y > 0 and not maze_grid.is_empty()

func get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	"""获取位置的邻居（4方向）"""
	var neighbors: Array[Vector2i] = []
	var directions = [
		Vector2i(0, -1), # 上
		Vector2i(1, 0), # 右
		Vector2i(0, 1), # 下
		Vector2i(-1, 0) # 左
	]
	
	for dir in directions:
		var neighbor = pos + dir
		if contains_position(neighbor):
			neighbors.append(neighbor)
	
	return neighbors

func get_diagonal_neighbors(pos: Vector2i) -> Array[Vector2i]:
	"""获取位置的对角线邻居（8方向）"""
	var neighbors: Array[Vector2i] = []
	var directions = [
		Vector2i(-1, -1), # 左上
		Vector2i(0, -1), # 上
		Vector2i(1, -1), # 右上
		Vector2i(1, 0), # 右
		Vector2i(1, 1), # 右下
		Vector2i(0, 1), # 下
		Vector2i(-1, 1), # 左下
		Vector2i(-1, 0) # 左
	]
	
	for dir in directions:
		var neighbor = pos + dir
		if contains_position(neighbor):
			neighbors.append(neighbor)
	
	return neighbors

func clear_data():
	"""清空迷宫数据"""
	maze_grid.clear()
	visited.clear()
	walls.clear()
	paths.clear()
	maze_id = -1
	position = Vector2i.ZERO
	size = Vector2i.ZERO
	center = Vector2i.ZERO
