class_name ShadowPanther
extends BeastBase

## 暗影魔豹 - 死地生态系统顶级魔物
## 在阴影中潜行攻击，使用暗影魔法攻击，统治中低级魔物

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.SHADOW_PANTHERS)
	_init_shadow_panther_data()

func _init_shadow_panther_data() -> void:
	var data = CharacterData.new()
	data.character_name = "暗影魔豹"
	data.creature_type = BeastsTypes.BeastType.SHADOW_PANTHER
	data.max_health = 1200
	data.attack = 55 # 极高攻击力
	data.armor = 10 # 高防御
	data.speed = 45 # 移动速度
	data.size = 25 # 大型体型
	
	# 应用数据
	character_data = data
	_init_from_character_data()
	
	# 设置野兽特有属性（在BeastBase中定义）
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置

## 获取生物描述
func get_creature_description() -> String:
	return "顶级魔物，在阴影中潜行攻击，使用暗影魔法攻击，统治中低级魔物，守卫死地核心区域。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "死地生态系统 - 顶级消费者 - 暗影潜行，魔法攻击，统治行为"
