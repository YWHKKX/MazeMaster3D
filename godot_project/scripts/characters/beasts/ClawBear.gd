extends BeastBase
class_name ClawBear

## 巨爪熊 - 森林中的顶级掠食者
## 阵营: 野兽阵营（中立）
## 特点: 杂食性，力量攻击，与影刃虎竞争领地

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_claw_bear_data()
	
	# 巨爪熊是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group("claw_bears")
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_claw_bear_data() -> void:
	var data = CharacterData.new()
	data.character_name = "巨爪熊"
	data.creature_type = Enums.CreatureType.CLAW_BEAR
	data.max_health = 1000
	data.attack = 90  # 极高攻击力
	data.armor = 30
	data.speed = 45  # 较慢但力量巨大
	data.size = 40
	data.attack_range = 4.0
	data.attack_cooldown = 2.0
	data.detection_range = 12.0
	data.color = Color(0.4, 0.3, 0.2)  # 棕色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 12.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 0.7  # 缓慢但有力

## 杂食行为 - 既吃植物也捕食其他动物
func omnivorous_behavior() -> void:
	# 杂食性行为，可以吃植物和动物
	pass

## 力量攻击 - 使用巨爪进行强力攻击
func perform_power_attack() -> void:
	# 力量攻击，造成巨大伤害
	var power_damage = attack * 0.8
	attack += power_damage
