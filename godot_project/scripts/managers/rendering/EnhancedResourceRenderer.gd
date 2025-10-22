extends Node
class_name EnhancedResourceRenderer

## 🎨 增强资源渲染管理器
## 统一管理植物、矿物和其他资源的渲染

# 渲染器组件
var plant_renderer: PlantRenderer = null
var mineral_renderer: MineralRenderer = null
var resource_renderer: ResourceRenderer = null

# 渲染配置
var render_config = {
	"enabled": true,
	"enable_plants": true,
	"enable_minerals": true,
	"enable_resources": true,
	"max_total_objects": 1000,
	"update_interval": 1.0,
	"lod_distance": 30.0,
	"batch_size": 50,
	"enable_performance_monitoring": true,
	"performance_update_interval": 5.0,
	"enable_adaptive_quality": true,
	"target_fps": 60.0,
	"quality_levels": {
		"high": {"max_plants": 500, "max_minerals": 300, "lod_distance": 30.0},
		"medium": {"max_plants": 300, "max_minerals": 200, "lod_distance": 20.0},
		"low": {"max_plants": 150, "max_minerals": 100, "lod_distance": 15.0}
	}
}

# 世界节点引用
var world_node: Node3D = null
var resource_manager = null
var update_timer: Timer = null
var performance_timer: Timer = null

# 性能监控
var performance_stats = {
	"current_fps": 60.0,
	"average_fps": 60.0,
	"frame_times": [],
	"object_count": 0,
	"quality_level": "high",
	"last_performance_check": 0.0
}

# 资源类型映射
var resource_type_mapping = {
	# 植物资源 - 使用ResourceManager.ResourceType
	ResourceManager.ResourceType.WOOD: {"type": "plant", "subtype": PlantRenderer.PlantType.TREE},
	ResourceManager.ResourceType.FOOD: {"type": "plant", "subtype": PlantRenderer.PlantType.CROP},
	ResourceManager.ResourceType.MAGIC_HERB: {"type": "plant", "subtype": PlantRenderer.PlantType.HERB},
	
	# 矿物资源 - 使用ResourceManager.ResourceType
	ResourceManager.ResourceType.GOLD: {"type": "mineral", "subtype": MineralRenderer.MineralType.GOLD_ORE},
	ResourceManager.ResourceType.STONE: {"type": "mineral", "subtype": MineralRenderer.MineralType.STONE},
	ResourceManager.ResourceType.IRON: {"type": "mineral", "subtype": MineralRenderer.MineralType.IRON_ORE},
	ResourceManager.ResourceType.GEM: {"type": "mineral", "subtype": MineralRenderer.MineralType.GEM},
	ResourceManager.ResourceType.MAGIC_CRYSTAL: {"type": "mineral", "subtype": MineralRenderer.MineralType.MAGIC_CRYSTAL},
	ResourceManager.ResourceType.DEMON_CORE: {"type": "mineral", "subtype": MineralRenderer.MineralType.DEMON_CORE},
	ResourceManager.ResourceType.MANA: {"type": "mineral", "subtype": MineralRenderer.MineralType.MAGIC_CRYSTAL}
}

# 生态系统资源类型映射（使用ResourceTypes.ResourceType）
var ecosystem_resource_mapping = {
	# 生态系统植物资源映射
	ResourceTypes.ResourceType.BERRY: {"type": "plant", "subtype": PlantRenderer.PlantType.BUSH},
	ResourceTypes.ResourceType.HERB: {"type": "plant", "subtype": PlantRenderer.PlantType.HERB},
	ResourceTypes.ResourceType.MUSHROOM: {"type": "plant", "subtype": PlantRenderer.PlantType.MUSHROOM},
	ResourceTypes.ResourceType.AQUATIC_PLANT: {"type": "plant", "subtype": PlantRenderer.PlantType.AQUATIC_PLANT},
	ResourceTypes.ResourceType.CROP: {"type": "plant", "subtype": PlantRenderer.PlantType.CROP},
	ResourceTypes.ResourceType.CORRUPTED_PLANT: {"type": "plant", "subtype": PlantRenderer.PlantType.CORRUPTED_PLANT},
	ResourceTypes.ResourceType.DEATH_FLOWER: {"type": "plant", "subtype": PlantRenderer.PlantType.FLOWER},
	ResourceTypes.ResourceType.PRIMITIVE_PLANT: {"type": "plant", "subtype": PlantRenderer.PlantType.GRASS},
	
	# 生态系统矿物资源映射
	ResourceTypes.ResourceType.IRON_ORE: {"type": "mineral", "subtype": MineralRenderer.MineralType.IRON_ORE},
	ResourceTypes.ResourceType.GOLD_ORE: {"type": "mineral", "subtype": MineralRenderer.MineralType.GOLD_ORE},
	ResourceTypes.ResourceType.RARE_MINERAL: {"type": "mineral", "subtype": MineralRenderer.MineralType.GEM},
	ResourceTypes.ResourceType.ESSENCE: {"type": "mineral", "subtype": MineralRenderer.MineralType.MAGIC_CRYSTAL},
	ResourceTypes.ResourceType.SOUL_STONE: {"type": "mineral", "subtype": MineralRenderer.MineralType.DEMON_CORE},
	ResourceTypes.ResourceType.CURSED_GEM: {"type": "mineral", "subtype": MineralRenderer.MineralType.DEMON_CORE},
	ResourceTypes.ResourceType.PREHISTORIC_MINERAL: {"type": "mineral", "subtype": MineralRenderer.MineralType.STONE},
	ResourceTypes.ResourceType.PRIMITIVE_CRYSTAL: {"type": "mineral", "subtype": MineralRenderer.MineralType.MAGIC_CRYSTAL},
	ResourceTypes.ResourceType.DRAGON_BLOOD_STONE: {"type": "mineral", "subtype": MineralRenderer.MineralType.DEMON_CORE},
	ResourceTypes.ResourceType.ANCIENT_DRAGON_SCALE: {"type": "mineral", "subtype": MineralRenderer.MineralType.DEMON_CORE}
}

