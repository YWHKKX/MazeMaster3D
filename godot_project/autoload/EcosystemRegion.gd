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
	
	return features

static func _generate_forest_features(region: RegionData) -> Array[RegionFeature]:
	"""生成森林特性"""
	var features: Array[RegionFeature] = []
	
	# 生成古树
	if randf() < 0.3:
		var pos = region.get_random_point()
		features.append(RegionFeature.new("ancient_tree", pos, "古老的巨树"))
	
	# 生成浆果丛
	var berry_count = randi_range(1, 3)
	for i in range(berry_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("berry_bush", pos, "浆果丛"))
	
	# 生成草药点
	if randf() < 0.5:
		var pos = region.get_random_point()
		features.append(RegionFeature.new("herb_patch", pos, "草药生长点"))
	
	return features

static func _generate_grassland_features(region: RegionData) -> Array[RegionFeature]:
	"""生成草地特性"""
	var features: Array[RegionFeature] = []
	
	# 生成野花田
	if randf() < 0.4:
		var pos = region.get_random_point()
		features.append(RegionFeature.new("wildflower_field", pos, "野花田"))
	
	# 生成水井
	if randf() < 0.2:
		var pos = region.get_random_point()
		features.append(RegionFeature.new("water_well", pos, "水井"))
	
	return features

static func _generate_lake_features(region: RegionData) -> Array[RegionFeature]:
	"""生成湖泊特性"""
	var features: Array[RegionFeature] = []
	
	# 生成小岛
	if randf() < 0.3:
		var pos = region.get_random_point()
		features.append(RegionFeature.new("small_island", pos, "小岛"))
	
	# 生成瀑布
	if randf() < 0.2:
		var pos = region.get_random_point()
		features.append(RegionFeature.new("waterfall", pos, "瀑布"))
	
	return features

static func _generate_cave_features(region: RegionData) -> Array[RegionFeature]:
	"""生成洞穴特性"""
	var features: Array[RegionFeature] = []
	
	# 生成钟乳石
	var stalactite_count = randi_range(2, 5)
	for i in range(stalactite_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("stalactite", pos, "钟乳石"))
	
	# 生成水晶洞
	if randf() < 0.3:
		var pos = region.get_random_point()
		features.append(RegionFeature.new("crystal_cave", pos, "水晶洞"))
	
	return features

static func _generate_wasteland_features(region: RegionData) -> Array[RegionFeature]:
	"""生成荒地特性"""
	var features: Array[RegionFeature] = []
	
	# 生成废弃建筑
	if randf() < 0.4:
		var pos = region.get_random_point()
		features.append(RegionFeature.new("ruined_building", pos, "废弃建筑"))
	
	# 生成辐射点
	if randf() < 0.3:
		var pos = region.get_random_point()
		features.append(RegionFeature.new("radiation_zone", pos, "辐射区域"))
	
	return features

static func _generate_dead_land_features(region: RegionData) -> Array[RegionFeature]:
	"""生成死地特性"""
	var features: Array[RegionFeature] = []
	
	# 生成祭坛
	if randf() < 0.5:
		var pos = region.get_random_point()
		features.append(RegionFeature.new("dark_altar", pos, "黑暗祭坛"))
	
	# 生成骸骨堆
	var bone_pile_count = randi_range(1, 3)
	for i in range(bone_pile_count):
		var pos = region.get_random_point()
		features.append(RegionFeature.new("bone_pile", pos, "骸骨堆"))
	
	# 生成魔法阵
	if randf() < 0.3:
		var pos = region.get_random_point()
		features.append(RegionFeature.new("magic_circle", pos, "魔法阵"))
	
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
		_: return "未知的生态类型"
