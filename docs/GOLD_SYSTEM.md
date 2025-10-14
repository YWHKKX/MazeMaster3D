# 💰 MazeMaster3D - 资源存储系统文档

## 📚 系统概述

MazeMaster3D的资源系统采用**建筑存储架构**，所有金币和魔力存储在建筑物中（地牢之心、金库、魔法祭坛），由ResourceManager统一管理。

**版本**: v3.1  
**更新日期**: 2025-10-14  
**核心文件**:
- `ResourceManager.gd` - 资源管理器
- `DungeonHeart.gd` - 地牢之心
- `Treasury.gd` - 金库
- `BuildingFinder.gd` - 建筑查找器
- `MovementHelper.gd` - 移动助手
- `GameUI.gd` - 主UI界面

---

## 🏗️ 架构设计

### 核心理念

**建筑存储模式**（而非全局变量）:
```
金币/魔力 存储在建筑物中
    ↓
ResourceManager 从建筑列表汇总
    ↓
UI 显示总资源量
    ↓
消耗时从建筑中扣除
```

**优势**:
- ✅ 物理化资源（建筑可被摧毁）
- ✅ 容量限制（建筑有上限）
- ✅ 扩展性强（新建金库增加容量）
- ✅ 策略性强（保护资源建筑）

---

## 💰 金币系统

### 金币存储建筑

| 建筑类型 | 初始容量 | 初始资源 | 建筑大小 | 可建造数量  |
| -------- | -------- | -------- | -------- | ----------- |
| 地牢之心 | 5000     | 1000     | 2x2      | 1个（唯一） |
| 金库     | 500      | 0        | 1x1      | 无限        |

### 地牢之心（DungeonHeart）

**初始化**:
```gdscript
# DungeonHeart.gd
func _ready():
    building_type = "dungeon_heart"
    building_name = "地牢之心"
    
    # 存储容量
    gold_storage_capacity = 5000
    mana_storage_capacity = 2000
    
    # 初始资源（游戏开始时）
    stored_gold = 1000
    stored_mana = 500
    
    # 注册到ResourceManager
    # （由BuildingManager自动调用）
```

**特性**:
- 2x2大小（占用4个格子）
- 同时存储金币和魔力
- 游戏核心建筑，被摧毁则失败
- 位置：地图中心（51, 51）
- 状态栏显示：头顶显示"当前金币/最大容量"

### 金库（Treasury）

**初始化**:
```gdscript
# Treasury.gd
func _ready():
    building_type = "treasury"
    building_name = "金库"
    
    # 存储容量
    gold_storage_capacity = 500
    stored_gold = 0  # 初始为空
    
    # 注册到ResourceManager
```

**特性**:
- 1x1大小（占用1个格子）
- 只存储金币
- 维护成本：0（无消耗）
- 建造成本：100金币
- 状态栏显示：头顶显示"当前金币/最大容量"

---

## 🔮 魔力系统

### 魔力存储建筑

| 建筑类型 | 初始容量 | 初始资源 | 可建造数量  |
| -------- | -------- | -------- | ----------- |
| 地牢之心 | 500      | 500      | 1个（唯一） |
| 魔法祭坛 | 300      | 0        | 无限        |

### 魔法祭坛（MagicAltar）

**初始化**:
```gdscript
# MagicAltar.gd（未来实现）
func _ready():
    building_type = "magic_altar"
    building_name = "魔法祭坛"
    
    # 存储容量
    mana_storage_capacity = 300
    stored_mana = 0
    
    # 注册到ResourceManager
```

**特性**:
- 2x2大小
- 只存储魔力
- 建造成本：150金币

---

## 🏗️ 建筑寻路系统

### 问题背景

**"终点被阻挡"错误**：
- 角色寻路到建筑中心时，GridPathFinder报告"终点被阻挡"
- 原因：建筑中心是阻挡格子，不可通行
- 影响：苦工和工程师无法到达建筑进行交互

