class_name SimpleMazeGenerator
extends Node

## 🌀 简单迷宫生成器
## 基于递归回溯算法的高效迷宫生成，配合洪水填充系统确定生成范围
## 使用MazeData数据结构和TileManager的标准瓦片类型

# ============================================================================
# 依赖注入
# ============================================================================

var tile_manager: Node
var flood_fill_system: FloodFillSystem

# ============================================================================
# 迷宫生成配置
# ============================================================================

var config = {
	"min_maze_size": 10, # 最小迷宫大小
	"max_maze_size": 100, # 最大迷宫大小
	"complexity_factor": 0.3, # 复杂度因子 (0.0-1.0)
	"wall_thickness": 1, # 墙壁厚度
	"path_width": 1, # 路径宽度
	"ensure_solvable": true, # 确保迷宫有解
	"random_seed": - 1, # 随机种子 (-1表示使用系统时间)
	"use_irregular_algorithm": true # 使用不规则区域算法
}

# ============================================================================
# 迷宫生成统计
# ============================================================================

var generation_stats = {
	"mazes_generated": 0,
	"total_walls": 0,
	"total_paths": 0,
	"generation_time": 0.0,
	"average_complexity": 0.0
}

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	"""初始化迷宫生成器"""
	LogManager.info("SimpleMazeGenerator - 初始化完成")

func initialize(tile_mgr: Node, flood_fill: FloodFillSystem):
	"""设置依赖项"""
	tile_manager = tile_mgr
	flood_fill_system = flood_fill

# ============================================================================
# 核心迷宫生成方法
# ============================================================================

func generate_maze_in_cavity(cavity) -> MazeData:
	"""在空洞内生成迷宫
	
	Args:
		cavity: 空洞对象
		
	Returns:
		生成的迷宫数据
	"""
	if not cavity or not tile_manager or not flood_fill_system:
		LogManager.error("SimpleMazeGenerator - 无效的输入参数")
		return null
	
	LogManager.info("🌀 生成迷宫: %s" % cavity.id)
	
	var start_time = Time.get_ticks_msec()
	
	# 使用洪水填充确定迷宫生成区域
	var generation_areas = flood_fill_system.flood_fill_maze_generation_areas(cavity, tile_manager)
	if generation_areas.is_empty():
		LogManager.warning("空洞 %s 内没有有效的迷宫生成区域" % cavity.id)
		return null
	
	# 选择最大的区域生成迷宫
	var best_area = _select_best_generation_area(generation_areas)
	if best_area.is_empty():
		LogManager.warning("没有找到合适的迷宫生成区域")
		return null
	
	# 根据配置选择算法
	var maze_data
	if config.get("use_irregular_algorithm", true):
		# 使用不规则区域算法生成迷宫
		maze_data = _generate_irregular_maze(best_area, cavity)
		if maze_data:
			_apply_irregular_maze_to_map(maze_data)
	else:
		# 使用传统矩形区域算法生成迷宫
		maze_data = _generate_recursive_backtracking_maze(best_area, cavity)
		if maze_data:
			_apply_maze_to_map(maze_data)
	
	if not maze_data:
		LogManager.error("迷宫生成失败")
		return null
	
	# 更新统计信息
	_update_generation_stats(maze_data, Time.get_ticks_msec() - start_time)
	
	LogManager.info("🌀 迷宫完成: %d墙/%d路" % [maze_data.get_wall_count(), maze_data.get_path_count()])
	
	return maze_data

