extends BeastBase
class_name RhinoBeast

## 犀角兽 - 草地中的大型生物
## 阵营: 野兽阵营（中立）
## 特点: 攻击性，体型巨大，防御力强，移动缓慢

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_rhino_beast_data()
	
	# 犀角兽是攻击性生物
	is_aggressive = true
	is_combat_unit = true
	
	add_to_group(GameGroups.BEASTS)
	add_to_group("rhino_beasts")
	
	# 状态机会在BeastBase._ready()中自动创建

func _init_rhino_beast_data() -> void:
	var data = CharacterData.new()
	data.character_name = "犀角兽"
	data.creature_type = Enums.CreatureType.RHINO_BEAST
	data.max_health = 1200  # 血量很高
	data.attack = 50        # 攻击力很强
	data.armor = 8          # 防御力很强
	data.speed = 25         # 移动缓慢
	data.size = 35          # 体型很大
	data.attack_range = 4.0
	data.attack_cooldown = 2.0
	data.detection_range = 8.0
	data.color = Color(0.3, 0.3, 0.3)  # 深灰色
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return 8.0  # 视野相对较小

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return 0.6  # 缓慢移动
