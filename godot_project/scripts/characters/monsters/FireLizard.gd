extends MonsterBase
class_name FireLizard

## 火蜥蜴 - 远程火力，具有溅射伤害
## 战斗等级: ⭐⭐⭐
##
## [已迁移] 从旧的 Monster 基类迁移到新的 MonsterBase

func _ready() -> void:
	super._ready()
	
	if not character_data:
		_init_fire_lizard_data()
	
	is_combat_unit = true
	add_to_group(GameGroups.MONSTERS)
	add_to_group("fire_lizards")
	
	if debug_mode:
		print("[FireLizard] 火蜥蜴初始化完成 - 位置: %v" % global_position)

func _init_fire_lizard_data() -> void:
	var data = CharacterData.new()
	data.character_name = "火蜥蜴"
	data.creature_type = Enums.CreatureType.FIRE_LIZARD
	data.max_health = 1000
	data.attack = 28
	data.armor = 3
	data.speed = 43
	data.size = 18
	data.attack_range = 8.5 # 远程单位（原85像素）
	data.attack_cooldown = 1.0
	data.detection_range = Constants.SEARCH_RANGE_FIRE_SALAMANDER
	data.cost_gold = GameBalance.FIRE_LIZARD_COST
	data.upkeep = GameBalance.FIRE_LIZARD_UPKEEP
	data.color = Color(1.0, 0.4, 0.2) # 火焰橙色
	data.attack_type = Enums.AttackType.RANGED
	
	character_data = data
	_init_from_character_data()
