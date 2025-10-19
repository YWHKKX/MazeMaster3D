extends Node3D

## 🗺️ 地形高亮系统
## 基于空洞系统的3D地形高亮可视化系统
## 使用MultiMeshInstance3D优化渲染，支持悬停信息弹窗

# ============================================================================
# 核心配置参数
# ============================================================================

# 传统高亮实例池（保留用于兼容性）
var highlight_instances: Array[Node3D] = []
var active_highlights: Array[Node3D] = []
var region_highlights: Dictionary = {} # 地形类型 -> 区域高亮实例
var max_highlight_instances: int = 1000

# ============================================================================
# 🚀 MultiMeshInstance3D 优化渲染系统
# ============================================================================

# 每个地形类型使用一个MultiMeshInstance3D进行批量渲染
var terrain_meshes: Dictionary = {} # 地形类型 -> MultiMeshInstance3D
var shared_plane_mesh: PlaneMesh # 共享的平面网格资源
var highlight_materials: Dictionary = {} # 地形类型 -> StandardMaterial3D

# ============================================================================
# 🖱️ 悬停信息弹窗系统
# ============================================================================

var tooltip_ui: Control = null # 弹窗UI容器
var tooltip_label: RichTextLabel = null # 信息显示标签
var current_hovered_terrain: int = -1 # 当前悬停的地形类型
var terrain_position_map: Dictionary = {} # 位置 -> 地形类型映射
var camera: Camera3D = null # 3D相机引用

# ============================================================================
# 🎯 地形优先级和渲染配置
# ============================================================================

# 地形类型优先级系统（解决重叠区域的渲染冲突）
var terrain_priorities = {
	TerrainManager.TerrainType.WASTELAND: 9, # 荒地 - 最高优先级
	TerrainManager.TerrainType.FOREST: 8, # 森林
	TerrainManager.TerrainType.LAKE: 7, # 湖泊
	TerrainManager.TerrainType.CAVE: 6, # 洞穴
	TerrainManager.TerrainType.MAZE_SYSTEM: 5, # 迷宫系统
	TerrainManager.TerrainType.ROOM_SYSTEM: 4, # 房间系统
	TerrainManager.TerrainType.GRASSLAND: 3, # 草地
	TerrainManager.TerrainType.SWAMP: 2, # 沼泽
	TerrainManager.TerrainType.DEAD_LAND: 1 # 死地 - 最低优先级
}

# 高亮渲染模式配置
var use_precise_highlighting: bool = false # 精确模式 vs 优化模式

# 洪水填充算法配置
var flood_fill_strategy: String = "single_start" # 填充策略
var flood_fill_max_distance: int = 50 # 最大填充距离
var flood_fill_batch_size: int = 10 # 批处理大小

# ============================================================================
# 🔗 系统引用
# ============================================================================

# 地形数据源
var terrain_highlight_colors: Dictionary = {} # 地形颜色映射（从TerrainManager获取）
var map_generator: Node = null # 地图生成器
var tile_manager: Node = null # 瓦片管理器
var terrain_manager: TerrainManager = null # 地形管理器

# 空洞系统引用
var cavity_manager: Node = null # 空洞管理器

# ============================================================================
# 🚀 系统初始化
# ============================================================================

func _ready():
	"""初始化地形高亮系统"""
	# 获取系统引用
	_get_system_references()
	
	# 初始化空洞系统引用
	_initialize_cavity_system()
	
	# 初始化MultiMeshInstance3D优化系统
	_setup_shared_resources()
	_setup_terrain_meshes()
	
	# 初始化悬停信息弹窗系统
	_setup_tooltip_system()
	
	# 从TerrainManager加载地形颜色
	_load_terrain_colors_from_manager()
	
	# 创建高亮材质
	_create_highlight_materials()
	
	# 预创建高亮实例池
	_create_highlight_pool()
	
func _initialize_cavity_system():
	"""初始化空洞系统引用"""
	cavity_manager = get_node("/root/Main/MapGenerator/CavityManager")

func _check_system_status():
	"""检查 TileManager 状态"""
	if not tile_manager:
		LogManager.warning("TileManager 引用为空")
		return

func _get_tile_manager_statistics() -> Dictionary:
	"""从 TileManager 获取统计信息"""
	var stats = {
		"total_tiles": 0,
		"default_tiles": 0,
		"ecosystem_tiles": 0,
		"room_tiles": 0,
		"maze_tiles": 0,
		"hero_camp_tiles": 0
	}
	
	if not tile_manager:
		return stats
	
	var map_size = tile_manager.get_map_size()
	stats.total_tiles = int(map_size.x * map_size.z)
	
	# 统计各类型瓦片数量
	for x in range(int(map_size.x)):
		for z in range(int(map_size.z)):
			var pos = Vector3(x, 0, z)
			var tile_type = tile_manager.get_tile_type(pos)
			
			match tile_type:
				TileTypes.TileType.UNEXCAVATED:
					stats.default_tiles += 1
				# 其他类型根据具体实现统计
	
	return stats

func _get_system_references():
	"""获取系统引用"""
	# 获取系统引用
	var parent = get_parent()
	if parent and parent is MapGenerator:
		map_generator = parent
	
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_node("TileManager"):
		tile_manager = main_scene.get_node("TileManager")
	
	if main_scene and main_scene.has_node("TerrainManager"):
		terrain_manager = main_scene.get_node("TerrainManager")
	

func _get_terrain_manager_reference():
	"""延迟获取 TerrainManager 引用"""
	# 首先尝试从父节点获取
	var parent = get_parent()
	if parent and parent.has_node("TerrainManager"):
		terrain_manager = parent.get_node("TerrainManager")
		LogManager.info("TerrainHighlightSystem - 从父节点获取 TerrainManager 引用")
		return
	
	# 然后尝试从主场景获取
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_node("MapGenerator/TerrainManager"):
		terrain_manager = main_scene.get_node("MapGenerator/TerrainManager")
		LogManager.info("TerrainHighlightSystem - 从主场景获取 TerrainManager 引用")
		return
	
	LogManager.warning("TerrainHighlightSystem - 未找到 TerrainManager 节点")

func set_tile_manager(manager: Node) -> void:
	"""设置瓦片管理器"""
	tile_manager = manager
	LogManager.info("TerrainHighlightSystem - 瓦片管理器已设置")

func _load_terrain_colors_from_manager():
	"""从TerrainManager加载地形颜色"""
	if not terrain_manager:
		_get_terrain_manager_reference()
	
	if terrain_manager:
		terrain_highlight_colors = terrain_manager.get_all_terrain_colors()
	else:
		# 如果TerrainManager不可用，使用默认颜色
		terrain_highlight_colors = {
			TerrainManager.TerrainType.ROOM_SYSTEM: Color(0.8, 0.8, 0.8, 0.3),
			TerrainManager.TerrainType.MAZE_SYSTEM: Color(0.5, 0.5, 0.5, 0.3),
			TerrainManager.TerrainType.FOREST: Color(0.2, 0.8, 0.2, 0.3),
			TerrainManager.TerrainType.GRASSLAND: Color(0.6, 0.9, 0.6, 0.3),
			TerrainManager.TerrainType.LAKE: Color(0.2, 0.6, 1.0, 0.3),
			TerrainManager.TerrainType.CAVE: Color(0.4, 0.2, 0.4, 0.3),
			TerrainManager.TerrainType.WASTELAND: Color(0.8, 0.6, 0.2, 0.3),
			TerrainManager.TerrainType.SWAMP: Color(0.4, 0.6, 0.2, 0.3),
			TerrainManager.TerrainType.DEAD_LAND: Color(0.3, 0.3, 0.3, 0.3),
		}

