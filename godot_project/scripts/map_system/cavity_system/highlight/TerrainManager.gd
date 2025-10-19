extends Node
class_name TerrainManager

## 🗺️ 地形管理器
## 基于空洞系统管理10种地形类型，提供地形查询和高亮功能

# ============================================================================
# 地形类型定义
# ============================================================================

enum TerrainType {
	ROOM_SYSTEM, # 房间系统
	MAZE_SYSTEM, # 迷宫系统
	FOREST, # 森林
	GRASSLAND, # 草地
	LAKE, # 湖泊
	CAVE, # 洞穴
	WASTELAND, # 荒地
	SWAMP, # 沼泽
	DEAD_LAND # 死地
	# 注意：HERO_CAMP 已移除，英雄营地现在作为建筑物系统
}

# ============================================================================
# 地形数据结构
# ============================================================================

class TerrainRegion:
	var terrain_type: TerrainType
	var center: Vector2i
	var cavity_id: String
	var positions: Array[Vector3] = []
	var highlight_color: Color
	
	func _init(type: TerrainType, center_pos: Vector2i, cavity: String):
		terrain_type = type
		center = center_pos
		cavity_id = cavity
		highlight_color = TerrainManager._get_color_for_terrain_type_static(type)
	

# ============================================================================
# 属性
# ============================================================================

var terrain_regions: Dictionary = {} # cavity_id -> TerrainRegion
var terrain_by_type: Dictionary = {} # TerrainType -> Array[TerrainRegion]
var cavity_manager: Node = null

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	"""初始化地形管理器"""
	name = "TerrainManager"
	LogManager.info("TerrainManager - 地形管理器已初始化")
	_get_system_references()

func _get_system_references():
	"""获取系统引用"""
	# 尝试从 MapGenerator 中获取 CavityManager
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_node("MapGenerator/CavityManager"):
		cavity_manager = main_scene.get_node("MapGenerator/CavityManager")
		LogManager.info("TerrainManager - 成功获取 CavityManager 引用")
	else:
		LogManager.warning("TerrainManager - 未找到 CavityManager")
		if main_scene:
			LogManager.info("  - 主场景子节点: %s" % str(main_scene.get_children().map(func(child): return child.name)))
			if main_scene.has_node("MapGenerator"):
				var map_gen = main_scene.get_node("MapGenerator")
				LogManager.info("  - MapGenerator 子节点: %s" % str(map_gen.get_children().map(func(child): return child.name)))

# ============================================================================
# 地形注册
# ============================================================================

func register_terrain_from_cavity(cavity_id: String) -> bool:
	"""从空洞注册地形"""
	
	# 如果 CavityManager 未初始化，尝试重新获取引用
	if not cavity_manager:
		LogManager.info("TerrainManager - CavityManager 未初始化，尝试重新获取引用...")
		_get_system_references()
	
	if not cavity_manager:
		LogManager.warning("TerrainManager - CavityManager 未初始化")
		return false
	
	var cavity = cavity_manager.get_cavity_by_id(cavity_id)
	if not cavity:
		LogManager.warning("TerrainManager - 未找到空洞: %s" % cavity_id)
		return false
	
	
	# 将空洞的 content_type 映射到地形类型
	var terrain_type = _map_content_type_to_terrain(cavity.content_type)
	if terrain_type == -2:
		# 特殊建筑类型，跳过处理
		return true
	elif terrain_type == -1:
		LogManager.warning("TerrainManager - 未知的地形类型: %s" % cavity.content_type)
		return false
	
	
	# 创建地形区域
	var terrain_region = TerrainRegion.new(terrain_type, cavity.center, cavity_id)
	terrain_region.positions = cavity.positions.duplicate()
	
	# 注册地形
	terrain_regions[cavity_id] = terrain_region
	
	# 按类型分组
	if not terrain_by_type.has(terrain_type):
		terrain_by_type[terrain_type] = [] as Array[TerrainRegion]
	terrain_by_type[terrain_type].append(terrain_region)
	
	LogManager.info("TerrainManager - 成功注册地形: %s (%s) 中心: %s, 位置数: %d" % [cavity_id, _get_terrain_type_name(terrain_type), cavity.center, terrain_region.positions.size()])
	return true

