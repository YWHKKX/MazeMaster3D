extends Node

## 🏗️ 空洞管理器
## 管理所有空洞的注册、查询和操作

# ============================================================================
# 类型引用
# ============================================================================

const Cavity = preload("res://scripts/map_system/cavity_system/cavities/Cavity.gd")
const CavityGenerator = preload("res://scripts/map_system/cavity_system/algorithms/CavityGenerator.gd")

# ============================================================================
# 属性
# ============================================================================

var cavities: Dictionary = {} # id -> Cavity
var cavities_by_type: Dictionary = {} # type -> Array[Cavity]
var cavities_by_content: Dictionary = {} # content_type -> Array[Cavity]
var cavity_count: int = 0

# 生成器引用
var cavity_generator: CavityGenerator

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	"""初始化空洞管理器"""
	name = "CavityManager"
	_initialize_generator()
	LogManager.info("CavityManager - 空洞管理器已初始化")

func _initialize_generator() -> void:
	"""初始化空洞生成器"""
	cavity_generator = CavityGenerator.new()
	add_child(cavity_generator)
	LogManager.info("CavityManager - 空洞生成器已初始化")

# ============================================================================
# 空洞注册
# ============================================================================

func register_cavity(cavity: Cavity) -> void:
	"""注册空洞"""
	if not cavity or cavity.id.is_empty():
		LogManager.warning("CavityManager - 尝试注册无效空洞")
		return
	
	# 检查ID是否已存在
	if cavities.has(cavity.id):
		LogManager.warning("CavityManager - 空洞ID已存在，将覆盖: %s" % cavity.id)
		unregister_cavity(cavity.id)
	
	# 注册到主字典
	cavities[cavity.id] = cavity
	cavity_count += 1
	
	# 注册到类型字典
	if not cavities_by_type.has(cavity.type):
		cavities_by_type[cavity.type] = []
	cavities_by_type[cavity.type].append(cavity)
	
	# 注册到内容类型字典
	if not cavities_by_content.has(cavity.content_type):
		cavities_by_content[cavity.content_type] = []
	cavities_by_content[cavity.content_type].append(cavity)
	
	# LogManager.info("CavityManager - 注册空洞: %s (%s, %s)" % [cavity.id, cavity.type, cavity.content_type])

func add_cavity(cavity: Cavity) -> void:
	"""添加空洞（register_cavity的别名）"""
	register_cavity(cavity)

func unregister_cavity(cavity_id: String) -> bool:
	"""注销空洞"""
	if not cavities.has(cavity_id):
		LogManager.warning("CavityManager - 未找到要注销的空洞: %s" % cavity_id)
		return false
	
	var cavity = cavities[cavity_id]
	
	# 从主字典移除
	cavities.erase(cavity_id)
	cavity_count -= 1
	
	# 从类型字典移除
	if cavities_by_type.has(cavity.type):
		cavities_by_type[cavity.type].erase(cavity)
		if cavities_by_type[cavity.type].is_empty():
			cavities_by_type.erase(cavity.type)
	
	# 从内容类型字典移除
	if cavities_by_content.has(cavity.content_type):
		cavities_by_content[cavity.content_type].erase(cavity)
		if cavities_by_content[cavity.content_type].is_empty():
			cavities_by_content.erase(cavity.content_type)
	
	LogManager.info("CavityManager - 注销空洞: %s" % cavity_id)
	return true

func clear_all_cavities() -> void:
	"""清空所有空洞"""
	cavities.clear()
	cavities_by_type.clear()
	cavities_by_content.clear()
	cavity_count = 0
	LogManager.info("CavityManager - 已清空所有空洞")

# ============================================================================
# 空洞查询
# ============================================================================

func get_cavity_by_id(id: String) -> Cavity:
	"""根据ID获取空洞"""
	return cavities.get(id, null)

func get_cavities_by_type(type: String) -> Array[Cavity]:
	"""根据类型获取空洞列表"""
	var result = cavities_by_type.get(type, [])
	if result is Array[Cavity]:
		return result
	else:
		return []

func get_cavities_by_content(content_type: String) -> Array[Cavity]:
	"""根据内容类型获取空洞列表"""
	var result = cavities_by_content.get(content_type, [])
	if result is Array[Cavity]:
		return result
	else:
		return []

func get_all_cavities() -> Array[Cavity]:
	"""获取所有空洞"""
	var result: Array[Cavity] = []
	for cavity in cavities.values():
		result.append(cavity)
	return result

