extends Node

## 🌍 生态区域类 - 单个生态区域的详细管理
## 负责管理特定生态区域的资源、生物和特殊逻辑

# ============================================================================
# 生态区域类型枚举（与MapGenerator保持一致）
# ============================================================================

enum EcosystemType {
	FOREST, # 森林
	GRASSLAND, # 草地
	LAKE, # 湖泊
	CAVE, # 洞穴
	WASTELAND, # 荒地
	DEAD_LAND, # 死地
	PRIMITIVE # 原始
}

# ============================================================================
# 生态区域数据结构
# ============================================================================

class RegionData:
	var position: Vector2i
	var size: Vector2i
	var ecosystem_type: EcosystemType
	var resource_spawns: Array = []
	var creature_spawns: Array = []
	var special_features: Array = []
	var is_active: bool = true
	var last_updated: float = 0.0
	
	func _init(pos: Vector2i, region_size: Vector2i, eco_type: EcosystemType):
		position = pos
		size = region_size
		ecosystem_type = eco_type
	
	func get_center() -> Vector2i:
		"""获取区域中心点"""
		return position + size / 2
	
	func get_area() -> int:
		"""获取区域面积"""
		return size.x * size.y
	
	func contains_point(point: Vector2i) -> bool:
		"""检查点是否在区域内"""
		return point.x >= position.x and point.x < position.x + size.x and \
			   point.y >= position.y and point.y < position.y + size.y
	
	func get_random_point() -> Vector2i:
		"""获取区域内的随机点"""
		var x = position.x + randi_range(0, size.x - 1)
		var y = position.y + randi_range(0, size.y - 1)
		return Vector2i(x, y)
	
	func get_random_position() -> Vector3:
		"""获取区域内的随机3D位置（向后兼容）"""
		var point = get_random_point()
		return Vector3(point.x, 0, point.y)

# ============================================================================
# 生态区域特性
# ============================================================================

class RegionFeature:
	var feature_type: String
	var position: Vector2i
	var description: String
	var is_active: bool = true
	
	func _init(type: String, pos: Vector2i, desc: String):
		feature_type = type
		position = pos
		description = desc

# ============================================================================
# 生态区域管理器
# ============================================================================

class EcosystemRegionManager:
	var regions: Array[RegionData] = []
	var active_regions: Array[RegionData] = []
	
	func add_region(region: RegionData):
		"""添加生态区域"""
		regions.append(region)
		if region.is_active:
			active_regions.append(region)
	
	func remove_region(region: RegionData):
		"""移除生态区域"""
		regions.erase(region)
		active_regions.erase(region)
	
	func get_regions_by_type(ecosystem_type: EcosystemType) -> Array[RegionData]:
		"""根据类型获取区域"""
		var filtered_regions: Array[RegionData] = []
		for region in regions:
			if region.ecosystem_type == ecosystem_type:
				filtered_regions.append(region)
		return filtered_regions
	
	func get_region_at_position(pos: Vector2i) -> RegionData:
		"""获取指定位置的区域"""
		for region in regions:
			if region.contains_point(pos):
				return region
		return null
	
	func get_nearby_regions(center: Vector2i, radius: float) -> Array[RegionData]:
		"""获取指定位置附近的区域"""
		var nearby_regions: Array[RegionData] = []
		for region in regions:
			var distance = region.get_center().distance_to(center)
			if distance <= radius:
				nearby_regions.append(region)
		return nearby_regions

# ============================================================================
# 生态区域特性生成
# ============================================================================

static func generate_region_features(region: RegionData) -> Array[RegionFeature]:
	"""为生态区域生成特殊特性"""
	var features: Array[RegionFeature] = []
	
	match region.ecosystem_type:
		EcosystemType.FOREST:
			features.append_array(_generate_forest_features(region))
		EcosystemType.GRASSLAND:
			features.append_array(_generate_grassland_features(region))
		EcosystemType.LAKE:
			features.append_array(_generate_lake_features(region))
		EcosystemType.CAVE:
			features.append_array(_generate_cave_features(region))
		EcosystemType.WASTELAND:
			features.append_array(_generate_wasteland_features(region))
		EcosystemType.DEAD_LAND:
			features.append_array(_generate_dead_land_features(region))
		EcosystemType.PRIMITIVE:
			features.append_array(_generate_primitive_features(region))
	
	return features

