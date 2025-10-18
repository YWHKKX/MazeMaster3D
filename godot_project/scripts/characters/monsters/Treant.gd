class_name Treant
extends MonsterBase

## 树人守护者 - 防守专家，具有控制能力
## 战斗等级: ⭐⭐⭐⭐
## [已迁移] 从旧的 Monster 基类迁移到新的 MonsterBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_treant_data()
	is_combat_unit = true
	add_to_group(GameGroups.MONSTERS)
	add_to_group(GameGroups.TREANTS)

func _init_treant_data() -> void:
	var data = CharacterData.new()
	data.character_name = "树人守护者"
	data.creature_type = MonstersTypes.MonsterType.TREANT
	data.max_health = 2000
	data.attack = 35
	data.armor = 10
	data.speed = 32
	data.size = 22 # 大型单位
	data.attack_range = 4.0
	data.attack_cooldown = 2.0
	data.detection_range = Constants.SEARCH_RANGE_TREE_GUARDIAN
	data.cost_gold = GameBalance.TREANT_COST
	data.upkeep = GameBalance.TREANT_UPKEEP
	character_data = data
	_init_from_character_data()
