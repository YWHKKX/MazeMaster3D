class_name ResourcePredictionManager
extends Node

## 🔮 资源预测和规划管理器
## 基于历史数据和当前状态预测资源需求和供应

# 导入依赖 - 使用动态加载避免循环依赖
# const ResourceManager = preload("res://scripts/managers/resource/ResourceManager.gd")

# 预测类型枚举
enum PredictionType {
	DEMAND, # 需求预测
	SUPPLY, # 供应预测
	SHORTAGE, # 短缺预测
	SURPLUS # 过剩预测
}

# 预测时间范围枚举
enum PredictionTimeRange {
	SHORT_TERM, # 短期 (1-5分钟)
	MEDIUM_TERM, # 中期 (5-30分钟)
	LONG_TERM # 长期 (30分钟以上)
}

# 历史数据记录
class ResourceHistoryRecord:
	var timestamp: float
	var resource_type: int
	var amount: int
	var operation_type: String # "consumed", "produced", "collected"
	var source: String # 来源描述
	
	func _init(time: float, type: int, amt: int, op: String, src: String = ""):
		timestamp = time
		resource_type = type
		amount = amt
		operation_type = op
		source = src

# 预测结果
class PredictionResult:
	var prediction_type: PredictionType
	var resource_type: int
	var predicted_value: float
	var confidence: float # 0.0-1.0
	var time_range: PredictionTimeRange
	var factors: Array = [] # 影响因子
	var recommendations: Array = [] # 建议措施
	
	func _init(type: PredictionType, res_type: int, value: float, conf: float, time: PredictionTimeRange):
		prediction_type = type
		resource_type = res_type
		predicted_value = value
		confidence = conf
		time_range = time

# 配置
var config = {
	"history_retention_hours": 24.0, # 历史数据保留时间
	"prediction_update_interval": 10.0, # 预测更新间隔
	"min_confidence_threshold": 0.6, # 最小置信度阈值
	"trend_analysis_window": 300.0, # 趋势分析窗口(秒)
	"demand_multiplier": 1.2, # 需求预测倍数
	"supply_multiplier": 0.8 # 供应预测倍数
}

# 数据存储
var resource_history: Array[ResourceHistoryRecord] = []
var current_predictions: Array[PredictionResult] = []
var demand_patterns: Dictionary = {} # 需求模式分析
var supply_patterns: Dictionary = {} # 供应模式分析

# 管理器引用
var resource_manager = null
var prediction_timer: Timer = null

# 信号定义
signal prediction_updated(predictions: Array)
signal shortage_predicted(resource_type: int, shortage_amount: int, time_range: PredictionTimeRange)
signal surplus_predicted(resource_type: int, surplus_amount: int, time_range: PredictionTimeRange)
signal recommendation_generated(recommendations: Array)

func _ready():
	"""初始化资源预测管理器"""
	LogManager.info("ResourcePredictionManager - 初始化开始")
	
	_setup_prediction_timer()
	_connect_signals()
	
	# 延迟获取管理器引用
	call_deferred("_setup_manager_references")
	
	LogManager.info("ResourcePredictionManager - 初始化完成")

func _setup_prediction_timer():
	"""设置预测更新定时器"""
	prediction_timer = Timer.new()
	prediction_timer.wait_time = config.prediction_update_interval
	prediction_timer.timeout.connect(_update_predictions)
	prediction_timer.autostart = true
	add_child(prediction_timer)

func _connect_signals():
	"""连接信号"""
	# 等待一帧确保其他系统已初始化
	await get_tree().process_frame
	
	if GameServices.has_method("get_resource_manager"):
		resource_manager = GameServices.get_resource_manager()
		if resource_manager:
			resource_manager.resource_added.connect(_on_resource_added)
			resource_manager.resource_removed.connect(_on_resource_removed)
			resource_manager.resource_spawned.connect(_on_resource_spawned)

func _setup_manager_references():
	"""设置管理器引用"""
	if GameServices.has_method("get_resource_manager"):
		resource_manager = GameServices.get_resource_manager()

# ===== 历史数据管理 =====

