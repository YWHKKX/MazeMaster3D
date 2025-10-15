extends Node

## 🐾 生物类型定义 - 生态系统生物管理
## 定义所有生态系统中可能出现的生物类型

# ============================================================================
# 生物类型枚举
# ============================================================================

enum CreatureType {
	# 森林生物
	DEER,           # 鹿
	FOREST_WOLF,    # 森林狼
	
	# 草地生物
	RABBIT,         # 野兔
	GRASSLAND_WOLF, # 草原狼
	RHINO_BEAST,    # 犀角兽
	
	# 湖泊生物
	FISH,           # 鱼
	FISH_MAN,       # 鱼人
	
	# 洞穴生物
	GIANT_RAT,      # 巨鼠
	
	# 荒地生物
	GIANT_LIZARD,   # 巨蜥
	
	# 死地生物
	SKELETON,       # 骷髅
	ZOMBIE,         # 僵尸
	DEMON,          # 恶魔
	SHADOW_BEAST    # 暗影兽
}

# ============================================================================
# 生物数据结构
# ============================================================================

class CreatureSpawn:
	var creature_type: CreatureType
	var position: Vector3
	var level: int
	var is_hostile: bool
	var respawn_time: float
	var is_active: bool = true
	var last_spawned: float = 0.0
	
	func _init(type: CreatureType, pos: Vector3, lvl: int, hostile: bool, respawn: float = 0.0):
		creature_type = type
		position = pos
		level = lvl
		is_hostile = hostile
		respawn_time = respawn

# ============================================================================
# 生态生物配置
# ============================================================================

## 森林生物配置
const FOREST_CREATURES = {
	CreatureType.DEER: {"probability": 0.6, "level_range": [1, 3], "hostile": false, "respawn_time": 600.0},
	CreatureType.FOREST_WOLF: {"probability": 0.3, "level_range": [2, 4], "hostile": true, "respawn_time": 900.0}
}

## 草地生物配置
const GRASSLAND_CREATURES = {
	CreatureType.RABBIT: {"probability": 0.7, "level_range": [1, 2], "hostile": false, "respawn_time": 300.0},
	CreatureType.GRASSLAND_WOLF: {"probability": 0.4, "level_range": [2, 3], "hostile": true, "respawn_time": 720.0},
	CreatureType.RHINO_BEAST: {"probability": 0.1, "level_range": [4, 6], "hostile": true, "respawn_time": 1800.0}
}

## 湖泊生物配置
const LAKE_CREATURES = {
	CreatureType.FISH: {"probability": 0.8, "level_range": [1, 2], "hostile": false, "respawn_time": 240.0},
	CreatureType.FISH_MAN: {"probability": 0.2, "level_range": [3, 5], "hostile": true, "respawn_time": 1200.0}
}

## 洞穴生物配置
const CAVE_CREATURES = {
	CreatureType.GIANT_RAT: {"probability": 0.8, "level_range": [1, 3], "hostile": true, "respawn_time": 480.0}
}

## 荒地生物配置
const WASTELAND_CREATURES = {
	CreatureType.GIANT_LIZARD: {"probability": 0.5, "level_range": [3, 5], "hostile": true, "respawn_time": 1500.0}
}

## 死地生物配置
const DEAD_LAND_CREATURES = {
	CreatureType.SKELETON: {"probability": 0.6, "level_range": [2, 4], "hostile": true, "respawn_time": 600.0},
	CreatureType.ZOMBIE: {"probability": 0.4, "level_range": [3, 5], "hostile": true, "respawn_time": 900.0},
	CreatureType.DEMON: {"probability": 0.2, "level_range": [5, 8], "hostile": true, "respawn_time": 3600.0},
	CreatureType.SHADOW_BEAST: {"probability": 0.1, "level_range": [6, 10], "hostile": true, "respawn_time": 7200.0}
}

# ============================================================================
# 工具函数
# ============================================================================

