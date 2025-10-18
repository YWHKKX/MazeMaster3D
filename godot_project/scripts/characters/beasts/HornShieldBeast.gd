class_name HornShieldBeast
extends BeastBase

## 角盾龙 - 原始生态系统食草恐龙
## 使用头部巨角和盾状鳞片防御，形成防御性族群

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.HORN_SHIELD_BEASTS)
	_init_horn_shield_beast_data()

func _init_horn_shield_beast_data() -> void:
	var data = CharacterData.new()
	data.character_name = "角盾龙"
	data.creature_type = BeastsTypes.BeastType.HORN_SHIELD_DRAGON
	data.max_health = 1500
	data.attack = 30 # 中等攻击力
	data.armor = 12 # 高防御
	data.speed = 25 # 移动速度较慢
	data.size = 30 # 大型体型
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.DEAD_LAND
	data.food_chain_level = 1 # 初级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM]
	
	# 设置角盾防御
	data.horn_shield_defense = true # 角盾防御
	data.defense_bonus = 0.5 # 防御力提升50%
	data.horn_attack = true # 角攻击
	data.horn_damage_multiplier = 1.4 # 角攻击伤害提升40%
	
	# 设置群体行为
	data.group_size = 10 # 形成防御性族群
	data.group_behavior = true
	data.defensive_formation = true # 防御阵型
	
	# 设置逃避行为
	data.flee_distance = 20.0 # 受到威胁时逃跑距离
	data.flee_speed_multiplier = 1.3 # 逃跑时速度提升30%
	
	# 设置适应能力
	data.primitive_adaptation = true # 适应原始环境
	data.herbivore_specialization = true # 食草特化
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "食草恐龙，使用头部巨角和盾状鳞片防御，形成防御性族群，以原始植物为食。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "原始生态系统 - 初级消费者 - 角盾防御，防御性族群，食草特化"
