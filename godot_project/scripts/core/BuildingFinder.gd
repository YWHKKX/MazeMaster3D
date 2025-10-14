extends Node

## BuildingFinder - 统一建筑查找工具
## 
## 提供统一的建筑查找API，避免代码重复
## 
## 核心功能：
## 1. 查找最近的地牢之心
## 2. 查找最近的可存储建筑（金库优先，地牢之心备选）
## 3. 查找最近的金库

## 查找结果
class BuildingSearchResult:
	var building: Node = null
	var distance: float = INF
	var building_type: String = ""
	
	func _init(b: Node = null, d: float = INF, t: String = ""):
		building = b
		distance = d
		building_type = t
	
	func is_valid() -> bool:
		return building != null and is_instance_valid(building)

# ============================================================================
# 核心查找API
# ============================================================================

## 查找最近的地牢之心
static func find_nearest_dungeon_heart(character: Node) -> BuildingSearchResult:
	"""查找最近的地牢之心
	
	Args:
		character: 角色对象
		
	Returns:
		BuildingSearchResult: 查找结果
	"""
	if not character.building_manager:
		return BuildingSearchResult.new()
	
	var dungeon_heart = character.building_manager.get_dungeon_heart()
	if not dungeon_heart or not is_instance_valid(dungeon_heart):
		return BuildingSearchResult.new()
	
	var distance = character.global_position.distance_to(dungeon_heart.global_position)
	return BuildingSearchResult.new(
		dungeon_heart,
		distance,
		"地牢之心"
	)

## 查找最近的可存储建筑（金库优先，地牢之心备选）
static func find_nearest_storage_building(character: Node) -> BuildingSearchResult:
	"""查找最近的可存储建筑
	
	优先级：
	1. 金库（已建造完成且未满）
	2. 地牢之心（备选）
	
	Args:
		character: 角色对象
		
	Returns:
		BuildingSearchResult: 查找结果
	"""
	if not character.building_manager:
		return BuildingSearchResult.new()
	
	var character_pos = character.global_position
	var best_result = BuildingSearchResult.new()
	
	# 1. 优先查找金库（for_deposit=true 表示查找可以存储金币的金库）
	var nearest_treasury = character.building_manager.get_nearest_treasury(character_pos, true)
	if nearest_treasury and is_instance_valid(nearest_treasury):
		var distance = character_pos.distance_to(nearest_treasury.global_position)
		best_result = BuildingSearchResult.new(
			nearest_treasury,
			distance,
			"金库"
		)
	
	# 2. 备选：查找地牢之心
	var dungeon_heart = character.building_manager.get_dungeon_heart()
	if dungeon_heart and is_instance_valid(dungeon_heart):
		var distance = character_pos.distance_to(dungeon_heart.global_position)
		
		# 如果还没有找到金库，或者地牢之心更近，则选择地牢之心
		if not best_result.is_valid() or distance < best_result.distance:
			best_result = BuildingSearchResult.new(
				dungeon_heart,
				distance,
				"地牢之心"
			)
	
	return best_result

## 查找最近的金库
static func find_nearest_treasury(character: Node) -> BuildingSearchResult:
	"""查找最近的金库
	
	Args:
		character: 角色对象
		
	Returns:
		BuildingSearchResult: 查找结果
	"""
	if not character.building_manager:
		return BuildingSearchResult.new()
	
	var nearest_treasury = character.building_manager.get_nearest_treasury(character.global_position, true)
	if not nearest_treasury or not is_instance_valid(nearest_treasury):
		return BuildingSearchResult.new()
	
	var distance = character.global_position.distance_to(nearest_treasury.global_position)
	return BuildingSearchResult.new(
		nearest_treasury,
		distance,
		"金库"
	)

## 查找最近的金库或地牢之心（用于取金币）
static func find_nearest_gold_source(character: Node) -> BuildingSearchResult:
	"""查找最近的金币来源（金库优先，地牢之心备选）
	
	用于工程师取金币时使用
	
	Args:
		character: 角色对象
		
	Returns:
		BuildingSearchResult: 查找结果
	"""
	if not character.building_manager:
		return BuildingSearchResult.new()
	
	var character_pos = character.global_position
	var best_result = BuildingSearchResult.new()
	
	# 1. 优先查找金库（有金币的）
	var treasury = character.building_manager.get_nearest_treasury(character_pos)
	if treasury and is_instance_valid(treasury):
		var distance = character_pos.distance_to(treasury.global_position)
		best_result = BuildingSearchResult.new(
			treasury,
			distance,
			"金库"
		)
	
	# 2. 备选：查找地牢之心
	var dungeon_heart = character.building_manager.get_dungeon_heart()
	if dungeon_heart and is_instance_valid(dungeon_heart):
		var distance = character_pos.distance_to(dungeon_heart.global_position)
		
		# 如果还没有找到金库，或者地牢之心更近，则选择地牢之心
		if not best_result.is_valid() or distance < best_result.distance:
			best_result = BuildingSearchResult.new(
				dungeon_heart,
				distance,
				"地牢之心"
			)
	
	return best_result

