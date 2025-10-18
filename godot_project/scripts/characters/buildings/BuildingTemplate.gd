extends RefCounted
class_name BuildingTemplate

## 🏗️ 建筑模板类
## 定义3x3x3建筑的GridMap模板结构

var name: String = ""
var building_type: int = 0
var size: Vector3 = Vector3(3, 3, 3) # 3x3x3空间
var components: Array[Array] = [] # 3D数组，存储每个位置的构件ID

# 模板元数据
var description: String = ""
var author: String = ""
var version: String = "1.0"
var tags: Array[String] = []


func _init(template_name: String = ""):
	name = template_name
	_initialize_empty_template()


func _initialize_empty_template():
	"""初始化空的3x3x3模板"""
	components.clear()
	
	# 创建3x3x3的空结构
	for y in range(3):
		var layer = []
		for z in range(3):
			var row = []
			for x in range(3):
				row.append(BuildingComponents.ID_EMPTY)
			layer.append(row)
		components.append(layer)


func set_component(x: int, y: int, z: int, component_id: int):
	"""设置指定位置的构件ID"""
	if _is_valid_position(x, y, z):
		components[y][z][x] = component_id


func get_component(x: int, y: int, z: int) -> int:
	"""获取指定位置的构件ID"""
	if _is_valid_position(x, y, z):
		return components[y][z][x]
	return BuildingComponents.ID_EMPTY


func _is_valid_position(x: int, y: int, z: int) -> bool:
	"""检查位置是否有效"""
	return x >= 0 and x < 3 and y >= 0 and y < 3 and z >= 0 and z < 3


func fill_layer(y: int, component_id: int):
	"""填充整个层"""
	if y >= 0 and y < 3:
		for z in range(3):
			for x in range(3):
				components[y][z][x] = component_id


func fill_walls(component_id: int):
	"""填充所有墙面"""
	# 底层墙面
	for y in range(3):
		for z in range(3):
			for x in range(3):
				# 检查是否为墙面位置（边缘但不是角落）
				if _is_wall_position(x, y, z):
					components[y][z][x] = component_id


func fill_corners(component_id: int):
	"""填充所有角落"""
	for y in range(3):
		for z in range(3):
			for x in range(3):
				if _is_corner_position(x, y, z):
					components[y][z][x] = component_id


func _is_wall_position(x: int, y: int, z: int) -> bool:
	"""检查是否为墙面位置"""
	# 墙面：在边缘但不是角落
	return (x == 0 or x == 2 or z == 0 or z == 2) and not _is_corner_position(x, y, z)


func _is_corner_position(x: int, y: int, z: int) -> bool:
	"""检查是否为角落位置"""
	return (x == 0 or x == 2) and (z == 0 or z == 2)


func add_door(x: int, y: int, z: int, door_type: int = BuildingComponents.ID_DOOR_WOOD):
	"""添加门"""
	if _is_valid_position(x, y, z) and _is_wall_position(x, y, z):
		set_component(x, y, z, door_type)


func add_window(x: int, y: int, z: int, window_type: int = BuildingComponents.ID_WINDOW_SMALL):
	"""添加窗户"""
	if _is_valid_position(x, y, z) and _is_wall_position(x, y, z):
		set_component(x, y, z, window_type)


func add_pillar(x: int, y: int, z: int, pillar_type: int = BuildingComponents.ID_PILLAR_STONE):
	"""添加柱子"""
	if _is_valid_position(x, y, z):
		set_component(x, y, z, pillar_type)


func add_decoration(x: int, y: int, z: int, decoration_type: int):
	"""添加装饰"""
	if _is_valid_position(x, y, z):
		set_component(x, y, z, decoration_type)


func create_simple_tower(tower_type: int = BuildingTypes.BuildingType.ARROW_TOWER):
	"""创建简单塔楼模板"""
	name = "Simple Tower"
	building_type = tower_type
	description = "简单的3x3x3塔楼结构"
	
	# 底层：石质地板
	fill_layer(0, BuildingComponents.ID_FLOOR_STONE)
	
	# 中层：石质墙体，中心留空
	fill_walls(BuildingComponents.ID_WALL_STONE)
	set_component(1, 1, 1, BuildingComponents.ID_FLOOR_STONE) # 中心地板
	
	# 顶层：屋顶
	fill_layer(2, BuildingComponents.ID_ROOF_SLOPE)
	set_component(1, 2, 1, BuildingComponents.ID_ROOF_PEAK) # 中心尖顶
	
	# 添加门（正面中央）
	add_door(1, 0, 0)
	
	# 添加窗户（中层）
	add_window(1, 1, 0)
	add_window(0, 1, 1)
	add_window(2, 1, 1)


