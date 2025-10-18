extends Node
class_name GrasslandEcosystem

## 🌱 草地生态系统
## 开阔平原，适合生存和建造

# ============================================================================
# 草地生态配置
# ============================================================================

class GrasslandConfig:
	var resource_density: float = 0.12 # 资源密度适中
	var creature_density: float = 0.1 # 生物密度较高
	var grass_patch_density: float = 0.2 # 草地密度
	var flower_field_density: float = 0.1 # 野花田密度
	var well_density: float = 0.02 # 水井密度
	
	# 食物链配置
	var predator_prey_ratio: float = 0.4 # 掠食者比例较高
	var herbivore_density: float = 0.6 # 食草动物密度

# ============================================================================
# 草地资源生成
# ============================================================================

func generate_grassland_resources(region: EcosystemRegion.RegionData) -> Array[ResourceTypes.ResourceSpawn]:
	"""生成草地资源"""
	var resources: Array[ResourceTypes.ResourceSpawn] = []
	var config = GrasslandConfig.new()
	var area = region.get_area()
	
	# 生成食物（草料）
	var food_count = int(area * config.resource_density * 2)
	for i in range(food_count):
		var pos = region.get_random_point()
		var amount = randi_range(5, 20) # 每点5-20食物
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.FOOD, Vector3(pos.x, 0, pos.y), amount, 240.0)
		resources.append(resource)
	
	# 生成草药
	var herb_count = int(area * config.resource_density * 0.8)
	for i in range(herb_count):
		var pos = region.get_random_point()
		var amount = randi_range(2, 8) # 每点2-8草药
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.HERB, Vector3(pos.x, 0, pos.y), amount, 360.0)
		resources.append(resource)
	
	return resources

# ============================================================================
# 草地生物生成
# ============================================================================

func generate_grassland_creatures(region: EcosystemRegion.RegionData) -> Array[BeastsTypes.BeastSpawn]:
	"""生成草地生物"""
	var creatures: Array[BeastsTypes.BeastSpawn] = []
	var config = GrasslandConfig.new()
	var area = region.get_area()
	
	# 生成小型食草动物（野兔）
	var rabbit_count = int(area * config.herbivore_density * 0.7)
	for i in range(rabbit_count):
		var pos = region.get_random_point()
		var level = randi_range(1, 2)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.RABBIT, Vector3(pos.x, 0, pos.y), level, false, 300.0)
		creatures.append(creature)
	
	# 生成掠食者（草原狼）
	var wolf_count = int(area * config.predator_prey_ratio * 0.5)
	for i in range(wolf_count):
		var pos = region.get_random_point()
		var level = randi_range(2, 3)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.GRASSLAND_WOLF, Vector3(pos.x, 0, pos.y), level, true, 720.0)
		creatures.append(creature)
	
	# 生成大型生物（犀角兽）
	var rhino_count = max(1, int(area / 150)) # 每150格区域1头犀角兽
	for i in range(rhino_count):
		var pos = region.get_random_point()
		var level = randi_range(4, 6)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.RHINO_BEAST, Vector3(pos.x, 0, pos.y), level, true, 1800.0)
		creatures.append(creature)
	
	return creatures

# ============================================================================
# 草地特殊特性
# ============================================================================

func generate_grassland_features(region: EcosystemRegion.RegionData) -> Array[EcosystemRegion.RegionFeature]:
	"""生成草地特殊特性"""
	var features: Array[EcosystemRegion.RegionFeature] = []
	var area = region.get_area()
	
	# 生成野花田
	var flower_field_count = max(1, int(area / 120)) # 每120格区域1个野花田
	for i in range(flower_field_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("flower_field", pos, "美丽的野花田，草药丰富")
		features.append(feature)
	
	# 生成水井
	var well_count = max(1, int(area / 200)) # 每200格区域1口水井
	for i in range(well_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("water_well", pos, "古老的水井，提供清洁水源")
		features.append(feature)
	
	return features

# ============================================================================
# 草地食物链系统
# ============================================================================

func update_grassland_food_chain(creatures: Array[BeastsTypes.BeastSpawn], delta: float) -> void:
	"""更新草地食物链"""
	# 草原狼捕食野兔
	var wolves = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.GRASSLAND_WOLF)
	var rabbits = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.RABBIT)
	
	for wolf in wolves:
		# 寻找附近的兔子
		var nearest_rabbit = find_nearest_creature(wolf.position, rabbits, 20.0)
		if nearest_rabbit:
			var distance = wolf.position.distance_to(nearest_rabbit.position)
			if distance < 2.5: # 捕食范围
				nearest_rabbit.is_active = false
				LogManager.info("草原狼捕食了野兔")
	
	# 犀角兽与草原狼的竞争
	var rhinos = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.RHINO_BEAST)
	
	for rhino in rhinos:
		# 犀角兽驱赶附近的狼
		var nearby_wolves = find_creatures_in_radius(rhino.position, wolves, 8.0)
		for wolf in nearby_wolves:
			# 狼被驱赶，移动到更远的地方
			LogManager.info("犀角兽驱赶了草原狼")
	
	# 野兔觅食
	for rabbit in rabbits:
		if rabbit.is_active:
			var nearby_food = find_nearby_resources(rabbit.position, 8.0, [ResourceTypes.ResourceType.FOOD, ResourceTypes.ResourceType.HERB])
			if nearby_food.size() > 0:
				LogManager.info("野兔在觅食")

func find_nearest_creature(position: Vector3, creatures: Array[BeastsTypes.BeastSpawn], max_distance: float) -> BeastsTypes.BeastSpawn:
	"""查找最近的生物"""
	var nearest: BeastsTypes.BeastSpawn = null
	var min_distance = max_distance
	
	for creature in creatures:
		if not creature.is_active:
			continue
		
		var distance = position.distance_to(creature.position)
		if distance < min_distance:
			min_distance = distance
			nearest = creature
	
	return nearest

func find_creatures_in_radius(position: Vector3, creatures: Array[BeastsTypes.BeastSpawn], radius: float) -> Array[BeastsTypes.BeastSpawn]:
	"""查找指定半径内的生物"""
	var nearby_creatures: Array[BeastsTypes.BeastSpawn] = []
	
	for creature in creatures:
		if not creature.is_active:
			continue
		
		var distance = position.distance_to(creature.position)
		if distance <= radius:
			nearby_creatures.append(creature)
	
	return nearby_creatures

func find_nearby_resources(position: Vector3, radius: float, resource_types: Array) -> Array[ResourceTypes.ResourceSpawn]:
	"""查找附近的资源"""
	# 简化实现，返回空数组
	return []
