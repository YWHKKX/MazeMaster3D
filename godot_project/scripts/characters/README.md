# 角色系统使用指南

## 概述

本角色系统提供了一个统一的、模块化的角色管理框架，适用于所有游戏单位（怪物和英雄）。

**版本**: v5.0  
**更新日期**: 2025-01-15  
**主要改进**: 
- ✅ 统一移动API（MovementHelper）
- ✅ 建筑寻路优化（BuildingFinder）
- ✅ 金矿包装器系统修复
- ✅ 状态机API统一化
- ✅ 统一状态机系统（StateManager）
- ✅ 阵营化状态机配置（野兽、英雄、怪物）

## 核心组件

### 1. CharacterData.gd (Resource)
**角色静态数据资源**，存储角色的配置信息。

**用途**：
- 在编辑器中创建和编辑角色配置
- 可序列化保存和加载
- 多个角色实例可以共享同一个 CharacterData

**属性分类**：
- 基础信息：名称、类型、图标、描述
- 基础属性：生命、攻击、防御、速度、体型
- 战斗属性：攻击范围、冷却时间、检测范围
- 经济属性：召唤成本、维护费
- 特殊能力：技能列表、特殊能力描述
- 视觉属性：颜色、发光效果
- 物理属性：击退类型、免疫、飞行能力
- 工作属性：挖矿速度、携带容量、建造速度

### 2. CharacterBase.gd (CharacterBody3D)
**角色基类**，所有角色的共同父类。

**核心功能**：
- 生命值管理和回血系统
- 战斗系统（受伤、死亡、目标管理）
- 阵营系统（敌友判断）
- 物理系统集成
- 导航系统集成
- 状态机集成
- 信号系统

### 3. MonsterBase.gd (extends CharacterBase)
**怪物基类**，所有怪物的父类。

**特有功能**：
- 游荡行为
- 逃跑行为
- 工作系统（挖矿、建造）
- 查找敌人和友军
- 工作信号
- 自动状态机创建（通用怪物状态）

### 4. HeroBase.gd (extends CharacterBase)
**英雄基类**，所有英雄的父类。

**特有功能**：
- 巡逻行为
- 追击系统
- 技能系统
- 经验和等级系统
- 查找怪物和建筑
- 自动状态机创建（英雄状态）

### 5. BeastBase.gd (extends CharacterBase)
**野兽基类**，所有野兽的父类。

**特有功能**：
- 觅食行为
- 逃跑行为
- 中立行为模式
- 生存状态管理
- 自动状态机创建（野兽状态）

### 6. StateManager.gd
**统一状态管理器**，负责管理所有阵营的状态机系统。

**核心功能**：
- 为不同阵营的角色创建相应的状态机
- 管理状态脚本的加载和配置
- 提供统计和调试功能
- 支持野兽、英雄、怪物三个阵营的状态机配置

## 继承层次

```
CharacterBase (CharacterBody3D)
├── MonsterBase
│   ├── GoblinWorker (独立状态机)
│   ├── GoblinEngineer (独立状态机)
│   ├── Imp
│   ├── OrcWarrior
│   └── ... (使用通用怪物状态机)
├── HeroBase
│   ├── Knight
│   ├── Archer
│   ├── Mage
│   └── ... (使用英雄状态机)
└── BeastBase
    ├── Deer
    ├── ForestWolf
    ├── GiantRat
    └── ... (使用野兽状态机)
```

## 🤖 统一状态机系统

### 概述
本系统为 MazeMaster3D 游戏中的三个阵营（野兽、英雄、怪物）提供了统一的状态机管理。每个阵营都有其独特的行为模式，通过状态机系统实现智能的AI行为。

### 阵营设计

#### 🦌 野兽阵营（中立势力）
- **特点**: 中立行为，不会主动攻击，主要进行觅食、游荡、休息等生存行为
- **状态**: IdleState, WanderState, FleeState, SeekFoodState, ConsumeFoodState, RestState
- **行为模式**: 被动防御，遇到威胁时逃跑

#### ⚔️ 英雄阵营（友方势力）
- **特点**: 主动保护，会帮助友军，主动攻击敌人
- **状态**: IdleState, CombatState, PatrolState, SupportState, RetreatState
- **行为模式**: 主动进攻，支援友军，巡逻保护

#### 👹 怪物阵营（敌对势力）
- **特点**: 主动攻击，会追击敌人，守卫特定区域
- **状态**: IdleState, CombatState, ChaseState, PatrolState, GuardState, RetreatState
- **行为模式**: 主动进攻，追击敌人，守卫领地

