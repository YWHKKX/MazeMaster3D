class_name Plankton
extends BeastBase

## 浮游生物 - 湖泊生态系统微型食草动物
## 以浮游植物和藻类为食，是湖泊食物链的最基础环节

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.PLANKTON)
	_init_plankton_data()

func _init_plankton_data() -> void:
	var data = CharacterData.new()
	data.character_name = "浮游生物"
	data.creature_type = BeastsTypes.BeastType.PLANKTON
	data.max_health = 50 # 极低血量
	data.attack = 1 # 无攻击力
	data.armor = 0 # 无防御
	data.speed = 15 # 极慢移动
	data.size = 2 # 微型生物
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	data.is_aquatic = true # 水生动物
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.LAKE
	data.food_chain_level = 1 # 初级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.AQUATIC_PLANT, ResourceTypes.ResourceType.FOOD]
	
	# 设置群体行为
	data.group_size = 20 # 形成大型浮游生物群
	data.group_behavior = true
	
	# 设置逃避行为
	data.flee_distance = 8.0 # 受到威胁时逃跑距离
	data.flee_speed_multiplier = 2.0 # 逃跑时速度大幅提升
	
	# 设置游泳能力
	data.swim_speed = data.speed * 1.5 # 游泳比陆地移动快
	data.dive_depth = 10.0 # 可以潜水到10米深
	
	# 设置浮游特性
	data.is_plankton = true # 浮游生物特性
	data.surface_dwelling = true # 主要在水面活动
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "微型浮游生物，以浮游植物和藻类为食，形成密集的浮游生物群，为整个湖泊食物链提供基础营养。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "湖泊生态系统 - 初级消费者 - 以浮游植物为食，是湖泊食物链的最基础环节"
