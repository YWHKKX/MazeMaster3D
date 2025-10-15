# 统一阵营系统设计文档

## 概述

本文档描述了游戏中的统一阵营系统，简化了原有的复杂敌我关系逻辑，使用统一的阵营属性来管理所有单位的敌我关系。系统支持英雄、怪物、野兽和中立四种阵营类型，实现了清晰的敌我关系管理。

## 阵营类型

### 1. 怪物阵营 (`Enums.Faction.MONSTERS`)
- **包含单位**：
  - 所有怪物类型（Imp, OrcWarrior, GoblinWorker, GoblinEngineer 等）
  - 死地生物（骷髅、僵尸、恶魔、暗影兽等）
- **特点**：与英雄阵营互相敌对
- **碰撞层**：Layer 2

### 2. 英雄阵营 (`Enums.Faction.HEROES`)
- **包含单位**：
  - 所有英雄类型（Knight, Paladin, Assassin 等）
  - 所有建筑（dungeon_heart, treasury, arrow_tower, arcane_tower 等）
- **特点**：与怪物阵营互相敌对
- **碰撞层**：Layer 3

### 3. 野兽阵营 (`Enums.Faction.BEASTS`) - 新增
- **包含单位**：
  - 生态系统中的野生动物（鹿、狼、鱼、巨鼠等）
  - 森林生物（鹿、森林狼）
  - 草地生物（野兔、草原狼、犀角兽）
  - 湖泊生物（鱼、鱼人）
  - 洞穴生物（巨鼠）
  - 荒地生物（巨蜥）
- **特点**：对所有其他阵营都是中立的
- **碰撞层**：Layer 4

### 4. 中立阵营 (`Enums.Faction.NEUTRAL`)
- **包含单位**：特殊中立单位
- **特点**：对所有阵营都是中立的
- **碰撞层**：Layer 5

## 简化后的属性系统

### 移除的属性
- `is_monster` - 不再需要，由faction判断
- `is_enemy` - 不再需要，由faction判断  
- `is_hero` - 不再需要，由faction判断

### 保留的属性
- `faction` - 阵营属性，统一管理敌我关系
- `is_combat_unit` - 是否为战斗单位（用于技能系统等）

## 阵营关系

### 敌对关系
- **英雄 ↔ 怪物**：互相敌对
- **不同阵营**：默认敌对（除了野兽和中立）

### 友军关系
- **相同阵营**：互相友好
- **英雄 ↔ 英雄**：友军
- **怪物 ↔ 怪物**：友军
- **野兽 ↔ 野兽**：友军

### 中立关系
- **野兽 ↔ 所有其他阵营**：中立
- **中立阵营 ↔ 所有阵营**：中立

## 敌我关系判断

### 统一判断逻辑
```gdscript
# 判断是否为敌人
func is_enemy_of(other: CharacterBase) -> bool:
    if not other or not is_instance_valid(other):
        return false
    
    # 野兽阵营对所有阵营都是中立的
    if faction == Enums.Faction.BEASTS or other.faction == Enums.Faction.BEASTS:
        return false
    
    return faction != other.faction

# 判断是否为友军
func is_friend_of(other: CharacterBase) -> bool:
    if not other or not is_instance_valid(other):
        return false
    
    return faction == other.faction

# 判断是否为中立
func is_neutral_to(other: CharacterBase) -> bool:
    if not other or not is_instance_valid(other):
        return false
    
    # 野兽阵营对所有阵营都是中立的
    if faction == Enums.Faction.BEASTS or other.faction == Enums.Faction.BEASTS:
        return true
    
    # 中立阵营对所有阵营都是中立的
    if faction == Enums.Faction.NEUTRAL or other.faction == Enums.Faction.NEUTRAL:
        return true
    
    return false
```

### 判断规则
1. **不同阵营 = 敌人**：`MONSTERS` vs `HEROES` = 敌对
2. **相同阵营 = 友军**：`MONSTERS` vs `MONSTERS` = 友军
3. **野兽阵营 = 中立**：`BEASTS` vs 所有阵营 = 中立
4. **无阵营属性 = 敌人**：兼容性考虑，默认为敌对

