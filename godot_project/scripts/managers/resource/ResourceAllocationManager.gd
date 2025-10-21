class_name ResourceAllocationManager
extends Node

## 🎯 资源分配算法管理器
## 智能优化资源分配，最大化效率和收益

# 导入依赖 - 使用动态加载避免循环依赖
# const ResourceManager = preload("res://scripts/managers/resource/ResourceManager.gd")
# const ResourcePredictionManager = preload("res://scripts/managers/resource/ResourcePredictionManager.gd")
# const ResourceTradeManager = preload("res://scripts/managers/resource/ResourceTradeManager.gd")

# 分配策略枚举
enum AllocationStrategy {
	BALANCED, # 平衡分配
	EFFICIENCY, # 效率优先
	PROFIT, # 利润优先
	URGENCY, # 紧急优先
	SUSTAINABILITY # 可持续优先
}

# 分配目标枚举
enum AllocationTarget {
	CONSTRUCTION, # 建筑建设
	UNIT_PRODUCTION, # 单位生产
	RESEARCH, # 研究开发
	MAINTENANCE, # 维护保养
	TRADE, # 贸易交易
	EMERGENCY # 紧急需求
}

# 分配请求
class AllocationRequest:
	var request_id: int
	var target: AllocationTarget
	var resource_type: int
	var amount_requested: int
	var amount_allocated: int = 0
	var priority: int # 1-10, 10最高
	var deadline: float # 截止时间
	var efficiency_factor: float = 1.0 # 效率因子
	var profit_factor: float = 1.0 # 利润因子
	var urgency_factor: float = 1.0 # 紧急因子
	var requester: Object = null # 请求者
	var created_time: float
	var status: String = "pending" # pending, allocated, completed, cancelled
	
	func _init(id: int, tgt: AllocationTarget, res_type: int, amt: int, prio: int, dl: float = 0.0):
		request_id = id
		target = tgt
		resource_type = res_type
		amount_requested = amt
		priority = prio
		deadline = dl if dl > 0 else Time.get_unix_time_from_system() + 3600.0 # 默认1小时后
		created_time = Time.get_unix_time_from_system()
	
	func get_priority_score() -> float:
		"""计算优先级分数"""
		var time_factor = 1.0 - (Time.get_unix_time_from_system() - created_time) / 3600.0 # 时间衰减
		var deadline_factor = 1.0 if deadline > Time.get_unix_time_from_system() else 0.5
		
		return (priority * 0.4 + efficiency_factor * 0.3 + profit_factor * 0.2 + urgency_factor * 0.1) * time_factor * deadline_factor

# 分配结果
class AllocationResult:
	var request_id: int
	var allocated_amount: int
	var allocation_efficiency: float
	var estimated_profit: int
	var completion_time: float
	var success: bool
	var reason: String
	
	func _init(id: int, amount: int, efficiency: float, profit: int, time: float, succ: bool, reason_str: String = ""):
		request_id = id
		allocated_amount = amount
		allocation_efficiency = efficiency
		estimated_profit = profit
		completion_time = time
		success = succ
		reason = reason_str

# 配置
var config = {
	"allocation_interval": 5.0, # 分配检查间隔
	"min_allocation_amount": 1, # 最小分配量
	"max_allocation_amount": 10000, # 最大分配量
	"efficiency_weight": 0.3, # 效率权重
	"profit_weight": 0.3, # 利润权重
	"urgency_weight": 0.2, # 紧急权重
	"balance_weight": 0.2, # 平衡权重
	"prediction_weight": 0.4, # 预测权重
	"reserve_ratio": 0.1, # 储备比例
	"reallocation_threshold": 0.8 # 重新分配阈值
}

# 数据存储
var allocation_requests: Array[AllocationRequest] = []
var allocation_results: Array[AllocationResult] = []
var allocation_history: Array[AllocationResult] = []
var _resource_reserves: Dictionary = {} # 资源储备
var allocation_counter: int = 0

# 管理器引用
var resource_manager = null
var prediction_manager = null
var trade_manager = null
var allocation_timer: Timer = null

# 信号定义
signal allocation_requested(request: AllocationRequest)
signal allocation_completed(result: AllocationResult)
signal allocation_failed(request: AllocationRequest, reason: String)
signal reallocation_triggered(resource_type: ResourceManager.ResourceType, old_allocation: int, new_allocation: int)