func _create_highlight_materials():
	"""创建高亮材质"""
	for terrain_type in terrain_highlight_colors.keys():
		var material = StandardMaterial3D.new()
		material.albedo_color = terrain_highlight_colors[terrain_type]
		material.flags_transparent = true
		material.flags_unshaded = true
		material.flags_do_not_receive_shadows = true
		material.flags_disabled = false
		material.noise_enabled = false
		
		highlight_materials[terrain_type] = material
	

func _create_highlight_pool():
	"""创建高亮实例池"""
	# 预创建50个高亮实例
	for i in range(50):
		var highlight_instance = _create_highlight_instance()
		highlight_instance.visible = false
		highlight_instances.append(highlight_instance)
		add_child(highlight_instance)
	

func _create_highlight_instance() -> Node3D:
	"""创建单个高亮实例"""
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(1.5, 1.0, 1.5) # 更大的高亮方块
	mesh_instance.mesh = box_mesh
	
	# 设置默认材质
	var default_material = StandardMaterial3D.new()
	default_material.albedo_color = Color(1.0, 1.0, 0.0, 0.9)
	default_material.flags_transparent = true
	default_material.flags_unshaded = true
	default_material.flags_disable_ambient_light = true
	default_material.flags_do_not_use_in_environment = true
	default_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	default_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	default_material.no_depth_test = false
	default_material.alpha_scissor_threshold = 0.1
	mesh_instance.material_override = default_material
	
	return mesh_instance

# ============================================================================
# 🎨 高亮控制功能
# ============================================================================

func highlight_terrain_area(positions: Array[Vector3], terrain_type: int) -> void:
	"""高亮指定区域的地形"""
	# 将Vector3位置转换为Vector2i
	var positions_2d: Array[Vector2i] = []
	for pos in positions:
		positions_2d.append(Vector2i(pos.x, pos.z))
	
	# 获取高亮颜色
	var highlight_color = Color.YELLOW
	var terrain_enum = _int_to_terrain_type(terrain_type)
	if terrain_enum in terrain_highlight_colors:
		highlight_color = terrain_highlight_colors[terrain_enum]
	else:
		highlight_color = Color.YELLOW
	
	var highlighted_count = _highlight_positions_batch(positions_2d, highlight_color)

# 瓦片级高亮方法已移除 - 现在使用空洞系统

# ============================================================================
# 🧹 高亮管理功能
# ============================================================================

func clear_all_highlights() -> void:
	"""清除所有高亮"""
	# 清除传统高亮
	for highlight in active_highlights:
		if highlight and is_instance_valid(highlight):
			highlight.visible = false
	
	active_highlights.clear()
	
	# 清除区域高亮
	clear_region_highlights()
	
	# 清除MultiMeshInstance3D高亮
	clear_terrain_meshes()
	

func clear_highlights_by_type(terrain_type: int) -> void:
	"""清除指定类型的高亮"""
	var to_remove: Array[Node3D] = []
	
	for highlight in active_highlights:
		if highlight and is_instance_valid(highlight):
			var material = highlight.material_override as StandardMaterial3D
			if material and material.albedo_color == terrain_highlight_colors.get(terrain_type):
				highlight.visible = false
				to_remove.append(highlight)
	
	for highlight in to_remove:
		active_highlights.erase(highlight)
	

func toggle_highlight_visibility(visible: bool) -> void:
	"""切换高亮可见性"""
	for highlight in active_highlights:
		if highlight and is_instance_valid(highlight):
			highlight.visible = visible
	

# ============================================================================
# 🔧 工具函数
# ============================================================================

func _get_highlight_instance() -> Node3D:
	"""从池中获取高亮实例"""
	# 优先从池中获取可用实例
	for instance in highlight_instances:
		if not instance.visible:
			return instance
	
	# 不再限制实例数量，使用区域合并策略
	
	# 创建新实例
	var new_instance = _create_highlight_instance()
	highlight_instances.append(new_instance)
	add_child(new_instance)
	
	return new_instance

func _get_terrain_type_at_position(position: Vector3) -> int:
	"""获取指定位置的地形类型"""
	# 尝试从瓦片管理器获取
	if tile_manager and tile_manager.has_method("get_tile_type"):
		return tile_manager.get_tile_type(position)
	
	# 尝试从地图生成器获取
	if map_generator and map_generator.has_method("get_terrain_type_at"):
		return map_generator.get_terrain_type_at(position)
	
	# 默认返回石质地板
	return TileTypes.TileType.STONE_FLOOR

# ============================================================================
# 🎯 预设高亮模式
# ============================================================================

# 传统瓦片级高亮方法已移除 - 现在使用空洞系统

func highlight_all_terrain_types_async() -> void:
	"""异步高亮所有地形类型 - 避免阻塞主线程"""
	_highlight_all_terrain_types_async_task()

func _highlight_all_terrain_types_async_task() -> void:
	"""异步高亮任务"""
	# 在下一帧执行，避免阻塞
	await get_tree().process_frame
	highlight_all_terrain_types()

func highlight_all_terrain_types() -> void:
	"""高亮所有地形类型 - 使用空洞中心进行洪水填充高亮"""
	# 尝试重新获取 TerrainManager 引用
	if not terrain_manager:
		_get_terrain_manager_reference()
	
	if not terrain_manager:
		LogManager.error("TerrainManager 未初始化，无法获取地形数据")
		return

	# 清除之前的高亮
	clear_all_highlights()

	# 使用新的区域高亮系统
	highlight_terrain_regions()

# ============================================================================
# ⚡ 批量高亮功能
# ============================================================================

func _highlight_positions_batch(positions: Array[Vector2i], highlight_color: Color) -> int:
	"""批量高亮位置列表 - 智能选择高亮模式"""
	if positions.size() == 0:
		return 0
	
	# 智能选择高亮模式
	var should_use_precise = _should_use_precise_highlighting(positions)
	
	if should_use_precise:
		# 精确模式：为每个位置创建高亮实例
		return _highlight_positions_precise(positions, highlight_color)
	else:
		# 优化模式：使用区域合并
		return _highlight_positions_optimized(positions, highlight_color)

func _should_use_precise_highlighting(positions: Array[Vector2i]) -> bool:
	"""智能判断是否使用精确高亮模式"""
	# 如果位置数量很少，使用精确模式
	if positions.size() <= 100:
		return true
	
	# 如果位置数量很多，使用优化模式
	if positions.size() > 1000:
		return false
	
	# 如果用户明确设置了模式，使用用户设置
	return use_precise_highlighting

