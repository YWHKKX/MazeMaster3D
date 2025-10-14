# 🗺️ MazeMaster3D - 地图生成架构文档

## 📚 系统概述

MazeMaster3D采用**程序化地图生成**架构，在运行时动态创建100x100的地下城地图，包含随机房间、通道、金矿等元素。

**版本**: v3.0  
**更新日期**: 2025-10-12  
**核心文件**:
- `MapGenerator.gd` - 地图生成器
- `TileManager.gd` - 地块管理器
- `RoomGenerator.gd` - 房间生成器

---

## 🏗️ 架构设计

### 场景结构

```
Main.tscn（场景文件）
├── Main (Node3D) - 主脚本
├── GameManager (Node)
├── TileManager (Node) - 地块管理
├── MapGenerator (Node) - 地图生成
├── World (Node3D) - 世界容器
│   ├── Environment (Node3D)
│   │   └── Dungeon (Node3D) ← 运行时动态添加 10,000个MeshInstance3D
│   ├── Characters (Node3D) ← 角色对象
│   └── Buildings (Node3D) ← 建筑对象
└── UI (CanvasLayer)
```

### 设计理念

**程序化生成（Procedural Generation）**:
- ✅ 每次游戏地图不同
- ✅ 无限可能性
- ✅ 支持动态挖掘和建造
- ✅ 类似《我的世界》、《暗黑地牢》

**优势**:
- 高度灵活，支持任意地图修改
- 可以挖掘、建造、动态改变地形
- 支持Roguelike随机性

**劣势**:
- 无法在编辑器中预览
- 每次启动需要生成时间（约0.5-1秒）
- 调试相对困难

---

## 🎲 地图生成流程

### 生成时序

```
游戏启动
  └── Main._ready()
       └── initialize_game()
       └── create_initial_dungeon()
             └── MapGenerator.generate_map()
                      ├── [1] _initialize_map() - 初始化100x100数组
                      ├── [2] _place_dungeon_heart() - 放置地牢之心（2x2）
                      ├── [3] _generate_initial_floor() - 生成8x8初始地面
                      ├── [4] _generate_rooms_on_map() - 生成随机房间
                      ├── [5] _generate_gold_mines() - 生成金矿
                      └── [6] GameEvents.emit("map_generated") - 通知生成完成
```

### 详细步骤

#### 步骤1: 初始化地图结构

**TileManager._initialize_map_structure()**:
```gdscript
func _initialize_map_structure():
    map_data = []
    
    for level_idx in range(levels_count):
        var level_data = []
        for x in range(int(map_size.x)):
            var row = []
            for z in range(int(map_size.z)):
                var pos = Vector3(x, 0, z)
                var tile_info = TileInfo.new(pos, TileType.UNEXCAVATED, level)
                row.append(tile_info)
            level_data.append(row)
        map_data.append(level_data)
    
    LogManager.info("地图结构初始化完成: %d x %d x %d" % [
        map_size.x, map_size.z, levels_count
    ])
```

**结果**: 100x100x1 的三维数组，所有地块初始化为 `UNEXCAVATED`（未挖掘）

---

#### 步骤2: 放置地牢之心

**MapGenerator._place_dungeon_heart()**:
```gdscript
func _place_dungeon_heart():
    var center = Vector2i(50, 50)  # 地图中心
    
    # 1. 创建8x8石质地面区域
    for x in range(center.x - 3, center.x + 5):
        for z in range(center.y - 3, center.y + 5):
            tile_manager.set_tile_type(Vector3(x, 0, z), TileType.STONE_FLOOR)
    
    # 2. 放置2x2地牢之心
    var heart_positions = [
        Vector3(49, 0, 49),
        Vector3(50, 0, 49),
        Vector3(49, 0, 50),
        Vector3(50, 0, 50)
    ]
    
    for pos in heart_positions:
        tile_manager.set_tile_type(pos, TileType.DUNGEON_HEART)
    
    # 3. 创建地牢之心建筑对象
    var dungeon_heart_scene = preload("res://...")
    var dungeon_heart = dungeon_heart_scene.instantiate()
    dungeon_heart.global_position = Vector3(49.5, 0.05, 49.5)
    
    # 4. 初始化资源
    dungeon_heart.stored_gold = 1000
    dungeon_heart.stored_mana = 500
    
    LogManager.info("地牢之心已放置在 (49.5, 49.5)")
```

