extends Node
## 🏷️ 游戏组定义（Autoload单例）
## 定义所有Groups常量，用于批量管理游戏对象
## 替代逐个查找对象的低效方式

# === 环境Groups ===
const ENVIRONMENT = "environment"

# === 建筑Groups ===
const BUILDINGS = "buildings"
const DUNGEON_HEART = "dungeon_heart"
const RESOURCE_BUILDINGS = "resource_buildings"
const PRODUCTION_BUILDINGS = "production_buildings"
const DEFENSIVE_BUILDINGS = "defensive_buildings"
const TRAINING_BUILDINGS = "training_buildings"
const TREASURY = "treasury"

# === 资源Groups ===
const GOLD_MINES = "gold_mines"
const RESOURCE_NODES = "resource_nodes"
const COLLECTIBLES = "collectibles"
const MINING_ZONES = "mining_zones"
const INTERACTION_ZONES = "interaction_zones"

# === 角色Groups ===
const CHARACTERS = "characters"
const MONSTERS = "monsters"
const HEROES = "heroes"
const BEASTS = "beasts"
const WORKERS = "workers"
const ENGINEERS = "engineers"
const COMBAT_UNITS = "combat_units"

# === 后勤单位Groups（特定类型）===
const GOBLIN_WORKERS = "goblin_workers"
const GOBLIN_ENGINEERS = "goblin_engineers"

# === 怪物单位Groups（特定类型）===
const IMPS = "imps"
const ORC_WARRIORS = "orc_warriors"
const GARGOYLES = "gargoyles"
const FIRE_LIZARDS = "fire_lizards"
const SHADOW_MAGES = "shadow_mages"
const HELLHOUNDS = "hellhounds"
const TREANTS = "treants"
const SUCCUBI = "succubi"
const SHADOW_LORDS = "shadow_lords"
const STONE_GOLEMS = "stone_golems"
const BONE_DRAGONS = "bone_dragons"

# === 英雄单位Groups（特定类型）===
const KNIGHTS = "knights"
const ARCHERS = "archers"
const MAGES = "mages"
const PALADINS = "paladins"
const BERSERKERS = "berserkers"
const ARCHMAGES = "archmages"
const PRIESTS = "priests"
const RANGERS = "rangers"
const DRAGON_KNIGHTS = "dragon_knights"
const DRUIDS = "druids"
const SHADOW_BLADE_MASTERS = "shadow_blade_masters"
const THIEVES = "thieves"
const ASSASSINS = "assassins"

# === 野兽单位Groups（特定类型）===
const DEERS = "deers"
const FOREST_WOLVES = "forest_wolves"
const GIANT_RATS = "giant_rats"
const RABBITS = "rabbits"
const GRASSLAND_WOLVES = "grassland_wolves"
const RHINO_BEASTS = "rhino_beasts"
const FISHES = "fishes"
const FISH_MEN = "fish_men"
const GIANT_LIZARDS = "giant_lizards"
const SKELETONS = "skeletons"
const ZOMBIES = "zombies"
const DEMONS = "demons"
const SHADOW_BEASTS = "shadow_beasts"
const STONE_BEETLES = "stone_beetles"
const SHADOW_TIGERS = "shadow_tigers"
const SHADOW_SPIDERS = "shadow_spiders"
const POISON_SCORPIONS = "poison_scorpions"
const CLAW_BEARS = "claw_bears"
const CAVE_BATS = "cave_bats"

# 湖泊生态系统野兽Groups
const WATER_GRASS_FISH = "water_grass_fish"
const PLANKTON = "plankton"
const WATER_SNAKES = "water_snakes"
const WATER_BIRDS = "water_birds"
const LAKE_MONSTERS = "lake_monsters"

# 荒地生态系统野兽Groups
const RADIOACTIVE_SCORPIONS = "radioactive_scorpions"
const SANDSTORM_WOLVES = "sandstorm_wolves"
const MUTANT_RATS = "mutant_rats"
const CORRUPTED_WORMS = "corrupted_worms"

# 死地生态系统野兽Groups
const SHADOW_WOLVES = "shadow_wolves"
const CORRUPTED_BOARS = "corrupted_boars"
const MAGIC_VULTURES = "magic_vultures"
const SHADOW_PANTHERS = "shadow_panthers"
const ABYSS_DRAGONS = "abyss_dragons"

# 原始生态系统野兽Groups
const HORN_SHIELD_BEASTS = "horn_shield_beasts"
const SPINE_BACK_BEASTS = "spine_back_beasts"
const SCALE_ARMOR_BEASTS = "scale_armor_beasts"
const CLAW_HUNTER_BEASTS = "claw_hunter_beasts"
const RAGE_BEASTS = "rage_beasts"
const SHADOW_DRAGONS = "shadow_dragons"
const DRAGON_BLOOD_BEASTS = "dragon_blood_beasts"
const ANCIENT_DRAGON_OVERLORDS = "ancient_dragon_overlords"

# === 交互Groups ===
const INTERACTABLE = "interactable"
const DESTRUCTIBLE = "destructible"
const SELECTABLE = "selectable"
const MINEABLE = "mineable"

# === 状态Groups ===
const MOVING = "moving"
const ATTACKING = "attacking"
const IDLE = "idle"
const DEAD = "dead"

