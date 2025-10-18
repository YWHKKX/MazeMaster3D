class_name ScaleArmorBeast
extends BeastBase

## 鳞甲龙 - 原始生态系统杂食恐龙
## 坚硬的鳞片提供强大防御，适应多种食物来源

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.SCALE_ARMOR_BEASTS)
	_init_scale_armor_beast_data()

func _init_scale_armor_beast_data() -> void:
	var data = CharacterData.new()
	data.character_name = "鳞甲龙"
	data.creature_type = BeastsTypes.BeastType.SCALE_ARMOR_DRAGON
	data.max_health = 1800
	data.attack = 45 # 高攻击力
	data.armor = 15 # 极高防御
	data.speed = 35 # 移动速度
	data.size = 32 # 大型体型
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.DEAD_LAND
	data.food_chain_level = 2 # 次级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM]
	
	# 设置捕食行为
	data.is_predator = true
	data.prey_types = [BeastsTypes.BeastType.HORN_SHIELD_DRAGON, BeastsTypes.BeastType.SPINE_BACK_DRAGON]
	
	# 设置鳞甲防御
	data.scale_armor = true # 鳞甲防御
	data.armor_bonus = 0.6 # 防御力提升60%
	data.scale_reflection = true # 鳞片反射攻击
	data.reflection_damage = 10 # 反射伤害
	
	# 设置杂食适应
	data.omnivore_adaptation = true # 杂食适应
	data.food_versatility = 0.8 # 80%食物适应性
	
	# 设置竞争行为
	data.territory_competition = true # 与其他鳞甲龙竞争领地
	data.territory_size = 50.0 # 领地大小50米
	data.territory_behavior = true
	
	# 设置适应能力
	data.primitive_adaptation = true # 适应原始环境
	data.versatile_feeding = true # 多样化觅食
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "杂食恐龙，坚硬的鳞片提供强大防御，适应多种食物来源，与其他鳞甲龙竞争领地。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "原始生态系统 - 次级消费者 - 鳞甲防御，杂食适应，领地竞争"
