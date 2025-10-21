extends Node

## 🌿 食物链管理系统 - 统一管理生态系统中的食物链关系
## 负责管理生物的食物链等级、生态系统类型和食物偏好

# ============================================================================
# 食物链等级枚举
# ============================================================================

enum FoodChainLevel {
	PRODUCER = 1, # 生产者（植物、浮游生物等）
	PRIMARY_CONSUMER = 2, # 初级消费者（草食动物）
	SECONDARY_CONSUMER = 3, # 次级消费者（小型肉食动物）
	TOP_CONSUMER = 4, # 顶级消费者（大型掠食者）
	APEX_PREDATOR = 5 # 终极统治者（顶级掠食者）
}

# ============================================================================
# 生态系统类型映射
# ============================================================================

## 野兽到生态系统类型的映射
const BEAST_ECOSYSTEM_MAP = {
	# 森林生态系统
	BeastsTypes.BeastType.DEER: EcosystemRegion.EcosystemType.FOREST,
	BeastsTypes.BeastType.FOREST_WOLF: EcosystemRegion.EcosystemType.FOREST,
	BeastsTypes.BeastType.SHADOW_TIGER: EcosystemRegion.EcosystemType.FOREST,
	BeastsTypes.BeastType.CLAW_BEAR: EcosystemRegion.EcosystemType.FOREST,
	
	# 草地生态系统
	BeastsTypes.BeastType.RABBIT: EcosystemRegion.EcosystemType.GRASSLAND,
	BeastsTypes.BeastType.GRASSLAND_WOLF: EcosystemRegion.EcosystemType.GRASSLAND,
	BeastsTypes.BeastType.RHINO_BEAST: EcosystemRegion.EcosystemType.GRASSLAND,
	
	# 湖泊生态系统
	BeastsTypes.BeastType.WATER_GRASS_FISH: EcosystemRegion.EcosystemType.LAKE,
	BeastsTypes.BeastType.PLANKTON: EcosystemRegion.EcosystemType.LAKE,
	BeastsTypes.BeastType.FISH: EcosystemRegion.EcosystemType.LAKE,
	BeastsTypes.BeastType.WATER_SNAKE: EcosystemRegion.EcosystemType.LAKE,
	BeastsTypes.BeastType.FISH_MAN: EcosystemRegion.EcosystemType.LAKE,
	BeastsTypes.BeastType.WATER_BIRD: EcosystemRegion.EcosystemType.LAKE,
	BeastsTypes.BeastType.WATER_TURTLE: EcosystemRegion.EcosystemType.LAKE,
	BeastsTypes.BeastType.WATER_CROCODILE: EcosystemRegion.EcosystemType.LAKE,
	BeastsTypes.BeastType.LAKE_MONSTER: EcosystemRegion.EcosystemType.LAKE,
	
	# 洞穴生态系统
	BeastsTypes.BeastType.GIANT_RAT: EcosystemRegion.EcosystemType.CAVE,
	BeastsTypes.BeastType.POISON_SCORPION: EcosystemRegion.EcosystemType.CAVE,
	BeastsTypes.BeastType.STONE_BEETLE: EcosystemRegion.EcosystemType.CAVE,
	BeastsTypes.BeastType.SHADOW_SPIDER: EcosystemRegion.EcosystemType.CAVE,
	BeastsTypes.BeastType.CAVE_BAT: EcosystemRegion.EcosystemType.CAVE,
	
	# 荒地生态系统
	BeastsTypes.BeastType.GIANT_LIZARD: EcosystemRegion.EcosystemType.WASTELAND,
	BeastsTypes.BeastType.RADIOACTIVE_SCORPION: EcosystemRegion.EcosystemType.WASTELAND,
	BeastsTypes.BeastType.SANDSTORM_WOLF: EcosystemRegion.EcosystemType.WASTELAND,
	BeastsTypes.BeastType.MUTANT_RAT: EcosystemRegion.EcosystemType.WASTELAND,
	BeastsTypes.BeastType.CORRUPTED_WORM: EcosystemRegion.EcosystemType.WASTELAND,
	
	# 死地生态系统
	BeastsTypes.BeastType.SHADOW_WOLF: EcosystemRegion.EcosystemType.DEAD_LAND,
	BeastsTypes.BeastType.CORRUPTED_BOAR: EcosystemRegion.EcosystemType.DEAD_LAND,
	BeastsTypes.BeastType.MAGIC_VULTURE: EcosystemRegion.EcosystemType.DEAD_LAND,
	BeastsTypes.BeastType.HELLHOUND: EcosystemRegion.EcosystemType.DEAD_LAND,
	BeastsTypes.BeastType.SHADOW_PANTHER: EcosystemRegion.EcosystemType.DEAD_LAND,
	BeastsTypes.BeastType.ABYSS_DRAGON: EcosystemRegion.EcosystemType.DEAD_LAND,
	BeastsTypes.BeastType.SHADOW_BEAST: EcosystemRegion.EcosystemType.DEAD_LAND,
	BeastsTypes.BeastType.CLAW_HUNTER_BEAST: EcosystemRegion.EcosystemType.DEAD_LAND,
	
	# 原始生态系统
	BeastsTypes.BeastType.HORN_SHIELD_DRAGON: EcosystemRegion.EcosystemType.PRIMITIVE,
	BeastsTypes.BeastType.SPINE_BACK_DRAGON: EcosystemRegion.EcosystemType.PRIMITIVE,
	BeastsTypes.BeastType.SCALE_ARMOR_DRAGON: EcosystemRegion.EcosystemType.PRIMITIVE,
	BeastsTypes.BeastType.CLAW_HUNTER_DRAGON: EcosystemRegion.EcosystemType.PRIMITIVE,
	BeastsTypes.BeastType.RAGE_DRAGON: EcosystemRegion.EcosystemType.PRIMITIVE,
	BeastsTypes.BeastType.RAGE_BEAST: EcosystemRegion.EcosystemType.PRIMITIVE,
	BeastsTypes.BeastType.SHADOW_DRAGON: EcosystemRegion.EcosystemType.PRIMITIVE,
	BeastsTypes.BeastType.DRAGON_BLOOD_BEAST: EcosystemRegion.EcosystemType.PRIMITIVE,
	BeastsTypes.BeastType.ANCIENT_DRAGON_OVERLORD: EcosystemRegion.EcosystemType.PRIMITIVE
}