func _ready():
	"""初始化增强资源渲染器"""
	_initialize_renderers()
	_setup_timer()
	LogManager.info("EnhancedResourceRenderer - 增强资源渲染器初始化完成")

func _initialize_renderers():
	"""初始化各个渲染器"""
	# 创建植物渲染器
	if render_config.enable_plants:
		plant_renderer = PlantRenderer.new()
		plant_renderer.name = "PlantRenderer"
		add_child(plant_renderer)
	
	# 创建矿物渲染器
	if render_config.enable_minerals:
		mineral_renderer = MineralRenderer.new()
		mineral_renderer.name = "MineralRenderer"
		add_child(mineral_renderer)
	
	# 创建资源渲染器
	if render_config.enable_resources:
		resource_renderer = ResourceRenderer.new()
		resource_renderer.name = "ResourceRenderer"
		add_child(resource_renderer)

func _setup_timer():
	"""设置更新定时器"""
	update_timer = Timer.new()
	update_timer.wait_time = render_config.update_interval
	update_timer.timeout.connect(_update_all_renderers)
	update_timer.autostart = true
	add_child(update_timer)
	
	# 设置性能监控定时器
	if render_config.enable_performance_monitoring:
		performance_timer = Timer.new()
		performance_timer.wait_time = render_config.performance_update_interval
		performance_timer.timeout.connect(_update_performance_stats)
		performance_timer.autostart = true
		add_child(performance_timer)

func set_world_node(world: Node3D):
	"""设置世界节点引用"""
	world_node = world
	
	# 设置各个渲染器的世界节点
	if plant_renderer:
		plant_renderer.set_world_node(world)
	if mineral_renderer:
		mineral_renderer.set_world_node(world)
	if resource_renderer:
		resource_renderer.set_world_node(world)
	
	LogManager.info("EnhancedResourceRenderer - 世界节点已设置")

func set_resource_manager(manager):
	"""设置资源管理器引用"""
	resource_manager = manager
	
	# 设置资源渲染器的管理器
	if resource_renderer:
		resource_renderer.set_resource_manager(manager)
	
	LogManager.info("EnhancedResourceRenderer - 资源管理器已设置")

func create_resource_object(resource_type, position: Vector3, amount: int = 1) -> Node3D:
	"""创建资源对象（支持ResourceManager.ResourceType和ResourceTypes.ResourceType）"""
	if not world_node:
		LogManager.error("EnhancedResourceRenderer - 世界节点未设置")
		return null
	
	# 获取资源映射（先尝试ResourceManager，再尝试ResourceTypes）
	var mapping = resource_type_mapping.get(resource_type, null)
	if not mapping:
		mapping = ecosystem_resource_mapping.get(resource_type, null)
	
	if not mapping:
		LogManager.warning("EnhancedResourceRenderer - 未知资源类型: %s" % str(resource_type))
		return null
	
	var resource_object = null
	
	# 根据类型创建相应的对象
	match mapping.type:
		"plant":
			if plant_renderer:
				resource_object = plant_renderer.create_plant(mapping.subtype, position)
		"mineral":
			if mineral_renderer:
				resource_object = mineral_renderer.create_mineral(mapping.subtype, position)
		"resource":
			if resource_renderer:
				# 使用原有的资源标记系统
				resource_object = _create_resource_marker(resource_type, position, amount)
	
	if resource_object:
		LogManager.info("✅ EnhancedResourceRenderer - 创建资源对象: %s 在位置 %s" % [str(resource_type), str(position)])
	else:
		LogManager.warning("❌ EnhancedResourceRenderer - 资源对象创建失败: %s 在位置 %s" % [str(resource_type), str(position)])
	
	return resource_object