func _highlight_positions_precise(positions: Array[Vector2i], highlight_color: Color) -> int:
	"""精确模式：为每个位置创建高亮实例"""
	var highlighted_count = 0
	
	for pos in positions:
		if highlighted_count >= max_highlight_instances:
			break
			
		var position = Vector3(pos.x, 0, pos.y)
		var highlight_instance = _get_highlight_instance()
		if highlight_instance:
			highlight_instance.position = position
			# 创建临时材质
			var temp_material = StandardMaterial3D.new()
			temp_material.albedo_color = highlight_color
			temp_material.flags_transparent = true
			temp_material.flags_unshaded = true
			highlight_instance.material_override = temp_material
			highlight_instance.visible = true
			active_highlights.append(highlight_instance)
			highlighted_count += 1
	
	return highlighted_count

func _highlight_positions_optimized(positions: Array[Vector2i], highlight_color: Color) -> int:
	"""优化模式：直接高亮所有位置，使用批量处理"""
	if positions.size() == 0:
		return 0
	
	# 限制处理的位置数量，避免卡顿
	var max_positions_to_process = 5000
	var positions_to_process = positions
	if positions.size() > max_positions_to_process:
		positions_to_process = positions.slice(0, max_positions_to_process)
	
	# 直接高亮所有位置，不使用洪水填充
	var highlight_count = 0
	var max_highlights = min(max_highlight_instances, 100)
	
	for pos in positions_to_process:
		if highlight_count >= max_highlights:
			break
		
		var highlight_instance = _create_single_position_highlight(pos, highlight_color)
		if highlight_instance:
			active_highlights.append(highlight_instance)
			highlight_count += 1
	
	return highlight_count

# ============================================================================
# 🌊 洪水填充算法和区域合并
# ============================================================================

func _find_connected_regions(positions: Array[Vector2i]) -> Array:
	"""使用洪水填充算法找到所有相邻的区域"""
	var regions: Array = []
	var visited: Dictionary = {}
	
	for pos in positions:
		if visited.has(pos):
			continue
		
		# 开始洪水填充
		var region: Array = []
		var stack: Array = [pos]
		
		while stack.size() > 0:
			var current_pos = stack.pop_back()
			
			if visited.has(current_pos):
				continue
			
			visited[current_pos] = true
			region.append(current_pos)
			
			# 检查相邻位置
			var neighbors = _get_neighbors_4_direction(current_pos)
			for neighbor in neighbors:
				if positions.has(neighbor) and not visited.has(neighbor):
					stack.append(neighbor)
		
		if region.size() > 0:
			regions.append(region)
	
	return regions

func _flood_fill_highlight_regions(positions: Array[Vector2i], highlight_color: Color) -> int:
	"""洪水填充系统 - 一次性确定所有需要高亮的地块，支持多策略"""
	if positions.size() == 0:
		return 0
	
	# 根据策略选择填充方法
	match flood_fill_strategy:
		"single_start":
			return _flood_fill_single_start(positions, highlight_color)
		"multi_start":
			return _flood_fill_multi_start(positions, highlight_color)
		"adaptive":
			return _flood_fill_adaptive(positions, highlight_color)
		_:
			return _flood_fill_single_start(positions, highlight_color)

func _flood_fill_single_start(positions: Array[Vector2i], highlight_color: Color) -> int:
	"""单起点洪水填充 - 从第一个位置开始扩散"""
	if positions.size() == 0:
		return 0
	
	# 创建位置集合，O(1)查找
	var position_set: Dictionary = {}
	for pos in positions:
		position_set[pos] = true
	
	var visited: Dictionary = {}
	var highlight_count = 0
	var max_highlights = min(max_highlight_instances, 100)
	
	# 从第一个位置开始洪水填充
	var queue: Array = [positions[0]]
	
	while queue.size() > 0 and highlight_count < max_highlights:
		var current_pos = queue.pop_front()
		
		if visited.has(current_pos):
			continue
		
		visited[current_pos] = true
		
		# 创建高亮实例
		var highlight_instance = _create_single_position_highlight(current_pos, highlight_color)
		if highlight_instance:
			active_highlights.append(highlight_instance)
			highlight_count += 1
		
		# 检查相邻位置 - 只检查在position_set中的位置
		var neighbors = _get_neighbors_4_direction(current_pos)
		for neighbor in neighbors:
			if position_set.has(neighbor) and not visited.has(neighbor):
				queue.append(neighbor)
	
	return highlight_count

func _flood_fill_multi_start(positions: Array[Vector2i], highlight_color: Color) -> int:
	"""多起点洪水填充 - 从多个位置同时开始扩散"""
	if positions.size() == 0:
		return 0
	
	# 创建位置集合
	var position_set: Dictionary = {}
	for pos in positions:
		position_set[pos] = true
	
	var visited: Dictionary = {}
	var highlight_count = 0
	var max_highlights = min(max_highlight_instances, 100)
	
	# 从多个位置开始洪水填充
	var queue: Array = []
	var start_positions = positions.slice(0, min(5, positions.size())) # 最多5个起点
	for pos in start_positions:
		queue.append(pos)
	
	while queue.size() > 0 and highlight_count < max_highlights:
		var current_pos = queue.pop_front()
		
		if visited.has(current_pos):
			continue
		
		visited[current_pos] = true
		
		# 创建高亮实例
		var highlight_instance = _create_single_position_highlight(current_pos, highlight_color)
		if highlight_instance:
			active_highlights.append(highlight_instance)
			highlight_count += 1
		
		# 检查相邻位置
		var neighbors = _get_neighbors_4_direction(current_pos)
		for neighbor in neighbors:
			if position_set.has(neighbor) and not visited.has(neighbor):
				queue.append(neighbor)
	
	return highlight_count

func _flood_fill_adaptive(positions: Array[Vector2i], highlight_color: Color) -> int:
	"""自适应洪水填充 - 根据位置分布自动选择策略"""
	if positions.size() == 0:
		return 0
	
	# 分析位置分布
	var density = _analyze_position_density(positions)
	
	if density > 0.7: # 高密度，使用单起点
		return _flood_fill_single_start(positions, highlight_color)
	elif density > 0.3: # 中密度，使用多起点
		return _flood_fill_multi_start(positions, highlight_color)
	else: # 低密度，使用精确模式
		return _highlight_positions_precise(positions, highlight_color)

func _analyze_position_density(positions: Array[Vector2i]) -> float:
	"""分析位置分布密度"""
	if positions.size() <= 1:
		return 0.0
	
	# 计算边界框
	var min_x = positions[0].x
	var max_x = positions[0].x
	var min_y = positions[0].y
	var max_y = positions[0].y
	
	for pos in positions:
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)
	
	var area = (max_x - min_x + 1) * (max_y - min_y + 1)
	var density = float(positions.size()) / float(area)
	
	return density

func _flood_fill_highlight_from_centers(centers: Array[Vector2i], positions: Array[Vector3], highlight_color: Color) -> int:
	"""从空洞中心开始进行洪水填充高亮"""
	if centers.size() == 0 or positions.size() == 0:
		return 0
	
	var highlighted_count = 0
	var max_highlights = min(max_highlight_instances, 500) # 限制高亮数量
	
	# 为每个中心进行洪水填充高亮
	for center in centers:
		if highlighted_count >= max_highlights:
			break
		
		# 从中心开始洪水填充
		var flood_positions = _flood_fill_from_center(center, positions)
		
		# 高亮洪水填充的位置
		for pos in flood_positions:
			if highlighted_count >= max_highlights:
				break
			
			var highlight_instance = _create_single_position_highlight(pos, highlight_color)
			if highlight_instance:
				active_highlights.append(highlight_instance)
				highlighted_count += 1
	
	return highlighted_count