### 解决方案

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
# MovementHelper._find_adjacent_walkable_position()
static func _find_adjacent_walkable_position(building: Node, character: Node) -> Vector3:
    # 使用 BuildingFinder 的统一方法
    return BuildingFinder.get_walkable_position_near_building(character, building)
```

### 建筑大小适配

| 建筑大小 | 搜索范围 | 示例偏移量       |
| -------- | -------- | ---------------- |
| 1x1      | 外部一圈 | (-1,-1) 到 (1,1) |
| 2x2      | 外部两圈 | (-2,-2) 到 (2,2) |
| 3x3+     | 外部两圈 | (-3,-3) 到 (3,3) |

### 状态栏显示系统

**建筑状态栏**：
- 存储建筑头顶显示"💰 当前/最大"格式
- 实时更新：金币变化时立即刷新显示
- 使用UnitStatusBar组件，支持3D渲染

**实现代码**：
```gdscript
# Building.gd
func _setup_storage_status_bar():
    if _is_storage_building():
        var bar = UnitStatusBar.new()
        bar.set_offset_y(2.0)  # 建筑头顶
        bar.set_unit_size(30.0)  # 建筑使用更大状态栏
        bar.update_storage(stored_gold, gold_storage_capacity)
```

---

## 🎮 ResourceManager（资源管理器）

### 核心数据结构

```gdscript
# ResourceManager.gd
class_name ResourceManager

# 建筑列表（动态维护）
var gold_buildings: Array = []  # 存储金币的建筑
var mana_buildings: Array = []  # 存储魔力的建筑

# 其他资源（直接存储）
var stored_stone: int = 0
var stored_wood: int = 0
var stored_iron: int = 0
```

### ResourceInfo类

```gdscript
class ResourceInfo:
    var total: int = 0          # 总量
    var available: int = 0      # 可用量
    var capacity: int = 0       # 容量上限
    var sources: Array = []     # 来源列表
    
    # sources示例:
    # [
    #   {
    #     "building": "dungeon_heart",
    #     "name": "地牢之心(49,49)",
    #     "amount": 850,
    #     "capacity": 1000,
    #     "available": 850
    #   },
    #   {
    #     "building": "treasury",
    #     "name": "金库(30,30)",
    #     "amount": 250,
    #     "capacity": 500,
    #     "available": 250
    #   }
    # ]
```

---

## 📥 资源获取（查询）

### 获取总金币

```gdscript
# ResourceManager.get_total_gold()
func get_total_gold() -> ResourceInfo:
    var sources = []
    var total_gold = 0
    var total_capacity = 0
    
    # 遍历所有金币建筑
    for building in gold_buildings:
        if "stored_gold" in building:
            var building_name = building.building_name
            var position = "(%d,%d)" % [building.tile_x, building.tile_y]
            var capacity = building.gold_storage_capacity
            
            sources.append({
                "building": building.building_type,
                "name": building_name + position,
                "amount": building.stored_gold,
                "capacity": capacity,
                "available": building.stored_gold
            })
            
            total_gold += building.stored_gold
            total_capacity += capacity
    
    return ResourceInfo.new(total_gold, total_gold, total_capacity, sources)

# 便捷方法
func get_gold() -> int:
    return get_total_gold().total
```

### 获取总魔力

```gdscript
func get_total_mana() -> ResourceInfo:
    var sources = []
    var total_mana = 0
    var total_capacity = 0
    
    for building in mana_buildings:
        if "stored_mana" in building:
            # ... 类似金币逻辑 ...
            total_mana += building.stored_mana
            total_capacity += building.mana_storage_capacity
    
    return ResourceInfo.new(total_mana, total_mana, total_capacity, sources)
```

### 使用示例

```gdscript
# 获取详细信息
var gold_info = resource_manager.get_total_gold()
print("总金币: %d/%d" % [gold_info.total, gold_info.capacity])
for source in gold_info.sources:
    print("  - %s: %d" % [source.name, source.amount])