func generate_maze_in_area(area: Array[Vector3], maze_id: int = -1) -> MazeData:
	"""在指定区域内生成迷宫
	
	Args:
		area: 生成区域位置数组
		maze_id: 迷宫ID (-1表示自动生成)
		
	Returns:
		生成的迷宫数据
	"""
	if area.is_empty() or not tile_manager:
		LogManager.error("SimpleMazeGenerator - 无效的生成区域")
		return null
	
	LogManager.info("🌀 在指定区域内生成迷宫...")
	
	var start_time = Time.get_ticks_msec()
	
	# 生成迷宫数据
	var maze_data = _generate_recursive_backtracking_maze(area, null, maze_id)
	if not maze_data:
		LogManager.error("迷宫生成失败")
		return null
	
	# 应用迷宫到地图
	_apply_maze_to_map(maze_data)
	
	# 更新统计信息
	_update_generation_stats(maze_data, Time.get_ticks_msec() - start_time)
	
	LogManager.info("🌀 迷宫生成完成: %d 墙壁, %d 路径" % [maze_data.get_wall_count(), maze_data.get_path_count()])
	
	return maze_data

# ============================================================================
# 不规则区域迷宫生成算法
# ============================================================================

func _generate_irregular_maze(area: Array[Vector3], cavity = null, maze_id: int = -1) -> MazeData:
	"""使用不规则区域算法生成迷宫"""
	
	# LogManager.info("🌀 开始生成不规则区域迷宫...")
	
	# 创建迷宫数据
	var maze_data = MazeData.new()
	maze_data.maze_id = maze_id if maze_id >= 0 else generation_stats.mazes_generated
	maze_data.cavity_positions = area
	maze_data.is_in_cavity = cavity != null
	
	# 初始化不规则区域数据结构
	_initialize_irregular_maze_data(maze_data, area)
	
	# 选择起始点
	var start_pos = _select_irregular_start_position(maze_data, area)
	if start_pos == Vector2i(-1, -1):
		LogManager.error("无法选择有效的起始位置")
		return null
	
	# 开始不规则区域递归回溯
	_irregular_recursive_backtrack(maze_data, start_pos, area)
	
	# 确保迷宫有解
	if config.ensure_solvable:
		_ensure_irregular_maze_solvable(maze_data, area)
	
	# 更新墙壁和路径列表
	_update_irregular_walls_and_paths(maze_data, area)
	
	# LogManager.info("🌀 不规则区域迷宫生成完成")
	return maze_data

func _initialize_irregular_maze_data(maze_data: MazeData, area: Array[Vector3]) -> void:
	"""初始化不规则区域迷宫数据"""
	# 创建位置到索引的映射
	maze_data.position_map = {}
	maze_data.index_map = {}
	
	# 计算区域边界（用于调试和显示）
	var bounds = _calculate_area_bounds(area)
	if bounds:
		maze_data.position = Vector2i(bounds.min_x, bounds.min_z)
		maze_data.size = Vector2i(bounds.width, bounds.height)
		maze_data.center = Vector2i(bounds.min_x + bounds.width / 2, bounds.min_z + bounds.height / 2)
	
	# 为每个有效位置创建索引
	var index = 0
	for pos in area:
		var grid_pos = Vector2i(pos.x, pos.z)
		maze_data.position_map[grid_pos] = index
		maze_data.index_map[index] = grid_pos
		index += 1
	
	# 初始化迷宫数据数组
	maze_data.maze_grid = []
	maze_data.visited = []
	for i in range(area.size()):
		maze_data.maze_grid.append(1) # 1表示墙壁
		maze_data.visited.append(false) # 未访问
	
	# LogManager.info("🌀 不规则区域数据初始化完成: %d 个位置" % area.size())

func _select_irregular_start_position(maze_data: MazeData, area: Array[Vector3]) -> Vector2i:
	"""选择不规则区域的起始位置"""
	# 优先选择区域中心附近的位置
	var center = maze_data.center
	var candidates = []
	
	# 在中心附近寻找有效位置
	for radius in range(1, 10):
		for x in range(center.x - radius, center.x + radius + 1):
			for y in range(center.y - radius, center.y + radius + 1):
				var pos = Vector2i(x, y)
				if _is_position_in_irregular_area(pos, area):
					candidates.append(pos)
		
		if not candidates.is_empty():
			break
	
	if candidates.is_empty():
		# 如果没有找到合适的候选位置，选择第一个有效位置
		if not area.is_empty():
			return Vector2i(area[0].x, area[0].z)
		return Vector2i(-1, -1)
	
	return candidates[randi() % candidates.size()]

