extends Node

## TileTypes - 瓦片类型常量（Autoload单例）
## 
## 统一管理地图瓦片类型枚举值，消除魔法数字

# ============================================================================
# 瓦片类型枚举
# ============================================================================

# ============================================================================
# 瓦片类型枚举 - 按功能分类
# ============================================================================

# 基础瓦片类型
enum TileType {
	# 基础地形
	EMPTY = 0, ## 空地（未开发）
	STONE_FLOOR = 1, ## 石头地板（已挖掘）
	STONE_WALL = 2, ## 石头墙壁（不可挖掘）
	DIRT_FLOOR = 3, ## 泥土地板
	MAGIC_FLOOR = 4, ## 魔法地板
	UNEXCAVATED = 5, ## 未挖掘区域
	CORRIDOR = 6, ## 走廊
	
	# 资源类型
	GOLD_MINE = 7, ## 金矿
	MANA_CRYSTAL = 8, ## 魔力水晶
	
	# 特殊地形
	LAVA = 9, ## 岩浆
	WATER = 10, ## 水域
	BRIDGE = 11, ## 桥梁
	PORTAL = 12, ## 传送门
	TRAP = 13, ## 陷阱
	SECRET_PASSAGE = 14, ## 秘密通道
	
	# 建筑类型
	DUNGEON_HEART = 15, ## 地牢之心瓦片
	BARRACKS = 16, ## 兵营
	WORKSHOP = 17, ## 工坊
	MAGIC_LAB = 18, ## 魔法实验室
	DEFENSE_TOWER = 19, ## 防御塔
	FOOD_FARM = 20, ## 食物农场
	
	# 生态系统类型
	FOREST = 21, ## 森林
	WASTELAND = 22, ## 荒地
	SWAMP = 23, ## 沼泽
	CAVE = 24, ## 洞穴
	
	# 空洞系统类型
	CAVITY_EMPTY = 25, ## 空洞空地
	CAVITY_BOUNDARY = 26, ## 空洞边界
	CAVITY_CENTER = 27, ## 空洞中心
	CAVITY_ENTRANCE = 28, ## 空洞入口
	
	# 生态系统特殊地块类型
	# 森林生态系统地块
	FOREST_CLEARING = 29, ## 森林空地
	DENSE_FOREST = 30, ## 茂密森林
	FOREST_EDGE = 31, ## 森林边缘
	ANCIENT_FOREST = 32, ## 古树区域
	
	# 草地生态系统地块
	GRASSLAND_PLAINS = 33, ## 草原平原
	GRASSLAND_HILLS = 34, ## 草原丘陵
	GRASSLAND_WETLANDS = 35, ## 草原湿地
	GRASSLAND_FIELDS = 36, ## 草原农田
	
	# 湖泊生态系统地块
	LAKE_SHALLOW = 37, ## 浅水区
	LAKE_DEEP = 38, ## 深水区
	LAKE_SHORE = 39, ## 湖岸
	LAKE_ISLAND = 40, ## 湖心岛
	
	# 洞穴生态系统地块
	CAVE_DEEP = 41, ## 深洞
	CAVE_CRYSTAL = 42, ## 水晶洞
	CAVE_UNDERGROUND_LAKE = 43, ## 地下湖
	
	# 荒地生态系统地块
	WASTELAND_DESERT = 44, ## 荒地沙漠
	WASTELAND_ROCKS = 45, ## 荒地岩石
	WASTELAND_RUINS = 46, ## 荒地废墟
	WASTELAND_TOXIC = 47, ## 荒地毒区
	
	# 死地生态系统地块
	DEAD_LAND_SWAMP = 48, ## 死亡沼泽
	DEAD_LAND_GRAVEYARD = 49, ## 墓地
	
