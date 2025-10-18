extends Node

## MonstersTypes - 怪物类型常量（Autoload单例）
## 
## 统一管理怪物类型字符串常量，避免拼写错误

# ============================================================================
# 怪物类型枚举
# ============================================================================

enum MonsterType {
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
	BONE_DRAGON ## 骨龙
}

# 怪物状态枚举
enum MonsterStatus {
	IDLE, ## 空闲
	WANDERING, ## 游荡
	MOVING, ## 移动中
	FIGHTING, ## 战斗中
	FLEEING, ## 逃跑中
	MINING, ## 挖矿中
	BUILDING, ## 建造中
	DEPOSITING, ## 存放中
	FETCHING, ## 取物中
	EXCAVATING ## 挖掘空洞中
}

# 工程师状态枚举（从Enums.gd迁移）
enum EngineerStatus {
	IDLE, ## 空闲 - 任务决策
	FETCHING_RESOURCES, ## 取金状态
	MOVING_TO_TARGET, ## 移动至目标建筑
	WORKING, ## 工作状态（建造/装填）
	RETURNING_GOLD, ## 归还金币
	ESCAPING ## 逃跑状态
}

# 苦工状态枚举（从Enums.gd迁移）
enum WorkerStatus {
	IDLE, ## 空闲状态
	MOVING_TO_MINE, ## 移动至金矿
	MINING, ## 挖矿状态
	RETURNING_TO_BASE, ## 返回基地
	DEPOSITING_GOLD, ## 存放金币
	WANDERING, ## 游荡状态
	ESCAPING ## 逃跑状态
}

# 阵营系统枚举（统一）
enum Faction {
	PLAYER = 0, ## 玩家阵营
	HEROES = 1, ## 英雄阵营（友方）
	MONSTERS = 2, ## 怪物阵营（敌对）
	BEASTS = 3, ## 野兽阵营（中立）
	NEUTRAL = 4 ## 中立阵营
}

# ============================================================================
# 怪物类型字符串常量
# ============================================================================

# 后勤单位类型
const GOBLIN_WORKER = "goblin_worker"
const GOBLIN_ENGINEER = "goblin_engineer"

# 怪物单位类型
const GOBLIN = "goblin"
const IMP = "imp"
const ORC_WARRIOR = "orc_warrior"
const GARGOYLE = "gargoyle"
const FIRE_LIZARD = "fire_lizard"
const SHADOW_MAGE = "shadow_mage"
const HELLHOUND = "hellhound"
const TREANT = "treant"
const SUCCUBUS = "succubus"
const SHADOW_LORD = "shadow_lord"
const STONE_GOLEM = "stone_golem"
const BONE_DRAGON = "bone_dragon"

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	name = "MonstersTypes"
	LogManager.info("MonstersTypes - 怪物类型常量已初始化")

# ============================================================================
# 工具函数
# ============================================================================

## 获取怪物类型名称（中文）
static func get_monster_name(monster_type: String) -> String:
	match monster_type:
		# 后勤单位
		GOBLIN_WORKER:
			return "哥布林苦工"
		GOBLIN_ENGINEER:
			return "地精工程师"
		
		# 怪物单位
		GOBLIN:
			return "哥布林"
		IMP:
			return "小鬼"
		ORC_WARRIOR:
			return "兽人战士"
		GARGOYLE:
			return "石像鬼"
		FIRE_LIZARD:
			return "火蜥蜴"
		SHADOW_MAGE:
			return "暗影法师"
		HELLHOUND:
			return "地狱犬"
		TREANT:
			return "树人"
		SUCCUBUS:
			return "魅魔"
		SHADOW_LORD:
			return "暗影领主"
		STONE_GOLEM:
			return "石头傀儡"
		BONE_DRAGON:
			return "骨龙"
		_:
			return "未知怪物"

## 检查是否是后勤单位
static func is_logistics_unit(monster_type: String) -> bool:
	return monster_type in [GOBLIN_WORKER, GOBLIN_ENGINEER]

## 检查是否是怪物单位
static func is_monster(monster_type: String) -> bool:
	return monster_type in [
		GOBLIN, IMP, ORC_WARRIOR, GARGOYLE, FIRE_LIZARD, SHADOW_MAGE,
		HELLHOUND, TREANT, SUCCUBUS, SHADOW_LORD, STONE_GOLEM, BONE_DRAGON
	]

## 检查是否是战斗单位
static func is_combat_unit(monster_type: String) -> bool:
	return is_monster(monster_type)

## 获取怪物分类
static func get_monster_category(monster_type: String) -> String:
	if is_logistics_unit(monster_type):
		return "logistics"
	elif is_monster(monster_type):
		return "monster"
	else:
		return "unknown"

## 获取怪物图标（用于UI显示）
static func get_monster_icon(monster_type: String) -> String:
	match monster_type:
		# 后勤单位
		GOBLIN_WORKER:
			return "👷"
		GOBLIN_ENGINEER:
			return "🔧"
		
		# 怪物单位
		GOBLIN:
			return "👹"
		IMP:
			return "👹"
		ORC_WARRIOR:
			return "⚔️"
		GARGOYLE:
			return "🗿"
		FIRE_LIZARD:
			return "🦎"
		SHADOW_MAGE:
			return "🧙"
		HELLHOUND:
			return "🐺"
		TREANT:
			return "🌳"
		SUCCUBUS:
			return "👿"
		SHADOW_LORD:
			return "👤"
		STONE_GOLEM:
			return "🗿"
		BONE_DRAGON:
			return "🐉"
		_:
			return "❓"

## 获取所有后勤单位类型
static func get_all_logistics_types() -> Array[String]:
	return [GOBLIN_WORKER, GOBLIN_ENGINEER]

## 获取所有怪物单位类型
static func get_all_monster_types() -> Array[String]:
	return [
		GOBLIN, IMP, ORC_WARRIOR, GARGOYLE, FIRE_LIZARD, SHADOW_MAGE,
		HELLHOUND, TREANT, SUCCUBUS, SHADOW_LORD, STONE_GOLEM, BONE_DRAGON
	]

## 获取怪物阵营
static func get_monster_faction(_monster_type: String) -> String:
	return "MONSTERS" # 所有怪物都属于怪物阵营

## 检查是否为魔法单位
static func is_magic_monster(monster_type: String) -> bool:
	return monster_type in [SHADOW_MAGE, SHADOW_LORD, SUCCUBUS, BONE_DRAGON]

## 检查是否为近战单位
static func is_melee_monster(monster_type: String) -> bool:
	return monster_type in [GOBLIN, ORC_WARRIOR, GARGOYLE, FIRE_LIZARD, HELLHOUND, TREANT, STONE_GOLEM, BONE_DRAGON]

## 检查是否为远程单位
static func is_ranged_monster(monster_type: String) -> bool:
	return monster_type in [IMP, SHADOW_MAGE, SHADOW_LORD, SUCCUBUS]

# ============================================================================
# 向后兼容函数
# ============================================================================

## 获取角色类型名称（向后兼容）
static func get_character_name(character_type: String) -> String:
	return get_monster_name(character_type)

## 获取角色图标（向后兼容）
static func get_character_icon(character_type: String) -> String:
	return get_monster_icon(character_type)

## 检查是否是怪物单位（向后兼容）
static func is_monster_unit(character_type: String) -> bool:
	return is_monster(character_type)

## 获取角色分类（向后兼容）
static func get_character_category(character_type: String) -> String:
	return get_monster_category(character_type)