func record_resource_operation(resource_type: int, amount: int, operation_type: String, source: String = ""):
	"""记录资源操作历史"""
	var record = ResourceHistoryRecord.new(
		Time.get_unix_time_from_system(),
		resource_type,
		amount,
		operation_type,
		source
	)
	
	resource_history.append(record)
	_cleanup_old_history()

func _cleanup_old_history():
	"""清理过期历史数据"""
	var current_time = Time.get_unix_time_from_system()
	var cutoff_time = current_time - (config.history_retention_hours * 3600.0)
	
	resource_history = resource_history.filter(func(record): return record.timestamp > cutoff_time)

func _on_resource_added(resource_type: int, amount: int):
	"""资源添加回调"""
	record_resource_operation(resource_type, amount, "produced")

func _on_resource_removed(resource_type: int, amount: int):
	"""资源移除回调"""
	record_resource_operation(resource_type, -amount, "consumed")

func _on_resource_spawned(resource_type: int, position: Vector2, amount: int):
	"""资源生成回调"""
	record_resource_operation(resource_type, amount, "collected", "spawn")

# ===== 预测分析 =====

func _update_predictions():
	"""更新预测结果"""
	if not resource_manager:
		return
	
	current_predictions.clear()
	
	# 为每种资源类型生成预测
	var resource_types = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] # 所有资源类型ID
	for resource_type in resource_types:
		_generate_resource_predictions(resource_type)
	
	# 生成建议
	_generate_recommendations()
	
	prediction_updated.emit(current_predictions)

func _generate_resource_predictions(resource_type: int):
	"""为特定资源生成预测"""
	# 需求预测
	var demand_prediction = _predict_demand(resource_type)
	if demand_prediction:
		current_predictions.append(demand_prediction)
	
	# 供应预测
	var supply_prediction = _predict_supply(resource_type)
	if supply_prediction:
		current_predictions.append(supply_prediction)
	
	# 短缺/过剩预测
	var shortage_prediction = _predict_shortage(resource_type)
	if shortage_prediction:
		current_predictions.append(shortage_prediction)
	
	var surplus_prediction = _predict_surplus(resource_type)
	if surplus_prediction:
		current_predictions.append(surplus_prediction)

func _predict_demand(resource_type: int) -> PredictionResult:
	"""预测资源需求"""
	var history_data = _get_resource_history(resource_type, "consumed")
	if history_data.size() < 3:
		return null
	
	# 计算平均消费率
	var avg_consumption = _calculate_average_consumption(history_data)
	var trend = _calculate_trend(history_data)
	
	# 应用趋势和倍数
	var predicted_demand = avg_consumption * config.demand_multiplier * (1.0 + trend)
	var confidence = _calculate_confidence(history_data.size(), trend)
	
	var prediction = PredictionResult.new(
		PredictionType.DEMAND,
		resource_type,
		predicted_demand,
		confidence,
		PredictionTimeRange.MEDIUM_TERM
	)
	
	prediction.factors.append("historical_consumption")
	prediction.factors.append("trend_analysis")
	
	return prediction

func _predict_supply(resource_type: int) -> PredictionResult:
	"""预测资源供应"""
	var history_data = _get_resource_history(resource_type, "produced")
	if history_data.size() < 3:
		return null
	
	# 计算平均生产率
	var avg_production = _calculate_average_production(history_data)
	var trend = _calculate_trend(history_data)
	
	# 应用趋势和倍数
	var predicted_supply = avg_production * config.supply_multiplier * (1.0 + trend)
	var confidence = _calculate_confidence(history_data.size(), trend)
	
	var prediction = PredictionResult.new(
		PredictionType.SUPPLY,
		resource_type,
		predicted_supply,
		confidence,
		PredictionTimeRange.MEDIUM_TERM
	)
	
	prediction.factors.append("historical_production")
	prediction.factors.append("trend_analysis")
	
	return prediction