func _flood_fill_from_center(center: Vector2i, all_positions: Array[Vector3]) -> Array[Vector2i]:
	"""从中心开始洪水填充，返回高亮位置"""
	var flood_positions: Array[Vector2i] = []
	var visited: Dictionary = {}
	var queue: Array[Vector2i] = [center]
	
	# 将3D位置转换为2D位置字典，便于快速查找
	var position_dict: Dictionary = {}
	for pos in all_positions:
		var pos_2d = Vector2i(int(pos.x), int(pos.z))
		position_dict[pos_2d] = true
	
	# 洪水填充
	while not queue.is_empty() and flood_positions.size() < 100: # 限制每个中心最多100个位置
		var current = queue.pop_front()
		
		if current in visited:
			continue
		
		visited[current] = true
		
		# 检查当前位置是否在空洞内
		if position_dict.has(current):
			flood_positions.append(current)
			
			# 添加4个方向的邻居到队列
			var directions = [
				Vector2i(1, 0), Vector2i(-1, 0),
				Vector2i(0, 1), Vector2i(0, -1)
			]
			
			for dir in directions:
				var neighbor = current + dir
				if neighbor not in visited:
					queue.append(neighbor)
	
	return flood_positions

func _get_terrain_type_name(terrain_type: int) -> String:
	"""获取地形类型名称 - 从TerrainManager获取"""
	if terrain_manager:
		# 将数字索引转换为TerrainType枚举
		var terrain_enum = _int_to_terrain_type(terrain_type)
		return terrain_manager.get_terrain_type_name(terrain_enum)
	else:
		# 如果TerrainManager不可用，使用默认名称
		var default_names = {
			0: "房间", 1: "迷宫", 2: "森林", 3: "草地", 4: "湖泊",
			5: "洞穴", 6: "荒地", 7: "沼泽", 8: "死地", 9: "英雄营地"
		}
		return default_names.get(terrain_type, "未知地形")

func _int_to_terrain_type(terrain_int: int) -> TerrainManager.TerrainType:
	"""将数字索引转换为TerrainType枚举"""
	match terrain_int:
		0: return TerrainManager.TerrainType.ROOM_SYSTEM
		1: return TerrainManager.TerrainType.MAZE_SYSTEM
		2: return TerrainManager.TerrainType.FOREST
		3: return TerrainManager.TerrainType.GRASSLAND
		4: return TerrainManager.TerrainType.LAKE
		5: return TerrainManager.TerrainType.CAVE
		6: return TerrainManager.TerrainType.WASTELAND
		7: return TerrainManager.TerrainType.SWAMP
		8: return TerrainManager.TerrainType.DEAD_LAND
		_: return TerrainManager.TerrainType.ROOM_SYSTEM


func _create_single_position_highlight(pos: Vector2i, highlight_color: Color) -> Node3D:
	"""为单个位置创建高亮实例"""
	var highlight_instance = _get_highlight_instance()
	if not highlight_instance:
		return null
	
	# 设置位置 - 抬高到合适的高度，避免与地面重叠
	highlight_instance.position = Vector3(pos.x, 0.5, pos.y)
	
	# 创建材质 - 使用更明显的颜色和设置
	var temp_material = StandardMaterial3D.new()
	temp_material.albedo_color = Color(highlight_color.r, highlight_color.g, highlight_color.b, 0.9)
	temp_material.flags_transparent = true
	temp_material.flags_unshaded = true
	temp_material.flags_disable_ambient_light = true
	temp_material.flags_do_not_use_in_environment = true
	temp_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	temp_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	temp_material.no_depth_test = false
	temp_material.alpha_scissor_threshold = 0.1
	highlight_instance.material_override = temp_material
	
	# 设置为1x1的方块 - 增加高度使其更明显
	if highlight_instance is MeshInstance3D:
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(1.5, 1.0, 1.5)
		highlight_instance.mesh = box_mesh
	
	highlight_instance.visible = true
	
	return highlight_instance

func _get_neighbors_4_direction(pos: Vector2i) -> Array:
	"""获取4方向的相邻位置"""
	return [
		Vector2i(pos.x + 1, pos.y),
		Vector2i(pos.x - 1, pos.y),
		Vector2i(pos.x, pos.y + 1),
		Vector2i(pos.x, pos.y - 1)
	]

func _calculate_region_bounds(region: Array) -> Dictionary:
	"""计算区域的边界框"""
	if region.size() == 0:
		return {}
	
	var min_x = region[0].x
	var max_x = region[0].x
	var min_z = region[0].y
	var max_z = region[0].y
	
	for pos in region:
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_z = min(min_z, pos.y)
		max_z = max(max_z, pos.y)
	
	return {
		"min_x": min_x,
		"max_x": max_x,
		"min_z": min_z,
		"max_z": max_z,
		"width": max_x - min_x + 1,
		"height": max_z - min_z + 1,
		"center": Vector3((min_x + max_x) / 2.0, 0, (min_z + max_z) / 2.0),
		"positions": region
	}


func _create_region_highlight(bounds: Dictionary, highlight_color: Color) -> Node3D:
	"""为区域创建大的高亮实例"""
	if bounds.is_empty():
		return null
	
	var highlight_instance = _get_highlight_instance()
	if not highlight_instance:
		return null
	
	# 设置位置到区域中心
	highlight_instance.position = bounds.center
	
	# 创建区域大小的高亮
	if highlight_instance is MeshInstance3D:
		# 创建平面网格
		var plane_mesh = PlaneMesh.new()
		plane_mesh.size = Vector2(bounds.width, bounds.height)
		highlight_instance.mesh = plane_mesh
		
		# 创建材质
		var temp_material = StandardMaterial3D.new()
		temp_material.albedo_color = highlight_color
		temp_material.flags_transparent = true
		temp_material.flags_unshaded = true
		temp_material.flags_disable_ambient_light = true
		highlight_instance.material_override = temp_material
	
	highlight_instance.visible = true
	
	return highlight_instance

# ============================================================================
# 🔧 辅助函数
# ============================================================================

func _get_ecosystem_type_name(eco_type: int) -> String:
	"""获取生态系统类型名称"""
	match eco_type:
		MapGenerator.EcosystemType.FOREST:
			return "森林"
		MapGenerator.EcosystemType.GRASSLAND:
			return "草地"
		MapGenerator.EcosystemType.LAKE:
			return "湖泊"
		MapGenerator.EcosystemType.CAVE:
			return "洞穴"
		MapGenerator.EcosystemType.WASTELAND:
			return "荒地"
		MapGenerator.EcosystemType.DEAD_LAND:
			return "死地"
		_:
			return "未知类型(%d)" % eco_type

# ============================================================================
# 🐛 调试功能
# ============================================================================

