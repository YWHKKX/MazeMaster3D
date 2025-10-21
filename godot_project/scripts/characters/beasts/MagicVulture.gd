class_name MagicVulture
extends BeastBase

## 魔化秃鹫 - 死地生态系统高级魔物
## 在空中盘旋寻找猎物，使用魔法羽毛攻击，通过接触传播腐化效果

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.MAGIC_VULTURES)
	_init_magic_vulture_data()

func _init_magic_vulture_data() -> void:
	var data = CharacterData.new()
	data.character_name = "魔化秃鹫"
	data.creature_type = BeastsTypes.BeastType.MAGIC_VULTURE
	data.max_health = 700
	data.attack = 30 # 中等攻击力
	data.armor = 5 # 中等防御
	data.speed = 50 # 飞行速度
	data.size = 20 # 大型体型
	
	# 设置行为属性
	data.can_fly = true # 飞行能力
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "高级魔物，在空中盘旋寻找猎物，使用魔法羽毛攻击，通过接触传播腐化效果。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "死地生态系统 - 高级消费者 - 飞行攻击，魔法攻击，腐化传播"
