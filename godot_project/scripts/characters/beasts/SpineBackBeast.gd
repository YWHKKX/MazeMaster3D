class_name SpineBackBeast
extends BeastBase

## 棘背龙 - 原始生态系统食草恐龙
## 背部的巨型棘刺威慑敌人，形成警戒性族群

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.SPINE_BACK_BEASTS)
	_init_spine_back_beast_data()

func _init_spine_back_beast_data() -> void:
	var data = CharacterData.new()
	data.character_name = "棘背龙"
	data.creature_type = BeastsTypes.BeastType.SPINE_BACK_DRAGON
	data.max_health = 1200
	data.attack = 25 # 中等攻击力
	data.armor = 10 # 高防御
	data.speed = 30 # 移动速度
	data.size = 28 # 大型体型
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.DEAD_LAND
	data.food_chain_level = 1 # 初级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM]
	
	# 设置棘背威慑
	data.spine_intimidation = true # 棘背威慑
	data.intimidation_radius = 15.0 # 威慑半径15米
	data.spine_attack = true # 棘刺攻击
	data.spine_damage_multiplier = 1.3 # 棘刺攻击伤害提升30%
	
	# 设置群体行为
	data.group_size = 8 # 形成警戒性族群
	data.group_behavior = true
	data.vigilant_formation = true # 警戒阵型
	
	# 设置警戒行为
	data.alert_behavior = true # 警戒行为
	data.alert_radius = 25.0 # 警戒半径25米
	data.alert_duration = 10.0 # 警戒持续10秒
	
	# 设置适应能力
	data.primitive_adaptation = true # 适应原始环境
	data.herbivore_specialization = true # 食草特化
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "食草恐龙，背部的巨型棘刺威慑敌人，形成警戒性族群，时刻保持警戒状态。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "原始生态系统 - 初级消费者 - 棘背威慑，警戒性族群，食草特化"
