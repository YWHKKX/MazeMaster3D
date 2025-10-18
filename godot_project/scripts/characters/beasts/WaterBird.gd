class_name WaterBird
extends BeastBase

## 水鸟 - 湖泊生态系统飞行掠食者
## 在空中盘旋寻找猎物，具有飞行优势和潜水能力

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.WATER_BIRDS)
	_init_water_bird_data()

func _init_water_bird_data() -> void:
	var data = CharacterData.new()
	data.character_name = "水鸟"
	data.creature_type = BeastsTypes.BeastType.WATER_BIRD
	data.max_health = 500
	data.attack = 20 # 中等攻击力
	data.armor = 2
	data.speed = 60 # 飞行速度
	data.size = 10 # 中等体型
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	data.is_aquatic = true # 水生动物
	data.can_fly = true # 飞行能力
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.LAKE
	data.food_chain_level = 3 # 高级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.AQUATIC_PLANT, ResourceTypes.ResourceType.FOOD]
	
	# 设置捕食行为
	data.is_predator = true
	data.prey_types = [BeastsTypes.BeastType.WATER_GRASS_FISH, BeastsTypes.BeastType.FISH, BeastsTypes.BeastType.WATER_SNAKE]
	
	# 设置飞行行为
	data.flight_height = 10.0 # 飞行高度10米
	data.dive_attack = true # 俯冲攻击
	data.dive_damage_multiplier = 1.3 # 俯冲攻击伤害提升30%
	
	# 设置游泳能力
	data.swim_speed = data.speed * 0.8 # 游泳比飞行慢
	data.dive_depth = 8.0 # 可以潜水到8米深
	
	# 设置群体行为
	data.group_size = 8 # 群体狩猎和栖息
	data.group_behavior = true
	
	# 设置领地行为
	data.territory_size = 30.0 # 守卫湖泊周边区域
	data.territory_behavior = true
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "飞行掠食者，在空中盘旋寻找猎物，具有飞行优势和潜水能力，群体狩猎和栖息。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "湖泊生态系统 - 高级消费者 - 飞行捕食，群体狩猎，守卫湖泊周边区域"
