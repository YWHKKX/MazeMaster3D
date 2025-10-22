extends UnifiedBuildingSystem
class_name UnifiedMarket

## 统一市场建筑
## 使用自由组件系统管理市场

# 市场专用属性
var trade_efficiency: float = 1.2
var max_merchants: int = 8
var current_merchants: int = 0
var trade_goods: int = 50
var daily_income: int = 100

func _init():
	super._init()
	building_type = BuildingTypes.BuildingType.MARKET
	building_name = "市场"
	building_description = "商业建筑，用于交易和贸易"
	
	# 建筑属性
	health = 150
	max_health = 150
	armor = 3
	cost_gold = 700
	
	# 资源存储属性
	gold_storage_capacity = 5000
	mana_storage_capacity = 200
	stored_gold = 0
	stored_mana = 0
	
	# 建筑尺寸和主题
	building_size = Vector2(2, 2) # 2x2瓦块
	building_theme = "trading"
	building_tier = 2
	building_category = "commerce"
	
	# 设置渲染模式为自由组件系统
	render_mode = RenderMode.TRADITIONAL
	allow_free_placement = true
	
	# 初始化自由组件
	_setup_market_components()

func _setup_market_components():
	"""设置市场自由组件"""
	# 市场主体结构
	add_component("Market_Main", Vector3(0.8, 0, 0.8), Vector3(1.2, 1.2, 1.2), "structure")
	add_component("Market_Roof", Vector3(0.8, 1.2, 0.8), Vector3(1.4, 0.2, 1.4), "structure")
	
	# 交易设施
	add_component("Trading_Desk", Vector3(0.3, 0.1, 0.3), Vector3(0.8, 0.6, 0.4), "decoration")
	add_component("Vendor_Stall_1", Vector3(0.2, 0.1, 0.7), Vector3(0.4, 0.5, 0.3), "decoration")
	add_component("Vendor_Stall_2", Vector3(1.3, 0.1, 0.7), Vector3(0.4, 0.5, 0.3), "decoration")
	add_component("Display_Counter", Vector3(0.5, 0.1, 0.2), Vector3(0.6, 0.4, 0.2), "decoration")
	add_component("Goods_Storage", Vector3(1.0, 0.1, 0.2), Vector3(0.4, 0.6, 0.3), "decoration")
	add_component("Merchant_Cart", Vector3(0.2, 0.1, 1.3), Vector3(0.5, 0.4, 0.3), "decoration")
	
	# 金币和装饰
	add_component("Coin_Counter", Vector3(0.8, 0.1, 0.3), Vector3(0.3, 0.2, 0.2), "decoration")
	add_component("Coin_Stack", Vector3(1.2, 0.1, 1.0), Vector3(0.2, 0.3, 0.2), "decoration")
	add_component("Market_Banner", Vector3(0.8, 0.8, 0.2), Vector3(0.4, 0.6, 0.1), "decoration")
	
	LogManager.info("🏪 [UnifiedMarket] 设置市场自由组件完成")

func _ready():
	"""建筑准备就绪"""
	super._ready()
	setup_free_components()
	_setup_market_effects()

func _setup_market_effects():
	"""设置市场特效"""
	# 创建交易光效
	var trade_light = OmniLight3D.new()
	trade_light.light_color = Color(1.0, 0.9, 0.6)
	trade_light.light_energy = 1.2
	trade_light.omni_range = 2.5
	trade_light.position = Vector3(0.8, 0.8, 0.8)
	add_child(trade_light)
	
	# 创建金币粒子效果
	var coin_particles = GPUParticles3D.new()
	coin_particles.position = Vector3(0.8, 0.3, 0.8)
	coin_particles.emitting = true
	coin_particles.amount = 30
	coin_particles.lifetime = 3.0
	add_child(coin_particles)
	
	LogManager.info("🏪 [UnifiedMarket] 设置市场特效完成")

func _process(delta: float):
	"""市场处理逻辑"""
	_update_trading_system(delta)
	_update_daily_income(delta)

func _update_trading_system(delta: float):
	"""更新交易系统"""
	if current_merchants > 0 and trade_goods > 0:
		# 进行交易
		var trade_amount = trade_efficiency * delta
		# 这里可以添加具体的交易逻辑
		trade_goods = max(0, trade_goods - int(trade_amount * 0.1))

func _update_daily_income(delta: float):
	"""更新每日收入"""
	# 根据商人数量和交易效率计算收入
	if current_merchants > 0:
		var income = daily_income * current_merchants * trade_efficiency * delta / 86400.0
		stored_gold = min(gold_storage_capacity, stored_gold + int(income))

func get_market_info() -> Dictionary:
	"""获取市场信息"""
	var info = get_building_info()
	info["trade_efficiency"] = trade_efficiency
	info["max_merchants"] = max_merchants
	info["current_merchants"] = current_merchants
	info["trade_goods"] = trade_goods
	info["daily_income"] = daily_income
	info["free_components"] = free_components.size()
	return info