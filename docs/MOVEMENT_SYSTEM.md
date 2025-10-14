# 🚶 MazeMaster3D - 移动系统文档

**版本**: v4.4.0 (金矿包装器修复)  
**更新日期**: 2025-10-14  
**架构**: Godot 4 + AStarGrid2D + MovementHelper统一API + 分层避障系统 + 建筑寻路优化

> **🚨 重要提醒**: 所有新的移动代码必须使用 `MovementHelper.process_navigation()` API！已移除所有旧的 NavigationAgent3D 和直接位置修改代码。

---

## 📚 系统概述

MazeMaster3D使用基于**AStarGrid2D**的动态网格寻路系统 + **MovementHelper统一API**，取代了传统的NavigationMesh烘焙方案。该系统专为**网格化地图**和**2D平面移动**优化，实现了高性能、低延迟的动态路径规划。

### 🎯 核心特性

- ✅ **完全统一移动API**: `MovementHelper.process_navigation()` 一站式移动控制
- ✅ **零冗余系统**: 已移除所有旧的 NavigationAgent3D 和直接位置修改
- ✅ **动态路径更新**: 挖掘/建筑放置后立即更新（<1ms，200倍提升）
- ✅ **智能避障**: 自动卡住检测、路径阻挡检测、动态重新寻路
- ✅ **动态避障**: 分层避障系统，全局路径+局部避障，流畅单位交互
- ✅ **路径缓存**: LRU策略，5秒过期，最多100条缓存
- ✅ **智能目标查找**: 自动找到建筑/资源块周围可通行位置
- ✅ **建筑寻路优化**: 根据建筑大小（1x1, 2x2, 3x3...）智能计算可到达位置
- ✅ **金矿包装器系统**: 解决RefCounted对象位置设置问题，确保正确寻路
- ✅ **精确移动**: 路径完成后的直线精确定位
- ✅ **代码简化**: 每个移动状态仅需15-20行代码（原75行）
- ✅ **系统一致性**: 所有角色（Worker、Engineer、Hero）使用相同API

### 🏗️ 系统架构

```
┌──────────────────────────────────────────────┐
│       MovementHelper (统一移动API)           │
│  - process_navigation() 一站式移动控制       │
│  - process_interaction_movement() 建筑交互   │
│  - 自动卡住检测 + 动态重新寻路               │
│  - 自动路径阻挡检测                          │
│  - 智能精确移动                              │
└──────────────────────────────────────────────┘
                ↓ 调用
┌──────────────────────────────────────────────┐
│       BuildingFinder (建筑查找器)            │
│  - get_walkable_position_near_building()     │
│  - 根据建筑大小智能计算可到达位置             │
│  - 1x1/2x2/3x3+ 不同搜索策略                │
│  - 统一建筑查找API                           │
└──────────────────────────────────────────────┘
                ↓ 调用
┌──────────────────────────────────────────────┐
│       GridPathFinder (Autoload)              │
│  - AStarGrid2D (100x100网格)                 │
│  - 路径缓存系统（LRU，5秒过期）              │
│  - 流场寻路                                   │
│  - 坐标转换                                   │
└──────────────────────────────────────────────┘
                ↓ 同步状态
┌──────────────────────────────────────────────┐
│       TileManager + BuildingManager          │
│  - 维护地块可通行状态                         │
│  - 挖掘时自动更新GridPathFinder               │
│  - 建筑放置时自动更新GridPathFinder           │
└──────────────────────────────────────────────┘
                ↓ 使用
┌──────────────────────────────────────────────┐
│     CharacterBase (CharacterBody3D)          │
│  ├── GoblinWorker (苦工) - 统一API           │
│  ├── GoblinEngineer (工程师) - 统一API       │
│  ├── CombatManager (战斗单位) - 统一API      │
│  ├── MiningManager (挖矿系统) - 统一API      │
│  └── 其他角色...（未来扩展仅需10-20行代码）  │
└──────────────────────────────────────────────┘
```

---

## 🎯 核心系统：MovementHelper 统一移动API

### 为什么需要MovementHelper？

**旧方案问题（v3.0及之前）：**
- ❌ 每个移动状态需要75行重复代码
- ❌ 手动管理 `current_path` 和 `current_waypoint`
- ❌ 卡住检测、路径阻挡需要在每个状态重复实现
- ❌ 新增单位需要复制大量代码
- ❌ 多套并行移动系统（NavigationAgent3D + 直接位置修改）
- ❌ 系统不一致，难以维护

**新方案优势（v4.1.0）：**
- ✅ 每个移动状态仅需15-20行代码（**减少76%**）
- ✅ 自动处理寻路、卡住、阻挡、精确移动
- ✅ 新增单位只需调用一个API
- ✅ 移动逻辑统一，易于调试和优化
- ✅ **完全统一**: 所有角色使用相同API
- ✅ **零冗余**: 移除所有旧的移动系统
- ✅ **系统一致性**: CombatManager、MiningManager等全部统一

---

### 统一API：process_navigation()

#### 核心接口

```gdscript
MovementHelper.process_navigation(
    character: Node,           // 角色对象
    target_position: Vector3,  // 目标位置（世界坐标）
    delta: float,              // 时间增量
    debug_prefix: String = ""  // 调试日志前缀（可选）
) -> int  // 返回 MoveResult 枚举
```

> **⚠️ 重要变更**: v4.1.0 已移除 `interaction_distance` 参数！现在使用 Area3D 系统处理交互检测，`MovementHelper` 只负责移动到目标附近（1米内）。

#### 返回值（MoveResult枚举）

```gdscript
enum MoveResult {
    MOVING,           # 正在移动中
    REACHED,          # 已到达目标（在交互距离内）
    FAILED_NO_PATH,   # 寻路失败（无可用路径）
    FAILED_STUCK      # 卡住失败（多次重新寻路无效）
}
```

#### 自动处理的功能

| 功能             | 说明               | 触发条件                 |
| ---------------- | ------------------ | ------------------------ |
| **初始寻路**     | 自动计算路径       | `path.is_empty()`        |
| **目标变更检测** | 自动重新寻路       | 目标距离>0.5米           |
| **卡住检测**     | 3秒内移动<0.05米   | 路径长度>3 且 距离>5米   |
| **路径阻挡检测** | 前方路径点不可通行 | 路径跟随阶段             |
| **动态重新寻路** | 1秒冷却时间        | 卡住或阻挡               |
| **网格路径跟随** | 逐点跟随           | waypoint < path.size()   |
| **精确移动**     | 直线移动           | 路径完成后               |
| **到达判定**     | 距离检测           | distance < 1.0米（固定） |
| **动态避障**     | 分层避障系统       | 自动启用，可配置参数     |