func debug_highlight_system() -> void:
	"""调试高亮系统状态"""
	LogManager.info("=== 地形高亮系统调试信息 ===")
	LogManager.info("高亮材质数量: %d" % highlight_materials.size())
	LogManager.info("高亮实例池大小: %d" % highlight_instances.size())
	LogManager.info("活跃高亮数量: %d" % active_highlights.size())
	LogManager.info("地图生成器引用: %s" % (map_generator != null))
	LogManager.info("瓦片管理器引用: %s" % (tile_manager != null))
	LogManager.info("当前高亮模式: %s" % ("精确模式" if use_precise_highlighting else "优化模式"))
	LogManager.info("最大高亮实例数: %d" % max_highlight_instances)
	LogManager.info("===============================")

func get_performance_stats() -> Dictionary:
	"""获取性能统计信息"""
	return {
		"highlight_materials_count": highlight_materials.size(),
		"highlight_instances_count": highlight_instances.size(),
		"active_highlights_count": active_highlights.size(),
		"max_highlight_instances": max_highlight_instances,
		"use_precise_highlighting": use_precise_highlighting,
		"map_generator_available": map_generator != null,
		"tile_manager_available": tile_manager != null,
		"flood_fill_strategy": flood_fill_strategy,
		"flood_fill_max_distance": flood_fill_max_distance,
		"flood_fill_batch_size": flood_fill_batch_size
	}

func test_highlight_patterns() -> void:
	"""测试各种高亮模式"""
	
	# 测试空洞高亮
	highlight_cavity_by_type("ecosystem")
	
	# 等待2秒
	await get_tree().create_timer(2.0).timeout
	
	# 测试房间高亮
	highlight_cavity_by_content("ROOM_SYSTEM")
	
	# 等待2秒
	await get_tree().create_timer(2.0).timeout
	
	# 清除所有高亮
	clear_all_highlights()
	

func test_flood_fill_strategies() -> void:
	"""测试洪水填充策略"""
	
	# 创建测试位置
	var test_positions: Array[Vector2i] = []
	for i in range(20):
		for j in range(20):
			test_positions.append(Vector2i(i * 2, j * 2))
	
	# 测试单起点策略
	set_flood_fill_strategy("single_start")
	clear_all_highlights()
	_flood_fill_highlight_regions(test_positions, Color.RED)
	
	await get_tree().create_timer(2.0).timeout
	
	# 测试多起点策略
	set_flood_fill_strategy("multi_start")
	clear_all_highlights()
	_flood_fill_highlight_regions(test_positions, Color.GREEN)
	
	await get_tree().create_timer(2.0).timeout
	
	# 测试自适应策略
	set_flood_fill_strategy("adaptive")
	clear_all_highlights()
	_flood_fill_highlight_regions(test_positions, Color.BLUE)
	
	await get_tree().create_timer(2.0).timeout
	
	# 清除所有高亮
	clear_all_highlights()
	

func toggle_highlight_mode() -> void:
	"""切换高亮模式"""
	use_precise_highlighting = !use_precise_highlighting
	
	# 清除当前高亮并重新高亮
	clear_all_highlights()
	debug_highlight_system()

func set_highlight_mode(precise: bool) -> void:
	"""设置高亮模式"""
	use_precise_highlighting = precise

func set_flood_fill_strategy(strategy: String) -> void:
	"""设置洪水填充策略"""
	if strategy in ["single_start", "multi_start", "adaptive"]:
		flood_fill_strategy = strategy
	else:
		LogManager.warning("无效的洪水填充策略: %s" % strategy)

func set_flood_fill_parameters(max_distance: int, batch_size: int) -> void:
	"""设置洪水填充参数"""
	flood_fill_max_distance = max_distance
	flood_fill_batch_size = batch_size

# ============================================================================
# 🕳️ 空洞级高亮方法
# ============================================================================

func highlight_cavity_by_type(cavity_type: String) -> void:
	"""高亮指定类型的所有空洞"""
	if not cavity_manager:
		LogManager.error("空洞管理器未初始化，无法高亮空洞")
		return
	
	var cavities = cavity_manager.get_cavities_by_type(cavity_type)
	if cavities.is_empty():
		LogManager.warning("未找到类型为 %s 的空洞" % cavity_type)
		return
	
	# 清除之前的高亮
	clear_all_highlights()
	
	# 高亮所有匹配的空洞
	for cavity in cavities:
		_highlight_cavity_boundary(cavity)
	
	LogManager.info("高亮 %d 个 %s 类型空洞" % [cavities.size(), cavity_type])

func highlight_cavity_by_content(content_type: String) -> void:
	"""高亮指定内容类型的所有空洞"""
	if not cavity_manager:
		LogManager.error("空洞管理器未初始化，无法高亮空洞")
		return
	
	var cavities = cavity_manager.get_cavities_by_content(content_type)
	if cavities.is_empty():
		LogManager.warning("未找到内容类型为 %s 的空洞" % content_type)
		return
	
	# 清除之前的高亮
	clear_all_highlights()
	
	# 高亮所有匹配的空洞
	for cavity in cavities:
		_highlight_cavity_boundary(cavity)
	
	LogManager.info("高亮 %d 个 %s 内容类型空洞" % [cavities.size(), content_type])

func highlight_cavity_by_id(cavity_id: String) -> void:
	"""高亮指定ID的空洞"""
	if not cavity_manager:
		LogManager.error("空洞管理器未初始化，无法高亮空洞")
		return
	
	var cavity = cavity_manager.get_cavity_by_id(cavity_id)
	if not cavity:
		LogManager.warning("未找到空洞: %s" % cavity_id)
		return
	
	# 清除之前的高亮
	clear_all_highlights()
	
	# 高亮指定空洞
	_highlight_cavity_boundary(cavity)
	LogManager.info("高亮空洞: %s" % cavity_id)

func highlight_all_cavity_boundaries() -> void:
	"""高亮所有空洞边界"""
	if not cavity_manager:
		LogManager.error("空洞管理器未初始化，无法高亮空洞")
		return
	
	var all_cavities = cavity_manager.get_all_cavities()
	if all_cavities.is_empty():
		LogManager.warning("没有找到任何空洞")
		return
	
	# 清除之前的高亮
	clear_all_highlights()
	
	# 高亮所有空洞边界
	for cavity in all_cavities:
		_highlight_cavity_boundary(cavity)
	
	LogManager.info("高亮所有空洞边界: %d 个空洞" % all_cavities.size())

func highlight_all_cavity_centers() -> void:
	"""高亮所有空洞中心"""
	if not cavity_manager:
		LogManager.error("空洞管理器未初始化，无法高亮空洞")
		return
	
	var all_cavities = cavity_manager.get_all_cavities()
	if all_cavities.is_empty():
		LogManager.warning("没有找到任何空洞")
		return
	
	# 清除之前的高亮
	clear_all_highlights()
	
	# 高亮所有空洞中心
	for cavity in all_cavities:
		_highlight_cavity_center(cavity)
	
	LogManager.info("高亮所有空洞中心: %d 个空洞" % all_cavities.size())

func clear_cavity_highlights() -> void:
	"""清除空洞高亮"""
	clear_all_highlights()
	LogManager.info("已清除所有空洞高亮")

func _highlight_cavity_boundary(cavity) -> void:
	"""高亮空洞边界"""
	if not cavity or cavity.positions.is_empty():
		return
	
	# 获取高亮材质
	var highlight_material = _get_highlight_material_for_cavity(cavity)
	
	# 高亮空洞边界
	var boundary_positions = cavity.get_boundary_positions()
	for pos in boundary_positions:
		_highlight_tile_at_position(pos, highlight_material)