func _ready():
	"""初始化资源分配管理器"""
	LogManager.info("ResourceAllocationManager - 初始化开始")
	
	_initialize_resource_reserves()
	_setup_allocation_timer()
	_connect_signals()
	
	# 延迟获取管理器引用
	call_deferred("_setup_manager_references")
	
	LogManager.info("ResourceAllocationManager - 初始化完成")

func _initialize_resource_reserves():
	"""初始化资源储备"""
	for resource_type in ResourceManager.ResourceType.values():
		_resource_reserves[resource_type] = 0

func _setup_allocation_timer():
	"""设置分配定时器"""
	allocation_timer = Timer.new()
	allocation_timer.wait_time = config.allocation_interval
	allocation_timer.timeout.connect(_process_allocations)
	allocation_timer.autostart = true
	add_child(allocation_timer)

func _connect_signals():
	"""连接信号"""
	# 等待一帧确保其他系统已初始化
	await get_tree().process_frame
	
	if GameServices.has_method("get_resource_manager"):
		resource_manager = GameServices.get_resource_manager()

func _setup_manager_references():
	"""设置管理器引用"""
	if GameServices.has_method("get_resource_manager"):
		resource_manager = GameServices.get_resource_manager()
	
	if GameServices.has_method("get_resource_prediction_manager"):
		prediction_manager = GameServices.get_resource_prediction_manager()
	
	if GameServices.has_method("get_resource_trade_manager"):
		trade_manager = GameServices.get_resource_trade_manager()

# ===== 分配请求管理 =====

func request_allocation(target: AllocationTarget, resource_type: ResourceManager.ResourceType, amount: int, priority: int, deadline: float = 0.0, requester: Object = null) -> AllocationRequest:
	"""请求资源分配"""
	# 验证请求
	if amount < config.min_allocation_amount or amount > config.max_allocation_amount:
		LogManager.warning("ResourceAllocationManager - 分配请求数量超出范围: %d" % amount)
		return null
	
	# 创建分配请求
	var request = AllocationRequest.new(
		allocation_counter,
		target,
		resource_type,
		amount,
		priority,
		deadline
	)
	
	request.requester = requester
	
	# 计算效率因子
	request.efficiency_factor = _calculate_efficiency_factor(target, resource_type, amount)
	
	# 计算利润因子
	request.profit_factor = _calculate_profit_factor(target, resource_type, amount)
	
	# 计算紧急因子
	request.urgency_factor = _calculate_urgency_factor(deadline, priority)
	
	allocation_requests.append(request)
	allocation_counter += 1
	
	allocation_requested.emit(request)
	
	LogManager.info("ResourceAllocationManager - 分配请求创建: %s %d %s (优先级: %d)" % [target, amount, resource_type, priority])
	
	return request

func _calculate_efficiency_factor(target: AllocationTarget, resource_type: ResourceManager.ResourceType, amount: int) -> float:
	"""计算效率因子"""
	var base_efficiency = 1.0
	
	# 根据目标类型调整效率
	match target:
		AllocationTarget.CONSTRUCTION:
			base_efficiency = 0.9 # 建筑建设效率较低
		AllocationTarget.UNIT_PRODUCTION:
			base_efficiency = 1.1 # 单位生产效率较高
		AllocationTarget.RESEARCH:
			base_efficiency = 0.8 # 研究效率较低但重要
		AllocationTarget.MAINTENANCE:
			base_efficiency = 1.0 # 维护效率中等
		AllocationTarget.TRADE:
			base_efficiency = 1.2 # 贸易效率较高
		AllocationTarget.EMERGENCY:
			base_efficiency = 1.5 # 紧急需求效率最高
	
	# 根据资源类型调整
	match resource_type:
		ResourceManager.ResourceType.GOLD:
			base_efficiency *= 1.0 # 金币效率标准
		ResourceManager.ResourceType.MANA:
			base_efficiency *= 0.7 # 魔力效率较低
		_:
			base_efficiency *= 0.9 # 其他资源效率稍低
	
	return base_efficiency

