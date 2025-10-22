extends UnifiedBuildingSystem
class_name UnifiedTreasury

## 💰 统一金库
## 使用自由组件系统的金库实现，1x1瓦块建筑

# 预加载金库配置
const TreasuryConfig = preload("res://scenes/buildings/treasury/TreasuryConfig.gd")
const TreasuryMaterialConfig = preload("res://scenes/buildings/treasury/materials/TreasuryMaterialConfig.gd")
const TreasuryTextures = preload("res://scenes/buildings/treasury/textures/TreasuryTextures.gd")

# 金库专用属性
var storage_capacity: int = 10000
var storage_efficiency: float = 1.0
var security_level: int = 3

# 金库特效属性
var gold_sparkle_level: float = 1.0
var treasure_glow: float = 0.0
var traditional_visual: MeshInstance3D = null

func _init():
	"""初始化金库"""
	super._init()
	
	# 基础属性
	building_type = BuildingTypes.BuildingType.TREASURY
	building_name = "金库"
	building_description = "存储金币的安全建筑"
	
	# 建筑属性
	max_health = 200
	health = 200
	armor = 5
	cost_gold = 500
	
	# 建筑尺寸和主题
	building_size = Vector2(1, 1) # 1x1瓦块
	building_theme = "treasury"
	building_tier = 2
	building_category = "economic"
	
	# 金库专用属性
	storage_capacity = 10000
	security_level = 3
	gold_storage_capacity = storage_capacity
	stored_gold = 0 # 初始金币为0
	
	# 设置渲染模式为自由组件系统
	render_mode = RenderMode.TRADITIONAL
	allow_free_placement = true
	
	# 初始化自由组件
	_setup_treasury_components()

func _setup_treasury_components():
	"""设置金库的自由组件"""
	LogManager.info("💰 [UnifiedTreasury] 设置金库自由组件")
	
	# 清空现有组件
	free_components.clear()
	
	# 添加金库核心组件
	_add_treasury_structure()
	_add_gold_storage()
	_add_security_features()
	_add_treasury_entrance()
	_add_gold_decorations()
	
	# 更新边界框
	_update_bounds()
	
	LogManager.info("✅ [UnifiedTreasury] 金库自由组件设置完成 (组件数量: %d)" % free_components.size())

func _add_treasury_structure():
	"""添加金库主体结构"""
	# 主建筑体
	add_component(
		"Treasury_Main",
		Vector3(0.2, 0, 0.2),
		Vector3(0.6, 1.2, 0.6),
		"structure"
	)
	
	# 屋顶
	add_component(
		"Treasury_Roof",
		Vector3(0.1, 1.2, 0.1),
		Vector3(0.8, 0.1, 0.8),
		"structure"
	)

func _add_gold_storage():
	"""添加金币存储组件"""
	# 主存储箱
	add_component(
		"Gold_Vault",
		Vector3(0.3, 0.1, 0.3),
		Vector3(0.4, 0.6, 0.4),
		"decoration"
	)
	
	# 金币堆1
	add_component(
		"Gold_Pile_1",
		Vector3(0.1, 0.05, 0.1),
		Vector3(0.2, 0.1, 0.2),
		"decoration"
	)
	
	# 金币堆2
	add_component(
		"Gold_Pile_2",
		Vector3(0.7, 0.05, 0.1),
		Vector3(0.2, 0.1, 0.2),
		"decoration"
	)
	
	# 金币堆3
	add_component(
		"Gold_Pile_3",
		Vector3(0.1, 0.05, 0.7),
		Vector3(0.2, 0.1, 0.2),
		"decoration"
	)
	
	# 金币堆4
	add_component(
		"Gold_Pile_4",
		Vector3(0.7, 0.05, 0.7),
		Vector3(0.2, 0.1, 0.2),
		"decoration"
	)

func _add_security_features():
	"""添加安全特性组件"""
	# 安全锁
	add_component(
		"Security_Lock",
		Vector3(0.4, 0.3, 0.1),
		Vector3(0.2, 0.1, 0.05),
		"decoration"
	)
	
	# 监控水晶
	add_component(
		"Security_Crystal",
		Vector3(0.4, 0.8, 0.4),
		Vector3(0.2, 0.2, 0.2),
		"decoration"
	)

