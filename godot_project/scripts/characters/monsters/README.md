# 单位状态机生成指南

## 📋 概述

本指南说明如何为游戏中的单位快速生成状态机系统。基于现有的 GoblinWorker 和 GoblinEngineer 状态机，提供标准化的状态机模板和生成流程。

**版本**: v4.0  
**更新日期**: 2025-10-14  
**主要改进**: 
- ✅ 金矿包装器系统修复
- ✅ 统一移动API集成
- ✅ 建筑寻路优化
- ✅ 状态机API标准化

## 🎯 状态机设计原则

### 1. 统一API使用
- **建筑交互**：使用 `MovementHelper.process_interaction_movement()` (两阶段移动)
- **简单移动**：使用 `MovementHelper.process_navigation()` (逃跑、游荡)
- **建筑查找**：使用 `BuildingFinder` 统一API

### 2. 状态分类
- **决策状态**：IdleState (任务分配中心)
- **移动状态**：MoveToXxxState (移动到目标)
- **工作状态**：XxxState (执行具体任务)
- **逃跑状态**：EscapeState (远离敌人)
- **游荡状态**：WanderState (无任务时随机移动)

### 3. 金矿包装器系统

**问题**: 金矿是RefCounted对象，不能直接作为Node使用
**解决方案**: 创建Node3D包装器并添加到场景树

```gdscript
# 创建金矿的建筑包装器
func _create_mine_building_wrapper(mine: RefCounted) -> Node3D:
    var wrapper = Node3D.new()
    wrapper.name = "MineWrapper"
    
    # 设置金矿位置（先设置position）
    var mine_pos = Vector3(
        floor(mine.position.x) + 0.5,
        0.05,
        floor(mine.position.z) + 0.5
    )
    wrapper.position = mine_pos
    
    # 🔧 关键修复：添加到场景树以确保位置设置生效
    var scene_tree = Engine.get_main_loop() as SceneTree
    if scene_tree and scene_tree.current_scene:
        scene_tree.current_scene.add_child(wrapper)
    
    # 添加建筑大小方法（金矿是1x1）
    wrapper.set_meta("building_size", Vector2(1, 1))
    wrapper.set_script(load("res://scripts/core/BuildingWrapper.gd"))
    
    return wrapper
```

**重要修复**:
- ✅ 使用`wrapper.position`而不是`wrapper.global_position`
- ✅ 将包装器添加到场景树以确保位置设置生效
- ✅ 在状态退出时清理包装器，避免内存泄漏

### 4. 标准转换条件
- 发现敌人 → EscapeState
- 任务完成 → IdleState
- 目标失效 → IdleState
- 无任务 → WanderState

## 🏗️ 状态机生成模板

### 基础状态机结构

```
UnitName (MonsterBase)
├── StateMachine
│   ├── IdleState          # 决策中心
│   ├── MoveToTargetState  # 移动到目标
│   ├── WorkState          # 执行工作
│   ├── EscapeState        # 逃跑
│   └── WanderState        # 游荡
├── NavigationAgent3D
└── DetectionArea3D
```

### 状态文件命名规范

```
unit_name_states/
├── IdleState.gd
├── MoveToTargetState.gd
├── WorkState.gd
├── EscapeState.gd
├── WanderState.gd
└── README.md
```

## 📝 状态机生成步骤

### 步骤1：创建状态机文件夹

```bash
# 创建新的单位状态机文件夹
mkdir godot_project/scripts/characters/monsters/unit_name_states
```

### 步骤2：复制模板文件

从现有状态机复制以下文件作为模板：
- `goblin_worker_states/IdleState.gd` → `unit_name_states/IdleState.gd`
- `goblin_worker_states/EscapeState.gd` → `unit_name_states/EscapeState.gd`
- `goblin_worker_states/WanderState.gd` → `unit_name_states/WanderState.gd`

### 步骤3：修改状态类名

