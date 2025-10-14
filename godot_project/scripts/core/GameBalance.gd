## 游戏平衡配置
##
## 此文件定义了游戏的平衡参数，包括起始资源、单位上限、刷新率等。
## 可以方便地调整这些参数来平衡游戏难度。
class_name GameBalance
extends Object

## ============================================================================
## 起始资源
## ============================================================================

const STARTING_GOLD: int = 1000
const STARTING_MANA: int = 100
const STARTING_FOOD: int = 50

## ============================================================================
## 单位和建筑限制
## ============================================================================

const MAX_CREATURES: int = 20
const MAX_BUILDINGS: int = 50
const MAX_HEROES: int = 10

## ============================================================================
## 刷新和生成
## ============================================================================

const HERO_SPAWN_RATE: float = 0.0008 # 每帧英雄刷新概率
const HERO_SPAWN_INTERVAL: float = 120.0 # 英雄刷新间隔（秒）

## ============================================================================
## 资源生成
## ============================================================================

const GOLD_PER_SECOND_PER_TREASURY: int = 1 # 每个金库每秒生成1金币
const MANA_PER_5_SECONDS: int = 1 # 地牢之心每5秒生成1点魔力
const MANA_GENERATION_INTERVAL: float = 5.0 # 魔力生成间隔（秒）

## ============================================================================
## 资源消耗
## ============================================================================

const DIG_COST: int = 10 # 挖掘成本
const SUMMON_WORKER_COST: int = 80 # 召唤苦工成本
const SUMMON_ENGINEER_COST: int = 100 # 召唤工程师成本

## ============================================================================
## 建筑成本
## ============================================================================

const TREASURY_COST: int = 200 # 金库成本
const MAGIC_ALTAR_COST: int = 350 # 魔法祭坛成本
const ARCANE_TOWER_COST: int = 200 # 奥术塔成本
const DEMON_LAIR_COST: int = 400 # 恶魔巢穴成本
const ORC_LAIR_COST: int = 400 # 兽人巢穴成本
const ARROW_TOWER_COST: int = 150 # 箭塔成本

## ============================================================================
## 建筑容量
## ============================================================================

const TREASURY_CAPACITY: int = 1000 # 金库容量
const MAGIC_ALTAR_CAPACITY: int = 500 # 魔法祭坛魔力容量
const MAGIC_ALTAR_TEMP_GOLD: int = 60 # 魔法祭坛临时金币存储

## ============================================================================
## 单位成本
## ============================================================================

const IMP_COST: int = 100 # 小恶魔成本
const ORC_WARRIOR_COST: int = 150 # 兽人战士成本
const GARGOYLE_COST: int = 120 # 石像鬼成本
const FIRE_LIZARD_COST: int = 140 # 火蜥蜴成本
const HELLHOUND_COST: int = 130 # 地狱犬成本
const SHADOW_MAGE_COST: int = 160 # 暗影法师成本
const TREANT_COST: int = 180 # 树人守护者成本
const SHADOW_LORD_COST: int = 200 # 暗影领主成本
const STONE_GOLEM_COST: int = 170 # 石魔像成本
const SUCCUBUS_COST: int = 150 # 魅魔成本
const BONE_DRAGON_COST: int = 300 # 骨龙成本

## ============================================================================
## 维护费用
## ============================================================================

const IMP_UPKEEP: float = 0.5 # 小恶魔维护费
const ORC_WARRIOR_UPKEEP: float = 1.0 # 兽人战士维护费
const GARGOYLE_UPKEEP: float = 0.8
const FIRE_LIZARD_UPKEEP: float = 0.9
const HELLHOUND_UPKEEP: float = 0.8
const SHADOW_MAGE_UPKEEP: float = 1.2
const TREANT_UPKEEP: float = 1.0
const SHADOW_LORD_UPKEEP: float = 1.5
const STONE_GOLEM_UPKEEP: float = 1.0
const SUCCUBUS_UPKEEP: float = 1.0
const BONE_DRAGON_UPKEEP: float = 2.0

## ============================================================================
## 战斗平衡
## ============================================================================

const ARMOR_DAMAGE_REDUCTION: float = 0.06 # 每点护甲减少6%伤害
const MAX_ARMOR_REDUCTION: float = 0.8 # 护甲最多减少80%伤害
const CRITICAL_HIT_CHANCE: float = 0.1 # 暴击概率10%
const CRITICAL_HIT_MULTIPLIER: float = 2.0 # 暴击伤害倍数

## ============================================================================
## 经验和升级 (预留)
## ============================================================================

const XP_PER_KILL: int = 10 # 每次击杀获得经验
const XP_FOR_LEVEL_UP: int = 100 # 升级所需经验
const LEVEL_UP_STAT_BONUS: float = 0.1 # 升级后属性提升10%