func _map_content_type_to_terrain(content_type: String) -> int:
	"""将空洞内容类型映射到地形类型"""
	match content_type:
		"ROOM_SYSTEM":
			return TerrainType.ROOM_SYSTEM
		"MAZE_SYSTEM":
			return TerrainType.MAZE_SYSTEM
		"FOREST":
			return TerrainType.FOREST
		"GRASSLAND":
			return TerrainType.GRASSLAND
		"LAKE":
			return TerrainType.LAKE
		"CAVE":
			return TerrainType.CAVE
		"WASTELAND":
			return TerrainType.WASTELAND
		"SWAMP":
			return TerrainType.SWAMP
		"DEAD_LAND":
			return TerrainType.DEAD_LAND
		# 特殊建筑类型，不作为地形处理
		"DUNGEON_HEART", "PORTAL":
			return -2 # 特殊标记，表示跳过
		_:
			return -1 # 未知类型

# ============================================================================
# 地形查询
# ============================================================================

func get_terrain_regions_by_type(terrain_type: TerrainType) -> Array[TerrainRegion]:
	"""根据地形类型获取地形区域"""
	return terrain_by_type.get(terrain_type, [] as Array[TerrainRegion])

func get_terrain_region_by_cavity_id(cavity_id: String) -> TerrainRegion:
	"""根据空洞ID获取地形区域"""
	return terrain_regions.get(cavity_id, null)

func get_terrain_type_at_position(pos: Vector3) -> TerrainType:
	"""获取指定位置的地形类型"""
	for region in terrain_regions.values():
		if pos in region.positions:
			return region.terrain_type
	return TerrainType.ROOM_SYSTEM # 默认返回房间系统

func get_terrain_center_positions() -> Dictionary:
	"""获取所有地形类型的中心坐标"""
	var centers = {}
	for terrain_type in TerrainType.values():
		centers[terrain_type] = []
		var regions = get_terrain_regions_by_type(terrain_type)
		for region in regions:
			centers[terrain_type].append(region.center)
	return centers

# ============================================================================
# 洪水填充高亮
# ============================================================================

func get_terrain_highlight_data() -> Dictionary:
	"""获取地形高亮数据，用于洪水填充高亮"""
	var highlight_data = {}
	
	for terrain_type in TerrainType.values():
		var regions = get_terrain_regions_by_type(terrain_type)
		if regions.size() > 0:
			highlight_data[terrain_type] = {
				"centers": [],
				"positions": [],
				"color": regions[0].highlight_color
			}
			
			for region in regions:
				highlight_data[terrain_type].centers.append(region.center)
				highlight_data[terrain_type].positions.append_array(region.positions)
	
	return highlight_data

# ============================================================================
# 统计信息
# ============================================================================

func get_terrain_statistics() -> Dictionary:
	"""获取地形统计信息"""
	var stats = {
		"total_regions": terrain_regions.size(),
		"terrain_counts": {},
		"terrain_centers": get_terrain_center_positions()
	}
	
	for terrain_type in TerrainType.values():
		var count = terrain_by_type.get(terrain_type, []).size()
		stats.terrain_counts[terrain_type] = count
	
	return stats

func _get_color_for_terrain_type(type: TerrainType) -> Color:
	"""🔧 [统一数据源] 获取地形类型颜色"""
	return _get_color_for_terrain_type_static(type)

