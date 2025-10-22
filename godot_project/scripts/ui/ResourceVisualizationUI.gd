extends Control
class_name ResourceVisualizationUI

## 🗺️ 资源可视化UI
## 在地图上显示资源位置和状态

# 导入UI工具类
const UIDesignConstants = preload("res://scripts/ui/UIDesignConstants.gd")
const ResourceManager = preload("res://scripts/managers/resource/ResourceManager.gd")

# UI配置
var ui_config = {
	"icon_size": Vector2(24, 24),
	"icon_spacing": 2,
	"panel_width": 250,
	"panel_height": 400,
	"margin": 10
}

# UI引用
var resource_panel: Control = null
var resource_list: VBoxContainer = null
var resource_icons: Dictionary = {} # 存储资源图标引用
var resource_markers: Array[Node3D] = [] # 存储3D标记

# 节点引用
var resource_manager = null
var camera_node: Camera3D = null
var world_node: Node3D = null

# 可视化状态
var is_visualization_enabled: bool = true
var show_only_available: bool = true # 只显示可采集的资源
var resource_filter: Array = [] # 资源类型过滤器

# LOD系统配置
var lod_config = {
	"high_detail_distance": 50.0, # 高细节距离
	"medium_detail_distance": 100.0, # 中细节距离
	"low_detail_distance": 200.0, # 低细节距离
	"cull_distance": 300.0, # 剔除距离
	"update_interval": 0.1, # 更新间隔（秒）
	"max_markers_per_frame": 10 # 每帧最大标记更新数量
}

# LOD状态
var lod_timer: Timer = null
var last_camera_position: Vector3 = Vector3.ZERO
var pending_marker_updates: Array = []
var marker_lod_levels: Dictionary = {} # {marker_id: lod_level}

func _ready():
	"""初始化资源可视化UI"""
	LogManager.info("ResourceVisualizationUI - 初始化开始")
	
	_setup_visualization_ui()
	_setup_lod_system()
	
	# 等待一帧，确保GameServices和ResourceManager都已初始化
	await get_tree().process_frame
	
	# 从GameServices获取ResourceManager
	resource_manager = GameServices.resource_manager
	if resource_manager:
		_connect_signals()
	else:
		LogManager.error("无法从GameServices获取ResourceManager！")
	
	# 查找相机节点
	_find_camera_node()
	
	LogManager.info("ResourceVisualizationUI - 初始化完成")

func set_world_node(node: Node3D):
	"""设置世界节点引用，用于添加3D标记"""
	world_node = node
	LogManager.info("ResourceVisualizationUI - 世界节点已设置")

func _setup_visualization_ui():
	"""设置资源可视化UI"""
	# 创建主面板
	_create_main_panel()
	
	# 初始时隐藏
	visible = false

func _create_main_panel():
	"""创建主面板"""
	resource_panel = UIUtils.create_panel(
		Vector2(ui_config.panel_width, ui_config.panel_height),
		UIDesignConstants.Colors.PANEL
	)
	resource_panel.position = Vector2(20, 150) # 左上角，在资源显示面板下方
	resource_panel.name = "ResourceVisualizationPanel"
	
	# 设置透明度
	resource_panel.modulate.a = 0.9
	
	# 将面板添加到场景树
	add_child(resource_panel)
	
	# 创建标题和控制区域
	_create_title_section()
	_create_control_section()
	_create_resource_list_section()