	# 原始生态系统地块
	PRIMITIVE_JUNGLE = 50, ## 原始丛林
	PRIMITIVE_VOLCANO = 51, ## 原始火山
	PRIMITIVE_SWAMP = 52 ## 原始沼泽
}

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
		TileType.EMPTY:
			return "空地"
		TileType.STONE_FLOOR:
			return "石头地板"
		TileType.STONE_WALL:
			return "石头墙壁"
		TileType.DIRT_FLOOR:
			return "泥土地板"
		TileType.MAGIC_FLOOR:
			return "魔法地板"
		TileType.UNEXCAVATED:
			return "未挖掘"
		TileType.GOLD_MINE:
			return "金矿"
		TileType.MANA_CRYSTAL:
			return "魔力水晶"
		TileType.CORRIDOR:
			return "走廊"
		TileType.DUNGEON_HEART:
			return "地牢之心"
		TileType.LAVA:
			return "岩浆"
		TileType.WATER:
			return "水域"
		TileType.BRIDGE:
			return "桥梁"
		TileType.PORTAL:
			return "传送门"
		TileType.TRAP:
			return "陷阱"
		TileType.SECRET_PASSAGE:
			return "秘密通道"
		TileType.BARRACKS:
			return "兵营"
		TileType.WORKSHOP:
			return "工坊"
		TileType.MAGIC_LAB:
			return "魔法实验室"
		TileType.DEFENSE_TOWER:
			return "防御塔"
		TileType.FOOD_FARM:
			return "食物农场"
		TileType.FOREST:
			return "森林"
		TileType.WASTELAND:
			return "荒地"
		TileType.SWAMP:
			return "沼泽"
		TileType.CAVE:
			return "洞穴"
		TileType.CAVITY_EMPTY:
			return "空洞空地"
		TileType.CAVITY_BOUNDARY:
			return "空洞边界"
		TileType.CAVITY_CENTER:
			return "空洞中心"
		TileType.CAVITY_ENTRANCE:
			return "空洞入口"
		# 森林生态系统地块
		TileType.FOREST_CLEARING:
			return "森林空地"
		TileType.DENSE_FOREST:
			return "茂密森林"
		TileType.FOREST_EDGE:
			return "森林边缘"
		TileType.ANCIENT_FOREST:
			return "古树区域"
		# 草地生态系统地块
		TileType.GRASSLAND_PLAINS:
			return "草原平原"
		TileType.GRASSLAND_HILLS:
			return "草原丘陵"
		TileType.GRASSLAND_WETLANDS:
			return "草原湿地"
		TileType.GRASSLAND_FIELDS:
			return "草原农田"
		# 湖泊生态系统地块
		TileType.LAKE_SHALLOW:
			return "浅水区"
		TileType.LAKE_DEEP:
			return "深水区"
		TileType.LAKE_SHORE:
			return "湖岸"
		TileType.LAKE_ISLAND:
			return "湖心岛"
		# 洞穴生态系统地块
		TileType.CAVE_DEEP:
			return "深洞"
		TileType.CAVE_CRYSTAL:
			return "水晶洞"
		TileType.CAVE_UNDERGROUND_LAKE:
			return "地下湖"
		# 荒地生态系统地块
		TileType.WASTELAND_DESERT:
			return "荒地沙漠"
		TileType.WASTELAND_ROCKS:
			return "荒地岩石"
		TileType.WASTELAND_RUINS:
			return "荒地废墟"
		TileType.WASTELAND_TOXIC:
			return "荒地毒区"
		# 死地生态系统地块
		TileType.DEAD_LAND_SWAMP:
			return "死亡沼泽"
		TileType.DEAD_LAND_GRAVEYARD:
			return "墓地"
		# 原始生态系统地块
		TileType.PRIMITIVE_JUNGLE:
			return "原始丛林"
		TileType.PRIMITIVE_VOLCANO:
			return "原始火山"
		TileType.PRIMITIVE_SWAMP:
			return "原始沼泽"
		_:
			return "未知类型"