**结果**: 
- 8x8石质地面（46-53, 46-53）
- 2x2地牢之心（49-50, 49-50）
- 初始资源：1000金币，500魔力

---

#### 步骤3: 生成随机房间

**MapGenerator._generate_rooms_on_map()**:
```gdscript
func _generate_rooms_on_map():
    var max_rooms = map_config.max_room_count  # 15个房间
    var min_size = map_config.min_room_size     # 最小6x6
    var max_size = map_config.max_room_size     # 最大15x15
    
    for i in range(max_rooms):
        # 1. 随机房间大小
        var room_size = Vector2i(
            randi_range(min_size, max_size),
            randi_range(min_size, max_size)
        )
        
        # 2. 随机位置（避开地牢之心区域）
        var room_pos = _get_random_room_position(room_size)
        
        # 3. 检查重叠
        var new_room = Room.new(room_pos, room_size, rooms.size())
        if _is_overlapping(new_room):
            continue
        
        # 4. 创建房间
        _create_room(new_room)
        rooms.append(new_room)
    
    # 5. 连接房间（生成通道）
    _connect_rooms()
    
    LogManager.info("已生成 %d 个房间" % rooms.size())
```

**房间类型**:
- 标准房间（石质地面 + 石墙边界）
- 房间大小：6x6 到 15x15
- 房间数量：尝试15个，成功约10-12个（因重叠检测）

**房间结构**:
```gdscript
class Room:
    var position: Vector2i      # 左上角坐标
    var size: Vector2i          # 房间尺寸
    var center: Vector2i        # 中心坐标
    var connections: Array      # 连接的房间列表
    var room_id: int
    var room_type: String = "normal"
```

---

#### 步骤4: 连接房间（通道生成）

**MapGenerator._connect_rooms()**:
```gdscript
func _connect_rooms():
    for i in range(rooms.size() - 1):
        var room_a = rooms[i]
        var room_b = rooms[i + 1]
        
        # 使用L形通道连接
        _create_l_corridor(room_a.center, room_b.center)
        
        room_a.connections.append(room_b)
        room_b.connections.append(room_a)
    
    # 额外随机连接
    for i in range(map_config.room_connection_attempts):
        var room_a = rooms[randi() % rooms.size()]
        var room_b = rooms[randi() % rooms.size()]
        
        if room_a != room_b and room_b not in room_a.connections:
            _create_l_corridor(room_a.center, room_b.center)
            room_a.connections.append(room_b)
            room_b.connections.append(room_a)
```

**通道生成**:
```gdscript
func _create_l_corridor(from: Vector2i, to: Vector2i):
    var width = map_config.corridor_width  # 3格宽
    
    # 水平段
    var x_min = min(from.x, to.x)
    var x_max = max(from.x, to.x)
    for x in range(x_min, x_max + 1):
        for w in range(width):
            var pos = Vector3(x, 0, from.y + w - 1)
            tile_manager.set_tile_type(pos, TileType.CORRIDOR)
    
    # 垂直段
    var y_min = min(from.y, to.y)
    var y_max = max(from.y, to.y)
    for y in range(y_min, y_max + 1):
        for w in range(width):
            var pos = Vector3(to.x + w - 1, 0, y)
            tile_manager.set_tile_type(pos, TileType.CORRIDOR)
```

**结果**: 所有房间通过3格宽的L形通道连接

---

#### 步骤5: 生成金矿

**MapGenerator._generate_gold_mines()（实际由GoldMineManager处理）**:
```gdscript
func generate_gold_mines():
    var map_size = tile_manager.get_map_size()
    var mine_count = 0
    
    for x in range(map_size.x):
        for z in range(map_size.z):
            var pos = Vector3(x, 0, z)
            var tile_data = tile_manager.get_tile_data(pos)
            
            # 只在未挖掘的岩石上生成
            if tile_data and tile_data.type == TileType.UNEXCAVATED:
                if randf() < 0.08:  # 8%概率
                    _create_gold_mine(pos)
                    mine_count += 1
                    
                    if mine_count >= config.max_mines:  # 最多50个
                        break
    
    LogManager.info("已生成 %d 个金矿" % mine_count)
```

