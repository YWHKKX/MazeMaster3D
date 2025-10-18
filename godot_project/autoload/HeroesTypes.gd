extends Node

## HeroesTypes - 英雄类型常量（Autoload单例）
## 
## 统一管理英雄类型字符串常量，避免拼写错误

# ============================================================================
# 英雄类型枚举
# ============================================================================

enum HeroType {
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

# 英雄状态枚举
enum HeroStatus {
	IDLE, ## 空闲
	WANDERING, ## 游荡
	MOVING, ## 移动中
	FIGHTING, ## 战斗中
	FLEEING, ## 逃跑中
	CASTING, ## 施法中
	HEALING, ## 治疗中
	BUFFING ## 增益中
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
# 英雄类型字符串常量
# ============================================================================

# 英雄单位类型
const KNIGHT = "knight"
const ARCHER = "archer"
const MAGE = "mage"
const PALADIN = "paladin"
const BERSERKER = "berserker"
const ARCHMAGE = "archmage"
const PRIEST = "priest"
const RANGER = "ranger"
const DRAGON_KNIGHT = "dragon_knight"
const DRUID = "druid"
const SHADOW_BLADE_MASTER = "shadow_blade_master"
const THIEF = "thief"
const ASSASSIN = "assassin"
const ENGINEER = "engineer"

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	name = "HeroesTypes"
	LogManager.info("HeroesTypes - 英雄类型常量已初始化")

# ============================================================================
# 工具函数
# ============================================================================

## 获取英雄类型名称（中文）
static func get_hero_name(hero_type: String) -> String:
	match hero_type:
		KNIGHT:
			return "骑士"
		ARCHER:
			return "弓箭手"
		MAGE:
			return "法师"
		PALADIN:
			return "圣骑士"
		BERSERKER:
			return "狂战士"
		ARCHMAGE:
			return "大法师"
		PRIEST:
			return "牧师"
		RANGER:
			return "游侠"
		DRAGON_KNIGHT:
			return "龙骑士"
		DRUID:
			return "德鲁伊"
		SHADOW_BLADE_MASTER:
			return "暗影剑圣"
		THIEF:
			return "盗贼"
		ASSASSIN:
			return "刺客"
		ENGINEER:
			return "工程师"
		_:
			return "未知英雄"

## 检查是否是英雄单位
static func is_hero(hero_type: String) -> bool:
	return hero_type in [
		KNIGHT, ARCHER, MAGE, PALADIN, BERSERKER, ARCHMAGE,
		PRIEST, RANGER, DRAGON_KNIGHT, DRUID, SHADOW_BLADE_MASTER,
		THIEF, ASSASSIN, ENGINEER
	]

## 获取英雄分类
static func get_hero_category(hero_type: String) -> String:
	if is_hero(hero_type):
		return "hero"
	else:
		return "unknown"

## 获取英雄图标（用于UI显示）
static func get_hero_icon(hero_type: String) -> String:
	match hero_type:
		KNIGHT:
			return "🛡️"
		ARCHER:
			return "🏹"
		MAGE:
			return "🔮"
		PALADIN:
			return "⚜️"
		BERSERKER:
			return "💪"
		ARCHMAGE:
			return "🌟"
		PRIEST:
			return "✝️"
		RANGER:
			return "🏹"
		DRAGON_KNIGHT:
			return "🐲"
		DRUID:
			return "🍃"
		SHADOW_BLADE_MASTER:
			return "🗡️"
		THIEF:
			return "🥷"
		ASSASSIN:
			return "🔪"
		ENGINEER:
			return "🔧"
		_:
			return "❓"

## 获取所有英雄单位类型
static func get_all_hero_types() -> Array[String]:
	return [
		KNIGHT, ARCHER, MAGE, PALADIN, BERSERKER, ARCHMAGE,
		PRIEST, RANGER, DRAGON_KNIGHT, DRUID, SHADOW_BLADE_MASTER,
		THIEF, ASSASSIN, ENGINEER
	]

## 获取英雄阵营
static func get_hero_faction(_hero_type: String) -> String:
	return "HEROES" # 所有英雄都属于英雄阵营

## 检查是否为战斗单位
static func is_combat_hero(hero_type: String) -> bool:
	return is_hero(hero_type) and hero_type != ENGINEER

## 检查是否为魔法单位
static func is_magic_hero(hero_type: String) -> bool:
	return hero_type in [MAGE, ARCHMAGE, PRIEST, DRUID, SHADOW_BLADE_MASTER]

## 检查是否为近战单位
static func is_melee_hero(hero_type: String) -> bool:
	return hero_type in [KNIGHT, PALADIN, BERSERKER, DRAGON_KNIGHT, THIEF, ASSASSIN, SHADOW_BLADE_MASTER]

## 检查是否为远程单位
static func is_ranged_hero(hero_type: String) -> bool:
	return hero_type in [ARCHER, MAGE, ARCHMAGE, PRIEST, RANGER, DRUID]

# ============================================================================
# 向后兼容函数
# ============================================================================

## 获取角色类型名称（向后兼容）
static func get_character_name(character_type: String) -> String:
	return get_hero_name(character_type)

## 获取角色图标（向后兼容）
static func get_character_icon(character_type: String) -> String:
	return get_hero_icon(character_type)

## 检查是否是英雄单位（向后兼容）
static func is_hero_unit(character_type: String) -> bool:
	return is_hero(character_type)

## 获取角色分类（向后兼容）
static func get_character_category(character_type: String) -> String:
	return get_hero_category(character_type)
