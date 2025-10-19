extends Node
# 瓦片网格工厂 - 负责创建和配置瓦片的3D对象
# 使用工厂模式，统一管理瓦片对象的创建逻辑

class_name TileMeshFactory

# 依赖注入
var material_manager: MaterialManager
var mesh_pool: MeshPool

func _ready():
	"""初始化瓦片网格工厂"""
	LogManager.info("TileMeshFactory - 初始化开始")
	
	# 获取依赖
	material_manager = MaterialManager.new()
	mesh_pool = MeshPool.new()
	
	# 添加到场景树
	add_child(material_manager)
	add_child(mesh_pool)
	
	LogManager.info("TileMeshFactory - 初始化完成")

func create_tile_object(tile_data) -> Node3D:
	"""创建瓦片3D对象"""
	var tile_type = tile_data.type
	var _position = tile_data.position
	var _level = tile_data.level
	
	# 特殊处理地牢之心
	if tile_type == TileTypes.TileType.DUNGEON_HEART:
		return _create_dungeon_heart_object(tile_data)
	
	# 创建基础瓦片对象
	var tile_object = _create_base_tile_object(tile_data)
	
	# 根据类型添加特定组件
	_configure_tile_by_type(tile_object, tile_data)
	
	return tile_object

func _create_base_tile_object(tile_data: ) -> MeshInstance3D:
	"""创建基础瓦片对象"""
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = _generate_tile_name(tile_data)
	
	# 设置位置
	mesh_instance.position = _calculate_tile_position(tile_data)
	
	# 获取网格和材质
	var mesh = mesh_pool.get_tile_mesh(tile_data.type)
	var material = material_manager.get_tile_material(tile_data.type)
	
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	
	return mesh_instance

func _create_dungeon_heart_object(tile_data: ) -> Node3D:
	"""创建地牢之心对象（只包含碰撞体和交互区域）"""
	var container = Node3D.new()
	container.name = _generate_tile_name(tile_data)
	container.position = _calculate_tile_position(tile_data)
	
	# 地牢之心不渲染网格，由专门的DungeonHeart对象处理
	# 只添加碰撞体和交互区域
	_add_collision_body(container, tile_data.type, tile_data.position)
	_add_interaction_area(container, tile_data.type, tile_data.position)
	
	return container

func _configure_tile_by_type(tile_object: Node3D, tile_data: ):
	"""根据瓦片类型配置特定组件"""
	var tile_type = tile_data.type
	
	# 添加碰撞体（如果需要）
	if _needs_collision(tile_type):
		_add_collision_body(tile_object, tile_type, tile_data.position)
	
	# 添加交互区域（如果需要）
	if _needs_interaction_area(tile_type):
		_add_interaction_area(tile_object, tile_type, tile_data.position)
	
	# 添加表层建筑（如果需要）
	if _needs_top_overlay(tile_type):
		_add_top_overlay(tile_object, tile_data)

func _generate_tile_name(tile_data: ) -> String:
	"""生成瓦片对象名称"""
	var type_name = _get_tile_type_name(tile_data.type)
	return "%s_%d_%d_%d" % [type_name, tile_data.position.x, tile_data.position.z, tile_data.level]

func _calculate_tile_position(tile_data: ) -> Vector3:
	"""计算瓦片渲染位置"""
	var base_pos = Vector3(tile_data.position.x + 0.5, 0, tile_data.position.z + 0.5)
	
	# 根据瓦片类型调整Y坐标
	if _is_full_fill_type(tile_data.type):
		# 全填充类型（墙体、金矿等）：中心在Y=0.5
		base_pos.y = 0.5
	elif _is_bottom_fill_type(tile_data.type):
		# 底部填充类型（地面）：中心在Y=0.025
		base_pos.y = 0.025
	else:
		# 建筑类型：基础在Y=0.025，表层会单独调整
		base_pos.y = 0.025
	
	return base_pos

