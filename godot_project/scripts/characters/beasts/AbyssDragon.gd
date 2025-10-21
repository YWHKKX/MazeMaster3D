class_name AbyssDragon
extends BeastBase

## 深渊魔龙 - 死地生态系统终极统治者
## 控制整个魔化野兽群，释放强大的龙威压制其他生物

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.ABYSS_DRAGONS)
	_init_abyss_dragon_data()

func _init_abyss_dragon_data() -> void:
	var data = CharacterData.new()
	data.character_name = "深渊魔龙"
	data.creature_type = BeastsTypes.BeastType.ABYSS_DRAGON
	data.max_health = 3000
	data.attack = 100 # 极高攻击力
	data.armor = 20 # 极高防御
	data.speed = 35 # 移动速度
	data.size = 40 # 巨型单位
	
	# 设置行为属性
	data.can_fly = true # 飞行能力
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "终极统治者，控制整个魔化野兽群，释放强大的龙威压制其他生物，使用深渊魔法。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "死地生态系统 - 终极统治者 - 龙威压制，深渊魔法，统治所有魔化野兽"
