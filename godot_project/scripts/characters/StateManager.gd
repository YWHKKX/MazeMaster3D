extends Node
class_name StateManagerClass

## 统一状态管理器
## 
## 负责管理所有阵营的状态机系统，提供统一的接口和配置。
## 支持野兽（中立）、英雄（友方）、怪物（敌对）三个阵营的状态机。

## ============================================================================
## 阵营常量定义
## ============================================================================

## 阵营类型常量
const FACTION_BEASTS = 3
const FACTION_HEROES = 1
const FACTION_MONSTERS = 2

## 阵营名称映射
const FACTION_NAMES = {
	FACTION_BEASTS: "野兽",
	FACTION_HEROES: "英雄",
	FACTION_MONSTERS: "怪物"
}

## ============================================================================
## 信号定义
## ============================================================================

## 状态机创建信号
signal state_machine_created(character: CharacterBase, faction: int)

## 状态机销毁信号
signal state_machine_destroyed(character: CharacterBase, faction: int)

## ============================================================================
## 状态机配置
## ============================================================================

## 统一状态机配置
const FACTION_STATE_CONFIGS = {
	FACTION_BEASTS: {
		"states": ["IdleState", "WanderState", "FleeState", "SeekFoodState", "ConsumeFoodState", "RestState"],
		"paths": {
			"IdleState": "res://scripts/characters/beasts/beast_states/IdleState.gd",
			"WanderState": "res://scripts/characters/beasts/beast_states/WanderState.gd",
			"FleeState": "res://scripts/characters/beasts/beast_states/FleeState.gd",
			"SeekFoodState": "res://scripts/characters/beasts/beast_states/SeekFoodState.gd",
			"ConsumeFoodState": "res://scripts/characters/beasts/beast_states/ConsumeFoodState.gd",
			"RestState": "res://scripts/characters/beasts/beast_states/RestState.gd"
		}
	},
	FACTION_HEROES: {
		"states": ["IdleState", "CombatState", "PatrolState", "SupportState", "RetreatState"],
		"paths": {
			"IdleState": "res://scripts/characters/heroes/hero_states/IdleState.gd",
			"CombatState": "res://scripts/characters/heroes/hero_states/CombatState.gd",
			"PatrolState": "res://scripts/characters/heroes/hero_states/PatrolState.gd",
			"SupportState": "res://scripts/characters/heroes/hero_states/SupportState.gd",
			"RetreatState": "res://scripts/characters/heroes/hero_states/RetreatState.gd"
		}
	},
	FACTION_MONSTERS: {
		"states": ["IdleState", "CombatState", "ChaseState", "PatrolState", "GuardState", "RetreatState"],
		"paths": {
			"IdleState": "res://scripts/characters/monsters/monster_states/IdleState.gd",
			"CombatState": "res://scripts/characters/monsters/monster_states/CombatState.gd",
			"ChaseState": "res://scripts/characters/monsters/monster_states/ChaseState.gd",
			"PatrolState": "res://scripts/characters/monsters/monster_states/PatrolState.gd",
			"GuardState": "res://scripts/characters/monsters/monster_states/GuardState.gd",
			"RetreatState": "res://scripts/characters/monsters/monster_states/RetreatState.gd"
		}
	}
}

## 🔧 [向后兼容] 保留原有的常量定义
const BEAST_STATES = FACTION_STATE_CONFIGS[FACTION_BEASTS]["states"]
const HERO_STATES = FACTION_STATE_CONFIGS[FACTION_HEROES]["states"]
const MONSTER_STATES = FACTION_STATE_CONFIGS[FACTION_MONSTERS]["states"]

const BEAST_STATE_PATHS = FACTION_STATE_CONFIGS[FACTION_BEASTS]["paths"]
const HERO_STATE_PATHS = FACTION_STATE_CONFIGS[FACTION_HEROES]["paths"]
const MONSTER_STATE_PATHS = FACTION_STATE_CONFIGS[FACTION_MONSTERS]["paths"]

## ============================================================================
## 核心方法
## ============================================================================

## 为角色创建状态机
func create_state_machine_for_character(character: CharacterBase) -> StateMachine:
	"""为角色创建适合其阵营和类型的状态机"""
	if not character:
		push_error("StateManager: 无法为null角色创建状态机")
		return null
	
	# 🔧 [特殊处理] 检查是否应该跳过状态机创建
	if _should_skip_state_machine_creation(character):
		return null
	
	var state_machine = StateMachine.new()
	state_machine.name = "StateMachine"
	
	# 根据阵营和角色类型添加相应的状态
	var state_paths = _get_state_paths_for_character(character)
	_add_states_to_machine(state_machine, state_paths)
	
	# 设置状态机属性
	state_machine.debug_mode = character.debug_mode
	state_machine.auto_start = true
	state_machine.initial_state = "IdleState"
	
	# 将状态机添加到角色
	character.add_child(state_machine)
	
	# 发出信号
	state_machine_created.emit(character, character.faction)

	return state_machine

