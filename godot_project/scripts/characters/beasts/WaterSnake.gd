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
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	data.is_aquatic = true # 水生动物
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.LAKE
	data.food_chain_level = 2 # 次级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.AQUATIC_PLANT, ResourceTypes.ResourceType.FOOD]
	
	# 设置捕食行为
	data.is_predator = true
	data.prey_types = [BeastsTypes.BeastType.WATER_GRASS_FISH, BeastsTypes.BeastType.FISH]
	
	# 设置潜伏行为
	data.ambush_behavior = true # 潜伏攻击
	data.ambush_duration = 3.0 # 潜伏3秒
	data.ambush_damage_multiplier = 1.5 # 潜伏攻击伤害提升50%
	
	# 设置游泳能力
	data.swim_speed = data.speed * 1.3 # 游泳比陆地移动快
	data.dive_depth = 15.0 # 可以潜水到15米深
	data.underwater_breathing = true # 可以在水下呼吸
	
	# 设置领地行为
	data.territory_size = 20.0 # 守卫浅水区域
	data.territory_behavior = true
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "中等掠食者，在水中潜伏等待猎物，具有优秀的游泳和潜水能力，主要捕食小型鱼类。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "湖泊生态系统 - 次级消费者 - 潜伏攻击小型鱼类，守卫浅水区域"
