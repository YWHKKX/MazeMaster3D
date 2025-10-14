extends Node
# 地块管理器 - 负责管理地下世界的所有地块
# 基于MAP_DESIGN.md的设计理念实现多层次地下结构
# 日志管理器实例（全局变量）
# 地块类型枚举
enum TileType {
	EMPTY, # 空地
	UNEXCAVATED, # 未挖掘地块（默认状态）
	STONE_WALL, # 石墙
	STONE_FLOOR, # 石制地面
	DIRT_FLOOR, # 泥土地面
	MAGIC_FLOOR, # 魔法地面
	GOLD_MINE, # 金矿
	MANA_CRYSTAL, # 法力水晶
	FOOD_FARM, # 食物农场
	BARRACKS, # 兵营
	WORKSHOP, # 工坊
	MAGIC_LAB, # 魔法实验室
	DEFENSE_TOWER, # 防御塔
	TRAP, # 陷阱
	CORRIDOR, # 通道
	SECRET_PASSAGE, # 秘密通道
	DUNGEON_HEART # 地牢之心
}

# 地块状态
enum TileState {
	NORMAL, # 正常状态
	HIGHLIGHTED, # 高亮显示
	SELECTED, # 选中状态
	INVALID, # 无效位置
	BUILDING # 建造中
}

# 瓦块高亮选项枚举
enum TileHighlightOption {
	NONE, # 无高亮
	GREEN, # 绿色 - 可以放置
	YELLOW, # 黄色 - 资源不足/空地
	CYAN, # 青色 - 可以挖掘
	RED, # 红色 - 地形问题/不可挖掘
	PURPLE, # 紫色 - 距离过远
	ORANGE, # 橙色 - 位置占用
	BROWN # 棕色 - 其他状态
}

# 地图层级
enum MapLevel {LEVEL_0_MAIN} # 主层 - 主要游戏区域


# 地块数据结构
class TileInfo:
	var type: TileType
	var state: TileState
	var position: Vector3
	var level: MapLevel
	var is_walkable: bool
	var is_buildable: bool
	var is_diggable: bool
	var is_building: bool # 新增：是否为建筑类型
	var is_reachable: bool = false # 🔧 新增：是否从地牢之心可达
	var resources: Dictionary = {}
	var building_data: Dictionary = {}
	var building_ref: Node = null # 🔧 2x2建筑：指向对应的Building对象（如DungeonHeart）
	var tile_object: MeshInstance3D = null # 对应的3D对象
	var highlight_option: TileHighlightOption = TileHighlightOption.NONE # 高亮选项

	func _init(
		pos: Vector3,
		tile_type: TileType = TileType.EMPTY,
		map_level: MapLevel = MapLevel.LEVEL_0_MAIN
	):
		position = pos
		type = tile_type
		level = map_level
		state = TileState.NORMAL
		is_walkable = false
		is_buildable = false
		is_diggable = false
		is_building = false
		_update_properties()

	func _update_properties():
		match type:
			TileType.EMPTY, \
			TileType.STONE_FLOOR, \
			TileType.DIRT_FLOOR, \
			TileType.MAGIC_FLOOR, \
			TileType.CORRIDOR:
				is_walkable = true
				is_buildable = true
				is_diggable = true
				is_building = false
			TileType.UNEXCAVATED:
				is_walkable = false
				is_buildable = false
				is_diggable = true
				is_building = false
			TileType.STONE_WALL:
				is_walkable = false
				is_buildable = false
				is_diggable = false
				is_building = false
			TileType.GOLD_MINE, \
			TileType.MANA_CRYSTAL:
				# 🔧 [关键修复] 金矿应该可通行！苦工需要站在金矿上挖掘
				is_walkable = true
				is_buildable = false
				is_diggable = false
				is_building = false
			TileType.FOOD_FARM:
				is_walkable = false
				is_buildable = false
				is_diggable = false
				is_building = true # 🔧 修复：食物农场是建筑类型，需要与_is_building_type()一致
			TileType.BARRACKS, \
			TileType.WORKSHOP, \
			TileType.MAGIC_LAB, \
			TileType.DEFENSE_TOWER, \
			TileType.DUNGEON_HEART:
				is_walkable = false
				is_buildable = false
				is_diggable = false
				is_building = true
			TileType.TRAP:
				is_walkable = true
				is_buildable = false
				is_diggable = true
				is_building = false
			TileType.SECRET_PASSAGE:
				is_walkable = true
				is_buildable = false
				is_diggable = true
				is_building = false


# 地图配置
var map_size = Vector3(100, 1, 100) # 宽度, 层级数, 深度
var tile_size = Vector3(1.0, 1.0, 1.0)

# 高亮颜色映射已移除，现在使用独立的高亮系统

# 地块存储
var tiles = [] # 三维数组 [level][x][z]
var tile_objects = [] # 对应的3D对象

# 节点引用
@onready var world: Node3D = get_node("/root/Main/World")
@onready var dungeon: Node3D = world.get_node("Environment/Dungeon")


func _ready():
	"""初始化地块管理器"""
	LogManager.info("TileManager - 初始化开始")
	_initialize_map_structure()
	# 注意：不在这里生成初始地图，由 MapGenerator 统一管理地图生成
	LogManager.info("TileManager - 初始化完成")

func set_map_size(new_size: Vector3) -> void:
	"""设置地图尺寸并重新初始化地图结构"""
	map_size = new_size
	LogManager.info("TileManager 地图尺寸设置为: " + str(map_size))
	_initialize_map_structure()


func _initialize_map_structure():
	"""初始化地图结构"""
	# 初始化三维数组
	tiles.clear()
	tile_objects.clear()

	for level in range(map_size.y):
		tiles.append([])
		tile_objects.append([])

		for x in range(map_size.x):
			tiles[level].append([])
			tile_objects[level].append([])

			for z in range(map_size.z):
				tiles[level][x].append(null)
				tile_objects[level][x].append(null)


func _generate_initial_map():
	"""生成初始地图"""
	LogManager.info("生成初始地下世界地图...")

	# 生成核心层 (Level 1)
	_generate_core_level()

	# 仅放置地牢之心（不生成通道与资源）
	_place_dungeon_heart()

	LogManager.info("地图生成完成")


func _generate_core_level():
	"""生成核心层地图
	
	🔧 [修改] 默认地块类型改为 EMPTY（而不是 UNEXCAVATED）
	"""
	var level = MapLevel.LEVEL_0_MAIN
	var level_index = int(level)

	LogManager.info("生成核心层地图...")

	for x in range(map_size.x):
		for z in range(map_size.z):
			var pos = Vector3(x, level_index, z)
			# 🔧 修改：默认为 EMPTY（空地），而不是 UNEXCAVATED（未挖掘）
			var tile_data = TileInfo.new(pos, TileType.EMPTY, level)

			tiles[level_index][x][z] = tile_data
			_create_tile_object(tile_data)