func _add_treasury_entrance():
	"""添加金库入口组件"""
	add_component(
		"Treasury_Door",
		Vector3(0.3, 0, 0.1),
		Vector3(0.4, 0.8, 0.1),
		"door"
	)

func _add_gold_decorations():
	"""添加金币装饰组件"""
	# 金币装饰1
	add_component(
		"Gold_Ornament_1",
		Vector3(0.1, 0.6, 0.4),
		Vector3(0.1, 0.1, 0.1),
		"decoration"
	)
	
	# 金币装饰2
	add_component(
		"Gold_Ornament_2",
		Vector3(0.8, 0.6, 0.4),
		Vector3(0.1, 0.1, 0.1),
		"decoration"
	)

func _ready():
	"""初始化金库"""
	super._ready()
	
	# 设置自由组件系统
	setup_free_components()
	
	# 设置金库特效
	_setup_treasury_effects()
	
	LogManager.info("✅ [UnifiedTreasury] 金库初始化完成")

func _setup_treasury_effects():
	"""设置金库特效"""
	# 添加金币光源
	var gold_light = OmniLight3D.new()
	gold_light.name = "GoldLight"
	gold_light.light_energy = 1.0
	gold_light.light_color = Color(1.0, 0.84, 0.0) # 金黄色
	gold_light.omni_range = 3.0
	gold_light.position = Vector3(0.5, 0.8, 0.5)
	add_child(gold_light)
	
	# 添加金币粒子效果
	var gold_particles = GPUParticles3D.new()
	gold_particles.name = "GoldParticles"
	gold_particles.emitting = true
	gold_particles.position = Vector3(0.5, 0.5, 0.5)
	add_child(gold_particles)

func _process(delta: float):
	"""每帧更新"""
	
	# 更新金币特效
	_update_gold_effects(delta)
	
	# 更新存储系统
	_update_storage_system(delta)

func _update_gold_effects(delta: float):
	"""更新金币特效"""
	# 更新金币闪烁
	gold_sparkle_level = 1.0 + sin(Time.get_time_dict_from_system()["second"] * 4) * 0.3
	
	# 更新宝藏发光
	treasure_glow = sin(Time.get_time_dict_from_system()["second"] * 2) * 0.5 + 0.5
	
	# 更新光源强度
	var gold_light = get_node_or_null("GoldLight")
	if gold_light:
		gold_light.light_energy = 0.8 + treasure_glow * 0.4

func _update_storage_system(delta: float):
	"""更新存储系统"""
	# 根据存储的金币数量调整特效强度
	var storage_ratio = float(stored_gold) / float(gold_storage_capacity)
	
	# 调整特效强度
	gold_sparkle_level = 1.0 + storage_ratio * 0.5

func get_storage_efficiency() -> float:
	"""获取存储效率"""
	return storage_efficiency

func get_security_level() -> float:
	"""获取安全等级"""
	return security_level

func get_storage_percentage() -> float:
	"""获取存储百分比"""
	return float(stored_gold) / float(gold_storage_capacity)

func can_store_more() -> bool:
	"""检查是否可以存储更多金币"""
	return stored_gold < gold_storage_capacity

func get_storage_info() -> Dictionary:
	"""获取存储信息"""
	return {
		"stored_gold": stored_gold,
		"capacity": gold_storage_capacity,
		"percentage": get_storage_percentage(),
		"efficiency": storage_efficiency,
		"security": security_level,
		"can_store_more": can_store_more()
	}

func enhance_storage():
	"""增强存储能力"""
	# 增加存储容量
	gold_storage_capacity += 1000
	storage_efficiency += 0.1
	security_level += 0.1
	
	LogManager.info("💰 [UnifiedTreasury] 金库存储能力增强: 容量 %d, 效率 %.1f" % [gold_storage_capacity, storage_efficiency])

func upgrade_security():
	"""升级安全等级"""
	security_level = min(2.0, security_level + 0.2)
	LogManager.info("💰 [UnifiedTreasury] 金库安全等级提升: %.1f" % security_level)

func get_treasury_info() -> Dictionary:
	"""获取金库信息"""
	var info = get_building_info()
	info["storage_capacity"] = storage_capacity
	info["storage_efficiency"] = storage_efficiency
	info["security_level"] = security_level
	info["gold_sparkle_level"] = gold_sparkle_level
	info["treasure_glow"] = treasure_glow
	info["free_components_count"] = free_components.size()
	info["component_bounds"] = component_bounds
	return info

