extends Node
class_name AutoAssigner

# 自动分配器 - 智能分配苦工和工程师的工作任务
# 参考 BUILDING_SYSTEM.md

const WorkerConstants = preload("res://scripts/characters/WorkerConstants.gd")
# Note: GoblinWorker and GoblinEngineer not preloaded to avoid circular dependencies

# 🔧 修复：Building 是全局类，直接使用
# Building.BuildingStatus 枚举可以直接访问

# 任务优先级枚举
enum TaskPriority {
	CRITICAL = 10, # 关键任务（紧急修理）
	HIGH = 7, # 高优先级（正常建造、修理）
	NORMAL = 4, # 普通优先级（升级、装填）
	LOW = 1 # 低优先级（维护任务）
}

# 分配策略枚举
enum AssignmentStrategy {
	BALANCED, # 平衡策略
	NEAREST_FIRST, # 最近优先
	EFFICIENCY, # 效率优先
	RANDOM # 随机分配
}

# 任务类型枚举
enum TaskType {
	MINING, # 挖掘任务
	CONSTRUCTION, # 建造任务
	REPAIR, # 修理任务
	RELOAD, # 装填任务
	GOLD_STORAGE # 金币存储任务
}


# 工作任务数据结构
class WorkTask:
	var task_id: int
	var task_type: TaskType
	var priority: TaskPriority
	var target_position: Vector3
	var target_object: Object # 目标对象（建筑、金矿等）
	var required_gold: int
	var created_time: float
	var assigned_worker: Object = null
	var is_completed: bool = false

	func _init(id: int, type: TaskType, prio: TaskPriority, pos: Vector3, obj: Object, gold: int):
		task_id = id
		task_type = type
		priority = prio
		target_position = pos
		target_object = obj
		required_gold = gold
		created_time = Time.get_ticks_msec()
		is_completed = false

	func get_priority_score() -> float:
		"""获取优先级分数"""
		var time_factor = 1.0 - (Time.get_ticks_msec() - created_time) / 100.0
		return priority * time_factor


# 分配器配置
var config = {
	"assignment_cooldown": 0.1, # 分配冷却时间0.1秒
	"task_scan_interval": 0.5, # 任务扫描间隔0.5秒
	"max_tasks_per_worker": 1, # 每个工人最大任务数
	"assignment_strategy": AssignmentStrategy.BALANCED,
	"enable_worker_assigner": true,
	"enable_engineer_assigner": true,
	"log_scan_interval": 10.0 # 日志输出间隔10秒（减少日志频率）
}

# 任务存储
var pending_tasks: Array[WorkTask] = []
var completed_tasks: Array[WorkTask] = []
var task_counter: int = 0

# 管理器引用（通过 GameServices 访问）
var gold_mine_manager = null
var building_manager = null
var character_manager = null

# 计时器
var last_assignment_time: float = 0.0
var last_scan_time: float = 0.0
var last_log_time: float = 0.0 # 上次输出日志的时间


func _ready():
	"""初始化自动分配器"""
	LogManager.info("AutoAssigner - 初始化开始")
	_initialize_assigner()
	call_deferred("_setup_manager_references")
	LogManager.info("AutoAssigner - 初始化完成")


func _initialize_assigner():
	"""初始化分配器"""
	# 设置初始配置
	last_assignment_time = 0.0
	last_scan_time = 0.0

func _setup_manager_references():
	"""使用 GameServices 设置管理器引用"""
	gold_mine_manager = GameServices.gold_mine_manager
	building_manager = GameServices.building_manager
	character_manager = GameServices.character_manager
	
	# 检查管理器引用是否获取成功