#### 动态避障系统 (v4.2.0)

**分层避障架构**：
- **全局路径规划**: AStarGrid2D负责计算从起点到终点的最优路径
- **局部避障处理**: 在移动过程中检测并避开附近的动态单位

**核心特性**：
- ✅ **智能混合**: 根据避障强度动态调整基础路径和避障力的混合比例
- ✅ **性能优化**: 使用平方距离筛选、限制邻居数量、更新频率控制
- ✅ **可配置参数**: 运行时调整检测半径、避障力强度等
- ✅ **流畅移动**: 避免单位相向移动时的卡住问题

**配置示例**：
```gdscript
# 调整避障参数
AvoidanceManager.configure_avoidance(
    avoidance_radius = 2.0,    # 检测半径
    avoidance_force = 8.0,     # 避障力强度
    separation_force = 10.0,   # 分离力强度
    max_neighbors = 6,         # 最大邻居数量
    update_frequency = 2,      # 每2帧更新一次
    enable = true              # 启用避障
)
```

#### 简化对比示例

**旧代码（75行）：**
```gdscript
var current_path: PackedVector3Array = []
var current_waypoint: int = 0

func enter(data):
    current_path = GridPathFinder.find_path(...)
    if current_path.is_empty(): ...

func physics_update(delta):
    # 卡住检测（15行）
    if MovementHelper.detect_stuck(...):
        var new_path = MovementHelper.try_replan_path(...)
        ...
    
    # 路径阻挡检测（15行）
    if MovementHelper.is_path_blocked(...):
        var new_path = MovementHelper.try_replan_path(...)
        ...
    
    # 路径跟随（20行）
    if current_waypoint < current_path.size():
        var follow_result = MovementHelper.follow_path(...)
        current_waypoint = follow_result.waypoint_index
        ...
    else:
        # 精确移动（15行）
        ...
```

**新代码（15行）：**
```gdscript
var target_position: Vector3 = Vector3.ZERO

func enter(data):
    target_position = _find_walkable_position(...)
    MovementHelper.reset_navigation(character)

func physics_update(delta):
    var result = MovementHelper.process_navigation(
        character, target_position, delta, "StateName"
    )
    match result:
        MovementHelper.MoveResult.REACHED:
            state_finished.emit("NextState")
        MovementHelper.MoveResult.FAILED_NO_PATH, MovementHelper.MoveResult.FAILED_STUCK:
            state_finished.emit("IdleState")
```

---

### 辅助函数

```gdscript
# 重置导航控制器（切换状态时调用）
MovementHelper.reset_navigation(character: Node)

# 获取角色速度（兼容多种结构）
MovementHelper.get_character_speed(character: Node) -> float

# 应用移动（自动计算速度和旋转）
MovementHelper.apply_movement(character: Node, direction: Vector3, delta: float)

# 低级API（高级用户）
MovementHelper.detect_stuck(...) -> bool
MovementHelper.is_path_blocked(...) -> bool
MovementHelper.try_replan_path(...) -> PackedVector3Array
MovementHelper.follow_path(...) -> Dictionary
```

---

## 🚨 重要：移动系统统一规范

### ⚠️ 强制使用 MovementHelper.process_navigation()

**所有新的移动代码必须使用统一的API：**

```gdscript
# ✅ 正确：使用统一API
var result = MovementHelper.process_navigation(
    character, target_position, delta, "DebugPrefix"
)

# ❌ 错误：直接修改位置
character.position += direction * speed * delta

# ❌ 错误：使用旧的NavigationAgent3D
nav_agent.target_position = target

# ❌ 错误：使用废弃的move_to_position
character.move_to_position(target)
```

### 📋 已统一的系统

| 系统                      | 状态     | 使用API                             |
| ------------------------- | -------- | ----------------------------------- |
| **GoblinWorker状态机**    | ✅ 已完成 | `MovementHelper.process_navigation` |
| **GoblinEngineer状态机**  | ✅ 已完成 | `MovementHelper.process_navigation` |
| **CombatManager战斗系统** | ✅ 已完成 | `MovementHelper.process_navigation` |
| **MiningManager挖矿系统** | ✅ 已完成 | `MovementHelper.process_navigation` |
| **HeroBase英雄系统**      | ✅ 已完成 | `MovementHelper.process_navigation` |
| **CharacterBase基类**     | ✅ 已清理 | 移除NavigationAgent3D代码           |

### 🔧 迁移指南

**从旧系统迁移到新系统：**

```gdscript
# 旧代码（NavigationAgent3D）
func move_to_target(target_pos: Vector3):
    if nav_agent:
        nav_agent.target_position = target_pos

# 新代码（MovementHelper）
func move_to_target(target_pos: Vector3, delta: float):
    var result = MovementHelper.process_navigation(
        character, target_pos, delta, "MoveToTarget"
    )
    # 处理结果...
```

**从直接位置修改迁移：**

```gdscript
# 旧代码（直接修改）
func move_directly(direction: Vector3, delta: float):
    character.position += direction * speed * delta

# 新代码（MovementHelper）
func move_to_position(target_pos: Vector3, delta: float):
    var result = MovementHelper.process_navigation(
        character, target_pos, delta, "DirectMove"
    )
    # 自动处理寻路、避障等
```

---

## 🏗️ 建筑寻路系统修复 (v4.3.0)

### 问题背景

**"终点被阻挡"错误**：
- 角色寻路到建筑中心时，GridPathFinder报告"终点被阻挡"
- 原因：建筑中心是阻挡格子，不可通行
- 影响：苦工和工程师无法到达建筑进行交互

## 🔧 金矿包装器系统修复 (v4.4.0)

### 问题背景

**金矿包装器位置设置失败**：
- 金矿是RefCounted对象，不能直接作为Node使用
- 创建Node3D包装器后，`global_position`设置失效，位置保持(0,0,0)
- 影响：`BuildingFinder.get_walkable_position_near_building()`返回(inf,inf,inf)
- 结果：苦工无法找到金矿的相邻可通行位置

### 解决方案

**金矿包装器位置修复**：
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