func _add_collision_body(tile_object: Node3D, tile_type: int, position: Vector3):
	"""添加碰撞体"""
	# 可通行地面不需要碰撞体
	if _is_walkable_floor_type(tile_type):
		return
	
	var static_body = StaticBody3D.new()
	static_body.name = "TileCollision"
	
	# 配置物理层
	_configure_collision_layers(static_body, tile_type)
	
	# 创建碰撞形状
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	
	# 设置碰撞体尺寸
	var collision_height = _get_collision_height_for_type(tile_type)
	box_shape.size = Vector3(1.0, collision_height, 1.0)
	collision_shape.shape = box_shape
	
	# 调整碰撞体位置
	collision_shape.position.y = _calculate_collision_offset(tile_type, collision_height)
	
	static_body.add_child(collision_shape)
	tile_object.add_child(static_body)

func _add_interaction_area(tile_object: Node3D, tile_type: int, _position: Vector3):
	"""添加交互区域"""
	var interaction_area = Area3D.new()
	
	# 启用监控
	interaction_area.monitoring = true
	interaction_area.monitorable = false
	
	# 设置名称和组
	interaction_area.name = "InteractionArea"
	_configure_interaction_area(interaction_area, tile_type)
	
	# 创建碰撞形状
	var area_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1.4, 1.0, 1.4) # 比碰撞体稍大
	area_shape.shape = box_shape
	
	interaction_area.add_child(area_shape)
	tile_object.add_child(interaction_area)

func _add_top_overlay(tile_object: MeshInstance3D, tile_data: ):
	"""添加表层建筑"""
	var top_mesh_instance = MeshInstance3D.new()
	top_mesh_instance.name = "TopOverlay"
	top_mesh_instance.position = Vector3.ZERO
	
	# 获取表层网格和材质
	var top_mesh = mesh_pool.get_tile_mesh(tile_data.type, false)
	var top_material = material_manager.get_tile_material(tile_data.type)
	
	top_mesh_instance.mesh = top_mesh
	top_mesh_instance.material_override = top_material
	
	# 计算表层高度
	var overlay_height = _get_overlay_height(tile_data.type)
	top_mesh_instance.position.y = 0.025 + overlay_height * 0.5
	
	tile_object.add_child(top_mesh_instance)

func _configure_collision_layers(static_body: StaticBody3D, tile_type: int):
	"""配置碰撞层"""
	static_body.collision_layer = 0
	static_body.collision_mask = 0
	
	if _is_building_type(tile_type):
		# 建筑使用建筑层（第4层）
		static_body.set_collision_layer_value(4, true)
	else:
		# 墙壁、地形、资源使用环境层（第1层）
		static_body.set_collision_layer_value(1, true)

func _configure_interaction_area(area: Area3D, tile_type: int):
	"""配置交互区域"""
	area.collision_layer = 0
	area.collision_mask = 0
	area.set_collision_mask_value(2, true) # 监测单位层
	
	# 添加到相应组
	match tile_type:
		TileTypes.TileType.GOLD_MINE:
			area.add_to_group(GameGroups.MINING_ZONES)
		TileTypes.TileType.MANA_CRYSTAL, TileTypes.TileType.FOOD_FARM:
			area.add_to_group(GameGroups.RESOURCE_NODES)
		TileTypes.TileType.DUNGEON_HEART:
			area.add_to_group(GameGroups.INTERACTION_ZONES)
	
	# 设置元数据
	area.set_meta("tile_type", tile_type)
	area.set_meta("tile_position", Vector3(0, 0, 0)) # 会被外部设置

func _calculate_collision_offset(tile_type: int, collision_height: float) -> float:
	"""计算碰撞体Y偏移"""
	if _is_full_fill_type(tile_type):
		# 墙体：tile_object在Y=0.5，碰撞体中心也在Y=0.5
		return 0.0
	else:
		# 地面和建筑：tile_object在Y=0.025，碰撞体从Y=0开始
		return collision_height / 2.0 - 0.025

# ===== 分类判断函数 =====

func _is_full_fill_type(tile_type: int) -> bool:
	"""判断是否为全填充类型"""
	return (
		tile_type == TileTypes.TileType.STONE_WALL or
		tile_type == TileTypes.TileType.GOLD_MINE or
		tile_type == TileTypes.TileType.UNEXCAVATED
	)