func _highlight_cavity_center(cavity) -> void:
	"""高亮空洞中心"""
	if not cavity:
		return
	
	# 获取高亮材质
	var highlight_material = _get_highlight_material_for_cavity(cavity)
	
	# 高亮空洞中心
	var center_pos = cavity.get_center_position()
	_highlight_tile_at_position(center_pos, highlight_material)

func _get_highlight_material_for_cavity(cavity) -> StandardMaterial3D:
	"""为空洞获取高亮材质"""
	var content_type = cavity.content_type
	if highlight_materials.has(content_type):
		return highlight_materials[content_type]
	
	var material = StandardMaterial3D.new()
	var base_color = _get_base_color_for_content_type(content_type)
	material.albedo_color = base_color
	material.emission_enabled = true
	material.emission = base_color * 0.5
	material.flags_transparent = true
	material.flags_unshaded = true
	
	highlight_materials[content_type] = material
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

func _highlight_tile_at_position(pos: Vector3, material: StandardMaterial3D) -> void:
	"""高亮指定位置的瓦片"""
	if not tile_manager:
		return
	
	var tile_data = tile_manager.get_tile_data(pos)
	if tile_data and tile_data.tile_object:
		tile_data.tile_object.set_surface_override_material(0, material)

# 瓦片模式相关函数已移除 - 系统现在完全基于空洞模式

# ============================================================================
# 🎯 统一高亮接口
# ============================================================================

func highlight_ecosystem_areas() -> void:
	"""高亮生态系统区域"""
	highlight_cavity_by_type("ecosystem")

func highlight_room_areas() -> void:
	"""高亮房间区域"""
	highlight_cavity_by_content("ROOM_SYSTEM")

func highlight_maze_areas() -> void:
	"""高亮迷宫区域"""
	highlight_cavity_by_content("MAZE_SYSTEM")

func highlight_critical_areas() -> void:
	"""高亮关键区域"""
	highlight_cavity_by_type("critical")

# ============================================================================
# 🧪 调试和测试方法
# ============================================================================

func test_cavity_highlight_system() -> void:
	"""测试空洞高亮系统"""
	
	if not cavity_manager:
		LogManager.error("空洞管理器未初始化")
		return
	
	# 测试高亮所有空洞边界
	highlight_all_cavity_boundaries()
	
	# 等待2秒
	await get_tree().create_timer(2.0).timeout
	
	# 测试高亮生态系统空洞
	highlight_cavity_by_type("ecosystem")
	
	# 等待2秒
	await get_tree().create_timer(2.0).timeout
	
	# 测试高亮森林空洞
	highlight_cavity_by_content("FOREST")
	
	# 等待2秒
	await get_tree().create_timer(2.0).timeout
	
	# 清除高亮
	clear_cavity_highlights()
	

func get_cavity_highlight_info() -> Dictionary:
	"""获取空洞高亮信息"""
	if not cavity_manager:
		return {"error": "空洞管理器未初始化"}
	
	return {
		"registered_cavities": cavity_manager.get_cavity_count(),
		"highlight_enabled": true,
		"material_cache_size": highlight_materials.size(),
		"tile_manager_ready": tile_manager != null
	}

func print_cavity_highlight_status() -> void:
	"""打印空洞高亮状态"""
	if not cavity_manager:
		LogManager.error("空洞管理器未初始化")
		return
	
	LogManager.info("=== 空洞高亮状态 ===")
	LogManager.info("注册空洞数: %d" % cavity_manager.get_cavity_count())
	LogManager.info("高亮启用: 是")
	LogManager.info("材质缓存大小: %d" % highlight_materials.size())
	LogManager.info("瓦片管理器就绪: %s" % ("是" if tile_manager else "否"))
	LogManager.info("==================")

# ============================================================================
# 🎨 区域高亮系统 - 将洪水填充的地块整理为一个高亮实例
# ============================================================================

func _create_terrain_region_highlight(terrain_type: int, positions: Array, color: Color) -> Node3D:
	"""为地形区域创建单个合并的高亮实例"""
	# 创建区域高亮节点
	var region_highlight = Node3D.new()
	region_highlight.name = "RegionHighlight_%d" % terrain_type
	
	# 为每个位置创建3D高亮平面
	for pos in positions:
		var highlight_plane = _create_3d_highlight_plane(pos, color)
		if highlight_plane:
			region_highlight.add_child(highlight_plane)
	
	return region_highlight

func _create_3d_highlight_plane(pos: Vector2i, color: Color) -> MeshInstance3D:
	"""创建3D高亮平面"""
	var mesh_instance = MeshInstance3D.new()
	
	# 创建平面网格
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(1.0, 1.0)
	mesh_instance.mesh = plane_mesh
	
	# 设置位置 (使用x和z坐标，y固定为1.2)
	mesh_instance.position = Vector3(pos.x, 1.2, pos.y)
	
	# 设置材质
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.flags_transparent = true
	material.flags_unshaded = true
	material.flags_do_not_receive_shadows = true
	material.flags_disabled = false
	material.noise_enabled = false
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	mesh_instance.material_override = material
	return mesh_instance


func highlight_terrain_regions() -> void:
	"""使用MultiMeshInstance3D高亮地形区域 - 异步优化版"""
	
	# 启动异步高亮处理
	_highlight_terrain_regions_async()

func _highlight_terrain_regions_async() -> void:
	"""异步高亮地形区域"""
	# 在下一帧执行，避免阻塞主线程
	await get_tree().process_frame
	
	# 直接调用优化版本
	highlight_terrain_regions_optimized()
	
	
func clear_region_highlights() -> void:
	"""清除所有区域高亮"""
	for terrain_type in region_highlights.keys():
		var region_highlight = region_highlights[terrain_type]
		if region_highlight and is_instance_valid(region_highlight):
			region_highlight.queue_free()
	
	region_highlights.clear()
	
	# 同时清除MultiMeshInstance3D高亮
	clear_terrain_meshes()

# ============================================================================
# 🚀 MultiMeshInstance3D 优化系统
# ============================================================================

func _setup_shared_resources() -> void:
	"""创建共享资源"""
	# 创建共享的平面网格 - 增大尺寸确保全区域覆盖
	shared_plane_mesh = PlaneMesh.new()
	shared_plane_mesh.size = Vector2(1.2, 1.2)
	shared_plane_mesh.subdivide_width = 1
	shared_plane_mesh.subdivide_depth = 1

func _setup_terrain_meshes() -> void:
	"""为每种地形类型创建 MultiMeshInstance3D"""
	var terrain_types = [
		TerrainManager.TerrainType.ROOM_SYSTEM,
		TerrainManager.TerrainType.MAZE_SYSTEM,
		TerrainManager.TerrainType.FOREST,
		TerrainManager.TerrainType.GRASSLAND,
		TerrainManager.TerrainType.LAKE,
		TerrainManager.TerrainType.CAVE,
		TerrainManager.TerrainType.WASTELAND,
		TerrainManager.TerrainType.SWAMP,
		TerrainManager.TerrainType.DEAD_LAND
	]
	
	for terrain_type in terrain_types:
		var multi_mesh_instance = MultiMeshInstance3D.new()
		var multi_mesh = MultiMesh.new()
		
		# 使用共享网格
		multi_mesh.mesh = shared_plane_mesh
		multi_mesh.instance_count = 0
		multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
		
		multi_mesh_instance.multimesh = multi_mesh
		multi_mesh_instance.material_override = _create_terrain_material(terrain_type as int)
		multi_mesh_instance.name = "TerrainMesh_%d" % terrain_type
		
		add_child(multi_mesh_instance)
		terrain_meshes[terrain_type] = multi_mesh_instance
	