## 检查瓦片是否可行走
static func is_walkable(tile_type: int) -> bool:
	"""检查瓦片是否可以行走"""
	return tile_type in [
		TileType.EMPTY, TileType.STONE_FLOOR, TileType.DIRT_FLOOR, TileType.MAGIC_FLOOR, TileType.CORRIDOR,
		TileType.GOLD_MINE, TileType.BRIDGE, TileType.DUNGEON_HEART, TileType.SECRET_PASSAGE, TileType.TRAP,
		TileType.FOREST, TileType.WASTELAND, TileType.SWAMP, TileType.CAVE,
		TileType.CAVITY_EMPTY, TileType.CAVITY_CENTER, TileType.CAVITY_ENTRANCE,
		# 森林生态系统地块
		TileType.FOREST_CLEARING, TileType.DENSE_FOREST, TileType.FOREST_EDGE, TileType.ANCIENT_FOREST,
		# 草地生态系统地块
		TileType.GRASSLAND_PLAINS, TileType.GRASSLAND_HILLS, TileType.GRASSLAND_WETLANDS, TileType.GRASSLAND_FIELDS,
		# 湖泊生态系统地块（浅水区和湖岸可行走）
		TileType.LAKE_SHALLOW, TileType.LAKE_SHORE, TileType.LAKE_ISLAND,
		# 洞穴生态系统地块
		TileType.CAVE_DEEP, TileType.CAVE_CRYSTAL, TileType.CAVE_UNDERGROUND_LAKE,
		# 荒地生态系统地块
		TileType.WASTELAND_DESERT, TileType.WASTELAND_ROCKS, TileType.WASTELAND_RUINS, TileType.WASTELAND_TOXIC,
		# 死地生态系统地块
		TileType.DEAD_LAND_SWAMP, TileType.DEAD_LAND_GRAVEYARD,
		# 原始生态系统地块
		TileType.PRIMITIVE_JUNGLE, TileType.PRIMITIVE_VOLCANO, TileType.PRIMITIVE_SWAMP
	]

## 检查瓦片是否可挖掘
static func is_diggable(tile_type: int) -> bool:
	"""检查瓦片是否可以挖掘"""
	return tile_type in [TileType.UNEXCAVATED]

## 检查瓦片是否是资源点
static func is_resource(tile_type: int) -> bool:
	"""检查瓦片是否是资源点"""
	return tile_type in [TileType.GOLD_MINE, TileType.MANA_CRYSTAL]

## 检查瓦片是否是固体（阻挡移动）
static func is_solid(tile_type: int) -> bool:
	"""检查瓦片是否是固体（阻挡移动）"""
	return tile_type in [TileType.STONE_WALL, TileType.UNEXCAVATED, TileType.LAVA]

## 检查瓦片是否是地板类型
static func is_floor(tile_type: int) -> bool:
	"""检查瓦片是否是地板类型"""
	return tile_type in [TileType.STONE_FLOOR, TileType.DIRT_FLOOR, TileType.MAGIC_FLOOR]

