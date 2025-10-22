extends Node

## 🌍 生态系统管理器 - 统一管理所有生态系统的生成和更新
## 负责协调资源生成、生物生成和生态区域管理
## [重构] 集成6个独立的生态系统模块

# ============================================================================
# 生态系统配置
# ============================================================================

class EcosystemConfig:
	var forest_probability: float = 0.25
	var grassland_probability: float = 0.25
	var lake_probability: float = 0.1
	var cave_probability: float = 0.2
	var wasteland_probability: float = 0.05
	var dead_land_probability: float = 0.05
	var primitive_probability: float = 0.1
	
	# 资源生成参数
	var resource_density: float = 0.1
	var resource_cluster_size: int = 3
	
	# 生物生成参数
	var creature_density: float = 0.05
	var creature_cluster_size: int = 2
	
	func _init():
		# 确保概率总和为1.0
		var total = forest_probability + grassland_probability + lake_probability + cave_probability + wasteland_probability + dead_land_probability + primitive_probability
		if total > 0:
			forest_probability /= total
			grassland_probability /= total
			lake_probability /= total
			cave_probability /= total
			wasteland_probability /= total
			dead_land_probability /= total
			primitive_probability /= total

# ============================================================================
# 核心变量
# ============================================================================

var ecosystem_config: EcosystemConfig
var resource_spawns: Array[ResourceTypes.ResourceSpawn] = []
var creature_spawns: Array[BeastsTypes.BeastSpawn] = []
var ecosystem_regions: Array[EcosystemRegion.RegionData] = []

# 引用
var tile_manager: Node
var character_manager: Node

# ============================================================================
# 生物实例创建函数
# ============================================================================

func create_beast_instance(creature_type: BeastsTypes.BeastType) -> Node3D:
	"""根据生物类型创建对应的实例 - 使用@beasts/文件夹中的野兽类"""
	if not character_manager:
		LogManager.error("EcosystemManager: CharacterManager未初始化，无法创建野兽")
		return null
	
	var beast_instance = null
	var beast_script = null
	
	# 使用preload加载@beasts/文件夹中的野兽类
	match creature_type:
		BeastsTypes.BeastType.DEER:
			beast_script = preload("res://scripts/characters/beasts/Deer.gd")
		BeastsTypes.BeastType.FOREST_WOLF:
			beast_script = preload("res://scripts/characters/beasts/ForestWolf.gd")
		BeastsTypes.BeastType.GIANT_RAT:
			beast_script = preload("res://scripts/characters/beasts/GiantRat.gd")
		BeastsTypes.BeastType.RABBIT:
			beast_script = preload("res://scripts/characters/beasts/Rabbit.gd")
		BeastsTypes.BeastType.GRASSLAND_WOLF:
			beast_script = preload("res://scripts/characters/beasts/GrasslandWolf.gd")
		BeastsTypes.BeastType.RHINO_BEAST:
			beast_script = preload("res://scripts/characters/beasts/RhinoBeast.gd")
		BeastsTypes.BeastType.FISH:
			beast_script = preload("res://scripts/characters/beasts/Fish.gd")
		BeastsTypes.BeastType.FISH_MAN:
			beast_script = preload("res://scripts/characters/beasts/FishMan.gd")
		BeastsTypes.BeastType.GIANT_LIZARD:
			beast_script = preload("res://scripts/characters/beasts/GiantLizard.gd")
		BeastsTypes.BeastType.SHADOW_DRAGON:
			beast_script = preload("res://scripts/characters/beasts/ShadowBeast.gd")
		BeastsTypes.BeastType.STONE_BEETLE:
			beast_script = preload("res://scripts/characters/beasts/StoneBeetle.gd")
		BeastsTypes.BeastType.SHADOW_TIGER:
			beast_script = preload("res://scripts/characters/beasts/ShadowTiger.gd")
		BeastsTypes.BeastType.SHADOW_SPIDER:
			beast_script = preload("res://scripts/characters/beasts/ShadowSpider.gd")
		BeastsTypes.BeastType.POISON_SCORPION:
			beast_script = preload("res://scripts/characters/beasts/PoisonScorpion.gd")
		BeastsTypes.BeastType.CLAW_BEAR:
			beast_script = preload("res://scripts/characters/beasts/ClawBear.gd")
		BeastsTypes.BeastType.CAVE_BAT:
			beast_script = preload("res://scripts/characters/beasts/CaveBat.gd")
		# 湖泊生态系统野兽
		BeastsTypes.BeastType.WATER_GRASS_FISH:
			beast_script = preload("res://scripts/characters/beasts/WaterGrassFish.gd")
		BeastsTypes.BeastType.PLANKTON:
			beast_script = preload("res://scripts/characters/beasts/Plankton.gd")
		BeastsTypes.BeastType.WATER_SNAKE:
			beast_script = preload("res://scripts/characters/beasts/WaterSnake.gd")
		BeastsTypes.BeastType.WATER_BIRD:
			beast_script = preload("res://scripts/characters/beasts/WaterBird.gd")
		BeastsTypes.BeastType.LAKE_MONSTER:
			beast_script = preload("res://scripts/characters/beasts/LakeMonster.gd")
		# 荒地生态系统野兽
		BeastsTypes.BeastType.RADIOACTIVE_SCORPION:
			beast_script = preload("res://scripts/characters/beasts/RadioactiveScorpion.gd")
		BeastsTypes.BeastType.SANDSTORM_WOLF:
			beast_script = preload("res://scripts/characters/beasts/SandstormWolf.gd")
		BeastsTypes.BeastType.MUTANT_RAT:
			beast_script = preload("res://scripts/characters/beasts/MutantRat.gd")
		BeastsTypes.BeastType.CORRUPTED_WORM:
			beast_script = preload("res://scripts/characters/beasts/CorruptedWorm.gd")
		# 死地生态系统野兽
		BeastsTypes.BeastType.SHADOW_WOLF:
			beast_script = preload("res://scripts/characters/beasts/ShadowWolf.gd")
		BeastsTypes.BeastType.CORRUPTED_BOAR:
			beast_script = preload("res://scripts/characters/beasts/CorruptedBoar.gd")
		BeastsTypes.BeastType.MAGIC_VULTURE:
			beast_script = preload("res://scripts/characters/beasts/MagicVulture.gd")
		BeastsTypes.BeastType.SHADOW_PANTHER:
			beast_script = preload("res://scripts/characters/beasts/ShadowPanther.gd")
		BeastsTypes.BeastType.ABYSS_DRAGON:
			beast_script = preload("res://scripts/characters/beasts/AbyssDragon.gd")
		# 原始生态系统野兽
		BeastsTypes.BeastType.HORN_SHIELD_DRAGON:
			beast_script = preload("res://scripts/characters/beasts/HornShieldBeast.gd")
		BeastsTypes.BeastType.SPINE_BACK_DRAGON:
			beast_script = preload("res://scripts/characters/beasts/SpineBackBeast.gd")
		BeastsTypes.BeastType.SCALE_ARMOR_DRAGON:
			beast_script = preload("res://scripts/characters/beasts/ScaleArmorBeast.gd")
		BeastsTypes.BeastType.CLAW_HUNTER_DRAGON:
			beast_script = preload("res://scripts/characters/beasts/ClawHunterBeast.gd")
		BeastsTypes.BeastType.RAGE_DRAGON:
			beast_script = preload("res://scripts/characters/beasts/RageBeast.gd")
		BeastsTypes.BeastType.SHADOW_DRAGON:
			beast_script = preload("res://scripts/characters/beasts/ShadowDragon.gd")
		BeastsTypes.BeastType.DRAGON_BLOOD_BEAST:
			beast_script = preload("res://scripts/characters/beasts/DragonBloodBeast.gd")
		BeastsTypes.BeastType.ANCIENT_DRAGON_OVERLORD:
			beast_script = preload("res://scripts/characters/beasts/AncientDragonOverlord.gd")
		_:
			LogManager.warning("WARNING: 未知的生物类型: %s" % creature_type)
			return null
	
	# 创建野兽实例
	if beast_script:
		beast_instance = beast_script.new()
		if beast_instance:
			# 添加到CharacterManager中
			character_manager.add_child(beast_instance)
			# 日志移除
			return beast_instance
		else:
			LogManager.error("❌ 野兽实例创建失败: %s" % BeastsTypes.get_beast_name(creature_type))
			return null
	else:
		LogManager.error("❌ 野兽脚本加载失败: %s" % BeastsTypes.get_beast_name(creature_type))
		return null

# 生态系统模块引用
var forest_ecosystem: ForestEcosystem
var grassland_ecosystem: GrasslandEcosystem
var lake_ecosystem: LakeEcosystem
var cave_ecosystem: CaveEcosystem
var wasteland_ecosystem: WastelandEcosystem
var deadland_ecosystem: DeadLandEcosystem
var primitive_ecosystem: PrimitiveEcosystem

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
	
	# 创建原始生态系统
	primitive_ecosystem = PrimitiveEcosystem.new()
	add_child(primitive_ecosystem)
	
	LogManager.info("生态系统模块初始化完成")

# ============================================================================
# 生态系统生成
# ============================================================================

func generate_ecosystem_regions(map_size: Vector3, region_count: int = 5) -> Array[EcosystemRegion.RegionData]:
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
		var region = EcosystemRegion.RegionData.new(region_pos, region_size, ecosystem_type)
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
		return 0 # FOREST
	
	cumulative += ecosystem_config.grassland_probability
	if rand_value <= cumulative:
		return 1 # GRASSLAND
	
	cumulative += ecosystem_config.lake_probability
	if rand_value <= cumulative:
		return 2 # LAKE
	
	cumulative += ecosystem_config.cave_probability
	if rand_value <= cumulative:
		return 3 # CAVE
	
	cumulative += ecosystem_config.wasteland_probability
	if rand_value <= cumulative:
		return 4 # WASTELAND
	
	cumulative += ecosystem_config.dead_land_probability
	if rand_value <= cumulative:
		return 5 # DEAD_LAND
	
	return 6 # PRIMITIVE

func _apply_ecosystem_region(region: EcosystemRegion.RegionData) -> void:
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
	# 为每个生态系统随机选择地块类型
	match ecosystem_type:
		0: # FOREST - 森林
			return _get_random_forest_tile()
		1: # GRASSLAND - 草地
			return _get_random_grassland_tile()
		2: # LAKE - 湖泊
			return _get_random_lake_tile()
		3: # CAVE - 洞穴
			return _get_random_cave_tile()
		4: # WASTELAND - 荒地
			return _get_random_wasteland_tile()
		5: # DEAD_LAND - 死地
			return _get_random_deadland_tile()
		6: # PRIMITIVE - 原始
			return _get_random_primitive_tile()
		_:
			return TileTypes.TileType.EMPTY

func _get_random_forest_tile() -> int:
	"""随机选择森林地块类型"""
	var forest_tiles = [
		TileTypes.TileType.FOREST_CLEARING,
		TileTypes.TileType.DENSE_FOREST,
		TileTypes.TileType.FOREST_EDGE,
		TileTypes.TileType.ANCIENT_FOREST
	]
	return forest_tiles[randi() % forest_tiles.size()]

