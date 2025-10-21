extends Node

## 🌿 资源类型定义 - 生态系统资源管理
## 定义所有生态系统中可能出现的资源类型

# ============================================================================
# 资源类型枚举
# ============================================================================

enum ResourceType {
	# 基础资源
	WOOD, # 木材
	FOOD, # 食物
	WATER, # 水
	STONE, # 石头
	
	# 植物资源
	BERRY, # 浆果
	HERB, # 草药
	MUSHROOM, # 蘑菇
	AQUATIC_PLANT, # 水产植物
	CROP, # 耕地作物
	CORRUPTED_PLANT, # 腐化植物
	
	# 矿物资源
	IRON_ORE, # 铁矿
	GOLD_ORE, # 金矿
	GEM, # 宝石
	RARE_MINERAL, # 稀有矿物
	
	# 魔法资源
	MAGIC_CRYSTAL, # 魔法水晶
	ESSENCE, # 精华
	SOUL_STONE, # 灵魂石
	DEMON_CORE, # 魔化核心
	CURSED_GEM, # 诅咒宝石
	DEATH_FLOWER, # 死灵花
	
	# 原始资源
	PRIMITIVE_PLANT, # 原始植物
	PREHISTORIC_MINERAL, # 史前矿物
	FOSSIL, # 化石
	AMBER, # 琥珀
	PRIMITIVE_CRYSTAL, # 原始水晶
	DRAGON_BLOOD_STONE, # 龙血石
	ANCIENT_DRAGON_SCALE # 古龙鳞片
}

# ============================================================================
# 资源数据结构
# ============================================================================

class ResourceSpawn:
	var resource_type: ResourceType
	var position: Vector3
	var amount: int
	var respawn_time: float
	var is_active: bool = true
	var last_harvested: float = 0.0
	
	func _init(type: ResourceType, pos: Vector3, amt: int, respawn: float = 0.0):
		resource_type = type
		position = pos
		amount = amt
		respawn_time = respawn

# ============================================================================
# 生态资源配置
# ============================================================================

## 森林资源配置
const FOREST_RESOURCES = {
	ResourceType.WOOD: {"probability": 0.8, "amount_range": [10, 50], "respawn_time": 300.0},
	ResourceType.BERRY: {"probability": 0.6, "amount_range": [5, 20], "respawn_time": 180.0},
	ResourceType.HERB: {"probability": 0.4, "amount_range": [3, 15], "respawn_time": 240.0}
}

## 草地资源配置
const GRASSLAND_RESOURCES = {
	ResourceType.FOOD: {"probability": 0.5, "amount_range": [8, 25], "respawn_time": 200.0},
	ResourceType.HERB: {"probability": 0.4, "amount_range": [2, 10], "respawn_time": 300.0},
	ResourceType.CROP: {"probability": 0.6, "amount_range": [5, 20], "respawn_time": 400.0}
}

## 湖泊资源配置
const LAKE_RESOURCES = {
	ResourceType.WATER: {"probability": 1.0, "amount_range": [20, 100], "respawn_time": 0.0},
	ResourceType.FOOD: {"probability": 0.6, "amount_range": [5, 30], "respawn_time": 360.0}, # 鱼类
	ResourceType.AQUATIC_PLANT: {"probability": 0.4, "amount_range": [3, 12], "respawn_time": 480.0}
}

## 洞穴资源配置
const CAVE_RESOURCES = {
	ResourceType.IRON_ORE: {"probability": 0.7, "amount_range": [15, 40], "respawn_time": 600.0},
	ResourceType.GOLD_ORE: {"probability": 0.3, "amount_range": [5, 20], "respawn_time": 900.0},
	ResourceType.GEM: {"probability": 0.2, "amount_range": [1, 5], "respawn_time": 1200.0},
	ResourceType.MUSHROOM: {"probability": 0.5, "amount_range": [3, 15], "respawn_time": 300.0}
}

## 荒地资源配置
const WASTELAND_RESOURCES = {
	ResourceType.RARE_MINERAL: {"probability": 0.3, "amount_range": [2, 8], "respawn_time": 1800.0},
	ResourceType.STONE: {"probability": 0.4, "amount_range": [10, 30], "respawn_time": 600.0},
	ResourceType.CORRUPTED_PLANT: {"probability": 0.5, "amount_range": [3, 12], "respawn_time": 800.0}
}

