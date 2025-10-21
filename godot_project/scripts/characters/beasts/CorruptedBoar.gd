class_name CorruptedBoar
extends BeastBase

## 腐化野猪 - 死地生态系统次级魔物
## 身体被魔法腐化，具有毒性，使用腐化獠牙进行冲撞攻击

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.CORRUPTED_BOARS)
	_init_corrupted_boar_data()

func _init_corrupted_boar_data() -> void:
	var data = CharacterData.new()
	data.character_name = "腐化野猪"
	data.creature_type = BeastsTypes.BeastType.CORRUPTED_BOAR
	data.max_health = 900
	data.attack = 35 # 高攻击力
	data.armor = 8 # 高防御
	data.speed = 30 # 移动速度
	data.size = 22 # 大型体型
	
	# 设置行为属性
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "次级魔物，身体被魔法腐化，具有毒性，使用腐化獠牙进行冲撞攻击，腐化皮肤提供强大防御。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "死地生态系统 - 次级消费者 - 腐化攻击，冲撞攻击，捕食暗影魔狼"
