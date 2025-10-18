## 英雄基类
##
## 继承自 CharacterBase，为所有英雄提供通用功能。
## 具体的英雄类型（如 Knight, Archer 等）继承此类。
##
## 使用方法：
## ```gdscript
## class_name Knight extends HeroBase
## ```
class_name HeroBase
extends CharacterBase

## ============================================================================
## 信号定义
## ============================================================================

## 技能释放信号
signal skill_cast(skill_name: String)

## 等级提升信号
signal leveled_up(new_level: int)

## ============================================================================
## 导出属性
## ============================================================================

## 巡逻半径
@export var patrol_radius: float = 10.0

## 追击距离（超过此距离放弃追击）
@export var pursuit_distance: float = 15.0

## ============================================================================
## 英雄特有属性
## ============================================================================

## 当前经验值
var current_exp: int = 0

## 当前等级
var current_level: int = 1

## 巡逻中心点
var patrol_center: Vector3 = Vector3.ZERO

## 巡逻目标
var patrol_target: Vector3 = Vector3.ZERO

## 技能列表
var skills: Array[String] = []

## 技能冷却时间字典
var skill_cooldowns: Dictionary = {}

## ============================================================================
## 生命周期
## ============================================================================

func _ready() -> void:
	super._ready()
	
	# 设置英雄阵营
	faction = HeroesTypes.Faction.HEROES
	
	# 设置巡逻中心为初始位置
	patrol_center = global_position
	
	# 加入英雄组（使用 GameGroups 常量）
	add_to_group(GameGroups.HEROES)
	
	# 创建状态机
	if enable_state_machine and not state_machine:
		state_machine = StateManager.get_instance().create_state_machine_for_character(self)
	
func _process(delta: float) -> void:
	if not is_alive:
		return
	
	# 更新技能冷却
	_update_skill_cooldowns(delta)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not is_alive:
		return
	
	# 更新回血
	update_regeneration(delta)

## ============================================================================
## 英雄行为
## ============================================================================

## 开始巡逻
func start_patrol() -> void:
	change_status(HeroesTypes.HeroStatus.WANDERING)
	_generate_patrol_target()

## 生成巡逻目标
func _generate_patrol_target() -> void:
	patrol_target = patrol_center + Vector3(
		randf_range(-patrol_radius, patrol_radius),
		0.0,
		randf_range(-patrol_radius, patrol_radius)
	)
	
## 追击敌人
func pursue_enemy(enemy: CharacterBase) -> void:
	if not enemy or not is_instance_valid(enemy):
		return
	
	set_target(enemy)
	change_status(HeroesTypes.HeroStatus.FIGHTING)
	
	# 🔧 [修复] 使用统一的MovementHelper.process_navigation替代NavigationAgent3D
	# 注意：这里只设置目标，实际的移动在_physics_process中处理
	# 或者可以考虑重构为状态机模式，类似怪物单位
	pass

## 放弃追击
func abandon_pursuit() -> void:
	clear_target()
	change_status(HeroesTypes.HeroStatus.WANDERING)
## 检查是否应该放弃追击
func should_abandon_pursuit() -> bool:
	if not current_target or not is_instance_valid(current_target):
		return true
	
	# 超出追击距离
	var distance = global_position.distance_to(patrol_center)
	return distance > pursuit_distance

## ============================================================================
## 技能系统
## ============================================================================

## 释放技能
func cast_skill(skill_name: String) -> bool:
	# 检查技能是否存在
	if skill_name not in skills:
		return false
	
	# 检查技能是否在冷却中
	if is_skill_on_cooldown(skill_name):
		return false
	
	# 释放技能
	skill_cast.emit(skill_name)
	
	# 设置冷却时间（这里使用默认值，子类可以自定义）
	skill_cooldowns[skill_name] = 5.0
	
	return true

## 检查技能是否在冷却中
func is_skill_on_cooldown(skill_name: String) -> bool:
	return skill_cooldowns.has(skill_name) and skill_cooldowns[skill_name] > 0

## 更新技能冷却
func _update_skill_cooldowns(delta: float) -> void:
	for skill in skill_cooldowns.keys():
		if skill_cooldowns[skill] > 0:
			skill_cooldowns[skill] -= delta
			if skill_cooldowns[skill] <= 0:
				skill_cooldowns[skill] = 0

## ============================================================================
## 经验和等级系统
## ============================================================================

## 获得经验
func gain_exp(amount: int) -> void:
	current_exp += amount
	
	# 检查升级
	while current_exp >= GameBalance.XP_FOR_LEVEL_UP:
		level_up()

## 升级
func level_up() -> void:
	current_level += 1
	current_exp -= GameBalance.XP_FOR_LEVEL_UP
	
	# 提升属性
	max_health *= (1.0 + GameBalance.LEVEL_UP_STAT_BONUS)
	current_health = max_health # 升级时恢复满血
	attack *= (1.0 + GameBalance.LEVEL_UP_STAT_BONUS)
	armor *= (1.0 + GameBalance.LEVEL_UP_STAT_BONUS)
	
	leveled_up.emit(current_level)
	
## ============================================================================
## 查找方法（英雄特定）
## ============================================================================

## 查找最近的怪物
func find_nearest_monster(max_distance: float = -1.0) -> MonsterBase:
	var search_distance = max_distance if max_distance > 0 else detection_range
	var nearest_monster: MonsterBase = null
	var nearest_distance := INF
	
	# 获取所有怪物（使用 GameGroups API）
	var all_monsters = GameGroups.get_nodes(GameGroups.MONSTERS)
	
	for monster in all_monsters:
		if monster is MonsterBase:
			var mon := monster as MonsterBase
			
			# 检查是否存活
			if not mon.is_alive:
				continue
			
			# 检查距离
			var distance = global_position.distance_to(mon.global_position)
			if distance < search_distance and distance < nearest_distance:
				nearest_distance = distance
				nearest_monster = mon
	
	return nearest_monster

## 查找最近的建筑
func find_nearest_building(max_distance: float = -1.0) -> Node3D:
	var search_distance = max_distance if max_distance > 0 else detection_range
	var nearest_building: Node3D = null
	var nearest_distance := INF
	
	# 获取所有建筑（使用 GameGroups API）
	var all_buildings = GameGroups.get_nodes(GameGroups.BUILDINGS)
	
	for building in all_buildings:
		# 检查距离
		var distance = global_position.distance_to(building.global_position)
		if distance < search_distance and distance < nearest_distance:
			nearest_distance = distance
			nearest_building = building
	
	return nearest_building

## ============================================================================
## 重写基类方法
## ============================================================================

func take_damage(damage: float, attacker: CharacterBase = null) -> void:
	super.take_damage(damage, attacker)
	
	# 英雄受到攻击时进入战斗状态
	if is_alive and current_status != HeroesTypes.HeroStatus.FIGHTING:
		if attacker:
			set_target(attacker)
			change_status(HeroesTypes.HeroStatus.FIGHTING)

func die() -> void:
	super.die()
	
	# 停止所有正在进行的行为
	if state_machine:
		state_machine.stop()
	
## 获取特定英雄的搜索范围（子类可重写）
func get_search_range() -> float:
	return detection_range

## ============================================================================
## 调试方法
## ============================================================================

func get_hero_info() -> Dictionary:
	var info = get_character_info()
	info["level"] = current_level
	info["exp"] = current_exp
	info["patrol_center"] = patrol_center
	info["patrol_target"] = patrol_target
	info["skills"] = skills
	return info
