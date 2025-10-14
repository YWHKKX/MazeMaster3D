extends Node

## CharacterTypes - 角色类型常量（Autoload单例）
## 
## 统一管理角色类型字符串常量，避免拼写错误

# ============================================================================
# 后勤单位类型
# ============================================================================

const GOBLIN_WORKER = "goblin_worker"
const GOBLIN_ENGINEER = "goblin_engineer"

# ============================================================================
# 怪物单位类型
# ============================================================================

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
# 英雄单位类型
# ============================================================================

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

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	name = "CharacterTypes"
	LogManager.info("CharacterTypes - 角色类型常量已初始化")

# ============================================================================
# 工具函数
# ============================================================================

## 获取角色类型名称（中文）
static func get_character_name(character_type: String) -> String:
	match character_type:
		# 后勤单位
		GOBLIN_WORKER:
			return "哥布林苦工"
		GOBLIN_ENGINEER:
			return "地精工程师"
		
		# 怪物单位
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
		
		# 英雄单位
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
		_:
			return "未知角色"

## 检查是否是后勤单位
static func is_logistics_unit(character_type: String) -> bool:
	return character_type in [GOBLIN_WORKER, GOBLIN_ENGINEER]

## 检查是否是怪物单位
static func is_monster(character_type: String) -> bool:
	return character_type in [
		IMP, ORC_WARRIOR, GARGOYLE, FIRE_LIZARD, SHADOW_MAGE,
		HELLHOUND, TREANT, SUCCUBUS, SHADOW_LORD, STONE_GOLEM, BONE_DRAGON
	]

## 检查是否是英雄单位
static func is_hero(character_type: String) -> bool:
	return character_type in [
		KNIGHT, ARCHER, MAGE, PALADIN, BERSERKER, ARCHMAGE,
		PRIEST, RANGER, DRAGON_KNIGHT, DRUID, SHADOW_BLADE_MASTER,
		THIEF, ASSASSIN
	]

## 检查是否是战斗单位
static func is_combat_unit(character_type: String) -> bool:
	return is_monster(character_type) or is_hero(character_type)

## 获取角色分类
static func get_character_category(character_type: String) -> String:
	if is_logistics_unit(character_type):
		return "logistics"
	elif is_monster(character_type):
		return "monster"
	elif is_hero(character_type):
		return "hero"
	else:
		return "unknown"

## 获取角色图标（用于UI显示）
static func get_character_icon(character_type: String) -> String:
	match character_type:
		# 后勤单位
		GOBLIN_WORKER:
			return "👷"
		GOBLIN_ENGINEER:
			return "🔧"
		
		# 怪物单位
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
		
		# 英雄单位
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
		_:
			return "❓"

## 获取所有后勤单位类型
static func get_all_logistics_types() -> Array[String]:
	return [GOBLIN_WORKER, GOBLIN_ENGINEER]

## 获取所有怪物单位类型
static func get_all_monster_types() -> Array[String]:
	return [
		IMP, ORC_WARRIOR, GARGOYLE, FIRE_LIZARD, SHADOW_MAGE,
		HELLHOUND, TREANT, SUCCUBUS, SHADOW_LORD, STONE_GOLEM, BONE_DRAGON
	]

## 获取所有英雄单位类型
static func get_all_hero_types() -> Array[String]:
	return [
		KNIGHT, ARCHER, MAGE, PALADIN, BERSERKER, ARCHMAGE,
		PRIEST, RANGER, DRAGON_KNIGHT, DRUID, SHADOW_BLADE_MASTER,
		THIEF, ASSASSIN
	]
