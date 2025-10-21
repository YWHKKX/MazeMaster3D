## 野兽基类
##
## 继承自 CharacterBase，为所有生态系统中的野兽提供通用功能。
## 野兽阵营对所有其他阵营都是中立的，不会主动攻击或被攻击。
##
## 使用方法：
## ```gdscript
## class_name Deer extends BeastBase
## ```
class_name BeastBase
extends CharacterBase

## ============================================================================
## 信号定义
## ============================================================================

## 开始觅食信号
signal foraging_started()

## 觅食完成信号
signal foraging_completed()

## 开始逃跑信号
signal flee_started()

## 逃跑结束信号
signal flee_ended()

## ============================================================================
## 导出属性
## ============================================================================

## 觅食半径
@export var foraging_radius: float = 8.0

## 逃跑距离
@export var flee_distance: float = 12.0

## 觅食超时时间（秒后自动停止觅食）
@export var foraging_timeout: float = 5.0

## 是否主动攻击（大部分野兽不会主动攻击）
@export var is_aggressive: bool = false

## ============================================================================
## 野兽特有属性
## ============================================================================

## 觅食目标位置
var foraging_target: Vector3 = Vector3.ZERO

## 逃跑目标位置
var flee_target: Vector3 = Vector3.ZERO

## 觅食计时器
var foraging_timer: float = 0.0

## 觅食目标（食物、资源等）
var foraging_object: Node3D = null

## 是否正在觅食
var is_foraging: bool = false

## ============================================================================
## 生命周期
## ============================================================================

func _ready() -> void:
	super._ready()
	
	# 设置野兽阵营
	faction = FactionManager.Faction.BEASTS
	
	# 野兽默认不是战斗单位（除非是攻击性的）
	is_combat_unit = is_aggressive
	
	# 创建状态机
	if enable_state_machine and not state_machine:
		state_machine = StateManager.get_instance().create_state_machine_for_character(self)
	
func _process(delta: float) -> void:
	if not is_alive:
		return
	
	# 更新觅食计时器
	if is_foraging:
		foraging_timer += delta
		
		# 觅食超时自动停止
		if foraging_timer > foraging_timeout:
			stop_foraging()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not is_alive:
		return
	
	# 更新回血
	update_regeneration(delta)
	
	# 检查是否需要逃跑（受到攻击时）
	if is_low_health() and current_status != BeastsTypes.BeastStatus.FLEEING:
		start_fleeing()

## ============================================================================
## 野兽行为
## ============================================================================

## 开始觅食
func start_foraging() -> void:
	change_status(BeastsTypes.BeastStatus.WANDERING)
	is_foraging = true
	foraging_timer = 0.0
	_generate_foraging_target()
	foraging_started.emit()
	
## 停止觅食
func stop_foraging() -> void:
	is_foraging = false
	foraging_timer = 0.0
	foraging_object = null
	foraging_completed.emit()
	
## 生成觅食目标
func _generate_foraging_target() -> void:
	foraging_target = global_position + Vector3(
		randf_range(-foraging_radius, foraging_radius),
		0.0,
		randf_range(-foraging_radius, foraging_radius)
	)
	
## 开始逃跑
func start_fleeing() -> void:
	change_status(BeastsTypes.BeastStatus.FLEEING)
	flee_started.emit()
	_generate_flee_target()
	
## 停止逃跑
func stop_fleeing() -> void:
	flee_ended.emit()
	change_status(BeastsTypes.BeastStatus.IDLE)
	
## 生成逃跑目标
func _generate_flee_target() -> void:
	# 远离威胁源逃跑
	var threat_direction = Vector3.ZERO
	if current_target and is_instance_valid(current_target):
		threat_direction = (global_position - current_target.global_position).normalized()
	else:
		# 随机方向逃跑
		threat_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	
	flee_target = global_position + threat_direction * flee_distance
	
## ============================================================================
## 查找方法
## ============================================================================

## 查找附近的食物
func find_nearby_food(max_distance: float = -1.0) -> Node3D:
	var search_distance = max_distance if max_distance > 0 else detection_range
	var nearest_food: Node3D = null
	var nearest_distance := INF
	
	# 获取所有资源点（这里需要根据实际的资源系统调整）
	var all_resources = get_tree().get_nodes_in_group("resources")
	
	for resource in all_resources:
		# 检查是否为食物类型
		if resource.has_method("get_resource_type"):
			var resource_type = resource.get_resource_type()
			if resource_type in ["food", "berry", "herb"]:
				var distance = global_position.distance_to(resource.global_position)
				if distance < search_distance and distance < nearest_distance:
					nearest_distance = distance
					nearest_food = resource
	
	return nearest_food

## 查找威胁源（攻击者）
func find_threat_source(max_distance: float = -1.0) -> CharacterBase:
	var search_distance = max_distance if max_distance > 0 else detection_range
	var nearest_threat: CharacterBase = null
	var nearest_distance := INF
	
	# 获取所有角色
	var all_characters = GameGroups.get_all_characters()
	
	for character in all_characters:
		if character is CharacterBase and character != self:
			var other_char := character as CharacterBase
			
			# 检查是否为威胁（不同阵营且存活）
			if other_char.faction != faction and other_char.is_alive:
				var distance = global_position.distance_to(other_char.global_position)
				if distance < search_distance and distance < nearest_distance:
					nearest_distance = distance
					nearest_threat = other_char
	
	return nearest_threat

## ============================================================================
## 重写基类方法
## ============================================================================

func take_damage(damage: float, attacker: CharacterBase = null) -> void:
	super.take_damage(damage, attacker)
	
	# 野兽受到攻击时逃跑
	if is_alive and current_status != BeastsTypes.BeastStatus.FLEEING:
		start_fleeing()

func die() -> void:
	super.die()
	
	# 停止所有正在进行的行为
	if state_machine:
		state_machine.stop()
	
	# 清理觅食目标
	foraging_object = null
	is_foraging = false

## ============================================================================
## 调试方法
## ============================================================================

func get_beast_info() -> Dictionary:
	var info = get_character_info()
	info["foraging_target"] = foraging_target
	info["flee_target"] = flee_target
	info["is_foraging"] = is_foraging
	info["foraging_timer"] = foraging_timer
	info["is_aggressive"] = is_aggressive
	
	var foraging_object_name := "none"
	if foraging_object and is_instance_valid(foraging_object):
		foraging_object_name = foraging_object.name
	info["foraging_object"] = foraging_object_name
	
	return info