### 特殊单位状态机
某些特殊单位（如 GoblinWorker、GoblinEngineer）拥有独立的状态机实现，不依赖通用的阵营状态机：

- **GoblinWorker**: 专门的工作状态机（挖矿、返回基地、存储金币等）
- **GoblinEngineer**: 专门的工程状态机（建造、修理、获取金币等）

### 状态机文件结构

```
characters/
├── StateManager.gd                    # 统一状态管理器
├── CharacterBase.gd                   # 角色基类（已更新支持状态机）
├── BeastBase.gd                       # 野兽基类
├── HeroBase.gd                        # 英雄基类
├── MonsterBase.gd                     # 怪物基类
├── beasts/
│   └── beast_states/                  # 野兽状态机
│       ├── IdleState.gd
│       ├── WanderState.gd
│       ├── FleeState.gd
│       ├── SeekFoodState.gd
│       ├── ConsumeFoodState.gd
│       └── RestState.gd
├── heroes/
│   └── hero_states/                   # 英雄状态机
│       ├── IdleState.gd
│       ├── CombatState.gd
│       ├── PatrolState.gd
│       ├── SupportState.gd
│       └── RetreatState.gd
└── monsters/
    ├── goblin_worker_states/          # 哥布林苦工专用状态机
    │   ├── IdleState.gd
    │   ├── MoveToMineState.gd
    │   ├── MiningState.gd
    │   ├── ReturnToBaseState.gd
    │   ├── DepositGoldState.gd
    │   ├── WanderState.gd
    │   └── EscapeState.gd
    ├── goblin_engineer_states/        # 地精工程师专用状态机
    │   ├── IdleState.gd
    │   ├── FetchGoldState.gd
    │   ├── MoveToTargetState.gd
    │   ├── WorkState.gd
    │   ├── ReturnGoldState.gd
    │   ├── WanderState.gd
    │   └── EscapeState.gd
    └── monster_states/                # 通用怪物状态机
        ├── IdleState.gd
        ├── CombatState.gd
        ├── ChaseState.gd
        ├── PatrolState.gd
        ├── GuardState.gd
        └── RetreatState.gd
```

## 快速开始

### 1. 创建角色数据资源

在 Godot 编辑器中：
1. 右键 → 新建 → 资源 → CharacterData
2. 填写角色属性
3. 保存为 `.tres` 文件

或在代码中：
```gdscript
var goblin_data = CharacterData.new()
goblin_data.character_name = "哥布林苦工"
goblin_data.max_health = 100
goblin_data.attack = 5
goblin_data.speed = 20
# ... 设置其他属性
```

### 2. 创建角色场景

创建一个新场景，结构如下：
```
GoblinWorker (extends MonsterBase)
├── Model (MeshInstance3D)
├── CollisionShape (CollisionShape3D)
├── NavigationAgent (NavigationAgent3D)
├── StateMachine (StateMachine)
│   ├── IdleState
│   ├── MoveToMineState
│   └── MiningState
└── AnimationPlayer
```

### 3. 编写角色脚本

```gdscript
# GoblinWorker.gd
class_name GoblinWorker
extends MonsterBase

# 苦工特有属性
var current_gold: int = 0
var max_gold: int = 100

func _ready() -> void:
    super._ready()
    
    # 设置为工人单位（不自动战斗）
    is_combat_unit = false
    
    # 加入特定组
    add_to_group("workers")

# 查找最近的金矿
func find_nearest_gold_mine() -> Node3D:
    var gold_mines = GameGroups.get_nodes("gold_mines")
    # ... 查找逻辑
    return null
```

## 使用示例

### 示例 1：创建怪物

```gdscript
# 在场景中实例化
var goblin_scene = preload("res://scenes/characters/monsters/goblin_worker.tscn")
var goblin = goblin_scene.instantiate()
goblin.position = Vector3(10, 0, 10)
add_child(goblin)
```

### 示例 2：使用战斗系统

```gdscript
# 让角色受伤
character.take_damage(20.0, attacker)

# 治疗角色
character.heal(50.0)

# 检查是否血量过低
if character.is_low_health():
    character.start_fleeing()

# 连接生命值变化信号
character.health_changed.connect(_on_health_changed)

func _on_health_changed(old_hp: float, new_hp: float):
    print("生命值变化: %d → %d" % [old_hp, new_hp])
```

