extends Building
class_name Prison

# 监狱 - 俘虏关押

var max_prisoners: int = 4
var current_prisoners: Array = []


func _init():
	super._init()
	building_name = "监狱"
	building_type = BuildingTypes.PRISON
	max_health = 400
	health = max_health
	armor = 7
	building_size = Vector2(1, 1)
	cost_gold = 200
	engineer_cost = 100
	build_time = 100.0
	engineer_required = 1
	status = BuildingStatus.PLANNING


func _ready():
	super._ready()
	var model_scene = preload("res://img/scenes/buildings/prison_base.tscn")
	var model = model_scene.instantiate()
	model.name = "Model"
	add_child(model)
