class_name ResourceCollectionManager
extends Node

## 🎯 统一资源采集管理器
## 整合所有资源采集逻辑，提供统一的采集者系统

# 导入依赖
const ResourceManager = preload("res://scripts/managers/resource/ResourceManager.gd")
const WorkerConstants = preload("res://scripts/characters/WorkerConstants.gd")

# 采集者类型枚举
enum CollectorType {
	WORKER, # 苦工 - 基础资源采集
	ENGINEER, # 工程师 - 高级资源采集
	SPECIALIST, # 专家 - 特殊资源采集
	AUTOMATED # 自动化 - 建筑自动采集
}

# 采集任务类型
enum CollectionTaskType {
	GATHER, # 采集任务
	MINE, # 挖掘任务
	HARVEST, # 收获任务
	EXTRACT # 提取任务
}

# 采集任务数据结构
class CollectionTask:
	var task_id: int
	var task_type: CollectionTaskType
	var resource_type: ResourceManager.ResourceType
	var target_position: Vector2
	var target_object: Object = null
	var required_collector_type: CollectorType
	var priority: int = 1
	var estimated_duration: float = 1.0
	var created_time: float
	var assigned_collector: Object = null
	var is_completed: bool = false
	var collection_amount: int = 0
	var collection_efficiency: float = 1.0
	
	func _init(id: int, type: CollectionTaskType, resource: ResourceManager.ResourceType, pos: Vector2, collector_type: CollectorType, amount: int = 0):
		task_id = id
		task_type = type
		resource_type = resource
		target_position = pos
		required_collector_type = collector_type
		collection_amount = amount
		created_time = Time.get_ticks_msec()
	
	func get_priority_score() -> float:
		"""获取优先级分数"""
		var time_factor = 1.0 - (Time.get_ticks_msec() - created_time) / 10000.0
		return priority * time_factor * collection_efficiency

# 采集者配置
class CollectorConfig:
	var collector_type: CollectorType
	var collection_speed: float = 1.0
	var carry_capacity: int = 50
	var collection_range: float = 5.0
	var efficiency_multiplier: float = 1.0
	var specializations: Array[ResourceManager.ResourceType] = []
	
	func _init(type: CollectorType, speed: float = 1.0, capacity: int = 50, range: float = 5.0):
		collector_type = type
		collection_speed = speed
		carry_capacity = capacity
		collection_range = range

# 配置
var config = {
	"task_scan_interval": 0.5, # 任务扫描间隔
	"assignment_cooldown": 0.1, # 分配冷却时间
	"max_concurrent_tasks": 50, # 最大并发任务数
	"auto_collection_enabled": true, # 自动采集开关
	"efficiency_optimization": true # 效率优化开关
}

# 数据存储
var pending_tasks: Array[CollectionTask] = []
var completed_tasks: Array[CollectionTask] = []
var active_collectors: Array[Object] = []
var collector_configs: Dictionary = {}
var task_counter: int = 0

# 管理器引用
var resource_manager = null
var character_manager = null
var auto_assigner = null

# 时间控制
var last_scan_time: float = 0.0
var last_assignment_time: float = 0.0

# 信号定义
signal task_created(task: CollectionTask)
signal task_assigned(task: CollectionTask, collector: Object)
signal task_completed(task: CollectionTask, collected_amount: int)
signal collection_started(resource_type: ResourceManager.ResourceType, position: Vector2, collector: Object)
signal collection_finished(resource_type: ResourceManager.ResourceType, position: Vector2, collected_amount: int)

func _ready():
	"""初始化统一资源采集管理器"""
	LogManager.info("ResourceCollectionManager - 初始化开始")
	
	_initialize_collector_configs()
	_connect_signals()
	
	# 延迟获取管理器引用
	call_deferred("_setup_manager_references")
	
	LogManager.info("ResourceCollectionManager - 初始化完成")

