extends MonsterBase
class_name Imp

## 小恶魔 - 基础战斗单位，性价比高
## 战斗等级: ⭐⭐
##
## [已迁移] 从旧的 Monster 基类迁移到新的 MonsterBase
## 使用新的常量系统和枚举定义

func _ready() -> void:
	super._ready()
	
	# 设置角色数据（如果没有在编辑器中配置）
	if not character_data:
		_init_imp_data()
	
	# 小恶魔是战斗单位
	is_combat_unit = true
	
	# 加入组（使用 GameGroups 常量）
	add_to_group(GameGroups.MONSTERS)
	add_to_group("imps")
	
	if debug_mode:
		print("[Imp] 小恶魔初始化完成 - 位置: %v" % global_position)

## 初始化小恶魔数据（如果没有使用 Resource）
func _init_imp_data() -> void:
	var data = CharacterData.new()
	data.character_name = "小恶魔"
	data.creature_type = Enums.CreatureType.IMP
	data.max_health = 800
	data.attack = 15
	data.armor = 2
	data.speed = 46 # 速度系统：30-80
	data.size = 18 # 🔧 从15增加到18，标准战斗单位大小
	data.attack_range = 3.0 # 3D空间（原30像素）
	data.attack_cooldown = 1.0
	data.detection_range = Constants.SEARCH_RANGE_IMP
	data.cost_gold = GameBalance.IMP_COST
	data.cost_mana = 0
	data.upkeep = GameBalance.IMP_UPKEEP
	data.color = Color(0.8, 0.4, 0.4) # 红色系
	
	character_data = data
	_init_from_character_data()

## 获取搜索范围
func get_search_range() -> float:
	return Constants.SEARCH_RANGE_IMP

## 获取游荡速度倍数
func get_wander_speed_multiplier() -> float:
	return Constants.WANDER_SPEED_IMP
