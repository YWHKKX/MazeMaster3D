extends State
class_name GoblinEngineerMoveToTargetState

## GoblinEngineer 移动到目标建筑状态
## 
## 职责：携带金币前往目标建筑的交互范围
## 
## 转换条件：
## - 到达建筑交互范围 → WorkState
## - 建筑失效/被摧毁 → IdleState
## - 发现敌人 → EscapeState

var target_building: Node = null
var target_position: Vector3 = Vector3.ZERO # 🔧 目标可通行位置（建筑周围）

# 🔧 [统一移动API] 使用 process_interaction_movement() 进行两阶段移动
# 不再需要手动管理 current_path 和 current_waypoint

func enter(data: Dictionary = {}) -> void:
	var engineer = state_machine.owner_node
	
	# 获取目标建筑
	if data.has("target_building"):
		target_building = data["target_building"]
	else:
		state_finished.emit("IdleState", {})
		return
	
	# 🔧 修复：检查目标建筑是否有效
	if not target_building or not is_instance_valid(target_building):
		state_finished.emit("IdleState", {})
		return
	
	# 配置移动到目标建筑
	
	# 🔧 [统一交互移动API] 重置交互移动状态（新状态开始）
	MovementHelper.reset_interaction_movement(engineer)
	
	# 播放行走动画
	if engineer.has_node("Model") and engineer.get_node("Model").has_method("play_animation"):
		engineer.get_node("Model").play_animation("move")
	
	# 🔧 使用 current_building 而非 target_building
	engineer.current_building = target_building
	

func physics_update(_delta: float) -> void:
	var engineer = state_machine.owner_node
	
	# 检查建筑是否有效
	if not is_instance_valid(target_building) or target_building.is_destroyed():
		state_finished.emit("IdleState", {})
		return
	
	# 检查是否有敌人
	if _has_nearby_enemies(engineer):
		state_finished.emit("EscapeState", {})
		return
	
	# 🔧 [统一交互移动API] 使用两阶段移动逻辑
	var move_result = MovementHelper.process_interaction_movement(
		engineer,
		target_building,
		_delta,
		"MoveToTargetState" if state_machine.debug_mode else ""
	)
	
	# 根据移动结果处理状态转换
	match move_result:
		MovementHelper.InteractionMoveResult.REACHED_INTERACTION:
			# 已到达交互范围，开始工作
			state_finished.emit("WorkState", {"target_building": target_building})
			return
		MovementHelper.InteractionMoveResult.FAILED_NO_PATH, MovementHelper.InteractionMoveResult.FAILED_STUCK:
			# 寻路失败或卡住，返回空闲
			state_finished.emit("IdleState", {})
		# MOVING_TO_ADJACENT 和 MOVING_TO_INTERACTION 继续移动

func exit() -> void:
	var engineer = state_machine.owner_node
	engineer.velocity = Vector3.ZERO

func _has_nearby_enemies(engineer: Node) -> bool:
	"""检查是否有敌人在附近"""
	# 使用 MonsterBase 的 find_nearest_enemy 方法
	var enemy = engineer.find_nearest_enemy()
	# 🔧 修复：检查敌人是否有效
	if enemy and is_instance_valid(enemy) and engineer and engineer.global_position.distance_to(enemy.global_position) < 15.0:
		return true
	
	return false
