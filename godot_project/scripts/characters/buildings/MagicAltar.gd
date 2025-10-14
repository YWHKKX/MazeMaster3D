extends Building
class_name MagicAltar

# 魔法祭坛 - 法力生成

var mana_generation_rate: float = 0.5 # 每秒生成0.5法力


func _init():
	super._init()
	building_name = "魔法祭坛"
	building_type = BuildingTypes.MAGIC_ALTAR
	max_health = 300
	health = max_health
	armor = 4
	building_size = Vector2(1, 1)
	cost_gold = 120
	engineer_cost = 60
	build_time = 160.0
	engineer_required = 1
	status = BuildingStatus.PLANNING


func _ready():
	super._ready()
	var model_scene = preload("res://img/scenes/buildings/magic_altar_base.tscn")
	var model = model_scene.instantiate()
	model.name = "Model"
	add_child(model)


func _update_logic(delta: float):
	if status == BuildingStatus.COMPLETED and resource_manager:
		var mana_generated = mana_generation_rate * delta
		resource_manager.add_mana(int(mana_generated))