func _calculate_profit_factor(target: AllocationTarget, resource_type: ResourceManager.ResourceType, amount: int) -> float:
	"""计算利润因子"""
	var profit_factor = 1.0
	
	# 根据目标类型计算利润潜力
	match target:
		AllocationTarget.CONSTRUCTION:
			profit_factor = 0.8 # 建筑建设利润较低但长期
		AllocationTarget.UNIT_PRODUCTION:
			profit_factor = 1.2 # 单位生产利润较高
		AllocationTarget.RESEARCH:
			profit_factor = 0.6 # 研究利润最低但影响长远
		AllocationTarget.MAINTENANCE:
			profit_factor = 0.5 # 维护基本无利润
		AllocationTarget.TRADE:
			profit_factor = 1.5 # 贸易利润最高
		AllocationTarget.EMERGENCY:
			profit_factor = 0.3 # 紧急需求利润最低
	
	return profit_factor

func _calculate_urgency_factor(deadline: float, priority: int) -> float:
	"""计算紧急因子"""
	var urgency = 1.0
	
	# 基于截止时间
	var time_remaining = deadline - Time.get_unix_time_from_system()
	if time_remaining < 300: # 5分钟内
		urgency = 2.0
	elif time_remaining < 1800: # 30分钟内
		urgency = 1.5
	elif time_remaining < 3600: # 1小时内
		urgency = 1.2
	
	# 基于优先级
	urgency *= (priority / 10.0)
	
	return urgency

# ===== 分配处理 =====

func _process_allocations():
	"""处理资源分配"""
	if not resource_manager:
		return
	
	# 更新资源储备
	_update_resource_reserves()
	
	# 处理待分配的请求
	_process_pending_requests()
	
	# 检查是否需要重新分配
	_check_reallocation_needs()
	
	# 清理已完成的请求
	_cleanup_completed_requests()

func _update_resource_reserves():
	"""更新资源储备"""
	for resource_type in ResourceManager.ResourceType.values():
		var total_amount = resource_manager.get_resource_amount(resource_type)
		_resource_reserves[resource_type] = int(total_amount * config.reserve_ratio)

func _process_pending_requests():
	"""处理待分配的请求"""
	# 按优先级排序
	allocation_requests.sort_custom(func(a, b): return a.get_priority_score() > b.get_priority_score())
	
	for request in allocation_requests:
		if request.status != "pending":
			continue
		
		var result = _allocate_resources(request)
		if result.success:
			request.status = "allocated"
			request.amount_allocated = result.allocated_amount
			allocation_results.append(result)
			allocation_completed.emit(result)
		else:
			request.status = "failed"
			allocation_failed.emit(request, result.reason)

func _allocate_resources(request: AllocationRequest) -> AllocationResult:
	"""分配资源"""
	var available_amount = _get_available_amount(request.resource_type)
	var requested_amount = request.amount_requested
	
	# 检查是否有足够资源
	if available_amount < requested_amount:
		# 尝试部分分配
		if available_amount >= config.min_allocation_amount:
			return _allocate_partial(request, available_amount)
		else:
			return AllocationResult.new(
				request.request_id, 0, 0.0, 0, 0.0, false, "资源不足"
			)
	
	# 执行完整分配
	return _allocate_full(request)

func _allocate_full(request: AllocationRequest) -> AllocationResult:
	"""执行完整分配"""
	var allocated_amount = request.amount_requested
	var efficiency = request.efficiency_factor
	var profit = int(allocated_amount * request.profit_factor)
	var completion_time = _estimate_completion_time(request, allocated_amount)
	
	# 预留资源（实际分配时扣除）
	_resource_reserves[request.resource_type] += allocated_amount
	
	return AllocationResult.new(
		request.request_id,
		allocated_amount,
		efficiency,
		profit,
		completion_time,
		true,
		"完整分配成功"
	)

func _allocate_partial(request: AllocationRequest, available_amount: int) -> AllocationResult:
	"""执行部分分配"""
	var allocated_amount = available_amount
	var efficiency = request.efficiency_factor * (allocated_amount / float(request.amount_requested))
	var profit = int(allocated_amount * request.profit_factor)
	var completion_time = _estimate_completion_time(request, allocated_amount)
	
	# 预留资源
	_resource_reserves[request.resource_type] += allocated_amount
	
	return AllocationResult.new(
		request.request_id,
		allocated_amount,
		efficiency,
		profit,
		completion_time,
		true,
		"部分分配成功"
	)

