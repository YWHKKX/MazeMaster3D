extends Node

## 🌍 生态系统管理器 - 统一管理所有生态系统的生成和更新
## 负责协调资源生成、生物生成和生态区域管理
## [重构] 集成6个独立的生态系统模块

# ============================================================================
# 生态系统配置
# ============================================================================

class EcosystemConfig:
	var forest_probability: float = 0.3
	var grassland_probability: float = 0.3
	var lake_probability: float = 0.1
	var cave_probability: float = 0.2
	var wasteland_probability: float = 0.05
	var dead_land_probability: float = 0.05
	
	# 资源生成参数
	var resource_density: float = 0.1
	var resource_cluster_size: int = 3
	
	# 生物生成参数
	var creature_density: float = 0.05
	var creature_cluster_size: int = 2
	
	func _init():
		# 确保概率总和为1.0
		var total = forest_probability + grassland_probability + lake_probability + cave_probability + wasteland_probability + dead_land_probability
		if total > 0:
			forest_probability /= total
			grassland_probability /= total
			lake_probability /= total
			cave_probability /= total
			wasteland_probability /= total
			dead_land_probability /= total

# ============================================================================
# 核心变量
# ============================================================================

var ecosystem_config: EcosystemConfig
var resource_spawns: Array[ResourceSpawn] = []
var creature_spawns: Array[CreatureSpawn] = []
var ecosystem_regions: Array[EcosystemRegion] = []

# 引用
var tile_manager: Node
var character_manager: Node

# 生态系统模块引用
var forest_ecosystem: ForestEcosystem
var grassland_ecosystem: GrasslandEcosystem
var lake_ecosystem: LakeEcosystem
var cave_ecosystem: CaveEcosystem
var wasteland_ecosystem: WastelandEcosystem
var deadland_ecosystem: DeadLandEcosystem

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	"""初始化生态系统管理器"""
	LogManager.info("EcosystemManager - 初始化开始")
	
	ecosystem_config = EcosystemConfig.new()
	
	# 获取管理器引用
	tile_manager = get_node_or_null("/root/Main/TileManager")
	if not tile_manager:
		LogManager.error("ERROR: TileManager 未找到！生态系统无法正常工作")
	else:
		LogManager.info("TileManager 连接成功")
	
	character_manager = get_node_or_null("/root/Main/CharacterManager")
	if not character_manager:
		LogManager.warning("WARNING: CharacterManager 未找到，生物生成功能将受限")
	else:
		LogManager.info("CharacterManager 连接成功")
	
	# 初始化生态系统模块
	_initialize_ecosystem_modules()
	
	LogManager.info("EcosystemManager - 初始化完成")

func _initialize_ecosystem_modules():
	"""初始化生态系统模块"""
	LogManager.info("初始化生态系统模块...")
	
	# 创建森林生态系统
	forest_ecosystem = ForestEcosystem.new()
	add_child(forest_ecosystem)
	
	# 创建草地生态系统
	grassland_ecosystem = GrasslandEcosystem.new()
	add_child(grassland_ecosystem)
	
	# 创建湖泊生态系统
	lake_ecosystem = LakeEcosystem.new()
	add_child(lake_ecosystem)
	
	# 创建洞穴生态系统
	cave_ecosystem = CaveEcosystem.new()
	add_child(cave_ecosystem)
	
	# 创建荒地生态系统
	wasteland_ecosystem = WastelandEcosystem.new()
	add_child(wasteland_ecosystem)
	
	# 创建死地生态系统
	deadland_ecosystem = DeadLandEcosystem.new()
	add_child(deadland_ecosystem)
	
	LogManager.info("生态系统模块初始化完成")

# ============================================================================
# 生态系统生成
# ============================================================================

func generate_ecosystem_regions(map_size: Vector3, region_count: int = 5) -> Array[EcosystemRegion]:
	"""生成生态区域"""
	LogManager.info("开始生成生态区域...")
	
	# 检查输入参数
	if map_size.x <= 0 or map_size.z <= 0:
		LogManager.error("ERROR: 地图大小无效！map_size: %s" % map_size)
		return []
	
	if region_count <= 0:
		LogManager.warning("WARNING: 区域数量无效，使用默认值 5")
		region_count = 5
	
	ecosystem_regions.clear()
	
	for i in range(region_count):
		var region_size = Vector2i(randi_range(8, 16), randi_range(8, 16))
		var region_pos = Vector2i(
			randi_range(10, int(map_size.x) - region_size.x - 10),
			randi_range(10, int(map_size.z) - region_size.y - 10)
		)
		
		# 检查区域位置是否有效
		if region_pos.x < 0 or region_pos.y < 0:
			LogManager.warning("WARNING: 区域 %d 位置无效，跳过" % i)
			continue
		
		# 根据配置概率选择生态类型
		var ecosystem_type = _select_ecosystem_type()
		var region = EcosystemRegion.EcosystemRegion.new(region_pos, region_size, ecosystem_type)
		ecosystem_regions.append(region)
		
		# 应用生态区域到地图
		_apply_ecosystem_region(region)
		
		# 生成该区域的资源和生物（使用对应的生态系统模块）
		_generate_region_resources_with_modules(region)
		_generate_region_creatures_with_modules(region)
	
	LogManager.info("生态区域生成完成，共生成 %d 个区域" % ecosystem_regions.size())
	return ecosystem_regions

