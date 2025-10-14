# 🧌 3D 模型集成系统

本目录包含游戏中所有 3D 角色模型的包装器场景和脚本。

---

## 📁 目录结构

```
scenes/models/
├── README.md                      # 本文档
├── goblin_worker_base.tscn        # GoblinWorker 继承场景
├── goblin_worker_model.gd         # GoblinWorker 包装器脚本
├── goblin_engineer_model.gd       # GoblinEngineer 包装器脚本（待添加）
└── (未来添加更多角色模型)
```

---

## 🎯 系统设计目的

### 问题背景

从外部下载的 3D 模型（如 .glb, .fbx）存在以下问题：

1. **动画名称不统一**：
   - Sketchfab 模型：`G_Idle1`, `G_Walk`, `G_Attack`
   - Mixamo 模型：`Idle`, `Walking`, `Attack`
   - 自制模型：可能是任意名称

2. **附带不需要的节点**：
   - 环境地面、装饰物等
   - 需要在运行时删除

3. **导入资源不可修改**：
   - .glb 文件是只读的导入资源
   - 无法直接重命名动画或删除节点

### 解决方案：包装器模式

使用 **继承场景 + 包装器脚本** 模式：

```
原始模型（.glb）→ 继承场景（.tscn）→ 包装器脚本（.gd）→ 游戏角色场景
    只读           可编辑           动画映射        使用包装器
```

**优势**：
- ✅ 保持原始 .glb 优化（性能）
- ✅ 统一动画接口（易于使用）
- ✅ 自动清理不需要的节点
- ✅ 支持多种模型来源

---

## 📥 完整工作流程

### 阶段 1：下载模型

#### 推荐资源站点：

| 站点           | 链接                       | 特点                |
| -------------- | -------------------------- | ------------------- |
| **Sketchfab**  | https://sketchfab.com      | ⭐ 最推荐，模型+动画 |
| **Mixamo**     | https://www.mixamo.com     | 海量动画，自动绑定  |
| **TurboSquid** | https://www.turbosquid.com | 多种选择            |
| **CGTrader**   | https://www.cgtrader.com   | 游戏优化资产        |

#### 下载设置：

- **格式**：优先选择 **glTF 2.0 (.glb)** 或 FBX
- **骨骼**：With Skin（包含模型）
- **动画**：确保包含动画数据
- **许可**：注意 CC BY 需要署名，CC0 完全自由

#### 当前已下载：

- ✅ **Goblin Worker** - 来自 Sketchfab (C. Anastasiadis)
  - 文件：`assets/models/goblin_worker.glb` (11.6 MB)
  - 许可：CC BY 4.0
  - 动画：G_Idle1, G_Walk, G_Attack, G_Dance, G_Idle2

---

### 阶段 2：安装到项目

#### 步骤：

1. **创建目录**（如果不存在）：
   ```
   godot_project/assets/models/
   ```

2. **复制模型文件**：
   ```bash
   # Windows PowerShell
   Copy-Item "下载路径/模型.glb" -Destination "godot_project/assets/models/"
   ```

3. **在 Godot 中导入**：
   - 打开 Godot 编辑器
   - 等待自动导入（10-30 秒）
   - 在 FileSystem 中查看导入结果

4. **检查导入设置**：
   - 点击 .glb 文件
   - 在 Import 面板中确认：
     - ✅ Scene Import
     - ✅ Animation
     - ✅ Materials: On Import

---

### 阶段 3：创建继承场景

#### 目的：

将只读的 .glb 模型包装为可配置的场景。

#### 步骤：

1. **创建继承场景**：
   - 在 FileSystem 中右键 `assets/models/xxx.glb`
   - 选择 **"New Inherited Scene"**
   - Godot 会打开继承场景编辑器

2. **附加包装器脚本**：
   - 选择场景根节点
   - 点击 "Attach Script" 图标
   - 脚本路径：`res://scenes/models/xxx_model.gd`
   - 使用包装器脚本模板（见下文）

3. **保存继承场景**：
   - Scene → Save Scene As...
   - 路径：`res://scenes/models/xxx_base.tscn`

#### 示例结构：

```
goblin_worker_base.tscn (继承场景)
└── Sketchfab_Scene (继承自 goblin_worker.glb)
    └── Sketchfab_model/root/GLTF_SceneRootNode/
        ├── G_Armature_68 (Goblin 模型) ← 附加脚本
        └── Landscape_69 (环境地面) ← 将被删除
```

