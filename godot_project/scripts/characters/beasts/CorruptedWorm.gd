class_name CorruptedWorm
extends BeastBase

## 腐化蠕虫 - 荒地生态系统变异生物
## 具有腐蚀性体液，在地下挖掘隧道

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.CORRUPTED_WORMS)
	_init_corrupted_worm_data()

func _init_corrupted_worm_data() -> void:
	var data = CharacterData.new()
	data.character_name = "腐化蠕虫"
	data.creature_type = BeastsTypes.BeastType.CORRUPTED_WORM
	data.max_health = 500
	data.attack = 12 # 低攻击力
	data.armor = 3 # 低防御
	data.speed = 20 # 移动速度较慢
	data.size = 14 # 中等体型
	
	# 应用数据
	character_data = data
	_init_from_character_data()
	
	# 设置野兽特有属性（在BeastBase中定义）
	flee_distance = 8.0 # 受到威胁时逃跑距离
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置

## 获取生物描述
func get_creature_description() -> String:
	return "变异生物，具有腐蚀性体液，在地下挖掘隧道，适应辐射和腐化环境。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "荒地生态系统 - 初级消费者 - 腐化攻击，地下挖掘，适应恶劣环境"
