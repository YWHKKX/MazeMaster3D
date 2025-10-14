extends HeroBase
class_name Knight

## 骑士 - 平衡型战士，适合新手使用
## 威胁等级: ⭐⭐ (LOW)
## [已迁移] 从旧的 Hero 基类迁移到新的 HeroBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_knight_data()
	is_combat_unit = true
	add_to_group(GameGroups.HEROES)
	add_to_group("knights")

func _init_knight_data() -> void:
	var data = CharacterData.new()
	data.character_name = "骑士"
	data.creature_type = Enums.CreatureType.KNIGHT
	data.max_health = 900
	data.attack = 18
	data.armor = 5
	data.speed = 42
	data.size = 18
	data.attack_range = 3.5
	data.attack_cooldown = 1.2
	data.detection_range = 8.8
	data.color = Color(0.7, 0.7, 1.0)
	character_data = data
	_init_from_character_data()
