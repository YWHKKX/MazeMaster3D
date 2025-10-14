extends MonsterBase
class_name OrcWarrior

## 兽人战士 - 狂暴战士，低血量时进入狂暴状态
## 战斗等级: ⭐⭐
##
## [已迁移] 从旧的 Monster 基类迁移到新的 MonsterBase

func _ready() -> void:
	super._ready()
	
	if not character_data:
		_init_orc_data()
	
	is_combat_unit = true
	add_to_group(GameGroups.MONSTERS)
	add_to_group("orc_warriors")
	
	if debug_mode:
		print("[OrcWarrior] 兽人战士初始化完成 - 位置: %v" % global_position)

func _init_orc_data() -> void:
	var data = CharacterData.new()
	data.character_name = "兽人战士"
	data.creature_type = Enums.CreatureType.ORC_WARRIOR
	data.max_health = 900
	data.attack = 22
	data.armor = 4
	data.speed = 80
	data.size = 18
	data.attack_range = 3.5 # 3D空间
	data.attack_cooldown = 1.2
	data.detection_range = Constants.SEARCH_RANGE_IMP
	data.cost_gold = GameBalance.ORC_WARRIOR_COST
	data.upkeep = GameBalance.ORC_WARRIOR_UPKEEP
	data.color = Color(0.4, 0.6, 0.4)
	
	character_data = data
	_init_from_character_data()
