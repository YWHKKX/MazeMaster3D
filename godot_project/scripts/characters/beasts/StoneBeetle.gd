extends BeastBase
class_name StoneBeetle

## 石甲虫 - 洞穴中的中型掠食者
## 阵营: 野兽阵营（中立）
## 特点: 甲壳防御，挖掘能力，坚硬的外壳提供保护

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_stone_beetle_data()
	
	# 石甲虫是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.STONE_BEETLES)
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_stone_beetle_data() -> void:
	var data = CharacterData.new()
	data.character_name = "石甲虫"
	data.creature_type = BeastsTypes.BeastType.STONE_BEETLE
	data.max_health = 400
	data.attack = 60 # 中等攻击力
	data.armor = 35 # 高护甲
	data.speed = 40 # 较慢
	data.size = 15
	data.attack_range = 2.0
	data.attack_cooldown = 1.5
	data.detection_range = 8.0
	data.color = Color(0.4, 0.4, 0.4) # 灰色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 8.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 0.8 # 较慢移动

## 甲壳防御 - 坚硬的外壳提供保护
func shell_defense() -> void:
	# 甲壳防御，减少受到的伤害
	var defense_bonus = armor * 0.5
	armor += defense_bonus

## 挖掘能力 - 挖掘洞穴和寻找食物
func dig_ability() -> void:
	# 挖掘能力，可以挖掘洞穴
	pass