func _get_random_grassland_tile() -> int:
	"""随机选择草地地块类型 - 草原平原占70%，其他类型占30%"""
	var rand_value = randf()
	
	# 70%概率返回草原平原
	if rand_value < 0.7:
		return TileTypes.TileType.GRASSLAND_PLAINS
	
	# 30%概率返回其他草地类型
	var other_grassland_tiles = [
		TileTypes.TileType.GRASSLAND_HILLS,
		TileTypes.TileType.GRASSLAND_WETLANDS,
		TileTypes.TileType.GRASSLAND_FIELDS
	]
	return other_grassland_tiles[randi() % other_grassland_tiles.size()]

func _get_random_lake_tile() -> int:
	"""随机选择湖泊地块类型"""
	var lake_tiles = [
		TileTypes.TileType.LAKE_SHALLOW,
		TileTypes.TileType.LAKE_DEEP,
		TileTypes.TileType.LAKE_SHORE,
		TileTypes.TileType.LAKE_ISLAND
	]
	return lake_tiles[randi() % lake_tiles.size()]

func _get_random_cave_tile() -> int:
	"""随机选择洞穴地块类型"""
	var cave_tiles = [
		TileTypes.TileType.CAVE_DEEP,
		TileTypes.TileType.CAVE_CRYSTAL,
		TileTypes.TileType.CAVE_UNDERGROUND_LAKE
	]
	return cave_tiles[randi() % cave_tiles.size()]

func _get_random_wasteland_tile() -> int:
	"""随机选择荒地地块类型"""
	var wasteland_tiles = [
		TileTypes.TileType.WASTELAND_DESERT,
		TileTypes.TileType.WASTELAND_ROCKS,
		TileTypes.TileType.WASTELAND_RUINS,
		TileTypes.TileType.WASTELAND_TOXIC
	]
	return wasteland_tiles[randi() % wasteland_tiles.size()]

func _get_random_deadland_tile() -> int:
	"""随机选择死地地块类型"""
	var deadland_tiles = [
		TileTypes.TileType.DEAD_LAND_GRAVEYARD,
		TileTypes.TileType.DEAD_LAND_SWAMP
	]
	return deadland_tiles[randi() % deadland_tiles.size()]

func _get_random_primitive_tile() -> int:
	"""随机选择原始地块类型 - 原始丛林占60%，其他类型占40%"""
	var rand_value = randf()
	
	# 60%概率返回原始丛林
	if rand_value < 0.6:
		return TileTypes.TileType.PRIMITIVE_JUNGLE
	
	# 40%概率返回其他原始类型
	var other_primitive_tiles = [
		TileTypes.TileType.PRIMITIVE_VOLCANO,
		TileTypes.TileType.PRIMITIVE_SWAMP
	]
	return other_primitive_tiles[randi() % other_primitive_tiles.size()]

func _get_ecosystem_type_name(ecosystem_type: int) -> String:
	"""根据生态类型获取对应的名称"""
	match ecosystem_type:
		0: return "FOREST"
		1: return "GRASSLAND"
		2: return "LAKE"
		3: return "CAVE"
		4: return "WASTELAND"
		5: return "DEAD_LAND"
		6: return "PRIMITIVE"
		_: return "UNKNOWN"

# ============================================================================
# 资源生成
# ============================================================================

func _generate_region_resources(region: EcosystemRegion.RegionData) -> void:
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
	
	var used_positions = {} # 记录已使用的位置，避免重叠
	
	for i in range(resource_count):
		# 随机选择资源类型
		var resource_type = _select_resource_type(resource_config)
		if resource_type == -1:
			LogManager.warning("WARNING: 无法选择资源类型，跳过")
			continue
		
		# 🌿 避免位置重叠：尝试多次找到可用位置
		var position = Vector3.ZERO
		var attempts = 0
		var max_attempts = 20
		
		while attempts < max_attempts:
			var pos_x = region.position.x + randi_range(0, region.size.x - 1)
			var pos_z = region.position.y + randi_range(0, region.size.y - 1)
			var test_position = Vector3(pos_x, 0, pos_z)
			var position_key = str(pos_x) + "," + str(pos_z)
			
			# 检查位置是否已被使用
			if not position_key in used_positions:
				position = test_position
				used_positions[position_key] = true
				break
			
			attempts += 1
		
		# 如果找不到可用位置，跳过
		if position == Vector3.ZERO:
			LogManager.warning("WARNING: 无法找到可用位置生成资源，跳过")
			continue
		
		# 获取资源数量
		var amount_range = resource_config[resource_type]["amount_range"]
		var amount = randi_range(amount_range[0], amount_range[1])
		
		# 获取重生时间
		var respawn_time = resource_config[resource_type]["respawn_time"]
		
		# 创建资源点
		var resource_spawn = ResourceTypes.ResourceSpawn.new(resource_type, position, amount, respawn_time)
		resource_spawns.append(resource_spawn)
		
		# 在地图上标记资源点（占据瓦块空间）
		_mark_resource_on_map(resource_spawn)
		
		# 🌿 创建视觉植物对象
		_create_visual_resource_object(resource_spawn)


func _mark_resource_on_map(resource_spawn: ResourceTypes.ResourceSpawn) -> void:
	"""在地图上标记资源点"""
	if not tile_manager:
		return
	
	# 🌿 根据资源类型和地块类型设置对应的生态系统特殊地块
	var tile_type = _get_resource_tile_type(resource_spawn.resource_type, Vector2(resource_spawn.position.x, resource_spawn.position.z))
	tile_manager.set_tile_type(resource_spawn.position, tile_type)

func _get_resource_tile_type(resource_type: ResourceTypes.ResourceType, position: Vector2) -> int:
	"""根据资源类型和位置获取对应的地块类型"""
	# 获取当前位置的地块类型
	var current_tile_type = tile_manager.get_tile_type(Vector3(position.x, 0, position.y))
	
	# 根据资源类型和当前地块类型确定最终地块类型
	match resource_type:
		ResourceTypes.ResourceType.WOOD:
			# 🌳 木材根据森林类型确定
			if current_tile_type in [TileTypes.TileType.FOREST_CLEARING, TileTypes.TileType.DENSE_FOREST, TileTypes.TileType.FOREST_EDGE, TileTypes.TileType.ANCIENT_FOREST]:
				return current_tile_type
			else:
				return TileTypes.TileType.DENSE_FOREST
		
		ResourceTypes.ResourceType.BERRY:
			# 🍓 浆果在森林空地
			return TileTypes.TileType.FOREST_CLEARING
		
		ResourceTypes.ResourceType.HERB:
			# 🌿 草药在森林边缘
			return TileTypes.TileType.FOREST_EDGE
		
		ResourceTypes.ResourceType.MUSHROOM:
			# 🍄 蘑菇在洞穴
			if current_tile_type in [TileTypes.TileType.CAVE_DEEP, TileTypes.TileType.CAVE_CRYSTAL]:
				return current_tile_type
			else:
				return TileTypes.TileType.CAVE_DEEP # CAVE_CHAMBER不存在，使用CAVE_DEEP代替
		
		ResourceTypes.ResourceType.AQUATIC_PLANT:
			# 🌊 水生植物在浅水区
			return TileTypes.TileType.LAKE_SHALLOW
		
		ResourceTypes.ResourceType.CROP:
			# 🌾 作物在农田
			return TileTypes.TileType.GRASSLAND_FIELDS
		
		ResourceTypes.ResourceType.CORRUPTED_PLANT:
			# 🌑 腐化植物在荒地毒区
			return TileTypes.TileType.WASTELAND_TOXIC
		
		ResourceTypes.ResourceType.DEATH_FLOWER:
			# 🌹 死灵花在死地墓地
			return TileTypes.TileType.DEAD_LAND_GRAVEYARD
		
		ResourceTypes.ResourceType.PRIMITIVE_PLANT:
			# 🌿 原始植物在原始丛林
			return TileTypes.TileType.PRIMITIVE_JUNGLE
		
		# 矿物资源
		ResourceTypes.ResourceType.IRON_ORE:
			# 铁矿石在洞穴深处
			return TileTypes.TileType.CAVE_DEEP
		
		ResourceTypes.ResourceType.GOLD_ORE:
			# 金矿石在洞穴水晶区
			return TileTypes.TileType.CAVE_CRYSTAL
		
		ResourceTypes.ResourceType.RARE_MINERAL:
			# 稀有矿物在荒地岩石区
			return TileTypes.TileType.WASTELAND_ROCKS
		
		ResourceTypes.ResourceType.ESSENCE:
			# 精华在死地腐化区
			return TileTypes.TileType.DEAD_LAND_SWAMP # DEAD_LAND_CORRUPTED不存在，使用DEAD_LAND_SWAMP代替
		
		ResourceTypes.ResourceType.SOUL_STONE:
			# 灵魂石在死地死城
			return TileTypes.TileType.DEAD_LAND_GRAVEYARD # DEAD_LAND_NECROPOLIS不存在，使用DEAD_LAND_GRAVEYARD代替
		
		ResourceTypes.ResourceType.CURSED_GEM:
			# 诅咒宝石在死地虚空
			return TileTypes.TileType.DEAD_LAND_SWAMP # DEAD_LAND_VOID不存在，使用DEAD_LAND_SWAMP代替
		
		ResourceTypes.ResourceType.PREHISTORIC_MINERAL:
			# 史前矿物在原始火山
			return TileTypes.TileType.PRIMITIVE_VOLCANO
		
		ResourceTypes.ResourceType.PRIMITIVE_CRYSTAL:
			# 原始水晶在原始水晶区
			return TileTypes.TileType.PRIMITIVE_SWAMP # PRIMITIVE_CRYSTAL不存在，使用PRIMITIVE_SWAMP代替
		
		ResourceTypes.ResourceType.DRAGON_BLOOD_STONE:
			# 龙血石在原始沼泽
			return TileTypes.TileType.PRIMITIVE_SWAMP
		
		ResourceTypes.ResourceType.ANCIENT_DRAGON_SCALE:
			# 古龙鳞在古树区域
			return TileTypes.TileType.ANCIENT_FOREST
		
		# 基础资源
		ResourceTypes.ResourceType.FOOD:
			# 食物在草原平原
			return TileTypes.TileType.GRASSLAND_PLAINS
		
		ResourceTypes.ResourceType.WATER:
			# 水在湖岸
			return TileTypes.TileType.LAKE_SHORE
		
		ResourceTypes.ResourceType.STONE:
			# 石头在荒地沙漠
			return TileTypes.TileType.WASTELAND_DESERT
		
		_:
			# 默认保持原地块类型
			return current_tile_type

func _create_visual_resource_object(resource_spawn: ResourceTypes.ResourceSpawn) -> void:
	"""创建视觉资源对象"""
	# 获取增强资源渲染器
	var enhanced_renderer = GameServices.get_enhanced_resource_renderer()
	if not enhanced_renderer:
		LogManager.warning("EcosystemManager - EnhancedResourceRenderer未找到，跳过视觉对象创建")
		return
	
	# 创建视觉对象
	var visual_object = enhanced_renderer.create_resource_object(resource_spawn.resource_type, resource_spawn.position, resource_spawn.amount)
	if visual_object:
		LogManager.info("✅ EcosystemManager - 创建视觉资源对象: %s 在位置 %s" % [ResourceTypes.get_resource_name(resource_spawn.resource_type), str(resource_spawn.position)])
	else:
		LogManager.warning("❌ EcosystemManager - 视觉资源对象创建失败: %s 在位置 %s" % [ResourceTypes.get_resource_name(resource_spawn.resource_type), str(resource_spawn.position)])

