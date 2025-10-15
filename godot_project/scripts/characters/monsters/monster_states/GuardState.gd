extends State
class_name MonsterGuardState

## 怪物守卫状态
## 
## 职责：敌对怪物的守卫行为，保护特定区域
## 
## 转换条件：
## - 发现敌人 → CombatState
## - 守卫超时 → IdleState
## - 收到新指令 → IdleState

var guard_position: Vector3 = Vector3.ZERO
var guard_timer: Timer = null
var guard_duration: float = 0.0
var max_guard_time: float = 30.0
var guard_radius: float = 10.0

func enter(_data: Dictionary = {}) -> void:
	var monster = state_machine.owner
	
	# 设置守卫位置
	guard_position = monster.global_position
	
	# 播放守卫动画
	if monster.has_node("Model") and monster.get_node("Model").has_method("play_animation"):
		monster.get_node("Model").play_animation("guard")
	elif monster.animation_player:
		monster.animation_player.play("guard")
	
	# 随机守卫时间
	guard_duration = randf_range(20.0, max_guard_time)
	
	# 创建守卫计时器
	guard_timer = Timer.new()
	guard_timer.wait_time = guard_duration
	guard_timer.timeout.connect(_on_guard_timeout)
	add_child(guard_timer)
	guard_timer.start()
	
	if state_machine.debug_mode:
		print("[MonsterGuardState] 怪物开始守卫 | 守卫位置: %s" % str(guard_position))

func update(_delta: float) -> void:
	var monster = state_machine.owner
	
	# 优先级1: 战斗准备 - 检测敌人
	if _has_nearby_enemies(monster):
		state_finished.emit("CombatState", {})
		return
	
	# 优先级2: 守卫行为 - 保持在守卫区域内
	_maintain_guard_position(monster, _delta)

func _maintain_guard_position(monster: Node, delta: float) -> void:
	"""保持在守卫位置"""
	var current_pos = monster.global_position
	var distance_from_guard = current_pos.distance_to(guard_position)
	
	# 如果距离守卫位置太远，返回守卫位置
	if distance_from_guard > guard_radius:
		if monster.has_method("move_towards"):
			monster.move_towards(guard_position, delta)
	else:
		# 在守卫区域内，停止移动
		monster.velocity = Vector3.ZERO
		
		# 播放守卫动画
		if monster.has_node("Model") and monster.get_node("Model").has_method("play_animation"):
			monster.get_node("Model").play_animation("guard")
		elif monster.animation_player:
			monster.animation_player.play("guard")

func _has_nearby_enemies(monster: Node) -> bool:
	"""检查附近是否有敌人"""
	var enemies = monster.get_tree().get_nodes_in_group("characters")
	for enemy in enemies:
		if enemy != monster and is_instance_valid(enemy):
			if monster.is_enemy_of(enemy):
				var distance = monster.global_position.distance_to(enemy.global_position)
				if distance < monster.detection_range:
					return true
	return false

func _on_guard_timeout() -> void:
	"""守卫时间结束"""
	state_finished.emit("IdleState", {})

func exit() -> void:
	# 清理计时器
	if guard_timer:
		guard_timer.stop()
		guard_timer.queue_free()
		guard_timer = null
