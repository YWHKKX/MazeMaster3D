extends BeastBase
class_name CaveBat

## 洞穴蝙蝠 - 洞穴中的飞行掠食者
## 阵营: 野兽阵营（中立）
## 特点: 飞行优势，群体狩猎，维持洞穴生态平衡

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_cave_bat_data()
	
	# 洞穴蝙蝠是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.CAVE_BATS)
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_cave_bat_data() -> void:
	var data = CharacterData.new()
	data.character_name = "洞穴蝙蝠"
	data.creature_type = BeastsTypes.BeastType.CAVE_BAT
	data.max_health = 300
	data.attack = 50 # 中等攻击力
	data.armor = 10
	data.speed = 90 # 极快
	data.size = 6
	data.attack_range = 3.0
	data.attack_cooldown = 0.8
	data.detection_range = 15.0
	data.color = Color(0.2, 0.2, 0.2) # 深灰色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 15.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 1.5 # 极快飞行

## 飞行优势 - 在空中追击猎物
func aerial_advantage() -> void:
	# 飞行优势，可以避开地面障碍
	pass

## 群体狩猎 - 群体狩猎行为
func swarm_hunting() -> void:
	# 群体狩猎，多个蝙蝠协同攻击
	pass