static func _generate_forest_features(region: RegionData) -> Array[RegionFeature]:
	"""生成森林特性"""
	var features: Array[RegionFeature] = []
	var area = region.get_area()
	
	# 生成古树（大型资源点）
	var ancient_tree_count = max(1, int(area / 100)) # 每100格区域1棵古树
	for i in range(ancient_tree_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("ancient_tree", pos, "古老的巨树，提供大量木材"))
	
	# 生成浆果丛聚集地
	var berry_grove_count = max(1, int(area / 200)) # 每200格区域1个浆果丛
	for i in range(berry_grove_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("berry_grove", pos, "茂密的浆果丛，浆果丰富"))
	
	# 生成草药生长点
	var herb_garden_count = max(1, int(area / 300)) # 每300格区域1个草药园
	for i in range(herb_garden_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("herb_garden", pos, "天然草药园，草药种类丰富"))
	
	# 生成虎穴
	if randf() < 0.2:
		var pos = region.get_random_point()
		features.append(RegionFeature.new("tiger_den", pos, "影刃虎的巢穴，危险但可能有珍贵资源"))
	
	# 生成熊洞
	if randf() < 0.15:
		var pos = region.get_random_point()
		features.append(RegionFeature.new("bear_cave", pos, "巨爪熊的洞穴，充满危险"))
	
	return features

static func _generate_grassland_features(region: RegionData) -> Array[RegionFeature]:
	"""生成草地特性"""
	var features: Array[RegionFeature] = []
	var area = region.get_area()
	
	# 生成野花田
	var flower_field_count = max(1, int(area / 120)) # 每120格区域1个野花田
	for i in range(flower_field_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("flower_field", pos, "美丽的野花田，草药丰富"))
	
	# 生成水井
	var well_count = max(1, int(area / 200)) # 每200格区域1口水井
	for i in range(well_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("water_well", pos, "古老的水井，提供清洁水源"))
	
	# 生成农田
	var farmland_count = max(1, int(area / 150)) # 每150格区域1块农田
	for i in range(farmland_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("farmland", pos, "肥沃的农田，可以种植作物"))
	
	return features

static func _generate_lake_features(region: RegionData) -> Array[RegionFeature]:
	"""生成湖泊特性"""
	var features: Array[RegionFeature] = []
	var area = region.get_area()
	
	# 生成小岛
	var island_count = max(1, int(area / 180)) # 每180格区域1个小岛
	for i in range(island_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("small_island", pos, "湖心小岛，可能有特殊资源"))
	
	# 生成瀑布
	var waterfall_count = max(1, int(area / 250)) # 每250格区域1个瀑布
	for i in range(waterfall_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("waterfall", pos, "壮观的瀑布，水源丰富"))
	
	# 生成深水区
	var deep_water_count = max(1, int(area / 200)) # 每200格区域1个深水区
	for i in range(deep_water_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("deep_water", pos, "深水区域，可能有大型鱼类"))
	
	# 生成浅滩
	var shallow_count = max(1, int(area / 150)) # 每150格区域1个浅滩
	for i in range(shallow_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("shallow_water", pos, "浅滩区域，适合涉水"))
	
	# 生成水草丛
	var grass_count = max(1, int(area / 100)) # 每100格区域1个水草丛
	for i in range(grass_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("water_grass", pos, "茂密的水草丛，鱼类聚集地"))
	
	# 生成浮游生物聚集区
	var plankton_count = max(1, int(area / 80)) # 每80格区域1个浮游生物聚集区
	for i in range(plankton_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("plankton_zone", pos, "浮游生物聚集区，生态基础"))
	
	# 生成水鸟栖息地
	var bird_count = max(1, int(area / 300)) # 每300格区域1个水鸟栖息地
	for i in range(bird_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("bird_habitat", pos, "水鸟栖息地，可能有鸟蛋"))
	
	# 生成湖怪巢穴
	if randf() < 0.1:
		var pos = region.get_random_point()
		features.append(RegionFeature.new("lake_monster_lair", pos, "湖怪巢穴，极度危险但可能有宝藏"))
	
	return features

