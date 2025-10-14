extends HeroBase
class_name ShadowBladeMaster

## 暗影剑圣 - 最高攻击力，适合高端操作
## 威胁等级: ⭐⭐⭐⭐⭐ (VERY_HIGH)
## [已迁移] 从旧的 Hero 基类迁移到新的 HeroBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_shadow_blade_master_data()
	is_combat_unit = true
	add_to_group(GameGroups.HEROES)
	add_to_group("shadow_blade_masters")

func _init_shadow_blade_master_data() -> void:
	var data = CharacterData.new()
	data.character_name = "暗影剑圣"
	data.creature_type = Enums.CreatureType.SHADOW_BLADE_MASTER
	data.max_health = 1400
	data.attack = 58
	data.armor = 8
	data.speed = 51
	data.size = 19
	data.attack_range = 3.5
	data.attack_cooldown = 1.0
	data.detection_range = 8.8
	data.color = Color(0.2, 0.1, 0.3)
	character_data = data
	_init_from_character_data()