# ============================================================================
# 食物链等级映射
# ============================================================================

## 野兽到食物链等级的映射
const BEAST_FOOD_CHAIN_MAP = {
	# 初级消费者（2级）
	BeastsTypes.BeastType.PLANKTON: FoodChainLevel.PRIMARY_CONSUMER,
	BeastsTypes.BeastType.DEER: FoodChainLevel.PRIMARY_CONSUMER,
	BeastsTypes.BeastType.RABBIT: FoodChainLevel.PRIMARY_CONSUMER,
	BeastsTypes.BeastType.WATER_GRASS_FISH: FoodChainLevel.PRIMARY_CONSUMER,
	BeastsTypes.BeastType.GIANT_RAT: FoodChainLevel.PRIMARY_CONSUMER,
	BeastsTypes.BeastType.MUTANT_RAT: FoodChainLevel.PRIMARY_CONSUMER,
	BeastsTypes.BeastType.SHADOW_WOLF: FoodChainLevel.PRIMARY_CONSUMER,
	BeastsTypes.BeastType.HORN_SHIELD_DRAGON: FoodChainLevel.PRIMARY_CONSUMER,
	BeastsTypes.BeastType.SPINE_BACK_DRAGON: FoodChainLevel.PRIMARY_CONSUMER,
	BeastsTypes.BeastType.CORRUPTED_WORM: FoodChainLevel.PRIMARY_CONSUMER,
	
	# 次级消费者（3级）
	BeastsTypes.BeastType.FOREST_WOLF: FoodChainLevel.SECONDARY_CONSUMER,
	BeastsTypes.BeastType.GRASSLAND_WOLF: FoodChainLevel.SECONDARY_CONSUMER,
	BeastsTypes.BeastType.WATER_SNAKE: FoodChainLevel.SECONDARY_CONSUMER,
	BeastsTypes.BeastType.FISH_MAN: FoodChainLevel.SECONDARY_CONSUMER,
	BeastsTypes.BeastType.POISON_SCORPION: FoodChainLevel.SECONDARY_CONSUMER,
	BeastsTypes.BeastType.STONE_BEETLE: FoodChainLevel.SECONDARY_CONSUMER,
	BeastsTypes.BeastType.SHADOW_SPIDER: FoodChainLevel.SECONDARY_CONSUMER,
	BeastsTypes.BeastType.CAVE_BAT: FoodChainLevel.SECONDARY_CONSUMER,
	BeastsTypes.BeastType.RADIOACTIVE_SCORPION: FoodChainLevel.SECONDARY_CONSUMER,
	BeastsTypes.BeastType.SANDSTORM_WOLF: FoodChainLevel.SECONDARY_CONSUMER,
	BeastsTypes.BeastType.CORRUPTED_BOAR: FoodChainLevel.SECONDARY_CONSUMER,
	BeastsTypes.BeastType.SCALE_ARMOR_DRAGON: FoodChainLevel.SECONDARY_CONSUMER,
	BeastsTypes.BeastType.CLAW_HUNTER_DRAGON: FoodChainLevel.SECONDARY_CONSUMER,
	BeastsTypes.BeastType.CLAW_HUNTER_BEAST: FoodChainLevel.SECONDARY_CONSUMER,
	
	# 顶级消费者（4级）
	BeastsTypes.BeastType.SHADOW_TIGER: FoodChainLevel.TOP_CONSUMER,
	BeastsTypes.BeastType.CLAW_BEAR: FoodChainLevel.TOP_CONSUMER,
	BeastsTypes.BeastType.RHINO_BEAST: FoodChainLevel.TOP_CONSUMER,
	BeastsTypes.BeastType.WATER_BIRD: FoodChainLevel.TOP_CONSUMER,
	BeastsTypes.BeastType.WATER_TURTLE: FoodChainLevel.TOP_CONSUMER,
	BeastsTypes.BeastType.WATER_CROCODILE: FoodChainLevel.TOP_CONSUMER,
	BeastsTypes.BeastType.LAKE_MONSTER: FoodChainLevel.TOP_CONSUMER,
	BeastsTypes.BeastType.GIANT_LIZARD: FoodChainLevel.TOP_CONSUMER,
	BeastsTypes.BeastType.MAGIC_VULTURE: FoodChainLevel.TOP_CONSUMER,
	BeastsTypes.BeastType.SHADOW_PANTHER: FoodChainLevel.TOP_CONSUMER,
	BeastsTypes.BeastType.RAGE_DRAGON: FoodChainLevel.TOP_CONSUMER,
	BeastsTypes.BeastType.SHADOW_DRAGON: FoodChainLevel.TOP_CONSUMER,
	BeastsTypes.BeastType.DRAGON_BLOOD_BEAST: FoodChainLevel.TOP_CONSUMER,
	
	# 高级消费者（4级）
	BeastsTypes.BeastType.HELLHOUND: FoodChainLevel.TOP_CONSUMER,
	BeastsTypes.BeastType.SHADOW_BEAST: FoodChainLevel.TOP_CONSUMER,
	
	# 终极统治者（5级）
	BeastsTypes.BeastType.ABYSS_DRAGON: FoodChainLevel.APEX_PREDATOR,
	BeastsTypes.BeastType.ANCIENT_DRAGON_OVERLORD: FoodChainLevel.APEX_PREDATOR
}

