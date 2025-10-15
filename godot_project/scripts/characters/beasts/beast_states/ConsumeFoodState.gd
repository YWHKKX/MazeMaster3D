extends State
class_name BeastConsumeFoodState

## 野兽进食状态
## 
## 职责：中立野兽的进食行为
## 
## 转换条件：
## - 进食完成 → IdleState
## - 发现威胁 → FleeState
## - 食物被消耗完 → IdleState

var target_food: Node = null
var consume_timer: Timer = null
var consume_duration: float = 0.0
var consume_interval: float = 2.0

func enter(data: Dictionary = {}) -> void:
	var beast = state_machine.owner
	
	# 获取目标食物
	if data.has("target_food"):
		target_food = data["target_food"]
	else:
		state_finished.emit("IdleState", {})
		return
	
	# 停止移动
	beast.velocity = Vector3.ZERO
	
	# 播放进食动画
	if beast.has_node("Model") and beast.get_node("Model").has_method("play_animation"):
		beast.get_node("Model").play_animation("eat")
	elif beast.animation_player:
		beast.animation_player.play("eat")
	
	# 随机进食时间
	consume_duration = randf_range(3.0, 8.0)
	
	# 创建进食计时器
	consume_timer = Timer.new()
	consume_timer.wait_time = consume_interval
	consume_timer.timeout.connect(_on_consume_tick)
	add_child(consume_timer)
	consume_timer.start()
	
	if state_machine.debug_mode:
		print("[BeastConsumeFoodState] 野兽开始进食 | 食物: %s" % str(target_food))

func update(_delta: float) -> void:
	var beast = state_machine.owner
	
	# 优先级1: 安全检查 - 检测威胁
	if _has_nearby_threats(beast):
		state_finished.emit("FleeState", {})
		return
	
	# 优先级2: 检查食物是否仍然有效
	if not target_food or not is_instance_valid(target_food):
		state_finished.emit("IdleState", {})
		return

func _on_consume_tick() -> void:
	"""进食定时器触发"""
	var beast = state_machine.owner
	
	# 检查食物是否仍然有效
	if not target_food or not is_instance_valid(target_food):
		state_finished.emit("IdleState", {})
		return
	
	# 消耗食物
	if target_food.has_method("consume"):
		var consumed = target_food.consume(1)
		if consumed > 0:
			# 恢复野兽的饥饿度
			if beast.has_method("restore_hunger"):
				beast.restore_hunger(consumed * 0.1)
			
			if state_machine.debug_mode:
				print("[BeastConsumeFoodState] 野兽消耗食物: %d" % consumed)
		else:
			# 食物被消耗完
			state_finished.emit("IdleState", {})
			return
	else:
		# 食物没有消耗方法，直接完成进食
		state_finished.emit("IdleState", {})
		return

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

func exit() -> void:
	# 清理计时器
	if consume_timer:
		consume_timer.stop()
		consume_timer.queue_free()
		consume_timer = null