在每个状态文件中修改类名：

```gdscript
# 原始
extends State
class_name GoblinWorkerIdleState

# 修改为
extends State
class_name UnitNameIdleState
```

### 步骤4：自定义工作状态

根据单位功能创建特定的工作状态：

```gdscript
extends State
class_name UnitNameWorkState

## UnitName 工作状态
## 
## 职责：[描述单位的具体工作]
## 
## 转换条件：
## - 工作完成 → IdleState
## - 发现敌人 → EscapeState
## - 目标失效 → IdleState

var target_object = null # 目标对象
var work_timer: Timer = null
var work_interval: float = 1.0

func enter(data: Dictionary = {}) -> void:
	var unit = state_machine.owner
	
	# 获取目标对象
	if data.has("target_object"):
		target_object = data["target_object"]
	else:
		state_finished.emit("IdleState")
		return
	
	# 停止移动
	unit.velocity = Vector3.ZERO
	
	# 播放工作动画
	if unit.has_node("Model") and unit.get_node("Model").has_method("play_animation"):
		unit.get_node("Model").play_animation("work")
	
	# 创建工作计时器
	work_timer = Timer.new()
	work_timer.wait_time = work_interval
	work_timer.timeout.connect(_on_work_tick)
	add_child(work_timer)
	work_timer.start()

func update(_delta: float) -> void:
	var unit = state_machine.owner
	
	# 检查目标是否有效
	if not is_instance_valid(target_object):
		state_finished.emit("IdleState")
		return
	
	# 检查是否有敌人
	if _has_nearby_enemies(unit):
		state_finished.emit("EscapeState")
		return

func _on_work_tick() -> void:
	"""工作定时器触发"""
	var unit = state_machine.owner
	
	# 执行具体工作逻辑
	_perform_work(unit)
	
	# 检查工作是否完成
	if _is_work_complete(unit):
		state_finished.emit("IdleState")

func _perform_work(unit: Node) -> void:
	"""执行具体工作"""
	# 根据单位类型实现具体工作逻辑
	pass

func _is_work_complete(unit: Node) -> bool:
	"""检查工作是否完成"""
	# 根据单位类型实现完成条件检查
	return true

func exit() -> void:
	if work_timer:
		work_timer.stop()
		work_timer.queue_free()
		work_timer = null

func _has_nearby_enemies(unit: Node) -> bool:
	"""检查是否有敌人在附近"""
	var enemy = unit.find_nearest_enemy()
	if enemy and unit.global_position.distance_to(enemy.global_position) < 15.0:
		return true
	return false
```

### 步骤5：自定义移动状态

根据单位目标类型创建移动状态：

