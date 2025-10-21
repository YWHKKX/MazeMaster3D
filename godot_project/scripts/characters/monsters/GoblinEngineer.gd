class_name GoblinEngineer
extends MonsterBase

## 地精工程师 - 专门负责建造和维护建筑的非战斗单位
## 
## [已重构] 使用 MonsterBase 基类和最新状态机 API
## [状态机] 使用完整的 StateMachine 框架

# WorkerConstants 现在是全局类，无需 preload
const EngineerStatus = WorkerConstants.EngineerStatus

# 状态机引用（使用不同名称避免与基类冲突）
@onready var engineer_state_machine: Node = $StateMachine

# 工程师配置
var engineer_config = {
	"carry_capacity": 60,
	"gold_capacity": 60, # 🔧 金币携带容量（与 carry_capacity 相同）
	"build_rate": 4,
	"repair_rate": 4,
	"wander_radius": 50,
	"idle_timeout": 1.0,
	"state_change_cooldown": 0.5
}

# 工程师状态数据（供状态类访问）
var current_building = null
var carried_gold: int = 0
var base_position: Vector3 = Vector3.ZERO

# 管理器引用
var gold_mine_manager = null
var building_manager = null
var auto_assigner = null
var resource_manager = null

func _ready() -> void:
	super._ready()
	
	if not character_data:
		_init_goblin_engineer_data()
	
	# 🔧 启用调试模式，诊断移动问题
	debug_mode = true # CharacterBase 的 debug_mode
	
	# 初始化属性
	carried_gold = 0
	is_combat_unit = false
	
	# 加入组（使用 GameGroups 常量）
	add_to_group(GameGroups.MONSTERS)
	add_to_group(GameGroups.ENGINEERS)
	add_to_group(GameGroups.GOBLIN_ENGINEERS) # 特定单位组
	
	# 设置管理器
	call_deferred("_setup_managers")

func _init_goblin_engineer_data() -> void:
	var data = CharacterData.new()
	data.character_name = "地精工程师"
	data.creature_type = MonstersTypes.MonsterType.GOBLIN_ENGINEER
	data.max_health = 800
	data.attack = 12
	data.armor = 2
	data.speed = 40
	data.size = 18 # 🔧 从12增加到18，使模型更清晰可见
	data.attack_range = 10.0
	data.attack_cooldown = 1.0
	data.detection_range = 10.0
	data.color = Color(0.1, 0.5, 0.1) # 🔧 工程师：深绿色（与苦工的棕色形成对比）
	data.building_speed = 4.0 # 🔧 修复：使用正确的属性名 building_speed（不是 build_speed）
	data.carry_capacity = 60
	character_data = data
	_init_from_character_data()

func _setup_managers() -> void:
	if is_inside_tree():
		# 使用 GameServices 访问管理器（Autoload API）
		gold_mine_manager = GameServices.get_gold_mines()
		building_manager = GameServices.building_manager
		auto_assigner = GameServices.auto_assigner
		resource_manager = GameServices.resource_manager
		
		# 🔧 启用状态机调试模式，诊断移动问题
		if engineer_state_machine:
			engineer_state_machine.debug_mode = true
		
		# 🔧 [状态栏系统] 启用金币显示
		call_deferred("_enable_gold_display")


## 🔧 [状态栏系统] 启用金币显示
func _enable_gold_display() -> void:
	"""启用状态栏的金币显示"""
	var bar = get("status_bar") # 从父类获取
	if bar and bar.has_method("set_show_gold"):
		bar.set_show_gold(true)
		_update_status_bar_gold()


## 🔧 [状态栏系统] 更新金币显示
func _update_status_bar_gold() -> void:
	"""更新状态栏的金币数量"""
	var bar = get("status_bar") # 从父类获取
	if bar and bar.has_method("update_gold"):
		bar.update_gold(carried_gold)


# ============================================================================
# 业务逻辑方法（供状态类调用）
# ============================================================================

func find_nearest_building_needing_work():
	"""查找需要工作的最近建筑"""
	if not building_manager:
		return null
	
	if building_manager.has_method("get_nearest_building_needing_work"):
		return building_manager.get_nearest_building_needing_work(global_position, 100.0)
	
	return null

func calculate_gold_needed(building) -> int:
	"""计算建筑需要的金币"""
	if not building:
		return 0
	if building.has_method("get_construction_cost_remaining"):
		return building.get_construction_cost_remaining()
	return engineer_config.carry_capacity

func fetch_gold_from_base(amount: int) -> int:
	"""从基地获取金币"""
	if not resource_manager:
		return 0
	
	var available = resource_manager.get_gold()
	var to_fetch = mini(mini(amount, available), engineer_config.carry_capacity)
	
	if to_fetch > 0:
		# TODO: 从资源管理器扣除金币
		carried_gold = to_fetch
		return to_fetch
	
	return 0

func perform_construction(delta: float) -> int:
	"""执行建造，返回消耗的金币"""
	if not current_building or carried_gold <= 0:
		return 0
	
	var gold_to_spend = mini(engineer_config.build_rate * delta, carried_gold)
	if current_building.has_method("add_construction_progress"):
		current_building.add_construction_progress(int(gold_to_spend))
	
	carried_gold -= int(gold_to_spend)
	return int(gold_to_spend)

