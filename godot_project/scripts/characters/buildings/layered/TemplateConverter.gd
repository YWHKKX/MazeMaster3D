extends RefCounted
class_name TemplateConverter

## 🔄 建筑模板转换器
## 将BuildingTemplateGenerator的Vector3模板转换为分层系统需要的字符串键模板

static func convert_vector3_template_to_layered(vector3_template: Dictionary) -> Dictionary:
	"""将Vector3模板转换为分层模板"""
	var layered_template = {
		"floor": {},
		"wall": {},
		"ceiling": {},
		"decoration": {}
	}
	
	# 根据Y坐标和组件类型分类
	for pos in vector3_template:
		var component_id = vector3_template[pos]
		var pos_str = "%d,%d,%d" % [pos.x, pos.y, pos.z]
		
		# 根据Y坐标和组件ID确定层类型
		var layer_type = _determine_layer_type(pos.y, component_id)
		
		# 将BuildingComponents ID映射到层管理器的枚举值
		var mapped_id = _map_component_id_to_layer_enum(component_id, layer_type)
		layered_template[layer_type][pos_str] = mapped_id
		
		# 调试日志：记录装饰组件的分类
		if layer_type == "decoration":
			LogManager.info("🔧 [TemplateConverter] 装饰组件分类: ID=%d, 位置=%s, 映射ID=%d" % [component_id, pos_str, mapped_id])
	
	# 统计各层组件数量
	var floor_count = layered_template["floor"].size()
	var wall_count = layered_template["wall"].size()
	var ceiling_count = layered_template["ceiling"].size()
	var decoration_count = layered_template["decoration"].size()
	LogManager.info("🏗️ [TemplateConverter] 模板转换完成: 地面=%d, 墙壁=%d, 天花板=%d, 装饰=%d" % [floor_count, wall_count, ceiling_count, decoration_count])
	
	return layered_template

static func _determine_layer_type(y_coord: int, component_id: int) -> String:
	"""根据Y坐标和组件ID确定层类型"""
	# 首先根据组件ID判断是否为装饰组件
	var layer_by_id = _determine_layer_by_component_id(component_id)
	if layer_by_id == "decoration":
		return "decoration"
	
	# 然后根据Y坐标分类
	# Y=0: 地面层
	if y_coord == 0:
		return "floor"
	# Y=1: 墙壁层
	elif y_coord == 1:
		return "wall"
	# Y=2: 天花板层
	elif y_coord == 2:
		return "ceiling"
	# 其他: 根据组件ID判断
	else:
		return layer_by_id

static func _determine_layer_by_component_id(component_id: int) -> String:
	"""根据组件ID确定层类型"""
	# 地面组件ID范围 (1-9)
	if component_id >= 1 and component_id <= 9:
		return "floor"
	# 墙壁组件ID范围 (4-6, 51-55)
	elif (component_id >= 4 and component_id <= 6) or (component_id >= 51 and component_id <= 55):
		return "wall"
	# 天花板组件ID范围 (10-14)
	elif component_id >= 10 and component_id <= 14:
		return "ceiling"
	# 装饰组件ID范围 (其他所有ID)
	else:
		return "decoration"

static func _map_component_id_to_layer_enum(component_id: int, layer_type: String) -> int:
	"""将BuildingComponents ID映射到层管理器的枚举值"""
	match layer_type:
		"floor":
			return _map_floor_component(component_id)
		"wall":
			return _map_wall_component(component_id)
		"ceiling":
			return _map_ceiling_component(component_id)
		"decoration":
			return _map_decoration_component(component_id)
		_:
			return 0

static func _map_floor_component(component_id: int) -> int:
	"""映射地面组件ID到FloorType枚举"""
	match component_id:
		BuildingComponents.ID_FLOOR_STONE:
			return 0 # FloorType.STONE_FLOOR
		BuildingComponents.ID_FLOOR_WOOD:
			return 1 # FloorType.WOOD_FLOOR
		BuildingComponents.ID_FLOOR_METAL:
			return 2 # FloorType.METAL_FLOOR
		BuildingComponents.ID_FLOOR_TRAP:
			return 3 # FloorType.TRAP_FLOOR
		_:
			return 0 # 默认石质地板

