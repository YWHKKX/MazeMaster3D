extends HeroBase
class_name Priest

## 牧师 - 辅助型角色，提供治疗支持
## 威胁等级: ⭐⭐ (LOW)
## [已迁移] 从旧的 Hero 基类迁移到新的 HeroBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_priest_data()
	is_combat_unit = true
	add_to_group(GameGroups.HEROES)
	add_to_group(GameGroups.PRIESTS)

func _init_priest_data() -> void:
	var data = CharacterData.new()
	data.character_name = "牧师"
	data.creature_type = HeroesTypes.HeroType.PRIEST
	data.max_health = 800
	data.attack = 10
	data.armor = 3
	data.speed = 40
	data.size = 16
	data.attack_range = 8.0
	data.attack_cooldown = 1.5
	data.detection_range = 8.0
	data.attack_type = CombatTypes.AttackType.MAGIC
	data.color = Color(1.0, 1.0, 0.9)
	character_data = data
	_init_from_character_data()