# === 状态名称常量 ===
# 🔧 避免硬编码状态名称字符串
const STATE_IDLE = "IdleState"
const STATE_WANDER = "WanderState"
const STATE_ESCAPE = "EscapeState"
const STATE_MINING = "MiningState"
const STATE_WORK = "WorkState"
const STATE_DEPOSIT_GOLD = "DepositGoldState"
const STATE_MOVE_TO_MINE = "MoveToMineState"
const STATE_RETURN_TO_BASE = "ReturnToBaseState"
const STATE_FETCH_GOLD = "FetchGoldState"
const STATE_MOVE_TO_TARGET = "MoveToTargetState"
const STATE_RETURN_GOLD = "ReturnGoldState"

# === 动画名称常量 ===
# 🔧 避免硬编码动画名称字符串
const ANIM_IDLE = "idle"
const ANIM_MOVE = "move"
const ANIM_RUN = "run"
const ANIM_WORK = "work"
const ANIM_DEPOSIT = "deposit"
const ANIM_HIT = "hit"

# === 建筑类型名称常量 ===
# 🔧 避免硬编码建筑类型名称字符串
const BUILDING_NAME_DUNGEON_HEART = "地牢之心"
const BUILDING_NAME_TREASURY = "金库"
const BUILDING_NAME_GOLD_MINE = "金矿"
const BUILDING_NAME_UNKNOWN = "未知"
const BUILDING_NAME_UNKNOWN_BUILDING = "未知建筑"


func _ready():
	"""初始化组管理器"""
	name = "GameGroups"
	LogManager.info("GameGroups - 组定义已初始化")


# === Groups操作API ===

static func add_node_to_group(node: Node, group_name: String):
	"""添加节点到组（重命名避免与Node.add_to_group()冲突）
	
	Args:
		node: 要添加的节点
		group_name: 组名
	"""
	if node and not node.is_in_group(group_name):
		node.add_to_group(group_name)

static func remove_node_from_group(node: Node, group_name: String):
	"""从组中移除节点（重命名避免与Node.remove_from_group()冲突）
	
	Args:
		node: 要移除的节点
		group_name: 组名
	"""
	if node and node.is_in_group(group_name):
		node.remove_from_group(group_name)

static func get_nodes(group_name: String) -> Array:
	"""获取组内所有节点
	
	Args:
		group_name: 组名
		
	Returns:
		节点数组
	"""
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_nodes_in_group(group_name)
	return []

static func get_first_node(group_name: String):
	"""获取组内第一个节点
	
	Args:
		group_name: 组名
		
	Returns:
		第一个节点，如果组为空则返回null
	"""
	var nodes = get_nodes(group_name)
	return nodes[0] if nodes.size() > 0 else null

static func count_nodes(group_name: String) -> int:
	"""获取组内节点数量
	
	Args:
		group_name: 组名
		
	Returns:
		节点数量
	"""
	return get_nodes(group_name).size()

static func is_node_in_group(node: Node, group_name: String) -> bool:
	"""检查节点是否在组内（重命名避免与Node.is_in_group()冲突）
	
	Args:
		node: 节点
		group_name: 组名
		
	Returns:
		是否在组内
	"""
	return node and node.is_in_group(group_name)


# === 便捷API ===

static func get_all_buildings() -> Array:
	"""获取所有建筑"""
	return get_nodes(BUILDINGS)

static func get_all_characters() -> Array:
	"""获取所有角色"""
	return get_nodes(CHARACTERS)

static func get_all_beasts() -> Array:
	"""获取所有野兽"""
	return get_nodes(BEASTS)

static func get_all_workers() -> Array:
	"""获取所有工人"""
	return get_nodes(WORKERS)

static func get_all_gold_mines() -> Array:
	"""获取所有金矿"""
	return get_nodes(GOLD_MINES)

static func get_dungeon_heart():
	"""获取地牢之心（应该只有一个）"""
	return get_first_node(DUNGEON_HEART)

# === 单位类型便捷API ===

static func get_all_goblin_workers() -> Array:
	"""获取所有哥布林苦工"""
	return get_nodes(GOBLIN_WORKERS)

static func get_all_goblin_engineers() -> Array:
	"""获取所有地精工程师"""
	return get_nodes(GOBLIN_ENGINEERS)

static func get_all_imps() -> Array:
	"""获取所有小鬼"""
	return get_nodes(IMPS)

static func get_all_orc_warriors() -> Array:
	"""获取所有兽人战士"""
	return get_nodes(ORC_WARRIORS)


# === 调试信息 ===

func print_group_status():
	"""打印所有组的状态"""
	LogManager.info("=== GameGroups Status ===")
	var groups = [
		BUILDINGS, DUNGEON_HEART, RESOURCE_BUILDINGS, PRODUCTION_BUILDINGS,
		GOLD_MINES, RESOURCE_NODES,
		CHARACTERS, MONSTERS, HEROES, BEASTS, WORKERS, ENGINEERS, COMBAT_UNITS,
		INTERACTABLE, DESTRUCTIBLE, SELECTABLE
	]
	for group in groups:
		var count = count_nodes(group)
		LogManager.info(group + ": " + str(count) + " nodes")
	LogManager.info("========================")
