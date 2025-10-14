extends Node
class_name CombatManager

# 战斗管理器 - 管理所有战斗逻辑和AI行为
# 参考 COMBAT_SYSTEM.md 和 CHARACTER_DESIGN.md

# 导入必要的类
const BuildingManager = preload("BuildingManager.gd")
# 日志管理器实例（全局变量）
# 战斗状态枚举
enum CombatState {
	IDLE, # 空闲
	MOVING, # 移动中
	FIGHTING, # 战斗中
	FLEEING, # 逃跑中
	WANDERING, # 游荡中
	EXPLORING, # 探索中
	PATROLLING # 巡逻中
}

# 攻击类型枚举
enum AttackType {
	MELEE, # 近战攻击
	RANGED, # 远程攻击
	MAGIC, # 魔法攻击
	AREA_DAMAGE, # 范围伤害
	AREA_HEAL # 范围治疗
}

# 战斗配置
var config = {
	"detection_range": 150.0, # 检测范围150像素
	"attack_range_multiplier": 2.5, # 近战追击范围倍数
	"ranged_pursuit_multiplier": 1.0, # 远程追击范围倍数
	"attack_cooldown": 1.0, # 攻击冷却时间1秒
	"regeneration_delay": 3.0, # 生命恢复延迟3秒
	"regeneration_rate": 2.0, # 每秒恢复2点生命值
	"flee_health_threshold": 0.3, # 逃跑血量阈值30%
	"combat_speed_multiplier": 1.2, # 战斗移动速度倍数
	"waiting_timeout": 2.0, # 等待超时时间2秒
	"state_change_cooldown": 0.5 # 状态切换冷却0.5秒
}


# 战斗单位数据结构
class CombatUnit:
	var character: CharacterBase
	var combat_state: CombatState = CombatState.IDLE
	var attack_targets: Array = []
	var current_target: CharacterBase = null
	var last_attack_time: float = 0.0
	var last_damage_time: float = 0.0
	var is_in_combat: bool = false
	var waiting_timer: float = 0.0
	var last_state_change: float = 0.0
	var pursuit_range: float = 0.0
	var attack_range: float = 0.0

	func _init(char: CharacterBase):
		character = char
		_update_ranges()

	func _update_ranges():
		"""更新攻击和追击范围"""
		attack_range = _calculate_attack_range()
		pursuit_range = _calculate_pursuit_range()

	func _calculate_attack_range() -> float:
		"""计算攻击范围（直接使用角色属性）"""
		return character.attack_range

	func _calculate_pursuit_range() -> float:
		"""计算追击范围（直接使用角色属性）"""
		return character.chase_range

	func can_attack() -> bool:
		"""检查是否可以攻击"""
		var current_time = Time.get_ticks_msec() / 1000.0 # 转换为秒
		return current_time - last_attack_time >= 1.0 # 使用固定值替代config

	func needs_regeneration() -> bool:
		"""检查是否需要生命恢复"""
		var current_time = Time.get_ticks_msec() / 1000.0 # 转换为秒
		return (
			character.health < character.max_health
			and not is_in_combat
			and (current_time - last_damage_time) >= 5.0
		) # 使用固定值替代config

	func should_flee() -> bool:
		"""检查是否应该逃跑"""
		return character.health <= character.max_health * 0.3 # 使用固定值替代config

	func get_nearest_target() -> CharacterBase:
		"""获取最近的攻击目标"""
		if attack_targets.is_empty():
			return null

		var nearest_target: CharacterBase = null
		var min_distance = INF

		for target in attack_targets:
			if target and target.is_alive:
				var distance = character.position.distance_to(target.position)
				if distance < min_distance:
					min_distance = distance
					nearest_target = target

		return nearest_target

	func add_attack_target(target: CharacterBase):
		"""添加攻击目标"""
		if target and target.is_alive and not attack_targets.has(target):
			attack_targets.append(target)

	func remove_attack_target(target: CharacterBase):
		"""移除攻击目标"""
		var index = attack_targets.find(target)
		if index >= 0:
			attack_targets.remove_at(index)
			if current_target == target:
				current_target = null

	func clear_attack_targets():
		"""清空攻击目标"""
		attack_targets.clear()
		current_target = null
		is_in_combat = false


