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
	CAVITY_ENTRANCE = 28 ## 空洞入口
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
		_:
			return "未知类型"

## 检查瓦片是否可行走
static func is_walkable(tile_type: int) -> bool:
	"""检查瓦片是否可以行走"""
	return tile_type in [TileType.EMPTY, TileType.STONE_FLOOR, TileType.DIRT_FLOOR, TileType.MAGIC_FLOOR, TileType.CORRIDOR, TileType.GOLD_MINE, TileType.BRIDGE, TileType.DUNGEON_HEART, TileType.SECRET_PASSAGE, TileType.TRAP, TileType.FOREST, TileType.WASTELAND, TileType.SWAMP, TileType.CAVE, TileType.CAVITY_EMPTY, TileType.CAVITY_CENTER, TileType.CAVITY_ENTRANCE]

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
