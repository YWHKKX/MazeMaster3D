class_name DragonBloodBeast
extends BeastBase

## 龙血兽 - 原始生态系统超级掠食者
## 拥有龙血的力量，使用龙息攻击，统治大片原始领地

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.DRAGON_BLOOD_BEASTS)
	_init_dragon_blood_beast_data()

func _init_dragon_blood_beast_data() -> void:
	var data = CharacterData.new()
	data.character_name = "龙血兽"
	data.creature_type = BeastsTypes.BeastType.DRAGON_BLOOD_BEAST
	data.max_health = 2500
	data.attack = 80 # 极高攻击力
	data.armor = 18 # 极高防御
	data.speed = 35 # 移动速度
	data.size = 38 # 巨型体型
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.DEAD_LAND
	data.food_chain_level = 4 # 顶级掠食者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM]
	
	# 设置捕食行为
	data.is_predator = true
	data.prey_types = [BeastsTypes.BeastType.RAGE_DRAGON, BeastsTypes.BeastType.SHADOW_DRAGON]
	
	# 设置龙血力量
	data.dragon_blood_power = true # 龙血力量
	data.dragon_blood_damage = 25 # 龙血伤害
	data.dragon_blood_duration = 8.0 # 龙血持续8秒
	data.dragon_blood_healing = 0.1 # 龙血恢复10%血量
	
	# 设置龙息攻击
	data.dragon_breath = true # 龙息攻击
	data.breath_damage = 35 # 龙息伤害
	data.breath_duration = 7.0 # 龙息持续7秒
	data.breath_radius = 25.0 # 龙息半径25米
	data.breath_cooldown = 15.0 # 龙息冷却15秒
	
	# 设置统治行为
	data.territory_size = 120.0 # 统治大片原始领地
	data.territory_behavior = true
	data.dominance_level = 4 # 统治等级4
	data.territory_control = true # 领地控制
	
	# 设置适应能力
	data.primitive_adaptation = true # 适应原始环境
	data.dragon_immunity = 0.7 # 70%龙类免疫
	
	# 设置特殊能力
	data.massive_size = true # 巨大体型
	data.intimidation_aura = true # 威慑光环
	data.intimidation_radius = 40.0 # 威慑半径40米
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "超级掠食者，拥有龙血的力量，使用龙息攻击，统治大片原始领地。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "原始生态系统 - 顶级掠食者 - 龙血力量，龙息攻击，统治行为"