---

### 阶段 4：编写包装器脚本

#### 包装器脚本模板：

```gdscript
extends Node3D
class_name XxxModel  # 替换为具体的类名

## 动画映射表（根据实际模型调整）
const ANIMATION_MAP = {
	"idle": "实际动画名",      # 例如: "G_Idle1" 或 "Idle"
	"move": "实际动画名",      # 例如: "G_Walk" 或 "Walking"
	"work": "实际动画名",      # 例如: "G_Attack" 或 "Hammering"
	"attack": "实际动画名",    # 例如: "G_Attack" 或 "Attack"
	"death": "实际动画名",     # 例如: "Death" 或 "Dying"
	"run": "实际动画名"        # 例如: "G_Walk" 或 "Running"
}

@onready var animation_player: AnimationPlayer = _find_animation_player(self)
@onready var skeleton: Skeleton3D = _find_skeleton(self)

func _ready():
	# 删除不需要的环境节点
	_remove_unwanted_nodes()
	
	if not animation_player:
		push_warning("未找到 AnimationPlayer")
	else:
		play_animation("idle")
		print("模型已加载，动画: ", animation_player.get_animation_list())

## 删除不需要的节点（如环境、装饰物）
func _remove_unwanted_nodes():
	# 删除名称包含特定关键词的节点
	var patterns = ["Landscape", "Environment", "Floor", "Ground"]
	
	for pattern in patterns:
		var node = _find_node_by_name_pattern(self, pattern)
		if node:
			node.queue_free()
			print("已删除节点: ", node.name)

## 播放动画（自动映射）
func play_animation(logical_name: String, speed: float = 1.0) -> bool:
	if not animation_player:
		return false
	
	var actual_name = ANIMATION_MAP.get(logical_name, logical_name)
	
	if animation_player.has_animation(actual_name):
		animation_player.play(actual_name)
		animation_player.speed_scale = speed
		return true
	
	return false

## 辅助函数：查找 AnimationPlayer
func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = _find_animation_player(child)
		if result:
			return result
	return null

## 辅助函数：查找 Skeleton3D
func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var result = _find_skeleton(child)
		if result:
			return result
	return null

## 辅助函数：按名称模式查找节点
func _find_node_by_name_pattern(node: Node, pattern: String) -> Node:
	if pattern.to_lower() in node.name.to_lower():
		return node
	for child in node.get_children():
		var result = _find_node_by_name_pattern(child, pattern)
		if result:
			return result
	return null
```

---

### 阶段 5：集成到角色场景

#### 在角色场景中使用包装器：

**示例**：`scenes/characters/GoblinWorker.tscn`

```gdscript
[gd_scene ...]

[ext_resource type="PackedScene" path="res://scenes/models/goblin_worker_base.tscn" id="2_goblin"]

[node name="GoblinWorker" type="CharacterBody3D"]
├── CollisionShape
├── Model [instance=ExtResource("2_goblin")]  ← 实例化包装器场景
├── NavigationAgent3D
└── StateMachine
```

#### 在代码中播放动画：

```gdscript
# 在状态文件中（如 IdleState.gd）
func enter(_data: Dictionary = {}) -> void:
	var worker = state_machine.owner
	
	# 通过 Model 节点播放动画（自动映射）
	if worker.has_node("Model") and worker.get_node("Model").has_method("play_animation"):
		worker.get_node("Model").play_animation("idle")  # 自动映射为 "G_Idle1"
	elif worker.animation_player:
		worker.animation_player.play("idle")  # 兼容旧系统
```

---

## 🔄 添加新模型的完整流程

### 示例：添加 Orc Warrior 模型

#### 1. 下载模型
```
下载 orc_warrior.glb 到 assets/models/
```

#### 2. 创建继承场景
```
右键 orc_warrior.glb → New Inherited Scene
→ 保存为 scenes/models/orc_warrior_base.tscn
```

#### 3. 创建包装器脚本
```gdscript
# scenes/models/orc_warrior_model.gd
extends Node3D
class_name OrcWarriorModel

const ANIMATION_MAP = {
	"idle": "Idle",         # 根据实际动画名称调整
	"move": "Walk",
	"attack": "Swing",
	"death": "Death"
}

# ... (复制包装器模板代码)
```

#### 4. 附加脚本到继承场景
```
在继承场景中：
选择根节点 → Attach Script → orc_warrior_model.gd
```

