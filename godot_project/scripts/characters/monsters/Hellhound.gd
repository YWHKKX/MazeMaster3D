class_name Hellhound
extends MonsterBase

## 地狱犬 - 高速猎手，适合追击
## 战斗等级: ⭐⭐⭐
## [已迁移] 从旧的 Monster 基类迁移到新的 MonsterBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_hellhound_data()
	is_combat_unit = true
	add_to_group(GameGroups.MONSTERS)
	add_to_group(GameGroups.HELLHOUNDS)

func _init_hellhound_data() -> void:
	var data = CharacterData.new()
	data.character_name = "地狱犬"
	data.creature_type = MonstersTypes.MonsterType.HELLHOUND
	data.max_health = 1100
	data.attack = 30
	data.armor = 3
	data.speed = 56
	data.size = 17
	data.attack_range = 2.5
	data.attack_cooldown = 0.8
	data.detection_range = Constants.SEARCH_RANGE_HELLHOUND
	data.cost_gold = GameBalance.HELLHOUND_COST
	data.upkeep = GameBalance.HELLHOUND_UPKEEP
	character_data = data
	_init_from_character_data()
