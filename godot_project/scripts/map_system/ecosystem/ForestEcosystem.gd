extends Node
class_name ForestEcosystem

## 🌲 森林生态系统
## 温和环境，资源丰富，适合生存

# ============================================================================
# 森林生态配置
# ============================================================================

class ForestConfig:
	var resource_density: float = 0.15 # 资源密度较高
	var creature_density: float = 0.08 # 生物密度适中
	var tree_density: float = 0.3 # 树木密度
	var berry_bush_density: float = 0.1 # 浆果丛密度
	var herb_patch_density: float = 0.05 # 草药生长点密度
	
	# 食物链配置
	var predator_prey_ratio: float = 0.3 # 掠食者比例
	var herbivore_density: float = 0.7 # 食草动物密度

# ============================================================================
# 森林资源生成
# ============================================================================

func generate_forest_resources(region: EcosystemRegion.RegionData) -> Array[ResourceTypes.ResourceSpawn]:
	"""生成森林资源"""
	var resources: Array[ResourceTypes.ResourceSpawn] = []
	var config = ForestConfig.new()
	var area = region.get_area()
	
	# 生成树木
	var tree_count = int(area * config.tree_density)
	for i in range(tree_count):
		var pos = region.get_random_point()
		var amount = randi_range(20, 60) # 每棵树20-60木材
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.WOOD, Vector3(pos.x, 0, pos.y), amount, 600.0)
		resources.append(resource)
	
	# 生成浆果丛
	var berry_count = int(area * config.berry_bush_density)
	for i in range(berry_count):
		var pos = region.get_random_point()
		var amount = randi_range(8, 25) # 每丛8-25浆果
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.BERRY, Vector3(pos.x, 0, pos.y), amount, 300.0)
		resources.append(resource)
	
	# 生成草药生长点
	var herb_count = int(area * config.herb_patch_density)
	for i in range(herb_count):
		var pos = region.get_random_point()
		var amount = randi_range(3, 12) # 每点3-12草药
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.HERB, Vector3(pos.x, 0, pos.y), amount, 480.0)
		resources.append(resource)
	
	return resources

# ============================================================================
# 森林生物生成
# ============================================================================

func generate_forest_creatures(region: EcosystemRegion.RegionData) -> Array[BeastsTypes.BeastSpawn]:
	"""生成森林生物"""
	var creatures: Array[BeastsTypes.BeastSpawn] = []
	var config = ForestConfig.new()
	var area = region.get_area()
	
	# 生成食草动物（鹿）
	var deer_count = int(area * config.herbivore_density * 0.8)
	for i in range(deer_count):
		var pos = region.get_random_point()
		var level = randi_range(1, 3)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.DEER, Vector3(pos.x, 0, pos.y), level, false, 600.0)
		creatures.append(creature)
	
	# 生成掠食者（森林狼）
	var wolf_count = int(area * config.predator_prey_ratio * 0.4)
	for i in range(wolf_count):
		var pos = region.get_random_point()
		var level = randi_range(2, 4)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.FOREST_WOLF, Vector3(pos.x, 0, pos.y), level, true, 900.0)
		creatures.append(creature)
	
	# 生成影刃虎（顶级掠食者）
	var tiger_count = int(area * config.predator_prey_ratio * 0.3)
	for i in range(tiger_count):
		var pos = region.get_random_point()
		var level = randi_range(4, 6)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.SHADOW_TIGER, Vector3(pos.x, 0, pos.y), level, true, 1200.0)
		creatures.append(creature)
	
	# 生成巨爪熊（顶级掠食者）
	var bear_count = int(area * config.predator_prey_ratio * 0.3)
	for i in range(bear_count):
		var pos = region.get_random_point()
		var level = randi_range(5, 7)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.CLAW_BEAR, Vector3(pos.x, 0, pos.y), level, true, 1500.0)
		creatures.append(creature)
	
	return creatures

# ============================================================================
# 森林特殊特性
# ============================================================================

func generate_forest_features(region: EcosystemRegion.RegionData) -> Array[EcosystemRegion.RegionFeature]:
	"""生成森林特殊特性"""
	var features: Array[EcosystemRegion.RegionFeature] = []
	var area = region.get_area()
	
	# 生成古树（大型资源点）
	var ancient_tree_count = max(1, int(area / 100)) # 每100格区域1棵古树
	for i in range(ancient_tree_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("ancient_tree", pos, "古老的巨树，提供大量木材")
		features.append(feature)
	
	# 生成浆果丛聚集地
	var berry_grove_count = max(1, int(area / 200)) # 每200格区域1个浆果丛
	for i in range(berry_grove_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("berry_grove", pos, "茂密的浆果丛，浆果丰富")
		features.append(feature)
	
	# 生成草药生长点
	var herb_garden_count = max(1, int(area / 300)) # 每300格区域1个草药园
	for i in range(herb_garden_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("herb_garden", pos, "天然草药园，草药种类丰富")
		features.append(feature)
	
	return features

# ============================================================================
# 森林食物链系统
# ============================================================================

func update_forest_food_chain(creatures: Array[BeastsTypes.BeastSpawn], _delta: float) -> void:
	"""更新森林食物链"""
	# 分类所有生物
	var deer = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.DEER)
	var wolves = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.FOREST_WOLF)
	var tigers = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.SHADOW_TIGER)
	var bears = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.CLAW_BEAR)
	
	# 影刃虎捕食森林狼和鹿
	for tiger in tigers:
		if tiger.is_active:
			var all_prey = wolves + deer
			var nearest_prey = find_nearest_creature(tiger.position, all_prey, 20.0)
			if nearest_prey:
				var distance = tiger.position.distance_to(nearest_prey.position)
				if distance < 4.0: # 捕食范围
					nearest_prey.is_active = false
					LogManager.info("影刃虎捕食了" + BeastsTypes.get_beast_name(nearest_prey.creature_type))
	
	# 巨爪熊捕食森林狼和鹿（杂食性）
	for bear in bears:
		if bear.is_active:
			var all_prey = wolves + deer
			var nearest_prey = find_nearest_creature(bear.position, all_prey, 18.0)
			if nearest_prey:
				var distance = bear.position.distance_to(nearest_prey.position)
				if distance < 3.5: # 捕食范围
					nearest_prey.is_active = false
					LogManager.info("巨爪熊捕食了" + BeastsTypes.get_beast_name(nearest_prey.creature_type))
	
	# 森林狼捕食鹿
	for wolf in wolves:
		if wolf.is_active:
			var nearest_prey = find_nearest_creature(wolf.position, deer, 15.0)
			if nearest_prey:
				var distance = wolf.position.distance_to(nearest_prey.position)
				if distance < 3.0: # 捕食范围
					nearest_prey.is_active = false
					LogManager.info("森林狼捕食了鹿")
	
	# 食草动物觅食
	for deer_creature in deer:
		if deer_creature.is_active:
			# 寻找食物源（浆果、草药）
			var nearby_food = find_nearby_resources(deer_creature.position, 10.0, [ResourceTypes.ResourceType.BERRY, ResourceTypes.ResourceType.HERB])
			if nearby_food.size() > 0:
				LogManager.info("鹿在觅食")

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

func find_nearby_resources(_position: Vector3, _radius: float, _resource_types: Array) -> Array[ResourceTypes.ResourceSpawn]:
	"""查找附近的资源"""
	# 这里需要从EcosystemManager获取资源列表
	# 简化实现，返回空数组
	return []
