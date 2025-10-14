extends Node

## MovementHelper - 统一移动控制系统
## 
## 🚀 核心功能：
## 1. 统一移动API (process_navigation) - 一站式移动控制
## 2. 智能卡住检测 - 自动检测并处理卡住情况
## 3. 动态路径重规划 - 智能绕过动态障碍
## 4. 分层避障系统 - 全局路径 + 局部避障
## 5. 路径跟随与精确移动 - 网格路径 + 直线精确定位
## 
## 📚 版本: v4.2.0 (动态避障系统)
## 📅 更新: 2025-10-13

# ============================================================================
# 统一移动API - 核心控制器
# ============================================================================

## 移动结果状态枚举
enum MoveResult {
	MOVING, # 🟢 正在移动中
	REACHED, # ✅ 已到达目标
	FAILED_NO_PATH, # ❌ 寻路失败（无可用路径）
	FAILED_STUCK # ⚠️ 卡住失败（多次重寻路无效）
}

## 🎯 统一导航处理 - 一站式移动API
##
## 这是MovementHelper的核心API，自动处理所有移动逻辑：
## • 智能寻路 (AStarGrid2D)
## • 卡住检测与重寻路
## • 动态障碍绕过
## • 路径跟随与精确移动
## • 分层避障系统
##
## @param character: 角色对象 (CharacterBody3D)
## @param target_position: 目标位置 (世界坐标)
## @param delta: 时间增量
## @param debug_prefix: 调试日志前缀 (可选)
## @return: MoveResult 移动结果状态
static func process_navigation(character: Node, target_position: Vector3, delta: float, debug_prefix: String = "") -> int:
	"""🚀 统一导航处理 - 一站式移动API
	
	📖 使用示例：
	```gdscript
	func physics_update(delta: float):
		var result = MovementHelper.process_navigation(unit, target_pos, delta, "MyState")
		match result:
			MovementHelper.MoveResult.REACHED:
				state_finished.emit("NextState")
			MovementHelper.MoveResult.FAILED_NO_PATH, MovementHelper.MoveResult.FAILED_STUCK:
				state_finished.emit("IdleState")
	```
	"""
	# 📋 初始化导航控制器
	var nav_data = _initialize_navigation_controller(character)
	
	# 🔄 检查目标变更并更新路径
	_update_target_if_changed(nav_data, target_position, debug_prefix)
	
	# 🗺️ 路径规划阶段
	var path_result = _handle_path_planning(character, nav_data, target_position, debug_prefix)
	if path_result != MoveResult.MOVING:
		return path_result
	
	# ⚠️ 卡住检测与重寻路
	var stuck_result = _handle_stuck_detection(character, nav_data, target_position, delta, debug_prefix)
	if stuck_result != MoveResult.MOVING:
		return stuck_result
	
	# 🔄 动态障碍检测与绕过
	var obstacle_result = _handle_dynamic_obstacles(character, nav_data, target_position, debug_prefix)
	if obstacle_result != MoveResult.MOVING:
		return obstacle_result
	
	# 🚶 移动执行阶段
	return _execute_movement(character, nav_data, target_position, delta, debug_prefix)

# ============================================================================
# 🔧 导航处理辅助函数 - 分解后的逻辑模块
# ============================================================================

## 📋 初始化导航控制器
static func _initialize_navigation_controller(character: Node) -> Dictionary:
	"""📋 初始化或获取导航控制器数据"""
	if not character.has_meta("_nav_controller"):
		character.set_meta("_nav_controller", {
			"path": PackedVector3Array(),
			"waypoint": 0,
			"last_target": Vector3.ZERO
		})
	return character.get_meta("_nav_controller")

## 🔄 检查目标变更并更新路径
static func _update_target_if_changed(nav_data: Dictionary, target_position: Vector3, debug_prefix: String) -> void:
	"""🔄 检查目标是否变更，如果变更则清空路径"""
	if nav_data.last_target.distance_to(target_position) > 0.5:
		# 目标已变更
		_reset_navigation_path(nav_data)
		nav_data.last_target = target_position

