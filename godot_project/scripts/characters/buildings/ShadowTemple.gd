extends Building
class_name ShadowTemple

# 暗影神殿 - 高级魔法建筑

var shadow_power_bonus: float = 0.3 # 30%暗影法术增强
var mana_generation_rate: float = 1.0 # 每秒1点法力


func _init():
	super._init()
	building_name = "暗影神殿"
	building_type = BuildingTypes.SHADOW_TEMPLE
	max_health = 1000
	health = max_health
	armor = 10
	building_size = Vector2(1, 1)
	cost_gold = 800
	engineer_cost = 400
	build_time = 300.0
	engineer_required = 3
	status = BuildingStatus.PLANNING


func _ready():
	super._ready()
	var model_scene = preload("res://img/scenes/buildings/shadow_temple_base.tscn")
	var model = model_scene.instantiate()
	model.name = "Model"
	add_child(model)


func _update_logic(delta: float):
	if status == BuildingStatus.COMPLETED and resource_manager:
		var mana = mana_generation_rate * delta
		resource_manager.add_mana(int(mana))