static func _get_color_for_terrain_type_static(type: TerrainType) -> Color:
	"""🔧 [静态方法] 获取地形类型颜色 - 供TerrainRegion类使用"""
	match type:
		TerrainType.ROOM_SYSTEM:
			return Color(0.8, 0.8, 0.8, 0.8) # 灰色
		TerrainType.MAZE_SYSTEM:
			return Color(0.5, 0.5, 0.5, 0.8) # 深灰
		TerrainType.FOREST:
			return Color(0.2, 0.8, 0.2, 0.8) # 绿色
		TerrainType.GRASSLAND:
			return Color(0.6, 0.9, 0.6, 0.8) # 浅绿
		TerrainType.LAKE:
			return Color(0.2, 0.6, 1.0, 0.8) # 蓝色
		TerrainType.CAVE:
			return Color(0.4, 0.2, 0.4, 0.8) # 紫色
		TerrainType.WASTELAND:
			return Color(0.8, 0.6, 0.2, 0.8) # 橙色
		TerrainType.SWAMP:
			return Color(0.4, 0.6, 0.2, 0.8) # 黄绿
		TerrainType.DEAD_LAND:
			return Color(0.3, 0.3, 0.3, 0.8) # 深灰
		_:
			return Color.WHITE

func _get_terrain_type_name(terrain_type: TerrainType) -> String:
	"""获取地形类型名称"""
	match terrain_type:
		TerrainType.ROOM_SYSTEM:
			return "房间"
		TerrainType.MAZE_SYSTEM:
			return "迷宫"
		TerrainType.FOREST:
			return "森林"
		TerrainType.GRASSLAND:
			return "草地"
		TerrainType.LAKE:
			return "湖泊"
		TerrainType.CAVE:
			return "洞穴"
		TerrainType.WASTELAND:
			return "荒地"
		TerrainType.SWAMP:
			return "沼泽"
		TerrainType.DEAD_LAND:
			return "死地"
		_:
			return "未知"

func get_terrain_type_name(terrain_type: TerrainType) -> String:
	"""🔧 [统一接口] 获取地形类型名称 - 供外部调用"""
	return _get_terrain_type_name(terrain_type)

func get_terrain_highlight_color(terrain_type: TerrainType) -> Color:
	"""🔧 [统一接口] 获取地形高亮颜色 - 供外部调用"""
	return _get_color_for_terrain_type(terrain_type)

func get_all_terrain_colors() -> Dictionary:
	"""🔧 [统一接口] 获取所有地形类型的颜色映射"""
	return _build_terrain_type_mapping(_get_color_for_terrain_type)

func get_all_terrain_names() -> Dictionary:
	"""🔧 [统一接口] 获取所有地形类型的名称映射"""
	return _build_terrain_type_mapping(_get_terrain_type_name)

func _build_terrain_type_mapping(mapping_func: Callable) -> Dictionary:
	"""🔧 [通用方法] 构建地形类型映射字典"""
	var result = {}
	for terrain_type in TerrainType.values():
		result[terrain_type] = mapping_func.call(terrain_type)
	return result

# ============================================================================
# 调试
# ============================================================================

func debug_terrain_info():
	"""调试地形信息"""
	LogManager.info("=== 地形管理器调试信息 ===")
	var stats = get_terrain_statistics()
	LogManager.info("总地形区域数: %d" % stats.total_regions)
	
	# 🔧 [优化] 使用预构建的名称映射，避免重复调用
	var terrain_names = get_all_terrain_names()
	
	for terrain_type in TerrainType.values():
		var count = stats.terrain_counts[terrain_type]
		if count > 0:
			LogManager.info("%s: %d 个区域" % [terrain_names[terrain_type], count])
			var centers = stats.terrain_centers[terrain_type]
			for i in range(min(centers.size(), 3)): # 只显示前3个中心
				LogManager.info("  中心 %d: %s" % [i + 1, centers[i]])
			if centers.size() > 3:
				LogManager.info("  ... 还有 %d 个中心" % (centers.size() - 3))
	
	LogManager.info("=========================")
