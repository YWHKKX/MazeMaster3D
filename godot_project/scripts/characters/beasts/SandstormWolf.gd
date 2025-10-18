class_name SandstormWolf
extends BeastBase

## 沙暴狼 - 荒地生态系统沙漠生物
## 具有制造沙暴掩护攻击的能力，群体狩猎

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.SANDSTORM_WOLVES)
	_init_sandstorm_wolf_data()

func _init_sandstorm_wolf_data() -> void:
	var data = CharacterData.new()
	data.character_name = "沙暴狼"
	data.creature_type = BeastsTypes.BeastType.SANDSTORM_WOLF
	data.max_health = 700
	data.attack = 30 # 中等攻击力
	data.armor = 5 # 中等防御
	data.speed = 45 # 移动速度
	data.size = 18 # 中等体型
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.WASTELAND
	data.food_chain_level = 2 # 中级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.RARE_MINERAL]
	
	# 设置捕食行为
	data.is_predator = true
	data.prey_types = [BeastsTypes.BeastType.MUTANT_RAT, BeastsTypes.BeastType.CORRUPTED_WORM,
					   BeastsTypes.BeastType.RADIOACTIVE_SCORPION]
	
	# 设置沙暴能力
	data.sandstorm_ability = true # 制造沙暴掩护攻击
	data.sandstorm_duration = 8.0 # 沙暴持续8秒
	data.sandstorm_radius = 25.0 # 沙暴半径25米
	data.sandstorm_damage_bonus = 0.3 # 沙暴中攻击力提升30%
	
	# 设置群体行为
	data.group_size = 6 # 群体狩猎
	data.group_behavior = true
	data.pack_hunting = true # 群体狩猎行为
	
	# 设置适应能力
	data.wasteland_adaptation = true # 适应荒地环境
	data.desert_adaptation = true # 适应沙漠环境
	data.heat_resistance = 0.8 # 80%高温抗性
	
	# 设置领地行为
	data.territory_size = 40.0 # 守卫沙漠区域
	data.territory_behavior = true
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "沙漠生物，具有制造沙暴掩护攻击的能力，群体狩猎，适应荒地环境。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "荒地生态系统 - 中级消费者 - 沙暴攻击，群体狩猎，适应沙漠环境"
