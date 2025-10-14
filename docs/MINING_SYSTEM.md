# ⛏️ MazeMaster3D - 挖矿系统文档

## 📚 系统概述

MazeMaster3D的挖矿系统通过哥布林苦工实现自动化金币采集，支持智能寻路、状态机AI、自动存储等功能。

**版本**: v4.0  
**更新日期**: 2025-10-14  
**核心文件**: 
- `GoblinWorker.gd` - 苦工AI
- `GoldMineManager.gd` - 金矿管理
- `goblin_worker_states/` - 状态机
- `BuildingFinder.gd` - 建筑查找器（统一API）
- `MovementHelper.gd` - 统一移动系统

---

## 🎮 游戏访问

**召唤方式**: 按 **5键** 打开后勤召唤界面

**功能**:
- ⛏️ 自动寻找并挖掘金矿
- 💰 自动运送金币到地牢之心
- 🏃 遇敌自动逃跑
- 📊 状态指示器显示工作状态
- 🎯 智能状态切换避免卡住

---

## 👷 哥布林苦工（GoblinWorker）

### 基础属性

| 属性         | 数值     | 说明             |
| ------------ | -------- | ---------------- |
| **成本**     | 80金币   | 召唤费用         |
| **生命值**   | 600      | 较低，需要保护   |
| **攻击力**   | 8        | 很弱，非战斗单位 |
| **移动速度** | 80       | 中等速度         |
| **携带容量** | 60金币   | 单次携带上限     |
| **挖矿速率** | 1.0秒/次 | 挖矿冷却时间     |
| **挖矿力量** | 4金币/次 | 每次挖掘产量     |
| **挖掘效率** | 4金币/秒 | 实际挖掘速度     |
| **体型**     | 18像素   | 碰撞半径0.09米   |
| **逃跑距离** | 60像素   | 敌人检测范围     |

### 视觉标识

- **颜色**: 棕色 `Color(0.6, 0.4, 0.2)`
- **状态指示器**: 横向空心长方形（8x4像素）
- **战斗类型**: 非战斗单位
- **模型**: goblin_worker.glb (Sketchfab)
- **动画映射**: 
  - idle → G_Idle1
  - move → G_Walk
  - work → G_Attack (挖矿动画)
  - run → G_Walk (1.5倍速)

---

## 🔄 状态机系统

### 状态类型（WorkerStatus）

```gdscript
enum WorkerStatus {
    IDLE,              # 空闲
    WANDERING,         # 游荡（寻找目标）
    MOVING_TO_MINE,    # 移动到金矿
    MINING,            # 挖掘中
    RETURNING_TO_BASE, # 返回基地存储
    DEPOSITING_GOLD,   # 存储金币
    FLEEING,           # 逃跑
}
```

### 📊 状态转换流程图

```
开始 → IDLE (空闲)
  ↓
检查敌人 → 有敌人 → ESCAPE (逃跑)
  ↓
检查携带金币 → 满载(60) → RETURNING_TO_BASE (返回基地)
  ↓                            ↓
无金币 → 寻找金矿              到达基地 → DEPOSITING_GOLD (存储)
  ↓                            ↓
找到金矿 → MOVING_TO_MINE      存储完成 → IDLE
  ↓
到达金矿 → MINING (挖掘)
  ↓
挖掘中 → 检查状态
  ├─ 背包满 → RETURNING_TO_BASE
  ├─ 金矿枯竭 → IDLE
  └─ 继续挖掘
```

### 🎯 工作优先级决策树

```
苦工状态检查
├── 检测敌人？
│   ├── 是 (60像素内) → ESCAPE (逃跑)
│   └── 否 → 继续检查
├── 携带金币 >= 60？
│   ├── 是 → RETURNING_TO_BASE (返回基地)
│   └── 否 → 继续检查
├── 有当前金矿？
│   ├── 是 → 检查金矿状态
│   │   ├── 在交互范围内 → MINING (挖掘)
│   │   ├── 未到达 → MOVING_TO_MINE
│   │   └── 金矿枯竭 → 清除目标，IDLE
│   └── 否 → 寻找金矿
│       ├── 找到可用金矿 → 设置目标 → MOVING_TO_MINE
│       └── 无可用金矿 → WANDERING (游荡)
└── 空闲超时(2秒) → WANDERING
```

### 🔄 详细状态流程

#### 状态优先级（从高到低）

