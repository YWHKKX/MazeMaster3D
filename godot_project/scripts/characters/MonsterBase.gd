## 怪物基类
##
## 继承自 CharacterBase，为所有怪物提供通用功能。
## 具体的怪物类型（如 GoblinWorker, Imp 等）继承此类。
##
## 使用方法：
## ```gdscript
## class_name GoblinWorker extends MonsterBase
## ```
class_name MonsterBase
extends CharacterBase

## ============================================================================
## 信号定义
## ============================================================================

## 开始工作信号
signal work_started()

## 工作完成信号
signal work_completed()

## 开始逃跑信号
signal flee_started()

## 逃跑结束信号
signal flee_ended()

## ============================================================================
## 导出属性
## ============================================================================

## 游荡半径
@export var wander_radius: float = 5.0

## 逃跑距离
@export var flee_distance: float = 10.0

## 空闲超时时间（秒后自动游荡）
@export var idle_timeout: float = 2.0

## ============================================================================
## 怪物特有属性
## ============================================================================

## 游荡目标位置
var wander_target: Vector3 = Vector3.ZERO

## 逃跑目标位置
var flee_target: Vector3 = Vector3.ZERO

## 空闲计时器
var idle_timer: float = 0.0

## 工作目标（金矿、建筑等）
var work_target: Node3D = null

## ============================================================================
## 生命周期
## ============================================================================

func _ready() -> void:
	super._ready()
	
	# 设置怪物阵营
	faction = MonstersTypes.Faction.MONSTERS
	
	# 🔧 [特殊处理] GoblinWorker 和 GoblinEngineer 使用场景预配置的状态机
	if _is_special_goblin_unit():
		_handle_special_goblin_state_machine()
	else:
		# 普通怪物使用 StateManager 创建状态机
		if enable_state_machine and not state_machine:
			var state_manager = StateManagerClass.get_instance()
			if state_manager:
				state_machine = state_manager.create_state_machine_for_character(self)
			else:
				LogManager.error("MonsterBase - StateManager 实例为空，无法创建状态机")

func _process(delta: float) -> void:
	if not is_alive:
		return
	
	# 更新空闲计时器
	if current_status == MonstersTypes.MonsterStatus.IDLE:
		idle_timer += delta
		
		# 空闲超时自动游荡
		if idle_timer > idle_timeout:
			change_status(MonstersTypes.MonsterStatus.WANDERING)
			idle_timer = 0.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not is_alive:
		return
	
	# 更新回血
	update_regeneration(delta)
	
	# 检查是否需要逃跑
	if is_low_health() and current_status != MonstersTypes.MonsterStatus.FLEEING:
		start_fleeing()

## ============================================================================
## 怪物行为
## ============================================================================

## 开始游荡
func start_wandering() -> void:
	change_status(MonstersTypes.MonsterStatus.WANDERING)
	_generate_wander_target()

## 生成游荡目标
func _generate_wander_target() -> void:
	wander_target = global_position + Vector3(
		randf_range(-wander_radius, wander_radius),
		0.0,
		randf_range(-wander_radius, wander_radius)
	)
	
## 开始逃跑
func start_fleeing() -> void:
	change_status(MonstersTypes.MonsterStatus.FLEEING)
	flee_started.emit()

func stop_fleeing() -> void:
	flee_ended.emit()
	change_status(MonstersTypes.MonsterStatus.IDLE)
	
## 开始工作
func start_working(target: Node3D = null) -> void:
	work_target = target
	work_started.emit()

## 完成工作
func complete_work() -> void:
	work_completed.emit()
	work_target = null
	change_status(MonstersTypes.MonsterStatus.IDLE)
	
## ============================================================================
## 查找方法
## ============================================================================

## 查找最近的敌人
func find_nearest_enemy(max_distance: float = -1.0) -> CharacterBase:
	var search_distance = max_distance if max_distance > 0 else detection_range
	var nearest_enemy: CharacterBase = null
	var nearest_distance := INF
	
	# 获取所有单位（使用 GameGroups API）
	var all_characters = GameGroups.get_all_characters()
	
	for character in all_characters:
		if character is CharacterBase:
			var other_char := character as CharacterBase
			
			# 检查是否为敌人且存活
			if not is_enemy_of(other_char) or not other_char.is_alive:
				continue
			
			# 检查距离
			var distance = global_position.distance_to(other_char.global_position)
			if distance < search_distance and distance < nearest_distance:
				nearest_distance = distance
				nearest_enemy = other_char
	
	return nearest_enemy

## 查找最近的友军
func find_nearest_ally(max_distance: float = -1.0) -> CharacterBase:
	var search_distance = max_distance if max_distance > 0 else detection_range
	var nearest_ally: CharacterBase = null
	var nearest_distance := INF
	
	var all_characters = GameGroups.get_all_characters()
	
	for character in all_characters:
		if character is CharacterBase and character != self:
			var other_char := character as CharacterBase
			
			# 检查是否为友军且存活
			if not is_friend_of(other_char) or not other_char.is_alive:
				continue
			
			# 检查距离
			var distance = global_position.distance_to(other_char.global_position)
			if distance < search_distance and distance < nearest_distance:
				nearest_distance = distance
				nearest_ally = other_char
	
	return nearest_ally

## ============================================================================
## 特定怪物类型的搜索范围（子类可重写）
## ============================================================================

func get_search_range() -> float:
	# 子类可以根据怪物类型返回特定的搜索范围
	# 例如：Constants.SEARCH_RANGE_IMP
	return detection_range

## ============================================================================
## 特殊哥布林单位处理
## ============================================================================

## 检查是否是特殊的哥布林单位（使用场景预配置状态机）
func _is_special_goblin_unit() -> bool:
	"""检查是否是 GoblinWorker 或 GoblinEngineer"""
	if not character_data:
		return false
	
	var creature_type = character_data.creature_type
	return creature_type in [MonstersTypes.MonsterType.GOBLIN_WORKER, MonstersTypes.MonsterType.GOBLIN_ENGINEER]

## 处理特殊哥布林单位的状态机
func _handle_special_goblin_state_machine() -> void:
	"""处理 GoblinWorker 和 GoblinEngineer 的场景预配置状态机"""
	# 获取场景中预配置的状态机
	var scene_state_machine = get_node_or_null("StateMachine")
	if scene_state_machine:
		# 将场景状态机赋值给基类的 state_machine 引用
		state_machine = scene_state_machine
		
		# 设置状态机属性
		state_machine.debug_mode = debug_mode
		state_machine.auto_start = true
	
	else:
		LogManager.error("MonsterBase - %s 场景中缺少 StateMachine 节点" % get_character_name())

## ============================================================================
## 重写基类方法
## ============================================================================

func take_damage(damage: float, attacker: CharacterBase = null) -> void:
	super.take_damage(damage, attacker)
	
	# 怪物受到伤害时可能触发逃跑
	if is_alive and is_low_health():
		start_fleeing()

func die() -> void:
	super.die()
	
	# 停止所有正在进行的行为
	if state_machine:
		state_machine.stop()
	
	# 清理工作目标
	work_target = null

## ============================================================================
## 调试方法
## ============================================================================

func get_monster_info() -> Dictionary:
	var info = get_character_info()
	info["wander_target"] = wander_target
	info["flee_target"] = flee_target
	
	var work_target_name := "none"
	if work_target and is_instance_valid(work_target):
		work_target_name = work_target.name
	info["work_target"] = work_target_name
	info["idle_timer"] = idle_timer
	return info
