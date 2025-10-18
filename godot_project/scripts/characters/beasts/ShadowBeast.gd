extends BeastBase
class_name ShadowBeast

## 暗影兽 - 死地中的终极亡灵生物
## 阵营: 野兽阵营（中立）
## 特点: 攻击性，暗影能力，最强大的亡灵生物

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_shadow_beast_data()
	
	# 暗影兽是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group(GameGroups.SHADOW_BEASTS)
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_shadow_beast_data() -> void:
	var data = CharacterData.new()
	data.character_name = "暗影兽"
	data.creature_type = BeastsTypes.BeastType.SHADOW_BEAST
	data.max_health = 1500 # 血量极高
	data.attack = 80 # 攻击力极强
	data.armor = 6
	data.speed = 50
	data.size = 30
	data.attack_range = 6.0
	data.attack_cooldown = 1.2
	data.detection_range = 15.0
	data.color = Color(0.1, 0.1, 0.2) # 深紫色/黑色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 15.0

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 1.2 # 活跃移动