**BuildingFinder.get_walkable_position_near_building()**：
```gdscript
# 根据建筑大小计算可到达位置
static func get_walkable_position_near_building(character: Node, building: Node) -> Vector3:
    # 1x1建筑：搜索外部一圈（8个方向）
    # 2x2建筑：搜索外部一圈 + 第二圈（更多选择）
    # 3x3+建筑：搜索外部两圈（确保有足够可走位置）
```

**MovementHelper集成**：
```gdscript
# MovementHelper 直接调用 BuildingFinder
move_state.adjacent_target = BuildingFinder.get_walkable_position_near_building(character, target_building)
```

### 建筑大小适配

| 建筑大小 | 搜索范围 | 示例偏移量       |
| -------- | -------- | ---------------- |
| 1x1      | 外部一圈 | (-1,-1) 到 (1,1) |
| 2x2      | 外部两圈 | (-2,-2) 到 (2,2) |
| 3x3+     | 外部两圈 | (-3,-3) 到 (3,3) |

### 修复效果

**建筑寻路修复**:
- ✅ **消除"终点被阻挡"错误**: 寻路目标改为建筑外部可走格子
- ✅ **支持任意大小建筑**: 1x1, 2x2, 3x3... 都有对应搜索逻辑
- ✅ **提高寻路成功率**: 更多可走位置选择
- ✅ **保持交互距离**: 角色仍能进入建筑交互范围

**金矿包装器修复**:
- ✅ **解决位置设置问题**: Node3D添加到场景树后位置正确设置
- ✅ **统一API兼容**: 金矿使用与建筑相同的寻路逻辑
- ✅ **消除(inf,inf,inf)错误**: BuildingFinder正确返回可通行位置
- ✅ **提高金矿寻路成功率**: 苦工能够正确找到金矿相邻位置

---

## 🧭 核心系统：GridPathFinder

### API接口

#### 寻路接口
```gdscript
# 查找路径（核心方法）
GridPathFinder.find_path(start: Vector3, end: Vector3) -> PackedVector3Array

# 快速可达性检查
GridPathFinder.is_position_reachable(start: Vector3, end: Vector3) -> bool

# 获取可通行邻居（用于游荡）
GridPathFinder.get_walkable_neighbors(pos: Vector3) -> Array
```

#### 动态更新接口
```gdscript
# 立即更新单格状态（O(1)复杂度）
GridPathFinder.set_cell_walkable(grid_pos: Vector2i, walkable: bool)

# 批量更新（0.1秒间隔）
GridPathFinder.set_cell_walkable_deferred(grid_pos: Vector2i, walkable: bool)

# 🔧 [v4.0新增] 建筑系统自动集成
# BuildingManager.place_building() 自动调用 GridPathFinder.set_cell_walkable()
# BuildingManager.unregister_building() 自动恢复可通行状态
# 支持 1x1 和 2x2 建筑
```

#### 坐标转换
```gdscript
# 世界坐标 → 网格坐标
GridPathFinder.world_to_grid(world_pos: Vector3) -> Vector2i

# 网格坐标 → 世界坐标（格子中心，Y=0.05）
GridPathFinder.grid_to_world(grid_pos: Vector2i) -> Vector3
```

#### 高级功能
```gdscript
# 流场寻路（多Worker优化）
GridPathFinder.update_flow_field(target: Vector3)
GridPathFinder.get_flow_direction(pos: Vector3) -> Vector3

# 路径平滑
GridPathFinder.smooth_path(path: PackedVector3Array) -> PackedVector3Array

# 性能统计
GridPathFinder.get_stats() -> Dictionary
GridPathFinder.print_stats()
```

### 性能特性

| 指标         | NavigationMesh | AStarGrid2D | 提升          |
| ------------ | -------------- | ----------- | ------------- |
| 挖掘响应时间 | 50-200ms       | <1ms        | **200倍**     |
| 寻路查询     | 5-10ms         | 1-3ms       | **3倍**       |
| 内存占用     | ~15MB          | ~60KB       | **99.6%节省** |
| 初始化时间   | 1-2秒          | 0.3-0.5秒   | **3倍**       |

### 路径缓存策略

```gdscript
# LRU缓存
- 最多缓存100条路径
- 5秒自动过期
- 缓存键: "start_x,start_z->end_x,end_z"
- 地形变化时自动清除

# 性能提升
- 重复路径查询: <0.1ms（缓存命中）
- 避免重复计算
```

---

## 🎯 移动模式分类

### 1. 🎯 路径跟随移动（Path Following Movement）

**定义**: 使用GridPathFinder计算路径，然后逐点跟随到达目标。

**适用场景**:
- Worker返回基地（ReturnToBaseState）
- Worker移动到金矿（MoveToMineState）
- Engineer取金币（FetchGoldState）
- Engineer移动到建筑（MoveToTargetState）
- Engineer归还金币（ReturnGoldState）

**核心实现（v4.1.0统一API）**:
```gdscript
# 🔧 [v4.1.0] 使用MovementHelper统一API - 15行代码
var target_position: Vector3 = Vector3.ZERO

# enter() - 初始化目标
func enter(data: Dictionary = {}):
    target_position = _get_target_position()  # 获取可通行目标位置
    MovementHelper.reset_navigation(character)

# physics_update() - 一行API调用
func physics_update(delta: float):
    var result = MovementHelper.process_navigation(
        character, target_position, delta, "StateName"
    )
    match result:
        MovementHelper.MoveResult.REACHED:
            state_finished.emit("NextState")
        MovementHelper.MoveResult.FAILED_NO_PATH, MovementHelper.MoveResult.FAILED_STUCK:
            state_finished.emit("IdleState")
```

**性能**: 
- 路径计算: 1-3ms
- 缓存命中: <0.1ms

---

### 2. 🎲 智能游荡移动（Smart Wandering Movement）

**定义**: 使用GridPathFinder找到附近可通行的邻居格子，随机选择一个作为游荡目标。

**适用场景**:
- Worker无任务时（WanderState）
- Engineer空闲时（WanderState）

