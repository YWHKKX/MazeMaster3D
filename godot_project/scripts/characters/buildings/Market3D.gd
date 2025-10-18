extends Building3D
class_name Market3D

## 🏗️ 市场3D - 3x3x3商业贸易建筑
## 基于Building3D，实现市场的3x3x3渲染

# 贸易系统
var trade_slots: int = 5 # 交易槽位数量
var gold_generation_rate: float = 2.0 # 金币生成速度
var trade_efficiency: float = 1.5 # 贸易效率倍率
var merchant_attraction_bonus: float = 0.3 # 商人吸引力加成（30%）

# 贸易状态
var active_trades: Array = [] # 当前活跃交易
var merchant_queue: Array = [] # 商人队列
var market_reputation: float = 0.0 # 市场声誉
var daily_revenue: int = 0 # 每日收入


func _init():
	"""初始化市场3D"""
	super._init()
	
	# 基础属性
	building_name = "市场"
	building_type = BuildingTypes.BuildingType.MARKET
	max_health = 280
	health = max_health
	armor = 3
	building_size = Vector2(1, 1) # 保持原有尺寸用于碰撞检测
	cost_gold = 500
	engineer_cost = 250
	build_time = 220.0
	engineer_required = 2
	status = BuildingStatus.PLANNING
	
	# 3D配置
	_setup_3d_config()


func _setup_3d_config():
	"""设置3D配置"""
	# 基础配置
	building_3d_config.set_basic_config(building_name, building_type, Vector3(3, 3, 3))
	
	# 结构配置
	building_3d_config.has_windows = true
	building_3d_config.has_door = true
	building_3d_config.has_roof = true
	building_3d_config.has_decorations = true
	
	# 材质配置（商业风格）
	building_3d_config.wall_color = Color(0.7, 0.6, 0.4) # 金色墙体
	building_3d_config.roof_color = Color(0.6, 0.5, 0.3) # 深金色屋顶
	building_3d_config.floor_color = Color(0.8, 0.7, 0.5) # 浅金色地板
	
	# 特殊功能配置
	building_3d_config.has_lighting = true
	building_3d_config.has_particles = true
	building_3d_config.has_animations = true
	building_3d_config.has_sound_effects = false


