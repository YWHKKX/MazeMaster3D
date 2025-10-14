extends Node

## GridPathFinder - AStarGrid2D动态网格寻路系统
## 
## 替代NavigationMesh烘焙系统，提供高性能的网格寻路
## 参考: docs/ASTAR_GRID_NAVIGATION_REFACTOR.md

# ============================================================================
# 核心数据
# ============================================================================

## AStarGrid2D实例
var astar_grid: AStarGrid2D = null

## 地图尺寸（从TileManager获取）
var map_size: Vector2i = Vector2i(100, 100)

## 单元格大小（世界坐标）
var cell_size: Vector2 = Vector2(1.0, 1.0)

## 是否已初始化
var is_initialized: bool = false

# ============================================================================
# 配置参数
# ============================================================================

## 对角线移动模式
enum DiagonalMode {
	NEVER, # 禁止对角线
	ALWAYS, # 总是允许
	AT_LEAST_ONE_WALKABLE, # 至少一侧可通行
	ONLY_IF_NO_OBSTACLES # 无障碍时允许
}

var diagonal_mode: DiagonalMode = DiagonalMode.NEVER

# ============================================================================
# 性能优化
# ============================================================================

## 路径缓存
var path_cache: Dictionary = {} # key: "start_x,start_z->end_x,end_z"
var cache_enabled: bool = true
var cache_max_size: int = 100
var cache_timeout: float = 5.0 # 缓存超时（秒）

## 批量更新
var pending_updates: Array = []
var update_timer: float = 0.0
var batch_update_interval: float = 0.1 # 批量更新间隔

## 流场寻路（可选）
var flow_field_cache: Dictionary = {}
var flow_field_target: Vector2i = Vector2i(-1, -1)
var flow_field_dirty: bool = true

# ============================================================================
# 统计信息
# ============================================================================

var stats = {
	"total_path_queries": 0,
	"cache_hits": 0,
	"cache_misses": 0,
	"avg_path_length": 0.0,
	"avg_query_time_ms": 0.0,
	"last_update_time": 0.0
}

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	"""GridPathFinder自动加载初始化"""
	LogManager.info("GridPathFinder - 初始化开始（Autoload）")
	
	# 等待其他系统就绪
	await get_tree().process_frame
	
	# 连接地图生成事件
	if GameEvents.has_signal("map_generated"):
		GameEvents.map_generated.connect(_on_map_generated)
		LogManager.info("GridPathFinder - 已连接map_generated事件")
	
	LogManager.info("GridPathFinder - 等待地图生成完成...")


func _on_map_generated():
	"""地图生成完成后初始化AStarGrid"""
	LogManager.info("GridPathFinder - 收到map_generated事件，开始初始化AStarGrid...")
	
	# 🔧 修复：直接从场景树获取TileManager，避免时序问题
	# 原因：map_generated信号发射时，TileManager可能还没注册到GameServices
	var tile_manager = get_node_or_null("/root/Main/TileManager")
	
	# 后备方案：尝试从GameServices获取
	if not tile_manager:
		tile_manager = GameServices.tile_manager
	
	if not tile_manager:
		LogManager.error("GridPathFinder - TileManager未找到（场景树和GameServices都没有），延迟1秒重试...")
		# 延迟重试
		await get_tree().create_timer(1.0).timeout
		tile_manager = GameServices.tile_manager
		if not tile_manager:
			LogManager.error("GridPathFinder - 重试失败，无法初始化")
			return
	
	# 从TileManager初始化
	initialize_from_tile_manager(tile_manager)


