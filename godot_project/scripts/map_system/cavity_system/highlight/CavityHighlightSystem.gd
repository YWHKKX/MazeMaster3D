extends Node

## 🎨 空洞高亮系统
## 提供空洞级高亮显示，支持边界高亮和内容高亮

# ============================================================================
# 类型引用
# ============================================================================

const Cavity = preload("res://scripts/map_system/cavity_system/cavities/Cavity.gd")

# ============================================================================
# 属性
# ============================================================================

var cavities: Array[Cavity] = []
var highlighted_cavity: Cavity = null
var highlight_materials: Dictionary = {}
var tile_manager: Node
var highlight_enabled: bool = true

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	"""初始化高亮系统"""
	name = "CavityHighlightSystem"
	LogManager.info("CavityHighlightSystem - 空洞高亮系统已初始化")

# ============================================================================
# 空洞注册
# ============================================================================

func register_cavity(cavity: Cavity) -> void:
	"""注册空洞"""
	if not cavity or cavity.id.is_empty():
		LogManager.warning("CavityHighlightSystem - 尝试注册无效空洞")
		return
	
	if cavity not in cavities:
		cavities.append(cavity)
		# LogManager.debug("CavityHighlightSystem - 注册空洞: %s" % cavity.id)

func unregister_cavity(cavity: Cavity) -> void:
	"""注销空洞"""
	if cavity in cavities:
		cavities.erase(cavity)
		# 如果正在高亮此空洞，清除高亮
		if highlighted_cavity == cavity:
			clear_highlight()
		# LogManager.debug("CavityHighlightSystem - 注销空洞: %s" % cavity.id)

func clear_all_cavities() -> void:
	"""清空所有空洞"""
	cavities.clear()
	clear_highlight()
	LogManager.info("CavityHighlightSystem - 已清空所有空洞")

# ============================================================================
# 高亮控制
# ============================================================================

func highlight_cavity(cavity_id: String) -> void:
	"""高亮指定空洞"""
	if not highlight_enabled:
		return
	
	# 清除之前的高亮
	clear_highlight()
	
	# 查找目标空洞
	var target_cavity = _find_cavity_by_id(cavity_id)
	if not target_cavity:
		LogManager.warning("CavityHighlightSystem - 未找到空洞: %s" % cavity_id)
		return
	
	# 高亮空洞
	_highlight_cavity(target_cavity)
	highlighted_cavity = target_cavity
	
	LogManager.info("CavityHighlightSystem - 高亮空洞: %s" % cavity_id)

func highlight_cavity_by_type(cavity_type: String) -> void:
	"""高亮指定类型的所有空洞"""
	if not highlight_enabled:
		return
	
	clear_highlight()
	
	var target_cavities = _find_cavities_by_type(cavity_type)
	if target_cavities.is_empty():
		LogManager.warning("CavityHighlightSystem - 未找到类型为 %s 的空洞" % cavity_type)
		return
	
	# 高亮所有匹配的空洞
	for cavity in target_cavities:
		_highlight_cavity(cavity)
	
	LogManager.info("CavityHighlightSystem - 高亮 %d 个 %s 类型空洞" % [target_cavities.size(), cavity_type])

func highlight_cavity_by_content(content_type: String) -> void:
	"""高亮指定内容类型的所有空洞"""
	if not highlight_enabled:
		return
	
	clear_highlight()
	
	var target_cavities = _find_cavities_by_content(content_type)
	if target_cavities.is_empty():
		LogManager.warning("CavityHighlightSystem - 未找到内容类型为 %s 的空洞" % content_type)
		return
	
	# 高亮所有匹配的空洞
	for cavity in target_cavities:
		_highlight_cavity(cavity)
	
	LogManager.info("CavityHighlightSystem - 高亮 %d 个 %s 内容类型空洞" % [target_cavities.size(), content_type])

