extends Node3D
# 网格管理器 - 负责管理可视化网格系统
# 提供虚线网格、坐标显示、导航辅助等功能
# 网格类型枚举
enum GridType {
	MAIN_GRID, # 主网格（大地图）
	MINOR_GRID, # 次要网格（细分）
	COORDINATE_GRID # 坐标网格（显示坐标）
}

# 网格样式枚举
enum GridStyle {
	DASHED, # 虚线
	SOLID, # 实线
	DOTTED # 点线
}

# 网格配置
var grid_config = {
	"enabled": true,
	"main_grid_size": 20.0, # 主网格大小（每20个单位一条线）
	"minor_grid_size": 5.0, # 次要网格大小（每5个单位一条线）
	"main_grid_color": Color(1.0, 1.0, 1.0, 0.5), # 主网格颜色（半透明白色）
	"minor_grid_color": Color(1.0, 1.0, 1.0, 0.2), # 次要网格颜色（更透明）
	"coordinate_color": Color(0.8, 0.8, 1.0, 0.6), # 坐标颜色
	"grid_style": GridStyle.DASHED,
	"show_coordinates": false,
	"grid_height": 0.5 # 网格高度（高于地面和建筑）
}

# 地图尺寸
var map_size: Vector3 = Vector3(100, 1, 100)
var tile_size: Vector3 = Vector3(1.0, 1.0, 1.0)
var grid_size: float = 1.0 # 网格单元大小

# 网格对象存储
var grid_objects: Array = []
var coordinate_objects: Array = []
var highlight_object: MeshInstance3D = null

# 节点引用
@onready var world: Node3D = get_node("/root/Main/World")
@onready var grid_container: Node3D = null
@onready var camera: Camera3D = get_node("/root/Main/World/Camera3D")


func _ready():
	"""初始化网格管理器"""
	LogManager.info("GridManager - 初始化开始")
	_setup_grid_container()
	# 等待一帧确保TileManager已初始化
	await get_tree().process_frame
	_update_map_size_from_tile_manager()
	_generate_grid()
	LogManager.info("GridManager - 初始化完成")


func _setup_grid_container():
	"""设置网格容器"""
	grid_container = Node3D.new()
	grid_container.name = "GridSystem"
	world.add_child(grid_container)


func _update_map_size_from_tile_manager():
	"""从TileManager获取实际地图尺寸"""
	var tile_manager = get_node("/root/Main/TileManager")
	if tile_manager and tile_manager.has_method("get_map_size"):
		var new_map_size = tile_manager.get_map_size()
		LogManager.info("GridManager - 从TileManager获取地图尺寸: " + str(new_map_size))
		if new_map_size != Vector3.ZERO:
			map_size = new_map_size
			LogManager.info("GridManager - 更新地图尺寸: " + str(map_size))
		else:
			LogManager.info("GridManager - TileManager返回零尺寸，保持默认: " + str(map_size))
	else:
		LogManager.info("GridManager - 无法获取TileManager，使用默认尺寸: " + str(map_size))


# 网格生成
func _generate_grid():
	"""生成网格"""
	if not grid_config.enabled:
		return

	LogManager.info("GridManager - 开始生成网格，地图尺寸: " + str(map_size))
	_clear_grid()
	_generate_main_grid()
	_generate_minor_grid()

	if grid_config.show_coordinates:
		_generate_coordinate_labels()
	
	LogManager.info("GridManager - 网格生成完成")


