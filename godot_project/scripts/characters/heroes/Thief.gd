extends HeroBase
class_name Thief

## 盗贼 - 高攻击速度，适合快速击杀
## 威胁等级: ⭐⭐ (LOW)
## [已迁移] 从旧的 Hero 基类迁移到新的 HeroBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_thief_data()
	is_combat_unit = true
	add_to_group(GameGroups.HEROES)
	add_to_group(GameGroups.THIEVES)

func _init_thief_data() -> void:
	var data = CharacterData.new()
	data.character_name = "盗贼"
	data.creature_type = HeroesTypes.HeroType.THIEF
	data.max_health = 600
	data.attack = 28
	data.armor = 1
	data.speed = 61
	data.size = 16 # 🔧 从14增加到16，确保模型清晰可见
	data.attack_range = 2.5
	data.attack_cooldown = 0.6
	data.detection_range = 6.3
	data.color = Color(0.4, 0.4, 0.4)
	character_data = data
	_init_from_character_data()
