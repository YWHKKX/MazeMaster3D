extends BeastBase
class_name GiantRat

## 巨鼠 - 洞穴中的生物
## 阵营: 野兽阵营（中立）
## 特点: 非攻击性，但会偷取食物

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_giant_rat_data()
	
	# 巨鼠是非攻击性生物
	is_aggressive = false
	is_combat_unit = false
	
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.GIANT_RATS)
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_giant_rat_data() -> void:
	var data = CharacterData.new()
	data.character_name = "巨鼠"
	data.creature_type = BeastsTypes.BeastType.GIANT_RAT
	data.max_health = 200
	data.attack = 8
	data.armor = 0
	data.speed = 70 # 跑得很快
	data.size = 12
	data.attack_range = 1.5
	data.attack_cooldown = 1.5
	data.detection_range = 6.0
	data.color = Color(0.4, 0.3, 0.2) # 棕色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 6.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 1.5 # 快速移动
