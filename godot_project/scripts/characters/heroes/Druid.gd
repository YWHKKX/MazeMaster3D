extends HeroBase
class_name Druid

## 德鲁伊 - 平衡型法师，具有自然魔法
## 威胁等级: ⭐⭐⭐ (MEDIUM)
## [已迁移] 从旧的 Hero 基类迁移到新的 HeroBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_druid_data()
	is_combat_unit = true
	add_to_group(GameGroups.HEROES)
	add_to_group(GameGroups.DRUIDS)

func _init_druid_data() -> void:
	var data = CharacterData.new()
	data.character_name = "德鲁伊"
	data.creature_type = HeroesTypes.HeroType.DRUID
	data.max_health = 1300
	data.attack = 22
	data.armor = 6
	data.speed = 42
	data.size = 17
	data.attack_range = 8.0
	data.attack_cooldown = 1.8
	data.detection_range = 8.0
	data.attack_type = CombatTypes.AttackType.MAGIC
	data.damage_type = CombatTypes.DamageType.MAGICAL
	data.color = Color(0.3, 0.8, 0.3)
	character_data = data
	_init_from_character_data()