## 🗺️ 处理路径规划
static func _handle_path_planning(character: Node, nav_data: Dictionary, target_position: Vector3, _debug_prefix: String) -> int:
	"""🗺️ 处理路径规划逻辑"""
	if not nav_data.path.is_empty():
		return MoveResult.MOVING
	
	var distance_to_target = character.global_position.distance_to(target_position)
	
	# 🎯 距离很近时直接移动，不寻路
	if distance_to_target <= 0.3:
		_reset_navigation_path(nav_data)
		return MoveResult.MOVING
	
	# 距离较远时才寻路
	nav_data.path = _find_path_direct(character.global_position, target_position)
	nav_data.waypoint = 0
	
	if nav_data.path.is_empty():
		# 路径失败时尝试直接移动
		return MoveResult.MOVING
	
	return MoveResult.MOVING

## ⚠️ 处理卡住检测与重寻路
static func _handle_stuck_detection(character: Node, nav_data: Dictionary, target_position: Vector3, delta: float, debug_prefix: String) -> int:
	"""⚠️ 处理卡住检测与重寻路逻辑"""
	var current_distance_to_target = character.global_position.distance_to(target_position)
	var should_check_stuck = nav_data.path.size() > 3 and current_distance_to_target > 5.0
	
	if not should_check_stuck or not detect_stuck(character, delta, 0.1, 4.0):
		return MoveResult.MOVING
	
	# 检测到卡住，尝试重新寻路
	
	var new_path = try_replan_path(character, target_position, 2.0)
	if not new_path.is_empty():
		nav_data.path = new_path
		nav_data.waypoint = 0
		reset_stuck_detection(character)
		# 重新寻路成功
		return MoveResult.MOVING
	else:
		# 重寻路失败时，清空路径尝试直接移动
		_reset_navigation_path(nav_data)
		# 重新寻路失败，尝试直接移动
		return MoveResult.MOVING

## 🔄 处理动态障碍检测与绕过
static func _handle_dynamic_obstacles(character: Node, nav_data: Dictionary, target_position: Vector3, debug_prefix: String) -> int:
	"""🔄 处理动态障碍检测与绕过逻辑"""
	if nav_data.waypoint >= nav_data.path.size():
		return MoveResult.MOVING
	
	# 检测前方路径是否被阻挡
	if not is_path_blocked(character.global_position, nav_data.path, nav_data.waypoint):
		return MoveResult.MOVING
	
	# 路径被阻挡，尝试绕过
	
	# 尝试局部重寻路（从当前位置重新规划）
	var new_path = try_replan_path(character, target_position, 1.5)
	if not new_path.is_empty():
		nav_data.path = new_path
		nav_data.waypoint = 0
		# 成功绕过障碍
		return MoveResult.MOVING
	else:
		# 无法绕过，尝试直接移动
		_reset_navigation_path(nav_data)
		# 无法绕过，尝试直接移动
		return MoveResult.MOVING

## 🚶 执行移动
static func _execute_movement(character: Node, nav_data: Dictionary, target_position: Vector3, delta: float, debug_prefix: String) -> int:
	"""🚶 执行移动逻辑"""
	if nav_data.waypoint < nav_data.path.size():
		# 🗺️ 网格路径跟随模式
		return _execute_path_following(character, nav_data, delta)
	else:
		# 🎯 精确直接移动模式
		return _execute_direct_movement(character, nav_data, target_position, delta, debug_prefix)

## 🗺️ 执行路径跟随
static func _execute_path_following(character: Node, nav_data: Dictionary, delta: float) -> int:
	"""🗺️ 执行路径跟随移动"""
	var follow_result = follow_path(character, nav_data.path, nav_data.waypoint, delta, 0.3)
	nav_data.waypoint = follow_result.waypoint_index
	
	if not follow_result.reached_end:
		apply_movement(character, follow_result.direction, delta)
	
	return MoveResult.MOVING

