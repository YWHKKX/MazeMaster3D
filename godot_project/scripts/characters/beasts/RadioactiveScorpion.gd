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
	
	# 应用数据
	character_data = data
	_init_from_character_data()
	
	# 设置野兽特有属性（在BeastBase中定义）
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置

## 获取生物描述
func get_creature_description() -> String:
	return "变异生物，具有辐射抗性和辐射毒素攻击能力，完全适应荒地环境，隐藏在荒地缝隙中伏击猎物。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "荒地生态系统 - 次级消费者 - 辐射攻击，捕食变异老鼠和腐化蠕虫"