# 战斗单位存储
var combat_units: Array[CombatUnit] = []
var non_combat_units: Array[CombatUnit] = []

# 管理器引用（通过 GameServices 访问）
var character_manager = null
var building_manager = null


func _ready():
	"""初始化战斗管理器"""
	LogManager.info("CombatManager - 初始化开始")
	_initialize_combat_system()
	call_deferred("_setup_manager_references")
	LogManager.info("CombatManager - 初始化完成")

func _initialize_combat_system():
	"""初始化战斗系统"""
	# 设置初始配置
	pass

func _setup_manager_references():
	"""使用 GameServices 设置管理器引用"""
	character_manager = GameServices.character_manager
	building_manager = GameServices.building_manager


func _process(_delta: float):
	"""每帧更新战斗逻辑"""
	if not character_manager:
		return

	# 更新战斗单位列表
	_update_combat_units()

	# 执行五阶段战斗处理
	_phase_combat_detection(_delta)
	_phase_combat_units(_delta)
	_phase_non_combat_units(_delta)
	_phase_building_combat(_delta)
	_phase_health_regeneration(_delta)


func _update_combat_units():
	"""更新战斗单位列表"""
	combat_units.clear()
	non_combat_units.clear()

	# 使用 GameGroups API 获取所有角色
	var all_monsters = GameGroups.get_nodes(GameGroups.MONSTERS)
	var all_heroes = GameGroups.get_nodes(GameGroups.HEROES)
	var all_characters = all_monsters + all_heroes

	for char in all_characters:
		if char and char.has_method("is_alive") and char.is_alive():
			var combat_unit = CombatUnit.new(char)

			# 根据角色类型分类
			if char.get("is_combat_unit") == true:
				combat_units.append(combat_unit)
			else:
				non_combat_units.append(combat_unit)


func _phase_combat_detection(_delta: float):
	"""阶段1: 战斗检测与状态更新"""
	for unit in combat_units:
		_detect_enemies(unit)
		_update_combat_state(unit)


func _detect_enemies(unit: CombatUnit):
	"""检测敌人"""
	if not character_manager:
		return

	# 清空当前攻击目标
	unit.clear_attack_targets()

	# 获取敌对单位
	var enemies = _get_enemy_units(unit.character)

	# 检测范围内的敌人
	for enemy in enemies:
		if enemy and enemy.is_alive:
			var distance = unit.character.position.distance_to(enemy.position)
			if distance <= 150.0: # 使用固定值替代config
				unit.add_attack_target(enemy)

	# 检测建筑目标
	_detect_building_targets(unit)


func _get_enemy_units(character: CharacterBase) -> Array:
	"""获取敌对单位"""
	if not character_manager:
		return []

	# 根据阵营获取敌对单位
	if character.faction == Enums.Faction.HEROES:
		return GameGroups.get_nodes(GameGroups.MONSTERS)
	
	return GameGroups.get_nodes(GameGroups.HEROES)


func _detect_building_targets(unit: CombatUnit):
	"""检测建筑目标"""
	if not building_manager:
		return

	# 英雄可以攻击建筑
	if unit.character.faction == Enums.Faction.HEROES:
		for building in building_manager.buildings:
			if building and building.status != BuildingManager.BuildingStatus.DESTROYED:
				var distance = unit.character.position.distance_to(building.position)
				if distance <= 150.0: # 使用固定值替代config
					# 将建筑作为攻击目标（需要特殊处理）
					pass # 暂时留空，后续实现建筑攻击逻辑


func _update_combat_state(unit: CombatUnit):
	"""更新战斗状态"""
	if unit.attack_targets.size() > 0:
		unit.is_in_combat = true
		unit.current_target = unit.get_nearest_target()
	else:
		unit.is_in_combat = false
		unit.current_target = null


func _phase_combat_units(_delta: float):
	"""阶段2: 战斗单位处理"""
	for unit in combat_units:
		_process_unit_combat(unit, _delta)