func initialize_from_tile_manager(tile_mgr):
	"""从TileManager初始化AStarGrid2D
	
	Args:
		tile_mgr: TileManager实例
	"""
	if is_initialized:
		LogManager.warning("GridPathFinder - 已经初始化，跳过")
		return
	
	LogManager.info("GridPathFinder - 开始从TileManager初始化...")
	
	# 获取地图尺寸
	var tile_map_size = tile_mgr.get_map_size()
	map_size = Vector2i(int(tile_map_size.x), int(tile_map_size.z))
	
	# 创建AStarGrid2D
	astar_grid = AStarGrid2D.new()
	astar_grid.region = Rect2i(0, 0, map_size.x, map_size.y)
	astar_grid.cell_size = cell_size
	
	# 设置对角线模式
	match diagonal_mode:
		DiagonalMode.NEVER:
			astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
		DiagonalMode.ALWAYS:
			astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
		DiagonalMode.AT_LEAST_ONE_WALKABLE:
			astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
		DiagonalMode.ONLY_IF_NO_OBSTACLES:
			astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	
	astar_grid.update()
	
	LogManager.info("GridPathFinder - AStarGrid2D创建完成")
	LogManager.info("  - 区域: %s" % str(astar_grid.region))
	LogManager.info("  - 单元格大小: %s" % str(cell_size))
	LogManager.info("  - 对角线模式: %s" % str(diagonal_mode))
	
	# 从TileManager同步初始状态
	_sync_from_tile_manager(tile_mgr)
	
	is_initialized = true
	LogManager.info("GridPathFinder - 初始化完成！")


func _sync_from_tile_manager(tile_mgr):
	"""从TileManager同步所有地块的可通行状态"""
	var walkable_count = 0
	var blocked_count = 0
	
	LogManager.info("GridPathFinder - 开始同步地块状态...")
	
	for x in range(map_size.x):
		for z in range(map_size.y):
			var world_pos = Vector3(x, 0, z)
			var tile_data = tile_mgr.get_tile_data(world_pos)
			
			# 默认为阻挡
			var is_solid = true
			
			if tile_data:
				# 可通行的地块设置为非阻挡
				is_solid = not tile_data.is_walkable
			
			astar_grid.set_point_solid(Vector2i(x, z), is_solid)
			
			if is_solid:
				blocked_count += 1
			else:
				walkable_count += 1
	
	LogManager.info("GridPathFinder - 同步完成！")
	LogManager.info("  - 可通行地块: %d" % walkable_count)
	LogManager.info("  - 阻挡地块: %d" % blocked_count)
	LogManager.info("  - 总地块: %d" % (walkable_count + blocked_count))
	LogManager.info("  - 可通行率: %.1f%%" % (walkable_count * 100.0 / (walkable_count + blocked_count)))

# ============================================================================
# 核心寻路API
# ============================================================================


func is_position_reachable(start_world: Vector3, end_world: Vector3) -> bool:
	"""检查从起点到终点是否可达
	
	Args:
		start_world: 起点世界坐标
		end_world: 终点世界坐标
	
	Returns:
		bool: 是否可达
	"""
	if not is_initialized:
		return false
	
	var start_grid = world_to_grid(start_world)
	var end_grid = world_to_grid(end_world)
	
	if not _is_valid_grid_pos(start_grid) or not _is_valid_grid_pos(end_grid):
		return false
	
	if astar_grid.is_point_solid(start_grid) or astar_grid.is_point_solid(end_grid):
		return false
	
	# 快速检查：获取路径
	var grid_path = astar_grid.get_id_path(start_grid, end_grid)
	return grid_path.size() > 0

# ============================================================================
# 动态更新API
# ============================================================================

func set_cell_walkable(grid_pos: Vector2i, walkable: bool):
	"""设置单个格子的可通行状态（立即更新）
	
	Args:
		grid_pos: 网格坐标
		walkable: 是否可通行
	"""
	if not is_initialized:
		return
	
	if not _is_valid_grid_pos(grid_pos):
		return
	
	var is_solid = not walkable
	astar_grid.set_point_solid(grid_pos, is_solid)
	
	# 清除路径缓存
	invalidate_path_cache()
	
	# 标记流场为脏
	flow_field_dirty = true


func set_cell_walkable_deferred(grid_pos: Vector2i, walkable: bool):
	"""延迟设置格子状态（批量更新优化）
	
	Args:
		grid_pos: 网格坐标
		walkable: 是否可通行
	"""
	pending_updates.append({"pos": grid_pos, "walkable": walkable})