func _predict_shortage(resource_type: int) -> PredictionResult:
	"""预测资源短缺"""
	var current_amount = resource_manager.get_resource_amount(resource_type)
	var demand_prediction = _get_prediction_by_type(resource_type, PredictionType.DEMAND)
	var supply_prediction = _get_prediction_by_type(resource_type, PredictionType.SUPPLY)
	
	if not demand_prediction or not supply_prediction:
		return null
	
	var net_demand = demand_prediction.predicted_value - supply_prediction.predicted_value
	var shortage_amount = max(0, net_demand - current_amount)
	
	if shortage_amount <= 0:
		return null
	
	var confidence = min(demand_prediction.confidence, supply_prediction.confidence) * 0.8
	var time_range = PredictionTimeRange.SHORT_TERM if shortage_amount > current_amount else PredictionTimeRange.MEDIUM_TERM
	
	var prediction = PredictionResult.new(
		PredictionType.SHORTAGE,
		resource_type,
		shortage_amount,
		confidence,
		time_range
	)
	
	prediction.factors.append("current_stock")
	prediction.factors.append("demand_supply_balance")
	
	shortage_predicted.emit(resource_type, int(shortage_amount), time_range)
	
	return prediction

func _predict_surplus(resource_type: int) -> PredictionResult:
	"""预测资源过剩"""
	var current_amount = resource_manager.get_resource_amount(resource_type)
	var demand_prediction = _get_prediction_by_type(resource_type, PredictionType.DEMAND)
	var supply_prediction = _get_prediction_by_type(resource_type, PredictionType.SUPPLY)
	
	if not demand_prediction or not supply_prediction:
		return null
	
	var net_supply = supply_prediction.predicted_value - demand_prediction.predicted_value
	var surplus_amount = max(0, current_amount + net_supply - _get_resource_capacity(resource_type))
	
	if surplus_amount <= 0:
		return null
	
	var confidence = min(demand_prediction.confidence, supply_prediction.confidence) * 0.8
	var time_range = PredictionTimeRange.LONG_TERM
	
	var prediction = PredictionResult.new(
		PredictionType.SURPLUS,
		resource_type,
		surplus_amount,
		confidence,
		time_range
	)
	
	prediction.factors.append("storage_capacity")
	prediction.factors.append("supply_demand_balance")
	
	surplus_predicted.emit(resource_type, int(surplus_amount), time_range)
	
	return prediction

# ===== 辅助分析函数 =====

func _get_resource_history(resource_type: int, operation_type: String) -> Array:
	"""获取特定资源的操作历史"""
	var filtered_history = []
	var cutoff_time = Time.get_unix_time_from_system() - config.trend_analysis_window
	
	for record in resource_history:
		if (record.resource_type == resource_type and
			record.operation_type == operation_type and
			record.timestamp > cutoff_time):
			filtered_history.append(record)
	
	return filtered_history

func _calculate_average_consumption(history_data: Array) -> float:
	"""计算平均消费率"""
	if history_data.is_empty():
		return 0.0
	
	var total_amount = 0.0
	var time_span = 0.0
	
	for i in range(history_data.size()):
		total_amount += abs(history_data[i].amount)
	
	if history_data.size() > 1:
		time_span = history_data[-1].timestamp - history_data[0].timestamp
	
	if time_span > 0:
		return total_amount / (time_span / 60.0) # 每分钟消费量
	else:
		return total_amount

func _calculate_average_production(history_data: Array) -> float:
	"""计算平均生产率"""
	if history_data.is_empty():
		return 0.0
	
	var total_amount = 0.0
	var time_span = 0.0
	
	for record in history_data:
		total_amount += record.amount
	
	if history_data.size() > 1:
		time_span = history_data[-1].timestamp - history_data[0].timestamp
	
	if time_span > 0:
		return total_amount / (time_span / 60.0) # 每分钟生产量
	else:
		return total_amount

func _calculate_trend(history_data: Array) -> float:
	"""计算趋势系数"""
	if history_data.size() < 2:
		return 0.0
	
	# 简单线性趋势计算
	var first_half = history_data.slice(0, history_data.size() / 2)
	var second_half = history_data.slice(history_data.size() / 2)
	
	var first_avg = 0.0
	var second_avg = 0.0
	
	for record in first_half:
		first_avg += abs(record.amount)
	first_avg /= first_half.size()
	
	for record in second_half:
		second_avg += abs(record.amount)
	second_avg /= second_half.size()
	
	if first_avg == 0:
		return 0.0
	
	return (second_avg - first_avg) / first_avg

