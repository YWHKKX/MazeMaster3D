extends UnifiedBuildingSystem
class_name UnifiedWorkshop

## 🔨 统一工坊建筑
## 使用自由组件系统的工坊实现，1x1瓦块建筑

# 工坊专用属性
var production_efficiency: float = 1.0
var crafting_speed: float = 1.0
var material_storage: int = 1000
var forge_temperature: float = 1000.0

func _init():
	"""初始化工坊"""
	super._init()
	
	# 基础属性
	building_type = BuildingTypes.BuildingType.WORKSHOP
	building_name = "工坊"
	building_description = "生产建筑，用于制造和修理装备"
	
	# 建筑属性
	max_health = 200
	health = 200
	armor = 5
	cost_gold = 800
	
	# 建筑尺寸和主题
	building_size = Vector2(1, 1) # 1x1瓦块
	building_theme = "industrial"
	building_tier = 2
	building_category = "production"
	
	# 工坊专用属性
	production_efficiency = 1.0
	crafting_speed = 1.0
	material_storage = 1000
	forge_temperature = 1000.0
	
	# 设置渲染模式为自由组件系统
	render_mode = RenderMode.TRADITIONAL
	allow_free_placement = true
	
	# 初始化自由组件
	_setup_workshop_components()

func _setup_workshop_components():
	"""设置工坊的自由组件"""
	LogManager.info("🔨 [UnifiedWorkshop] 设置工坊自由组件")
	
	# 清空现有组件
	free_components.clear()
	
	# 添加工坊核心组件
	_add_workshop_structure()
	_add_forge_components()
	_add_workbench_components()
	_add_tool_racks()
	_add_material_storage()
	_add_crafting_tools()
	
	# 更新边界框
	_update_bounds()
	
	LogManager.info("✅ [UnifiedWorkshop] 工坊自由组件设置完成 (组件数量: %d)" % free_components.size())

func _add_workshop_structure():
	"""添加工坊主体结构"""
	# 主建筑体
	add_component(
		"Workshop_Main",
		Vector3(0.2, 0, 0.2),
		Vector3(0.6, 1.0, 0.6),
		"structure"
	)
	
	# 屋顶
	add_component(
		"Workshop_Roof",
		Vector3(0.1, 1.0, 0.1),
		Vector3(0.8, 0.1, 0.8),
		"structure"
	)

func _add_forge_components():
	"""添加熔炉组件"""
	# 主熔炉
	add_component(
		"Forge_Main",
		Vector3(0.3, 0.1, 0.3),
		Vector3(0.4, 0.6, 0.4),
		"decoration"
	)
	
	# 熔炉火焰
	add_component(
		"Forge_Flame",
		Vector3(0.35, 0.7, 0.35),
		Vector3(0.3, 0.2, 0.3),
		"decoration"
	)

func _add_workbench_components():
	"""添加工作台组件"""
	# 主工作台
	add_component(
		"Workbench_Main",
		Vector3(0.1, 0.1, 0.6),
		Vector3(0.3, 0.1, 0.3),
		"decoration"
	)
	
	# 工具架
	add_component(
		"Tool_Shelf",
		Vector3(0.6, 0.1, 0.1),
		Vector3(0.3, 0.1, 0.3),
		"decoration"
	)

func _add_tool_racks():
	"""添加工具架组件"""
	# 工具架1
	add_component(
		"Tool_Rack_1",
		Vector3(0.1, 0.2, 0.1),
		Vector3(0.1, 0.6, 0.1),
		"decoration"
	)
	
	# 工具架2
	add_component(
		"Tool_Rack_2",
		Vector3(0.8, 0.2, 0.1),
		Vector3(0.1, 0.6, 0.1),
		"decoration"
	)

func _add_material_storage():
	"""添加材料存储组件"""
	# 材料堆1
	add_component(
		"Material_Pile_1",
		Vector3(0.1, 0.05, 0.8),
		Vector3(0.2, 0.1, 0.2),
		"decoration"
	)
	
	# 材料堆2
	add_component(
		"Material_Pile_2",
		Vector3(0.7, 0.05, 0.8),
		Vector3(0.2, 0.1, 0.2),
		"decoration"
	)

func _add_crafting_tools():
	"""添加制作工具组件"""
	# 铁砧
	add_component(
		"Anvil",
		Vector3(0.4, 0.05, 0.6),
		Vector3(0.2, 0.15, 0.2),
		"decoration"
	)
	
	# 锤子
	add_component(
		"Hammer",
		Vector3(0.5, 0.2, 0.5),
		Vector3(0.1, 0.3, 0.1),
		"decoration"
	)