func _process(_delta: float):
	"""每帧更新"""
	# 🔧 修复：检查并重新获取管理器引用（如果为空）
	if not building_manager or not gold_mine_manager or not character_manager:
		_setup_manager_references()
		return # 本帧跳过，等待下一帧
	
	# 使用毫秒时间戳
	var current_time = Time.get_ticks_msec()

	# 🔧 修复：将秒转换为毫秒
	var scan_interval_ms = config.task_scan_interval * 1000.0
	var assignment_cooldown_ms = config.assignment_cooldown * 1000.0

	# 定期扫描任务
	if current_time - last_scan_time >= scan_interval_ms:
		_scan_for_tasks()
		last_scan_time = current_time

	# 定期分配任务
	if current_time - last_assignment_time >= assignment_cooldown_ms:
		_assign_tasks()
		last_assignment_time = current_time

	# 清理已完成的任务
	_cleanup_completed_tasks()


func _scan_for_tasks():
	"""扫描并创建新任务"""
	# 扫描挖掘任务
	if config.enable_worker_assigner:
		_scan_mining_tasks()

	# 扫描建造任务
	if config.enable_engineer_assigner:
		var tasks_before = pending_tasks.size()
		_scan_construction_tasks()
		_scan_repair_tasks()
		_scan_reload_tasks()
		_scan_gold_storage_tasks()
		
		# 任务扫描完成


func _scan_mining_tasks():
	"""扫描挖掘任务"""
	if not gold_mine_manager:
		return

	# 获取所有活跃的金矿
	var active_mines = []
	for mine in gold_mine_manager.gold_mines:
		if mine.status == GoldMineManager.MineStatus.ACTIVE and mine.can_accept_miner():
			active_mines.append(mine)

	# 为每个可达的金矿创建挖掘任务
	for mine in active_mines:
		# 检查金矿是否可达（使用GoldMineManager的缓存）
		if not gold_mine_manager.is_mine_reachable(mine):
			continue
		
		if not _has_task_for_object(mine, TaskType.MINING):
			var task = WorkTask.new(
				task_counter, TaskType.MINING, TaskPriority.NORMAL, mine.position, mine, 0 # 挖掘任务不需要金币
			)
			pending_tasks.append(task)
			task_counter += 1


func _scan_construction_tasks():
	"""扫描建造任务
	
	📋 [BUILDING_SYSTEM.md] 扫描需要建造的建筑
	"""
	if not building_manager:
		LogManager.warning("📋 [AutoAssigner] building_manager 为空，无法扫描")
		return

	# 🔍 调试：输出建筑列表
	var total_buildings = building_manager.buildings.size()
	var construction_needed = 0
	
	# 获取需要建造的建筑
	for building in building_manager.buildings:
		# 🔧 修复：空值检查
		if not building or not is_instance_valid(building):
			continue
		
		# 🔍 调试：输出每个建筑的状态
		var status_str = ""
		# 🔧 修复：直接比较枚举值（整数）
		match building.status:
			0: # PLANNING
				status_str = "PLANNING"
			1: # UNDER_CONSTRUCTION
				status_str = "UNDER_CONSTRUCTION"
			2: # COMPLETED
				status_str = "COMPLETED"
			3: # DAMAGED
				status_str = "DAMAGED"
			4: # DESTROYED
				status_str = "DESTROYED"
			_:
				status_str = "UNKNOWN"
		
		var needs_construction = building.has_method("needs_construction") and building.needs_construction()
		
		if needs_construction:
			construction_needed += 1
			
		# 🔧 优化：移除频繁的建筑详细日志（只在调试时需要）
		# 如需调试，可以临时启用这行：
		# LogManager.debug("📋 建筑扫描: %s | 状态: %s" % [building.building_name, status_str])
		
		# 🔧 修复：使用 Building.BuildingStatus 而非 BuildingManager.BuildingStatus
		if needs_construction:
			if not _has_task_for_object(building, TaskType.CONSTRUCTION):
				# 🔧 修复：使用 building.engineer_cost 而非 building.config.engineer_cost
				var task = WorkTask.new(
					task_counter,
					TaskType.CONSTRUCTION,
					TaskPriority.HIGH,
					building.global_position, # 🔧 修复：使用 global_position
					building,
					building.engineer_cost # 🔧 修复：直接访问 engineer_cost
				)
				pending_tasks.append(task)
				task_counter += 1
				
				# 建造任务已创建
	
	# 🔧 优化：只在间隔时间后输出汇总日志（减少日志频率）
	var current_time_ms = Time.get_ticks_msec()
	var log_interval_ms = config.log_scan_interval * 1000.0
	if current_time_ms - last_log_time >= log_interval_ms:
		LogManager.info("📋 [AutoAssigner] 建筑扫描汇总 | 总数: %d | 需要建造: %d | 间隔: %.1fs" % [
			total_buildings, construction_needed, (current_time_ms - last_log_time) / 1000.0
		])
		last_log_time = current_time_ms


