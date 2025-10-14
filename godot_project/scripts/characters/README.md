# 角色系统使用指南

## 概述

本角色系统提供了一个统一的、模块化的角色管理框架，适用于所有游戏单位（怪物和英雄）。

**版本**: v4.0  
**更新日期**: 2025-10-14  
**主要改进**: 
- ✅ 统一移动API（MovementHelper）
- ✅ 建筑寻路优化（BuildingFinder）
- ✅ 金矿包装器系统修复
- ✅ 状态机API统一化

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

### 4. HeroBase.gd (extends CharacterBase)
**英雄基类**，所有英雄的父类。

**特有功能**：
- 巡逻行为
- 追击系统
- 技能系统
- 经验和等级系统
- 查找怪物和建筑

## 继承层次

```
CharacterBase (CharacterBody3D)
├── MonsterBase
│   ├── GoblinWorker
│   ├── GoblinEngineer
│   ├── Imp
│   ├── OrcWarrior
│   └── ...
└── HeroBase
    ├── Knight
    ├── Archer
    ├── Mage
    └── ...
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

```gdscript
# 在角色脚本中获取状态机
@onready var state_machine: StateMachine = $StateMachine

func _ready():
    super._ready()
    # 状态机会自动启动并进入初始状态

# 在状态中访问角色属性
# IdleState.gd
func enter(_data: Dictionary = {}) -> void:
    # owner_node 引用 GoblinWorker 实例
    var nearest_mine = owner_node.find_nearest_gold_mine()
    if nearest_mine:
        change_to("MoveToMineState", {"target": nearest_mine})
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
StateMachine
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

### 4. 正确使用阵营系统

```gdscript
# 判断敌友关系
if character.is_enemy_of(other_character):
    # 攻击敌人
    pass
elif character.is_friend_of(other_character):
    # 帮助友军
    pass
```

### 5. 生命周期管理

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

- v1.0 (2025-10-10): 初始版本
  - 创建 CharacterData Resource
  - 创建 CharacterBase 基类
  - 创建 MonsterBase 怪物基类
  - 创建 HeroBase 英雄基类
  - 集成状态机系统
  - 集成常量和枚举系统

---

**最后更新**：2025-10-10  
**版本**：1.0  
**状态**：稳定

