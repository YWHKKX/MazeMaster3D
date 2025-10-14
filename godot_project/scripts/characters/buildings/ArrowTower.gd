extends Building
class_name ArrowTower

## 箭塔 - 自动攻击防御建筑
## 📋 [BUILDING_SYSTEM.md] 箭塔：自动攻击入侵者，需要弹药装填

# 弹药系统
var current_ammunition: int = 0
var max_ammunition: int = 60 # 最大60发弹药
var ammo_cost_per_shot: int = 1 # 每发消耗1金币

# 攻击系统
var attack_damage: float = 30.0
var attack_range: float = 100.0 # 100像素半径
var attack_interval: float = 1.5 # 1.5秒攻击一次
var attack_timer: float = 0.0
var current_target: Node = null

# 击退系统
var knockback_power: float = 1.5 # 重击类型
var critical_chance: float = 0.25 # 25%暴击概率
var critical_multiplier: float = 1.5 # 1.5倍暴击伤害


func _init():
	"""初始化箭塔"""
	super._init()
	
	building_name = "箭塔"
	building_type = BuildingTypes.ARROW_TOWER
	
	# 箭塔属性
	max_health = 800
	health = max_health
	armor = 5
	
	# 1x1 建筑
	building_size = Vector2(1, 1)
	
	# 🔧 [建造系统] 建造成本
	cost_gold = 200
	engineer_cost = 100
	build_time = 100.0
	engineer_required = 1
	
	# 初始状态：规划中
	status = BuildingStatus.PLANNING
	build_progress = 0.0
	construction_gold_invested = 0


func _ready():
	"""场景准备就绪"""
	super._ready()
	
	# 🔧 [模型系统] 加载箭塔3D模型
	_load_building_model()


func _load_building_model():
	"""加载箭塔3D模型"""
	var ArrowTowerModelScene = preload("res://img/scenes/buildings/arrow_tower_base.tscn")
	var model = ArrowTowerModelScene.instantiate()
	model.name = "Model"
	add_child(model)
	
	LogManager.info("🏹 箭塔模型已加载")
	
	# 添加到防御建筑组
	add_to_group(GameGroups.DEFENSE_BUILDINGS)


# ===== 建造系统回调 =====

func _on_construction_completed() -> void:
	"""建造完成回调"""
	super._on_construction_completed()
	
	# 箭塔初始化：无弹药
	current_ammunition = 0
	
	LogManager.info("🏹 箭塔已就绪，需要装填弹药")


# ===== 弹药系统 =====

func needs_ammo() -> bool:
	"""检查是否需要弹药
	
	📋 [BUILDING_SYSTEM.md] 弹药系统：工程师装填弹药
	"""
	if status != BuildingStatus.COMPLETED:
		return false
	
	return current_ammunition < max_ammunition


func get_ammo_needed() -> int:
	"""获取需要的弹药数量（等于需要的金币）"""
	return max(0, max_ammunition - current_ammunition)


func add_ammo(amount: int) -> int:
	"""添加弹药（工程师装填）
	
	Args:
		amount: 装填的弹药数量
	
	Returns:
		int: 实际消耗的金币数量
	"""
	if status != BuildingStatus.COMPLETED:
		return 0
	
	var ammo_to_add = min(amount, max_ammunition - current_ammunition)
	current_ammunition += ammo_to_add
	
	LogManager.info("🔫 箭塔装填弹药: +%d (当前: %d/%d)" % [
		ammo_to_add, current_ammunition, max_ammunition
	])
	
	return ammo_to_add # 返回消耗的金币数


# ===== 攻击系统 =====

func _update_logic(delta: float):
	"""更新箭塔逻辑"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 无弹药不攻击
	if current_ammunition <= 0:
		current_target = null
		return
	
	# 攻击冷却
	attack_timer += delta
	if attack_timer < attack_interval:
		return
	
	# 寻找目标
	if not is_instance_valid(current_target) or not _is_valid_target(current_target):
		current_target = _find_nearest_enemy()
	
	# 攻击目标
	if current_target:
		_attack_target(current_target)
		attack_timer = 0.0


func _find_nearest_enemy() -> Node:
	"""寻找最近的敌人（英雄阵营）"""
	var enemies = GameGroups.get_nodes(GameGroups.HEROES)
	var nearest: Node = null
	var min_distance = attack_range
	
	for enemy in enemies:
		if not _is_valid_target(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = enemy
	
	return nearest


func _is_valid_target(target: Node) -> bool:
	"""检查目标是否有效"""
	if not is_instance_valid(target):
		return false
	
	# 检查距离
	var distance = global_position.distance_to(target.global_position)
	if distance > attack_range:
		return false
	
	# 检查是否存活
	if target.has_method("is_alive") and not target.is_alive():
		return false
	
	return true


func _attack_target(target: Node):
	"""攻击目标
	
	📋 [BUILDING_SYSTEM.md] 箭塔攻击系统：
	- 30点物理伤害
	- 25%暴击概率（1.5倍伤害）
	- 强击退效果
	"""
	# 消耗弹药
	current_ammunition -= 1
	
	# 计算伤害
	var damage = attack_damage
	var is_critical = randf() < critical_chance
	if is_critical:
		damage *= critical_multiplier
	
	# 应用伤害
	if target.has_method("take_damage"):
		target.take_damage(damage, self)
	
	# 应用击退
	if target.has_method("apply_knockback"):
		var direction = (target.global_position - global_position).normalized()
		var knockback_force = knockback_power * 10.8 # 击退距离10.8像素
		target.apply_knockback(direction, knockback_force)
	
	if is_critical:
		LogManager.info("💥 箭塔暴击: %.1f 伤害 (弹药: %d/%d)" % [
			damage, current_ammunition, max_ammunition
		])


# ===== 调试信息 =====

func get_building_info() -> Dictionary:
	"""获取建筑详细信息"""
	var base_info = super.get_building_info()
	base_info["ammunition"] = current_ammunition
	base_info["max_ammunition"] = max_ammunition
	base_info["ammo_percentage"] = "%.1f%%" % (float(current_ammunition) / float(max_ammunition) * 100.0 if max_ammunition > 0 else 0.0)
	base_info["has_target"] = is_instance_valid(current_target)
	return base_info
