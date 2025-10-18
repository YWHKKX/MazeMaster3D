class_name CorruptedBoar
extends BeastBase

## 腐化野猪 - 死地生态系统次级魔物
## 身体被魔法腐化，具有毒性，使用腐化獠牙进行冲撞攻击

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.CORRUPTED_BOARS)
	_init_corrupted_boar_data()

func _init_corrupted_boar_data() -> void:
	var data = CharacterData.new()
	data.character_name = "腐化野猪"
	data.creature_type = BeastsTypes.BeastType.CORRUPTED_BOAR
	data.max_health = 900
	data.attack = 35 # 高攻击力
	data.armor = 8 # 高防御
	data.speed = 30 # 移动速度
	data.size = 22 # 大型体型
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = false # 野兽阵营中立
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.DEAD_LAND
	data.food_chain_level = 2 # 次级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.MAGIC_CRYSTAL, ResourceTypes.ResourceType.HERB]
	
	# 设置捕食行为
	data.is_predator = true
	data.prey_types = [BeastsTypes.BeastType.SHADOW_WOLF]
	
	# 设置腐化特性
	data.corruption_attack = true # 腐化攻击
	data.corruption_damage = 12 # 腐化伤害
	data.corruption_duration = 5.0 # 腐化持续5秒
	data.corruption_resistance = 0.8 # 80%腐化抗性
	
	# 设置冲撞攻击
	data.charge_attack = true # 冲撞攻击
	data.charge_damage_multiplier = 1.6 # 冲撞攻击伤害提升60%
	data.charge_distance = 15.0 # 冲撞距离15米
	data.charge_cooldown = 8.0 # 冲撞冷却8秒
	
	# 设置防御能力
	data.corrupted_skin = true # 腐化皮肤提供强大防御
	data.defense_bonus = 0.3 # 防御力提升30%
	
	# 设置适应能力
	data.deadland_adaptation = true # 适应死地环境
	data.magic_immunity = 0.4 # 40%魔法免疫
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "次级魔物，身体被魔法腐化，具有毒性，使用腐化獠牙进行冲撞攻击，腐化皮肤提供强大防御。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "死地生态系统 - 次级消费者 - 腐化攻击，冲撞攻击，捕食暗影魔狼"