# 获取简单数值
var gold = resource_manager.get_gold()
if gold >= 100:
    buy_something()
```

---

## 📤 资源添加（收入）

### 添加金币

```gdscript
# ResourceManager.add_gold()
func add_gold(amount: int) -> bool:
    if amount <= 0:
        return false
    
    var remaining = amount
    
    # 优先填充非满的建筑
    for building in gold_buildings:
        if "stored_gold" not in building:
            continue
        
        var capacity = building.gold_storage_capacity
        var current = building.stored_gold
        var available_space = capacity - current
        
        if available_space > 0:
            var to_add = min(remaining, available_space)
            building.stored_gold += to_add
            remaining -= to_add
            
            LogManager.info("添加金币: +%d → %s（现有%d/%d）" % [
                to_add, building.building_name, building.stored_gold, capacity
            ])
            
            if remaining <= 0:
                break
    
    # 发送信号通知UI
    resource_changed.emit(ResourceType.GOLD, amount, get_gold() - amount)
    
    # 如果还有剩余，说明容量不足
    if remaining > 0:
        LogManager.warning("金币存储空间不足，丢失 %d 金币" % remaining)
        return false
    
    return true
```

### 苦工存储金币流程

```gdscript
# ReturnToBaseState.gd
func deposit_gold():
    var amount = worker.carried_gold
    
    # 添加到ResourceManager（会自动分配到建筑）
    if resource_manager.add_gold(amount):
        worker.carried_gold = 0
        LogManager.info("苦工存储了 %d 金币" % amount)
    else:
        LogManager.warning("金币存储失败（容量不足）")
```

---

## 💸 资源消耗（支出）

### 消耗金币

```gdscript
# ResourceManager.consume_gold()
func consume_gold(amount: int) -> Dictionary:
    """消耗金币，返回消耗结果
    
    Returns:
        {
            "success": bool,       # 是否成功
            "consumed": int,       # 实际消耗量
            "remaining": int,      # 剩余需求
            "sources": Array       # 消耗来源
        }
    """
    var result = {
        "success": false,
        "consumed": 0,
        "remaining": amount,
        "sources": []
    }
    
    # 检查总量
    var total = get_gold()
    if total < amount:
        insufficient_resources.emit(ResourceType.GOLD, amount, total)
        return result
    
    # 从建筑中扣除（优先扣除非地牢之心）
    var remaining = amount
    
    # 第一轮：从金库扣除
    for building in gold_buildings:
        if building.building_type == "treasury" and remaining > 0:
            var available = building.stored_gold
            var to_consume = min(remaining, available)
            
            if to_consume > 0:
                building.stored_gold -= to_consume
                remaining -= to_consume
                result.consumed += to_consume
                result.sources.append({
                    "building": building.building_name,
                    "amount": to_consume
                })
    
    # 第二轮：从地牢之心扣除
    if remaining > 0:
        for building in gold_buildings:
            if building.building_type == "dungeon_heart":
                var available = building.stored_gold
                var to_consume = min(remaining, available)
                
                if to_consume > 0:
                    building.stored_gold -= to_consume
                    remaining -= to_consume
                    result.consumed += to_consume
                    result.sources.append({
                        "building": building.building_name,
                        "amount": to_consume
                    })
    
    result.success = (remaining == 0)
    result.remaining = remaining
    
    # 发送信号
    if result.success:
        resource_changed.emit(ResourceType.GOLD, -amount, total)
        resource_removed.emit(ResourceType.GOLD, amount)
    
    return result
```

### 建造建筑流程

```gdscript
# PlacementSystem.place_entity()
func place_entity(entity_id: String, position: Vector3) -> bool:
    var config = entity_configs[entity_id]
    var cost = config.cost
    
    # 检查资源
    var gold = resource_manager.get_gold()
    if gold < cost:
        LogManager.warning("金币不足：需要%d，当前%d" % [cost, gold])
        return false
    
    # 扣除资源
    var result = resource_manager.consume_gold(cost)
    if not result.success:
        LogManager.error("资源扣除失败")
        return false
    
    # 执行建造
    _execute_placement(entity_id, position)
    
    LogManager.info("建造成功，花费 %d 金币" % cost)
    return true
