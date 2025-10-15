extends State
class_name MonsterRetreatState

## 怪物撤退状态
## 
## 职责：敌对怪物的撤退行为，寻找安全位置
## 
## 转换条件：
## - 到达安全位置 → IdleState
## - 恢复健康 → IdleState
## - 撤退超时 → IdleState

var retreat_timer: Timer = null
var retreat_duration: float = 0.0
var max_retreat_time: float = 8.0
var retreat_speed_multiplier: float = 1.1

func enter(_data: Dictionary = {}) -> void:
	var monster = state_machine.owner
	
	# 播放撤退动画
	if monster.has_node("Model") and monster.get_node("Model").has_method("play_animation"):
		monster.get_node("Model").play_animation("retreat")
	elif monster.animation_player:
		monster.animation_player.play("retreat")
	
	# 随机撤退时间
	retreat_duration = randf_range(3.0, max_retreat_time)
	
	# 创建撤退计时器
	retreat_timer = Timer.new()
	retreat_timer.wait_time = retreat_duration
	retreat_timer.timeout.connect(_on_retreat_timeout)
	add_child(retreat_timer)
	retreat_timer.start()
	
	# 寻找安全位置
	_find_safe_position(monster)
	
	if state_machine.debug_mode:
		print("[MonsterRetreatState] 怪物开始撤退 | 撤退时间: %.1f秒" % retreat_duration)

func update(_delta: float) -> void:
	var monster = state_machine.owner
	
	# 检查是否恢复健康
	if _is_healthy_enough(monster):
		state_finished.emit("IdleState", {})
		return
	
	# 撤退到安全位置
	_retreat_to_safety(monster, _delta)

func _find_safe_position(monster: Node) -> void:
	"""寻找安全位置"""
	var current_pos = monster.global_position
	var safe_distance = 15.0
	
	# 寻找远离敌人的方向
	var enemy_direction = _get_enemy_direction(monster)
	var safe_direction = -enemy_direction if enemy_direction != Vector3.ZERO else Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	
	var safe_position = current_pos + safe_direction * safe_distance
	
	# 设置移动目标
	if monster.has_method("set_movement_target"):
		monster.set_movement_target(safe_position)

func _get_enemy_direction(monster: Node) -> Vector3:
	"""获取敌人方向"""
	var enemies = monster.get_tree().get_nodes_in_group("characters")
	var enemy_direction = Vector3.ZERO
	
	for enemy in enemies:
		if enemy != monster and is_instance_valid(enemy):
			if monster.is_enemy_of(enemy):
				var distance = monster.global_position.distance_to(enemy.global_position)
				if distance < monster.detection_range * 1.5:  # 撤退时检测范围更大
					var direction = (enemy.global_position - monster.global_position).normalized()
					enemy_direction += direction
	
	return enemy_direction.normalized()

func _retreat_to_safety(monster: Node, delta: float) -> void:
	"""撤退到安全位置"""
	if not monster.has_method("move_towards"):
		return
	
	# 使用撤退速度
	var original_speed = monster.speed
	monster.speed = original_speed * retreat_speed_multiplier
	
	# 移动到安全位置
	var safe_direction = _get_enemy_direction(monster)
	if safe_direction != Vector3.ZERO:
		var retreat_target = monster.global_position - safe_direction * 15.0
		monster.move_towards(retreat_target, delta)
	else:
		# 随机撤退方向
		var random_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		var retreat_target = monster.global_position + random_direction * 15.0
		monster.move_towards(retreat_target, delta)
	
	# 恢复原始速度
	monster.speed = original_speed

func _is_healthy_enough(monster: Node) -> bool:
	"""检查是否恢复足够的健康"""
	if monster.has_method("get_health_percentage"):
		return monster.get_health_percentage() >= 0.4  # 40%以上可以停止撤退
	return false

func _on_retreat_timeout() -> void:
	"""撤退时间结束"""
	state_finished.emit("IdleState", {})

func exit() -> void:
	# 清理计时器
	if retreat_timer:
		retreat_timer.stop()
		retreat_timer.queue_free()
		retreat_timer = null