func _initialize_collector_configs():
	"""初始化采集者配置"""
	# 苦工配置
	var worker_config = CollectorConfig.new(CollectorType.WORKER, 1.0, 60, 5.0)
	worker_config.specializations = [
		ResourceManager.ResourceType.GOLD,
		ResourceManager.ResourceType.STONE,
		ResourceManager.ResourceType.WOOD
	] as Array[ResourceManager.ResourceType]
	collector_configs[CollectorType.WORKER] = worker_config
	
	# 工程师配置
	var engineer_config = CollectorConfig.new(CollectorType.ENGINEER, 0.8, 40, 3.0)
	engineer_config.specializations = [
		ResourceManager.ResourceType.IRON,
		ResourceManager.ResourceType.GEM,
		ResourceManager.ResourceType.MAGIC_CRYSTAL
	] as Array[ResourceManager.ResourceType]
	collector_configs[CollectorType.ENGINEER] = engineer_config
	
	# 专家配置
	var specialist_config = CollectorConfig.new(CollectorType.SPECIALIST, 0.6, 30, 2.0)
	specialist_config.specializations = [
		ResourceManager.ResourceType.MAGIC_HERB,
		ResourceManager.ResourceType.DEMON_CORE,
		ResourceManager.ResourceType.MANA
	] as Array[ResourceManager.ResourceType]
	collector_configs[CollectorType.SPECIALIST] = specialist_config

func _connect_signals():
	"""连接信号"""
	# 等待一帧确保其他系统已初始化
	await get_tree().process_frame
	
	if GameServices.has_method("get_resource_manager"):
		resource_manager = GameServices.get_resource_manager()
		if resource_manager:
			resource_manager.resource_spawned.connect(_on_resource_spawned)
			resource_manager.resource_depleted.connect(_on_resource_depleted)
			resource_manager.resource_respawned.connect(_on_resource_respawned)

func _setup_manager_references():
	"""设置管理器引用"""
	resource_manager = GameServices.get_resources()
	character_manager = GameServices.get_characters()
	auto_assigner = GameServices.auto_assigner

func _process(delta: float):
	"""每帧更新"""
	if not resource_manager or not character_manager:
		return
	
	var current_time = Time.get_ticks_msec()
	
	# 定期扫描任务
	if current_time - last_scan_time >= config.task_scan_interval * 1000:
		_scan_for_collection_tasks()
		last_scan_time = current_time
	
	# 定期分配任务
	if current_time - last_assignment_time >= config.assignment_cooldown * 1000:
		_assign_collection_tasks()
		last_assignment_time = current_time
	
	# 清理已完成的任务
	_cleanup_completed_tasks()

# ===== 任务扫描 =====

func _scan_for_collection_tasks():
	"""扫描采集任务"""
	if not config.auto_collection_enabled:
		return
	
	# 扫描所有资源生成点
	var resource_spawns = resource_manager.get_all_resource_spawns()
	
	for spawn in resource_spawns:
		if spawn.get("is_depleted", false):
			continue
		
		# 检查是否已有针对此资源的任务
		if _has_task_for_resource(spawn.resource_type, spawn.position):
			continue
		
		# 创建采集任务
		var task_type = _get_collection_task_type(spawn.resource_type)
		var collector_type = _get_required_collector_type(spawn.resource_type)
		
		var task = CollectionTask.new(
			task_counter,
			task_type,
			spawn.resource_type,
			spawn.position,
			collector_type,
			spawn.get("amount", 0)
		)
		
		# 设置任务优先级
		task.priority = _calculate_task_priority(spawn)
		task.collection_efficiency = _calculate_collection_efficiency(spawn)
		
		pending_tasks.append(task)
		task_counter += 1
		
		task_created.emit(task)
		
		# 限制任务数量
		if pending_tasks.size() >= config.max_concurrent_tasks:
			break

func _has_task_for_resource(resource_type: ResourceManager.ResourceType, position: Vector2) -> bool:
	"""检查是否已有针对特定资源的任务"""
	for task in pending_tasks:
		if (task.resource_type == resource_type and
			task.target_position.distance_to(position) < 5.0 and
			not task.is_completed):
			return true
	return false

func _get_collection_task_type(resource_type: ResourceManager.ResourceType) -> CollectionTaskType:
	"""根据资源类型获取采集任务类型"""
	match resource_type:
		ResourceManager.ResourceType.GOLD, ResourceManager.ResourceType.IRON:
			return CollectionTaskType.MINE
		ResourceManager.ResourceType.FOOD, ResourceManager.ResourceType.MAGIC_HERB:
			return CollectionTaskType.HARVEST
		ResourceManager.ResourceType.MAGIC_CRYSTAL, ResourceManager.ResourceType.DEMON_CORE:
			return CollectionTaskType.EXTRACT
		_:
			return CollectionTaskType.GATHER

func _get_required_collector_type(resource_type: ResourceManager.ResourceType) -> CollectorType:
	"""根据资源类型获取所需的采集者类型"""
	# 检查各采集者的专业领域
	for collector_type in collector_configs:
		var config_data = collector_configs[collector_type]
		if resource_type in config_data.specializations:
			return collector_type
	
	# 默认使用苦工
	return CollectorType.WORKER

