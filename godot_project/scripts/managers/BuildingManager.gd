extends Node
class_name BuildingManager

# 建筑系统管理器 - 负责所有建筑的创建、管理和维护
# 参考 BUILDING_SYSTEM.md

# 🔧 使用autoload中的枚举类型
# BuildingType 和 BuildingStatus 现在从 BuildingTypes autoload 获取

# 建筑配置类
class BuildingManagerConfig:
	var building_type: BuildingTypes.BuildingType
	var name: String
	var cost_gold: int
	var engineer_cost: int # 工程师建造成本（建筑成本的一半）
	var build_time: float # 建造时间（秒）
	var engineer_required: int # 所需工程师数量
	var health: int
	var max_health: int
	var armor: int
	var color: Color
	var size: Vector2
	var building_level: int # 建筑等级（星级）
	var placement_type: String # 放置类型
	var can_place_on: Array[String] # 可放置的地形类型
	
	func _init(type: BuildingTypes.BuildingType, n: String, cost: int, time: float, eng_req: int,
		hp: int, arm: int, col: Color, sz: Vector2, level: int, p_type: String, terrain: Array[String]):
		building_type = type
		name = n
		cost_gold = cost
		engineer_cost = cost / 2 # 工程师成本为建筑成本的一半
		build_time = time
		engineer_required = eng_req
		health = hp
		max_health = hp
		armor = arm
		color = col
		size = sz
		building_level = level
		placement_type = p_type
		can_place_on = terrain

# 注意：Building 类已移至 res://scripts/characters/Building.gd
# 所有建筑现在使用3D版本（如 DungeonHeart3D, Treasury3D 等）
# 这里保留 BuildingManagerConfig 类用于建筑配置

# 系统引用
var main_game: Node = null
var tile_manager = null # TileManager (global class)
var character_manager = null # CharacterManager (global class)
var resource_manager = null # ResourceManager (global class)

# 建筑数据
var buildings: Array = [] # Array of Building objects
var building_configs: Dictionary = {}
var next_building_id: int = 1

func _ready():
	"""初始化建筑管理器"""
	_initialize_building_configs()

func _initialize_building_configs():
	"""初始化建筑配置"""
	# 地牢之心
	building_configs[BuildingTypes.BuildingType.DUNGEON_HEART] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.DUNGEON_HEART, "地牢之心", 0, 0, 0,
		1000, 10, Color(0.545, 0.0, 0.0), Vector2(40, 40), 5,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 金库
	building_configs[BuildingTypes.BuildingType.TREASURY] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.TREASURY, "金库", 100, 60, 1,
		200, 5, Color(1.0, 0.843, 0.0), Vector2(20, 20), 2,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 恶魔巢穴
	building_configs[BuildingTypes.BuildingType.DEMON_LAIR] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.DEMON_LAIR, "恶魔巢穴", 200, 180, 1,
		450, 6, Color(0.294, 0.0, 0.510), Vector2(20, 20), 4,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 兽人巢穴
	building_configs[BuildingTypes.BuildingType.ORC_LAIR] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.ORC_LAIR, "兽人巢穴", 200, 150, 1,
		500, 6, Color(0.545, 0.271, 0.075), Vector2(20, 20), 3,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 训练室
	building_configs[BuildingTypes.BuildingType.TRAINING_ROOM] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.TRAINING_ROOM, "训练室", 200, 120, 1,
		300, 6, Color(0.439, 0.502, 0.565), Vector2(30, 30), 3,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 图书馆
	building_configs[BuildingTypes.BuildingType.LIBRARY] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.LIBRARY, "图书馆", 250, 150, 1,
		200, 5, Color(0.098, 0.098, 0.439), Vector2(28, 28), 3,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 箭塔
	building_configs[BuildingTypes.BuildingType.ARROW_TOWER] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.ARROW_TOWER, "箭塔", 200, 100, 1,
		800, 5, Color(0.827, 0.827, 0.827), Vector2(15, 35), 3,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 奥术塔
	building_configs[BuildingTypes.BuildingType.ARCANE_TOWER] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.ARCANE_TOWER, "奥术塔", 200, 100, 1,
		800, 5, Color(0.541, 0.169, 0.886), Vector2(15, 35), 3,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 魔法祭坛
	building_configs[BuildingTypes.BuildingType.MAGIC_ALTAR] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.MAGIC_ALTAR, "魔法祭坛", 120, 160, 1,
		300, 4, Color(0.0, 0.502, 0.502), Vector2(20, 20), 4,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 工坊
	building_configs[BuildingTypes.BuildingType.WORKSHOP] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.WORKSHOP, "工坊", 300, 180, 2,
		250, 6, Color(0.502, 0.251, 0.0), Vector2(25, 25), 3,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 暗影神殿
	building_configs[BuildingTypes.BuildingType.SHADOW_TEMPLE] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.SHADOW_TEMPLE, "暗影神殿", 800, 300, 3,
		500, 8, Color(0.051, 0.051, 0.051), Vector2(32, 32), 5,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 魔法研究院
	building_configs[BuildingTypes.BuildingType.MAGIC_RESEARCH_INSTITUTE] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.MAGIC_RESEARCH_INSTITUTE, "魔法研究院", 600, 240, 2,
		350, 6, Color(0.294, 0.0, 0.510), Vector2(28, 28), 4,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 学院
	building_configs[BuildingTypes.BuildingType.ACADEMY] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.ACADEMY, "学院", 400, 200, 2,
		300, 5, Color(0.098, 0.098, 0.439), Vector2(30, 30), 4,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 医院
	building_configs[BuildingTypes.BuildingType.HOSPITAL] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.HOSPITAL, "医院", 350, 180, 2,
		250, 4, Color.WHITE, Vector2(25, 25), 3,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 工厂
	building_configs[BuildingTypes.BuildingType.FACTORY] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.FACTORY, "工厂", 500, 240, 3,
		400, 8, Color(0.502, 0.251, 0.0), Vector2(35, 35), 4,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)
	
	# 市场
	building_configs[BuildingTypes.BuildingType.MARKET] = BuildingManagerConfig.new(
		BuildingTypes.BuildingType.MARKET, "市场", 300, 150, 2,
		200, 4, Color(1.0, 0.843, 0.0), Vector2(30, 30), 3,
		"building", ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR"]
	)

