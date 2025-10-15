extends Node
class_name LakeEcosystem

## 🏞️ 湖泊生态系统
## 水域环境，独特的生态关系

# ============================================================================
# 湖泊生态配置
# ============================================================================

class LakeConfig:
	var resource_density: float = 0.08   # 资源密度较低
	var creature_density: float = 0.12   # 生物密度较高
	var water_plant_density: float = 0.15 # 水生植物密度
	var fish_school_density: float = 0.2  # 鱼群密度
	var island_density: float = 0.05     # 小岛密度
	
	# 食物链配置
	var predator_prey_ratio: float = 0.25  # 掠食者比例较低
	var herbivore_density: float = 0.75    # 食草动物密度较高

# ============================================================================
# 湖泊资源生成
# ============================================================================

func generate_lake_resources(region: EcosystemRegion) -> Array[ResourceSpawn]:
	"""生成湖泊资源"""
	var resources: Array[ResourceSpawn] = []
	var config = LakeConfig.new()
	var area = region.get_area()
	
	# 生成水资源（无限）
	var water_count = max(1, int(area / 50))  # 每50格区域1个水源
	for i in range(water_count):
		var pos = region.get_random_point()
		var amount = randi_range(50, 200)  # 每点50-200水
		var resource = ResourceSpawn.new(ResourceTypes.ResourceType.WATER, Vector3(pos.x, 0, pos.y), amount, 0.0)  # 水资源不重生
		resources.append(resource)
	
	# 生成鱼类食物
	var fish_food_count = int(area * config.resource_density * 3)
	for i in range(fish_food_count):
		var pos = region.get_random_point()
		var amount = randi_range(8, 25)  # 每点8-25鱼类
		var resource = ResourceSpawn.new(ResourceTypes.ResourceType.FOOD, Vector3(pos.x, 0, pos.y), amount, 480.0)
		resources.append(resource)
	
	# 生成水生植物
	var plant_count = int(area * config.water_plant_density)
	for i in range(plant_count):
		var pos = region.get_random_point()
		var amount = randi_range(3, 10)  # 每点3-10水生植物
		var resource = ResourceSpawn.new(ResourceTypes.ResourceType.AQUATIC_PLANT, Vector3(pos.x, 0, pos.y), amount, 600.0)
		resources.append(resource)
	
	return resources

# ============================================================================
# 湖泊生物生成
# ============================================================================

func generate_lake_creatures(region: EcosystemRegion) -> Array[CreatureSpawn]:
	"""生成湖泊生物"""
	var creatures: Array[CreatureSpawn] = []
	var config = LakeConfig.new()
	var area = region.get_area()
	
	# 生成鱼类（食草动物）
	var fish_count = int(area * config.herbivore_density * 2)
	for i in range(fish_count):
		var pos = region.get_random_point()
		var level = randi_range(1, 2)
		var creature = CreatureSpawn.new(CreatureTypes.CreatureType.FISH, Vector3(pos.x, 0, pos.y), level, false, 240.0)
		creatures.append(creature)
	
	# 生成鱼人（掠食者）
	var fishman_count = int(area * config.predator_prey_ratio * 0.8)
	for i in range(fishman_count):
		var pos = region.get_random_point()
		var level = randi_range(3, 5)
		var creature = CreatureSpawn.new(CreatureTypes.CreatureType.FISH_MAN, Vector3(pos.x, 0, pos.y), level, true, 1200.0)
		creatures.append(creature)
	
	return creatures

# ============================================================================
# 湖泊特殊特性
# ============================================================================

func generate_lake_features(region: EcosystemRegion) -> Array[RegionFeature]:
	"""生成湖泊特殊特性"""
	var features: Array[RegionFeature] = []
	var area = region.get_area()
	
	# 生成小岛
	var island_count = max(1, int(area / 180))  # 每180格区域1个小岛
	for i in range(island_count):
		var pos = region.get_random_point()
		var feature = RegionFeature.new("small_island", pos, "湖心小岛，可能有特殊资源")
		features.append(feature)
	
	# 生成瀑布
	var waterfall_count = max(1, int(area / 250))  # 每250格区域1个瀑布
	for i in range(waterfall_count):
		var pos = region.get_random_point()
		var feature = RegionFeature.new("waterfall", pos, "壮观的瀑布，水源丰富")
		features.append(feature)
	
	# 生成深水区
	var deep_water_count = max(1, int(area / 200))  # 每200格区域1个深水区
	for i in range(deep_water_count):
		var pos = region.get_random_point()
		var feature = RegionFeature.new("deep_water", pos, "深水区域，可能有大型鱼类")
		features.append(feature)
	
	return features

# ============================================================================
# 湖泊食物链系统
# ============================================================================

func update_lake_food_chain(creatures: Array[CreatureSpawn], delta: float) -> void:
	"""更新湖泊食物链"""
	# 鱼人捕食鱼类
	var fishmen = creatures.filter(func(c): return c.creature_type == CreatureTypes.CreatureType.FISH_MAN)
	var fishes = creatures.filter(func(c): return c.creature_type == CreatureTypes.CreatureType.FISH)
	
	for fishman in fishmen:
		# 寻找附近的鱼
		var nearest_fish = find_nearest_creature(fishman.position, fishes, 12.0)
		if nearest_fish:
			var distance = fishman.position.distance_to(nearest_fish.position)
			if distance < 2.0:  # 捕食范围
				nearest_fish.is_active = false
				LogManager.info("鱼人捕食了鱼")
	
	# 鱼类觅食水生植物
	for fish in fishes:
		if fish.is_active:
			var nearby_plants = find_nearby_resources(fish.position, 6.0, [ResourceTypes.ResourceType.AQUATIC_PLANT])
			if nearby_plants.size() > 0:
				LogManager.info("鱼在觅食水生植物")
	
	# 鱼群行为
	update_fish_school_behavior(fishes)
	
	# 鱼人领地行为
	update_fishman_territory_behavior(fishmen)

func update_fish_school_behavior(fishes: Array[CreatureSpawn]) -> void:
	"""更新鱼群行为"""
	var active_fishes = fishes.filter(func(f): return f.is_active)
	if active_fishes.size() < 3:
		return
	
	# 简单的鱼群聚集行为
	for i in range(0, active_fishes.size(), 3):
		if i + 2 < active_fishes.size():
			var fish1 = active_fishes[i]
			var fish2 = active_fishes[i + 1]
			var fish3 = active_fishes[i + 2]
			
			# 计算鱼群中心
			var center = (fish1.position + fish2.position + fish3.position) / 3
			LogManager.info("鱼群聚集在位置: " + str(center))

func update_fishman_territory_behavior(fishmen: Array[CreatureSpawn]) -> void:
	"""更新鱼人领地行为"""
	for fishman in fishmen:
		# 鱼人守卫领地
		LogManager.info("鱼人在守卫领地")

func find_nearest_creature(position: Vector3, creatures: Array[CreatureSpawn], max_distance: float) -> CreatureSpawn:
	"""查找最近的生物"""
	var nearest: CreatureSpawn = null
	var min_distance = max_distance
	
	for creature in creatures:
		if not creature.is_active:
			continue
		
		var distance = position.distance_to(creature.position)
		if distance < min_distance:
			min_distance = distance
			nearest = creature
	
	return nearest

func find_nearby_resources(position: Vector3, radius: float, resource_types: Array) -> Array[ResourceSpawn]:
	"""查找附近的资源"""
	# 简化实现，返回空数组
	return []
