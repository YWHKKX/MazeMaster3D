extends State
class_name MonsterIdleState

## 怪物空闲状态
## 
## 职责：敌对怪物的基础行为决策中心
## 
## 优先级：
## 1. 战斗准备（检测敌人）
## 2. 巡逻行为（寻找目标）
## 3. 守卫行为（保护区域）
## 4. 待机状态（等待目标）

var idle_timer: Timer = null
var idle_duration: float = 0.0
var max_idle_time: float = 4.0

func enter(_data: Dictionary = {}) -> void:
	if not state_machine or not state_machine.owner_node:
		LogManager.warning("MonsterIdleState - state_machine 或 owner_node 为空")
		return
	
	var monster = state_machine.owner_node
	
	# 播放待机动画
	if monster.has_node("Model") and monster.get_node("Model").has_method("play_animation"):
		monster.get_node("Model").play_animation("idle")
	elif monster.animation_player:
		monster.animation_player.play("idle")
	
	# 停止移动
	monster.velocity = Vector3.ZERO
	
	# 随机空闲时间
	idle_duration = randf_range(2.0, max_idle_time)
	
	# 创建空闲计时器
	idle_timer = Timer.new()
	idle_timer.wait_time = idle_duration
	idle_timer.timeout.connect(_on_idle_timeout)
	add_child(idle_timer)
	idle_timer.start()
	
func update(_delta: float) -> void:
	if not state_machine or not state_machine.owner_node:
		return
	
	var monster = state_machine.owner_node
	
	# 优先级1: 战斗准备 - 检测敌人
	if _has_nearby_enemies(monster):
		state_finished.emit("CombatState", {})
		return
	
	# 优先级2: 巡逻行为 - 寻找目标
	if _should_patrol(monster):
		state_finished.emit("PatrolState", {})
		return
	
	# 优先级3: 守卫行为 - 保护区域
	if _should_guard(monster):
		state_finished.emit("GuardState", {})
		return
	
	# 优先级4: 待机状态 - 等待目标
	# 继续待机

func _has_nearby_enemies(monster: Node) -> bool:
	"""检查附近是否有敌人"""
	var enemies = monster.get_tree().get_nodes_in_group("characters")
	for enemy in enemies:
		if enemy != monster and is_instance_valid(enemy):
			if monster.is_enemy_of(enemy):
				var distance = monster.global_position.distance_to(enemy.global_position)
				if distance < monster.detection_range:
					return true
	return false

func _should_patrol(monster: Node) -> bool:
	"""判断是否应该巡逻"""
	# 基于随机概率或特定条件
	return randf() < 0.4

func _should_guard(monster: Node) -> bool:
	"""判断是否应该守卫"""
	# 基于随机概率或特定条件
	return randf() < 0.3

func _on_idle_timeout() -> void:
	"""空闲时间结束"""
	if not state_machine or not state_machine.owner_node:
		return
	
	var monster = state_machine.owner_node
	
	# 随机选择下一个行为
	var behaviors = ["PatrolState", "GuardState", "IdleState"]
	var next_behavior = behaviors[randi() % behaviors.size()]
	
	state_finished.emit(next_behavior, {})

func exit() -> void:
	# 清理计时器
	if idle_timer:
		idle_timer.stop()
		idle_timer.queue_free()
		idle_timer = null
