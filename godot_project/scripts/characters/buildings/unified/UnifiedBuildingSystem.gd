extends Node3D
class_name UnifiedBuildingSystem

## 🏗️ 统一建筑系统
## 整合传统建筑系统和3D建筑系统，提供统一的接口

# 预加载依赖
const BuildingComponents = preload("res://scripts/characters/buildings/components/BuildingComponents.gd")
const LayeredGridMapSystem = preload("res://scripts/characters/buildings/layered/LayeredGridMapSystem.gd")
const TemplateConverter = preload("res://scripts/characters/buildings/layered/TemplateConverter.gd")

# 引用全局单例
# LogManager 是全局单例，直接使用

# 建筑渲染模式枚举
enum RenderMode {
	GRIDMAP, # 使用GridMap渲染
	PROCEDURAL, # 程序化生成
	EXTERNAL_MODEL, # 外部模型
	TRADITIONAL, # 传统简单渲染
	LAYERED # 分层GridMap渲染
}

# 分层管理相关
var layered_system: LayeredGridMapSystem = null
var use_layered_rendering: bool = false

# 建筑基础属性
var building_id: String = ""
var building_name: String = ""
var building_description: String = ""
var building_type # 使用 BuildingTypes
var tile_x: int = 0
var tile_y: int = 0

# 通用建筑属性
var building_theme: String = "default" # 建筑主题
var building_tier: int = 1 # 建筑等级
var building_category: String = "general" # 建筑分类

# 建筑状态
var status: int = BuildingStatus.PLANNING
var build_progress: float = 0.0
var construction_gold_invested: int = 0

# 建筑属性
var max_health: int = 100
var health: int = 100
var armor: int = 0
var is_active: bool = true

# 建筑尺寸
var building_size: Vector2 = Vector2(1, 1) # 瓦块尺寸 (1x1 或 2x2)
var component_size: Vector3 = Vector3(0.33, 0.33, 0.33) # 组件尺寸
var interaction_range: float = 0.01

# 自由组件系统
var free_components: Array[Dictionary] = [] # 自由组件列表
var component_bounds: AABB = AABB() # 组件边界框
var allow_free_placement: bool = true # 允许自由放置
var free_component_nodes: Array[Node3D] = [] # 自由组件节点

# 建造成本
var cost_gold: int = 0
var engineer_cost: int = 0
var build_time: float = 0.0

# 资源存储属性
var gold_storage_capacity: int = 0
var mana_storage_capacity: int = 0
var stored_gold: int = 0
var stored_mana: int = 0

# 渲染模式
var render_mode: RenderMode = RenderMode.TRADITIONAL

# 3D建筑相关
var mesh_library: MeshLibrary
var gridmap_renderer: GridMap
var building_3d: Node3D

# 交互区域
var interaction_area: Area3D

# 管理器引用
var building_manager = null

func _init():
	"""初始化建筑系统"""
	# 基础初始化，子类可以重写

func _add_component_to_library(component_name: String, component_id: int):
	"""添加构件到MeshLibrary（子类重写）"""
	# 基础实现，子类可以重写
	pass

func _setup_building_effects():
	"""设置建筑特效（子类重写）"""
	# 基础实现，子类可以重写
	pass

func _ready():
	"""初始化建筑系统"""
	LogManager.info("🏗️ [UnifiedBuildingSystem] 初始化建筑: %s" % building_name)
	_setup_interaction_area()
	_setup_visual()
	
func _setup_interaction_area():
	"""设置交互区域"""
	interaction_area = Area3D.new()
	interaction_area.name = "InteractionArea"
	
	# 创建碰撞形状
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(building_size.x, 2.0, building_size.y)
	collision_shape.shape = box_shape
	interaction_area.add_child(collision_shape)
	
	# 🔧 修复：Area3D位置应该是建筑中心，相对于建筑原点
	# 对于2x2建筑：位置应该是(1.0, 1.0, 1.0)，这样Area3D覆盖整个建筑
	interaction_area.position = Vector3(building_size.x * 0.5, 1.0, building_size.y * 0.5)
	
	add_child(interaction_area)
	
	# 设置交互区域属性
	interaction_area.set_meta("building_type", building_type)
	interaction_area.set_meta("building_name", building_name)
	interaction_area.set_meta("building_position", global_position)

func _setup_visual():
	"""设置建筑视觉效果"""
	# 根据渲染模式选择视觉系统
	match render_mode:
		RenderMode.LAYERED:
			_setup_layered_building()
		RenderMode.TRADITIONAL:
			_setup_traditional_visual()
		_:
			# 默认使用传统系统
			render_mode = RenderMode.TRADITIONAL
			_setup_traditional_visual()