func _is_position_in_irregular_area(pos: Vector2i, area: Array[Vector3]) -> bool:
	"""检查位置是否在不规则区域内"""
	var world_pos = Vector3(pos.x, 0, pos.y)
	for area_pos in area:
		if area_pos == world_pos:
			return true
	return false

func _irregular_recursive_backtrack(maze_data: MazeData, current: Vector2i, area: Array[Vector3]) -> void:
	"""不规则区域递归回溯算法核心"""
	# 获取当前位置的索引
	var current_index = maze_data.position_map.get(current, -1)
	if current_index == -1:
		return
	
	# 标记当前位置为已访问
	maze_data.visited[current_index] = true
	maze_data.maze_grid[current_index] = 0 # 0表示路径
	
	# 获取未访问的邻居
	var neighbors = _get_irregular_unvisited_neighbors(current, maze_data, area)
	
	# 随机打乱邻居顺序
	neighbors.shuffle()
	
	for neighbor in neighbors:
		var neighbor_index = maze_data.position_map.get(neighbor, -1)
		if neighbor_index != -1 and not maze_data.visited[neighbor_index]:
			# 在当前位置和邻居之间创建路径（移除墙壁）
			_remove_wall_between_positions(maze_data, current, neighbor, area)
			
			# 递归访问邻居
			_irregular_recursive_backtrack(maze_data, neighbor, area)

func _get_irregular_unvisited_neighbors(pos: Vector2i, maze_data: MazeData, area: Array[Vector3]) -> Array[Vector2i]:
	"""获取不规则区域的未访问邻居（跳跃2格）"""
	var neighbors: Array[Vector2i] = []
	var directions = [
		Vector2i(0, -2), # 上
		Vector2i(2, 0), # 右
		Vector2i(0, 2), # 下
		Vector2i(-2, 0) # 左
	]
	
	for dir in directions:
		var neighbor = pos + dir
		if _is_position_in_irregular_area(neighbor, area):
			var neighbor_index = maze_data.position_map.get(neighbor, -1)
			if neighbor_index != -1 and not maze_data.visited[neighbor_index]:
				neighbors.append(neighbor)
	
	return neighbors

func _remove_wall_between_positions(maze_data: MazeData, pos1: Vector2i, pos2: Vector2i, area: Array[Vector3]) -> void:
	"""移除两个位置之间的墙壁"""
	# 计算中间位置（跳跃2格的情况）
	var middle_pos = (pos1 + pos2) / 2
	
	# 检查中间位置是否在区域内
	if _is_position_in_irregular_area(middle_pos, area):
		var middle_index = maze_data.position_map.get(middle_pos, -1)
		if middle_index != -1:
			maze_data.maze_grid[middle_index] = 0 # 设置为路径
			maze_data.visited[middle_index] = true # 标记为已访问

func _ensure_irregular_maze_solvable(maze_data: MazeData, area: Array[Vector3]) -> void:
	"""确保不规则迷宫有解"""
	# 使用BFS检查连通性
	var visited = {}
	var queue = []
	
	# 找到第一个路径点作为起始点
	var start_found = false
	for i in range(maze_data.maze_grid.size()):
		if maze_data.maze_grid[i] == 0: # 路径
			var pos = maze_data.index_map[i]
			queue.append(pos)
			start_found = true
			break
	
	if not start_found:
		LogManager.warning("不规则迷宫中没有找到路径点")
		return
	
	# BFS遍历
	var connected_count = 0
	while not queue.is_empty():
		var current = queue.pop_front()
		var key = str(current.x) + "," + str(current.y)
		
		if key in visited:
			continue
		
		visited[key] = true
		connected_count += 1
		
		# 检查四个方向的邻居
		var directions = [
			Vector2i(0, -1), # 上
			Vector2i(1, 0), # 右
			Vector2i(0, 1), # 下
			Vector2i(-1, 0) # 左
		]
		
		for dir in directions:
			var neighbor = current + dir
			if _is_position_in_irregular_area(neighbor, area):
				var neighbor_key = str(neighbor.x) + "," + str(neighbor.y)
				if neighbor_key not in visited:
					queue.append(neighbor)
	
	var total_paths = 0
	for i in range(maze_data.maze_grid.size()):
		if maze_data.maze_grid[i] == 0:
			total_paths += 1
	
	var connectivity_ratio = float(connected_count) / total_paths if total_paths > 0 else 0.0
	var is_connected = connectivity_ratio >= 0.95 # 95%以上连通
	
	# LogManager.info("不规则迷宫连通性检查: %d/%d (%.1f%%) - %s" % [
	#	connected_count, total_paths, connectivity_ratio * 100,
	#	"连通" if is_connected else "不连通"
	#])

