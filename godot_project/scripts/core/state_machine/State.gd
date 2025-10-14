## 状态基类
##
## 所有具体状态的父类，定义了状态的生命周期接口。
## 继承此类来创建自定义状态，如 IdleState, MoveToMineState 等。
##
## 使用方法：
## ```gdscript
## class_name IdleState extends State
##
## func enter(data: Dictionary = {}) -> void:
##     print("进入空闲状态")
##
## func physics_update(delta: float) -> void:
##     # 检测条件并切换状态
##     if should_move_to_mine():
##         state_finished.emit("MoveToMineState", {})
## ```
class_name State
extends Node

## 状态结束信号，用于通知状态机切换到下一个状态
## @param next_state: 下一个状态的名称（字符串）
## @param data: 传递给下一个状态的数据（字典）
signal state_finished(next_state: String, data: Dictionary)

## 状态机引用，由状态机在初始化时自动设置
var state_machine: StateMachine = null

## 持有该状态机的节点引用（如 GoblinWorker, GoblinEngineer 等）
## 可以通过此引用访问所有者的属性和方法
var owner_node: Node = null

## ============================================================================
## 生命周期方法（子类需要重写）
## ============================================================================

## 进入状态时调用
## @param _data: 从上一个状态传递过来的数据
func enter(_data: Dictionary = {}) -> void:
	pass

## 退出状态时调用
## 用于清理资源、停止计时器等
func exit() -> void:
	pass

## 每帧调用（在 _process 中）
## 用于处理非物理相关的逻辑，如 UI 更新
## @param _delta: 帧时间间隔（秒）
func update(_delta: float) -> void:
	pass

## 每物理帧调用（在 _physics_process 中）
## 用于处理物理相关的逻辑，如移动、碰撞检测
## @param _delta: 物理帧时间间隔（秒）
func physics_update(_delta: float) -> void:
	pass

## ============================================================================
## 辅助方法
## ============================================================================

## 切换到下一个状态
## @param next_state_name: 下一个状态的名称
## @param data: 传递给下一个状态的数据
func change_to(next_state_name: String, data: Dictionary = {}) -> void:
	state_finished.emit(next_state_name, data)

## 获取状态名称（用于调试）
func get_state_name() -> String:
	return name

## 检查所有者节点是否有效
func is_owner_valid() -> bool:
	return owner_node != null and is_instance_valid(owner_node)

## ============================================================================
## 调试辅助
## ============================================================================

## 调试输出（可以在子类中重写以提供更详细的信息）
func _to_string() -> String:
	return "State[%s]" % name
