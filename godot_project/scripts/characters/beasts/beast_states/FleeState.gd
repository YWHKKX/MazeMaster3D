extends State
class_name BeastFleeState

## 野兽逃跑状态
## 
## 职责：中立野兽的逃跑行为，远离威胁
## 
## 转换条件：
## - 威胁消失 → IdleState
## - 逃跑时间过长 → IdleState
## - 找到安全位置 → IdleState

var threat_position: Vector3 = Vector3.ZERO
var flee_timer: Timer = null
var flee_duration: float = 0.0
var max_flee_time: float = 10.0
var flee_speed_multiplier: float = 1.5

func enter(data: Dictionary = {}) -> void:
	var beast = state_machine.owner
	
	# 播放逃跑动画
	if beast.has_node("Model") and beast.get_node("Model").has_method("play_animation"):
		beast.get_node("Model").play_animation("run")
	elif beast.animation_player:
		beast.animation_player.play("run")
	
	# 获取威胁位置
	if data.has("threat_position"):
		threat_position = data["threat_position"]
	else:
		# 寻找最近的威胁
		threat_position = _find_nearest_threat_position(beast)
	
	# 随机逃跑时间
	flee_duration = randf_range(3.0, max_flee_time)
	
	# 创建逃跑计时器
	flee_timer = Timer.new()
	flee_timer.wait_time = flee_duration
	flee_timer.timeout.connect(_on_flee_timeout)
	add_child(flee_timer)
	flee_timer.start()
	
	# 计算逃跑方向
	_calculate_flee_direction(beast)
	
	if state_machine.debug_mode:
		print("[BeastFleeState] 野兽开始逃跑 | 威胁位置: %s" % str(threat_position))

func update(_delta: float) -> void:
	var beast = state_machine.owner
	
	# 检查威胁是否仍然存在
	if not _threat_still_present(beast):
		state_finished.emit("IdleState", {})
		return
	
	# 更新威胁位置
	threat_position = _find_nearest_threat_position(beast)
	
	# 计算逃跑方向并移动
	_calculate_flee_direction(beast)
	_move_away_from_threat(beast, _delta)

func _find_nearest_threat_position(beast: Node) -> Vector3:
	"""寻找最近威胁的位置"""
	var enemies = beast.get_tree().get_nodes_in_group("characters")
	var nearest_threat = null
	var min_distance = INF
	
	for enemy in enemies:
		if enemy != beast and is_instance_valid(enemy):
			if beast.is_enemy_of(enemy):
				var distance = beast.global_position.distance_to(enemy.global_position)
				if distance < beast.detection_range and distance < min_distance:
					min_distance = distance
					nearest_threat = enemy
	
	if nearest_threat:
		return nearest_threat.global_position
	else:
		return beast.global_position

func _threat_still_present(beast: Node) -> bool:
	"""检查威胁是否仍然存在"""
	var enemies = beast.get_tree().get_nodes_in_group("characters")
	for enemy in enemies:
		if enemy != beast and is_instance_valid(enemy):
			if beast.is_enemy_of(enemy):
				var distance = beast.global_position.distance_to(enemy.global_position)
				if distance < beast.detection_range * 1.5:  # 逃跑时检测范围更大
					return true
	return false

func _calculate_flee_direction(beast: Node) -> void:
	"""计算逃跑方向"""
	var current_pos = beast.global_position
	var flee_direction = (current_pos - threat_position).normalized()
	
	# 添加一些随机性，避免所有野兽朝同一方向逃跑
	var random_angle = randf_range(-PI/4, PI/4)
	var rotation_matrix = Transform3D().rotated(Vector3.UP, random_angle)
	flee_direction = rotation_matrix * flee_direction
	
	# 设置移动目标
	var flee_target = current_pos + flee_direction * 20.0
	if beast.has_method("set_movement_target"):
		beast.set_movement_target(flee_target)

func _move_away_from_threat(beast: Node, delta: float) -> void:
	"""远离威胁移动"""
	if not beast.has_method("move_towards"):
		return
	
	# 使用逃跑速度
	var original_speed = beast.speed
	beast.speed = original_speed * flee_speed_multiplier
	
	# 移动到逃跑目标
	var flee_direction = (beast.global_position - threat_position).normalized()
	var flee_target = beast.global_position + flee_direction * 20.0
	beast.move_towards(flee_target, delta)
	
	# 恢复原始速度
	beast.speed = original_speed

func _on_flee_timeout() -> void:
	"""逃跑时间结束"""
	state_finished.emit("IdleState", {})

func exit() -> void:
	# 清理计时器
	if flee_timer:
		flee_timer.stop()
		flee_timer.queue_free()
		flee_timer = null