func _create_terrain_material(terrain_type: int) -> StandardMaterial3D:
	"""创建地形材质"""
	var terrain_enum = _int_to_terrain_type(terrain_type)
	if highlight_materials.has(terrain_enum):
		return highlight_materials[terrain_enum]
	
	var material = StandardMaterial3D.new()
	
	# 尝试获取TerrainManager引用
	_get_terrain_manager_reference()
	
	# 从TerrainManager获取颜色
	if terrain_manager:
		var color = terrain_manager.get_terrain_highlight_color(terrain_enum)
		# 增加透明度，让高亮更柔和
		color.a = 0.3
		material.albedo_color = color
	else:
		# 如果TerrainManager不可用，使用默认颜色
		var color = terrain_highlight_colors.get(terrain_enum, Color(1.0, 1.0, 1.0, 0.3))
		material.albedo_color = color
	
	material.flags_transparent = true
	material.flags_unshaded = true
	material.flags_do_not_receive_shadows = true
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.no_depth_test = false
	material.alpha_scissor_threshold = 0.1
	
	highlight_materials[terrain_enum] = material
	return material

func highlight_terrain_regions_optimized() -> void:
	"""使用MultiMeshInstance3D高亮地形区域"""
	
	# 获取地形管理器引用
	_get_terrain_manager_reference()
	
	if not terrain_manager:
		LogManager.error("TerrainManager 未初始化，无法获取地形数据")
		return
	
	# 清除现有高亮
	clear_terrain_meshes()
	
	var start_time = Time.get_ticks_msec()
	var total_positions = 0
	
	# 为每种地形类型创建MultiMesh高亮
	var processed_types = 0
	for terrain_type in range(9): # 只有9种地形类型 (0-8)
		var terrain_enum = _int_to_terrain_type(terrain_type)
		var regions = terrain_manager.get_terrain_regions_by_type(terrain_enum)
		if regions.is_empty():
			continue
		
		var all_positions = []
		for region in regions:
			all_positions.append_array(region.positions)
		
		if all_positions.is_empty():
			continue
		
		# 更新对应地形类型的MultiMesh
		_update_terrain_mesh(terrain_enum, all_positions)
		total_positions += all_positions.size()
		processed_types += 1
		
	
	var end_time = Time.get_ticks_msec()
	LogManager.info("地形高亮完成: %d 种类型, %d 个位置, 耗时: %dms" % [processed_types, total_positions, end_time - start_time])
	
	# 更新鼠标悬停位置映射
	_update_terrain_position_map()
	

func _update_terrain_mesh(terrain_type: TerrainManager.TerrainType, positions: Array) -> void:
	"""更新地形网格 - 批量优化版"""
	if not terrain_meshes.has(terrain_type):
		LogManager.error("地形类型 %s 的MultiMesh不存在" % terrain_type)
		return
		
	var multi_mesh_instance = terrain_meshes[terrain_type]
	var multi_mesh = multi_mesh_instance.multimesh
	
	# 设置实例数量
	multi_mesh.instance_count = positions.size()
	
	# 批量设置变换矩阵 - 针对1x1网格优化
	# 使用批量处理，每100个位置让出一帧
	var batch_size = 100
	for i in range(0, positions.size(), batch_size):
		var end_idx = min(i + batch_size, positions.size())
		
		# 批量设置变换矩阵
		for j in range(i, end_idx):
			var pos = positions[j]
			var transform = Transform3D()
			# 为不同地形类型添加微小的Y偏移，避免Z-fighting
			var y_offset = 1.2 + (terrain_type as int * 0.01)
			transform.origin = Vector3(pos.x, y_offset, pos.z)
			multi_mesh.set_instance_transform(j, transform)
		
		# 每处理100个位置后让出一帧
		if i + batch_size < positions.size():
			await get_tree().process_frame
	
	# 显示对应地形类型的MultiMesh
	multi_mesh_instance.visible = true

func clear_terrain_meshes() -> void:
	"""清除所有地形网格"""
	var cleared_count = 0
	for terrain_type in terrain_meshes.keys():
		var multi_mesh_instance = terrain_meshes[terrain_type]
		if multi_mesh_instance and is_instance_valid(multi_mesh_instance):
			var instance_count = multi_mesh_instance.multimesh.instance_count
			multi_mesh_instance.visible = false
			multi_mesh_instance.multimesh.instance_count = 0
			if instance_count > 0:
				cleared_count += 1
	
	# 清除位置映射和隐藏弹窗
	terrain_position_map.clear()
	_hide_tooltip()

func _get_terrain_type_from_content(content_type: String) -> int:
	"""根据内容类型获取地形类型索引"""
	match content_type:
		"ROOM_SYSTEM": return 0
		"MAZE_SYSTEM": return 1
		"FOREST": return 2
		"GRASSLAND": return 3
		"LAKE": return 4
		"CAVE": return 5
		"WASTELAND": return 6
		"SWAMP": return 7
		"DEAD_LAND": return 8
		# 英雄营地已移除，改为建筑物系统
		_: return 0

# ============================================================================
# 🖱️ 悬停信息弹窗系统
# ============================================================================

func _setup_tooltip_system() -> void:
	"""初始化悬停信息弹窗系统"""
	# 创建UI层
	tooltip_ui = Control.new()
	tooltip_ui.name = "TerrainTooltipUI"
	tooltip_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tooltip_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tooltip_ui)
	
	# 创建信息标签
	tooltip_label = RichTextLabel.new()
	tooltip_label.name = "TerrainTooltipLabel"
	tooltip_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	tooltip_label.position = Vector2(10, 10)
	tooltip_label.size = Vector2(300, 150)
	tooltip_label.bbcode_enabled = true
	tooltip_label.fit_content = true
	tooltip_label.visible = false
	
	# 设置样式
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.8, 0.8, 0.8, 1.0)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	tooltip_label.add_theme_stylebox_override("normal", style_box)
	
	tooltip_ui.add_child(tooltip_label)
	
	# 获取相机引用
	camera = get_viewport().get_camera_3d()
	

func _process(_delta: float) -> void:
	"""处理鼠标悬停检测"""
	if not tooltip_ui or not tooltip_label.visible:
		return
	
	# 更新弹窗位置跟随鼠标
	var mouse_pos = get_viewport().get_mouse_position()
	tooltip_label.position = mouse_pos + Vector2(15, 15)
	
	# 确保弹窗不超出屏幕边界
	var viewport_size = get_viewport().get_visible_rect().size
	var tooltip_size = tooltip_label.size
	
	if tooltip_label.position.x + tooltip_size.x > viewport_size.x:
		tooltip_label.position.x = mouse_pos.x - tooltip_size.x - 15
	
	if tooltip_label.position.y + tooltip_size.y > viewport_size.y:
		tooltip_label.position.y = mouse_pos.y - tooltip_size.y - 15

