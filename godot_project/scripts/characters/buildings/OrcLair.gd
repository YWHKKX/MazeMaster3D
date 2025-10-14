extends Building
class_name OrcLair

## 兽人巢穴 - 训练兽人战士
## 📋 [BUILDING_SYSTEM.md] 兽人巢穴：投入30金币训练兽人战士

# 训练系统
var temporary_gold_storage: int = 0 # 临时金币存储
var training_cost: int = 30 # 训练成本
var training_time: float = 90.0 # 训练时间90秒
var training_progress: float = 0.0 # 训练进度
var is_training: bool = false

# 绑定单位
var bound_orc: Node = null # 绑定的兽人战士
var is_locked: bool = false # 锁定状态（有绑定怪物时）


func _init():
	"""初始化兽人巢穴"""
	super._init()
	
	building_name = "兽人巢穴"
	building_type = BuildingTypes.ORC_LAIR
	
	# 兽人巢穴属性
	max_health = 500
	health = max_health
	armor = 6
	
	# 1x1 建筑
	building_size = Vector2(1, 1)
	
	# 🔧 [建造系统] 建造成本
	cost_gold = 200
	engineer_cost = 100
	build_time = 150.0
	engineer_required = 1
	
	# 初始状态：规划中
	status = BuildingStatus.PLANNING
	build_progress = 0.0
	construction_gold_invested = 0


func _ready():
	"""场景准备就绪"""
	super._ready()
	
	# 🔧 [模型系统] 加载兽人巢穴3D模型
	_load_building_model()


func _load_building_model():
	"""加载兽人巢穴3D模型"""
	var OrcLairModelScene = preload("res://img/scenes/buildings/orc_lair_base.tscn")
	var model = OrcLairModelScene.instantiate()
	model.name = "Model"
	add_child(model)
	
	LogManager.info("🗡️ 兽人巢穴模型已加载")


# ===== 建造系统回调 =====

func _on_construction_completed() -> void:
	"""建造完成回调"""
	super._on_construction_completed()
	
	# 兽人巢穴初始化
	temporary_gold_storage = 0
	is_training = false
	training_progress = 0.0
	
	LogManager.info("🗡️ 兽人巢穴已就绪，可以开始训练")


# ===== 金币投入系统 =====

func can_accept_gold() -> bool:
	"""检查是否可以接受金币投入
	
	📋 [BUILDING_SYSTEM.md] 需要30金币才能开始训练
	"""
	if status != BuildingStatus.COMPLETED:
		return false
	
	if is_locked:
		return false # 已有绑定怪物
	
	return temporary_gold_storage < training_cost


func add_temporary_gold(amount: int) -> int:
	"""添加临时金币（工程师投入）
	
	Returns:
		int: 实际接受的金币数量
	"""
	var space_available = training_cost - temporary_gold_storage
	var gold_to_accept = min(amount, space_available)
	
	temporary_gold_storage += gold_to_accept
	
	LogManager.info("💰 兽人巢穴接收金币: +%d (当前: %d/%d)" % [
		gold_to_accept, temporary_gold_storage, training_cost
	])
	
	# 金币满30后自动开始训练
	if temporary_gold_storage >= training_cost and not is_training:
		_start_training()
	
	return gold_to_accept


# ===== 训练系统 =====

func _start_training():
	"""开始训练兽人战士"""
	is_training = true
	training_progress = 0.0
	
	LogManager.info("🗡️ 兽人巢穴开始训练兽人战士")


func _update_logic(delta: float):
	"""更新训练进度"""
	if status != BuildingStatus.COMPLETED:
		return
	
	if not is_training:
		return
	
	# 推进训练进度
	training_progress += delta
	
	# 训练完成
	if training_progress >= training_time:
		_spawn_orc()
		_reset_training()


func _spawn_orc():
	"""生成兽人战士"""
	# TODO: 实际生成兽人战士单位
	# var orc = CharacterManager.create_orc_warrior(global_position + Vector3(1, 0, 0))
	# bound_orc = orc
	# is_locked = true
	
	LogManager.info("✅ 兽人巢穴训练完成：兽人战士")


func _reset_training():
	"""重置训练状态"""
	temporary_gold_storage = 0
	is_training = false
	training_progress = 0.0


# ===== 绑定系统 =====

func on_orc_died():
	"""兽人战士死亡回调
	
	📋 [BUILDING_SYSTEM.md] 自动解除绑定并解锁
	"""
	bound_orc = null
	is_locked = false
	
	LogManager.info("💀 兽人巢穴解除绑定，可以继续训练")


# ===== 调试信息 =====

func get_building_info() -> Dictionary:
	"""获取建筑详细信息"""
	var base_info = super.get_building_info()
	base_info["temporary_gold"] = temporary_gold_storage
	base_info["is_training"] = is_training
	base_info["training_progress"] = "%.1f%%" % (training_progress / training_time * 100.0 if training_time > 0 else 0.0)
	base_info["is_locked"] = is_locked
	base_info["has_orc"] = is_instance_valid(bound_orc)
	return base_info
