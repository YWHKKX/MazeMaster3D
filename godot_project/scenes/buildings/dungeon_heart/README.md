# 🏰 地牢之心 (Dungeon Heart)

## 📁 文件夹结构

```
dungeon_heart/
├── components/           # 地牢之心专用组件
│   ├── Heart_Core.tscn          # 地牢之心核心
│   ├── Core_Chamber.tscn        # 核心密室
│   ├── Power_Node.tscn          # 能量节点
│   ├── Energy_Flow.tscn         # 能量流动
│   ├── Energy_Crystal.tscn      # 能量水晶
│   ├── Heart_Entrance.tscn      # 地牢之心入口
│   ├── Energy_Conduit.tscn      # 能量导管
│   ├── Magic_Core.tscn          # 魔法核心
│   ├── Mana_Crystal.tscn        # 魔力水晶
│   ├── Energy_Node.tscn         # 能量节点
│   └── Storage_Core.tscn        # 存储核心
├── materials/            # 地牢之心专用材质
│   ├── DungeonHeartMaterials.tres      # 材质资源文件
│   └── DungeonHeartMaterialConfig.gd   # 材质配置脚本
├── textures/             # 地牢之心专用纹理
│   └── DungeonHeartTextures.gd         # 纹理配置脚本
├── DungeonHeartConfig.gd # 地牢之心主配置文件
└── README.md             # 说明文档
```

## 🎨 材质系统 - 黑色底座 + 红色魔力主题

### 核心组件材质 (红色魔力核心)
- **Heart Core**: 深红色发光 `Color(0.9, 0.1, 0.1)`，高金属度0.9，强烈红色发光 `emission_energy: 2.5`
- **Magic Core**: 深红色发光 `Color(0.9, 0.1, 0.1)`，高金属度0.8，强烈红色发光 `emission_energy: 2.2`
- **Energy Crystal**: 红色水晶 `Color(0.8, 0.1, 0.1)`，红色发光 `emission_energy: 2.0`
- **Mana Crystal**: 深红色魔力水晶 `Color(0.7, 0.1, 0.1)`，红色发光 `emission_energy: 1.8`

### 魔力管道材质 (红色魔力管道)
- **Energy Conduit**: 深红色导管 `Color(0.6, 0.1, 0.1)`，红色发光 `emission_energy: 1.5`
- **Energy Node**: 深红色节点 `Color(0.5, 0.1, 0.1)`，红色发光 `emission_energy: 1.6`
- **Storage Core**: 深红色存储 `Color(0.4, 0.1, 0.1)`，红色发光 `emission_energy: 1.4`
- **Energy Flow**: 深红色流动 `Color(0.6, 0.1, 0.1)`，红色发光 `emission_energy: 1.6`

### 黑色底座材质 (黑色底座)
- **Core Chamber**: 纯黑色金属底座 `Color(0.1, 0.1, 0.1)`，高金属度0.8，不发光
- **Heart Entrance**: 深红色木质入口 `Color(0.2, 0.1, 0.1)`，微弱红色发光 `emission_energy: 0.3`

## 🖼️ 纹理系统

### 纹理特点
- **UV缩放**: 根据组件类型调整纹理重复
- **法线贴图**: 增强表面细节
- **粗糙度贴图**: 控制表面反射特性
- **发光贴图**: 支持自发光效果

### 纹理文件
- `heart_core.png` - 地牢之心核心纹理
- `energy_crystal.png` - 能量水晶纹理
- `mana_crystal.png` - 魔力水晶纹理
- `magic_core.png` - 魔法核心纹理
- `energy_conduit.png` - 能量导管纹理
- `energy_node.png` - 能量节点纹理
- `storage_core.png` - 存储核心纹理
- `heart_entrance.png` - 地牢之心入口纹理
- `dungeon_stone.png` - 地牢石质纹理
- `dungeon_metal.png` - 地牢金属纹理

## 🏗️ 建筑配置

### 建筑属性
- **尺寸**: 2x2瓦块，3层高
- **生命值**: 300/300
- **护甲**: 10
- **造价**: 1500金币

### 特殊属性
- **魔力生成率**: 10.0/秒
- **最大魔力容量**: 1000
- **生命力**: 100
- **腐化半径**: 5.0

### 渲染模式
- **分层渲染**: 启用
- **发光效果**: 启用
- **透明效果**: 启用

## 🔧 使用方法

### 1. 加载配置
```gdscript
var config = DungeonHeartConfig.get_config()
var materials = DungeonHeartMaterialConfig.get_all_materials()
var textures = DungeonHeartTextures.get_all_textures()
```

### 2. 创建材质
```gdscript
var heart_core_material = DungeonHeartMaterialConfig.create_material("heart_core")
var energy_crystal_material = DungeonHeartMaterialConfig.create_material("energy_crystal")
```

### 3. 应用纹理
```gdscript
DungeonHeartTextures.apply_texture_to_material(material, "heart_core_texture")
```

### 4. 获取组件配置
```gdscript
var heart_core_config = DungeonHeartConfig.get_component_config("heart_core")
var energy_crystal_config = DungeonHeartConfig.get_component_config("energy_crystal")
```

## 📝 注意事项

1. **组件ID**: 确保组件ID与BuildingComponents.gd中的定义一致
2. **材质路径**: 纹理文件需要放在textures/文件夹中
3. **场景文件**: 组件场景文件需要正确引用BuildingComponent.gd脚本
4. **资源加载**: 使用前确保所有资源文件存在且路径正确

## 🎯 扩展说明

### 添加新组件
1. 在`components/`文件夹中创建新的.tscn文件
2. 在`DungeonHeartConfig.gd`中添加组件配置
3. 在`DungeonHeartMaterialConfig.gd`中添加材质配置
4. 在`DungeonHeartTextures.gd`中添加纹理配置

### 修改材质
1. 编辑`DungeonHeartMaterialConfig.gd`中的材质参数
2. 重新生成材质资源文件
3. 更新组件场景文件中的材质引用

### 添加纹理
1. 将纹理文件放入`textures/`文件夹
2. 在`DungeonHeartTextures.gd`中添加纹理配置
3. 更新材质配置以使用新纹理
