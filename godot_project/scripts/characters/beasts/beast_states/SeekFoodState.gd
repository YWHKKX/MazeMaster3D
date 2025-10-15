extends State
class_name BeastSeekFoodState

## 野兽觅食状态
## 
## 职责：中立野兽的觅食行为
## 
## 转换条件：
## - 找到食物 → ConsumeFoodState
## - 发现威胁 → FleeState
## - 觅食超时 → IdleState
## - 找不到食物 → IdleState

var target_food: Node = null
var seek_timer: Timer = null
var seek_duration: float = 0.0
var max_seek_time: float = 15.0

func enter(data: Dictionary = {}) -> void:
	var beast = state_machine.owner
	
	# 播放觅食动画
	if beast.has_node("Model") and beast.get_node("Model").has_method("play_animation"):
		beast.get_node("Model").play_animation("walk")
	elif beast.animation_player:
		beast.animation_player.play("walk")
	
	# 获取目标食物
	if data.has("target_food"):
		target_food = data["target_food"]
	else:
		target_food = _find_nearest_food(beast)
	
	# 随机觅食时间
	seek_duration = randf_range(5.0, max_seek_time)
	
	# 创建觅食计时器
	seek_timer = Timer.new()
	seek_timer.wait_time = seek_duration
	seek_timer.timeout.connect(_on_seek_timeout)
	add_child(seek_timer)
	seek_timer.start()
	
	if state_machine.debug_mode:
		print("[BeastSeekFoodState] 野兽开始觅食 | 目标食物: %s" % str(target_food))

func update(_delta: float) -> void:
	var beast = state_machine.owner
	
	# 优先级1: 安全检查 - 检测威胁
	if _has_nearby_threats(beast):
		state_finished.emit("FleeState", {})
		return
	
	# 优先级2: 检查目标食物是否有效
	if not target_food or not is_instance_valid(target_food):
		target_food = _find_nearest_food(beast)
		if not target_food:
			state_finished.emit("IdleState", {})
			return
	
	# 优先级3: 移动到食物位置
	_move_to_food(beast, _delta)
	
	# 检查是否到达食物位置
	if _reached_food(beast):
		state_finished.emit("ConsumeFoodState", {"target_food": target_food})

func _find_nearest_food(beast: Node) -> Node:
	"""寻找最近的食物源"""
	# 这里可以扩展为寻找实际的资源点
	# 暂时返回null，让野兽继续其他行为
	return null

func _move_to_food(beast: Node, delta: float) -> void:
	"""移动到食物位置"""
	if not beast.has_method("move_towards") or not target_food:
		return
	
	# 移动到食物位置
	beast.move_towards(target_food.global_position, delta)

func _reached_food(beast: Node) -> bool:
	"""检查是否到达食物位置"""
	if not target_food:
		return false
	
	var distance = beast.global_position.distance_to(target_food.global_position)
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

func _on_seek_timeout() -> void:
	"""觅食超时"""
	state_finished.emit("IdleState", {})

func exit() -> void:
	# 清理计时器
	if seek_timer:
		seek_timer.stop()
		seek_timer.queue_free()
		seek_timer = null
