extends State
class_name GoblinEngineerIdleState

## GoblinEngineer 空闲状态
## 
## 📋 [BUILDING_SYSTEM.md] 符合文档的状态机逻辑
## 
## 优先级（按文档流程）：
## 1. 检查携带金币 → 有金币 → RETURNING_TO_BASE (返回基地)
## 2. 无金币 → 等待自动分配器分配任务
## 3. 空闲超过1秒 → WANDERING (游荡)
## 
## ⚠️ 关键：不再自己扫描建筑，等待AutoAssigner分配任务

var idle_timer: float = 0.0
const IDLE_TIMEOUT: float = 1.0 # 空闲超时时间

func enter(_data: Dictionary = {}) -> void:
	var engineer = state_machine.owner_node
	
	# 重置空闲计时器
	idle_timer = 0.0
	
	# 停止移动
	engineer.velocity = Vector3.ZERO
	
	# 播放待机动画
	if engineer.has_node("Model") and engineer.get_node("Model").has_method("play_animation"):
		engineer.get_node("Model").play_animation("idle")
	
	LogManager.info("[IdleState] 进入空闲状态 | 金币: %d | 建筑: %s" % [
		engineer.carried_gold,
		engineer.current_building.name if engineer.current_building else "无"
	])

func update(delta: float) -> void:
	var engineer = state_machine.owner_node
	
	# 🔍 调试：仅在进入IdleState和即将超时时输出（减少日志）
	if idle_timer == 0.0:
		LogManager.info("🔍 [IdleState] 进入 | 金币: %d | 建筑: %s" % [
			engineer.carried_gold,
			engineer.current_building.building_name if engineer.current_building else "无"
		])
	
	# 🔧 [文档逻辑] 优先级1: 检查携带金币
	if engineer.carried_gold > 0:
		LogManager.info("[IdleState] 携带金币 %d，返回基地存储" % engineer.carried_gold)
		state_finished.emit("ReturnGoldState", {})
		return
	
	# 🔧 [文档逻辑] 优先级2: 等待自动分配器（AutoAssigner会设置current_building）
	# AutoAssigner会调用 engineer._change_state() 直接切换状态
	# 这里只检查 current_building 是否被设置
	if engineer.current_building:
		LogManager.info("[IdleState] ✅ 自动分配器已分配建筑: %s" % engineer.current_building.building_name)
		
		# 检查金币需求
		var gold_needed = _calculate_gold_needed(engineer, engineer.current_building)
		LogManager.info("[IdleState] 金币需求: %d | 当前携带: %d" % [gold_needed, engineer.carried_gold])
		
		if gold_needed > 0:
			# 金币不足，获取资源
			LogManager.info("[IdleState] → FetchGoldState（金币不足）")
			state_finished.emit("FetchGoldState", {"target_building": engineer.current_building})
		else:
			# 金币充足（或不需要金币），前往工地
			LogManager.info("[IdleState] → MoveToTargetState（金币充足）")
			state_finished.emit("MoveToTargetState", {"target_building": engineer.current_building})
		return
	
	# 🔧 [文档逻辑] 优先级3: 空闲超时，转为游荡
	idle_timer += delta
	if idle_timer >= IDLE_TIMEOUT:
		LogManager.info("[IdleState] 空闲超时 %.1fs，转为游荡" % idle_timer)
		state_finished.emit("WanderState", {})
		return

func _calculate_gold_needed(_engineer: Node, building: Node) -> int:
	"""计算建筑需要的金币数量
	
	📋 [BUILDING_SYSTEM.md] 金币需求计算：
	- 修复建筑: (max_health - current_health) × (建造成本 × 0.001)
	- 装填弹药: max_ammunition - current_ammunition
	- 建造建筑: building.get_construction_cost_remaining()
	"""
	if not building:
		return 0
	
	# 1. 检查是否需要建造
	if building.has_method("needs_construction") and building.needs_construction():
		return building.get_construction_cost_remaining()
	
	# 2. 检查是否需要修复
	if building.has_method("needs_repair") and building.needs_repair():
		var health_missing = building.max_health - building.health
		var repair_cost = int(health_missing * building.cost_gold * 0.001)
		return max(1, repair_cost) # 至少需要1金币
	
	# 3. 检查是否需要装填弹药
	if building.has_method("needs_ammo") and building.needs_ammo():
		if building.has_method("get_ammo_needed"):
			return building.get_ammo_needed()
		else:
			return 10 # 默认装填10发
	
	return 0