static func _generate_cave_features(region: RegionData) -> Array[RegionFeature]:
	"""生成洞穴特性"""
	var features: Array[RegionFeature] = []
	var area = region.get_area()
	
	# 生成钟乳石
	var stalactite_count = int(area * 0.08) # 密度0.08
	for i in range(stalactite_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("stalactite", pos, "古老的钟乳石，可能有矿物"))
	
	# 生成水晶洞
	var crystal_cave_count = max(1, int(area / 200)) # 每200格区域1个水晶洞
	for i in range(crystal_cave_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("crystal_cave", pos, "闪闪发光的水晶洞，宝石丰富"))
	
	# 生成深洞
	var deep_cave_count = max(1, int(area / 300)) # 每300格区域1个深洞
	for i in range(deep_cave_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("deep_cave", pos, "深不见底的洞穴，可能有稀有矿物"))
	
	# 生成地下湖
	var underground_lake_count = max(1, int(area / 250)) # 每250格区域1个地下湖
	for i in range(underground_lake_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("underground_lake", pos, "神秘的地下湖，可能有特殊生物"))
	
	# 生成虫巢
	var nest_count = max(1, int(area / 150)) # 每150格区域1个虫巢
	for i in range(nest_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("insect_nest", pos, "昆虫巢穴，危险但可能有虫类资源"))
	
	# 生成蝙蝠洞
	var bat_cave_count = max(1, int(area / 200)) # 每200格区域1个蝙蝠洞
	for i in range(bat_cave_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("bat_cave", pos, "蝙蝠洞穴，可能有蝙蝠粪便肥料"))
	
	return features

static func _generate_wasteland_features(region: RegionData) -> Array[RegionFeature]:
	"""生成荒地特性"""
	var features: Array[RegionFeature] = []
	var area = region.get_area()
	
	# 生成废弃建筑
	var abandoned_building_count = max(1, int(area / 150)) # 每150格区域1个废弃建筑
	for i in range(abandoned_building_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("abandoned_building", pos, "废弃的建筑，可能有稀有矿物"))
	
	# 生成辐射区域
	var radiation_zone_count = max(1, int(area / 300)) # 每300格区域1个辐射区域
	for i in range(radiation_zone_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("radiation_zone", pos, "危险的辐射区域，但可能有稀有资源"))
	
	# 生成沙漠绿洲
	var oasis_count = max(1, int(area / 400)) # 每400格区域1个绿洲
	for i in range(oasis_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("desert_oasis", pos, "沙漠中的绿洲，生命之源"))
	
	# 生成矿物富集区
	var mineral_rich_zone_count = max(1, int(area / 250)) # 每250格区域1个矿物富集区
	for i in range(mineral_rich_zone_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("mineral_rich_zone", pos, "矿物富集区域，稀有矿物丰富"))
	
	# 生成辐射坑
	var radiation_pit_count = max(1, int(area / 350)) # 每350格区域1个辐射坑
	for i in range(radiation_pit_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("radiation_pit", pos, "深不见底的辐射坑，极度危险"))
	
	# 生成鼠洞
	var rat_hole_count = max(1, int(area / 100)) # 每100格区域1个鼠洞
	for i in range(rat_hole_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("rat_hole", pos, "变异老鼠的洞穴，可能有老鼠资源"))
	
	# 生成腐化土壤
	var corrupted_soil_count = max(1, int(area / 200)) # 每200格区域1个腐化土壤
	for i in range(corrupted_soil_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("corrupted_soil", pos, "被污染的土壤，可能种植特殊植物"))
	
	return features

static func _generate_dead_land_features(region: RegionData) -> Array[RegionFeature]:
	"""生成死地特性"""
	var features: Array[RegionFeature] = []
	var area = region.get_area()
	
	# 生成黑暗祭坛
	var dark_altar_count = max(1, int(area / 200)) # 每200格区域1个黑暗祭坛
	for i in range(dark_altar_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("dark_altar", pos, "邪恶的黑暗祭坛，魔法力量强大"))
	
	# 生成骸骨堆
	var bone_pile_count = max(1, int(area / 150)) # 每150格区域1个骸骨堆
	for i in range(bone_pile_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("bone_pile", pos, "堆积如山的骸骨，亡灵力量聚集"))
	
	# 生成魔法阵
	var magic_circle_count = max(1, int(area / 250)) # 每250格区域1个魔法阵
	for i in range(magic_circle_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("magic_circle", pos, "古老的魔法阵，可能召唤亡灵"))
	
	# 生成诅咒区域
	var cursed_zone_count = max(1, int(area / 300)) # 每300格区域1个诅咒区域
	for i in range(cursed_zone_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("cursed_zone", pos, "被诅咒的区域，危险但资源丰富"))
	
	# 生成魔化洞穴
	var corrupted_cave_count = max(1, int(area / 220)) # 每220格区域1个魔化洞穴
	for i in range(corrupted_cave_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("corrupted_cave", pos, "被魔法腐化的洞穴，充满邪恶力量"))
	
	# 生成深渊裂缝
	var abyss_crack_count = max(1, int(area / 400)) # 每400格区域1个深渊裂缝
	for i in range(abyss_crack_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("abyss_crack", pos, "通往深渊的裂缝，极度危险"))
	
	# 生成魔龙巢穴
	var dragon_lair_count = max(1, int(area / 500)) # 每500格区域1个魔龙巢穴
	for i in range(dragon_lair_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("dragon_lair", pos, "深渊魔龙的巢穴，极度危险但可能有宝藏"))
	
	# 生成诅咒祭坛
	var cursed_altar_count = max(1, int(area / 350)) # 每350格区域1个诅咒祭坛
	for i in range(cursed_altar_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("cursed_altar", pos, "被诅咒的祭坛，可能进行邪恶仪式"))
	
	return features

