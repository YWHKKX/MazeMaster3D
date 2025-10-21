class_name ResourceTradeManager
extends Node

## 💰 资源交易管理器
## 处理资源之间的交易、兑换和优化分配

# 导入依赖 - 使用动态加载避免循环依赖
# const ResourceManager = preload("res://scripts/managers/resource/ResourceManager.gd")
# const ResourcePredictionManager = preload("res://scripts/managers/resource/ResourcePredictionManager.gd")

# 交易类型枚举
enum TradeType {
	EXCHANGE, # 资源兑换
	SELL, # 出售资源
	BUY, # 购买资源
	TRADE_OFFER, # 交易报价
	AUTO_TRADE # 自动交易
}

# 交易状态枚举
enum TradeStatus {
	PENDING, # 待处理
	ACCEPTED, # 已接受
	REJECTED, # 已拒绝
	COMPLETED, # 已完成
	CANCELLED # 已取消
}

# 交易记录
class TradeRecord:
	var trade_id: int
	var trade_type: TradeType
	var resource_from: int
	var amount_from: int
	var resource_to: int
	var amount_to: int
	var exchange_rate: float
	var timestamp: float
	var status: TradeStatus
	var profit: int # 交易利润
	var reason: String # 交易原因
	
	func _init(id: int, type: TradeType, from_type: int, from_amt: int, to_type: int, to_amt: int, rate: float, reason_str: String = ""):
		trade_id = id
		trade_type = type
		resource_from = from_type
		amount_from = from_amt
		resource_to = to_type
		amount_to = to_amt
		exchange_rate = rate
		timestamp = Time.get_unix_time_from_system()
		status = TradeStatus.PENDING
		profit = 0
		reason = reason_str

# 交易规则
class TradeRule:
	var resource_from: int
	var resource_to: int
	var base_rate: float # 基础汇率
	var min_rate: float # 最小汇率
	var max_rate: float # 最大汇率
	var auto_trade_threshold: int # 自动交易阈值
	var enabled: bool = true
	
	func _init(from_type: int, to_type: int, rate: float, min_r: float = 0.0, max_r: float = 0.0, threshold: int = 0):
		resource_from = from_type
		resource_to = to_type
		base_rate = rate
		min_rate = min_r if min_r > 0 else rate * 0.8
		max_rate = max_r if max_r > 0 else rate * 1.2
		auto_trade_threshold = threshold

# 配置
var config = {
	"auto_trade_enabled": true, # 自动交易开关
	"auto_trade_interval": 30.0, # 自动交易检查间隔
	"max_trade_amount": 1000, # 单次最大交易量
	"min_trade_amount": 10, # 单次最小交易量
	"profit_margin": 0.1, # 利润边际
	"trade_history_retention": 100, # 交易历史保留数量
	"market_volatility": 0.05, # 市场波动率
	"demand_supply_factor": 0.3 # 供需影响因子
}

# 数据存储
var trade_rules: Array[TradeRule] = []
var trade_history: Array[TradeRecord] = []
var pending_trades: Array[TradeRecord] = []
var trade_counter: int = 0

# 市场数据
var market_prices: Dictionary = {} # 市场价格
var market_volatility: Dictionary = {} # 市场波动
var demand_supply_ratio: Dictionary = {} # 供需比例

# 管理器引用
var resource_manager = null
var prediction_manager = null
var trade_timer: Timer = null

# 信号定义
signal trade_created(trade: TradeRecord)
signal trade_completed(trade: TradeRecord)
signal trade_cancelled(trade: TradeRecord)
signal auto_trade_executed(trade: TradeRecord)
signal market_price_updated(resource_type: int, new_price: float)

func _ready():
	"""初始化资源交易管理器"""
	LogManager.info("ResourceTradeManager - 初始化开始")
	
	_initialize_trade_rules()
	_setup_trade_timer()
	_connect_signals()
	
	# 延迟获取管理器引用
	call_deferred("_setup_manager_references")
	
	LogManager.info("ResourceTradeManager - 初始化完成")

