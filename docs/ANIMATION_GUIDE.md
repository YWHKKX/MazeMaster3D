# 🎬 动画系统使用指南

## ✅ 当前状态

已为 `GoblinWorker` 和 `GoblinEngineer` 添加了基础占位动画，游戏现在可以正常运行。

### 已创建的动画
- ✅ **idle** - 待机动画（上下浮动）
- ✅ **move** - 移动动画（左右摇摆）
- ✅ **work** - 工作动画（前后摆动）
- ✅ **attack** - 攻击动画（挤压拉伸）
- ✅ **death** - 死亡动画（缩小消失）

这些是简单的程序动画，用于让单位"活"起来，直到您获得真实的3D模型和骨骼动画。

---

## 🚀 升级到专业动画（推荐方案）

基于 `文档/模型下载.md` 和 `文档/模型导入.md` 的建议：

### 步骤 1: 从 Mixamo 获取动画

1. **访问 Mixamo**
   - 网址：https://www.mixamo.com
   - 使用 Adobe 账号登录（免费）

2. **选择模型**
   - 方案A：使用 Mixamo 的 Goblin 模型
   - 方案B：上传自己的模型（需要无骨骼的 FBX/OBJ）

3. **下载关键动画**（推荐列表）
   ```
   必需动画：
   - Idle (待机)
   - Walking (行走)
   - Running (奔跑)
   
   工作动画：
   - Mining (挖掘)
   - Hammering (锤击)
   - Carrying (搬运)
   
   战斗动画：
   - Punching (攻击)
   - Getting Hit (受击)
   - Death (死亡)
   - Running Away (逃跑)
   ```

4. **下载设置**
   - **格式**: glTF (.glb) 或 FBX
   - **骨骼**: With Skin（如果需要模型）或 Without Skin（仅动画）
   - **帧率**: 30 FPS
   - **Skin**: T-Pose 或 Current Pose

### 步骤 2: 导入到 Godot

1. **创建动画资源目录**
   ```
   godot_project/assets/
   ├── models/
   │   └── goblin_worker.glb
   └── animations/
       ├── goblin_idle.glb
       ├── goblin_walk.glb
       ├── goblin_mining.glb
       └── ...
   ```

2. **拖入文件**
   - 将 .glb/.fbx 文件拖入 Godot 的 "FileSystem" Dock
   - Godot 会自动导入并创建 `.import` 文件

3. **配置导入设置**
   - 在 "Import" Dock 中选择 "Scene"
   - 勾选 "Import as Skeletal Animation"
   - 点击 "Reimport"

### 步骤 3: 替换场景动画

1. **打开场景文件**
   - `scenes/characters/GoblinWorker.tscn`
   - `scenes/characters/GoblinEngineer.tscn`

2. **替换 Model 节点**
   - 删除当前的 `MeshInstance3D` (CapsuleMesh)
   - 从导入的 .glb 场景拖入完整的模型节点树
   - 确保包含 `Skeleton3D` 和 `AnimationPlayer`

3. **更新 AnimationPlayer**
   - 选择 `AnimationPlayer` 节点
   - 在 "Animation" 面板中可以看到导入的所有动画
   - 修改 autoplay 为 "idle" 或您的待机动画名称

4. **调整碰撞体**
   - 根据新模型的大小调整 `CollisionShape3D`
   - 确保碰撞体包裹模型但不过大

### 步骤 4: 更新脚本中的动画名称

如果 Mixamo 的动画名称与您的不同（如 "Idle" vs "idle"），需要更新脚本：

```gdscript
# 在各个状态文件中查找并替换
animation_player.play("Idle")  # Mixamo 通常首字母大写
```

---

## 🎮 使用 AnimationTree（高级）

对于更复杂的动画状态管理，可以使用 `AnimationTree`：

### 1. 添加 AnimationTree 节点
```
GoblinWorker (CharacterBody3D)
├── Model (...)
├── AnimationPlayer
└── AnimationTree  # 新增
```

### 2. 配置状态机
- 在 `AnimationTree` 的 "Tree Root" 属性中选择 "AnimationNodeStateMachine"
- 添加动画状态：Idle, Move, Work, Attack, Death
- 连接状态转换（Transitions）

