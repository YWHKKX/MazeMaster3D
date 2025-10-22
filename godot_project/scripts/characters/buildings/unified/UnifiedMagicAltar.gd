extends UnifiedBuildingSystem
class_name UnifiedMagicAltar

## 🔮 统一魔法祭坛建筑
## 使用自由组件系统的魔法祭坛实现，1x1瓦块建筑

# 魔法祭坛专用属性
var spell_power: float = 1.0
var mana_generation_rate: float = 5.0
var ritual_active: bool = false
var magic_aura_intensity: float = 1.0

func _init():
	"""初始化魔法祭坛"""
	super._init()
	
	# 基础属性
	building_type = BuildingTypes.BuildingType.MAGIC_ALTAR
	building_name = "魔法祭坛"
	building_description = "魔法建筑，用于施法和召唤"
	
	# 建筑属性
	max_health = 180
	health = 180
	armor = 8
	cost_gold = 1200
	
	# 建筑尺寸和主题
	building_size = Vector2(1, 1) # 1x1瓦块
	building_theme = "arcane"
	building_tier = 3
	building_category = "magic"
	
	# 魔力存储属性
	mana_storage_capacity = 300
	stored_mana = 0 # 初始魔力为0
	
	# 魔法祭坛专用属性
	spell_power = 1.0
	mana_generation_rate = 5.0
	ritual_active = false
	magic_aura_intensity = 1.0
	
	# 设置渲染模式为自由组件系统
	render_mode = RenderMode.TRADITIONAL
	allow_free_placement = true
	
	# 初始化自由组件
	_setup_magic_altar_components()

func _setup_magic_altar_components():
	"""设置魔法祭坛的自由组件"""
	LogManager.info("🔮 [UnifiedMagicAltar] 设置魔法祭坛自由组件")
	
	# 清空现有组件
	free_components.clear()
	
	# 添加魔法祭坛核心组件
	_add_altar_structure()
	_add_magic_crystals()
	_add_rune_circles()
	_add_ritual_components()
	_add_magic_aura()
	
	# 更新边界框
	_update_bounds()
	
	LogManager.info("✅ [UnifiedMagicAltar] 魔法祭坛自由组件设置完成 (组件数量: %d)" % free_components.size())

func _add_altar_structure():
	"""添加祭坛主体结构"""
	# 祭坛基座
	add_component(
		"Altar_Base",
		Vector3(0.2, 0, 0.2),
		Vector3(0.6, 0.2, 0.6),
		"structure"
	)
	
	# 祭坛台面
	add_component(
		"Altar_Top",
		Vector3(0.1, 0.2, 0.1),
		Vector3(0.8, 0.1, 0.8),
		"structure"
	)
	
	# 祭坛支柱
	add_component(
		"Altar_Pillar",
		Vector3(0.4, 0.3, 0.4),
		Vector3(0.2, 0.8, 0.2),
		"structure"
	)

func _add_magic_crystals():
	"""添加魔法水晶组件"""
	# 主水晶
	add_component(
		"Magic_Crystal_Main",
		Vector3(0.4, 1.1, 0.4),
		Vector3(0.2, 0.3, 0.2),
		"decoration"
	)
	
	# 辅助水晶1
	add_component(
		"Magic_Crystal_1",
		Vector3(0.1, 0.3, 0.1),
		Vector3(0.15, 0.2, 0.15),
		"decoration"
	)
	
	# 辅助水晶2
	add_component(
		"Magic_Crystal_2",
		Vector3(0.75, 0.3, 0.1),
		Vector3(0.15, 0.2, 0.15),
		"decoration"
	)
	
	# 辅助水晶3
	add_component(
		"Magic_Crystal_3",
		Vector3(0.1, 0.3, 0.75),
		Vector3(0.15, 0.2, 0.15),
		"decoration"
	)
	
	# 辅助水晶4
	add_component(
		"Magic_Crystal_4",
		Vector3(0.75, 0.3, 0.75),
		Vector3(0.15, 0.2, 0.15),
		"decoration"
	)

func _add_rune_circles():
	"""添加符文圈组件"""
	# 外圈符文
	add_component(
		"Rune_Circle_Outer",
		Vector3(0.2, 0.05, 0.2),
		Vector3(0.6, 0.05, 0.6),
		"decoration"
	)
	
	# 内圈符文
	add_component(
		"Rune_Circle_Inner",
		Vector3(0.35, 0.1, 0.35),
		Vector3(0.3, 0.05, 0.3),
		"decoration"
	)

func _add_ritual_components():
	"""添加仪式组件"""
	# 仪式蜡烛1
	add_component(
		"Ritual_Candle_1",
		Vector3(0.3, 0.3, 0.3),
		Vector3(0.05, 0.2, 0.05),
		"decoration"
	)
	
	# 仪式蜡烛2
	add_component(
		"Ritual_Candle_2",
		Vector3(0.65, 0.3, 0.3),
		Vector3(0.05, 0.2, 0.05),
		"decoration"
	)
	
	# 仪式蜡烛3
	add_component(
		"Ritual_Candle_3",
		Vector3(0.3, 0.3, 0.65),
		Vector3(0.05, 0.2, 0.05),
		"decoration"
	)
	
	# 仪式蜡烛4
	add_component(
		"Ritual_Candle_4",
		Vector3(0.65, 0.3, 0.65),
		Vector3(0.05, 0.2, 0.05),
		"decoration"
	)

