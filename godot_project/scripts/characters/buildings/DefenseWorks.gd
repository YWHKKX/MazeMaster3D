extends Building
class_name DefenseWorks

# 防御工事 - 区域防御

var defense_bonus: float = 0.2 # 20%防御加成
var defense_range: float = 80.0


func _init():
	super._init()
	building_name = "防御工事"
	building_type = BuildingTypes.DEFENSE_WORKS
	max_health = 600
	health = max_health
	armor = 8
	building_size = Vector2(1, 1)
	cost_gold = 180
	engineer_cost = 90
	build_time = 80.0
	engineer_required = 1
	status = BuildingStatus.PLANNING


func _ready():
	super._ready()
	var model_scene = preload("res://img/scenes/buildings/defense_works_base.tscn")
	var model = model_scene.instantiate()
	model.name = "Model"
	add_child(model)