1. **安全优先**: `ESCAPE` - 检测到敌人立即逃跑
2. **资源管理**: `RETURNING_TO_BASE` / `DEPOSITING_GOLD` - 满载金币优先存储
3. **主要工作**: `MOVING_TO_MINE` / `MINING` - 挖掘金矿
4. **搜索目标**: `IDLE` / `WANDERING` - 寻找新金矿

#### 金矿选择优先级

```
金矿筛选条件（按顺序）:
1. 金矿未枯竭 (gold_amount > 0)
2. 金矿未满员 (miners.size() < 3)
3. 金矿可达 (is_reachable)
4. 距离最近 (distance < closest_distance)
5. 未在失败列表 (not in failed_mines)
```

#### 存储位置选择

```
存储优先级:
1. 检查200像素内是否有金库
   ├─ 有金库 → 前往最近的金库
   └─ 无金库 → 前往地牢之心
2. 到达交互范围后存储
3. 存储完成清空携带金币
4. 返回 IDLE 继续工作
```

---

## 🔨 状态详解

### 1. IdleState（空闲）

**触发条件**:
- 初始生成
- 完成其他状态后

**行为**:
- 等待2秒超时
- 超时后自动进入游荡状态

**状态指示**: ⚪ 白色边框

---

### 2. WanderState（游荡）

**触发条件**:
- 空闲超时
- 找不到可用金矿

**行为**:
```gdscript
func enter(worker):
    # 在50像素半径内随机移动
    var random_offset = Vector3(
        randf_range(-50, 50),
        0,
        randf_range(-50, 50)
    )
    target_position = worker.global_position + random_offset
    
    # 限制在地图范围内
    target_position = clamp_to_map(target_position)
```

**持续时间**: 持续寻找金矿，无固定时间

**状态指示**: 🟠 橙色边框

---

### 3. MoveToMineState（移动到金矿）

**触发条件**:
- 找到可用金矿
- 金矿未枯竭
- 金矿未满员（<3个苦工）

**行为**:
```gdscript
func enter(data: Dictionary = {}):
    target_mine = data["target_mine"]
    
    # 🔧 [v4.0] 使用统一移动API
    mine_building = _create_mine_building_wrapper(target_mine)
    MovementHelper.reset_navigation(worker)

func physics_update(delta: float):
    # 🔧 [v4.0] 使用统一移动API - 一行代码完成所有移动逻辑
    var result = MovementHelper.process_interaction_movement(
        worker, mine_building, delta, "MoveToMine"
    )
    match result:
        MovementHelper.InteractionMoveResult.REACHED_INTERACTION:
            state_finished.emit("MiningState", {"target_mine": target_mine})
        MovementHelper.InteractionMoveResult.FAILED_NO_PATH, MovementHelper.InteractionMoveResult.FAILED_STUCK:
            # 标记失败金矿，避免重复尝试
            worker.failed_mines[target_mine.position] = Time.get_ticks_msec()
            state_finished.emit("IdleState")
```

**失败处理**:
- 金矿被其他苦工占满 → 记录失败，寻找其他金矿
- 路径不可达 → 10秒后重试
- 金矿包装器位置设置失败 → 自动重新创建包装器

**状态指示**: 🟢 绿色边框

---

### 4. MiningState（挖掘中）

**触发条件**:
- 到达金矿附近（<1.5米）
- 金矿未枯竭
- 携带量未满

**挖掘机制**:
```gdscript
var mining_rate = 1.0  # 每1.0秒挖一次
var mining_power = 4   # 每次挖4金币

func enter(data):
    # 设置挖矿计时器
    mining_timer = Timer.new()
    mining_timer.wait_time = 1.0
    mining_timer.timeout.connect(_on_mining_tick)
    add_child(mining_timer)
    mining_timer.start()

func _on_mining_tick():
    # 从金矿挖掘
    var mined = target_mine.mine_gold(mining_power)
    carried_gold = min(carried_gold + mined, carry_capacity)
    
    # 检查金矿状态
    if target_mine.is_exhausted():
        change_to("IdleState")
    
    # 检查携带量
    if carried_gold >= carry_capacity:
        change_to("ReturnToBaseState")
```

**效率**:
- 每1.0秒挖4金币
- 理论速率: **4金币/秒**
- 携带量满后自动存储（**60金币**）
- 装满时间: 60 ÷ 4 = **15秒**

**状态指示**: 🟤 深棕色边框

---

