extends RefCounted
class_name BuildingComponents

## 🏗️ 建筑构件常量类
## 定义所有建筑构件的ID和属性

# ========================================
# 建筑构件ID常量定义 - 重新整理版本
# ========================================

# 空构件
const ID_EMPTY = 0

# ========================================
# 基础结构构件 (1-50) - 预留50个ID
# ========================================
const ID_FLOOR_STONE = 1
const ID_FLOOR_WOOD = 2
const ID_FLOOR_METAL = 3
const ID_WALL_STONE = 4
const ID_WALL_WOOD = 5
const ID_WALL_METAL = 6
const ID_CORNER_STONE = 7
const ID_CORNER_WOOD = 8
const ID_CORNER_METAL = 9
const ID_ROOF_TILE = 10
const ID_ROOF_SLOPE = 11
const ID_ROOF_PEAK = 12
const ID_STAIRS_WOOD = 13
const ID_STAIRS_STONE = 14
const ID_FLOOR_TRAP = 15

# ========================================
# 门窗构件 (51-100) - 预留50个ID
# ========================================
const ID_DOOR_WOOD = 51
const ID_DOOR_METAL = 52
const ID_GATE_STONE = 53
const ID_WINDOW_SMALL = 54
const ID_WINDOW_LARGE = 55

# ========================================
# 装饰构件 (101-150) - 预留50个ID
# ========================================
const ID_PILLAR_STONE = 101
const ID_PILLAR_WOOD = 102
const ID_TORCH_WALL = 103
const ID_BANNER_CLOTH = 104
const ID_STATUE_STONE = 105

# ========================================
# 魔法构件 (151-200) - 预留50个ID
# ========================================
const ID_MAGIC_CRYSTAL = 151
const ID_ENERGY_RUNE = 152
const ID_MAGIC_CORE = 153
const ID_ENERGY_CONDUIT = 154
const ID_ENERGY_NODE = 155
const ID_STORAGE_CORE = 156
const ID_MANA_POOL = 157
const ID_MAGIC_ALTAR = 158
const ID_HELL_FIRE = 159
const ID_DARK_FLAME = 160
const ID_DEMON_CORE = 161
const ID_SUMMONING_CIRCLE = 162
const ID_DEMON_HORN = 163
const ID_MANA_CRYSTAL = 164
const ID_WISDOM_CRYSTAL = 165
const ID_DARK_CRYSTAL = 166
const ID_HEALING_CRYSTAL = 167
const ID_SHADOW_RUNE = 168
const ID_MAGIC_SCROLL = 169

# ========================================
# 军事构件 (201-250) - 预留50个ID
# ========================================
const ID_ARROW_SLOT = 201
const ID_CROSSBOW = 202
const ID_AMMO_RACK = 203
const ID_WATCHTOWER = 204
const ID_BATTLE_STANDARD = 205
const ID_TRAINING_POST = 206
const ID_TRAINING_GROUND = 207
const ID_WAR_DRUM = 208
const ID_DEMON_CLAW = 209

# ========================================
# 资源构件 (251-300) - 预留50个ID
# ========================================
const ID_GOLD_PILE = 251
const ID_TREASURE_CHEST = 252
const ID_RESOURCE_NODE = 253
const ID_STORAGE_CRATE = 254
const ID_GEM_PILE = 255
const ID_COIN_STACK = 256
const ID_POTION_BOTTLE = 257
const ID_ARTIFACT_DISPLAY = 258

# ========================================
# 知识构件 (301-350) - 预留50个ID
# ========================================
const ID_BOOKSHELF = 301
const ID_RESEARCH_TABLE = 302
const ID_KNOWLEDGE_ORB = 303
const ID_SCROLL_RACK = 304
const ID_STUDY_LAMP = 305
const ID_ANCIENT_TEXT = 306

# ========================================
# 恶魔构件 (351-400) - 预留50个ID
# ========================================
const ID_SOUL_CAGE = 351
const ID_BLOOD_POOL = 352
const ID_SKULL_PILE = 353
const ID_BONE_THRONE = 354
const ID_CHAOS_CRYSTAL = 355
const ID_INFERNAL_ALTAR = 356