**金矿特性**:
- 生成概率：8%
- 预期数量：约128个（理论），实际约50-100个
- 初始储量：500金币/矿
- 位置：随机分布在未挖掘岩石上

---

## 🎨 地块渲染系统

### 渲染方式

**动态MeshInstance3D**（程序化生成）:

```gdscript
# TileManager._create_tile_object()
func _create_tile_object(tile_data: TileInfo):
    # 1. 创建MeshInstance3D
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.name = "Tile_%d_%d" % [tile_data.position.x, tile_data.position.z]
    
    # 2. 创建Mesh
    var mesh = _get_mesh_for_tile_type(tile_data.type)
    mesh_instance.mesh = mesh
    
    # 3. 设置材质
    var material = _get_material_for_tile_type(tile_data.type)
    mesh_instance.set_surface_override_material(0, material)
    
    # 4. 设置位置
    mesh_instance.global_position = _get_tile_world_position(tile_data.position)
    
    # 5. 添加碰撞体（墙壁/金矿）
    if tile_data.type in [TileType.STONE_WALL, TileType.GOLD_MINE]:
        _add_simple_collision(mesh_instance, tile_data)
    
    # 6. 添加交互区域（金矿）
    if tile_data.type == TileType.GOLD_MINE:
        _add_tile_interaction_area(mesh_instance, tile_data)
    
    # 7. 添加到场景树
    var dungeon = get_node("/root/Main/World/Environment/Dungeon")
    dungeon.add_child(mesh_instance)
    
    tile_data.tile_object = mesh_instance
```

### 地块类型对照表

| 地块类型      | Mesh类型  | 尺寸（米）   | 世界Y位置 | 碰撞体          |
| ------------- | --------- | ------------ | --------- | --------------- |
| UNEXCAVATED   | BoxMesh   | 1.0x1.0x1.0  | 0.5       | StaticBody3D    |
| STONE_WALL    | BoxMesh   | 1.0x1.0x1.0  | 0.5       | StaticBody3D    |
| STONE_FLOOR   | PlaneMesh | 1.0x0.05x1.0 | 0.025     | 无              |
| GOLD_MINE     | BoxMesh   | 1.0x1.0x1.0  | 0.5       | StaticBody+Area |
| DUNGEON_HEART | 自定义    | 2x2（特殊）  | 0.5       | StaticBody+Area |

### 材质配置

```gdscript
func _get_material_for_tile_type(tile_type: TileType) -> StandardMaterial3D:
    var material = StandardMaterial3D.new()
    
    match tile_type:
        TileType.UNEXCAVATED:
            material.albedo_color = Color(0.3, 0.3, 0.3)  # 深灰
        TileType.STONE_WALL:
            material.albedo_color = Color(0.5, 0.5, 0.5)  # 灰色
        TileType.STONE_FLOOR:
            material.albedo_color = Color(0.6, 0.6, 0.6)  # 浅灰
        TileType.GOLD_MINE:
            material.albedo_color = Color(1.0, 0.84, 0.0) # 金色
            material.emission_enabled = true
            material.emission = Color(0.8, 0.7, 0.0)
        TileType.CORRIDOR:
            material.albedo_color = Color(0.65, 0.65, 0.65)
    
    return material
```

---

## 📊 地图数据结构

### TileInfo类

```gdscript
class TileInfo:
    var type: TileType              # 地块类型
    var state: TileState            # 地块状态
    var position: Vector3           # 网格坐标（x, 0, z）
    var level: MapLevel             # 层级
    var is_walkable: bool           # 是否可行走
    var is_buildable: bool          # 是否可建造
    var is_diggable: bool           # 是否可挖掘
    var is_building: bool           # 是否为建筑
    var is_reachable: bool          # 是否可达（从地牢之心）
    var resources: Dictionary       # 资源数据
    var building_data: Dictionary   # 建筑数据
    var building_ref: Node          # 建筑对象引用
    var tile_object: MeshInstance3D # 3D对象引用
    var highlight_option: TileHighlightOption  # 高亮选项
```