func initialize_systems(main: Node, tile_mgr, char_mgr, res_mgr):
	"""初始化系统引用"""
	main_game = main
	tile_manager = tile_mgr
	character_manager = char_mgr
	resource_manager = res_mgr

func register_building(building: Building):
	"""注册建筑到管理器
	
	建筑应该在场景中创建，然后注册到这里进行管理
	"""
	if building and building not in buildings:
		buildings.append(building)
		building.building_manager = self
		
		# 🔧 [关键修复] 延迟更新GridPathFinder：等待建筑_ready()完成后再更新
		# 原因：DungeonHeart等建筑的tile_positions在_ready()中设置，需要延迟一帧
		call_deferred("_update_pathfinding_for_building", building, false)
		
		# 如果是地牢之心或金库，注册到资源管理器
		if resource_manager:
			match building.building_type:
				BuildingTypes.BuildingType.DUNGEON_HEART:
					resource_manager.register_dungeon_heart(building)
				BuildingTypes.BuildingType.TREASURY:
					resource_manager.register_treasury(building)
		
		# 建筑已注册


func unregister_building(building: Building):
	"""从管理器注销建筑"""
	if building in buildings:
		buildings.erase(building)
		
		# 🔧 [关键修复] 更新GridPathFinder：恢复建筑占用的格子为可通行
		_update_pathfinding_for_building(building, true)
		
		# 从资源管理器移除
		if resource_manager:
			match building.building_type:
				BuildingTypes.BuildingType.DUNGEON_HEART:
					resource_manager.remove_gold_building(building)
					resource_manager.remove_mana_building(building)
				BuildingTypes.BuildingType.TREASURY:
					resource_manager.remove_gold_building(building)
		
		# 建筑已注销

func get_building_by_id(building_id: String):
	"""根据ID获取建筑"""
	for building in buildings:
		if building.building_id == building_id:
			return building
	return null

func get_buildings_by_type(building_type: BuildingTypes.BuildingType) -> Array:
	"""根据类型获取建筑列表"""
	var result: Array = []
	for building in buildings:
		if building.building_type == building_type:
			result.append(building)
	return result

func get_dungeon_heart():
	"""获取地牢之心（主基地）"""
	var hearts = get_buildings_by_type(BuildingTypes.BuildingType.DUNGEON_HEART)
	if hearts.size() > 0:
		var heart = hearts[0]
		return heart
	LogManager.warning("🏰 [BuildingManager] 未找到地牢之心！")
	return null