# 注意：以下生成函数已移除，因为当前使用单层模式
# 如需多层级支持，可以重新添加这些函数


func _create_initial_corridors():
	"""创建初始通道系统"""
	LogManager.info("创建初始通道系统...")

	# 创建主干道
	_create_main_corridors()

	# 创建支线通道
	_create_branch_corridors()


func _create_main_corridors():
	"""创建主干道"""
	var center_x = int(map_size.x / 2)
	var center_z = int(map_size.z / 2)
	var level_index = int(MapLevel.LEVEL_0_MAIN)

	# 水平主干道
	for x in range(map_size.x):
		var pos = Vector3(x, center_z, level_index)
		_set_tile_type(pos, TileType.CORRIDOR)

	# 垂直主干道
	for z in range(map_size.z):
		var pos = Vector3(center_x, z, level_index)
		_set_tile_type(pos, TileType.CORRIDOR)


func _create_branch_corridors():
	"""创建支线通道"""
	var level_index = int(MapLevel.LEVEL_0_MAIN)

	# 创建一些随机的支线通道
	for i in range(10):
		var start_x = randi() % int(map_size.x)
		var start_z = randi() % int(map_size.z)
		var length = randi() % 8 + 3

		# 随机方向
		var direction = Vector2(randf() - 0.5, randf() - 0.5).normalized()

		for j in range(length):
			var x = int(start_x + direction.x * j)
			var z = int(start_z + direction.y * j)

			if x >= 0 and x < map_size.x and z >= 0 and z < map_size.z:
				var pos = Vector3(x, z, level_index)
				if _get_tile_type(pos) == TileType.STONE_WALL:
					_set_tile_type(pos, TileType.CORRIDOR)


func _place_dungeon_heart():
	"""放置地牢之心
	
	🔧 [修改] 只在地牢之心周围一圈（3x3 外围）设置为 STONE_FLOOR
	"""
	var center_x = int(map_size.x / 2)
	var center_z = int(map_size.z / 2)
	var level_index = int(MapLevel.LEVEL_0_MAIN)

	LogManager.info("放置地牢之心在位置: (" + str(center_x) + ", " + str(center_z) + ")")

	# 地牢之心本身是2x2：(50,50), (50,51), (51,50), (51,51)
	# 不设置瓦片类型，由 main.gd 创建 DungeonHeart 对象时设置
	
	# 🔧 修改：只在地牢之心周围一圈设置为 STONE_FLOOR
	# 3x3外围：从 (-1,-1) 到 (2,2)，排除地牢之心本身的 2x2 区域
	var floor_count = 0
	for dx in range(-1, 3):
		for dz in range(-1, 3):
			# 排除地牢之心本身的 2x2 区域 [(0,0), (0,1), (1,0), (1,1)]
			if dx >= 0 and dx <= 1 and dz >= 0 and dz <= 1:
				continue
			
			var floor_pos = Vector3(center_x + dx, level_index, center_z + dz)
			_set_tile_type(floor_pos, TileType.STONE_FLOOR)
			floor_count += 1
	
	LogManager.info("✅ 地牢之心周围一圈已设置为石质地面（共 %d 个地块）" % floor_count)


func _create_tile_object(tile_data: TileInfo):
	"""创建地块的3D对象（优化版本：UNEXCAVATED使用简化渲染）"""
	var level_index = int(tile_data.level)
	var x = int(tile_data.position.x)
	var z = int(tile_data.position.z)

	# 添加边界检查
	if level_index < 0 or level_index >= tile_objects.size():
		return
	if x < 0 or x >= tile_objects[level_index].size():
		return
	if z < 0 or z >= tile_objects[level_index][x].size():
		return

	# 如果已经有对象，先删除
	if tile_objects[level_index][x][z] != null:
		tile_objects[level_index][x][z].queue_free()

	# 检查是否在图形模式下运行
	if not OS.has_feature("headless"):
		var tile_object = null
		
		# 🔧 地牢之心瓦片不渲染（由DungeonHeart对象统一渲染），但需要碰撞体和交互区域
		if tile_data.type == TileType.DUNGEON_HEART:
			# 创建一个空节点，只用于挂载碰撞体和交互区域
			tile_object = Node3D.new()
			tile_object.name = (
				"DungeonHeartTile_"
				+ str(tile_data.position.x)
				+"_"
				+ str(tile_data.position.z)
			)
			tile_object.position = Vector3(tile_data.position.x + 0.5, 0, tile_data.position.z + 0.5)
			
			# 添加碰撞体
			_add_simple_collision(tile_object, tile_data.type)
			
			# 添加交互区域（苦工存放金币）
			_add_tile_interaction_area(tile_object, tile_data.type, tile_data.position)
			
			LogManager.info("🏰 [TileManager] 地牢之心瓦片 (%d, %d) - 只创建碰撞体和交互区域，无渲染" % [
				tile_data.position.x, tile_data.position.z
			])
			
		# UNEXCAVATED类型使用简化的墙体渲染
		elif tile_data.type == TileType.UNEXCAVATED:
			tile_object = _create_simple_wall_mesh(tile_data)
		else:
			# 其他类型使用完整的3D对象
			tile_object = _create_tile_mesh(tile_data)
		
		if tile_object != null:
			dungeon.add_child(tile_object)
			tile_objects[level_index][x][z] = tile_object
			tile_data.tile_object = tile_object


func _create_simple_wall_mesh(tile_data: TileInfo) -> MeshInstance3D:
	"""创建简化的墙体网格（用于UNEXCAVATED类型） - 下沉到Y=0层"""
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = (
		"SimpleWall_"
		+ str(tile_data.position.x)
		+"_"
		+ str(tile_data.position.z)
		+"_"
		+ str(tile_data.level)
	)
	
	# 瓦块渲染位置：墙体中心（格子中心）
	# tile_data.position是格子左下角整数坐标，需要+0.5到格子中心
	mesh_instance.position = Vector3(tile_data.position.x + 0.5, 0.5, tile_data.position.z + 0.5)

	# 使用简单的立方体网格
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(1.0, 1.0, 1.0)
	mesh_instance.mesh = box_mesh

	# 使用简化的材质（类似石墙但更简单）
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.4, 0.4, 0.4, 1.0) # 深灰色
	material.roughness = 0.8
	material.metallic = 0.1
	mesh_instance.material_override = material

	# 添加完整高度的碰撞体
	_add_simple_collision(mesh_instance, tile_data.type)
	
	return mesh_instance


