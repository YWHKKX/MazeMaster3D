# ⚙️ Autoload配置说明

## 📋 需要配置的Autoload

按照以下顺序在 `Project Settings -> Autoload` 中添加：

### 1. LogManager（已存在）
- ✅ Path: `res://scripts/managers/LogManager.gd`
- ✅ Node Name: `LogManager`
- ✅ 优先级：最高（第一个加载）

### 2. GameServices
- 📁 Path: `res://godot_project/autoload/GameServices.gd`
- 🏷️ Node Name: `GameServices`
- 📌 优先级：第二（依赖LogManager）

### 3. GameEvents
- 📁 Path: `res://godot_project/autoload/GameEvents.gd`
- 🏷️ Node Name: `GameEvents`
- 📌 优先级：第三

### 4. GameGroups
- 📁 Path: `res://godot_project/autoload/GameGroups.gd`
- 🏷️ Node Name: `GameGroups`
- 📌 优先级：第四

### 5. BuildingTypes
- 📁 Path: `res://godot_project/autoload/BuildingTypes.gd`
- 🏷️ Node Name: `BuildingTypes`
- 📌 优先级：第五
- 📝 用途：建筑类型常量定义，避免魔法数字

### 6. BuildingStatus
- 📁 Path: `res://autoload/BuildingStatus.gd`
- 🏷️ Node Name: `BuildingStatus`
- 📌 优先级：第六
- 📝 用途：建筑状态常量定义，消除魔法数字（0,1,2）
- ✅ 已配置到 project.godot

### 7. TileTypes ⚠️ **需要配置**
- 📁 Path: `res://autoload/TileTypes.gd`
- 🏷️ Node Name: `TileTypes`
- 📌 优先级：第七
- 📝 用途：瓦片类型常量，地图系统支持

### 8. CharacterTypes ⚠️ **需要配置**
- 📁 Path: `res://autoload/CharacterTypes.gd`
- 🏷️ Node Name: `CharacterTypes`
- 📌 优先级：第八
- 📝 用途：角色类型常量，避免字符串拼写错误

### 9. CombatTypes ⚠️ **需要配置**
- 📁 Path: `res://autoload/CombatTypes.gd`
- 🏷️ Node Name: `CombatTypes`
- 📌 优先级：第九
- 📝 用途：战斗系统常量（伤害类型、效果、计算）

---

## 🔧 配置步骤

1. 打开 Godot Editor
2. 点击菜单 `Project -> Project Settings`
3. 选择 `Autoload` 标签
4. 点击 `Add` 按钮
5. 浏览并选择对应的 `.gd` 文件
6. 设置 `Node Name`（必须与上面一致）
7. 点击 `Add` 完成

重复以上步骤添加所有Autoload。

---

## ✅ 验证配置

配置完成后，在 `Project Settings -> Autoload` 中应该看到：

```
[已启用] LogManager
[已启用] GameServices
[已启用] GameEvents
[已启用] GameGroups
[已启用] GridPathFinder
[已启用] BuildingTypes
[已启用] BuildingStatus
[待添加] TileTypes  ⚠️
[待添加] CharacterTypes  ⚠️
[待添加] CombatTypes  ⚠️
```

---

## 🎯 使用示例

配置完成后，可以在任何脚本中直接使用：

```gdscript
# 访问管理器
var physics = GameServices.physics_system
var resources = GameServices.resource_manager

# 发送事件
GameEvents.resource_changed.emit("gold", 100, 1000)

# 监听事件
func _ready():
	GameEvents.character_spawned.connect(_on_character_spawned)

# 使用Groups
GameGroups.add_to_group(self, GameGroups.WORKERS)
var all_workers = GameGroups.get_all_workers()

# 使用BuildingTypes
if building.building_type == BuildingTypes.DUNGEON_HEART:
    print("这是地牢之心")
var name = BuildingTypes.get_building_name(building.building_type)

# 使用BuildingStatus
if building.status == BuildingStatus.COMPLETED:
    print("建筑已完成")
var status_name = BuildingStatus.get_status_name(building.status)

# 使用TileTypes
if TileTypes.is_walkable(tile_type):
    allow_movement()

# 使用CharacterTypes
var name = CharacterTypes.get_character_name(CharacterTypes.GOBLIN_WORKER)

# 使用CombatTypes
var damage = CombatTypes.calculate_actual_damage(100, 20, CombatTypes.PHYSICAL_DAMAGE)
```

---

## ⚠️ 注意事项

1. **加载顺序很重要**：LogManager必须第一个，GameServices第二个
2. **Node Name必须精确匹配**：代码中使用的是这些名称
3. **不要重复添加**：检查是否已存在同名Autoload
4. **测试验证**：添加后运行游戏，检查控制台输出

---

## 🐛 常见问题

### Q: 找不到GameServices
**A**: 检查Autoload是否正确配置，Node Name是否为 "GameServices"

### Q: 报错"Invalid call..."
**A**: 确保LogManager已配置且在GameServices之前

### Q: 信号不触发
**A**: 检查是否正确连接，使用 `GameEvents.signal_name.connect(callback)`

---

## 📚 更多信息

查看完整重构方案：`docs/REFACTORING_PLAN.md`