## 🎯 执行直接移动
static func _execute_direct_movement(character: Node, nav_data: Dictionary, target_position: Vector3, delta: float, debug_prefix: String) -> int:
	"""🎯 执行直接移动"""
	var distance = character.global_position.distance_to(target_position)
	
	# 检查是否已到达目标
	if distance <= 0.1:
		# 已到达目标
		return MoveResult.REACHED
	
	# 距离过远时重新寻路（防止路径失效）
	if distance > 8.0:
		_reset_navigation_path(nav_data)
		return MoveResult.MOVING
	
	# 精确移动：直接向目标移动
	var direction = (target_position - character.global_position)
	direction.y = 0
	
	if direction.length() > 0.01:
		direction = direction.normalized()
		
		# 统一速度处理：使用get_character_speed并除以100
		var speed = get_character_speed(character)
		var target_velocity = direction * (speed / 100.0)
		target_velocity.y = 0 # 保持Y轴为0（地面移动）
		
		# 动态避障处理：全局路径 + 局部避障
		var final_velocity = _apply_dynamic_avoidance(character, target_velocity, delta)
		
		apply_movement_with_velocity(character, final_velocity, delta)
	
	return MoveResult.MOVING

## 🔄 重置导航路径
static func _reset_navigation_path(nav_data: Dictionary) -> void:
	"""🔄 重置导航路径数据"""
	nav_data.path = PackedVector3Array()
	nav_data.waypoint = 0

# ============================================================================
# 🛡️ 动态避障系统 - 分层避障架构
# ============================================================================

## 应用动态避障：分层处理全局路径和局部避障
static func _apply_dynamic_avoidance(character: Node, base_velocity: Vector3, delta: float) -> Vector3:
	"""🛡️ 分层避障处理：
	1. 全局路径：由AStarGrid2D提供的基础移动方向
	2. 局部避障：检测并避开附近的动态单位
	"""
	var avoidance_velocity = Vector3.ZERO
	
	# 检查是否启用避障系统
	if AvoidanceManager and AvoidanceManager.has_method("calculate_avoidance_force"):
		avoidance_velocity = AvoidanceManager.calculate_avoidance_force(
			character, base_velocity, delta
		)
	
	# 智能混合：根据避障强度调整混合比例
	return _blend_velocities(base_velocity, avoidance_velocity)

## 🎯 智能速度混合：根据避障强度动态调整混合比例
static func _blend_velocities(base_velocity: Vector3, avoidance_velocity: Vector3) -> Vector3:
	"""🎯 智能混合基础速度和避障速度：
	• 避障力小：以遵循路径为主
	• 避障力大：以避障为主  
	• 中间值：平滑混合
	"""
	var avoid_strength = avoidance_velocity.length()
	var base_speed = base_velocity.length()
	
	if avoid_strength < 0.1:
		# 避障力很小，以遵循路径为主
		return base_velocity
	elif avoid_strength > 0.5:
		# 避障力很大，说明有紧急碰撞风险，以避障为主
		return avoidance_velocity.normalized() * base_speed
	else:
		# 一般情况下，将两者平滑混合
		var blend_factor = avoid_strength * 0.6 # 0.6是混合系数
		var mixed_velocity = base_velocity.lerp(avoidance_velocity, blend_factor)
		return mixed_velocity.normalized() * base_speed

## 🔄 重置导航控制器（切换状态时调用）
static func reset_navigation(character: Node) -> void:
	"""🔄 重置导航控制器状态"""
	if character.has_meta("_nav_controller"):
		character.set_meta("_nav_controller", {
			"path": PackedVector3Array(),
			"waypoint": 0,
			"last_target": Vector3.ZERO
		})
	reset_stuck_detection(character)

# ============================================================================
# ⚠️ 卡住检测系统
# ============================================================================

