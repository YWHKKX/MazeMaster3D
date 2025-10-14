# 核心常量和枚举系统

## 概述

本目录包含了游戏的核心常量、枚举定义和配置系统。这些文件为整个游戏提供统一的配置管理。

## 文件说明

### Constants.gd
**游戏常量类**

包含所有游戏中使用的常量值，如：
- 地图和世界设置
- 战斗系统参数
- 物理系统常量
- 移动系统参数
- 建筑系统配置
- UI常量
- 颜色定义

**使用示例：**
```gdscript
# 获取默认攻击范围
var attack_range = Constants.DEFAULT_ATTACK_RANGE

# 使用颜色常量
var ui_color = Constants.Colors.UI_BG

# 使用击退距离
var knockback_dist = Constants.KNOCKBACK_DISTANCE_NORMAL
```

### GameBalance.gd
**游戏平衡配置类**

包含游戏平衡相关的参数，如：
- 起始资源（金币、魔力、食物）
- 单位和建筑限制
- 刷新率和生成配置
- 资源生成和消耗
- 建筑成本
- 单位成本和维护费用
- 战斗平衡参数

**使用示例：**
```gdscript
# 获取起始金币
var starting_gold = GameBalance.STARTING_GOLD

# 获取建筑成本
var treasury_cost = GameBalance.TREASURY_COST

# 获取护甲减伤比例
var armor_reduction = GameBalance.ARMOR_DAMAGE_REDUCTION
```

### Enums.gd
**枚举定义类**

包含所有游戏中使用的枚举类型，如：
- TileType: 瓦片类型
- BuildMode: 建造模式
- CreatureType: 生物类型
- CreatureStatus: 生物状态
- EngineerStatus: 工程师专用状态
- WorkerStatus: 苦工专用状态
- AttackType: 攻击类型
- KnockbackType: 击退类型
- BuildingType: 建筑类型
- BuildingStatus: 建筑状态
- Faction: 阵营
- ResourceType: 资源类型
- DamageType: 伤害类型
- SkillType: 技能类型
- UIMode: UI模式
- GameState: 游戏状态

**使用示例：**
```gdscript
# 定义生物类型
var creature_type: Enums.CreatureType = Enums.CreatureType.GOBLIN_WORKER

# 使用建筑状态
var building_status: Enums.BuildingStatus = Enums.BuildingStatus.COMPLETED

# 转换枚举为字符串
var type_name = Enums.creature_type_to_string(creature_type)

# 在match语句中使用
match tile_type:
    Enums.TileType.ROCK:
        print("这是岩石")
    Enums.TileType.GOLD_VEIN:
        print("这是金矿")
```

### BuildingStatuses.gd
**建筑状态配置类**

提供建筑状态的颜色映射和辅助函数：
- 状态颜色定义
- 状态名称（中文）
- 状态判断辅助函数

**使用示例：**
```gdscript
# 获取建筑状态颜色
var status_color = BuildingStatuses.get_status_color(building.status)

# 获取状态名称
var status_name = BuildingStatuses.get_status_name(building.status)

# 判断建筑是否可用
if BuildingStatuses.is_building_operational(building.status):
    print("建筑可用")

# 判断是否需要维护
if BuildingStatuses.needs_maintenance(building.status):
    print("建筑需要维护")

# 判断是否在工作
if BuildingStatuses.is_working(building.status):
    print("建筑正在工作")
```

## 设计原则

### 1. 单一数据源
所有常量和配置都定义在这些文件中，避免在代码中硬编码魔法数字。

### 2. 类型安全
使用 Godot 的枚举系统确保类型安全，避免使用字符串或整数表示状态。

### 3. 易于调整
游戏平衡参数集中在 `GameBalance.gd` 中，方便快速调整和平衡。

### 4. 可读性
使用有意义的常量名和详细的注释，提高代码可读性。

## 最佳实践

### ✅ 推荐做法

```gdscript
# 使用常量而不是硬编码
var speed = base_speed * Constants.COMBAT_SPEED_MULTIPLIER

# 使用枚举进行状态管理
var state: Enums.CreatureStatus = Enums.CreatureStatus.IDLE

# 使用辅助函数
var status_color = BuildingStatuses.get_status_color(status)
```

### ❌ 不推荐做法

```gdscript
# 不要硬编码数值
var speed = base_speed * 1.2  # 应该使用 Constants.COMBAT_SPEED_MULTIPLIER

# 不要使用字符串表示状态
var state = "idle"  # 应该使用 Enums.CreatureStatus.IDLE

# 不要直接使用数字表示类型
var creature_type = 5  # 应该使用 Enums.CreatureType.ORC_WARRIOR
```

## 修改指南

### 添加新常量

1. 在 `Constants.gd` 或 `GameBalance.gd` 中找到合适的分类
2. 添加常量定义，使用有意义的名称
3. 添加注释说明其用途
4. 如果是颜色，使用 Color 类型

```gdscript
## 新功能的常量
const NEW_FEATURE_COOLDOWN: float = 5.0  # 新功能冷却时间（秒）
```

### 添加新枚举

1. 在 `Enums.gd` 中添加新的枚举类型
2. 如果需要，添加对应的辅助转换函数
3. 更新本文档的枚举列表

```gdscript
enum NewFeatureType {
    TYPE_A,
    TYPE_B,
    TYPE_C
}

static func new_feature_type_to_string(type: NewFeatureType) -> String:
    match type:
        NewFeatureType.TYPE_A: return "type_a"
        NewFeatureType.TYPE_B: return "type_b"
        NewFeatureType.TYPE_C: return "type_c"
        _: return "unknown"
```

### 修改平衡参数

直接修改 `GameBalance.gd` 中的值即可，无需修改其他代码：

```gdscript
# 调整起始金币
const STARTING_GOLD: int = 1500  # 从 1000 增加到 1500
```

## 与 Python 版本的对应关系

本系统基于 Python 版本的以下文件：
- `src/core/constants.py` → `Constants.gd` + `GameBalance.gd`
- `src/core/enums.py` → `Enums.gd`
- 建筑状态相关 → `BuildingStatuses.gd`

主要差异：
1. Python 的 `class` 变成了 Godot 的 `class_name`
2. Python 的 Enum 变成了 Godot 的 `enum`
3. RGB 颜色元组转换为 `Color` 对象
4. 常量使用 `const` 关键字而不是类变量

## 版本历史

- v1.0 (2025-10-10): 初始版本，从 Python 版本迁移
  - 创建 Constants.gd
  - 创建 GameBalance.gd
  - 创建 Enums.gd
  - 创建 BuildingStatuses.gd

## 相关文档

- [重构计划](../../../docs/GODOT_3D_REFACTOR_PLAN.md)
- [设计文档](../../../docs/设计文档.md)
- [Python 版本常量系统](../../../../MazeMaster/src/core/constants.py)