func _scan_repair_tasks():
	"""扫描修理任务"""
	if not building_manager:
		return

	# 获取需要修理的建筑
	for building in building_manager.buildings:
		# 🔧 修复：空值检查
		if not building or not is_instance_valid(building):
			continue
		
		if building.has_method("needs_repair") and building.needs_repair():
			if not _has_task_for_object(building, TaskType.REPAIR):
				var priority = (
					TaskPriority.CRITICAL
					if building.health < building.max_health * 0.3
					else TaskPriority.HIGH
				)
				
				# 🔧 计算修理成本
				var repair_cost = 0
				if building.has_method("get_repair_cost"):
					repair_cost = building.get_repair_cost()
				else:
					var health_missing = building.max_health - building.health
					repair_cost = int(health_missing * building.cost_gold * 0.001)
				
				var task = WorkTask.new(
					task_counter,
					TaskType.REPAIR,
					priority,
					building.global_position, # 🔧 修复
					building,
					repair_cost
				)
				pending_tasks.append(task)
				task_counter += 1


func _scan_reload_tasks():
	"""扫描装填任务"""
	if not building_manager:
		return

	# 获取需要装填的箭塔
	for building in building_manager.buildings:
		# 🔧 修复：空值检查
		if not building or not is_instance_valid(building):
			continue
		
		if building.has_method("needs_ammo") and building.needs_ammo():
			if not _has_task_for_object(building, TaskType.RELOAD):
				var ammo_needed = 60
				if building.has_method("get_ammo_needed"):
					ammo_needed = building.get_ammo_needed()
				
				var task = WorkTask.new(
					task_counter,
					TaskType.RELOAD,
					TaskPriority.NORMAL,
					building.global_position, # 🔧 修复
					building,
					ammo_needed
				)
				pending_tasks.append(task)
				task_counter += 1


func _scan_gold_storage_tasks():
	"""扫描金币存储任务
	
	📋 [BUILDING_SYSTEM.md] 工程师可以为建筑存储金币
	"""
	if not building_manager:
		return

	# 🔧 暂时禁用金币存储任务（优先级LOW，且会干扰建造任务）
	# 以后需要时再启用
	return
	
	# 获取需要金币存储的建筑
	for building in building_manager.buildings:
		# 🔧 修复：空值检查
		if not building or not is_instance_valid(building):
			continue
		
		# 检查建筑是否有金币存储容量（地牢之心和金库）
		var has_storage = "gold_storage_capacity" in building and building.gold_storage_capacity > 0
		if has_storage:
			# 这里可以添加存储需求检查逻辑
			if not _has_task_for_object(building, TaskType.GOLD_STORAGE):
				var task = WorkTask.new(
					task_counter,
					TaskType.GOLD_STORAGE,
					TaskPriority.LOW,
					building.global_position, # 🔧 修复
					building,
					0 # 存储任务不需要金币
				)
				pending_tasks.append(task)
				task_counter += 1


func _task_type_to_string(task_type: TaskType) -> String:
	"""任务类型转字符串"""
	match task_type:
		TaskType.MINING:
			return "挖掘"
		TaskType.CONSTRUCTION:
			return "建造"
		TaskType.REPAIR:
			return "修理"
		TaskType.RELOAD:
			return "装填"
		TaskType.GOLD_STORAGE:
			return "存储"
		_:
			return "未知"


