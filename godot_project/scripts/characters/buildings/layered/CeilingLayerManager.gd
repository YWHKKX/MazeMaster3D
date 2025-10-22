extends Node
class_name CeilingLayerManager

## 🏗️ 天花板层管理器
## 专门处理天花板和顶部覆盖

signal ceiling_updated(cell_count: int)

var gridmap: GridMap
var ceiling_config: Dictionary = {}
var ceiling_components: Dictionary = {}

# 天花板组件类型
enum CeilingType {
	STONE_CEILING, # 石质天花板
	WOOD_CEILING, # 木质天花板
	METAL_CEILING, # 金属天花板
	MAGIC_CEILING, # 魔法天花板
	GLASS_CEILING, # 玻璃天花板
	MARBLE_CEILING, # 大理石天花板
	DECORATIVE_CEILING, # 装饰天花板
	SKY_CEILING # 天空天花板
}

func _ready():
	"""初始化天花板层管理器"""
	_setup_ceiling_components()
	LogManager.info("🏗️ [CeilingLayerManager] 天花板层管理器初始化完成")


func set_gridmap(gridmap_node: GridMap):
	"""设置GridMap引用"""
	gridmap = gridmap_node
	_setup_mesh_library()

func _setup_mesh_library():
	"""设置MeshLibrary"""
	if not gridmap:
		return
	
	var mesh_library = MeshLibrary.new()
	
	# 为每种天花板类型创建网格
	for ceiling_type in ceiling_components:
		var component = ceiling_components[ceiling_type]
		var mesh = _create_ceiling_mesh(component)
		if mesh:
			mesh_library.create_item(component.id)
			mesh_library.set_item_mesh(component.id, mesh)
	
	gridmap.mesh_library = mesh_library
	LogManager.info("🔧 [CeilingLayerManager] MeshLibrary已设置，包含 %d 个网格" % mesh_library.get_item_list().size())

func _create_ceiling_mesh(component: Dictionary) -> Mesh:
	"""创建天花板网格"""
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.33, 0.05, 0.33) # 天花板较薄
	
	# 创建材质
	var material = StandardMaterial3D.new()
	material.albedo_color = component.get("color", Color.WHITE)
	material.roughness = component.get("roughness", 0.8)
	material.metallic = component.get("metallic", 0.1)
	
	# 如果有发光属性
	if component.has("emission"):
		material.emission_enabled = true
		material.emission = component.emission
		material.emission_energy = component.get("emission_energy", 1.0)
	
	box_mesh.surface_set_material(0, material)
	return box_mesh


func _setup_ceiling_components():
	"""设置天花板组件"""
	ceiling_components = {
		CeilingType.STONE_CEILING: {
			"id": 20,
			"name": "石质天花板",
			"material": "stone",
			"texture": "stone_ceiling",
			"color": Color(0.15, 0.15, 0.15), # 深黑色石质天花板
			"roughness": 0.9,
			"metallic": 0.2,
			"thickness": 0.1
		},
		CeilingType.WOOD_CEILING: {
			"id": 21,
			"name": "木质天花板",
			"material": "wood",
			"texture": "wood_ceiling",
			"color": Color(0.2, 0.1, 0.1), # 深红色木质天花板
			"roughness": 0.8,
			"metallic": 0.0,
			"thickness": 0.1
		},
		CeilingType.METAL_CEILING: {
			"id": 22,
			"name": "金属天花板",
			"material": "metal",
			"texture": "metal_ceiling",
			"color": Color(0.1, 0.1, 0.1), # 深黑色金属天花板
			"roughness": 0.3,
			"metallic": 0.9,
			"thickness": 0.1
		},
		CeilingType.MAGIC_CEILING: {
			"id": 23,
			"name": "魔法天花板",
			"material": "magic",
			"texture": "magic_ceiling",
			"color": Color(0.3, 0.1, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.2, 0.1, 0.6),
			"emission_energy": 0.5,
			"thickness": 0.1
		},
		CeilingType.GLASS_CEILING: {
			"id": 24,
			"name": "玻璃天花板",
			"material": "glass",
			"texture": "glass_ceiling",
			"color": Color(0.8, 0.9, 1.0),
			"roughness": 0.0,
			"metallic": 0.0,
			"transparency": 0.3,
			"thickness": 0.1
		},
		CeilingType.MARBLE_CEILING: {
			"id": 25,
			"name": "大理石天花板",
			"material": "marble",
			"texture": "marble_ceiling",
			"color": Color(0.9, 0.9, 0.95),
			"roughness": 0.1,
			"metallic": 0.0,
			"thickness": 0.1
		},
		CeilingType.DECORATIVE_CEILING: {
			"id": 26,
			"name": "装饰天花板",
			"material": "decorative",
			"texture": "decorative_ceiling",
			"color": Color(0.8, 0.6, 0.4),
			"roughness": 0.7,
			"metallic": 0.2,
			"thickness": 0.1
		},
		CeilingType.SKY_CEILING: {
			"id": 27,
			"name": "天空天花板",
			"material": "sky",
			"texture": "sky_ceiling",
			"color": Color(0.5, 0.8, 1.0),
			"roughness": 0.0,
			"metallic": 0.0,
			"transparency": 0.8,
			"thickness": 0.1
		}
	}


