extends Node
class_name LakeEcosystem

## 🏞️ 湖泊生态系统
## 水域环境，独特的生态关系

# ============================================================================
# 湖泊生态配置
# ============================================================================

class LakeConfig:
	var resource_density: float = 0.08 # 资源密度较低
	var creature_density: float = 0.12 # 生物密度较高
	var water_plant_density: float = 0.15 # 水生植物密度
	var fish_school_density: float = 0.2 # 鱼群密度
	var island_density: float = 0.05 # 小岛密度
	
	# 食物链配置
	var predator_prey_ratio: float = 0.25 # 掠食者比例较低
	var herbivore_density: float = 0.75 # 食草动物密度较高

# ============================================================================
# 湖泊资源生成
# ============================================================================

func generate_lake_resources(region: EcosystemRegion.RegionData) -> Array[ResourceTypes.ResourceSpawn]:
	"""生成湖泊资源"""
	var resources: Array[ResourceTypes.ResourceSpawn] = []
	var config = LakeConfig.new()
	var area = region.get_area()
	
	# 生成水资源（无限）
	var water_count = max(1, int(area / 50)) # 每50格区域1个水源
	for i in range(water_count):
		var pos = region.get_random_point()
		var amount = randi_range(50, 200) # 每点50-200水
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.WATER, Vector3(pos.x, 0, pos.y), amount, 0.0) # 水资源不重生
		resources.append(resource)
	
	# 生成鱼类食物
	var fish_food_count = int(area * config.resource_density * 3)
	for i in range(fish_food_count):
		var pos = region.get_random_point()
		var amount = randi_range(8, 25) # 每点8-25鱼类
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.FOOD, Vector3(pos.x, 0, pos.y), amount, 480.0)
		resources.append(resource)
	
	# 生成水生植物
	var plant_count = int(area * config.water_plant_density)
	for i in range(plant_count):
		var pos = region.get_random_point()
		var amount = randi_range(3, 10) # 每点3-10水生植物
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.AQUATIC_PLANT, Vector3(pos.x, 0, pos.y), amount, 600.0)
		resources.append(resource)
	
	return resources

# ============================================================================
# 湖泊生物生成
# ============================================================================

func generate_lake_creatures(region: EcosystemRegion.RegionData) -> Array[BeastsTypes.BeastSpawn]:
	"""生成湖泊生物"""
	var creatures: Array[BeastsTypes.BeastSpawn] = []
	var config = LakeConfig.new()
	var area = region.get_area()
	
	# 生成鱼类（食草动物）
	var fish_count = int(area * config.herbivore_density * 2)
	for i in range(fish_count):
		var pos = region.get_random_point()
		var level = randi_range(1, 2)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.FISH, Vector3(pos.x, 0, pos.y), level, false, 240.0)
		creatures.append(creature)
	
	# 生成鱼人（掠食者）
	var fishman_count = int(area * config.predator_prey_ratio * 0.8)
	for i in range(fishman_count):
		var pos = region.get_random_point()
		var level = randi_range(3, 5)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.FISH_MAN, Vector3(pos.x, 0, pos.y), level, true, 1200.0)
		creatures.append(creature)
	
	return creatures

# ============================================================================
# 湖泊特殊特性
# ============================================================================

