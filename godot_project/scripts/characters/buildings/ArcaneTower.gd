extends Building
class_name ArcaneTower

# 奥术塔 - 魔法防御塔

var attack_damage: float = 40.0
var attack_range: float = 100.0
var attack_interval: float = 2.5
var mana_cost_per_attack: float = 1.0
var last_attack_time: float = 0.0


func _init():
	super._init()
	building_name = "奥术塔"
	building_type = BuildingTypes.ARCANE_TOWER
	max_health = 800
	health = max_health
	armor = 5
	building_size = Vector2(1, 1)
	cost_gold = 200
	engineer_cost = 100
	build_time = 100.0
	engineer_required = 1
	status = BuildingStatus.PLANNING


func _ready():
	super._ready()
	var model_scene = preload("res://img/scenes/buildings/arcane_tower_base.tscn")
	var model = model_scene.instantiate()
	model.name = "Model"
	add_child(model)
	add_to_group(GameGroups.DEFENSE_BUILDINGS)


func _update_logic(delta: float):
	if status != BuildingStatus.COMPLETED:
		return
	
	last_attack_time += delta
	if last_attack_time >= attack_interval:
		_try_attack()
		last_attack_time = 0.0


func _try_attack():
	"""尝试攻击敌人"""
	var enemies = GameGroups.get_nodes(GameGroups.HEROES)
	var nearest_enemy = null
	var min_distance = attack_range
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest_enemy = enemy
	
	if nearest_enemy and resource_manager:
		# 检查魔力
		if resource_manager.get_mana() >= mana_cost_per_attack:
			resource_manager.remove_mana(int(mana_cost_per_attack))
			# 攻击逻辑（需要ProjectileManager支持）
			if nearest_enemy.has_method("take_damage"):
				nearest_enemy.take_damage(attack_damage)