func _setup_layered_building():
	"""设置分层建筑系统"""
	LogManager.info("🏗️ [UnifiedBuildingSystem] 设置分层建筑系统: %s" % building_name)
	
	# 创建分层GridMap系统
	layered_system = LayeredGridMapSystem.new()
	layered_system.name = "LayeredGridMapSystem"
	add_child(layered_system)
	
	# 设置分层系统配置
	var building_config = {
		"building_name": building_name,
		"building_type": building_type,
		"layers": {
			"floor": {"enabled": true, "priority": 1},
			"wall": {"enabled": true, "priority": 2},
			"ceiling": {"enabled": true, "priority": 3},
			"decoration": {"enabled": true, "priority": 4}
		}
	}
	layered_system.set_building_config(building_config)
	
	# 生成建筑模板
	var building_template = _generate_layered_building_template()
	
	# 延迟组装建筑，等待LayeredGridMapSystem完全初始化
	call_deferred("_assemble_layered_building", building_template, building_name)
	
	use_layered_rendering = true
	LogManager.info("✅ [UnifiedBuildingSystem] 分层建筑系统设置完成: %s" % building_name)

func _generate_layered_building_template() -> Dictionary:
	"""生成分层建筑模板"""
	# 使用模板转换器将Vector3模板转换为分层模板
	var template = TemplateConverter.convert_building_template(building_type)
	
	LogManager.info("🏗️ [UnifiedBuildingSystem] 生成分层建筑模板: %s" % building_name)
	return template

func _assemble_layered_building(building_template: Dictionary, building_name: String):
	"""延迟组装分层建筑"""
	if layered_system:
		layered_system.assemble_building(building_template, building_name)
		LogManager.info("✅ [UnifiedBuildingSystem] 分层建筑组装完成: %s" % building_name)
	else:
		LogManager.error("❌ [UnifiedBuildingSystem] 分层系统未初始化: %s" % building_name)


func _setup_traditional_visual():
	"""设置传统视觉效果"""
	# 创建简单的立方体作为占位符
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(building_size.x, 2.0, building_size.y)
	mesh_instance.mesh = box_mesh
	
	# 设置材质
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.5, 0.5)
	mesh_instance.material_override = material
	
	add_child(mesh_instance)
	LogManager.info("🏗️ [UnifiedBuildingSystem] 传统视觉系统设置完成: %s" % building_name)

func get_building_info() -> Dictionary:
	"""获取建筑信息"""
	return {
		"id": building_id,
		"name": building_name,
		"type": building_type,
		"position": Vector2(tile_x, tile_y),
		"health": health,
		"max_health": max_health,
		"status": status,
		"render_mode": render_mode,
		"use_layered_rendering": use_layered_rendering,
		"building_size": building_size,
		"building_theme": building_theme,
		"building_tier": building_tier,
		"building_category": building_category
	}

func is_1x1_building() -> bool:
	"""判断是否为1x1瓦块建筑"""
	return building_size == Vector2(1, 1)

func is_2x2_building() -> bool:
	"""判断是否为2x2瓦块建筑"""
	return building_size == Vector2(2, 2)

func get_component_grid_size() -> Vector3:
	"""获取组件网格尺寸"""
	if is_2x2_building():
		return Vector3(6, 3, 6) # 2x2瓦块 = 6x6x3组件
	else:
		return Vector3(3, 3, 3) # 1x1瓦块 = 3x3x3组件

# ========================================
# 自由组件系统方法
# ========================================

func get_building_bounds() -> AABB:
	"""获取建筑边界框"""
	return component_bounds


func debug_coordinate_system():
	"""调试坐标系统"""
	LogManager.info("🔍 [UnifiedBuildingSystem] 坐标系统调试: %s" % building_name)
	LogManager.info("  📍 建筑世界位置: %s" % str(global_position))
	LogManager.info("  📍 建筑本地位置: %s" % str(position))
	LogManager.info("  📏 建筑尺寸: %s" % str(building_size))
	
	if interaction_area:
		LogManager.info("  🎯 Area3D位置: %s" % str(interaction_area.global_position))
		LogManager.info("  🎯 Area3D本地位置: %s" % str(interaction_area.position))
		var collision_shape = interaction_area.get_child(0) as CollisionShape3D
		if collision_shape and collision_shape.shape:
			LogManager.info("  🎯 Area3D尺寸: %s" % str(collision_shape.shape.size))
	
	LogManager.info("  🧩 组件边界框: %s" % str(component_bounds))
	LogManager.info("  🧩 组件数量: %d" % free_components.size())
	
	for i in range(min(3, free_components.size())): # 只显示前3个组件
		var component = free_components[i]
		LogManager.info("    🧩 组件%d: %s 位置=%s 尺寸=%s" % [
			i + 1,
			component["name"],
			str(component["position"]),
			str(component["size"])
		])