func _generate_main_grid():
	"""生成主网格"""
	var grid_spacing = grid_config.main_grid_size
	var color = grid_config.main_grid_color

	# 以地图中心为原点，覆盖四个象限
	var half_x = map_size.x / 2.0
	var half_z = map_size.z / 2.0
	var start_x = int(floor(-half_x))
	var end_x = int(ceil(half_x))
	var start_z = int(floor(-half_z))
	var end_z = int(ceil(half_z))
	var origin_offset = Vector3(half_x, grid_config.grid_height, half_z)

	LogManager.info("GridManager - 生成主网格，间距: " + str(grid_spacing) + " X[" + str(start_x) + ".." + str(end_x) + "] Z[" + str(start_z) + ".." + str(end_z) + "]")

	# X方向网格线（垂直于X轴）
	var x_lines = 0
	for x in range(start_x, end_x + 1, int(grid_spacing)):
		var start_pos = Vector3(x, 0.0, start_z) + origin_offset
		var end_pos = Vector3(x, 0.0, end_z) + origin_offset
		_create_grid_line(start_pos, end_pos, color, GridType.MAIN_GRID)
		x_lines += 1

	# Z方向网格线（垂直于Z轴）
	var z_lines = 0
	for z in range(start_z, end_z + 1, int(grid_spacing)):
		var start_pos = Vector3(start_x, 0.0, z) + origin_offset
		var end_pos = Vector3(end_x, 0.0, z) + origin_offset
		_create_grid_line(start_pos, end_pos, color, GridType.MAIN_GRID)
		z_lines += 1

	LogManager.info("GridManager - 主网格生成完成，X方向线条: " + str(x_lines) + " Z方向线条: " + str(z_lines))


func _generate_minor_grid():
	"""生成次要网格"""
	var grid_spacing = grid_config.minor_grid_size
	var color = grid_config.minor_grid_color

	# 以地图中心为原点，覆盖四个象限
	var half_x = map_size.x / 2.0
	var half_z = map_size.z / 2.0
	var start_x = int(floor(-half_x))
	var end_x = int(ceil(half_x))
	var start_z = int(floor(-half_z))
	var end_z = int(ceil(half_z))
	var origin_offset = Vector3(half_x, grid_config.grid_height, half_z)

	# X方向次要网格线
	for x in range(start_x, end_x + 1, int(grid_spacing)):
		# 跳过主网格线
		if int(abs(x)) % int(grid_config.main_grid_size) == 0:
			continue
		var start_pos = Vector3(x, 0.0, start_z) + origin_offset
		var end_pos = Vector3(x, 0.0, end_z) + origin_offset
		_create_grid_line(start_pos, end_pos, color, GridType.MINOR_GRID)

	# Z方向次要网格线
	for z in range(start_z, end_z + 1, int(grid_spacing)):
		# 跳过主网格线
		if int(abs(z)) % int(grid_config.main_grid_size) == 0:
			continue
		var start_pos = Vector3(start_x, 0.0, z) + origin_offset
		var end_pos = Vector3(end_x, 0.0, z) + origin_offset
		_create_grid_line(start_pos, end_pos, color, GridType.MINOR_GRID)


func _create_grid_line(start_pos: Vector3, end_pos: Vector3, color: Color, grid_type: GridType):
	"""创建网格线"""
	var line = MeshInstance3D.new()
	var mesh = _create_line_mesh(start_pos, end_pos, color)
	line.mesh = mesh
	line.position = (start_pos + end_pos) / 2

	# 设置网格类型
	line.set_meta("grid_type", grid_type)
	
	# 设置渲染属性（通过材质优先级确保可见）
	line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	grid_container.add_child(line)
	grid_objects.append(line)


func _create_line_mesh(start_pos: Vector3, end_pos: Vector3, color: Color) -> ArrayMesh:
	"""创建线条网格"""
	var mesh = ArrayMesh.new()
	var vertices = PackedVector3Array()
	var colors = PackedColorArray()

	# 根据网格样式创建不同的线条
	match grid_config.grid_style:
		GridStyle.DASHED:
			_create_dashed_line(vertices, colors, start_pos, end_pos, color)
		GridStyle.SOLID:
			_create_solid_line(vertices, colors, start_pos, end_pos, color)
		GridStyle.DOTTED:
			_create_dotted_line(vertices, colors, start_pos, end_pos, color)

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_COLOR] = colors

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	# 创建材质确保网格可见
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.flags_transparent = true
	material.flags_unshaded = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	material.render_priority = 1
	
	mesh.surface_set_material(0, material)
	return mesh


func _create_dashed_line(
	vertices: PackedVector3Array,
	colors: PackedColorArray,
	start: Vector3,
	end: Vector3,
	color: Color
):
	"""创建虚线"""
	var direction = (end - start).normalized()
	var distance = start.distance_to(end)
	var dash_length = 0.5
	var gap_length = 0.3

	var current_pos = 0.0
	var is_dash = true

	while current_pos < distance:
		var segment_length = dash_length if is_dash else gap_length
		var segment_end = min(current_pos + segment_length, distance)

		if is_dash:
			var segment_start_pos = start + direction * current_pos
			var segment_end_pos = start + direction * segment_end

			# 创建线段（使用两个点）
			vertices.append(segment_start_pos)
			vertices.append(segment_end_pos)
			colors.append(color)
			colors.append(color)

		current_pos = segment_end
		is_dash = not is_dash


