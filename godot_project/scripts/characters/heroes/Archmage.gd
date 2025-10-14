extends HeroBase
class_name Archmage

## 大法师 - 范围魔法攻击，适合群体作战
## 威胁等级: ⭐⭐⭐ (MEDIUM)
## [已迁移] 从旧的 Hero 基类迁移到新的 HeroBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_archmage_data()
	is_combat_unit = true
	add_to_group(GameGroups.HEROES)
	add_to_group("archmages")

func _init_archmage_data() -> void:
	var data = CharacterData.new()
	data.character_name = "大法师"
	data.creature_type = Enums.CreatureType.ARCHMAGE
	data.max_health = 800
	data.attack = 35
	data.armor = 2
	data.speed = 38
	data.size = 18
	data.attack_range = 12.0
	data.attack_cooldown = 2.5
	data.detection_range = 12.0
	data.attack_type = Enums.AttackType.AREA
	data.damage_type = Enums.DamageType.MAGICAL
	data.color = Color(0.6, 0.4, 1.0)
	character_data = data
	_init_from_character_data()
