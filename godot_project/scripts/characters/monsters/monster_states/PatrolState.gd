extends State
class_name MonsterPatrolState

## 怪物巡逻状态
## 
## 职责：敌对怪物的巡逻行为，寻找目标
## 
## 转换条件：
## - 发现敌人 → CombatState
## - 巡逻完成 → IdleState
## - 收到新指令 → IdleState

var patrol_points: Array[Vector3] = []
var current_patrol_index: int = 0
var patrol_timer: Timer = null
var patrol_duration: float = 0.0
var max_patrol_time: float = 25.0

func enter(_data: Dictionary = {}) -> void:
	var monster = state_machine.owner
	
	# 播放巡逻动画
	if monster.has_node("Model") and monster.get_node("Model").has_method("play_animation"):
		monster.get_node("Model").play_animation("walk")
	elif monster.animation_player:
		monster.animation_player.play("walk")
	
	# 生成巡逻点
	_generate_patrol_points(monster)
	
	# 随机巡逻时间
	patrol_duration = randf_range(15.0, max_patrol_time)
	
	# 创建巡逻计时器
	patrol_timer = Timer.new()
	patrol_timer.wait_time = patrol_duration
	patrol_timer.timeout.connect(_on_patrol_timeout)
	add_child(patrol_timer)
	patrol_timer.start()
	
	if state_machine.debug_mode:
		print("[MonsterPatrolState] 怪物开始巡逻 | 巡逻点数量: %d" % patrol_points.size())

func update(_delta: float) -> void:
	var monster = state_machine.owner
	
	# 优先级1: 战斗准备 - 检测敌人
	if _has_nearby_enemies(monster):
		state_finished.emit("CombatState", {})
		return
	
	# 优先级2: 巡逻行为 - 移动到下一个巡逻点
	_patrol_to_next_point(monster, _delta)

func _generate_patrol_points(monster: Node) -> void:
	"""生成巡逻点"""
	patrol_points.clear()
	current_patrol_index = 0
	
	var start_pos = monster.global_position
	var patrol_radius = 20.0
	var point_count = 5
	
	for i in range(point_count):
		var angle = (i * 2.0 * PI) / point_count
		var offset = Vector3(
			cos(angle) * patrol_radius,
			0,
			sin(angle) * patrol_radius
		)
		patrol_points.append(start_pos + offset)

func _patrol_to_next_point(monster: Node, delta: float) -> void:
	"""巡逻到下一个点"""
	if patrol_points.is_empty():
		return
	
	var current_target = patrol_points[current_patrol_index]
	
	# 移动到目标点
	if monster.has_method("move_towards"):
		monster.move_towards(current_target, delta)
	
	# 检查是否到达目标点
	if _reached_patrol_point(monster, current_target):
		# 到达巡逻点，移动到下一个点
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		
		# 在巡逻点停留一会儿
		_wait_at_patrol_point(monster)

func _reached_patrol_point(monster: Node, target: Vector3) -> bool:
	"""检查是否到达巡逻点"""
	var distance = monster.global_position.distance_to(target)
	return distance < 3.0

func _wait_at_patrol_point(monster: Node) -> void:
	"""在巡逻点等待"""
	# 停止移动
	monster.velocity = Vector3.ZERO
	
	# 播放待机动画
	if monster.has_node("Model") and monster.get_node("Model").has_method("play_animation"):
		monster.get_node("Model").play_animation("idle")
	elif monster.animation_player:
		monster.animation_player.play("idle")
	
	# 等待一段时间后继续巡逻
	var wait_timer = Timer.new()
	wait_timer.wait_time = randf_range(2.0, 4.0)
	wait_timer.timeout.connect(func(): wait_timer.queue_free())
	add_child(wait_timer)
	wait_timer.start()

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

func _on_patrol_timeout() -> void:
	"""巡逻时间结束"""
	state_finished.emit("IdleState", {})

func exit() -> void:
	# 清理计时器
	if patrol_timer:
		patrol_timer.stop()
		patrol_timer.queue_free()
		patrol_timer = null
