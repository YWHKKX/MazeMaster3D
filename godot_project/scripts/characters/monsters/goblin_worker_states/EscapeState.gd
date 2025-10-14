extends State
class_name GoblinWorkerEscapeState

## GoblinWorker 逃跑状态
## 
## 职责：远离敌人，保命第一
## 
## 转换条件：
## - 敌人消失 → IdleState
## - 到达安全区域 → IdleState

var flee_speed_multiplier: float = 1.5 # 逃跑速度加成
var safe_distance: float = 20.0 # 安全距离

func enter(_data: Dictionary = {}) -> void:
	var worker = state_machine.owner
	
	# 播放奔跑动画
	if worker.has_node("Model") and worker.get_node("Model").has_method("play_animation"):
		worker.get_node("Model").play_animation("run", 1.5) # 加速播放模拟奔跑
	elif worker.has_node("AnimationPlayer"):
		var anim_player = worker.get_node("AnimationPlayer")
		if anim_player.has_animation("run"):
			anim_player.play("run")
		else:
			anim_player.play("move")
	
	# 开始逃跑，发现敌人

func physics_update(_delta: float) -> void:
	var worker = state_machine.owner
	
	# 检查敌人是否还存在
	var nearest_enemy = worker.find_nearest_enemy()
	
	if not nearest_enemy:
		# 敌人消失，返回空闲
		state_finished.emit("IdleState", {})
		return
	
	# 检查是否已脱离危险
	var distance_to_enemy = worker.global_position.distance_to(nearest_enemy.global_position)
	if distance_to_enemy > safe_distance:
		# 脱离危险，返回空闲
		state_finished.emit("IdleState", {})
		return
	
	# 🔧 [统一移动API] 计算逃跑目标位置，使用MovementHelper.process_navigation
	var flee_target = _calculate_flee_target(worker, nearest_enemy)
	
	var move_result = MovementHelper.process_navigation(
		worker,
		flee_target,
		_delta
	)
	
	# 逃跑状态下，即使失败也继续尝试逃跑
	if move_result == MovementHelper.MoveResult.FAILED_NO_PATH or move_result == MovementHelper.MoveResult.FAILED_STUCK:
		# 重新计算逃跑目标
		pass # 下一帧会重新计算
	
	# 逃跑中，持续监控敌人距离

func exit() -> void:
	var worker = state_machine.owner
	worker.velocity = Vector3.ZERO
	
	# 脱离逃跑状态

func _calculate_flee_target(worker: Node, enemy: Node) -> Vector3:
	"""计算逃跑目标位置"""
	# 计算逃跑方向（远离敌人）
	var flee_direction = (worker.global_position - enemy.global_position)
	flee_direction.y = 0 # 清零Y分量，只在XZ平面移动
	flee_direction = flee_direction.normalized()
	
	# 优先逃向基地方向
	var base = BuildingFinder.get_nearest_dungeon_heart(worker)
	if base:
		var to_base = (base.global_position - worker.global_position)
		to_base.y = 0 # 清零Y分量
		to_base = to_base.normalized()
		# 混合逃跑方向和基地方向（70%远离敌人，30%向基地）
		flee_direction = (flee_direction * 0.7 + to_base * 0.3)
		flee_direction.y = 0 # 混合后再次清零
		flee_direction = flee_direction.normalized()
	
	# 计算逃跑目标位置（距离当前位置一段距离）
	var flee_distance = 10.0 # 逃跑距离
	var flee_target = worker.global_position + flee_direction * flee_distance
	
	return flee_target