# ============================================================================
# 生物生成
# ============================================================================

func _generate_region_creatures(region: EcosystemRegion.RegionData) -> void:
	"""为生态区域生成生物"""
	var creature_config = BeastsTypes.get_ecosystem_creatures(_get_ecosystem_type_name(region.ecosystem_type))
	
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
		var creature_faction = FactionManager.Faction.BEASTS
		
		# 创建生物点
		var creature_spawn = BeastsTypes.BeastSpawn.new(creature_type, position, level, is_hostile, respawn_time)
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

func _spawn_creature(creature_spawn: BeastsTypes.BeastSpawn, faction: int = FactionManager.Faction.BEASTS) -> void:
	"""实际生成生物"""
	if not character_manager:
		LogManager.warning("WARNING: CharacterManager 未找到，无法生成生物")
		return
	
	# 根据阵营确定生物类型
	var faction_name = FactionManager.get_faction_name(faction)
	
	# 🔧 修复：使用WorldConstants设置正确的y坐标
	var spawn_position = WorldConstants.get_character_spawn_position(creature_spawn.position.x, creature_spawn.position.z)
	
	# 创建对应的野兽实例
	var beast_instance = create_beast_instance(creature_spawn.creature_type)
	if beast_instance:
		beast_instance.global_position = spawn_position
		beast_instance.faction = faction
		
		# 添加到场景中
		character_manager.add_child(beast_instance)
		
		LogManager.info("生成生物: %s 在位置 %s，阵营: %s" % [
			BeastsTypes.get_creature_name(creature_spawn.creature_type),
			spawn_position,
			faction_name
		])
	else:
		LogManager.warning("WARNING: 无法找到生物场景: %s" % BeastsTypes.get_creature_name(creature_spawn.creature_type))

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

func _generate_region_resources_with_modules(region: EcosystemRegion.RegionData) -> void:
	"""使用生态系统模块生成区域资源"""
	var resources: Array[ResourceTypes.ResourceSpawn] = []
	
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
		6: # PRIMITIVE
			if primitive_ecosystem:
				resources = primitive_ecosystem.generate_primitive_resources(region)
	
	# 添加到全局资源列表
	for resource in resources:
		resource_spawns.append(resource)
	
	LogManager.info("为生态类型 %d 生成了 %d 个资源" % [region.ecosystem_type, resources.size()])

func _generate_region_creatures_with_modules(region: EcosystemRegion.RegionData) -> void:
	"""使用生态系统模块生成区域生物"""
	var creatures: Array[BeastsTypes.BeastSpawn] = []
	
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
		6: # PRIMITIVE
			if primitive_ecosystem:
				creatures = primitive_ecosystem.generate_primitive_creatures(region)
	
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
			6: # PRIMITIVE
				if primitive_ecosystem:
					primitive_ecosystem.update_primitive_food_chain(region_creatures)

# ============================================================================
# 公共接口
# ============================================================================

func get_resources_in_area(center: Vector3, radius: float) -> Array[ResourceTypes.ResourceSpawn]:
	"""获取指定区域内的资源"""
	var nearby_resources: Array[ResourceTypes.ResourceSpawn] = []
	
	for resource_spawn in resource_spawns:
		if resource_spawn.is_active and resource_spawn.position.distance_to(center) <= radius:
			nearby_resources.append(resource_spawn)
	
	return nearby_resources

func get_creatures_in_area(center: Vector3, radius: float) -> Array[BeastsTypes.BeastSpawn]:
	"""获取指定区域内的生物"""
	var nearby_creatures: Array[BeastsTypes.BeastSpawn] = []
	
	for creature_spawn in creature_spawns:
		if creature_spawn.is_active and creature_spawn.position.distance_to(center) <= radius:
			nearby_creatures.append(creature_spawn)
	
	return nearby_creatures

func harvest_resource(resource_spawn: ResourceTypes.ResourceSpawn) -> int:
	"""收获资源"""
	if not resource_spawn.is_active:
		return 0
	
	var amount = resource_spawn.amount
	resource_spawn.is_active = false
	resource_spawn.last_harvested = 0.0
	
	LogManager.info("收获资源: %s x%d" % [ResourceTypes.get_resource_name(resource_spawn.resource_type), amount])
	return amount

func set_tile_manager(manager: Node) -> void:
	"""设置瓦片管理器"""
	tile_manager = manager
	LogManager.info("EcosystemManager - 瓦片管理器已设置")

func set_character_manager(manager: Node) -> void:
	"""设置角色管理器"""
	character_manager = manager
	LogManager.info("EcosystemManager - 角色管理器已设置")

func _select_resource_type(resource_config: Dictionary) -> ResourceTypes.ResourceType:
	"""根据概率选择资源类型"""
	var total_probability = 0.0
	for resource_type in resource_config.keys():
		total_probability += resource_config[resource_type].probability
	
	var random_value = randf() * total_probability
	var current_probability = 0.0
	
	for resource_type in resource_config.keys():
		current_probability += resource_config[resource_type].probability
		if random_value <= current_probability:
			return resource_type
	
	# 如果没有选中任何资源，返回第一个
	if resource_config.size() > 0:
		return resource_config.keys()[0]
	else:
		return ResourceTypes.ResourceType.WOOD # 默认返回木材

func _select_beast_type(beast_config: Dictionary) -> BeastsTypes.BeastType:
	"""根据概率选择野兽类型"""
	var total_probability = 0.0
	for beast_type in beast_config.keys():
		total_probability += beast_config[beast_type].probability
	
	var random_value = randf() * total_probability
	var current_probability = 0.0
	
	for beast_type in beast_config.keys():
		current_probability += beast_config[beast_type].probability
		if random_value <= current_probability:
			return beast_type
	
	# 如果没有选中任何野兽，返回第一个
	return beast_config.keys()[0] if beast_config.size() > 0 else null

func _is_position_in_cavity(pos: Vector3) -> bool:
	"""检查位置是否在空洞范围内"""
	if not tile_manager:
		return false
	
	# 检查该位置的地块类型是否为生态系统类型
	var tile_data = tile_manager.get_tile_data(pos)
	if not tile_data:
		return false
	
	# 🌍 检查是否为生态系统类型的地块（包括所有特殊地块类型）
	var tile_type = tile_data.type
	
	# 检查森林生态系统特殊地块
	if tile_type in [TileTypes.TileType.FOREST_CLEARING, TileTypes.TileType.DENSE_FOREST, TileTypes.TileType.FOREST_EDGE, TileTypes.TileType.ANCIENT_FOREST]:
		return true
	
	# 检查草地生态系统特殊地块
	if tile_type in [TileTypes.TileType.GRASSLAND_PLAINS, TileTypes.TileType.GRASSLAND_HILLS, TileTypes.TileType.GRASSLAND_WETLANDS, TileTypes.TileType.GRASSLAND_FIELDS]:
		return true
	
	# 检查湖泊生态系统特殊地块
	if tile_type in [TileTypes.TileType.LAKE_SHALLOW, TileTypes.TileType.LAKE_DEEP, TileTypes.TileType.LAKE_SHORE, TileTypes.TileType.LAKE_ISLAND]:
		return true
	
	# 检查洞穴生态系统特殊地块
	if tile_type in [TileTypes.TileType.CAVE_DEEP, TileTypes.TileType.CAVE_CRYSTAL, TileTypes.TileType.CAVE_UNDERGROUND_LAKE]:
		return true
	
	# 检查荒地生态系统特殊地块
	if tile_type in [TileTypes.TileType.WASTELAND_DESERT, TileTypes.TileType.WASTELAND_ROCKS, TileTypes.TileType.WASTELAND_RUINS, TileTypes.TileType.WASTELAND_TOXIC]:
		return true
	
	# 检查死地生态系统特殊地块
	if tile_type in [TileTypes.TileType.DEAD_LAND_GRAVEYARD, TileTypes.TileType.DEAD_LAND_SWAMP]:
		return true
	
	# 检查原始生态系统特殊地块
	if tile_type in [TileTypes.TileType.PRIMITIVE_JUNGLE, TileTypes.TileType.PRIMITIVE_VOLCANO, TileTypes.TileType.PRIMITIVE_SWAMP]:
		return true
	
	return false

func populate_ecosystem_region(positions: Array, ecosystem_type: String) -> void:
	"""填充生态系统区域 - 在空洞内容填充阶段调用"""
	LogManager.info("🌍 填充生态系统区域: %s, 位置数: %d" % [ecosystem_type, positions.size()])
	
	if not tile_manager:
		LogManager.error("EcosystemManager: TileManager未设置，无法填充生态系统区域")
		return
	
	if not character_manager:
		LogManager.error("EcosystemManager: CharacterManager未设置，无法填充生态系统区域")
		return
	
	# 根据生态系统类型生成资源和生物
	match ecosystem_type:
		"FOREST":
			_generate_forest_content(positions)
		"LAKE":
			_generate_lake_content(positions)
		"CAVE":
			_generate_cave_content(positions)
		"WASTELAND":
			_generate_wasteland_content(positions)
		"GRASSLAND":
			_generate_grassland_content(positions)
		"DEAD_LAND":
			_generate_dead_land_content(positions)
		"PRIMITIVE":
			_generate_primitive_content(positions)
		_:
			LogManager.warning("EcosystemManager: 未知的生态系统类型: %s" % ecosystem_type)

func _generate_forest_content(positions: Array) -> void:
	"""生成森林内容 - 严格限制在空洞范围内"""
	LogManager.info("🌲 生成森林内容...")
	
	# 生成森林资源
	var resource_count = 0
	for pos in positions:
		# 🔧 严格限制：只在空洞范围内的位置生成
		if not _is_position_in_cavity(pos):
			continue
			
		if randf() < 0.3: # 30%概率生成资源
			# 根据概率选择资源类型
			var resource_type = _select_resource_type(ResourceTypes.FOREST_RESOURCES)
			if resource_type != null:
				var resource_data = ResourceTypes.FOREST_RESOURCES[resource_type]
				var amount = randi_range(resource_data.amount_range[0], resource_data.amount_range[1])
				var resource_spawn = ResourceTypes.ResourceSpawn.new(resource_type, pos, amount, resource_data.respawn_time)
				resource_spawns.append(resource_spawn)
				resource_count += 1
	
	# 生成森林生物
	var creature_count = 0
	for pos in positions:
		# 🔧 严格限制：只在空洞范围内的位置生成
		if not _is_position_in_cavity(pos):
			continue
			
		if randf() < 0.15: # 15%概率生成生物
			# 根据概率选择野兽类型
			var creature_type = _select_beast_type(BeastsTypes.FOREST_BEASTS)
			if creature_type != null:
				var beast_data = BeastsTypes.FOREST_BEASTS[creature_type]
				var level = randi_range(beast_data.level_range[0], beast_data.level_range[1])
				var creature_spawn = BeastsTypes.BeastSpawn.new(creature_type, pos, level, beast_data.hostile, beast_data.respawn_time)
				creature_spawns.append(creature_spawn)
				creature_count += 1
			
			# 创建实际的生物实例
			var beast_instance = create_beast_instance(creature_type)
			if beast_instance:
				# 🔧 使用正确的y坐标
				var spawn_position = WorldConstants.get_character_spawn_position(pos.x, pos.z)
				beast_instance.global_position = spawn_position
				beast_instance.name = BeastsTypes.get_beast_name(creature_type) + "_" + str(creature_count)
	
	LogManager.info("🌲 森林内容生成完成: %d 资源, %d 生物 (位置总数: %d)" % [resource_count, creature_count, positions.size()])