func _create_tile_mesh(tile_data: TileInfo) -> MeshInstance3D:
	"""创建地块网格 - 使用三种渲染原型：全填充/底部填充/特殊填充，且全部下沉到Y=0层"""
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = (
		"Tile_"
		+ str(tile_data.position.x)
		+"_"
		+ str(tile_data.position.z)
		+"_"
		+ str(tile_data.level)
	)
	
	# 瓦块渲染位置（格子中心）
	# tile_data.position是格子的左下角整数坐标（如51, 53）
	# 渲染位置应该是格子中心：(51.5, 0, 53.5)
	# 这样1x1的碰撞体才能正确覆盖整个格子 [51, 52] x [53, 54]
	var render_position = Vector3(tile_data.position.x + 0.5, 0, tile_data.position.z + 0.5)
	mesh_instance.position = render_position

	# 分类渲染
	if _is_full_fill_type(tile_data.type):
		var mesh: Mesh = _create_cube_mesh()
		var material: StandardMaterial3D = null
		match tile_data.type:
			TileType.STONE_WALL:
				material = _create_stone_material()
			TileType.GOLD_MINE:
				material = _create_gold_material()
			TileType.UNEXCAVATED:
				material = _create_unexcavated_material()
			_:
				material = _create_floor_material()
		mesh_instance.mesh = mesh
		mesh_instance.material_override = material
		# 全填充：中心在Y=0.5（底部Y=0，顶部Y=1.0）
		mesh_instance.position.y = 0.5
	elif _is_bottom_fill_type(tile_data.type):
		var mesh2: Mesh = null
		var material2: StandardMaterial3D = null
		match tile_data.type:
			TileType.EMPTY:
				mesh2 = _create_empty_mesh()
				material2 = _create_empty_material()
			TileType.STONE_FLOOR:
				mesh2 = _create_floor_mesh()
				material2 = _create_floor_material()
			TileType.DIRT_FLOOR:
				mesh2 = _create_floor_mesh()
				material2 = _create_dirt_material()
			TileType.MAGIC_FLOOR:
				mesh2 = _create_floor_mesh()
				material2 = _create_magic_material()
			TileType.CORRIDOR:
				mesh2 = _create_floor_mesh()
				material2 = _create_corridor_material()
			TileType.SECRET_PASSAGE:
				mesh2 = _create_floor_mesh()
				material2 = _create_secret_material()
			TileType.TRAP:
				mesh2 = _create_floor_mesh()
				material2 = _create_trap_material()
			_:
				mesh2 = _create_floor_mesh()
				material2 = _create_floor_material()
		mesh_instance.mesh = mesh2
		mesh_instance.material_override = material2
		# 底部填充：地面中心在Y=0.025（底部Y=0，厚度0.05）
		mesh_instance.position.y = 0.025
	else:
		# 特殊填充：底部 + 表层建筑/物件（建筑/设施类、走廊等也会至少有底层）
		var base_mesh: Mesh = _create_floor_mesh()
		var base_material: StandardMaterial3D = _create_floor_material()
		mesh_instance.mesh = base_mesh
		mesh_instance.material_override = base_material
		# 底部薄层：地面中心在Y=0.025（底部Y=0，厚度0.05）
		mesh_instance.position.y = 0.025

		# 表层模型（仅建筑/资源类）
		if _needs_top_overlay(tile_data.type):
			var top_mesh_instance := MeshInstance3D.new()
			top_mesh_instance.position = Vector3(0, 0, 0)
			var top_mesh: Mesh = null
			var top_material: StandardMaterial3D = null
			match tile_data.type:
				TileType.BARRACKS:
					top_mesh = _create_building_mesh()
					top_material = _create_building_material()
				TileType.WORKSHOP:
					top_mesh = _create_building_mesh()
					top_material = _create_workshop_material()
				TileType.MAGIC_LAB:
					top_mesh = _create_building_mesh()
					top_material = _create_lab_material()
				TileType.DEFENSE_TOWER:
					top_mesh = _create_tower_mesh()
					top_material = _create_tower_material()
				TileType.DUNGEON_HEART:
					top_mesh = _create_heart_mesh()
					top_material = _create_heart_material()
				TileType.MANA_CRYSTAL:
					top_mesh = _create_crystal_mesh()
					top_material = _create_crystal_material()
				TileType.FOOD_FARM:
					top_mesh = _create_building_mesh()
					top_material = _create_farm_material()
				_:
					pass
			if top_mesh != null and top_material != null:
				top_mesh_instance.mesh = top_mesh
				top_mesh_instance.material_override = top_material
				# 计算表层中心高度：地面顶部(0.05) + 表层高度/2，相对于瓦块节点(0.5)
				var overlay_height := 0.8
				match tile_data.type:
					TileType.DEFENSE_TOWER, TileType.DUNGEON_HEART:
						overlay_height = 1.0
					TileType.MANA_CRYSTAL:
						overlay_height = 0.8
					TileType.FOOD_FARM, TileType.BARRACKS, TileType.WORKSHOP, TileType.MAGIC_LAB:
						overlay_height = 0.8
				# 建筑表层：底部在地面顶部(0.05)，相对于mesh_instance(0.025)的偏移
				# 建筑底部世界Y = 0.05，建筑中心世界Y = 0.05 + overlay_height/2
				# mesh_instance世界Y = 0.025
				# top_mesh相对偏移 = (0.05 + overlay_height/2) - 0.025 = 0.025 + overlay_height/2
				top_mesh_instance.position.y = 0.025 + overlay_height * 0.5
				mesh_instance.add_child(top_mesh_instance)

		# 根据瓦片类型添加合适的碰撞体
		_add_simple_collision(mesh_instance, tile_data.type)
	
	# [新增] 为需要交互的瓦块添加交互区域（Area3D）
	if _needs_interaction_area(tile_data.type):
		_add_tile_interaction_area(mesh_instance, tile_data.type, tile_data.position)

	return mesh_instance


# ===== 分类辅助函数 =====
func _is_full_fill_type(tile_type: int) -> bool:
	# 全填充：墙体与实体矿点
	return (
		tile_type == TileType.STONE_WALL or
		tile_type == TileType.GOLD_MINE or
		tile_type == TileType.UNEXCAVATED
	)


func _is_bottom_fill_type(tile_type: int) -> bool:
	# 底部填充：所有地面类型
	return (
		tile_type == TileType.STONE_FLOOR or
		tile_type == TileType.EMPTY or
		tile_type == TileType.DIRT_FLOOR or
		tile_type == TileType.MAGIC_FLOOR or
		tile_type == TileType.CORRIDOR or
		tile_type == TileType.SECRET_PASSAGE or
		tile_type == TileType.TRAP
	)


