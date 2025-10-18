extends BeastBase
class_name Zombie

## 僵尸 - 死地中的亡灵生物
## 阵营: 野兽阵营（中立）
## 特点: 攻击性，缓慢但坚韧，感染能力

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_zombie_data()
	
	# 僵尸是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.ZOMBIES)
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_zombie_data() -> void:
	var data = CharacterData.new()
	data.character_name = "僵尸"
	data.creature_type = BeastsTypes.BeastType.ZOMBIE
	data.max_health = 800 # 血量较高
	data.attack = 30
	data.armor = 2
	data.speed = 20 # 移动很慢
	data.size = 20
	data.attack_range = 3.0
	data.attack_cooldown = 2.5
	data.detection_range = 6.0
	data.color = Color(0.3, 0.5, 0.3) # 灰绿色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 6.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 0.5 # 非常缓慢