### 示例 3：使用目标系统

```gdscript
# 设置目标
var enemy = find_nearest_enemy()
if enemy:
    character.set_target(enemy)

# 检查目标是否有效
if character.is_target_valid():
    # 攻击目标
    if character.can_attack_target(character.current_target):
        # 执行攻击逻辑
        pass

# 清除目标
character.clear_target()
```

### 示例 4：使用状态机

#### 4.1 通用角色状态机（自动创建）

```gdscript
# 在 BeastBase, HeroBase, MonsterBase 中，状态机会自动创建
func _ready() -> void:
    super._ready()
    
    # 设置阵营（野兽、英雄、怪物）
    faction = Enums.Faction.BEASTS
    
    # 状态机会根据阵营自动创建相应的状态
    if enable_state_machine and not state_machine:
        state_machine = StateManager.get_instance().create_state_machine_for_character(self)

# 在状态中访问角色属性
# IdleState.gd
func enter(_data: Dictionary = {}) -> void:
    # owner_node 引用角色实例
    if owner_node.faction == Enums.Faction.BEASTS:
        # 野兽行为
        pass
    elif owner_node.faction == Enums.Faction.HEROES:
        # 英雄行为
        pass
```

#### 4.2 特殊单位状态机（GoblinWorker, GoblinEngineer）

```gdscript
# GoblinWorker.gd - 使用专用状态机
@onready var worker_state_machine: Node = $StateMachine

func _ready() -> void:
    super._ready()
    
    # 启用调试模式
    debug_mode = true
    if worker_state_machine:
        worker_state_machine.debug_mode = true

# 在专用状态中访问苦工属性
# MoveToMineState.gd
func enter(_data: Dictionary = {}) -> void:
    # owner_node 引用 GoblinWorker 实例
    var nearest_mine = owner_node.find_nearby_gold_mine()
    if nearest_mine:
        change_to("MiningState", {"target": nearest_mine})
```

#### 4.3 手动创建状态机

```gdscript
# 如果需要手动创建状态机
var state_machine = StateManager.get_instance().create_state_machine_for_character(character)

# 调试状态机
if character.debug_mode:
    print("当前状态: %s" % state_machine.get_current_state_name())
```

### 示例 5：使用信号系统

```gdscript
# 连接信号
character.died.connect(_on_character_died)
character.attacked.connect(_on_character_attacked)
character.target_acquired.connect(_on_target_acquired)

func _on_character_died():
    print("%s 死亡了" % character.get_character_name())
    # 播放死亡特效
    # 更新UI
    # 掉落物品

func _on_character_attacked(attacker: CharacterBase, damage: float):
    print("%s 被攻击，受到 %.1f 伤害" % [character.get_character_name(), damage])

func _on_target_acquired(target: Node3D):
    print("%s 锁定目标: %s" % [character.get_character_name(), target.name])
```

## 最佳实践

### 1. 使用 CharacterData 配置角色

✅ **推荐**：
```gdscript
@export var character_data: CharacterData
# 在编辑器中指定 CharacterData 资源
```

❌ **不推荐**：
```gdscript
# 硬编码属性
max_health = 100
attack = 20
# 不易维护和调整
```

### 2. 使用信号解耦

✅ **推荐**：
```gdscript
# 发出信号
character.died.emit()

# 在其他系统中监听
character.died.connect(_on_character_died)
```

❌ **不推荐**：
```gdscript
# 直接调用其他系统的方法
ui_manager.update_character_died(character)
# 造成紧耦合
```

### 3. 使用状态机管理行为

✅ **推荐**：
```gdscript
# 使用状态机管理复杂行为
# 通用角色使用阵营状态机
StateMachine (自动创建)
├── IdleState
├── CombatState
├── PatrolState
└── RetreatState

# 特殊单位使用专用状态机
GoblinWorker StateMachine
├── IdleState
├── MoveToMineState
├── MiningState
└── ReturnToBaseState
```

❌ **不推荐**：
```gdscript
# 在 _process 中使用大量 if-else
func _process(delta):
    if is_idle:
        # 空闲逻辑
    elif is_mining:
        # 挖矿逻辑
    # ... 几百行代码
```

### 4. 状态机使用最佳实践

