extends Node
# 瓦片渲染器 - 核心渲染管理类
# 负责协调所有渲染组件，提供统一的瓦片渲染接口

class_name TileRenderer

# 依赖组件
var mesh_factory: TileMeshFactory
var ecosystem_renderer: EcosystemTileRenderer

# 渲染配置
var render_config = {
	"batch_size": 100, # 批处理大小
	"max_visible_tiles": 10000, # 最大可见瓦片数
	"lod_distance": 50.0, # LOD距离
	"enable_frustum_culling": true, # 启用视锥剔除
	"enable_occlusion_culling": false # 启用遮挡剔除
}

# 渲染统计
var render_stats = {
	"total_tiles": 0,
	"rendered_tiles": 0,
	"culled_tiles": 0,
	"batches_created": 0
}

func _ready():
	"""初始化瓦片渲染器"""
	LogManager.info("TileRenderer - 初始化开始")
	
	# 创建网格工厂
	mesh_factory = TileMeshFactory.new()
	add_child(mesh_factory)
	
	# 创建生态系统渲染器
	ecosystem_renderer = EcosystemTileRenderer.new()
	add_child(ecosystem_renderer)
	
	LogManager.info("TileRenderer - 初始化完成")

func render_tile(tile_data, parent_node: Node3D) -> Node3D:
	"""渲染单个瓦片"""
	var tile_object = mesh_factory.create_tile_object(tile_data)
	
	if tile_object:
		parent_node.add_child(tile_object)
		tile_data.tile_object = tile_object
		render_stats["rendered_tiles"] += 1
		
		# 🌍 为生态系统地块添加装饰效果
		if ecosystem_renderer and _is_ecosystem_tile(tile_data.type):
			ecosystem_renderer.render_tile_decorations(tile_data.type, tile_data.position)
	
	return tile_object

func render_tiles_batch(tile_data_array: Array, parent_node: Node3D) -> Array[Node3D]:
	"""批量渲染瓦片"""
	var rendered_objects: Array[Node3D] = []
	var batch_count = 0
	
	LogManager.info("🔄 [TileRenderer] 开始批量渲染 %d 个瓦片" % tile_data_array.size())
	
	for tile_data in tile_data_array:
		var tile_object = render_tile(tile_data, parent_node)
		if tile_object:
			rendered_objects.append(tile_object)
			batch_count += 1
			
			# 批处理限制
			if batch_count >= render_config["batch_size"]:
				await get_tree().process_frame # 让出控制权
				batch_count = 0
				render_stats["batches_created"] += 1
	
	LogManager.info("✅ [TileRenderer] 批量渲染完成，成功渲染 %d 个瓦片" % rendered_objects.size())
	return rendered_objects

func update_tile(tile_data) -> bool:
	"""更新瓦片渲染"""
	if not tile_data.tile_object:
		return false
	
	# 销毁旧对象
	tile_data.tile_object.queue_free()
	
	# 重新渲染
	var new_object = mesh_factory.create_tile_object(tile_data)
	if new_object and tile_data.tile_object.get_parent():
		tile_data.tile_object.get_parent().add_child(new_object)
		tile_data.tile_object = new_object
		return true
	
	return false

func destroy_tile(tile_data) -> bool:
	"""销毁瓦片渲染"""
	if tile_data.tile_object:
		tile_data.tile_object.queue_free()
		tile_data.tile_object = null
		render_stats["rendered_tiles"] -= 1
		return true
	return false

func destroy_tiles_batch(tile_data_array: Array) -> int:
	"""批量销毁瓦片渲染"""
	var destroyed_count = 0
	
	for tile_data in tile_data_array:
		if destroy_tile(tile_data):
			destroyed_count += 1
	
	LogManager.info("🗑️ [TileRenderer] 批量销毁完成，销毁 %d 个瓦片" % destroyed_count)
	return destroyed_count

