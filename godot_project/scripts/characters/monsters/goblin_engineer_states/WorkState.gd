extends State
class_name GoblinEngineerWorkState

## GoblinEngineer 工作状态
## 
## 职责：消耗金币推进建筑进度（建造或装填）
## 
## 转换条件：
## - 工作完成且有剩余金币 → ReturnGoldState
## - 工作完成且金币用完 → IdleState
## - 金币用完但工作未完成 → FetchGoldState
## - 建筑被摧毁 → IdleState
## - 发现敌人 → EscapeState

var target_building: Node = null
var work_timer: Timer = null
var work_interval: float = 1.0 # 🔧 [文档] 每1秒投入一次金币

func enter(data: Dictionary = {}) -> void:
	var engineer = state_machine.owner
	
	# 获取目标建筑
	if data.has("target_building"):
		target_building = data["target_building"]
	else:
		state_finished.emit("IdleState", {})
		return
	
	# 停止移动
	engineer.velocity = Vector3.ZERO
	
	# 播放工作动画
	if engineer.has_node("Model") and engineer.get_node("Model").has_method("play_animation"):
		engineer.get_node("Model").play_animation("work")
	
	# 创建工作计时器
	work_timer = Timer.new()
	work_timer.wait_time = work_interval
	work_timer.timeout.connect(_on_work_tick)
	add_child(work_timer)
	work_timer.start()
	
	# 🔧 使用 current_building 而非 target_building
	engineer.current_building = target_building
	
	# 开始工作

func update(_delta: float) -> void:
	var engineer = state_machine.owner
	
	# 检查建筑是否有效
	if not is_instance_valid(target_building) or target_building.is_destroyed():
		# 建筑失效，返回空闲
		state_finished.emit("IdleState", {})
		return
	
	# 检查是否有敌人
	if _has_nearby_enemies(engineer):
		state_finished.emit("EscapeState", {})
		return

func _on_work_tick() -> void:
	"""工作定时器触发"""
	var engineer = state_machine.owner
	
	# 检查建筑是否还需要金币
	if not _building_needs_work():
		# 🔧 [文档逻辑] 工作完成，清理建筑引用
		engineer.current_building = null
		
		# 根据剩余金币决定下一步
		if engineer.carried_gold > 0:
			# 工作完成，归还剩余金币
			state_finished.emit("ReturnGoldState", {})
		else:
			# 工作完成，返回空闲
			state_finished.emit("IdleState", {})
		return
	
	# 检查工程师是否有金币
	if engineer.carried_gold == 0:
		# 金币用完，继续取金
		state_finished.emit("FetchGoldState", {"target_building": target_building})
		return
	
	# 🔧 [文档] 投入金币到建筑：每秒4金币
	var gold_to_spend = mini(4, engineer.carried_gold) # 每次最多投入4金币
	var gold_spent = _invest_gold_to_building(gold_to_spend)
	engineer.carried_gold -= gold_spent
	
	# 🔧 [状态栏系统] 更新金币显示
	if engineer.has_method("_update_status_bar_gold"):
		engineer._update_status_bar_gold()
	
	# 投入金币到建筑

func _building_needs_work() -> bool:
	"""检查建筑是否还需要工作"""
	if not is_instance_valid(target_building):
		return false
	
	# 检查是否需要建造
	if target_building.has_method("needs_construction"):
		if target_building.needs_construction():
			return true
	
	# 检查是否需要装填
	if target_building.has_method("needs_ammo"):
		if target_building.needs_ammo():
			return true
	
	return false

func _invest_gold_to_building(amount: int) -> int:
	"""投入金币到建筑，返回实际消耗的金币数"""
	if not is_instance_valid(target_building):
		return 0
	
	# 建造进度
	if target_building.has_method("add_construction_progress"):
		return target_building.add_construction_progress(amount)
	
	# 装填弹药
	if target_building.has_method("add_ammo"):
		return target_building.add_ammo(amount)
	
	return 0

func exit() -> void:
	# 清理计时器
	if work_timer:
		work_timer.stop()
		work_timer.queue_free()
		work_timer = null

func _has_nearby_enemies(engineer: Node) -> bool:
	"""检查是否有敌人在附近"""
	# 使用 MonsterBase 的 find_nearest_enemy 方法
	var enemy = engineer.find_nearest_enemy()
	# 🔧 修复：检查敌人是否有效
	if enemy and is_instance_valid(enemy) and engineer.global_position.distance_to(enemy.global_position) < 15.0:
		return true
	
	return false