## ⚠️ 检测单位是否卡住
## 
## @param character: 角色节点
## @param delta: 时间增量
## @param stuck_threshold: 距离阈值（单位：米）
## @param stuck_time_threshold: 时间阈值（单位：秒）
## @return: bool 是否卡住
static func detect_stuck(character: Node, delta: float, stuck_threshold: float = 0.05, stuck_time_threshold: float = 3.0) -> bool:
	"""⚠️ 检测单位是否卡住
	
	🔍 原理：跟踪单位的位置，如果在一定时间内移动距离过小，则判定为卡住
	"""
	# 初始化卡住检测数据
	if not character.has_meta("_stuck_detection"):
		character.set_meta("_stuck_detection", {
			"last_position": character.global_position,
			"stuck_timer": 0.0,
			"is_stuck": false
		})
	
	var stuck_data = character.get_meta("_stuck_detection")
	var distance_moved = character.global_position.distance_to(stuck_data.last_position)
	
	# 检测移动距离
	if distance_moved < stuck_threshold:
		# 单位几乎没有移动，增加卡住计时器
		stuck_data.stuck_timer += delta
		if stuck_data.stuck_timer >= stuck_time_threshold:
			stuck_data.is_stuck = true
			return true
	else:
		# 单位正常移动，重置计时器
		stuck_data.stuck_timer = 0.0
		stuck_data.is_stuck = false
		stuck_data.last_position = character.global_position
	
	return false


## 🔄 重置卡住检测状态
static func reset_stuck_detection(character: Node) -> void:
	"""🔄 重置卡住检测状态（例如在新路径开始时调用）"""
	if character.has_meta("_stuck_detection"):
		var stuck_data = character.get_meta("_stuck_detection")
		stuck_data.stuck_timer = 0.0
		stuck_data.is_stuck = false
		stuck_data.last_position = character.global_position


# ============================================================================
# 🔄 动态路径重规划系统
# ============================================================================

## 🚧 检查路径是否被阻挡
## 
## @param current_position: 当前位置
## @param path: 路径点数组
## @param waypoint_index: 当前路径点索引
## @return: bool 路径是否被阻挡
static func is_path_blocked(_current_position: Vector3, path: PackedVector3Array, waypoint_index: int) -> bool:
	"""🚧 检查接下来的路径点是否被阻挡
	
	🔍 原理：检查前方1-2个路径点是否不可通行
	"""
	if waypoint_index >= path.size():
		return false
	
	# 检查下一个路径点
	var next_waypoint = path[waypoint_index]
	var next_grid = GridPathFinder.world_to_grid(next_waypoint)
	if GridPathFinder.is_point_solid(next_grid):
		return true
	
	# 检查下下个路径点（如果存在）
	if waypoint_index + 1 < path.size():
		var next_next_waypoint = path[waypoint_index + 1]
		var next_next_grid = GridPathFinder.world_to_grid(next_next_waypoint)
		if GridPathFinder.is_point_solid(next_next_grid):
			return true
	
	return false


## 🔄 尝试重新规划路径（带避障移动）
## 
## @param character: 角色节点
## @param target_position: 目标位置
## @param min_replan_interval: 最小重规划间隔（秒）
## @return: PackedVector3Array 新路径（如果重规划成功），否则返回空数组
static func try_replan_path(character: Node, target_position: Vector3, min_replan_interval: float = 1.0) -> PackedVector3Array:
	"""🔄 尝试重新规划路径（带避障移动和冷却时间）
	
	🔍 原理：
	1. 避免频繁重规划导致性能问题，使用冷却时间限制重规划频率
	2. 重规划前先让单位朝向其他方向移动一段距离以避免碰撞
	"""
	# 初始化重规划数据
	if not character.has_meta("_replan_cooldown"):
		character.set_meta("_replan_cooldown", {
			"last_replan_time": 0.0,
			"avoidance_start_time": 0.0,
			"avoidance_direction": Vector3.ZERO,
			"is_avoiding": false
		})
	
	var replan_data = character.get_meta("_replan_cooldown")
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# 检查冷却时间
	if current_time - replan_data.last_replan_time < min_replan_interval:
		return PackedVector3Array() # 冷却中，返回空路径
	
	# 🔧 [新增] 避障移动逻辑
	if not replan_data.is_avoiding:
		# 开始避障移动
		replan_data.is_avoiding = true
		replan_data.avoidance_start_time = current_time
		replan_data.avoidance_direction = _get_avoidance_direction(character, target_position)
		
		# 执行避障移动
		_apply_avoidance_movement(character, replan_data.avoidance_direction)
		return PackedVector3Array() # 返回空路径，继续避障移动
	
	# 检查避障移动是否完成（移动1-2秒）
	var avoidance_duration = current_time - replan_data.avoidance_start_time
	if avoidance_duration < 1.5: # 避障移动1.5秒
		# 继续避障移动
		_apply_avoidance_movement(character, replan_data.avoidance_direction)
		return PackedVector3Array() # 返回空路径，继续避障移动
	
	# 避障移动完成，重置状态并尝试重新规划
	replan_data.is_avoiding = false
	replan_data.avoidance_direction = Vector3.ZERO
	
	# 尝试重新规划
	if GridPathFinder and GridPathFinder.is_ready():
		var new_path = _find_path_direct(character.global_position, target_position)
		if not new_path.is_empty():
			replan_data.last_replan_time = current_time
			return new_path
	
	return PackedVector3Array() # 重规划失败


