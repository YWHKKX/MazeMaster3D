extends Node
class_name StatusIndicatorManager

# 状态指示器管理器 - 管理所有单位的状态指示器
# 参考 STATUS_INDICATOR.md 文档

# 指示器存储
var indicators: Dictionary = {}

# 预加载StatusIndicator类
const StatusIndicatorClass = preload("res://scripts/ui/StatusIndicator.gd")

func _ready():
	"""初始化状态指示器管理器"""
	LogManager.info("状态指示器管理器初始化")

func create_indicator(unit_id: String) -> StatusIndicatorClass:
	"""创建新的状态指示器"""
	var indicator = StatusIndicatorClass.new()
	
	# 添加到场景树
	add_child(indicator)
	indicators[unit_id] = indicator
	
	# LogManager.debug("创建状态指示器: " + unit_id)
	return indicator

func get_indicator(unit_id: String) -> StatusIndicatorClass:
	"""获取指定的状态指示器"""
	if unit_id in indicators:
		return indicators[unit_id]
	return null

func remove_indicator(unit_id: String):
	"""移除指定的状态指示器"""
	if unit_id in indicators:
		var indicator = indicators[unit_id]
		if is_instance_valid(indicator):
			indicator.queue_free()
		indicators.erase(unit_id)
		# LogManager.debug("移除状态指示器: " + unit_id)

func set_unit_state(unit_id: String, state: String):
	"""设置单位状态"""
	var indicator = get_indicator(unit_id)
	if indicator:
		indicator.set_state(state)
	else:
		# 自动创建指示器
		indicator = create_indicator(unit_id)
		indicator.set_state(state)

func show_unit_indicator(unit_id: String):
	"""显示单位指示器"""
	var indicator = get_indicator(unit_id)
	if indicator:
		indicator.show_indicator()

func hide_unit_indicator(unit_id: String):
	"""隐藏单位指示器"""
	var indicator = get_indicator(unit_id)
	if indicator:
		indicator.hide_indicator()

func attach_to_unit(unit_id: String, unit_node: Node3D):
	"""将指示器附加到单位"""
	var indicator = get_indicator(unit_id)
	if indicator and unit_node:
		# 如果指示器已经有父节点，先从父节点移除
		if indicator.get_parent():
			indicator.get_parent().remove_child(indicator)
		
		# 直接将指示器作为单位的子节点，这样会自动跟随单位移动
		unit_node.add_child(indicator)
		indicator.position = Vector3.ZERO

func list_indicators() -> Array:
	"""获取所有指示器名称列表"""
	return indicators.keys()

func cleanup():
	"""清理所有指示器"""
	for unit_id in indicators.keys():
		remove_indicator(unit_id)
	LogManager.info("状态指示器管理器清理完成")