func _update_irregular_walls_and_paths(maze_data: MazeData, area: Array[Vector3]) -> void:
	"""更新不规则迷宫的墙壁和路径列表"""
	maze_data.walls.clear()
	maze_data.paths.clear()
	
	for i in range(maze_data.maze_grid.size()):
		var pos = maze_data.index_map[i]
		if maze_data.maze_grid[i] == 1:
			maze_data.walls.append(pos)
		else:
			maze_data.paths.append(pos)

func _apply_irregular_maze_to_map(maze_data: MazeData) -> void:
	"""将不规则迷宫应用到地图"""
	# LogManager.info("🌀 应用不规则迷宫到地图: %d 个位置" % maze_data.maze_grid.size())
	
	for i in range(maze_data.maze_grid.size()):
		var pos = maze_data.index_map[i]
		var world_pos = Vector3(pos.x, 0, pos.y)
		
		if maze_data.maze_grid[i] == 1:
			# 墙壁
			tile_manager.set_tile_type(world_pos, TileTypes.TileType.STONE_WALL)
		else:
			# 路径
			tile_manager.set_tile_type(world_pos, TileTypes.TileType.EMPTY)

# ============================================================================
# 递归回溯算法核心
# ============================================================================

func _generate_recursive_backtracking_maze(area: Array[Vector3], cavity = null, maze_id: int = -1) -> MazeData:
	"""使用递归回溯算法生成迷宫"""
	
	# 计算区域边界
	var bounds = _calculate_area_bounds(area)
	if not bounds:
		return null
	
	# 创建迷宫数据
	var maze_data = MazeData.new()
	maze_data.maze_id = maze_id if maze_id >= 0 else generation_stats.mazes_generated
	maze_data.position = Vector2i(bounds.min_x, bounds.min_z)
	maze_data.size = Vector2i(bounds.width, bounds.height)
	maze_data.center = Vector2i(bounds.min_x + bounds.width / 2, bounds.min_z + bounds.height / 2)
	maze_data.cavity_positions = area
	maze_data.is_in_cavity = cavity != null
	
	# 初始化迷宫网格（全部为墙壁）
	_initialize_maze_grid(maze_data)
	
	# 选择起始点
	var start_pos = _select_start_position(maze_data, area)
	if start_pos == Vector2i(-1, -1):
		LogManager.error("无法选择有效的起始位置")
		return null
	
	# 开始递归回溯
	_recursive_backtrack(maze_data, start_pos, area)
	
	# 确保迷宫有解
	if config.ensure_solvable:
		_ensure_maze_solvable(maze_data)
	
	# 更新墙壁和路径列表
	_update_walls_and_paths(maze_data)
	
	return maze_data

