extends MonsterBase
class_name Gargoyle

## 石像鬼 - 重装战士，适合正面作战
## 战斗等级: ⭐⭐⭐
##
## [已迁移] 从旧的 Monster 基类迁移到新的 MonsterBase

func _ready() -> void:
	super._ready()
	
	if not character_data:
		_init_gargoyle_data()
	
	is_combat_unit = true
	add_to_group(GameGroups.MONSTERS)
	add_to_group("gargoyles")
	
	if debug_mode:
		print("[Gargoyle] 石像鬼初始化完成 - 位置: %v" % global_position)

func _init_gargoyle_data() -> void:
	var data = CharacterData.new()
	data.character_name = "石像鬼"
	data.creature_type = Enums.CreatureType.GARGOYLE
	data.max_health = 1200
	data.attack = 25
	data.armor = 6
	data.speed = 40
	data.size = 20
	data.attack_range = 3.5
	data.attack_cooldown = 1.2
	data.detection_range = Constants.SEARCH_RANGE_GARGOYLE
	data.cost_gold = GameBalance.GARGOYLE_COST
	data.upkeep = GameBalance.GARGOYLE_UPKEEP
	data.color = Color(0.5, 0.5, 0.5) # 石头灰色
	
	character_data = data
	_init_from_character_data()