func _estimate_completion_time(request: AllocationRequest, amount: int) -> float:
	"""估算完成时间"""
	var base_time = 60.0 # 基础时间1分钟
	
	# 根据资源类型调整时间
	match request.resource_type:
		ResourceManager.ResourceType.GOLD:
			base_time = 30.0 # 金币处理较快
		ResourceManager.ResourceType.MANA:
			base_time = 120.0 # 魔力处理较慢
		_:
			base_time = 60.0
	
	# 根据数量调整时间
	var time_factor = 1.0 + (amount / 1000.0)
	
	# 根据效率调整时间
	time_factor /= request.efficiency_factor
	
	return base_time * time_factor

func _get_available_amount(resource_type: ResourceManager.ResourceType) -> int:
	"""获取可用资源数量"""
	if not resource_manager:
		return 0
	
	var total_amount = resource_manager.get_resource_amount(resource_type)
	var reserved_amount = _resource_reserves.get(resource_type, 0)
	
	return max(0, total_amount - reserved_amount)

# ===== 重新分配检查 =====

func _check_reallocation_needs():
	"""检查重新分配需求"""
	if not prediction_manager:
		return
	
	var predictions = prediction_manager.get_predictions()
	
	for prediction in predictions:
		if prediction.prediction_type == ResourcePredictionManager.PredictionType.SHORTAGE:
			_handle_shortage_reallocation(prediction)

func _handle_shortage_reallocation(prediction: ResourcePredictionManager.PredictionResult):
	"""处理短缺重新分配"""
	var resource_type = prediction.resource_type
	var shortage_amount = int(prediction.predicted_value)
	
	# 查找可以重新分配的低优先级请求
	var low_priority_requests = _get_low_priority_requests(resource_type)
	
	var total_reclaimable = 0
	for request in low_priority_requests:
		total_reclaimable += request.amount_allocated
		
		if total_reclaimable >= shortage_amount:
			break
	
	if total_reclaimable >= shortage_amount:
		_execute_reallocation(resource_type, low_priority_requests, shortage_amount)

func _get_low_priority_requests(resource_type: ResourceManager.ResourceType) -> Array:
	"""获取低优先级请求"""
	var low_priority = []
	
	for request in allocation_requests:
		if (request.resource_type == resource_type and
			request.status == "allocated" and
			request.priority <= 5):
			low_priority.append(request)
	
	# 按优先级排序（优先级低的在前）
	low_priority.sort_custom(func(a, b): return a.priority < b.priority)
	
	return low_priority

func _execute_reallocation(resource_type: ResourceManager.ResourceType, requests: Array, needed_amount: int):
	"""执行重新分配"""
	var reclaimed_amount = 0
	
	for request in requests:
		if reclaimed_amount >= needed_amount:
			break
		
		var reclaim_amount = min(request.amount_allocated, needed_amount - reclaimed_amount)
		
		# 取消部分分配
		request.amount_allocated -= reclaim_amount
		_resource_reserves[resource_type] -= reclaim_amount
		reclaimed_amount += reclaim_amount
		
		# 如果完全取消，标记为失败
		if request.amount_allocated == 0:
			request.status = "cancelled"
		
		reallocation_triggered.emit(resource_type, request.amount_allocated + reclaim_amount, request.amount_allocated)
		
		LogManager.info("ResourceAllocationManager - 重新分配: 从请求 %d 回收 %d %s" % [request.request_id, reclaim_amount, resource_type])

# ===== 清理和维护 =====

func _cleanup_completed_requests():
	"""清理已完成的请求"""
	var active_requests = []
	
	for request in allocation_requests:
		if request.status in ["completed", "cancelled", "failed"]:
			# 释放预留资源
			if request.amount_allocated > 0:
				_resource_reserves[request.resource_type] -= request.amount_allocated
			
			# 添加到历史记录
			var result = allocation_results.filter(func(r): return r.request_id == request.request_id)
			if not result.is_empty():
				allocation_history.append(result[0])
		else:
			active_requests.append(request)
	
	allocation_requests = active_requests
	
	# 限制历史记录大小
	if allocation_history.size() > 100:
		allocation_history = allocation_history.slice(-50)

# ===== 公共接口 =====

func complete_allocation(request_id: int) -> bool:
	"""完成分配"""
	for request in allocation_requests:
		if request.request_id == request_id and request.status == "allocated":
			request.status = "completed"
			
			# 实际扣除资源
			if resource_manager:
				resource_manager.consume_resource(request.resource_type, request.amount_allocated)
			
			# 释放预留
			_resource_reserves[request.resource_type] -= request.amount_allocated
			
			LogManager.info("ResourceAllocationManager - 分配完成: 请求 %d, 资源 %d %s" % [request_id, request.amount_allocated, request.resource_type])
			return true
	
	return false