### 5. ReturnToBaseState（返回基地）

**触发条件**:
- 携带金币 >= 20
- 主动调用存储

**行为**:
```gdscript
func enter(worker):
    # 获取地牢之心位置
    var dungeon_heart = _get_dungeon_heart()
    if not dungeon_heart:
        return
    
    # 计算可达位置（地牢之心旁边的空地）
    var target_pos = _get_accessible_position_near_base(dungeon_heart)
    navigation_agent.target_position = target_pos

func physics_update(delta):
    # 移动到地牢之心
    # ... 移动逻辑 ...
    
    # 到达检测（边缘距离）
    var center_distance = worker.global_position.distance_to(base.global_position)
    var collision_sum = worker.collision_radius + base.collision_radius
    var edge_distance = center_distance - collision_sum
    
    if edge_distance <= 2.0:  # 2米交互范围
        deposit_gold()
```

**存储逻辑**:
```gdscript
func deposit_gold():
    var amount = worker.carried_gold
    
    # 添加到ResourceManager
    resource_manager.add_gold(amount)
    
    # 清空携带
    worker.carried_gold = 0
    worker.has_deposited = true
    
    # 返回挖矿
    change_to("IdleState")
```

**状态指示**: 🔵 青色边框

---

### 6. EscapeState（逃跑）

**触发条件**:
- 检测到60像素内有敌人
- 敌人是英雄阵营

**行为**:
```gdscript
func enter(worker):
    # 计算逃跑方向（远离敌人）
    var escape_direction = (worker.global_position - threat.global_position).normalized()
    escape_direction.y = 0
    
    # 逃跑目标：当前位置 + 50像素
    target_position = worker.global_position + escape_direction * 50.0

func physics_update(delta):
    # 快速移动
    var direction = worker.global_position.direction_to(target_position)
    direction.y = 0
    
    worker.velocity = direction * worker.speed * 1.2  # 逃跑速度+20%
    worker.move_and_slide()
    
    # 脱离危险后返回工作
    if not _is_threat_nearby():
        change_to("IdleState")
```

**状态指示**: ⚫ 深灰色边框

---

## ⛏️ 金矿系统（GoldMineManager）

### GoldMine数据结构

```gdscript
class GoldMine:
    var mine_id: int              # 唯一ID
    var position: Vector3         # 世界坐标
    var gold_amount: int          # 剩余黄金（初始500）
    var status: MineStatus        # 状态
    var mining_status: MiningStatus  # 挖掘状态
    var miners: Array             # 当前挖掘者列表
    var max_miners: int = 3       # 最大3个苦工同时挖
```

### 金矿状态

```gdscript
enum MineStatus {
    UNDISCOVERED,  # 未发现（需要挖掘岩石）
    ACTIVE,        # 活跃（可挖掘）
    EXHAUSTED      # 枯竭（金币=0）
}

enum MiningStatus {
    AVAILABLE,     # 可用（0个苦工）
    BUSY,          # 忙碌（1个苦工）
    FULL           # 满员（2-3个苦工）
}
```

### 金矿生成

**生成时机**: 地图生成时

**生成概率**: 8%（1600个岩石 → 约128个金矿）

**生成逻辑**:
```gdscript
func generate_gold_mines():
    var map_size = tile_manager.get_map_size()
    
    for x in range(map_size.x):
        for z in range(map_size.z):
            var pos = Vector3(x, 0, z)
            var tile_data = tile_manager.get_tile_data(pos)
            
            if tile_data and tile_data.type == TileType.UNEXCAVATED:
                if randf() < 0.08:  # 8%概率
                    create_gold_mine(pos)
```

### 金矿管理

**添加挖掘者**:
```gdscript
func add_miner(mine: GoldMine, worker: GoblinWorker) -> bool:
    if mine.miners.size() >= mine.max_miners:
        return false
    
    if worker not in mine.miners:
        mine.miners.append(worker)
        _update_mining_status(mine)
    
    return true
```

**挖掘黄金**:
```gdscript
func mine_gold(mine: GoldMine, amount: int) -> int:
    var mined = min(amount, mine.gold_amount)
    mine.gold_amount -= mined
    
    if mine.gold_amount <= 0:
        mine.status = MineStatus.EXHAUSTED
        # 通知所有苦工
        for miner in mine.miners:
            miner.on_mine_exhausted()
        mine.miners.clear()
    
    return mined
```