## 获取瓦片颜色（用于可视化）
static func get_tile_color(tile_type: int) -> Color:
	match tile_type:
		TileType.EMPTY:
			return Color(0.1, 0.1, 0.1) # 深灰
		TileType.STONE_FLOOR:
			return Color(0.5, 0.5, 0.5) # 灰色
		TileType.STONE_WALL:
			return Color(0.3, 0.3, 0.3) # 深灰
		TileType.DIRT_FLOOR:
			return Color(0.4, 0.3, 0.2) # 棕色
		TileType.MAGIC_FLOOR:
			return Color(0.5, 0.3, 0.8) # 紫色
		TileType.UNEXCAVATED:
			return Color(0.2, 0.2, 0.2) # 黑灰
		TileType.GOLD_MINE:
			return Color(1.0, 0.84, 0.0) # 金色
		TileType.MANA_CRYSTAL:
			return Color(0.0, 0.5, 1.0) # 蓝色
		TileType.CORRIDOR:
			return Color(0.6, 0.6, 0.6) # 浅灰
		TileType.DUNGEON_HEART:
			return Color(0.8, 0.1, 0.1) # 红色
		TileType.LAVA:
			return Color(1.0, 0.3, 0.0) # 橙红
		TileType.WATER:
			return Color(0.2, 0.4, 0.8) # 水蓝
		TileType.BRIDGE:
			return Color(0.6, 0.4, 0.2) # 木色
		TileType.PORTAL:
			return Color(0.5, 0.0, 0.8) # 紫色
		TileType.TRAP:
			return Color(0.5, 0.5, 0.0) # 黄色
		TileType.SECRET_PASSAGE:
			return Color(0.3, 0.3, 0.3) # 深灰
		TileType.BARRACKS:
			return Color(0.6, 0.4, 0.2) # 棕色
		TileType.WORKSHOP:
			return Color(0.4, 0.4, 0.4) # 灰色
		TileType.MAGIC_LAB:
			return Color(0.5, 0.3, 0.8) # 紫色
		TileType.DEFENSE_TOWER:
			return Color(0.7, 0.7, 0.7) # 浅灰
		TileType.FOOD_FARM:
			return Color(0.3, 0.7, 0.3) # 绿色
		# 森林生态系统地块
		TileType.FOREST_CLEARING:
			return Color(0.4, 0.7, 0.4) # 浅绿色
		TileType.DENSE_FOREST:
			return Color(0.1, 0.4, 0.1) # 深绿色
		TileType.FOREST_EDGE:
			return Color(0.5, 0.6, 0.3) # 黄绿色
		TileType.ANCIENT_FOREST:
			return Color(0.0, 0.3, 0.0) # 墨绿色
		# 草地生态系统地块
		TileType.GRASSLAND_PLAINS:
			return Color(0.6, 0.8, 0.4) # 草绿色
		TileType.GRASSLAND_HILLS:
			return Color(0.5, 0.6, 0.3) # 丘陵绿
		TileType.GRASSLAND_WETLANDS:
			return Color(0.3, 0.6, 0.5) # 湿地绿
		TileType.GRASSLAND_FIELDS:
			return Color(0.7, 0.8, 0.3) # 农田黄绿
		# 湖泊生态系统地块
		TileType.LAKE_SHALLOW:
			return Color(0.2, 0.6, 0.8) # 浅蓝色
		TileType.LAKE_DEEP:
			return Color(0.0, 0.3, 0.6) # 深蓝色
		TileType.LAKE_SHORE:
			return Color(0.6, 0.5, 0.3) # 湖岸棕色
		TileType.LAKE_ISLAND:
			return Color(0.4, 0.6, 0.3) # 岛屿绿色
		# 洞穴生态系统地块
		TileType.CAVE_DEEP:
			return Color(0.2, 0.2, 0.2) # 深洞极深灰
		TileType.CAVE_CRYSTAL:
			return Color(0.6, 0.4, 0.8) # 水晶紫
		TileType.CAVE_UNDERGROUND_LAKE:
			return Color(0.1, 0.3, 0.6) # 地下湖深蓝
		# 荒地生态系统地块
		TileType.WASTELAND_DESERT:
			return Color(0.8, 0.7, 0.4) # 沙漠黄
		TileType.WASTELAND_ROCKS:
			return Color(0.5, 0.5, 0.4) # 岩石灰
		TileType.WASTELAND_RUINS:
			return Color(0.4, 0.3, 0.2) # 废墟棕
		TileType.WASTELAND_TOXIC:
			return Color(0.6, 0.8, 0.2) # 毒绿
		# 死地生态系统地块
		TileType.DEAD_LAND_SWAMP:
			return Color(0.2, 0.4, 0.2) # 死亡沼泽深绿
		TileType.DEAD_LAND_GRAVEYARD:
			return Color(0.3, 0.3, 0.2) # 墓地灰
		# 原始生态系统地块
		TileType.PRIMITIVE_JUNGLE:
			return Color(0.2, 0.5, 0.2) # 丛林绿
		TileType.PRIMITIVE_VOLCANO:
			return Color(0.6, 0.2, 0.1) # 火山红
		TileType.PRIMITIVE_SWAMP:
			return Color(0.3, 0.4, 0.2) # 沼泽绿
		_:
			return Color(1.0, 0.0, 1.0) # 品红（错误）