```

---

## 🔔 信号系统

### 信号定义

```gdscript
# ResourceManager信号
signal resource_changed(resource_type: ResourceType, amount: int, old_amount: int)
signal resource_added(resource_type: ResourceType, amount: int)
signal resource_removed(resource_type: ResourceType, amount: int)
signal insufficient_resources(resource_type: ResourceType, required: int, available: int)
```

### UI连接示例

```gdscript
# ResourceDisplayUI.gd
func _ready():
    var resource_manager = GameServices.get_service("resource_manager")
    
    # 连接信号
    resource_manager.resource_changed.connect(_on_resource_changed)
    resource_manager.resource_added.connect(_on_resource_added)
    resource_manager.resource_removed.connect(_on_resource_removed)
    
    # 初始更新
    _update_resource_display()

func _on_resource_changed(type: ResourceType, amount: int, old_amount: int):
    _update_resource_display()
    
    # 显示变化动画
    if amount > 0:
        _show_gain_animation(type, amount)
    else:
        _show_loss_animation(type, abs(amount))

func _update_resource_display():
    var gold_info = resource_manager.get_total_gold()
    var mana_info = resource_manager.get_total_mana()
    
    gold_label.text = "%d / %d" % [gold_info.total, gold_info.capacity]
    mana_label.text = "%d / %d" % [mana_info.total, mana_info.capacity]
```

---

## 🏗️ 建筑注册

### 注册流程

```gdscript
# BuildingManager.register_building()
func register_building(building: Node):
    buildings.append(building)
    
    # 自动注册到ResourceManager
    var resource_manager = GameServices.get_service("resource_manager")
    
    match building.building_type:
        "dungeon_heart":
            resource_manager.register_dungeon_heart(building)
        "treasury":
            resource_manager.register_treasury(building)
        "magic_altar":
            resource_manager.register_magic_altar(building)
```

### 注销流程

```gdscript
# BuildingManager.unregister_building()
func unregister_building(building: Node):
    buildings.erase(building)
    
    # 从ResourceManager移除
    var resource_manager = GameServices.get_service("resource_manager")
    
    if "stored_gold" in building:
        resource_manager.remove_gold_building(building)
    if "stored_mana" in building:
        resource_manager.remove_mana_building(building)
    
    LogManager.warning("建筑被摧毁: %s，资源丢失！" % building.building_name)
```

---

## 📊 资源面板UI

### 显示内容

```
┌─────────────────┐
│ 💰 金币: 1250/1500 │  ← 总量/总容量
│ 🔮 魔力: 450/800   │
│ 🪨 石头: 50       │  ← 直接存储
│ 🪵 木材: 30       │
│ ⚙️ 铁矿: 10       │
└─────────────────┘
```

### 实现代码

```gdscript
# ResourceDisplayUI.gd
func _update_resource_display():
    if not resource_manager:
        return
    
    # 获取资源信息
    var gold_info = resource_manager.get_total_gold()
    var mana_info = resource_manager.get_total_mana()
    
    # 更新标签
    gold_label.text = "💰 %d/%d" % [gold_info.total, gold_info.capacity]
    mana_label.text = "🔮 %d/%d" % [mana_info.total, mana_info.capacity]
    
    # 容量警告（≥90%显示红色）
    if gold_info.total >= gold_info.capacity * 0.9:
        gold_label.add_theme_color_override("font_color", Color.RED)
    else:
        gold_label.add_theme_color_override("font_color", Color.WHITE)
```

### 详细信息面板

```gdscript
# 点击资源图标显示详细信息
func _on_gold_clicked():
    var gold_info = resource_manager.get_total_gold()
    var details = ""
    
    for source in gold_info.sources:
        details += "%s: %d/%d\n" % [
            source.name,
            source.amount,
            source.capacity
        ]
    
    show_tooltip(details)
