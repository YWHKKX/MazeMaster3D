extends UnifiedBuildingSystem
class_name UnifiedArcaneTower

## 🔮 统一奥术塔
## 使用自由组件系统的奥术塔实现，1x1瓦块建筑

# 预加载奥术塔配置
const ArcaneTowerConfig = preload("res://scenes/buildings/arcane_tower/ArcaneTowerConfig.gd")
const ArcaneTowerMaterialConfig = preload("res://scenes/buildings/arcane_tower/materials/ArcaneTowerMaterialConfig.gd")
const ArcaneTowerTextures = preload("res://scenes/buildings/arcane_tower/textures/ArcaneTowerTextures.gd")

# 奥术塔专用属性
var attack_damage: float = 40.0
var attack_range: float = 100.0
var attack_interval: float = 2.5
var mana_cost_per_attack: float = 1.0
var last_attack_time: float = 0.0
var magic_energy_level: float = 1.0
var magic_crystal_glow: float = 0.0

func _init():
	"""初始化奥术塔"""
	super._init()
	
	# 基础属性
	building_type = BuildingTypes.BuildingType.ARCANE_TOWER
	building_name = "奥术塔"
	building_description = "发射魔法攻击的防御塔"
	
	# 建筑属性
	max_health = 300
	health = 300
	armor = 3
	cost_gold = 600
	
	# 建筑尺寸和主题
	building_size = Vector2(1, 1) # 1x1瓦块
	building_theme = "arcane_tower"
	building_tier = 2
	building_category = "magic"
	
	# 奥术塔专用属性
	attack_damage = 40.0
	attack_range = 100.0
	mana_cost_per_attack = 1.0
	
	# 设置渲染模式为自由组件系统
	render_mode = RenderMode.TRADITIONAL
	allow_free_placement = true
	
	# 初始化自由组件
	_setup_arcane_tower_components()

func _setup_arcane_tower_components():
	"""设置奥术塔的自由组件"""
	LogManager.info("🔮 [UnifiedArcaneTower] 设置奥术塔自由组件")
	
	# 清空现有组件
	free_components.clear()
	
	# 添加奥术塔核心组件
	_add_tower_structure()
	_add_magic_crystals()
	_add_arcane_orbs()
	_add_rune_stones()
	_add_spell_books()
	_add_magic_circles()
	
	# 更新边界框
	_update_bounds()
	
	LogManager.info("✅ [UnifiedArcaneTower] 奥术塔自由组件设置完成 (组件数量: %d)" % free_components.size())

func _add_tower_structure():
	"""添加塔体结构组件"""
	# 塔基
	add_component(
		"Tower_Base",
		Vector3(0.2, 0, 0.2),
		Vector3(0.6, 0.3, 0.6),
		"structure"
	)
	
	# 塔身
	add_component(
		"Tower_Body",
		Vector3(0.25, 0.3, 0.25),
		Vector3(0.5, 1.0, 0.5),
		"structure"
	)
	
	# 塔顶
	add_component(
		"Tower_Top",
		Vector3(0.3, 1.3, 0.3),
		Vector3(0.4, 0.4, 0.4),
		"structure"
	)

func _add_magic_crystals():
	"""添加魔法水晶组件"""
	# 主水晶
	add_component(
		"Magic_Crystal_Main",
		Vector3(0.4, 1.4, 0.4),
		Vector3(0.2, 0.3, 0.2),
		"decoration"
	)
	
	# 辅助水晶1
	add_component(
		"Magic_Crystal_1",
		Vector3(0.1, 0.8, 0.1),
		Vector3(0.15, 0.2, 0.15),
		"decoration"
	)
	
	# 辅助水晶2
	add_component(
		"Magic_Crystal_2",
		Vector3(0.75, 0.8, 0.1),
		Vector3(0.15, 0.2, 0.15),
		"decoration"
	)
	
	# 辅助水晶3
	add_component(
		"Magic_Crystal_3",
		Vector3(0.1, 0.8, 0.75),
		Vector3(0.15, 0.2, 0.15),
		"decoration"
	)
	
	# 辅助水晶4
	add_component(
		"Magic_Crystal_4",
		Vector3(0.75, 0.8, 0.75),
		Vector3(0.15, 0.2, 0.15),
		"decoration"
	)

func _add_arcane_orbs():
	"""添加奥术球组件"""
	# 奥术球1
	add_component(
		"Arcane_Orb_1",
		Vector3(0.2, 0.5, 0.4),
		Vector3(0.1, 0.1, 0.1),
		"decoration"
	)
	
	# 奥术球2
	add_component(
		"Arcane_Orb_2",
		Vector3(0.7, 0.5, 0.4),
		Vector3(0.1, 0.1, 0.1),
		"decoration"
	)

func _add_rune_stones():
	"""添加符文石组件"""
	# 符文石1
	add_component(
		"Rune_Stone_1",
		Vector3(0.4, 0.1, 0.1),
		Vector3(0.2, 0.1, 0.1),
		"decoration"
	)
	
	# 符文石2
	add_component(
		"Rune_Stone_2",
		Vector3(0.4, 0.1, 0.8),
		Vector3(0.2, 0.1, 0.1),
		"decoration"
	)