## 获取瓦片图标（用于UI显示）
static func get_tile_icon(tile_type: int) -> String:
	match tile_type:
		TileType.EMPTY:
			return "⬛"
		TileType.STONE_FLOOR:
			return "⬜"
		TileType.STONE_WALL:
			return "🧱"
		TileType.DIRT_FLOOR:
			return "🟫"
		TileType.MAGIC_FLOOR:
			return "🟪"
		TileType.UNEXCAVATED:
			return "⚫"
		TileType.GOLD_MINE:
			return "💰"
		TileType.MANA_CRYSTAL:
			return "💎"
		TileType.CORRIDOR:
			return "➖"
		TileType.DUNGEON_HEART:
			return "❤️"
		TileType.LAVA:
			return "🔥"
		TileType.WATER:
			return "💧"
		TileType.BRIDGE:
			return "🌉"
		TileType.PORTAL:
			return "🌀"
		TileType.TRAP:
			return "⚠️"
		TileType.SECRET_PASSAGE:
			return "🚪"
		TileType.BARRACKS:
			return "🏰"
		TileType.WORKSHOP:
			return "🔨"
		TileType.MAGIC_LAB:
			return "🧪"
		TileType.DEFENSE_TOWER:
			return "🗼"
		TileType.FOOD_FARM:
			return "🌾"
		# 森林生态系统地块
		TileType.FOREST_CLEARING:
			return "🌲"
		TileType.DENSE_FOREST:
			return "🌳"
		TileType.FOREST_EDGE:
			return "🌿"
		TileType.ANCIENT_FOREST:
			return "🌲"
		# 草地生态系统地块
		TileType.GRASSLAND_PLAINS:
			return "🌱"
		TileType.GRASSLAND_HILLS:
			return "⛰️"
		TileType.GRASSLAND_WETLANDS:
			return "🌊"
		TileType.GRASSLAND_FIELDS:
			return "🌾"
		# 湖泊生态系统地块
		TileType.LAKE_SHALLOW:
			return "🏞️"
		TileType.LAKE_DEEP:
			return "🌊"
		TileType.LAKE_SHORE:
			return "🏖️"
		TileType.LAKE_ISLAND:
			return "🏝️"
		# 洞穴生态系统地块
		TileType.CAVE_DEEP:
			return "⛏️"
		TileType.CAVE_CRYSTAL:
			return "💎"
		TileType.CAVE_UNDERGROUND_LAKE:
			return "🌊"
		# 荒地生态系统地块
		TileType.WASTELAND_DESERT:
			return "🏜️"
		TileType.WASTELAND_ROCKS:
			return "🗻"
		TileType.WASTELAND_RUINS:
			return "🏚️"
		TileType.WASTELAND_TOXIC:
			return "☢️"
		# 死地生态系统地块
		TileType.DEAD_LAND_SWAMP:
			return "🐊"
		TileType.DEAD_LAND_GRAVEYARD:
			return "⚰️"
		# 原始生态系统地块
		TileType.PRIMITIVE_JUNGLE:
			return "🦕"
		TileType.PRIMITIVE_VOLCANO:
			return "🌋"
		TileType.PRIMITIVE_SWAMP:
			return "🐊"
		_:
			return "❓"

## 获取瓦片对应的网格名称（用于渲染系统）
static func get_mesh_name(tile_type: int) -> String:
	"""获取瓦片对应的网格名称"""
	match tile_type:
		TileType.EMPTY:
			return "floor_empty"
		TileType.STONE_FLOOR, TileType.DIRT_FLOOR, TileType.MAGIC_FLOOR, TileType.CORRIDOR, TileType.SECRET_PASSAGE, TileType.TRAP:
			return "floor_thin"
		TileType.STONE_WALL, TileType.UNEXCAVATED, TileType.GOLD_MINE:
			return "cube_full"
		TileType.MANA_CRYSTAL:
			return "cube_crystal"
		TileType.BARRACKS, TileType.WORKSHOP, TileType.MAGIC_LAB, TileType.FOOD_FARM:
			return "cube_half"
		TileType.DEFENSE_TOWER:
			return "cube_tower"
		TileType.DUNGEON_HEART:
			return "cube_heart"
		# 森林生态系统地块
		TileType.FOREST_CLEARING, TileType.DENSE_FOREST, TileType.FOREST_EDGE, TileType.ANCIENT_FOREST:
			return "floor_forest"
		# 草地生态系统地块
		TileType.GRASSLAND_PLAINS, TileType.GRASSLAND_HILLS, TileType.GRASSLAND_WETLANDS, TileType.GRASSLAND_FIELDS:
			return "floor_grassland"
		# 湖泊生态系统地块
		TileType.LAKE_SHALLOW, TileType.LAKE_DEEP, TileType.LAKE_SHORE, TileType.LAKE_ISLAND:
			return "floor_water"
		# 洞穴生态系统地块
		TileType.CAVE_DEEP, TileType.CAVE_CRYSTAL, TileType.CAVE_UNDERGROUND_LAKE:
			return "floor_cave"
		# 荒地生态系统地块
		TileType.WASTELAND_DESERT, TileType.WASTELAND_ROCKS, TileType.WASTELAND_RUINS, TileType.WASTELAND_TOXIC:
			return "floor_wasteland"
		# 死地生态系统地块
		TileType.DEAD_LAND_SWAMP, TileType.DEAD_LAND_GRAVEYARD:
			return "floor_deadland"
		# 原始生态系统地块
		TileType.PRIMITIVE_JUNGLE, TileType.PRIMITIVE_VOLCANO, TileType.PRIMITIVE_SWAMP:
			return "floor_primitive"
		_:
			return "floor_thin" # 默认网格

