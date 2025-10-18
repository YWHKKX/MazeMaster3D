class_name RadioactiveScorpion
extends BeastBase

## 辐射蝎 - 荒地生态系统变异生物
## 具有辐射抗性和辐射毒素攻击能力

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.RADIOACTIVE_SCORPIONS)
	_init_radioactive_scorpion_data()

func _init_radioactive_scorpion_data() -> void:
	var data = CharacterData.new()
	data.character_name = "辐射蝎"
	data.creature_type = BeastsTypes.BeastType.RADIOACTIVE_SCORPION
	data.max_health = 800
	data.attack = 35 # 高攻击力
	data.armor = 8 # 高防御
	data.speed = 30 # 移动速度
	data.size = 15 # 中等体型
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.WASTELAND
	data.food_chain_level = 2 # 次级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.RARE_MINERAL]
	
	# 设置捕食行为
	data.is_predator = true
	data.prey_types = [BeastsTypes.BeastType.MUTANT_RAT, BeastsTypes.BeastType.CORRUPTED_WORM]
	
	# 设置辐射特性
	data.radiation_resistance = 0.8 # 80%辐射抗性
	data.radiation_attack = true # 辐射毒素攻击
	data.radiation_damage = 10 # 辐射伤害
	data.radiation_duration = 5.0 # 辐射持续5秒
	
	# 设置毒性攻击
	data.poison_attack = true # 毒性攻击
	data.poison_damage = 8 # 毒素伤害
	data.poison_duration = 3.0 # 毒素持续3秒
	
	# 设置潜伏行为
	data.ambush_behavior = true # 隐藏在荒地缝隙中
	data.ambush_duration = 2.0 # 潜伏2秒
	data.ambush_damage_multiplier = 1.3 # 潜伏攻击伤害提升30%
	
	# 设置适应能力
	data.wasteland_adaptation = true # 完全适应荒地环境
	data.heat_resistance = 0.9 # 90%高温抗性
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "变异生物，具有辐射抗性和辐射毒素攻击能力，完全适应荒地环境，隐藏在荒地缝隙中伏击猎物。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "荒地生态系统 - 次级消费者 - 辐射攻击，捕食变异老鼠和腐化蠕虫"
