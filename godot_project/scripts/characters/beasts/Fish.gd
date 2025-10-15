extends BeastBase
class_name Fish

## 鱼 - 湖泊中的小型生物
## 阵营: 野兽阵营（中立）
## 特点: 非攻击性，水中游泳，成群活动

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_fish_data()
	
	# 鱼是非攻击性生物
	is_aggressive = false
	is_combat_unit = false
	
	add_to_group(GameGroups.BEASTS)
	add_to_group("fishes")
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_fish_data() -> void:
	var data = CharacterData.new()
	data.character_name = "鱼"
	data.creature_type = Enums.CreatureType.FISH
	data.max_health = 100  # 血量很低
	data.attack = 2        # 攻击力很低
	data.armor = 0
	data.speed = 45        # 水中游泳速度
	data.size = 6          # 体型很小
	data.attack_range = 1.0
	data.attack_cooldown = 3.0
	data.detection_range = 8.0
	data.color = Color(0.2, 0.4, 0.8)  # 蓝色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 8.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 1.0  # 正常游泳
