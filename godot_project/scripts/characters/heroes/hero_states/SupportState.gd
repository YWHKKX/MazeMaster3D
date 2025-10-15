extends State
class_name HeroSupportState

## 英雄支援状态
## 
## 职责：友方英雄的支援行为，帮助受伤的友军
## 
## 转换条件：
## - 友军恢复健康 → IdleState
## - 发现敌人 → CombatState
## - 友军死亡 → IdleState
## - 支援超时 → IdleState

var target_ally: Node = null
var support_timer: Timer = null
var support_duration: float = 0.0
var max_support_time: float = 15.0
var heal_interval: float = 2.0

func enter(data: Dictionary = {}) -> void:
	var hero = state_machine.owner
	
	# 获取目标友军
	if data.has("target_ally"):
		target_ally = data["target_ally"]
	else:
		state_finished.emit("IdleState", {})
		return
	
	# 播放支援动画
	if hero.has_node("Model") and hero.get_node("Model").has_method("play_animation"):
		hero.get_node("Model").play_animation("support")
	elif hero.animation_player:
		hero.animation_player.play("support")
	
	# 随机支援时间
	support_duration = randf_range(5.0, max_support_time)
	
	# 创建支援计时器
	support_timer = Timer.new()
	support_timer.wait_time = heal_interval
	support_timer.timeout.connect(_on_heal_tick)
	add_child(support_timer)
	support_timer.start()
	
	if state_machine.debug_mode:
		print("[HeroSupportState] 英雄开始支援友军 | 目标: %s" % str(target_ally))

func update(_delta: float) -> void:
	var hero = state_machine.owner
	
	# 优先级1: 战斗准备 - 检测敌人
	if _has_nearby_enemies(hero):
		state_finished.emit("CombatState", {})
		return
	
	# 优先级2: 检查目标友军是否仍然有效
	if not target_ally or not is_instance_valid(target_ally):
		state_finished.emit("IdleState", {})
		return
	
	# 优先级3: 移动到友军位置
	_move_to_ally(hero, _delta)
	
	# 检查是否到达友军位置
	if _reached_ally(hero):
		# 停止移动，开始支援
		hero.velocity = Vector3.ZERO
	else:
		# 继续移动到友军位置
		pass

func _move_to_ally(hero: Node, delta: float) -> void:
	"""移动到友军位置"""
	if not hero.has_method("move_towards") or not target_ally:
		return
	
	hero.move_towards(target_ally.global_position, delta)

func _reached_ally(hero: Node) -> bool:
	"""检查是否到达友军位置"""
	if not target_ally:
		return false
	
	var distance = hero.global_position.distance_to(target_ally.global_position)
	return distance < 3.0

func _on_heal_tick() -> void:
	"""治疗定时器触发"""
	var hero = state_machine.owner
	
	# 检查目标友军是否仍然有效
	if not target_ally or not is_instance_valid(target_ally):
		state_finished.emit("IdleState", {})
		return
	
	# 检查是否在支援范围内
	if not _reached_ally(hero):
		return
	
	# 执行治疗
	_perform_heal(hero, target_ally)
	
	# 检查友军是否恢复健康
	if _is_ally_healthy(target_ally):
		state_finished.emit("IdleState", {})
		return

func _perform_heal(hero: Node, ally: Node) -> void:
	"""执行治疗"""
	if hero.has_method("heal"):
		hero.heal(ally)
		if state_machine.debug_mode:
			print("[HeroSupportState] 英雄治疗友军: %s" % str(ally))
	else:
		# 默认治疗逻辑
		if ally.has_method("restore_health"):
			var heal_amount = 20  # 默认治疗量
			ally.restore_health(heal_amount)

func _is_ally_healthy(ally: Node) -> bool:
	"""检查友军是否恢复健康"""
	if not ally or not is_instance_valid(ally):
		return true
	
	if ally.has_method("get_health_percentage"):
		return ally.get_health_percentage() >= 0.9  # 90%以上算健康
	return false

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

func exit() -> void:
	# 清理计时器
	if support_timer:
		support_timer.stop()
		support_timer.queue_free()
		support_timer = null
