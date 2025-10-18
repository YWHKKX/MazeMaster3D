class_name LakeMonster
extends BeastBase

## 湖怪 - 湖泊生态系统顶级掠食者
## 统治湖泊深水区域，拥有巨大的体型和力量

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.LAKE_MONSTERS)
	_init_lake_monster_data()

func _init_lake_monster_data() -> void:
	var data = CharacterData.new()
	data.character_name = "湖怪"
	data.creature_type = BeastsTypes.BeastType.LAKE_MONSTER
	data.max_health = 2000
	data.attack = 80 # 极高攻击力
	data.armor = 15 # 高防御
	data.speed = 25 # 移动速度较慢
	data.size = 35 # 大型单位
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	data.is_aquatic = true # 水生动物
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.LAKE
	data.food_chain_level = 4 # 顶级掠食者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.AQUATIC_PLANT, ResourceTypes.ResourceType.FOOD]
	
	# 设置捕食行为
	data.is_predator = true
	data.prey_types = [BeastsTypes.BeastType.WATER_GRASS_FISH, BeastsTypes.BeastType.FISH,
					   BeastsTypes.BeastType.WATER_SNAKE, BeastsTypes.BeastType.WATER_BIRD]
	
	# 设置潜伏行为
	data.ambush_behavior = true # 在深水中潜伏等待猎物
	data.ambush_duration = 5.0 # 潜伏5秒
	data.ambush_damage_multiplier = 2.0 # 潜伏攻击伤害翻倍
	
	# 设置游泳能力
	data.swim_speed = data.speed * 1.5 # 游泳比陆地移动快
	data.dive_depth = 50.0 # 可以潜水到50米深
	data.underwater_breathing = true # 可以在水下呼吸
	
	# 设置统治行为
	data.territory_size = 100.0 # 控制整个湖泊的核心区域
	data.territory_behavior = true
	data.dominance_level = 5 # 最高统治等级
	
	# 设置特殊能力
	data.massive_size = true # 巨大体型
	data.intimidation_aura = true # 威慑光环
	data.intimidation_radius = 30.0 # 威慑半径30米
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "湖泊的终极统治者，拥有巨大的体型和力量，在深水中潜伏等待猎物，控制整个湖泊的核心区域。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "湖泊生态系统 - 顶级掠食者 - 统治深水区域，维持湖泊生态系统的顶级平衡"