func cancel_allocation(request_id: int) -> bool:
	"""取消分配"""
	for request in allocation_requests:
		if request.request_id == request_id and request.status in ["pending", "allocated"]:
			request.status = "cancelled"
			
			# 释放预留资源
			if request.amount_allocated > 0:
				_resource_reserves[request.resource_type] -= request.amount_allocated
			
			LogManager.info("ResourceAllocationManager - 分配取消: 请求 %d" % request_id)
			return true
	
	return false

func get_allocation_status() -> Dictionary:
	"""获取分配状态"""
	var status = {
		"pending_requests": 0,
		"allocated_requests": 0,
		"completed_requests": 0,
		"total_reserved": {},
		"available_resources": {},
		"allocation_efficiency": 0.0
	}
	
	var total_efficiency = 0.0
	var efficiency_count = 0
	
	for request in allocation_requests:
		match request.status:
			"pending":
				status.pending_requests += 1
			"allocated":
				status.allocated_requests += 1
			"completed":
				status.completed_requests += 1
		
		if request.status == "allocated":
			total_efficiency += request.efficiency_factor
			efficiency_count += 1
	
	if efficiency_count > 0:
		status.allocation_efficiency = total_efficiency / efficiency_count
	
	# 计算预留和可用资源
	var resource_types = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] # 所有资源类型ID
	for resource_type in resource_types:
		var total = resource_manager.get_resource_amount(resource_type) if resource_manager else 0
		var reserved = _resource_reserves.get(resource_type, 0)
		
		status.total_reserved[resource_type] = reserved
		status.available_resources[resource_type] = total - reserved
	
	return status

func get_allocation_statistics() -> Dictionary:
	"""获取分配统计"""
	var stats = {
		"total_requests": allocation_history.size(),
		"success_rate": 0.0,
		"average_efficiency": 0.0,
		"total_profit": 0,
		"requests_by_target": {},
		"requests_by_resource": {}
	}
	
	if allocation_history.is_empty():
		return stats
	
	var successful_requests = 0
	var total_efficiency = 0.0
	
	for result in allocation_history:
		if result.success:
			successful_requests += 1
			total_efficiency += result.allocation_efficiency
			stats.total_profit += result.estimated_profit
	
	stats.success_rate = float(successful_requests) / float(allocation_history.size())
	stats.average_efficiency = total_efficiency / float(successful_requests) if successful_requests > 0 else 0.0
	
	# 统计按目标和资源分类的请求
	for request in allocation_requests:
		var target_name = str(request.target)
		var resource_name = str(request.resource_type)
		
		stats.requests_by_target[target_name] = stats.requests_by_target.get(target_name, 0) + 1
		stats.requests_by_resource[resource_name] = stats.requests_by_resource.get(resource_name, 0) + 1
	
	return stats

func set_allocation_strategy(strategy: AllocationStrategy):
	"""设置分配策略"""
	match strategy:
		AllocationStrategy.BALANCED:
			config.efficiency_weight = 0.25
			config.profit_weight = 0.25
			config.urgency_weight = 0.25
			config.balance_weight = 0.25
		AllocationStrategy.EFFICIENCY:
			config.efficiency_weight = 0.5
			config.profit_weight = 0.2
			config.urgency_weight = 0.2
			config.balance_weight = 0.1
		AllocationStrategy.PROFIT:
			config.profit_weight = 0.5
			config.efficiency_weight = 0.2
			config.urgency_weight = 0.2
			config.balance_weight = 0.1
		AllocationStrategy.URGENCY:
			config.urgency_weight = 0.5
			config.efficiency_weight = 0.2
			config.profit_weight = 0.2
			config.balance_weight = 0.1
		AllocationStrategy.SUSTAINABILITY:
			config.balance_weight = 0.4
			config.efficiency_weight = 0.3
			config.profit_weight = 0.2
			config.urgency_weight = 0.1
	
	LogManager.info("ResourceAllocationManager - 分配策略更新: %s" % strategy)

func set_config(new_config: Dictionary):
	"""设置配置"""
	config.merge(new_config)
	
	if allocation_timer:
		allocation_timer.wait_time = config.allocation_interval