func _create_solid_line(
	vertices: PackedVector3Array,
	colors: PackedColorArray,
	start: Vector3,
	end: Vector3,
	color: Color
):
	"""创建实线"""
	vertices.append(start)
	vertices.append(end)
	colors.append(color)
	colors.append(color)


func _create_dotted_line(
	vertices: PackedVector3Array,
	colors: PackedColorArray,
	start: Vector3,
	end: Vector3,
	color: Color
):
	"""创建点线"""
	var direction = (end - start).normalized()
	var distance = start.distance_to(end)
	var dot_spacing = 0.2

	var current_pos = 0.0
	while current_pos < distance:
		var dot_pos = start + direction * current_pos

		# 创建点（使用两个相同点）
		vertices.append(dot_pos)
		vertices.append(dot_pos)
		colors.append(color)
		colors.append(color)

		current_pos += dot_spacing


# 坐标标签生成
func _generate_coordinate_labels():
	"""生成坐标标签"""
	var spacing = int(grid_config.main_grid_size)

	for x in range(0, int(map_size.x) + 1, spacing):
		for z in range(0, int(map_size.z) + 1, spacing):
			var label_pos = Vector3(x, grid_config.grid_height + 0.2, z)
			_create_coordinate_label(label_pos, x, z)


func _create_coordinate_label(position: Vector3, x: int, z: int):
	"""创建坐标标签"""
	# 创建简单的3D文本标签
	var label_3d = Label3D.new()
	label_3d.text = str(x) + "," + str(z)
	label_3d.position = position
	label_3d.modulate = grid_config.coordinate_color
	label_3d.font_size = 12
	label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED

	grid_container.add_child(label_3d)
	coordinate_objects.append(label_3d)


# 网格控制
func toggle_grid():
	"""切换网格显示"""
	grid_config.enabled = not grid_config.enabled
	if grid_config.enabled:
		_generate_grid()
		LogManager.info("网格已启用")
	else:
		_clear_grid()
		LogManager.info("网格已禁用")


func toggle_coordinates():
	"""切换坐标显示"""
	grid_config.show_coordinates = not grid_config.show_coordinates
	if grid_config.show_coordinates:
		_generate_coordinate_labels()
		LogManager.info("坐标标签已启用")
	else:
		_clear_coordinates()
		LogManager.info("坐标标签已禁用")


func set_grid_style(style: GridStyle):
	"""设置网格样式"""
	grid_config.grid_style = style
	if grid_config.enabled:
		_generate_grid()
		LogManager.info("网格样式已更改为: " + str(style))


func set_grid_size(main_size: float, minor_size: float = 2.0):
	"""设置网格大小"""
	grid_config.main_grid_size = main_size
	grid_config.minor_grid_size = minor_size
	if grid_config.enabled:
		_generate_grid()
		LogManager.info("网格大小已更新: 主网格=" + str(main_size) + " 次要网格=" + str(minor_size))


func set_grid_colors(main_color: Color, minor_color: Color = Color(1.0, 1.0, 1.0, 0.1)):
	"""设置网格颜色"""
	grid_config.main_grid_color = main_color
	grid_config.minor_grid_color = minor_color
	if grid_config.enabled:
		_generate_grid()
		LogManager.info("网格颜色已更新")


# 清理函数
func _clear_grid():
	"""清理网格"""
	for obj in grid_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	grid_objects.clear()


func _clear_coordinates():
	"""清理坐标标签"""
	for obj in coordinate_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	coordinate_objects.clear()


func _clear_all():
	"""清理所有网格"""
	_clear_grid()
	_clear_coordinates()


# 工具函数
## 重复的辅助函数已移除（使用下方统一实现）


func get_grid_info() -> Dictionary:
	"""获取网格信息"""
	return {
		"enabled": grid_config.enabled,
		"main_grid_size": grid_config.main_grid_size,
		"minor_grid_size": grid_config.minor_grid_size,
		"style": grid_config.grid_style,
		"show_coordinates": grid_config.show_coordinates,
		"map_size": map_size
	}


