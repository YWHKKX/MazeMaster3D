extends Building
class_name Library

# 图书馆 - 法力生成和研究

var mana_generation_rate: float = 0.2 # 每秒生成0.2法力
var spell_power_bonus: float = 0.15 # 15%法术增强


func _init():
	super._init()
	building_name = "图书馆"
	building_type = BuildingTypes.LIBRARY
	max_health = 200
	health = max_health
	armor = 5
	building_size = Vector2(1, 1)
	cost_gold = 250
	engineer_cost = 125
	build_time = 150.0
	engineer_required = 1
	status = BuildingStatus.PLANNING


func _ready():
	super._ready()
	var model_scene = preload("res://img/scenes/buildings/library_base.tscn")
	var model = model_scene.instantiate()
	model.name = "Model"
	add_child(model)


func _update_logic(delta: float):
	if status == BuildingStatus.COMPLETED and resource_manager:
		# 生成法力
		var mana_generated = mana_generation_rate * delta
		resource_manager.add_mana(int(mana_generated))
