extends Node

## ⚙️ 空洞配置系统
## 管理所有空洞的配置信息，支持从autoload获取配置

# ============================================================================
# 单例模式
# ============================================================================

static var instance: CavityConfig = null

# ============================================================================
# 配置数据
# ============================================================================

var cavities: Array[Dictionary] = []
var default_configs: Array[Dictionary] = []

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	"""初始化配置系统"""
	instance = self
	_load_default_configs()

# ============================================================================
# 默认配置加载
# ============================================================================

func _load_default_configs() -> void:
	"""加载默认空洞配置"""
	default_configs = [
		# 关键建筑空洞
		{
			"id": "dungeon_heart",
			"type": "critical",
			"shape": "rectangle",
			"center": [100, 100],
			"size": [7, 7],
			"content_type": "DUNGEON_HEART",
			"highlight_color": [1.0, 0.0, 0.0, 0.8],
			"priority": 1,
			"is_fixed": true # 固定位置，不可调整
		},
		{
			"id": "portal_1",
			"type": "critical",
			"shape": "circle",
			"center": [20, 20],
			"radius": 3,
			"content_type": "PORTAL",
			"highlight_color": [0.5, 0.0, 0.8, 0.8],
			"priority": 1,
			"is_fixed": true
		},
		{
			"id": "portal_2",
			"type": "critical",
			"shape": "circle",
			"center": [180, 20],
			"radius": 3,
			"content_type": "PORTAL",
			"highlight_color": [0.5, 0.0, 0.8, 0.8],
			"priority": 1,
			"is_fixed": true
		},
		{
			"id": "portal_3",
			"type": "critical",
			"shape": "circle",
			"center": [20, 180],
			"radius": 3,
			"content_type": "PORTAL",
			"highlight_color": [0.5, 0.0, 0.8, 0.8],
			"priority": 1,
			"is_fixed": true
		},
		{
			"id": "portal_4",
			"type": "critical",
			"shape": "circle",
			"center": [180, 180],
			"radius": 3,
			"content_type": "PORTAL",
			"highlight_color": [0.5, 0.0, 0.8, 0.8],
			"priority": 1,
			"is_fixed": true
		},
		
		# 功能系统空洞
		{
			"id": "room_system_1",
			"type": "functional",
			"shape": "rectangle",
			"center": [100, 100],
			"size": [60, 60],
			"content_type": "ROOM_SYSTEM",
			"highlight_color": [0.0, 0.0, 1.0, 0.6],
			"priority": 2,
			"is_fixed": false
		},
		{
			"id": "maze_system_1",
			"type": "functional",
			"shape": "maze",
			"center": [60, 60],
			"size": [80, 80],
			"content_type": "MAZE_SYSTEM",
			"highlight_color": [0.5, 0.0, 0.5, 0.6],
			"priority": 3,
			"is_fixed": false
		},
		
		# 生态系统空洞
		{
			"id": "forest_1",
			"type": "ecosystem",
			"shape": "noise",
			"center": [50, 50],
			"radius": 25,
			"content_type": "FOREST",
			"highlight_color": [0.0, 0.8, 0.0, 0.6],
			"priority": 4,
			"is_fixed": false
		},
		{
			"id": "lake_1",
			"type": "ecosystem",
			"shape": "noise",
			"center": [150, 50],
			"radius": 20,
			"content_type": "LAKE",
			"highlight_color": [0.0, 0.6, 1.0, 0.6],
			"priority": 4,
			"is_fixed": false
		},
		{
			"id": "cave_1",
			"type": "ecosystem",
			"shape": "noise",
			"center": [50, 150],
			"radius": 30,
			"content_type": "CAVE",
			"highlight_color": [0.5, 0.3, 0.1, 0.6],
			"priority": 4,
			"is_fixed": false
		},
		{
			"id": "wasteland_1",
			"type": "ecosystem",
			"shape": "noise",
			"center": [150, 150],
			"radius": 22,
			"content_type": "WASTELAND",
			"highlight_color": [0.8, 0.8, 0.0, 0.6],
			"priority": 4,
			"is_fixed": false
		}
	]
	
	# 从autoload获取配置
	_load_from_autoload()

func _load_from_autoload() -> void:
	"""从autoload系统加载配置"""
	if MapConfig:
		var map_size = MapConfig.get_map_size()
		# 将Vector3转换为Vector2i（只使用x和z坐标）
		var map_size_2d = Vector2i(int(map_size.x), int(map_size.z))
		_update_configs_for_map_size(map_size_2d)

# ============================================================================
# 配置管理
# ============================================================================

func get_all_cavities() -> Array[Dictionary]:
	"""获取所有空洞配置"""
	return default_configs.duplicate(true)

func get_cavities_by_type(type: String) -> Array[Dictionary]:
	"""根据类型获取空洞配置"""
	var result: Array[Dictionary] = []
	for cavity in default_configs:
		if cavity.type == type:
			result.append(cavity)
	return result

func get_cavity_by_id(id: String) -> Dictionary:
	"""根据ID获取空洞配置"""
	for cavity in default_configs:
		if cavity.id == id:
			return cavity
	return {}

func get_critical_cavities() -> Array[Dictionary]:
	"""获取关键空洞配置"""
	return get_cavities_by_type("critical")

func get_functional_cavities() -> Array[Dictionary]:
	"""获取功能空洞配置"""
	return get_cavities_by_type("functional")

func get_ecosystem_cavities() -> Array[Dictionary]:
	"""获取生态系统空洞配置"""
	return get_cavities_by_type("ecosystem")

# ============================================================================
# 配置验证
# ============================================================================