func _initialize_trade_rules():
	"""初始化交易规则"""
	# 核心资源之间的交易规则
	trade_rules.append(TradeRule.new(
		0, # GOLD
		1, # FOOD
		2.0, # 1金币 = 2食物
		1.5, 3.0, 50 # 阈值50
	))
	
	trade_rules.append(TradeRule.new(
		1, # FOOD
		0, # GOLD
		0.5, # 2食物 = 1金币
		0.3, 0.7, 100
	))
	
	# 基础资源交易规则
	trade_rules.append(TradeRule.new(
		0, # GOLD
		2, # STONE
		3.0, # 1金币 = 3石头
		2.0, 4.0, 30
	))
	
	trade_rules.append(TradeRule.new(
		0, # GOLD
		3, # WOOD
		2.5, # 1金币 = 2.5木材
		1.8, 3.2, 40
	))
	
	trade_rules.append(TradeRule.new(
		0, # GOLD
		4, # IRON
		4.0, # 1金币 = 4铁矿
		3.0, 5.0, 20
	))
	
	# 特殊资源交易规则
	trade_rules.append(TradeRule.new(
		0, # GOLD
		5, # GEM
		10.0, # 1金币 = 10宝石
		8.0, 12.0, 5
	))
	
	trade_rules.append(TradeRule.new(
		0, # GOLD
		6, # MAGIC_HERB
		15.0, # 1金币 = 15魔法草药
		12.0, 18.0, 3
	))
	
	trade_rules.append(TradeRule.new(
		0, # GOLD
		7, # MAGIC_CRYSTAL
		25.0, # 1金币 = 25魔法水晶
		20.0, 30.0, 2
	))
	
	trade_rules.append(TradeRule.new(
		0, # GOLD
		8, # DEMON_CORE
		50.0, # 1金币 = 50恶魔核心
		40.0, 60.0, 1
	))
	
	# 特殊资源之间的交易
	trade_rules.append(TradeRule.new(
		5, # GEM
		6, # MAGIC_HERB
		1.5, # 1宝石 = 1.5魔法草药
		1.2, 1.8, 2
	))
	
	trade_rules.append(TradeRule.new(
		6, # MAGIC_HERB
		7, # MAGIC_CRYSTAL
		1.7, # 1魔法草药 = 1.7魔法水晶
		1.4, 2.0, 1
	))

func _setup_trade_timer():
	"""设置交易定时器"""
	if not config.auto_trade_enabled:
		return
	
	trade_timer = Timer.new()
	trade_timer.wait_time = config.auto_trade_interval
	trade_timer.timeout.connect(_process_auto_trades)
	trade_timer.autostart = true
	add_child(trade_timer)

func _connect_signals():
	"""连接信号"""
	# 等待一帧确保其他系统已初始化
	await get_tree().process_frame
	
	if GameServices.has_method("get_resource_manager"):
		resource_manager = GameServices.get_resource_manager()
	
	if GameServices.has_method("get_resource_prediction_manager"):
		prediction_manager = GameServices.get_resource_prediction_manager()

func _setup_manager_references():
	"""设置管理器引用"""
	if GameServices.has_method("get_resource_manager"):
		resource_manager = GameServices.get_resource_manager()
	
	if GameServices.has_method("get_resource_prediction_manager"):
		prediction_manager = GameServices.get_resource_prediction_manager()

# ===== 交易执行 =====

func create_trade(resource_from: int, amount_from: int, resource_to: int, reason: String = "") -> TradeRecord:
	"""创建交易"""
	var trade_rule = _find_trade_rule(resource_from, resource_to)
	if not trade_rule or not trade_rule.enabled:
		LogManager.warning("ResourceTradeManager - 未找到有效的交易规则: %s -> %s" % [resource_from, resource_to])
		return null
	
	# 检查资源是否足够
	if not resource_manager or resource_manager.get_resource_amount(resource_from) < amount_from:
		LogManager.warning("ResourceTradeManager - 资源不足，无法创建交易")
		return null
	
	# 计算交易量和汇率
	var exchange_rate = _calculate_current_rate(trade_rule, resource_from, resource_to)
	var amount_to = int(amount_from * exchange_rate)
	
	# 限制交易量
	amount_from = clamp(amount_from, config.min_trade_amount, config.max_trade_amount)
	amount_to = int(amount_from * exchange_rate)
	
	# 创建交易记录
	var trade = TradeRecord.new(
		trade_counter,
		TradeType.EXCHANGE,
		resource_from,
		amount_from,
		resource_to,
		amount_to,
		exchange_rate,
		reason
	)
	
	trade_counter += 1
	pending_trades.append(trade)
	
	# 执行交易
	if _execute_trade(trade):
		trade.status = TradeStatus.COMPLETED
		trade_history.append(trade)
		_cleanup_trade_history()
		
		trade_created.emit(trade)
		trade_completed.emit(trade)
		
		LogManager.info("ResourceTradeManager - 交易完成: %d %s -> %d %s (汇率: %.2f)" % [amount_from, resource_from, amount_to, resource_to, exchange_rate])
	else:
		trade.status = TradeStatus.REJECTED
		trade_cancelled.emit(trade)
		
		LogManager.warning("ResourceTradeManager - 交易失败: %s" % reason)
	
	return trade

