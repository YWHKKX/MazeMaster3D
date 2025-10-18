extends State
class_name MonsterCombatState

## 怪物战斗状态
## 
## 职责：敌对怪物的战斗行为
## 
## 转换条件：
## - 敌人死亡 → IdleState
## - 敌人逃跑 → ChaseState
## - 自身受伤严重 → RetreatState
## - 战斗胜利 → IdleState

var target_enemy: Node = null
var combat_timer: Timer = null
var attack_interval: float = 1.5
var last_attack_time: float = 0.0

func enter(data: Dictionary = {}) -> void:
	if not state_machine or not state_machine.owner_node:
		LogManager.warning("MonsterCombatState - state_machine 或 owner_node 为空")
		return
	
	var monster = state_machine.owner_node
	
	# 获取目标敌人
	if data.has("target_enemy"):
		target_enemy = data["target_enemy"]
	else:
		target_enemy = _find_nearest_enemy(monster)
	
	if not target_enemy:
		state_finished.emit("IdleState", {})
		return
	
	# 播放战斗动画
	if monster.has_node("Model") and monster.get_node("Model").has_method("play_animation"):
		monster.get_node("Model").play_animation("combat")
	elif monster.animation_player:
		monster.animation_player.play("combat")
	
	# 创建战斗计时器
	combat_timer = Timer.new()
	combat_timer.wait_time = attack_interval
	combat_timer.timeout.connect(_on_attack_tick)
	add_child(combat_timer)
	combat_timer.start()
	

func update(_delta: float) -> void:
	var monster = state_machine.owner_node
	
	# 检查目标敌人是否仍然有效
	if not target_enemy or not is_instance_valid(target_enemy):
		target_enemy = _find_nearest_enemy(monster)
		if not target_enemy:
			state_finished.emit("IdleState", {})
			return
	
	# 检查自身是否受伤严重
	if _is_seriously_injured(monster):
		state_finished.emit("RetreatState", {})
		return
	
	# 移动到攻击范围
	_move_to_attack_range(monster, _delta)
	
	# 检查是否在攻击范围内
	if _in_attack_range(monster):
		# 停止移动，准备攻击
		monster.velocity = Vector3.ZERO
	else:
		# 继续移动到攻击范围
		pass

func _find_nearest_enemy(monster: Node) -> Node:
	"""寻找最近的敌人"""
	var enemies = monster.get_tree().get_nodes_in_group("characters")
	var nearest_enemy = null
	var min_distance = INF
	
	for enemy in enemies:
		if enemy != monster and is_instance_valid(enemy):
			if monster.is_enemy_of(enemy):
				var distance = monster.global_position.distance_to(enemy.global_position)
				if distance < monster.detection_range and distance < min_distance:
					min_distance = distance
					nearest_enemy = enemy
	
	return nearest_enemy

func _is_seriously_injured(monster: Node) -> bool:
	"""检查是否受伤严重"""
	if monster.has_method("get_health_percentage"):
		return monster.get_health_percentage() < 0.25 # 25%以下算严重受伤
	return false

func _move_to_attack_range(monster: Node, delta: float) -> void:
	"""移动到攻击范围"""
	if not monster.has_method("move_towards") or not target_enemy:
		return
	
	# 计算攻击位置
	var attack_position = _calculate_attack_position(monster, target_enemy)
	monster.move_towards(attack_position, delta)

func _calculate_attack_position(monster: Node, enemy: Node) -> Vector3:
	"""计算攻击位置"""
	var enemy_pos = enemy.global_position
	var monster_pos = monster.global_position
	var direction = (enemy_pos - monster_pos).normalized()
	var attack_range = monster.attack_range if monster.has_method("get_attack_range") else 2.5
	
	return enemy_pos - direction * attack_range

func _in_attack_range(monster: Node) -> bool:
	"""检查是否在攻击范围内"""
	if not target_enemy:
		return false
	
	var distance = monster.global_position.distance_to(target_enemy.global_position)
	var attack_range = monster.attack_range if monster.has_method("get_attack_range") else 2.5
	return distance <= attack_range

func _on_attack_tick() -> void:
	"""攻击定时器触发"""
	var monster = state_machine.owner_node
	
	# 检查目标是否仍然有效
	if not target_enemy or not is_instance_valid(target_enemy):
		state_finished.emit("IdleState", {})
		return
	
	# 检查是否在攻击范围内
	if not _in_attack_range(monster):
		return
	
	# 执行攻击
	_perform_attack(monster, target_enemy)
	
	# 检查敌人是否死亡
	if _is_enemy_dead(target_enemy):
		state_finished.emit("IdleState", {})
		return

func _perform_attack(monster: Node, enemy: Node) -> void:
	"""执行攻击"""
	if monster.has_method("attack"):
		monster.attack(enemy)
	else:
		# 默认攻击逻辑
		if enemy.has_method("take_damage"):
			var damage = monster.attack_power if monster.has_method("get_attack_power") else 15
			enemy.take_damage(damage)

func _is_enemy_dead(enemy: Node) -> bool:
	"""检查敌人是否死亡"""
	if not enemy or not is_instance_valid(enemy):
		return true
	
	if enemy.has_method("is_dead"):
		return enemy.is_dead()
	
	if enemy.has_method("get_health_percentage"):
		return enemy.get_health_percentage() <= 0.0
	
	return false

func exit() -> void:
	# 清理计时器
	if combat_timer:
		combat_timer.stop()
		combat_timer.queue_free()
		combat_timer = null