func _create_resource_marker(resource_type: ResourceManager.ResourceType, position: Vector3, amount: int) -> Node3D:
	"""创建资源标记（兼容原有系统）"""
	if not resource_renderer:
		return null
	
	# 创建资源生成数据
	var spawn_data = {
		"resource_type": resource_type,
		"position": position,
		"amount": amount,
		"is_depleted": false
	}
	
	# 使用资源渲染器创建标记
	resource_renderer._create_resource_marker(spawn_data)
	return null # 资源渲染器内部管理标记

func create_plant(plant_type: PlantRenderer.PlantType, position: Vector3, scale: float = 1.0) -> Node3D:
	"""创建植物"""
	if plant_renderer:
		return plant_renderer.create_plant(plant_type, position, scale)
	return null

func create_mineral(mineral_type: MineralRenderer.MineralType, position: Vector3, scale: float = 1.0) -> Node3D:
	"""创建矿物"""
	if mineral_renderer:
		return mineral_renderer.create_mineral(mineral_type, position, scale)
	return null

func _update_all_renderers():
	"""更新所有渲染器"""
	if not render_config.enabled:
		return
	
	# 更新性能统计
	_update_frame_stats()
	
	# 更新各个渲染器
	if plant_renderer:
		plant_renderer._update_plants()
	if mineral_renderer:
		mineral_renderer._update_minerals()
	if resource_renderer:
		resource_renderer._update_resource_markers()

func _update_frame_stats():
	"""更新帧统计"""
	var frame_time = get_process_delta_time()
	
	performance_stats.current_fps = 1.0 / frame_time if frame_time > 0 else 60.0
	performance_stats.frame_times.append(frame_time)
	
	# 保持最近100帧的数据
	if performance_stats.frame_times.size() > 100:
		performance_stats.frame_times.pop_front()
	
	# 计算平均FPS
	var total_time = 0.0
	for time in performance_stats.frame_times:
		total_time += time
	performance_stats.average_fps = performance_stats.frame_times.size() / total_time if total_time > 0 else 60.0
	
	# 更新对象数量
	performance_stats.object_count = get_total_object_count()

func _update_performance_stats():
	"""更新性能统计并调整质量"""
	if not render_config.enable_adaptive_quality:
		return
	
	var target_fps = render_config.target_fps
	var current_fps = performance_stats.average_fps
	
	# 根据FPS调整质量级别
	var new_quality_level = performance_stats.quality_level
	
	if current_fps < target_fps * 0.8: # FPS低于目标80%
		if performance_stats.quality_level == "high":
			new_quality_level = "medium"
		elif performance_stats.quality_level == "medium":
			new_quality_level = "low"
	elif current_fps > target_fps * 1.1: # FPS高于目标110%
		if performance_stats.quality_level == "low":
			new_quality_level = "medium"
		elif performance_stats.quality_level == "medium":
			new_quality_level = "high"
	
	# 如果质量级别改变，应用新设置
	if new_quality_level != performance_stats.quality_level:
		_apply_quality_level(new_quality_level)
		performance_stats.quality_level = new_quality_level
		LogManager.info("EnhancedResourceRenderer - 质量级别调整为: %s (FPS: %.1f)" % [new_quality_level, current_fps])

func _apply_quality_level(quality_level: String):
	"""应用质量级别设置"""
	var quality_config = render_config.quality_levels.get(quality_level, render_config.quality_levels["medium"])
	
	# 更新植物渲染器配置
	if plant_renderer:
		var plant_config = {
			"max_plants": quality_config.max_plants,
			"lod_distance": quality_config.lod_distance,
			"enable_animations": quality_level != "low",
			"enable_wind_effect": quality_level == "high"
		}
		plant_renderer.set_render_config(plant_config)
	
	# 更新矿物渲染器配置
	if mineral_renderer:
		var mineral_config = {
			"max_minerals": quality_config.max_minerals,
			"lod_distance": quality_config.lod_distance,
			"enable_particles": quality_level != "low",
			"enable_glow": quality_level != "low"
		}
		mineral_renderer.set_render_config(mineral_config)

func remove_resource_object(position: Vector3, resource_type: ResourceManager.ResourceType = ResourceManager.ResourceType.GOLD):
	"""移除资源对象"""
	# 获取资源映射
	var _mapping = null
	if resource_type != ResourceManager.ResourceType.GOLD: # 使用默认值检查
		_mapping = resource_type_mapping.get(resource_type, null)
	
	# 尝试从各个渲染器移除
	if plant_renderer:
		plant_renderer.remove_plant(position)
	if mineral_renderer:
		mineral_renderer.remove_mineral(position)
	if resource_renderer:
		# 资源渲染器使用不同的移除方式
		var pos_key = resource_renderer._get_position_key(position)
		if pos_key in resource_renderer.resource_markers:
			var marker = resource_renderer.resource_markers[pos_key]
			if marker and is_instance_valid(marker):
				marker.queue_free()
			resource_renderer.resource_markers.erase(pos_key)

