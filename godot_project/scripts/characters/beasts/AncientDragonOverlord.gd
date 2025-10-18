class_name AncientDragonOverlord
extends BeastBase

## 古龙霸主 - 原始生态系统终极统治者
## 统治整个原始生态系统，释放古龙的强大威压

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.ANCIENT_DRAGON_OVERLORDS)
	_init_ancient_dragon_overlord_data()

func _init_ancient_dragon_overlord_data() -> void:
	var data = CharacterData.new()
	data.character_name = "古龙霸主"
	data.creature_type = BeastsTypes.BeastType.ANCIENT_DRAGON_OVERLORD
	data.max_health = 4000
	data.attack = 120 # 极高攻击力
	data.armor = 25 # 极高防御
	data.speed = 30 # 移动速度
	data.size = 45 # 巨型单位
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.DEAD_LAND
	data.food_chain_level = 5 # 终极统治者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM]
	
	# 设置捕食行为
	data.is_predator = true
	data.prey_types = [BeastsTypes.BeastType.DRAGON_BLOOD_BEAST, BeastsTypes.BeastType.RAGE_DRAGON,
					   BeastsTypes.BeastType.SHADOW_DRAGON]
	
	# 设置古龙威压
	data.ancient_dragon_aura = true # 古龙威压
	data.aura_radius = 80.0 # 威压半径80米
	data.aura_damage = 30 # 威压伤害
	data.aura_duration = 15.0 # 威压持续15秒
	
	# 设置龙鳞防御
	data.dragon_scale_defense = true # 龙鳞防御
	data.defense_bonus = 0.8 # 防御力提升80%
	data.scale_reflection = true # 鳞片反射攻击
	data.reflection_damage = 20 # 反射伤害
	
	# 设置龙魂攻击
	data.dragon_soul_attack = true # 龙魂攻击
	data.soul_damage = 50 # 龙魂伤害
	data.soul_duration = 10.0 # 龙魂持续10秒
	data.soul_radius = 35.0 # 龙魂半径35米
	data.soul_cooldown = 25.0 # 龙魂冷却25秒
	
	# 设置统治行为
	data.territory_size = 300.0 # 控制整个原始世界的领地
	data.territory_behavior = true
	data.dominance_level = 5 # 最高统治等级
	data.ecosystem_control = true # 生态系统控制
	
	# 设置适应能力
	data.primitive_adaptation = true # 适应原始环境
	data.dragon_immunity = 0.95 # 95%龙类免疫
	data.ancient_power = true # 古龙力量
	
	# 设置特殊能力
	data.massive_size = true # 巨大体型
	data.intimidation_aura = true # 威慑光环
	data.intimidation_radius = 150.0 # 威慑半径150米
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "终极统治者，统治整个原始生态系统，释放古龙的强大威压，拥有古龙鳞片的无敌防御。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "原始生态系统 - 终极统治者 - 古龙威压，龙鳞防御，龙魂攻击，统治整个生态系统"
