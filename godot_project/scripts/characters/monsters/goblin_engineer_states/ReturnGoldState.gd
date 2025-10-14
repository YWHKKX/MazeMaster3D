extends State
class_name GoblinEngineerReturnGoldState

## GoblinEngineer 归还金币状态
## 
## 职责：将剩余金币送回基地/金库
## 
## 转换条件：
## - 到达金库 → IdleState
## - 发现敌人 → EscapeState

var target_treasury: Node = null

# 🔧 [统一移动API] 使用 process_interaction_movement() 进行两阶段移动
# 不再需要手动管理 current_path 和 current_waypoint

func enter(_data: Dictionary = {}) -> void:
	var engineer = state_machine.owner
	
	# 查找最近的存储建筑（金库优先，地牢之心备选）
	target_treasury = BuildingFinder.get_nearest_storage_building(engineer)
	
	# 🔧 修复：检查金库是否有效
	if not target_treasury or not is_instance_valid(target_treasury):
		# 没有金库，直接清空金币（不应该发生）
		if state_machine.debug_mode:
			print("[ReturnGoldState] 找不到金库，金币丢失: %d" % engineer.carried_gold)
		engineer.carried_gold = 0
		state_finished.emit("IdleState", {})
		return
	
	# 🔧 [统一移动API] 重置导航控制器（新状态开始）
	MovementHelper.reset_navigation(engineer)
	
	# 播放行走动画
	if engineer.has_node("Model") and engineer.get_node("Model").has_method("play_animation"):
		engineer.get_node("Model").play_animation("move")
	
	if state_machine.debug_mode:
		print("[ReturnGoldState] 归还金币 | 数量: %d | 目标: %s" % [
			engineer.carried_gold, str(target_treasury.global_position)
		])

func physics_update(_delta: float) -> void:
	var engineer = state_machine.owner
	
	# 检查金库是否有效
	if not is_instance_valid(target_treasury):
		if state_machine.debug_mode:
			print("[ReturnGoldState] 金库失效，金币丢失")
		engineer.carried_gold = 0
		state_finished.emit("IdleState", {})
		return
	
	# 检查是否有敌人
	if _has_nearby_enemies(engineer):
		state_finished.emit("EscapeState", {})
		return
	
	# 🔧 [统一移动API] 使用两阶段交互移动逻辑
	var move_result = MovementHelper.process_interaction_movement(
		engineer,
		target_treasury,
		_delta,
		"ReturnGoldState" if state_machine.debug_mode else ""
	)
	
	# 根据移动结果处理状态转换
	match move_result:
		MovementHelper.InteractionMoveResult.REACHED_INTERACTION:
			# 已到达交互范围，存入金币
			if state_machine.debug_mode:
				print("[ReturnGoldState] Engineer进入金库交互范围，存入金币")
			_deposit_gold(engineer)
			state_finished.emit("IdleState", {})
		MovementHelper.InteractionMoveResult.FAILED_NO_PATH, MovementHelper.InteractionMoveResult.FAILED_STUCK:
			# 寻路失败或卡住，金币丢失，返回空闲
			if state_machine.debug_mode:
				print("❌ [ReturnGoldState] 无法到达金库，金币丢失: %d" % engineer.carried_gold)
			engineer.carried_gold = 0
			state_finished.emit("IdleState", {})
		# MOVING_TO_ADJACENT 和 MOVING_TO_INTERACTION 继续移动

func _deposit_gold(engineer: Node) -> void:
	"""将金币存入金库"""
	if engineer.resource_manager:
		engineer.resource_manager.add_gold(engineer.carried_gold)
		if state_machine.debug_mode:
			print("[ReturnGoldState] 归还 %d 金币到金库" % engineer.carried_gold)
	
	engineer.carried_gold = 0
	
	# 🔧 [状态栏系统] 更新金币显示
	if engineer.has_method("_update_status_bar_gold"):
		engineer._update_status_bar_gold()

func exit() -> void:
	var engineer = state_machine.owner
	engineer.velocity = Vector3.ZERO


func _has_nearby_enemies(engineer: Node) -> bool:
	"""检查是否有敌人在附近"""
	# 使用 MonsterBase 的 find_nearest_enemy 方法
	var enemy = engineer.find_nearest_enemy()
	# 🔧 修复：检查敌人是否有效
	if enemy and is_instance_valid(enemy) and engineer.global_position.distance_to(enemy.global_position) < 15.0:
		return true
	
	return false
