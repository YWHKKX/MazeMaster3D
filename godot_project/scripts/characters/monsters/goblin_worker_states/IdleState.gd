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
	var worker = state_machine.owner
	
	# 播放待机动画
	if worker.has_node("Model") and worker.get_node("Model").has_method("play_animation"):
		worker.get_node("Model").play_animation("idle")
	elif worker.animation_player:
		worker.animation_player.play("idle")
	
	if state_machine.debug_mode:
		print("[IdleState] 进入空闲状态 | 携带金币: %d/%d" % [
			worker.carried_gold, worker.worker_config.carry_capacity
		])

func update(_delta: float) -> void:
	var worker = state_machine.owner
	
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
			# 🔧 调试：为什么找不到金矿
			LogManager.info("❌ [IdleState] 苦工找不到金矿 | gold_mine_manager: %s | 位置: %s" % [
				"存在" if worker.gold_mine_manager else "null",
				str(worker.global_position)
			])
			if worker.gold_mine_manager:
				var reachable = worker.gold_mine_manager.get_reachable_mines_in_radius(worker.global_position, 100.0)
				LogManager.info("  可达金矿数量: %d" % reachable.size())
				if not reachable.is_empty():
					var available_count = 0
					for m in reachable:
						if not m.is_exhausted() and m.can_accept_miner():
							available_count += 1
					LogManager.info("  可接受挖掘的金矿: %d / %d" % [available_count, reachable.size()])
					
					# 详细检查前3个金矿
					for i in range(mini(3, reachable.size())):
						var checked_mine = reachable[i]
						var in_blacklist = worker.failed_mines.has(checked_mine.position)
						var blacklist_info = ""
						if in_blacklist:
							var failed_time = worker.failed_mines[checked_mine.position]
							var elapsed = (Time.get_ticks_msec() - failed_time) / 1000.0
							var remaining = worker.failed_mine_timeout - elapsed
							blacklist_info = "(超时剩余: %.1fs)" % remaining
						LogManager.info("  金矿#%d: 位置=%s, 枯竭=%s, 可接受=%s, 黑名单=%s%s, 矿工数=%d/%d" % [
							i + 1,
							str(checked_mine.position),
							str(checked_mine.is_exhausted()),
							str(checked_mine.can_accept_miner()),
							str(in_blacklist),
							blacklist_info,
							checked_mine.miners.size(),
							checked_mine.get_mining_capacity()
						])
	
	# 优先级4: 无事可做 - 游荡
	state_finished.emit("WanderState", {})

func _has_nearby_enemies(worker: Node) -> bool:
	"""检查是否有敌人在附近"""
	# 使用 MonsterBase 的 find_nearest_enemy 方法
	var enemy = worker.find_nearest_enemy()
	if enemy and worker.global_position.distance_to(enemy.global_position) < 15.0:
		return true
	
	return false