func _needs_top_overlay(tile_type: int) -> bool:
	# 为建筑/资源类添加表层：兵营/工坊/魔法实验室/防御塔/地牢之心/水晶/农场
	return (
		tile_type == TileType.BARRACKS or
		tile_type == TileType.WORKSHOP or
		tile_type == TileType.MAGIC_LAB or
		tile_type == TileType.DEFENSE_TOWER or
		tile_type == TileType.DUNGEON_HEART or
		tile_type == TileType.MANA_CRYSTAL or
		tile_type == TileType.FOOD_FARM
	)

func _needs_interaction_area(tile_type: int) -> bool:
	"""判断瓦块是否需要交互区域（Area3D）
	
	需要交互的瓦块：
	- 金矿：苦工采矿
	- 魔力水晶：采集魔力
	- 食物农场：收获食物
	- 地牢之心：苦工存放金币
	"""
	return (
		tile_type == TileType.GOLD_MINE or
		tile_type == TileType.MANA_CRYSTAL or
		tile_type == TileType.FOOD_FARM or
		tile_type == TileType.DUNGEON_HEART
	)


func _add_simple_collision(tile_node: Node3D, tile_type: TileType = TileType.STONE_FLOOR):
	"""根据瓦片类型添加合适的碰撞体
	
	[物理迁移] 配置物理层和掩码，集成Godot标准物理系统
	[修复] 可通行地块不添加碰撞体，避免与角色胶囊体底部冲突
	[方案C] 金矿有碰撞体(1x1)阻挡Worker，Area3D(1.4x1.4)覆盖相邻格子
	"""
	# [修复] 可通行地块不需要碰撞体（角色可自由移动）
	# 原因：
	# 1. 俯视角游戏，角色Y坐标固定在0.05
	# 2. 可通行性由is_walkable控制（寻路系统使用）
	# 3. 地面碰撞体(0.05高)会与角色胶囊体底部(-0.046)重叠，导致持续碰撞
	# 4. 物理碰撞只用于真正的阻挡物（墙壁、建筑）
	if _is_walkable_floor_type(tile_type):
		return # 不添加碰撞体
	
	# 创建静态体
	var static_body = StaticBody3D.new()
	static_body.name = "TileCollision"
	
	# [物理迁移] 配置物理层和掩码
	# 物理层定义：
	# - Layer 1: 环境层（墙壁、地形）
	# - Layer 2: 单位层（角色）
	# - Layer 3: 资源层（金矿、水晶）
	# - Layer 4: 建筑层
	
	# 清空所有层
	static_body.collision_layer = 0
	static_body.collision_mask = 0
	
	# 🔧 [方案C] 设置碰撞层（修正后的层级）
	# Layer 1: 环境层（墙壁、地形、金矿等不可穿越物体）
	# Layer 2: 玩家单位层（Worker、Engineer）
	# Layer 3: 敌方单位层（Hero）
	# Layer 4: 建筑层（DungeonHeart、Treasury等）
	if _is_building_type(tile_type):
		# 建筑使用建筑层（第4层）
		static_body.set_collision_layer_value(4, true)
	else:
		# 墙壁、地形、资源（金矿）都使用环境层（第1层）
		# 金矿应该像墙壁一样阻挡移动，Worker站在旁边通过Area3D交互
		static_body.set_collision_layer_value(1, true)
	
	# 环境和建筑都不主动检测其他物体（被动碰撞，mask保持为0）
	
	# 创建碰撞形状
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	
	# 根据瓦片类型设置碰撞高度
	var collision_height = _get_collision_height_for_type(tile_type)
	box_shape.size = Vector3(tile_size.x, collision_height, tile_size.z)
	
	# 🔍 调试：地牢之心和石墙碰撞体
	# 设置碰撞体层
	
	collision_shape.shape = box_shape
	
	# 调整碰撞体位置（相对于tile_node）
	# 新坐标系：地面底部Y=0
	# 墙体tile_node在Y=0.5，地面tile_node在Y=0.025
	# 碰撞体应该让底部对齐地面底部Y=0
	if _is_full_fill_type(tile_type):
		# 墙体：tile_node在Y=0.5，碰撞体中心也在Y=0.5（相对偏移=0）
		collision_shape.position.y = 0.0
	else:
		# 地面和建筑：tile_node在Y=0.025（地面mesh中心）
		# 碰撞体应该从Y=0开始，中心在Y=collision_height/2
		# 相对于tile_node的偏移 = collision_height/2 - 0.025
		collision_shape.position.y = collision_height / 2.0 - 0.025
	
	static_body.add_child(collision_shape)
	tile_node.add_child(static_body)

