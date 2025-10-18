class_name GoblinWorker
extends MonsterBase

## 哥布林苦工 - 专门负责挖掘金矿的非战斗单位
## 
## [已重构] 使用 MonsterBase 基类和最新状态机 API
## [状态机] 使用完整的 StateMachine 框架

# WorkerConstants 现在是全局类，无需 preload
const WorkerStatus = WorkerConstants.WorkerStatus

# 状态机引用（使用不同名称避免与基类冲突）
@onready var worker_state_machine: Node = $StateMachine

# 苦工配置
var worker_config = {
	"mining_rate": 1.0, # 🔧 挖矿间隔：每1秒挖一次
	"carry_capacity": 60, # 🔧 提升携带量：从20改为60
	"flee_distance": 60,
	"wander_radius": 50,
	"idle_timeout": 2.0,
	"state_change_cooldown": 0.5
}

# 🔧 挖矿力量（每次挖掘产量，供状态机使用）
var mining_power: int = 4 # 🔧 挖掘产量：每次挖4金币（4金币/秒）

# 苦工状态数据（供状态类访问）
var current_mine = null
var target_base = null
var carried_gold: int = 0
var mining_progress: float = 0.0
var base_position: Vector3 = Vector3(50, 0.05, 50)
var failed_mines: Dictionary = {}
var failed_mine_timeout: float = 10.0 # 🔧 黑名单超时：10秒后重试
var has_deposited: bool = false

# 🔧 [新增] 定期清理过期的黑名单
var blacklist_cleanup_timer: float = 0.0
const BLACKLIST_CLEANUP_INTERVAL: float = 5.0 # 每5秒清理一次

# 管理器引用
var gold_mine_manager = null
var auto_assigner = null
var building_manager = null
var resource_manager = null

func _ready() -> void:
	super._ready()
	
	if not character_data:
		_init_goblin_worker_data()
	
	# 初始化属性
	carried_gold = 0
	is_combat_unit = false
	
	# 加入组（使用 GameGroups 常量）
	add_to_group(GameGroups.MONSTERS)
	add_to_group(GameGroups.WORKERS)
	add_to_group(GameGroups.GOBLIN_WORKERS)
	
	# 🔧 启用调试模式（排查地牢之心交互问题）
	debug_mode = true # CharacterBase 的 debug_mode
	if worker_state_machine:
		worker_state_machine.debug_mode = true
	
	# 设置管理器
	call_deferred("_setup_managers")
	call_deferred("_init_base_position")

func _init_goblin_worker_data() -> void:
	var data = CharacterData.new()
	data.character_name = "哥布林苦工"
	data.creature_type = MonstersTypes.MonsterType.GOBLIN_WORKER
	data.max_health = 600
	data.attack = 8
	data.armor = 0
	data.speed = 40 # 🔧 移动速度：与工程师相同（0.4米/秒）
	data.size = 18
	data.attack_range = 3.0
	data.attack_cooldown = 1.0
	data.detection_range = 10.0
	data.color = Color(0.6, 0.4, 0.2)
	data.mining_speed = 1.0 # 🔧 挖矿速度：1.0秒/次
	data.carry_capacity = 60 # 🔧 携带容量：从20提升到60
	character_data = data
	_init_from_character_data()

func _setup_managers() -> void:
	if is_inside_tree():
		# 使用 GameServices 访问管理器（Autoload API）
		gold_mine_manager = GameServices.gold_mine_manager
		auto_assigner = GameServices.auto_assigner
		building_manager = GameServices.building_manager
		resource_manager = GameServices.resource_manager
		
		# 🔧 [状态栏系统] 启用金币显示
		call_deferred("_enable_gold_display")

func _init_base_position() -> void:
		base_position = _find_base_position()


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

func find_nearby_gold_mine():
	"""查找附近的金矿"""
	if not gold_mine_manager:
		return null
	
	_cleanup_failed_mines()
	
	var all_mines = gold_mine_manager.get_available_mines_in_range(global_position, 50.0)
	if all_mines.is_empty():
		return null
	
	var nearest_mine = null
	var min_distance = INF
	
	for mine in all_mines:
		if _is_mine_failed(mine.position):
			continue
		if mine.is_exhausted() or not mine.can_accept_miner():
			continue
		
		var dist = global_position.distance_to(mine.position)
		if dist < min_distance:
			min_distance = dist
			nearest_mine = mine
	
	return nearest_mine

