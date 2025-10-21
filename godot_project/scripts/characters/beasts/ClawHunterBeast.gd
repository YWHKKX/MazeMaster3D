class_name ClawHunterBeast
extends BeastBase

## 利爪龙 - 原始生态系统杂食恐龙
## 使用锋利的利爪攻击，具有极高的移动速度，主动狩猎小型恐龙

func _ready():
	super._ready()
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.CLAW_HUNTER_BEASTS)
	_init_claw_hunter_beast_data()

func _init_claw_hunter_beast_data() -> void:
	var data = CharacterData.new()
	data.character_name = "利爪龙"
	data.creature_type = BeastsTypes.BeastType.CLAW_HUNTER_DRAGON
	data.max_health = 1400
	data.attack = 50 # 高攻击力
	data.armor = 8 # 中等防御
	data.speed = 55 # 极高移动速度
	data.size = 26 # 中等体型
	
	# 设置行为属性
	# 注意：生态属性由BeastBase类自动设置，不需要手动设置
	data.active_hunting = true # 主动狩猎
	data.hunting_radius = 40.0 # 狩猎半径40米
	data.hunting_duration = 15.0 # 狩猎持续15秒
	
	# 设置杂食适应
	data.omnivore_adaptation = true # 杂食适应
	data.food_versatility = 0.7 # 70%食物适应性
	
	# 设置适应能力
	data.primitive_adaptation = true # 适应原始环境
	data.versatile_feeding = true # 多样化觅食
	
	# 应用数据
	character_data = data
	_init_from_character_data()

## 获取生物描述
func get_creature_description() -> String:
	return "杂食恐龙，使用锋利的利爪攻击，具有极高的移动速度，主动狩猎小型恐龙。"

## 获取生态信息
func get_ecosystem_info() -> String:
	return "原始生态系统 - 次级消费者 - 利爪攻击，快速移动，主动狩猎"
