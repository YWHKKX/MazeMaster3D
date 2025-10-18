extends Node
class_name PrimitiveEcosystem

## 🦕 原始生态系统
## 史前环境，以各种恐龙为核心，资源丰富但危险

# ============================================================================
# 原始生态配置
# ============================================================================

class PrimitiveConfig:
	var resource_density: float = 0.12 # 资源密度高
	var creature_density: float = 0.06 # 生物密度适中
	var dinosaur_density: float = 0.4 # 恐龙密度
	var primitive_plant_density: float = 0.2 # 原始植物密度
	var fossil_density: float = 0.05 # 化石密度
	
	# 食物链配置
	var predator_prey_ratio: float = 0.4 # 掠食者比例高
	var herbivore_density: float = 0.6 # 食草动物密度

# ============================================================================
# 原始资源生成
# ============================================================================

func generate_primitive_resources(region: EcosystemRegion.RegionData) -> Array[ResourceTypes.ResourceSpawn]:
	"""生成原始资源"""
	var resources: Array[ResourceTypes.ResourceSpawn] = []
	var config = PrimitiveConfig.new()
	var area = region.get_area()
	
	# 生成原始植物
	var primitive_plant_count = int(area * config.primitive_plant_density)
	for i in range(primitive_plant_count):
		var pos = region.get_random_position()
		var amount = randi_range(5, 15)
		var resource = ResourceTypes.ResourceSpawn.new(
			ResourceTypes.ResourceType.PRIMITIVE_PLANT,
			pos,
			amount,
			600.0
		)
		resources.append(resource)
	
	# 生成史前矿物
	var mineral_count = int(area * config.resource_density * 0.3)
	for i in range(mineral_count):
		var pos = region.get_random_position()
		var amount = randi_range(3, 10)
		var resource = ResourceTypes.ResourceSpawn.new(
			ResourceTypes.ResourceType.PREHISTORIC_MINERAL,
			pos,
			amount,
			800.0
		)
		resources.append(resource)
	
	# 生成化石
	var fossil_count = int(area * config.fossil_density)
	for i in range(fossil_count):
		var pos = region.get_random_position()
		var amount = randi_range(1, 3)
		var resource = ResourceTypes.ResourceSpawn.new(
			ResourceTypes.ResourceType.FOSSIL,
			pos,
			amount,
			1000.0
		)
		resources.append(resource)
	
	# 生成琥珀
	var amber_count = int(area * config.resource_density * 0.1)
	for i in range(amber_count):
		var pos = region.get_random_position()
		var amount = randi_range(1, 2)
		var resource = ResourceTypes.ResourceSpawn.new(
			ResourceTypes.ResourceType.AMBER,
			pos,
			amount,
			1200.0
		)
		resources.append(resource)
	
	# 生成原始水晶
	var crystal_count = int(area * config.resource_density * 0.05)
	for i in range(crystal_count):
		var pos = region.get_random_position()
		var amount = randi_range(1, 2)
		var resource = ResourceTypes.ResourceSpawn.new(
			ResourceTypes.ResourceType.PRIMITIVE_CRYSTAL,
			pos,
			amount,
			1500.0
		)
		resources.append(resource)
	
	# 生成龙血石（稀有）
	if randf() < 0.1:
		var pos = region.get_random_position()
		var resource = ResourceTypes.ResourceSpawn.new(
			ResourceTypes.ResourceType.DRAGON_BLOOD_STONE,
			pos,
			1,
			3000.0
		)
		resources.append(resource)
	
	# 生成古龙鳞片（极稀有）
	if randf() < 0.01:
		var pos = region.get_random_position()
		var resource = ResourceTypes.ResourceSpawn.new(
			ResourceTypes.ResourceType.ANCIENT_DRAGON_SCALE,
			pos,
			1,
			5000.0
		)
		resources.append(resource)
	
	LogManager.info("PrimitiveEcosystem - 生成了 %d 个原始资源" % resources.size())
	return resources

# ============================================================================
# 原始生物生成
# ============================================================================

