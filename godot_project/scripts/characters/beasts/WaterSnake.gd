class_name WaterSnake
extends BeastBase

## 水蛇 - 湖泊生态系统中等掠食者
## 在水中潜伏等待猎物，具有优秀的游泳和潜水能力

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.WATER_SNAKES)
	_init_water_snake_data()

func _init_water_snake_data() -> void:
	var data = CharacterData.new()
	data.character_name = "水蛇"
	data.creature_type = BeastsTypes.BeastType.WATER_SNAKE
	data.max_health = 600
	data.attack = 25 # 中等攻击力
	data.armor = 3
	data.speed = 35 # 游泳速度
	data.size = 12 # 中等体型
	
	# 设置行为属性
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "中等掠食者，在水中潜伏等待猎物，具有优秀的游泳和潜水能力，主要捕食小型鱼类。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "湖泊生态系统 - 次级消费者 - 潜伏攻击小型鱼类，守卫浅水区域"
