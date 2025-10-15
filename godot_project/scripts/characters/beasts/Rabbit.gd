extends BeastBase
class_name Rabbit

## 野兔 - 草地中的小型生物
## 阵营: 野兽阵营（中立）
## 特点: 非攻击性，跑得很快，胆小

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_rabbit_data()
	
	# 野兔是非攻击性生物
	is_aggressive = false
	is_combat_unit = false
	
	add_to_group(GameGroups.BEASTS)
	add_to_group("rabbits")
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_rabbit_data() -> void:
	var data = CharacterData.new()
	data.character_name = "野兔"
	data.creature_type = Enums.CreatureType.RABBIT
	data.max_health = 150  # 血量很低
	data.attack = 3        # 攻击力很低
	data.armor = 0
	data.speed = 80        # 跑得很快
	data.size = 8          # 体型很小
	data.attack_range = 1.0
	data.attack_cooldown = 2.0
	data.detection_range = 12.0  # 警觉性很高
	data.color = Color(0.7, 0.6, 0.4)  # 浅棕色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 12.0  # 警觉性很高

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 1.8  # 快速移动，胆小易惊