func _calculate_task_priority(spawn: Dictionary) -> int:
	"""计算任务优先级"""
	var priority = 1
	
	# 根据资源类型设置基础优先级
	match spawn.resource_type:
		ResourceManager.ResourceType.GOLD:
			priority = 3
		ResourceManager.ResourceType.FOOD:
			priority = 2
		ResourceManager.ResourceType.MANA:
			priority = 4
		_:
			priority = 1
	
	# 根据资源数量调整优先级
	var amount = spawn.get("amount", 0)
	if amount > 50:
		priority += 1
	elif amount < 10:
		priority -= 1
	
	return max(1, priority)

func _calculate_collection_efficiency(spawn: Dictionary) -> float:
	"""计算采集效率"""
	var efficiency = 1.0
	
	# 根据地形类型调整效率
	var terrain_type = spawn.get("terrain_type", "")
	match terrain_type:
		"flat":
			efficiency += 0.2
		"mountain":
			efficiency -= 0.1
		"water":
			efficiency -= 0.3
	
	# 根据资源数量调整效率
	var amount = spawn.get("amount", 0)
	if amount > 100:
		efficiency += 0.1
	elif amount < 20:
		efficiency -= 0.1
	
	return max(0.1, efficiency)

# ===== 任务分配 =====

func _assign_collection_tasks():
	"""分配采集任务"""
	# 按优先级排序任务
	_sort_tasks_by_priority()
	
	# 获取可用的采集者
	var available_collectors = _get_available_collectors()
	
	# 分配任务
	for task in pending_tasks:
		if task.assigned_collector != null:
			continue
		
		var best_collector = _find_best_collector_for_task(task, available_collectors)
		if best_collector:
			_assign_task_to_collector(task, best_collector)
			available_collectors.erase(best_collector)

func _sort_tasks_by_priority():
	"""按优先级排序任务"""
	pending_tasks.sort_custom(func(a, b): return a.get_priority_score() > b.get_priority_score())

func _get_available_collectors() -> Array:
	"""获取可用的采集者"""
	var collectors = []
	
	# 获取苦工
	var workers = GameGroups.get_nodes(GameGroups.GOBLIN_WORKERS)
	for worker in workers:
		if worker.has_method("can_accept_assignment") and worker.can_accept_assignment():
			collectors.append(worker)
	
	# 获取工程师
	var engineers = GameGroups.get_nodes(GameGroups.GOBLIN_ENGINEERS)
	for engineer in engineers:
		if engineer.has_method("can_accept_assignment") and engineer.can_accept_assignment():
			collectors.append(engineer)
	
	return collectors

func _find_best_collector_for_task(task: CollectionTask, available_collectors: Array) -> Object:
	"""为任务找到最佳采集者"""
	var best_collector = null
	var best_score = -1.0
	
	for collector in available_collectors:
		var score = _calculate_collector_task_score(collector, task)
		if score > best_score:
			best_score = score
			best_collector = collector
	
	return best_collector

func _calculate_collector_task_score(collector: Object, task: CollectionTask) -> float:
	"""计算采集者任务匹配分数"""
	var score = 0.0
	
	# 检查采集者类型匹配
	var collector_type = _get_collector_type(collector)
	if collector_type == task.required_collector_type:
		score += 10.0
	
	# 检查专业匹配
	var config_data = collector_configs.get(collector_type)
	if config_data and task.resource_type in config_data.specializations:
		score += 5.0
	
	# 距离因素
	var distance = collector.global_position.distance_to(Vector3(task.target_position.x, 0, task.target_position.y))
	score += max(0, 10.0 - distance / 10.0)
	
	# 效率因素
	score += task.collection_efficiency * 3.0
	
	return score

func _get_collector_type(collector: Object) -> CollectorType:
	"""获取采集者类型"""
	if collector.is_in_group(GameGroups.GOBLIN_WORKERS):
		return CollectorType.WORKER
	elif collector.is_in_group(GameGroups.GOBLIN_ENGINEERS):
		return CollectorType.ENGINEER
	else:
		return CollectorType.WORKER # 默认

func _assign_task_to_collector(task: CollectionTask, collector: Object):
	"""将任务分配给采集者"""
	task.assigned_collector = collector
	
	# 设置采集者的目标
	if collector.has_method("set_collection_target"):
		collector.set_collection_target(task.target_position, task.resource_type)
	
	task_assigned.emit(task, collector)
	collection_started.emit(task.resource_type, task.target_position, collector)
	
	LogManager.info("ResourceCollectionManager - 任务分配给采集者: %s -> %s" % [task.resource_type, collector.name])