**查找可用金矿**:
```gdscript
func find_available_mine(worker_position: Vector3, max_distance: float = 100.0) -> GoldMine:
    var closest_mine = null
    var closest_distance = max_distance
    
    for mine in gold_mines:
        # 跳过枯竭和满员的金矿
        if mine.is_exhausted() or mine.miners.size() >= mine.max_miners:
            continue
        
        # 🔧 [v4.0] 使用洪水填充算法预计算的可达性
        if not mine.is_reachable:
            continue
        
        var distance = worker_position.distance_to(mine.position)
        if distance < closest_distance:
            closest_mine = mine
            closest_distance = distance
    
    return closest_mine
```

**金矿包装器系统**:
```gdscript
# 创建金矿的建筑包装器，用于统一API
func _create_mine_building_wrapper(mine: RefCounted) -> Node3D:
    var wrapper = Node3D.new()
    wrapper.name = "MineWrapper"
    
    # 设置金矿位置（确保正确设置）
    var mine_pos = Vector3(
        floor(mine.position.x) + 0.5,
        0.05,
        floor(mine.position.z) + 0.5
    )
    wrapper.position = mine_pos
    
    # 添加到场景树以确保位置设置生效
    var scene_tree = Engine.get_main_loop() as SceneTree
    if scene_tree and scene_tree.current_scene:
        scene_tree.current_scene.add_child(wrapper)
    
    # 添加建筑大小方法（金矿是1x1）
    wrapper.set_meta("building_size", Vector2(1, 1))
    wrapper.set_script(load("res://scripts/core/BuildingWrapper.gd"))
    
    return wrapper
```

---

## 📊 性能优化

### 可达性缓存

**问题**: 每次查找金矿都检查可达性 → 慢

**解决方案**: 预计算+缓存
```gdscript
var reachable_mines_cache: Dictionary = {}  # {mine_id: bool}
var cache_dirty: bool = true

func update_reachability_cache():
    for mine in gold_mines:
        reachable_mines_cache[mine.mine_id] = tile_manager.is_reachable(mine.position)
    cache_dirty = false
```

**更新时机**:
- 地图挖掘后
- 金矿生成后
- 手动标记dirty

### 空间查询优化

**使用TileManager的空间索引**:
```gdscript
# 快速查找附近金矿
func get_mines_in_radius(position: Vector3, radius: float) -> Array:
    var nearby_mines = []
    
    # 只检查半径内的瓦块
    var grid_radius = int(radius) + 1
    var grid_pos = Vector2i(position.x, position.z)
    
    for x in range(-grid_radius, grid_radius + 1):
        for z in range(-grid_radius, grid_radius + 1):
            var check_pos = grid_pos + Vector2i(x, z)
            var mine = get_mine_at_position(check_pos)
            if mine:
                nearby_mines.append(mine)
    
    return nearby_mines
```

---

## 🎯 智能行为

### 失败金矿记录

**问题**: 苦工反复尝试不可达的金矿

**解决方案**: 失败记录
```gdscript
var failed_mines: Dictionary = {}  # {mine_id: timestamp}
var failed_mine_timeout: float = 10.0  # 10秒后重试

func mark_mine_failed(mine: GoldMine):
    failed_mines[mine.mine_id] = Time.get_ticks_msec() / 1000.0

func is_mine_failed(mine: GoldMine) -> bool:
    if mine.mine_id not in failed_mines:
        return false
    
    var current_time = Time.get_ticks_msec() / 1000.0
    var failed_time = failed_mines[mine.mine_id]
    
    if current_time - failed_time > failed_mine_timeout:
        failed_mines.erase(mine.mine_id)
        return false
    
    return true
```

### 状态切换冷却

**问题**: 苦工频繁切换状态

**解决方案**: 切换冷却
```gdscript
var state_change_cooldown: float = 0.5  # 0.5秒冷却
var last_state_change_time: float = 0.0

func can_change_state() -> bool:
    var current_time = Time.get_ticks_msec() / 1000.0
    return current_time - last_state_change_time >= state_change_cooldown
```

### 空闲超时机制

**问题**: 苦工长时间空闲不工作

**解决方案**: 2秒超时自动游荡
```gdscript
var idle_timeout: float = 2.0
var idle_timer: float = 0.0

func update_idle_state(delta):
    idle_timer += delta
    if idle_timer >= idle_timeout:
        change_state("WanderState")
```

---

## 🎨 视觉反馈

### 状态指示器颜色