func _select_ecosystem_type() -> int:
	"""根据配置概率选择生态类型"""
	var rand_value = randf()
	var cumulative = 0.0
	
	# 按概率顺序检查
	cumulative += ecosystem_config.forest_probability
	if rand_value <= cumulative:
		return 0  # FOREST
	
	cumulative += ecosystem_config.grassland_probability
	if rand_value <= cumulative:
		return 1  # GRASSLAND
	
	cumulative += ecosystem_config.lake_probability
	if rand_value <= cumulative:
		return 2  # LAKE
	
	cumulative += ecosystem_config.cave_probability
	if rand_value <= cumulative:
		return 3  # CAVE
	
	cumulative += ecosystem_config.wasteland_probability
	if rand_value <= cumulative:
		return 4  # WASTELAND
	
	return 5  # DEAD_LAND

func _apply_ecosystem_region(region: EcosystemRegion) -> void:
	"""将生态区域应用到地图"""
	if not tile_manager:
		LogManager.error("ERROR: TileManager 未找到！无法应用生态区域到地图")
		return
		
	for x in range(region.size.x):
		for z in range(region.size.y):
			var world_pos = Vector3(region.position.x + x, 0, region.position.y + z)
			var tile_type = _get_tile_type_for_ecosystem(region.ecosystem_type)
			tile_manager.set_tile_type(world_pos, tile_type)

func _get_tile_type_for_ecosystem(ecosystem_type: int) -> int:
	"""根据生态类型获取对应的瓦片类型"""
	match ecosystem_type:
		0: return TileTypes.EMPTY  # FOREST - 森林
		1: return TileTypes.EMPTY  # GRASSLAND - 草地
		2: return TileTypes.WATER  # LAKE - 湖泊
		3: return TileTypes.EMPTY  # CAVE - 洞穴
		4: return TileTypes.EMPTY  # WASTELAND - 荒地
		5: return TileTypes.EMPTY  # DEAD_LAND - 死地
		_: return TileTypes.EMPTY

# ============================================================================
# 资源生成
# ============================================================================

func _generate_region_resources(region: EcosystemRegion) -> void:
	"""为生态区域生成资源"""
	var resource_config = ResourceTypes.get_ecosystem_resources(region.ecosystem_type)
	
	if resource_config.is_empty():
		LogManager.warning("WARNING: 生态类型 %d 没有资源配置" % region.ecosystem_type)
		return
	
	# 计算该区域应该生成的资源点数量
	var region_area = region.size.x * region.size.y
	var resource_count = int(region_area * ecosystem_config.resource_density)
	
	if resource_count <= 0:
		LogManager.warning("WARNING: 区域 %s 资源密度过低，跳过资源生成" % region.position)
		return
	
	for i in range(resource_count):
		# 随机选择资源类型
		var resource_type = _select_resource_type(resource_config)
		if resource_type == -1:
			LogManager.warning("WARNING: 无法选择资源类型，跳过")
			continue
		
		# 随机选择位置
		var pos_x = region.position.x + randi_range(0, region.size.x - 1)
		var pos_z = region.position.y + randi_range(0, region.size.y - 1)
		var position = Vector3(pos_x, 0, pos_z)
		
		# 获取资源数量
		var amount_range = resource_config[resource_type]["amount_range"]
		var amount = randi_range(amount_range[0], amount_range[1])
		
		# 获取重生时间
		var respawn_time = resource_config[resource_type]["respawn_time"]
		
		# 创建资源点
		var resource_spawn = ResourceSpawn.new(resource_type, position, amount, respawn_time)
		resource_spawns.append(resource_spawn)
		
		# 在地图上标记资源点（可选）
		_mark_resource_on_map(resource_spawn)

