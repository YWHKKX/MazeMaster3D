extends Node

## 🐾 野兽类型定义 - 生态系统野兽管理
## 定义所有生态系统中可能出现的野兽类型

# ============================================================================
# 野兽类型枚举
# ============================================================================

enum BeastType {
	# 森林野兽
	DEER, # 鹿
	FOREST_WOLF, # 森林狼
	SHADOW_TIGER, # 影刃虎
	CLAW_BEAR, # 巨爪熊
	
	# 草地野兽
	RABBIT, # 野兔
	GRASSLAND_WOLF, # 草原狼
	RHINO_BEAST, # 犀角兽
	
	# 湖泊野兽
	WATER_GRASS_FISH, # 水草鱼
	PLANKTON, # 浮游生物
	FISH, # 鱼
	WATER_SNAKE, # 水蛇
	FISH_MAN, # 鱼人
	WATER_BIRD, # 水鸟
	LAKE_MONSTER, # 湖怪
	
	# 洞穴野兽
	GIANT_RAT, # 巨鼠
	POISON_SCORPION, # 毒刺蝎
	STONE_BEETLE, # 石甲虫
	SHADOW_SPIDER, # 暗影蜘蛛
	CAVE_BAT, # 洞穴蝙蝠
	
	# 荒地野兽
	GIANT_LIZARD, # 巨蜥
	RADIOACTIVE_SCORPION, # 辐射蝎
	SANDSTORM_WOLF, # 沙暴狼
	MUTANT_RAT, # 变异老鼠
	CORRUPTED_WORM, # 腐化蠕虫
	
	# 死地野兽
	SHADOW_WOLF, # 暗影魔狼
	CORRUPTED_BOAR, # 腐化野猪
	MAGIC_VULTURE, # 魔化秃鹫
	HELLHOUND, # 地狱犬
	SHADOW_PANTHER, # 暗影魔豹
	ABYSS_DRAGON, # 深渊魔龙
	SKELETON, # 骷髅
	ZOMBIE, # 僵尸
	DEMON, # 恶魔
	SHADOW_BEAST, # 暗影兽
	CLAW_HUNTER_BEAST, # 利爪猎兽
	
	# 原始野兽
	HORN_SHIELD_DRAGON, # 角盾龙
	SPINE_BACK_DRAGON, # 棘背龙
	SCALE_ARMOR_DRAGON, # 鳞甲龙
	CLAW_HUNTER_DRAGON, # 利爪龙
	RAGE_DRAGON, # 暴怒龙
	RAGE_BEAST, # 暴怒兽
	SHADOW_DRAGON, # 暗影龙
	DRAGON_BLOOD_BEAST, # 龙血兽
	ANCIENT_DRAGON_OVERLORD # 古龙霸主
}

# ============================================================================
# 野兽数据结构
# ============================================================================

class BeastSpawn:
	var beast_type: BeastType
	var position: Vector3
	var level: int
	var is_hostile: bool
	var respawn_time: float
	var is_active: bool = true
	var last_spawned: float = 0.0
	
	func _init(type: BeastType, pos: Vector3, lvl: int, hostile: bool, respawn: float = 0.0):
		beast_type = type
		position = pos
		level = lvl
		is_hostile = hostile
		respawn_time = respawn

# ============================================================================
# 生态野兽配置
# ============================================================================

## 森林野兽配置
const FOREST_BEASTS = {
	BeastType.DEER: {"probability": 0.6, "level_range": [1, 3], "hostile": false, "respawn_time": 600.0},
	BeastType.FOREST_WOLF: {"probability": 0.3, "level_range": [2, 4], "hostile": false, "respawn_time": 800.0},
	BeastType.SHADOW_TIGER: {"probability": 0.08, "level_range": [4, 6], "hostile": false, "respawn_time": 1200.0},
	BeastType.CLAW_BEAR: {"probability": 0.02, "level_range": [5, 7], "hostile": false, "respawn_time": 1500.0}
}

## 草地野兽配置
const GRASSLAND_BEASTS = {
	BeastType.RABBIT: {"probability": 0.7, "level_range": [1, 2], "hostile": false, "respawn_time": 300.0},
	BeastType.GRASSLAND_WOLF: {"probability": 0.25, "level_range": [2, 4], "hostile": false, "respawn_time": 800.0},
	BeastType.RHINO_BEAST: {"probability": 0.05, "level_range": [4, 6], "hostile": false, "respawn_time": 1000.0}
}

