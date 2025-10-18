extends HeroBase
class_name Archer

## 弓箭手 - 远程输出，需要保护
## 威胁等级: ⭐⭐ (LOW)
## [已迁移] 从旧的 Hero 基类迁移到新的 HeroBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_archer_data()
	is_combat_unit = true
	add_to_group(GameGroups.HEROES)
	add_to_group(GameGroups.ARCHERS)
	
	# 状态机会在HeroBase._ready()中自动创建

func _init_archer_data() -> void:
	var data = CharacterData.new()
	data.character_name = "弓箭手"
	data.creature_type = HeroesTypes.HeroType.ARCHER
	data.max_health = 700
	data.attack = 16
	data.armor = 2
	data.speed = 46
	data.size = 16
	data.attack_range = 12.0
	data.attack_cooldown = 1.0
	data.detection_range = 12.0
	data.attack_type = CombatTypes.AttackType.RANGED
	data.color = Color(0.6, 0.8, 0.6)
	character_data = data
	_init_from_character_data()