func assemble_layer(ceiling_data: Dictionary):
	"""组装天花板层"""
	if not gridmap:
		LogManager.error("❌ [CeilingLayerManager] GridMap未设置")
		return
	
	LogManager.info("🏗️ [CeilingLayerManager] 开始组装天花板层，数据量: %d" % ceiling_data.size())
	
	var cell_count = 0
	for pos_str in ceiling_data:
		var pos = _parse_position(pos_str)
		var ceiling_type = ceiling_data[pos_str]
		
		if ceiling_type in ceiling_components:
			var component = ceiling_components[ceiling_type]
			gridmap.set_cell_item(Vector3i(pos.x, pos.y, pos.z), component.id)
			cell_count += 1
		else:
			LogManager.warning("⚠️ [CeilingLayerManager] 未知天花板类型: %s" % str(ceiling_type))
	
	ceiling_updated.emit(cell_count)
	LogManager.info("✅ [CeilingLayerManager] 天花板层组装完成，放置了 %d 个天花板组件" % cell_count)


func place_ceiling_component(position: Vector3i, ceiling_type: CeilingType):
	"""放置天花板组件"""
	if not gridmap:
		LogManager.error("❌ [CeilingLayerManager] GridMap未设置")
		return false
	
	if ceiling_type in ceiling_components:
		var component = ceiling_components[ceiling_type]
		gridmap.set_cell_item(position, component.id)
		LogManager.info("🏗️ [CeilingLayerManager] 放置天花板组件: %s 在位置 %s" % [component.name, str(position)])
		return true
	else:
		LogManager.warning("⚠️ [CeilingLayerManager] 未知天花板类型: %s" % str(ceiling_type))
		return false


func remove_ceiling_component(position: Vector3i):
	"""移除天花板组件"""
	if not gridmap:
		LogManager.error("❌ [CeilingLayerManager] GridMap未设置")
		return false
	
	gridmap.set_cell_item(position, -1)
	LogManager.info("🗑️ [CeilingLayerManager] 移除位置 %s 的天花板组件" % str(position))
	return true


func get_ceiling_component_info(position: Vector3i) -> Dictionary:
	"""获取天花板组件信息"""
	if not gridmap:
		return {}
	
	var item_id = gridmap.get_cell_item(position)
	if item_id == -1:
		return {}
	
	# 查找对应的组件信息
	for ceiling_type in ceiling_components:
		if ceiling_components[ceiling_type].id == item_id:
			return ceiling_components[ceiling_type]
	
	return {}


func set_config(config: Dictionary):
	"""设置天花板层配置"""
	ceiling_config = config
	LogManager.info("⚙️ [CeilingLayerManager] 天花板层配置已更新")


func get_layer_info() -> Dictionary:
	"""获取天花板层信息"""
	if not gridmap:
		return {"cell_count": 0, "components": []}
	
	var used_cells = gridmap.get_used_cells()
	var components = []
	
	for cell in used_cells:
		var item_id = gridmap.get_cell_item(cell)
		var component_info = get_ceiling_component_info(cell)
		if not component_info.is_empty():
			components.append({
				"position": cell,
				"component": component_info
			})
	
	return {
		"cell_count": used_cells.size(),
		"components": components
	}


func _parse_position(pos_str: String) -> Vector3:
	"""解析位置字符串"""
	var parts = pos_str.split(",")
	if parts.size() == 3:
		return Vector3(float(parts[0]), float(parts[1]), float(parts[2]))
	return Vector3.ZERO
