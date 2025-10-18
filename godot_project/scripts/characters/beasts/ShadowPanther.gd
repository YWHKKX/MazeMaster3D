class_name ShadowPanther
extends BeastBase

## 暗影魔豹 - 死地生态系统顶级魔物
## 在阴影中潜行攻击，使用暗影魔法攻击，统治中低级魔物

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.SHADOW_PANTHERS)
	_init_shadow_panther_data()

func _init_shadow_panther_data() -> void:
	var data = CharacterData.new()
	data.character_name = "暗影魔豹"
	data.creature_type = BeastsTypes.BeastType.SHADOW_PANTHER
	data.max_health = 1200
	data.attack = 55 # 极高攻击力
	data.armor = 10 # 高防御
	data.speed = 45 # 移动速度
	data.size = 25 # 大型体型
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.DEAD_LAND
	data.food_chain_level = 4 # 顶级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.MAGIC_CRYSTAL, ResourceTypes.ResourceType.HERB]
	
	# 设置捕食行为
	data.is_predator = true
	data.prey_types = [BeastsTypes.BeastType.MAGIC_VULTURE, BeastsTypes.BeastType.HELLHOUND]
	
	# 设置暗影潜行
	data.shadow_stealth = true # 在阴影中潜行攻击
	data.stealth_damage_multiplier = 2.0 # 潜行攻击伤害翻倍
	data.stealth_duration = 8.0 # 潜行持续8秒
	data.stealth_cooldown = 15.0 # 潜行冷却15秒
	
	# 设置暗影魔法攻击
	data.shadow_magic_attack = true # 暗影魔法攻击
	data.shadow_magic_damage = 25 # 暗影魔法伤害
	data.shadow_magic_duration = 5.0 # 暗影魔法持续5秒
	data.shadow_magic_radius = 15.0 # 暗影魔法半径15米
	
	# 设置统治行为
	data.dominance_level = 4 # 统治等级4
	data.territory_size = 60.0 # 守卫死地核心区域
	data.territory_behavior = true
	data.control_lower_creatures = true # 控制中低级魔物
	
	# 设置适应能力
	data.deadland_adaptation = true # 适应死地环境
	data.shadow_immunity = 0.9 # 90%暗影免疫
	data.magic_immunity = 0.6 # 60%魔法免疫
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "顶级魔物，在阴影中潜行攻击，使用暗影魔法攻击，统治中低级魔物，守卫死地核心区域。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "死地生态系统 - 顶级消费者 - 暗影潜行，魔法攻击，统治行为"
