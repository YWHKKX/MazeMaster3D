extends UnifiedBuildingSystem
class_name UnifiedShadowTemple

## 🌑 统一暗影神殿建筑
## 使用自由组件系统的暗影神殿实现，3x3瓦块建筑

# 暗影神殿专用属性
var shadow_power: float = 1.0
var dark_ritual_active: bool = false
var shadow_aura_intensity: float = 1.0
var corruption_level: float = 0.0

func _init():
	"""初始化暗影神殿"""
	super._init()
	
	# 基础属性
	building_type = BuildingTypes.BuildingType.SHADOW_TEMPLE
	building_name = "暗影神殿"
	building_description = "暗影建筑，用于黑暗魔法和仪式"
	
	# 建筑属性
	max_health = 250
	health = 250
	armor = 12
	cost_gold = 1500
	
	# 建筑尺寸和主题
	building_size = Vector2(3, 3) # 3x3瓦块
	building_theme = "shadow"
	building_tier = 3
	building_category = "magic"
	
	# 暗影神殿专用属性
	shadow_power = 1.0
	dark_ritual_active = false
	shadow_aura_intensity = 1.0
	corruption_level = 0.0
	
	# 设置渲染模式为自由组件系统
	render_mode = RenderMode.TRADITIONAL
	allow_free_placement = true
	
	# 初始化自由组件
	_setup_shadow_temple_components()

func _setup_shadow_temple_components():
	"""设置暗影神殿的自由组件"""
	LogManager.info("🌑 [UnifiedShadowTemple] 设置暗影神殿自由组件")
	
	# 清空现有组件
	free_components.clear()
	
	# 添加暗影神殿核心组件
	_add_temple_structure()
	_add_shadow_altar()
	_add_dark_crystals()
	_add_shadow_pillars()
	_add_dark_ritual_components()
	_add_shadow_aura()
	
	# 更新边界框
	_update_bounds()
	
	# 🔧 验证坐标系统一致性
	validate_coordinate_system()

func _add_temple_structure():
	"""添加神殿主体结构"""
	# 神殿基座
	add_component(
		"Temple_Base",
		Vector3(0.3, 0, 0.3),
		Vector3(2.4, 0.3, 2.4),
		"structure"
	)
	
	# 神殿墙壁
	add_component(
		"Temple_Wall_North",
		Vector3(0.3, 0.3, 0.1),
		Vector3(2.4, 1.5, 0.2),
		"structure"
	)
	
	add_component(
		"Temple_Wall_South",
		Vector3(0.3, 0.3, 2.7),
		Vector3(2.4, 1.5, 0.2),
		"structure"
	)
	
	add_component(
		"Temple_Wall_East",
		Vector3(2.7, 0.3, 0.3),
		Vector3(0.2, 1.5, 2.4),
		"structure"
	)
	
	add_component(
		"Temple_Wall_West",
		Vector3(0.1, 0.3, 0.3),
		Vector3(0.2, 1.5, 2.4),
		"structure"
	)
	
	# 神殿屋顶
	add_component(
		"Temple_Roof",
		Vector3(0.1, 1.8, 0.1),
		Vector3(2.8, 0.2, 2.8),
		"structure"
	)

func _add_shadow_altar():
	"""添加暗影祭坛组件"""
	# 主祭坛
	add_component(
		"Shadow_Altar",
		Vector3(1.2, 0.3, 1.2),
		Vector3(0.6, 0.8, 0.6),
		"decoration"
	)
	
	# 祭坛台面
	add_component(
		"Altar_Top",
		Vector3(1.1, 1.1, 1.1),
		Vector3(0.8, 0.1, 0.8),
		"decoration"
	)

