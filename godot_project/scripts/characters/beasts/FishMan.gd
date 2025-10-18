extends BeastBase
class_name FishMan

## 鱼人 - 湖泊中的智慧生物
## 阵营: 野兽阵营（中立）
## 特点: 攻击性，水陆两栖，有一定智慧

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_fish_man_data()
	
	# 鱼人是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.FISH_MEN)
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_fish_man_data() -> void:
	var data = CharacterData.new()
	data.character_name = "鱼人"
	data.creature_type = BeastsTypes.BeastType.FISH_MAN
	data.max_health = 700
	data.attack = 35
	data.armor = 3
	data.speed = 40 # 水陆两栖速度
	data.size = 18
	data.attack_range = 3.5
	data.attack_cooldown = 1.5
	data.detection_range = 10.0
	data.color = Color(0.1, 0.6, 0.5) # 青绿色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 10.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 1.1 # 适度活跃