**核心实现（v4.1.0统一API）**:
```gdscript
func _generate_wander_target(unit: Node):
    # 🔧 使用GridPathFinder获取可通行邻居
    if GridPathFinder and GridPathFinder.is_ready():
        var walkable = GridPathFinder.get_walkable_neighbors(unit.global_position)
        if walkable.size() > 0:
            # 随机选择一个可通行邻居
            wander_target = walkable[randi() % walkable.size()]
            return
    
    # 后备方案：随机生成
    var angle = randf() * TAU
    var distance = randf() * min(wander_radius, 10.0)
    wander_target = position + Vector3(cos(angle) * distance, 0, sin(angle) * distance)

# 使用统一API进行游荡移动
func physics_update(delta: float):
    var result = MovementHelper.process_navigation(
        unit, wander_target, delta, "Wandering"
    )
    match result:
        MovementHelper.MoveResult.REACHED:
            # 到达目标，生成新的游荡目标
            _generate_wander_target(unit)
        MovementHelper.MoveResult.FAILED_NO_PATH, MovementHelper.MoveResult.FAILED_STUCK:
            # 游荡失败，生成新目标
            _generate_wander_target(unit)
```

**特点**:
- ✅ 确保游荡目标在可通行区域
- ✅ 不会撞墙或卡住
- ✅ 游荡速度减半（0.5倍速度）

---

### 3. 🏃 直接方向移动（Direct Direction Movement）

**定义**: 不使用寻路，直接计算方向向量并移动。

**⚠️ 注意**: 这是特殊情况，仅在紧急逃离时使用。其他所有移动都应使用 `MovementHelper.process_navigation`。

**适用场景**:
- Worker逃离敌人（EscapeState）
- Engineer逃离敌人（EscapeState）
- CombatManager战斗单位的紧急移动

**核心实现**:
```gdscript
func physics_update(delta: float):
    var nearest_enemy = unit.find_nearest_enemy()
    
    # 计算逃离方向（远离敌人）
    var flee_direction = (unit.position - nearest_enemy.position).normalized()
    flee_direction.y = 0
    
    # 混合逃向基地方向（70%远离敌人，30%向基地）
    var base = _find_nearest_base(unit)
    if base:
        var to_base = (base.position - unit.position).normalized()
        to_base.y = 0
        flee_direction = (flee_direction * 0.7 + to_base * 0.3).normalized()
    
    # 设置速度（加速逃跑，1.5倍）
    unit.velocity = flee_direction * (unit.speed / 100.0) * 1.5
    unit.move_and_slide()
```

**特点**:
- ✅ 即时响应，无需计算路径
- ✅ 适合紧急情况（逃跑）
- ✅ 速度提升1.5倍

---

### 4. 🛑 静止状态（Stationary）

**定义**: 单位停止移动，执行其他任务。

**适用场景**:
- Worker挖矿（MiningState）
- Worker存放金币（DepositGoldState）
- Engineer工作（WorkState）
- 所有单位空闲（IdleState）

**核心实现**:
```gdscript
func physics_update(delta: float):
    unit.velocity = Vector3.ZERO
    # 执行工作逻辑（挖矿、建造等）
```

---

## 👹 单位移动策略详解

### 哥布林苦工（GoblinWorker）

#### 状态机概览

```
[IdleState] ──发现金矿──→ [MoveToMineState] ──到达──→ [MiningState]
     ↑                           ↓                         ↓
     │                      [路径失败]                [采集金币]
     │                           ↓                         ↓
     └──[WanderState]←──[无可达金矿]               [背包已满]
                                                           ↓
                                               [ReturnToBaseState]
                                                           ↓
                                                    [DepositGoldState]
                                                           ↓
                                                     [返回IdleState]

[任意状态] ──检测到敌人──→ [EscapeState] ──脱离危险──→ [IdleState]
```

#### 移动参数配置

```gdscript
# GoblinWorker配置（v4.0已统一）
speed = 40  # 0.4米/秒（与Engineer统一）
mining_rate = 0.5  # 挖矿速率
carry_capacity = 20  # 携带容量
flee_distance = 60  # 逃离距离
wander_radius = 50  # 游荡半径
```

#### 状态详解

| 状态                  | 移动模式 | 触发条件                    | 目标选择               | 速度 |
| --------------------- | -------- | --------------------------- | ---------------------- | ---- |
| **IdleState**         | 静止     | 初始/完成任务               | -                      | 0    |
| **MoveToMineState**   | 路径跟随 | 发现可达金矿                | 金矿周围可通行位置     | 1.0x |
| **MiningState**       | 静止     | 到达金矿交互范围（1.1x1.1） | -                      | 0    |
| **ReturnToBaseState** | 路径跟随 | 背包已满（20金币）          | 地牢之心周围可通行位置 | 1.0x |
| **DepositGoldState**  | 静止     | 到达基地交互范围            | -                      | 0    |
| **WanderState**       | 智能游荡 | 无可达金矿                  | 可通行邻居             | 0.5x |
| **EscapeState**       | 直接逃离 | 发现敌人（<15米）           | 远离敌人+向基地        | 1.5x |

#### 特殊机制

**1. 智能目标查找**
```gdscript
# 金矿是1x1不可通行资源块，寻路到周围可通行位置
func _get_accessible_position_near_mine(mine):
    # 检查金矿周围8个方向（正交+对角）
    var offsets = [
        Vector3(-1,0,0), Vector3(1,0,0),  # 左、右
        Vector3(0,0,-1), Vector3(0,0,1),  # 上、下
        Vector3(-1,0,-1), Vector3(1,0,-1), # 对角
        Vector3(-1,0,1), Vector3(1,0,1)
    ]
    
    for offset in offsets:
        var test_pos = mine_center + offset
        if tile_manager.is_walkable(test_pos):
            return test_pos  # ✅ 返回第一个可通行位置

# Worker移动到金矿旁边 → 1.1x1.1交互范围内采矿
```

**2. 定期路径重新规划**
```gdscript
# ReturnToBaseState每1秒重新规划路径
var path_update_timer: float = 0.0
const PATH_UPDATE_INTERVAL: float = 1.0

func physics_update(delta: float):
    path_update_timer += delta
    if path_update_timer >= PATH_UPDATE_INTERVAL:
        path_update_timer = 0.0
        # 重新计算路径（避免地形变化）
        current_path = GridPathFinder.find_path(current_pos, target)
        current_waypoint = 0
```

**3. 失败金矿记录**
```gdscript
# 标记无法到达的金矿，避免重复尝试
var failed_mines: Dictionary = {}  # {Vector3 -> timestamp}
var failed_mine_timeout: float = 10.0  # 10秒后重试

# MoveToMineState中
if current_path.is_empty():
    worker.failed_mines[target_mine.position] = Time.get_ticks_msec()
    state_finished.emit("IdleState")
```

