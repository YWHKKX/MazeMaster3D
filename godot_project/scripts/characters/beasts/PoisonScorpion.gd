extends BeastBase
class_name PoisonScorpion

## 毒刺蝎 - 洞穴中的小型掠食者
## 阵营: 野兽阵营（中立）
## 特点: 毒性攻击，潜伏行为，隐藏在洞穴缝隙中

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_poison_scorpion_data()
	
	# 毒刺蝎是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group("poison_scorpions")
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_poison_scorpion_data() -> void:
	var data = CharacterData.new()
	data.character_name = "毒刺蝎"
	data.creature_type = Enums.CreatureType.POISON_SCORPION
	data.max_health = 200
	data.attack = 45  # 中等攻击力
	data.armor = 15
	data.speed = 55  # 中等速度
	data.size = 8
	data.attack_range = 2.5
	data.attack_cooldown = 1.0
	data.detection_range = 6.0
	data.color = Color(0.3, 0.2, 0.1)  # 深棕色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 6.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 1.0  # 正常速度

## 毒性攻击 - 使用毒刺攻击猎物
func perform_poison_attack() -> void:
	# 毒性攻击，造成持续伤害
	var poison_damage = attack * 0.3
	attack += poison_damage

## 潜伏行为 - 隐藏在洞穴缝隙中
func stealth_behavior() -> void:
	# 潜伏行为，降低被发现的概率
	pass
