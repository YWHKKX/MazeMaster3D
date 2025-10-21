extends Node

## 🏛️ 统一阵营管理器 - 集中管理所有阵营相关功能
## 提供统一的阵营枚举、关系和判断逻辑

# ============================================================================
# 阵营枚举（统一）
# ============================================================================

enum Faction {
	PLAYER = 0, ## 玩家阵营
	HEROES = 1, ## 英雄阵营（友方）
	MONSTERS = 2, ## 怪物阵营（敌对）
	BEASTS = 3, ## 野兽阵营（中立）
	NEUTRAL = 4 ## 中立阵营
}

# ============================================================================
# 阵营关系定义
# ============================================================================

# 阵营关系矩阵 [攻击者][被攻击者] = 关系类型
const FACTION_RELATIONS = {
	Faction.PLAYER: {
		Faction.PLAYER: "FRIENDLY", # 玩家对玩家：友好
		Faction.HEROES: "FRIENDLY", # 玩家对英雄：友好
		Faction.MONSTERS: "HOSTILE", # 玩家对怪物：敌对
		Faction.BEASTS: "NEUTRAL", # 玩家对野兽：中立
		Faction.NEUTRAL: "NEUTRAL" # 玩家对中立：中立
	},
	Faction.HEROES: {
		Faction.PLAYER: "FRIENDLY", # 英雄对玩家：友好
		Faction.HEROES: "FRIENDLY", # 英雄对英雄：友好
		Faction.MONSTERS: "HOSTILE", # 英雄对怪物：敌对
		Faction.BEASTS: "NEUTRAL", # 英雄对野兽：中立
		Faction.NEUTRAL: "NEUTRAL" # 英雄对中立：中立
	},
	Faction.MONSTERS: {
		Faction.PLAYER: "HOSTILE", # 怪物对玩家：敌对
		Faction.HEROES: "HOSTILE", # 怪物对英雄：敌对
		Faction.MONSTERS: "FRIENDLY", # 怪物对怪物：友好
		Faction.BEASTS: "NEUTRAL", # 怪物对野兽：中立
		Faction.NEUTRAL: "NEUTRAL" # 怪物对中立：中立
	},
	Faction.BEASTS: {
		Faction.PLAYER: "NEUTRAL", # 野兽对玩家：中立
		Faction.HEROES: "NEUTRAL", # 野兽对英雄：中立
		Faction.MONSTERS: "NEUTRAL", # 野兽对怪物：中立
		Faction.BEASTS: "FRIENDLY", # 野兽对野兽：友好
		Faction.NEUTRAL: "NEUTRAL" # 野兽对中立：中立
	},
	Faction.NEUTRAL: {
		Faction.PLAYER: "NEUTRAL", # 中立对玩家：中立
		Faction.HEROES: "NEUTRAL", # 中立对英雄：中立
		Faction.MONSTERS: "NEUTRAL", # 中立对怪物：中立
		Faction.BEASTS: "NEUTRAL", # 中立对野兽：中立
		Faction.NEUTRAL: "NEUTRAL" # 中立对中立：中立
	}
}

# ============================================================================
# 阵营名称映射
# ============================================================================

const FACTION_NAMES = {
	Faction.PLAYER: "玩家阵营",
	Faction.HEROES: "英雄阵营",
	Faction.MONSTERS: "怪物阵营",
	Faction.BEASTS: "野兽阵营",
	Faction.NEUTRAL: "中立阵营"
}

const FACTION_NAMES_EN = {
	Faction.PLAYER: "Player",
	Faction.HEROES: "Heroes",
	Faction.MONSTERS: "Monsters",
	Faction.BEASTS: "Beasts",
	Faction.NEUTRAL: "Neutral"
}

# ============================================================================
# 阵营图标映射
# ============================================================================

const FACTION_ICONS = {
	Faction.PLAYER: "👤",
	Faction.HEROES: "🛡️",
	Faction.MONSTERS: "👹",
	Faction.BEASTS: "🐾",
	Faction.NEUTRAL: "⚪"
}

# ============================================================================
# 阵营颜色映射
# ============================================================================

const FACTION_COLORS = {
	Faction.PLAYER: Color.BLUE,
	Faction.HEROES: Color.GREEN,
	Faction.MONSTERS: Color.RED,
	Faction.BEASTS: Color.ORANGE,
	Faction.NEUTRAL: Color.GRAY
}

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	name = "FactionManager"
	LogManager.info("FactionManager - 统一阵营管理器已初始化")

# ============================================================================
# 核心阵营判断函数
# ============================================================================

## 检查两个阵营是否为敌对关系
static func are_enemies(faction1: int, faction2: int) -> bool:
	if not _is_valid_faction(faction1) or not _is_valid_faction(faction2):
		return false
	
	var relation = FACTION_RELATIONS.get(faction1, {}).get(faction2, "NEUTRAL")
	return relation == "HOSTILE"