func _add_spell_books():
	"""添加法术书组件"""
	# 法术书1
	add_component(
		"Spell_Book_1",
		Vector3(0.1, 0.2, 0.4),
		Vector3(0.1, 0.15, 0.1),
		"decoration"
	)
	
	# 法术书2
	add_component(
		"Spell_Book_2",
		Vector3(0.8, 0.2, 0.4),
		Vector3(0.1, 0.15, 0.1),
		"decoration"
	)

func _add_magic_circles():
	"""添加魔法阵组件"""
	# 魔法阵
	add_component(
		"Magic_Circle",
		Vector3(0.3, 0.05, 0.3),
		Vector3(0.4, 0.05, 0.4),
		"decoration"
	)

func _ready():
	"""初始化奥术塔"""
	super._ready()
	
	# 设置自由组件系统
	setup_free_components()
	
	# 设置奥术塔特效
	_setup_arcane_tower_effects()
	
	LogManager.info("✅ [UnifiedArcaneTower] 奥术塔初始化完成")

func _setup_arcane_tower_effects():
	"""设置奥术塔特效"""
	# 添加魔法光源
	var magic_light = OmniLight3D.new()
	magic_light.name = "MagicLight"
	magic_light.light_energy = 1.2
	magic_light.light_color = Color(0.5, 0.2, 1.0) # 紫色
	magic_light.omni_range = 4.0
	magic_light.position = Vector3(0.5, 1.5, 0.5)
	add_child(magic_light)
	
	# 添加魔法粒子效果
	var magic_particles = GPUParticles3D.new()
	magic_particles.name = "MagicParticles"
	magic_particles.emitting = true
	magic_particles.position = Vector3(0.5, 1.4, 0.5)
	add_child(magic_particles)

func _process(delta: float):
	"""每帧更新"""
	
	# 更新魔法能量
	_update_magic_energy(delta)
	
	# 更新攻击系统
	_update_attack_system(delta)

func _update_magic_energy(delta: float):
	"""更新魔法能量"""
	# 更新魔法能量等级
	magic_energy_level = 1.0 + sin(Time.get_time_dict_from_system()["second"] * 3) * 0.2
	
	# 更新水晶发光
	magic_crystal_glow = sin(Time.get_time_dict_from_system()["second"] * 2) * 0.5 + 0.5
	
	# 更新光源强度
	var magic_light = get_node_or_null("MagicLight")
	if magic_light:
		magic_light.light_energy = 1.0 + magic_crystal_glow * 0.5

func _update_attack_system(delta: float):
	"""更新攻击系统"""
	# 检查是否可以攻击
	var current_time = Time.get_time_dict_from_system()["second"]
	if current_time - last_attack_time >= attack_interval:
		# 这里可以添加攻击逻辑
		last_attack_time = current_time

func get_attack_damage() -> float:
	"""获取攻击伤害"""
	return attack_damage

func get_attack_range() -> float:
	"""获取攻击范围"""
	return attack_range

func get_magic_energy_level() -> float:
	"""获取魔法能量等级"""
	return magic_energy_level

func get_arcane_tower_info() -> Dictionary:
	"""获取奥术塔信息"""
	var info = get_building_info()
	info["attack_damage"] = attack_damage
	info["attack_range"] = attack_range
	info["attack_interval"] = attack_interval
	info["mana_cost_per_attack"] = mana_cost_per_attack
	info["magic_energy_level"] = magic_energy_level
	info["magic_crystal_glow"] = magic_crystal_glow
	info["free_components_count"] = free_components.size()
	info["component_bounds"] = component_bounds
	return info

func _load_building_specific_components():
	"""加载奥术塔专用构件"""
	# 使用奥术塔配置加载组件
	var config = ArcaneTowerConfig.get_all_components()
	
	for component_name in config:
		var component_config = config[component_name]
		var component_id = component_config.get("id", 0)
		
		# 加载组件到库
		_add_component_to_library(component_name, component_id)
		
		# 应用专用材质
		var material_name = component_config.get("material", "")
		var texture_name = component_config.get("texture", "")
		
		if not material_name.is_empty():
			_apply_arcane_tower_material(component_id, material_name, texture_name)

func _apply_arcane_tower_material(component_id: int, material_name: String, texture_name: String):
	"""应用奥术塔专用材质"""
	# 创建材质
	var material = ArcaneTowerMaterialConfig.create_material(material_name)
	if not material:
		LogManager.warning("⚠️ [UnifiedArcaneTower] 无法创建材质: %s" % material_name)
		return
	
	# 应用纹理
	if not texture_name.is_empty():
		ArcaneTowerTextures.apply_texture_to_material(material, texture_name)
	
	# 将材质应用到组件
	if mesh_library:
		mesh_library.set_item_mesh(component_id, _create_component_mesh_with_material(material))
	
	LogManager.info("🎨 [UnifiedArcaneTower] 应用材质: %s -> 组件ID %d" % [material_name, component_id])

func _create_component_mesh_with_material(material: StandardMaterial3D) -> Mesh:
	"""创建带材质的组件网格"""
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.33, 0.33, 0.33)
	box_mesh.surface_set_material(0, material)
	return box_mesh