func get_cavity_at_position(pos: Vector3) -> Cavity:
	"""获取指定位置的空洞"""
	for cavity in cavities.values():
		if cavity.contains_position(pos):
			return cavity
	return null

func get_cavities_in_area(center: Vector3, radius: float) -> Array[Cavity]:
	"""获取指定区域内的空洞"""
	var result: Array[Cavity] = []
	
	for cavity in cavities.values():
		var cavity_center = cavity.get_center_position()
		if cavity_center.distance_to(center) <= radius:
			result.append(cavity)
	
	return result

func get_cavities_in_rect(rect: Rect2i) -> Array[Cavity]:
	"""获取指定矩形区域内的空洞"""
	var result: Array[Cavity] = []
	
	for cavity in cavities.values():
		var cavity_rect = cavity.get_bounding_rect()
		if rect.intersects(cavity_rect):
			result.append(cavity)
	
	return result

# ============================================================================
# 特殊查询
# ============================================================================

func get_dungeon_heart() -> Cavity:
	"""获取地牢之心空洞"""
	return get_cavity_by_id("dungeon_heart")

func get_portals() -> Array[Cavity]:
	"""获取所有传送门空洞"""
	return get_cavities_by_content("PORTAL")

func get_ecosystem_cavities() -> Array[Cavity]:
	"""获取所有生态系统空洞"""
	return get_cavities_by_type("ecosystem")

func get_functional_cavities() -> Array[Cavity]:
	"""获取所有功能空洞"""
	return get_cavities_by_type("functional")

func get_critical_cavities() -> Array[Cavity]:
	"""获取所有关键空洞"""
	return get_cavities_by_type("critical")

# ============================================================================
# 空洞操作
# ============================================================================

func add_position_to_cavity(cavity_id: String, pos: Vector3) -> bool:
	"""向空洞添加位置"""
	var cavity = get_cavity_by_id(cavity_id)
	if not cavity:
		LogManager.warning("CavityManager - 未找到空洞: %s" % cavity_id)
		return false
	
	cavity.add_position(pos)
	LogManager.debug("CavityManager - 向空洞 %s 添加位置: %s" % [cavity_id, pos])
	return true

func remove_position_from_cavity(cavity_id: String, pos: Vector3) -> bool:
	"""从空洞移除位置"""
	var cavity = get_cavity_by_id(cavity_id)
	if not cavity:
		LogManager.warning("CavityManager - 未找到空洞: %s" % cavity_id)
		return false
	
	cavity.remove_position(pos)
	LogManager.debug("CavityManager - 从空洞 %s 移除位置: %s" % [cavity_id, pos])
	return true

func merge_cavities(cavity_id1: String, cavity_id2: String) -> bool:
	"""合并两个空洞"""
	var cavity1 = get_cavity_by_id(cavity_id1)
	var cavity2 = get_cavity_by_id(cavity_id2)
	
	if not cavity1 or not cavity2:
		LogManager.warning("CavityManager - 无法合并空洞，缺少空洞: %s, %s" % [cavity_id1, cavity_id2])
		return false
	
	# 将cavity2的位置添加到cavity1
	for pos in cavity2.positions:
		cavity1.add_position(pos)
	
	# 注销cavity2
	unregister_cavity(cavity_id2)
	
	LogManager.info("CavityManager - 合并空洞: %s + %s -> %s" % [cavity_id1, cavity_id2, cavity_id1])
	return true

func split_cavity(cavity_id: String, split_positions: Array[Vector3]) -> Array[Cavity]:
	"""分割空洞"""
	var cavity = get_cavity_by_id(cavity_id)
	if not cavity:
		LogManager.warning("CavityManager - 未找到要分割的空洞: %s" % cavity_id)
		var empty_result: Array[Cavity] = []
		return empty_result
	
	var new_cavities: Array[Cavity] = []
	var remaining_positions: Array[Vector3] = []
	
	# 分离位置
	for pos in cavity.positions:
		if pos in split_positions:
			# 创建新空洞
			var new_cavity = Cavity.new()
			new_cavity.id = cavity_id + "_split_" + str(new_cavities.size())
			new_cavity.type = cavity.type
			new_cavity.content_type = cavity.content_type
			new_cavity.highlight_color = cavity.highlight_color
			new_cavity.priority = cavity.priority
			new_cavity.add_position(pos)
			new_cavities.append(new_cavity)
		else:
			remaining_positions.append(pos)
	
	# 更新原空洞
	cavity.positions = remaining_positions
	cavity._update_bounds()
	
	# 注册新空洞
	for new_cavity in new_cavities:
		register_cavity(new_cavity)
	
	LogManager.info("CavityManager - 分割空洞 %s，创建 %d 个新空洞" % [cavity_id, new_cavities.size()])
	return new_cavities

