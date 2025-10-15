extends State
class_name BeastRestState

## 野兽休息状态
## 
## 职责：中立野兽的休息行为，恢复体力
## 
## 转换条件：
## - 休息完成 → IdleState
## - 发现威胁 → FleeState
## - 休息时间结束 → IdleState

var rest_timer: Timer = null
var rest_duration: float = 0.0
var max_rest_time: float = 10.0

func enter(_data: Dictionary = {}) -> void:
	var beast = state_machine.owner
	
	# 停止移动
	beast.velocity = Vector3.ZERO
	
	# 播放休息动画
	if beast.has_node("Model") and beast.get_node("Model").has_method("play_animation"):
		beast.get_node("Model").play_animation("rest")
	elif beast.animation_player:
		beast.animation_player.play("rest")
	
	# 随机休息时间
	rest_duration = randf_range(5.0, max_rest_time)
	
	# 创建休息计时器
	rest_timer = Timer.new()
	rest_timer.wait_time = rest_duration
	rest_timer.timeout.connect(_on_rest_timeout)
	add_child(rest_timer)
	rest_timer.start()
	
	if state_machine.debug_mode:
		print("[BeastRestState] 野兽开始休息 | 休息时间: %.1f秒" % rest_duration)

func update(_delta: float) -> void:
	var beast = state_machine.owner
	
	# 优先级1: 安全检查 - 检测威胁
	if _has_nearby_threats(beast):
		state_finished.emit("FleeState", {})
		return
	
	# 优先级2: 恢复体力
	_restore_stamina(beast, _delta)

func _restore_stamina(beast: Node, delta: float) -> void:
	"""恢复体力"""
	if beast.has_method("restore_stamina"):
		# 使用角色的体力恢复方法
		beast.restore_stamina(delta * 0.1)  # 每秒恢复10%体力
	else:
		# 默认体力恢复逻辑
		if beast.has_method("get_stamina_level"):
			var current_stamina = beast.get_stamina_level()
			if current_stamina < 1.0:
				# 这里可以添加体力恢复逻辑
				pass

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

func _on_rest_timeout() -> void:
	"""休息时间结束"""
	state_finished.emit("IdleState", {})

func exit() -> void:
	# 清理计时器
	if rest_timer:
		rest_timer.stop()
		rest_timer.queue_free()
		rest_timer = null
