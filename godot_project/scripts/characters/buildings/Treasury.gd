extends Building
class_name Treasury

# 金库 - 用于存储额外的金币
# 📋 [BUILDING_SYSTEM.md] 金库提供500金币独立存储容量

# 存储容量（stored_gold 和 gold_storage_capacity 继承自 Building 基类）

# 信号定义
signal gold_changed(amount: int, old_amount: int)


func _init():
	"""初始化金库"""
	super._init()
	
	building_name = "金库"
	building_type = BuildingTypes.TREASURY
	
	# 金库属性
	max_health = 200
	health = max_health
	armor = 5
	
	# 1x1 建筑
	building_size = Vector2(1, 1)
	
	# 建造成本
	cost_gold = 100
	engineer_cost = 50
	build_time = 60.0
	engineer_required = 1
	
	# 设置存储属性
	stored_gold = 0
	gold_storage_capacity = 500


func _ready():
	"""场景准备就绪"""
	super._ready()
	
	# 🔧 [模型系统] 加载金库3D模型
	_load_building_model()
	
	# 注册到资源管理器（当建造完成时）
	if status == BuildingStatus.COMPLETED:
		_register_to_resource_manager()
	
	# 🔧 [状态栏系统] 初始化存储显示
	call_deferred("_update_storage_display")


func _load_building_model():
	"""加载金库3D模型"""
	var TreasuryModelScene = preload("res://img/scenes/buildings/treasury_base.tscn")
	var model = TreasuryModelScene.instantiate()
	model.name = "Model"
	add_child(model)
	
	LogManager.info("💰 金库模型已加载")


func _register_to_resource_manager():
	"""注册到资源管理器"""
	if has_node("/root/Main/ResourceManager"):
		resource_manager = get_node("/root/Main/ResourceManager")
		resource_manager.register_treasury(self)
		LogManager.info("金库已注册到资源管理器")


func _update_logic(_delta: float):
	"""更新金库逻辑"""
	# 金库被建造完成时注册
	if status == BuildingStatus.COMPLETED and resource_manager == null:
		_register_to_resource_manager()


# ===== 资源管理（只读接口，实际操作通过 ResourceManager）=====

func is_full() -> bool:
	"""检查金库是否已满"""
	return stored_gold >= gold_storage_capacity


func get_fill_percentage() -> float:
	"""获取填充百分比"""
	return float(stored_gold) / float(gold_storage_capacity) if gold_storage_capacity > 0 else 0.0


func withdraw_gold(amount: int) -> int:
	"""从金库取出金币（供工程师使用）
	
	🔧 [新建造系统] 直接从建筑扣除金币
	
	Args:
		amount: 要取出的金币数量
	
	Returns:
		int: 实际取出的金币数量
	"""
	if not is_active or status != BuildingStatus.COMPLETED:
		return 0
	
	var available = mini(stored_gold, amount)
	if available > 0:
		var old_amount = stored_gold
		stored_gold -= available
		LogManager.info("💰 金库取出 %d 金币 | 剩余: %d/%d" % [
			available, stored_gold, gold_storage_capacity
		])
		# 发出金币变化信号
		gold_changed.emit(stored_gold, old_amount)
		
		# 🔧 [状态栏系统] 更新存储显示
		_update_storage_display()
	
	return available


func accept_gold_deposit(_depositor, amount: int) -> Dictionary:
	"""接受金币存储（供苦工等单位使用）- 通过 ResourceManager
	
	Args:
		_depositor: 存储者（苦工等）
		amount: 存储数量
	
	Returns:
		Dictionary: 存储结果
	"""
	if not is_active or status != BuildingStatus.COMPLETED:
		return {
			"deposited": false,
			"amount_deposited": 0,
			"message": "金库未完成或已损坏"
		}
	
	if is_full():
		return {
			"deposited": false,
			"amount_deposited": 0,
			"message": "金库已满"
		}
	
	# 通过 ResourceManager 添加金币
	if resource_manager:
		var result = resource_manager.add_gold(amount, self)
		return {
			"deposited": result.get("success", false),
			"amount_deposited": result.get("amount", 0),
			"message": "成功存储 %d 金币" % result.get("amount", 0) if result.get("success", false) else "金库容量不足"
		}
	
	return {
		"deposited": false,
		"amount_deposited": 0,
		"message": "资源管理器不可用"
	}


# ===== 建造完成回调 =====

func _on_construction_completed() -> void:
	"""建造完成时的回调（重写父类方法）"""
	super._on_construction_completed()
	
	# 🔧 修复：建造完成后立即注册到资源管理器
	LogManager.info("💰 [Treasury] 建造完成，正在注册到资源管理器...")
	_register_to_resource_manager()


# ===== 调试信息 =====

func get_building_info() -> Dictionary:
	"""获取金库信息"""
	var info = super.get_building_info()
	info["stored_gold"] = stored_gold
	info["gold_capacity"] = gold_storage_capacity
	info["fill"] = "%.1f%%" % (get_fill_percentage() * 100)
	info["is_full"] = is_full()
	return info
