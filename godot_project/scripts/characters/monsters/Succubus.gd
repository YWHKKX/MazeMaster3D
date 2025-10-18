class_name Succubus
extends MonsterBase

## 魅魔 - 心智控制，适合战术配合
## 战斗等级: ⭐⭐⭐⭐
## [已迁移] 从旧的 Monster 基类迁移到新的 MonsterBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_succubus_data()
	is_combat_unit = true
	add_to_group(GameGroups.MONSTERS)
	add_to_group(GameGroups.SUCCUBI)

func _init_succubus_data() -> void:
	var data = CharacterData.new()
	data.character_name = "魅魔"
	data.creature_type = MonstersTypes.MonsterType.SUCCUBUS
	data.max_health = 1500
	data.attack = 32
	data.armor = 5
	data.speed = 43
	data.size = 16
	data.attack_range = 7.0
	data.attack_cooldown = 1.8
	data.detection_range = Constants.SEARCH_RANGE_SUCCUBUS
	data.cost_gold = GameBalance.SUCCUBUS_COST
	data.upkeep = GameBalance.SUCCUBUS_UPKEEP
	data.attack_type = CombatTypes.AttackType.MAGIC
	character_data = data
	_init_from_character_data()