## 查找最近的可访问金矿
static func find_nearest_accessible_gold_mine(character: Node) -> RefCounted:
	"""查找最近的可访问金矿（使用可达性检查）
	
	Args:
		character: 角色对象
		
	Returns:
		RefCounted: 金矿对象，如果没找到返回null
	"""
	if not character.gold_mine_manager:
		return null
	
	# 使用可达性检查的方法（从GoldMineManager获取可达金矿）
	var reachable_mines = character.gold_mine_manager.get_reachable_mines_in_radius(
		character.global_position,
		100.0 # 搜索半径
	)
	
	if reachable_mines.is_empty():
		return null
	
	var nearest_mine = null
	var min_distance = INF
	
	for mine in reachable_mines:
		# 跳过枯竭的金矿
		if mine.is_exhausted():
			continue
		
		# 跳过不能接受矿工的金矿
		if not mine.can_accept_miner():
			continue
		
		# 跳过失败黑名单中的金矿（暂时不尝试）
		if character.failed_mines.has(mine.position):
			var failed_time = character.failed_mines[mine.position]
			if Time.get_ticks_msec() - failed_time < character.failed_mine_timeout * 1000:
				continue
		
		var distance = character.global_position.distance_to(mine.position)
		if distance < min_distance:
			min_distance = distance
			nearest_mine = mine
	
	return nearest_mine

## 获取金矿附近的可通行位置
static func get_accessible_position_near_mine(character: Node, mine: RefCounted) -> Vector3:
	"""获取金矿旁边的可通行位置（使用与建筑相同的逻辑）
	
	Args:
		character: 角色对象
		mine: 金矿对象
		
	Returns:
		Vector3: 可通行位置
	"""
	if not GridPathFinder or not GridPathFinder.is_ready():
		return Vector3.INF
	
	# 🔧 [统一逻辑] 将金矿作为1x1建筑处理，使用与金库相同的计算逻辑
	var mine_pos = Vector3(
		floor(mine.position.x) + 0.5,
		0.05,
		floor(mine.position.z) + 0.5
	)
	
	var mine_grid = GridPathFinder.world_to_grid(mine_pos)
	var character_pos = character.global_position
	
	# 🔧 [统一逻辑] 金矿作为1x1建筑，使用相同的搜索逻辑
	# var building_size = Vector2(1, 1) # 金矿是1x1建筑（已移除未使用变量）
	
	# 计算搜索偏移量：建筑外部一圈
	var search_offsets = _generate_search_offsets(1, 1)
	
	# 搜索金矿周围位置
	
	var best_position = Vector3.INF
	var best_distance = INF
	
	for offset in search_offsets:
		var check_grid = mine_grid + offset
		
		# 检查是否在范围内
		if check_grid.x < 0 or check_grid.x >= GridPathFinder.map_size.x:
			continue
		if check_grid.y < 0 or check_grid.y >= GridPathFinder.map_size.y:
			continue
		
		# 🔧 [统一逻辑] 使用与建筑相同的可通行性检查
		if _is_position_walkable(check_grid, character):
			var walkable_pos = GridPathFinder.grid_to_world(check_grid)
			var distance = character_pos.distance_to(walkable_pos)
			
			# 找到可通行位置
			
			# 选择距离角色最近的点
			if distance < best_distance:
				best_distance = distance
				best_position = walkable_pos
	
	return best_position

## 找到建筑周围的可通行点
static func get_walkable_position_near_building(character: Node, building: Node) -> Vector3:
	"""找到建筑周围的可通行点
	
	根据建筑大小（1x1, 2x2, 3x3...）计算不同的搜索范围
	
	Args:
		character: 角色对象
		building: 目标建筑
		
	Returns:
		Vector3: 可通行点的世界坐标，如果没找到返回 Vector3.INF
	"""
	if not GridPathFinder or not GridPathFinder.is_ready():
		return Vector3.INF
	
	var building_pos = building.global_position
	var building_grid = GridPathFinder.world_to_grid(building_pos)
	var character_pos = character.global_position
	
	# 🔧 [建筑大小适配] 根据建筑大小计算搜索范围
	var building_size = Vector2(1, 1) # 默认1x1
	if building.has_method("get_building_size"):
		building_size = building.get_building_size()
	elif "building_size" in building:
		building_size = building.building_size
	
	# 计算建筑占用的格子范围
	var size_x = int(building_size.x)
	var size_y = int(building_size.y)
	
	# 计算搜索偏移量：建筑外部一圈
	var search_offsets = _generate_search_offsets(size_x, size_y)
	
	var best_position = Vector3.INF
	var best_distance = INF
	
	for offset in search_offsets:
		var check_grid = building_grid + offset
		
		# 检查是否在范围内
		if check_grid.x < 0 or check_grid.x >= GridPathFinder.map_size.x:
			continue
		if check_grid.y < 0 or check_grid.y >= GridPathFinder.map_size.y:
			continue
		
		# 🔧 [修复] 检查是否真的可通行
		if _is_position_walkable(check_grid, character):
			var walkable_pos = GridPathFinder.grid_to_world(check_grid)
			var distance = character_pos.distance_to(walkable_pos)
			
			# 找到可通行位置
			
			# 坐标转换验证
			
			# 选择距离角色最近的点
			if distance < best_distance:
				best_distance = distance
				best_position = walkable_pos
	
	return best_position