### 地图数据数组

```gdscript
# TileManager
var map_data: Array = []  # Array[Array[Array[TileInfo]]]

# 访问方式
func get_tile_data(position: Vector3) -> TileInfo:
    var level = 0
    var x = int(position.x)
    var z = int(position.z)
    
    if x < 0 or x >= map_size.x or z < 0 or z >= map_size.z:
        return null
    
    return map_data[level][x][z]
```

---

## 🔍 可达性系统

### 洪水填充算法

**目的**: 计算从地牢之心可达的所有地块

**算法**:
```gdscript
# TileManager.update_tile_reachability()
func update_tile_reachability():
    # 1. 重置所有地块
    for level in map_data:
        for row in level:
            for tile in row:
                tile.is_reachable = false
    
    # 2. 从地牢之心开始（4个瓦块）
    var queue: Array = []
    var heart_positions = [
        Vector3(49, 0, 49),
        Vector3(50, 0, 49),
        Vector3(49, 0, 50),
        Vector3(50, 0, 50)
    ]
    
    for pos in heart_positions:
        queue.append(pos)
        var tile = get_tile_data(pos)
        if tile:
            tile.is_reachable = true
    
    # 3. 洪水填充
    while not queue.is_empty():
        var current_pos = queue.pop_front()
        
        # 检查4个方向
        for dir in [Vector3(1,0,0), Vector3(-1,0,0), Vector3(0,0,1), Vector3(0,0,-1)]:
            var neighbor_pos = current_pos + dir
            var neighbor = get_tile_data(neighbor_pos)
            
            if neighbor and neighbor.is_walkable and not neighbor.is_reachable:
                neighbor.is_reachable = true
                queue.append(neighbor_pos)
    
    LogManager.info("可达性分析完成")
```

**触发时机**:
- 地图生成完成后
- 挖掘地块后
- 建造建筑后

---

## ⚡ 性能考虑

### 当前性能数据

```
地图大小: 100x100 = 10,000 地块
生成时间: 0.5-1.0秒
内存占用: ~50MB（包含所有MeshInstance3D）
帧率影响: 初始生成时有短暂卡顿，之后稳定60fps
```

### 性能瓶颈

1. **MeshInstance3D创建** - 10,000个独立对象
2. **材质创建** - 每个地块独立材质
3. **场景树添加** - add_child操作耗时

### 优化方案（未来）

#### 方案A: GridMap（推荐）

**优势**:
- Godot内置优化，批量渲染
- 内存占用更小
- 编辑器可视化
- NavigationMesh自动集成

**迁移工作量**: 中等（2-3天）

**示例**:
```gdscript
# 使用GridMap
var grid_map = GridMap.new()
grid_map.mesh_library = preload("res://assets/dungeon_mesh_library.tres")

# 设置地块
grid_map.set_cell_item(Vector3i(x, 0, z), TILE_ID)
```

---

#### 方案B: MultiMeshInstance3D

**优势**:
- GPU实例化渲染
- 极高性能
- 保持程序化生成

**劣势**:
- 碰撞检测需额外处理
- 动态修改较复杂

**示例**:
```gdscript
# 批量渲染相同类型地块
var multi_mesh = MultiMesh.new()
multi_mesh.mesh = box_mesh
multi_mesh.instance_count = stone_wall_count

for i in range(stone_wall_count):
    multi_mesh.set_instance_transform(i, transform)
    multi_mesh.set_instance_color(i, color)

var multi_mesh_instance = MultiMeshInstance3D.new()
multi_mesh_instance.multimesh = multi_mesh
```

---

## 🔄 动态修改系统

### 挖掘地块