# ============================================================================
# 食物偏好映射
# ============================================================================

## 野兽到食物偏好的映射
const BEAST_FOOD_PREFERENCES = {
	# 森林生态系统食物偏好
	BeastsTypes.BeastType.DEER: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.BERRY],
	BeastsTypes.BeastType.FOREST_WOLF: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.BERRY],
	BeastsTypes.BeastType.SHADOW_TIGER: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.BERRY],
	BeastsTypes.BeastType.CLAW_BEAR: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.BERRY],
	
	# 草地生态系统食物偏好
	BeastsTypes.BeastType.RABBIT: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.CROP],
	BeastsTypes.BeastType.GRASSLAND_WOLF: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.CROP],
	BeastsTypes.BeastType.RHINO_BEAST: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.CROP],
	
	# 湖泊生态系统食物偏好
	BeastsTypes.BeastType.WATER_GRASS_FISH: [ResourceTypes.ResourceType.AQUATIC_PLANT, ResourceTypes.ResourceType.FOOD],
	BeastsTypes.BeastType.PLANKTON: [ResourceTypes.ResourceType.AQUATIC_PLANT, ResourceTypes.ResourceType.FOOD],
	BeastsTypes.BeastType.FISH: [ResourceTypes.ResourceType.AQUATIC_PLANT, ResourceTypes.ResourceType.FOOD],
	BeastsTypes.BeastType.WATER_SNAKE: [ResourceTypes.ResourceType.AQUATIC_PLANT, ResourceTypes.ResourceType.FOOD],
	BeastsTypes.BeastType.FISH_MAN: [ResourceTypes.ResourceType.AQUATIC_PLANT, ResourceTypes.ResourceType.FOOD],
	BeastsTypes.BeastType.WATER_BIRD: [ResourceTypes.ResourceType.AQUATIC_PLANT, ResourceTypes.ResourceType.FOOD],
	BeastsTypes.BeastType.WATER_TURTLE: [ResourceTypes.ResourceType.AQUATIC_PLANT, ResourceTypes.ResourceType.FOOD],
	BeastsTypes.BeastType.WATER_CROCODILE: [ResourceTypes.ResourceType.AQUATIC_PLANT, ResourceTypes.ResourceType.FOOD],
	BeastsTypes.BeastType.LAKE_MONSTER: [ResourceTypes.ResourceType.AQUATIC_PLANT, ResourceTypes.ResourceType.FOOD],
	
	# 洞穴生态系统食物偏好
	BeastsTypes.BeastType.GIANT_RAT: [ResourceTypes.ResourceType.MUSHROOM, ResourceTypes.ResourceType.STONE],
	BeastsTypes.BeastType.POISON_SCORPION: [ResourceTypes.ResourceType.MUSHROOM, ResourceTypes.ResourceType.STONE],
	BeastsTypes.BeastType.STONE_BEETLE: [ResourceTypes.ResourceType.MUSHROOM, ResourceTypes.ResourceType.STONE],
	BeastsTypes.BeastType.SHADOW_SPIDER: [ResourceTypes.ResourceType.MUSHROOM, ResourceTypes.ResourceType.STONE],
	BeastsTypes.BeastType.CAVE_BAT: [ResourceTypes.ResourceType.MUSHROOM, ResourceTypes.ResourceType.STONE],
	
	# 荒地生态系统食物偏好
	BeastsTypes.BeastType.GIANT_LIZARD: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.RARE_MINERAL],
	BeastsTypes.BeastType.RADIOACTIVE_SCORPION: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.RARE_MINERAL],
	BeastsTypes.BeastType.SANDSTORM_WOLF: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.RARE_MINERAL],
	BeastsTypes.BeastType.MUTANT_RAT: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.RARE_MINERAL],
	BeastsTypes.BeastType.CORRUPTED_WORM: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.STONE],
	
	# 死地生态系统食物偏好
	BeastsTypes.BeastType.SHADOW_WOLF: [ResourceTypes.ResourceType.MAGIC_CRYSTAL, ResourceTypes.ResourceType.HERB],
	BeastsTypes.BeastType.CORRUPTED_BOAR: [ResourceTypes.ResourceType.MAGIC_CRYSTAL, ResourceTypes.ResourceType.HERB],
	BeastsTypes.BeastType.MAGIC_VULTURE: [ResourceTypes.ResourceType.MAGIC_CRYSTAL, ResourceTypes.ResourceType.HERB],
	BeastsTypes.BeastType.HELLHOUND: [ResourceTypes.ResourceType.MAGIC_CRYSTAL, ResourceTypes.ResourceType.HERB],
	BeastsTypes.BeastType.SHADOW_PANTHER: [ResourceTypes.ResourceType.MAGIC_CRYSTAL, ResourceTypes.ResourceType.HERB],
	BeastsTypes.BeastType.ABYSS_DRAGON: [ResourceTypes.ResourceType.MAGIC_CRYSTAL, ResourceTypes.ResourceType.HERB],
	BeastsTypes.BeastType.SHADOW_BEAST: [ResourceTypes.ResourceType.MAGIC_CRYSTAL, ResourceTypes.ResourceType.HERB],
	BeastsTypes.BeastType.CLAW_HUNTER_BEAST: [ResourceTypes.ResourceType.MAGIC_CRYSTAL, ResourceTypes.ResourceType.HERB],
	
	# 原始生态系统食物偏好
	BeastsTypes.BeastType.HORN_SHIELD_DRAGON: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM],
	BeastsTypes.BeastType.SPINE_BACK_DRAGON: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM],
	BeastsTypes.BeastType.SCALE_ARMOR_DRAGON: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM],
	BeastsTypes.BeastType.CLAW_HUNTER_DRAGON: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM],
	BeastsTypes.BeastType.RAGE_DRAGON: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM],
	BeastsTypes.BeastType.RAGE_BEAST: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM],
	BeastsTypes.BeastType.SHADOW_DRAGON: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM],
	BeastsTypes.BeastType.DRAGON_BLOOD_BEAST: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM],
	BeastsTypes.BeastType.ANCIENT_DRAGON_OVERLORD: [ResourceTypes.ResourceType.HERB, ResourceTypes.ResourceType.MUSHROOM]
}