## 检查两个阵营是否为友好关系
static func are_allies(faction1: int, faction2: int) -> bool:
	if not _is_valid_faction(faction1) or not _is_valid_faction(faction2):
		return false
	
	var relation = FACTION_RELATIONS.get(faction1, {}).get(faction2, "NEUTRAL")
	return relation == "FRIENDLY"

## 检查两个阵营是否为中立关系
static func are_neutral(faction1: int, faction2: int) -> bool:
	if not _is_valid_faction(faction1) or not _is_valid_faction(faction2):
		return false
	
	var relation = FACTION_RELATIONS.get(faction1, {}).get(faction2, "NEUTRAL")
	return relation == "NEUTRAL"

## 获取两个阵营的关系类型
static func get_relation_type(faction1: int, faction2: int) -> String:
	if not _is_valid_faction(faction1) or not _is_valid_faction(faction2):
		return "UNKNOWN"
	
	return FACTION_RELATIONS.get(faction1, {}).get(faction2, "NEUTRAL")

## 检查是否应该攻击目标
static func should_attack(attacker_faction: int, target_faction: int) -> bool:
	return are_enemies(attacker_faction, target_faction)

## 检查是否应该保护目标
static func should_protect(protector_faction: int, target_faction: int) -> bool:
	return are_allies(protector_faction, target_faction)

## 检查是否应该忽略目标
static func should_ignore(observer_faction: int, target_faction: int) -> bool:
	return are_neutral(observer_faction, target_faction)

# ============================================================================
# 阵营信息获取函数
# ============================================================================

## 获取阵营名称（中文）
static func get_faction_name(faction: int) -> String:
	return FACTION_NAMES.get(faction, "未知阵营")

## 获取阵营名称（英文）
static func get_faction_name_en(faction: int) -> String:
	return FACTION_NAMES_EN.get(faction, "Unknown")

## 获取阵营图标
static func get_faction_icon(faction: int) -> String:
	return FACTION_ICONS.get(faction, "❓")

## 获取阵营颜色
static func get_faction_color(faction: int) -> Color:
	return FACTION_COLORS.get(faction, Color.WHITE)

## 获取所有阵营列表
static func get_all_factions() -> Array[int]:
	return [Faction.PLAYER, Faction.HEROES, Faction.MONSTERS, Faction.BEASTS, Faction.NEUTRAL]

## 获取所有阵营名称
static func get_all_faction_names() -> Array[String]:
	var names: Array[String] = []
	for faction in get_all_factions():
		names.append(get_faction_name(faction))
	return names

# ============================================================================
# 特殊阵营判断函数
# ============================================================================

## 检查是否为玩家阵营
static func is_player_faction(faction: int) -> bool:
	return faction == Faction.PLAYER

## 检查是否为英雄阵营
static func is_hero_faction(faction: int) -> bool:
	return faction == Faction.HEROES

## 检查是否为怪物阵营
static func is_monster_faction(faction: int) -> bool:
	return faction == Faction.MONSTERS

## 检查是否为野兽阵营
static func is_beast_faction(faction: int) -> bool:
	return faction == Faction.BEASTS

## 检查是否为中立阵营
static func is_neutral_faction(faction: int) -> bool:
	return faction == Faction.NEUTRAL

## 检查是否为战斗阵营（玩家、英雄、怪物）
static func is_combat_faction(faction: int) -> bool:
	return faction in [Faction.PLAYER, Faction.HEROES, Faction.MONSTERS]

## 检查是否为非战斗阵营（野兽、中立）
static func is_non_combat_faction(faction: int) -> bool:
	return faction in [Faction.BEASTS, Faction.NEUTRAL]

# ============================================================================
# 阵营转换函数
# ============================================================================

## 从字符串转换为阵营枚举
static func faction_from_string(faction_str: String) -> int:
	match faction_str.to_upper():
		"PLAYER": return Faction.PLAYER
		"HEROES": return Faction.HEROES
		"MONSTERS": return Faction.MONSTERS
		"BEASTS": return Faction.BEASTS
		"NEUTRAL": return Faction.NEUTRAL
		_: return Faction.NEUTRAL

## 从阵营枚举转换为字符串
static func faction_to_string(faction: int) -> String:
	return get_faction_name_en(faction)

## 从数字转换为阵营枚举
static func faction_from_int(faction_int: int) -> int:
	if faction_int in get_all_factions():
		return faction_int
	return Faction.NEUTRAL

## 从阵营枚举转换为数字
static func faction_to_int(faction: int) -> int:
	return faction

# ============================================================================
# 阵营关系查询函数
# ============================================================================

## 获取阵营的所有敌人
static func get_enemy_factions(faction: int) -> Array[int]:
	if not _is_valid_faction(faction):
		return []
	
	var enemies: Array[int] = []
	for other_faction in get_all_factions():
		if are_enemies(faction, other_faction):
			enemies.append(other_faction)
	return enemies

