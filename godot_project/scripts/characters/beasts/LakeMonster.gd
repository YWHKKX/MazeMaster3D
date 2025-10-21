class_name LakeMonster
extends BeastBase

## 湖怪 - 湖泊生态系统顶级掠食者
## 统治湖泊深水区域，拥有巨大的体型和力量

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.LAKE_MONSTERS)
	_init_lake_monster_data()

func _init_lake_monster_data() -> void:
	var data = CharacterData.new()
	data.character_name = "湖怪"
	data.creature_type = BeastsTypes.BeastType.LAKE_MONSTER
	data.max_health = 2000
	data.attack = 80 # 极高攻击力
	data.armor = 15 # 高防御
	data.speed = 25 # 移动速度较慢
	data.size = 35 # 大型单位
	
	# 应用数据
	character_data = data
	_init_from_character_data()
	
	# 设置野兽特有属性（在BeastBase中定义）
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置

## 获取生物描述
func get_creature_description() -> String:
	return "湖泊的终极统治者，拥有巨大的体型和力量，在深水中潜伏等待猎物，控制整个湖泊的核心区域。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "湖泊生态系统 - 顶级掠食者 - 统治深水区域，维持湖泊生态系统的顶级平衡"
