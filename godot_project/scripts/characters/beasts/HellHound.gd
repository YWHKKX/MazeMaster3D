class_name HellHound
extends BeastBase

## 地狱犬 - 死地生态系统高级魔物
## 喷吐地狱火焰，具有极高的移动速度，使用地狱犬牙攻击

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.HELLHOUNDS)
	_init_hellhound_data()

func _init_hellhound_data() -> void:
	var data = CharacterData.new()
	data.character_name = "地狱犬"
	data.creature_type = BeastsTypes.BeastType.HELLHOUND
	data.max_health = 800
	data.attack = 40 # 高攻击力
	data.armor = 6 # 中等防御
	data.speed = 60 # 极高移动速度
	data.size = 18 # 中等体型
	
	# 设置阵营为野兽（中立）
	data.faction = 3 # BeastsTypes.Faction.BEASTS
	
	# 设置行为属性
	data.is_hostile = true
	
	# 设置生态属性
	data.ecosystem_type = EcosystemRegion.EcosystemType.DEAD_LAND
	data.food_chain_level = 3 # 高级消费者
	
	# 设置觅食偏好
	data.preferred_food_types = [ResourceTypes.ResourceType.MAGIC_CRYSTAL, ResourceTypes.ResourceType.HERB]
	
	# 设置捕食行为
	data.is_predator = true
	data.prey_types = [BeastsTypes.BeastType.SHADOW_WOLF, BeastsTypes.BeastType.CORRUPTED_BOAR]
	
	# 设置火焰攻击
	data.hellfire_breath = true # 喷吐地狱火焰
	data.fire_damage = 20 # 火焰伤害
	data.fire_duration = 6.0 # 火焰持续6秒
	data.fire_radius = 12.0 # 火焰半径12米
	
	# 设置撕咬攻击
	data.hell_fang_attack = true # 地狱犬牙攻击
	data.bite_damage_multiplier = 1.3 # 撕咬攻击伤害提升30%
	data.bite_bleeding = true # 撕咬造成流血效果
	data.bleeding_damage = 5 # 流血伤害
	data.bleeding_duration = 8.0 # 流血持续8秒
	
	# 设置快速移动
	data.sprint_ability = true # 冲刺能力
	data.sprint_speed_multiplier = 1.8 # 冲刺时速度提升80%
	data.sprint_duration = 5.0 # 冲刺持续5秒
	data.sprint_cooldown = 10.0 # 冲刺冷却10秒
	
	# 设置适应能力
	data.deadland_adaptation = true # 适应死地环境
	data.fire_immunity = 0.8 # 80%火焰免疫
	data.magic_immunity = 0.4 # 40%魔法免疫
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "高级魔物，喷吐地狱火焰，具有极高的移动速度，使用地狱犬牙攻击。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "死地生态系统 - 高级消费者 - 火焰攻击，快速移动，撕咬攻击"
