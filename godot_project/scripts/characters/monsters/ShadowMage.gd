class_name ShadowMage
extends MonsterBase

## 暗影法师 - 魔法攻击，具有穿透效果
## 战斗等级: ⭐⭐⭐
## [已迁移] 从旧的 Monster 基类迁移到新的 MonsterBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_shadow_mage_data()
	is_combat_unit = true
	add_to_group(GameGroups.MONSTERS)
	add_to_group(GameGroups.SHADOW_MAGES)

func _init_shadow_mage_data() -> void:
	var data = CharacterData.new()
	data.character_name = "暗影法师"
	data.creature_type = MonstersTypes.MonsterType.SHADOW_MAGE
	data.max_health = 900
	data.attack = 22
	data.armor = 2
	data.speed = 40
	data.size = 16
	data.attack_range = 10.0 # 远程魔法
	data.attack_cooldown = 2.5
	data.detection_range = Constants.SEARCH_RANGE_SHADOW_MAGE
	data.cost_gold = GameBalance.SHADOW_MAGE_COST
	data.upkeep = GameBalance.SHADOW_MAGE_UPKEEP
	data.attack_type = CombatTypes.AttackType.MAGIC
	data.damage_type = CombatTypes.DamageType.MAGICAL
	character_data = data
	_init_from_character_data()
