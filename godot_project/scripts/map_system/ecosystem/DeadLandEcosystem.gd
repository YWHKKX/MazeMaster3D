extends Node
class_name DeadLandEcosystem

## 💀 死地生态系统
## 最危险环境，亡灵生物，魔法资源丰富

# ============================================================================
# 死地生态配置
# ============================================================================

class DeadLandConfig:
	var resource_density: float = 0.12 # 资源密度较高（魔法资源）
	var creature_density: float = 0.08 # 生物密度适中
	var magic_crystal_density: float = 0.2 # 魔法水晶密度
	var essence_density: float = 0.15 # 精华密度
	var soul_stone_density: float = 0.1 # 灵魂石密度
	var demon_core_density: float = 0.05 # 恶魔核心密度
	
	# 死地特有配置
	var corruption_level: float = 1.0 # 腐化程度
	var undead_power: float = 0.8 # 亡灵力量
	var dark_magic_factor: float = 0.9 # 黑暗魔法因子

# ============================================================================
# 死地资源生成
# ============================================================================

func generate_deadland_resources(region: EcosystemRegion.RegionData) -> Array[ResourceTypes.ResourceSpawn]:
	"""生成死地资源"""
	var resources: Array[ResourceTypes.ResourceSpawn] = []
	var config = DeadLandConfig.new()
	var area = region.get_area()
	
	# 生成魔法水晶
	var crystal_count = int(area * config.magic_crystal_density)
	for i in range(crystal_count):
		var pos = region.get_random_point()
		var amount = randi_range(3, 12) # 每点3-12魔法水晶
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.MAGIC_CRYSTAL, Vector3(pos.x, 0, pos.y), amount, 3600.0)
		resources.append(resource)
	
	# 生成精华
	var essence_count = int(area * config.essence_density)
	for i in range(essence_count):
		var pos = region.get_random_point()
		var amount = randi_range(1, 6) # 每点1-6精华
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.ESSENCE, Vector3(pos.x, 0, pos.y), amount, 4800.0)
		resources.append(resource)
	
	# 生成灵魂石
	var soul_stone_count = int(area * config.soul_stone_density)
	for i in range(soul_stone_count):
		var pos = region.get_random_point()
		var amount = randi_range(1, 3) # 每点1-3灵魂石
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.SOUL_STONE, Vector3(pos.x, 0, pos.y), amount, 7200.0)
		resources.append(resource)
	
	# 生成恶魔核心
	var demon_core_count = int(area * config.demon_core_density)
	for i in range(demon_core_count):
		var pos = region.get_random_point()
		var amount = randi_range(1, 2) # 每点1-2恶魔核心
		var resource = ResourceTypes.ResourceSpawn.new(ResourceTypes.ResourceType.DEMON_CORE, Vector3(pos.x, 0, pos.y), amount, 14400.0)
		resources.append(resource)
	
	return resources

# ============================================================================
# 死地生物生成
# ============================================================================

func generate_deadland_creatures(region: EcosystemRegion.RegionData) -> Array[BeastsTypes.BeastSpawn]:
	"""生成死地生物"""
	var creatures: Array[BeastsTypes.BeastSpawn] = []
	var config = DeadLandConfig.new()
	var area = region.get_area()
	
	# 生成骷髅（低级亡灵）
	var skeleton_count = int(area * config.creature_density * 2)
	for i in range(skeleton_count):
		var pos = region.get_random_point()
		var level = randi_range(2, 4)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.SKELETON, Vector3(pos.x, 0, pos.y), level, true, 600.0)
		creatures.append(creature)
	
	# 生成僵尸（中级亡灵）
	var zombie_count = int(area * config.creature_density * 1.5)
	for i in range(zombie_count):
		var pos = region.get_random_point()
		var level = randi_range(3, 5)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.ZOMBIE, Vector3(pos.x, 0, pos.y), level, true, 900.0)
		creatures.append(creature)
	
	# 生成恶魔（高级亡灵）
	var demon_count = max(1, int(area / 300)) # 每300格区域1只恶魔
	for i in range(demon_count):
		var pos = region.get_random_point()
		var level = randi_range(5, 8)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.DEMON, Vector3(pos.x, 0, pos.y), level, true, 3600.0)
		creatures.append(creature)
	
	# 生成暗影兽（顶级亡灵）
	var shadow_beast_count = max(1, int(area / 500)) # 每500格区域1只暗影兽
	for i in range(shadow_beast_count):
		var pos = region.get_random_point()
		var level = randi_range(6, 10)
		var creature = BeastsTypes.BeastSpawn.new(BeastsTypes.BeastType.SHADOW_DRAGON, Vector3(pos.x, 0, pos.y), level, true, 7200.0)
		creatures.append(creature)
	
	return creatures

