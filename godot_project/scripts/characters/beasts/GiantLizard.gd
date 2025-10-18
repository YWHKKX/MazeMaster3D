class_name GiantLizard
extends BeastBase

## 巨蜥 - 荒地中的大型掠食者
## 阵营: 野兽阵营（中立）
## 特点: 攻击性，适应恶劣环境，毒性攻击

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_giant_lizard_data()
	
	# 巨蜥是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.GIANT_LIZARDS)
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_giant_lizard_data() -> void:
	var data = CharacterData.new()
	data.character_name = "巨蜥"
	data.creature_type = BeastsTypes.BeastType.GIANT_LIZARD
	data.max_health = 900
	data.attack = 40
	data.armor = 5
	data.speed = 35 # 移动适中
	data.size = 28
	data.attack_range = 4.0
	data.attack_cooldown = 1.8
	data.detection_range = 9.0
	data.color = Color(0.4, 0.6, 0.2) # 黄绿色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 9.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 0.8 # 缓慢但持续移动
