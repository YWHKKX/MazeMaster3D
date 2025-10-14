extends Building
class_name Workshop

# 工坊 - 制造陷阱和装备

var trap_production_rate: float = 1.0 # 陷阱生产速率
var current_production: String = ""


func _init():
	super._init()
	building_name = "工坊"
	building_type = BuildingTypes.WORKSHOP
	max_health = 350
	health = max_health
	armor = 7
	building_size = Vector2(1, 1)
	cost_gold = 300
	engineer_cost = 150
	build_time = 180.0
	engineer_required = 2
	status = BuildingStatus.PLANNING


func _ready():
	super._ready()
	var model_scene = preload("res://img/scenes/buildings/workshop_base.tscn")
	var model = model_scene.instantiate()
	model.name = "Model"
	add_child(model)