func _add_dark_crystals():
	"""添加暗影水晶组件"""
	# 主暗影水晶
	add_component(
		"Dark_Crystal_Main",
		Vector3(1.3, 1.2, 1.3),
		Vector3(0.4, 0.6, 0.4),
		"decoration"
	)
	
	# 辅助暗影水晶
	var crystal_positions = [
		Vector3(0.5, 0.5, 0.5),
		Vector3(2.0, 0.5, 0.5),
		Vector3(0.5, 0.5, 2.0),
		Vector3(2.0, 0.5, 2.0),
		Vector3(1.0, 0.5, 0.5),
		Vector3(1.5, 0.5, 0.5),
		Vector3(1.0, 0.5, 2.0),
		Vector3(1.5, 0.5, 2.0)
	]
	
	for i in range(crystal_positions.size()):
		add_component(
			"Dark_Crystal_" + str(i + 1),
			crystal_positions[i],
			Vector3(0.2, 0.4, 0.2),
			"decoration"
		)

func _add_shadow_pillars():
	"""添加暗影支柱组件"""
	# 暗影支柱1
	add_component(
		"Shadow_Pillar_1",
		Vector3(0.3, 0.3, 0.3),
		Vector3(0.2, 1.2, 0.2),
		"decoration"
	)
	
	# 暗影支柱2
	add_component(
		"Shadow_Pillar_2",
		Vector3(2.5, 0.3, 0.3),
		Vector3(0.2, 1.2, 0.2),
		"decoration"
	)
	
	# 暗影支柱3
	add_component(
		"Shadow_Pillar_3",
		Vector3(0.3, 0.3, 2.5),
		Vector3(0.2, 1.2, 0.2),
		"decoration"
	)
	
	# 暗影支柱4
	add_component(
		"Shadow_Pillar_4",
		Vector3(2.5, 0.3, 2.5),
		Vector3(0.2, 1.2, 0.2),
		"decoration"
	)

func _add_dark_ritual_components():
	"""添加黑暗仪式组件"""
	# 仪式圈
	add_component(
		"Dark_Ritual_Circle",
		Vector3(0.8, 0.05, 0.8),
		Vector3(1.4, 0.1, 1.4),
		"decoration"
	)
	
	# 黑暗符文
	add_component(
		"Dark_Runes",
		Vector3(1.0, 0.1, 1.0),
		Vector3(1.0, 0.05, 1.0),
		"decoration"
	)

func _add_shadow_aura():
	"""添加暗影光环组件"""
	# 暗影光环
	add_component(
		"Shadow_Aura",
		Vector3(1.2, 0.05, 1.2),
		Vector3(0.6, 0.1, 0.6),
		"decoration"
	)

func _ready():
	"""初始化暗影神殿"""
	super._ready()
	
	# 设置自由组件系统
	setup_free_components()
	
	# 设置暗影神殿特效
	_setup_shadow_temple_effects()
	
	LogManager.info("✅ [UnifiedShadowTemple] 暗影神殿初始化完成")

func _setup_shadow_temple_effects():
	"""设置暗影神殿特效"""
	# 添加暗影光源
	var shadow_light = OmniLight3D.new()
	shadow_light.name = "ShadowLight"
	shadow_light.light_energy = 0.8
	shadow_light.light_color = Color(0.2, 0.1, 0.3) # 深紫色
	shadow_light.omni_range = 4.0
	shadow_light.position = Vector3(1.5, 1.5, 1.5)
	add_child(shadow_light)
	
	# 添加暗影粒子效果
	var shadow_particles = GPUParticles3D.new()
	shadow_particles.name = "ShadowParticles"
	shadow_particles.emitting = true
	shadow_particles.position = Vector3(1.5, 1.2, 1.5)
	add_child(shadow_particles)

func _process(delta: float):
	"""每帧更新"""
	# 更新暗影效果
	_update_shadow_effects(delta)
	
	# 更新黑暗仪式
	_update_dark_ritual(delta)

func _update_shadow_effects(delta: float):
	"""更新暗影效果"""
	# 更新暗影光环强度
	shadow_aura_intensity = 1.0 + sin(Time.get_time_dict_from_system()["second"] * 1.5) * 0.4
	
	# 更新光源强度
	var shadow_light = get_node_or_null("ShadowLight")
	if shadow_light:
		var intensity = 0.6 + shadow_aura_intensity * 0.2
		shadow_light.light_energy = intensity

