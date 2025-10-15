extends State
class_name BeastIdleState

## 野兽空闲状态
## 
## 职责：中立野兽的基础行为决策中心
## 
## 优先级：
## 1. 安全检查（威胁检测）
## 2. 觅食行为（寻找食物）
## 3. 休息行为（恢复体力）
## 4. 游荡行为（探索环境）

var idle_timer: Timer = null
var idle_duration: float = 0.0
var max_idle_time: float = 5.0

func enter(_data: Dictionary = {}) -> void:
	var beast = state_machine.owner
	
	# 播放待机动画
	if beast.has_node("Model") and beast.get_node("Model").has_method("play_animation"):
		beast.get_node("Model").play_animation("idle")
	elif beast.animation_player:
		beast.animation_player.play("idle")
	
	# 停止移动
	beast.velocity = Vector3.ZERO
	
	# 随机空闲时间
	idle_duration = randf_range(2.0, max_idle_time)
	
	# 创建空闲计时器
	idle_timer = Timer.new()
	idle_timer.wait_time = idle_duration
	idle_timer.timeout.connect(_on_idle_timeout)
	add_child(idle_timer)
	idle_timer.start()
	
	if state_machine.debug_mode:
		print("[BeastIdleState] 野兽进入空闲状态 | 阵营: %s" % Enums.faction_to_string(beast.faction))

func update(_delta: float) -> void:
	var beast = state_machine.owner
	
	# 优先级1: 安全检查 - 检测威胁
	if _has_nearby_threats(beast):
		state_finished.emit("FleeState", {})
		return
	
	# 优先级2: 觅食行为 - 寻找食物
	if _should_seek_food(beast):
		var food_source = _find_nearest_food(beast)
		if food_source:
			state_finished.emit("SeekFoodState", {"target_food": food_source})
			return
	
	# 优先级3: 休息行为 - 恢复体力
	if _should_rest(beast):
		state_finished.emit("RestState", {})
		return

func _on_idle_timeout() -> void:
	"""空闲时间结束"""
	var beast = state_machine.owner
	
	# 随机选择下一个行为
	var behaviors = ["WanderState", "SeekFoodState", "RestState"]
	var next_behavior = behaviors[randi() % behaviors.size()]
	
	state_finished.emit(next_behavior, {})

func _has_nearby_threats(beast: Node) -> bool:
	"""检查附近是否有威胁"""
	# 检查附近是否有敌对单位
	var enemies = beast.get_tree().get_nodes_in_group("characters")
	for enemy in enemies:
		if enemy != beast and is_instance_valid(enemy):
			# 检查是否为敌对关系
			if beast.is_enemy_of(enemy):
				var distance = beast.global_position.distance_to(enemy.global_position)
				if distance < beast.detection_range:
					return true
	return false

func _should_seek_food(beast: Node) -> bool:
	"""判断是否应该寻找食物"""
	# 基于饥饿度或随机概率
	if beast.has_method("get_hunger_level"):
		return beast.get_hunger_level() > 0.5
	else:
		# 随机觅食概率
		return randf() < 0.3

func _find_nearest_food(beast: Node) -> Node:
	"""寻找最近的食物源"""
	# 这里可以扩展为寻找实际的资源点
	# 暂时返回null，让野兽游荡
	return null

func _should_rest(beast: Node) -> bool:
	"""判断是否应该休息"""
	# 基于体力或随机概率
	if beast.has_method("get_stamina_level"):
		return beast.get_stamina_level() < 0.3
	else:
		# 随机休息概率
		return randf() < 0.2

func exit() -> void:
	# 清理计时器
	if idle_timer:
		idle_timer.stop()
		idle_timer.queue_free()
		idle_timer = null