func _process_unit_combat(unit: CombatUnit, _delta: float):
	"""处理单位战斗逻辑"""
	if not unit.is_in_combat or not unit.current_target:
		# 非战斗状态处理
		_handle_non_combat_behavior(unit, _delta)
		return

	var target = unit.current_target
	
	# 修正：从单位边缘计算距离，而不是中心点距离
	# 中心距离减去两者的碰撞半径之和，得到边缘距离
	var center_distance = unit.character.position.distance_to(target.position)
	var collision_sum = unit.character.get_collision_radius() + target.get_collision_radius()
	var edge_distance = center_distance - collision_sum
	
	# 使用边缘距离判断是否在攻击范围内
	if edge_distance <= unit.attack_range:
		# 在攻击范围内，执行攻击
		_execute_attack_sequence(unit, target, _delta)
	else:
		# 不在攻击范围内，执行追击
		_handle_combat_pursuit(unit, target, _delta, center_distance)


func _execute_attack_sequence(unit: CombatUnit, target: CharacterBase, _delta: float):
	"""执行攻击序列"""
	if not unit.can_attack():
		return

	var current_time = Time.get_ticks_msec() / 1000.0
	var attacker = unit.character
	var attack_type = attacker.get("attack_type")
	
	# 根据攻击类型执行不同逻辑
	if _is_ranged_attack(attack_type):
		# 远程攻击：生成投射物
		_execute_ranged_attack(attacker, target)
	else:
		# 近战攻击：直接伤害
		var damage = _calculate_damage(attacker, target)
		target.take_damage(int(damage), attacker)
		
		# 触发击退效果
		_execute_knockback_effect(attacker, target, damage)
		
		LogManager.info("攻击执行: " + attacker.get_character_name() + " 对 " + target.get_character_name() + " 造成 " + str(damage) + " 伤害")
	
	# 更新攻击时间和状态
	unit.last_attack_time = current_time
	unit.combat_state = CombatState.FIGHTING

func _is_ranged_attack(attack_type) -> bool:
	"""检查是否为远程攻击"""
	return attack_type in [
		Enums.AttackType.RANGED,
		Enums.AttackType.RANGED_BOW,
		Enums.AttackType.RANGED_GUN,
		Enums.AttackType.RANGED_CROSSBOW,
		Enums.AttackType.MAGIC_SINGLE
	]

func _execute_ranged_attack(attacker: CharacterBase, target: CharacterBase):
	"""执行远程攻击"""
	# TODO: 需要ProjectileManager引用
	# attacker.execute_ranged_attack(target, projectile_manager)
	LogManager.info("远程攻击: " + attacker.get_character_name() + " → " + target.get_character_name())


func _calculate_damage(attacker: CharacterBase, target: CharacterBase) -> float:
	"""计算伤害"""
	var base_damage = attacker.attack_damage
	var armor_reduction = target.defense * 0.1 # 每点护甲减少10%伤害
	var final_damage = max(1.0, base_damage - armor_reduction)
	return final_damage


func _execute_knockback_effect(attacker: CharacterBase, target: CharacterBase, _damage: float):
	"""执行击退效果"""
	# 计算击退方向（从攻击者指向被击者）
	var direction = (target.global_position - attacker.global_position).normalized()
	
	# 根据攻击类型决定击退力度
	var knockback_force = 15.0 # 默认中等击退
	var attack_type = attacker.get("attack_type")
	if attack_type == Enums.AttackType.MELEE_AXE:
		knockback_force = 30.0 # 斧类强击退
	elif attack_type == Enums.AttackType.MELEE_SPEAR:
		knockback_force = 20.0 # 矛类中强击退
	elif attack_type == Enums.AttackType.MAGIC_AOE or attack_type == Enums.AttackType.AREA:
		knockback_force = 25.0 # AOE魔法强击退
	elif attack_type == Enums.AttackType.HEAVY:
		knockback_force = 25.0 # 重击强击退
	
	# 应用击退
	if target.has_method("apply_knockback"):
		target.apply_knockback(direction, knockback_force)
	
	LogManager.info("击退效果: " + attacker.get_character_name() + " 击退 " + target.get_character_name() + " 力度:" + str(knockback_force))


