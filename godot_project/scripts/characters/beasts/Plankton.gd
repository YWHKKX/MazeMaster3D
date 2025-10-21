class_name Plankton
extends BeastBase

## 浮游生物 - 湖泊生态系统微型食草动物
## 以浮游植物和藻类为食，是湖泊食物链的最基础环节

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.PLANKTON)
	_init_plankton_data()

func _init_plankton_data() -> void:
	var data = CharacterData.new()
	data.character_name = "浮游生物"
	data.creature_type = BeastsTypes.BeastType.PLANKTON
	data.max_health = 50 # 极低血量
	data.attack = 1 # 无攻击力
	data.armor = 0 # 无防御
	data.speed = 15 # 极慢移动
	data.size = 2 # 微型生物
	
	# 设置行为属性
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "微型浮游生物，以浮游植物和藻类为食，形成密集的浮游生物群，为整个湖泊食物链提供基础营养。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "湖泊生态系统 - 初级消费者 - 以浮游植物为食，是湖泊食物链的最基础环节"