func _generate_lake_content(positions: Array) -> void:
	"""生成湖泊内容 - 严格限制在空洞范围内"""
	LogManager.info("🏞️ 生成湖泊内容...")
	
	# 🏝️ 生成湖心岛群（使用聚类算法）
	_generate_lake_islands_clustered(positions)
	
	# 生成湖泊资源
	var resource_count = 0
	for pos in positions:
		# 🔧 严格限制：只在空洞范围内的位置生成
		if not _is_position_in_cavity(pos):
			continue
			
		if randf() < 0.3: # 30%概率生成资源
			# 根据概率选择资源类型
			var resource_type = _select_resource_type(ResourceTypes.LAKE_RESOURCES)
			if resource_type != null:
				var resource_data = ResourceTypes.LAKE_RESOURCES[resource_type]
				var amount = randi_range(resource_data.amount_range[0], resource_data.amount_range[1])
				var resource_spawn = ResourceTypes.ResourceSpawn.new(resource_type, pos, amount, resource_data.respawn_time)
				resource_spawns.append(resource_spawn)
				resource_count += 1
	
	# 生成湖泊生物
	var creature_count = 0
	for pos in positions:
		# 🔧 严格限制：只在空洞范围内的位置生成
		if not _is_position_in_cavity(pos):
			continue
			
		if randf() < 0.15: # 15%概率生成生物
			# 根据概率选择野兽类型
			var creature_type = _select_beast_type(BeastsTypes.LAKE_BEASTS)
			if creature_type != null:
				var beast_data = BeastsTypes.LAKE_BEASTS[creature_type]
				var level = randi_range(beast_data.level_range[0], beast_data.level_range[1])
				var creature_spawn = BeastsTypes.BeastSpawn.new(creature_type, pos, level, beast_data.hostile, beast_data.respawn_time)
				creature_spawns.append(creature_spawn)
				creature_count += 1
			
			# 创建实际的生物实例
			var beast_instance = create_beast_instance(creature_type)
			if beast_instance:
				# 🔧 使用正确的y坐标
				var spawn_position = WorldConstants.get_character_spawn_position(pos.x, pos.z)
				beast_instance.global_position = spawn_position
				beast_instance.name = BeastsTypes.get_beast_name(creature_type) + "_" + str(creature_count)
	
	LogManager.info("🏞️ 湖泊内容生成完成: %d 资源, %d 生物" % [resource_count, creature_count])

func _generate_cave_content(positions: Array) -> void:
	"""生成洞穴内容 - 严格限制在空洞范围内"""
	LogManager.info("🕳️ 生成洞穴内容...")
	
	# 生成洞穴资源
	var resource_count = 0
	for pos in positions:
		# 🔧 严格限制：只在空洞范围内的位置生成
		if not _is_position_in_cavity(pos):
			continue
			
		if randf() < 0.3: # 30%概率生成资源
			# 根据概率选择资源类型
			var resource_type = _select_resource_type(ResourceTypes.CAVE_RESOURCES)
			if resource_type != null:
				var resource_data = ResourceTypes.CAVE_RESOURCES[resource_type]
				var amount = randi_range(resource_data.amount_range[0], resource_data.amount_range[1])
				var resource_spawn = ResourceTypes.ResourceSpawn.new(resource_type, pos, amount, resource_data.respawn_time)
				resource_spawns.append(resource_spawn)
				resource_count += 1
	
	# 生成洞穴生物
	var creature_count = 0
	for pos in positions:
		# 🔧 严格限制：只在空洞范围内的位置生成
		if not _is_position_in_cavity(pos):
			continue
			
		if randf() < 0.15: # 15%概率生成生物
			# 根据概率选择野兽类型
			var creature_type = _select_beast_type(BeastsTypes.CAVE_BEASTS)
			if creature_type != null:
				var beast_data = BeastsTypes.CAVE_BEASTS[creature_type]
				var level = randi_range(beast_data.level_range[0], beast_data.level_range[1])
				var creature_spawn = BeastsTypes.BeastSpawn.new(creature_type, pos, level, beast_data.hostile, beast_data.respawn_time)
				creature_spawns.append(creature_spawn)
				creature_count += 1
			
			# 创建实际的生物实例
			var beast_instance = create_beast_instance(creature_type)
			if beast_instance:
				# 🔧 使用正确的y坐标
				var spawn_position = WorldConstants.get_character_spawn_position(pos.x, pos.z)
				beast_instance.global_position = spawn_position
				beast_instance.name = BeastsTypes.get_beast_name(creature_type) + "_" + str(creature_count)
	
	LogManager.info("🕳️ 洞穴内容生成完成: %d 资源, %d 生物" % [resource_count, creature_count])

func _generate_wasteland_content(positions: Array) -> void:
	"""生成荒地内容 - 严格限制在空洞范围内"""
	LogManager.info("🏜️ 生成荒地内容...")
	
	# 生成荒地资源
	var resource_count = 0
	for pos in positions:
		# 🔧 严格限制：只在空洞范围内的位置生成
		if not _is_position_in_cavity(pos):
			continue
			
		if randf() < 0.3: # 30%概率生成资源
			# 根据概率选择资源类型
			var resource_type = _select_resource_type(ResourceTypes.WASTELAND_RESOURCES)
			if resource_type != null:
				var resource_data = ResourceTypes.WASTELAND_RESOURCES[resource_type]
				var amount = randi_range(resource_data.amount_range[0], resource_data.amount_range[1])
				var resource_spawn = ResourceTypes.ResourceSpawn.new(resource_type, pos, amount, resource_data.respawn_time)
				resource_spawns.append(resource_spawn)
				resource_count += 1
	
	# 生成荒地生物
	var creature_count = 0
	for pos in positions:
		# 🔧 严格限制：只在空洞范围内的位置生成
		if not _is_position_in_cavity(pos):
			continue
			
		if randf() < 0.15: # 15%概率生成生物
			# 根据概率选择野兽类型
			var creature_type = _select_beast_type(BeastsTypes.WASTELAND_BEASTS)
			if creature_type != null:
				var beast_data = BeastsTypes.WASTELAND_BEASTS[creature_type]
				var level = randi_range(beast_data.level_range[0], beast_data.level_range[1])
				var creature_spawn = BeastsTypes.BeastSpawn.new(creature_type, pos, level, beast_data.hostile, beast_data.respawn_time)
				creature_spawns.append(creature_spawn)
				creature_count += 1
			
			# 创建实际的生物实例
			var beast_instance = create_beast_instance(creature_type)
			if beast_instance:
				# 🔧 使用正确的y坐标
				var spawn_position = WorldConstants.get_character_spawn_position(pos.x, pos.z)
				beast_instance.global_position = spawn_position
				beast_instance.name = BeastsTypes.get_beast_name(creature_type) + "_" + str(creature_count)
	
	LogManager.info("🏜️ 荒地内容生成完成: %d 资源, %d 生物" % [resource_count, creature_count])

func _generate_grassland_content(positions: Array) -> void:
	"""生成草地内容 - 严格限制在空洞范围内"""
	LogManager.info("🌱 生成草地内容...")
	
	# 🌾 生成草原农田群（使用小范围聚类算法）
	_generate_grassland_fields_clustered(positions)
	
	# 🏔️ 生成草原丘陵群（使用聚类算法）
	_generate_grassland_hills_clustered(positions)
	
	# 🌊 生成草原湿地群（使用聚类算法）
	_generate_grassland_wetlands_clustered(positions)
	
	# 生成草地资源
	var resource_count = 0
	for pos in positions:
		# 🔧 严格限制：只在空洞范围内的位置生成
		if not _is_position_in_cavity(pos):
			continue
			
		if randf() < 0.3: # 30%概率生成资源
			# 根据概率选择资源类型
			var resource_type = _select_resource_type(ResourceTypes.GRASSLAND_RESOURCES)
			if resource_type != null:
				var resource_data = ResourceTypes.GRASSLAND_RESOURCES[resource_type]
				var amount = randi_range(resource_data.amount_range[0], resource_data.amount_range[1])
				var resource_spawn = ResourceTypes.ResourceSpawn.new(resource_type, pos, amount, resource_data.respawn_time)
				resource_spawns.append(resource_spawn)
				resource_count += 1
	
	# 生成草地生物
	var creature_count = 0
	for pos in positions:
		# 🔧 严格限制：只在空洞范围内的位置生成
		if not _is_position_in_cavity(pos):
			continue
			
		if randf() < 0.15: # 15%概率生成生物
			# 根据概率选择野兽类型
			var creature_type = _select_beast_type(BeastsTypes.GRASSLAND_BEASTS)
			if creature_type != null:
				var beast_data = BeastsTypes.GRASSLAND_BEASTS[creature_type]
				var level = randi_range(beast_data.level_range[0], beast_data.level_range[1])
				var creature_spawn = BeastsTypes.BeastSpawn.new(creature_type, pos, level, beast_data.hostile, beast_data.respawn_time)
				creature_spawns.append(creature_spawn)
				creature_count += 1
			
			# 创建实际的生物实例
			var beast_instance = create_beast_instance(creature_type)
			if beast_instance:
				# 🔧 使用正确的y坐标
				var spawn_position = WorldConstants.get_character_spawn_position(pos.x, pos.z)
				beast_instance.global_position = spawn_position
				beast_instance.name = BeastsTypes.get_beast_name(creature_type) + "_" + str(creature_count)
	
	LogManager.info("🌱 草地内容生成完成: %d 资源, %d 生物" % [resource_count, creature_count])

func _generate_grassland_hills_clustered(positions: Array) -> void:
	"""生成草原丘陵聚类区域"""
	if positions.is_empty():
		return
	
	var config = {
		"cluster_count": max(2, positions.size() / 200), # 每200个位置生成1个聚类
		"max_radius": 8.0, # 最大聚类半径
		"min_size": 3, # 最小聚类大小
		"max_size": 12 # 最大聚类大小
	}
	
	# 获取丘陵候选位置
	var hill_positions = _get_hill_candidate_positions(positions, config)
	if hill_positions.is_empty():
		return
	
	# 执行小范围聚类
	var clusters = _perform_small_range_clustering(hill_positions, config.cluster_count, config.max_radius)
	
	# 生成连接的丘陵区域
	_generate_connected_hills(clusters, config)

func _get_hill_candidate_positions(grassland_positions: Array, config: Dictionary) -> Array:
	"""获取丘陵候选位置 - 优先选择较高位置"""
	var candidates: Array = []
	var center = _calculate_center_position(grassland_positions)
	
	for pos in grassland_positions:
		# 检查是否在空洞范围内
		if not _is_position_in_cavity(pos):
			continue
		
		# 丘陵倾向于在边缘区域生成
		var distance_from_center = pos.distance_to(center)
		var max_distance = config.max_radius * 2
		
		# 距离中心较远的位置更可能成为丘陵
		if distance_from_center > max_distance * 0.3 and randf() < 0.15: # 15%概率
			candidates.append(pos)
	
	return candidates

