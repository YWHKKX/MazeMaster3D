extends State
class_name MonsterChaseState

## 怪物追击状态
## 
## 职责：敌对怪物的追击行为，追赶逃跑的敌人
## 
## 转换条件：
## - 追上敌人 → CombatState
## - 敌人消失 → IdleState
## - 追击超时 → IdleState
## - 发现新敌人 → CombatState

var target_enemy: Node = null
var chase_timer: Timer = null
var chase_duration: float = 0.0
var max_chase_time: float = 15.0
var chase_speed_multiplier: float = 1.3

func enter(data: Dictionary = {}) -> void:
	var monster = state_machine.owner_node
	
	# 获取目标敌人
	if data.has("target_enemy"):
		target_enemy = data["target_enemy"]
	else:
		target_enemy = _find_nearest_enemy(monster)
	
	if not target_enemy:
		state_finished.emit("IdleState", {})
		return
	
	# 播放追击动画
	if monster.has_node("Model") and monster.get_node("Model").has_method("play_animation"):
		monster.get_node("Model").play_animation("run")
	elif monster.animation_player:
		monster.animation_player.play("run")
	
	# 随机追击时间
	chase_duration = randf_range(5.0, max_chase_time)
	
	# 创建追击计时器
	chase_timer = Timer.new()
	chase_timer.wait_time = chase_duration
	chase_timer.timeout.connect(_on_chase_timeout)
	add_child(chase_timer)
	chase_timer.start()
		

func update(_delta: float) -> void:
	var monster = state_machine.owner_node
	
	# 检查目标敌人是否仍然有效
	if not target_enemy or not is_instance_valid(target_enemy):
		target_enemy = _find_nearest_enemy(monster)
		if not target_enemy:
			state_finished.emit("IdleState", {})
			return
	
	# 检查是否在攻击范围内
	if _in_attack_range(monster):
		state_finished.emit("CombatState", {"target_enemy": target_enemy})
		return
	
	# 追击敌人
	_chase_enemy(monster, _delta)

func _find_nearest_enemy(monster: Node) -> Node:
	"""寻找最近的敌人"""
	var enemies = monster.get_tree().get_nodes_in_group("characters")
	var nearest_enemy = null
	var min_distance = INF
	
	for enemy in enemies:
		if enemy != monster and is_instance_valid(enemy):
			if monster.is_enemy_of(enemy):
				var distance = monster.global_position.distance_to(enemy.global_position)
				if distance < monster.detection_range * 1.5 and distance < min_distance: # 追击时检测范围更大
					min_distance = distance
					nearest_enemy = enemy
	
	return nearest_enemy

func _in_attack_range(monster: Node) -> bool:
	"""检查是否在攻击范围内"""
	if not target_enemy:
		return false
	
	var distance = monster.global_position.distance_to(target_enemy.global_position)
	var attack_range = monster.attack_range if monster.has_method("get_attack_range") else 2.5
	return distance <= attack_range

func _chase_enemy(monster: Node, delta: float) -> void:
	"""追击敌人"""
	if not target_enemy:
		return
	
	# 🔧 [统一移动API] 使用 MovementHelper.process_navigation 处理追击移动
	var move_result = MovementHelper.process_navigation(
		monster,
		target_enemy.global_position,
		delta,
		"ChaseState" if state_machine.debug_mode else ""
	)
	
	# 处理移动结果
	match move_result:
		MovementHelper.MoveResult.REACHED:
			# 到达敌人位置，进入战斗状态
			state_finished.emit("CombatState", {"target_enemy": target_enemy})
		MovementHelper.MoveResult.FAILED_NO_PATH, MovementHelper.MoveResult.FAILED_STUCK:
			# 追击失败，返回空闲状态
			state_finished.emit("IdleState", {})
		# MovementHelper.MoveResult.MOVING: 继续追击

func _on_chase_timeout() -> void:
	"""追击超时"""
	state_finished.emit("IdleState", {})

func exit() -> void:
	# 清理计时器
	if chase_timer:
		chase_timer.stop()
		chase_timer.queue_free()
		chase_timer = null