#### 5. 在角色场景中使用
```
在 OrcWarrior.tscn 中：
添加 Model 节点 [instance=orc_warrior_base.tscn]
```

#### 6. 更新状态文件
```gdscript
if warrior.has_node("Model"):
	warrior.get_node("Model").play_animation("attack")
```

---

## 📊 当前已集成的模型

### GoblinWorker

- **源文件**: `assets/models/goblin_worker.glb` (11.6 MB)
- **继承场景**: `scenes/models/goblin_worker_base.tscn`
- **包装器**: `scenes/models/goblin_worker_model.gd`
- **来源**: Sketchfab - C. Anastasiadis
- **许可**: CC BY 4.0
- **链接**: https://sketchfab.com/3d-models/goblin-be36443ae66e487aaca4f84c014bff5a

**动画映射**：
```
idle   → G_Idle1   (待机)
move   → G_Walk    (行走)
work   → G_Attack  (工作/挖矿/建造) ⭐
attack → G_Attack  (战斗攻击，复用)
run    → G_Walk    (奔跑，1.5倍速)
dance  → G_Dance   (舞蹈，备用)
```

**特殊处理**：
- ✅ 自动删除 `Landscape_69` 环境地面节点
- ✅ 工作动画使用 `G_Attack`（挥舞动作）

---

## 🛠️ 包装器系统 API

### 核心方法

#### `play_animation(logical_name: String, speed: float = 1.0) -> bool`

播放动画（自动映射名称）

**参数**：
- `logical_name`: 游戏逻辑中使用的统一动画名称（如 "idle", "move", "work"）
- `speed`: 播放速度倍率（1.0 = 正常，1.5 = 快速，0.8 = 慢速）

**返回**：是否成功播放

**示例**：
```gdscript
# 在状态文件中
var model = worker.get_node("Model")
model.play_animation("work")         # 正常速度挖矿
model.play_animation("run", 1.5)     # 1.5倍速奔跑
model.play_animation("move", 0.8)    # 0.8倍速游荡
```

#### `has_animation(logical_name: String) -> bool`

检查动画是否存在（使用逻辑名称）

#### `get_animation_player() -> AnimationPlayer`

获取内部的 AnimationPlayer 节点引用

---

## 🎬 标准动画名称约定

为保持代码一致性，游戏逻辑中**始终使用**以下标准名称：

| 逻辑名称 | 用途 | 适用场景         |
| -------- | ---- | ---------------- |
| `idle`   | 待机 | 站立不动时       |
| `move`   | 行走 | 普通移动         |
| `run`    | 奔跑 | 快速移动、逃跑   |
| `work`   | 工作 | 挖矿、建造、采集 |
| `attack` | 攻击 | 战斗攻击         |
| `hit`    | 受击 | 被攻击时反应     |
| `death`  | 死亡 | 死亡动画         |
| `dance`  | 庆祝 | 胜利、特殊事件   |

包装器脚本负责将这些标准名称映射到实际模型的动画名称。

---

## 📝 从不同来源导入模型的注意事项

### Sketchfab 模型

**特点**：
- 动画名称通常有前缀（如 `G_`, `Orc_`）
- 可能包含环境装饰节点
- 通常使用 glTF 格式

**处理**：
```gdscript
const ANIMATION_MAP = {
	"idle": "G_Idle1",      # 注意前缀
	"move": "G_Walk",
	"work": "G_Attack"
}

func _remove_unwanted_nodes():
	_remove_node_by_pattern("Landscape")  # 删除环境
```

---

### Mixamo 模型

**特点**：
- 动画名称首字母大写（如 `Idle`, `Walking`）
- 通常不包含环境节点
- 支持 FBX 和 glTF

**处理**：
```gdscript
const ANIMATION_MAP = {
	"idle": "Idle",         # 首字母大写
	"move": "Walking",
	"attack": "Punch"
}
```

---

### 自制模型（Blender 等）

**特点**：
- 动画名称自定义
- 可能需要调整坐标系（Y-up vs Z-up）

**处理**：
```gdscript
const ANIMATION_MAP = {
	"idle": "Armature|idle",  # 可能包含 Armature 前缀
	"move": "Armature|walk"
}
```

---

## 🔧 常见问题与解决方案

### 问题 1：动画不播放

**原因**：动画名称映射错误