func _generate_connected_hills(hill_clusters: Array, config: Dictionary) -> void:
	"""生成连接的丘陵区域"""
	var used_positions = {}
	
	for cluster in hill_clusters:
		if cluster.is_empty():
			continue
		
		# 为每个聚类生成一个丘陵区域
		var cluster_center = _calculate_center_position(cluster)
		var hill_size = randi_range(config.min_size, config.max_size)
		
		var new_hill = _generate_single_hill(cluster_center, hill_size, used_positions)
		if new_hill.size() > 0:
			# 连接到附近的丘陵
			_connect_to_nearby_hills(new_hill, hill_clusters, config.max_radius * 1.5)

func _generate_single_hill(center_pos: Vector3, size: int, used_positions: Dictionary) -> Array:
	"""生成单个丘陵 - 使用BFS算法"""
	var hill_positions: Array = []
	var queue: Array = [center_pos]
	var visited = {}
	
	while not queue.is_empty() and hill_positions.size() < size:
		var current_pos = queue.pop_front()
		
		if current_pos in visited or current_pos in used_positions:
			continue
		
		# 检查位置是否在空洞范围内
		if not _is_position_in_cavity(current_pos):
			continue
		
		visited[current_pos] = true
		used_positions[current_pos] = true
		hill_positions.append(current_pos)
		
		# 设置地块类型为丘陵
		if tile_manager:
			tile_manager.set_tile_type(current_pos, TileTypes.TileType.GRASSLAND_HILLS)
		
		# 添加邻居到队列（8方向）
		for dx in range(-1, 2):
			for dz in range(-1, 2):
				if dx == 0 and dz == 0:
					continue
				
				var neighbor_pos = current_pos + Vector3(dx, 0, dz)
				if neighbor_pos not in visited and neighbor_pos not in used_positions:
					queue.append(neighbor_pos)
	
	return hill_positions

func _connect_to_nearby_hills(new_hill: Array, existing_hills: Array, max_distance: float) -> void:
	"""连接到附近的丘陵"""
	if new_hill.is_empty() or existing_hills.is_empty():
		return
	
	# 找到最近的丘陵
	var closest_hill = null
	var min_distance = max_distance
	
	for existing_hill in existing_hills:
		if existing_hill.is_empty():
			continue
		
		var distance = new_hill[0].distance_to(existing_hill[0])
		if distance < min_distance:
			min_distance = distance
			closest_hill = existing_hill
	
	if closest_hill:
		_create_hill_connection(new_hill, closest_hill)

func _create_hill_connection(hill1: Array, hill2: Array) -> void:
	"""创建丘陵之间的连接"""
	if hill1.is_empty() or hill2.is_empty():
		return
	
	var start = hill1[0]
	var end = hill2[0]
	var path = _calculate_hill_path(start, end)
	
	# 在路径上设置丘陵地块
	for pos in path:
		if _is_position_in_cavity(pos) and tile_manager:
			tile_manager.set_tile_type(pos, TileTypes.TileType.GRASSLAND_HILLS)

func _calculate_hill_path(start: Vector3, end: Vector3) -> Array:
	"""计算丘陵路径"""
	var path: Array = []
	var steps = max(1, int(start.distance_to(end) / 2))
	
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var pos = start.lerp(end, t)
		path.append(pos.round())
	
	return path

func _generate_grassland_wetlands_clustered(positions: Array) -> void:
	"""生成草原湿地聚类区域"""
	if positions.is_empty():
		return
	
	var config = {
		"cluster_count": max(1, positions.size() / 300), # 每300个位置生成1个聚类
		"max_radius": 6.0, # 最大聚类半径
		"min_size": 2, # 最小聚类大小
		"max_size": 8 # 最大聚类大小
	}
	
	# 获取湿地候选位置
	var wetland_positions = _get_wetland_candidate_positions(positions, config)
	if wetland_positions.is_empty():
		return
	
	# 执行小范围聚类
	var clusters = _perform_small_range_clustering(wetland_positions, config.cluster_count, config.max_radius)
	
	# 生成连接的湿地区域
	_generate_connected_wetlands(clusters, config)

func _get_wetland_candidate_positions(grassland_positions: Array, config: Dictionary) -> Array:
	"""获取湿地候选位置 - 优先选择低洼位置"""
	var candidates: Array = []
	var center = _calculate_center_position(grassland_positions)
	
	for pos in grassland_positions:
		# 检查是否在空洞范围内
		if not _is_position_in_cavity(pos):
			continue
		
		# 湿地倾向于在中心区域生成
		var distance_from_center = pos.distance_to(center)
		var max_distance = config.max_radius * 2
		
		# 距离中心较近的位置更可能成为湿地
		if distance_from_center < max_distance * 0.6 and randf() < 0.12: # 12%概率
			candidates.append(pos)
	
	return candidates

func _generate_connected_wetlands(wetland_clusters: Array, config: Dictionary) -> void:
	"""生成连接的湿地区域"""
	var used_positions = {}
	
	for cluster in wetland_clusters:
		if cluster.is_empty():
			continue
		
		# 为每个聚类生成一个湿地区域
		var cluster_center = _calculate_center_position(cluster)
		var wetland_size = randi_range(config.min_size, config.max_size)
		
		var new_wetland = _generate_single_wetland(cluster_center, wetland_size, used_positions)
		if new_wetland.size() > 0:
			# 连接到附近的湿地
			_connect_to_nearby_wetlands(new_wetland, wetland_clusters, config.max_radius * 1.5)

func _generate_single_wetland(center_pos: Vector3, size: int, used_positions: Dictionary) -> Array:
	"""生成单个湿地 - 使用BFS算法"""
	var wetland_positions: Array = []
	var queue: Array = [center_pos]
	var visited = {}
	
	while not queue.is_empty() and wetland_positions.size() < size:
		var current_pos = queue.pop_front()
		
		if current_pos in visited or current_pos in used_positions:
			continue
		
		# 检查位置是否在空洞范围内
		if not _is_position_in_cavity(current_pos):
			continue
		
		visited[current_pos] = true
		used_positions[current_pos] = true
		wetland_positions.append(current_pos)
		
		# 设置地块类型为湿地
		if tile_manager:
			tile_manager.set_tile_type(current_pos, TileTypes.TileType.GRASSLAND_WETLANDS)
		
		# 添加邻居到队列（4方向，湿地更紧凑）
		var directions = [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]
		for direction in directions:
			var neighbor_pos = current_pos + direction
			if neighbor_pos not in visited and neighbor_pos not in used_positions:
				queue.append(neighbor_pos)
	
	return wetland_positions

func _connect_to_nearby_wetlands(new_wetland: Array, existing_wetlands: Array, max_distance: float) -> void:
	"""连接到附近的湿地"""
	if new_wetland.is_empty() or existing_wetlands.is_empty():
		return
	
	# 找到最近的湿地
	var closest_wetland = null
	var min_distance = max_distance
	
	for existing_wetland in existing_wetlands:
		if existing_wetland.is_empty():
			continue
		
		var distance = new_wetland[0].distance_to(existing_wetland[0])
		if distance < min_distance:
			min_distance = distance
			closest_wetland = existing_wetland
	
	if closest_wetland:
		_create_wetland_connection(new_wetland, closest_wetland)

func _create_wetland_connection(wetland1: Array, wetland2: Array) -> void:
	"""创建湿地之间的连接"""
	if wetland1.is_empty() or wetland2.is_empty():
		return
	
	var start = wetland1[0]
	var end = wetland2[0]
	var path = _calculate_wetland_path(start, end)
	
	# 在路径上设置湿地地块
	for pos in path:
		if _is_position_in_cavity(pos) and tile_manager:
			tile_manager.set_tile_type(pos, TileTypes.TileType.GRASSLAND_WETLANDS)

func _calculate_wetland_path(start: Vector3, end: Vector3) -> Array:
	"""计算湿地路径"""
	var path: Array = []
	var steps = max(1, int(start.distance_to(end) / 2))
	
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var pos = start.lerp(end, t)
		path.append(pos.round())
	
	return path

func _generate_primitive_content(positions: Array) -> void:
	"""生成原始生态内容 - 严格限制在空洞范围内"""
	LogManager.info("🌿 生成原始生态内容...")
	
	# 🌋 生成原始火山群（使用聚类算法）
	_generate_primitive_volcano_clustered(positions)
	
	# 🌊 生成原始沼泽群（使用聚类算法）
	_generate_primitive_swamp_clustered(positions)
	
	# 生成原始生态资源
	var resource_count = 0
	for pos in positions:
		# 🔧 严格限制：只在空洞范围内的位置生成
		if not _is_position_in_cavity(pos):
			continue
			
		if randf() < 0.08: # 8%概率生成资源
			# 根据概率选择资源类型
			var resource_type = _select_resource_type(ResourceTypes.PRIMITIVE_RESOURCES)
			if resource_type != null:
				var resource_data = ResourceTypes.PRIMITIVE_RESOURCES[resource_type]
				var amount = randi_range(resource_data.amount_range[0], resource_data.amount_range[1])
				var resource_spawn = ResourceTypes.ResourceSpawn.new(resource_type, pos, amount, resource_data.respawn_time)
				resource_spawns.append(resource_spawn)
				resource_count += 1
	
	# 生成原始生态生物
	var creature_count = 0
	for pos in positions:
		# 🔧 严格限制：只在空洞范围内的位置生成
		if not _is_position_in_cavity(pos):
			continue
			
		if randf() < 0.03: # 3%概率生成生物
			# 根据概率选择野兽类型
			var creature_type = _select_beast_type(BeastsTypes.PRIMITIVE_BEASTS)
			if creature_type != null:
				var beast_data = BeastsTypes.PRIMITIVE_BEASTS[creature_type]
				var level = randi_range(beast_data.level_range[0], beast_data.level_range[1])
				var creature_spawn = BeastsTypes.BeastSpawn.new(creature_type, pos, level, beast_data.hostile, beast_data.respawn_time)
				creature_spawns.append(creature_spawn)
				creature_count += 1
			
			# 创建实际的生物实例
			var beast_instance = create_beast_instance(creature_type)
			if beast_instance:
				# 🔧 使用正确的y坐标
				var spawn_position = WorldConstants.get_character_spawn_position(pos.x, pos.z)
				beast_instance.global_position = spawn_position
				beast_instance.name = BeastsTypes.get_beast_name(creature_type) + "_" + str(creature_count)
	
	LogManager.info("🌿 原始生态内容生成完成: %d 资源, %d 生物" % [resource_count, creature_count])

func _generate_primitive_volcano_clustered(positions: Array) -> void:
	"""生成原始火山聚类区域"""
	if positions.is_empty():
		return
	
	var config = {
		"cluster_count": max(1, positions.size() / 400), # 每400个位置生成1个聚类
		"max_radius": 10.0, # 最大聚类半径
		"min_size": 4, # 最小聚类大小
		"max_size": 15 # 最大聚类大小
	}
	
	# 获取火山候选位置
	var volcano_positions = _get_volcano_candidate_positions(positions, config)
	if volcano_positions.is_empty():
		return
	
	# 执行小范围聚类
	var clusters = _perform_small_range_clustering(volcano_positions, config.cluster_count, config.max_radius)
	
	# 生成连接的火山区域
	_generate_connected_volcanoes(clusters, config)

