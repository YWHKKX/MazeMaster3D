class_name WaterGrassFish
extends BeastBase

## 水草鱼 - 湖泊生态系统小型食草动物
## 以水生植物为食，形成小型鱼群，是湖泊食物链的基础

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.WATER_GRASS_FISH)
	_init_water_grass_fish_data()

func _init_water_grass_fish_data() -> void:
	var data = CharacterData.new()
	data.character_name = "水草鱼"
	data.creature_type = BeastsTypes.BeastType.WATER_GRASS_FISH
	data.max_health = 200
	data.attack = 2 # 极低攻击力，主要用于自卫
	data.armor = 1
	data.speed = 40 # 游泳速度适中
	data.size = 8 # 小型鱼类
	
	# 应用数据
	character_data = data
	_init_from_character_data()
	
	# 设置野兽特有属性（在BeastBase中定义）
	flee_distance = 15.0 # 受到威胁时逃跑距离
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置

## 获取生物描述
func get_creature_description() -> String:
	return "小型食草鱼类，以水生植物为食，形成小型鱼群，是湖泊食物链的重要基础。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "湖泊生态系统 - 初级消费者 - 以水生植物为食，为其他水生生物提供食物来源"
