extends HeroBase
class_name Assassin

## 刺客 - 极高攻击力，适合暗杀战术
## 威胁等级: ⭐⭐⭐ (MEDIUM)
## [已迁移] 从旧的 Hero 基类迁移到新的 HeroBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_assassin_data()
	is_combat_unit = true
	add_to_group(GameGroups.HEROES)
	add_to_group(GameGroups.ASSASSINS)
	
	# 状态机会在HeroBase._ready()中自动创建

func _init_assassin_data() -> void:
	var data = CharacterData.new()
	data.character_name = "刺客"
	data.creature_type = HeroesTypes.HeroType.ASSASSIN
	data.max_health = 900
	data.attack = 38
	data.armor = 3
	data.speed = 56
	data.size = 16 # 🔧 从15增加到16，确保模型清晰可见
	data.attack_range = 2.5
	data.attack_cooldown = 0.8
	data.detection_range = 6.3
	data.color = Color(0.3, 0.1, 0.3)
	character_data = data
	_init_from_character_data()