## 单位分类

### 战斗单位 (`is_combat_unit = True`)
- 所有英雄
- 所有怪物
- 攻击性野兽（如森林狼）
- 防御塔（arrow_tower, arcane_tower）

### 非战斗单位 (`is_combat_unit = False`)
- 所有建筑（除防御塔外）
- 功能性单位（goblin_worker, goblin_engineer）
- 非攻击性野兽（如鹿、巨鼠）

## 实现细节

### 1. 碰撞层设置
```gdscript
# 根据阵营设置碰撞层
match faction:
    Enums.Faction.MONSTERS:
        set_collision_layer_value(2, true) # 怪物阵营层
    Enums.Faction.HEROES:
        set_collision_layer_value(3, true) # 英雄阵营层
    Enums.Faction.BEASTS:
        set_collision_layer_value(4, true) # 野兽阵营层
    Enums.Faction.NEUTRAL:
        set_collision_layer_value(5, true) # 中立阵营层
```

### 2. CharacterBase基类
```gdscript
class_name CharacterBase
extends CharacterBody3D

@export var faction: Enums.Faction = Enums.Faction.MONSTERS
@export var is_combat_unit: bool = true

func is_enemy_of(other: CharacterBase) -> bool:
    # 野兽阵营对所有阵营都是中立的
    if faction == Enums.Faction.BEASTS or other.faction == Enums.Faction.BEASTS:
        return false
    return faction != other.faction

func is_friend_of(other: CharacterBase) -> bool:
    return faction == other.faction

func is_neutral_to(other: CharacterBase) -> bool:
    if faction == Enums.Faction.BEASTS or other.faction == Enums.Faction.BEASTS:
        return true
    if faction == Enums.Faction.NEUTRAL or other.faction == Enums.Faction.NEUTRAL:
        return true
    return false
```

### 3. HeroBase类
```gdscript
class_name HeroBase
extends CharacterBase

func _ready() -> void:
    super._ready()
    faction = Enums.Faction.HEROES
    add_to_group(GameGroups.HEROES)
```

### 4. MonsterBase类
```gdscript
class_name MonsterBase
extends CharacterBase

func _ready() -> void:
    super._ready()
    faction = Enums.Faction.MONSTERS
    add_to_group(GameGroups.MONSTERS)
```

### 5. BeastBase类
```gdscript
class_name BeastBase
extends CharacterBase

@export var is_aggressive: bool = false

func _ready() -> void:
    super._ready()
    faction = Enums.Faction.BEASTS
    is_combat_unit = is_aggressive
    add_to_group(GameGroups.BEASTS)
```

### 6. 生态系统集成
```gdscript
# 在CreatureTypes.gd中定义生物阵营映射
static func get_creature_faction(creature_type: CreatureType) -> int:
    match creature_type:
        # 森林生物 - 野兽阵营（中立）
        CreatureType.DEER, CreatureType.FOREST_WOLF:
            return 3  # Enums.Faction.BEASTS
        
        # 死地生物 - 怪物阵营（敌对）
        CreatureType.SKELETON, CreatureType.ZOMBIE, CreatureType.DEMON:
            return 1  # Enums.Faction.MONSTERS
```

## 文件结构

```
scripts/
├── characters/
│   ├── CharacterBase.gd          # 基础角色类，包含阵营判断逻辑
│   ├── HeroBase.gd              # 英雄基类，设置英雄阵营
│   ├── MonsterBase.gd           # 怪物基类，设置怪物阵营
│   ├── BeastBase.gd             # 野兽基类，设置野兽阵营
│   ├── heroes/                  # 具体英雄类
│   ├── monsters/                # 具体怪物类
│   └── beasts/                  # 具体野兽类
│       ├── Deer.gd              # 鹿
│       ├── ForestWolf.gd        # 森林狼
│       └── GiantRat.gd          # 巨鼠
├── core/
│   └── Enums.gd                 # 阵营枚举定义
├── ecosystem/
│   ├── creatures/
│   │   └── CreatureTypes.gd     # 生物类型和阵营映射
│   ├── EcosystemManager.gd      # 生态系统管理器
│   └── FactionSystemTest.gd     # 阵营系统测试
└── autoload/
    └── GameGroups.gd            # 游戏组管理，包含野兽组
```

