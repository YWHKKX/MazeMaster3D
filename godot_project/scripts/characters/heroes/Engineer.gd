extends HeroBase
class_name HeroEngineer

## 工程师 (英雄) - 建造炮台
## 威胁等级: ⭐⭐⭐ (MEDIUM)
## [已迁移] 从旧的 Hero 基类迁移到新的 HeroBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_engineer_data()
	is_combat_unit = true
	add_to_group(GameGroups.HEROES)
	add_to_group(GameGroups.ENGINEERS)

func _init_engineer_data() -> void:
	var data = CharacterData.new()
	data.character_name = "工程师"
	data.creature_type = HeroesTypes.HeroType.ENGINEER
	data.max_health = 1100
	data.attack = 20
	data.armor = 6
	data.speed = 37
	data.size = 16
	data.attack_range = 6.0
	data.attack_cooldown = 2.0
	data.detection_range = 6.0
	data.attack_type = CombatTypes.AttackType.RANGED
	data.color = Color(0.7, 0.6, 0.4)
	character_data = data
	_init_from_character_data()
