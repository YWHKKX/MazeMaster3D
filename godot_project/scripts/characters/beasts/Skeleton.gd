extends BeastBase
class_name Skeleton

## 骷髅 - 死地中的亡灵生物
## 阵营: 野兽阵营（中立）
## 特点: 攻击性，亡灵特性，不惧死亡

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_skeleton_data()
	
	# 骷髅是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group("skeletons")
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_skeleton_data() -> void:
	var data = CharacterData.new()
	data.character_name = "骷髅"
	data.creature_type = Enums.CreatureType.SKELETON
	data.max_health = 400
	data.attack = 25
	data.armor = 1
	data.speed = 30        # 移动缓慢
	data.size = 16
	data.attack_range = 2.5
	data.attack_cooldown = 2.0
	data.detection_range = 7.0
	data.color = Color(0.8, 0.8, 0.8)  # 白色/灰色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 7.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 0.7  # 缓慢移动