# ============================================================================
# 🚶 移动执行系统
# ============================================================================

## 🗺️ 跟随路径移动
## 
## @param character: 角色节点
## @param path: 路径数组
## @param waypoint_index: 当前路径点索引（引用传递）
## @param delta: 时间增量
## @param waypoint_threshold: 到达路径点的距离阈值
## @return: Dictionary 包含路径进度信息
static func follow_path(character: Node, path: PackedVector3Array, waypoint_index: int, _delta: float, waypoint_threshold: float = 0.3) -> Dictionary:
	"""🗺️ 跟随路径移动
	
	📋 返回移动方向和路径进度信息：
	• waypoint_index: 更新后的路径点索引
	• reached_end: 是否到达路径终点
	• direction: 移动方向
	"""
	if waypoint_index >= path.size():
		return {
			"waypoint_index": waypoint_index,
			"reached_end": true,
			"direction": Vector3.ZERO
		}
	
	# 获取当前目标路径点
	var target_waypoint = path[waypoint_index]
	var distance_to_waypoint = character.global_position.distance_to(target_waypoint)
	
	# 检查是否到达当前路径点
	if distance_to_waypoint < waypoint_threshold:
		waypoint_index += 1
		
		# 检查是否到达路径终点
		if waypoint_index >= path.size():
			return {
				"waypoint_index": waypoint_index,
				"reached_end": true,
				"direction": Vector3.ZERO
			}
		
		# 前进到下一个路径点
		target_waypoint = path[waypoint_index]
	
	# 计算移动方向
	var direction = (target_waypoint - character.global_position).normalized()
	
	return {
		"waypoint_index": waypoint_index,
		"reached_end": false,
		"direction": direction
	}


# ============================================================================
# 🔧 实用工具函数
# ============================================================================

## 🗺️ 直接寻路方法（替代GridPathFinder.find_path）
static func _find_path_direct(start_world: Vector3, end_world: Vector3) -> PackedVector3Array:
	"""直接寻路方法，替代GridPathFinder.find_path
	
	Args:
		start_world: 起点世界坐标
		end_world: 终点世界坐标
	
	Returns:
		PackedVector3Array: 路径点数组（世界坐标），空数组表示无路径
	"""
	if not GridPathFinder or not GridPathFinder.is_ready():
		return PackedVector3Array()
	
	# 转换为网格坐标
	var start_grid = GridPathFinder.world_to_grid(start_world)
	var end_grid = GridPathFinder.world_to_grid(end_world)
	
	# 使用AStarGrid2D寻路
	var grid_path = GridPathFinder.astar_grid.get_point_path(start_grid, end_grid)
	
	# 转换为世界坐标
	var world_path: PackedVector3Array = []
	for grid_point in grid_path:
		world_path.append(GridPathFinder.grid_to_world(grid_point))
	
	return world_path

