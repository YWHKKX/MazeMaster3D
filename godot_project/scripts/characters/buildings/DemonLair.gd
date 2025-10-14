extends Building
class_name DemonLair

## 恶魔巢穴 - 自动召唤小恶魔
## 📋 [BUILDING_SYSTEM.md] 恶魔巢穴：投入20金币自动召唤小恶魔

# 召唤系统
var temporary_gold_storage: int = 0 # 临时金币存储
var summoning_cost: int = 20 # 召唤成本
var summoning_time: float = 60.0 # 召唤时间60秒
var summoning_progress: float = 0.0 # 召唤进度
var is_summoning: bool = false

# 魔力消耗
var mana_cost_per_second: float = 1.0 # 每秒消耗1点魔力

# 绑定单位
var bound_demon: Node = null # 绑定的小恶魔
var is_locked: bool = false # 锁定状态（有绑定怪物时）


func _init():
	"""初始化恶魔巢穴"""
	super._init()
	
	building_name = "恶魔巢穴"
	building_type = BuildingTypes.DEMON_LAIR
	
	# 恶魔巢穴属性
	max_health = 450
	health = max_health
	armor = 6
	
	# 1x1 建筑
	building_size = Vector2(1, 1)
	
	# 🔧 [建造系统] 建造成本
	cost_gold = 200
	engineer_cost = 100
	build_time = 180.0
	engineer_required = 1
	
	# 初始状态：规划中
	status = BuildingStatus.PLANNING
	build_progress = 0.0
	construction_gold_invested = 0


func _ready():
	"""场景准备就绪"""
	super._ready()
	
	# 🔧 [模型系统] 加载恶魔巢穴3D模型
	_load_building_model()


func _load_building_model():
	"""加载恶魔巢穴3D模型"""
	var DemonLairModelScene = preload("res://img/scenes/buildings/demon_lair_base.tscn")
	var model = DemonLairModelScene.instantiate()
	model.name = "Model"
	add_child(model)
	
	LogManager.info("👿 恶魔巢穴模型已加载")
	
	# 获取管理器
	call_deferred("_setup_managers")


func _setup_managers():
	"""设置管理器引用"""
	if is_inside_tree():
		resource_manager = GameServices.resource_manager


# ===== 建造系统回调 =====

func _on_construction_completed() -> void:
	"""建造完成回调"""
	super._on_construction_completed()
	
	# 恶魔巢穴初始化
	temporary_gold_storage = 0
	is_summoning = false
	summoning_progress = 0.0
	
	LogManager.info("👿 恶魔巢穴已就绪，可以开始召唤")


# ===== 金币投入系统 =====

func can_accept_gold() -> bool:
	"""检查是否可以接受金币投入
	
	📋 [BUILDING_SYSTEM.md] 需要20金币才能开始召唤
	"""
	if status != BuildingStatus.COMPLETED:
		return false
	
	if is_locked:
		return false # 已有绑定怪物
	
	return temporary_gold_storage < summoning_cost


func add_temporary_gold(amount: int) -> int:
	"""添加临时金币（工程师投入）
	
	Returns:
		int: 实际接受的金币数量
	"""
	var space_available = summoning_cost - temporary_gold_storage
	var gold_to_accept = min(amount, space_available)
	
	temporary_gold_storage += gold_to_accept
	
	LogManager.info("💰 恶魔巢穴接收金币: +%d (当前: %d/%d)" % [
		gold_to_accept, temporary_gold_storage, summoning_cost
	])
	
	# 金币满20后自动开始召唤
	if temporary_gold_storage >= summoning_cost and not is_summoning:
		_start_summoning()
	
	return gold_to_accept


# ===== 召唤系统 =====

func _start_summoning():
	"""开始召唤小恶魔"""
	is_summoning = true
	summoning_progress = 0.0
	
	LogManager.info("👿 恶魔巢穴开始召唤小恶魔")


func _update_logic(delta: float):
	"""更新召唤进度"""
	if status != BuildingStatus.COMPLETED:
		return
	
	if not is_summoning:
		return
	
	# 检查魔力
	if not _check_and_consume_mana(delta):
		# 魔力不足，暂停召唤
		return
	
	# 推进召唤进度
	summoning_progress += delta
	
	# 召唤完成
	if summoning_progress >= summoning_time:
		_spawn_demon()
		_reset_summoning()


func _check_and_consume_mana(delta: float) -> bool:
	"""检查并消耗魔力
	
	📋 [BUILDING_SYSTEM.md] 每秒消耗1点魔力
	"""
	if not resource_manager:
		return true # 如果没有resource_manager，跳过检查
	
	var mana_needed = mana_cost_per_second * delta
	
	# 检查魔力是否充足
	var total_mana = resource_manager.get_total_mana()
	if total_mana and total_mana.total < mana_needed:
		LogManager.warning("⚠️ 恶魔巢穴魔力不足，暂停召唤")
		return false
	
	# 消耗魔力
	var consumed = resource_manager.consume_mana(int(ceil(mana_needed)))
	return consumed.success


func _spawn_demon():
	"""生成小恶魔"""
	# TODO: 实际生成小恶魔单位
	# var demon = CharacterManager.create_demon(global_position + Vector3(1, 0, 0))
	# bound_demon = demon
	# is_locked = true
	
	LogManager.info("✅ 恶魔巢穴召唤完成：小恶魔")


func _reset_summoning():
	"""重置召唤状态"""
	temporary_gold_storage = 0
	is_summoning = false
	summoning_progress = 0.0


# ===== 绑定系统 =====

func on_demon_died():
	"""小恶魔死亡回调
	
	📋 [BUILDING_SYSTEM.md] 自动解除绑定并解锁
	"""
	bound_demon = null
	is_locked = false
	
	LogManager.info("💀 恶魔巢穴解除绑定，可以继续召唤")


# ===== 调试信息 =====

func get_building_info() -> Dictionary:
	"""获取建筑详细信息"""
	var base_info = super.get_building_info()
	base_info["temporary_gold"] = temporary_gold_storage
	base_info["is_summoning"] = is_summoning
	base_info["summoning_progress"] = "%.1f%%" % (summoning_progress / summoning_time * 100.0 if summoning_time > 0 else 0.0)
	base_info["is_locked"] = is_locked
	base_info["has_demon"] = is_instance_valid(bound_demon)
	return base_info
