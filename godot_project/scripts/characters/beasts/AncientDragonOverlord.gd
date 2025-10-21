class_name AncientDragonOverlord
extends BeastBase

## 古龙霸主 - 原始生态系统终极统治者
## 统治整个原始生态系统，释放古龙的强大威压

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.ANCIENT_DRAGON_OVERLORDS)
	_init_ancient_dragon_overlord_data()

func _init_ancient_dragon_overlord_data() -> void:
	var data = CharacterData.new()
	data.character_name = "古龙霸主"
	data.creature_type = BeastsTypes.BeastType.ANCIENT_DRAGON_OVERLORD
	data.max_health = 4000
	data.attack = 120 # 极高攻击力
	data.armor = 25 # 极高防御
	data.speed = 30 # 移动速度
	data.size = 45 # 巨型单位
	
	# 设置行为属性
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "终极统治者，统治整个原始生态系统，释放古龙的强大威压，拥有古龙鳞片的无敌防御。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "原始生态系统 - 终极统治者 - 古龙威压，龙鳞防御，龙魂攻击，统治整个生态系统"