func _load_building_specific_components():
	"""加载金库专用构件"""
	# 使用金库配置加载组件
	var config = TreasuryConfig.get_all_components()
	
	for component_name in config:
		var component_config = config[component_name]
		var component_id = component_config.get("id", 0)
		
		# 加载组件到库
		_add_component_to_library(component_name, component_id)
		
		# 应用专用材质
		var material_name = component_config.get("material", "")
		var texture_name = component_config.get("texture", "")
		
		if not material_name.is_empty():
			_apply_treasury_material(component_id, material_name, texture_name)

func _apply_treasury_material(component_id: int, material_name: String, texture_name: String):
	"""应用金库专用材质"""
	# 创建材质
	var material = TreasuryMaterialConfig.create_material(material_name)
	if not material:
		LogManager.warning("⚠️ [UnifiedTreasury] 无法创建材质: %s" % material_name)
		return
	
	# 应用纹理
	if not texture_name.is_empty():
		TreasuryTextures.apply_texture_to_material(material, texture_name)
	
	# 将材质应用到组件
	if mesh_library:
		mesh_library.set_item_mesh(component_id, _create_component_mesh_with_material(material))
	
	LogManager.info("🎨 [UnifiedTreasury] 应用材质: %s -> 组件ID %d" % [material_name, component_id])

func _create_component_mesh_with_material(material: StandardMaterial3D) -> Mesh:
	"""创建带材质的组件网格"""
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.33, 0.33, 0.33)
	box_mesh.surface_set_material(0, material)
	return box_mesh
	
	# 金库特定初始化
	_setup_treasury_specific()


func _setup_treasury_specific():
	"""设置金库特定功能"""
	# 设置金币特效
	if building_3d:
		_setup_gold_effects()
	
	# 设置存储系统
	_setup_storage_system()


func _setup_gold_effects():
	"""设置金币特效"""
	if not building_3d:
		return
	
	# 启动金币粒子效果
	if building_3d.effect_manager:
		building_3d.effect_manager.start_functional_effects()
	
	# 设置金币光效
	_setup_gold_lighting()


func _setup_gold_lighting():
	"""设置金币光照"""
	# 创建金币光源
	var gold_light = OmniLight3D.new()
	gold_light.name = "GoldLight"
	gold_light.light_energy = 1.0
	gold_light.light_color = Color(1.0, 0.84, 0.0) # 金黄色
	gold_light.omni_range = 6.0
	gold_light.position = Vector3(0, 1.0, 0)
	
	add_child(gold_light)


func _setup_storage_system():
	"""设置存储系统"""
	# 金库的存储系统已经在父类中实现
	# 这里可以添加金库特定的存储逻辑
	pass


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("💰 [UnifiedTreasury] 金库3D准备就绪")
	
	# 启动金币特效
	_setup_gold_effects()
	
	# 启动存储系统
	_setup_storage_system()


func on_traditional_building_ready():
	"""传统建筑准备就绪回调"""
	LogManager.info("💰 [UnifiedTreasury] 金库传统准备就绪")
	
	# 传统系统的金币效果
	_setup_traditional_gold_effects()


func _setup_traditional_gold_effects():
	"""设置传统金币效果"""
	if not traditional_visual:
		return
	
	# 设置金币材质
	var material = traditional_visual.material_override
	if material:
		material.emission_enabled = true
		material.emission = Color(1.0, 0.84, 0.0)
		material.emission_energy = 0.4


func _on_construction_completed():
	"""建造完成回调"""
	# super._on_construction_completed()  # 父类方法不存在
	
	# 金库建造完成后的特殊处理
	LogManager.info("💰 [UnifiedTreasury] 金库建造完成，存储系统激活")
	
	# 根据当前渲染系统执行相应逻辑
	if render_mode == RenderMode.LAYERED:
		on_3d_building_ready()
	else:
		on_traditional_building_ready()


func switch_to_3d_system():
	"""切换到3D系统"""
	# super.switch_to_3d_system()  # 父类方法不存在
	
	# 金库特定的3D切换逻辑
	on_3d_building_ready()


func switch_to_traditional_system():
	"""切换到传统系统"""
	# super.switch_to_traditional_system()  # 父类方法不存在
	
	# 金库特定的传统切换逻辑
	on_traditional_building_ready()
