extends Node

## TileTypes - 瓦片类型常量（Autoload单例）
## 
## 统一管理地图瓦片类型枚举值，消除魔法数字

# ============================================================================
# 瓦片类型枚举
# ============================================================================

const EMPTY = 0 # 空地（未开发）
const STONE_FLOOR = 1 # 石头地板（已挖掘）
const STONE_WALL = 2 # 石头墙壁（不可挖掘）
const DIRT_FLOOR = 3 # 泥土地板
const MAGIC_FLOOR = 4 # 魔法地板
const UNEXCAVATED = 5 # 未挖掘区域
const GOLD_MINE = 6 # 金矿
const MANA_CRYSTAL = 7 # 魔力水晶
const CORRIDOR = 8 # 走廊
const DUNGEON_HEART = 9 # 地牢之心瓦片

# 其他特殊瓦片类型
const LAVA = 10 # 岩浆
const WATER = 11 # 水域
const BRIDGE = 12 # 桥梁
const PORTAL = 13 # 传送门
const TRAP = 14 # 陷阱

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	name = "TileTypes"
	LogManager.info("TileTypes - 瓦片类型常量已初始化")

# ============================================================================
# 工具函数
# ============================================================================

## 获取瓦片类型名称（中文）
static func get_tile_name(tile_type: int) -> String:
	match tile_type:
		EMPTY:
			return "空地"
		STONE_FLOOR:
			return "石头地板"
		STONE_WALL:
			return "石头墙壁"
		DIRT_FLOOR:
			return "泥土地板"
		MAGIC_FLOOR:
			return "魔法地板"
		UNEXCAVATED:
			return "未挖掘"
		GOLD_MINE:
			return "金矿"
		MANA_CRYSTAL:
			return "魔力水晶"
		CORRIDOR:
			return "走廊"
		DUNGEON_HEART:
			return "地牢之心"
		LAVA:
			return "岩浆"
		WATER:
			return "水域"
		BRIDGE:
			return "桥梁"
		PORTAL:
			return "传送门"
		TRAP:
			return "陷阱"
		_:
			return "未知类型"

## 获取瓦片类型名称（英文）
static func get_tile_name_en(tile_type: int) -> String:
	match tile_type:
		EMPTY:
			return "Empty"
		STONE_FLOOR:
			return "Stone Floor"
		STONE_WALL:
			return "Stone Wall"
		DIRT_FLOOR:
			return "Dirt Floor"
		MAGIC_FLOOR:
			return "Magic Floor"
		UNEXCAVATED:
			return "Unexcavated"
		GOLD_MINE:
			return "Gold Mine"
		MANA_CRYSTAL:
			return "Mana Crystal"
		CORRIDOR:
			return "Corridor"
		DUNGEON_HEART:
			return "Dungeon Heart"
		LAVA:
			return "Lava"
		WATER:
			return "Water"
		BRIDGE:
			return "Bridge"
		PORTAL:
			return "Portal"
		TRAP:
			return "Trap"
		_:
			return "Unknown"

## 检查瓦片是否可行走
static func is_walkable(tile_type: int) -> bool:
	"""检查瓦片是否可以行走"""
	return tile_type in [EMPTY, STONE_FLOOR, DIRT_FLOOR, MAGIC_FLOOR, CORRIDOR, GOLD_MINE, BRIDGE, DUNGEON_HEART]

## 检查瓦片是否可挖掘
static func is_diggable(tile_type: int) -> bool:
	"""检查瓦片是否可以挖掘"""
	return tile_type in [UNEXCAVATED, STONE_WALL]

## 检查瓦片是否是资源点
static func is_resource(tile_type: int) -> bool:
	"""检查瓦片是否是资源点"""
	return tile_type in [GOLD_MINE, MANA_CRYSTAL]

## 检查瓦片是否是固体（阻挡移动）
static func is_solid(tile_type: int) -> bool:
	"""检查瓦片是否是固体（阻挡移动）"""
	return tile_type in [STONE_WALL, UNEXCAVATED, LAVA]

## 检查瓦片是否是地板类型
static func is_floor(tile_type: int) -> bool:
	"""检查瓦片是否是地板类型"""
	return tile_type in [STONE_FLOOR, DIRT_FLOOR, MAGIC_FLOOR]

## 获取瓦片颜色（用于可视化）
static func get_tile_color(tile_type: int) -> Color:
	match tile_type:
		EMPTY:
			return Color(0.1, 0.1, 0.1) # 深灰
		STONE_FLOOR:
			return Color(0.5, 0.5, 0.5) # 灰色
		STONE_WALL:
			return Color(0.3, 0.3, 0.3) # 深灰
		DIRT_FLOOR:
			return Color(0.4, 0.3, 0.2) # 棕色
		MAGIC_FLOOR:
			return Color(0.5, 0.3, 0.8) # 紫色
		UNEXCAVATED:
			return Color(0.2, 0.2, 0.2) # 黑灰
		GOLD_MINE:
			return Color(1.0, 0.84, 0.0) # 金色
		MANA_CRYSTAL:
			return Color(0.0, 0.5, 1.0) # 蓝色
		CORRIDOR:
			return Color(0.6, 0.6, 0.6) # 浅灰
		DUNGEON_HEART:
			return Color(0.8, 0.1, 0.1) # 红色
		LAVA:
			return Color(1.0, 0.3, 0.0) # 橙红
		WATER:
			return Color(0.2, 0.4, 0.8) # 水蓝
		BRIDGE:
			return Color(0.6, 0.4, 0.2) # 木色
		PORTAL:
			return Color(0.5, 0.0, 0.8) # 紫色
		TRAP:
			return Color(0.5, 0.5, 0.0) # 黄色
		_:
			return Color(1.0, 0.0, 1.0) # 品红（错误）

## 获取瓦片图标（用于UI显示）
static func get_tile_icon(tile_type: int) -> String:
	match tile_type:
		EMPTY:
			return "⬛"
		STONE_FLOOR:
			return "⬜"
		STONE_WALL:
			return "🧱"
		DIRT_FLOOR:
			return "🟫"
		MAGIC_FLOOR:
			return "🟪"
		UNEXCAVATED:
			return "⚫"
		GOLD_MINE:
			return "💰"
		MANA_CRYSTAL:
			return "💎"
		CORRIDOR:
			return "➖"
		DUNGEON_HEART:
			return "❤️"
		LAVA:
			return "🔥"
		WATER:
			return "💧"
		BRIDGE:
			return "🌉"
		PORTAL:
			return "🌀"
		TRAP:
			return "⚠️"
		_:
			return "❓"