func _get_volcano_candidate_positions(primitive_positions: Array, config: Dictionary) -> Array:
	"""获取火山候选位置 - 优先选择中心区域"""
	var candidates: Array = []
	var center = _calculate_center_position(primitive_positions)
	
	for pos in primitive_positions:
		# 检查是否在空洞范围内
		if not _is_position_in_cavity(pos):
			continue
		
		# 火山倾向于在中心区域生成
		var distance_from_center = pos.distance_to(center)
		var max_distance = config.max_radius * 2
		
		# 距离中心较近的位置更可能成为火山
		if distance_from_center < max_distance * 0.5 and randf() < 0.08: # 8%概率
			candidates.append(pos)
	
	return candidates

func _generate_connected_volcanoes(volcano_clusters: Array, config: Dictionary) -> void:
	"""生成连接的火山区域"""
	var used_positions = {}
	
	for cluster in volcano_clusters:
		if cluster.is_empty():
			continue
		
		# 为每个聚类生成一个火山区域
		var cluster_center = _calculate_center_position(cluster)
		var volcano_size = randi_range(config.min_size, config.max_size)
		
		var new_volcano = _generate_single_volcano(cluster_center, volcano_size, used_positions)
		if new_volcano.size() > 0:
			# 连接到附近的火山
			_connect_to_nearby_volcanoes(new_volcano, volcano_clusters, config.max_radius * 2.0)

func _generate_single_volcano(center_pos: Vector3, size: int, used_positions: Dictionary) -> Array:
	"""生成单个火山 - 使用BFS算法"""
	var volcano_positions: Array = []
	var queue: Array = [center_pos]
	var visited = {}
	
	while not queue.is_empty() and volcano_positions.size() < size:
		var current_pos = queue.pop_front()
		
		if current_pos in visited or current_pos in used_positions:
			continue
		
		# 检查位置是否在空洞范围内
		if not _is_position_in_cavity(current_pos):
			continue
		
		visited[current_pos] = true
		used_positions[current_pos] = true
		volcano_positions.append(current_pos)
		
		# 设置地块类型为火山
		if tile_manager:
			tile_manager.set_tile_type(current_pos, TileTypes.TileType.PRIMITIVE_VOLCANO)
		
		# 添加邻居到队列（8方向）
		for dx in range(-1, 2):
			for dz in range(-1, 2):
				if dx == 0 and dz == 0:
					continue
				
				var neighbor_pos = current_pos + Vector3(dx, 0, dz)
				if neighbor_pos not in visited and neighbor_pos not in used_positions:
					queue.append(neighbor_pos)
	
	return volcano_positions

func _connect_to_nearby_volcanoes(new_volcano: Array, existing_volcanoes: Array, max_distance: float) -> void:
	"""连接到附近的火山"""
	if new_volcano.is_empty() or existing_volcanoes.is_empty():
		return
	
	# 找到最近的火山
	var closest_volcano = null
	var min_distance = max_distance
	
	for existing_volcano in existing_volcanoes:
		if existing_volcano.is_empty():
			continue
		
		var distance = new_volcano[0].distance_to(existing_volcano[0])
		if distance < min_distance:
			min_distance = distance
			closest_volcano = existing_volcano
	
	if closest_volcano:
		_create_volcano_connection(new_volcano, closest_volcano)

func _create_volcano_connection(volcano1: Array, volcano2: Array) -> void:
	"""创建火山之间的连接"""
	if volcano1.is_empty() or volcano2.is_empty():
		return
	
	var start = volcano1[0]
	var end = volcano2[0]
	var path = _calculate_volcano_path(start, end)
	
	# 在路径上设置火山地块
	for pos in path:
		if _is_position_in_cavity(pos) and tile_manager:
			tile_manager.set_tile_type(pos, TileTypes.TileType.PRIMITIVE_VOLCANO)

func _calculate_volcano_path(start: Vector3, end: Vector3) -> Array:
	"""计算火山路径"""
	var path: Array = []
	var steps = max(1, int(start.distance_to(end) / 3))
	
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var pos = start.lerp(end, t)
		path.append(pos.round())
	
	return path

func _generate_primitive_swamp_clustered(positions: Array) -> void:
	"""生成原始沼泽聚类区域"""
	if positions.is_empty():
		return
	
	var config = {
		"cluster_count": max(2, positions.size() / 350), # 每350个位置生成1个聚类
		"max_radius": 8.0, # 最大聚类半径
		"min_size": 3, # 最小聚类大小
		"max_size": 12 # 最大聚类大小
	}
	
	# 获取沼泽候选位置
	var swamp_positions = _get_swamp_candidate_positions(positions, config)
	if swamp_positions.is_empty():
		return
	
	# 执行小范围聚类
	var clusters = _perform_small_range_clustering(swamp_positions, config.cluster_count, config.max_radius)
	
	# 生成连接的沼泽区域
	_generate_connected_swamps(clusters, config)

func _get_swamp_candidate_positions(primitive_positions: Array, config: Dictionary) -> Array:
	"""获取沼泽候选位置 - 优先选择边缘区域"""
	var candidates: Array = []
	var center = _calculate_center_position(primitive_positions)
	
	for pos in primitive_positions:
		# 检查是否在空洞范围内
		if not _is_position_in_cavity(pos):
			continue
		
		# 沼泽倾向于在边缘区域生成
		var distance_from_center = pos.distance_to(center)
		var max_distance = config.max_radius * 2
		
		# 距离中心较远的位置更可能成为沼泽
		if distance_from_center > max_distance * 0.4 and randf() < 0.10: # 10%概率
			candidates.append(pos)
	
	return candidates

func _generate_connected_swamps(swamp_clusters: Array, config: Dictionary) -> void:
	"""生成连接的沼泽区域"""
	var used_positions = {}
	
	for cluster in swamp_clusters:
		if cluster.is_empty():
			continue
		
		# 为每个聚类生成一个沼泽区域
		var cluster_center = _calculate_center_position(cluster)
		var swamp_size = randi_range(config.min_size, config.max_size)
		
		var new_swamp = _generate_single_swamp(cluster_center, swamp_size, used_positions)
		if new_swamp.size() > 0:
			# 连接到附近的沼泽
			_connect_to_nearby_swamps(new_swamp, swamp_clusters, config.max_radius * 1.8)

func _generate_single_swamp(center_pos: Vector3, size: int, used_positions: Dictionary) -> Array:
	"""生成单个沼泽 - 使用BFS算法"""
	var swamp_positions: Array = []
	var queue: Array = [center_pos]
	var visited = {}
	
	while not queue.is_empty() and swamp_positions.size() < size:
		var current_pos = queue.pop_front()
		
		if current_pos in visited or current_pos in used_positions:
			continue
		
		# 检查位置是否在空洞范围内
		if not _is_position_in_cavity(current_pos):
			continue
		
		visited[current_pos] = true
		used_positions[current_pos] = true
		swamp_positions.append(current_pos)
		
		# 设置地块类型为沼泽
		if tile_manager:
			tile_manager.set_tile_type(current_pos, TileTypes.TileType.PRIMITIVE_SWAMP)
		
		# 添加邻居到队列（4方向，沼泽更紧凑）
		var directions = [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]
		for direction in directions:
			var neighbor_pos = current_pos + direction
			if neighbor_pos not in visited and neighbor_pos not in used_positions:
				queue.append(neighbor_pos)
	
	return swamp_positions

func _connect_to_nearby_swamps(new_swamp: Array, existing_swamps: Array, max_distance: float) -> void:
	"""连接到附近的沼泽"""
	if new_swamp.is_empty() or existing_swamps.is_empty():
		return
	
	# 找到最近的沼泽
	var closest_swamp = null
	var min_distance = max_distance
	
	for existing_swamp in existing_swamps:
		if existing_swamp.is_empty():
			continue
		
		var distance = new_swamp[0].distance_to(existing_swamp[0])
		if distance < min_distance:
			min_distance = distance
			closest_swamp = existing_swamp
	
	if closest_swamp:
		_create_swamp_connection(new_swamp, closest_swamp)

func _create_swamp_connection(swamp1: Array, swamp2: Array) -> void:
	"""创建沼泽之间的连接"""
	if swamp1.is_empty() or swamp2.is_empty():
		return
	
	var start = swamp1[0]
	var end = swamp2[0]
	var path = _calculate_swamp_path(start, end)
	
	# 在路径上设置沼泽地块
	for pos in path:
		if _is_position_in_cavity(pos) and tile_manager:
			tile_manager.set_tile_type(pos, TileTypes.TileType.PRIMITIVE_SWAMP)

func _calculate_swamp_path(start: Vector3, end: Vector3) -> Array:
	"""计算沼泽路径"""
	var path: Array = []
	var steps = max(1, int(start.distance_to(end) / 2))
	
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var pos = start.lerp(end, t)
		path.append(pos.round())
	
	return path

func _generate_dead_land_content(positions: Array) -> void:
	"""生成死地内容 - 严格限制在空洞范围内"""
	LogManager.info("💀 生成死地内容...")
	
	# 生成死地资源
	var resource_count = 0
	for pos in positions:
		# 🔧 严格限制：只在空洞范围内的位置生成
		if not _is_position_in_cavity(pos):
			continue
			
		if randf() < 0.3: # 30%概率生成资源
			# 根据概率选择资源类型
			var resource_type = _select_resource_type(ResourceTypes.DEAD_LAND_RESOURCES)
			if resource_type != null:
				var resource_data = ResourceTypes.DEAD_LAND_RESOURCES[resource_type]
				var amount = randi_range(resource_data.amount_range[0], resource_data.amount_range[1])
				var resource_spawn = ResourceTypes.ResourceSpawn.new(resource_type, pos, amount, resource_data.respawn_time)
				resource_spawns.append(resource_spawn)
				resource_count += 1
	
	# 生成死地生物
	var creature_count = 0
	for pos in positions:
		# 🔧 严格限制：只在空洞范围内的位置生成
		if not _is_position_in_cavity(pos):
			continue
			
		if randf() < 0.15: # 15%概率生成生物
			# 根据概率选择野兽类型
			var creature_type = _select_beast_type(BeastsTypes.DEAD_LAND_BEASTS)
			if creature_type != null:
				var beast_data = BeastsTypes.DEAD_LAND_BEASTS[creature_type]
				var level = randi_range(beast_data.level_range[0], beast_data.level_range[1])
				var creature_spawn = BeastsTypes.BeastSpawn.new(creature_type, pos, level, beast_data.hostile, beast_data.respawn_time)
				creature_spawns.append(creature_spawn)
				creature_count += 1
			
			# 创建实际的生物实例
			var beast_instance = create_beast_instance(creature_type)
			if beast_instance:
				# 🔧 使用正确的y坐标
				var spawn_position = WorldConstants.get_character_spawn_position(pos.x, pos.z)
				beast_instance.global_position = spawn_position
				beast_instance.name = BeastsTypes.get_beast_name(creature_type) + "_" + str(creature_count)
	
	LogManager.info("💀 死地内容生成完成: %d 资源, %d 生物" % [resource_count, creature_count])