---

### 🔨 地精工程师（GoblinEngineer）

#### 状态机概览

```
[IdleState] ──接收建造任务──→ [FetchGoldState] ──取到金币──→ [MoveToTargetState]
     ↑                              ↓                              ↓
     │                         [金库可达]                      [到达建筑]
     │                              ↓                              ↓
     │                         [移动到金库]                   [WorkState]
     │                              ↓                              ↓
     │                         [取金币]                      [建造/修理/升级]
     │                                                              ↓
     └──[无任务]←──[ReturnGoldState]←──[剩余金币]←──[工作完成]

[任意状态] ──检测到敌人──→ [EscapeState] ──脱离危险──→ [IdleState]
```

#### 移动参数配置

```gdscript
# GoblinEngineer配置（v4.0已统一）
speed = 40  # 0.4米/秒（与Worker统一）
gold_capacity = 60  # 携带容量（工程师更大）
safe_distance = 20  # 安全距离
```

#### 状态详解

| 状态                  | 移动模式 | 触发条件          | 目标选择        | 速度 |
| --------------------- | -------- | ----------------- | --------------- | ---- |
| **IdleState**         | 静止     | 初始/无任务       | -               | 0    |
| **FetchGoldState**    | 路径跟随 | 接收建造任务      | 金库/地牢之心   | 1.0x |
| **MoveToTargetState** | 路径跟随 | 取到金币          | 目标建筑位置    | 1.0x |
| **WorkState**         | 静止     | 到达建筑          | -               | 0    |
| **ReturnGoldState**   | 路径跟随 | 工作剩余金币      | 金库/地牢之心   | 1.0x |
| **WanderState**       | 智能游荡 | 无任务            | 可通行邻居      | 0.5x |
| **EscapeState**       | 直接逃离 | 发现敌人（<15米） | 远离敌人+向基地 | 1.5x |

---

## 🔧 核心技术实现

### 路径跟踪系统（7个状态机使用）

#### 模式：基础路径跟随

```gdscript
# 所有移动状态的统一模式

# 1. 状态变量
var current_path: PackedVector3Array = []
var current_waypoint: int = 0

# 2. enter() - 初始化路径
func enter(data: Dictionary = {}):
    var target_pos = _get_target_position()
    
    # 计算路径
    current_path = GridPathFinder.find_path(
        unit.global_position,
        target_pos
    )
    current_waypoint = 0
    
    # 验证路径
    if current_path.is_empty():
        state_finished.emit("IdleState")
        return

# 3. physics_update() - 跟随路径点
func physics_update(delta: float):
    # 检查是否到达当前路径点
    if current_waypoint < current_path.size():
        var target_waypoint = current_path[current_waypoint]
        var distance_to_waypoint = unit.global_position.distance_to(target_waypoint)
        
        # 到达路径点，前进
        if distance_to_waypoint < 0.3:
            current_waypoint += 1
            if current_waypoint >= current_path.size():
                # 路径完成
                state_finished.emit("TargetReachedState")
                return
        
        # 移动
        var direction = (target_waypoint - unit.global_position).normalized()
        direction.y = 0  # ✅ 强制2D移动
        unit.velocity = direction * (unit.speed / 100.0)
        unit.move_and_slide()
```

---

### 智能目标查找

#### 资源块周围寻路

**问题**: 金矿、地牢之心是不可通行的实体，不能直接寻路到中心。

**解决方案**: 自动找到周围可通行位置

**实现1: 金矿周围（1x1资源块）**
```gdscript
func _get_accessible_position_near_mine(mine) -> Vector3:
    var mine_center = Vector3(
        floor(mine.position.x) + 0.5,
        0.05,
        floor(mine.position.z) + 0.5
    )
    
    # 周围8个方向（距离1格）
    var offsets = [
        Vector3(-1, 0, 0), Vector3(1, 0, 0),    # 左、右
        Vector3(0, 0, -1), Vector3(0, 0, 1),    # 上、下
        Vector3(-1, 0, -1), Vector3(1, 0, -1),  # 对角
        Vector3(-1, 0, 1), Vector3(1, 0, 1)
    ]
    
    # 找到第一个可通行位置
    for offset in offsets:
        var test_pos = mine_center + offset
        if tile_manager.is_walkable(Vector3(int(test_pos.x), 0, int(test_pos.z))):
            return test_pos
    
    return mine_center + offsets[0]  # 后备方案
```

**实现2: 建筑周围（统一方法）**
```gdscript
# 🔧 [v4.3.0] 使用 BuildingFinder 统一方法
func _get_accessible_position_near_building(building: Node) -> Vector3:
    return BuildingFinder.get_walkable_position_near_building(character, building)

# 旧方法已废弃，现在使用统一API
# - 1x1建筑（金库）：搜索外部一圈
# - 2x2建筑（地牢之心）：搜索外部两圈
# - 3x3+建筑：搜索外部两圈
```

**效果**:
- ✅ Worker移动到金矿旁边 → 1.1x1.1交互范围内采矿
- ✅ Worker移动到地牢之心旁边 → 2.59米交互范围内存金币
- ✅ 完全符合游戏设计

---

### 物理移动系统（Godot 4）

#### CharacterBody3D配置

```gdscript
# CharacterBase.gd
extends CharacterBody3D

# 重力配置
const GRAVITY = 9.8

# 移动方法
func _physics_process(delta: float):
    # 应用重力
    if not is_on_floor():
        velocity.y -= GRAVITY * delta
    
    # 状态机控制velocity
    # ReturnToBaseState/MoveToMineState/etc 设置 velocity
    
    # 执行移动和碰撞检测
    move_and_slide()
```

#### 碰撞层配置

```gdscript
# 物理层定义：
# Layer 1: 环境层（墙壁、地形）
# Layer 2: 单位层（角色）
# Layer 3: 资源层（金矿、水晶）
# Layer 4: 建筑层（地牢之心、兵营等）

# CharacterBase碰撞配置
collision_layer = 2   # 单位层
collision_mask = 1 | 2 | 4  # 检测环境、其他单位、建筑
```

#### 交互范围计算