# ===== 任务完成处理 =====

func complete_collection_task(task_id: int, collected_amount: int):
	"""完成任务"""
	for task in pending_tasks:
		if task.task_id == task_id:
			task.is_completed = true
			task.collection_amount = collected_amount
			
			task_completed.emit(task, collected_amount)
			collection_finished.emit(task.resource_type, task.target_position, collected_amount)
			
			LogManager.info("ResourceCollectionManager - 任务完成: %s x%d" % [task.resource_type, collected_amount])
			break

func _cleanup_completed_tasks():
	"""清理已完成的任务"""
	var active_tasks: Array[CollectionTask] = []
	
	for task in pending_tasks:
		if task.is_completed:
			completed_tasks.append(task)
		else:
			active_tasks.append(task)
	
	pending_tasks = active_tasks
	
	# 限制已完成任务的数量
	if completed_tasks.size() > 100:
		completed_tasks = completed_tasks.slice(-50) # 保留最近50个

# ===== 信号处理 =====

func _on_resource_spawned(resource_type: ResourceManager.ResourceType, position: Vector2, amount: int):
	"""资源生成信号处理"""
	LogManager.info("ResourceCollectionManager - 新资源生成: %s 在位置 %s" % [resource_type, position])

func _on_resource_depleted(resource_type: ResourceManager.ResourceType, position: Vector2):
	"""资源枯竭信号处理"""
	# 取消相关的待分配任务
	for task in pending_tasks:
		if (task.resource_type == resource_type and
			task.target_position.distance_to(position) < 5.0 and
			task.assigned_collector == null):
			task.is_completed = true
	
	LogManager.info("ResourceCollectionManager - 资源枯竭: %s 在位置 %s" % [resource_type, position])

func _on_resource_respawned(resource_type: ResourceManager.ResourceType, position: Vector2, amount: int):
	"""资源重生信号处理"""
	LogManager.info("ResourceCollectionManager - 资源重生: %s 在位置 %s" % [resource_type, position])

# ===== 公共接口 =====

func create_manual_collection_task(resource_type: ResourceManager.ResourceType, position: Vector2, collector_type: CollectorType = CollectorType.WORKER) -> CollectionTask:
	"""手动创建采集任务"""
	var task = CollectionTask.new(
		task_counter,
		_get_collection_task_type(resource_type),
		resource_type,
		position,
		collector_type
	)
	
	task.priority = 5 # 手动任务优先级更高
	
	pending_tasks.append(task)
	task_counter += 1
	
	task_created.emit(task)
	return task

func get_task_statistics() -> Dictionary:
	"""获取任务统计信息"""
	var stats = {
		"pending_tasks": pending_tasks.size(),
		"completed_tasks": completed_tasks.size(),
		"active_collectors": active_collectors.size(),
		"tasks_by_type": {},
		"tasks_by_priority": {}
	}
	
	# 按类型统计
	for task in pending_tasks:
		var type_name = _task_type_to_string(task.task_type)
		stats.tasks_by_type[type_name] = stats.tasks_by_type.get(type_name, 0) + 1
		
		var priority_name = str(task.priority)
		stats.tasks_by_priority[priority_name] = stats.tasks_by_priority.get(priority_name, 0) + 1
	
	return stats

func _task_type_to_string(task_type: CollectionTaskType) -> String:
	"""任务类型转字符串"""
	match task_type:
		CollectionTaskType.GATHER:
			return "采集"
		CollectionTaskType.MINE:
			return "挖掘"
		CollectionTaskType.HARVEST:
			return "收获"
		CollectionTaskType.EXTRACT:
			return "提取"
		_:
			return "未知"

func set_config(new_config: Dictionary):
	"""设置配置"""
	config.merge(new_config)

func toggle_auto_collection(enabled: bool):
	"""切换自动采集"""
	config.auto_collection_enabled = enabled
	LogManager.info("ResourceCollectionManager - 自动采集: %s" % ("开启" if enabled else "关闭"))

func get_collector_efficiency(collector_type: CollectorType) -> float:
	"""获取采集者效率"""
	var config_data = collector_configs.get(collector_type)
	return config_data.efficiency_multiplier if config_data else 1.0

func set_collector_efficiency(collector_type: CollectorType, efficiency: float):
	"""设置采集者效率"""
	if collector_type in collector_configs:
		collector_configs[collector_type].efficiency_multiplier = efficiency
