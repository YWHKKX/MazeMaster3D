extends Building
class_name Lair

## 巢穴 - 怪物休息和治疗建筑
## 📋 [BUILDING_SYSTEM.md] 巢穴：提供住房和治疗功能

# 住房系统
var max_occupants: int = 5 # 最大容纳5个怪物
var current_occupants: Array = [] # 当前居住的怪物

# 治疗系统
var heal_rate: float = 2.0 # 每秒回复2点生命值
var heal_multiplier: float = 2.0 # 治疗速度提升100%

# 士气加成
var morale_bonus: float = 0.1 # 周围怪物攻击力+10%
var morale_radius: float = 60.0 # 60像素范围


func _init():
	"""初始化巢穴"""
	super._init()
	
	building_name = "巢穴"
	building_type = BuildingTypes.LAIR
	
	# 巢穴属性
	max_health = 250
	health = max_health
	armor = 4
	
	# 1x1 建筑
	building_size = Vector2(1, 1)
	
	# 🔧 [建造系统] 建造成本
	cost_gold = 150
	engineer_cost = 75
	build_time = 90.0
	engineer_required = 1
	
	# 初始状态：规划中
	status = BuildingStatus.PLANNING
	build_progress = 0.0
	construction_gold_invested = 0


func _ready():
	"""场景准备就绪"""
	super._ready()
	
	# 🔧 [模型系统] 加载巢穴3D模型
	_load_building_model()


func _load_building_model():
	"""加载巢穴3D模型"""
	var LairModelScene = preload("res://img/scenes/buildings/lair_base.tscn")
	var model = LairModelScene.instantiate()
	model.name = "Model"
	add_child(model)
	
	LogManager.info("🏠 巢穴模型已加载")


# ===== 建造系统回调 =====

func _on_construction_completed() -> void:
	"""建造完成回调"""
	super._on_construction_completed()
	
	# 巢穴初始化
	current_occupants.clear()
	
	LogManager.info("🏠 巢穴已就绪，可以容纳怪物")


# ===== 住房系统 =====

func can_accept_occupant() -> bool:
	"""检查是否可以接受新居民"""
	if status != BuildingStatus.COMPLETED:
		return false
	
	return current_occupants.size() < max_occupants


func add_occupant(monster: Node) -> bool:
	"""添加居民
	
	Args:
		monster: 怪物节点
	
	Returns:
		bool: 是否成功添加
	"""
	if not can_accept_occupant():
		return false
	
	if monster in current_occupants:
		return false # 已经是居民了
	
	current_occupants.append(monster)
	
	LogManager.info("🏠 巢穴接纳新居民: %s (当前: %d/%d)" % [
		monster.name if monster.has_method("get_name") else "未知",
		current_occupants.size(),
		max_occupants
	])
	
	return true


func remove_occupant(monster: Node):
	"""移除居民"""
	if monster in current_occupants:
		current_occupants.erase(monster)


# ===== 治疗系统 =====

func _update_logic(delta: float):
	"""更新巢穴逻辑 - 治疗居民"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 治疗所有居民
	for monster in current_occupants:
		if not is_instance_valid(monster):
			current_occupants.erase(monster)
			continue
		
		if monster.has_method("heal"):
			monster.heal(heal_rate * heal_multiplier * delta)


# ===== 调试信息 =====

func get_building_info() -> Dictionary:
	"""获取建筑详细信息"""
	var base_info = super.get_building_info()
	base_info["occupants"] = current_occupants.size()
	base_info["max_occupants"] = max_occupants
	base_info["occupancy"] = "%.1f%%" % (float(current_occupants.size()) / float(max_occupants) * 100.0)
	return base_info