func _add_tile_interaction_area(tile_node: Node3D, tile_type: TileType, tile_position: Vector3):
	"""为瓦块添加交互区域（Area3D）
	
	🔧 [方案C] Area3D主动查询系统
	- Area3D = 1.4x1.4，比碰撞体(1x1)稍大，覆盖相邻格子边缘
	- Worker站在金矿旁边（相邻格子）自然进入Area3D
	- 使用get_overlapping_bodies()主动查询，无需信号连接
	- collision_layer=0确保不阻挡移动（只监测，不碰撞）
	"""
	var interaction_area = Area3D.new()
	
	# [关键] 启用监控和检测
	interaction_area.monitoring = true # 启用监控（检测进入的物体）
	interaction_area.monitorable = false # 不需要被其他 Area 检测
	
	# 根据瓦块类型设置交互范围和名称
	var interaction_size: Vector3
	var area_name: String
	var group_name: String
	
	match tile_type:
		TileType.GOLD_MINE:
			# 🔧 [方案C修正] Area3D = 1.4x1.4，比碰撞体(1x1)大0.4米
			# - 金矿有物理碰撞体(1x1)，Worker不能穿过
			# - Area3D覆盖相邻格子边缘（0.2米延伸）
			# - Worker站在相邻格子(0.5米外)自然进入Area3D
			interaction_size = Vector3(1.4, 1.0, 1.4)
			area_name = "MiningInteractionArea"
			group_name = GameGroups.MINING_ZONES
		TileType.MANA_CRYSTAL:
			interaction_size = Vector3(1.4, 1.0, 1.4) # 同金矿
			area_name = "CrystalInteractionArea"
			group_name = GameGroups.RESOURCE_ZONES
		TileType.FOOD_FARM:
			interaction_size = Vector3(1.4, 1.0, 1.4) # 同金矿
			area_name = "FarmInteractionArea"
			group_name = GameGroups.RESOURCE_ZONES
		TileType.DUNGEON_HEART:
			# 地牢之心2x2建筑，Area3D稍大，覆盖周围
			interaction_size = Vector3(1.4, 1.0, 1.4) # 每个瓦片1.4x1.4
			area_name = "DungeonHeartInteractionArea"
			group_name = GameGroups.INTERACTION_ZONES
		_:
			# 默认配置（不应该走到这里）
			interaction_size = Vector3(1.0, 1.0, 1.0)
			area_name = "InteractionArea"
			group_name = GameGroups.RESOURCE_ZONES
	
	interaction_area.name = area_name
	
	# 创建碰撞形状
	var area_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = interaction_size
	area_shape.shape = box_shape
	area_shape.position = Vector3.ZERO # 相对于tile_node的中心
	
	interaction_area.add_child(area_shape)
	tile_node.add_child(interaction_area)
	
	# 🔧 [方案C] 设置碰撞层：Area3D在独立的Layer 5（交互层）
	# - Layer 5 不会被CharacterBody3D的collision_mask检测，因此完全不阻挡移动
	# - Area3D可以监测Layer 2的单位进入
	# - 使用get_overlapping_bodies()主动查询，无需信号
	interaction_area.collision_layer = 0 # 不在任何层（不被其他物体检测）
	interaction_area.collision_mask = 0 # 清空所有掩码
	interaction_area.set_collision_mask_value(2, true) # 只监测单位层（Layer 2）
	
	# ⚠️ 关键：collision_layer=0 确保 CharacterBody3D 无法"碰到"Area3D
	
	# 添加到Group和Meta，便于识别
	interaction_area.add_to_group(group_name)
	interaction_area.set_meta("tile_type", tile_type)
	interaction_area.set_meta("tile_position", tile_position)
	interaction_area.set_meta("tile_world_pos", tile_node.position)
	
	# 特殊Meta（兼容性）
	if tile_type == TileType.GOLD_MINE:
		interaction_area.set_meta("mine_position", tile_position)
		interaction_area.set_meta("mine_world_pos", tile_node.position)
	elif tile_type == TileType.DUNGEON_HEART:
		# 🔧 使用 BuildingTypes autoload 常量
		interaction_area.set_meta("building_type", BuildingTypes.DUNGEON_HEART)
		interaction_area.set_meta("building_position", tile_node.position)

func _get_tile_type_name(tile_type: TileType) -> String:
	"""获取瓦块类型的可读名称（用于调试日志）"""
	match tile_type:
		TileType.EMPTY: return "空地"
		TileType.UNEXCAVATED: return "未挖掘"
		TileType.STONE_WALL: return "石墙"
		TileType.STONE_FLOOR: return "石质地面"
		TileType.DIRT_FLOOR: return "泥土地面"
		TileType.MAGIC_FLOOR: return "魔法地面"
		TileType.GOLD_MINE: return "金矿"
		TileType.MANA_CRYSTAL: return "魔力水晶"
		TileType.FOOD_FARM: return "食物农场"
		TileType.BARRACKS: return "兵营"
		TileType.WORKSHOP: return "工坊"
		TileType.MAGIC_LAB: return "魔法实验室"
		TileType.DEFENSE_TOWER: return "防御塔"
		TileType.TRAP: return "陷阱"
		TileType.CORRIDOR: return "通道"
		TileType.SECRET_PASSAGE: return "秘密通道"
		TileType.DUNGEON_HEART: return "地牢之心"
		_: return "未知类型"

func _is_walkable_floor_type(tile_type: TileType) -> bool:
	"""判断是否为可通行地面类型（不需要碰撞体）"""
	return (
		tile_type == TileType.EMPTY or
		tile_type == TileType.STONE_FLOOR or
		tile_type == TileType.DIRT_FLOOR or
		tile_type == TileType.MAGIC_FLOOR or
		tile_type == TileType.CORRIDOR or
		tile_type == TileType.TRAP or
		tile_type == TileType.SECRET_PASSAGE
	)

func _is_resource_type(tile_type: TileType) -> bool:
	"""判断是否为资源类型（金矿、魔力水晶等）"""
	return (
		tile_type == TileType.GOLD_MINE or
		tile_type == TileType.MANA_CRYSTAL
	)

func _is_building_type(tile_type: TileType) -> bool:
	"""判断是否为建筑类型"""
	return (
		tile_type == TileType.BARRACKS or
		tile_type == TileType.WORKSHOP or
		tile_type == TileType.MAGIC_LAB or
		tile_type == TileType.DEFENSE_TOWER or
		tile_type == TileType.DUNGEON_HEART or
		tile_type == TileType.FOOD_FARM
	)

func _get_collision_height_for_type(tile_type: TileType) -> float:
	"""获取瓦片类型对应的碰撞高度（总高度，包括地面）"""
	match tile_type:
		TileType.UNEXCAVATED, TileType.STONE_WALL, TileType.GOLD_MINE:
			return 1.0 # 完整立方体
		TileType.DEFENSE_TOWER, TileType.DUNGEON_HEART:
			return 1.05 # 建筑高度1.0 + 地面0.05
		TileType.BARRACKS, TileType.WORKSHOP, TileType.MAGIC_LAB, \
		TileType.MANA_CRYSTAL, TileType.FOOD_FARM:
			return 0.85 # 建筑高度0.8 + 地面0.05
		TileType.STONE_FLOOR, TileType.DIRT_FLOOR, TileType.EMPTY, \
		TileType.CORRIDOR, TileType.MAGIC_FLOOR, TileType.SECRET_PASSAGE, TileType.TRAP:
			return 0.05 # 地面薄层（匹配渲染高度）
		_:
			return 0.5 # 默认高度


# 网格创建函数 - 重新设计，所有渲染下沉到Y=0层
func _create_cube_mesh() -> BoxMesh:
	"""创建立方体瓦块 - 用于墙体等实体瓦块"""
	var mesh = BoxMesh.new()
	mesh.size = tile_size
	return mesh


func _create_floor_mesh() -> BoxMesh:
	"""创建地面瓦块 - 薄层渲染，下沉到Y=0层"""
	var mesh = BoxMesh.new()
	mesh.size = Vector3(tile_size.x, 0.05, tile_size.z) # 更薄的薄层
	return mesh


func _create_empty_mesh() -> BoxMesh:
	"""创建空心瓦块 - EMPTY类型，只渲染底部薄层"""
	var mesh = BoxMesh.new()
	# 只渲染底部薄层
	mesh.size = Vector3(tile_size.x, 0.05, tile_size.z) # 底部薄层
	return mesh


