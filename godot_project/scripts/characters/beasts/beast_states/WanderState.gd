extends State
class_name BeastWanderState

## 野兽游荡状态
## 
## 职责：中立野兽的探索行为
## 
## 转换条件：
## - 发现威胁 → FleeState
## - 发现食物 → SeekFoodState
## - 游荡时间结束 → IdleState
## - 需要休息 → RestState

var target_position: Vector3 = Vector3.ZERO
var wander_timer: Timer = null
var wander_duration: float = 0.0
var max_wander_time: float = 8.0
var wander_radius: float = 10.0

func enter(_data: Dictionary = {}) -> void:
	if not state_machine or not state_machine.owner_node:
		return
	var beast = state_machine.owner_node
	
	# 播放移动动画
	if beast.has_node("Model") and beast.get_node("Model").has_method("play_animation"):
		beast.get_node("Model").play_animation("walk")
	elif beast.animation_player:
		beast.animation_player.play("walk")
	
	# 随机游荡时间
	wander_duration = randf_range(3.0, max_wander_time)
	
	# 创建游荡计时器
	wander_timer = Timer.new()
	wander_timer.wait_time = wander_duration
	wander_timer.timeout.connect(_on_wander_timeout)
	add_child(wander_timer)
	wander_timer.start()
	
	# 选择游荡目标点
	_choose_wander_target(beast)
	
func update(_delta: float) -> void:
	if not state_machine or not state_machine.owner_node:
		return
	var beast = state_machine.owner_node
	
	# 优先级1: 安全检查 - 检测威胁
	if _has_nearby_threats(beast):
		state_finished.emit("FleeState", {})
		return
	
	# 优先级2: 检查是否发现食物
	var food_source = _find_nearest_food(beast)
	if food_source:
		state_finished.emit("SeekFoodState", {"target_food": food_source})
		return
	
	# 优先级3: 移动到目标点
	_move_to_target(beast, _delta)
	
	# 检查是否到达目标点
	if _reached_target(beast):
		# 到达目标点，选择新的游荡目标
		_choose_wander_target(beast)

func _choose_wander_target(beast: Node) -> void:
	"""选择游荡目标点"""
	var current_pos = beast.global_position
	var angle = randf() * 2.0 * PI
	var distance = randf_range(5.0, wander_radius)
	
	target_position = current_pos + Vector3(
		cos(angle) * distance,
		0,
		sin(angle) * distance
	)
	
	# 设置移动目标
	if beast.has_method("set_movement_target"):
		beast.set_movement_target(target_position)

func _move_to_target(beast: Node, delta: float) -> void:
	"""移动到目标点"""
	# 🔧 [统一移动API] 使用 MovementHelper.process_navigation 处理游荡移动
	var move_result = MovementHelper.process_navigation(
		beast,
		target_position,
		delta,
		"BeastWanderState" if state_machine.debug_mode else ""
	)
	
	# 处理移动结果
	match move_result:
		MovementHelper.MoveResult.REACHED:
			# 到达目标点，选择新的游荡目标
			_choose_wander_target(beast)
		MovementHelper.MoveResult.FAILED_NO_PATH, MovementHelper.MoveResult.FAILED_STUCK:
			# 移动失败，选择新的游荡目标
			_choose_wander_target(beast)
		# MovementHelper.MoveResult.MOVING: 继续移动

func _reached_target(beast: Node) -> bool:
	"""检查是否到达目标点"""
	var distance = beast.global_position.distance_to(target_position)
	return distance < 2.0

func _has_nearby_threats(beast: Node) -> bool:
	"""检查附近是否有威胁"""
	var enemies = beast.get_tree().get_nodes_in_group("characters")
	for enemy in enemies:
		if enemy != beast and is_instance_valid(enemy):
			if beast.is_enemy_of(enemy):
				var distance = beast.global_position.distance_to(enemy.global_position)
				if distance < beast.detection_range:
					return true
	return false

func _find_nearest_food(_beast: Node) -> Node:
	"""寻找最近的食物源"""
	# 这里可以扩展为寻找实际的资源点
	# 暂时返回null，让野兽继续游荡
	return null

func _on_wander_timeout() -> void:
	"""游荡时间结束"""
	state_finished.emit("IdleState", {})

func exit() -> void:
	# 清理计时器
	if wander_timer:
		wander_timer.stop()
		wander_timer.queue_free()
		wander_timer = null