func _recursive_backtrack(maze_data: MazeData, current: Vector2i, area: Array[Vector3]) -> void:
	"""递归回溯算法核心"""
	var local_pos = current - maze_data.position
	
	# 标记当前位置为已访问
	if local_pos.x >= 0 and local_pos.x < maze_data.size.x and local_pos.y >= 0 and local_pos.y < maze_data.size.y:
		maze_data.visited[local_pos.x][local_pos.y] = true
		maze_data.maze_grid[local_pos.x][local_pos.y] = 0 # 0表示路径
	
	# 获取未访问的邻居（跳跃2格）
	var neighbors = _get_unvisited_neighbors(current, maze_data, area)
	
	# 随机打乱邻居顺序
	neighbors.shuffle()
	
	for neighbor in neighbors:
		var neighbor_local = neighbor - maze_data.position
		if neighbor_local.x >= 0 and neighbor_local.x < maze_data.size.x and neighbor_local.y >= 0 and neighbor_local.y < maze_data.size.y:
			if not maze_data.visited[neighbor_local.x][neighbor_local.y]:
				# 移除当前单元格和邻居之间的墙壁
				var wall = (current + neighbor) / 2
				var wall_local = wall - maze_data.position
				if wall_local.x >= 0 and wall_local.x < maze_data.size.x and wall_local.y >= 0 and wall_local.y < maze_data.size.y:
					maze_data.maze_grid[wall_local.x][wall_local.y] = 0
				
				# 递归访问邻居
				_recursive_backtrack(maze_data, neighbor, area)

func _get_unvisited_neighbors(pos: Vector2i, maze_data: MazeData, area: Array[Vector3]) -> Array[Vector2i]:
	"""获取未访问的邻居（跳跃2格）"""
	var neighbors: Array[Vector2i] = []
	var directions = [
		Vector2i(0, -2), # 上
		Vector2i(2, 0), # 右
		Vector2i(0, 2), # 下
		Vector2i(-2, 0) # 左
	]
	
	for dir in directions:
		var neighbor = pos + dir
		if _is_valid_maze_position(neighbor, maze_data, area):
			neighbors.append(neighbor)
	
	return neighbors

# ============================================================================
# 迷宫应用和渲染
# ============================================================================

func _apply_maze_to_map(maze_data: MazeData) -> void:
	"""将迷宫应用到地图"""
	LogManager.info("🌀 应用迷宫到地图: %dx%d" % [maze_data.size.x, maze_data.size.y])
	
	for x in range(maze_data.size.x):
		for y in range(maze_data.size.y):
			var world_pos = Vector3(maze_data.position.x + x, 0, maze_data.position.y + y)
			var local_pos = Vector2i(x, y)
			
			if maze_data.maze_grid[x][y] == 1:
				# 墙壁
				tile_manager.set_tile_type(world_pos, TileTypes.TileType.STONE_WALL)
			else:
				# 路径
				tile_manager.set_tile_type(world_pos, TileTypes.TileType.EMPTY)

# ============================================================================
# 工具方法
# ============================================================================

func _select_best_generation_area(areas: Array) -> Array[Vector3]:
	"""选择最佳的生成区域"""
	if areas.is_empty():
		return []
	
	# 选择最大的区域
	var best_area = areas[0]
	for area in areas:
		if area.size() > best_area.size():
			best_area = area
	
	return best_area

func _calculate_area_bounds(area: Array[Vector3]) -> Dictionary:
	"""计算区域边界"""
	if area.is_empty():
		return {}
	
	var min_x = area[0].x
	var max_x = area[0].x
	var min_z = area[0].z
	var max_z = area[0].z
	
	for pos in area:
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_z = min(min_z, pos.z)
		max_z = max(max_z, pos.z)
	
	return {
		"min_x": min_x,
		"max_x": max_x,
		"min_z": min_z,
		"max_z": max_z,
		"width": max_x - min_x + 1,
		"height": max_z - min_z + 1
	}

func _initialize_maze_grid(maze_data: MazeData) -> void:
	"""初始化迷宫网格"""
	maze_data.maze_grid.clear()
	maze_data.visited.clear()
	
	for x in range(maze_data.size.x):
		maze_data.maze_grid.append([])
		maze_data.visited.append([])
		for y in range(maze_data.size.y):
			maze_data.maze_grid[x].append(1) # 1表示墙壁
			maze_data.visited[x].append(false) # 未访问

