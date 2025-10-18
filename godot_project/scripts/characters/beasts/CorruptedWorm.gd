class_name CorruptedWorm
extends BeastBase

## 腐化蠕虫 - 荒地生态系统变异生物
## 具有腐蚀性体液，在地下挖掘隧道

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.CORRUPTED_WORMS)
	_init_corrupted_worm_data()

func _init_corrupted_worm_data() -> void:
	var data = CharacterData.new()
	data.character_name = "腐化蠕虫"
	data.creature_type = BeastsTypes.BeastType.CORRUPTED_WORM
	data.max_health = 500
	data.attack = 12 # 低攻击力
	data.armor = 3 # 低防御
	data.speed = 20 # 移动速度较慢
	data.size = 14 # 中等体型
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.WASTELAND
	data.food_chain_level = 1 # 初级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.STONE]
	
	# 设置腐化特性
	data.corruption_attack = true # 腐蚀性体液攻击
	data.corruption_damage = 6 # 腐蚀伤害
	data.corruption_duration = 4.0 # 腐蚀持续4秒
	data.corruption_resistance = 0.7 # 70%腐化抗性
	
	# 设置挖掘能力
	data.burrowing_ability = true # 挖掘能力
	data.burrow_depth = 5.0 # 可以挖掘5米深
	data.underground_movement = true # 地下移动
	data.tunnel_creation = true # 创建隧道
	
	# 设置适应能力
	data.wasteland_adaptation = true # 适应荒地环境
	data.corruption_immunity = 0.5 # 50%腐化免疫
	
	# 设置群体行为
	data.group_size = 8 # 群体行为
	data.group_behavior = true
	
	# 设置逃避行为
	data.flee_distance = 8.0 # 受到威胁时逃跑距离
	data.underground_flee = true # 可以钻入地下逃跑
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "变异生物，具有腐蚀性体液，在地下挖掘隧道，适应辐射和腐化环境。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "荒地生态系统 - 初级消费者 - 腐化攻击，地下挖掘，适应恶劣环境"