func _has_task_for_object(target_object: Object, task_type: TaskType) -> bool:
	"""检查是否已有针对特定对象的任务"""
	for task in pending_tasks:
		if (
			task.target_object == target_object
			and task.task_type == task_type
			and not task.is_completed
		):
			return true
	return false


func _assign_tasks():
	"""分配任务给工人"""
	# 按优先级排序任务
	_sort_tasks_by_priority()

	# 分配苦工任务
	if config.enable_worker_assigner:
		_assign_worker_tasks()

	# 分配工程师任务
	if config.enable_engineer_assigner:
		_assign_engineer_tasks()


func _sort_tasks_by_priority():
	"""按优先级排序任务"""
	pending_tasks.sort_custom(func(a, b): return a.get_priority_score() > b.get_priority_score())


func _assign_worker_tasks():
	"""分配苦工任务"""
	if not character_manager:
		return

	# 获取所有空闲的哥布林苦工（使用 GameGroups API）
	var available_workers = GameGroups.get_nodes(GameGroups.GOBLIN_WORKERS)
	var idle_workers = []

	for worker in available_workers:
		# 使用 can_accept_assignment() 检查是否可以接受新任务（包括状态和冷却检查）
		if worker.has_method("can_accept_assignment") and worker.can_accept_assignment():
			idle_workers.append(worker)

	# 为每个空闲苦工分配挖掘任务
	for worker in idle_workers:
		var assigned = false
		for task in pending_tasks:
			if task.task_type == TaskType.MINING and task.assigned_worker == null:
				_assign_task_to_worker(task, worker)
				assigned = true
				break

		if not assigned:
			# 没有挖掘任务，让苦工游荡
			if worker.has_method("_change_state"):
				worker._change_state(WorkerConstants.WorkerStatus.WANDERING)


func _assign_engineer_tasks():
	"""分配工程师任务
	
	📋 [BUILDING_SYSTEM.md] 为空闲工程师分配建造/修理/装填任务
	"""
	if not character_manager:
		return

	# 获取所有空闲的地精工程师（使用 GameGroups API）
	var available_engineers = GameGroups.get_nodes(GameGroups.GOBLIN_ENGINEERS)
	var idle_engineers = []

	for engineer in available_engineers:
		# 使用 can_accept_assignment() 检查是否可以接受新任务（包括状态和冷却检查）
		if engineer.has_method("can_accept_assignment") and engineer.can_accept_assignment():
			idle_engineers.append(engineer)

	# 检查是否有空闲工程师和待分配任务

	# 为每个空闲工程师分配任务
	for engineer in idle_engineers:
		var assigned = false
		for task in pending_tasks:
			if task.task_type != TaskType.MINING and task.assigned_worker == null:
				_assign_task_to_engineer(task, engineer)
				assigned = true
				break

		# ⚠️ 不再手动切换到游荡，让 IdleState 的超时机制处理


func _assign_task_to_worker(task: WorkTask, worker: Object):
	"""将任务分配给苦工"""
	task.assigned_worker = worker

	# 设置苦工的目标金矿
	if worker.has_method("set_target_mine") and task.target_object:
		worker.set_target_mine(task.target_object)

	# 改变苦工状态
	if worker.has_method("_change_state"):
		worker._change_state(WorkerConstants.WorkerStatus.MOVING_TO_MINE)

		LogManager.info("分配挖掘任务给苦工: " + str(task.target_position))


