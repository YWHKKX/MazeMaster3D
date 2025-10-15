extends HeroBase
class_name Mage

## 法师 - 高伤害但脆弱，需要战术配合
## 威胁等级: ⭐⭐ (LOW)
## [已迁移] 从旧的 Hero 基类迁移到新的 HeroBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_mage_data()
	is_combat_unit = true
	add_to_group(GameGroups.HEROES)
	add_to_group("mages")
	
	# 状态机会在HeroBase._ready()中自动创建

func _init_mage_data() -> void:
	var data = CharacterData.new()
	data.character_name = "法师"
	data.creature_type = Enums.CreatureType.MAGE
	data.max_health = 500
	data.attack = 22
	data.armor = 1
	data.speed = 40
	data.size = 16
	data.attack_range = 10.0
	data.attack_cooldown = 2.0
	data.detection_range = 10.0
	data.attack_type = Enums.AttackType.MAGIC
	data.damage_type = Enums.DamageType.MAGICAL
	data.color = Color(0.8, 0.6, 1.0)
	character_data = data
	_init_from_character_data()