```gdscript
extends State
class_name UnitNameMoveToTargetState

## UnitName 移动到目标状态
## 
## 职责：使用统一移动API移动到目标对象
## 
## 转换条件：
## - 到达目标交互范围 → WorkState
## - 目标失效 → IdleState
## - 发现敌人 → EscapeState

var target_object: Node = null

# 🔧 [统一移动API] 使用 process_interaction_movement() 进行两阶段移动
# 不再需要手动管理 current_path 和 current_waypoint

func enter(data: Dictionary = {}) -> void:
	var unit = state_machine.owner
	
	# 获取目标对象
	if data.has("target_object"):
		target_object = data["target_object"]
	else:
		state_finished.emit("IdleState")
		return
	
	# 检查目标是否有效
	if not target_object or not is_instance_valid(target_object):
		state_finished.emit("IdleState")
		return
	
	# 🔧 [统一交互移动API] 重置交互移动状态
	MovementHelper.reset_interaction_movement(unit)
	
	# 播放行走动画
	if unit.has_node("Model") and unit.get_node("Model").has_method("play_animation"):
		unit.get_node("Model").play_animation("move")

func physics_update(_delta: float) -> void:
	var unit = state_machine.owner
	
	# 检查目标是否有效
	if not is_instance_valid(target_object):
		state_finished.emit("IdleState")
		return
	
	# 检查是否有敌人
	if _has_nearby_enemies(unit):
		state_finished.emit("EscapeState")
		return
	
	# 🔧 [统一交互移动API] 使用两阶段移动逻辑
	var move_result = MovementHelper.process_interaction_movement(
		unit,
		target_object,
		_delta,
		"MoveToTargetState" if state_machine.debug_mode else ""
	)
	
	# 根据移动结果处理状态转换
	match move_result:
		MovementHelper.InteractionMoveResult.REACHED_INTERACTION:
			# 已到达交互范围，开始工作
			state_finished.emit("WorkState", {"target_object": target_object})
		MovementHelper.InteractionMoveResult.FAILED_NO_PATH, MovementHelper.InteractionMoveResult.FAILED_STUCK:
			# 寻路失败，返回空闲
			state_finished.emit("IdleState")
		# MOVING_TO_ADJACENT 和 MOVING_TO_INTERACTION 继续移动

func exit() -> void:
	var unit = state_machine.owner
	unit.velocity = Vector3.ZERO

func _has_nearby_enemies(unit: Node) -> bool:
	"""检查是否有敌人在附近"""
	var enemy = unit.find_nearest_enemy()
	if enemy and unit.global_position.distance_to(enemy.global_position) < 15.0:
		return true
	return false
```

### 步骤6：自定义IdleState

根据单位功能修改决策逻辑：

```gdscript
extends State
class_name UnitNameIdleState

## UnitName 空闲状态
## 
## 职责：决策中心，评估环境并分配任务
## 
## 转换条件：
## - 发现敌人 → EscapeState
## - 有任务需求 → MoveToTargetState
## - 无任务 → WanderState

func enter(_data: Dictionary = {}) -> void:
	var unit = state_machine.owner
	
	# 停止移动
	unit.velocity = Vector3.ZERO
	
	# 播放空闲动画
	if unit.has_node("Model") and unit.get_node("Model").has_method("play_animation"):
		unit.get_node("Model").play_animation("idle")

func update(_delta: float) -> void:
	var unit = state_machine.owner
	
	# 检查是否有敌人
	if _has_nearby_enemies(unit):
		state_finished.emit("EscapeState")
		return
	
	# 查找任务
	var task = _find_available_task(unit)
	if task:
		state_finished.emit("MoveToTargetState", {"target_object": task})
		return
	
	# 无任务，开始游荡
	state_finished.emit("WanderState")

func _find_available_task(unit: Node) -> Node:
	"""查找可用的任务
	
	根据单位类型实现具体的任务查找逻辑
	"""
	# 示例：查找需要建造的建筑
	if unit.building_manager:
		var buildings = unit.building_manager.get_all_buildings()
		for building in buildings:
			if building.needs_work():
				return building
	
	return null

func _has_nearby_enemies(unit: Node) -> bool:
	"""检查是否有敌人在附近"""
	var enemy = unit.find_nearest_enemy()
	if enemy and unit.global_position.distance_to(enemy.global_position) < 15.0:
		return true
	return false
```

### 步骤7：创建README文档

为每个单位状态机创建README文档：

