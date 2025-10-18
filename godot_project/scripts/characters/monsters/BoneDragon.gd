class_name BoneDragon
extends MonsterBase

## 骨龙 - 终极武器，具有范围攻击
## 战斗等级: ⭐⭐⭐⭐⭐
## [已迁移] 从旧的 Monster 基类迁移到新的 MonsterBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_bone_dragon_data()
	is_combat_unit = true
	add_to_group(GameGroups.MONSTERS)
	add_to_group(GameGroups.BONE_DRAGONS)

func _init_bone_dragon_data() -> void:
	var data = CharacterData.new()
	data.character_name = "骨龙"
	data.creature_type = MonstersTypes.MonsterType.BONE_DRAGON
	data.max_health = 4000
	data.attack = 60
	data.armor = 18
	data.speed = 51
	data.size = 32 # 超大型单位
	data.attack_range = 5.0
	data.attack_cooldown = 2.0
	data.detection_range = Constants.SEARCH_RANGE_BONE_DRAGON
	data.cost_gold = GameBalance.BONE_DRAGON_COST
	data.upkeep = GameBalance.BONE_DRAGON_UPKEEP
	data.can_fly = true
	data.attack_type = CombatTypes.AttackType.AREA
	character_data = data
	_init_from_character_data()