## 检查位置是否真的可通行
static func _is_position_walkable(grid_pos: Vector2i, _character: Node) -> bool:
	"""检查位置是否真的可通行
	
	不仅检查AStarGrid状态，还检查TileManager状态
	
	Args:
		grid_pos: 网格坐标
		character: 角色对象
		
	Returns:
		bool: 是否可通行
	"""
	# 1. 检查AStarGrid状态
	if not GridPathFinder or not GridPathFinder.is_ready():
		return false
	
	if GridPathFinder.astar_grid.is_point_solid(grid_pos):
		return false
	
	# 2. 检查TileManager状态（如果可用）
	var tile_manager = GameServices.tile_manager
	if tile_manager:
		var world_pos = Vector3(grid_pos.x, 0, grid_pos.y)
		if not tile_manager.is_walkable(world_pos):
			return false
	
	return true


## 根据建筑大小生成搜索偏移量
static func _generate_search_offsets(size_x: int, size_y: int) -> Array[Vector2i]:
	"""根据建筑大小生成搜索偏移量
	
	Args:
		size_x: 建筑X方向大小（格子数）
		size_y: 建筑Y方向大小（格子数）
		
	Returns:
		Array[Vector2i]: 搜索偏移量数组
	"""
	var offsets: Array[Vector2i] = []
	
	# 计算建筑边界
	var half_x = size_x / 2
	var half_y = size_y / 2
	
	# 生成建筑外部一圈的偏移量
	# 上边界和下边界
	for x in range(-half_x - 1, half_x + 2):
		offsets.append(Vector2i(x, -half_y - 1)) # 上边界
		offsets.append(Vector2i(x, half_y + 1)) # 下边界
	
	# 左边界和右边界
	for y in range(-half_y, half_y + 1):
		offsets.append(Vector2i(-half_x - 1, y)) # 左边界
		offsets.append(Vector2i(half_x + 1, y)) # 右边界
	
	# 如果建筑很大，添加更外圈的偏移量
	if size_x >= 2 or size_y >= 2:
		# 第二圈
		for x in range(-half_x - 2, half_x + 3):
			offsets.append(Vector2i(x, -half_y - 2)) # 上边界第二圈
			offsets.append(Vector2i(x, half_y + 2)) # 下边界第二圈
		
		for y in range(-half_y - 1, half_y + 2):
			offsets.append(Vector2i(-half_x - 2, y)) # 左边界第二圈
			offsets.append(Vector2i(half_x + 2, y)) # 右边界第二圈
	
	return offsets

# ============================================================================
# 便捷方法
# ============================================================================

## 查找最近的地牢之心（返回Node）
static func get_nearest_dungeon_heart(character: Node) -> Node:
	"""查找最近的地牢之心（返回Node对象）
	
	Args:
		character: 角色对象
		
	Returns:
		Node: 地牢之心节点，如果没找到返回null
	"""
	var result = find_nearest_dungeon_heart(character)
	return result.building

## 查找最近的可存储建筑（返回Node）
static func get_nearest_storage_building(character: Node) -> Node:
	"""查找最近的可存储建筑（返回Node对象）
	
	Args:
		character: 角色对象
		
	Returns:
		Node: 存储建筑节点，如果没找到返回null
	"""
	var result = find_nearest_storage_building(character)
	return result.building

## 查找最近的金库（返回Node）
static func get_nearest_treasury(character: Node) -> Node:
	"""查找最近的金库（返回Node对象）
	
	Args:
		character: 角色对象
		
	Returns:
		Node: 金库节点，如果没找到返回null
	"""
	var result = find_nearest_treasury(character)
	return result.building

## 查找最近的金币来源（返回Node）
static func get_nearest_gold_source(character: Node) -> Node:
	"""查找最近的金币来源（返回Node对象）
	
	Args:
		character: 角色对象
		
	Returns:
		Node: 金币来源节点，如果没找到返回null
	"""
	var result = find_nearest_gold_source(character)
	return result.building

# ============================================================================
# 调试方法
# ============================================================================

## 打印查找结果
static func print_search_result(result: BuildingSearchResult, prefix: String = ""):
	"""打印查找结果（调试用）
	
	Args:
		result: 查找结果
		prefix: 日志前缀
	"""
	# 建筑查找完成
