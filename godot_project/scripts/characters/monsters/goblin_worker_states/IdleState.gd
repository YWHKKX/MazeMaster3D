extends State
class_name GoblinWorkerIdleState

## GoblinWorker 空闲状态
## 
## 职责：决策中心，评估环境并分配合适的任务
## 
## 优先级：
## 1. 安全检查（敌人）
## 2. 背包管理（满载时返回基地）
## 3. 寻找金矿（主要任务）
## 4. 游荡（无事可做）

func enter(_data: Dictionary = {}) -> void:
	if not state_machine or not state_machine.owner_node:
		LogManager.warning("GoblinWorkerIdleState - state_machine 或 owner_node 为空")
		return
	
	var worker = state_machine.owner_node
	
	# 播放待机动画
	if worker.has_node("Model") and worker.get_node("Model").has_method("play_animation"):
		worker.get_node("Model").play_animation("idle")
	elif worker.animation_player:
		worker.animation_player.play("idle")
	

func update(_delta: float) -> void:
	var worker = state_machine.owner_node
	
	# 优先级1: 安全检查 - 附近是否有敌人
	if _has_nearby_enemies(worker):
		state_finished.emit("EscapeState", {})
		return
	
	# 优先级2: 金币管理 - 只要有金币就返回基地存储
	# 🔧 [逻辑修复] 不需要等到背包满，只要有金币就应该返回
	if worker.carried_gold > 0:
		var base = BuildingFinder.get_nearest_storage_building(worker)
		if base:
			state_finished.emit("ReturnToBaseState", {"target_base": base})
			return
		else:
			# 找不到基地，无法存储金币
			pass
	
	# 优先级3: 寻找金矿 - 如果背包为空
	if worker.carried_gold == 0:
		var mine = BuildingFinder.find_nearest_accessible_gold_mine(worker)
		if mine:
			LogManager.info("✅ [IdleState] 苦工找到金矿 at %s，距离: %.1fm" % [
				str(mine.position),
				worker.global_position.distance_to(mine.position)
			])
			state_finished.emit("MoveToMineState", {"target_mine": mine})
			return
		else:
			# 精简日志，避免刷屏
			pass
	
	# 优先级4: 无事可做 - 游荡
	state_finished.emit("WanderState", {})

func _has_nearby_enemies(worker: Node) -> bool:
	"""检查是否有敌人在附近"""
	# 使用 MonsterBase 的 find_nearest_enemy 方法
	var enemy = worker.find_nearest_enemy()
	if enemy and worker.global_position.distance_to(enemy.global_position) < 15.0:
		return true
	
	return false
