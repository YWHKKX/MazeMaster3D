extends HeroBase
class_name Paladin

## 圣骑士 - 高生命值和护甲，适合坦克角色
## 威胁等级: ⭐⭐⭐ (MEDIUM)
## [已迁移] 从旧的 Hero 基类迁移到新的 HeroBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_paladin_data()
	is_combat_unit = true
	add_to_group(GameGroups.HEROES)
	add_to_group("paladins")
	
	# 状态机会在HeroBase._ready()中自动创建

func _init_paladin_data() -> void:
	var data = CharacterData.new()
	data.character_name = "圣骑士"
	data.creature_type = Enums.CreatureType.PALADIN
	data.max_health = 1600
	data.attack = 28
	data.armor = 10
	data.speed = 37
	data.size = 20
	data.attack_range = 4.0
	data.attack_cooldown = 1.5
	data.detection_range = 10.0
	data.color = Color(1.0, 0.9, 0.6)
	character_data = data
	_init_from_character_data()