# ========================================
# 暗影构件 (401-450) - 预留50个ID
# ========================================
const ID_SHADOW_ALTAR = 401
const ID_SHADOW_POOL = 402
const ID_SHADOW_WALL = 403
const ID_SHADOW_VEIL = 404
const ID_VOID_ORB = 405
const ID_SHADOW_FLAME = 406
const ID_DARK_RITUAL = 407
const ID_SHADOW_CORE = 408

# ========================================
# 兽人构件 (451-500) - 预留50个ID
# ========================================
const ID_ORC_SKULL = 451
const ID_BONE_PILE = 452
const ID_PRIMITIVE_TOTEM = 453
const ID_ORC_SHACK = 454
const ID_ORC_WEAPON_RACK = 455
const ID_ORC_ENTRANCE = 456
const ID_ORC_BONE = 457
const ID_ORC_BANNER = 458
const ID_BONE_NECKLACE = 459
const ID_PRIMITIVE_AXE = 460
const ID_TRIBAL_MASK = 461
const ID_WAR_HORN = 462
const ID_SACRED_TOTEM = 463
const ID_BLOOD_RITUAL = 464

# ========================================
# 地牢之心专用构件 (801-850) - 预留50个ID
# ========================================
const ID_HEART_CORE = 801
const ID_ENERGY_CONDUIT_2 = 802
const ID_POWER_NODE = 803
const ID_CORE_CHAMBER = 804
const ID_ENERGY_FLOW = 805
const ID_HEART_ENTRANCE = 806

# ========================================
# 金库专用构件 (851-900) - 预留50个ID
# ========================================
const ID_TREASURE_CHEST_2 = 851
const ID_GOLD_PILE_2 = 852
const ID_GOLD_BAR = 853
const ID_VAULT_DOOR = 854
const ID_GOLD_COIN = 855

# ========================================
# 奥术塔专用构件 (901-950) - 预留50个ID
# ========================================
const ID_CRYSTAL_BALL = 901
const ID_MAGIC_CIRCLE = 902
const ID_ARCANE_ORB = 903
const ID_SPELL_BOOK = 904
const ID_RUNE_STONE = 905

# ========================================
# 兵营专用构件 (951-1000) - 预留50个ID
# ========================================
const ID_MILITARY_FLAG = 951
const ID_CAMPFIRE = 952
const ID_BARRACKS_BUNK = 953
const ID_ARMOR_STAND = 954
const ID_SHIELD_RACK = 955

# ========================================
# 工坊专用构件 (1001-1050) - 预留50个ID
# ========================================
const ID_WORKBENCH = 1001
const ID_FORGE = 1002
const ID_TOOL_RACK = 1003
const ID_ANVIL = 1004
const ID_MATERIAL_PILE = 1005
const ID_HAMMER = 1006
const ID_CHISEL = 1007

# ========================================
# 医院专用构件 (1051-1100) - 预留50个ID
# ========================================
const ID_HOSPITAL_BED = 1051
const ID_MEDICAL_EQUIPMENT = 1052
const ID_SURGICAL_TABLE = 1053
const ID_MEDICAL_SCANNER = 1054
const ID_NURSING_STATION = 1055
const ID_OPERATING_ROOM = 1056
const ID_PHARMACY = 1057

# ========================================
# 市场专用构件 (1101-1150) - 预留50个ID
# ========================================
const ID_VENDOR_STALL = 1101
const ID_TRADING_DESK = 1102
const ID_DISPLAY_COUNTER = 1103
const ID_MERCHANT_CART = 1104
const ID_GOODS_STORAGE = 1105
const ID_COIN_COUNTER = 1106
const ID_MARKET_BANNER = 1108
const ID_MARKET_SIGN = 1109
const ID_GOLDEN_CREST = 1110

# ========================================
# 暗影神殿专用构件 (1151-1200) - 预留50个ID
# ========================================
const ID_SHADOW_CORE_2 = 1151
const ID_SHADOW_FLAME_2 = 1152
const ID_SHADOW_POOL_2 = 1153