## 🚧 获取避障移动方向
static func _get_avoidance_direction(character: Node, target_position: Vector3) -> Vector3:
	"""🚧 计算避障移动方向
	
	🔍 原理：寻找与目标方向垂直的方向，优先选择右侧，如果右侧被阻挡则选择左侧
	"""
	var current_pos = character.global_position
	var to_target = (target_position - current_pos).normalized()
	
	# 计算右侧方向（顺时针90度）
	var right_direction = Vector3(-to_target.z, 0, to_target.x)
	
	# 计算左侧方向（逆时针90度）
	var left_direction = Vector3(to_target.z, 0, -to_target.x)
	
	# 检查右侧是否可通行
	var right_pos = current_pos + right_direction * 2.0
	if GridPathFinder and GridPathFinder.is_ready():
		var right_grid = GridPathFinder.world_to_grid(right_pos)
		if not GridPathFinder.is_point_solid(right_grid):
			return right_direction
	
	# 检查左侧是否可通行
	var left_pos = current_pos + left_direction * 2.0
	if GridPathFinder and GridPathFinder.is_ready():
		var left_grid = GridPathFinder.world_to_grid(left_pos)
		if not GridPathFinder.is_point_solid(left_grid):
			return left_direction
	
	# 如果左右都被阻挡，尝试向后移动
	var backward_direction = - to_target
	var backward_pos = current_pos + backward_direction * 2.0
	if GridPathFinder and GridPathFinder.is_ready():
		var backward_grid = GridPathFinder.world_to_grid(backward_pos)
		if not GridPathFinder.is_point_solid(backward_grid):
			return backward_direction
	
	# 如果所有方向都被阻挡，返回右侧方向（让单位尝试移动）
	return right_direction

## 🚶 应用避障移动
static func _apply_avoidance_movement(character: Node, direction: Vector3) -> void:
	"""🚶 应用避障移动
	
	🔍 原理：让单位朝向指定方向移动，速度较慢以便观察和调整
	"""
	if direction.length() < 0.01:
		return
	
	# 计算移动速度（避障移动速度较慢）
	var speed = get_character_speed(character)
	var velocity = direction * (speed / 200.0) # 避障移动速度是正常速度的一半
	velocity.y = 0 # 保持Y轴为0（地面移动）
	
	# 应用移动
	character.velocity = velocity
	
	# 应用旋转（面向移动方向）
	var target_rotation = atan2(direction.x, direction.z)
	character.rotation.y = lerp_angle(character.rotation.y, target_rotation, 0.2)

## ⚡ 获取角色的移动速度
static func get_character_speed(character: Node) -> float:
	"""⚡ 获取角色的移动速度（兼容不同的角色结构）"""
	if character.has_method("get_speed"):
		return character.get_speed()
	elif "data" in character and "speed" in character.data:
		return character.data.speed
	elif "speed" in character:
		return character.speed
	else:
		return 40.0 # 默认速度

## 🚶 应用移动（使用角色的速度）
static func apply_movement(character: Node, direction: Vector3, _delta: float) -> void:
	"""🚶 设置角色的移动速度（只设置velocity，不调用move_and_slide）
	
	🔧 [修复] 只设置 velocity，让 CharacterBase._physics_process() 统一调用 move_and_slide()
	避免双重调用导致的移动冲突
	"""
	if direction.length() < 0.01:
		character.velocity = Vector3.ZERO
		return
	
	var speed = get_character_speed(character)
	# 🔧 [关键修复] 速度需要除以100（项目约定：data.speed=40 → 实际速度=0.4米/秒）
	var velocity = direction * (speed / 100.0)
	velocity.y = 0 # 保持Y轴为0（地面移动）
	
	# 🔧 只设置 velocity，不调用 move_and_slide()（由CharacterBase统一调用）
	character.velocity = velocity
	
	# 应用旋转（面向移动方向）
	if direction.length() > 0.01:
		var target_rotation = atan2(direction.x, direction.z)
		character.rotation.y = lerp_angle(character.rotation.y, target_rotation, 0.1)