func _create_crystal_mesh() -> BoxMesh:
	"""创建水晶瓦块 - 下沉到Y=0层"""
	var mesh = BoxMesh.new()
	mesh.size = Vector3(tile_size.x * 0.8, tile_size.y * 0.8, tile_size.z * 0.8) # 降低高度
	return mesh


func _create_building_mesh() -> BoxMesh:
	"""创建建筑瓦块 - 下沉到Y=0层"""
	var mesh = BoxMesh.new()
	mesh.size = Vector3(tile_size.x * 0.9, tile_size.y * 0.8, tile_size.z * 0.9) # 降低高度
	return mesh


func _create_tower_mesh() -> BoxMesh:
	"""创建塔楼瓦块 - 下沉到Y=0层"""
	var mesh = BoxMesh.new()
	mesh.size = Vector3(tile_size.x * 0.6, tile_size.y * 1.0, tile_size.z * 0.6) # 降低高度
	return mesh


func _create_heart_mesh() -> BoxMesh:
	"""创建地牢之心瓦块 - 下沉到Y=0层"""
	var mesh = BoxMesh.new()
	mesh.size = Vector3(tile_size.x * 1.8, tile_size.y * 1.0, tile_size.z * 1.8) # 降低高度
	return mesh


# 材质创建函数
func _create_basic_material(color: Color, roughness: float = 0.8, metallic: float = 0.0, emission: Color = Color.BLACK, emission_energy: float = 0.0) -> StandardMaterial3D:
	"""创建基础材质的通用函数"""
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	if emission != Color.BLACK:
		material.emission = emission
		material.emission_energy = emission_energy
	return material


func _create_empty_material() -> StandardMaterial3D:
	"""创建EMPTY类型材质 - 底部薄层效果"""
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.6, 0.6, 0.7, 0.8) # 半透明浅灰色
	material.roughness = 0.8
	material.metallic = 0.05
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _create_unexcavated_material() -> StandardMaterial3D:
	return _create_basic_material(Color(0.2, 0.2, 0.25), 0.95, 0.0)


func _create_stone_material() -> StandardMaterial3D:
	return _create_basic_material(Color(0.7, 0.7, 0.75), 0.9, 0.1)


func _create_floor_material() -> StandardMaterial3D:
	return _create_basic_material(Color(0.6, 0.6, 0.7), 0.8, 0.05)


func _create_dirt_material() -> StandardMaterial3D:
	return _create_basic_material(Color(0.4, 0.3, 0.2), 0.9, 0.0)


func _create_magic_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.2, 0.6)
	material.emission = Color(0.1, 0.05, 0.2)
	material.emission_energy = 0.3
	material.roughness = 0.7
	material.metallic = 0.2
	return material


func _create_gold_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.6, 0.2)
	material.roughness = 0.3
	material.metallic = 0.8
	material.emission = Color(0.4, 0.3, 0.1)
	material.emission_energy = 0.2
	return material


func _create_crystal_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.5, 0.9)
	material.emission = Color(0.1, 0.2, 0.4)
	material.emission_energy = 0.8
	material.roughness = 0.1
	material.metallic = 0.3
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.8
	return material


func _create_farm_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.5, 0.2)
	material.roughness = 0.8
	material.metallic = 0.0
	return material


func _create_building_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.4, 0.3)
	material.roughness = 0.7
	material.metallic = 0.2
	return material


func _create_workshop_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.4, 0.35, 0.3)
	material.roughness = 0.6
	material.metallic = 0.4
	material.emission = Color(0.1, 0.05, 0.0)
	material.emission_energy = 0.1
	return material


func _create_lab_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.4, 0.6)
	material.emission = Color(0.05, 0.1, 0.2)
	material.emission_energy = 0.3
	material.roughness = 0.5
	material.metallic = 0.3
	return material


func _create_tower_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.6, 0.5, 0.4)
	material.roughness = 0.8
	material.metallic = 0.3
	return material


func _create_trap_material() -> StandardMaterial3D:
	return _create_basic_material(Color(0.5, 0.2, 0.2), 0.9, 0.1, Color(0.1, 0.0, 0.0), 0.1)


func _create_corridor_material() -> StandardMaterial3D:
	return _create_basic_material(Color(0.4, 0.4, 0.42), 0.8, 0.1)


func _create_secret_material() -> StandardMaterial3D:
	return _create_basic_material(Color(0.2, 0.2, 0.25), 0.9, 0.05)


func _create_heart_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.2, 0.2)
	material.emission = Color(0.4, 0.1, 0.1)
	material.emission_energy = 1.0
	material.roughness = 0.3
	material.metallic = 0.2
	return material


# 高亮效果函数已移除，现在使用独立的高亮系统


# 辅助函数
func _is_center_area(x: int, z: int, radius: int = 5) -> bool:
	"""检查是否是中心区域"""
	var center_x = int(map_size.x / 2)
	var center_z = int(map_size.z / 2)
	return abs(x - center_x) <= radius and abs(z - center_z) <= radius


func _is_border(x: int, z: int) -> bool:
	"""检查是否是边界"""
	return x == 0 or x == map_size.x - 1 or z == 0 or z == map_size.z - 1


func _is_valid_resource_position(pos: Vector3) -> bool:
	"""检查是否是有效的资源位置"""
	# 确保资源点之间有足够的距离
	var min_distance = 3 # 降低距离要求
	var level_index = int(pos.y)

	# 检查level_index是否有效
	if level_index < 0 or level_index >= tiles.size():
		return false

	for dx in range(-min_distance, min_distance + 1):
		for dz in range(-min_distance, min_distance + 1):
			var check_x = int(pos.x) + dx
			var check_z = int(pos.z) + dz

			if check_x >= 0 and check_x < map_size.x and check_z >= 0 and check_z < map_size.z:
				# 检查数组访问是否安全
				if check_x < tiles[level_index].size() and check_z < tiles[level_index][check_x].size():
					var check_tile = tiles[level_index][check_x][check_z]
					if (
						check_tile != null
						and (
							check_tile.type == TileType.GOLD_MINE
							or check_tile.type == TileType.MANA_CRYSTAL
							or check_tile.type == TileType.FOOD_FARM
						)
					):
						return false

	return true


# 公共接口函数
func get_tile_data(position: Vector3) -> TileInfo:
	"""获取指定位置的地块数据"""
	var level_index = int(position.y)
	var x = int(position.x)
	var z = int(position.z)

	if (
		level_index >= 0
		and level_index < map_size.y
		and x >= 0
		and x < map_size.x
		and z >= 0
		and z < map_size.z
	):
		return tiles[level_index][x][z]

	return null


func get_tile_type(position: Vector3) -> TileType:
	"""获取指定位置的地块类型"""
	var tile_data = get_tile_data(position)
	if tile_data != null:
		return tile_data.type
	return TileType.EMPTY


