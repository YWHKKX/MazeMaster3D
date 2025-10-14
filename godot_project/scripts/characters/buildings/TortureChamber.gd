extends Building
class_name TortureChamber

# 刑房 - 转换英雄为怪物

var conversion_rate: float = 2.0 # 转换速度倍率


func _init():
	super._init()
	building_name = "刑房"
	building_type = BuildingTypes.TORTURE_CHAMBER
	max_health = 500
	health = max_health
	armor = 8
	building_size = Vector2(1, 1)
	cost_gold = 400
	engineer_cost = 200
	build_time = 200.0
	engineer_required = 2
	status = BuildingStatus.PLANNING


func _ready():
	super._ready()
	var model_scene = preload("res://img/scenes/buildings/torture_chamber_base.tscn")
	var model = model_scene.instantiate()
	model.name = "Model"
	add_child(model)
