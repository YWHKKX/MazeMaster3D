# 状态机系统使用指南

## 概述

本状态机系统是一个通用的有限状态机（FSM）实现，用于管理游戏对象的行为状态。它提供了清晰的状态生命周期管理、状态间数据传递和调试功能。

## 核心组件

### State.gd - 状态基类
所有具体状态的父类，定义了状态的生命周期接口。

**生命周期方法**：
- `enter(data: Dictionary)` - 进入状态时调用
- `exit()` - 退出状态时调用
- `update(delta: float)` - 每帧调用（_process）
- `physics_update(delta: float)` - 每物理帧调用（_physics_process）

### StateMachine.gd - 状态机管理器
管理状态的注册、切换和更新。

**主要功能**：
- 自动注册子节点状态
- 状态切换和生命周期管理
- 状态间数据传递
- 调试模式和日志输出

## 快速开始

### 1. 创建场景结构

```
GoblinWorker (CharacterBody3D)
├── Model (MeshInstance3D)
├── CollisionShape3D
├── NavigationAgent3D
└── StateMachine (Node)
    ├── IdleState (State)
    ├── MoveToMineState (State)
    ├── MiningState (State)
    ├── ReturnToBaseState (State)
    └── DepositGoldState (State)
```

### 2. 创建自定义状态

```gdscript
# IdleState.gd
class_name IdleState
extends State

func enter(data: Dictionary = {}) -> void:
    print("苦工进入空闲状态")
    # 播放空闲动画
    if owner_node.has_node("AnimationPlayer"):
        owner_node.get_node("AnimationPlayer").play("idle")

func physics_update(delta: float) -> void:
    # 检查是否有可挖掘的金矿
    var nearest_mine = owner_node.find_nearest_gold_mine()
    
    if nearest_mine:
        # 切换到移动至金矿状态，并传递金矿引用
        change_to("MoveToMineState", {"target_mine": nearest_mine})
    elif owner_node.current_gold >= owner_node.max_gold:
        # 背包已满，返回基地
        change_to("ReturnToBaseState")

func exit() -> void:
    print("苦工离开空闲状态")
```

### 3. 在所有者节点中使用状态机

```gdscript
# GoblinWorker.gd
extends CharacterBody3D

@onready var state_machine: StateMachine = $StateMachine

var current_gold: int = 0
var max_gold: int = 100

func _ready():
    # 状态机会自动启动
    # 也可以手动启动：state_machine.start()
    pass

func find_nearest_gold_mine():
    # 查找最近的金矿逻辑
    pass
```

## 详细示例

### 示例 1：简单的状态切换

```gdscript
# MoveToMineState.gd
class_name MoveToMineState
extends State

var target_mine: Node3D

func enter(data: Dictionary = {}) -> void:
    if data.has("target_mine"):
        target_mine = data["target_mine"]
    else:
        # 没有目标，返回空闲状态
        change_to("IdleState")
        return
    
    # 设置导航目标
    owner_node.get_node("NavigationAgent3D").target_position = target_mine.global_position

func physics_update(delta: float) -> void:
    # 检查是否到达金矿
    if owner_node.global_position.distance_to(target_mine.global_position) < 2.0:
        # 到达金矿，切换到挖矿状态
        change_to("MiningState", {"target_mine": target_mine})

func exit() -> void:
    target_mine = null
```

### 示例 2：带计时器的状态

```gdscript
# MiningState.gd
class_name MiningState
extends State

var target_mine: Node3D
var mining_timer: float = 0.0
var mining_interval: float = 1.0  # 每秒挖一次

func enter(data: Dictionary = {}) -> void:
    target_mine = data.get("target_mine")
    mining_timer = 0.0
    
    # 播放挖矿动画
    owner_node.get_node("AnimationPlayer").play("mining")

func physics_update(delta: float) -> void:
    mining_timer += delta
    
    if mining_timer >= mining_interval:
        mining_timer = 0.0
        
        # 挖掘金币
        var gold_mined = target_mine.extract_gold(10)
        owner_node.current_gold += gold_mined
        
        # 检查是否已满
        if owner_node.current_gold >= owner_node.max_gold:
            change_to("ReturnToBaseState")
        # 检查金矿是否枯竭
        elif target_mine.is_depleted():
            change_to("IdleState")

func exit() -> void:
    # 停止挖矿动画
    owner_node.get_node("AnimationPlayer").stop()
```

### 示例 3：全局状态切换（逃跑）

任何状态都可以切换到逃跑状态，这是一种常见的模式：

```gdscript
# 在任何状态的 physics_update 中
func physics_update(delta: float) -> void:
    # 检查敌人
    if owner_node.detect_enemies():
        change_to("EscapeState", {"threat_level": "high"})
        return
    
    # 正常的状态逻辑...
```

## 状态间数据传递

### 通过字典传递数据

```gdscript
# 从 IdleState 传递数据到 MoveToMineState
change_to("MoveToMineState", {
    "target_mine": nearest_mine,
    "priority": "high",
    "reason": "player_command"
})

# 在 MoveToMineState.enter() 中接收
func enter(data: Dictionary = {}) -> void:
    var target = data.get("target_mine")
    var priority = data.get("priority", "normal")  # 默认值
    var reason = data.get("reason", "auto")
```

### 使用所有者节点共享数据

```gdscript
# 在所有者节点中定义共享变量
# GoblinWorker.gd
var shared_target: Node3D
var shared_path: Array[Vector3]

# 在状态中访问
func enter(data: Dictionary = {}) -> void:
    owner_node.shared_target = data["target_mine"]
```