```

---

## ⚖️ 经济平衡

### 初始资源

```
地牢之心:
  金币: 1000
  魔力: 500
  容量: 5000金币 / 2000魔力

足以：
  - 建造1个金库（100金币）
  - 召唤12个哥布林苦工（80金币/个 = 960金币）
  - 还剩-60金币（需要先挖矿）
```

### 资源流入

| 来源         | 速率            | 说明             |
| ------------ | --------------- | ---------------- |
| 挖矿（苦工） | ~4金币/秒/苦工  | 主要收入来源     |
| 金矿（建筑） | 0（当前未实现） | 被动收入（未来） |
| 击杀英雄     | 不定（未来）    | 战斗奖励         |

### 资源流出

| 支出         | 费用 | 频率         |
| ------------ | ---- | ------------ |
| 哥布林苦工   | 80   | 按需         |
| 哥布林工程师 | 100  | 按需         |
| 小恶魔       | 50   | 按需         |
| 石像鬼       | 150  | 按需         |
| 金库         | 100  | 一次性       |
| 兵营         | 150  | 一次性       |
| 维护成本     | 0    | 无（已取消） |

### 容量规划

```
初始容量: 5000（地牢之心）
扩展方案:
  - 每个金库+500容量
  - 建议配比: 1地牢之心 + 2金库 = 6000容量

金矿总量: 128个 × 500金币 = 64,000金币（理论）
推荐容量: 6000-8000（足够缓冲）
```

---

## 🔒 安全机制

### 容量保护

```gdscript
# 达到容量上限时停止接收
if gold_info.total >= gold_info.capacity:
    LogManager.warning("金币存储已满，无法添加")
    return false
```

### 建筑摧毁保护

```gdscript
# 地牢之心特殊处理
func on_building_destroyed(building):
    if building.building_type == "dungeon_heart":
        # 游戏失败
        GameEvents.emit_signal("game_over", "地牢之心被摧毁")
    else:
        # 普通建筑：资源丢失
        var lost_gold = building.stored_gold
        LogManager.warning("建筑被摧毁，丢失 %d 金币" % lost_gold)
```

### 资源不足提示

```gdscript
func _on_insufficient_resources(type, required, available):
    var resource_name = "金币" if type == ResourceType.GOLD else "魔力"
    show_notification("❌ %s不足！需要%d，当前%d" % [
        resource_name, required, available
    ])
```

---

## 🐛 常见问题

### Q1: 资源面板显示0？
**A**: 检查初始化顺序：
```gdscript
# main.gd
await create_initial_dungeon()  # 必须await
show_main_menu()  # 之后才显示UI
```

### Q2: 存储金币失败？
**A**: 检查：
1. 地牢之心是否正确注册
2. ResourceManager是否初始化
3. 容量是否已满

```gdscript
# 调试代码
var gold_buildings = resource_manager.gold_buildings
print("金币建筑数量: ", gold_buildings.size())
for building in gold_buildings:
    print("  - %s: %d/%d" % [
        building.building_name,
        building.stored_gold,
        building.gold_storage_capacity
    ])
```

### Q3: UI不更新？
**A**: 检查信号连接：
```gdscript
# ResourceDisplayUI._ready()
var resource_manager = GameServices.get_service("resource_manager")
if resource_manager:
    resource_manager.resource_changed.connect(_on_resource_changed)
else:
    LogManager.error("ResourceManager未找到")
```

### Q4: 扣除金币失败？
**A**: 使用consume_gold而非remove_gold：
```gdscript
# ❌ 错误
resource_manager.remove_gold(100)

# ✅ 正确
var result = resource_manager.consume_gold(100)
if result.success:
    proceed()