static func _generate_primitive_features(region: RegionData) -> Array[RegionFeature]:
	"""生成原始生态系统特性"""
	var features: Array[RegionFeature] = []
	var area = region.get_area()
	
	# 生成恐龙巢穴
	var nest_count = int(area * 0.1) # 密度0.1
	for i in range(nest_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("dinosaur_nest", pos, "恐龙的巢穴，散发着史前的气息"))
	
	# 生成史前遗迹
	var ruin_count = int(area * 0.05) # 密度0.05
	for i in range(ruin_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("prehistoric_ruins", pos, "古老的史前遗迹，隐藏着远古的秘密"))
	
	# 生成化石坑
	var fossil_pit_count = int(area * 0.08) # 密度0.08
	for i in range(fossil_pit_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("fossil_pit", pos, "富含化石的坑洞，可以挖掘到珍贵的化石"))
	
	# 生成原始森林
	var forest_count = int(area * 0.15) # 密度0.15
	for i in range(forest_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("primitive_forest", pos, "茂密的原始森林，生长着史前植物"))
	
	# 生成火山口
	var volcano_count = int(area * 0.02) # 密度0.02
	for i in range(volcano_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("volcano_crater", pos, "活跃的火山口，散发着炽热的气息"))
	
	# 生成龙血池
	var blood_pool_count = int(area * 0.01) # 密度0.01
	for i in range(blood_pool_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("dragon_blood_pool", pos, "神秘的龙血池，蕴含着强大的龙血力量"))
	
	# 生成古龙圣地
	var sanctuary_count = int(area * 0.005) # 密度0.005
	for i in range(sanctuary_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("ancient_dragon_sanctuary", pos, "古龙的神圣领地，散发着威严的气息"))
	
	# 生成龙骨墓地
	var graveyard_count = int(area * 0.003) # 密度0.003
	for i in range(graveyard_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("dragon_graveyard", pos, "古龙的墓地，埋葬着远古的龙族"))
	
	return features

# ============================================================================
# 工具函数
# ============================================================================

static func get_ecosystem_name(ecosystem_type: EcosystemType) -> String:
	"""获取生态类型名称"""
	match ecosystem_type:
		EcosystemType.FOREST: return "森林"
		EcosystemType.GRASSLAND: return "草地"
		EcosystemType.LAKE: return "湖泊"
		EcosystemType.CAVE: return "洞穴"
		EcosystemType.WASTELAND: return "荒地"
		EcosystemType.DEAD_LAND: return "死地"
		EcosystemType.PRIMITIVE: return "原始"
		_: return "未知"

static func get_ecosystem_description(ecosystem_type: EcosystemType) -> String:
	"""获取生态类型描述"""
	match ecosystem_type:
		EcosystemType.FOREST: return "茂密的森林，充满生机，有丰富的木材和草药资源"
		EcosystemType.GRASSLAND: return "开阔的草原，适合建造，有丰富的食物资源"
		EcosystemType.LAKE: return "清澈的湖泊，需要桥梁才能通过，有丰富的鱼类资源"
		EcosystemType.CAVE: return "神秘的洞穴，隐藏着矿物和宝石，但充满危险"
		EcosystemType.WASTELAND: return "贫瘠的荒地，资源稀少，但可能找到稀有矿物"
		EcosystemType.DEAD_LAND: return "危险的死地，充满魔法材料和危险生物"
		EcosystemType.PRIMITIVE: return "史前环境，以各种恐龙为核心，资源丰富但危险"
		_: return "未知的生态类型"
