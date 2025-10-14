extends HeroBase
class_name DragonKnight

## 龙骑士 - 综合能力极强，适合各种战术
## 威胁等级: ⭐⭐⭐⭐ (HIGH)
## [已迁移] 从旧的 Hero 基类迁移到新的 HeroBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_dragon_knight_data()
	is_combat_unit = true
	add_to_group(GameGroups.HEROES)
	add_to_group("dragon_knights")

func _init_dragon_knight_data() -> void:
	var data = CharacterData.new()
	data.character_name = "龙骑士"
	data.creature_type = Enums.CreatureType.DRAGON_KNIGHT
	data.max_health = 2200
	data.attack = 48
	data.armor = 12
	data.speed = 46
	data.size = 24
	data.attack_range = 4.5
	data.attack_cooldown = 1.8
	data.detection_range = 11.3
	data.attack_type = Enums.AttackType.AREA
	data.color = Color(1.0, 0.6, 0.2)
	character_data = data
	_init_from_character_data()