## 获取阵营的所有盟友
static func get_ally_factions(faction: int) -> Array[int]:
	if not _is_valid_faction(faction):
		return []
	
	var allies: Array[int] = []
	for other_faction in get_all_factions():
		if are_allies(faction, other_faction):
			allies.append(other_faction)
	return allies

## 获取阵营的所有中立阵营
static func get_neutral_factions(faction: int) -> Array[int]:
	if not _is_valid_faction(faction):
		return []
	
	var neutrals: Array[int] = []
	for other_faction in get_all_factions():
		if are_neutral(faction, other_faction):
			neutrals.append(other_faction)
	return neutrals

# ============================================================================
# 阵营行为函数
# ============================================================================

## 获取阵营的默认行为模式
static func get_faction_behavior(faction: int) -> String:
	match faction:
		Faction.PLAYER: return "AGGRESSIVE" # 玩家：主动攻击
		Faction.HEROES: return "DEFENSIVE" # 英雄：防御性
		Faction.MONSTERS: return "AGGRESSIVE" # 怪物：主动攻击
		Faction.BEASTS: return "PASSIVE" # 野兽：被动
		Faction.NEUTRAL: return "PASSIVE" # 中立：被动
		_: return "PASSIVE"

## 获取阵营的移动模式
static func get_faction_movement(faction: int) -> String:
	match faction:
		Faction.PLAYER: return "CONTROLLED" # 玩家：受控制
		Faction.HEROES: return "PATROL" # 英雄：巡逻
		Faction.MONSTERS: return "WANDER" # 怪物：游荡
		Faction.BEASTS: return "WANDER" # 野兽：游荡
		Faction.NEUTRAL: return "STATIC" # 中立：静止
		_: return "STATIC"

## 获取阵营的AI模式
static func get_faction_ai_mode(faction: int) -> String:
	match faction:
		Faction.PLAYER: return "MANUAL" # 玩家：手动控制
		Faction.HEROES: return "SMART" # 英雄：智能AI
		Faction.MONSTERS: return "AGGRESSIVE" # 怪物：攻击性AI
		Faction.BEASTS: return "PASSIVE" # 野兽：被动AI
		Faction.NEUTRAL: return "NONE" # 中立：无AI
		_: return "NONE"

# ============================================================================
# 工具函数
# ============================================================================

## 验证阵营是否有效
static func _is_valid_faction(faction: int) -> bool:
	return faction in get_all_factions()

## 获取阵营的详细描述
static func get_faction_description(faction: int) -> String:
	match faction:
		Faction.PLAYER:
			return "玩家阵营 - 由玩家直接控制的单位"
		Faction.HEROES:
			return "英雄阵营 - 友方单位，会保护玩家和攻击怪物"
		Faction.MONSTERS:
			return "怪物阵营 - 敌对单位，会攻击玩家和英雄"
		Faction.BEASTS:
			return "野兽阵营 - 中立单位，不会主动攻击但可能反击"
		Faction.NEUTRAL:
			return "中立阵营 - 完全中立的单位"
		_:
			return "未知阵营"

## 获取阵营的优先级（用于AI决策）
static func get_faction_priority(faction: int) -> int:
	match faction:
		Faction.PLAYER: return 100 # 最高优先级
		Faction.HEROES: return 80 # 高优先级
		Faction.MONSTERS: return 60 # 中等优先级
		Faction.BEASTS: return 20 # 低优先级
		Faction.NEUTRAL: return 10 # 最低优先级
		_: return 0

# ============================================================================
# 调试函数
# ============================================================================

## 打印所有阵营信息
static func print_all_factions():
	print("=== 阵营信息 ===")
	for faction in get_all_factions():
		print("%s (%s): %s" % [get_faction_name(faction), get_faction_name_en(faction), get_faction_description(faction)])

## 打印阵营关系矩阵
static func print_faction_relations():
	print("=== 阵营关系矩阵 ===")
	for attacker in get_all_factions():
		for target in get_all_factions():
			var relation = get_relation_type(attacker, target)
			print("%s -> %s: %s" % [get_faction_name(attacker), get_faction_name(target), relation])

## 获取阵营统计信息
static func get_faction_stats() -> Dictionary:
	var stats = {
		"total_factions": get_all_factions().size(),
		"combat_factions": 0,
		"non_combat_factions": 0,
		"faction_relations": {}
	}
	
	for faction in get_all_factions():
		if is_combat_faction(faction):
			stats.combat_factions += 1
		else:
			stats.non_combat_factions += 1
		
		stats.faction_relations[get_faction_name(faction)] = {
			"enemies": get_enemy_factions(faction).size(),
			"allies": get_ally_factions(faction).size(),
			"neutrals": get_neutral_factions(faction).size()
		}
	
	return stats