# ============================================================================
# 公共接口
# ============================================================================

## 获取野兽的生态系统类型
static func get_beast_ecosystem_type(beast_type: BeastsTypes.BeastType) -> EcosystemRegion.EcosystemType:
	"""获取野兽所属的生态系统类型"""
	return BEAST_ECOSYSTEM_MAP.get(beast_type, EcosystemRegion.EcosystemType.FOREST)

## 获取野兽的食物链等级
static func get_beast_food_chain_level(beast_type: BeastsTypes.BeastType) -> FoodChainLevel:
	"""获取野兽在食物链中的等级"""
	return BEAST_FOOD_CHAIN_MAP.get(beast_type, FoodChainLevel.PRIMARY_CONSUMER)

## 获取野兽的食物偏好
static func get_beast_food_preferences(beast_type: BeastsTypes.BeastType) -> Array[ResourceTypes.ResourceType]:
	"""获取野兽的食物偏好列表"""
	return BEAST_FOOD_PREFERENCES.get(beast_type, [ResourceTypes.ResourceType.HERB])

## 获取食物链等级名称
static func get_food_chain_level_name(level: FoodChainLevel) -> String:
	"""获取食物链等级的中文名称"""
	match level:
		FoodChainLevel.PRODUCER: return "生产者"
		FoodChainLevel.PRIMARY_CONSUMER: return "初级消费者"
		FoodChainLevel.SECONDARY_CONSUMER: return "次级消费者"
		FoodChainLevel.TOP_CONSUMER: return "顶级消费者"
		FoodChainLevel.APEX_PREDATOR: return "终极统治者"
		_: return "未知等级"

