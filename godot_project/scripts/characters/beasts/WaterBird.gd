class_name WaterBird
extends BeastBase

## 水鸟 - 湖泊生态系统飞行掠食者
## 在空中盘旋寻找猎物，具有飞行优势和潜水能力

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.WATER_BIRDS)
	_init_water_bird_data()

func _init_water_bird_data() -> void:
	var data = CharacterData.new()
	data.character_name = "水鸟"
	data.creature_type = BeastsTypes.BeastType.WATER_BIRD
	data.max_health = 500
	data.attack = 20 # 中等攻击力
	data.armor = 2
	data.speed = 60 # 飞行速度
	data.size = 10 # 中等体型
	
	# 设置行为属性
	data.can_fly = true # 飞行能力（这是CharacterData中的有效属性）
	
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "飞行掠食者，在空中盘旋寻找猎物，具有飞行优势和潜水能力，群体狩猎和栖息。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "湖泊生态系统 - 高级消费者 - 飞行捕食，群体狩猎，守卫湖泊周边区域"