func _select_resource_type(resource_config: Dictionary) -> int:
	"""根据概率选择资源类型"""
	var rand_value = randf()
	var cumulative = 0.0
	
	for resource_type in resource_config.keys():
		var probability = resource_config[resource_type]["probability"]
		cumulative += probability
		
		if rand_value <= cumulative:
			return resource_type
	
	return -1

func _mark_resource_on_map(resource_spawn: ResourceSpawn) -> void:
	"""在地图上标记资源点"""
	if not tile_manager:
		return
	
	# 根据资源类型设置不同的瓦片类型
	match resource_spawn.resource_type:
		ResourceTypes.ResourceType.WOOD, ResourceTypes.ResourceType.BERRY, ResourceTypes.ResourceType.HERB:
			# 植物资源保持EMPTY，但可以添加特殊标记
			pass
		ResourceTypes.ResourceType.IRON_ORE, ResourceTypes.ResourceType.GOLD_ORE, ResourceTypes.ResourceType.GEM:
			# 矿物资源可以设置为特殊瓦片类型
			tile_manager.set_tile_type(resource_spawn.position, TileTypes.GOLD_MINE)
		_:
			pass

# ============================================================================
# 生物生成
# ============================================================================

func _generate_region_creatures(region: EcosystemRegion) -> void:
	"""为生态区域生成生物"""
	var creature_config = CreatureTypes.get_ecosystem_creatures(region.ecosystem_type)
	
	if creature_config.is_empty():
		LogManager.warning("WARNING: 生态类型 %d 没有生物配置" % region.ecosystem_type)
		return
	
	# 计算该区域应该生成的生物数量
	var region_area = region.size.x * region.size.y
	var creature_count = int(region_area * ecosystem_config.creature_density)
	
	if creature_count <= 0:
		LogManager.warning("WARNING: 区域 %s 生物密度过低，跳过生物生成" % region.position)
		return
	
	for i in range(creature_count):
		# 随机选择生物类型
		var creature_type = _select_creature_type(creature_config)
		if creature_type == -1:
			LogManager.warning("WARNING: 无法选择生物类型，跳过")
			continue
		
		# 随机选择位置
		var pos_x = region.position.x + randi_range(0, region.size.x - 1)
		var pos_z = region.position.y + randi_range(0, region.size.y - 1)
		var position = Vector3(pos_x, 0, pos_z)
		
		# 获取生物等级
		var level_range = creature_config[creature_type]["level_range"]
		var level = randi_range(level_range[0], level_range[1])
		
		# 获取是否敌对
		var is_hostile = creature_config[creature_type]["hostile"]
		
		# 获取重生时间
		var respawn_time = creature_config[creature_type]["respawn_time"]
		
		# 获取生物阵营
		var creature_faction = CreatureTypes.get_creature_faction(creature_type)
		
		# 创建生物点
		var creature_spawn = CreatureSpawn.new(creature_type, position, level, is_hostile, respawn_time)
		creature_spawns.append(creature_spawn)
		
		# 实际生成生物（如果需要）
		_spawn_creature(creature_spawn, creature_faction)

func _select_creature_type(creature_config: Dictionary) -> int:
	"""根据概率选择生物类型"""
	var rand_value = randf()
	var cumulative = 0.0
	
	for creature_type in creature_config.keys():
		var probability = creature_config[creature_type]["probability"]
		cumulative += probability
		
		if rand_value <= cumulative:
			return creature_type
	
	return -1

func _spawn_creature(creature_spawn: CreatureSpawn, faction: int = 3) -> void:
	"""实际生成生物"""
	if not character_manager:
		LogManager.warning("WARNING: CharacterManager 未找到，无法生成生物")
		return
	
	# 根据阵营确定生物类型
	var faction_name = ""
	match faction:
		1: faction_name = "怪物阵营（敌对）"
		2: faction_name = "英雄阵营（友方）"
		3: faction_name = "野兽阵营（中立）"
		4: faction_name = "中立阵营"
		_: faction_name = "未知阵营"
	
	# 创建对应的野兽场景
	var beast_scene = _get_beast_scene(creature_spawn.creature_type)
	if beast_scene:
		var beast_instance = beast_scene.instantiate()
		beast_instance.global_position = creature_spawn.position
		beast_instance.faction = faction
		
		# 添加到场景中
		character_manager.add_child(beast_instance)
		
		LogManager.info("生成生物: %s 在位置 %s，阵营: %s" % [
			CreatureTypes.get_creature_name(creature_spawn.creature_type), 
			creature_spawn.position,
			faction_name
		])
	else:
		LogManager.warning("WARNING: 无法找到生物场景: %s" % CreatureTypes.get_creature_name(creature_spawn.creature_type))

