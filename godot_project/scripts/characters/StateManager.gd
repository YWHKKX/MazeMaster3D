extends Node
class_name StateManager

## 统一状态管理器
## 
## 负责管理所有阵营的状态机系统，提供统一的接口和配置。
## 支持野兽（中立）、英雄（友方）、怪物（敌对）三个阵营的状态机。

## ============================================================================
## 信号定义
## ============================================================================

## 状态机创建信号
signal state_machine_created(character: CharacterBase, faction: Enums.Faction)

## 状态机销毁信号
signal state_machine_destroyed(character: CharacterBase, faction: Enums.Faction)

## ============================================================================
## 状态机配置
## ============================================================================

## 野兽状态机配置
const BEAST_STATES = [
	"IdleState",
	"WanderState", 
	"FleeState",
	"SeekFoodState",
	"ConsumeFoodState",
	"RestState"
]

## 英雄状态机配置
const HERO_STATES = [
	"IdleState",
	"CombatState",
	"PatrolState", 
	"SupportState",
	"RetreatState"
]

## 怪物状态机配置
const MONSTER_STATES = [
	"IdleState",
	"CombatState",
	"ChaseState",
	"PatrolState",
	"GuardState", 
	"RetreatState"
]

## ============================================================================
## 状态机路径配置
## ============================================================================

## 野兽状态机路径
const BEAST_STATE_PATHS = {
	"IdleState": "res://scripts/characters/beasts/beast_states/IdleState.gd",
	"WanderState": "res://scripts/characters/beasts/beast_states/WanderState.gd",
	"FleeState": "res://scripts/characters/beasts/beast_states/FleeState.gd",
	"SeekFoodState": "res://scripts/characters/beasts/beast_states/SeekFoodState.gd",
	"ConsumeFoodState": "res://scripts/characters/beasts/beast_states/ConsumeFoodState.gd",
	"RestState": "res://scripts/characters/beasts/beast_states/RestState.gd"
}

## 英雄状态机路径
const HERO_STATE_PATHS = {
	"IdleState": "res://scripts/characters/heroes/hero_states/IdleState.gd",
	"CombatState": "res://scripts/characters/heroes/hero_states/CombatState.gd",
	"PatrolState": "res://scripts/characters/heroes/hero_states/PatrolState.gd",
	"SupportState": "res://scripts/characters/heroes/hero_states/SupportState.gd",
	"RetreatState": "res://scripts/characters/heroes/hero_states/RetreatState.gd"
}

## 怪物状态机路径
const MONSTER_STATE_PATHS = {
	"IdleState": "res://scripts/characters/monsters/monster_states/IdleState.gd",
	"CombatState": "res://scripts/characters/monsters/monster_states/CombatState.gd",
	"ChaseState": "res://scripts/characters/monsters/monster_states/ChaseState.gd",
	"PatrolState": "res://scripts/characters/monsters/monster_states/PatrolState.gd",
	"GuardState": "res://scripts/characters/monsters/monster_states/GuardState.gd",
	"RetreatState": "res://scripts/characters/monsters/monster_states/RetreatState.gd"
}

## ============================================================================
## 核心方法
## ============================================================================

## 为角色创建状态机
func create_state_machine_for_character(character: CharacterBase) -> StateMachine:
	"""为角色创建适合其阵营的状态机"""
	if not character:
		push_error("StateManager: 无法为null角色创建状态机")
		return null
	
	var state_machine = StateMachine.new()
	state_machine.name = "StateMachine"
	
	# 根据阵营添加相应的状态
	match character.faction:
		Enums.Faction.BEASTS:
			_add_states_to_machine(state_machine, BEAST_STATE_PATHS)
		Enums.Faction.HEROES:
			_add_states_to_machine(state_machine, HERO_STATE_PATHS)
		Enums.Faction.MONSTERS:
			_add_states_to_machine(state_machine, MONSTER_STATE_PATHS)
		_:
			push_warning("StateManager: 未知阵营 %s，使用默认状态机" % character.faction)
			_add_states_to_machine(state_machine, MONSTER_STATE_PATHS)
	
	# 设置状态机属性
	state_machine.debug_mode = character.debug_mode
	state_machine.auto_start = true
	state_machine.initial_state = "IdleState"
	
	# 将状态机添加到角色
	character.add_child(state_machine)
	
	# 发出信号
	state_machine_created.emit(character, character.faction)
	
	if character.debug_mode:
		print("[StateManager] 为 %s 创建状态机，阵营: %s" % [
			character.get_character_name(),
			Enums.faction_to_string(character.faction)
		])
	
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
		
		if character.debug_mode:
			print("[StateManager] 销毁 %s 的状态机" % character.get_character_name())

## 获取阵营的状态列表
func get_faction_states(faction: Enums.Faction) -> Array[String]:
	"""获取指定阵营的状态列表"""
	match faction:
		Enums.Faction.BEASTS:
			return BEAST_STATES
		Enums.Faction.HEROES:
			return HERO_STATES
		Enums.Faction.MONSTERS:
			return MONSTER_STATES
		_:
			return []

## 获取状态脚本路径
func get_state_script_path(faction: Enums.Faction, state_name: String) -> String:
	"""获取状态脚本路径"""
	match faction:
		Enums.Faction.BEASTS:
			return BEAST_STATE_PATHS.get(state_name, "")
		Enums.Faction.HEROES:
			return HERO_STATE_PATHS.get(state_name, "")
		Enums.Faction.MONSTERS:
			return MONSTER_STATE_PATHS.get(state_name, "")
		_:
			return ""

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
				match char_base.faction:
					Enums.Faction.BEASTS:
						stats["beast_machines"] += 1
					Enums.Faction.HEROES:
						stats["hero_machines"] += 1
					Enums.Faction.MONSTERS:
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
## 单例模式
## ============================================================================

## 全局状态管理器实例
static var instance: StateManager = null

func _ready() -> void:
	# 设置单例
	if instance == null:
		instance = self
	else:
		queue_free()

## 获取全局状态管理器实例
static func get_instance() -> StateManager:
	if instance == null:
		instance = StateManager.new()
	return instance