### 3. 代码控制
```gdscript
# 在状态文件中
var anim_tree = worker.get_node("AnimationTree")
anim_tree.set("parameters/conditions/is_moving", true)

# 或直接切换状态
var playback = anim_tree.get("parameters/playback")
playback.travel("Move")
```

---

## 📋 动画映射表

### GoblinWorker 状态 → 动画映射
| 状态 State        | 推荐动画            | 当前占位动画 |
| ----------------- | ------------------- | ------------ |
| IdleState         | Idle / Standing     | idle         |
| MoveToMineState   | Walking             | move         |
| MiningState       | Mining / Hammering  | work         |
| ReturnToBaseState | Walking (Carrying)  | move         |
| DepositGoldState  | Idle                | idle         |
| WanderState       | Walking (Slow)      | move         |
| EscapeState       | Running / Panicking | move         |

### GoblinEngineer 状态 → 动画映射
| 状态 State        | 推荐动画              | 当前占位动画 |
| ----------------- | --------------------- | ------------ |
| IdleState         | Idle / Looking Around | idle         |
| FetchGoldState    | Walking               | move         |
| MoveToTargetState | Walking               | move         |
| WorkState         | Hammering / Building  | work         |
| ReturnGoldState   | Walking (Carrying)    | move         |
| WanderState       | Walking (Slow)        | move         |
| EscapeState       | Running / Panicking   | move         |

---

## 🎯 性能优化建议（来自设计文档）

### 1. 批量渲染（MultiMeshInstance3D）
当有大量相同单位时：
```gdscript
# 使用 MultiMeshInstance3D 渲染大量工人
var multi_mesh = MultiMeshInstance3D.new()
multi_mesh.multimesh = MultiMesh.new()
multi_mesh.multimesh.mesh = worker_mesh
multi_mesh.multimesh.instance_count = 100
```

### 2. LOD（Level of Detail）
为远处的单位使用低细节模型：
```gdscript
# 简单的 LOD 实现
func _process(_delta):
    var distance = global_position.distance_to(camera.global_position)
    if distance > 50:
        model.visible = false  # 或切换到低模
    else:
        model.visible = true
```

### 3. 动画更新频率控制
```gdscript
# 远处单位降低动画帧率
if distance > 30:
    animation_player.playback_speed = 0.5
else:
    animation_player.playback_speed = 1.0
```

---

## 🔄 快速切换指南

### 从占位动画切换到真实动画：

1. ✅ **保留当前代码** - 所有动画调用已经就位
2. ✅ **替换场景** - 只需更新 .tscn 文件中的模型和动画
3. ✅ **匹配名称** - 确保新动画名称与代码中的一致
4. ✅ **测试运行** - 在 Godot 编辑器中测试每个状态

### 推荐工作流程：
```
当前阶段 → 游戏原型开发（使用占位动画）
    ↓
第二阶段 → 下载 Mixamo 动画（保留占位作为备份）
    ↓
第三阶段 → 集成真实动画（逐个单位类型替换）
    ↓
第四阶段 → 优化性能（LOD、批量渲染）
```

---

## 🆘 常见问题

### Q: 动画播放了但模型没有动？
A: 确保模型有 `Skeleton3D` 节点，并且动画轨道绑定到了骨骼。

### Q: 导入的模型太大或太小？
A: 在导入设置中调整 "Scale"，或在场景中设置 Model 节点的 scale。

### Q: 动画切换不流畅？
A: 使用 `AnimationTree` 的混合功能，或在代码中添加：
```gdscript
animation_player.play("new_anim")
animation_player.queue("next_anim")  # 队列下一个动画
```

### Q: Mixamo 动画在 Godot 中方向不对？
A: Mixamo 模型默认朝向是 +Z，可能需要旋转模型节点 180度。

---

## 📚 参考资源

- **Mixamo**: https://www.mixamo.com
- **Godot Animation文档**: https://docs.godotengine.org/en/stable/tutorials/animation/index.html
- **glTF规范**: https://www.khronos.org/gltf/
- **项目文档**: 
  - `文档/模型下载.md` - 资源获取指南
  - `文档/模型导入.md` - Godot导入详细步骤

---

**最后更新**: 2025-10-10  
**当前状态**: 占位动画已就位，可正常运行游戏 ✅  
**下一步**: 根据需要从 Mixamo 获取专业动画进行升级

