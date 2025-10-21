class_name SpineBackBeast
extends BeastBase

## 棘背龙 - 原始生态系统食草恐龙
## 背部的巨型棘刺威慑敌人，形成警戒性族群

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.SPINE_BACK_BEASTS)
	_init_spine_back_beast_data()

func _init_spine_back_beast_data() -> void:
	var data = CharacterData.new()
	data.character_name = "棘背龙"
	data.creature_type = BeastsTypes.BeastType.SPINE_BACK_DRAGON
	data.max_health = 1200
	data.attack = 25 # 中等攻击力
	data.armor = 10 # 高防御
	data.speed = 30 # 移动速度
	data.size = 28 # 大型体型
	
	# 应用数据
	character_data = data
	_init_from_character_data()
	
	# 设置野兽特有属性（在BeastBase中定义）
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置

## 获取生物描述
func get_creature_description() -> String:
	return "食草恐龙，背部的巨型棘刺威慑敌人，形成警戒性族群，时刻保持警戒状态。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "原始生态系统 - 初级消费者 - 棘背威慑，警戒性族群，食草特化"