## 死地资源配置
const DEAD_LAND_RESOURCES = {
	ResourceType.MAGIC_CRYSTAL: {"probability": 0.2, "amount_range": [3, 12], "respawn_time": 2400.0},
	ResourceType.ESSENCE: {"probability": 0.15, "amount_range": [1, 6], "respawn_time": 3600.0},
	ResourceType.SOUL_STONE: {"probability": 0.15, "amount_range": [1, 3], "respawn_time": 7200.0},
	ResourceType.DEMON_CORE: {"probability": 0.1, "amount_range": [1, 2], "respawn_time": 14400.0},
	ResourceType.CURSED_GEM: {"probability": 0.2, "amount_range": [1, 2], "respawn_time": 10800.0},
	ResourceType.DEATH_FLOWER: {"probability": 0.2, "amount_range": [1, 1], "respawn_time": 18000.0}
}

## 原始资源配置
const PRIMITIVE_RESOURCES = {
	ResourceType.PRIMITIVE_PLANT: {"probability": 0.3, "amount_range": [5, 15], "respawn_time": 600.0},
	ResourceType.PREHISTORIC_MINERAL: {"probability": 0.25, "amount_range": [3, 10], "respawn_time": 800.0},
	ResourceType.FOSSIL: {"probability": 0.2, "amount_range": [1, 3], "respawn_time": 1000.0},
	ResourceType.AMBER: {"probability": 0.15, "amount_range": [1, 2], "respawn_time": 1200.0},
	ResourceType.PRIMITIVE_CRYSTAL: {"probability": 0.08, "amount_range": [1, 2], "respawn_time": 1500.0},
	ResourceType.DRAGON_BLOOD_STONE: {"probability": 0.015, "amount_range": [1, 1], "respawn_time": 3000.0},
	ResourceType.ANCIENT_DRAGON_SCALE: {"probability": 0.005, "amount_range": [1, 1], "respawn_time": 5000.0}
}

# ============================================================================
# 工具函数
# ============================================================================

static func get_resource_name(resource_type: ResourceType) -> String:
	"""获取资源类型名称"""
	match resource_type:
		ResourceType.WOOD: return "木材"
		ResourceType.FOOD: return "食物"
		ResourceType.WATER: return "水"
		ResourceType.STONE: return "石头"
		ResourceType.BERRY: return "浆果"
		ResourceType.HERB: return "草药"
		ResourceType.MUSHROOM: return "蘑菇"
		ResourceType.AQUATIC_PLANT: return "水产植物"
		ResourceType.CROP: return "耕地作物"
		ResourceType.CORRUPTED_PLANT: return "腐化植物"
		ResourceType.IRON_ORE: return "铁矿"
		ResourceType.GOLD_ORE: return "金矿"
		ResourceType.GEM: return "宝石"
		ResourceType.RARE_MINERAL: return "稀有矿物"
		ResourceType.MAGIC_CRYSTAL: return "魔法水晶"
		ResourceType.ESSENCE: return "精华"
		ResourceType.SOUL_STONE: return "灵魂石"
		ResourceType.DEMON_CORE: return "恶魔核心"
		ResourceType.CURSED_GEM: return "诅咒宝石"
		ResourceType.DEATH_FLOWER: return "死灵花"
		_: return "未知资源"

static func get_resource_icon(resource_type: ResourceType) -> String:
	"""获取资源图标"""
	match resource_type:
		ResourceType.WOOD: return "📦" # 使用箱子替代木材
		ResourceType.FOOD: return "🍖"
		ResourceType.WATER: return "💧"
		ResourceType.STONE: return "🔳" # 使用方块替代石头
		ResourceType.BERRY: return "🫐"
		ResourceType.HERB: return "🌿"
		ResourceType.MUSHROOM: return "🍄"
		ResourceType.AQUATIC_PLANT: return "🌊"
		ResourceType.CROP: return "🌾"
		ResourceType.CORRUPTED_PLANT: return "🌱"
		ResourceType.IRON_ORE: return "⛏️"
		ResourceType.GOLD_ORE: return "💰"
		ResourceType.GEM: return "💎"
		ResourceType.RARE_MINERAL: return "🔮"
		ResourceType.MAGIC_CRYSTAL: return "✨"
		ResourceType.ESSENCE: return "🌟"
		ResourceType.SOUL_STONE: return "💀"
		ResourceType.DEMON_CORE: return "👹"
		ResourceType.CURSED_GEM: return "💀"
		ResourceType.DEATH_FLOWER: return "🌹"
		_: return "❓"

static func get_ecosystem_resources(ecosystem_type: int) -> Dictionary:
	"""根据生态类型获取资源配置"""
	match ecosystem_type:
		0: return FOREST_RESOURCES # FOREST
		1: return GRASSLAND_RESOURCES # GRASSLAND
		2: return LAKE_RESOURCES # LAKE
		3: return CAVE_RESOURCES # CAVE
		4: return WASTELAND_RESOURCES # WASTELAND
		5: return DEAD_LAND_RESOURCES # DEAD_LAND
		6: return PRIMITIVE_RESOURCES # PRIMITIVE
		_: return {}
