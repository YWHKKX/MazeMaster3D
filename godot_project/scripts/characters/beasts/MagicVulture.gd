class_name MagicVulture
extends BeastBase

## 魔化秃鹫 - 死地生态系统高级魔物
## 在空中盘旋寻找猎物，使用魔法羽毛攻击，通过接触传播腐化效果

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.MAGIC_VULTURES)
	_init_magic_vulture_data()

func _init_magic_vulture_data() -> void:
	var data = CharacterData.new()
	data.character_name = "魔化秃鹫"
	data.creature_type = BeastsTypes.BeastType.MAGIC_VULTURE
	data.max_health = 700
	data.attack = 30 # 中等攻击力
	data.armor = 5 # 中等防御
	data.speed = 50 # 飞行速度
	data.size = 20 # 大型体型
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	data.can_fly = true # 飞行能力
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.DEAD_LAND
	data.food_chain_level = 3 # 高级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.MAGIC_CRYSTAL, ResourceTypes.ResourceType.HERB]
	
	# 设置捕食行为
	data.is_predator = true
	data.prey_types = [BeastsTypes.BeastType.SHADOW_WOLF, BeastsTypes.BeastType.CORRUPTED_BOAR]
	
	# 设置飞行行为
	data.flight_height = 15.0 # 飞行高度15米
	data.dive_attack = true # 俯冲攻击
	data.dive_damage_multiplier = 1.4 # 俯冲攻击伤害提升40%
	
	# 设置魔法攻击
	data.magic_feather_attack = true # 魔法羽毛攻击
	data.magic_damage = 15 # 魔法伤害
	data.magic_duration = 4.0 # 魔法持续4秒
	
	# 设置腐化传播
	data.corruption_spread = true # 通过接触传播腐化效果
	data.corruption_spread_radius = 8.0 # 腐化传播半径8米
	data.corruption_spread_duration = 6.0 # 腐化传播持续6秒
	
	# 设置适应能力
	data.deadland_adaptation = true # 适应死地环境
	data.magic_immunity = 0.5 # 50%魔法免疫
	
	# 设置群体行为
	data.group_size = 4 # 群体栖息
	data.group_behavior = true
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "高级魔物，在空中盘旋寻找猎物，使用魔法羽毛攻击，通过接触传播腐化效果。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "死地生态系统 - 高级消费者 - 飞行攻击，魔法攻击，腐化传播"