func generate_primitive_creatures(region: EcosystemRegion.RegionData) -> Array[BeastsTypes.BeastSpawn]:
	"""生成原始生物"""
	var creatures: Array[BeastsTypes.BeastSpawn] = []
	var config = PrimitiveConfig.new()
	var area = region.get_area()
	
	# 生成食草恐龙
	var herbivore_count = int(area * config.creature_density * config.herbivore_density)
	for i in range(herbivore_count):
		var pos = region.get_random_position()
		var creature_type = [BeastsTypes.BeastType.HORN_SHIELD_DRAGON, BeastsTypes.BeastType.SPINE_BACK_DRAGON][randi() % 2]
		var level = randi_range(3, 5)
		var creature = BeastsTypes.BeastSpawn.new(
			creature_type,
			pos,
			level,
			false, # 野兽阵营中立
			1200.0
		)
		creatures.append(creature)
	
	# 生成杂食恐龙
	var omnivore_count = int(area * config.creature_density * 0.3)
	for i in range(omnivore_count):
		var pos = region.get_random_position()
		var creature_type = [BeastsTypes.BeastType.SCALE_ARMOR_DRAGON, BeastsTypes.BeastType.CLAW_HUNTER_DRAGON][randi() % 2]
		var level = randi_range(4, 6)
		var creature = BeastsTypes.BeastSpawn.new(
			creature_type,
			pos,
			level,
			false, # 野兽阵营中立
			1500.0
		)
		creatures.append(creature)
	
	# 生成掠食恐龙
	var predator_count = int(area * config.creature_density * config.predator_prey_ratio * 0.5)
	for i in range(predator_count):
		var pos = region.get_random_position()
		var creature_type = [BeastsTypes.BeastType.RAGE_DRAGON, BeastsTypes.BeastType.SHADOW_DRAGON][randi() % 2]
		var level = randi_range(6, 8)
		var creature = BeastsTypes.BeastSpawn.new(
			creature_type,
			pos,
			level,
			false, # 野兽阵营中立
			2000.0
		)
		creatures.append(creature)
	
	# 生成顶级掠食者
	var apex_count = int(area * config.creature_density * 0.1)
	for i in range(apex_count):
		var pos = region.get_random_position()
		var creature_type = BeastsTypes.CreatureType.DRAGON_BLOOD_BEAST
		var level = randi_range(8, 10)
		var creature = BeastsTypes.BeastSpawn.new(
			creature_type,
			pos,
			level,
			false, # 野兽阵营中立
			3000.0
		)
		creatures.append(creature)
	
	# 生成古龙霸主（极稀有）
	if randf() < 0.05:
		var pos = region.get_random_position()
		var creature = BeastsTypes.BeastSpawn.new(
			BeastsTypes.CreatureType.ANCIENT_DRAGON_OVERLORD,
			pos,
			randi_range(10, 12),
			false, # 野兽阵营中立
			5000.0
		)
		creatures.append(creature)
	
	LogManager.info("PrimitiveEcosystem - 生成了 %d 个原始生物" % creatures.size())
	return creatures

# ============================================================================
# 原始特性生成
# ============================================================================

func generate_primitive_features(region: EcosystemRegion.RegionData) -> Array[Dictionary]:
	"""生成原始特殊特性"""
	var features: Array[Dictionary] = []
	var area = region.get_area()
	
	# 恐龙巢穴
	var nest_count = int(area * 0.1)
	for i in range(nest_count):
		var pos = region.get_random_position()
		var feature = {
			"type": "恐龙巢穴",
			"position": pos,
			"description": "恐龙的巢穴，散发着史前的气息"
		}
		features.append(feature)
	
	# 史前遗迹
	var ruin_count = int(area * 0.05)
	for i in range(ruin_count):
		var pos = region.get_random_position()
		var feature = {
			"type": "史前遗迹",
			"position": pos,
			"description": "古老的史前遗迹，隐藏着远古的秘密"
		}
		features.append(feature)
	
	# 化石坑
	var fossil_pit_count = int(area * 0.08)
	for i in range(fossil_pit_count):
		var pos = region.get_random_position()
		var feature = {
			"type": "化石坑",
			"position": pos,
			"description": "富含化石的坑洞，可以挖掘到珍贵的化石"
		}
		features.append(feature)
	
	# 原始森林
	var forest_count = int(area * 0.15)
	for i in range(forest_count):
		var pos = region.get_random_position()
		var feature = {
			"type": "原始森林",
			"position": pos,
			"description": "茂密的原始森林，生长着史前植物"
		}
		features.append(feature)
	
	# 火山口
	var volcano_count = int(area * 0.02)
	for i in range(volcano_count):
		var pos = region.get_random_position()
		var feature = {
			"type": "火山口",
			"position": pos,
			"description": "活跃的火山口，散发着炽热的气息"
		}
		features.append(feature)
	
	# 龙血池
	var blood_pool_count = int(area * 0.01)
	for i in range(blood_pool_count):
		var pos = region.get_random_position()
		var feature = {
			"type": "龙血池",
			"position": pos,
			"description": "神秘的龙血池，蕴含着强大的龙血力量"
		}
		features.append(feature)
	
	# 古龙圣地
	var sanctuary_count = int(area * 0.005)
	for i in range(sanctuary_count):
		var pos = region.get_random_position()
		var feature = {
			"type": "古龙圣地",
			"position": pos,
			"description": "古龙的神圣领地，散发着威严的气息"
		}
		features.append(feature)
	
	# 龙骨墓地
	var graveyard_count = int(area * 0.003)
	for i in range(graveyard_count):
		var pos = region.get_random_position()
		var feature = {
			"type": "龙骨墓地",
			"position": pos,
			"description": "古龙的墓地，埋葬着远古的龙族"
		}
		features.append(feature)
	
	LogManager.info("PrimitiveEcosystem - 生成了 %d 个原始特性" % features.size())
	return features