func set_tile_type(position: Vector3, tile_type: TileType) -> bool:
	"""设置指定位置的地块类型"""
	var level_index = int(position.y)
	var x = int(position.x)
	var z = int(position.z)

	if (
		level_index >= 0
		and level_index < map_size.y
		and x >= 0
		and x < map_size.x
		and z >= 0
		and z < map_size.z
	):
		var tile_data = tiles[level_index][x][z]
		if tile_data != null:
			# 检查是否需要更新类型，避免重复创建相同类型的瓦片
			if tile_data.type != tile_type:
				tile_data.type = tile_type
				tile_data._update_properties()
				_create_tile_object(tile_data)
				
				# 🔧 [AStarGrid重构] 通知GridPathFinder更新格子状态
				var grid_pos = Vector2i(x, z)
				if GridPathFinder and GridPathFinder.is_ready():
					GridPathFinder.set_cell_walkable(grid_pos, tile_data.is_walkable)
			return true

	return false


func _set_tile_type(position: Vector3, tile_type: TileType):
	"""内部设置地块类型（不检查边界）"""
	var level_index = int(position.y)
	var x = int(position.x)
	var z = int(position.z)

	# 添加边界检查
	if level_index < 0 or level_index >= tiles.size():
		return
	if x < 0 or x >= tiles[level_index].size():
		return
	if z < 0 or z >= tiles[level_index][x].size():
		return

	if tiles[level_index][x][z] != null:
		# 检查是否需要更新类型，避免重复创建相同类型的瓦片
		if tiles[level_index][x][z].type != tile_type:
			tiles[level_index][x][z].type = tile_type
			tiles[level_index][x][z]._update_properties()
			_create_tile_object(tiles[level_index][x][z])


func clear_all_tiles():
	"""清除所有地块"""
	LogManager.info("清除所有地块...")
	
	# 清除所有3D对象
	for level in range(tile_objects.size()):
		for x in range(tile_objects[level].size()):
			for z in range(tile_objects[level][x].size()):
				var tile_obj = tile_objects[level][x][z]
				if tile_obj and is_instance_valid(tile_obj):
					tile_obj.queue_free()
				tile_objects[level][x][z] = null
	
	# 重新初始化地图结构
	_initialize_map_structure()
	
	LogManager.info("所有地块已清除")


func _get_tile_type(position: Vector3) -> TileType:
	"""内部获取地块类型（不检查边界）"""
	var level_index = int(position.y)
	var x = int(position.x)
	var z = int(position.z)

	# 添加边界检查
	if level_index < 0 or level_index >= tiles.size():
		return TileType.EMPTY
	if x < 0 or x >= tiles[level_index].size():
		return TileType.EMPTY
	if z < 0 or z >= tiles[level_index][x].size():
		return TileType.EMPTY

	if tiles[level_index][x][z] != null:
		return tiles[level_index][x][z].type
	return TileType.EMPTY


func is_walkable(position: Vector3) -> bool:
	"""检查位置是否可通行"""
	var tile_data = get_tile_data(position)
	if tile_data != null:
		return tile_data.is_walkable
	return false

func is_reachable(position: Vector3) -> bool:
	"""检查位置是否从地牢之心可达"""
	var tile_data = get_tile_data(position)
	if tile_data != null:
		return tile_data.is_reachable
	return false

func debug_reachability_at(position: Vector3) -> void:
	"""调试：输出指定位置的可达性信息"""
	var tile_data = get_tile_data(position)
	# 检查地块可达性

func update_tile_reachability():
	"""更新所有地块的可达性标记（从地牢之心开始洪水填充）"""
	LogManager.info("🔄 [TileManager] 更新地块可达性...")
	
	# 1. 重置所有地块的可达性
	for level in tiles:
		for row in level:
			for tile_data in row:
				if tile_data:
					tile_data.is_reachable = false
	
	# 2. 从地牢之心开始洪水填充
	var reachable_positions = _flood_fill_from_dungeon_heart()
	
	# 3. 标记可达地块
	for grid_pos in reachable_positions:
		var world_pos = Vector3(grid_pos.x, 0, grid_pos.y)
		var tile_data = get_tile_data(world_pos)
		if tile_data:
			tile_data.is_reachable = true
	
	LogManager.info("✅ [TileManager] 可达性更新完成，可达地块数: %d" % reachable_positions.size())
	
	return reachable_positions.size()

func _flood_fill_from_dungeon_heart() -> Dictionary:
	"""从地牢之心开始洪水填充，返回所有可达位置
	
	返回：Dictionary {Vector2i -> true}
	"""
	var reachable: Dictionary = {}
	var queue: Array[Vector2i] = []
	
	# 找到地牢之心位置（地图中心）
	var dungeon_heart_x = int(map_size.x / 2)
	var dungeon_heart_z = int(map_size.z / 2)
	
	# 从地牢之心周围9x9区域开始（地牢之心是2x2建筑）
	for dx in range(-4, 5):
		for dz in range(-4, 5):
			var start_pos = Vector2i(dungeon_heart_x + dx, dungeon_heart_z + dz)
			
			# 检查边界
			if start_pos.x < 0 or start_pos.x >= map_size.x:
				continue
			if start_pos.y < 0 or start_pos.y >= map_size.z:
				continue
			
			# 检查是否可通行
			var world_pos = Vector3(start_pos.x, 0, start_pos.y)
			if is_walkable(world_pos):
				queue.append(start_pos)
				reachable[start_pos] = true
	
	# 8个方向
	var directions = [
		Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1),
		Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)
	]
	
	# BFS
	while not queue.is_empty():
		var current = queue.pop_front()
		
		for dir in directions:
			var next_pos = current + dir
			
			# 跳过已访问
			if reachable.has(next_pos):
				continue
			
			# 检查边界
			if next_pos.x < 0 or next_pos.x >= map_size.x or next_pos.y < 0 or next_pos.y >= map_size.z:
				continue
			
			# 检查可通行
			var world_pos = Vector3(next_pos.x, 0, next_pos.y)
			if is_walkable(world_pos):
				reachable[next_pos] = true
				queue.append(next_pos)
	
	return reachable


func is_buildable(position: Vector3) -> bool:
	"""检查位置是否可建造"""
	var tile_data = get_tile_data(position)
	if tile_data != null:
		return tile_data.is_buildable
	return false


func is_diggable(position: Vector3) -> bool:
	"""检查位置是否可挖掘"""
	var tile_data = get_tile_data(position)
	if tile_data != null:
		return tile_data.is_diggable
	return false