```gdscript
# CharacterBase提供统一的交互范围计算
func get_interaction_range(target_radius: float, buffer: float) -> float:
    # 总范围 = 角色半径 + 目标半径 + 缓冲距离
    var character_radius = size / 200.0  # size=18 → radius=0.09
    return character_radius + target_radius + buffer

# 示例使用
# 金矿交互：角色0.09 + 金矿0.5 + 缓冲0.5 = 1.09米
var effective_range = worker.get_interaction_range(0.5, 0.5)

# 地牢之心交互：角色0.09 + 建筑1.0 + 缓冲1.5 = 2.59米
var effective_range = worker.get_interaction_range(1.0, 1.5)
```

---

## 📊 移动行为矩阵

### 单位行为决策表

| 单位类型       | 情况   | 优先级1  | 优先级2         | 优先级3    | 优先级4 |
| -------------- | ------ | -------- | --------------- | ---------- | ------- |
| **哥布林苦工** | 任意   | 逃离敌人 | 背包满→返回基地 | 寻找金矿   | 游荡    |
| **地精工程师** | 有任务 | 逃离敌人 | 取金币          | 移动到建筑 | 工作    |
| **地精工程师** | 空闲   | 逃离敌人 | 归还剩余金币    | -          | 游荡    |

### 移动速度配置

| 单位类型       | 基础速度 | 实际速度（米/秒） | 逃离速度        | 游荡速度        |
| -------------- | -------- | ----------------- | --------------- | --------------- |
| **哥布林苦工** | 80       | 0.8 m/s           | 1.2 m/s (1.5x)  | 0.4 m/s (0.5x)  |
| **地精工程师** | 70       | 0.7 m/s           | 1.05 m/s (1.5x) | 0.35 m/s (0.5x) |

**速度计算公式**:
```gdscript
# speed范围：1-100
# 转换为实际速度（米/秒）
var actual_speed = speed / 100.0

# speed=80 → 0.8米/秒
# speed=70 → 0.7米/秒
```

---

## 🎮 状态转换详解

### Worker状态转换逻辑

#### IdleState → MoveToMineState

**触发条件**:
```gdscript
# 1. 背包未满
worker.carried_gold < worker.worker_config.carry_capacity

# 2. 找到可达金矿
var mine = _find_nearest_accessible_gold_mine(worker)
if mine:
    state_finished.emit("MoveToMineState", {"target_mine": mine})
```

**金矿选择条件**:
- ✅ 从GoldMineManager获取可达金矿
- ✅ 金矿未枯竭
- ✅ 金矿可接受新矿工
- ✅ 不在失败黑名单中（或已超时）

---

#### MoveToMineState → MiningState

**触发条件**:
```gdscript
# 到达金矿交互范围
var distance_to_mine = worker.global_position.distance_to(target_mine.position)
var effective_range = worker.get_interaction_range(0.5, 0.5)  # 1.09米

if distance_to_mine <= effective_range:
    state_finished.emit("MiningState", {"target_mine": target_mine})
```

**路径跟随**:
- 目标：金矿周围可通行位置（`_get_accessible_position_near_mine()`）
- 路径点间隔：0.3米判定到达
- 速度：0.8米/秒

---

#### MiningState → ReturnToBaseState

**触发条件**:
```gdscript
# 背包已满
worker.carried_gold >= worker.worker_config.carry_capacity  # 20金币

# 转换
state_finished.emit("ReturnToBaseState", {"target_base": dungeon_heart})
```

**挖矿参数**:
- 挖矿速率：0.5秒/次
- 每次产量：3金币（mining_power）
- 背包容量：20金币
- 挖满时间：≈3.3秒（20÷3÷0.5≈3.3）

---

#### ReturnToBaseState → DepositGoldState

**触发条件**:
```gdscript
# 到达地牢之心交互范围
var distance_to_base = worker.global_position.distance_to(target_base.global_position)
var effective_range = worker.get_interaction_range(1.0, 1.5)  # 2.59米

if distance_to_base <= effective_range:
    state_finished.emit("DepositGoldState", {"target_base": target_base})
```

**路径特性**:
- 目标：地牢之心周围可通行位置（`_get_accessible_position_near_base()`）
- 定期重新规划：1秒间隔
- 速度：0.8米/秒

---

#### DepositGoldState → IdleState

**存放金币后自动返回空闲**:
```gdscript
func enter(data: Dictionary = {}):
    var target_base = data["target_base"]
    
    # 存放金币到地牢之心
    if target_base.has_method("add_gold"):
        target_base.add_gold(worker.carried_gold)
    
    # 清空背包
    worker.carried_gold = 0
    
    # 返回空闲
    state_finished.emit("IdleState")
```

---

#### 任意状态 → EscapeState

**触发条件**:
```gdscript
# 在所有移动状态的physics_update()中检查
func _has_nearby_enemies(worker: Node) -> bool:
    var enemy = worker.find_nearest_enemy()
    if enemy and worker.global_position.distance_to(enemy.global_position) < 15.0:
        return true
    return false

# 检测到敌人
if _has_nearby_enemies(worker):
    state_finished.emit("EscapeState", {})
```

**逃离特性**:
- 检测范围：15米
- 逃离速度：1.5倍（1.2米/秒）
- 安全距离：20米（超过后返回IdleState）
- 方向混合：70%远离敌人 + 30%向基地

---

### Engineer状态转换逻辑

#### IdleState → FetchGoldState

**触发条件**:
```gdscript
# 接收到建造任务
var building_task = _find_building_task(engineer)
if building_task:
    state_finished.emit("FetchGoldState", {
        "target_building": building_task
    })
```

---

#### FetchGoldState → MoveToTargetState

**触发条件**:
```gdscript
# 到达金库/地牢之心并取到金币
var distance = engineer.global_position.distance_to(target_treasury.global_position)
var effective_range = engineer.get_interaction_range(1.0, 0.5)

if distance <= effective_range:
    _withdraw_gold(engineer)  # 取10金币
    
    if engineer.carried_gold > 0 and target_building:
        state_finished.emit("MoveToTargetState", {"target_building": target_building})
```

---

#### MoveToTargetState → WorkState

**触发条件**:
```gdscript
# 到达目标建筑
var distance = engineer.global_position.distance_to(target_building.global_position)
var effective_range = engineer.get_interaction_range(1.0, 0.5)

if distance <= effective_range:
    state_finished.emit("WorkState", {"target_building": target_building})
```

---

#### WorkState → ReturnGoldState / IdleState