# ============================================================================
# 食物链更新
# ============================================================================

func update_primitive_food_chain(creatures: Array[BeastsTypes.BeastSpawn]) -> void:
	"""更新原始生态系统食物链"""
	# 原始食物链：原始植物 → 角盾龙/棘背龙 → 鳞甲龙/利爪龙 → 暴怒龙/暗影龙 → 龙血兽 → 古龙霸主
	
	# 统计各层级生物数量
	var herbivore_count = 0
	var omnivore_count = 0
	var predator_count = 0
	var apex_count = 0
	var overlord_count = 0
	
	for creature in creatures:
		match creature.creature_type:
			BeastsTypes.BeastType.HORN_SHIELD_DRAGON, BeastsTypes.BeastType.SPINE_BACK_DRAGON:
				herbivore_count += 1
			BeastsTypes.BeastType.SCALE_ARMOR_DRAGON, BeastsTypes.BeastType.CLAW_HUNTER_DRAGON:
				omnivore_count += 1
			BeastsTypes.BeastType.RAGE_DRAGON, BeastsTypes.BeastType.SHADOW_DRAGON:
				predator_count += 1
			BeastsTypes.CreatureType.DRAGON_BLOOD_BEAST:
				apex_count += 1
			BeastsTypes.CreatureType.ANCIENT_DRAGON_OVERLORD:
				overlord_count += 1
	
	# 生态平衡检查
	var total_predators = omnivore_count + predator_count + apex_count + overlord_count
	var total_prey = herbivore_count
	
	if total_prey > 0 and total_predators > 0:
		var predator_ratio = float(total_predators) / float(total_prey)
		if predator_ratio > 0.4: # 掠食者过多
			LogManager.info("PrimitiveEcosystem - 掠食者过多，需要增加猎物")
		elif predator_ratio < 0.2: # 掠食者过少
			LogManager.info("PrimitiveEcosystem - 掠食者过少，食草恐龙可能过度繁殖")
	
	LogManager.info("PrimitiveEcosystem - 食物链统计: 食草恐龙 %d, 杂食恐龙 %d, 掠食恐龙 %d, 顶级掠食者 %d, 古龙霸主 %d" %
		[herbivore_count, omnivore_count, predator_count, apex_count, overlord_count])

# ============================================================================
# 工具函数
# ============================================================================

func get_ecosystem_info() -> Dictionary:
	"""获取原始生态系统信息"""
	return {
		"type": "PRIMITIVE",
		"name": "原始生态系统",
		"description": "史前环境，以各种恐龙为核心，资源丰富但危险",
		"resource_types": ["原始植物", "史前矿物", "化石", "琥珀", "原始水晶", "龙血石", "古龙鳞片"],
		"creature_types": ["角盾龙", "棘背龙", "鳞甲龙", "利爪龙", "暴怒龙", "暗影龙", "龙血兽", "古龙霸主"],
		"features": ["恐龙巢穴", "史前遗迹", "化石坑", "原始森林", "火山口", "龙血池", "古龙圣地", "龙骨墓地"]
	}
