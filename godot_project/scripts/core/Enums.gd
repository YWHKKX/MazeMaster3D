## 游戏枚举定义
##
## 此文件定义了游戏中所有的枚举类型，包括瓦片类型、建造模式、
## 生物类型、攻击类型、击退类型等。保持与Python版本的enums.py一致。
class_name Enums
extends Object

## ============================================================================
## 瓦片类型
## ============================================================================

enum TileType {
	ROCK = 0, ## 岩石
	GROUND = 1, ## 地面
	ROOM = 2, ## 房间
	GOLD_VEIN = 3, ## 金矿脉
	DEPLETED_VEIN = 4 ## 枯竭的矿脉
}

## ============================================================================
## 建造模式
## ============================================================================

enum BuildMode {
	NONE, ## 无建造模式
	DIG, ## 挖掘模式
	TREASURY, ## 建造金库
	SUMMON, ## 召唤单位
	SUMMON_SELECTION, ## 怪物选择模式
	SUMMON_LOGISTICS, ## 后勤召唤模式
	
	## 建筑系统建造模式
	BUILD_INFRASTRUCTURE, ## 基础设施建筑
	BUILD_FUNCTIONAL, ## 功能性建筑
	BUILD_MILITARY, ## 军事建筑
	BUILD_MAGICAL, ## 魔法建筑
	BUILD_SPECIFIC, ## 特定建筑类型
	
	## 工程师相关模式
	SUMMON_ENGINEER ## 召唤工程师
}

## ============================================================================
## 生物类型
## ============================================================================

enum CreatureType {
	## 怪物类型
	GOBLIN, ## 哥布林
	GOBLIN_WORKER, ## 哥布林苦工
	GOBLIN_ENGINEER, ## 地精工程师
	ORC_WARRIOR, ## 兽人战士
	IMP, ## 小恶魔
	GARGOYLE, ## 石像鬼
	FIRE_LIZARD, ## 火蜥蜴
	HELLHOUND, ## 地狱犬
	TREANT, ## 树人守护者
	SHADOW_MAGE, ## 暗影法师
	SHADOW_LORD, ## 暗影领主
	STONE_GOLEM, ## 石魔像
	SUCCUBUS, ## 魅魔
	BONE_DRAGON, ## 骨龙
	
	## 英雄类型
	KNIGHT, ## 骑士
	ARCHER, ## 弓箭手
	MAGE, ## 法师
	PRIEST, ## 牧师
	THIEF, ## 盗贼
	PALADIN, ## 圣骑士
	ASSASSIN, ## 刺客
	RANGER, ## 游侠
	ARCHMAGE, ## 大法师
	DRUID, ## 德鲁伊
	BERSERKER, ## 狂战士
	ENGINEER, ## 工程师
	DRAGON_KNIGHT, ## 龙骑士
	SHADOW_BLADE_MASTER ## 暗影剑圣
}

## ============================================================================
## 生物状态 (通用)
## ============================================================================

enum CreatureStatus {
	IDLE, ## 空闲
	WANDERING, ## 游荡
	MOVING, ## 移动中
	FIGHTING, ## 战斗中
	FLEEING, ## 逃跑中
	MINING, ## 挖矿中
	BUILDING, ## 建造中
	DEPOSITING, ## 存放中
	FETCHING ## 取物中
}

## ============================================================================
## 工程师状态 (特殊)
## ============================================================================

enum EngineerStatus {
	IDLE, ## 空闲 - 任务决策
	FETCHING_RESOURCES, ## 取金状态
	MOVING_TO_TARGET, ## 移动至目标建筑
	WORKING, ## 工作状态（建造/装填）
	RETURNING_GOLD, ## 归还金币
	ESCAPING ## 逃跑状态
}

## ============================================================================
## 苦工状态 (特殊)
## ============================================================================

enum WorkerStatus {
	IDLE, ## 空闲状态
	MOVING_TO_MINE, ## 移动至金矿
	MINING, ## 挖矿状态
	RETURNING_TO_BASE, ## 返回基地
	DEPOSITING_GOLD, ## 存放金币
	WANDERING, ## 游荡状态
	ESCAPING ## 逃跑状态
}

## ============================================================================
## 攻击类型
## ============================================================================

enum AttackType {
	NORMAL, ## 普通攻击
	HEAVY, ## 重击攻击
	AREA, ## 范围攻击
	MAGIC, ## 魔法攻击
	PIERCING, ## 穿透攻击
	RANGED, ## 远程攻击
	## 详细分类（参考战斗系统.md）
	MELEE_SWORD, ## 近战-剑类
	MELEE_SPEAR, ## 近战-矛类
	MELEE_AXE, ## 近战-斧类
	RANGED_BOW, ## 远程-弓箭
	RANGED_GUN, ## 远程-火枪
	RANGED_CROSSBOW, ## 远程-弩
	MAGIC_SINGLE, ## 单体魔法
	MAGIC_AOE, ## 范围魔法
	MAGIC_HEAL ## 治疗魔法
}

## ============================================================================
## 击退类型
## ============================================================================

enum KnockbackType {
	NONE, ## 无击退
	WEAK, ## 弱击退
	NORMAL, ## 普通击退
	STRONG ## 强击退
}

## ============================================================================
## 建筑类型
## ============================================================================