**触发条件**:
```gdscript
# 工作完成后
if work_finished:
    if engineer.carried_gold > 0:
        # 有剩余金币，归还
        state_finished.emit("ReturnGoldState", {})
    else:
        # 无剩余金币，空闲
        state_finished.emit("IdleState", {})
```

---

## 🚀 性能优化策略

### 1. 路径缓存

**策略**: LRU缓存，5秒过期

```gdscript
# GridPathFinder内部实现
var path_cache: Dictionary = {}
var cache_max_size: int = 100
var cache_timeout: float = 5.0

func find_path(start, end):
    var cache_key = "%d,%d->%d,%d" % [start.x, start.z, end.x, end.z]
    
    # 检查缓存
    if path_cache.has(cache_key):
        var cached = path_cache[cache_key]
        if Time.get_ticks_msec() - cached.timestamp < cache_timeout * 1000:
            stats.cache_hits += 1
            return cached.path
    
    # 计算新路径
    var path = astar_grid.get_point_path(start_grid, end_grid)
    
    # 缓存路径
    path_cache[cache_key] = {
        "path": path,
        "timestamp": Time.get_ticks_msec()
    }
    
    return path
```

**效果**:
- 重复路径查询: <0.1ms
- 缓存命中率: 待测试

---

### 2. 批量更新

**策略**: 0.1秒间隔合并多次地形变化

```gdscript
var pending_updates: Array = []
var update_timer: float = 0.0
var batch_update_interval: float = 0.1

func set_cell_walkable_deferred(grid_pos: Vector2i, walkable: bool):
    pending_updates.append({"pos": grid_pos, "walkable": walkable})

func _process(delta: float):
    update_timer += delta
    if update_timer >= batch_update_interval and not pending_updates.is_empty():
        for update in pending_updates:
            astar_grid.set_point_solid(update.pos, not update.walkable)
        pending_updates.clear()
        invalidate_path_cache()
        update_timer = 0.0
```

**适用场景**: 玩家连续挖掘多个地块

---

### 3. 流场寻路（多Worker优化）

**适用场景**: 10+个Worker同时返回地牢之心

**实现**:
```gdscript
# 1. 预计算流场（BFS从目标向外扩散）
GridPathFinder.update_flow_field(dungeon_heart_position)

# 2. Worker AI简化为获取方向
func physics_update(delta: float):
    var direction = GridPathFinder.get_flow_direction(worker.global_position)
    if direction != Vector3.ZERO:
        worker.velocity = direction * (worker.speed / 100.0)
        worker.move_and_slide()
```

**性能**:
- 预计算: O(n) - 只需1次
- 每个Worker查询: O(1)
- 10个Worker: 比单独寻路快10倍

---

## 🔧 动态地形响应

### 挖掘后路径更新

**流程**:
```
玩家挖掘地块
    ↓
PlacementSystem._execute_dig()
    ↓
TileManager.set_tile_type(position, EMPTY)
    ↓
tile_data.is_walkable = true
    ↓
GridPathFinder.set_cell_walkable(grid_pos, true)  // O(1)
    ↓
astar_grid.set_point_solid(grid_pos, false)
    ↓
path_cache.clear()  // 清除缓存
    ↓
Worker下次调用find_path()时获得新路径
```

**响应时间**:
- NavigationMesh: 50-200ms（烘焙整个区域）
- AStarGrid2D: <1ms（更新单格）
- **提升**: 200倍

---

## 🎯 移动系统最佳实践

### 1. 状态机设计模式

**核心原则**:
- ✅ 每个状态只负责一个职责
- ✅ 使用`state_finished.emit()`进行状态转换
- ✅ 在`enter()`中初始化，在`exit()`中清理
- ✅ 在`physics_update()`中执行移动逻辑

**示例: MoveToMineState完整实现**
```gdscript
extends State
class_name GoblinWorkerMoveToMineState

var target_mine = null
var current_path: PackedVector3Array = []
var current_waypoint: int = 0

func enter(data: Dictionary = {}):
    target_mine = data["target_mine"]
    
    # 找到金矿旁边可通行位置
    var accessible_pos = _get_accessible_position_near_mine(target_mine)
    
    # 计算路径
    current_path = GridPathFinder.find_path(worker.global_position, accessible_pos)
    current_waypoint = 0
    
    if current_path.is_empty():
        # 标记失败
        worker.failed_mines[target_mine.position] = Time.get_ticks_msec()
        state_finished.emit("IdleState")
        return

func physics_update(delta: float):
    # 检查敌人
    if _has_nearby_enemies(worker):
        state_finished.emit("EscapeState", {})
        return
    
    # 检查是否到达交互范围
    var distance_to_mine = worker.global_position.distance_to(target_mine.position)
    var effective_range = worker.get_interaction_range(0.5, 0.5)
    if distance_to_mine <= effective_range:
        state_finished.emit("MiningState", {"target_mine": target_mine})
        return
    
    # 跟随路径
    if current_waypoint < current_path.size():
        var target = current_path[current_waypoint]
        if worker.global_position.distance_to(target) < 0.3:
            current_waypoint += 1
        
        var direction = (target - worker.global_position).normalized()
        direction.y = 0
        worker.velocity = direction * (worker.speed / 100.0)

func exit():
    worker.velocity = Vector3.ZERO
```

---

### 2. 错误处理

**路径查找失败**:
```gdscript
current_path = GridPathFinder.find_path(start, target)

if current_path.is_empty():
    # 对于金矿：标记失败，避免重复尝试
    worker.failed_mines[target.position] = Time.get_ticks_msec()
    
    # 返回空闲
    state_finished.emit("IdleState")
    return
```

**路径中途失败**:
```gdscript
# 路径完成但未到达目标
if current_waypoint >= current_path.size():
    if distance_to_target > effective_range:
        # 重新寻路
        current_path.clear()
        return
```

---

### 3. 调试技巧

**启用调试日志**:
```gdscript
# GoblinWorker.gd
debug_mode = true  # CharacterBase调试
worker_state_machine.debug_mode = true  # 状态机调试
```

**查看GridPathFinder统计**:
```gdscript
# 在游戏运行时调用
GridPathFinder.print_stats()

# 输出示例：
# === GridPathFinder 统计信息 ===
#   初始化状态: true
#   地图尺寸: (100, 100)
#   总查询次数: 145
#   缓存命中: 67
#   缓存未命中: 78
#   缓存命中率: 46.2%
#   平均路径长度: 12.3
#   平均查询时间: 2.1ms
```