func _update_dark_ritual(delta: float):
	"""更新黑暗仪式"""
	# 检查是否可以开始黑暗仪式
	if shadow_power >= 0.8 and not dark_ritual_active:
		_start_dark_ritual()
	elif shadow_power < 0.3 and dark_ritual_active:
		_stop_dark_ritual()

func _start_dark_ritual():
	"""开始黑暗仪式"""
	dark_ritual_active = true
	corruption_level += 0.1
	LogManager.info("🌑 [UnifiedShadowTemple] 黑暗仪式开始")

func _stop_dark_ritual():
	"""停止黑暗仪式"""
	dark_ritual_active = false
	LogManager.info("🌑 [UnifiedShadowTemple] 黑暗仪式结束")

func get_shadow_power() -> float:
	"""获取暗影威力"""
	return shadow_power

func is_dark_ritual_active() -> bool:
	"""检查黑暗仪式是否激活"""
	return dark_ritual_active

func get_shadow_aura_intensity() -> float:
	"""获取暗影光环强度"""
	return shadow_aura_intensity

func get_corruption_level() -> float:
	"""获取腐蚀等级"""
	return corruption_level

func get_shadow_temple_info() -> Dictionary:
	"""获取暗影神殿信息"""
	var info = get_building_info()
	info["shadow_power"] = shadow_power
	info["dark_ritual_active"] = dark_ritual_active
	info["shadow_aura_intensity"] = shadow_aura_intensity
	info["corruption_level"] = corruption_level
	info["free_components_count"] = free_components.size()
	info["component_bounds"] = component_bounds
	return info

func _load_building_specific_components():
	"""加载暗影神殿专用构件"""
	# 预加载暗影神殿配置
	const ShadowTempleConfig = preload("res://scenes/buildings/shadow_temple/ShadowTempleConfig.gd")
	
	# 使用暗影神殿配置加载组件
	var config = ShadowTempleConfig.get_all_components()
	
	for component_name in config:
		var component_config = config[component_name]
		var component_id = component_config.get("id", 0)
		
		# 加载组件到库
		_add_component_to_library(component_name, component_id)
		
		# 应用专用材质
		var material_name = component_config.get("material", "")
		var texture_name = component_config.get("texture", "")
		
		if not material_name.is_empty():
			_apply_shadow_temple_material(component_id, material_name, texture_name)

func _apply_shadow_temple_material(component_id: int, material_name: String, texture_name: String):
	"""应用暗影神殿专用材质"""
	# 创建材质
	var material = StandardMaterial3D.new()
	
	# 根据材质类型设置属性
	match material_name:
		"stone":
			material.albedo_color = Color(0.05, 0.05, 0.05)
			material.roughness = 0.9
			material.metallic = 0.1
			material.emission_enabled = true
			material.emission = Color(0.1, 0.0, 0.1)
			material.emission_energy = 1.5
		"magic":
			material.albedo_color = Color(0.1, 0.0, 0.1, 0.8)
			material.roughness = 0.1
			material.metallic = 0.0
			material.emission_enabled = true
			material.emission = Color(0.3, 0.0, 0.3)
			material.emission_energy = 2.5
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	# 将材质应用到组件
	if mesh_library:
		mesh_library.set_item_mesh(component_id, _create_component_mesh_with_material(material))
	
	LogManager.info("🎨 [UnifiedShadowTemple] 应用材质: %s -> 组件ID %d" % [material_name, component_id])

func _create_component_mesh_with_material(material: StandardMaterial3D) -> Mesh:
	"""创建带材质的组件网格"""
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.33, 0.33, 0.33)
	box_mesh.surface_set_material(0, material)
	return box_mesh

func _setup_building_effects():
	"""设置暗影神殿特效"""
	# 暗影神殿特有的暗影特效
	LogManager.info("🌑 [UnifiedShadowTemple] 设置暗影神殿特效")