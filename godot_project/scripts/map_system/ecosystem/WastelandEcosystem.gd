extends Node
class_name WastelandEcosystem

## 🏜️ 荒地生态系统
## 恶劣环境，资源稀少但稀有矿物丰富

# ============================================================================
# 荒地生态配置
# ============================================================================

class WastelandConfig:
	var resource_density: float = 0.05 # 资源密度很低
	var creature_density: float = 0.03 # 生物密度很低
	var rare_mineral_density: float = 0.15 # 稀有矿物密度
	var stone_density: float = 0.2 # 石头密度
	var radiation_density: float = 0.1 # 辐射区域密度
	
	# 荒地特有配置
	var harsh_environment_factor: float = 0.8 # 恶劣环境因子
	var survival_difficulty: float = 0.9 # 生存难度

# ============================================================================
# 荒地资源生成
# ============================================================================

func generate_wasteland_resources(region: EcosystemRegion.RegionData) -> Array[ResourceTypes.ResourceSpawn]:
	"""生成荒地资源"""
	var resources: Array[ResourceTypes.ResourceSpawn] = []
	var config = WastelandConfig.new()
	var area = region.get_area()
	
	# 生成稀有矿物
	var rare_mineral_count = int(area * config.rare_mineral_density)
	for i in range(rare_mineral_count):
		var pos = region.get_random_point()
		var amount = randi_range(2, 8) # 每点2-8稀有矿物
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.RARE_MINERAL, Vector3(pos.x, 0, pos.y), amount, 2400.0)
		resources.append(resource)
	
	# 生成石头
	var stone_count = int(area * config.stone_density)
	for i in range(stone_count):
		var pos = region.get_random_point()
		var amount = randi_range(8, 25) # 每点8-25石头
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.STONE, Vector3(pos.x, 0, pos.y), amount, 900.0)
		resources.append(resource)
	
	return resources

# ============================================================================
# 荒地生物生成
# ============================================================================

func generate_wasteland_creatures(region: EcosystemRegion.RegionData) -> Array[BeastsTypes.BeastSpawn]:
	"""生成荒地生物"""
	var creatures: Array[BeastsTypes.BeastSpawn] = []
	var config = WastelandConfig.new()
	var area = region.get_area()
	
	# 生成巨蜥（荒地主要生物）
	var lizard_count = max(1, int(area / 200)) # 每200格区域1只巨蜥
	for i in range(lizard_count):
		var pos = region.get_random_point()
		var level = randi_range(3, 5)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.GIANT_LIZARD, Vector3(pos.x, 0, pos.y), level, true, 1800.0)
		creatures.append(creature)
	
	return creatures

# ============================================================================
# 荒地特殊特性
# ============================================================================

func generate_wasteland_features(region: EcosystemRegion.RegionData) -> Array[EcosystemRegion.RegionFeature]:
	"""生成荒地特殊特性"""
	var features: Array[EcosystemRegion.RegionFeature] = []
	var area = region.get_area()
	
	# 生成废弃建筑
	var abandoned_building_count = max(1, int(area / 150)) # 每150格区域1个废弃建筑
	for i in range(abandoned_building_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("abandoned_building", pos, "废弃的建筑，可能有稀有矿物")
		features.append(feature)
	
	# 生成辐射区域
	var radiation_zone_count = max(1, int(area / 300)) # 每300格区域1个辐射区域
	for i in range(radiation_zone_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("radiation_zone", pos, "危险的辐射区域，但可能有稀有资源")
		features.append(feature)
	
	# 生成沙漠绿洲
	var oasis_count = max(1, int(area / 400)) # 每400格区域1个绿洲
	for i in range(oasis_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("desert_oasis", pos, "沙漠中的绿洲，生命之源")
		features.append(feature)
	
	# 生成矿物富集区
	var mineral_rich_zone_count = max(1, int(area / 250)) # 每250格区域1个矿物富集区
	for i in range(mineral_rich_zone_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("mineral_rich_zone", pos, "矿物富集区域，稀有矿物丰富")
		features.append(feature)
	
	return features

# ============================================================================
# 荒地生态系统
# ============================================================================

func update_wasteland_ecosystem(creatures: Array[BeastsTypes.BeastSpawn], delta: float) -> void:
	"""更新荒地生态系统"""
	var lizards = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.GIANT_LIZARD)
	
	# 巨蜥适应恶劣环境
	for lizard in lizards:
		if lizard.is_active:
			# 巨蜥寻找稀有矿物
			var nearby_minerals = find_nearby_resources(lizard.position, 15.0, [ResourceTypes.ResourceType.RARE_MINERAL, ResourceTypes.ResourceType.STONE])
			if nearby_minerals.size() > 0:
				LogManager.info("巨蜥在寻找稀有矿物")
	
	# 荒地环境压力
	update_harsh_environment_pressure(lizards)
	
	# 巨蜥领地行为
	update_lizard_territory_behavior(lizards)

func update_harsh_environment_pressure(lizards: Array[BeastsTypes.BeastSpawn]) -> void:
	"""更新恶劣环境压力"""
	for lizard in lizards:
		if lizard.is_active:
			# 荒地环境对生物的影响
			LogManager.info("巨蜥在恶劣环境中生存")

func update_lizard_territory_behavior(lizards: Array[BeastsTypes.BeastSpawn]) -> void:
	"""更新巨蜥领地行为"""
	for lizard in lizards:
		# 巨蜥守卫领地
		LogManager.info("巨蜥在守卫领地")

func find_nearby_resources(position: Vector3, radius: float, resource_types: Array) -> Array[ResourceTypes.ResourceSpawn]:
	"""查找附近的资源"""
	# 简化实现，返回空数组
	return []