func get_detailed_building_info() -> Dictionary:
	"""获取详细建筑信息"""
	return {
		"building_name": building_name,
		"building_type": building_type,
		"world_position": global_position,
		"local_position": position,
		"building_size": building_size,
		"component_count": free_components.size(),
		"component_bounds": component_bounds,
		"interaction_area_position": interaction_area.global_position if interaction_area else Vector3.ZERO,
		"render_mode": render_mode
	}


func normalize_component_coordinates():
	"""标准化组件坐标，确保所有组件都在合理的范围内"""
	for component in free_components:
		var pos = component["position"]
		var size = component["size"]
		
		# 确保位置不为负数
		pos.x = max(0.0, pos.x)
		pos.y = max(0.0, pos.y)
		pos.z = max(0.0, pos.z)
		
		# 确保尺寸为正数
		size.x = max(0.1, size.x)
		size.y = max(0.1, size.y)
		size.z = max(0.1, size.z)
		
		component["position"] = pos
		component["size"] = size
	
	_update_bounds()


func add_component(component_name: String, pos: Vector3, size: Vector3, component_type: String = "decoration"):
	"""添加组件到建筑"""
	var component = {
		"name": component_name,
		"position": pos,
		"size": size,
		"type": component_type
	}
	free_components.append(component)
	_update_bounds()
	
	# 如果建筑已经初始化，立即创建组件节点
	if is_inside_tree():
		_create_component_node(component)


func remove_component(component_name: String):
	"""从建筑中移除组件"""
	for i in range(free_components.size() - 1, -1, -1):
		if free_components[i]["name"] == component_name:
			free_components.remove_at(i)
			# 移除对应的组件节点
			if i < free_component_nodes.size():
				var node = free_component_nodes[i]
				if node and is_instance_valid(node):
					node.queue_free()
				free_component_nodes.remove_at(i)
	_update_bounds()


func _update_bounds():
	"""更新组件边界框"""
	if free_components.is_empty():
		component_bounds = AABB()
		return
	
	var min_pos = Vector3.INF
	var max_pos = Vector3(-INF, -INF, -INF)
	
	for component in free_components:
		var pos = component["position"]
		var size = component["size"]
		var end_pos = pos + size
		
		min_pos = Vector3(min(min_pos.x, pos.x), min(min_pos.y, pos.y), min(min_pos.z, pos.z))
		max_pos = Vector3(max(max_pos.x, end_pos.x), max(max_pos.y, end_pos.y), max(max_pos.z, end_pos.z))
	
	# 确保边界框有最小尺寸
	if min_pos == Vector3.INF:
		min_pos = Vector3.ZERO
	if max_pos == Vector3(-INF, -INF, -INF):
		max_pos = Vector3.ONE
	
	component_bounds = AABB(min_pos, max_pos - min_pos)


func validate_component_placement(component: Dictionary) -> bool:
	"""验证组件放置是否有效"""
	if not allow_free_placement:
		return true # 如果允许自由放置，则不进行边界检查
	
	var bounds = get_building_bounds()
	var component_pos = component["position"]
	var component_sz = component["size"]
	
	# 如果边界框为空，则允许放置
	if bounds.size == Vector3.ZERO:
		return true
	
	# 检查组件是否在建筑边界内
	var component_aabb = AABB(component_pos, component_sz)
	return bounds.encloses(component_aabb)


func generate_free_template() -> Dictionary:
	"""生成自由组件建筑模板"""
	return {
		"building_name": building_name,
		"building_size": building_size,
		"components": free_components,
		"bounds": get_building_bounds(),
		"allow_free_placement": allow_free_placement
	}


func _create_component_node(component: Dictionary):
	"""创建组件节点"""
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = component["size"]
	mesh_instance.mesh = box_mesh
	
	# 设置位置
	mesh_instance.position = component["position"]
	mesh_instance.name = component["name"]
	
	# 设置材质 - 使用更详细的材质系统
	var material = StandardMaterial3D.new()
	_apply_component_material(material, component)
	
	mesh_instance.material_override = material
	add_child(mesh_instance)
	free_component_nodes.append(mesh_instance)