func perform_mining(delta: float) -> int:
	"""执行挖矿，返回挖到的金币数量"""
	if not current_mine:
		return 0
	
	mining_progress += worker_config.mining_rate * delta
	
	if mining_progress >= 1.0:
		var mining_amount = int(mining_progress)
		mining_progress -= mining_amount
		
		mining_amount = mini(mining_amount, current_mine.gold_amount)
		mining_amount = mini(mining_amount, worker_config.carry_capacity - carried_gold)
		
		if mining_amount > 0:
			current_mine.gold_amount -= mining_amount
			carried_gold += mining_amount
			return mining_amount
	
	return 0

func store_gold() -> void:
	"""存储金币到资源管理器"""
	if carried_gold > 0 and resource_manager:
		resource_manager.add_resource(0, carried_gold)
		carried_gold = 0

func _find_base_position() -> Vector3:
	"""查找基地位置"""
	if building_manager:
		var heart = _find_dungeon_heart()
		if heart:
			return heart.position
	return Vector3(50, 0.05, 50)

func _find_dungeon_heart():
	"""查找地牢之心"""
	if not building_manager:
		return null
	for building in building_manager.buildings:
		if building.has_method("is_dungeon_heart") and building.is_dungeon_heart():
			return building
	return null

func mark_mine_as_failed(mine_pos: Vector3) -> void:
	"""标记金矿为失败"""
	failed_mines[str(mine_pos)] = Time.get_ticks_msec()

func _is_mine_failed(mine_pos: Vector3) -> bool:
	"""检查金矿是否在失败列表中"""
	return failed_mines.has(str(mine_pos))

func _cleanup_failed_mines() -> void:
	"""清理过期的失败金矿记录"""
	var current_time = Time.get_ticks_msec()
	var to_remove = []
	for key in failed_mines.keys():
		if (current_time - failed_mines[key]) > (failed_mine_timeout * 1000):
			to_remove.append(key)
	for key in to_remove:
		failed_mines.erase(key)
	
# ============================================================================
# 状态查询接口
# ============================================================================

func set_target_mine(mine) -> void:
	current_mine = mine

func get_worker_status() -> int:
	"""获取苦工状态（从状态机获取）"""
	if worker_state_machine and worker_state_machine.has_method("get_current_state_name"):
		var state_name = worker_state_machine.get_current_state_name()
		match state_name:
			"IdleState": return WorkerStatus.IDLE
			"WanderState": return WorkerStatus.WANDERING
			"MoveToMineState": return WorkerStatus.MOVING_TO_MINE
			"MiningState": return WorkerStatus.MINING
			"ReturnToBaseState": return WorkerStatus.RETURNING_TO_BASE
			"DepositGoldState": return WorkerStatus.RETURNING_TO_BASE
			"EscapeState": return WorkerStatus.FLEEING
	return WorkerStatus.IDLE

func can_accept_assignment() -> bool:
	"""检查是否可以接受新任务"""
	if worker_state_machine and worker_state_machine.has_method("get_current_state_name"):
		return worker_state_machine.get_current_state_name() == "IdleState"
	return true

func get_carried_gold() -> int:
	return carried_gold

func get_worker_info() -> Dictionary:
	return {
		"position": global_position,
		"status": get_worker_status(),
		"carried_gold": carried_gold,
		"health": current_health,
		"max_health": max_health
	}

func get_status_color() -> Color:
	var status = get_worker_status()
	match status:
		WorkerStatus.IDLE: return Color.WHITE
		WorkerStatus.MOVING_TO_MINE: return Color.GREEN
		WorkerStatus.MINING: return Color.YELLOW
		WorkerStatus.RETURNING_TO_BASE: return Color.CYAN
		WorkerStatus.FLEEING: return Color(0.3, 0.3, 0.3)
		WorkerStatus.WANDERING: return Color.ORANGE
		_: return Color.WHITE
