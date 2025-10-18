class_name ShadowDragon
extends BeastBase

## 暗影龙 - 原始生态系统掠食恐龙
## 在阴影中潜行攻击，使用暗影力量攻击，释放恐惧效果

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.SHADOW_DRAGONS)
	_init_shadow_dragon_data()

func _init_shadow_dragon_data() -> void:
	var data = CharacterData.new()
	data.character_name = "暗影龙"
	data.creature_type = BeastsTypes.BeastType.SHADOW_DRAGON
	data.max_health = 1800
	data.attack = 55 # 高攻击力
	data.armor = 10 # 高防御
	data.speed = 45 # 移动速度
	data.size = 33 # 大型体型
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.DEAD_LAND
	data.food_chain_level = 3 # 高级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM]
	
	# 设置捕食行为
	data.is_predator = true
	data.prey_types = [BeastsTypes.BeastType.SCALE_ARMOR_DRAGON, BeastsTypes.BeastType.CLAW_HUNTER_DRAGON]
	
	# 设置暗影潜行
	data.shadow_stealth = true # 在阴影中潜行攻击
	data.stealth_damage_multiplier = 1.8 # 潜行攻击伤害提升80%
	data.stealth_duration = 12.0 # 潜行持续12秒
	data.stealth_cooldown = 20.0 # 潜行冷却20秒
	
	# 设置暗影攻击
	data.shadow_attack = true # 暗影力量攻击
	data.shadow_damage = 20 # 暗影伤害
	data.shadow_duration = 6.0 # 暗影持续6秒
	data.shadow_radius = 20.0 # 暗影半径20米
	
	# 设置恐惧光环
	data.fear_aura = true # 恐惧光环
	data.fear_radius = 25.0 # 恐惧半径25米
	data.fear_duration = 8.0 # 恐惧持续8秒
	data.fear_effect = "paralyze" # 恐惧效果：麻痹
	
	# 设置领地行为
	data.territory_size = 70.0 # 守卫狩猎领地
	data.territory_behavior = true
	data.shadow_territory = true # 阴影领地
	
	# 设置适应能力
	data.primitive_adaptation = true # 适应原始环境
	data.shadow_immunity = 0.8 # 80%暗影免疫
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "掠食恐龙，在阴影中潜行攻击，使用暗影力量攻击，释放恐惧效果。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "原始生态系统 - 高级消费者 - 暗影潜行，暗影攻击，恐惧光环"