| 状态              | 颜色     | 说明       |
| ----------------- | -------- | ---------- |
| IDLE              | ⚪ 白色   | 空闲等待   |
| WANDERING         | 🟠 橙色   | 游荡寻找   |
| MOVING_TO_MINE    | 🟢 绿色   | 移动到金矿 |
| MINING            | 🟤 深棕色 | 挖掘中     |
| RETURNING_TO_BASE | 🔵 青色   | 返回存储   |
| FLEEING           | ⚫ 深灰色 | 逃跑中     |
| TRAINING          | 🟤 深棕色 | 训练中     |

### 金矿状态指示

**基于挖掘者数量**:
- 🟢 绿色边框: 1个苦工
- 🟡 黄色边框: 2个苦工
- 🔴 红色边框: 3个苦工（满员）
- 🟫 棕色: 枯竭

---

## 📈 经济平衡

### 投资回报分析

```
成本: 80金币
收益: 500金币/矿（理论最大值）
挖掘时间: 500 ÷ 4 = 125秒（理论）
实际时间: ~150-180秒（含移动、存储）
投资回报率: 625%（500÷80）
回本时间: ~20秒（挖80金币）
```

### 效率计算

```
挖矿效率: 4金币/1.0秒 = 4金币/秒（挖掘时）
携带效率: 60金币/次
装满时间: 60 ÷ 4 = 15秒
存储频率: 每15秒一次
移动损耗: ~5-10秒/次往返
实际效率: ~3金币/秒（含移动）
单次收益: 60金币（之前20金币，提升3倍）
```

### 最优配置

**推荐苦工数量**:
```
金矿数量 ÷ 2 = 建议苦工数
例如: 100个金矿 → 50个苦工

原因: 
- 每个金矿最多3个苦工
- 2个苦工配合效率最高
- 避免过度拥挤
```

---

## 🔧 配置参数

### 可调参数

```gdscript
var worker_config = {
    "mining_rate": 1.0,           # 挖矿冷却（秒）
    "carry_capacity": 60,         # 携带容量（金币）
    "flee_distance": 60,          # 逃跑检测距离（像素）
    "wander_radius": 50,          # 游荡半径（像素）
    "idle_timeout": 2.0,          # 空闲超时（秒）
    "state_change_cooldown": 0.5  # 状态切换冷却（秒）
}

var mining_power: int = 4  # 每次挖掘产量（4金币/秒）
var mining_interval: float = 1.0  # 挖矿间隔
```

### 平衡建议

**加快挖矿**: 
- 减少 `mining_rate` (如0.5秒)
- 增加 `mining_power` (如6金币)
- 效果: 6金币/0.5秒 = 12金币/秒

**增强生存**:
- 增加 `flee_distance` (如80像素)
- 提高 `health` (如800)
- 提高 `speed` (如100)

**提高效率**:
- 增加 `carry_capacity` (如100金币)
- 减少往返时间
- 效果: 更少存储次数

---

## 🐛 常见问题

### Q1: 苦工不去挖矿？
**A**: 检查：
1. 金矿是否可达（洪水填充算法预计算）
2. 金矿是否满员（max 3个苦工）
3. 金矿包装器位置是否正确设置
4. 是否在失败黑名单中（10秒超时）

### Q2: 苦工卡住不动？
**A**: 原因：
1. 金矿包装器位置设置失败（(0,0,0)）
2. 目标位置被阻挡
3. 状态机卡死

**解决**: 
1. 检查金矿包装器是否正确添加到场景树
2. 使用2秒空闲超时机制自动恢复
3. 检查BuildingFinder.get_walkable_position_near_building()返回值

### Q3: 金币不显示？
**A**: 检查ResourceManager注册：
```gdscript
resource_manager.add_gold(amount)
```

---

## 🎉 总结

MazeMaster3D的挖矿系统提供了完整的自动化资源采集机制：

**核心特性**:
- ✅ 智能状态机AI
- ✅ 自动寻路和挖掘
- ✅ 安全机制（逃跑）
- ✅ 防卡机制（超时游荡）
- ✅ 性能优化（缓存）
- ✅ 视觉反馈（状态指示器）

**游戏体验**:
- 召唤简单，操作零负担
- AI自主工作，玩家专注战斗
- 经济回报高，值得投资
- 视觉清晰，状态一目了然

*勤劳的哥布林苦工是地下城经济的支柱！* ⛏️💰