**解决**：
1. 双击 .glb 文件查看实际动画名称
2. 更新包装器脚本中的 `ANIMATION_MAP`
3. 重启 Godot

---

### 问题 2：模型显示为粉红色

**原因**：材质或纹理丢失

**解决**：
1. 选择 .glb 文件
2. 在 Import 面板中：
   - Materials: Extract
   - Textures: Extract
3. 点击 Reimport

---

### 问题 3：模型太大或太小

**原因**：不同软件的缩放单位不同

**解决方案 A**（在继承场景中）：
```
打开 xxx_base.tscn
→ 选择根节点
→ Transform.Scale = 0.5 或 2.0
```

**解决方案 B**（在角色场景中）：
```
打开 XxxCharacter.tscn
→ 选择 Model 节点
→ Transform.Scale = 0.5 或 2.0
```

---

### 问题 4：模型方向错误（躺倒或朝向不对）

**原因**：坐标系差异（Blender 的 Z-up vs Godot 的 Y-up）

**解决**：
```
在继承场景中：
Transform.Rotation.X = -90° 或 90°
Transform.Rotation.Y = 180°
```

---

### 问题 5：模型包含不需要的节点

**原因**：模型导出时包含了环境、相机等

**解决**：在包装器脚本中自动删除

```gdscript
func _remove_unwanted_nodes():
	var patterns = [
		"Landscape",     # 环境地面
		"Environment",   # 环境设置
		"Camera",        # 相机
		"Light",         # 灯光
		"Floor",         # 地板
		"Props"          # 装饰物
	]
	
	for pattern in patterns:
		var node = _find_node_by_name_pattern(self, pattern)
		if node:
			node.queue_free()
			print("已删除: ", node.name)
```

---

## 📚 参考文档

### 项目文档
- `docs/ANIMATION_GUIDE.md` - 动画系统使用指南
- `docs/GOBLIN_MODEL_RESOURCES.md` - 模型资源获取
- `文档/模型下载.md` - 外部资源推荐
- `文档/模型导入.md` - Godot 导入详细步骤

### 外部资源
- Godot 动画文档：https://docs.godotengine.org/en/stable/tutorials/animation/
- glTF 规范：https://www.khronos.org/gltf/
- Sketchfab：https://sketchfab.com
- Mixamo：https://www.mixamo.com

---

## 🎯 最佳实践

### 1. 统一命名规范
- 场景文件：`xxx_base.tscn`
- 脚本文件：`xxx_model.gd`
- 类名：`XxxModel`

### 2. 动画映射优先级
```gdscript
1. 查找 ANIMATION_MAP 中的映射
2. 如果映射的动画存在，播放
3. 否则尝试直接使用逻辑名称
4. 都不存在则输出警告
```

### 3. 性能优化
- 使用 .glb 而不是 .gltf（单文件，加载更快）
- 保持原始 .glb 不变（享受导入优化）
- 仅在包装器中添加必要逻辑

### 4. 团队协作
- 所有模型使用统一的包装器模式
- 文档化每个模型的来源和许可
- 在 CREDITS.md 中署名作者

---

## 🚀 快速参考

### 添加新模型（5 步）：

```bash
# 1. 下载模型
下载 xxx.glb → assets/models/

# 2. 创建继承场景
右键 xxx.glb → New Inherited Scene → 保存为 xxx_base.tscn

# 3. 创建包装器脚本
复制模板 → 修改 ANIMATION_MAP → 保存为 xxx_model.gd

# 4. 附加脚本
在继承场景中 Attach Script → 选择 xxx_model.gd

# 5. 使用场景
在角色场景中 instance xxx_base.tscn 作为 Model 节点
```

### 测试新模型：

```gdscript
# 在任意状态文件中
var model = character.get_node("Model")
if model and model.has_method("play_animation"):
	model.play_animation("idle")    # 自动映射！
	model.play_animation("work")    # 自动映射！
	model.play_animation("attack")  # 自动映射！
```

---

## ✅ 署名（CC BY 许可要求）

使用 CC BY 许可的模型时，需要在游戏中署名：

### 当前使用的模型：

**Goblin Model**
- 作者：C. Anastasiadis
- 来源：Sketchfab
- 许可：CC BY 4.0
- 链接：https://sketchfab.com/3d-models/goblin-be36443ae66e487aaca4f84c014bff5a

---

**最后更新**: 2025-10-10  
**系统版本**: v1.0  
**Godot 版本**: 4.3+