```gdscript
# PlacementSystem._execute_dig()
func _execute_dig(position: Vector3):
    # 1. 更改地块类型
    tile_manager.set_tile_type(position, TileType.EMPTY)
    
    # 2. 更新可达性
    tile_manager.update_tile_reachability()
    
    # 3. 触发导航网格更新
    navigation_manager.rebake_navigation_mesh()
    
    # 4. 检查金矿发现
    var gold_mine = gold_mine_manager.check_gold_mine(position)
    if gold_mine:
        tile_manager.set_tile_type(position, TileType.GOLD_MINE)
        GameEvents.emit_signal("gold_mine_discovered", gold_mine)
```

### 建造建筑

```gdscript
# PlacementSystem.place_building()
func place_building(building_type: String, position: Vector3):
    # 1. 检查是否可建造
    if not tile_manager.is_buildable(position):
        return false
    
    # 2. 扣除资源
    if not resource_manager.consume_gold(building_cost):
        return false
    
    # 3. 放置建筑
    tile_manager.set_tile_type(position, TileType.BARRACKS)  # 示例
    
    # 4. 创建建筑对象
    var building_scene = load("res://scenes/buildings/%s.tscn" % building_type)
    var building = building_scene.instantiate()
    building.global_position = position
    
    # 5. 注册到BuildingManager
    building_manager.register_building(building)
    
    return true
```

---

## 🎯 地图配置

### MapConfig类

```gdscript
class MapConfig:
    var map_type: MapType = MapType.STANDARD_DUNGEON
    var size: Vector3 = Vector3(100, 1, 100)
    var max_room_count: int = 15
    var min_room_size: int = 6
    var max_room_size: int = 15
    var room_connection_attempts: int = 10
    var resource_density: float = 0.1
    var corridor_width: int = 3
    var complexity: float = 0.5
```

### 地图类型

```gdscript
enum MapType {
    STANDARD_DUNGEON,   # 标准地牢（当前实现）
    COMPLEX_MAZE,       # 复杂迷宫（未来）
    RESOURCE_RICH,      # 资源丰富（未来）
    MILITARY_FOCUSED,   # 军事重点（未来）
    EXPLORATION_HEAVY   # 探索重型（未来）
}
```

---

## 🐛 常见问题

### Q1: 地图生成后看不到地牢之心？
**A**: 检查生成顺序，确保：
```gdscript
await create_initial_dungeon()
# 必须await等待生成完成
```

### Q2: NavigationMesh烘焙失败？
**A**: 确保地图生成完成后再烘焙：
```gdscript
GameEvents.map_generated.connect(_on_map_generated)

func _on_map_generated():
    navigation_manager.bake_navigation_mesh()
```

### Q3: 房间重叠？
**A**: 增强重叠检测：
```gdscript
func _is_overlapping(new_room: Room) -> bool:
    for room in rooms:
        if new_room.overlaps(room):
            return true
    return false
```

### Q4: 金矿太少/太多？
**A**: 调整生成概率：
```gdscript
var discovery_chance = 0.08  # 8% → 调整为0.05或0.10
```

---

## 📚 参考架构

### Roguelike地图生成

**经典算法**:
1. BSP（Binary Space Partitioning）- 递归分割
2. Cellular Automata - 元胞自动机
3. Random Walk - 随机游走
4. Drunkard's Walk - 醉汉漫步

**当前实现**: 简化的房间+通道系统

### 相似游戏

- **《我的世界》**: Chunk系统 + 程序化生成
- **《暗黑地牢》**: 房间+走廊 + Roguelike
- **《地下城守护者》**: 可挖掘地形 + 建造系统

---

## 🎉 总结

MazeMaster3D的地图生成系统成功实现了灵活的程序化地图：

**核心特性**:
- ✅ 100x100大地图
- ✅ 随机房间生成
- ✅ L形通道连接
- ✅ 8%金矿分布
- ✅ 动态挖掘和建造
- ✅ 可达性分析

**技术亮点**:
- 程序化生成，每次不同
- 动态MeshInstance3D渲染
- 洪水填充可达性算法
- 支持实时地形修改

**未来方向**:
- 迁移到GridMap提升性能
- 实现更多地图类型
- 添加Chunk加载系统
- 支持多层地图

*每个地下城都是独一无二的冒险！* 🗺️⚔️