## 检查两个野兽是否存在捕食关系
static func is_predator_prey(predator_type: BeastsTypes.BeastType, prey_type: BeastsTypes.BeastType) -> bool:
	"""检查是否存在捕食关系（捕食者的等级必须高于被捕食者）"""
	var predator_level: FoodChainLevel = get_beast_food_chain_level(predator_type)
	var prey_level: FoodChainLevel = get_beast_food_chain_level(prey_type)
	return predator_level > prey_level

## 获取生态系统中的所有野兽类型
static func get_beasts_by_ecosystem(ecosystem_type: EcosystemRegion.EcosystemType) -> Array[BeastsTypes.BeastType]:
	"""获取指定生态系统中的所有野兽类型"""
	var beasts: Array[BeastsTypes.BeastType] = []
	for beast_type in BEAST_ECOSYSTEM_MAP.keys():
		if BEAST_ECOSYSTEM_MAP[beast_type] == ecosystem_type:
			beasts.append(beast_type)
	return beasts

## 获取指定食物链等级的所有野兽类型
static func get_beasts_by_food_chain_level(level: FoodChainLevel) -> Array[BeastsTypes.BeastType]:
	"""获取指定食物链等级的所有野兽类型"""
	var beasts: Array[BeastsTypes.BeastType] = []
	for beast_type in BEAST_FOOD_CHAIN_MAP.keys():
		if BEAST_FOOD_CHAIN_MAP[beast_type] == level:
			beasts.append(beast_type)
	return beasts

## 获取野兽的完整生态信息
static func get_beast_ecology_info(beast_type: BeastsTypes.BeastType) -> Dictionary:
	"""获取野兽的完整生态信息"""
	return {
		"ecosystem_type": get_beast_ecosystem_type(beast_type),
		"food_chain_level": get_beast_food_chain_level(beast_type),
		"food_preferences": get_beast_food_preferences(beast_type),
		"ecosystem_name": EcosystemRegion.get_ecosystem_name(get_beast_ecosystem_type(beast_type)),
		"food_chain_name": get_food_chain_level_name(get_beast_food_chain_level(beast_type))
	}

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	LogManager.info("FoodChainManager - 食物链管理系统已初始化")