func clear_all_tiles(tile_data_array: Array) -> int:
	"""清除所有瓦片渲染"""
	LogManager.info("🧹 [TileRenderer] 开始清除所有瓦片渲染")
	
	var cleared_count = destroy_tiles_batch(tile_data_array)
	
	# 重置统计
	render_stats["total_tiles"] = 0
	render_stats["rendered_tiles"] = 0
	render_stats["culled_tiles"] = 0
	render_stats["batches_created"] = 0
	
	LogManager.info("✅ [TileRenderer] 清除完成，共清除 %d 个瓦片" % cleared_count)
	return cleared_count

func optimize_rendering(camera_position: Vector3, tile_data_array: Array) -> void:
	"""优化渲染性能"""
	if not render_config["enable_frustum_culling"]:
		return
	
	var optimized_count = 0
	var culled_count = 0
	
	for tile_data in tile_data_array:
		var distance = camera_position.distance_to(tile_data.position)
		
		# 距离剔除
		if distance > render_config["lod_distance"]:
			if tile_data.tile_object and tile_data.tile_object.visible:
				tile_data.tile_object.visible = false
				culled_count += 1
		else:
			if tile_data.tile_object and not tile_data.tile_object.visible:
				tile_data.tile_object.visible = true
				optimized_count += 1
	
	render_stats["culled_tiles"] = culled_count
	
	if culled_count > 0 or optimized_count > 0:
		LogManager.debug("🎯 [TileRenderer] 渲染优化: 剔除 %d 个，显示 %d 个" % [culled_count, optimized_count])

func set_render_config(config_name: String, value) -> void:
	"""设置渲染配置"""
	if render_config.has(config_name):
		render_config[config_name] = value
		LogManager.info("⚙️ [TileRenderer] 配置更新: %s = %s" % [config_name, str(value)])
	else:
		LogManager.warning("⚠️ [TileRenderer] 未知配置项: %s" % config_name)

func get_render_stats() -> Dictionary:
	"""获取渲染统计信息"""
	return render_stats.duplicate()

func get_performance_info() -> Dictionary:
	"""获取性能信息"""
	var info = {
		"render_stats": get_render_stats(),
		"mesh_factory_stats": {},
		"material_cache_size": 0,
		"mesh_pool_stats": {}
	}
	
	if mesh_factory and mesh_factory.material_manager and mesh_factory.material_manager.has_method("get_cache_size"):
		info["material_cache_size"] = mesh_factory.material_manager.get_cache_size()
	
	if mesh_factory and mesh_factory.mesh_pool and mesh_factory.mesh_pool.has_method("get_pool_stats"):
		info["mesh_pool_stats"] = mesh_factory.mesh_pool.get_pool_stats()
	
	return info

func enable_debug_mode(enabled: bool) -> void:
	"""启用/禁用调试模式"""
	# 这里可以添加调试相关的功能
	LogManager.info("🔍 [TileRenderer] 调试模式: %s" % ("启用" if enabled else "禁用"))

func _is_ecosystem_tile(tile_type: int) -> bool:
	"""检查是否为生态系统地块"""
	return tile_type >= TileTypes.TileType.FOREST_CLEARING and tile_type <= TileTypes.TileType.PRIMITIVE_VOLCANO

func set_world_node(world: Node3D):
	"""设置世界节点引用"""
	if ecosystem_renderer:
		ecosystem_renderer.set_world_node(world)
	LogManager.info("TileRenderer - 世界节点已设置")

func _get_tile_type_name(tile_type: int) -> String:
	"""获取瓦片类型名称（用于日志）"""
	# 🔧 [统一类型] 使用 TileTypes.get_tile_name 方法
	return TileTypes.get_tile_name(tile_type)

func cleanup():
	"""清理资源"""
	LogManager.info("TileRenderer - 开始清理资源")
	
	if mesh_factory:
		mesh_factory.cleanup()
	
	LogManager.info("TileRenderer - 资源清理完成")

func _exit_tree():
	"""节点退出时自动清理"""
	cleanup()