static func _map_wall_component(component_id: int) -> int:
	"""映射墙壁组件ID到WallType枚举"""
	match component_id:
		BuildingComponents.ID_WALL_STONE:
			return 0 # WallType.STONE_WALL
		BuildingComponents.ID_WALL_WOOD:
			return 1 # WallType.WOOD_WALL
		BuildingComponents.ID_WALL_METAL:
			return 2 # WallType.METAL_WALL
		BuildingComponents.ID_DOOR_WOOD, BuildingComponents.ID_DOOR_METAL:
			return 0 # 门也视为石质墙壁
		_:
			return 0 # 默认石质墙壁

static func _map_ceiling_component(component_id: int) -> int:
	"""映射天花板组件ID到CeilingType枚举"""
	match component_id:
		BuildingComponents.ID_ROOF_TILE:
			return 0 # CeilingType.STONE_CEILING
		BuildingComponents.ID_ROOF_SLOPE:
			return 1 # CeilingType.WOOD_CEILING
		BuildingComponents.ID_ROOF_PEAK:
			return 2 # CeilingType.METAL_CEILING
		_:
			return 0 # 默认石质天花板

static func _map_decoration_component(component_id: int) -> int:
	"""映射装饰组件ID到DecorationType枚举"""
	# 地牢之心装饰组件映射
	match component_id:
		BuildingComponents.ID_HEART_CORE:
			return 0 # 地牢之心核心
		BuildingComponents.ID_ENERGY_CRYSTAL:
			return 1 # 能量水晶
		BuildingComponents.ID_MANA_CRYSTAL:
			return 2 # 魔力水晶
		BuildingComponents.ID_MAGIC_CORE:
			return 3 # 魔法核心
		BuildingComponents.ID_ENERGY_CONDUIT:
			return 4 # 能量导管
		BuildingComponents.ID_ENERGY_NODE:
			return 5 # 能量节点
		BuildingComponents.ID_STORAGE_CORE:
			return 6 # 存储核心
		BuildingComponents.ID_ENERGY_CONDUIT_2:
			return 4 # 能量导管2
		BuildingComponents.ID_POWER_NODE:
			return 7 # 能量节点
		BuildingComponents.ID_CORE_CHAMBER:
			return 8 # 核心密室
		BuildingComponents.ID_ENERGY_FLOW:
			return 9 # 能量流动
		BuildingComponents.ID_HEART_ENTRANCE:
			return 10 # 地牢之心入口
		_:
			return 0 # 默认装饰组件

static func convert_dungeon_heart_template() -> Dictionary:
	"""专门转换地牢之心模板"""
	var vector3_template = BuildingTemplateGenerator.generate_dungeon_heart_template()
	return convert_vector3_template_to_layered(vector3_template)

static func convert_arcane_tower_template() -> Dictionary:
	"""转换奥术塔模板"""
	var vector3_template = BuildingTemplateGenerator.generate_arcane_tower_template()
	return convert_vector3_template_to_layered(vector3_template)

static func convert_arrow_tower_template() -> Dictionary:
	"""转换箭塔模板"""
	var vector3_template = BuildingTemplateGenerator.generate_arrow_tower_template()
	return convert_vector3_template_to_layered(vector3_template)

static func convert_treasury_template() -> Dictionary:
	"""转换金库模板"""
	var vector3_template = BuildingTemplateGenerator.generate_treasury_template()
	return convert_vector3_template_to_layered(vector3_template)

static func convert_building_template(building_type: BuildingTypes.BuildingType) -> Dictionary:
	"""根据建筑类型转换模板"""
	# 获取Vector3模板
	var vector3_template: Dictionary
	
	# 根据建筑类型选择模板生成方法
	match building_type:
		BuildingTypes.BuildingType.DUNGEON_HEART:
			vector3_template = BuildingTemplateGenerator.generate_dungeon_heart_template()
		BuildingTypes.BuildingType.TREASURY:
			vector3_template = BuildingTemplateGenerator.generate_1x1_treasury_template()
		BuildingTypes.BuildingType.ARCANE_TOWER:
			vector3_template = BuildingTemplateGenerator.generate_1x1_arcane_tower_template()
		BuildingTypes.BuildingType.BARRACKS:
			vector3_template = BuildingTemplateGenerator.generate_1x1_barracks_template()
		BuildingTypes.BuildingType.WORKSHOP:
			vector3_template = BuildingTemplateGenerator.generate_1x1_workshop_template()
		_:
			# 默认使用1x1模板
			vector3_template = BuildingTemplateGenerator.generate_default_1x1_template()
	
	# 转换为分层模板
	return convert_vector3_template_to_layered(vector3_template)
