extends MonsterBase
class_name ShadowLord

## 暗影领主 - 全能战士，形态切换能力强
## 战斗等级: ⭐⭐⭐⭐⭐
## [已迁移] 从旧的 Monster 基类迁移到新的 MonsterBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_shadow_lord_data()
	is_combat_unit = true
	add_to_group(GameGroups.MONSTERS)
	add_to_group("shadow_lords")

func _init_shadow_lord_data() -> void:
	var data = CharacterData.new()
	data.character_name = "暗影领主"
	data.creature_type = Enums.CreatureType.SHADOW_LORD
	data.max_health = 3200
	data.attack = 55
	data.armor = 12
	data.speed = 46
	data.size = 24 # 大型单位
	data.attack_range = 6.0
	data.attack_cooldown = 1.5
	data.detection_range = Constants.SEARCH_RANGE_SHADOW_LORD
	data.cost_gold = GameBalance.SHADOW_LORD_COST
	data.upkeep = GameBalance.SHADOW_LORD_UPKEEP
	data.damage_type = Enums.DamageType.MAGICAL
	character_data = data
	_init_from_character_data()