static func get_creature_name(creature_type: CreatureType) -> String:
	"""获取生物类型名称"""
	match creature_type:
		CreatureType.DEER: return "鹿"
		CreatureType.FOREST_WOLF: return "森林狼"
		CreatureType.RABBIT: return "野兔"
		CreatureType.GRASSLAND_WOLF: return "草原狼"
		CreatureType.RHINO_BEAST: return "犀角兽"
		CreatureType.FISH: return "鱼"
		CreatureType.FISH_MAN: return "鱼人"
		CreatureType.GIANT_RAT: return "巨鼠"
		CreatureType.GIANT_LIZARD: return "巨蜥"
		CreatureType.SKELETON: return "骷髅"
		CreatureType.ZOMBIE: return "僵尸"
		CreatureType.DEMON: return "恶魔"
		CreatureType.SHADOW_BEAST: return "暗影兽"
		_: return "未知生物"

static func get_creature_icon(creature_type: CreatureType) -> String:
	"""获取生物图标"""
	match creature_type:
		CreatureType.DEER: return "🦌"
		CreatureType.FOREST_WOLF: return "🐺"
		CreatureType.RABBIT: return "🐰"
		CreatureType.GRASSLAND_WOLF: return "🐺"
		CreatureType.RHINO_BEAST: return "🦏"
		CreatureType.FISH: return "🐟"
		CreatureType.FISH_MAN: return "🐠"
		CreatureType.GIANT_RAT: return "🐀"
		CreatureType.GIANT_LIZARD: return "🦎"
		CreatureType.SKELETON: return "💀"
		CreatureType.ZOMBIE: return "🧟"
		CreatureType.DEMON: return "👹"
		CreatureType.SHADOW_BEAST: return "👤"
		_: return "❓"

static func get_ecosystem_creatures(ecosystem_type: int) -> Dictionary:
	"""根据生态类型获取生物配置"""
	match ecosystem_type:
		0: return FOREST_CREATURES    # FOREST
		1: return GRASSLAND_CREATURES # GRASSLAND
		2: return LAKE_CREATURES      # LAKE
		3: return CAVE_CREATURES      # CAVE
		4: return WASTELAND_CREATURES # WASTELAND
		5: return DEAD_LAND_CREATURES # DEAD_LAND
		_: return {}

static func get_creature_faction(creature_type: CreatureType) -> int:
	"""获取生物对应的阵营"""
	match creature_type:
		# 森林生物 - 野兽阵营（中立）
		CreatureType.DEER, CreatureType.FOREST_WOLF:
			return 3  # Enums.Faction.BEASTS
		
		# 草地生物 - 野兽阵营（中立）
		CreatureType.RABBIT, CreatureType.GRASSLAND_WOLF, CreatureType.RHINO_BEAST:
			return 3  # Enums.Faction.BEASTS
		
		# 湖泊生物 - 野兽阵营（中立）
		CreatureType.FISH, CreatureType.FISH_MAN:
			return 3  # Enums.Faction.BEASTS
		
		# 洞穴生物 - 野兽阵营（中立）
		CreatureType.GIANT_RAT:
			return 3  # Enums.Faction.BEASTS
		
		# 荒地生物 - 野兽阵营（中立）
		CreatureType.GIANT_LIZARD:
			return 3  # Enums.Faction.BEASTS
		
		# 死地生物 - 怪物阵营（敌对）
		CreatureType.SKELETON, CreatureType.ZOMBIE, CreatureType.DEMON, CreatureType.SHADOW_BEAST:
			return 1  # Enums.Faction.MONSTERS
		
		_:
			return 3  # 默认为野兽阵营

static func is_creature_hostile(creature_type: CreatureType) -> bool:
	"""检查生物是否敌对"""
	match creature_type:
		CreatureType.DEER, CreatureType.RABBIT, CreatureType.FISH:
			return false
		_:
			return true
