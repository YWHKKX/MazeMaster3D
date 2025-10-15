extends BeastBase
class_name Deer

## 鹿 - 森林中的和平生物
## 阵营: 野兽阵营（中立）
## 特点: 非攻击性，受到攻击会逃跑

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_deer_data()
	
	# 鹿是非攻击性生物
	is_aggressive = false
	is_combat_unit = false
	
	add_to_group(GameGroups.BEASTS)
	add_to_group("deers")
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_deer_data() -> void:
	var data = CharacterData.new()
	data.character_name = "鹿"
	data.creature_type = Enums.CreatureType.DEER
	data.max_health = 400
	data.attack = 5  # 很低，主要用于自卫
	data.armor = 1
	data.speed = 60  # 跑得很快
	data.size = 20
	data.attack_range = 2.0
	data.attack_cooldown = 2.0
	data.detection_range = 8.0
	data.color = Color(0.6, 0.4, 0.2)  # 棕色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 8.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 0.8  # 悠闲地游荡
