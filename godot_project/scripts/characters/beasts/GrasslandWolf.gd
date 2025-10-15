extends BeastBase
class_name GrasslandWolf

## 草原狼 - 草地中的掠食者
## 阵营: 野兽阵营（中立）
## 特点: 攻击性，群体狩猎，速度快

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_grassland_wolf_data()
	
	# 草原狼是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group("grassland_wolves")
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_grassland_wolf_data() -> void:
	var data = CharacterData.new()
	data.character_name = "草原狼"
	data.creature_type = Enums.CreatureType.GRASSLAND_WOLF
	data.max_health = 500
	data.attack = 30
	data.armor = 2
	data.speed = 65        # 比森林狼更快
	data.size = 20
	data.attack_range = 3.0
	data.attack_cooldown = 1.0
	data.detection_range = 12.0
	data.color = Color(0.5, 0.4, 0.2)  # 黄棕色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 12.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 1.3  # 活跃地巡逻