func clear_highlight() -> void:
	"""清除所有高亮"""
	if highlighted_cavity:
		_clear_cavity_highlight(highlighted_cavity)
		highlighted_cavity = null
	
	# 清除所有空洞的高亮
	for cavity in cavities:
		_clear_cavity_highlight(cavity)
	
	# LogManager.debug("CavityHighlightSystem - 清除所有高亮")

# ============================================================================
# 内部高亮方法
# ============================================================================

func _highlight_cavity(cavity: Cavity) -> void:
	"""高亮空洞边界"""
	if not cavity or cavity.positions.is_empty():
		return
	
	# 获取高亮材质
	var highlight_material = _get_highlight_material(cavity.content_type)
	
	# 高亮空洞边界
	var boundary_positions = cavity.get_boundary_positions()
	for pos in boundary_positions:
		_highlight_tile_at_position(pos, highlight_material)

func _clear_cavity_highlight(cavity: Cavity) -> void:
	"""清除空洞高亮"""
	if not cavity or cavity.positions.is_empty():
		return
	
	# 清除空洞边界高亮
	var boundary_positions = cavity.get_boundary_positions()
	for pos in boundary_positions:
		_clear_tile_highlight(pos)

func _highlight_tile_at_position(pos: Vector3, material: StandardMaterial3D) -> void:
	"""高亮指定位置的瓦片"""
	if not tile_manager:
		return
	
	var tile_data = tile_manager.get_tile_data(pos)
	if tile_data and tile_data.tile_object:
		tile_data.tile_object.set_surface_override_material(0, material)

func _clear_tile_highlight(pos: Vector3) -> void:
	"""清除指定位置瓦片的高亮"""
	if not tile_manager:
		return
	
	var tile_data = tile_manager.get_tile_data(pos)
	if tile_data and tile_data.tile_object:
		tile_data.tile_object.set_surface_override_material(0, null)

# ============================================================================
# 材质管理
# ============================================================================

func _get_highlight_material(content_type: String) -> StandardMaterial3D:
	"""获取高亮材质"""
	if highlight_materials.has(content_type):
		return highlight_materials[content_type]
	
	var material = _create_highlight_material(content_type)
	highlight_materials[content_type] = material
	return material

func _create_highlight_material(content_type: String) -> StandardMaterial3D:
	"""创建高亮材质"""
	var material = StandardMaterial3D.new()
	
	# 根据内容类型设置颜色
	var base_color = _get_base_color_for_content_type(content_type)
	material.albedo_color = base_color
	material.emission_enabled = true
	material.emission = base_color * 0.5
	material.flags_transparent = true
	material.flags_unshaded = true
	
	return material

func _get_base_color_for_content_type(content_type: String) -> Color:
	"""根据内容类型获取基础颜色"""
	match content_type:
		"FOREST":
			return Color(0.0, 0.8, 0.0, 0.8)
		"LAKE":
			return Color(0.0, 0.6, 1.0, 0.8)
		"CAVE":
			return Color(0.5, 0.3, 0.1, 0.8)
		"WASTELAND":
			return Color(0.8, 0.8, 0.0, 0.8)
		"ROOM_SYSTEM":
			return Color(0.0, 0.0, 1.0, 0.8)
		"MAZE_SYSTEM":
			return Color(0.5, 0.0, 0.5, 0.8)
		"DUNGEON_HEART":
			return Color(1.0, 0.0, 0.0, 0.9)
		"PORTAL":
			return Color(0.5, 0.0, 0.8, 0.9)
		_:
			return Color(0.5, 0.5, 0.5, 0.8)

# ============================================================================
# 特殊高亮模式
# ============================================================================

func highlight_cavity_boundaries() -> void:
	"""高亮所有空洞边界"""
	if not highlight_enabled:
		return
	
	clear_highlight()
	
	for cavity in cavities:
		_highlight_cavity_boundary(cavity)
	
	LogManager.info("CavityHighlightSystem - 高亮所有空洞边界")

