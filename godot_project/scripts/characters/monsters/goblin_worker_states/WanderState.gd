extends State
class_name GoblinWorkerWanderState

## GoblinWorker 游荡状态
## 
## 职责：无目标时随机移动，定期检查新任务
## 
## 转换条件：
## - 定时检查（2秒） → IdleState
## - 发现敌人 → EscapeState

var wander_timer: Timer = null
var wander_check_interval: float = 2.0
var wander_target: Vector3 = Vector3.ZERO
var wander_radius: float = 50.0

func enter(_data: Dictionary = {}) -> void:
	var worker = state_machine.owner
	
	# 生成随机游荡目标
	_generate_wander_target(worker)
	
	# 播放行走动画
	if worker.has_node("Model") and worker.get_node("Model").has_method("play_animation"):
		worker.get_node("Model").play_animation("move", 0.8) # 游荡速度慢一点
	elif worker.has_node("AnimationPlayer"):
		worker.get_node("AnimationPlayer").play("move")
	
	# 创建检查计时器
	wander_timer = Timer.new()
	wander_timer.wait_time = wander_check_interval
	wander_timer.timeout.connect(_on_check_situation)
	add_child(wander_timer)
	wander_timer.start()
	
	if state_machine.debug_mode:
		print("[WanderState] 开始游荡 | 目标: %s" % str(wander_target))

func physics_update(_delta: float) -> void:
	var worker = state_machine.owner
	
	# 🔧 [逻辑修复] 优先级1: 检查是否携带金币
	# 如果有金币，立即转到IdleState，让它处理返回基地
	if worker.carried_gold > 0:
		# 发现携带金币，转到IdleState处理
		state_finished.emit("IdleState", {})
		return
	
	# 检查是否有敌人
	if _has_nearby_enemies(worker):
		state_finished.emit("EscapeState")
		return
	
	# 🔧 [统一移动API] 使用 MovementHelper.process_navigation 处理游荡移动
	var move_result = MovementHelper.process_navigation(
		worker,
		wander_target,
		_delta,
		"WanderState" if state_machine.debug_mode else ""
	)
	
	# 处理移动结果
	match move_result:
		MovementHelper.MoveResult.REACHED:
			# 到达目标，生成新的游荡目标
			_generate_wander_target(worker)
		MovementHelper.MoveResult.FAILED_NO_PATH, MovementHelper.MoveResult.FAILED_STUCK:
			# 游荡失败，生成新目标
			_generate_wander_target(worker)

func _on_check_situation() -> void:
	"""定时检查是否有新任务"""
	# 返回空闲状态重新评估
	state_finished.emit("IdleState", {})

func exit() -> void:
	var worker = state_machine.owner
	worker.velocity = Vector3.ZERO
	
	# 清理计时器
	if wander_timer:
		wander_timer.stop()
		wander_timer.queue_free()
		wander_timer = null

func _generate_wander_target(worker: Node) -> void:
	"""生成随机游荡目标
	
	🔧 [AStarGrid重构] 使用GridPathFinder.get_walkable_neighbors()
	确保游荡目标在可通行区域
	"""
	# 尝试使用GridPathFinder找到可通行的邻居
	if GridPathFinder and GridPathFinder.is_ready():
		var walkable = GridPathFinder.get_walkable_neighbors(worker.global_position)
		if walkable.size() > 0:
			# 从可通行邻居中随机选择一个
			var random_neighbor = walkable[randi() % walkable.size()]
			wander_target = random_neighbor
			wander_target.y = 0.05
			return
	
	# 后备方案：随机生成（可能不可通行）
	var angle = randf() * TAU
	var distance = randf() * min(wander_radius, 10.0) # 限制范围更小
	
	wander_target = worker.global_position + Vector3(
		cos(angle) * distance,
		0,
		sin(angle) * distance
	)
	wander_target.y = 0.05

func _has_nearby_enemies(worker: Node) -> bool:
	"""检查是否有敌人在附近"""
	# 使用 MonsterBase 的 find_nearest_enemy 方法
	var enemy = worker.find_nearest_enemy()
	if enemy and worker.global_position.distance_to(enemy.global_position) < 15.0:
		return true
	
	return false
