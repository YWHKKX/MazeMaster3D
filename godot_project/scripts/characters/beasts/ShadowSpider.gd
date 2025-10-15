extends BeastBase
class_name ShadowSpider

## 暗影蜘蛛 - 洞穴中的大型掠食者
## 阵营: 野兽阵营（中立）
## 特点: 蛛网陷阱，潜伏行为，控制洞穴昆虫数量

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_shadow_spider_data()
	
	# 暗影蜘蛛是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group("shadow_spiders")
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_shadow_spider_data() -> void:
	var data = CharacterData.new()
	data.character_name = "暗影蜘蛛"
	data.creature_type = Enums.CreatureType.SHADOW_SPIDER
	data.max_health = 600
	data.attack = 70  # 高攻击力
	data.armor = 20
	data.speed = 65  # 快速
	data.size = 25
	data.attack_range = 4.0
	data.attack_cooldown = 1.2
	data.detection_range = 12.0
	data.color = Color(0.1, 0.1, 0.1)  # 黑色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 12.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 1.1  # 快速移动

## 蛛网陷阱 - 设置蛛网捕捉猎物
func create_web_trap() -> void:
	# 设置蛛网陷阱，减缓敌人移动
	pass

## 潜伏行为 - 在洞穴深处潜伏
func deep_stealth() -> void:
	# 在洞穴深处潜伏，等待猎物
	pass
