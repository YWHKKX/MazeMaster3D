extends Node
class_name CaveEcosystem

## 🕳️ 洞穴生态系统
## 地下环境，矿物丰富，需要挖掘

# ============================================================================
# 洞穴生态配置
# ============================================================================

class CaveConfig:
	var resource_density: float = 0.2 # 资源密度很高
	var creature_density: float = 0.06 # 生物密度较低
	var mineral_density: float = 0.25 # 矿物密度
	var mushroom_density: float = 0.1 # 蘑菇密度
	var crystal_density: float = 0.05 # 水晶密度
	
	# 洞穴特有配置
	var deep_cave_ratio: float = 0.3 # 深洞比例
	var stalactite_density: float = 0.08 # 钟乳石密度

# ============================================================================
# 洞穴资源生成
# ============================================================================

func generate_cave_resources(region: EcosystemRegion.RegionData) -> Array[ResourceTypes.ResourceSpawn]:
	"""生成洞穴资源"""
	var resources: Array[ResourceTypes.ResourceSpawn] = []
	var config = CaveConfig.new()
	var area = region.get_area()
	
	# 生成铁矿
	var iron_count = int(area * config.mineral_density * 1.5)
	for i in range(iron_count):
		var pos = region.get_random_point()
		var amount = randi_range(15, 40) # 每点15-40铁矿
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.IRON_ORE, Vector3(pos.x, 0, pos.y), amount, 900.0)
		resources.append(resource)
	
	# 生成金矿
	var gold_count = int(area * config.mineral_density * 0.8)
	for i in range(gold_count):
		var pos = region.get_random_point()
		var amount = randi_range(5, 20) # 每点5-20金矿
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.GOLD_ORE, Vector3(pos.x, 0, pos.y), amount, 1200.0)
		resources.append(resource)
	
	# 生成宝石
	var gem_count = int(area * config.crystal_density)
	for i in range(gem_count):
		var pos = region.get_random_point()
		var amount = randi_range(1, 5) # 每点1-5宝石
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.GEM, Vector3(pos.x, 0, pos.y), amount, 1800.0)
		resources.append(resource)
	
	# 生成蘑菇
	var mushroom_count = int(area * config.mushroom_density)
	for i in range(mushroom_count):
		var pos = region.get_random_point()
		var amount = randi_range(3, 12) # 每点3-12蘑菇
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.MUSHROOM, Vector3(pos.x, 0, pos.y), amount, 360.0)
		resources.append(resource)
	
	return resources

# ============================================================================
# 洞穴生物生成
# ============================================================================

func generate_cave_creatures(region: EcosystemRegion.RegionData) -> Array[BeastsTypes.BeastSpawn]:
	"""生成洞穴生物"""
	var creatures: Array[BeastsTypes.BeastSpawn] = []
	var config = CaveConfig.new()
	var area = region.get_area()
	
	# 生成巨鼠（洞穴主要生物）
	var rat_count = int(area * config.creature_density * 3)
	for i in range(rat_count):
		var pos = region.get_random_point()
		var level = randi_range(1, 3)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.GIANT_RAT, Vector3(pos.x, 0, pos.y), level, true, 480.0)
		creatures.append(creature)
	
	return creatures

# ============================================================================
# 洞穴特殊特性
# ============================================================================

func generate_cave_features(region: EcosystemRegion.RegionData) -> Array[EcosystemRegion.RegionFeature]:
	"""生成洞穴特殊特性"""
	var features: Array[EcosystemRegion.RegionFeature] = []
	var area = region.get_area()
	var config = CaveConfig.new()
	
	# 生成钟乳石
	var stalactite_count = int(area * config.stalactite_density)
	for i in range(stalactite_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("stalactite", pos, "古老的钟乳石，可能有矿物")
		features.append(feature)
	
	# 生成水晶洞
	var crystal_cave_count = max(1, int(area / 200)) # 每200格区域1个水晶洞
	for i in range(crystal_cave_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("crystal_cave", pos, "闪闪发光的水晶洞，宝石丰富")
		features.append(feature)
	
	# 生成深洞
	var deep_cave_count = max(1, int(area / 300)) # 每300格区域1个深洞
	for i in range(deep_cave_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("deep_cave", pos, "深不见底的洞穴，可能有稀有矿物")
		features.append(feature)
	
	# 生成地下湖
	var underground_lake_count = max(1, int(area / 250)) # 每250格区域1个地下湖
	for i in range(underground_lake_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("underground_lake", pos, "神秘的地下湖，可能有特殊生物")
		features.append(feature)
	
	return features

# ============================================================================
# 洞穴生态系统
# ============================================================================

func update_cave_ecosystem(creatures: Array[BeastsTypes.BeastSpawn], delta: float) -> void:
	"""更新洞穴生态系统"""
	var rats = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.GIANT_RAT)
	
	# 巨鼠觅食行为
	for rat in rats:
		if rat.is_active:
			# 寻找蘑菇和矿物
			var nearby_food = find_nearby_resources(rat.position, 8.0, [ResourceTypes.ResourceType.MUSHROOM, ResourceTypes.ResourceType.IRON_ORE])
			if nearby_food.size() > 0:
				LogManager.info("巨鼠在觅食蘑菇")
	
	# 巨鼠群体行为
	update_rat_colony_behavior(rats)
	
	# 洞穴环境适应
	update_cave_environment_adaptation(rats)

func update_rat_colony_behavior(rats: Array[BeastsTypes.BeastSpawn]) -> void:
	"""更新巨鼠群体行为"""
	var active_rats = rats.filter(func(r): return r.is_active)
	if active_rats.size() < 2:
		return
	
	# 简单的群体聚集行为
	for i in range(0, active_rats.size(), 2):
		if i + 1 < active_rats.size():
			var rat1 = active_rats[i]
			var rat2 = active_rats[i + 1]
			
			var distance = rat1.position.distance_to(rat2.position)
			if distance < 5.0:
				LogManager.info("巨鼠群体聚集")

func update_cave_environment_adaptation(rats: Array[BeastsTypes.BeastSpawn]) -> void:
	"""更新洞穴环境适应"""
	for rat in rats:
		if rat.is_active:
			# 巨鼠适应黑暗环境
			LogManager.info("巨鼠适应了洞穴的黑暗环境")

func find_nearby_resources(position: Vector3, radius: float, resource_types: Array) -> Array[ResourceTypes.ResourceSpawn]:
	"""查找附近的资源"""
	# 简化实现，返回空数组
	return []