func _execute_trade(trade: TradeRecord) -> bool:
	"""执行交易"""
	if not resource_manager:
		return false
	
	# 检查资源是否仍然足够
	if resource_manager.get_resource_amount(trade.resource_from) < trade.amount_from:
		return false
	
	# 扣除源资源
	resource_manager.consume_resource(trade.resource_from, trade.amount_from)
	
	# 添加目标资源
	resource_manager.add_resource(trade.resource_to, trade.amount_to)
	
	# 计算利润
	trade.profit = _calculate_trade_profit(trade)
	
	# 更新市场价格
	_update_market_prices(trade)
	
	return true

func _calculate_trade_profit(trade: TradeRecord) -> int:
	"""计算交易利润"""
	# 基于市场价格的利润计算
	var from_value = _get_market_value(trade.resource_from, trade.amount_from)
	var to_value = _get_market_value(trade.resource_to, trade.amount_to)
	
	return to_value - from_value

func _get_market_value(resource_type: int, amount: int) -> int:
	"""获取市场价值"""
	var base_price = market_prices.get(resource_type, 1.0)
	return int(amount * base_price)

# ===== 自动交易 =====

func _process_auto_trades():
	"""处理自动交易"""
	if not resource_manager or not prediction_manager:
		return
	
	# 获取预测结果
	var predictions = prediction_manager.get_predictions()
	
	for prediction in predictions:
		if prediction.prediction_type == ResourcePredictionManager.PredictionType.SHORTAGE:
			_handle_shortage_prediction(prediction)
		elif prediction.prediction_type == ResourcePredictionManager.PredictionType.SURPLUS:
			_handle_surplus_prediction(prediction)

func _handle_shortage_prediction(prediction: ResourcePredictionManager.PredictionResult):
	"""处理短缺预测"""
	var resource_type = prediction.resource_type
	var shortage_amount = int(prediction.predicted_value)
	
	# 寻找可以兑换的资源
	var best_trade = _find_best_exchange_for_shortage(resource_type, shortage_amount)
	if best_trade:
		var trade = create_trade(
			best_trade.resource_from,
			best_trade.amount_from,
			resource_type,
			"自动交易: 短缺预测"
		)
		if trade:
			auto_trade_executed.emit(trade)

func _handle_surplus_prediction(prediction: ResourcePredictionManager.PredictionResult):
	"""处理过剩预测"""
	var resource_type = prediction.resource_type
	var surplus_amount = int(prediction.predicted_value)
	
	# 寻找可以兑换的目标资源
	var best_trade = _find_best_exchange_for_surplus(resource_type, surplus_amount)
	if best_trade:
		var trade = create_trade(
			resource_type,
			best_trade.amount_from,
			best_trade.resource_to,
			"自动交易: 过剩预测"
		)
		if trade:
			auto_trade_executed.emit(trade)

func _find_best_exchange_for_shortage(target_resource: int, amount_needed: int) -> Dictionary:
	"""为短缺资源寻找最佳兑换方案"""
	var best_trade = null
	var best_efficiency = 0.0
	
	for rule in trade_rules:
		if rule.resource_to == target_resource and rule.enabled:
			var current_rate = _calculate_current_rate(rule, rule.resource_from, rule.resource_to)
			var required_amount = int(amount_needed / current_rate)
			
			# 检查是否有足够资源
			if resource_manager.get_resource_amount(rule.resource_from) >= required_amount:
				var efficiency = current_rate / rule.base_rate
				if efficiency > best_efficiency:
					best_efficiency = efficiency
					best_trade = {
						"resource_from": rule.resource_from,
						"amount_from": required_amount,
						"resource_to": rule.resource_to,
						"amount_to": amount_needed
					}
	
	return best_trade

func _find_best_exchange_for_surplus(source_resource: int, available_amount: int) -> Dictionary:
	"""为过剩资源寻找最佳兑换方案"""
	var best_trade = null
	var best_value = 0.0
	
	for rule in trade_rules:
		if rule.resource_from == source_resource and rule.enabled:
			var current_rate = _calculate_current_rate(rule, rule.resource_from, rule.resource_to)
			var trade_amount = min(available_amount, config.max_trade_amount)
			var target_amount = int(trade_amount * current_rate)
			
			var trade_value = _get_market_value(rule.resource_to, target_amount)
			if trade_value > best_value:
				best_value = trade_value
				best_trade = {
					"resource_from": rule.resource_from,
					"amount_from": trade_amount,
					"resource_to": rule.resource_to,
					"amount_to": target_amount
				}
	
	return best_trade

# ===== 辅助函数 =====

func _find_trade_rule(resource_from: int, resource_to: int) -> TradeRule:
	"""查找交易规则"""
	for rule in trade_rules:
		if rule.resource_from == resource_from and rule.resource_to == resource_to:
			return rule
	return null

