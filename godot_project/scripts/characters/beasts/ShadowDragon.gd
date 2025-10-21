class_name ShadowDragon
extends BeastBase

## 暗影龙 - 原始生态系统掠食恐龙
## 在阴影中潜行攻击，使用暗影力量攻击，释放恐惧效果

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.SHADOW_DRAGONS)
	_init_shadow_dragon_data()

func _init_shadow_dragon_data() -> void:
	var data = CharacterData.new()
	data.character_name = "暗影龙"
	data.creature_type = BeastsTypes.BeastType.SHADOW_DRAGON
	data.max_health = 1800
	data.attack = 55 # 高攻击力
	data.armor = 10 # 高防御
	data.speed = 45 # 移动速度
	data.size = 33 # 大型体型
	
	# 设置行为属性
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "掠食恐龙，在阴影中潜行攻击，使用暗影力量攻击，释放恐惧效果。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "原始生态系统 - 高级消费者 - 暗影潜行，暗影攻击，恐惧光环"