func _handle_combat_pursuit(unit: CombatUnit, target: CharacterBase, _delta: float, distance: float):
	"""处理战斗追击"""
	if not target.is_alive:
		unit.remove_attack_target(target)
		return

	# 检查是否超出追击范围
	if distance > unit.pursuit_range:
		unit.remove_attack_target(target)
		unit.is_in_combat = false
		unit.combat_state = CombatState.WANDERING
		return

	# 执行追击移动
	unit.combat_state = CombatState.MOVING
	_move_towards_target(unit.character, target.position, _delta)


func _move_towards_target(character: CharacterBase, target_position: Vector3, _delta: float):
	"""朝目标移动 - 使用统一的MovementHelper API"""
	# 🔧 [修复] 使用统一的MovementHelper.process_navigation替代直接位置修改
	var move_result = MovementHelper.process_navigation(
		character,
		target_position,
		_delta,
		"CombatManager"
	)
	
	# 根据移动结果处理状态（可选）
	match move_result:
		MovementHelper.MoveResult.FAILED_NO_PATH:
			# 寻路失败，可能需要重新评估目标
			pass
		MovementHelper.MoveResult.FAILED_STUCK:
			# 卡住，可能需要改变策略
			pass
		MovementHelper.MoveResult.REACHED:
			# 已到达目标
			pass
		MovementHelper.MoveResult.MOVING:
			# 正在移动
			pass


func _phase_non_combat_units(_delta: float):
	"""阶段3: 非战斗单位处理"""
	for unit in non_combat_units:
		_handle_non_combat_behavior(unit, _delta)


func _handle_non_combat_behavior(unit: CombatUnit, _delta: float):
	"""处理非战斗单位行为"""
	var character = unit.character

	# 检查是否被攻击
	if _is_under_attack(character):
		_handle_under_attack(character)
		return

	# 根据单位类型处理不同行为
	if character.get("creature_type") == Enums.CreatureType.GOBLIN_WORKER:
		_handle_worker_behavior(unit, _delta)
	elif character.get("creature_type") == Enums.CreatureType.GOBLIN_ENGINEER:
		_handle_engineer_behavior(unit, _delta)
	else:
		_handle_generic_non_combat_behavior(unit, _delta)


func _is_under_attack(_character: CharacterBase) -> bool:
	"""检查是否被攻击"""
	# 这里可以添加被攻击检测逻辑
	return false


func _handle_under_attack(character: CharacterBase):
	"""处理被攻击情况"""
	# 非战斗单位被攻击时逃跑
	if character.has_method("_change_status"):
		character._change_status(CombatState.FLEEING)


func _handle_worker_behavior(unit: CombatUnit, _delta: float):
	"""处理苦工行为"""
	# 苦工有特殊的工作逻辑，由GoblinWorker类处理
	pass


func _handle_engineer_behavior(unit: CombatUnit, _delta: float):
	"""处理工程师行为"""
	# 工程师有特殊的工作逻辑，由GoblinEngineer类处理
	pass


func _handle_generic_non_combat_behavior(unit: CombatUnit, _delta: float):
	"""处理通用非战斗单位行为"""
	# 检查状态切换
	_check_state_transition(unit, _delta)

	# 根据状态执行行为
	match unit.combat_state:
		CombatState.IDLE:
			_handle_idle_state(unit, _delta)
		CombatState.WANDERING:
			_handle_wandering_state(unit, _delta)
		CombatState.EXPLORING:
			_handle_exploring_state(unit, _delta)
		CombatState.FLEEING:
			_handle_fleeing_state(unit, _delta)