# 更新地图尺寸
func update_map_size(new_size: Vector3):
	"""更新地图尺寸"""
	map_size = new_size
	if grid_config.enabled:
		_generate_grid()
		LogManager.info("地图尺寸已更新，网格已重新生成")


# 输入处理
func handle_input(event: InputEvent):
	"""处理输入事件"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_G:
				toggle_grid()


func _process(_delta: float):
	"""每帧更新"""
	# 🔧 禁用自动鼠标悬停高亮（避免与SelectionHighlightSystem冲突）
	# _update_mouse_highlight()  # 已禁用
	pass

func snap_to_grid(position: Vector3) -> Vector3:
	"""将位置对齐到网格中心
	
	修复：使用 floor() 对齐到格子左下角，然后 +0.5 居中
	避免 round() 导致的边界跳跃问题
	"""
	# 🔧 对齐到格子左下角（整数坐标）
	var grid_x = floor(position.x / grid_size)
	var grid_z = floor(position.z / grid_size)
	
	# 🔧 居中到格子中心
	var snapped_x = grid_x * grid_size + grid_size / 2.0
	var snapped_z = grid_z * grid_size + grid_size / 2.0
	
	return Vector3(snapped_x, position.y, snapped_z)


func get_grid_position(world_position: Vector3) -> Vector2i:
	"""获取世界坐标对应的网格坐标（格子左下角整数坐标）
	
	修复：使用 floor() 确保稳定性
	"""
	# 🔧 使用 floor() 对齐到格子左下角
	var grid_x = int(floor(world_position.x / grid_size))
	var grid_z = int(floor(world_position.z / grid_size))
	return Vector2i(grid_x, grid_z)


func get_world_position(grid_position: Vector2i) -> Vector3:
	"""获取网格坐标对应的世界坐标（格子中心）
	
	@param grid_position: 格子坐标（整数）
	@return: 格子中心的世界坐标 (x+0.5, 0, z+0.5)
	"""
	# 🔧 返回格子中心坐标
	var world_x = grid_position.x * grid_size + grid_size / 2.0
	var world_z = grid_position.y * grid_size + grid_size / 2.0
	return Vector3(world_x, 0, world_z)


func _update_mouse_highlight():
	"""更新鼠标高亮"""
	if not camera or not grid_config.enabled:
		return
	
	# 获取鼠标射线
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
	
	# 检测与地面的交点
	var space_state = world.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1 # 地面层
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_position = result.position
		var grid_position = snap_to_grid(hit_position)
		_show_grid_highlight(grid_position)
	else:
		_hide_grid_highlight()


func _show_grid_highlight(position: Vector3):
	"""显示网格高亮"""
	if not highlight_object:
		_create_highlight_object()
	
	highlight_object.position = position
	highlight_object.visible = true


func _hide_grid_highlight():
	"""隐藏网格高亮"""
	if highlight_object:
		highlight_object.visible = false


func _create_highlight_object():
	"""创建高亮对象"""
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(grid_size, grid_size)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 1.0, 0.0, 0.5) # 半透明黄色
	material.flags_transparent = true
	material.flags_unshaded = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	material.render_priority = 2
	
	highlight_object = MeshInstance3D.new()
	highlight_object.mesh = plane_mesh
	highlight_object.material_override = material
	highlight_object.position.y = 0.1 # 高于地面
	highlight_object.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	grid_container.add_child(highlight_object)


func cleanup():
	"""清理资源，防止内存泄漏"""
	LogManager.info("GridManager - 开始清理资源")
	
	# 清理网格容器
	if grid_container != null and is_instance_valid(grid_container):
		grid_container.queue_free()
		grid_container = null
	
	# 清理高亮对象
	if highlight_object != null and is_instance_valid(highlight_object):
		highlight_object.queue_free()
		highlight_object = null
	
	LogManager.info("GridManager - 资源清理完成")


func _exit_tree():
	"""节点退出时自动清理"""
	cleanup()


func regenerate_grid():
	"""重新生成网格"""
	LogManager.info("GridManager - 重新生成网格")
	_update_map_size_from_tile_manager()
	_generate_grid()