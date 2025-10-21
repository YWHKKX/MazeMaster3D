class_name ShadowWolf
extends BeastBase

## 暗影魔狼 - 死地生态系统初级魔物
## 被魔法力量魔化，具有暗影能力，形成魔狼群

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.SHADOW_WOLVES)
	_init_shadow_wolf_data()

func _init_shadow_wolf_data() -> void:
	var data = CharacterData.new()
	data.character_name = "暗影魔狼"
	data.creature_type = BeastsTypes.BeastType.SHADOW_WOLF
	data.max_health = 600
	data.attack = 25 # 中等攻击力
	data.armor = 4 # 中等防御
	data.speed = 40 # 移动速度
	data.size = 16 # 中等体型
	
	# 应用数据
	character_data = data
	_init_from_character_data()
	
	# 设置野兽特有属性（在BeastBase中定义）
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置

## 获取生物描述
func get_creature_description() -> String:
	return "初级魔物，被魔法力量魔化，具有暗影能力，形成魔狼群，集体狩猎。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "死地生态系统 - 初级消费者 - 魔化特性，暗影攻击，群体狩猎"