# ========================================
# 学院专用构件 (1201-1250) - 预留50个ID
# ========================================
const ID_SCHOLAR_STATUE = 1201
const ID_ACADEMY_TOWER = 1202
const ID_WISDOM_TOWER = 1203
const ID_RESEARCH_LAB = 1204
const ID_ACADEMIC_BANNER = 1205
const ID_CLASSROOM_DESK = 1206
const ID_TEACHER_PODIUM = 1207
const ID_ACADEMIC_LIBRARY = 1208
const ID_ACADEMY_ENTRANCE = 1209

# ========================================
# 工厂专用构件 (1251-1300) - 预留50个ID
# ========================================
const ID_ASSEMBLY_LINE = 1251
const ID_CONVEYOR_BELT = 1252
const ID_SMOKESTACK = 1253
const ID_VENTILATION = 1254

# ========================================
# 图书馆专用构件 (1301-1350) - 预留50个ID
# ========================================
const ID_BOOK_PILE = 1302
const ID_READING_DESK = 1303

# ========================================
# 魔法祭坛专用构件 (1351-1400) - 预留50个ID
# ========================================
const ID_ENERGY_CRYSTAL = 1357

# ========================================
# 暗影神殿专用构件 (1401-1450) - 预留50个ID
# ========================================

# ========================================
# 通用装饰构件 (1451-1500) - 预留50个ID
# ========================================
const ID_WOODEN_PALISADE = 1452
const ID_WEAPON_RACK = 1453
const ID_RECEPTION_DESK = 1454
const ID_WELCOME_MAT = 1455