func _calculate_current_rate(trade_rule: TradeRule, resource_from: int, resource_to: int) -> float:
	"""计算当前汇率"""
	var base_rate = trade_rule.base_rate
	
	# 根据供需比例调整汇率
	var supply_demand_factor = _get_supply_demand_factor(resource_from, resource_to)
	var adjusted_rate = base_rate * (1.0 + supply_demand_factor * config.demand_supply_factor)
	
	# 添加市场波动
	var volatility = market_volatility.get(resource_from, config.market_volatility)
	var random_factor = randf_range(-volatility, volatility)
	adjusted_rate *= (1.0 + random_factor)
	
	# 限制在合理范围内
	adjusted_rate = clamp(adjusted_rate, trade_rule.min_rate, trade_rule.max_rate)
	
	return adjusted_rate

func _get_supply_demand_factor(resource_from: int, resource_to: int) -> float:
	"""获取供需因子"""
	if not resource_manager:
		return 0.0
	
	var from_amount = resource_manager.get_resource_amount(resource_from)
	var to_amount = resource_manager.get_resource_amount(resource_to)
	
	if to_amount == 0:
		return 1.0 # 目标资源完全短缺
	
	return float(from_amount) / float(to_amount) - 1.0

func _update_market_prices(trade: TradeRecord):
	"""更新市场价格"""
	var from_price = market_prices.get(trade.resource_from, 1.0)
	var to_price = market_prices.get(trade.resource_to, 1.0)
	
	# 基于交易量调整价格
	var volume_factor = float(trade.amount_from) / float(config.max_trade_amount)
	
	# 供应增加，价格下降
	market_prices[trade.resource_from] = from_price * (1.0 - volume_factor * 0.01)
	
	# 需求增加，价格上涨
	market_prices[trade.resource_to] = to_price * (1.0 + volume_factor * 0.01)
	
	market_price_updated.emit(trade.resource_from, market_prices[trade.resource_from])
	market_price_updated.emit(trade.resource_to, market_prices[trade.resource_to])

func _cleanup_trade_history():
	"""清理交易历史"""
	if trade_history.size() > config.trade_history_retention:
		trade_history = trade_history.slice(-config.trade_history_retention)

# ===== 公共接口 =====

func get_trade_rules() -> Array:
	"""获取交易规则"""
	return trade_rules

func get_trade_history(limit: int = 50) -> Array:
	"""获取交易历史"""
	if limit > 0:
		return trade_history.slice(-limit)
	else:
		return trade_history

func get_market_prices() -> Dictionary:
	"""获取市场价格"""
	return market_prices

func get_trade_statistics() -> Dictionary:
	"""获取交易统计"""
	var stats = {
		"total_trades": trade_history.size(),
		"pending_trades": pending_trades.size(),
		"total_profit": 0,
		"trades_by_type": {},
		"most_traded_resource": "",
		"highest_profit_trade": 0
	}
	
	var resource_trade_counts = {}
	var max_trades = 0
	var max_profit = 0
	
	for trade in trade_history:
		stats.total_profit += trade.profit
		max_profit = max(max_profit, trade.profit)
		
		var type_name = str(trade.trade_type)
		stats.trades_by_type[type_name] = stats.trades_by_type.get(type_name, 0) + 1
		
		var from_name = str(trade.resource_from)
		resource_trade_counts[from_name] = resource_trade_counts.get(from_name, 0) + 1
		
		if resource_trade_counts[from_name] > max_trades:
			max_trades = resource_trade_counts[from_name]
			stats.most_traded_resource = from_name
	
	stats.highest_profit_trade = max_profit
	
	return stats

func set_trade_rule_enabled(resource_from: int, resource_to: int, enabled: bool):
	"""设置交易规则启用状态"""
	var rule = _find_trade_rule(resource_from, resource_to)
	if rule:
		rule.enabled = enabled
		LogManager.info("ResourceTradeManager - 交易规则 %s->%s: %s" % [resource_from, resource_to, "启用" if enabled else "禁用"])

func set_config(new_config: Dictionary):
	"""设置配置"""
	config.merge(new_config)
	
	if trade_timer:
		trade_timer.wait_time = config.auto_trade_interval

func toggle_auto_trade(enabled: bool):
	"""切换自动交易"""
	config.auto_trade_enabled = enabled
	
	if enabled and not trade_timer:
		_setup_trade_timer()
	elif not enabled and trade_timer:
		trade_timer.queue_free()
		trade_timer = null
	
	LogManager.info("ResourceTradeManager - 自动交易: %s" % ("开启" if enabled else "关闭"))