func create_simple_house(house_type: int = BuildingTypes.BuildingType.LAIR):
	"""创建简单房屋模板"""
	name = "Simple House"
	building_type = house_type
	description = "简单的3x3x3房屋结构"
	
	# 底层：木质地板
	fill_layer(0, BuildingComponents.ID_FLOOR_WOOD)
	
	# 中层：木质墙体，中心留空
	fill_walls(BuildingComponents.ID_WALL_WOOD)
	set_component(1, 1, 1, BuildingComponents.ID_FLOOR_WOOD) # 中心地板
	
	# 顶层：屋顶
	fill_layer(2, BuildingComponents.ID_ROOF_SLOPE)
	set_component(1, 2, 1, BuildingComponents.ID_ROOF_PEAK) # 中心尖顶
	
	# 添加门（正面中央）
	add_door(1, 0, 0)
	
	# 添加窗户（中层）
	add_window(1, 1, 0)
	add_window(0, 1, 1)
	add_window(2, 1, 1)


func create_magic_structure(magic_type: int = BuildingTypes.BuildingType.ARCANE_TOWER):
	"""创建魔法结构模板"""
	name = "Magic Structure"
	building_type = magic_type
	description = "神秘的3x3x3魔法结构"
	
	# 底层：石质地板
	fill_layer(0, BuildingComponents.ID_FLOOR_STONE)
	
	# 中层：石质墙体，中心魔法核心
	fill_walls(BuildingComponents.ID_WALL_STONE)
	set_component(1, 1, 1, BuildingComponents.ID_STATUE_STONE) # 中心魔法核心
	
	# 顶层：魔法屋顶
	fill_layer(2, BuildingComponents.ID_ROOF_SLOPE)
	set_component(1, 2, 1, BuildingComponents.ID_ROOF_PEAK) # 中心尖顶
	
	# 添加魔法门
	add_door(1, 0, 0, BuildingComponents.ID_GATE_STONE)
	
	# 添加魔法窗户
	add_window(1, 1, 0, BuildingComponents.ID_WINDOW_LARGE)
	add_window(0, 1, 1, BuildingComponents.ID_WINDOW_LARGE)
	add_window(2, 1, 1, BuildingComponents.ID_WINDOW_LARGE)
	
	# 添加魔法装饰
	add_decoration(1, 0, 1, BuildingComponents.ID_TORCH_WALL)
	add_decoration(1, 1, 0, BuildingComponents.ID_TORCH_WALL)


func create_military_structure(military_type: int = BuildingTypes.BuildingType.TRAINING_ROOM):
	"""创建军事结构模板"""
	name = "Military Structure"
	building_type = military_type
	description = "坚固的3x3x3军事结构"
	
	# 底层：金属地板
	fill_layer(0, BuildingComponents.ID_FLOOR_METAL)
	
	# 中层：金属墙体，中心训练场
	fill_walls(BuildingComponents.ID_WALL_METAL)
	set_component(1, 1, 1, BuildingComponents.ID_FLOOR_METAL) # 中心训练场
	
	# 顶层：军事屋顶
	fill_layer(2, BuildingComponents.ID_ROOF_SLOPE)
	set_component(1, 2, 1, BuildingComponents.ID_ROOF_PEAK) # 中心尖顶
	
	# 添加军事门
	add_door(1, 0, 0, BuildingComponents.ID_DOOR_METAL)
	
	# 添加军事窗户
	add_window(1, 1, 0, BuildingComponents.ID_WINDOW_SMALL)
	add_window(0, 1, 1, BuildingComponents.ID_WINDOW_SMALL)
	add_window(2, 1, 1, BuildingComponents.ID_WINDOW_SMALL)
	
	# 添加军事装饰
	add_decoration(1, 0, 1, BuildingComponents.ID_BANNER_CLOTH)
	add_decoration(1, 1, 0, BuildingComponents.ID_BANNER_CLOTH)


func to_dict() -> Dictionary:
	"""转换为字典"""
	return {
		"name": name,
		"building_type": building_type,
		"size": size,
		"components": components,
		"description": description,
		"author": author,
		"version": version,
		"tags": tags
	}


func from_dict(data: Dictionary):
	"""从字典加载"""
	name = data.get("name", "")
	building_type = data.get("building_type", 0)
	size = data.get("size", Vector3(3, 3, 3))
	components = data.get("components", [])
	description = data.get("description", "")
	author = data.get("author", "")
	version = data.get("version", "1.0")
	tags = data.get("tags", [])


func print_template():
	"""打印模板结构（调试用）"""
	LogManager.info("=== Building Template: %s ===" % name)
	for y in range(2, -1, -1): # 从顶层开始打印
		LogManager.info("Layer %d (Y=%d):" % [y, y])
		for z in range(3):
			var row = ""
			for x in range(3):
				var component_id = get_component(x, y, z)
				row += "[%d] " % component_id
			LogManager.info("  %s" % row)
	LogManager.info("===============================")
