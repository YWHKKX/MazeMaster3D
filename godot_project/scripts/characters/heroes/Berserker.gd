extends HeroBase
class_name Berserker

## 狂战士 - 极高攻击力，适合正面冲锋
## 威胁等级: ⭐⭐⭐ (MEDIUM)
## [已迁移] 从旧的 Hero 基类迁移到新的 HeroBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_berserker_data()
	is_combat_unit = true
	add_to_group(GameGroups.HEROES)
	add_to_group(GameGroups.BERSERKERS)

func _init_berserker_data() -> void:
	var data = CharacterData.new()
	data.character_name = "狂战士"
	data.creature_type = HeroesTypes.HeroType.BERSERKER
	data.max_health = 1200
	data.attack = 42
	data.armor = 3
	data.speed = 49
	data.size = 21
	data.attack_range = 3.0
	data.attack_cooldown = 0.8
	data.detection_range = 7.5
	data.color = Color(1.0, 0.3, 0.3)
	character_data = data
	_init_from_character_data()