**可视化路径**（可选）:
```gdscript
# 绘制路径点
func _draw_path_debug(path: PackedVector3Array):
    for i in range(path.size()):
        var sphere = create_debug_sphere(path[i])
        sphere.material_override.albedo_color = Color.GREEN
```

---

## 📈 性能分析

### 寻路性能测试

**测试环境**:
- 地图: 100x100网格
- 可通行地块: 60-70个（初始地牢之心周围）
- Worker数量: 1-10个

**测试结果**:
```
初始化: 0.3-0.5秒
  - 创建AStarGrid2D: <0.1秒
  - 同步地块状态: 0.2-0.4秒（10,000个地块）

首次寻路: 1-3ms
  - AStarGrid2D.get_point_path(): 1-2ms
  - 坐标转换: <0.5ms
  - 路径平滑（可选）: +0.5ms

缓存命中: <0.1ms
  - 字典查询: O(1)

地形更新: <1ms
  - set_point_solid(): O(1)
  - 缓存清除: O(1)
```

### 内存占用分析

```
GridPathFinder总内存: ~60KB
  - AStarGrid2D: ~10KB (100x100 bool数组)
  - 路径缓存: ~50KB (最多100条路径)
  - 流场数据: 可选启用

相比NavigationMesh节省: 99.6%
  - NavigationMesh数据: ~5MB
  - 临时烘焙数据: ~10MB
```

---

## 🎮 游戏体验影响

### 玩家可感知的改进

**1. 挖掘即时响应**
```
之前: 挖掘 → 等待200ms → Worker重新寻路
现在: 挖掘 → Worker立即重新寻路（<1ms）
```

**2. 更多Worker不卡顿**
```
之前: 10个Worker → 烘焙10次 → 2秒延迟
现在: 10个Worker → 更新10次 → <10ms延迟
```

**3. 路径可预测**
- 沿网格移动，路径清晰可见
- 玩家可以预判Worker行为
- 挖掘通道更有策略性

---

## 🔍 常见问题解答

### Q: Worker为什么不直接移动到金矿中心？
**A**: 金矿是`GOLD_MINE`类型，不可通行。Worker使用`_get_accessible_position_near_mine()`找到金矿旁边的可通行位置，然后在1.1x1.1交互范围内开始采矿。

### Q: 路径为什么是方格状的？
**A**: GridPathFinder使用网格寻路，对角线模式设置为`NEVER`。可以启用`AT_LEAST_ONE_WALKABLE`允许对角线移动，或使用`smooth_path()`平滑路径。

### Q: Worker会不会卡住？
**A**: 不会。所有移动状态都添加了：
1. `direction.y = 0` 强制2D移动
2. 路径跟随系统（0.3米判定到达）
3. 失败金矿记录（避免重复尝试）
4. 定期重新规划路径（1秒间隔）

### Q: 如何优化多个Worker性能？
**A**: 使用流场寻路：
```gdscript
# 1. 在地牢之心位置计算流场
GridPathFinder.update_flow_field(dungeon_heart_pos)

# 2. Worker直接获取方向
var direction = GridPathFinder.get_flow_direction(worker.global_position)
worker.velocity = direction * speed
```

### Q: 新的移动系统有什么优势？
**A**: v4.1.0完全统一移动API的优势：
- ✅ **代码简化**: 每个移动状态从75行减少到15行
- ✅ **系统一致**: 所有角色使用相同API
- ✅ **零冗余**: 移除多套并行移动系统
- ✅ **易于维护**: 统一的数据源和逻辑
- ✅ **自动功能**: 卡住检测、路径阻挡、精确移动全自动

### Q: 如何从旧系统迁移到新系统？
**A**: 遵循迁移指南：
```gdscript
# 旧代码
character.move_to_position(target)
# 或
character.position += direction * speed * delta

# 新代码
var result = MovementHelper.process_navigation(
    character, target, delta, "DebugPrefix"
)
```

### Q: "终点被阻挡"错误如何解决？
**A**: 已修复！现在使用BuildingFinder.get_walkable_position_near_building()：
```gdscript
# 自动根据建筑大小计算可到达位置
# 1x1建筑：搜索外部一圈
# 2x2建筑：搜索外部两圈
# 3x3+建筑：搜索外部两圈

# MovementHelper 内部自动调用
var approach_pos = BuildingFinder.get_walkable_position_near_building(character, building)
```

### Q: 建筑寻路如何适配不同大小？
**A**: BuildingFinder自动检测建筑大小：
```gdscript
# 自动检测建筑大小
var building_size = Vector2(1, 1) # 默认1x1
if building.has_method("get_building_size"):
    building_size = building.get_building_size()
elif "building_size" in building:
    building_size = building.building_size

# 根据大小生成搜索偏移量
var search_offsets = _generate_search_offsets(size_x, size_y)
```

---

## 📚 相关文档

- **物理系统**: `PHYSICS_SYSTEM.md` - CharacterBody3D、碰撞层配置
- **挖矿系统**: `MINING_SYSTEM.md` - Worker状态机、挖矿参数
- **资源系统**: `GOLD_SYSTEM.md` - 金币存储、资源管理、建筑寻路修复
- **地图生成**: `MAP_GENERATION_ARCHITECTURE.md` - 地图初始化、可达性
- **建筑系统**: `BUILDING_SYSTEM.md` - 建筑类型、大小配置

---

## 🎉 总结

**MazeMaster3D移动系统特点**:

1. ✅ **高性能**: AStarGrid2D动态网格寻路，挖掘响应<1ms
2. ✅ **智能化**: 自动找到资源块周围可通行位置
3. ✅ **建筑寻路优化**: 根据建筑大小智能计算可到达位置，消除"终点被阻挡"错误
4. ✅ **完全统一**: 所有单位使用相同的MovementHelper.process_navigation API
5. ✅ **零冗余**: 移除所有旧的NavigationAgent3D和直接位置修改
6. ✅ **系统一致**: CombatManager、MiningManager等全部统一
7. ✅ **可扩展**: 支持路径缓存、流场寻路、路径平滑
8. ✅ **易调试**: 性能统计、详细日志、网格可视化

**系统状态**: 生产就绪 🚀

**最后更新**: 2025-10-14 - 建筑寻路系统修复完成

---

*好的移动系统是优秀游戏AI的基石！* ✨