func _generate_lake_islands_clustered(positions: Array) -> void:
	"""使用聚类算法生成湖心岛群"""
	if not tile_manager:
		LogManager.error("EcosystemManager: TileManager未设置，无法生成湖心岛")
		return
	
	# 🏝️ 湖心岛生成参数
	var island_config = {
		"cluster_count": 2, # 湖心岛群数量
		"min_islands_per_cluster": 2, # 每个群最少岛屿数
		"max_islands_per_cluster": 5, # 每个群最多岛屿数
		"cluster_radius": 8, # 群内岛屿最大距离
		"min_distance_between_clusters": 15, # 群间最小距离
		"island_size_range": [1, 3], # 单个岛屿大小范围
		"prefer_center": true # 优先在深水区中心生成
	}
	
	# 筛选出浅水区和深水区的位置
	var water_positions = []
	for pos in positions:
		if not _is_position_in_cavity(pos):
			continue
		
		# 检查是否为浅水区或深水区
		var tile_data = tile_manager.get_tile_data(pos)
		if tile_data and tile_data.type in [TileTypes.TileType.LAKE_SHALLOW, TileTypes.TileType.LAKE_DEEP]:
			water_positions.append(pos)
	
	if water_positions.size() < 10:
		LogManager.warning("湖泊区域太小，跳过湖心岛生成")
		return
	
	LogManager.info("🏝️ 开始生成湖心岛群，水域位置数: %d" % water_positions.size())
	
	# 🎯 第一步：找到水域中心点作为候选位置
	var water_center = _calculate_center_position(water_positions)
	var candidate_positions = _get_island_candidate_positions(water_positions, water_center, island_config)
	
	# 🎯 第二步：使用K-means聚类算法分组候选位置
	var clusters = _perform_kmeans_clustering(candidate_positions, island_config.cluster_count, island_config.cluster_radius)
	
	# 🎯 第三步：为每个聚类生成连接的湖心岛群
	var island_count = 0
	for i in range(clusters.size()):
		var cluster = clusters[i]
		if cluster.size() < island_config.min_islands_per_cluster:
			continue
		
		# 限制每个群的岛屿数量
		var max_islands = min(cluster.size(), island_config.max_islands_per_cluster)
		var selected_islands = cluster.slice(0, max_islands)
		
		# 生成连接的岛屿
		var cluster_islands = _generate_connected_islands(selected_islands, island_config)
		island_count += cluster_islands.size()
		
		LogManager.info("🏝️ 湖心岛群 %d: 生成 %d 个岛屿" % [i + 1, cluster_islands.size()])
	
	LogManager.info("🏝️ 湖心岛生成完成，总计: %d 个岛屿" % island_count)

func _calculate_center_position(positions: Array) -> Vector3:
	"""计算位置集合的中心点"""
	if positions.is_empty():
		return Vector3.ZERO
	
	var sum_x = 0.0
	var sum_z = 0.0
	
	for pos in positions:
		sum_x += pos.x
		sum_z += pos.z
	
	return Vector3(sum_x / positions.size(), 0, sum_z / positions.size())

func _get_island_candidate_positions(water_positions: Array, center: Vector3, config: Dictionary) -> Array:
	"""获取湖心岛候选位置（优先深水区中心）"""
	var candidates = []
	var deep_water_positions = []
	var shallow_water_positions = []
	
	# 分类水域位置
	for pos in water_positions:
		var tile_data = tile_manager.get_tile_data(pos)
		if tile_data:
			if tile_data.type == TileTypes.TileType.LAKE_DEEP:
				deep_water_positions.append(pos)
			elif tile_data.type == TileTypes.TileType.LAKE_SHALLOW:
				shallow_water_positions.append(pos)
	
	# 🎯 优先选择深水区位置，按距离中心远近排序
	var sorted_deep_water = deep_water_positions.duplicate()
	sorted_deep_water.sort_custom(func(a, b): return a.distance_to(center) < b.distance_to(center))
	
	# 选择深水区候选位置（最多70%）
	var deep_count = min(sorted_deep_water.size(), int(water_positions.size() * 0.3))
	for i in range(deep_count):
		candidates.append(sorted_deep_water[i])
	
	# 选择浅水区候选位置（最多30%）
	var shallow_count = min(shallow_water_positions.size(), int(water_positions.size() * 0.2))
	for i in range(shallow_count):
		var pos = shallow_water_positions[randi() % shallow_water_positions.size()]
		if pos not in candidates:
			candidates.append(pos)
	
	return candidates

func _perform_kmeans_clustering(positions: Array, cluster_count: int, max_radius: float) -> Array:
	"""执行K-means聚类算法"""
	if positions.size() <= cluster_count:
		# 如果位置数量少于聚类数量，每个位置作为一个聚类
		return positions.map(func(pos): return [pos])
	
	# 初始化聚类中心
	var centers = []
	var clusters = []
	
	# 随机选择初始聚类中心
	var shuffled_positions = positions.duplicate()
	shuffled_positions.shuffle()
	
	for i in range(min(cluster_count, positions.size())):
		centers.append(shuffled_positions[i])
		clusters.append([])
	
	# 迭代优化聚类
	var max_iterations = 10
	for iteration in range(max_iterations):
		# 清空聚类
		for i in range(clusters.size()):
			clusters[i].clear()
		
		# 将每个位置分配到最近的聚类中心
		for pos in positions:
			var min_distance = INF
			var best_cluster = 0
			
			for i in range(centers.size()):
				var distance = pos.distance_to(centers[i])
				if distance < min_distance:
					min_distance = distance
					best_cluster = i
			
			# 检查是否在最大半径内
			if min_distance <= max_radius:
				clusters[best_cluster].append(pos)
			else:
				# 如果距离太远，创建新的聚类
				if clusters.size() < cluster_count:
					centers.append(pos)
					clusters.append([pos])
		
		# 更新聚类中心
		var centers_changed = false
		for i in range(clusters.size()):
			if clusters[i].is_empty():
				continue
			
			var new_center = _calculate_center_position(clusters[i])
			if new_center.distance_to(centers[i]) > 1.0:
				centers[i] = new_center
				centers_changed = true
		
		# 如果中心没有变化，提前结束
		if not centers_changed:
			break
	
	# 过滤掉空的聚类
	var valid_clusters = []
	for cluster in clusters:
		if not cluster.is_empty():
			valid_clusters.append(cluster)
	
	return valid_clusters

func _generate_connected_islands(island_positions: Array, config: Dictionary) -> Array:
	"""为聚类生成连接的湖心岛群"""
	var islands = []
	var used_positions = {}
	
	# 按距离排序，确保岛屿连接性
	island_positions.sort_custom(func(a, b): return a.distance_to(Vector3.ZERO) < b.distance_to(Vector3.ZERO))
	
	for pos in island_positions:
		# 检查是否已经被使用
		var pos_key = str(int(pos.x)) + "," + str(int(pos.z))
		if pos_key in used_positions:
			continue
		
		# 生成单个岛屿
		var island_size = randi_range(config.island_size_range[0], config.island_size_range[1])
		var island_tiles = _generate_single_island(pos, island_size, used_positions)
		
		if island_tiles.size() > 0:
			islands.append(island_tiles)
			
			# 尝试连接到附近的岛屿
			_connect_to_nearby_islands(island_tiles, islands, config.cluster_radius)
	
	return islands

func _generate_single_island(center_pos: Vector3, size: int, used_positions: Dictionary) -> Array:
	"""生成单个岛屿"""
	var island_tiles = []
	var queue = [center_pos]
	var processed = {}
	
	# 使用BFS算法扩展岛屿
	while not queue.is_empty() and island_tiles.size() < size:
		var current_pos = queue.pop_front()
		var pos_key = str(int(current_pos.x)) + "," + str(int(current_pos.z))
		
		if pos_key in processed or pos_key in used_positions:
			continue
		
		# 检查位置是否在水域中
		if not _is_position_in_cavity(current_pos):
			continue
		
		var tile_data = tile_manager.get_tile_data(current_pos)
		if not tile_data or tile_data.type not in [TileTypes.TileType.LAKE_SHALLOW, TileTypes.TileType.LAKE_DEEP]:
			continue
		
		# 设置为湖心岛
		tile_manager.set_tile_type(current_pos, TileTypes.TileType.LAKE_ISLAND)
		island_tiles.append(current_pos)
		used_positions[pos_key] = true
		processed[pos_key] = true
		
		# 添加相邻位置到队列
		var neighbors = [
			Vector3(current_pos.x + 1, 0, current_pos.z),
			Vector3(current_pos.x - 1, 0, current_pos.z),
			Vector3(current_pos.x, 0, current_pos.z + 1),
			Vector3(current_pos.x, 0, current_pos.z - 1)
		]
		
		for neighbor in neighbors:
			var neighbor_key = str(int(neighbor.x)) + "," + str(int(neighbor.z))
			if neighbor_key not in processed and neighbor_key not in used_positions:
				queue.append(neighbor)
	
	return island_tiles

func _connect_to_nearby_islands(new_island: Array, existing_islands: Array, max_distance: float) -> void:
	"""尝试将新岛屿连接到附近的岛屿"""
	if existing_islands.size() <= 1:
		return
	
	var new_center = _calculate_center_position(new_island)
	var closest_island = null
	var min_distance = INF
	
	# 找到最近的岛屿
	for i in range(existing_islands.size() - 1): # 排除刚添加的新岛屿
		var island = existing_islands[i]
		var island_center = _calculate_center_position(island)
		var distance = new_center.distance_to(island_center)
		
		if distance < min_distance and distance <= max_distance:
			min_distance = distance
			closest_island = island
	
	# 如果找到合适的岛屿，尝试创建连接
	if closest_island:
		_create_island_bridge(new_island, closest_island)

func _create_island_bridge(island1: Array, island2: Array) -> void:
	"""在两个岛屿之间创建桥梁连接"""
	if island1.is_empty() or island2.is_empty():
		return
	
	var center1 = _calculate_center_position(island1)
	var center2 = _calculate_center_position(island2)
	
	# 计算连接路径
	var path = _calculate_bridge_path(center1, center2)
	
	# 在路径上设置岛屿地块
	for pos in path:
		if _is_position_in_cavity(pos):
			var tile_data = tile_manager.get_tile_data(pos)
			if tile_data and tile_data.type in [TileTypes.TileType.LAKE_SHALLOW, TileTypes.TileType.LAKE_DEEP]:
				tile_manager.set_tile_type(pos, TileTypes.TileType.LAKE_ISLAND)

func _calculate_bridge_path(start: Vector3, end: Vector3) -> Array:
	"""计算两点之间的桥梁路径"""
	var path = []
	var steps = int(max(abs(end.x - start.x), abs(end.z - start.z)))
	
	if steps == 0:
		return [start]
	
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var x = int(lerp(start.x, end.x, t))
		var z = int(lerp(start.z, end.z, t))
		path.append(Vector3(x, 0, z))
	
	return path