✅ **推荐**：
```gdscript
# 让角色基类自动创建状态机
func _ready() -> void:
    super._ready()
    faction = Enums.Faction.BEASTS  # 设置阵营
    # 状态机会根据阵营自动创建

# 在状态中访问角色属性
func enter(_data: Dictionary = {}) -> void:
    # 使用 owner_node 访问角色实例
    if owner_node.has_method("find_nearest_enemy"):
        var enemy = owner_node.find_nearest_enemy()
```

❌ **不推荐**：
```gdscript
# 手动创建状态机（除非有特殊需求）
var state_machine = StateMachine.new()
# 手动添加状态...
```

### 5. 正确使用阵营系统

```gdscript
# 判断敌友关系
if character.is_enemy_of(other_character):
    # 攻击敌人
    pass
elif character.is_friend_of(other_character):
    # 帮助友军
    pass
```

### 6. 生命周期管理

```gdscript
func _ready():
    super._ready()  # 始终调用父类的 _ready
    # 子类的初始化逻辑

func _process(delta):
    super._process(delta)  # 可选，根据需要
    # 子类的更新逻辑
```

## 与 Python 版本的对应

| Python 版本      | Godot 版本               | 说明     |
| ---------------- | ------------------------ | -------- |
| `Creature` 类    | `CharacterBase.gd`       | 角色基类 |
| `Monster` 类     | `MonsterBase.gd`         | 怪物基类 |
| `Hero` 类        | `HeroBase.gd`            | 英雄基类 |
| 属性字典         | `CharacterData` Resource | 数据驱动 |
| `faction` 字符串 | `Enums.Faction` 枚举     | 类型安全 |
| `CreatureStatus` | `Enums.CreatureStatus`   | 统一枚举 |

## 场景模板

### 怪物场景模板

```
MonsterScene.tscn
├── GoblinWorker (MonsterBase) [Script: GoblinWorker.gd]
│   ├── character_data = goblin_worker_data.tres
│   ├── faction = MONSTERS
│   └── debug_mode = false
├── Model (MeshInstance3D)
│   └── mesh = BoxMesh
├── CollisionShape (CollisionShape3D)
│   └── shape = CapsuleShape3D
├── NavigationAgent (NavigationAgent3D)
├── StateMachine (StateMachine)
│   ├── IdleState
│   ├── MoveToMineState
│   └── MiningState
└── AnimationPlayer
```

### 英雄场景模板

```
HeroScene.tscn
├── Knight (HeroBase) [Script: Knight.gd]
│   ├── character_data = knight_data.tres
│   ├── faction = HEROES
│   └── patrol_radius = 10.0
├── Model (MeshInstance3D)
├── CollisionShape (CollisionShape3D)
├── NavigationAgent (NavigationAgent3D)
├── StateMachine (StateMachine)
│   ├── IdleState
│   ├── PatrolState
│   └── CombatState
└── AnimationPlayer
```

## 调试技巧

### 1. 启用调试模式

在编辑器中设置 `debug_mode = true`，或在代码中：
```gdscript
character.debug_mode = true
```

### 2. 打印角色信息

```gdscript
print(character.get_character_info())
print(monster.get_monster_info())
print(hero.get_hero_info())
```

### 3. 可视化调试

```gdscript
# 可视化碰撞体
get_tree().debug_collisions_hint = true

# 可视化导航路径
nav_agent.debug_enabled = true
```

## 参考资料

- [角色设计文档](../../../docs/CHARACTER_DESIGN.md)
- [状态机指南](../core/state_machine/README.md)
- [Godot CharacterBody3D 文档](https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html)
- Python 版本：`src/entities/creature.py`

## 版本历史

- v5.0 (2025-01-15): 统一状态机系统
  - 新增 BeastBase 野兽基类
  - 新增 StateManager 统一状态管理器
  - 实现阵营化状态机配置（野兽、英雄、怪物）
  - 保持 GoblinWorker 和 GoblinEngineer 的独立状态机
  - 更新状态机文档和使用指南

- v4.0 (2025-10-14): 状态机API统一化
  - 统一移动API（MovementHelper）
  - 建筑寻路优化（BuildingFinder）
  - 金矿包装器系统修复
  - 状态机API统一化

- v1.0 (2025-10-10): 初始版本
  - 创建 CharacterData Resource
  - 创建 CharacterBase 基类
  - 创建 MonsterBase 怪物基类
  - 创建 HeroBase 英雄基类
  - 集成状态机系统
  - 集成常量和枚举系统

---

**最后更新**：2025-01-15  
**版本**：5.0  
**状态**：稳定

