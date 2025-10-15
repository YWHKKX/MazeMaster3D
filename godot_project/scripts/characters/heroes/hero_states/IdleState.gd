extends State
class_name HeroIdleState

## 英雄空闲状态
## 
## 职责：友方英雄的基础行为决策中心
## 
## 优先级：
## 1. 战斗准备（检测敌人）
## 2. 巡逻任务（保护区域）
## 3. 支援任务（帮助友军）
## 4. 待命状态（等待指令）

var idle_timer: Timer = null
var idle_duration: float = 0.0
var max_idle_time: float = 3.0

func enter(_data: Dictionary = {}) -> void:
	var hero = state_machine.owner
	
	# 播放待机动画
	if hero.has_node("Model") and hero.get_node("Model").has_method("play_animation"):
		hero.get_node("Model").play_animation("idle")
	elif hero.animation_player:
		hero.animation_player.play("idle")
	
	# 停止移动
	hero.velocity = Vector3.ZERO
	
	# 随机空闲时间
	idle_duration = randf_range(1.0, max_idle_time)
	
	# 创建空闲计时器
	idle_timer = Timer.new()
	idle_timer.wait_time = idle_duration
	idle_timer.timeout.connect(_on_idle_timeout)
	add_child(idle_timer)
	idle_timer.start()
	
	if state_machine.debug_mode:
		print("[HeroIdleState] 英雄进入待命状态 | 阵营: %s" % Enums.faction_to_string(hero.faction))

func update(_delta: float) -> void:
	var hero = state_machine.owner
	
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
	
	# 优先级3: 巡逻任务 - 保护区域
	if _should_patrol(hero):
		state_finished.emit("PatrolState", {})
		return
	
	# 优先级4: 待命状态 - 等待指令
	# 继续待命

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
				if distance < hero.detection_range * 1.5:  # 支援范围更大
					if ally.has_method("get_health_percentage"):
						if ally.get_health_percentage() < 0.8:  # 80%以下算受伤
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

func _should_patrol(hero: Node) -> bool:
	"""判断是否应该巡逻"""
	# 基于随机概率或特定条件
	return randf() < 0.3

func _on_idle_timeout() -> void:
	"""空闲时间结束"""
	var hero = state_machine.owner
	
	# 随机选择下一个行为
	var behaviors = ["PatrolState", "IdleState"]
	var next_behavior = behaviors[randi() % behaviors.size()]
	
	state_finished.emit(next_behavior, {})

func exit() -> void:
	# 清理计时器
	if idle_timer:
		idle_timer.stop()
		idle_timer.queue_free()
		idle_timer = null
