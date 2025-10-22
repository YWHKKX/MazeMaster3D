# 🏦 金库建筑 (Treasury)

## 概述
金库是游戏中用于存储金币的1x1瓦块建筑，采用金色财富主题设计。

## 建筑信息
- **建筑类型**: 经济建筑 (Economic)
- **建筑尺寸**: 1x1瓦块
- **建筑等级**: Tier 2
- **主题色彩**: 金色、深金色、浅金色
- **特殊效果**: 金色发光效果

## 组件列表
金库使用5个专用组件：

1. **Treasure_Chest** (ID: 1001)
   - 层级: 地面层 (Floor)
   - 材质: 金色 (Gold)
   - 说明: 存储金币的主要宝箱

2. **Gold_Pile** (ID: 1002)
   - 层级: 装饰层 (Decoration)
   - 材质: 金色 (Gold)
   - 说明: 闪闪发光的金币堆

3. **Gold_Bar** (ID: 1003)
   - 层级: 装饰层 (Decoration)
   - 材质: 金色 (Gold)
   - 说明: 珍贵的金条装饰

4. **Vault_Door** (ID: 1004)
   - 层级: 墙壁层 (Wall)
   - 材质: 金属 (Metal)
   - 说明: 坚固的金库大门

5. **Gold_Coin** (ID: 1005)
   - 层级: 装饰层 (Decoration)
   - 材质: 金色 (Gold)
   - 说明: 散落的金币装饰

## 文件结构
```
treasury/
├── components/          # 组件场景文件
│   ├── Treasure_Chest.tscn
│   ├── Gold_Pile.tscn
│   ├── Gold_Bar.tscn
│   ├── Vault_Door.tscn
│   └── Gold_Coin.tscn
├── materials/           # 材质配置
│   └── TreasuryMaterialConfig.gd
├── textures/            # 纹理配置
│   └── TreasuryTextures.gd
├── TreasuryConfig.gd    # 主配置文件
└── README.md            # 本文档
```

## 建筑属性
- **生命值**: 200
- **护甲**: 5
- **建造成本**: 500金币
- **存储容量**: 10,000金币
- **安全等级**: 3

## 材质配置
金库使用5种材质：

1. **gold** - 标准金色
   - 颜色: RGB(1.0, 0.84, 0.0)
   - 粗糙度: 0.2
   - 金属度: 0.9
   - 发光: RGB(1.0, 0.9, 0.3), 能量1.5

2. **dark_gold** - 深金色
   - 颜色: RGB(0.8, 0.6, 0.0)
   - 粗糙度: 0.3
   - 金属度: 0.8
   - 发光: RGB(0.9, 0.7, 0.2), 能量1.0

3. **light_gold** - 浅金色
   - 颜色: RGB(1.0, 1.0, 0.8)
   - 粗糙度: 0.1
   - 金属度: 0.7
   - 发光: RGB(1.0, 1.0, 0.9), 能量2.0

4. **metal** - 金属色
   - 颜色: RGB(0.6, 0.6, 0.6)
   - 粗糙度: 0.3
   - 金属度: 0.9

5. **stone** - 石质色
   - 颜色: RGB(0.4, 0.4, 0.4)
   - 粗糙度: 0.8
   - 金属度: 0.1

## 使用方法
```gdscript
# 创建金库实例
var treasury = UnifiedTreasury.new()
treasury.building_id = "treasury_001"
treasury.tile_x = 10
treasury.tile_y = 5
add_child(treasury)
```

## 开发状态
- [x] 配置文件创建
- [x] 材质系统创建
- [x] 纹理系统创建
- [x] UnifiedTreasury重构
- [ ] 组件场景文件创建
- [ ] 纹理资源创建
- [ ] 游戏内测试

## 设计参考
基于地牢之心的成功实现，金库采用相同的分层GridMap系统和配置化设计，确保系统的一致性和可维护性。