func _ready():
	"""初始化工坊"""
	super._ready()
	
	# 设置自由组件系统
	setup_free_components()
	
	# 设置工坊特效
	_setup_workshop_effects()
	
	LogManager.info("✅ [UnifiedWorkshop] 工坊初始化完成")

func _setup_workshop_effects():
	"""设置工坊特效"""
	# 添加熔炉光源
	var forge_light = OmniLight3D.new()
	forge_light.name = "ForgeLight"
	forge_light.light_energy = 1.8
	forge_light.light_color = Color(1.0, 0.3, 0.0) # 橙红色
	forge_light.omni_range = 2.5
	forge_light.position = Vector3(0.5, 0.8, 0.5)
	add_child(forge_light)
	
	# 添加火花粒子效果
	var spark_particles = GPUParticles3D.new()
	spark_particles.name = "SparkParticles"
	spark_particles.emitting = true
	spark_particles.position = Vector3(0.5, 0.7, 0.5)
	add_child(spark_particles)

func _process(delta: float):
	"""每帧更新"""
	
	# 更新熔炉效果
	_update_forge_effects(delta)

func _update_forge_effects(delta: float):
	"""更新熔炉效果"""
	# 更新熔炉温度
	forge_temperature = 1000.0 + sin(Time.get_time_dict_from_system()["second"] * 4) * 200.0
	
	# 更新光源强度
	var forge_light = get_node_or_null("ForgeLight")
	if forge_light:
		var intensity = 1.5 + sin(Time.get_time_dict_from_system()["second"] * 6) * 0.3
		forge_light.light_energy = intensity

func get_production_efficiency() -> float:
	"""获取生产效率"""
	return production_efficiency

func get_crafting_speed() -> float:
	"""获取制作速度"""
	return crafting_speed

func get_material_storage() -> int:
	"""获取材料存储"""
	return material_storage

func get_forge_temperature() -> float:
	"""获取熔炉温度"""
	return forge_temperature

func get_workshop_info() -> Dictionary:
	"""获取工坊信息"""
	var info = get_building_info()
	info["production_efficiency"] = production_efficiency
	info["crafting_speed"] = crafting_speed
	info["material_storage"] = material_storage
	info["forge_temperature"] = forge_temperature
	info["free_components_count"] = free_components.size()
	info["component_bounds"] = component_bounds
	return info

func _load_building_specific_components():
	"""加载工坊专用构件"""
	# 预加载工坊配置
	const WorkshopConfig = preload("res://scenes/buildings/workshop/WorkshopConfig.gd")
	
	# 使用工坊配置加载组件
	var config = WorkshopConfig.get_all_components()
	
	for component_name in config:
		var component_config = config[component_name]
		var component_id = component_config.get("id", 0)
		
		# 加载组件到库
		_add_component_to_library(component_name, component_id)
		
		# 应用专用材质
		var material_name = component_config.get("material", "")
		var texture_name = component_config.get("texture", "")
		
		if not material_name.is_empty():
			_apply_workshop_material(component_id, material_name, texture_name)

func _apply_workshop_material(component_id: int, material_name: String, texture_name: String):
	"""应用工坊专用材质"""
	# 创建材质
	var material = StandardMaterial3D.new()
	
	# 根据材质类型设置属性
	match material_name:
		"wood":
			material.albedo_color = Color(0.4, 0.2, 0.1)
			material.roughness = 0.8
			material.metallic = 0.0
		"metal":
			material.albedo_color = Color(0.5, 0.5, 0.5)
			material.roughness = 0.4
			material.metallic = 0.7
		"stone":
			material.albedo_color = Color(0.5, 0.4, 0.3)
			material.roughness = 0.8
			material.metallic = 0.2
	
	# 将材质应用到组件
	if mesh_library:
		mesh_library.set_item_mesh(component_id, _create_component_mesh_with_material(material))
	
	LogManager.info("🎨 [UnifiedWorkshop] 应用材质: %s -> 组件ID %d" % [material_name, component_id])

func _create_component_mesh_with_material(material: StandardMaterial3D) -> Mesh:
	"""创建带材质的组件网格"""
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.33, 0.33, 0.33)
	box_mesh.surface_set_material(0, material)
	return box_mesh

func _setup_building_effects():
	"""设置工坊特效"""
	# 工坊特有的生产特效
	LogManager.info("🔧 [UnifiedWorkshop] 设置工坊特效")