func _process(delta: float):
	"""处理批量更新"""
	if pending_updates.is_empty():
		return
	
	update_timer += delta
	
	if update_timer >= batch_update_interval:
		_apply_pending_updates()
		update_timer = 0.0


func _apply_pending_updates():
	"""应用所有待处理的更新"""
	if pending_updates.is_empty():
		return
	
	for update in pending_updates:
		var grid_pos = update.pos
		var walkable = update.walkable
		var is_solid = not walkable
		
		if _is_valid_grid_pos(grid_pos):
			astar_grid.set_point_solid(grid_pos, is_solid)
	
	LogManager.info("GridPathFinder - 批量更新 %d 个格子" % pending_updates.size())
	
	pending_updates.clear()
	invalidate_path_cache()
	flow_field_dirty = true

# ============================================================================
# 坐标转换
# ============================================================================

func world_to_grid(world_pos: Vector3) -> Vector2i:
	"""世界坐标转网格坐标
	
	Args:
		world_pos: 世界坐标（Vector3）
	
	Returns:
		Vector2i: 网格坐标
	"""
	return Vector2i(int(world_pos.x), int(world_pos.z))


func grid_to_world(grid_pos: Vector2i) -> Vector3:
	"""网格坐标转世界坐标（格子中心）
	
	Args:
		grid_pos: 网格坐标
	
	Returns:
		Vector3: 世界坐标（格子中心，Y=0.05地面高度）
	"""
	return Vector3(
		grid_pos.x + 0.5, # 格子中心X
		0.05, # 地面高度
		grid_pos.y + 0.5 # 格子中心Z
	)


func _is_valid_grid_pos(grid_pos: Vector2i) -> bool:
	"""检查网格坐标是否有效
	
	Args:
		grid_pos: 网格坐标
	
	Returns:
		bool: 是否在地图范围内
	"""
	return (grid_pos.x >= 0 and grid_pos.x < map_size.x and
			grid_pos.y >= 0 and grid_pos.y < map_size.y)

# ============================================================================
# 路径缓存系统
# ============================================================================

func _get_cache_key(start: Vector3, end: Vector3) -> String:
	"""生成缓存键"""
	return "%d,%d->%d,%d" % [
		int(start.x), int(start.z),
		int(end.x), int(end.z)
	]


func _get_cached_path(start: Vector3, end: Vector3) -> PackedVector3Array:
	"""获取缓存的路径"""
	var key = _get_cache_key(start, end)
	
	if not path_cache.has(key):
		return PackedVector3Array()
	
	var cache_entry = path_cache[key]
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# 检查是否过期
	if current_time - cache_entry.timestamp > cache_timeout:
		path_cache.erase(key)
		return PackedVector3Array()
	
	return cache_entry.path


func _cache_path(start: Vector3, end: Vector3, path: PackedVector3Array):
	"""缓存路径"""
	# 检查缓存大小
	if path_cache.size() >= cache_max_size:
		# 清除最旧的缓存
		_cleanup_old_cache()
	
	var key = _get_cache_key(start, end)
	path_cache[key] = {
		"path": path,
		"timestamp": Time.get_ticks_msec() / 1000.0
	}


func _cleanup_old_cache():
	"""清理旧缓存"""
	var current_time = Time.get_ticks_msec() / 1000.0
	var keys_to_remove = []
	
	for key in path_cache:
		var cache_entry = path_cache[key]
		if current_time - cache_entry.timestamp > cache_timeout:
			keys_to_remove.append(key)
	
	for key in keys_to_remove:
		path_cache.erase(key)


func invalidate_path_cache():
	"""清除所有路径缓存"""
	path_cache.clear()

# ============================================================================
# 流场寻路（高级功能）
# ============================================================================