func _generate_grassland_fields_clustered(positions: Array) -> void:
	"""使用小范围聚类算法生成草原农田群"""
	if not tile_manager:
		LogManager.error("EcosystemManager: TileManager未设置，无法生成草原农田")
		return
	
	# 🌾 草原农田生成参数
	var fields_config = {
		"cluster_count": 3, # 农田群数量
		"min_fields_per_cluster": 4, # 每个群最少农田数
		"max_fields_per_cluster": 12, # 每个群最多农田数
		"cluster_radius": 6, # 群内农田最大距离（小范围）
		"min_distance_between_clusters": 12, # 群间最小距离
		"field_size_range": [2, 5], # 单个农田大小范围
		"field_density": 0.15, # 农田密度
		"prefer_flat_areas": true # 优先在平坦区域生成
	}
	
	# 筛选出草地位置
	var grassland_positions = []
	for pos in positions:
		if not _is_position_in_cavity(pos):
			continue
		
		# 检查是否为草地类型
		var tile_data = tile_manager.get_tile_data(pos)
		if tile_data and tile_data.type in [
			TileTypes.TileType.GRASSLAND_PLAINS,
			TileTypes.TileType.GRASSLAND_HILLS,
			TileTypes.TileType.GRASSLAND_WETLANDS,
			TileTypes.TileType.GRASSLAND_FIELDS
		]:
			grassland_positions.append(pos)
	
	if grassland_positions.size() < 20:
		LogManager.warning("草地区域太小，跳过草原农田生成")
		return
	
	LogManager.info("🌾 开始生成草原农田群，草地位置数: %d" % grassland_positions.size())
	
	# 🎯 第一步：选择适合农田的候选位置
	var candidate_positions = _get_farmland_candidate_positions(grassland_positions, fields_config)
	
	# 🎯 第二步：使用小范围K-means聚类算法分组候选位置
	var clusters = _perform_small_range_clustering(candidate_positions, fields_config.cluster_count, fields_config.cluster_radius)
	
	# 🎯 第三步：为每个聚类生成连接的农田群
	var field_count = 0
	for i in range(clusters.size()):
		var cluster = clusters[i]
		if cluster.size() < fields_config.min_fields_per_cluster:
			continue
		
		# 限制每个群的农田数量
		var max_fields = min(cluster.size(), fields_config.max_fields_per_cluster)
		var selected_fields = cluster.slice(0, max_fields)
		
		# 生成连接的农田
		var cluster_fields = _generate_connected_farmlands(selected_fields, fields_config)
		field_count += cluster_fields.size()
		
		LogManager.info("🌾 草原农田群 %d: 生成 %d 个农田" % [i + 1, cluster_fields.size()])
	
	LogManager.info("🌾 草原农田生成完成，总计: %d 个农田" % field_count)

func _get_farmland_candidate_positions(grassland_positions: Array, config: Dictionary) -> Array:
	"""获取农田候选位置（优先平坦区域）"""
	var candidates = []
	var flat_positions = []
	var hilly_positions = []
	
	# 分类草地位置
	for pos in grassland_positions:
		var tile_data = tile_manager.get_tile_data(pos)
		if tile_data:
			if tile_data.type in [TileTypes.TileType.GRASSLAND_PLAINS, TileTypes.TileType.GRASSLAND_FIELDS]:
				flat_positions.append(pos)
			elif tile_data.type in [TileTypes.TileType.GRASSLAND_HILLS, TileTypes.TileType.GRASSLAND_WETLANDS]:
				hilly_positions.append(pos)
	
	# 🎯 优先选择平坦区域位置（80%）
	var flat_count = int(grassland_positions.size() * config.field_density * 0.8)
	for i in range(min(flat_count, flat_positions.size())):
		candidates.append(flat_positions[randi() % flat_positions.size()])
	
	# 选择丘陵区域位置（20%）
	var hilly_count = int(grassland_positions.size() * config.field_density * 0.2)
	for i in range(min(hilly_count, hilly_positions.size())):
		candidates.append(hilly_positions[randi() % hilly_positions.size()])
	
	return candidates

func _perform_small_range_clustering(positions: Array, cluster_count: int, max_radius: float) -> Array:
	"""执行小范围聚类算法（优化的K-means）"""
	if positions.size() <= cluster_count:
		# 如果位置数量少于聚类数量，每个位置作为一个聚类
		return positions.map(func(pos): return [pos])
	
	# 初始化聚类中心
	var centers = []
	var clusters = []
	
	# 随机选择初始聚类中心
	var shuffled_positions = positions.duplicate()
	shuffled_positions.shuffle()
	
	for i in range(min(cluster_count, positions.size())):
		centers.append(shuffled_positions[i])
		clusters.append([])
	
	# 迭代优化聚类（减少迭代次数，适合小范围）
	var max_iterations = 6
	for iteration in range(max_iterations):
		# 清空聚类
		for i in range(clusters.size()):
			clusters[i].clear()
		
		# 将每个位置分配到最近的聚类中心
		for pos in positions:
			var min_distance = INF
			var best_cluster = 0
			
			for i in range(centers.size()):
				var distance = pos.distance_to(centers[i])
				if distance < min_distance:
					min_distance = distance
					best_cluster = i
			
			# 检查是否在最大半径内（小范围限制）
			if min_distance <= max_radius:
				clusters[best_cluster].append(pos)
			else:
				# 如果距离太远，创建新的聚类（限制数量）
				if clusters.size() < cluster_count * 2: # 允许适度扩展
					centers.append(pos)
					clusters.append([pos])
		
		# 更新聚类中心
		var centers_changed = false
		for i in range(clusters.size()):
			if clusters[i].is_empty():
				continue
			
			var new_center = _calculate_center_position(clusters[i])
			if new_center.distance_to(centers[i]) > 0.5: # 更小的变化阈值
				centers[i] = new_center
				centers_changed = true
		
		# 如果中心没有变化，提前结束
		if not centers_changed:
			break
	
	# 过滤掉空的聚类和过小的聚类
	var valid_clusters = []
	for cluster in clusters:
		if cluster.size() >= 2: # 至少需要2个位置才能形成农田群
			valid_clusters.append(cluster)
	
	return valid_clusters

func _generate_connected_farmlands(field_positions: Array, config: Dictionary) -> Array:
	"""为聚类生成连接的农田群"""
	var farmlands = []
	var used_positions = {}
	
	# 按距离排序，确保农田连接性
	field_positions.sort_custom(func(a, b): return a.distance_to(Vector3.ZERO) < b.distance_to(Vector3.ZERO))
	
	for pos in field_positions:
		# 检查是否已经被使用
		var pos_key = str(int(pos.x)) + "," + str(int(pos.z))
		if pos_key in used_positions:
			continue
		
		# 生成单个农田
		var field_size = randi_range(config.field_size_range[0], config.field_size_range[1])
		var field_tiles = _generate_single_farmland(pos, field_size, used_positions)
		
		if field_tiles.size() > 0:
			farmlands.append(field_tiles)
			
			# 尝试连接到附近的农田
			_connect_to_nearby_farmlands(field_tiles, farmlands, config.cluster_radius)
	
	return farmlands

func _generate_single_farmland(center_pos: Vector3, size: int, used_positions: Dictionary) -> Array:
	"""生成单个农田"""
	var farmland_tiles = []
	var queue = [center_pos]
	var processed = {}
	
	# 使用BFS算法扩展农田
	while not queue.is_empty() and farmland_tiles.size() < size:
		var current_pos = queue.pop_front()
		var pos_key = str(int(current_pos.x)) + "," + str(int(current_pos.z))
		
		if pos_key in processed or pos_key in used_positions:
			continue
		
		# 检查位置是否在草地中
		if not _is_position_in_cavity(current_pos):
			continue
		
		var tile_data = tile_manager.get_tile_data(current_pos)
		if not tile_data or tile_data.type not in [
			TileTypes.TileType.GRASSLAND_PLAINS,
			TileTypes.TileType.GRASSLAND_HILLS,
			TileTypes.TileType.GRASSLAND_WETLANDS,
			TileTypes.TileType.GRASSLAND_FIELDS
		]:
			continue
		
		# 设置为草原农田
		tile_manager.set_tile_type(current_pos, TileTypes.TileType.GRASSLAND_FIELDS)
		farmland_tiles.append(current_pos)
		used_positions[pos_key] = true
		processed[pos_key] = true
		
		# 添加相邻位置到队列（包括对角线）
		var neighbors = [
			Vector3(current_pos.x + 1, 0, current_pos.z),
			Vector3(current_pos.x - 1, 0, current_pos.z),
			Vector3(current_pos.x, 0, current_pos.z + 1),
			Vector3(current_pos.x, 0, current_pos.z - 1),
			Vector3(current_pos.x + 1, 0, current_pos.z + 1),
			Vector3(current_pos.x - 1, 0, current_pos.z - 1),
			Vector3(current_pos.x + 1, 0, current_pos.z - 1),
			Vector3(current_pos.x - 1, 0, current_pos.z + 1)
		]
		
		for neighbor in neighbors:
			var neighbor_key = str(int(neighbor.x)) + "," + str(int(neighbor.z))
			if neighbor_key not in processed and neighbor_key not in used_positions:
				queue.append(neighbor)
	
	return farmland_tiles

func _connect_to_nearby_farmlands(new_farmland: Array, existing_farmlands: Array, max_distance: float) -> void:
	"""尝试将新农田连接到附近的农田"""
	if existing_farmlands.size() <= 1:
		return
	
	var new_center = _calculate_center_position(new_farmland)
	var closest_farmland = null
	var min_distance = INF
	
	# 找到最近的农田
	for i in range(existing_farmlands.size() - 1): # 排除刚添加的新农田
		var farmland = existing_farmlands[i]
		var farmland_center = _calculate_center_position(farmland)
		var distance = new_center.distance_to(farmland_center)
		
		if distance < min_distance and distance <= max_distance:
			min_distance = distance
			closest_farmland = farmland
	
	# 如果找到合适的农田，尝试创建连接
	if closest_farmland:
		_create_farmland_connection(new_farmland, closest_farmland)

func _create_farmland_connection(farmland1: Array, farmland2: Array) -> void:
	"""在两个农田之间创建连接"""
	if farmland1.is_empty() or farmland2.is_empty():
		return
	
	var center1 = _calculate_center_position(farmland1)
	var center2 = _calculate_center_position(farmland2)
	
	# 计算连接路径
	var path = _calculate_farmland_path(center1, center2)
	
	# 在路径上设置农田地块
	for pos in path:
		if _is_position_in_cavity(pos):
			var tile_data = tile_manager.get_tile_data(pos)
			if tile_data and tile_data.type in [
				TileTypes.TileType.GRASSLAND_PLAINS,
				TileTypes.TileType.GRASSLAND_HILLS,
				TileTypes.TileType.GRASSLAND_WETLANDS
			]:
				tile_manager.set_tile_type(pos, TileTypes.TileType.GRASSLAND_FIELDS)

func _calculate_farmland_path(start: Vector3, end: Vector3) -> Array:
	"""计算两点之间的农田连接路径"""
	var path = []
	var steps = int(max(abs(end.x - start.x), abs(end.z - start.z)))
	
	if steps == 0:
		return [start]
	
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var x = int(lerp(start.x, end.x, t))
		var z = int(lerp(start.z, end.z, t))
		path.append(Vector3(x, 0, z))
	
	return path

func clear_ecosystem():
	"""清空生态系统"""
	resource_spawns.clear()
	creature_spawns.clear()
	ecosystem_regions.clear()
	LogManager.info("生态系统已清空")