# ============================================================================
# 统计信息
# ============================================================================

func get_cavity_count() -> int:
	"""获取空洞总数"""
	return cavity_count

func get_cavity_count_by_type() -> Dictionary:
	"""获取各类型空洞数量"""
	var counts = {}
	for type in cavities_by_type.keys():
		counts[type] = cavities_by_type[type].size()
	return counts

func get_cavity_count_by_content() -> Dictionary:
	"""获取各内容类型空洞数量"""
	var counts = {}
	for content_type in cavities_by_content.keys():
		counts[content_type] = cavities_by_content[content_type].size()
	return counts

func get_total_cavity_area() -> float:
	"""获取空洞总面积"""
	var total_area = 0.0
	for cavity in cavities.values():
		total_area += cavity.area
	return total_area

func get_cavity_statistics() -> Dictionary:
	"""获取空洞统计信息"""
	return {
		"total_cavities": cavity_count,
		"cavities_by_type": get_cavity_count_by_type(),
		"cavities_by_content": get_cavity_count_by_content(),
		"total_area": get_total_cavity_area(),
		"average_area": get_total_cavity_area() / max(cavity_count, 1)
	}

# ============================================================================
# 调试和验证
# ============================================================================

func validate_cavities() -> bool:
	"""验证空洞数据"""
	var errors: Array[String] = []
	
	for cavity_id in cavities.keys():
		var cavity = cavities[cavity_id]
		
		# 检查基本属性
		if cavity.id != cavity_id:
			errors.append("空洞ID不匹配: %s != %s" % [cavity.id, cavity_id])
		
		if cavity.positions.is_empty():
			errors.append("空洞位置为空: %s" % cavity_id)
		
		# 检查连通性
		if not cavity.check_connectivity():
			errors.append("空洞不连通: %s" % cavity_id)
	
	if errors.size() > 0:
		for error in errors:
			LogManager.error("CavityManager - %s" % error)
		return false
	
	LogManager.info("CavityManager - 空洞验证通过")
	return true

func get_debug_info() -> String:
	"""获取调试信息"""
	var info = "=== 空洞管理器调试信息 ===\n"
	info += "总空洞数: %d\n" % cavity_count
	info += "按类型分布: %s\n" % get_cavity_count_by_type()
	info += "按内容分布: %s\n" % get_cavity_count_by_content()
	info += "总面积: %.2f\n" % get_total_cavity_area()
	info += "平均面积: %.2f\n" % (get_total_cavity_area() / max(cavity_count, 1))
	info += "========================="
	return info

func print_cavity_list() -> void:
	"""打印空洞列表"""
	LogManager.info("=== 空洞列表 ===")
	for cavity_id in cavities.keys():
		var cavity = cavities[cavity_id]
		LogManager.info("  %s: %s (%s) - %d 位置" % [cavity_id, cavity.type, cavity.content_type, cavity.positions.size()])
	LogManager.info("===============")

# ============================================================================
# 空洞生成
# ============================================================================

func generate_cavities_with_constraints() -> Array[Cavity]:
	"""生成带约束条件的空洞"""
	if not cavity_generator:
		LogManager.error("CavityManager - 空洞生成器未初始化")
		return []
	
	LogManager.info("CavityManager - 开始生成约束空洞")
	
	# 使用生成器生成空洞
	var generated_cavities = cavity_generator.generate_cavities_with_constraints()
	
	# 注册所有生成的空洞
	for cavity in generated_cavities:
		register_cavity(cavity)
	
	LogManager.info("CavityManager - 生成并注册了 %d 个约束空洞" % generated_cavities.size())
	return generated_cavities

func generate_cavities() -> Array[Cavity]:
	"""生成普通空洞"""
	if not cavity_generator:
		LogManager.error("CavityManager - 空洞生成器未初始化")
		return []
	
	LogManager.info("CavityManager - 开始生成空洞")
	
	# 使用生成器生成空洞
	var generated_cavities = cavity_generator.generate_cavities()
	
	# 注册所有生成的空洞
	for cavity in generated_cavities:
		register_cavity(cavity)
	
	LogManager.info("CavityManager - 生成并注册了 %d 个空洞" % generated_cavities.size())
	return generated_cavities
