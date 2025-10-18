class_name MutantRat
extends BeastBase

## 变异老鼠 - 荒地生态系统变异生物
## 具有辐射抗性，体型增大，形成老鼠群体

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.MUTANT_RATS)
	_init_mutant_rat_data()

func _init_mutant_rat_data() -> void:
	var data = CharacterData.new()
	data.character_name = "变异老鼠"
	data.creature_type = BeastsTypes.BeastType.MUTANT_RAT
	data.max_health = 400
	data.attack = 8 # 低攻击力
	data.armor = 2 # 低防御
	data.speed = 35 # 移动速度
	data.size = 10 # 中等体型（比普通老鼠大）
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.WASTELAND
	data.food_chain_level = 1 # 初级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.RARE_MINERAL]
	
	# 设置变异特性
	data.radiation_resistance = 0.6 # 60%辐射抗性
	data.mutation_effects = true # 变异效果
	data.increased_size = true # 体型增大
	
	# 设置群体行为
	data.group_size = 12 # 形成大型老鼠群体
	data.group_behavior = true
	data.swarm_behavior = true # 群体行为
	
	# 设置适应能力
	data.wasteland_adaptation = true # 适应荒地环境
	data.radiation_immunity = 0.3 # 30%辐射免疫
	
	# 设置挖掘能力
	data.burrowing_ability = true # 挖掘能力
	data.burrow_depth = 3.0 # 可以挖掘3米深
	data.underground_movement = true # 地下移动
	
	# 设置逃避行为
	data.flee_distance = 12.0 # 受到威胁时逃跑距离
	data.flee_speed_multiplier = 1.8 # 逃跑时速度大幅提升
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "变异生物，具有辐射抗性，体型增大，形成大型老鼠群体，适应恶劣的荒地环境。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "荒地生态系统 - 初级消费者 - 变异特性，群体行为，适应辐射环境"
