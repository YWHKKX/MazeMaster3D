extends HeroBase
class_name Ranger

## 游侠 - 超远射程，适合风筝战术
## 威胁等级: ⭐⭐⭐ (MEDIUM)
## [已迁移] 从旧的 Hero 基类迁移到新的 HeroBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_ranger_data()
	is_combat_unit = true
	add_to_group(GameGroups.HEROES)
	add_to_group("rangers")

func _init_ranger_data() -> void:
	var data = CharacterData.new()
	data.character_name = "游侠"
	data.creature_type = Enums.CreatureType.RANGER
	data.max_health = 1000
	data.attack = 25
	data.armor = 4
	data.speed = 43
	data.size = 17
	data.attack_range = 15.0
	data.attack_cooldown = 1.2
	data.detection_range = 15.0
	data.attack_type = Enums.AttackType.RANGED
	data.color = Color(0.4, 0.6, 0.3)
	character_data = data
	_init_from_character_data()