func _assign_task_to_engineer(task: WorkTask, engineer: Object):
	"""将任务分配给工程师
	
	📋 [BUILDING_SYSTEM.md] 新的分配逻辑：
	- 设置 engineer.current_building
	- IdleState 会自动检测并处理
	"""
	# 🔧 修复：空值检查
	if not engineer or not is_instance_valid(engineer):
		LogManager.warning("📋 [AutoAssigner] 工程师无效，无法分配任务")
		return
	
	if not task.target_object or not is_instance_valid(task.target_object):
		LogManager.warning("📋 [AutoAssigner] 任务目标建筑无效，无法分配")
		return
	
	task.assigned_worker = engineer

	# 🔧 [文档逻辑] 设置工程师的目标建筑（使用 current_building）
	engineer.current_building = task.target_object
	
	# 任务已分配给工程师
	
	# ⚠️ 不再使用 _change_state()，让 IdleState 自动处理状态转换


func _cleanup_completed_tasks():
	"""清理已完成的任务"""
	var active_tasks: Array[WorkTask] = []

	for task in pending_tasks:
		if task.is_completed:
			completed_tasks.append(task)
		else:
			# 检查任务是否超时或无效
			if _is_task_invalid(task):
				task.is_completed = true
				completed_tasks.append(task)
			else:
				active_tasks.append(task)

	pending_tasks = active_tasks


func _is_task_invalid(task: WorkTask) -> bool:
	"""检查任务是否无效"""
	# 🔧 修复：检查目标对象是否存在且有效
	if not task.target_object or not is_instance_valid(task.target_object):
		return true

	# 检查目标对象是否仍然有效
	if task.target_object.has_method("is_valid"):
		return not task.target_object.is_valid()

	return false


func get_task_statistics() -> Dictionary:
	"""获取任务统计信息"""
	var stats = {
		"pending_tasks": pending_tasks.size(),
		"completed_tasks": completed_tasks.size(),
		"mining_tasks": 0,
		"construction_tasks": 0,
		"repair_tasks": 0,
		"reload_tasks": 0,
		"storage_tasks": 0
	}

	for task in pending_tasks:
		match task.task_type:
			TaskType.MINING:
				stats.mining_tasks += 1
			TaskType.CONSTRUCTION:
				stats.construction_tasks += 1
			TaskType.REPAIR:
				stats.repair_tasks += 1
			TaskType.RELOAD:
				stats.reload_tasks += 1
			TaskType.GOLD_STORAGE:
				stats.storage_tasks += 1

	return stats


func set_assignment_strategy(strategy: AssignmentStrategy):
	"""设置分配策略"""
	config.assignment_strategy = strategy
	LogManager.info("分配策略已设置为: " + str(strategy))


func enable_worker_assigner(enabled: bool):
	"""启用 / 禁用苦工分配器"""
	config.enable_worker_assigner = enabled
	LogManager.info("苦工分配器已" + ("启用" if enabled else "禁用"))


func enable_engineer_assigner(enabled: bool):
	"""启用 / 禁用工程师分配器"""
	config.enable_engineer_assigner = enabled
	LogManager.info("工程师分配器已" + ("启用" if enabled else "禁用"))


# 调试功能
func debug_print_tasks():
	"""调试：打印所有任务信息"""
	LogManager.info("=== 自动分配器调试信息 ===")
	LogManager.info("待处理任务: " + str(pending_tasks.size()))
	LogManager.info("已完成任务: " + str(completed_tasks.size()))
	
	for i in range(pending_tasks.size()):
		var task = pending_tasks[i]
		LogManager.info("任务 " + str(i) + ": 类型=" + str(task.task_type) + " 优先级=" + str(task.priority) + " 位置=" + str(task.target_position) + " 分配工人=" + str(task.assigned_worker != null))


func get_debug_info() -> String:
	"""获取调试信息"""
	var stats = get_task_statistics()
	return (
		"待处理任务: "
		+ str(stats.pending_tasks)
		+" 已完成: "
		+ str(stats.completed_tasks)
		+" 挖掘: "
		+ str(stats.mining_tasks)
		+" 建造: "
		+ str(stats.construction_tasks)
		+" 修理: "
		+ str(stats.repair_tasks)
	)
