extends BeastBase
class_name ShadowTiger

## 影刃虎 - 森林中的顶级掠食者
## 阵营: 野兽阵营（中立）
## 特点: 潜伏伏击，控制森林狼数量

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_shadow_tiger_data()
	
	# 影刃虎是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group("shadow_tigers")
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_shadow_tiger_data() -> void:
	var data = CharacterData.new()
	data.character_name = "影刃虎"
	data.creature_type = Enums.CreatureType.SHADOW_TIGER
	data.max_health = 800
	data.attack = 85  # 高攻击力
	data.armor = 25
	data.speed = 75  # 速度很快
	data.size = 35
	data.attack_range = 3.5
	data.attack_cooldown = 1.5
	data.detection_range = 15.0
	data.color = Color(0.2, 0.2, 0.3)  # 暗色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 15.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 1.2  # 快速移动寻找猎物

## 潜伏伏击能力
func perform_ambush_attack() -> void:
	# 潜伏伏击攻击，造成额外伤害
	var bonus_damage = attack * 0.5
	attack += bonus_damage