func validate_config() -> bool:
	"""验证配置的有效性"""
	var errors = []
	
	for cavity in default_configs:
		# 检查必需字段
		if not cavity.has("id") or cavity.id.is_empty():
			errors.append("空洞配置缺少ID: %s" % cavity)
		
		if not cavity.has("type"):
			errors.append("空洞配置缺少类型: %s" % cavity.id)
		
		if not cavity.has("content_type"):
			errors.append("空洞配置缺少内容类型: %s" % cavity.id)
		
		# 检查位置是否在地图范围内
		if not _is_cavity_in_bounds(cavity):
			errors.append("空洞超出地图边界: %s" % cavity.id)
	
	if errors.size() > 0:
		for error in errors:
			LogManager.error("CavityConfig - %s" % error)
		return false
	
	LogManager.info("CavityConfig - 配置验证通过")
	return true

func _is_cavity_in_bounds(cavity: Dictionary) -> bool:
	"""检查空洞是否在地图边界内"""
	var map_size = Vector2i(200, 200)
	if MapConfig:
		var map_size_3d = MapConfig.get_map_size()
		# 将Vector3转换为Vector2i（只使用x和z坐标）
		map_size = Vector2i(int(map_size_3d.x), int(map_size_3d.z))
	
	if cavity.shape == "circle":
		var center = Vector2i(cavity.center[0], cavity.center[1])
		var radius = cavity.radius
		return center.x - radius >= 0 and center.x + radius < map_size.x and \
			   center.y - radius >= 0 and center.y + radius < map_size.y
	elif cavity.shape == "rectangle":
		var center = Vector2i(cavity.center[0], cavity.center[1])
		var size = Vector2i(cavity.size[0], cavity.size[1])
		var half_width = size.x / 2
		var half_height = size.y / 2
		return center.x - half_width >= 0 and center.x + half_width < map_size.x and \
			   center.y - half_height >= 0 and center.y + half_height < map_size.y
	
	return true

# ============================================================================
# 动态配置
# ============================================================================

func add_cavity_config(config: Dictionary) -> void:
	"""添加空洞配置"""
	if not config.has("id"):
		LogManager.error("CavityConfig - 添加配置失败：缺少ID")
		return
	
	# 检查ID是否已存在
	if get_cavity_by_id(config.id).has("id"):
		LogManager.warning("CavityConfig - 配置ID已存在，将覆盖: %s" % config.id)
		remove_cavity_config(config.id)
	
	default_configs.append(config)
	LogManager.info("CavityConfig - 添加空洞配置: %s" % config.id)

func remove_cavity_config(id: String) -> bool:
	"""移除空洞配置"""
	for i in range(default_configs.size()):
		if default_configs[i].id == id:
			default_configs.remove_at(i)
			LogManager.info("CavityConfig - 移除空洞配置: %s" % id)
			return true
	
	LogManager.warning("CavityConfig - 未找到要移除的配置: %s" % id)
	return false

func update_cavity_config(id: String, updates: Dictionary) -> bool:
	"""更新空洞配置"""
	for i in range(default_configs.size()):
		if default_configs[i].id == id:
			for key in updates:
				default_configs[i][key] = updates[key]
			LogManager.info("CavityConfig - 更新空洞配置: %s" % id)
			return true
	
	LogManager.warning("CavityConfig - 未找到要更新的配置: %s" % id)
	return false

# ============================================================================
# 地图尺寸适配
# ============================================================================

func _update_configs_for_map_size(map_size: Vector2i) -> void:
	"""根据地图尺寸更新配置"""
	var scale_factor = Vector2(map_size.x / 200.0, map_size.y / 200.0)
	
	for cavity in default_configs:
		# 更新中心位置
		if cavity.has("center"):
			cavity.center[0] = int(cavity.center[0] * scale_factor.x)
			cavity.center[1] = int(cavity.center[1] * scale_factor.y)
		
		# 更新尺寸
		if cavity.has("size"):
			cavity.size[0] = int(cavity.size[0] * scale_factor.x)
			cavity.size[1] = int(cavity.size[1] * scale_factor.y)
		
		# 更新半径
		if cavity.has("radius"):
			cavity.radius = int(cavity.radius * (scale_factor.x + scale_factor.y) / 2)

# ============================================================================
# 工具方法
# ============================================================================

func get_cavity_count_by_type() -> Dictionary:
	"""获取各类型空洞数量统计"""
	var counts = {}
	for cavity in default_configs:
		var type = cavity.get("type", "unknown")
		counts[type] = counts.get(type, 0) + 1
	return counts

func get_total_cavity_area() -> float:
	"""获取空洞总面积"""
	var total_area = 0.0
	for cavity in default_configs:
		if cavity.shape == "circle":
			total_area += PI * cavity.radius * cavity.radius
		elif cavity.shape == "rectangle":
			total_area += cavity.size[0] * cavity.size[1]
		# 其他形状的面积计算较复杂，这里简化处理
	return total_area

func get_config_summary() -> Dictionary:
	"""获取配置摘要信息"""
	return {
		"total_cavities": default_configs.size(),
		"cavity_types": get_cavity_count_by_type(),
		"total_area": get_total_cavity_area(),
		"is_valid": validate_config()
	}

# ============================================================================
# 静态访问方法
# ============================================================================

static func get_instance() -> CavityConfig:
	"""获取配置实例（已废弃，直接使用autoload单例）"""
	return CavityConfig

static func get_all_cavities_static() -> Array[Dictionary]:
	"""静态方法：获取所有空洞配置"""
	return get_instance().get_all_cavities()

static func get_cavities_by_type_static(type: String) -> Array[Dictionary]:
	"""静态方法：根据类型获取空洞配置"""
	return get_instance().get_cavities_by_type(type)