## 🛡️ 应用指定速度的移动（避障系统专用）
static func apply_movement_with_velocity(character: Node, velocity: Vector3, _delta: float) -> void:
	"""🛡️ 设置角色的移动速度（直接使用指定的速度向量）
	
	🔧 [避障系统] 用于应用经过避障计算的速度
	"""
	if velocity.length() < 0.01:
		character.velocity = Vector3.ZERO
		return
	
	# 🔧 只设置 velocity，不调用 move_and_slide()（由CharacterBase统一调用）
	character.velocity = velocity
	
	# 应用旋转（面向移动方向）
	if velocity.length() > 0.01:
		var direction = velocity.normalized()
		var target_rotation = atan2(direction.x, direction.z)
		character.rotation.y = lerp_angle(character.rotation.y, target_rotation, 0.1)


# ============================================================================
# 🔧 [统一交互移动API] 两阶段移动系统
# ============================================================================

## 两阶段交互移动结果
enum InteractionMoveResult {
	MOVING_TO_ADJACENT, # 第一阶段：正在移动到相邻地块
	MOVING_TO_INTERACTION, # 第二阶段：正在精确移动到交互范围
	REACHED_INTERACTION, # 已到达交互范围
	FAILED_NO_PATH, # 寻路失败
	FAILED_STUCK # 卡住失败
}

## 两阶段交互移动状态数据
class InteractionMoveState:
	var has_reached_adjacent_tile: bool = false
	var adjacent_target: Vector3 = Vector3.ZERO
	var interaction_target: Vector3 = Vector3.ZERO
	var target_building: Node = null
	
	func _init():
		reset()
	
	func reset():
		has_reached_adjacent_tile = false
		adjacent_target = Vector3.ZERO
		interaction_target = Vector3.ZERO
		target_building = null

# 全局状态存储（按角色存储）
var interaction_move_states: Dictionary = {}

static func process_interaction_movement(
	character: Node,
	target_building: Node,
	delta: float,
	debug_prefix: String = ""
) -> InteractionMoveResult:
	"""统一的两阶段交互移动API
	
	🔧 [统一交互移动] 所有建筑交互都使用这个API：
	1. 第一阶段：使用AStarGrid2D移动到建筑相邻的可通行地块
	2. 第二阶段：使用直接移动精确移动到Area3D交互范围
	
	Args:
		character: 角色对象
		target_building: 目标建筑（金矿、地牢之心、金库等）
		delta: 时间增量
		debug_prefix: 调试日志前缀
	
	Returns:
		InteractionMoveResult: 移动结果
	"""
	if not character or not target_building:
		return InteractionMoveResult.FAILED_NO_PATH
	
	# 获取或创建移动状态（通过MovementHelper实例访问）
	var movement_helper = MovementHelper
	var state_id = str(character.get_instance_id())
	if not state_id in movement_helper.interaction_move_states:
		movement_helper.interaction_move_states[state_id] = InteractionMoveState.new()
	
	var move_state = movement_helper.interaction_move_states[state_id]
	
	# 如果目标建筑改变，重置状态
	if move_state.target_building != target_building:
		move_state.reset()
		move_state.target_building = target_building
		
		# 计算相邻目标和交互目标
		move_state.adjacent_target = BuildingFinder.get_walkable_position_near_building(character, target_building)
		move_state.interaction_target = _calculate_interaction_position(target_building, character)
		
		# 设置相邻目标
		
		if move_state.adjacent_target == Vector3.INF:
			# 无法找到建筑相邻的可通行点
			return InteractionMoveResult.FAILED_NO_PATH
		
		# 两阶段移动开始
	
	# 检查是否已到达交互范围
	if _check_in_interaction_range(character, target_building):
		# 已到达交互范围
		return InteractionMoveResult.REACHED_INTERACTION
	
	# 第一阶段：移动到相邻地块
	if not move_state.has_reached_adjacent_tile:
		var first_move_result = process_navigation(
			character,
			move_state.adjacent_target,
			delta,
			debug_prefix + "_Phase1"
		)
		
		# 🔧 [修复] 只有当真正到达相邻地块时才进入第二阶段
		if first_move_result == MoveResult.REACHED:
			var actual_distance = character.global_position.distance_to(move_state.adjacent_target)
			# 第一阶段完成
			move_state.has_reached_adjacent_tile = true
			# 已到达相邻地块，开始精确移动
		
		# 处理移动失败
		match first_move_result:
			MoveResult.FAILED_NO_PATH, MoveResult.FAILED_STUCK:
				return InteractionMoveResult.FAILED_NO_PATH
		
		return InteractionMoveResult.MOVING_TO_ADJACENT
	
	# 第二阶段：精确移动到交互范围
	if debug_prefix:
		var distance_to_interaction = character.global_position.distance_to(move_state.interaction_target)
		# 开始第二阶段精确移动
	
	var second_move_result = process_navigation(
		character,
		move_state.interaction_target,
		delta,
		debug_prefix + "_Phase2"
	)
	
	# 处理移动失败
	match second_move_result:
		MoveResult.FAILED_NO_PATH, MoveResult.FAILED_STUCK:
			return InteractionMoveResult.FAILED_STUCK
	
	return InteractionMoveResult.MOVING_TO_INTERACTION