## 为角色添加状态到状态机
func _add_states_to_machine(state_machine: StateMachine, state_paths: Dictionary) -> void:
	"""为状态机添加状态节点"""
	for state_name in state_paths.keys():
		var state_path = state_paths[state_name]
		var state_script = load(state_path)
		
		if state_script:
			var state_node = state_script.new()
			state_node.name = state_name
			state_machine.add_child(state_node)
		else:
			push_error("StateManager: 无法加载状态脚本: %s" % state_path)

## 销毁角色的状态机
func destroy_state_machine_for_character(character: CharacterBase) -> void:
	"""销毁角色的状态机"""
	if not character:
		return
	
	var state_machine = character.get_node_or_null("StateMachine")
	if state_machine:
		state_machine.queue_free()
		state_machine_destroyed.emit(character, character.faction)
		
## 获取阵营的状态列表
func get_faction_states(faction: int) -> Array[String]:
	"""获取指定阵营的状态列表"""
	return _get_faction_config(faction, "states", [])

## 获取状态脚本路径
func get_state_script_path(faction: int, state_name: String) -> String:
	"""获取状态脚本路径"""
	var paths = _get_faction_config(faction, "paths", {})
	return paths.get(state_name, "")

## 🔧 [通用方法] 获取阵营配置
func _get_faction_config(faction: int, config_key: String, default_value):
	"""获取指定阵营的配置项"""
	if FACTION_STATE_CONFIGS.has(faction):
		return FACTION_STATE_CONFIGS[faction].get(config_key, default_value)
	return default_value

## ============================================================================
## 角色类型特殊处理
## ============================================================================

## 检查是否应该跳过状态机创建
func _should_skip_state_machine_creation(character: CharacterBase) -> bool:
	"""检查角色是否使用场景预配置状态机"""
	if not character or not character.character_data:
		return false
	
	var creature_type = character.character_data.creature_type
	# GoblinWorker 和 GoblinEngineer 使用场景预配置状态机
	return creature_type in [MonstersTypes.MonsterType.GOBLIN_WORKER, MonstersTypes.MonsterType.GOBLIN_ENGINEER]

## 根据角色获取状态路径
func _get_state_paths_for_character(character: CharacterBase) -> Dictionary:
	"""根据角色的阵营和类型获取合适的状态路径"""
	if not character:
		return _get_faction_config(FACTION_MONSTERS, "paths", {})
	
	# 根据阵营选择基础状态路径
	var paths = _get_faction_config(character.faction, "paths", {})
	if paths.is_empty():
		push_warning("StateManager: 未知阵营 %s，使用默认状态机" % character.faction)
		return _get_faction_config(FACTION_MONSTERS, "paths", {})
	
	return paths

## ============================================================================
## 调试和统计
## ============================================================================

## 获取所有活跃状态机的统计信息
func get_state_machine_stats() -> Dictionary:
	"""获取状态机统计信息"""
	var stats = {
		"beast_machines": 0,
		"hero_machines": 0,
		"monster_machines": 0,
		"total_machines": 0
	}
	
	# 统计各阵营的状态机数量
	var all_characters = GameGroups.get_all_characters()
	for character in all_characters:
		if character is CharacterBase:
			var char_base = character as CharacterBase
			if char_base.get_node_or_null("StateMachine"):
				stats["total_machines"] += 1
				# 🔧 [优化] 使用阵营常量
				match char_base.faction:
					FACTION_BEASTS:
						stats["beast_machines"] += 1
					FACTION_HEROES:
						stats["hero_machines"] += 1
					FACTION_MONSTERS:
						stats["monster_machines"] += 1
	
	return stats

## 打印状态机统计信息
func print_state_machine_stats() -> void:
	"""打印状态机统计信息"""
	var stats = get_state_machine_stats()
	print("[StateManager] 状态机统计:")
	print("  野兽状态机: %d" % stats["beast_machines"])
	print("  英雄状态机: %d" % stats["hero_machines"])
	print("  怪物状态机: %d" % stats["monster_machines"])
	print("  总状态机数: %d" % stats["total_machines"])

## ============================================================================
## 辅助函数
## ============================================================================

## 获取阵营名称
func _get_faction_name(faction: int) -> String:
	"""获取阵营名称"""
	return FACTION_NAMES.get(faction, "未知")

## ============================================================================
## 单例模式
## ============================================================================

## 全局状态管理器实例
static var instance: StateManagerClass = null

func _ready() -> void:
	# 设置单例
	if instance == null:
		instance = self
	else:
		queue_free()

## 获取全局状态管理器实例
static func get_instance() -> StateManagerClass:
	if instance == null:
		instance = StateManagerClass.new()
	return instance
