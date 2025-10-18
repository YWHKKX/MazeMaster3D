extends State
class_name HeroPatrolState

## 英雄巡逻状态
## 
## 职责：友方英雄的巡逻行为，保护区域
## 
## 转换条件：
## - 发现敌人 → CombatState
## - 发现受伤友军 → SupportState
## - 巡逻完成 → IdleState
## - 收到新指令 → IdleState

var patrol_points: Array[Vector3] = []
var current_patrol_index: int = 0
var patrol_timer: Timer = null
var patrol_duration: float = 0.0
var max_patrol_time: float = 20.0

func enter(_data: Dictionary = {}) -> void:
	var hero = state_machine.owner_node
	
	# 播放巡逻动画
	if hero.has_node("Model") and hero.get_node("Model").has_method("play_animation"):
		hero.get_node("Model").play_animation("walk")
	elif hero.animation_player:
		hero.animation_player.play("walk")
	
	# 生成巡逻点
	_generate_patrol_points(hero)
	
	# 随机巡逻时间
	patrol_duration = randf_range(10.0, max_patrol_time)
	
	# 创建巡逻计时器
	patrol_timer = Timer.new()
	patrol_timer.wait_time = patrol_duration
	patrol_timer.timeout.connect(_on_patrol_timeout)
	add_child(patrol_timer)
	patrol_timer.start()

func update(_delta: float) -> void:
	var hero = state_machine.owner_node
	
	# 优先级1: 战斗准备 - 检测敌人
	if _has_nearby_enemies(hero):
		state_finished.emit("CombatState", {})
		return
	
	# 优先级2: 支援任务 - 帮助受伤的友军
	if _has_injured_allies(hero):
		var injured_ally = _find_nearest_injured_ally(hero)
		if injured_ally:
			state_finished.emit("SupportState", {"target_ally": injured_ally})
			return
	
	# 优先级3: 巡逻行为 - 移动到下一个巡逻点
	_patrol_to_next_point(hero, _delta)

func _generate_patrol_points(hero: Node) -> void:
	"""生成巡逻点"""
	patrol_points.clear()
	current_patrol_index = 0
	
	var start_pos = hero.global_position
	var patrol_radius = 15.0
	var point_count = 4
	
	for i in range(point_count):
		var angle = (i * 2.0 * PI) / point_count
		var offset = Vector3(
			cos(angle) * patrol_radius,
			0,
			sin(angle) * patrol_radius
		)
		patrol_points.append(start_pos + offset)

func _patrol_to_next_point(hero: Node, delta: float) -> void:
	"""巡逻到下一个点"""
	if patrol_points.is_empty():
		return
	
	var current_target = patrol_points[current_patrol_index]
	
	# 🔧 [统一移动API] 使用 MovementHelper.process_navigation 处理巡逻移动
	var move_result = MovementHelper.process_navigation(
		hero,
		current_target,
		delta,
		"HeroPatrolState" if state_machine.debug_mode else ""
	)
	
	# 处理移动结果
	match move_result:
		MovementHelper.MoveResult.REACHED:
			# 到达巡逻点，移动到下一个点
			current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
			_wait_at_patrol_point(hero)
		MovementHelper.MoveResult.FAILED_NO_PATH, MovementHelper.MoveResult.FAILED_STUCK:
			# 移动失败，跳过这个巡逻点
			current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		# MovementHelper.MoveResult.MOVING: 继续移动

func _reached_patrol_point(hero: Node, target: Vector3) -> bool:
	"""检查是否到达巡逻点"""
	var distance = hero.global_position.distance_to(target)
	return distance < 2.0

func _wait_at_patrol_point(hero: Node) -> void:
	"""在巡逻点等待"""
	# 停止移动
	hero.velocity = Vector3.ZERO
	
	# 播放待机动画
	if hero.has_node("Model") and hero.get_node("Model").has_method("play_animation"):
		hero.get_node("Model").play_animation("idle")
	elif hero.animation_player:
		hero.animation_player.play("idle")
	
	# 等待一段时间后继续巡逻
	var wait_timer = Timer.new()
	wait_timer.wait_time = randf_range(1.0, 3.0)
	wait_timer.timeout.connect(func(): wait_timer.queue_free())
	add_child(wait_timer)
	wait_timer.start()

func _has_nearby_enemies(hero: Node) -> bool:
	"""检查附近是否有敌人"""
	var enemies = hero.get_tree().get_nodes_in_group("characters")
	for enemy in enemies:
		if enemy != hero and is_instance_valid(enemy):
			if hero.is_enemy_of(enemy):
				var distance = hero.global_position.distance_to(enemy.global_position)
				if distance < hero.detection_range:
					return true
	return false

func _has_injured_allies(hero: Node) -> bool:
	"""检查是否有受伤的友军"""
	var allies = hero.get_tree().get_nodes_in_group("characters")
	for ally in allies:
		if ally != hero and is_instance_valid(ally):
			if hero.is_friend_of(ally):
				var distance = hero.global_position.distance_to(ally.global_position)
				if distance < hero.detection_range * 1.5:
					if ally.has_method("get_health_percentage"):
						if ally.get_health_percentage() < 0.8:
							return true
	return false

func _find_nearest_injured_ally(hero: Node) -> Node:
	"""寻找最近的受伤友军"""
	var allies = hero.get_tree().get_nodes_in_group("characters")
	var nearest_ally = null
	var min_distance = INF
	
	for ally in allies:
		if ally != hero and is_instance_valid(ally):
			if hero.is_friend_of(ally):
				var distance = hero.global_position.distance_to(ally.global_position)
				if distance < hero.detection_range * 1.5:
					if ally.has_method("get_health_percentage"):
						if ally.get_health_percentage() < 0.8:
							if distance < min_distance:
								min_distance = distance
								nearest_ally = ally
	
	return nearest_ally

func _on_patrol_timeout() -> void:
	"""巡逻时间结束"""
	state_finished.emit("IdleState", {})

func exit() -> void:
	# 清理计时器
	if patrol_timer:
		patrol_timer.stop()
		patrol_timer.queue_free()
		patrol_timer = null