enum BuildingType {
	DUNGEON_HEART, ## 地牢之心
	TREASURY, ## 金库
	MAGIC_ALTAR, ## 魔法祭坛
	ARCANE_TOWER, ## 奥术塔
	ARROW_TOWER, ## 箭塔
	DEMON_LAIR, ## 恶魔巢穴
	ORC_LAIR, ## 兽人巢穴
	BARRACKS, ## 兵营
	TRAINING_ROOM, ## 训练室
	LIBRARY, ## 图书馆
	WORKSHOP ## 工坊
}

## ============================================================================
## 建筑状态
## ============================================================================

enum BuildingStatus {
	INCOMPLETE, ## 未完成建筑
	COMPLETED, ## 完成建筑
	DESTROYED, ## 被摧毁建筑
	NEEDS_REPAIR, ## 需要修复建筑
	NO_AMMUNITION, ## 空弹药
	TREASURY_FULL, ## 金库爆满
	NEEDS_MAGE, ## 需要法师辅助
	MANA_FULL, ## 法力存储池已满
	MANA_GENERATION, ## 魔力生成状态
	TRAINING, ## 训练状态
	SUMMONING, ## 召唤状态
	SUMMONING_PAUSED, ## 暂停召唤状态
	LOCKED, ## 锁定状态
	READY_TO_TRAIN, ## 准备训练
	READY_TO_SUMMON, ## 准备召唤
	ACCEPTING_GOLD ## 接受金币
}

## ============================================================================
## 阵营系统
## ============================================================================

enum Faction {
	PLAYER, ## 玩家阵营
	MONSTERS, ## 怪物阵营
	HEROES, ## 英雄阵营
	NEUTRAL ## 中立阵营
}

## ============================================================================
## 资源类型
## ============================================================================

enum ResourceType {
	GOLD, ## 金币
	MANA, ## 法力
	FOOD ## 食物
}

## ============================================================================
## 伤害类型
## ============================================================================

enum DamageType {
	PHYSICAL, ## 物理伤害
	MAGICAL, ## 魔法伤害
	TRUE ## 真实伤害（无视护甲）
}

## ============================================================================
## 技能类型
## ============================================================================

enum SkillType {
	PASSIVE, ## 被动技能
	ACTIVE, ## 主动技能
	ULTIMATE ## 终极技能
}

## ============================================================================
## UI 模式
## ============================================================================

enum UIMode {
	NORMAL, ## 正常模式
	BUILD, ## 建造模式
	SUMMON, ## 召唤模式
	SELECT ## 选择模式
}

## ============================================================================
## 游戏状态
## ============================================================================

enum GameState {
	MENU, ## 菜单状态
	PLAYING, ## 游戏中
	PAUSED, ## 暂停
	GAME_OVER, ## 游戏结束
	VICTORY ## 胜利
}

## ============================================================================
## 辅助函数：枚举转字符串
## ============================================================================

static func tile_type_to_string(type: TileType) -> String:
	match type:
		TileType.ROCK: return "rock"
		TileType.GROUND: return "ground"
		TileType.ROOM: return "room"
		TileType.GOLD_VEIN: return "gold_vein"
		TileType.DEPLETED_VEIN: return "depleted_vein"
		_: return "unknown"

static func creature_type_to_string(type: CreatureType) -> String:
	match type:
		CreatureType.GOBLIN: return "goblin"
		CreatureType.GOBLIN_WORKER: return "goblin_worker"
		CreatureType.GOBLIN_ENGINEER: return "goblin_engineer"
		CreatureType.KNIGHT: return "knight"
		CreatureType.ARCHER: return "archer"
		CreatureType.MAGE: return "mage"
		CreatureType.ORC_WARRIOR: return "orc_warrior"
		CreatureType.IMP: return "imp"
		CreatureType.GARGOYLE: return "gargoyle"
		CreatureType.FIRE_LIZARD: return "fire_lizard"
		CreatureType.HELLHOUND: return "hellhound"
		CreatureType.TREANT: return "treant"
		CreatureType.SHADOW_MAGE: return "shadow_mage"
		CreatureType.SHADOW_LORD: return "shadow_lord"
		CreatureType.STONE_GOLEM: return "stone_golem"
		CreatureType.SUCCUBUS: return "succubus"
		CreatureType.BONE_DRAGON: return "bone_dragon"
		_: return "unknown"

static func building_type_to_string(type: BuildingType) -> String:
	match type:
		BuildingType.DUNGEON_HEART: return "dungeon_heart"
		BuildingType.TREASURY: return "treasury"
		BuildingType.MAGIC_ALTAR: return "magic_altar"
		BuildingType.ARCANE_TOWER: return "arcane_tower"
		BuildingType.ARROW_TOWER: return "arrow_tower"
		BuildingType.DEMON_LAIR: return "demon_lair"
		BuildingType.ORC_LAIR: return "orc_lair"
		BuildingType.BARRACKS: return "barracks"
		BuildingType.TRAINING_ROOM: return "training_room"
		BuildingType.LIBRARY: return "library"
		BuildingType.WORKSHOP: return "workshop"
		_: return "unknown"

static func faction_to_string(faction: Faction) -> String:
	match faction:
		Faction.PLAYER: return "player"
		Faction.MONSTERS: return "monsters"
		Faction.HEROES: return "heroes"
		Faction.NEUTRAL: return "neutral"
		_: return "unknown"