func generate_lake_features(region: EcosystemRegion.RegionData) -> Array[EcosystemRegion.RegionFeature]:
	"""生成湖泊特殊特性"""
	var features: Array[EcosystemRegion.RegionFeature] = []
	var area = region.get_area()
	
	# 生成小岛
	var island_count = max(1, int(area / 180)) # 每180格区域1个小岛
	for i in range(island_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("small_island", pos, "湖心小岛，可能有特殊资源")
		features.append(feature)
	
	# 生成瀑布
	var waterfall_count = max(1, int(area / 250)) # 每250格区域1个瀑布
	for i in range(waterfall_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("waterfall", pos, "壮观的瀑布，水源丰富")
		features.append(feature)
	
	# 生成深水区
	var deep_water_count = max(1, int(area / 200)) # 每200格区域1个深水区
	for i in range(deep_water_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("deep_water", pos, "深水区域，可能有大型鱼类")
		features.append(feature)
	
	return features

# ============================================================================
# 湖泊食物链系统
# ============================================================================

func update_lake_food_chain(creatures: Array[BeastsTypes.BeastSpawn], _delta: float) -> void:
	"""更新湖泊食物链"""
	# 分类所有生物
	var fish = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.FISH)
	var birds = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.WATER_BIRD)
	var turtles = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.WATER_TURTLE)
	var crocodiles = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.WATER_CROCODILE)
	var lake_monsters = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.LAKE_MONSTER)
	
	# 湖怪捕食所有其他生物（顶级掠食者）
	for monster in lake_monsters:
		if monster.is_active:
			var all_prey = fish + birds + turtles + crocodiles
			var nearest_prey = find_nearest_creature(monster.position, all_prey, 25.0)
			if nearest_prey:
				var distance = monster.position.distance_to(nearest_prey.position)
				if distance < 5.0: # 捕食范围
					nearest_prey.is_active = false
					LogManager.info("湖怪捕食了" + BeastsTypes.get_beast_name(nearest_prey.creature_type))
	
	# 鳄鱼捕食鱼类、鸟类和乌龟
	for crocodile in crocodiles:
		if crocodile.is_active:
			var all_prey = fish + birds + turtles
			var nearest_prey = find_nearest_creature(crocodile.position, all_prey, 15.0)
			if nearest_prey:
				var distance = crocodile.position.distance_to(nearest_prey.position)
				if distance < 3.0: # 捕食范围
					nearest_prey.is_active = false
					LogManager.info("鳄鱼捕食了" + BeastsTypes.get_beast_name(nearest_prey.creature_type))
	
	# 水鸟捕食鱼类
	for bird in birds:
		if bird.is_active:
			var nearest_fish = find_nearest_creature(bird.position, fish, 12.0)
			if nearest_fish:
				var distance = bird.position.distance_to(nearest_fish.position)
				if distance < 2.5: # 捕食范围
					nearest_fish.is_active = false
					LogManager.info("水鸟捕食了鱼类")
	
	# 乌龟觅食水草
	for turtle in turtles:
		if turtle.is_active:
			var nearby_food = find_nearby_resources(turtle.position, 8.0, [ResourceTypes.ResourceType.AQUATIC_PLANT])
			if nearby_food.size() > 0:
				LogManager.info("乌龟在觅食水草")
	
	# 鱼类觅食浮游生物和水草
	for fish_creature in fish:
		if fish_creature.is_active:
			var nearby_food = find_nearby_resources(fish_creature.position, 8.0, [ResourceTypes.ResourceType.AQUATIC_PLANT])
			if nearby_food.size() > 0:
				LogManager.info("鱼类在觅食")
	
	# 鱼群行为
	update_fish_school_behavior(fish)
	
	# 水鸟群行为
	update_bird_flock_behavior(birds)

func update_fish_school_behavior(fishes: Array[BeastsTypes.BeastSpawn]) -> void:
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

func update_bird_flock_behavior(birds: Array[BeastsTypes.BeastSpawn]) -> void:
	"""更新水鸟群行为"""
	var active_birds = birds.filter(func(b): return b.is_active)
	if active_birds.size() < 2:
		return
	
	# 水鸟群聚行为
	for bird in active_birds:
		var nearby_birds = find_creatures_in_radius(bird.position, active_birds, 10.0)
		if nearby_birds.size() > 1:
			LogManager.info("水鸟群聚在一起")

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
		if creature.is_active and position.distance_to(creature.position) <= radius:
			nearby_creatures.append(creature)
	return nearby_creatures

func find_nearby_resources(_position: Vector3, _radius: float, _resource_types: Array) -> Array[ResourceTypes.ResourceSpawn]:
	"""查找附近的资源"""
	# 简化实现，返回空数组
	return []
