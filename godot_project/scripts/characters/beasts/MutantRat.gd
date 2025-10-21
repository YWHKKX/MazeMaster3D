class_name MutantRat
extends BeastBase

## 变异老鼠 - 荒地生态系统变异生物
## 具有辐射抗性，体型增大，形成老鼠群体

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.MUTANT_RATS)
	_init_mutant_rat_data()

func _init_mutant_rat_data() -> void:
	var data = CharacterData.new()
	data.character_name = "变异老鼠"
	data.creature_type = BeastsTypes.BeastType.MUTANT_RAT
	data.max_health = 400
	data.attack = 8 # 低攻击力
	data.armor = 2 # 低防御
	data.speed = 35 # 移动速度
	data.size = 10 # 中等体型（比普通老鼠大）
	
	# 应用数据
	character_data = data
	_init_from_character_data()
	
	# 设置野兽特有属性（在BeastBase中定义）
	flee_distance = 12.0 # 受到威胁时逃跑距离
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置

## 获取生物描述
func get_creature_description() -> String:
	return "变异生物，具有辐射抗性，体型增大，形成大型老鼠群体，适应恶劣的荒地环境。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "荒地生态系统 - 初级消费者 - 变异特性，群体行为，适应辐射环境"
