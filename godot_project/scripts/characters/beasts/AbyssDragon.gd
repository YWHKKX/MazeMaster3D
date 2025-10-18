class_name AbyssDragon
extends BeastBase

## 深渊魔龙 - 死地生态系统终极统治者
## 控制整个魔化野兽群，释放强大的龙威压制其他生物

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.ABYSS_DRAGONS)
	_init_abyss_dragon_data()

func _init_abyss_dragon_data() -> void:
	var data = CharacterData.new()
	data.character_name = "深渊魔龙"
	data.creature_type = BeastsTypes.BeastType.ABYSS_DRAGON
	data.max_health = 3000
	data.attack = 100 # 极高攻击力
	data.armor = 20 # 极高防御
	data.speed = 35 # 移动速度
	data.size = 40 # 巨型单位
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	data.can_fly = true # 飞行能力
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.DEAD_LAND
	data.food_chain_level = 5 # 终极统治者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.MAGIC_CRYSTAL, ResourceTypes.ResourceType.HERB]
	
	# 设置捕食行为
	data.is_predator = true
	data.prey_types = [BeastsTypes.BeastType.SHADOW_PANTHER, BeastsTypes.BeastType.MAGIC_VULTURE,
					   BeastsTypes.BeastType.HELLHOUND]
	
	# 设置飞行能力
	data.flight_height = 25.0 # 飞行高度25米
	data.dive_attack = true # 俯冲攻击
	data.dive_damage_multiplier = 2.5 # 俯冲攻击伤害提升150%
	
	# 设置龙威压制
	data.dragon_aura = true # 龙威压制
	data.dragon_aura_radius = 50.0 # 龙威半径50米
	data.dragon_aura_damage = 15 # 龙威伤害
	data.dragon_aura_duration = 10.0 # 龙威持续10秒
	
	# 设置深渊魔法
	data.abyss_magic = true # 深渊魔法
	data.abyss_magic_damage = 40 # 深渊魔法伤害
	data.abyss_magic_duration = 8.0 # 深渊魔法持续8秒
	data.abyss_magic_radius = 30.0 # 深渊魔法半径30米
	
	# 设置统治行为
	data.dominance_level = 5 # 最高统治等级
	data.territory_size = 200.0 # 控制整个死地区域
	data.territory_behavior = true
	data.control_all_creatures = true # 控制所有魔化野兽群
	
	# 设置适应能力
	data.deadland_adaptation = true # 适应死地环境
	data.dragon_immunity = 0.95 # 95%龙类免疫
	data.magic_immunity = 0.8 # 80%魔法免疫
	
	# 设置特殊能力
	data.massive_size = true # 巨大体型
	data.intimidation_aura = true # 威慑光环
	data.intimidation_radius = 100.0 # 威慑半径100米
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "终极统治者，控制整个魔化野兽群，释放强大的龙威压制其他生物，使用深渊魔法。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "死地生态系统 - 终极统治者 - 龙威压制，深渊魔法，统治所有魔化野兽"