func _highlight_cavity_boundary(cavity: Cavity) -> void:
	"""高亮单个空洞边界"""
	if not cavity or cavity.positions.is_empty():
		return
	
	var boundary_material = _create_boundary_material()
	var boundary_positions = cavity.get_boundary_positions()
	
	for pos in boundary_positions:
		_highlight_tile_at_position(pos, boundary_material)

func _create_boundary_material() -> StandardMaterial3D:
	"""创建边界材质"""
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 1.0, 0.0, 0.9) # 黄色边界
	material.emission_enabled = true
	material.emission = Color(1.0, 1.0, 0.0, 0.5)
	material.flags_transparent = true
	material.flags_unshaded = true
	return material

func highlight_cavity_centers() -> void:
	"""高亮所有空洞中心"""
	if not highlight_enabled:
		return
	
	clear_highlight()
	
	for cavity in cavities:
		_highlight_cavity_center(cavity)
	
	LogManager.info("CavityHighlightSystem - 高亮所有空洞中心")

func _highlight_cavity_center(cavity: Cavity) -> void:
	"""高亮单个空洞中心"""
	if not cavity or cavity.positions.is_empty():
		return
	
	var center_material = _create_center_material()
	var center_pos = cavity.get_center_position()
	_highlight_tile_at_position(center_pos, center_material)

func _create_center_material() -> StandardMaterial3D:
	"""创建中心材质"""
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.0, 1.0, 0.9) # 品红色中心
	material.emission_enabled = true
	material.emission = Color(1.0, 0.0, 1.0, 0.7)
	material.flags_transparent = true
	material.flags_unshaded = true
	return material

# ============================================================================
# 查找方法
# ============================================================================

func _find_cavity_by_id(cavity_id: String) -> Cavity:
	"""根据ID查找空洞"""
	for cavity in cavities:
		if cavity.id == cavity_id:
			return cavity
	return null

func _find_cavities_by_type(cavity_type: String) -> Array[Cavity]:
	"""根据类型查找空洞"""
	var result: Array[Cavity] = []
	for cavity in cavities:
		if cavity.type == cavity_type:
			result.append(cavity)
	return result

func _find_cavities_by_content(content_type: String) -> Array[Cavity]:
	"""根据内容类型查找空洞"""
	var result: Array[Cavity] = []
	for cavity in cavities:
		if cavity.content_type == content_type:
			result.append(cavity)
	return result

# ============================================================================
# 配置和控制
# ============================================================================

func set_tile_manager(manager: Node) -> void:
	"""设置瓦片管理器"""
	tile_manager = manager

func set_highlight_enabled(enabled: bool) -> void:
	"""设置高亮是否启用"""
	highlight_enabled = enabled
	if not enabled:
		clear_highlight()
	LogManager.info("CavityHighlightSystem - 高亮%s" % ("启用" if enabled else "禁用"))

func clear_material_cache() -> void:
	"""清空材质缓存"""
	highlight_materials.clear()
	LogManager.info("CavityHighlightSystem - 已清空材质缓存")

# ============================================================================
# 调试信息
# ============================================================================

func get_highlight_info() -> Dictionary:
	"""获取高亮信息"""
	return {
		"registered_cavities": cavities.size(),
		"highlighted_cavity": highlighted_cavity.id if highlighted_cavity else "",
		"highlight_enabled": highlight_enabled,
		"material_cache_size": highlight_materials.size(),
		"tile_manager_ready": tile_manager != null
	}

func print_highlight_status() -> void:
	"""打印高亮状态"""
	LogManager.info("=== 空洞高亮状态 ===")
	LogManager.info("注册空洞数: %d" % cavities.size())
	LogManager.info("当前高亮空洞: %s" % (highlighted_cavity.id if highlighted_cavity else "无"))
	LogManager.info("高亮启用: %s" % ("是" if highlight_enabled else "否"))
	LogManager.info("材质缓存大小: %d" % highlight_materials.size())
	LogManager.info("瓦片管理器就绪: %s" % ("是" if tile_manager else "否"))
	LogManager.info("==================")