## 调试技巧

### 1. 启用调试模式

在 Godot 编辑器中选择 StateMachine 节点，勾选 `Debug Mode`。

这将在控制台输出：
```
[StateMachine] 注册状态: IdleState
[StateMachine] 注册状态: MoveToMineState
[StateMachine] 启动，初始状态: IdleState
[StateMachine] 切换状态: IdleState → MoveToMineState
```

### 2. 在代码中打印状态信息

```gdscript
# 打印当前状态
print("当前状态: ", state_machine.get_current_state_name())

# 打印所有状态
print("所有状态: ", state_machine.get_state_names())

# 检查是否在特定状态
if state_machine.is_in_state("MiningState"):
    print("正在挖矿")

# 打印完整调试信息
state_machine.print_debug_info()
```

### 3. 自定义状态调试信息

```gdscript
# 在自定义状态中重写 _to_string()
func _to_string() -> String:
    return "MiningState[target=%s, gold=%d/%d]" % [
        target_mine.name if target_mine else "none",
        owner_node.current_gold,
        owner_node.max_gold
    ]
```

## 最佳实践

### 1. 状态命名规范

- 使用清晰的动词或形容词命名状态
- 推荐格式：`<动作>State` 或 `<状态描述>State`
- 例如：`IdleState`, `MovingState`, `AttackingState`

### 2. 状态职责单一

每个状态应该只负责一件事：

✅ **好的做法**：
```
IdleState - 只负责决策下一步做什么
MoveToMineState - 只负责移动到金矿
MiningState - 只负责挖矿
```

❌ **不好的做法**：
```
WorkState - 同时处理移动、挖矿、返回（职责过多）
```

### 3. 避免状态间循环依赖

```gdscript
# ❌ 不推荐：A → B → A → B 的循环
# IdleState → MoveState → IdleState → MoveState

# ✅ 推荐：使用中间状态或条件判断
# IdleState → MoveState → ReachedState → (判断) → IdleState 或 WorkState
```

### 4. 使用信号通知外部

```gdscript
# 在状态中发出信号
signal mining_completed(gold_amount: int)

func physics_update(delta: float) -> void:
    if mining_done:
        owner_node.emit_signal("mining_completed", gold_collected)
        change_to("IdleState")
```

### 5. 清理资源

始终在 `exit()` 中清理资源：

```gdscript
func exit() -> void:
    # 停止计时器
    if mining_timer:
        mining_timer.stop()
    
    # 清理引用
    target_mine = null
    
    # 停止动画
    if owner_node.has_node("AnimationPlayer"):
        owner_node.get_node("AnimationPlayer").stop()
```

## 高级用法

### 1. 状态栈（回退到上一个状态）

```gdscript
# 在 StateMachine 中添加
var state_stack: Array[String] = []

func change_state_with_history(new_state: String, data: Dictionary = {}) -> void:
    if current_state:
        state_stack.append(current_state.get_state_name())
    change_state(new_state, data)

func pop_state() -> void:
    if state_stack.size() > 0:
        var previous_state = state_stack.pop_back()
        change_state(previous_state)
```

### 2. 全局状态（任何时候都可以切换）

```gdscript
# 在 StateMachine 中添加
var global_states: Array[String] = ["PausedState", "DeathState"]

func can_change_to(state_name: String) -> bool:
    return state_name in global_states or states.has(state_name)
```

### 3. 状态组（多个状态的集合）

```gdscript
# 定义状态组
const COMBAT_STATES = ["AttackingState", "DefendingState", "FleeingState"]
const WORK_STATES = ["MiningState", "BuildingState", "CarryingState"]

# 检查是否在某个状态组中
func is_in_combat() -> bool:
    return state_machine.get_current_state_name() in COMBAT_STATES
```

## 常见问题

### Q: 状态切换后数据丢失？
A: 使用所有者节点的成员变量存储需要跨状态共享的数据，或通过 `change_to()` 传递数据。

### Q: 状态机不更新？
A: 检查 `auto_start` 是否为 true，或手动调用 `state_machine.start()`。

### Q: 找不到状态？
A: 确保状态节点是 StateMachine 的直接子节点，并且继承自 State 类。

### Q: 状态切换延迟一帧？
A: 这是正常的，因为 Godot 的信号是异步的。如果需要立即切换，可以直接调用 `state_machine.change_state()`。

## 与 Python 版本的对应

| Python 版本        | Godot 版本              | 说明         |
| ------------------ | ----------------------- | ------------ |
| `State` 类         | `State.gd`              | 状态基类     |
| `StateMachine` 类  | `StateMachine.gd`       | 状态机管理器 |
| `enter()`          | `enter(data)`           | 支持数据传递 |
| `update()`         | `update(delta)`         | 每帧更新     |
| `physics_update()` | `physics_update(delta)` | 物理帧更新   |

## 参考资料

- [Godot 官方文档 - 节点和场景](https://docs.godotengine.org/en/stable/getting_started/step_by_step/nodes_and_scenes.html)
- [GDQuest 状态机教程](https://www.gdquest.com/)
- Python 版本实现：`d:/GameProject/MazeMaster/src/entities/monster/goblin_worker.py`

## 版本历史

- v1.0 (2025-10-10): 初始版本，从 Python 版本迁移
  - 实现 State 基类
  - 实现 StateMachine 管理器
  - 添加调试功能
  - 完整的文档和示例

---

**最后更新**：2025-10-10  
**版本**：1.0  
**状态**：稳定