func _get_beast_scene(creature_type: CreatureTypes.CreatureType) -> PackedScene:
	"""根据生物类型获取对应的场景"""
	match creature_type:
		CreatureTypes.CreatureType.DEER:
			return preload("res://scripts/characters/beasts/Deer.gd")
		CreatureTypes.CreatureType.FOREST_WOLF:
			return preload("res://scripts/characters/beasts/ForestWolf.gd")
		CreatureTypes.CreatureType.GIANT_RAT:
			return preload("res://scripts/characters/beasts/GiantRat.gd")
		CreatureTypes.CreatureType.RABBIT:
			return preload("res://scripts/characters/beasts/Rabbit.gd")
		CreatureTypes.CreatureType.GRASSLAND_WOLF:
			return preload("res://scripts/characters/beasts/GrasslandWolf.gd")
		CreatureTypes.CreatureType.RHINO_BEAST:
			return preload("res://scripts/characters/beasts/RhinoBeast.gd")
		CreatureTypes.CreatureType.FISH:
			return preload("res://scripts/characters/beasts/Fish.gd")
		CreatureTypes.CreatureType.FISH_MAN:
			return preload("res://scripts/characters/beasts/FishMan.gd")
		CreatureTypes.CreatureType.GIANT_LIZARD:
			return preload("res://scripts/characters/beasts/GiantLizard.gd")
		CreatureTypes.CreatureType.SKELETON:
			return preload("res://scripts/characters/beasts/Skeleton.gd")
		CreatureTypes.CreatureType.ZOMBIE:
			return preload("res://scripts/characters/beasts/Zombie.gd")
		CreatureTypes.CreatureType.DEMON:
			return preload("res://scripts/characters/beasts/Demon.gd")
		CreatureTypes.CreatureType.SHADOW_BEAST:
			return preload("res://scripts/characters/beasts/ShadowBeast.gd")
		_:
			return null

# ============================================================================
# 更新和维护
# ============================================================================

func _process(_delta: float):
	"""更新生态系统"""
	_update_resource_respawns(_delta)
	_update_creature_respawns(_delta)
	update_ecosystem_food_chains(_delta)

func _update_resource_respawns(_delta: float):
	"""更新资源重生"""
	for resource_spawn in resource_spawns:
		if not resource_spawn.is_active and resource_spawn.respawn_time > 0:
			resource_spawn.last_harvested += _delta
			if resource_spawn.last_harvested >= resource_spawn.respawn_time:
				resource_spawn.is_active = true
				resource_spawn.last_harvested = 0.0
				LogManager.info("资源重生: %s 在位置 %s" % [ResourceTypes.get_resource_name(resource_spawn.resource_type), resource_spawn.position])

func _update_creature_respawns(_delta: float):
	"""更新生物重生"""
	for creature_spawn in creature_spawns:
		if not creature_spawn.is_active and creature_spawn.respawn_time > 0:
			creature_spawn.last_spawned += _delta
			if creature_spawn.last_spawned >= creature_spawn.respawn_time:
				creature_spawn.is_active = true
				creature_spawn.last_spawned = 0.0
				_spawn_creature(creature_spawn)

# ============================================================================
# 新的生态系统模块方法
# ============================================================================

func _generate_region_resources_with_modules(region: EcosystemRegion) -> void:
	"""使用生态系统模块生成区域资源"""
	var resources: Array[ResourceSpawn] = []
	
	match region.ecosystem_type:
		EcosystemRegion.EcosystemType.FOREST:
			if forest_ecosystem:
				resources = forest_ecosystem.generate_forest_resources(region)
		EcosystemRegion.EcosystemType.GRASSLAND:
			if grassland_ecosystem:
				resources = grassland_ecosystem.generate_grassland_resources(region)
		EcosystemRegion.EcosystemType.LAKE:
			if lake_ecosystem:
				resources = lake_ecosystem.generate_lake_resources(region)
		EcosystemRegion.EcosystemType.CAVE:
			if cave_ecosystem:
				resources = cave_ecosystem.generate_cave_resources(region)
		EcosystemRegion.EcosystemType.WASTELAND:
			if wasteland_ecosystem:
				resources = wasteland_ecosystem.generate_wasteland_resources(region)
		EcosystemRegion.EcosystemType.DEAD_LAND:
			if deadland_ecosystem:
				resources = deadland_ecosystem.generate_deadland_resources(region)
	
	# 添加到全局资源列表
	for resource in resources:
		resource_spawns.append(resource)
	
	LogManager.info("为生态类型 %d 生成了 %d 个资源" % [region.ecosystem_type, resources.size()])