# ============================================================================
# 死地特殊特性
# ============================================================================

func generate_deadland_features(region: EcosystemRegion.RegionData) -> Array[EcosystemRegion.RegionFeature]:
	"""生成死地特殊特性"""
	var features: Array[EcosystemRegion.RegionFeature] = []
	var area = region.get_area()
	
	# 生成黑暗祭坛
	var dark_altar_count = max(1, int(area / 200)) # 每200格区域1个黑暗祭坛
	for i in range(dark_altar_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("dark_altar", pos, "邪恶的黑暗祭坛，魔法力量强大")
		features.append(feature)
	
	# 生成骸骨堆
	var bone_pile_count = max(1, int(area / 150)) # 每150格区域1个骸骨堆
	for i in range(bone_pile_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("bone_pile", pos, "堆积如山的骸骨，亡灵力量聚集")
		features.append(feature)
	
	# 生成魔法阵
	var magic_circle_count = max(1, int(area / 250)) # 每250格区域1个魔法阵
	for i in range(magic_circle_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("magic_circle", pos, "古老的魔法阵，可能召唤亡灵")
		features.append(feature)
	
	# 生成诅咒区域
	var cursed_zone_count = max(1, int(area / 300)) # 每300格区域1个诅咒区域
	for i in range(cursed_zone_count):
		var pos = region.get_random_point()
		var feature = EcosystemRegion.RegionFeature.new("cursed_zone", pos, "被诅咒的区域，危险但资源丰富")
		features.append(feature)
	
	return features

# ============================================================================
# 死地生态系统
# ============================================================================

func update_deadland_ecosystem(creatures: Array[BeastsTypes.BeastSpawn], delta: float) -> void:
	"""更新死地生态系统"""
	# 亡灵等级制度
	var skeletons = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.SKELETON)
	var zombies = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.ZOMBIE)
	var demons = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.DEMON)
	var shadow_beasts = creatures.filter(func(c): return c.creature_type == BeastsTypes.BeastType.SHADOW_DRAGON)
	
	# 暗影兽统治其他亡灵
	update_shadow_beast_domination(shadow_beasts, demons, zombies, skeletons)
	
	# 恶魔指挥低级亡灵
	update_demon_command(demons, zombies, skeletons)
	
	# 亡灵觅食魔法资源
	update_undead_feeding(creatures)
	
	# 死地腐化效果
	update_corruption_effects(creatures)

func update_shadow_beast_domination(shadow_beasts: Array[BeastsTypes.BeastSpawn], demons: Array[BeastsTypes.BeastSpawn], zombies: Array[BeastsTypes.BeastSpawn], skeletons: Array[BeastsTypes.BeastSpawn]) -> void:
	"""更新暗影兽统治"""
	for shadow_beast in shadow_beasts:
		if shadow_beast.is_active:
			# 暗影兽统治范围内的其他亡灵
			var all_undead = demons + zombies + skeletons
			var nearby_undead = find_creatures_in_radius(shadow_beast.position, all_undead, 20.0)
			
			for undead in nearby_undead:
				LogManager.info("暗影兽统治了亡灵")

func update_demon_command(demons: Array[BeastsTypes.BeastSpawn], zombies: Array[BeastsTypes.BeastSpawn], skeletons: Array[BeastsTypes.BeastSpawn]) -> void:
	"""更新恶魔指挥"""
	for demon in demons:
		if demon.is_active:
			# 恶魔指挥低级亡灵
			var low_level_undead = zombies + skeletons
			var nearby_undead = find_creatures_in_radius(demon.position, low_level_undead, 15.0)
			
			for undead in nearby_undead:
				LogManager.info("恶魔指挥了低级亡灵")

func update_undead_feeding(creatures: Array[BeastsTypes.BeastSpawn]) -> void:
	"""更新亡灵觅食"""
	for creature in creatures:
		if creature.is_active:
			# 亡灵寻找魔法资源
			var nearby_magic = find_nearby_resources(creature.position, 10.0, [
				ResourceTypes.ResourceType.MAGIC_CRYSTAL,
				ResourceTypes.ResourceType.ESSENCE,
				ResourceTypes.ResourceType.SOUL_STONE
			])
			if nearby_magic.size() > 0:
				LogManager.info("亡灵在觅食魔法资源")

func update_corruption_effects(creatures: Array[BeastsTypes.BeastSpawn]) -> void:
	"""更新腐化效果"""
	for creature in creatures:
		if creature.is_active:
			# 死地的腐化效果
			LogManager.info("亡灵受到死地腐化的影响")

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