func _check_state_transition(unit: CombatUnit, _delta: float):
	"""检查状态切换"""
	var current_time = Time.get_ticks_msec() / 1000.0 # 转换为秒

	# 检查等待超时
	if (
		unit.combat_state
		in [CombatState.IDLE, CombatState.WANDERING, CombatState.EXPLORING, CombatState.PATROLLING]
	):
		unit.waiting_timer += _delta
		if unit.waiting_timer >= 2.0: # 使用固定值替代config
			unit.combat_state = CombatState.WANDERING
			unit.waiting_timer = 0.0

	# 检查状态切换冷却
	if current_time - unit.last_state_change < 0.5: # 使用固定值替代config
		return

	unit.last_state_change = current_time


func _handle_idle_state(unit: CombatUnit, _delta: float):
	"""处理空闲状态"""
	# 空闲状态不执行任何动作
	pass


func _handle_wandering_state(unit: CombatUnit, _delta: float):
	"""处理游荡状态 - 使用统一的MovementHelper API"""
	# 🔧 [修复] 使用统一的MovementHelper.process_navigation替代直接位置修改
	# 生成随机目标位置（在当前位置附近）
	var random_offset = Vector3(
		randf_range(-5, 5), # X方向随机偏移
		0,
		randf_range(-5, 5) # Z方向随机偏移
	)
	var random_target = unit.character.global_position + random_offset
	
	var move_result = MovementHelper.process_navigation(
		unit.character,
		random_target,
		_delta,
		"CombatManager.Wandering"
	)
	
	# 根据移动结果处理状态
	match move_result:
		MovementHelper.MoveResult.FAILED_NO_PATH, MovementHelper.MoveResult.FAILED_STUCK:
			# 随机目标不可达，选择新的随机目标
			pass
		MovementHelper.MoveResult.REACHED:
			# 到达随机目标，可以切换到其他状态
			pass
		MovementHelper.MoveResult.MOVING:
			# 正在向随机目标移动
			pass


func _handle_exploring_state(unit: CombatUnit, _delta: float):
	"""处理探索状态"""
	# 寻找地牢之心
	var dungeon_heart_pos = Vector3(25, 0, 25) # 地牢之心位置
	_move_towards_target(unit.character, dungeon_heart_pos, _delta)


func _handle_fleeing_state(unit: CombatUnit, _delta: float):
	"""处理逃跑状态"""
	# 寻找最近的敌人并远离
	var nearest_enemy = _find_nearest_enemy(unit.character)
	if nearest_enemy:
		var flee_direction = (unit.character.position - nearest_enemy.position).normalized()
		var flee_target = unit.character.position + flee_direction * 100.0
		_move_towards_target(unit.character, flee_target, _delta)


func _find_nearest_enemy(character: CharacterBase) -> CharacterBase:
	"""寻找最近的敌人"""
	var enemies = _get_enemy_units(character)
	var nearest_enemy: CharacterBase = null
	var min_distance = INF

	for enemy in enemies:
		if enemy and enemy.is_alive:
			var distance = character.position.distance_to(enemy.position)
			if distance < min_distance:
				min_distance = distance
				nearest_enemy = enemy

	return nearest_enemy


func _phase_building_combat(_delta: float):
	"""阶段4: 建筑攻击处理"""
	# 这里可以添加建筑攻击逻辑
	pass


func _phase_health_regeneration(_delta: float):
	"""阶段5: 生命值恢复"""
	for unit in combat_units:
		if unit.needs_regeneration():
			unit.character.health = min(
				unit.character.health + 10.0 * _delta, unit.character.max_health
			) # 使用固定值替代config


# 调试功能
func debug_print_combat_status():
	"""调试：打印战斗状态"""
	# LogManager.info("=== 战斗系统调试信息 ===")
	# LogManager.info("战斗单位数量: " + " " + str(combat_units.size()))
	# LogManager.info("非战斗单位数量: " + " " + str(non_combat_units.size()))

	for i in range(combat_units.size()):
		var unit = combat_units[i]
		# LogManager.info("战斗单位 " + str(i) + ": " + unit.character.get_character_name() + " 状态=" + str(unit.combat_state) + " 目标数=" + str(unit.attack_targets.size()))


func get_debug_info() -> String:
	"""获取调试信息"""
	return "战斗单位: " + str(combat_units.size()) + " 非战斗单位: " + str(non_combat_units.size())