## 获取瓦片对应的材质名称（用于渲染系统）
static func get_material_name(tile_type: int) -> String:
	"""获取瓦片对应的材质名称"""
	match tile_type:
		TileType.EMPTY:
			return "empty"
		TileType.STONE_FLOOR:
			return "stone_floor"
		TileType.DIRT_FLOOR:
			return "dirt_floor"
		TileType.MAGIC_FLOOR:
			return "magic_floor"
		TileType.CORRIDOR:
			return "corridor"
		TileType.STONE_WALL:
			return "stone_wall"
		TileType.UNEXCAVATED:
			return "unexcavated"
		TileType.GOLD_MINE:
			return "gold_mine"
		TileType.MANA_CRYSTAL:
			return "mana_crystal"
		TileType.BARRACKS:
			return "building"
		TileType.WORKSHOP:
			return "workshop"
		TileType.MAGIC_LAB:
			return "magic_lab"
		TileType.DEFENSE_TOWER:
			return "defense_tower"
		TileType.FOOD_FARM:
			return "food_farm"
		TileType.DUNGEON_HEART:
			return "dungeon_heart"
		TileType.TRAP:
			return "trap"
		TileType.SECRET_PASSAGE:
			return "secret_passage"
		# 森林生态系统地块
		TileType.FOREST_CLEARING:
			return "forest_clearing"
		TileType.DENSE_FOREST:
			return "dense_forest"
		TileType.FOREST_EDGE:
			return "forest_edge"
		TileType.ANCIENT_FOREST:
			return "ancient_forest"
		# 草地生态系统地块
		TileType.GRASSLAND_PLAINS:
			return "grassland_plains"
		TileType.GRASSLAND_HILLS:
			return "grassland_hills"
		TileType.GRASSLAND_WETLANDS:
			return "grassland_wetlands"
		TileType.GRASSLAND_FIELDS:
			return "grassland_fields"
		# 湖泊生态系统地块
		TileType.LAKE_SHALLOW:
			return "lake_shallow"
		TileType.LAKE_DEEP:
			return "lake_deep"
		TileType.LAKE_SHORE:
			return "lake_shore"
		TileType.LAKE_ISLAND:
			return "lake_island"
		# 洞穴生态系统地块
		TileType.CAVE_DEEP:
			return "cave_deep"
		TileType.CAVE_CRYSTAL:
			return "cave_crystal"
		TileType.CAVE_UNDERGROUND_LAKE:
			return "cave_underground_lake"
		# 荒地生态系统地块
		TileType.WASTELAND_DESERT:
			return "wasteland_desert"
		TileType.WASTELAND_ROCKS:
			return "wasteland_rocks"
		TileType.WASTELAND_RUINS:
			return "wasteland_ruins"
		TileType.WASTELAND_TOXIC:
			return "wasteland_toxic"
		# 死地生态系统地块
		TileType.DEAD_LAND_SWAMP:
			return "deadland_swamp"
		TileType.DEAD_LAND_GRAVEYARD:
			return "deadland_graveyard"
		# 原始生态系统地块
		TileType.PRIMITIVE_JUNGLE:
			return "primitive_jungle"
		TileType.PRIMITIVE_VOLCANO:
			return "primitive_volcano"
		TileType.PRIMITIVE_SWAMP:
			return "primitive_swamp"
		_:
			return "stone_floor" # 默认材质

## 房间生成相关工具函数
static func get_min_room_size() -> int:
	"""获取最小房间尺寸"""
	return 3

static func get_max_room_size() -> int:
	"""获取最大房间尺寸"""
	return 8

static func get_max_overlap_floors() -> int:
	"""获取最大重叠地板数量"""
	return 5

static func get_directions() -> Dictionary:
	"""获取方向常量"""
	return {
		"right": Vector3i.RIGHT,
		"bottom": Vector3i.BACK,
		"left": Vector3i.LEFT,
		"top": Vector3i.FORWARD,
	}

static func get_room_tile_mapping() -> Dictionary:
	"""获取房间瓦片类型映射"""
	return {
		"floor": TileType.STONE_FLOOR,
		"normalWall": TileType.STONE_WALL,
		"cornerWall": TileType.STONE_WALL,
		"doorWay": TileType.CORRIDOR,
		"normalWallOffSet": TileType.STONE_WALL
	}