func _is_bottom_fill_type(tile_type: int) -> bool:
	"""判断是否为底部填充类型"""
	# 🔧 [简化] 使用 TileTypes 的工具函数
	return TileTypes.is_walkable(tile_type)

func _needs_top_overlay(tile_type: int) -> bool:
	"""判断是否需要表层建筑"""
	return (
		tile_type == TileTypes.TileType.BARRACKS or
		tile_type == TileTypes.TileType.WORKSHOP or
		tile_type == TileTypes.TileType.MAGIC_LAB or
		tile_type == TileTypes.TileType.DEFENSE_TOWER or
		tile_type == TileTypes.TileType.DUNGEON_HEART or
		tile_type == TileTypes.TileType.MANA_CRYSTAL or
		tile_type == TileTypes.TileType.FOOD_FARM
	)

func _needs_collision(tile_type: int) -> bool:
	"""判断是否需要碰撞体"""
	return not _is_walkable_floor_type(tile_type)

func _needs_interaction_area(tile_type: int) -> bool:
	"""判断是否需要交互区域"""
	return (
		tile_type == TileTypes.TileType.GOLD_MINE or
		tile_type == TileTypes.TileType.MANA_CRYSTAL or
		tile_type == TileTypes.TileType.FOOD_FARM or
		tile_type == TileTypes.TileType.DUNGEON_HEART
	)

func _is_walkable_floor_type(tile_type: int) -> bool:
	"""判断是否为可通行地面类型"""
	# 🔧 [简化] 直接使用 TileTypes 的工具函数
	return TileTypes.is_walkable(tile_type)

func _is_building_type(tile_type: int) -> bool:
	"""判断是否为建筑类型"""
	return (
		tile_type == TileTypes.TileType.BARRACKS or
		tile_type == TileTypes.TileType.WORKSHOP or
		tile_type == TileTypes.TileType.MAGIC_LAB or
		tile_type == TileTypes.TileType.DEFENSE_TOWER or
		tile_type == TileTypes.TileType.DUNGEON_HEART or
		tile_type == TileTypes.TileType.FOOD_FARM
	)

func _get_collision_height_for_type(tile_type: int) -> float:
	"""获取瓦片类型对应的碰撞高度"""
	match tile_type:
		TileTypes.TileType.UNEXCAVATED, TileTypes.TileType.STONE_WALL, TileTypes.TileType.GOLD_MINE:
			return 1.0
		TileTypes.TileType.DEFENSE_TOWER, TileTypes.TileType.DUNGEON_HEART:
			return 1.05
		TileTypes.TileType.BARRACKS, TileTypes.TileType.WORKSHOP, TileTypes.TileType.MAGIC_LAB, \
		TileTypes.TileType.MANA_CRYSTAL, TileTypes.TileType.FOOD_FARM:
			return 0.85
		_:
			return 0.05

func _get_overlay_height(tile_type: int) -> float:
	"""获取表层建筑高度"""
	match tile_type:
		TileTypes.TileType.DEFENSE_TOWER, TileTypes.TileType.DUNGEON_HEART:
			return 1.0
		TileTypes.TileType.MANA_CRYSTAL:
			return 0.8
		TileTypes.TileType.FOOD_FARM, TileTypes.TileType.BARRACKS, TileTypes.TileType.WORKSHOP, TileTypes.TileType.MAGIC_LAB:
			return 0.8
		_:
			return 0.8

func _get_tile_type_name(tile_type: int) -> String:
	"""获取瓦片类型名称"""
	# 🔧 [统一类型] 使用 TileTypes.get_tile_name 方法
	return TileTypes.get_tile_name(tile_type)

func cleanup():
	"""清理资源"""
	LogManager.info("TileMeshFactory - 开始清理资源")
	
	if material_manager:
		material_manager.clear_cache()
	if mesh_pool:
		mesh_pool.clear_pools()
	
	LogManager.info("TileMeshFactory - 资源清理完成")