func _create_title_section():
	"""创建标题区域"""
	var title_container = UIUtils.create_hbox_container(UIDesignConstants.Spacing.SM)
	title_container.position = Vector2(UIDesignConstants.Spacing.SM, UIDesignConstants.Spacing.SM)
	resource_panel.add_child(title_container)
	
	# 标题
	var title = UIUtils.create_label(
		"🗺️ 资源地图", UIDesignConstants.FontSizes.H2, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	title_container.add_child(title)

func _create_control_section():
	"""创建控制区域"""
	var control_container = UIUtils.create_hbox_container(UIDesignConstants.Spacing.SM)
	control_container.position = Vector2(UIDesignConstants.Spacing.SM, 40)
	resource_panel.add_child(control_container)
	
	# 可视化开关按钮
	var toggle_button = UIUtils.create_button(
		"显示/隐藏", Vector2(80, 30), _toggle_visualization
	)
	control_container.add_child(toggle_button)
	
	# 过滤器按钮
	var filter_button = UIUtils.create_button(
		"过滤", Vector2(60, 30), _toggle_filter_mode
	)
	control_container.add_child(filter_button)

func _create_resource_list_section():
	"""创建资源列表区域"""
	resource_list = UIUtils.create_vbox_container(UIDesignConstants.Spacing.XS)
	resource_list.position = Vector2(UIDesignConstants.Spacing.SM, 80)
	resource_list.custom_minimum_size = Vector2(230, 310)
	resource_panel.add_child(resource_list)
	
	# 创建资源类型列表
	_create_resource_type_list()

func _create_resource_type_list():
	"""创建资源类型列表"""
	# 核心资源
	_create_resource_category_section("🥇 核心资源", ResourceManager.ResourceCategory.CORE)
	
	# 基础资源
	_create_resource_category_section("🥈 基础资源", ResourceManager.ResourceCategory.BASIC)
	
	# 特殊资源
	_create_resource_category_section("🥉 特殊资源", ResourceManager.ResourceCategory.SPECIAL)

func _create_resource_category_section(title: String, category: ResourceManager.ResourceCategory):
	"""创建资源分类区域"""
	# 分类标题
	var category_label = UIUtils.create_label(
		title, UIDesignConstants.FontSizes.NORMAL, UIDesignConstants.Colors.TEXT_SECONDARY
	)
	resource_list.add_child(category_label)
	
	# 获取该分类的资源
	var resources = resource_manager.get_resources_by_category(category) if resource_manager else []
	
	for resource_info in resources:
		_create_resource_type_item(resource_info)

func _create_resource_type_item(resource_info: Dictionary):
	"""创建资源类型项目"""
	var item_container = UIUtils.create_hbox_container(UIDesignConstants.Spacing.XS)
	resource_list.add_child(item_container)
	
	# 资源图标
	var icon_label = UIUtils.create_label(
		resource_info.icon, UIDesignConstants.FontSizes.NORMAL, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	icon_label.custom_minimum_size = Vector2(20, 20)
	item_container.add_child(icon_label)
	
	# 资源名称
	var name_label = UIUtils.create_label(
		resource_info.name, UIDesignConstants.FontSizes.SMALL, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	name_label.custom_minimum_size = Vector2(100, 20)
	item_container.add_child(name_label)
	
	# 资源数量
	var amount_label = UIUtils.create_label(
		"0", UIDesignConstants.FontSizes.SMALL, UIDesignConstants.Colors.SUCCESS
	)
	amount_label.custom_minimum_size = Vector2(40, 20)
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	item_container.add_child(amount_label)
	
	# 显示状态复选框
	var show_checkbox = CheckBox.new()
	show_checkbox.pressed = true
	show_checkbox.toggled.connect(_on_resource_visibility_toggled.bind(resource_info.type))
	item_container.add_child(show_checkbox)
	
	# 存储引用
	resource_icons[resource_info.type] = {
		"icon": icon_label,
		"name": name_label,
		"amount": amount_label,
		"checkbox": show_checkbox
	}

func _connect_signals():
	"""连接信号"""
	if resource_manager:
		resource_manager.resource_changed.connect(_on_resource_changed)
		resource_manager.resource_spawned.connect(_on_resource_spawned)
		resource_manager.resource_depleted.connect(_on_resource_depleted)
		resource_manager.resource_respawned.connect(_on_resource_respawned)

func _find_camera_node():
	"""查找相机节点"""
	camera_node = get_viewport().get_camera_3d()
	if not camera_node:
		# 如果没找到，尝试从场景树中查找
		camera_node = get_tree().get_first_node_in_group("camera")
	
	if camera_node:
		LogManager.info("ResourceVisualizationUI - 找到相机节点")
	else:
		LogManager.warning("ResourceVisualizationUI - 未找到相机节点")

# 信号处理函数
func _on_resource_changed(resource_type: ResourceManager.ResourceType, amount: int, old_amount: int):
	"""资源变化回调"""
	_update_resource_display(resource_type)

func _on_resource_spawned(resource_type: ResourceManager.ResourceType, position: Vector2, amount: int):
	"""资源生成回调"""
	_create_resource_marker(resource_type, position, amount)

func _on_resource_depleted(resource_type: ResourceManager.ResourceType, position: Vector2):
	"""资源耗尽回调"""
	_remove_resource_marker(position)

func _on_resource_respawned(resource_type: ResourceManager.ResourceType, position: Vector2, amount: int):
	"""资源重生回调"""
	_create_resource_marker(resource_type, position, amount)

func _on_resource_visibility_toggled(resource_type: ResourceManager.ResourceType, visible: bool):
	"""资源可见性切换"""
	if visible:
		if not resource_type in resource_filter:
			resource_filter.append(resource_type)
	else:
		if resource_type in resource_filter:
			resource_filter.erase(resource_type)
	
	_update_resource_markers_visibility()

# 资源标记管理
func _create_resource_marker(resource_type: ResourceManager.ResourceType, position: Vector2, amount: int):
	"""创建资源标记"""
	if not is_visualization_enabled:
		return
	
	# 检查是否在过滤列表中
	if resource_type in resource_filter:
		return
	
	# 创建3D标记
	var marker = _create_3d_marker(resource_type, position, amount)
	if marker:
		resource_markers.append(marker)
		add_child(marker)

func _create_3d_marker(resource_type: ResourceManager.ResourceType, position: Vector2, amount: int) -> Node3D:
	"""创建3D资源标记"""
	# 使用预制的ResourceMarker场景
	var marker_scene = preload("res://scenes/ui/resource_marker.tscn")
	var marker = marker_scene.instantiate() as ResourceMarker
	
	if marker:
		marker.name = "ResourceMarker_" + str(resource_type) + "_" + str(position)
		marker.setup_resource(resource_type, amount, position)
		
		# 连接信号
		marker.resource_collected.connect(_on_resource_collected)
		marker.resource_clicked.connect(_on_resource_clicked)
		
		# 设置初始LOD级别
		if camera_node:
			var distance = camera_node.global_position.distance_to(marker.global_position)
			var lod_level = _calculate_lod_level(distance)
			_apply_lod_to_marker(marker, lod_level)
			marker_lod_levels[marker.get_instance_id()] = lod_level
		
		return marker
	else:
		LogManager.error("ResourceVisualizationUI - 无法创建ResourceMarker场景")
		return null

func _remove_resource_marker(position: Vector2):
	"""移除资源标记"""
	for i in range(resource_markers.size() - 1, -1, -1):
		var marker = resource_markers[i]
		var marker_position = marker.get_meta("position", Vector2.ZERO)
		if marker_position == position:
			marker.queue_free()
			resource_markers.remove_at(i)

func _update_resource_markers_visibility():
	"""更新资源标记可见性"""
	for marker in resource_markers:
		var resource_type = marker.get_meta("resource_type")
		var should_show = not resource_type in resource_filter
		marker.visible = should_show

# 辅助函数
func _get_resource_icon_texture(resource_type: ResourceManager.ResourceType) -> Texture2D:
	"""获取资源图标纹理"""
	# 这里可以根据需要加载实际的纹理资源
	# 暂时返回null，使用默认显示
	return null

func _get_resource_color(resource_type: ResourceManager.ResourceType) -> Color:
	"""获取资源颜色"""
	match resource_type:
		ResourceManager.ResourceType.GOLD:
			return Color.GOLD
		ResourceManager.ResourceType.FOOD:
			return Color.ORANGE
		ResourceManager.ResourceType.STONE:
			return Color.GRAY
		ResourceManager.ResourceType.WOOD:
			return Color.BROWN
		ResourceManager.ResourceType.IRON:
			return Color.SILVER
		ResourceManager.ResourceType.GEM:
			return Color.PURPLE
		ResourceManager.ResourceType.MAGIC_HERB:
			return Color.GREEN
		ResourceManager.ResourceType.MAGIC_CRYSTAL:
			return Color.CYAN
		ResourceManager.ResourceType.DEMON_CORE:
			return Color.RED
		ResourceManager.ResourceType.MANA:
			return Color.MAGENTA
		_:
			return Color.WHITE

func _update_resource_display(resource_type: ResourceManager.ResourceType):
	"""更新资源显示"""
	if resource_type in resource_icons:
		var amount = resource_manager.get_resource_amount(resource_type) if resource_manager else 0
		var amount_label = resource_icons[resource_type].amount
		amount_label.text = str(amount)
		
		# 根据数量设置颜色
		if amount > 0:
			amount_label.modulate = UIDesignConstants.Colors.SUCCESS
		else:
			amount_label.modulate = UIDesignConstants.Colors.TEXT_SECONDARY

# 控制函数
func _toggle_visualization():
	"""切换可视化显示"""
	is_visualization_enabled = !is_visualization_enabled
	
	# 更新所有标记的可见性
	for marker in resource_markers:
		marker.visible = is_visualization_enabled
	
	LogManager.info("资源可视化: %s" % ("开启" if is_visualization_enabled else "关闭"))

func _toggle_filter_mode():
	"""切换过滤模式"""
	show_only_available = !show_only_available
	_update_resource_markers_visibility()
	
	LogManager.info("资源过滤模式: %s" % ("仅显示可采集" if show_only_available else "显示全部"))

# 公共接口
func show_ui():
	"""显示UI"""
	visible = true
	_update_all_resource_displays()

func hide_ui():
	"""隐藏UI"""
	visible = false

func toggle_ui():
	"""切换UI显示"""
	if visible:
		hide_ui()
	else:
		show_ui()

func _update_all_resource_displays():
	"""更新所有资源显示"""
	if resource_manager:
		for resource_type in resource_icons:
			_update_resource_display(resource_type)

func refresh_resource_markers():
	"""刷新资源标记"""
	# 清除现有标记
	for marker in resource_markers:
		marker.queue_free()
	resource_markers.clear()
	
	# 重新创建标记
	if resource_manager:
		var all_spawns = resource_manager.get_all_resource_spawns()
		for spawn in all_spawns:
			if not spawn.is_depleted:
				_create_resource_marker(spawn.resource_type, spawn.position, spawn.amount)

func set_camera_reference(camera: Camera3D):
	"""设置相机引用"""
	camera_node = camera

func get_resource_markers() -> Array[Node3D]:
	"""获取所有资源标记"""
	return resource_markers

func clear_all_markers():
	"""清除所有标记"""
	for marker in resource_markers:
		marker.queue_free()
	resource_markers.clear()
	marker_lod_levels.clear()
	pending_marker_updates.clear()

func update_marker_positions():
	"""更新标记位置（当相机移动时调用）"""
	# 使用LOD系统更新标记
	_update_all_marker_lod()

# ===== 信号处理函数 =====

func _on_resource_collected(resource_type: ResourceManager.ResourceType, position: Vector2):
	"""处理资源收集事件"""
	LogManager.info("ResourceVisualizationUI - 资源被收集: %s 在位置 %s" % [str(resource_type), str(position)])
	
	# 从ResourceManager中移除资源
	if resource_manager:
		resource_manager.collect_resource_at_position(resource_type, position)
	
	# 移除标记
	_remove_resource_marker(position)

func _on_resource_clicked(resource_type: ResourceManager.ResourceType, position: Vector2):
	"""处理资源点击事件"""
	LogManager.info("ResourceVisualizationUI - 资源被点击: %s 在位置 %s" % [str(resource_type), str(position)])
	
	# 可以在这里添加资源详情显示逻辑
	_show_resource_details(resource_type, position)

func _show_resource_details(resource_type: ResourceManager.ResourceType, position: Vector2):
	"""显示资源详情"""
	if resource_manager:
		var resource_name = resource_manager.get_resource_name(resource_type)
		var spawns = resource_manager.get_all_resource_spawns()
		
		for spawn in spawns:
			if spawn.position == position and spawn.resource_type == resource_type:
				var info = "资源详情:\n"
				info += "类型: %s\n" % resource_name
				info += "数量: %d\n" % spawn.amount
				info += "位置: %s\n" % str(position)
				info += "地形: %s\n" % spawn.get("terrain_type", "未知")
				info += "状态: %s" % ("可收集" if not spawn.get("is_depleted", false) else "已枯竭")
				
				LogManager.info("ResourceVisualizationUI - %s" % info)
				break

# ===== LOD系统 =====

func _setup_lod_system():
	"""设置LOD系统"""
	# 创建LOD更新定时器
	lod_timer = Timer.new()
	lod_timer.wait_time = lod_config.update_interval
	lod_timer.timeout.connect(_update_lod_system)
	lod_timer.autostart = true
	add_child(lod_timer)
	
	LogManager.info("ResourceVisualizationUI - LOD系统已启动")

func _update_lod_system():
	"""更新LOD系统"""
	if not camera_node or not is_visualization_enabled:
		return
	
	var current_camera_position = camera_node.global_position
	var camera_moved = current_camera_position.distance_to(last_camera_position) > 1.0
	
	if camera_moved:
		last_camera_position = current_camera_position
		_update_all_marker_lod()

func _update_all_marker_lod():
	"""更新所有标记的LOD级别"""
	var updated_count = 0
	var max_updates = lod_config.max_markers_per_frame
	
	for marker in resource_markers:
		if updated_count >= max_updates:
			break
		
		var distance = camera_node.global_position.distance_to(marker.global_position)
		var new_lod_level = _calculate_lod_level(distance)
		var marker_id = marker.get_instance_id()
		
		# 检查LOD级别是否改变
		if marker_lod_levels.get(marker_id, -1) != new_lod_level:
			_apply_lod_to_marker(marker, new_lod_level)
			marker_lod_levels[marker_id] = new_lod_level
			updated_count += 1

func _calculate_lod_level(distance: float) -> int:
	"""计算LOD级别"""
	if distance <= lod_config.high_detail_distance:
		return 0 # 高细节
	elif distance <= lod_config.medium_detail_distance:
		return 1 # 中细节
	elif distance <= lod_config.low_detail_distance:
		return 2 # 低细节
	elif distance <= lod_config.cull_distance:
		return 3 # 最低细节
	else:
		return -1 # 剔除

func _apply_lod_to_marker(marker: Node3D, lod_level: int):
	"""应用LOD级别到标记"""
	if lod_level == -1:
		# 剔除标记
		marker.visible = false
		return
	
	marker.visible = true
	
	# 获取标记的子节点
	var mesh_instance = marker.get_node("MeshInstance3D")
	var label_3d = marker.get_node("Label3D")
	
	if not mesh_instance or not label_3d:
		return
	
	match lod_level:
		0: # 高细节
			mesh_instance.visible = true
			label_3d.visible = true
			mesh_instance.scale = Vector3.ONE
			label_3d.scale = Vector3.ONE
		1: # 中细节
			mesh_instance.visible = true
			label_3d.visible = true
			mesh_instance.scale = Vector3(0.8, 0.8, 0.8)
			label_3d.scale = Vector3(0.8, 0.8, 0.8)
		2: # 低细节
			mesh_instance.visible = true
			label_3d.visible = false
			mesh_instance.scale = Vector3(0.6, 0.6, 0.6)
		3: # 最低细节
			mesh_instance.visible = true
			label_3d.visible = false
			mesh_instance.scale = Vector3(0.4, 0.4, 0.4)

# ===== 资源密度显示 =====

func show_resource_density():
	"""显示资源密度"""
	if not resource_manager:
		return
	
	var density_info = _calculate_resource_density()
	_display_density_info(density_info)

func _calculate_resource_density() -> Dictionary:
	"""计算资源密度"""
	var density_info = {}
	var total_resources = 0
	var area_size = 100.0 # 100x100单位区域
	
	for resource_type in ResourceManager.ResourceType.values():
		var spawns = resource_manager.get_all_resource_spawns()
		var type_count = 0
		
		for spawn in spawns:
			if spawn.resource_type == resource_type and not spawn.get("is_depleted", false):
				type_count += 1
		
		var density = type_count / (area_size * area_size / 10000.0) # 每100x100区域的密度
		density_info[resource_type] = {
			"count": type_count,
			"density": density
		}
		total_resources += type_count
	
	density_info["total"] = total_resources
	return density_info

func _display_density_info(density_info: Dictionary):
	"""显示密度信息"""
	var info_text = "资源密度信息:\n"
	
	for resource_type in ResourceManager.ResourceType.values():
		if density_info.has(resource_type):
			var info = density_info[resource_type]
			var resource_name = resource_manager.get_resource_name(resource_type)
			info_text += "%s: %d个 (密度: %.2f)\n" % [resource_name, info.count, info.density]
	
	info_text += "总计: %d个资源点" % density_info.total
	LogManager.info("ResourceVisualizationUI - %s" % info_text)

# ===== 性能优化 =====

func optimize_marker_performance():
	"""优化标记性能"""
	# 批量更新标记
	var batch_size = 20
	var processed = 0
	
	for marker in resource_markers:
		if processed >= batch_size:
			break
		
		# 检查标记是否在视野内
		if _is_marker_in_frustum(marker):
			marker.visible = true
		else:
			marker.visible = false
		
		processed += 1

func _is_marker_in_frustum(marker: Node3D) -> bool:
	"""检查标记是否在相机视锥体内"""
	if not camera_node:
		return true
	
	var marker_position = marker.global_position
	var camera_position = camera_node.global_position
	var distance = camera_position.distance_to(marker_position)
	
	# 简单的距离检查
	return distance <= lod_config.cull_distance

func set_lod_config(config: Dictionary):
	"""设置LOD配置"""
	lod_config.merge(config)
	
	# 更新定时器间隔
	if lod_timer:
		lod_timer.wait_time = lod_config.update_interval

func get_performance_stats() -> Dictionary:
	"""获取性能统计"""
	return {
		"total_markers": resource_markers.size(),
		"visible_markers": _count_visible_markers(),
		"lod_levels": marker_lod_levels.size(),
		"pending_updates": pending_marker_updates.size()
	}

func _count_visible_markers() -> int:
	"""统计可见标记数量"""
	var visible_count = 0
	for marker in resource_markers:
		if marker.visible:
			visible_count += 1
	return visible_count