# ========================================
# 构件ID到文件名的映射表
# ========================================
static var COMPONENT_FILE_MAPPING = {
	# 基础结构构件
	ID_FLOOR_STONE: "res://scenes/buildings/common/components/Floor_Stone",
	ID_FLOOR_WOOD: "res://scenes/buildings/common/components/Floor_Wood",
	ID_FLOOR_METAL: "res://scenes/buildings/common/components/Floor_Metal",
	ID_WALL_STONE: "res://scenes/buildings/common/components/Wall_Stone",
	ID_WALL_WOOD: "res://scenes/buildings/common/components/Wall_Wood",
	ID_WALL_METAL: "res://scenes/buildings/common/components/Wall_Metal",
	ID_CORNER_STONE: "res://scenes/buildings/common/components/Corner_Stone",
	ID_CORNER_WOOD: "res://scenes/buildings/common/components/Corner_Wood",
	ID_CORNER_METAL: "res://scenes/buildings/common/components/Corner_Metal",
	ID_ROOF_TILE: "res://scenes/buildings/common/components/Roof_Tile",
	ID_ROOF_SLOPE: "res://scenes/buildings/common/components/Roof_Slope",
	ID_ROOF_PEAK: "res://scenes/buildings/common/components/Roof_Peak",
	ID_STAIRS_WOOD: "res://scenes/buildings/common/components/Stairs_Wood",
	ID_STAIRS_STONE: "res://scenes/buildings/common/components/Stairs_Stone",
	ID_FLOOR_TRAP: "res://scenes/buildings/common/components/Floor_Trap",
	
	# 门窗构件
	ID_DOOR_WOOD: "res://scenes/buildings/common/components/Door_Wood",
	ID_DOOR_METAL: "res://scenes/buildings/common/components/Door_Metal",
	ID_GATE_STONE: "res://scenes/buildings/common/components/Gate_Stone",
	ID_WINDOW_SMALL: "res://scenes/buildings/common/components/Window_Small",
	ID_WINDOW_LARGE: "res://scenes/buildings/common/components/Window_Large",
	
	# 装饰构件
	ID_PILLAR_STONE: "res://scenes/buildings/common/components/Pillar_Stone",
	ID_PILLAR_WOOD: "res://scenes/buildings/common/components/Pillar_Wood",
	ID_TORCH_WALL: "res://scenes/buildings/common/components/Torch_Wall",
	ID_BANNER_CLOTH: "res://scenes/buildings/common/components/Banner_Cloth",
	ID_STATUE_STONE: "res://scenes/buildings/common/components/Statue_Stone",
	
	# 魔法构件
	ID_MAGIC_CRYSTAL: "Magic_Crystal",
	ID_ENERGY_RUNE: "Energy_Rune",
	ID_MAGIC_CORE: "Magic_Core",
	ID_ENERGY_CONDUIT: "Energy_Conduit",
	ID_ENERGY_NODE: "Energy_Node",
	ID_STORAGE_CORE: "Storage_Core",
	ID_MANA_POOL: "Mana_Pool",
	ID_MAGIC_ALTAR: "Magic_Altar",
	ID_HELL_FIRE: "Hell_Fire",
	ID_DARK_FLAME: "Dark_Flame",
	ID_DEMON_CORE: "Demon_Core",
	ID_SUMMONING_CIRCLE: "Summoning_Circle",
	ID_DEMON_HORN: "Demon_Horn",
	ID_MANA_CRYSTAL: "Mana_Crystal",
	ID_WISDOM_CRYSTAL: "Wisdom_Crystal",
	ID_DARK_CRYSTAL: "Dark_Crystal",
	ID_HEALING_CRYSTAL: "Healing_Crystal",
	ID_SHADOW_RUNE: "Shadow_Rune",
	ID_MAGIC_SCROLL: "Magic_Scroll",
	
	# 军事构件
	ID_ARROW_SLOT: "Arrow_Slot",
	ID_CROSSBOW: "Crossbow",
	ID_AMMO_RACK: "Ammo_Rack",
	ID_WATCHTOWER: "Watchtower",
	ID_BATTLE_STANDARD: "Battle_Standard",
	ID_TRAINING_POST: "Training_Post",
	ID_TRAINING_GROUND: "Training_Ground",
	ID_WAR_DRUM: "War_Drum",
	ID_DEMON_CLAW: "Demon_Claw",
	
	# 资源构件
	ID_GOLD_PILE: "Gold_Pile",
	ID_TREASURE_CHEST: "Treasure_Chest",
	ID_RESOURCE_NODE: "Resource_Node",
	ID_STORAGE_CRATE: "Storage_Crate",
	ID_GEM_PILE: "Gem_Pile",
	ID_COIN_STACK: "Coin_Stack",
	ID_POTION_BOTTLE: "Potion_Bottle",
	ID_ARTIFACT_DISPLAY: "Artifact_Display",
	
	# 知识构件
	ID_BOOKSHELF: "Bookshelf",
	ID_RESEARCH_TABLE: "Research_Table",
	ID_KNOWLEDGE_ORB: "Knowledge_Orb",
	ID_SCROLL_RACK: "Scroll_Rack",
	ID_STUDY_LAMP: "Study_Lamp",
	ID_ANCIENT_TEXT: "Ancient_Text",
	
	# 恶魔构件
	ID_SOUL_CAGE: "Soul_Cage",
	ID_BLOOD_POOL: "Blood_Pool",
	ID_SKULL_PILE: "Skull_Pile",
	ID_BONE_THRONE: "Bone_Throne",
	ID_CHAOS_CRYSTAL: "Chaos_Crystal",
	ID_INFERNAL_ALTAR: "Infernal_Altar",
	
	# 暗影构件
	ID_SHADOW_ALTAR: "Shadow_Altar",
	ID_SHADOW_POOL: "Shadow_Pool",
	ID_SHADOW_WALL: "Shadow_Wall",
	ID_SHADOW_VEIL: "Shadow_Veil",
	ID_VOID_ORB: "Void_Orb",
	ID_SHADOW_FLAME: "Shadow_Flame",
	ID_DARK_RITUAL: "Dark_Ritual",
	ID_SHADOW_CORE: "Shadow_Core",
	
	# 兽人构件
	ID_ORC_SKULL: "Orc_Skull",
	ID_BONE_PILE: "Bone_Pile",
	ID_PRIMITIVE_TOTEM: "Primitive_Totem",
	ID_ORC_SHACK: "Orc_Shack",
	ID_ORC_WEAPON_RACK: "Orc_Weapon_Rack",
	ID_ORC_ENTRANCE: "Orc_Entrance",
	ID_ORC_BONE: "Orc_Bone",
	ID_ORC_BANNER: "Orc_Banner",
	ID_BONE_NECKLACE: "Bone_Necklace",
	ID_PRIMITIVE_AXE: "Primitive_Axe",
	ID_TRIBAL_MASK: "Tribal_Mask",
	ID_WAR_HORN: "War_Horn",
	ID_SACRED_TOTEM: "Sacred_Totem",
	ID_BLOOD_RITUAL: "Blood_Ritual",
	
	# 地牢之心专用构件
	ID_HEART_CORE: "res://scenes/buildings/dungeon_heart/components/Heart_Core",
	ID_ENERGY_CONDUIT_2: "res://scenes/buildings/dungeon_heart/components/Energy_Conduit",
	ID_POWER_NODE: "res://scenes/buildings/dungeon_heart/components/Power_Node",
	ID_CORE_CHAMBER: "res://scenes/buildings/dungeon_heart/components/Core_Chamber",
	ID_ENERGY_FLOW: "res://scenes/buildings/dungeon_heart/components/Energy_Flow",
	ID_HEART_ENTRANCE: "res://scenes/buildings/dungeon_heart/components/Heart_Entrance",
	
	# 金库专用构件
	ID_TREASURE_CHEST_2: "res://scenes/buildings/treasury/components/Treasure_Chest",
	ID_GOLD_PILE_2: "res://scenes/buildings/treasury/components/Gold_Pile",
	ID_GOLD_BAR: "res://scenes/buildings/treasury/components/Gold_Bar",
	ID_VAULT_DOOR: "res://scenes/buildings/treasury/components/Vault_Door",
	ID_GOLD_COIN: "res://scenes/buildings/treasury/components/Gold_Coin",
	
	# 奥术塔专用构件
	ID_CRYSTAL_BALL: "res://scenes/buildings/arcane_tower/components/Crystal_Ball",
	ID_MAGIC_CIRCLE: "res://scenes/buildings/arcane_tower/components/Magic_Circle",
	ID_ARCANE_ORB: "res://scenes/buildings/arcane_tower/components/Arcane_Orb",
	ID_SPELL_BOOK: "res://scenes/buildings/arcane_tower/components/Spell_Book",
	ID_RUNE_STONE: "res://scenes/buildings/arcane_tower/components/Rune_Stone",
	
	# 兵营专用构件
	ID_MILITARY_FLAG: "res://scenes/buildings/barracks/components/Military_Flag",
	ID_CAMPFIRE: "res://scenes/buildings/barracks/components/Campfire",
	ID_BARRACKS_BUNK: "res://scenes/buildings/barracks/components/Barracks_Bunk",
	ID_ARMOR_STAND: "res://scenes/buildings/barracks/components/Armor_Stand",
	ID_SHIELD_RACK: "res://scenes/buildings/barracks/components/Shield_Rack",
	
	# 工坊专用构件
	ID_WORKBENCH: "res://scenes/buildings/workshop/components/Workbench",
	ID_FORGE: "res://scenes/buildings/workshop/components/Forge",
	ID_TOOL_RACK: "res://scenes/buildings/workshop/components/Tool_Rack",
	ID_ANVIL: "res://scenes/buildings/workshop/components/Anvil",
	ID_MATERIAL_PILE: "res://scenes/buildings/workshop/components/Material_Pile",
	ID_HAMMER: "res://scenes/buildings/workshop/components/Hammer",
	ID_CHISEL: "res://scenes/buildings/workshop/components/Chisel",
	
	# 医院专用构件
	ID_HOSPITAL_BED: "res://scenes/buildings/hospital/components/Hospital_Bed",
	ID_MEDICAL_EQUIPMENT: "res://scenes/buildings/hospital/components/Medical_Equipment",
	ID_SURGICAL_TABLE: "res://scenes/buildings/hospital/components/Surgical_Table",
	ID_MEDICAL_SCANNER: "res://scenes/buildings/hospital/components/Medical_Scanner",
	ID_NURSING_STATION: "res://scenes/buildings/hospital/components/Nursing_Station",
	ID_OPERATING_ROOM: "res://scenes/buildings/hospital/components/Operating_Room",
	ID_PHARMACY: "res://scenes/buildings/hospital/components/Pharmacy",
	
	# 市场专用构件
	ID_VENDOR_STALL: "res://scenes/buildings/market/components/Vendor_Stall",
	ID_TRADING_DESK: "res://scenes/buildings/market/components/Trading_Desk",
	ID_DISPLAY_COUNTER: "res://scenes/buildings/market/components/Display_Counter",
	ID_MERCHANT_CART: "res://scenes/buildings/market/components/Merchant_Cart",
	ID_GOODS_STORAGE: "res://scenes/buildings/market/components/Goods_Storage",
	ID_COIN_COUNTER: "res://scenes/buildings/market/components/Coin_Counter",
	ID_MARKET_BANNER: "res://scenes/buildings/market/components/Market_Banner",
	ID_MARKET_SIGN: "res://scenes/buildings/market/components/Market_Sign",
	ID_GOLDEN_CREST: "res://scenes/buildings/common/components/Golden_Crest",
	
	# 暗影神殿专用构件
	ID_SHADOW_CORE_2: "res://scenes/buildings/shadow_temple/components/Shadow_Core",
	ID_SHADOW_FLAME_2: "res://scenes/buildings/shadow_temple/components/Shadow_Flame",
	ID_SHADOW_POOL_2: "res://scenes/buildings/shadow_temple/components/Shadow_Pool",
	
	
	# 工厂专用构件
	ID_ASSEMBLY_LINE: "res://scenes/buildings/factory/components/Assembly_Line",
	ID_CONVEYOR_BELT: "res://scenes/buildings/factory/components/Conveyor_Belt",
	ID_SMOKESTACK: "res://scenes/buildings/factory/components/Smokestack",
	ID_VENTILATION: "res://scenes/buildings/factory/components/Ventilation",
	
	
}

