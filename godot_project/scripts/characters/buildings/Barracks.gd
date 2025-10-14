extends Building
class_name Barracks

# 训练室（兵营）- 提供怪物训练功能

# 训练配置
var training_speed_multiplier: float = 1.5 # 训练速度倍率
var max_trainees: int = 3 # 最多同时训练3个怪物
var current_trainees: Array = [] # 当前训练中的怪物


func _init():
	"""初始化训练室"""
	super._init()
	
	building_name = "训练室"
	building_type = BuildingTypes.TRAINING_ROOM
	
	# 训练室属性
	max_health = 300
	health = max_health
	armor = 6
	
	# 1x1 建筑
	building_size = Vector2(1, 1)
	
	# 建造成本
	cost_gold = 200
	engineer_cost = 100
	build_time = 120.0
	engineer_required = 1
	
	# 初始状态
	status = BuildingStatus.PLANNING
	build_progress = 0.0


func _ready():
	"""场景准备就绪"""
	super._ready()
	
	# 🔧 [模型系统] 加载训练室3D模型
	_load_building_model()


func _load_building_model():
	"""加载训练室3D模型"""
	var BarracksModelScene = preload("res://img/scenes/buildings/barracks_base.tscn")
	var model = BarracksModelScene.instantiate()
	model.name = "Model"
	add_child(model)
	
	LogManager.info("🏋️ 训练室模型已加载")


func _update_logic(delta: float):
	"""更新训练室逻辑"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 训练中的怪物
	for trainee in current_trainees:
		if is_instance_valid(trainee):
			_train_monster(trainee, delta)


func can_accept_trainee() -> bool:
	"""检查是否可以接收新的训练者"""
	return current_trainees.size() < max_trainees and status == BuildingStatus.COMPLETED


func add_trainee(monster: Node) -> bool:
	"""添加训练者"""
	if can_accept_trainee():
		current_trainees.append(monster)
		return true
	return false


func remove_trainee(monster: Node):
	"""移除训练者"""
	current_trainees.erase(monster)


func _train_monster(monster: Node, delta: float):
	"""训练怪物（提升经验值）"""
	if monster.has_method("gain_experience"):
		var exp_gain = 10.0 * training_speed_multiplier * delta
		monster.gain_experience(exp_gain)