## 湖泊野兽配置
const LAKE_BEASTS = {
	BeastType.WATER_GRASS_FISH: {"probability": 0.4, "level_range": [1, 2], "hostile": false, "respawn_time": 400.0},
	BeastType.PLANKTON: {"probability": 0.3, "level_range": [1, 1], "hostile": false, "respawn_time": 200.0},
	BeastType.FISH: {"probability": 0.2, "level_range": [1, 3], "hostile": false, "respawn_time": 500.0},
	BeastType.WATER_SNAKE: {"probability": 0.05, "level_range": [3, 5], "hostile": false, "respawn_time": 900.0},
	BeastType.FISH_MAN: {"probability": 0.03, "level_range": [4, 6], "hostile": false, "respawn_time": 1200.0},
	BeastType.WATER_BIRD: {"probability": 0.015, "level_range": [3, 5], "hostile": false, "respawn_time": 1000.0},
	BeastType.LAKE_MONSTER: {"probability": 0.005, "level_range": [6, 8], "hostile": false, "respawn_time": 2000.0}
}

## 洞穴野兽配置
const CAVE_BEASTS = {
	BeastType.GIANT_RAT: {"probability": 0.5, "level_range": [1, 3], "hostile": false, "respawn_time": 400.0},
	BeastType.POISON_SCORPION: {"probability": 0.25, "level_range": [2, 4], "hostile": false, "respawn_time": 600.0},
	BeastType.STONE_BEETLE: {"probability": 0.15, "level_range": [2, 4], "hostile": false, "respawn_time": 700.0},
	BeastType.SHADOW_SPIDER: {"probability": 0.08, "level_range": [3, 5], "hostile": false, "respawn_time": 1000.0},
	BeastType.CAVE_BAT: {"probability": 0.02, "level_range": [2, 4], "hostile": false, "respawn_time": 800.0}
}

## 荒地野兽配置
const WASTELAND_BEASTS = {
	BeastType.GIANT_LIZARD: {"probability": 0.1, "level_range": [4, 6], "hostile": false, "respawn_time": 1500.0},
	BeastType.RADIOACTIVE_SCORPION: {"probability": 0.3, "level_range": [2, 4], "hostile": false, "respawn_time": 800.0},
	BeastType.SANDSTORM_WOLF: {"probability": 0.25, "level_range": [3, 5], "hostile": false, "respawn_time": 1000.0},
	BeastType.MUTANT_RAT: {"probability": 0.3, "level_range": [1, 3], "hostile": false, "respawn_time": 500.0},
	BeastType.CORRUPTED_WORM: {"probability": 0.05, "level_range": [2, 4], "hostile": false, "respawn_time": 600.0}
}

## 死地野兽配置
const DEAD_LAND_BEASTS = {
	BeastType.SHADOW_WOLF: {"probability": 0.4, "level_range": [3, 5], "hostile": false, "respawn_time": 1000.0},
	BeastType.CORRUPTED_BOAR: {"probability": 0.25, "level_range": [4, 6], "hostile": false, "respawn_time": 1200.0},
	BeastType.MAGIC_VULTURE: {"probability": 0.15, "level_range": [4, 6], "hostile": false, "respawn_time": 1500.0},
	BeastType.HELLHOUND: {"probability": 0.15, "level_range": [5, 7], "hostile": false, "respawn_time": 1800.0},
	BeastType.SHADOW_PANTHER: {"probability": 0.04, "level_range": [6, 8], "hostile": false, "respawn_time": 2000.0},
	BeastType.ABYSS_DRAGON: {"probability": 0.01, "level_range": [8, 10], "hostile": false, "respawn_time": 3000.0}
}

## 原始野兽配置
const PRIMITIVE_BEASTS = {
	BeastType.HORN_SHIELD_DRAGON: {"probability": 0.3, "level_range": [3, 5], "hostile": false, "respawn_time": 1200.0},
	BeastType.SPINE_BACK_DRAGON: {"probability": 0.3, "level_range": [3, 5], "hostile": false, "respawn_time": 1200.0},
	BeastType.SCALE_ARMOR_DRAGON: {"probability": 0.2, "level_range": [4, 6], "hostile": false, "respawn_time": 1500.0},
	BeastType.CLAW_HUNTER_DRAGON: {"probability": 0.15, "level_range": [4, 6], "hostile": false, "respawn_time": 1500.0},
	BeastType.RAGE_DRAGON: {"probability": 0.03, "level_range": [6, 8], "hostile": false, "respawn_time": 2000.0},
	BeastType.SHADOW_DRAGON: {"probability": 0.015, "level_range": [6, 8], "hostile": false, "respawn_time": 2000.0},
	BeastType.DRAGON_BLOOD_BEAST: {"probability": 0.004, "level_range": [8, 10], "hostile": false, "respawn_time": 3000.0},
	BeastType.ANCIENT_DRAGON_OVERLORD: {"probability": 0.001, "level_range": [10, 12], "hostile": false, "respawn_time": 5000.0}
}

# ============================================================================
# 工具函数
# ============================================================================