func _calculate_confidence(data_size: int, trend: float) -> float:
	"""计算预测置信度"""
	var size_factor = min(1.0, data_size / 10.0) # 数据量因子
	var trend_factor = 1.0 - abs(trend) # 趋势稳定性因子
	return size_factor * trend_factor

func _get_prediction_by_type(resource_type: int, prediction_type: PredictionType) -> PredictionResult:
	"""根据类型获取预测结果"""
	for prediction in current_predictions:
		if prediction.resource_type == resource_type and prediction.prediction_type == prediction_type:
			return prediction
	return null

func _get_resource_capacity(resource_type: int) -> int:
	"""获取资源存储容量"""
	# 这里应该从ResourceManager获取实际容量
	# 暂时返回一个较大的默认值
	return 999999

# ===== 建议生成 =====

func _generate_recommendations():
	"""生成资源管理建议"""
	var recommendations = []
	
	for prediction in current_predictions:
		match prediction.prediction_type:
			PredictionType.SHORTAGE:
				recommendations.append(_generate_shortage_recommendation(prediction))
			PredictionType.SURPLUS:
				recommendations.append(_generate_surplus_recommendation(prediction))
	
	recommendation_generated.emit(recommendations)

func _generate_shortage_recommendation(prediction: PredictionResult) -> Dictionary:
	"""生成短缺建议"""
	var recommendation = {
		"type": "shortage",
		"resource_type": prediction.resource_type,
		"severity": "high" if prediction.predicted_value > 100 else "medium",
		"actions": []
	}
	
	# 根据资源类型生成具体建议
	match prediction.resource_type:
		0: # GOLD
			recommendation.actions.append("增加金矿开采")
			recommendation.actions.append("建造更多金库")
		1: # FOOD
			recommendation.actions.append("增加食物生产建筑")
			recommendation.actions.append("减少单位消耗")
		2: # MANA
			recommendation.actions.append("建造魔法祭坛")
			recommendation.actions.append("升级魔法建筑")
		_:
			recommendation.actions.append("增加采集者数量")
			recommendation.actions.append("优化采集路线")
	
	return recommendation

func _generate_surplus_recommendation(prediction: PredictionResult) -> Dictionary:
	"""生成过剩建议"""
	var recommendation = {
		"type": "surplus",
		"resource_type": prediction.resource_type,
		"severity": "low",
		"actions": []
	}
	
	recommendation.actions.append("考虑资源交易")
	recommendation.actions.append("升级相关建筑")
	recommendation.actions.append("减少生产投入")
	
	return recommendation

# ===== 公共接口 =====

func get_predictions(resource_type: int = -1) -> Array:
	"""获取预测结果"""
	if resource_type:
		return current_predictions.filter(func(p): return p.resource_type == resource_type)
	else:
		return current_predictions

func get_prediction_summary() -> Dictionary:
	"""获取预测摘要"""
	var summary = {
		"total_predictions": current_predictions.size(),
		"shortages": 0,
		"surpluses": 0,
		"high_confidence": 0,
		"low_confidence": 0
	}
	
	for prediction in current_predictions:
		if prediction.prediction_type == PredictionType.SHORTAGE:
			summary.shortages += 1
		elif prediction.prediction_type == PredictionType.SURPLUS:
			summary.surpluses += 1
		
		if prediction.confidence > config.min_confidence_threshold:
			summary.high_confidence += 1
		else:
			summary.low_confidence += 1
	
	return summary

func set_config(new_config: Dictionary):
	"""设置配置"""
	config.merge(new_config)
	
	if prediction_timer:
		prediction_timer.wait_time = config.prediction_update_interval

func get_history_statistics() -> Dictionary:
	"""获取历史统计信息"""
	var stats = {
		"total_records": resource_history.size(),
		"records_by_type": {},
		"records_by_operation": {},
		"time_span_hours": 0.0
	}
	
	if not resource_history.is_empty():
		stats.time_span_hours = (resource_history[-1].timestamp - resource_history[0].timestamp) / 3600.0
	
	for record in resource_history:
		var type_name = str(record.resource_type)
		var op_name = record.operation_type
		
		stats.records_by_type[type_name] = stats.records_by_type.get(type_name, 0) + 1
		stats.records_by_operation[op_name] = stats.records_by_operation.get(op_name, 0) + 1
	
	return stats