func perform_repair(delta: float) -> int:
	"""执行修理，返回消耗的金币"""
	if not current_building or carried_gold <= 0:
		return 0
	
	var gold_to_spend = mini(engineer_config.repair_rate * delta, carried_gold)
	if current_building.has_method("repair"):
		current_building.repair(int(gold_to_spend))
	
	carried_gold -= int(gold_to_spend)
	return int(gold_to_spend)

func find_dungeon_heart():
	"""查找地牢之心"""
	if not building_manager:
		return null
	for building in building_manager.buildings:
		if building.has_method("is_dungeon_heart") and building.is_dungeon_heart():
			return building
	return null

# ============================================================================
# 状态查询接口
# ============================================================================

func set_target_building(building) -> void:
	current_building = building

func get_engineer_status() -> int:
	"""获取工程师状态（从状态机获取）"""
	if engineer_state_machine and engineer_state_machine.has_method("get_current_state_name"):
		var state_name = engineer_state_machine.get_current_state_name()
		match state_name:
			"IdleState":
				return EngineerStatus.IDLE
			"WanderState":
				return EngineerStatus.WANDERING
			"FetchGoldState":
				return EngineerStatus.FETCHING_RESOURCES
			"MoveToTargetState":
				return EngineerStatus.MOVING_TO_SITE
			"WorkState":
				if current_building and current_building.has_method("needs_construction"):
					return EngineerStatus.CONSTRUCTING if current_building.needs_construction() else EngineerStatus.REPAIRING
				return EngineerStatus.CONSTRUCTING
			"ReturnGoldState":
				return EngineerStatus.RETURNING_TO_BASE
			"EscapeState":
				return EngineerStatus.IDLE
	return EngineerStatus.IDLE

func can_accept_assignment() -> bool:
	"""检查是否可以接受新任务
	
	📋 [BUILDING_SYSTEM.md] 可接受任务的状态：
	- IDLE (空闲)
	- WANDERING (游荡)
	"""
	if engineer_state_machine and engineer_state_machine.has_method("get_current_state_name"):
		var state_name = engineer_state_machine.get_current_state_name()
		return state_name in ["IdleState", "WanderState"]
	return true

func get_carried_gold() -> int:
	return carried_gold

func get_engineer_info() -> Dictionary:
	return {
		"position": global_position,
		"status": get_engineer_status(),
		"carried_gold": carried_gold,
		"health": current_health,
		"max_health": max_health
	}

func get_status_color() -> Color:
	var status = get_engineer_status()
	match status:
		EngineerStatus.IDLE: return Color.WHITE
		EngineerStatus.FETCHING_RESOURCES: return Color(0.0, 0.8, 0.0)
		EngineerStatus.MOVING_TO_SITE: return Color.GREEN
		EngineerStatus.CONSTRUCTING: return Color(0.6, 0.4, 0.2)
		EngineerStatus.REPAIRING: return Color.YELLOW
		_: return Color.WHITE


# ===== Area3D交互检测（供状态机使用）=====

func check_in_building_area3d(target_building: Node) -> bool:
	"""检查Engineer是否在建筑的Area3D交互范围内
	
	🔧 [方案C] 主动查询Area3D重叠，统一方法避免代码重复
	
	适用于：
	- 地牢之心（2x2，Area3D在tile_object上，通过INTERACTION_ZONES）
	- 金库（1x1，Area3D在tile_object上，通过INTERACTION_ZONES）
	- 普通建筑（Area3D在建筑对象的子节点中）
	"""
	# 🔧 [修复] 使用建筑的实际交互范围，而不是固定的1.4米
	var engineer_pos = self.global_position
	var building_pos = target_building.global_position
	var distance_to_building = engineer_pos.distance_to(building_pos)
	
	# 使用建筑的实际交互范围（默认0.01米，地牢之心2.0米）
	var interaction_range = 0.01 # 默认交互范围
	if target_building.has_method("get_interaction_range"):
		interaction_range = target_building.get_interaction_range()
	elif "interaction_range" in target_building:
		interaction_range = target_building.interaction_range
	
	# 对于大型建筑（如地牢之心），适当增加交互范围
	if target_building.building_size and target_building.building_size.x >= 2:
		interaction_range = max(interaction_range, 1.0) # 大型建筑至少1.0米
	
	# 如果距离足够近，直接返回true（后备方案）
	if distance_to_building <= interaction_range:
		return true
	
	# 方案1: 尝试从INTERACTION_ZONES查找（地牢之心、金库）
	var interaction_areas = GameGroups.get_nodes(GameGroups.INTERACTION_ZONES)
	
	for area in interaction_areas:
		if area.has_meta("building_type") or area.has_meta("building_position"):
			# 通过位置距离匹配（2x2建筑对角线约1.4米）
			if area.has_meta("building_position"):
				var area_pos = area.get_meta("building_position")
				var distance = area_pos.distance_to(target_building.global_position)
				
				if distance < 2.0:
					var overlapping = area.get_overlapping_bodies()
					if self in overlapping:
						return true
	
	# 方案2: 检查建筑子节点中的Area3D（普通建筑）
	for child in target_building.get_children():
		if child is Area3D:
			var overlapping = child.get_overlapping_bodies()
			if self in overlapping:
				return true
	
	return false