```markdown
# UnitName 状态机系统

## 📋 概述

UnitName 是游戏中的[单位类型描述]，负责[主要功能描述]。
本状态机系统基于统一的状态机模板实现。

## 🎯 状态列表

### 1. IdleState - 空闲状态
**职责**：决策中心，评估环境并分配任务

**转换条件**：
- 发现敌人 → `EscapeState`
- 有任务需求 → `MoveToTargetState`
- 无任务 → `WanderState`

### 2. MoveToTargetState - 移动到目标
**职责**：使用统一移动API移动到目标对象

**转换条件**：
- 到达目标交互范围 → `WorkState`
- 目标失效 → `IdleState`
- 发现敌人 → `EscapeState`

### 3. WorkState - 工作中
**职责**：[具体工作描述]

**转换条件**：
- 工作完成 → `IdleState`
- 发现敌人 → `EscapeState`
- 目标失效 → `IdleState`

### 4. EscapeState - 逃跑
**职责**：远离敌人，保命第一

**转换条件**：
- 敌人消失 → `IdleState`

### 5. WanderState - 游荡
**职责**：无目标时随机移动，定期检查新任务

**转换条件**：
- 定时检查（2秒） → `IdleState`
- 发现敌人 → `EscapeState`

## 🔧 使用方法

### 场景结构
```
UnitName (MonsterBase)
├── StateMachine
│   ├── IdleState
│   ├── MoveToTargetState
│   ├── WorkState
│   ├── EscapeState
│   └── WanderState
├── NavigationAgent3D
└── DetectionArea3D
```

### 代码示例

```gdscript
# UnitName.gd
extends MonsterBase
class_name UnitName

# 单位相关属性
@export var work_speed: float = 1.0
@export var detection_range: float = 15.0

func _ready() -> void:
    super._ready()
    # 状态机会自动初始化
```

## 📝 注意事项

1. **目标查找**：使用相应的Manager提供的查找方法
2. **移动系统**：使用统一的MovementHelper API
3. **敌人检测**：通过DetectionArea信号触发
4. **状态转换**：确保所有状态都有明确的转换条件

## 🔍 调试

开启 StateMachine 的 debug_mode 可以看到：
- 当前状态名称
- 状态转换日志
- 目标位置可视化

```gdscript
$StateMachine.debug_mode = true
```

---

**版本**：1.0  
**创建日期**：[当前日期]  
**基于模板**：统一状态机模板
```

## 🚀 快速生成脚本

### 自动化生成脚本

```bash
#!/bin/bash
# generate_unit_states.sh

UNIT_NAME=$1
if [ -z "$UNIT_NAME" ]; then
    echo "Usage: ./generate_unit_states.sh <unit_name>"
    exit 1
fi

# 创建状态机文件夹
mkdir -p "godot_project/scripts/characters/monsters/${UNIT_NAME}_states"

# 复制模板文件
cp "godot_project/scripts/characters/monsters/goblin_worker_states/IdleState.gd" "godot_project/scripts/characters/monsters/${UNIT_NAME}_states/"
cp "godot_project/scripts/characters/monsters/goblin_worker_states/EscapeState.gd" "godot_project/scripts/characters/monsters/${UNIT_NAME}_states/"
cp "godot_project/scripts/characters/monsters/goblin_worker_states/WanderState.gd" "godot_project/scripts/characters/monsters/${UNIT_NAME}_states/"

# 替换类名
sed -i "s/GoblinWorker/${UNIT_NAME^}/g" "godot_project/scripts/characters/monsters/${UNIT_NAME}_states/"*.gd

echo "状态机文件已生成到: godot_project/scripts/characters/monsters/${UNIT_NAME}_states/"
echo "请根据单位功能自定义 WorkState 和 MoveToTargetState"
```

## 📋 检查清单

创建新单位状态机时，请确保：

- [ ] 所有状态都使用统一的API
- [ ] 状态转换条件明确且完整
- [ ] 错误处理逻辑完善
- [ ] 调试信息充分
- [ ] 文档完整且准确
- [ ] 代码风格一致
- [ ] 性能优化合理

## 🎯 最佳实践

1. **保持一致性**：使用统一的API和命名规范
2. **错误处理**：每个状态都要处理目标失效和寻路失败
3. **性能优化**：避免在update中执行重复的昂贵操作
4. **调试友好**：提供充分的调试信息和日志
5. **文档完整**：为每个状态机创建详细的README文档

---

**版本**：1.0  
**创建日期**：2025-01-27  
**基于系统**：GoblinWorker & GoblinEngineer 状态机