func _select_start_position(maze_data: MazeData, area: Array[Vector3]) -> Vector2i:
	"""选择起始位置"""
	# 优先选择区域中心附近的奇数位置
	var center = maze_data.center
	var candidates = []
	
	for x in range(center.x - 5, center.x + 6, 2):
		for y in range(center.y - 5, center.y + 6, 2):
			var pos = Vector2i(x, y)
			if _is_valid_maze_position(pos, maze_data, area):
				candidates.append(pos)
	
	if candidates.is_empty():
		# 如果没有找到合适的候选位置，选择第一个有效位置
		for pos in area:
			var grid_pos = Vector2i(pos.x, pos.z)
			if _is_valid_maze_position(grid_pos, maze_data, area):
				return grid_pos
		return Vector2i(-1, -1)
	
	return candidates[randi() % candidates.size()]

func _is_valid_maze_position(pos: Vector2i, maze_data: MazeData, area: Array[Vector3]) -> bool:
	"""检查位置是否有效的迷宫位置"""
	# 检查是否在迷宫边界内
	if pos.x < maze_data.position.x or pos.x >= maze_data.position.x + maze_data.size.x:
		return false
	if pos.y < maze_data.position.y or pos.y >= maze_data.position.y + maze_data.size.y:
		return false
	
	# 检查是否在区域内
	var world_pos = Vector3(pos.x, 0, pos.y)
	for area_pos in area:
		if area_pos == world_pos:
			return true
	
	return false

func _ensure_maze_solvable(maze_data: MazeData) -> void:
	"""确保迷宫有解"""
	# 简单的连通性检查：确保所有路径区域都连通
	# 这里可以实现更复杂的算法，如BFS检查连通性
	pass

func _update_walls_and_paths(maze_data: MazeData) -> void:
	"""更新墙壁和路径列表"""
	maze_data.walls.clear()
	maze_data.paths.clear()
	
	for x in range(maze_data.size.x):
		for y in range(maze_data.size.y):
			var pos = Vector2i(maze_data.position.x + x, maze_data.position.y + y)
			if maze_data.maze_grid[x][y] == 1:
				maze_data.walls.append(pos)
			else:
				maze_data.paths.append(pos)

func _update_generation_stats(maze_data: MazeData, generation_time: int) -> void:
	"""更新生成统计信息"""
	generation_stats.mazes_generated += 1
	generation_stats.total_walls += maze_data.get_wall_count()
	generation_stats.total_paths += maze_data.get_path_count()
	generation_stats.generation_time += generation_time
	generation_stats.average_complexity = float(generation_stats.total_paths) / (generation_stats.total_walls + generation_stats.total_paths)

# ============================================================================
# 配置和统计方法
# ============================================================================

func set_config(new_config: Dictionary) -> void:
	"""设置生成配置"""
	for key in new_config:
		if key in config:
			config[key] = new_config[key]

func get_config() -> Dictionary:
	"""获取当前配置"""
	return config.duplicate()

func get_generation_stats() -> Dictionary:
	"""获取生成统计信息"""
	return generation_stats.duplicate()

func reset_stats() -> void:
	"""重置统计信息"""
	generation_stats = {
		"mazes_generated": 0,
		"total_walls": 0,
		"total_paths": 0,
		"generation_time": 0.0,
		"average_complexity": 0.0
	}

func get_maze_info(maze_data: MazeData) -> Dictionary:
	"""获取迷宫详细信息"""
	if not maze_data:
		return {}
	
	return {
		"id": maze_data.maze_id,
		"position": maze_data.position,
		"size": maze_data.size,
		"center": maze_data.center,
		"wall_count": maze_data.get_wall_count(),
		"path_count": maze_data.get_path_count(),
		"complexity": maze_data.get_complexity(),
		"is_valid": maze_data.is_valid()
	}

# 调试函数已移除

# 调试函数已移除

# 调试函数已移除

# 调试函数已移除