func update_flow_field(target_world: Vector3):
	"""为目标点计算流场（BFS从目标向外扩散）
	
	适用于大量单位向同一目标移动的场景（如Workers返回地牢之心）
	
	Args:
		target_world: 目标世界坐标
	"""
	if not is_initialized:
		return
	
	var target_grid = world_to_grid(target_world)
	
	if not _is_valid_grid_pos(target_grid) or astar_grid.is_point_solid(target_grid):
		LogManager.warning("GridPathFinder - 流场目标无效: %s" % str(target_grid))
		return
	
	flow_field_cache.clear()
	flow_field_target = target_grid
	
	# BFS从目标向外扩散
	var queue: Array = [target_grid]
	flow_field_cache[target_grid] = Vector2i.ZERO # 目标点方向为0
	
	while not queue.is_empty():
		var current = queue.pop_front()
		
		for neighbor in _get_neighbors(current):
			# 跳过阻挡点
			if astar_grid.is_point_solid(neighbor):
				continue
			
			# 跳过已访问点
			if flow_field_cache.has(neighbor):
				continue
			
			# 记录邻居指向当前点
			flow_field_cache[neighbor] = current - neighbor
			queue.append(neighbor)
	
	flow_field_dirty = false
	LogManager.info("GridPathFinder - 流场计算完成，覆盖 %d 个格子" % flow_field_cache.size())


func get_flow_direction(world_pos: Vector3) -> Vector3:
	"""获取世界坐标处的流场方向
	
	Args:
		world_pos: 世界坐标
	
	Returns:
		Vector3: 流场方向向量（已归一化），如果无流场则返回ZERO
	"""
	if not is_initialized or flow_field_dirty:
		return Vector3.ZERO
	
	var grid_pos = world_to_grid(world_pos)
	
	if not flow_field_cache.has(grid_pos):
		return Vector3.ZERO
	
	var dir_2d = flow_field_cache[grid_pos]
	
	if dir_2d == Vector2i.ZERO:
		return Vector3.ZERO # 已在目标点
	
	return Vector3(dir_2d.x, 0, dir_2d.y).normalized()


func _get_neighbors(grid_pos: Vector2i) -> Array:
	"""获取相邻格子（4方向或8方向）
	
	Args:
		grid_pos: 网格坐标
	
	Returns:
		Array: 相邻格子数组
	"""
	var neighbors = []
	
	# 4方向（上下左右）
	var directions = [
		Vector2i(1, 0), # 右
		Vector2i(-1, 0), # 左
		Vector2i(0, 1), # 下
		Vector2i(0, -1) # 上
	]
	
	# 如果允许对角线，添加4个对角方向
	if diagonal_mode != DiagonalMode.NEVER:
		directions.append_array([
			Vector2i(1, 1), # 右下
			Vector2i(1, -1), # 右上
			Vector2i(-1, 1), # 左下
			Vector2i(-1, -1) # 左上
		])
	
	for dir in directions:
		var neighbor = grid_pos + dir
		if _is_valid_grid_pos(neighbor):
			neighbors.append(neighbor)
	
	return neighbors

# ============================================================================
# 路径平滑（可选优化）
# ============================================================================

func smooth_path(path: PackedVector3Array) -> PackedVector3Array:
	"""路径平滑 - 使用视线检测移除不必要的中间点
	
	Args:
		path: 原始路径
	
	Returns:
		PackedVector3Array: 平滑后的路径
	"""
	if path.size() < 3:
		return path
	
	var smoothed: PackedVector3Array = []
	smoothed.append(path[0]) # 起点
	
	var i = 0
	while i < path.size() - 1:
		# 寻找最远的可见点
		var furthest = i + 1
		
		for j in range(i + 2, path.size()):
			if _has_line_of_sight(path[i], path[j]):
				furthest = j
			else:
				break
		
		smoothed.append(path[furthest])
		i = furthest
	
	return smoothed