static func reset_interaction_movement(character: Node):
	"""重置角色的交互移动状态"""
	var movement_helper = MovementHelper
	var state_id = str(character.get_instance_id())
	if state_id in movement_helper.interaction_move_states:
		movement_helper.interaction_move_states[state_id].reset()


static func _calculate_interaction_position(building: Node, character: Node) -> Vector3:
	"""计算精确交互位置（第二阶段：找到建筑内部最近的一个1x1位置）"""
	var building_pos = building.global_position
	var character_pos = character.global_position
	
	# 获取建筑大小
	var building_size = Vector2(1, 1) # 默认1x1
	if building.has_method("get_building_size"):
		building_size = building.get_building_size()
	elif "building_size" in building:
		building_size = building.building_size
	
	var size_x = int(building_size.x)
	var size_y = int(building_size.y)
	
	# 计算建筑内部所有1x1位置
	var positions: Array[Vector3] = []
	for x in range(size_x):
		for y in range(size_y):
			# 计算每个1x1格子的中心位置
			var tile_pos = Vector3(
				building_pos.x - (size_x - 1) * 0.5 + x,
				building_pos.y,
				building_pos.z - (size_y - 1) * 0.5 + y
			)
			positions.append(tile_pos)
	
	# 找到距离角色最近的位置
	var closest_pos = building_pos
	var min_distance = character_pos.distance_to(building_pos)
	
	for pos in positions:
		var distance = character_pos.distance_to(pos)
		if distance < min_distance:
			min_distance = distance
			closest_pos = pos
	
	return closest_pos

static func _check_in_interaction_range(character: Node, building: Node) -> bool:
	"""检查角色是否在建筑的交互范围内"""
	# 使用角色自己的检查方法（如果存在）
	if character.has_method("check_in_building_area3d"):
		return character.check_in_building_area3d(building)
	
	# 后备方案：距离检测
	var distance = character.global_position.distance_to(building.global_position)
	
	# 🔧 [修复] 根据建筑大小动态计算交互范围
	var interaction_range = 0.01 # 基础交互范围（0.01米）
	
	# 获取建筑大小
	var building_size = Vector2(1, 1) # 默认1x1
	if building.has_method("get_building_size"):
		building_size = building.get_building_size()
	elif "building_size" in building:
		building_size = building.building_size
	
	# 根据建筑大小计算交互范围
	var size_x = int(building_size.x)
	var size_y = int(building_size.y)
	
	# 交互范围 = 建筑大小 + 0.01米缓冲
	# 1x1建筑：1 + 0.01 = 1.01米
	# 2x2建筑：2 + 0.01 = 2.01米
	# 3x3建筑：3 + 0.01 = 3.01米
	interaction_range = max(size_x, size_y) + 0.01
	
	# 如果建筑有自定义交互范围，使用较大的值
	if building.has_method("get_interaction_range"):
		var custom_range = building.get_interaction_range()
		interaction_range = max(interaction_range, custom_range)
	elif "interaction_range" in building:
		var custom_range = building.interaction_range
		interaction_range = max(interaction_range, custom_range)
	
	return distance <= interaction_range
