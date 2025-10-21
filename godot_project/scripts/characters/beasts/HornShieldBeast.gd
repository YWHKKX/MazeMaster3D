class_name HornShieldBeast
extends BeastBase

## 角盾龙 - 原始生态系统食草恐龙
## 使用头部巨角和盾状鳞片防御，形成防御性族群

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.HORN_SHIELD_BEASTS)
	_init_horn_shield_beast_data()

func _init_horn_shield_beast_data() -> void:
	var data = CharacterData.new()
	data.character_name = "角盾龙"
	data.creature_type = BeastsTypes.BeastType.HORN_SHIELD_DRAGON
	data.max_health = 1500
	data.attack = 30 # 中等攻击力
	data.armor = 12 # 高防御
	data.speed = 25 # 移动速度较慢
	data.size = 30 # 大型体型
	
	# 应用数据
	character_data = data
	_init_from_character_data()
	
	# 设置野兽特有属性（在BeastBase中定义）
	flee_distance = 20.0 # 受到威胁时逃跑距离
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置

## 获取生物描述
func get_creature_description() -> String:
	return "食草恐龙，使用头部巨角和盾状鳞片防御，形成防御性族群，以原始植物为食。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "原始生态系统 - 初级消费者 - 角盾防御，防御性族群，食草特化"
