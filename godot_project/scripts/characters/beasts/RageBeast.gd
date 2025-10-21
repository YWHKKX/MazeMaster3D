class_name RageBeast
extends BeastBase

## 暴怒龙 - 原始生态系统掠食恐龙
## 主要捕食鳞甲龙和利爪龙，进入暴怒状态时攻击力翻倍

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.RAGE_BEASTS)
	_init_rage_beast_data()

func _init_rage_beast_data() -> void:
	var data = CharacterData.new()
	data.character_name = "暴怒龙"
	data.creature_type = BeastsTypes.BeastType.RAGE_DRAGON
	data.max_health = 2000
	data.attack = 60 # 高攻击力
	data.armor = 12 # 高防御
	data.speed = 40 # 移动速度
	data.size = 35 # 大型体型
	
	# 设置行为属性
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置
	data.roar_radius = 30.0 # 咆哮半径30米
	data.roar_damage = 15 # 咆哮伤害
	data.roar_duration = 5.0 # 咆哮持续5秒
	
	# 设置适应能力
	data.primitive_adaptation = true # 适应原始环境
	data.predator_specialization = true # 掠食者特化
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "掠食恐龙，主要捕食鳞甲龙和利爪龙，进入暴怒状态时攻击力翻倍，通过咆哮威慑其他生物。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "原始生态系统 - 高级消费者 - 暴怒状态，领地行为，威慑咆哮"
