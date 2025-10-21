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
	
	# 设置行为属性
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "高级魔物，喷吐地狱火焰，具有极高的移动速度，使用地狱犬牙攻击。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "死地生态系统 - 高级消费者 - 火焰攻击，快速移动，撕咬攻击"