static func get_beast_name(beast_type: BeastType) -> String:
	"""获取野兽名称"""
	match beast_type:
		# 森林野兽
		BeastType.DEER: return "鹿"
		BeastType.FOREST_WOLF: return "森林狼"
		BeastType.SHADOW_TIGER: return "影刃虎"
		BeastType.CLAW_BEAR: return "巨爪熊"
		
		# 草地野兽
		BeastType.RABBIT: return "野兔"
		BeastType.GRASSLAND_WOLF: return "草原狼"
		BeastType.RHINO_BEAST: return "犀角兽"
		
		# 湖泊野兽
		BeastType.WATER_GRASS_FISH: return "水草鱼"
		BeastType.PLANKTON: return "浮游生物"
		BeastType.FISH: return "鱼"
		BeastType.WATER_SNAKE: return "水蛇"
		BeastType.FISH_MAN: return "鱼人"
		BeastType.WATER_BIRD: return "水鸟"
		BeastType.LAKE_MONSTER: return "湖怪"
		
		# 洞穴野兽
		BeastType.GIANT_RAT: return "巨鼠"
		BeastType.POISON_SCORPION: return "毒刺蝎"
		BeastType.STONE_BEETLE: return "石甲虫"
		BeastType.SHADOW_SPIDER: return "暗影蜘蛛"
		BeastType.CAVE_BAT: return "洞穴蝙蝠"
		
		# 荒地野兽
		BeastType.GIANT_LIZARD: return "巨蜥"
		BeastType.RADIOACTIVE_SCORPION: return "辐射蝎"
		BeastType.SANDSTORM_WOLF: return "沙暴狼"
		BeastType.MUTANT_RAT: return "变异老鼠"
		BeastType.CORRUPTED_WORM: return "腐化蠕虫"
		
		# 死地野兽
		BeastType.SHADOW_WOLF: return "暗影魔狼"
		BeastType.CORRUPTED_BOAR: return "腐化野猪"
		BeastType.MAGIC_VULTURE: return "魔化秃鹫"
		BeastType.HELLHOUND: return "地狱犬"
		BeastType.SHADOW_PANTHER: return "暗影魔豹"
		BeastType.ABYSS_DRAGON: return "深渊魔龙"
		BeastType.SKELETON: return "骷髅"
		BeastType.ZOMBIE: return "僵尸"
		BeastType.DEMON: return "恶魔"
		BeastType.SHADOW_BEAST: return "暗影兽"
		BeastType.CLAW_HUNTER_BEAST: return "利爪猎兽"
		
		# 原始野兽
		BeastType.HORN_SHIELD_DRAGON: return "角盾龙"
		BeastType.SPINE_BACK_DRAGON: return "棘背龙"
		BeastType.SCALE_ARMOR_DRAGON: return "鳞甲龙"
		BeastType.CLAW_HUNTER_DRAGON: return "利爪龙"
		BeastType.RAGE_DRAGON: return "暴怒龙"
		BeastType.RAGE_BEAST: return "暴怒兽"
		BeastType.SHADOW_DRAGON: return "暗影龙"
		BeastType.DRAGON_BLOOD_BEAST: return "龙血兽"
		BeastType.ANCIENT_DRAGON_OVERLORD: return "古龙霸主"
		_: return "未知野兽"

static func get_beast_icon(beast_type: BeastType) -> String:
	"""获取野兽图标路径"""
	return "res://assets/icons/beasts/" + get_beast_name(beast_type) + ".png"

static func get_ecosystem_beasts(ecosystem_type: String) -> Dictionary:
	"""根据生态系统类型获取野兽配置"""
	match ecosystem_type:
		"FOREST": return FOREST_BEASTS
		"GRASSLAND": return GRASSLAND_BEASTS
		"LAKE": return LAKE_BEASTS
		"CAVE": return CAVE_BEASTS
		"WASTELAND": return WASTELAND_BEASTS
		"DEAD_LAND": return DEAD_LAND_BEASTS
		"PRIMITIVE": return PRIMITIVE_BEASTS
		_: return {}

static func is_beast_creature(beast_type: BeastType) -> bool:
	"""检查是否为野兽类型（所有生态系统生物都是野兽）"""
	return true # 所有生态系统生物都属于野兽阵营

static func get_beast_faction(beast_type: BeastType) -> String:
	"""获取野兽阵营"""
	return "BEAST" # 所有生态系统生物都属于野兽阵营

# ============================================================================
# 兼容性函数（向后兼容）
# ============================================================================

# 为了向后兼容，保留一些旧的函数名
static func get_creature_name(creature_type: BeastType) -> String:
	"""获取生物名称（向后兼容）"""
	return get_beast_name(creature_type)

static func get_creature_icon(creature_type: BeastType) -> String:
	"""获取生物图标路径（向后兼容）"""
	return get_beast_icon(creature_type)

static func get_ecosystem_creatures(ecosystem_type: String) -> Dictionary:
	"""根据生态系统类型获取生物配置（向后兼容）"""
	return get_ecosystem_beasts(ecosystem_type)
