extends BeastBase
class_name ForestWolf

## 森林狼 - 森林中的掠食者
## 阵营: 野兽阵营（中立）
## 特点: 攻击性，但不会主动攻击英雄和怪物

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_forest_wolf_data()
	
	# 森林狼是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.FOREST_WOLVES)
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_forest_wolf_data() -> void:
	var data = CharacterData.new()
	data.character_name = "森林狼"
	data.creature_type = BeastsTypes.BeastType.FOREST_WOLF
	data.max_health = 600
	data.attack = 25
	data.armor = 3
	data.speed = 55
	data.size = 22
	data.attack_range = 3.0
	data.attack_cooldown = 1.2
	data.detection_range = 10.0
	data.color = Color(0.3, 0.3, 0.3) # 灰色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 10.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 1.2 # 活跃地巡逻