func get_nearest_treasury(position: Vector3, for_deposit: bool = false):
	"""获取最近的可用金库
	
	🔧 [修复] 支持两种查询模式：
	- for_deposit=false: 查找有金币的金库（供工程师取金币）
	- for_deposit=true: 查找未满的金库（供苦工存金币）
	
	Args:
		position: 查询位置
		for_deposit: 是否用于存储（true=查找未满的金库，false=查找有金币的金库）
	
	Returns:
		最近的金库，如果没有则返回 null
	"""
	var treasuries = get_buildings_by_type(BuildingTypes.BuildingType.TREASURY)
	if treasuries.is_empty():
		return null
	
	var nearest = null
	var min_distance = INF
	
	for treasury in treasuries:
		# 基础验证
		if not is_instance_valid(treasury):
			continue
		# 必须是已完成的金库 (2 = COMPLETED)
		if treasury.status != 2:
			continue
		
		# 根据用途过滤
		if for_deposit:
			# 苦工存金币：查找未满的金库
			if not "stored_gold" in treasury or not "gold_storage_capacity" in treasury:
				continue
			if treasury.stored_gold >= treasury.gold_storage_capacity:
				continue # 金库已满
		else:
			# 工程师取金币：查找有金币的金库
			if not "stored_gold" in treasury or treasury.stored_gold <= 0:
				continue
		
		# 计算距离
		var distance = position.distance_to(treasury.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = treasury
	
	return nearest

func get_building_at_position(pos: Vector3):
	"""根据位置获取建筑"""
	for building in buildings:
		if building.position == pos:
			return building
	return null

func get_nearest_building_needing_work(pos: Vector3, max_distance: float = 100.0):
	"""获取最近需要工作的建筑"""
	var nearest_building = null
	var nearest_distance: float = max_distance
	
	for building in buildings:
		var distance = pos.distance_to(building.position)
		if distance > max_distance:
			continue
		
		# 检查建筑是否需要工作
		var needs_work = false
		# 🔧 修复：直接使用整数值比较
		match building.status:
			0, 1: # PLANNING=0, UNDER_CONSTRUCTION=1
				needs_work = true
			2: # COMPLETED=2
				needs_work = building.needs_repair()
			_:
				needs_work = false
		
		if needs_work and distance < nearest_distance:
			nearest_building = building
			nearest_distance = distance
	
	return nearest_building

func assign_engineer_to_building(engineer, building) -> bool:
	"""将工程师分配到建筑（委托给建筑对象）"""
	if not building or not engineer:
		return false
	
	return building.assign_engineer(engineer)

func remove_engineer_from_building(engineer, building):
	"""从建筑移除工程师（委托给建筑对象）"""
	if not building or not engineer:
		return
	
	building.remove_engineer(engineer)

func get_all_buildings() -> Array:
	"""获取所有建筑"""
	return buildings

func get_building_count() -> int:
	"""获取建筑数量"""
	return buildings.size()

func get_building_config(building_type: BuildingTypes.BuildingType) -> BuildingManagerConfig:
	"""获取建筑配置"""
	return building_configs.get(building_type)

func get_available_building_types() -> Array:
	"""获取可用的建筑类型"""
	return building_configs.keys()

func destroy_building(building):
	"""销毁建筑（委托给建筑对象和注销）"""
	if not building:
		return
	
	# 移除所有分配的工程师
	for engineer in building.assigned_engineers.duplicate():
		building.remove_engineer(engineer)
	
	# 调用建筑的销毁逻辑
	building._on_destroyed()
	
	# 从管理器注销
	unregister_building(building)
	
	# 建筑已销毁

func update_buildings(delta: float):
	"""更新所有建筑（委托给建筑对象）"""
	for building in buildings:
		if building:
			building.update_building(delta)


# ===== 建筑放置系统 =====

func place_building(building_type: BuildingTypes.BuildingType, world_position: Vector3, parent_node: Node = null) -> Node:
	"""放置新建筑（规划状态，需要工程师建造）
	
	🔧 [建造系统] 创建处于PLANNING状态的建筑，等待工程师建造
	
	Args:
		building_type: 建筑类型
		world_position: 世界坐标
		parent_node: 父节点（默认为Main节点）
	
	Returns:
		建筑节点（如果成功）
	"""
	var building = _create_building_instance(building_type)
	if not building:
		LogManager.warning("❌ 未找到建筑类型: %d" % building_type)
		return null
	
	# 🔧 [建筑渲染系统] 设置位置：将格子左下角坐标转换为格子中心坐标
	# world_position 是格子左下角(x, 0, z)
	# 建筑应该放在格子中心(x+0.5, 0.05, z+0.5)
	var building_position = Vector3(
		world_position.x + 0.5,
		0.05, # Y坐标固定在地面表面
		world_position.z + 0.5
	)
	building.global_position = building_position
	# 🔧 修复：直接使用整数值 (0 = PLANNING)
	building.status = 0
	
	# 🔧 [关键修复] 设置建筑占用的网格坐标
	building.tile_x = int(world_position.x)
	building.tile_y = int(world_position.z)
	
	# 添加到场景树
	if not parent_node:
		parent_node = get_tree().root.get_node("Main")
	parent_node.add_child(building)
	
	# 注册到管理器
	register_building(building)
	
	# 🔧 [关键修复] 更新GridPathFinder：将建筑占用的格子标记为不可通行
	_update_pathfinding_for_building(building, false)
	
	# 建筑已放置
	
	return building


func _update_pathfinding_for_building(building: Node, walkable: bool):
	"""更新建筑占用格子的寻路状态
	
	Args:
		building: 建筑对象
		walkable: 是否可通行（false = 阻挡）
	"""
	if not is_instance_valid(building):
		return
	
	# 获取GridPathFinder
	if not GridPathFinder.is_initialized:
		LogManager.warning("GridPathFinder未初始化，无法更新寻路状态")
		return
	
	# 获取建筑占用的所有格子
	var occupied_tiles = []
	
	# 方案1：检查 tile_positions（DungeonHeart 2x2建筑使用）
	if "tile_positions" in building and building.tile_positions:
		for tile_pos in building.tile_positions:
			occupied_tiles.append(Vector2i(int(tile_pos.x), int(tile_pos.z)))
	
	# 方案2：检查 occupied_tiles（其他建筑可能使用）
	elif "occupied_tiles" in building and building.occupied_tiles:
		for tile in building.occupied_tiles:
			occupied_tiles.append(tile)
	
	# 方案3：使用 tile_x, tile_y（1x1建筑）
	elif "tile_x" in building and "tile_y" in building:
		occupied_tiles.append(Vector2i(building.tile_x, building.tile_y))
	
	# 更新所有占用的格子
	for tile in occupied_tiles:
		GridPathFinder.set_cell_walkable(tile, walkable)
		# 更新格子寻路状态

func _create_building_instance(building_type: BuildingTypes.BuildingType) -> Node:
	"""创建建筑实例（根据类型）
	
	🔧 [建造系统] 建筑类型到实例的映射 - 使用3D版本
	"""
	match building_type:
		BuildingTypes.BuildingType.DUNGEON_HEART:
			return DungeonHeart3D.new()
		BuildingTypes.BuildingType.TREASURY:
			return Treasury3D.new()
		BuildingTypes.BuildingType.DEMON_LAIR:
			return DemonLair3D.new()
		BuildingTypes.BuildingType.ORC_LAIR:
			return OrcLair3D.new()
		BuildingTypes.BuildingType.TRAINING_ROOM:
			return Barracks3D.new()
		BuildingTypes.BuildingType.LIBRARY:
			return Library3D.new()
		BuildingTypes.BuildingType.WORKSHOP:
			return Workshop3D.new()
		BuildingTypes.BuildingType.ACADEMY:
			return Academy3D.new()
		BuildingTypes.BuildingType.HOSPITAL:
			return Hospital3D.new()
		BuildingTypes.BuildingType.FACTORY:
			return Factory3D.new()
		BuildingTypes.BuildingType.MARKET:
			return Market3D.new()
		BuildingTypes.BuildingType.ARROW_TOWER:
			return ArrowTower3D.new()
		BuildingTypes.BuildingType.ARCANE_TOWER:
			return ArcaneTower3D.new()
		BuildingTypes.BuildingType.MAGIC_ALTAR:
			return MagicAltar3D.new()
		BuildingTypes.BuildingType.SHADOW_TEMPLE:
			return ShadowTemple3D.new()
		BuildingTypes.BuildingType.MAGIC_RESEARCH_INSTITUTE:
			return MagicResearchInstitute3D.new()
		_:
			LogManager.warning("⚠️ 未实现的建筑类型: %d，使用默认Building" % building_type)
			return null

func clear_all_buildings():
	"""清空所有建筑"""
	LogManager.info("BuildingManager - 清空所有建筑...")
	
	# 销毁所有建筑
	for building in buildings.duplicate():
		destroy_building(building)
	
	# 清空建筑列表
	buildings.clear()
	
	# 重置建筑ID计数器
	next_building_id = 1
	
	LogManager.info("BuildingManager - 所有建筑已清空")
