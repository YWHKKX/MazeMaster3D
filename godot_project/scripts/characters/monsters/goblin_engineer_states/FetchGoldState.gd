extends State
class_name GoblinEngineerFetchGoldState

## GoblinEngineer 取金币状态
## 
## 职责：从基地/金库获取金币
## 
## 转换条件：
## - 取到金币 → MoveToTargetState
## - 金库空了 → IdleState
## - 发现敌人 → EscapeState

var target_treasury: Node = null
var target_building: Node = null # 记住原本要去的建筑

# 🔧 [统一移动API] 使用 process_interaction_movement() 进行两阶段移动
# 不再需要手动管理 current_path 和 current_waypoint

func enter(data: Dictionary = {}) -> void:
	var engineer = state_machine.owner
	
	# 记住目标建筑
	if data.has("target_building"):
		target_building = data["target_building"]
	
	
	# 查找最近的金币来源（有金币的金库优先，地牢之心备选）
	target_treasury = BuildingFinder.get_nearest_gold_source(engineer)
	
	# 🔧 修复：检查金库是否有效
	if not target_treasury or not is_instance_valid(target_treasury):
		if state_machine.debug_mode:
			print("[FetchGoldState] 找不到金库，返回空闲")
		state_finished.emit("IdleState", {})
		return
	
	# 🔧 [统一交互移动API] 重置交互移动状态（新状态开始）
	MovementHelper.reset_interaction_movement(engineer)
	
	# 播放行走动画
	if engineer.has_node("Model") and engineer.get_node("Model").has_method("play_animation"):
		engineer.get_node("Model").play_animation("move")
	
	if state_machine.debug_mode:
		print("[FetchGoldState] 前往金库取金")

func physics_update(_delta: float) -> void:
	var engineer = state_machine.owner
	
	# 检查金库是否有效
	if not is_instance_valid(target_treasury):
		if state_machine.debug_mode:
			print("[FetchGoldState] 金库失效，返回空闲")
		state_finished.emit("IdleState", {})
		return
	
	# 检查是否有敌人
	if _has_nearby_enemies(engineer):
		state_finished.emit("EscapeState", {})
		return
	
	# 🔧 [方案C] 使用Area3D主动查询检测是否可交互
	if engineer.check_in_building_area3d(target_treasury):
		# 🔧 [新建造系统] 持续取金币直到取满或金库空
		var remaining_capacity = engineer.engineer_config.gold_capacity - engineer.carried_gold
		
		if remaining_capacity > 0:
			# 还有空间，继续取金币
			_withdraw_gold(engineer)
			
			# 取完后检查是否已满
			if engineer.carried_gold >= engineer.engineer_config.gold_capacity:
				# 已取满，前往目标建筑
				if target_building:
					state_finished.emit("MoveToTargetState", {"target_building": target_building})
				else:
					state_finished.emit("IdleState", {})
				return
			# 还没取满，继续留在此状态（下一帧继续取）
		else:
			# 已经满了，前往目标建筑
			if target_building:
				if state_machine.debug_mode:
					print("[FetchGoldState] ✅ 金币已满 %d/%d，前往建筑" % [
						engineer.carried_gold, engineer.engineer_config.gold_capacity
					])
				state_finished.emit("MoveToTargetState", {"target_building": target_building})
			else:
				state_finished.emit("IdleState", {})
			return
	
	# 🔧 [统一交互移动API] 使用两阶段移动逻辑
	var move_result = MovementHelper.process_interaction_movement(
		engineer,
		target_treasury,
		_delta,
		"FetchGoldState" if state_machine.debug_mode else ""
	)
	
	# 处理移动失败
	match move_result:
		MovementHelper.InteractionMoveResult.FAILED_NO_PATH, MovementHelper.InteractionMoveResult.FAILED_STUCK:
			state_finished.emit("IdleState", {})
			return
		# REACHED_INTERACTION, MOVING_TO_ADJACENT, MOVING_TO_INTERACTION 继续处理

func _withdraw_gold(engineer: Node) -> void:
	"""从金库取金币
	
	🔧 [新建造系统] 直接从目标金库/地牢之心扣除金币
	"""
	# 🔧 修复：检查 target_treasury 是否有效
	if not target_treasury or not is_instance_valid(target_treasury):
		if state_machine.debug_mode:
			print("[FetchGoldState] 目标金库无效，无法取金")
		return
	
	# 🔧 直接从目标建筑扣除金币
	if target_treasury.has_method("withdraw_gold"):
		# 🔧 一次性取满，而不是每次只取10
		var remaining_capacity = engineer.engineer_config.gold_capacity - engineer.carried_gold
		var withdrawn = target_treasury.withdraw_gold(remaining_capacity)
		
		if withdrawn > 0:
			engineer.carried_gold += withdrawn
			
			# 🔧 [状态栏系统] 更新金币显示
			if engineer.has_method("_update_status_bar_gold"):
				engineer._update_status_bar_gold()
			
			# 从金库取得金币

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