func _get_building_template():
	"""获取市场建筑模板"""
	var template = BuildingTemplateClass.new("市场")
	template.building_type = BuildingTypes.BuildingType.MARKET
	template.description = "繁华的3x3x3商业市场，散发着贸易的气息"
	
	# 创建商业结构
	template.create_market_structure(BuildingTypes.BuildingType.MARKET)
	
	# 自定义市场元素
	# 顶层：招牌和旗帜
	template.set_component(0, 2, 0, BuildingComponents.ID_MARKET_BANNER)
	template.set_component(1, 2, 0, BuildingComponents.ID_MARKET_SIGN)
	template.set_component(2, 2, 0, BuildingComponents.ID_MARKET_BANNER)
	template.set_component(0, 2, 1, BuildingComponents.ID_MARKET_BANNER)
	template.set_component(1, 2, 1, BuildingComponents.ID_GOLDEN_CREST)
	template.set_component(2, 2, 1, BuildingComponents.ID_MARKET_BANNER)
	template.set_component(0, 2, 2, BuildingComponents.ID_MARKET_BANNER)
	template.set_component(1, 2, 2, BuildingComponents.ID_MARKET_SIGN)
	template.set_component(2, 2, 2, BuildingComponents.ID_MARKET_BANNER)
	
	# 中层：摊位和展示台
	template.set_component(0, 1, 0, BuildingComponents.ID_VENDOR_STALL)
	template.set_component(1, 1, 0, BuildingComponents.ID_DISPLAY_COUNTER)
	template.set_component(2, 1, 0, BuildingComponents.ID_VENDOR_STALL)
	template.set_component(0, 1, 1, BuildingComponents.ID_DISPLAY_COUNTER)
	template.set_component(1, 1, 1, BuildingComponents.ID_TRADING_DESK)
	template.set_component(2, 1, 1, BuildingComponents.ID_DISPLAY_COUNTER)
	template.set_component(0, 1, 2, BuildingComponents.ID_VENDOR_STALL)
	template.set_component(1, 1, 2, BuildingComponents.ID_DISPLAY_COUNTER)
	template.set_component(2, 1, 2, BuildingComponents.ID_VENDOR_STALL)
	
	# 底层：商品存储和入口
	template.set_component(0, 0, 0, BuildingComponents.ID_GOODS_STORAGE)
	template.set_component(1, 0, 0, BuildingComponents.ID_COIN_COUNTER)
	template.set_component(2, 0, 0, BuildingComponents.ID_GOODS_STORAGE)
	template.set_component(0, 0, 1, BuildingComponents.ID_GOODS_STORAGE)
	template.set_component(1, 0, 1, BuildingComponents.ID_WELCOME_MAT)
	template.set_component(2, 0, 1, BuildingComponents.ID_GOODS_STORAGE)
	template.set_component(0, 0, 2, BuildingComponents.ID_GOODS_STORAGE)
	template.set_component(1, 0, 2, BuildingComponents.ID_COIN_COUNTER)
	template.set_component(2, 0, 2, BuildingComponents.ID_GOODS_STORAGE)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取市场建筑配置"""
	var config = BuildingConfig.new()
	config.name = building_name
	config.width = 3
	config.depth = 3
	config.height = 3
	
	# 结构配置
	config.has_windows = true
	config.has_door = true
	config.has_roof = true
	config.has_decorations = true
	config.has_tower = false
	config.has_balcony = false
	
	# 材质配置
	config.wall_color = Color(0.7, 0.6, 0.4) # 金色
	config.roof_color = Color(0.6, 0.5, 0.3) # 深金色
	config.floor_color = Color(0.8, 0.7, 0.5) # 浅金色
	config.window_color = Color(0.9, 0.8, 0.6) # 淡金色窗户
	config.door_color = Color(0.5, 0.4, 0.2) # 深金色门
	
	return config


func _load_building_specific_components():
	"""加载市场特定构件"""
	# 加载商业构件
	_add_component_to_library("Market_Banner", BuildingComponents.ID_MARKET_BANNER)
	_add_component_to_library("Market_Sign", BuildingComponents.ID_MARKET_SIGN)
	_add_component_to_library("Golden_Crest", BuildingComponents.ID_GOLDEN_CREST)
	_add_component_to_library("Vendor_Stall", BuildingComponents.ID_VENDOR_STALL)
	_add_component_to_library("Display_Counter", BuildingComponents.ID_DISPLAY_COUNTER)
	_add_component_to_library("Trading_Desk", BuildingComponents.ID_TRADING_DESK)
	_add_component_to_library("Goods_Storage", BuildingComponents.ID_GOODS_STORAGE)
	_add_component_to_library("Coin_Counter", BuildingComponents.ID_COIN_COUNTER)
	_add_component_to_library("Welcome_Mat", BuildingComponents.ID_WELCOME_MAT)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("🏪 [Market3D] 市场3D准备就绪")
	
	# 启动市场特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("🏪 [Market3D] 市场3D建造完成")
	
	# 启动贸易系统
	_start_trading_system()
	
	# 启动市场动画
	if construction_animator:
		construction_animator.play_function_animation("market_activity")


func _start_trading_system():
	"""启动贸易系统"""
	# 设置贸易更新定时器
	var trading_timer = Timer.new()
	trading_timer.name = "TradingTimer"
	trading_timer.wait_time = 1.0 # 每秒更新一次
	trading_timer.timeout.connect(_update_trading)
	trading_timer.autostart = true
	add_child(trading_timer)
	
	# 设置金币生成定时器
	var gold_timer = Timer.new()
	gold_timer.name = "GoldTimer"
	gold_timer.wait_time = 2.0 # 每2秒生成一次
	gold_timer.timeout.connect(_generate_gold)
	gold_timer.autostart = true
	add_child(gold_timer)
	
	# 初始化市场声誉
	market_reputation = 50.0


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑"""
	# 调用父类方法
	super._update_3d_building_logic(delta)
	
	# 更新贸易系统
	_update_trading_system(delta)
	
	# 更新市场特效
	_update_market_effects(delta)


