class_name ShadowWolf
extends BeastBase

## 暗影魔狼 - 死地生态系统初级魔物
## 被魔法力量魔化，具有暗影能力，形成魔狼群

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.SHADOW_WOLVES)
	_init_shadow_wolf_data()

func _init_shadow_wolf_data() -> void:
	var data = CharacterData.new()
	data.character_name = "暗影魔狼"
	data.creature_type = BeastsTypes.BeastType.SHADOW_WOLF
	data.max_health = 600
	data.attack = 25 # 中等攻击力
	data.armor = 4 # 中等防御
	data.speed = 40 # 移动速度
	data.size = 16 # 中等体型
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.DEAD_LAND
	data.food_chain_level = 1 # 初级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.MAGIC_CRYSTAL, ResourceTypes.ResourceType.HERB]
	
	# 设置魔化特性
	data.shadow_ability = true # 暗影能力
	data.shadow_damage = 8 # 暗影伤害
	data.shadow_duration = 3.0 # 暗影持续3秒
	data.magic_resistance = 0.6 # 60%魔法抗性
	
	# 设置群体行为
	data.group_size = 8 # 形成魔狼群
	data.group_behavior = true
	data.pack_hunting = true # 集体狩猎
	
	# 设置潜伏行为
	data.ambush_behavior = true # 潜伏攻击
	data.ambush_duration = 2.5 # 潜伏2.5秒
	data.ambush_damage_multiplier = 1.4 # 潜伏攻击伤害提升40%
	
	# 设置适应能力
	data.deadland_adaptation = true # 适应死地环境
	data.magic_immunity = 0.3 # 30%魔法免疫
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "初级魔物，被魔法力量魔化，具有暗影能力，形成魔狼群，集体狩猎。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "死地生态系统 - 初级消费者 - 魔化特性，暗影攻击，群体狩猎"
