class_name DragonBloodBeast
extends BeastBase

## 龙血兽 - 原始生态系统超级掠食者
## 拥有龙血的力量，使用龙息攻击，统治大片原始领地

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.DRAGON_BLOOD_BEASTS)
	_init_dragon_blood_beast_data()

func _init_dragon_blood_beast_data() -> void:
	var data = CharacterData.new()
	data.character_name = "龙血兽"
	data.creature_type = BeastsTypes.BeastType.DRAGON_BLOOD_BEAST
	data.max_health = 2500
	data.attack = 80 # 极高攻击力
	data.armor = 18 # 极高防御
	data.speed = 35 # 移动速度
	data.size = 38 # 巨型体型
	
	# 设置行为属性
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "超级掠食者，拥有龙血的力量，使用龙息攻击，统治大片原始领地。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "原始生态系统 - 顶级掠食者 - 龙血力量，龙息攻击，统治行为"