func _has_line_of_sight(start_world: Vector3, end_world: Vector3) -> bool:
	"""检查两点之间是否有直线视野（Bresenham算法）
	
	Args:
		start_world: 起点世界坐标
		end_world: 终点世界坐标
	
	Returns:
		bool: 是否有视线
	"""
	var start_grid = world_to_grid(start_world)
	var end_grid = world_to_grid(end_world)
	
	var x0 = start_grid.x
	var y0 = start_grid.y
	var x1 = end_grid.x
	var y1 = end_grid.y
	
	var dx = abs(x1 - x0)
	var dy = abs(y1 - y0)
	var x_step = 1 if x0 < x1 else -1
	var y_step = 1 if y0 < y1 else -1
	
	var error = dx - dy
	var x = x0
	var y = y0
	
	while true:
		# 检查当前点是否可通行
		var current = Vector2i(x, y)
		if astar_grid.is_point_solid(current):
			return false
		
		# 到达终点
		if x == x1 and y == y1:
			break
		
		# Bresenham步进
		var e2 = 2 * error
		if e2 > -dy:
			error -= dy
			x += x_step
		if e2 < dx:
			error += dx
			y += y_step
	
	return true

# ============================================================================
# 调试和统计
# ============================================================================

func get_stats() -> Dictionary:
	"""获取统计信息"""
	var cache_hit_rate = 0.0
	if stats.total_path_queries > 0:
		cache_hit_rate = float(stats.cache_hits) / float(stats.total_path_queries) * 100.0
	
	return {
		"initialized": is_initialized,
		"map_size": str(map_size),
		"total_queries": stats.total_path_queries,
		"cache_hits": stats.cache_hits,
		"cache_misses": stats.cache_misses,
		"cache_hit_rate": "%.1f%%" % cache_hit_rate,
		"avg_path_length": "%.1f" % stats.avg_path_length,
		"avg_query_time_ms": "%.3f ms" % stats.avg_query_time_ms,
		"cached_paths": path_cache.size(),
		"flow_field_size": flow_field_cache.size()
	}


func print_stats():
	"""打印统计信息"""
	var s = get_stats()
	LogManager.info("=== GridPathFinder 统计 ===")
	for key in s:
		LogManager.info("  %s: %s" % [key, str(s[key])])


func debug_visualize_grid():
	"""调试可视化网格（可选实现）"""
	# 可以添加DebugDraw来可视化网格和路径
	pass


func reset_stats():
	"""重置统计信息"""
	stats = {
		"total_path_queries": 0,
		"cache_hits": 0,
		"cache_misses": 0,
		"avg_path_length": 0.0,
		"avg_query_time_ms": 0.0,
		"last_update_time": 0.0
	}

# ============================================================================
# 辅助函数
# ============================================================================

func get_grid_size() -> Vector2i:
	"""获取网格尺寸"""
	return map_size


func is_ready() -> bool:
	"""检查系统是否就绪"""
	return is_initialized

func is_point_solid(grid_pos: Vector2i) -> bool:
	"""检查格子点是否固体（不可通行）
	
	Args:
		grid_pos: 网格坐标
		
	Returns:
		bool: 是否固体（true=阻挡，false=可通行）
	"""
	if not is_initialized or not astar_grid:
		return true # 未初始化时视为阻挡
	
	if not _is_valid_grid_pos(grid_pos):
		return true # 无效位置视为阻挡
	
	return astar_grid.is_point_solid(grid_pos)

func is_point_walkable(grid_pos: Vector2i) -> bool:
	"""检查格子点是否可通行（is_point_solid的反向）
	
	Args:
		grid_pos: 网格坐标
		
	Returns:
		bool: 是否可通行
	"""
	return not is_point_solid(grid_pos)

func get_walkable_neighbors(world_pos: Vector3) -> Array:
	"""获取世界坐标处的所有可通行邻居
	
	Args:
		world_pos: 世界坐标
	
	Returns:
		Array: 可通行邻居的世界坐标数组
	"""
	if not is_initialized:
		return []
	
	var grid_pos = world_to_grid(world_pos)
	var neighbors = _get_neighbors(grid_pos)
	var walkable_neighbors = []
	
	for neighbor in neighbors:
		if not astar_grid.is_point_solid(neighbor):
			walkable_neighbors.append(grid_to_world(neighbor))
	
	return walkable_neighbors