func clear_all_objects():
	"""清除所有对象"""
	if plant_renderer:
		plant_renderer.clear_all_plants()
	if mineral_renderer:
		mineral_renderer.clear_all_minerals()
	if resource_renderer:
		resource_renderer._clear_all_markers()

func toggle_rendering():
	"""切换渲染状态"""
	render_config.enabled = !render_config.enabled
	
	if render_config.enabled:
		_update_all_renderers()
	else:
		clear_all_objects()
	
	LogManager.info("EnhancedResourceRenderer - 渲染状态: %s" % ("开启" if render_config.enabled else "关闭"))

func toggle_plant_rendering():
	"""切换植物渲染"""
	render_config.enable_plants = !render_config.enable_plants
	
	if plant_renderer:
		if render_config.enable_plants:
			plant_renderer.render_config.enabled = true
		else:
			plant_renderer.clear_all_plants()
			plant_renderer.render_config.enabled = false
	
	LogManager.info("EnhancedResourceRenderer - 植物渲染: %s" % ("开启" if render_config.enable_plants else "关闭"))

func toggle_mineral_rendering():
	"""切换矿物渲染"""
	render_config.enable_minerals = !render_config.enable_minerals
	
	if mineral_renderer:
		if render_config.enable_minerals:
			mineral_renderer.render_config.enabled = true
		else:
			mineral_renderer.clear_all_minerals()
			mineral_renderer.render_config.enabled = false
	
	LogManager.info("EnhancedResourceRenderer - 矿物渲染: %s" % ("开启" if render_config.enable_minerals else "关闭"))

func toggle_resource_rendering():
	"""切换资源渲染"""
	render_config.enable_resources = !render_config.enable_resources
	
	if resource_renderer:
		resource_renderer.toggle_rendering()
	
	LogManager.info("EnhancedResourceRenderer - 资源渲染: %s" % ("开启" if render_config.enable_resources else "关闭"))

func set_render_config(new_config: Dictionary):
	"""设置渲染配置"""
	render_config.merge(new_config, true)
	
	# 更新各个渲染器的配置
	if plant_renderer:
		var plant_config = {
			"enabled": render_config.enable_plants,
			"update_interval": render_config.update_interval,
			"lod_distance": render_config.lod_distance,
			"batch_size": render_config.batch_size
		}
		plant_renderer.set_render_config(plant_config)
	
	if mineral_renderer:
		var mineral_config = {
			"enabled": render_config.enable_minerals,
			"update_interval": render_config.update_interval,
			"lod_distance": render_config.lod_distance,
			"batch_size": render_config.batch_size
		}
		mineral_renderer.set_render_config(mineral_config)
	
	if resource_renderer:
		var resource_config = {
			"enabled": render_config.enable_resources,
			"update_interval": render_config.update_interval
		}
		resource_renderer.set_render_config(resource_config)
	
	# 更新定时器
	if update_timer:
		update_timer.wait_time = render_config.update_interval
	
	LogManager.info("EnhancedResourceRenderer - 渲染配置已更新")

func get_render_status() -> Dictionary:
	"""获取渲染状态"""
	var status = {
		"enabled": render_config.enabled,
		"enable_plants": render_config.enable_plants,
		"enable_minerals": render_config.enable_minerals,
		"enable_resources": render_config.enable_resources,
		"update_interval": render_config.update_interval,
		"performance_monitoring": render_config.enable_performance_monitoring,
		"adaptive_quality": render_config.enable_adaptive_quality,
		"quality_level": performance_stats.quality_level,
		"current_fps": performance_stats.current_fps,
		"average_fps": performance_stats.average_fps,
		"total_objects": performance_stats.object_count
	}
	
	# 获取各个渲染器的状态
	if plant_renderer:
		status["plant_status"] = plant_renderer.get_render_status()
	if mineral_renderer:
		status["mineral_status"] = mineral_renderer.get_render_status()
	if resource_renderer:
		status["resource_status"] = resource_renderer.get_render_status()
	
	return status

func get_total_object_count() -> int:
	"""获取总对象数量"""
	var total = 0
	
	if plant_renderer:
		total += plant_renderer.plant_instances.size()
	if mineral_renderer:
		total += mineral_renderer.mineral_instances.size()
	if resource_renderer:
		total += resource_renderer.resource_markers.size()
	
	return total
