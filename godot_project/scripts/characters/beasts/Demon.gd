extends BeastBase
class_name Demon

## 恶魔 - 死地中的高等亡灵生物
## 阵营: 野兽阵营（中立）
## 特点: 攻击性，强大的魔法能力，邪恶存在

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_demon_data()
	
	# 恶魔是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group("demons")
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_demon_data() -> void:
	var data = CharacterData.new()
	data.character_name = "恶魔"
	data.creature_type = Enums.CreatureType.DEMON
	data.max_health = 1000  # 血量很高
	data.attack = 60        # 攻击力很强
	data.armor = 4
	data.speed = 45
	data.size = 25
	data.attack_range = 5.0
	data.attack_cooldown = 1.5
	data.detection_range = 12.0
	data.color = Color(0.6, 0.1, 0.1)  # 深红色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 12.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 1.0  # 正常移动