func is_summonable(position: Vector3) -> bool:
	"""检查位置是否可以召唤单位（怪物或后勤）"""
	var tile_data = get_tile_data(position)
	if tile_data == null:
		return false
	
	# 允许召唤的瓦片类型：EMPTY，STONE_FLOOR，DIRT_FLOOR，MAGIC_FLOOR
	match tile_data.type:
		TileType.EMPTY:
			return true
		TileType.STONE_FLOOR:
			return true
		TileType.DIRT_FLOOR:
			return true
		TileType.MAGIC_FLOOR:
			return true
		_:
			return false


func get_map_size() -> Vector3:
	"""获取地图尺寸"""
	return map_size


func get_tile_size() -> Vector3:
	"""获取地块尺寸"""
	return tile_size


func set_tile_highlight_option(position: Vector3, highlight_option: TileHighlightOption):
	"""设置瓦块的高亮选项"""
	var tile_data = get_tile_data(position)
	if tile_data != null:
		tile_data.highlight_option = highlight_option
		# 更新状态以保持兼容性
		tile_data.state = TileState.HIGHLIGHTED if highlight_option != TileHighlightOption.NONE else TileState.NORMAL
		_create_tile_object(tile_data) # 重新创建对象以应用高亮效果


func update_tile_highlight(position: Vector3, highlighted: bool):
	"""更新地块高亮状态（兼容性函数，内部调用set_tile_highlight_option）"""
	var highlight_option = TileHighlightOption.NONE if not highlighted else TileHighlightOption.GREEN
	set_tile_highlight_option(position, highlight_option)


func get_tile_highlight_option(position: Vector3) -> TileHighlightOption:
	"""获取瓦块的高亮选项"""
	var tile_data = get_tile_data(position)
	if tile_data != null:
		return tile_data.highlight_option
	return TileHighlightOption.NONE


func clear_tile_highlight(position: Vector3):
	"""清除瓦块的高亮效果"""
	set_tile_highlight_option(position, TileHighlightOption.NONE)


func clear_all_highlights():
	"""清除所有瓦块的高亮效果"""
	for _level in range(tiles.size()):
		for _x in range(tiles[_level].size()):
			for _z in range(tiles[_level][_x].size()):
				var tile_data = tiles[_level][_x][_z]
				if tile_data != null and tile_data.highlight_option != TileHighlightOption.NONE:
					tile_data.highlight_option = TileHighlightOption.NONE
					_create_tile_object(tile_data)


func get_neighboring_tiles(position: Vector3, include_diagonal: bool = false) -> Array:
	"""获取相邻地块"""
	var neighbors = []
	# 注：坐标变量供后续调试使用（如需要）
	var _level_index = int(position.y)
	var _x = int(position.x)
	var _z = int(position.z)

	var directions = [Vector3(-1, 0, 0), Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(0, 0, 1)]

	if include_diagonal:
		directions.append_array(
			[Vector3(-1, 0, -1), Vector3(-1, 0, 1), Vector3(1, 0, -1), Vector3(1, 0, 1)]
		)

	for direction in directions:
		var neighbor_pos = position + direction
		var neighbor_tile = get_tile_data(neighbor_pos)
		if neighbor_tile != null:
			neighbors.append(neighbor_tile)

	return neighbors


func get_tiles_of_type(tile_type: TileType, level: MapLevel = MapLevel.LEVEL_0_MAIN) -> Array:
	"""获取指定类型的所有地块"""
	var result = []
	var level_index = int(level)

	for x in range(map_size.x):
		for z in range(map_size.z):
			var tile_data = tiles[level_index][x][z]
			if tile_data != null and tile_data.type == tile_type:
				result.append(tile_data)

	return result


func get_tiles_in_radius(
	center: Vector3, radius: int, level: MapLevel = MapLevel.LEVEL_0_MAIN
) -> Array:
	"""获取指定半径内的所有地块"""
	var result = []
	var _level_index = int(level)

	for dx in range(-radius, radius + 1):
		for dz in range(-radius, radius + 1):
			if dx * dx + dz * dz <= radius * radius:
				var pos = Vector3(center.x + dx, center.y, center.z + dz)
				var tile_data = get_tile_data(pos)
				if tile_data != null:
					result.append(tile_data)

	return result


func get_resource_manager() -> Node:
	"""获取资源管理器"""
	# 这里将返回资源管理器的引用
	# 暂时返回null，实际实现时需要正确获取引用
	return null


func cleanup():
	"""清理资源，防止内存泄漏"""
	LogManager.info("TileManager - 开始清理资源")
	
	# 清理所有3D对象
	for level in range(tile_objects.size()):
		for x in range(tile_objects[level].size()):
			for z in range(tile_objects[level][x].size()):
				var tile_obj = tile_objects[level][x][z]
				if tile_obj != null and is_instance_valid(tile_obj):
					tile_obj.queue_free()
				tile_objects[level][x][z] = null
	
	# 清空数组
	tile_objects.clear()
	tiles.clear()
	
	LogManager.info("TileManager - 资源清理完成")


func is_position_walkable(grid_position: Vector2i) -> bool:
	"""检查网格位置是否可通行（用于路径规划）"""
	# 检查是否在地图范围内
	if grid_position.x < 0 or grid_position.x >= map_size.x or grid_position.y < 0 or grid_position.y >= map_size.z:
		return false
	
	# 将Vector2i转换为Vector3进行检查
	var world_position = Vector3(grid_position.x, 0, grid_position.y)
	return is_walkable(world_position)


func get_walkable_neighbors(grid_position: Vector2i) -> Array[Vector2i]:
	"""获取可通行的相邻位置"""
	var neighbors: Array[Vector2i] = []
	var directions = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0), Vector2i(1, 0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)
	]
	
	for direction in directions:
		var neighbor_pos = grid_position + direction
		if is_position_walkable(neighbor_pos):
			neighbors.append(neighbor_pos)
	
	return neighbors


func set_tile_building_ref(position: Vector3, building: Node) -> bool:
	"""设置瓦片的建筑引用（用于2x2等多瓦片建筑）
	
	参数：
		position: 瓦片位置
		building: 建筑对象（如DungeonHeart）
	返回：
		是否设置成功
	"""
	var tile_data = get_tile_data(position)
	if tile_data:
		tile_data.building_ref = building
		return true
	return false

func get_tile_building_ref(position: Vector3) -> Node:
	"""获取瓦片的建筑引用
	
	参数：
		position: 瓦片位置
	返回：
		建筑对象，如果没有则返回null
	"""
	var tile_data = get_tile_data(position)
	if tile_data:
		return tile_data.building_ref
	return null

func _exit_tree():
	"""节点退出时自动清理"""
	cleanup()