func _apply_component_material(material: StandardMaterial3D, component: Dictionary):
	"""应用组件材质"""
	var component_name = component["name"]
	var component_type = component["type"]
	
	# 根据组件名称和类型设置专用材质
	
	# ===== 地牢之心组件 =====
	if "Heart_Core" in component_name or "Magic_Core" in component_name:
		# 地牢之心核心 - 深红色发光
		material.albedo_color = Color(0.9, 0.1, 0.1, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.9, 0.1, 0.1, 1.0)
		material.emission_energy = 2.5
		material.roughness = 0.2
		material.metallic = 0.8
	elif "Energy_Crystal" in component_name or "Mana_Crystal" in component_name:
		# 能量/魔力水晶 - 红色水晶
		material.albedo_color = Color(0.8, 0.1, 0.1, 0.8)
		material.emission_enabled = true
		material.emission = Color(0.8, 0.1, 0.1, 1.0)
		material.emission_energy = 2.0
		material.roughness = 0.1
		material.metallic = 0.0
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	elif "Energy_Conduit" in component_name or "Energy_Flow" in component_name:
		# 能量导管 - 深红色发光
		material.albedo_color = Color(0.6, 0.1, 0.1, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.8, 0.2, 0.2, 1.0)
		material.emission_energy = 1.5
		material.roughness = 0.3
		material.metallic = 0.6
	elif "Energy_Node" in component_name:
		# 能量节点 - 蓝色发光
		material.albedo_color = Color(0.2, 0.6, 0.9, 0.7)
		material.emission_enabled = true
		material.emission = Color(0.3, 0.7, 0.9, 1.0)
		material.emission_energy = 1.6
		material.roughness = 0.1
		material.metallic = 0.4
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	elif "Storage_Core" in component_name:
		# 存储核心 - 紫色发光
		material.albedo_color = Color(0.6, 0.3, 0.8, 0.8)
		material.emission_enabled = true
		material.emission = Color(0.7, 0.4, 0.9, 1.0)
		material.emission_energy = 1.4
		material.roughness = 0.2
		material.metallic = 0.7
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	elif "Heart_Entrance" in component_name:
		# 地牢之心入口 - 深棕色微弱发光
		material.albedo_color = Color(0.2, 0.1, 0.1, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.3, 0.1, 0.1, 1.0)
		material.emission_energy = 0.3
		material.roughness = 0.7
		material.metallic = 0.0
	elif "Dungeon_Stone" in component_name:
		# 地牢石结构 - 深灰色不发光
		material.albedo_color = Color(0.4, 0.4, 0.4, 1.0)
		material.emission_enabled = false
		material.roughness = 0.8
		material.metallic = 0.0
	
	# ===== 金库组件 =====
	elif "Treasury_Main" in component_name:
		# 金库主体 - 深金色发光
		material.albedo_color = Color(0.8, 0.6, 0.2, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.8, 0.6, 0.2, 1.0)
		material.emission_energy = 1.8
		material.roughness = 0.3
		material.metallic = 0.8
	elif "Treasury_Roof" in component_name:
		# 金库屋顶 - 金色发光
		material.albedo_color = Color(0.9, 0.7, 0.3, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.9, 0.7, 0.3, 1.0)
		material.emission_energy = 1.5
		material.roughness = 0.4
		material.metallic = 0.7
	elif "Gold_Vault" in component_name or "Gold_Pile" in component_name:
		# 金币保险箱/金币堆 - 亮金色发光
		material.albedo_color = Color(1.0, 0.8, 0.2, 1.0)
		material.emission_enabled = true
		material.emission = Color(1.0, 0.8, 0.2, 1.0)
		material.emission_energy = 2.0
		material.roughness = 0.2
		material.metallic = 0.9
	elif "Security_Lock" in component_name or "Security_Crystal" in component_name:
		# 安全锁/安全水晶 - 金属色发光
		material.albedo_color = Color(0.6, 0.6, 0.7, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.6, 0.6, 0.7, 1.0)
		material.emission_energy = 0.8
		material.roughness = 0.2
		material.metallic = 0.8
	elif "Gold_Ornament" in component_name:
		# 金饰 - 亮金色发光
		material.albedo_color = Color(1.0, 0.9, 0.3, 1.0)
		material.emission_enabled = true
		material.emission = Color(1.0, 0.9, 0.3, 1.0)
		material.emission_energy = 1.4
		material.roughness = 0.1
		material.metallic = 0.9
	
	# ===== 奥术塔组件 =====
	elif "Tower_Base" in component_name:
		# 塔基 - 深紫色发光
		material.albedo_color = Color(0.4, 0.2, 0.6, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.4, 0.2, 0.6, 1.0)
		material.emission_energy = 1.2
		material.roughness = 0.4
		material.metallic = 0.6
	elif "Tower_Body" in component_name:
		# 塔身 - 紫色发光
		material.albedo_color = Color(0.6, 0.3, 0.8, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.6, 0.3, 0.8, 1.0)
		material.emission_energy = 1.5
		material.roughness = 0.3
		material.metallic = 0.7
	elif "Tower_Top" in component_name:
		# 塔顶 - 亮紫色发光
		material.albedo_color = Color(0.8, 0.4, 1.0, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.8, 0.4, 1.0, 1.0)
		material.emission_energy = 1.8
		material.roughness = 0.2
		material.metallic = 0.8
	elif "Magic_Crystal" in component_name:
		# 魔法水晶 - 紫色水晶发光
		material.albedo_color = Color(0.7, 0.3, 0.9, 0.8)
		material.emission_enabled = true
		material.emission = Color(0.7, 0.3, 0.9, 1.0)
		material.emission_energy = 2.0
		material.roughness = 0.1
		material.metallic = 0.0
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	elif "Arcane_Orb" in component_name:
		# 奥术球 - 亮紫色发光
		material.albedo_color = Color(0.9, 0.5, 1.0, 0.9)
		material.emission_enabled = true
		material.emission = Color(0.9, 0.5, 1.0, 1.0)
		material.emission_energy = 2.2
		material.roughness = 0.1
		material.metallic = 0.0
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	elif "Rune_Stone" in component_name:
		# 符文石 - 深紫色发光
		material.albedo_color = Color(0.5, 0.2, 0.7, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.5, 0.2, 0.7, 1.0)
		material.emission_energy = 1.0
		material.roughness = 0.5
		material.metallic = 0.3
	
	# ===== 兵营组件 =====
	elif "Barracks_Main" in component_name or "Barracks_Roof" in component_name:
		# 兵营主体/屋顶 - 深棕色不发光
		material.albedo_color = Color(0.4, 0.3, 0.2, 1.0)
		material.emission_enabled = false
		material.roughness = 0.8
		material.metallic = 0.0
	elif "Training_Ground" in component_name:
		# 训练场 - 土色不发光
		material.albedo_color = Color(0.6, 0.5, 0.4, 1.0)
		material.emission_enabled = false
		material.roughness = 0.9
		material.metallic = 0.0
	elif "Weapon_Rack" in component_name or "Armor_Stand" in component_name:
		# 武器架/盔甲架 - 金属色发光
		material.albedo_color = Color(0.6, 0.6, 0.7, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.6, 0.6, 0.7, 1.0)
		material.emission_energy = 0.5
		material.roughness = 0.3
		material.metallic = 0.8
	elif "Military_Flag" in component_name:
		# 军旗 - 红色发光
		material.albedo_color = Color(0.8, 0.2, 0.2, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.8, 0.2, 0.2, 1.0)
		material.emission_energy = 0.8
		material.roughness = 0.6
		material.metallic = 0.0
	elif "Campfire" in component_name:
		# 营火 - 橙色发光
		material.albedo_color = Color(1.0, 0.5, 0.2, 1.0)
		material.emission_enabled = true
		material.emission = Color(1.0, 0.5, 0.2, 1.0)
		material.emission_energy = 2.0
		material.roughness = 0.4
		material.metallic = 0.0
	
	# ===== 工坊组件 =====
	elif "Workshop_Main" in component_name or "Workshop_Roof" in component_name:
		# 工坊主体/屋顶 - 深灰色不发光
		material.albedo_color = Color(0.4, 0.4, 0.4, 1.0)
		material.emission_enabled = false
		material.roughness = 0.8
		material.metallic = 0.0
	elif "Forge_Main" in component_name:
		# 熔炉主体 - 深红色发光
		material.albedo_color = Color(0.6, 0.2, 0.2, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.6, 0.2, 0.2, 1.0)
		material.emission_energy = 1.5
		material.roughness = 0.3
		material.metallic = 0.7
	elif "Forge_Flame" in component_name:
		# 熔炉火焰 - 亮红色发光
		material.albedo_color = Color(1.0, 0.3, 0.1, 1.0)
		material.emission_enabled = true
		material.emission = Color(1.0, 0.3, 0.1, 1.0)
		material.emission_energy = 2.5
		material.roughness = 0.2
		material.metallic = 0.0
	elif "Workbench_Main" in component_name:
		# 工作台 - 棕色不发光
		material.albedo_color = Color(0.6, 0.4, 0.3, 1.0)
		material.emission_enabled = false
		material.roughness = 0.7
		material.metallic = 0.0
	elif "Tool_Shelf" in component_name or "Anvil" in component_name:
		# 工具架/铁砧 - 金属色发光
		material.albedo_color = Color(0.6, 0.6, 0.7, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.6, 0.6, 0.7, 1.0)
		material.emission_energy = 0.3
		material.roughness = 0.2
		material.metallic = 0.9
	
	# ===== 魔法祭坛组件 =====
	elif "Altar_Base" in component_name or "Altar_Top" in component_name or "Altar_Pillar" in component_name:
		# 祭坛结构 - 紫色发光
		material.albedo_color = Color(0.4, 0.2, 0.6, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.4, 0.2, 0.6, 1.0)
		material.emission_energy = 1.2
		material.roughness = 0.4
		material.metallic = 0.6
	elif "Rune_Circle" in component_name:
		# 符文圈 - 亮紫色发光
		material.albedo_color = Color(0.8, 0.4, 1.0, 0.7)
		material.emission_enabled = true
		material.emission = Color(0.8, 0.4, 1.0, 1.0)
		material.emission_energy = 1.6
		material.roughness = 0.1
		material.metallic = 0.0
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	elif "Ritual_Candle" in component_name:
		# 仪式蜡烛 - 橙色发光
		material.albedo_color = Color(0.9, 0.6, 0.2, 1.0)
		material.emission_enabled = true
		material.emission = Color(1.0, 0.7, 0.3, 1.0)
		material.emission_energy = 1.0
		material.roughness = 0.3
		material.metallic = 0.0
	elif "Magic_Aura" in component_name:
		# 魔法光环 - 紫色发光
		material.albedo_color = Color(0.5, 0.2, 0.7, 0.5)
		material.emission_enabled = true
		material.emission = Color(0.6, 0.3, 0.8, 1.0)
		material.emission_energy = 1.0
		material.roughness = 0.1
		material.metallic = 0.0
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	# ===== 暗影神殿组件 =====
	elif "Shadow_Altar" in component_name:
		# 暗影祭坛 - 深黑色发光
		material.albedo_color = Color(0.1, 0.1, 0.1, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.1, 0.1, 0.1, 1.0)
		material.emission_energy = 1.0
		material.roughness = 0.8
		material.metallic = 0.0
	elif "Shadow_Core" in component_name or "Dark_Crystal" in component_name:
		# 暗影核心/暗影水晶 - 深紫色发光
		material.albedo_color = Color(0.3, 0.1, 0.4, 0.8)
		material.emission_enabled = true
		material.emission = Color(0.3, 0.1, 0.4, 1.0)
		material.emission_energy = 2.0
		material.roughness = 0.1
		material.metallic = 0.0
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	elif "Shadow_Flame" in component_name:
		# 暗影火焰 - 深紫色发光
		material.albedo_color = Color(0.5, 0.1, 0.6, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.5, 0.1, 0.6, 1.0)
		material.emission_energy = 2.2
		material.roughness = 0.2
		material.metallic = 0.0
	elif "Dark_Ritual" in component_name or "Shadow_Rune" in component_name:
		# 黑暗仪式/暗影符文 - 深黑色发光
		material.albedo_color = Color(0.05, 0.05, 0.05, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.05, 0.05, 0.05, 1.0)
		material.emission_energy = 0.8
		material.roughness = 0.9
		material.metallic = 0.0
	
	# ===== 医院组件 =====
	elif "Hospital_Main" in component_name or "Hospital_Roof" in component_name:
		# 医院主体/屋顶 - 白色/浅蓝色不发光
		if "Roof" in component_name:
			material.albedo_color = Color(0.7, 0.8, 0.9, 1.0)
	else:
			material.albedo_color = Color(0.9, 0.9, 0.9, 1.0)
		material.emission_enabled = false
		material.roughness = 0.8
		material.metallic = 0.0
	elif "Nursing_Station" in component_name:
		# 护士站 - 浅绿色发光
		material.albedo_color = Color(0.8, 0.9, 0.8, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.8, 0.9, 0.8, 1.0)
		material.emission_energy = 0.8
		material.roughness = 0.6
		material.metallic = 0.0
	elif "Hospital_Bed" in component_name:
		# 病床 - 白色不发光
		material.albedo_color = Color(0.95, 0.95, 0.95, 1.0)
		material.emission_enabled = false
		material.roughness = 0.7
		material.metallic = 0.0
	elif "Medical_Equipment" in component_name or "Surgical_Table" in component_name:
		# 医疗设备/手术台 - 金属色发光
		material.albedo_color = Color(0.8, 0.8, 0.9, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.8, 0.8, 0.9, 1.0)
		material.emission_energy = 0.6
		material.roughness = 0.2
		material.metallic = 0.8
	elif "Healing_Crystal" in component_name:
		# 治愈水晶 - 绿色发光
		material.albedo_color = Color(0.3, 0.8, 0.3, 0.7)
		material.emission_enabled = true
		material.emission = Color(0.3, 0.8, 0.3, 1.0)
		material.emission_energy = 1.8
		material.roughness = 0.1
		material.metallic = 0.0
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	# ===== 市场组件 =====
	elif "Market_Main" in component_name or "Market_Roof" in component_name:
		# 市场主体/屋顶 - 棕色不发光
		material.albedo_color = Color(0.6, 0.4, 0.3, 1.0)
		material.emission_enabled = false
		material.roughness = 0.8
		material.metallic = 0.0
	elif "Trading_Desk" in component_name or "Vendor_Stall" in component_name:
		# 交易台/商贩摊位 - 棕色发光
		material.albedo_color = Color(0.7, 0.5, 0.4, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.7, 0.5, 0.4, 1.0)
		material.emission_energy = 0.8
		material.roughness = 0.7
		material.metallic = 0.1
	elif "Display_Counter" in component_name or "Goods_Storage" in component_name:
		# 展示柜台/货物存储 - 棕色发光
		material.albedo_color = Color(0.6, 0.4, 0.3, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.6, 0.4, 0.3, 1.0)
		material.emission_energy = 0.6
		material.roughness = 0.6
		material.metallic = 0.2
	elif "Merchant_Cart" in component_name:
		# 商贩推车 - 棕色发光
		material.albedo_color = Color(0.5, 0.3, 0.2, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.5, 0.3, 0.2, 1.0)
		material.emission_energy = 0.4
		material.roughness = 0.8
		material.metallic = 0.0
	elif "Coin_Counter" in component_name or "Coin_Stack" in component_name:
		# 金币计数器/金币堆 - 金色发光
		material.albedo_color = Color(1.0, 0.8, 0.2, 1.0)
		material.emission_enabled = true
		material.emission = Color(1.0, 0.8, 0.2, 1.0)
		material.emission_energy = 1.2
		material.roughness = 0.3
		material.metallic = 0.8
	elif "Market_Banner" in component_name:
		# 市场横幅 - 彩色发光
		material.albedo_color = Color(0.8, 0.6, 0.4, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.8, 0.6, 0.4, 1.0)
		material.emission_energy = 0.6
		material.roughness = 0.5
		material.metallic = 0.0
	
	# ===== 图书馆组件 =====
	elif "Library_Main" in component_name or "Library_Roof" in component_name:
		# 图书馆主体/屋顶 - 棕色不发光
		material.albedo_color = Color(0.6, 0.4, 0.3, 1.0)
		material.emission_enabled = false
		material.roughness = 0.8
		material.metallic = 0.0
	elif "Reading_Desk" in component_name or "Research_Table" in component_name:
		# 阅读桌/研究桌 - 棕色发光
		material.albedo_color = Color(0.7, 0.5, 0.4, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.7, 0.5, 0.4, 1.0)
		material.emission_energy = 0.8
		material.roughness = 0.6
		material.metallic = 0.1
	elif "Bookshelf" in component_name or "Scroll_Rack" in component_name:
		# 书架/卷轴架 - 棕色发光
		material.albedo_color = Color(0.5, 0.3, 0.2, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.5, 0.3, 0.2, 1.0)
		material.emission_energy = 0.6
		material.roughness = 0.7
		material.metallic = 0.0
	elif "Knowledge_Orb" in component_name or "Wisdom_Crystal" in component_name:
		# 知识球/智慧水晶 - 蓝色发光
		material.albedo_color = Color(0.3, 0.7, 1.0, 0.7)
		material.emission_enabled = true
		material.emission = Color(0.3, 0.7, 1.0, 1.0)
		material.emission_energy = 1.8
		material.roughness = 0.1
		material.metallic = 0.0
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	elif "Study_Lamp" in component_name:
		# 学习灯 - 黄色发光
		material.albedo_color = Color(1.0, 0.9, 0.6, 1.0)
		material.emission_enabled = true
		material.emission = Color(1.0, 0.9, 0.6, 1.0)
		material.emission_energy = 1.0
		material.roughness = 0.3
		material.metallic = 0.0
	
	# ===== 学院组件 =====
	elif "Academy_Main" in component_name or "Academy_Tower" in component_name:
		# 学院主体/塔 - 白色发光
		material.albedo_color = Color(0.95, 0.95, 0.95, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.9, 0.95, 1.0, 1.0)
		material.emission_energy = 0.8
		material.roughness = 0.6
		material.metallic = 0.0
	elif "Academy_Entrance" in component_name:
		# 学院入口 - 白色发光
		material.albedo_color = Color(0.9, 0.9, 0.9, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.9, 0.9, 0.9, 1.0)
		material.emission_energy = 0.6
		material.roughness = 0.7
		material.metallic = 0.0
	elif "Classroom_Desk" in component_name or "Teacher_Podium" in component_name:
		# 教室桌/教师讲台 - 棕色发光
		material.albedo_color = Color(0.7, 0.5, 0.4, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.7, 0.5, 0.4, 1.0)
		material.emission_energy = 0.6
		material.roughness = 0.6
		material.metallic = 0.1
	elif "Research_Lab" in component_name or "Academic_Library" in component_name:
		# 研究实验室/学术图书馆 - 白色发光
		material.albedo_color = Color(0.9, 0.9, 0.95, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.9, 0.9, 0.95, 1.0)
		material.emission_energy = 0.8
		material.roughness = 0.5
		material.metallic = 0.0
	elif "Scholar_Statue" in component_name:
		# 学者雕像 - 白色发光
		material.albedo_color = Color(0.95, 0.95, 0.95, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.95, 0.95, 0.95, 1.0)
		material.emission_energy = 0.4
		material.roughness = 0.8
		material.metallic = 0.0
	elif "Academic_Banner" in component_name:
		# 学术横幅 - 蓝色发光
		material.albedo_color = Color(0.6, 0.7, 0.9, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.6, 0.7, 0.9, 1.0)
		material.emission_energy = 0.6
		material.roughness = 0.5
		material.metallic = 0.0
	elif "Wisdom_Tower" in component_name:
		# 智慧塔 - 蓝色发光
		material.albedo_color = Color(0.4, 0.6, 0.8, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.4, 0.6, 0.8, 1.0)
		material.emission_energy = 1.2
		material.roughness = 0.3
		material.metallic = 0.0
	
	# ===== 工厂组件 =====
	elif "Factory_Main" in component_name:
		# 工厂主体 - 深灰色不发光
		material.albedo_color = Color(0.3, 0.3, 0.3, 1.0)
		material.emission_enabled = false
		material.roughness = 0.8
		material.metallic = 0.0
	elif "Smokestack" in component_name:
		# 烟囱 - 深灰色发光
		material.albedo_color = Color(0.4, 0.4, 0.4, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.4, 0.4, 0.4, 1.0)
		material.emission_energy = 0.8
		material.roughness = 0.7
		material.metallic = 0.0
	elif "Assembly_Line" in component_name or "Conveyor_Belt" in component_name:
		# 装配线/传送带 - 金属色发光
		material.albedo_color = Color(0.7, 0.7, 0.8, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.7, 0.7, 0.8, 1.0)
		material.emission_energy = 0.6
		material.roughness = 0.3
		material.metallic = 0.8
	elif "Storage_Crate" in component_name:
		# 存储箱 - 棕色发光
		material.albedo_color = Color(0.6, 0.4, 0.3, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.6, 0.4, 0.3, 1.0)
		material.emission_energy = 0.4
		material.roughness = 0.7
		material.metallic = 0.0
	elif "Ventilation" in component_name:
		# 通风设备 - 金属色发光
		material.albedo_color = Color(0.6, 0.6, 0.7, 1.0)
		material.emission_enabled = true
		material.emission = Color(0.6, 0.6, 0.7, 1.0)
		material.emission_energy = 0.5
		material.roughness = 0.4
		material.metallic = 0.7
	
	else:
		# 默认材质
		match component_type:
			"door":
				material.albedo_color = Color.BROWN
				material.roughness = 0.7
				material.metallic = 0.0
			"decoration":
				material.albedo_color = Color.GOLD
				material.emission_enabled = true
				material.emission = Color.GOLD
				material.emission_energy = 0.5
			"structure":
				material.albedo_color = Color.GRAY
				material.roughness = 0.8
				material.metallic = 0.0
			"floor":
				material.albedo_color = Color.DARK_GRAY
				material.roughness = 0.9
				material.metallic = 0.0
			_:
				material.albedo_color = Color.WHITE
				material.roughness = 0.5
				material.metallic = 0.0


func setup_free_components():
	"""设置自由组件系统"""
	LogManager.info("🏗️ [UnifiedBuildingSystem] 设置自由组件系统: %s" % building_name)
	
	# 标准化组件坐标
	normalize_component_coordinates()
	
	# 清理现有组件节点
	for node in free_component_nodes:
		if node and is_instance_valid(node):
			node.queue_free()
	free_component_nodes.clear()
	
	# 创建所有组件节点
	for component in free_components:
		_create_component_node(component)
	
	LogManager.info("✅ [UnifiedBuildingSystem] 自由组件系统设置完成: %s (组件数量: %d)" % [building_name, free_components.size()])


func switch_to_free_component_system():
	"""切换到自由组件系统"""
	render_mode = RenderMode.TRADITIONAL # 使用传统渲染模式但支持自由组件
	allow_free_placement = true
	setup_free_components()
	LogManager.info("🔄 [UnifiedBuildingSystem] 切换到自由组件系统: %s" % building_name)