func _input(event: InputEvent) -> void:
	"""处理输入事件"""
	if event is InputEventMouseMotion and not terrain_position_map.is_empty():
		_handle_mouse_hover(event.global_position)

func _handle_mouse_hover(mouse_pos: Vector2) -> void:
	"""处理鼠标悬停 - 改进版"""
	if not camera:
		camera = get_viewport().get_camera_3d()
		if not camera:
			return
	
	# 将鼠标位置转换为3D射线
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	# 计算射线与Y=1.2平面的交点（地形高亮的高度）
	var ray_direction = (to - from).normalized()
	if abs(ray_direction.y) < 0.001: # 射线平行于地面
		_hide_tooltip()
		return
	
	var t = (1.2 - from.y) / ray_direction.y
	if t < 0: # 射线向上
		_hide_tooltip()
		return
	
	var hit_pos = from + ray_direction * t
	var grid_pos = Vector3(round(hit_pos.x), 0, round(hit_pos.z))
	
	# 检查该位置是否有地形高亮
	var pos_key = str(grid_pos)
	if terrain_position_map.has(pos_key):
		var terrain_type = terrain_position_map[pos_key]
		if terrain_type != current_hovered_terrain:
			_show_tooltip(terrain_type, grid_pos)
	else:
		_hide_tooltip()

func _show_tooltip(terrain_type: int, position: Vector3) -> void:
	"""显示地形信息弹窗"""
	current_hovered_terrain = terrain_type
	
	# 获取地形信息
	var terrain_info = _get_terrain_info(terrain_type, position)
	
	# 构建显示文本
	var text = "[b]%s[/b]\n" % terrain_info.name
	text += "位置: (%d, %d)\n" % [int(position.x), int(position.z)]
	
	# 特殊处理房间系统的显示
	if terrain_type == 0: # 房间系统
		text += "房间: %d\n" % terrain_info.current_resources
		text += "走廊: %d" % terrain_info.current_beasts
	else:
		# 其他地形类型显示资源/野兽（使用 0/n 格式）
		text += "资源: %d/%d\n" % [terrain_info.current_resources, terrain_info.max_resources]
		text += "野兽: %d/%d" % [terrain_info.current_beasts, terrain_info.max_beasts]
	
	tooltip_label.text = text
	tooltip_label.visible = true
	

func _hide_tooltip() -> void:
	"""隐藏地形信息弹窗"""
	if current_hovered_terrain != -1:
		current_hovered_terrain = -1
		tooltip_label.visible = false

func _get_terrain_info(terrain_type: int, _position: Vector3) -> Dictionary:
	"""获取地形信息"""
	# 使用TerrainManager获取地形名称
	var terrain_name = _get_terrain_type_name(terrain_type)
	
	# 特殊处理房间系统 - 显示房间和走廊统计
	if terrain_type == 0: # 房间系统
		var room_stats = _get_room_system_stats()
		return {
			"name": terrain_name,
			"current_resources": room_stats.room_count,
			"max_resources": room_stats.max_rooms,
			"current_beasts": room_stats.corridor_count,
			"max_beasts": room_stats.max_corridors
		}
	
	# 其他地形类型 - 显示资源/野兽数据
	var base_resources = {
		1: {"max": 50, "current": 30}, # 迷宫系统
		2: {"max": 200, "current": 150}, # 森林
		3: {"max": 80, "current": 60}, # 草地
		4: {"max": 120, "current": 90}, # 湖泊
		5: {"max": 150, "current": 120}, # 洞穴
		6: {"max": 60, "current": 40}, # 荒地
		7: {"max": 90, "current": 70}, # 沼泽
		8: {"max": 30, "current": 10} # 死地
	}
	
	var base_beasts = {
		1: {"max": 8, "current": 6}, # 迷宫系统
		2: {"max": 15, "current": 12}, # 森林
		3: {"max": 6, "current": 4}, # 草地
		4: {"max": 10, "current": 8}, # 湖泊
		5: {"max": 12, "current": 9}, # 洞穴
		6: {"max": 4, "current": 2}, # 荒地
		7: {"max": 7, "current": 5}, # 沼泽
		8: {"max": 2, "current": 1} # 死地
	}
	
	var resources = base_resources.get(terrain_type, {"max": 0, "current": 0})
	var beasts = base_beasts.get(terrain_type, {"max": 0, "current": 0})
	
	return {
		"name": terrain_name,
		"current_resources": resources.current,
		"max_resources": resources.max,
		"current_beasts": beasts.current,
		"max_beasts": beasts.max
	}

func _get_room_system_stats() -> Dictionary:
	"""获取房间系统统计信息"""
	var stats = {
		"room_count": 0,
		"max_rooms": 0,
		"corridor_count": 0,
		"max_corridors": 0
	}
	
	# 尝试从MapGenerator获取SimpleRoomGenerator
	if not map_generator:
		return stats
	
	var simple_room_generator = map_generator.get_node("SimpleRoomGenerator")
	if not simple_room_generator:
		return stats
	
	# 直接获取房间统计信息
	stats.room_count = simple_room_generator.get_room_count()
	stats.corridor_count = simple_room_generator.get_corridor_count()
	
	# 调试输出
	LogManager.info("房间系统统计: 房间=%d, 走廊=%d" % [stats.room_count, stats.corridor_count])
	
	# 设置合理的最大值（基于地图配置）
	if MapConfig:
		var room_config = MapConfig.get_room_generation_config()
		stats.max_rooms = room_config.max_room_count
		stats.max_corridors = stats.max_rooms * 2 # 走廊数量通常是房间数量的2倍
	
	return stats

func _update_terrain_position_map() -> void:
	"""🖱️ [悬停系统] 更新地形位置映射"""
	terrain_position_map.clear()
	
	# 遍历所有地形类型，建立位置映射
	var terrain_types = [
		TerrainManager.TerrainType.ROOM_SYSTEM, # 0
		TerrainManager.TerrainType.MAZE_SYSTEM, # 1
		TerrainManager.TerrainType.FOREST, # 2
		TerrainManager.TerrainType.GRASSLAND, # 3
		TerrainManager.TerrainType.LAKE, # 4
		TerrainManager.TerrainType.CAVE, # 5
		TerrainManager.TerrainType.WASTELAND, # 6
		TerrainManager.TerrainType.SWAMP, # 7
		TerrainManager.TerrainType.DEAD_LAND # 8
	]
	
	for terrain_type in terrain_types:
		var regions = terrain_manager.get_terrain_regions_by_type(terrain_type)
		if regions.is_empty():
			continue
		
		for region in regions:
			for pos in region.positions:
				var pos_key = str(pos)
				# 使用优先级系统确保每个位置只属于一个地形类型
				if not terrain_position_map.has(pos_key):
					terrain_position_map[pos_key] = terrain_type
				else:
					# 如果已存在，比较优先级
					var existing_terrain = terrain_position_map[pos_key]
					var current_priority = terrain_priorities.get(terrain_type, 0)
					var existing_priority = terrain_priorities.get(existing_terrain, 0)
					
					if current_priority > existing_priority:
						terrain_position_map[pos_key] = terrain_type
