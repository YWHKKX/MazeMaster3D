## 状态机管理器
##
## 管理状态的切换、更新和生命周期。
## 将此节点作为角色的子节点，并添加各种状态作为其子节点。
##
## 场景结构示例：
## ```
## GoblinWorker (CharacterBody3D)
## └── StateMachine (Node)
##     ├── IdleState (State)
##     ├── MoveToMineState (State)
##     ├── MiningState (State)
##     └── ...
## ```
##
## 使用方法：
## ```gdscript
## # 在所有者节点中获取状态机
## @onready var state_machine: StateMachine = $StateMachine
##
## # 手动切换状态（通常不需要，状态会自己切换）
## state_machine.change_state("IdleState")
## ```
class_name StateMachine
extends Node

## ============================================================================
## 信号
## ============================================================================

## 状态切换信号
## @param from_state: 之前的状态名称
## @param to_state: 切换到的状态名称
signal state_changed(from_state: String, to_state: String)

## ============================================================================
## 配置属性
## ============================================================================

## 初始状态名称（如果为空，则使用第一个子状态）
@export var initial_state: String = ""

## 是否启用调试模式（在控制台输出状态切换信息）
@export var debug_mode: bool = false

## 是否在启动时自动开始（如果为false，需要手动调用start()）
@export var auto_start: bool = true

## ============================================================================
## 状态管理
## ============================================================================

## 当前活动状态
var current_state: State = null

## 所有状态的字典 {状态名称: State实例}
var states: Dictionary = {}

## 状态机是否正在运行
var is_running: bool = false

## 所有者节点引用（状态机的父节点）
var owner_node: Node = null

## ============================================================================
## 生命周期
## ============================================================================

func _ready() -> void:
	# 获取所有者节点
	owner_node = get_parent()
	
	# 注册所有子状态
	_register_states()
	
	# 如果启用自动开始，则启动状态机
	if auto_start:
		call_deferred("start")

func _process(delta: float) -> void:
	if is_running and current_state != null:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if is_running and current_state != null:
		current_state.physics_update(delta)

## ============================================================================
## 状态机控制
## ============================================================================

## 启动状态机
func start() -> void:
	if is_running:
		push_warning("StateMachine: 状态机已经在运行")
		return
	
	if states.is_empty():
		push_error("StateMachine: 没有可用的状态")
		return
	
	is_running = true
	
	# 确定初始状态
	var start_state_name := initial_state
	if start_state_name.is_empty() or not states.has(start_state_name):
		# 使用第一个状态作为初始状态
		var state_names := states.keys()
		if state_names.size() > 0:
			start_state_name = state_names[0]
		else:
			push_error("StateMachine: 无法找到初始状态")
			return
	
	# 切换到初始状态
	change_state(start_state_name)
	
	# 状态机已启动

## 停止状态机
func stop() -> void:
	if not is_running:
		return
	
	if current_state:
		current_state.exit()
		current_state = null
	
	is_running = false
	
	# 状态机已停止

## 暂停状态机（保持当前状态，但停止更新）
func pause() -> void:
	is_running = false
	# 状态机已暂停

## 恢复状态机
func resume() -> void:
	is_running = true
	# 状态机已恢复

## ============================================================================
## 状态切换
## ============================================================================

## 切换到指定状态
## @param new_state_name: 目标状态的名称
## @param data: 传递给新状态的数据
func change_state(new_state_name: String, data: Dictionary = {}) -> void:
	# 检查目标状态是否存在
	if not states.has(new_state_name):
		push_error("StateMachine: 状态 '%s' 不存在" % new_state_name)
		return
	
	var old_state_name := ""
	
	# 退出当前状态
	if current_state:
		old_state_name = current_state.get_state_name()
		current_state.exit()
		
		# 退出状态
	
	# 切换到新状态
	current_state = states[new_state_name]
	current_state.enter(data)
	
	# 发出状态切换信号
	state_changed.emit(old_state_name, new_state_name)
	
	# 状态已切换

## ============================================================================
## 状态查询
## ============================================================================

## 获取当前状态名称
func get_current_state_name() -> String:
	if current_state:
		return current_state.get_state_name()
	return ""

## 检查是否处于指定状态
## @param state_name: 状态名称
func is_in_state(state_name: String) -> bool:
	return current_state != null and current_state.get_state_name() == state_name

## 获取所有状态名称列表
func get_state_names() -> Array[String]:
	var names: Array[String] = []
	for key in states.keys():
		names.append(key)
	return names

## 检查状态是否存在
func has_state(state_name: String) -> bool:
	return states.has(state_name)

## ============================================================================
## 内部方法
## ============================================================================

## 注册所有子状态
func _register_states() -> void:
	states.clear()
	
	for child in get_children():
		if child is State:
			var state := child as State
			
			# 设置状态的引用
			state.state_machine = self
			state.owner_node = owner_node
			
			# 连接状态完成信号
			if not state.state_finished.is_connected(_on_state_finished):
				state.state_finished.connect(_on_state_finished)
			
			# 注册状态
			states[state.name] = state
			
			# 状态已注册
	
	# 状态注册完成

## 状态完成信号处理
func _on_state_finished(next_state: String, data: Dictionary) -> void:
	change_state(next_state, data)

## ============================================================================
## 调试辅助
## ============================================================================

## 获取状态机信息（用于调试）
func get_debug_info() -> String:
	var info := "StateMachine Debug Info:\n"
	info += "  Running: %s\n" % is_running
	info += "  Current State: %s\n" % get_current_state_name()
	info += "  Available States: %s\n" % ", ".join(get_state_names())
	return info

## 打印调试信息
func print_debug_info() -> void:
	# 调试信息已移除，减少日志输出
	pass

func _to_string() -> String:
	return "StateMachine[current=%s, states=%d]" % [get_current_state_name(), states.size()]