func _generate_region_creatures_with_modules(region: EcosystemRegion) -> void:
	"""使用生态系统模块生成区域生物"""
	var creatures: Array[CreatureSpawn] = []
	
	match region.ecosystem_type:
		EcosystemRegion.EcosystemType.FOREST:
			if forest_ecosystem:
				creatures = forest_ecosystem.generate_forest_creatures(region)
		EcosystemRegion.EcosystemType.GRASSLAND:
			if grassland_ecosystem:
				creatures = grassland_ecosystem.generate_grassland_creatures(region)
		EcosystemRegion.EcosystemType.LAKE:
			if lake_ecosystem:
				creatures = lake_ecosystem.generate_lake_creatures(region)
		EcosystemRegion.EcosystemType.CAVE:
			if cave_ecosystem:
				creatures = cave_ecosystem.generate_cave_creatures(region)
		EcosystemRegion.EcosystemType.WASTELAND:
			if wasteland_ecosystem:
				creatures = wasteland_ecosystem.generate_wasteland_creatures(region)
		EcosystemRegion.EcosystemType.DEAD_LAND:
			if deadland_ecosystem:
				creatures = deadland_ecosystem.generate_deadland_creatures(region)
	
	# 添加到全局生物列表并实际生成
	for creature in creatures:
		creature_spawns.append(creature)
		_spawn_creature(creature)
	
	LogManager.info("为生态类型 %d 生成了 %d 个生物" % [region.ecosystem_type, creatures.size()])

func update_ecosystem_food_chains(delta: float) -> void:
	"""更新所有生态系统的食物链"""
	for region in ecosystem_regions:
		if not region.is_active:
			continue
		
		# 获取该区域的生物
		var region_creatures = creature_spawns.filter(func(c): return region.contains_point(Vector2i(c.position.x, c.position.z)))
		
		# 根据生态类型更新食物链
		match region.ecosystem_type:
			EcosystemRegion.EcosystemType.FOREST:
				if forest_ecosystem:
					forest_ecosystem.update_forest_food_chain(region_creatures, delta)
			EcosystemRegion.EcosystemType.GRASSLAND:
				if grassland_ecosystem:
					grassland_ecosystem.update_grassland_food_chain(region_creatures, delta)
			EcosystemRegion.EcosystemType.LAKE:
				if lake_ecosystem:
					lake_ecosystem.update_lake_food_chain(region_creatures, delta)
			EcosystemRegion.EcosystemType.CAVE:
				if cave_ecosystem:
					cave_ecosystem.update_cave_ecosystem(region_creatures, delta)
			EcosystemRegion.EcosystemType.WASTELAND:
				if wasteland_ecosystem:
					wasteland_ecosystem.update_wasteland_ecosystem(region_creatures, delta)
			EcosystemRegion.EcosystemType.DEAD_LAND:
				if deadland_ecosystem:
					deadland_ecosystem.update_deadland_ecosystem(region_creatures, delta)

# ============================================================================
# 公共接口
# ============================================================================

func get_resources_in_area(center: Vector3, radius: float) -> Array[ResourceSpawn]:
	"""获取指定区域内的资源"""
	var nearby_resources: Array[ResourceSpawn] = []
	
	for resource_spawn in resource_spawns:
		if resource_spawn.is_active and resource_spawn.position.distance_to(center) <= radius:
			nearby_resources.append(resource_spawn)
	
	return nearby_resources

func get_creatures_in_area(center: Vector3, radius: float) -> Array[CreatureSpawn]:
	"""获取指定区域内的生物"""
	var nearby_creatures: Array[CreatureSpawn] = []
	
	for creature_spawn in creature_spawns:
		if creature_spawn.is_active and creature_spawn.position.distance_to(center) <= radius:
			nearby_creatures.append(creature_spawn)
	
	return nearby_creatures

func harvest_resource(resource_spawn: ResourceSpawn) -> int:
	"""收获资源"""
	if not resource_spawn.is_active:
		return 0
	
	var amount = resource_spawn.amount
	resource_spawn.is_active = false
	resource_spawn.last_harvested = 0.0
	
	LogManager.info("收获资源: %s x%d" % [ResourceTypes.get_resource_name(resource_spawn.resource_type), amount])
	return amount

func clear_ecosystem():
	"""清空生态系统"""
	resource_spawns.clear()
	creature_spawns.clear()
	ecosystem_regions.clear()
	LogManager.info("生态系统已清空")