## 优势

### 1. 简化逻辑
- 移除了复杂的多重判断条件
- 统一使用faction属性管理敌我关系
- 代码更易维护和理解

### 2. 性能优化
- 减少了属性检查次数
- 简化了敌我判断逻辑
- 提高了战斗系统性能

### 3. 易于扩展
- 新增单位只需设置正确的faction
- 新增阵营类型只需修改判断逻辑
- 支持更复杂的阵营关系（如中立阵营）

### 4. 生态系统集成
- 野兽阵营的中立特性使生态系统更加真实
- 支持复杂的生物行为（觅食、逃跑等）
- 为游戏世界增添了更丰富的生态关系

## 兼容性

### 向后兼容
- 保留了`is_combat_unit`属性用于技能系统
- 对于没有faction属性的单位，默认为敌人
- 渐进式迁移，不影响现有功能

### 迁移指南
1. 移除所有`is_monster`、`is_enemy`、`is_hero`属性引用
2. 使用`faction`属性进行敌我判断
3. 使用`is_combat_unit`属性进行战斗单位判断

## 使用方法

### 创建野兽单位
```gdscript
# 创建鹿
var deer = preload("res://scripts/characters/beasts/Deer.gd").new()
deer.faction = Enums.Faction.BEASTS
add_child(deer)

# 创建森林狼
var wolf = preload("res://scripts/characters/beasts/ForestWolf.gd").new()
wolf.faction = Enums.Faction.BEASTS
wolf.is_aggressive = true  # 设置为攻击性
add_child(wolf)
```

### 检查阵营关系
```gdscript
# 检查是否为敌人
if hero.is_enemy_of(monster):
    print("英雄和怪物是敌人")

# 检查是否为友军
if hero.is_friend_of(another_hero):
    print("两个英雄是友军")

# 检查是否为中立
if beast.is_neutral_to(hero):
    print("野兽对英雄是中立的")
```

### 获取阵营信息
```gdscript
# 获取阵营名称
var faction_name = Enums.faction_to_string(character.faction)

# 获取所有野兽
var all_beasts = GameGroups.get_all_beasts()
```

## 测试建议

### 1. 阵营判断测试
- 验证不同阵营单位互相敌对
- 验证相同阵营单位互相友好
- 验证野兽阵营的中立特性
- 验证无阵营属性的兼容性

### 2. 技能系统测试
- 验证兽人战士旋风斩技能正常工作
- 验证技能只攻击敌对阵营
- 验证战斗单位判断正确

### 3. 战斗系统测试
- 验证攻击列表管理正确
- 验证目标选择逻辑正确
- 验证防御塔攻击逻辑正确

### 4. 生态系统测试
- 验证野兽的觅食和逃跑行为
- 验证野兽不会主动攻击其他阵营
- 验证死地生物的正确阵营设置

## 注意事项

1. 野兽阵营对所有其他阵营都是中立的，不会主动攻击或被攻击
2. 死地生物（骷髅、僵尸、恶魔等）属于怪物阵营，与英雄敌对
3. 碰撞层设置确保了不同阵营单位可以正确检测到彼此
4. 野兽受到攻击时会逃跑，体现了野生动物的特性

## 未来扩展

- 可以添加更多阵营类型（如中立商人、敌对派系等）
- 可以实现动态阵营变化（如野兽被驯服后改变阵营）
- 可以添加阵营声望系统
- 可以实现更复杂的阵营关系（如临时联盟等）

## 总结

统一阵营系统成功简化了游戏的敌我关系管理，提高了代码的可维护性和性能。通过使用单一的`faction`属性，我们实现了清晰、高效的阵营判断逻辑。新增的野兽阵营为游戏世界增添了更真实的生态关系，使英雄和怪物在战斗的同时，还能与生态系统中的野生动物和谐共存，为游戏的后续发展奠定了良好的基础。