```

### Q5: "终点被阻挡"错误？
**A**: 已修复！现在使用BuildingFinder.get_walkable_position_near_building()：
```gdscript
# 自动根据建筑大小计算可到达位置
# 1x1建筑：搜索外部一圈
# 2x2建筑：搜索外部两圈
# 3x3+建筑：搜索外部两圈
```

### Q6: 建筑状态栏不显示？
**A**: 检查建筑类型和状态栏设置：
```gdscript
# 只有存储建筑才显示状态栏
func _is_storage_building() -> bool:
    return building_type in [BuildingTypes.DUNGEON_HEART, BuildingTypes.TREASURY]

# 状态栏更新
func _update_storage_display():
    if status_bar and status_bar.has_method("update_storage"):
        status_bar.update_storage(stored_gold, gold_storage_capacity)
```

---

## 📚 API参考

### ResourceManager主要方法

```gdscript
# 查询
func get_gold() -> int
func get_total_gold() -> ResourceInfo
func get_mana() -> int
func get_total_mana() -> ResourceInfo

# 添加
func add_gold(amount: int) -> bool
func add_mana(amount: int) -> bool

# 消耗
func consume_gold(amount: int) -> Dictionary
func consume_mana(amount: int) -> Dictionary

# 建筑注册
func register_dungeon_heart(building)
func register_treasury(building)
func register_magic_altar(building)
func remove_gold_building(building)
func remove_mana_building(building)
```

### BuildingFinder主要方法

```gdscript
# 建筑查找
static func get_nearest_storage_building(character: Node) -> Node
static func get_nearest_dungeon_heart(character: Node) -> Node
static func get_nearest_treasury(character: Node) -> Node
static func get_nearest_gold_source(character: Node) -> Node

# 寻路辅助
static func get_walkable_position_near_building(character: Node, building: Node) -> Vector3
static func get_accessible_position_near_mine(character: Node, mine: Node) -> Vector3
```

### MovementHelper主要方法

```gdscript
# 交互移动
static func process_interaction_movement(character: Node, target_building: Node, delta: float, debug_prefix: String) -> InteractionMoveResult
static func reset_interaction_movement(character: Node)

# 普通移动
static func process_navigation(character: Node, target_position: Vector3, delta: float, debug_prefix: String) -> MoveResult
static func reset_navigation(character: Node)
```

### Building属性

```gdscript
# 每个建筑必须实现
var building_type: String         # "dungeon_heart" / "treasury" / ...
var building_name: String         # 显示名称
var stored_gold: int = 0          # 当前存储金币
var stored_mana: int = 0          # 当前存储魔力
var gold_storage_capacity: int   # 金币容量
var mana_storage_capacity: int   # 魔力容量
var tile_x: int                  # X坐标
var tile_y: int                  # Z坐标
```

---

## 🎉 总结

MazeMaster3D的资源系统采用创新的建筑存储架构：

**核心特性**:
- ✅ 建筑存储模式（物理化资源）
- ✅ 动态容量系统（可扩展）
- ✅ 统一管理接口（ResourceManager）
- ✅ 实时信号更新（UI同步）
- ✅ 智能扣除策略（优先金库）
- ✅ 智能寻路系统（支持不同建筑大小）
- ✅ 3D状态栏显示（建筑头顶显示存储信息）

**游戏体验**:
- 资源有物理实体（建筑）
- 容量可见可管理
- 建筑摧毁 = 资源丢失（风险）
- 扩展金库 = 扩大经济（策略）
- 角色能正确寻路到建筑（无"终点被阻挡"错误）
- 建筑状态一目了然（头顶显示存储量）

**技术优势**:
- 易于扩展（添加新建筑类型）
- 调试友好（资源来源清晰）
- 性能优秀（O(n)查询，n=建筑数）
- 架构清晰（单一职责原则）
- 寻路智能（自动适配建筑大小）
- 代码统一（BuildingFinder集中管理）

**最新改进**:
- 🔧 修复"终点被阻挡"寻路问题
- 🔧 增加建筑状态栏显示
- 🔧 统一建筑查找API
- 🔧 优化经济平衡（地牢之心容量提升至5000）

*资源是地下城的生命线，保护好你的宝库！* 💰🏰