func _add_magic_aura():
	"""添加魔法光环组件"""
	# 魔法光环
	add_component(
		"Magic_Aura",
		Vector3(0.4, 0.05, 0.4),
		Vector3(0.2, 0.1, 0.2),
		"decoration"
	)

func _ready():
	"""初始化魔法祭坛"""
	super._ready()
	
	# 设置自由组件系统
	setup_free_components()
	
	# 设置魔法祭坛特效
	_setup_magic_altar_effects()
	
	LogManager.info("✅ [UnifiedMagicAltar] 魔法祭坛初始化完成")

func _setup_magic_altar_effects():
	"""设置魔法祭坛特效"""
	# 添加魔法光源
	var magic_light = OmniLight3D.new()
	magic_light.name = "MagicLight"
	magic_light.light_energy = 1.5
	magic_light.light_color = Color(0.8, 0.2, 1.0) # 紫色
	magic_light.omni_range = 3.5
	magic_light.position = Vector3(0.5, 1.2, 0.5)
	add_child(magic_light)
	
	# 添加魔法粒子效果
	var magic_particles = GPUParticles3D.new()
	magic_particles.name = "MagicParticles"
	magic_particles.emitting = true
	magic_particles.position = Vector3(0.5, 1.1, 0.5)
	add_child(magic_particles)

func _process(delta: float):
	"""每帧更新"""
	
	# 更新魔法效果
	_update_magic_effects(delta)
	
	# 更新仪式状态
	_update_ritual_status(delta)

func _update_magic_effects(delta: float):
	"""更新魔法效果"""
	# 更新魔法光环强度
	magic_aura_intensity = 1.0 + sin(Time.get_time_dict_from_system()["second"] * 2) * 0.3
	
	# 更新光源强度
	var magic_light = get_node_or_null("MagicLight")
	if magic_light:
		var intensity = 1.2 + magic_aura_intensity * 0.3
		magic_light.light_energy = intensity

func _update_ritual_status(delta: float):
	"""更新仪式状态"""
	# 检查是否有足够的魔力进行仪式
	if stored_mana >= 50 and not ritual_active:
		_start_ritual()
	elif stored_mana < 10 and ritual_active:
		_stop_ritual()

func _start_ritual():
	"""开始仪式"""
	ritual_active = true
	LogManager.info("🔮 [UnifiedMagicAltar] 魔法仪式开始")

func _stop_ritual():
	"""停止仪式"""
	ritual_active = false
	LogManager.info("🔮 [UnifiedMagicAltar] 魔法仪式结束")

func get_spell_power() -> float:
	"""获取法术威力"""
	return spell_power

func get_mana_generation_rate() -> float:
	"""获取魔力生成速率"""
	return mana_generation_rate

func is_ritual_active() -> bool:
	"""检查仪式是否激活"""
	return ritual_active

func get_magic_aura_intensity() -> float:
	"""获取魔法光环强度"""
	return magic_aura_intensity

func get_magic_altar_info() -> Dictionary:
	"""获取魔法祭坛信息"""
	var info = get_building_info()
	info["spell_power"] = spell_power
	info["mana_generation_rate"] = mana_generation_rate
	info["ritual_active"] = ritual_active
	info["magic_aura_intensity"] = magic_aura_intensity
	info["free_components_count"] = free_components.size()
	info["component_bounds"] = component_bounds
	return info

func _load_building_specific_components():
	"""加载魔法祭坛专用构件"""
	# 预加载魔法祭坛配置
	const MagicAltarConfig = preload("res://scenes/buildings/magic_altar/MagicAltarConfig.gd")
	
	# 使用魔法祭坛配置加载组件
	var config = MagicAltarConfig.get_all_components()
	
	for component_name in config:
		var component_config = config[component_name]
		var component_id = component_config.get("id", 0)
		
		# 加载组件到库
		_add_component_to_library(component_name, component_id)
		
		# 应用专用材质
		var material_name = component_config.get("material", "")
		var texture_name = component_config.get("texture", "")
		
		if not material_name.is_empty():
			_apply_magic_altar_material(component_id, material_name, texture_name)

func _apply_magic_altar_material(component_id: int, material_name: String, texture_name: String):
	"""应用魔法祭坛专用材质"""
	# 创建材质
	var material = StandardMaterial3D.new()
	
	# 根据材质类型设置属性
	match material_name:
		"magic":
			material.albedo_color = Color(0.1, 0.05, 0.2)
			material.roughness = 0.1
			material.metallic = 0.0
			material.emission_enabled = true
			material.emission = Color(0.3, 0.1, 0.6)
			material.emission_energy = 2.5
		"cloth":
			material.albedo_color = Color(0.8, 0.6, 0.4)
			material.roughness = 0.8
			material.metallic = 0.0
			material.emission_enabled = true
			material.emission = Color(1.0, 0.8, 0.4)
			material.emission_energy = 1.0
	
	# 将材质应用到组件
	if mesh_library:
		mesh_library.set_item_mesh(component_id, _create_component_mesh_with_material(material))
	
	LogManager.info("🎨 [UnifiedMagicAltar] 应用材质: %s -> 组件ID %d" % [material_name, component_id])

func _create_component_mesh_with_material(material: StandardMaterial3D) -> Mesh:
	"""创建带材质的组件网格"""
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.33, 0.33, 0.33)
	box_mesh.surface_set_material(0, material)
	return box_mesh

func _setup_building_effects():
	"""设置魔法祭坛特效"""
	# 魔法祭坛特有的魔法特效
	LogManager.info("🔮 [UnifiedMagicAltar] 设置魔法祭坛特效")