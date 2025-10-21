class_name SandstormWolf
extends BeastBase

## 沙暴狼 - 荒地生态系统沙漠生物
## 具有制造沙暴掩护攻击的能力，群体狩猎

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.SANDSTORM_WOLVES)
	_init_sandstorm_wolf_data()

func _init_sandstorm_wolf_data() -> void:
	var data = CharacterData.new()
	data.character_name = "沙暴狼"
	data.creature_type = BeastsTypes.BeastType.SANDSTORM_WOLF
	data.max_health = 700
	data.attack = 30 # 中等攻击力
	data.armor = 5 # 中等防御
	data.speed = 45 # 移动速度
	data.size = 18 # 中等体型
	
	# 设置行为属性
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "沙漠生物，具有制造沙暴掩护攻击的能力，群体狩猎，适应荒地环境。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "荒地生态系统 - 中级消费者 - 沙暴攻击，群体狩猎，适应沙漠环境"
