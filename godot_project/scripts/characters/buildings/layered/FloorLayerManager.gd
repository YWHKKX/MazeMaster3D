extends Node
class_name FloorLayerManager

## 🏗️ 地面层管理器
## 专门处理地板和基础结构

signal floor_updated(cell_count: int)

var gridmap: GridMap
var floor_config: Dictionary = {}
var floor_components: Dictionary = {}

# 地面组件类型
enum FloorType {
	STONE_FLOOR, # 石质地板
	WOOD_FLOOR, # 木质地板
	METAL_FLOOR, # 金属地板
	TRAP_FLOOR, # 陷阱地板
	MAGIC_FLOOR, # 魔法地板
	MARBLE_FLOOR, # 大理石地板
	CARPET_FLOOR, # 地毯地板
	GRASS_FLOOR # 草地地板
}

func _ready():
	"""初始化地面层管理器"""
	_setup_floor_components()
	LogManager.info("🏗️ [FloorLayerManager] 地面层管理器初始化完成")


func set_gridmap(gridmap_node: GridMap):
	"""设置GridMap引用"""
	gridmap = gridmap_node
	_setup_mesh_library()

func _setup_mesh_library():
	"""设置MeshLibrary"""
	if not gridmap:
		return
	
	var mesh_library = MeshLibrary.new()
	
	# 为每种地面类型创建网格
	for floor_type in floor_components:
		var component = floor_components[floor_type]
		var mesh = _create_floor_mesh(component)
		if mesh:
			mesh_library.create_item(component.id)
			mesh_library.set_item_mesh(component.id, mesh)
	
	gridmap.mesh_library = mesh_library
	LogManager.info("🔧 [FloorLayerManager] MeshLibrary已设置，包含 %d 个网格" % mesh_library.get_item_list().size())

func _create_floor_mesh(component: Dictionary) -> Mesh:
	"""创建地面网格"""
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.33, 0.05, 0.33) # 地面较薄
	
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


func _setup_floor_components():
	"""设置地面组件"""
	floor_components = {
		FloorType.STONE_FLOOR: {
			"id": 1,
			"name": "石质地板",
			"material": "stone",
			"texture": "stone_floor",
			"color": Color(0.15, 0.15, 0.15), # 深黑色石质地板
			"roughness": 0.9,
			"metallic": 0.2
		},
		FloorType.WOOD_FLOOR: {
			"id": 2,
			"name": "木质地板",
			"material": "wood",
			"texture": "wood_floor",
			"color": Color(0.2, 0.1, 0.1), # 深红色木质地板
			"roughness": 0.8,
			"metallic": 0.0
		},
		FloorType.METAL_FLOOR: {
			"id": 3,
			"name": "金属地板",
			"material": "metal",
			"texture": "metal_floor",
			"color": Color(0.1, 0.1, 0.1), # 深黑色金属地板
			"roughness": 0.3,
			"metallic": 0.95
		},
		FloorType.TRAP_FLOOR: {
			"id": 4,
			"name": "陷阱地板",
			"material": "stone",
			"texture": "trap_floor",
			"color": Color(0.4, 0.2, 0.2),
			"roughness": 0.9,
			"metallic": 0.0
		},
		FloorType.MAGIC_FLOOR: {
			"id": 5,
			"name": "魔法地板",
			"material": "magic",
			"texture": "magic_floor",
			"color": Color(0.3, 0.1, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.2, 0.1, 0.6),
			"emission_energy": 0.5
		},
		FloorType.MARBLE_FLOOR: {
			"id": 6,
			"name": "大理石地板",
			"material": "stone",
			"texture": "marble_floor",
			"color": Color(0.9, 0.9, 0.95),
			"roughness": 0.1,
			"metallic": 0.0
		},
		FloorType.CARPET_FLOOR: {
			"id": 7,
			"name": "地毯地板",
			"material": "fabric",
			"texture": "carpet_floor",
			"color": Color(0.8, 0.2, 0.2),
			"roughness": 0.9,
			"metallic": 0.0
		},
		FloorType.GRASS_FLOOR: {
			"id": 8,
			"name": "草地地板",
			"material": "nature",
			"texture": "grass_floor",
			"color": Color(0.2, 0.6, 0.2),
			"roughness": 0.8,
			"metallic": 0.0
		}
	}


func assemble_layer(floor_data: Dictionary):
	"""组装地面层"""
	if not gridmap:
		LogManager.error("❌ [FloorLayerManager] GridMap未设置")
		return
	
	LogManager.info("🏗️ [FloorLayerManager] 开始组装地面层，数据量: %d" % floor_data.size())
	
	var cell_count = 0
	for pos_str in floor_data:
		var pos = _parse_position(pos_str)
		var floor_type = floor_data[pos_str]
		
		if floor_type in floor_components:
			var component = floor_components[floor_type]
			gridmap.set_cell_item(Vector3i(pos.x, pos.y, pos.z), component.id)
			cell_count += 1
		else:
			LogManager.warning("⚠️ [FloorLayerManager] 未知地面类型: %s" % str(floor_type))
	
	floor_updated.emit(cell_count)
	LogManager.info("✅ [FloorLayerManager] 地面层组装完成，放置了 %d 个地面组件" % cell_count)


func place_floor_component(position: Vector3i, floor_type: FloorType):
	"""放置地面组件"""
	if not gridmap:
		LogManager.error("❌ [FloorLayerManager] GridMap未设置")
		return false
	
	if floor_type in floor_components:
		var component = floor_components[floor_type]
		gridmap.set_cell_item(position, component.id)
		LogManager.info("🏗️ [FloorLayerManager] 放置地面组件: %s 在位置 %s" % [component.name, str(position)])
		return true
	else:
		LogManager.warning("⚠️ [FloorLayerManager] 未知地面类型: %s" % str(floor_type))
		return false


func remove_floor_component(position: Vector3i):
	"""移除地面组件"""
	if not gridmap:
		LogManager.error("❌ [FloorLayerManager] GridMap未设置")
		return false
	
	gridmap.set_cell_item(position, -1)
	LogManager.info("🗑️ [FloorLayerManager] 移除位置 %s 的地面组件" % str(position))
	return true


func get_floor_component_info(position: Vector3i) -> Dictionary:
	"""获取地面组件信息"""
	if not gridmap:
		return {}
	
	var item_id = gridmap.get_cell_item(position)
	if item_id == -1:
		return {}
	
	# 查找对应的组件信息
	for floor_type in floor_components:
		if floor_components[floor_type].id == item_id:
			return floor_components[floor_type]
	
	return {}


func set_config(config: Dictionary):
	"""设置地面层配置"""
	floor_config = config
	LogManager.info("⚙️ [FloorLayerManager] 地面层配置已更新")


func get_layer_info() -> Dictionary:
	"""获取地面层信息"""
	if not gridmap:
		return {"cell_count": 0, "components": []}
	
	var used_cells = gridmap.get_used_cells()
	var components = []
	
	for cell in used_cells:
		var item_id = gridmap.get_cell_item(cell)
		var component_info = get_floor_component_info(cell)
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
