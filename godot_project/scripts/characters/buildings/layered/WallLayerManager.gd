extends Node
class_name WallLayerManager

## 🏗️ 墙壁层管理器
## 专门处理垂直墙面和隔断

signal wall_updated(cell_count: int)

var gridmap: GridMap
var wall_config: Dictionary = {}
var wall_components: Dictionary = {}

# 墙壁组件类型
enum WallType {
	STONE_WALL, # 石质墙壁
	WOOD_WALL, # 木质墙壁
	METAL_WALL, # 金属墙壁
	MAGIC_WALL, # 魔法墙壁
	GLASS_WALL, # 玻璃墙壁
	BRICK_WALL, # 砖墙
	MARBLE_WALL, # 大理石墙
	DECORATIVE_WALL # 装饰墙
}

func _ready():
	"""初始化墙壁层管理器"""
	_setup_wall_components()
	LogManager.info("🏗️ [WallLayerManager] 墙壁层管理器初始化完成")


func set_gridmap(gridmap_node: GridMap):
	"""设置GridMap引用"""
	gridmap = gridmap_node
	_setup_mesh_library()

func _setup_mesh_library():
	"""设置MeshLibrary"""
	if not gridmap:
		return
	
	var mesh_library = MeshLibrary.new()
	
	# 为每种墙壁类型创建网格
	for wall_type in wall_components:
		var component = wall_components[wall_type]
		var mesh = _create_wall_mesh(component)
		if mesh:
			mesh_library.create_item(component.id)
			mesh_library.set_item_mesh(component.id, mesh)
	
	gridmap.mesh_library = mesh_library
	LogManager.info("🔧 [WallLayerManager] MeshLibrary已设置，包含 %d 个网格" % mesh_library.get_item_list().size())

func _create_wall_mesh(component: Dictionary) -> Mesh:
	"""创建墙壁网格"""
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.33, 0.33, 0.05) # 墙壁较薄
	
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


func _setup_wall_components():
	"""设置墙壁组件"""
	wall_components = {
		WallType.STONE_WALL: {
			"id": 10,
			"name": "石质墙壁",
			"material": "stone",
			"texture": "stone_wall",
			"color": Color(0.15, 0.15, 0.15), # 深黑色石质墙壁
			"roughness": 0.9,
			"metallic": 0.2,
			"height": 1.0
		},
		WallType.WOOD_WALL: {
			"id": 11,
			"name": "木质墙壁",
			"material": "wood",
			"texture": "wood_wall",
			"color": Color(0.2, 0.1, 0.1), # 深红色木质墙壁
			"roughness": 0.8,
			"metallic": 0.0,
			"height": 1.0
		},
		WallType.METAL_WALL: {
			"id": 12,
			"name": "金属墙壁",
			"material": "metal",
			"texture": "metal_wall",
			"color": Color(0.1, 0.1, 0.1), # 深黑色金属墙壁
			"roughness": 0.3,
			"metallic": 0.9,
			"height": 1.0
		},
		WallType.MAGIC_WALL: {
			"id": 13,
			"name": "魔法墙壁",
			"material": "magic",
			"texture": "magic_wall",
			"color": Color(0.3, 0.1, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.2, 0.1, 0.6),
			"emission_energy": 0.5,
			"height": 1.0
		},
		WallType.GLASS_WALL: {
			"id": 14,
			"name": "玻璃墙壁",
			"material": "glass",
			"texture": "glass_wall",
			"color": Color(0.8, 0.9, 1.0),
			"roughness": 0.0,
			"metallic": 0.0,
			"transparency": 0.3,
			"height": 1.0
		},
		WallType.BRICK_WALL: {
			"id": 15,
			"name": "砖墙",
			"material": "brick",
			"texture": "brick_wall",
			"color": Color(0.7, 0.4, 0.3),
			"roughness": 0.9,
			"metallic": 0.0,
			"height": 1.0
		},
		WallType.MARBLE_WALL: {
			"id": 16,
			"name": "大理石墙",
			"material": "marble",
			"texture": "marble_wall",
			"color": Color(0.9, 0.9, 0.95),
			"roughness": 0.1,
			"metallic": 0.0,
			"height": 1.0
		},
		WallType.DECORATIVE_WALL: {
			"id": 17,
			"name": "装饰墙",
			"material": "decorative",
			"texture": "decorative_wall",
			"color": Color(0.8, 0.6, 0.4),
			"roughness": 0.7,
			"metallic": 0.2,
			"height": 1.0
		}
	}


func assemble_layer(wall_data: Dictionary):
	"""组装墙壁层"""
	if not gridmap:
		LogManager.error("❌ [WallLayerManager] GridMap未设置")
		return
	
	LogManager.info("🏗️ [WallLayerManager] 开始组装墙壁层，数据量: %d" % wall_data.size())
	
	var cell_count = 0
	for pos_str in wall_data:
		var pos = _parse_position(pos_str)
		var wall_type = wall_data[pos_str]
		
		if wall_type in wall_components:
			var component = wall_components[wall_type]
			gridmap.set_cell_item(Vector3i(pos.x, pos.y, pos.z), component.id)
			cell_count += 1
		else:
			LogManager.warning("⚠️ [WallLayerManager] 未知墙壁类型: %s" % str(wall_type))
	
	wall_updated.emit(cell_count)
	LogManager.info("✅ [WallLayerManager] 墙壁层组装完成，放置了 %d 个墙壁组件" % cell_count)


func place_wall_component(position: Vector3i, wall_type: WallType):
	"""放置墙壁组件"""
	if not gridmap:
		LogManager.error("❌ [WallLayerManager] GridMap未设置")
		return false
	
	if wall_type in wall_components:
		var component = wall_components[wall_type]
		gridmap.set_cell_item(position, component.id)
		LogManager.info("🏗️ [WallLayerManager] 放置墙壁组件: %s 在位置 %s" % [component.name, str(position)])
		return true
	else:
		LogManager.warning("⚠️ [WallLayerManager] 未知墙壁类型: %s" % str(wall_type))
		return false


func remove_wall_component(position: Vector3i):
	"""移除墙壁组件"""
	if not gridmap:
		LogManager.error("❌ [WallLayerManager] GridMap未设置")
		return false
	
	gridmap.set_cell_item(position, -1)
	LogManager.info("🗑️ [WallLayerManager] 移除位置 %s 的墙壁组件" % str(position))
	return true


func get_wall_component_info(position: Vector3i) -> Dictionary:
	"""获取墙壁组件信息"""
	if not gridmap:
		return {}
	
	var item_id = gridmap.get_cell_item(position)
	if item_id == -1:
		return {}
	
	# 查找对应的组件信息
	for wall_type in wall_components:
		if wall_components[wall_type].id == item_id:
			return wall_components[wall_type]
	
	return {}


func set_config(config: Dictionary):
	"""设置墙壁层配置"""
	wall_config = config
	LogManager.info("⚙️ [WallLayerManager] 墙壁层配置已更新")


func get_layer_info() -> Dictionary:
	"""获取墙壁层信息"""
	if not gridmap:
		return {"cell_count": 0, "components": []}
	
	var used_cells = gridmap.get_used_cells()
	var components = []
	
	for cell in used_cells:
		var item_id = gridmap.get_cell_item(cell)
		var component_info = get_wall_component_info(cell)
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