func _update_trading_system(delta: float):
	"""更新贸易系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 更新贸易进度
	_update_trading_progress(delta)


func _update_trading_progress(delta: float):
	"""更新贸易进度"""
	# 这里可以添加贸易进度的视觉指示
	pass


func _update_trading():
	"""更新贸易"""
	# 处理当前活跃的交易
	for trade in active_trades:
		if is_instance_valid(trade):
			_process_trade(trade, 1.0)
	
	# 处理商人队列
	_process_merchant_queue()


func _process_trade(trade: Dictionary, delta: float):
	"""处理交易"""
	if not trade.has("progress"):
		trade["progress"] = 0.0
	
	var efficiency = trade_efficiency * (1.0 + merchant_attraction_bonus)
	trade["progress"] += delta * efficiency
	
	# 检查交易是否完成
	if trade["progress"] >= 100.0:
		_complete_trade(trade)


func _complete_trade(trade: Dictionary):
	"""完成交易"""
	var trade_value = trade.get("value", 100)
	active_trades.erase(trade)
	
	# 增加市场声誉和收入
	market_reputation += trade_value * 0.01
	daily_revenue += trade_value
	
	# 播放完成特效
	_play_trade_complete_effect()
	
	LogManager.info("🏪 [Market3D] 交易完成: %s, 价值: %d" % [trade.get("name", "未知"), trade_value])


func _process_merchant_queue():
	"""处理商人队列"""
	if merchant_queue.size() > 0 and active_trades.size() < trade_slots:
		var merchant = merchant_queue.pop_front()
		_start_trade_with_merchant(merchant)


func _start_trade_with_merchant(merchant: Dictionary):
	"""开始与商人的交易"""
	var trade = {
		"name": merchant.get("name", "未知商人"),
		"type": merchant.get("type", "普通"),
		"value": merchant.get("value", 100),
		"progress": 0.0,
		"merchant": merchant
	}
	active_trades.append(trade)
	
	_play_trade_start_effect()


func _generate_gold():
	"""生成金币"""
	var gold_generated = int(gold_generation_rate * (1.0 + market_reputation * 0.01))
	if resource_manager:
		resource_manager.add_gold(gold_generated)
	
	# 播放金币生成特效
	_play_gold_generation_effect()


func _play_trade_start_effect():
	"""播放交易开始特效"""
	if not effect_manager:
		return
	
	# 创建交易开始粒子效果
	effect_manager._create_particle_effect("trade_start", global_position + Vector3(0, 1, 0), 2.0)


func _play_trade_complete_effect():
	"""播放交易完成特效"""
	if not effect_manager:
		return
	
	# 创建交易完成粒子效果
	effect_manager._create_particle_effect("trade_complete", global_position + Vector3(0, 1.5, 0), 3.0)


func _play_gold_generation_effect():
	"""播放金币生成特效"""
	if not effect_manager:
		return
	
	# 创建金币生成粒子效果
	effect_manager._create_particle_effect("gold_generation", global_position + Vector3(0, 0.5, 0), 1.5)


func can_start_trade() -> bool:
	"""检查是否可以开始新的交易"""
	return active_trades.size() < trade_slots and status == BuildingStatus.COMPLETED


func start_trade_with_merchant(merchant_name: String, trade_type: String, trade_value: int) -> bool:
	"""开始与商人的交易"""
	if can_start_trade():
		var merchant = {
			"name": merchant_name,
			"type": trade_type,
			"value": trade_value
		}
		merchant_queue.append(merchant)
		return true
	return false


func _update_market_effects(delta: float):
	"""更新市场特效"""
	# 更新招牌动画
	_update_market_sign_animation(delta)
	
	# 更新摊位活动
	_update_vendor_stall_activity(delta)


func _update_market_sign_animation(delta: float):
	"""更新市场招牌动画"""
	# 招牌动画
	if construction_animator:
		construction_animator.play_function_animation("market_sign")
	
	# 根据贸易活跃度调整招牌发光
	var trade_intensity = float(active_trades.size()) / float(trade_slots)
	
	if effect_manager and effect_manager.light_systems.has("market_sign_light"):
		var light = effect_manager.light_systems["market_sign_light"]
		if light and light.visible:
			light.light_energy = 0.6 + trade_intensity * 0.8
			light.light_color = Color(1.0, 0.8, 0.4) # 金色招牌光


func _update_vendor_stall_activity(delta: float):
	"""更新摊位活动"""
	# 摊位活动动画
	if construction_animator:
		construction_animator.play_function_animation("vendor_stall")
	
	# 根据贸易数量调整活动强度
	var activity_intensity = float(active_trades.size()) / float(trade_slots)
	
	if effect_manager and effect_manager.particle_systems.has("market_particles"):
		var ps = effect_manager.particle_systems["market_particles"]
		if ps and ps.emitting:
			# 调整粒子强度
			ps.amount = int(4 + activity_intensity * 10)


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新市场特定特效
	_update_market_specific_effects(delta)


func _update_market_specific_effects(delta: float):
	"""更新市场特定特效"""
	# 市场脉冲效果
	var trade_count = active_trades.size()
	var pulse_frequency = 1.1 + trade_count * 0.4
	
	if effect_manager and effect_manager.light_systems.has("market_glow"):
		var light = effect_manager.light_systems["market_glow"]
		if light and light.visible:
			# 市场脉冲
			light.light_energy = 0.7 + sin(Time.get_time_dict_from_system()["second"] * pulse_frequency) * 0.3
			light.light_color = Color(1.0, 0.8, 0.4) # 金色市场光


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加市场特定信息
	base_info["trade_slots"] = trade_slots
	base_info["gold_generation_rate"] = gold_generation_rate
	base_info["trade_efficiency"] = trade_efficiency
	base_info["merchant_attraction_bonus"] = merchant_attraction_bonus
	base_info["active_trades_count"] = active_trades.size()
	base_info["merchant_queue_size"] = merchant_queue.size()
	base_info["market_reputation"] = market_reputation
	base_info["daily_revenue"] = daily_revenue
	base_info["can_start_trade"] = can_start_trade()
	base_info["trade_capacity_ratio"] = float(active_trades.size()) / float(trade_slots)
	
	return base_info


func _on_destroyed():
	"""建筑被摧毁时的回调（重写父类方法）"""
	# 调用父类方法
	super._on_destroyed()
	
	# 停止所有交易
	active_trades.clear()
	merchant_queue.clear()
	
	# 停止所有特效
	if effect_manager:
		effect_manager.stop_functional_effects()
	
	# 停止所有动画
	if construction_animator:
		construction_animator.stop_all_animations()
	
	LogManager.info("💀 [Market3D] 市场被摧毁，所有特效已停止")