# ========================================
# 构件属性管理
# ========================================
var component_properties = {}

func _init():
	_initialize_component_properties()

func _initialize_component_properties():
	"""初始化构件属性"""
	component_properties.clear()
	
	# 基础结构构件
	_add_component_property(ID_FLOOR_STONE, "Floor Stone", "石质地板", Color.GRAY, Vector3(0.33, 0.05, 0.33))
	_add_component_property(ID_FLOOR_WOOD, "Floor Wood", "木质地板", Color(0.6, 0.4, 0.2), Vector3(0.33, 0.05, 0.33))
	_add_component_property(ID_FLOOR_METAL, "Floor Metal", "金属地板", Color.SILVER, Vector3(0.33, 0.05, 0.33))
	_add_component_property(ID_WALL_STONE, "Wall Stone", "石质墙体", Color.GRAY, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_WALL_WOOD, "Wall Wood", "木质墙体", Color(0.6, 0.4, 0.2), Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_WALL_METAL, "Wall Metal", "金属墙体", Color.SILVER, Vector3(0.33, 0.33, 0.05))
	
	# 魔法构件
	_add_component_property(ID_MAGIC_CRYSTAL, "Magic Crystal", "魔法水晶", Color.PURPLE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ENERGY_RUNE, "Energy Rune", "能量符文", Color.CYAN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_MAGIC_CORE, "Magic Core", "魔法核心", Color.MAGENTA, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_SUMMONING_CIRCLE, "Summoning Circle", "召唤阵", Color.DARK_MAGENTA, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_DEMON_HORN, "Demon Horn", "恶魔角", Color.DARK_RED, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ENERGY_CONDUIT, "Energy Conduit", "能量导管", Color.YELLOW, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ENERGY_NODE, "Energy Node", "能量节点", Color.ORANGE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_STORAGE_CORE, "Storage Core", "存储核心", Color.BLUE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_MANA_POOL, "Mana Pool", "魔力池", Color.CYAN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_MAGIC_ALTAR, "Magic Altar", "魔法祭坛", Color.PURPLE, Vector3(0.33, 0.33, 0.33))
	
func _add_component_property(id: int, name: String, description: String, color: Color, size: Vector3):
	"""添加构件属性"""
	component_properties[id] = {
		"name": name,
		"description": description,
		"color": color,
		"size": size
	}

func get_component_property(id: int) -> Dictionary:
	"""获取构件属性"""
	return component_properties.get(id, {})

func get_all_component_ids() -> Array:
	"""获取所有构件ID"""
	return component_properties.keys()

func get_component_count() -> int:
	"""获取构件数量"""
	return component_properties.size()