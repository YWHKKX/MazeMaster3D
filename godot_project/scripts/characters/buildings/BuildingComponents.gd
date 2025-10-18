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
# 基础结构构件 (1-20)
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
# 门窗构件 (21-30)
# ========================================
const ID_DOOR_WOOD = 21
const ID_DOOR_METAL = 22
const ID_GATE_STONE = 23
const ID_WINDOW_SMALL = 24
const ID_WINDOW_LARGE = 25

# ========================================
# 装饰构件 (31-50)
# ========================================
const ID_PILLAR_STONE = 31
const ID_PILLAR_WOOD = 32
const ID_TORCH_WALL = 33
const ID_BANNER_CLOTH = 34
const ID_STATUE_STONE = 35
const ID_LIBRARY_DECORATION = 36
const ID_MARKET_DECORATION = 37
const ID_HOSPITAL_DECORATION = 38
const ID_FACTORY_DECORATION = 39
const ID_ACADEMY_DECORATION = 40
const ID_BARRACKS_DECORATION = 41
const ID_TEMPLE_DECORATION = 42

# ========================================
# 魔法构件 (51-70)
# ========================================
const ID_MAGIC_CRYSTAL = 51
const ID_ENERGY_RUNE = 52
const ID_MAGIC_CORE = 53
const ID_ENERGY_CONDUIT = 54
const ID_ENERGY_NODE = 55
const ID_STORAGE_CORE = 56
const ID_MANA_POOL = 57
const ID_MAGIC_ALTAR = 58
const ID_HELL_FIRE = 59
const ID_DEMON_CORE = 60
const ID_SUMMONING_CIRCLE = 61
const ID_DEMON_HORN = 62
const ID_MANA_CRYSTAL = 63
const ID_SPELL_CRYSTAL = 64
const ID_WISDOM_CRYSTAL = 65
const ID_DARK_CRYSTAL = 66
const ID_ENERGY_CRYSTAL = 67
const ID_HEALING_CRYSTAL = 68
const ID_SHADOW_RUNE = 69
const ID_MAGIC_SCROLL = 70

# ========================================
# 军事构件 (71-90)
# ========================================
const ID_ARROW_SLOT = 71
const ID_CROSSBOW = 72
const ID_AMMO_RACK = 73
const ID_WATCHTOWER = 74
const ID_BATTLE_STANDARD = 75
const ID_TRAINING_POST = 76
const ID_TRAINING_GROUND = 77
const ID_WAR_DRUM = 78
const ID_DEMON_CLAW = 79
const ID_TRAINING_DUMMY = 80
const ID_WEAPON_RACK = 81
const ID_COMBAT_ARENA = 82
const ID_TRAINING_MAT = 83
const ID_STRENGTH_TRAINER = 84
const ID_AGILITY_COURSE = 85
const ID_BARRACKS_ENTRANCE = 86

# ========================================
# 资源构件 (91-110)
# ========================================
const ID_GOLD_PILE = 91
const ID_RESOURCE_NODE = 92
const ID_STORAGE_CRATE = 93
const ID_TREASURE_CHEST = 94
const ID_RAW_MATERIALS = 95
const ID_FINISHED_GOODS = 96

# ========================================
# 学术构件 (111-130)
# ========================================
const ID_ACADEMY_TOWER = 111
const ID_ACADEMIC_BANNER = 112
const ID_WISDOM_TOWER = 113
const ID_CLASSROOM_DESK = 114
const ID_TEACHER_PODIUM = 115
const ID_RESEARCH_LAB = 116
const ID_ACADEMIC_LIBRARY = 117
const ID_ACADEMY_ENTRANCE = 118
const ID_RESEARCH_DESK = 119
const ID_EXPERIMENT_TABLE = 120
const ID_MAGIC_TOME = 121
const ID_ALCHEMY_SET = 122
const ID_RESEARCH_LIBRARY = 123
const ID_INSTITUTE_ENTRANCE = 124
const ID_RESEARCH_TABLE = 125
const ID_ANCIENT_TEXT = 126
const ID_KNOWLEDGE_ORB = 127
const ID_SCROLL_RACK = 128
const ID_STUDY_LAMP = 129
const ID_BOOKSHELF = 130

# ========================================
# 工业构件 (131-150)
# ========================================
const ID_TOOL_RACK = 131
const ID_WORKBENCH = 132
const ID_FORGE = 133
const ID_MATERIAL_PILE = 134
const ID_ASSEMBLY_LINE = 135
const ID_MACHINE_TOOL = 136
const ID_CONVEYOR_BELT = 137
const ID_QUALITY_CONTROL = 138
const ID_PACKAGING_STATION = 139
const ID_STEAM_ENGINE = 140
const ID_FACTORY_CHIMNEY = 141
const ID_FACTORY_ENTRANCE = 142
const ID_SMOKESTACK = 143
const ID_VENTILATION = 144
const ID_CONTROL_ROOM = 145
const ID_INDUSTRIAL_MACHINE = 146

# ========================================
# 医疗构件 (151-170)
# ========================================
const ID_HOSPITAL_BED = 151
const ID_MEDICAL_CABINET = 152
const ID_SURGERY_TABLE = 153
const ID_PHARMACY_SHELF = 154
const ID_HOSPITAL_ENTRANCE = 155
const ID_MEDICAL_EQUIPMENT = 156
const ID_SURGICAL_TABLE = 157
const ID_OPERATING_ROOM = 158
const ID_NURSING_STATION = 159
const ID_PHARMACY = 160
const ID_RECEPTION_DESK = 161

# ========================================
# 商业构件 (171-180)
# ========================================
const ID_MARKET_STALL = 171
const ID_MERCHANT_COUNTER = 172
const ID_CASH_REGISTER = 173
const ID_PRODUCT_DISPLAY = 174
const ID_SHOPPING_CART = 175
const ID_MARKET_BANNER = 176
const ID_TRADING_POST = 177
const ID_MARKET_ENTRANCE = 178

# ========================================
# 兽人构件 (181-190)
# ========================================
const ID_ORC_SKULL = 181
const ID_BONE_PILE = 182
const ID_PRIMITIVE_TOTEM = 183
const ID_ORC_SHACK = 184
const ID_ORC_WEAPON_RACK = 185
const ID_ORC_ENTRANCE = 186
const ID_ORC_BONE = 187

# ========================================
# 暗影神殿构件 (188-195)
# ========================================
const ID_SHADOW_ALTAR = 188
const ID_SHADOW_PILLAR = 189
const ID_NECROMANCY_TABLE = 190
const ID_SOUL_CAGE = 191
const ID_TEMPLE_ENTRANCE = 192

# ========================================
# 地牢之心构件 (193-200)
# ========================================
const ID_HEART_CORE = 193
const ID_ENERGY_CONDUIT_2 = 194
const ID_POWER_NODE = 195
const ID_CORE_CHAMBER = 196
const ID_ENERGY_FLOW = 197
const ID_HEART_ENTRANCE = 198

# ========================================
# 图书馆构件 (199-205)
# ========================================
const ID_BOOK_PILE = 199
const ID_READING_DESK = 200
const ID_SCHOLAR_STATUE = 201

# ========================================
# 市场构件 (202-215)
# ========================================
const ID_MARKET_SIGN = 202
const ID_GOLDEN_CREST = 203
const ID_VENDOR_STALL = 204
const ID_DISPLAY_COUNTER = 205
const ID_TRADING_DESK = 206
const ID_GOODS_STORAGE = 207
const ID_COIN_COUNTER = 208
const ID_WELCOME_MAT = 209

# ========================================
# 兽人建筑构件 (210-215)
# ========================================
const ID_WOODEN_PALISADE = 210
const ID_WOODEN_GATE = 211

# ========================================
# 暗影神殿构件 (212-220)
# ========================================
const ID_SHADOW_CORE = 212
const ID_SHADOW_POOL = 213
const ID_SHADOW_WALL = 214


# 构件属性映射
static var component_properties: Dictionary = {}

# 初始化构件属性
static func _static_init():
	_initialize_component_properties()


static func _initialize_component_properties():
	"""初始化构件属性"""
	component_properties.clear()
	
	# 基础结构构件
	_add_component_property(ID_FLOOR_STONE, "Floor Stone", "石质地板", Color.GRAY, Vector3(0.33, 0.05, 0.33))
	_add_component_property(ID_FLOOR_WOOD, "Floor Wood", "木质地板", Color(0.6, 0.4, 0.2), Vector3(0.33, 0.05, 0.33))
	_add_component_property(ID_FLOOR_METAL, "Floor Metal", "金属地板", Color.SILVER, Vector3(0.33, 0.05, 0.33))
	_add_component_property(ID_WALL_STONE, "Wall Stone", "石质墙体", Color.GRAY, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_WALL_WOOD, "Wall Wood", "木质墙体", Color(0.6, 0.4, 0.2), Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_WALL_METAL, "Wall Metal", "金属墙体", Color.SILVER, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_CORNER_STONE, "Corner Stone", "石质墙角", Color.GRAY, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_CORNER_WOOD, "Corner Wood", "木质墙角", Color(0.6, 0.4, 0.2), Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_CORNER_METAL, "Corner Metal", "金属墙角", Color.SILVER, Vector3(0.33, 0.33, 0.33))
	
	# 门窗构件
	_add_component_property(ID_DOOR_WOOD, "Door Wood", "木门", Color(0.4, 0.2, 0.1), Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_DOOR_METAL, "Door Metal", "金属门", Color.SILVER, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_WINDOW_SMALL, "Window Small", "小窗户", Color.LIGHT_BLUE, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_WINDOW_LARGE, "Window Large", "大窗户", Color.LIGHT_BLUE, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_GATE_STONE, "Gate Stone", "石门", Color.GRAY, Vector3(0.33, 0.33, 0.05))
	
	# 装饰构件
	_add_component_property(ID_PILLAR_STONE, "Pillar Stone", "石柱", Color.GRAY, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_PILLAR_WOOD, "Pillar Wood", "木柱", Color(0.6, 0.4, 0.2), Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_TORCH_WALL, "Torch Wall", "壁挂火把", Color.ORANGE, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_BANNER_CLOTH, "Banner Cloth", "布制旗帜", Color.RED, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_STATUE_STONE, "Statue Stone", "石制雕像", Color.GRAY, Vector3(0.33, 0.33, 0.33))
	
	# 特殊构件
	_add_component_property(ID_STAIRS_WOOD, "Stairs Wood", "木制楼梯", Color(0.6, 0.4, 0.2), Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_STAIRS_STONE, "Stairs Stone", "石制楼梯", Color.GRAY, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ROOF_SLOPE, "Roof Slope", "斜屋顶", Color.RED, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ROOF_PEAK, "Roof Peak", "尖屋顶", Color.RED, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_FLOOR_TRAP, "Floor Trap", "陷阱地板", Color.DARK_RED, Vector3(0.33, 0.05, 0.33))
	
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
	
	# 军事构件
	_add_component_property(ID_ARROW_SLOT, "Arrow Slot", "射箭口", Color.GRAY, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_CROSSBOW, "Crossbow", "弩机", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_AMMO_RACK, "Ammo Rack", "弹药架", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_WATCHTOWER, "Watchtower", "瞭望台", Color.GRAY, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_BATTLE_STANDARD, "Battle Standard", "战旗", Color.RED, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_TRAINING_POST, "Training Post", "训练台", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_TRAINING_GROUND, "Training Ground", "训练场", Color.GREEN, Vector3(0.33, 0.05, 0.33))
	_add_component_property(ID_WAR_DRUM, "War Drum", "战鼓", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ORC_BONE, "Orc Bone", "兽骨", Color.WHITE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_DEMON_CLAW, "Demon Claw", "恶魔爪", Color.DARK_RED, Vector3(0.33, 0.33, 0.33))
	
	# 资源构件
	_add_component_property(ID_GOLD_PILE, "Gold Pile", "金币堆", Color.GOLD, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_MANA_CRYSTAL, "Mana Crystal", "魔力水晶", Color.BLUE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_RESOURCE_NODE, "Resource Node", "资源节点", Color.GREEN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_STORAGE_CRATE, "Storage Crate", "存储箱", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_TREASURE_CHEST, "Treasure Chest", "宝箱", Color(0.8, 0.6, 0.2), Vector3(0.33, 0.33, 0.33))
	
	# 恶魔构件
	_add_component_property(ID_HELL_FIRE, "Hell Fire", "地狱火焰", Color.RED, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_DEMON_CORE, "Demon Core", "恶魔核心", Color.DARK_RED, Vector3(0.33, 0.33, 0.33))
	
	# 学术构件
	_add_component_property(ID_ACADEMY_TOWER, "Academy Tower", "学院塔", Color.BLUE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ACADEMIC_BANNER, "Academic Banner", "学术旗帜", Color.NAVY_BLUE, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_WISDOM_TOWER, "Wisdom Tower", "智慧塔", Color.CYAN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_CLASSROOM_DESK, "Classroom Desk", "课桌", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_TEACHER_PODIUM, "Teacher Podium", "讲台", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_RESEARCH_LAB, "Research Lab", "研究室", Color.PURPLE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ACADEMIC_LIBRARY, "Academic Library", "学术图书馆", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ACADEMY_ENTRANCE, "Academy Entrance", "学院入口", Color.BLUE, Vector3(0.33, 0.33, 0.05))
	
	# 工业构件
	_add_component_property(ID_TOOL_RACK, "Tool Rack", "工具架", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_WORKBENCH, "Workbench", "工作台", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_FORGE, "Forge", "锻造炉", Color.ORANGE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_MATERIAL_PILE, "Material Pile", "材料堆", Color.GRAY, Vector3(0.33, 0.33, 0.33))
	
	# 医疗构件
	_add_component_property(ID_HOSPITAL_BED, "Hospital Bed", "病床", Color.WHITE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_MEDICAL_CABINET, "Medical Cabinet", "医疗柜", Color.WHITE, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_HEALING_CRYSTAL, "Healing Crystal", "治疗水晶", Color.LIGHT_BLUE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_SURGERY_TABLE, "Surgery Table", "手术台", Color.WHITE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_PHARMACY_SHELF, "Pharmacy Shelf", "药架", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_HOSPITAL_ENTRANCE, "Hospital Entrance", "医院入口", Color.WHITE, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_MEDICAL_EQUIPMENT, "Medical Equipment", "医疗设备", Color.WHITE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_SURGICAL_TABLE, "Surgical Table", "手术台", Color.WHITE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_OPERATING_ROOM, "Operating Room", "手术室", Color.WHITE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_NURSING_STATION, "Nursing Station", "护理站", Color.WHITE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_PHARMACY, "Pharmacy", "药房", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_RECEPTION_DESK, "Reception Desk", "接待台", Color.WHITE, Vector3(0.33, 0.33, 0.33))
	
	# 商业构件
	_add_component_property(ID_MARKET_STALL, "Market Stall", "市场摊位", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_MERCHANT_COUNTER, "Merchant Counter", "商人柜台", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_CASH_REGISTER, "Cash Register", "收银台", Color.BLACK, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_PRODUCT_DISPLAY, "Product Display", "商品展示", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_SHOPPING_CART, "Shopping Cart", "购物车", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_MARKET_BANNER, "Market Banner", "市场旗帜", Color.YELLOW, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_TRADING_POST, "Trading Post", "贸易站", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_MARKET_ENTRANCE, "Market Entrance", "市场入口", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	
	# 工厂构件
	_add_component_property(ID_ASSEMBLY_LINE, "Assembly Line", "装配线", Color.SILVER, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_MACHINE_TOOL, "Machine Tool", "机床", Color.SILVER, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_CONVEYOR_BELT, "Conveyor Belt", "传送带", Color.GRAY, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_QUALITY_CONTROL, "Quality Control", "质检台", Color.BLUE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_PACKAGING_STATION, "Packaging Station", "包装台", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_STEAM_ENGINE, "Steam Engine", "蒸汽机", Color.SILVER, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_FACTORY_CHIMNEY, "Factory Chimney", "工厂烟囱", Color.GRAY, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_FACTORY_ENTRANCE, "Factory Entrance", "工厂入口", Color.GRAY, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_SMOKESTACK, "Smokestack", "烟囱", Color.GRAY, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_VENTILATION, "Ventilation", "通风系统", Color.SILVER, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_CONTROL_ROOM, "Control Room", "控制室", Color.BLUE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_INDUSTRIAL_MACHINE, "Industrial Machine", "工业机器", Color.SILVER, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_RAW_MATERIALS, "Raw Materials", "原材料", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_FINISHED_GOODS, "Finished Goods", "成品", Color.GREEN, Vector3(0.33, 0.33, 0.33))
	
	# 兽人构件
	_add_component_property(ID_ORC_SKULL, "Orc Skull", "兽人头骨", Color.WHITE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_BONE_PILE, "Bone Pile", "骨头堆", Color.WHITE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_PRIMITIVE_TOTEM, "Primitive Totem", "原始图腾", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ORC_SHACK, "Orc Shack", "兽人小屋", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ORC_WEAPON_RACK, "Orc Weapon Rack", "兽人武器架", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_ORC_ENTRANCE, "Orc Entrance", "兽人入口", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	
	# 魔法研究院构件
	_add_component_property(ID_RESEARCH_DESK, "Research Desk", "研究桌", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_EXPERIMENT_TABLE, "Experiment Table", "实验台", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_MAGIC_TOME, "Magic Tome", "魔法书", Color.PURPLE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_SPELL_CRYSTAL, "Spell Crystal", "法术水晶", Color.CYAN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ALCHEMY_SET, "Alchemy Set", "炼金设备", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_MAGIC_SCROLL, "Magic Scroll", "魔法卷轴", Color.YELLOW, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_RESEARCH_LIBRARY, "Research Library", "研究图书馆", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_INSTITUTE_ENTRANCE, "Institute Entrance", "研究院入口", Color.PURPLE, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_RESEARCH_TABLE, "Research Table", "研究台", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_WISDOM_CRYSTAL, "Wisdom Crystal", "智慧水晶", Color.PURPLE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ANCIENT_TEXT, "Ancient Text", "古代文献", Color.YELLOW, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_KNOWLEDGE_ORB, "Knowledge Orb", "知识球", Color.CYAN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_SCROLL_RACK, "Scroll Rack", "卷轴架", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_STUDY_LAMP, "Study Lamp", "学习灯", Color.YELLOW, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_BOOKSHELF, "Bookshelf", "书架", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_SCHOLAR_STATUE, "Scholar Statue", "学者雕像", Color.GRAY, Vector3(0.33, 0.33, 0.33))
	
	# 暗影神殿构件
	_add_component_property(ID_SHADOW_ALTAR, "Shadow Altar", "暗影祭坛", Color.DARK_MAGENTA, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_DARK_CRYSTAL, "Dark Crystal", "暗黑水晶", Color.BLACK, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_SHADOW_PILLAR, "Shadow Pillar", "暗影柱", Color.DARK_GRAY, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_NECROMANCY_TABLE, "Necromancy Table", "死灵桌", Color.BLACK, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_SOUL_CAGE, "Soul Cage", "灵魂笼", Color.DARK_MAGENTA, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_SHADOW_RUNE, "Shadow Rune", "暗影符文", Color.DARK_MAGENTA, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_TEMPLE_ENTRANCE, "Temple Entrance", "神殿入口", Color.DARK_MAGENTA, Vector3(0.33, 0.33, 0.05))
	
	# 训练室构件
	_add_component_property(ID_TRAINING_DUMMY, "Training Dummy", "训练假人", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_WEAPON_RACK, "Weapon Rack", "武器架", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_COMBAT_ARENA, "Combat Arena", "战斗竞技场", Color.GRAY, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_TRAINING_MAT, "Training Mat", "训练垫", Color.GREEN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_STRENGTH_TRAINER, "Strength Trainer", "力量训练器", Color.SILVER, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_AGILITY_COURSE, "Agility Course", "敏捷训练场", Color.GREEN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_BARRACKS_ENTRANCE, "Barracks Entrance", "训练室入口", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	
	# 地牢之心构件
	_add_component_property(ID_HEART_CORE, "Heart Core", "心脏核心", Color.RED, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ENERGY_CONDUIT_2, "Energy Conduit 2", "能量导管2", Color.YELLOW, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_POWER_NODE, "Power Node", "能量节点", Color.ORANGE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ENERGY_CRYSTAL, "Energy Crystal", "能量水晶", Color.CYAN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_CORE_CHAMBER, "Core Chamber", "核心室", Color.RED, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ENERGY_FLOW, "Energy Flow", "能量流", Color.YELLOW, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_HEART_ENTRANCE, "Heart Entrance", "地牢之心入口", Color.RED, Vector3(0.33, 0.33, 0.05))
	
	# 图书馆构件
	_add_component_property(ID_BOOK_PILE, "Book Pile", "书堆", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_READING_DESK, "Reading Desk", "阅读桌", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	
	# 市场构件
	_add_component_property(ID_MARKET_SIGN, "Market Sign", "市场招牌", Color.YELLOW, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_GOLDEN_CREST, "Golden Crest", "金色徽章", Color.GOLD, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_VENDOR_STALL, "Vendor Stall", "商贩摊位", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_DISPLAY_COUNTER, "Display Counter", "展示柜台", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_TRADING_DESK, "Trading Desk", "交易桌", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_GOODS_STORAGE, "Goods Storage", "商品存储", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_COIN_COUNTER, "Coin Counter", "金币计数器", Color.YELLOW, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_WELCOME_MAT, "Welcome Mat", "欢迎垫", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	
	# 兽人建筑构件
	_add_component_property(ID_WOODEN_PALISADE, "Wooden Palisade", "木栅栏", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_WOODEN_GATE, "Wooden Gate", "木门", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	
	# 暗影神殿构件
	_add_component_property(ID_SHADOW_CORE, "Shadow Core", "暗影核心", Color.PURPLE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_SHADOW_POOL, "Shadow Pool", "暗影池", Color.DARK_MAGENTA, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_SHADOW_WALL, "Shadow Wall", "暗影墙", Color.DARK_GRAY, Vector3(0.33, 0.33, 0.33))
	
	# 通用装饰构件
	_add_component_property(ID_LIBRARY_DECORATION, "Library Decoration", "图书馆装饰", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_MARKET_DECORATION, "Market Decoration", "市场装饰", Color.YELLOW, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_HOSPITAL_DECORATION, "Hospital Decoration", "医院装饰", Color.WHITE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_FACTORY_DECORATION, "Factory Decoration", "工厂装饰", Color.GRAY, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_ACADEMY_DECORATION, "Academy Decoration", "学院装饰", Color.BLUE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_BARRACKS_DECORATION, "Barracks Decoration", "训练室装饰", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_TEMPLE_DECORATION, "Temple Decoration", "神殿装饰", Color.PURPLE, Vector3(0.33, 0.33, 0.33))
	
	# 恶魔巢穴构件
	_add_component_property(ID_DEMON_HORN, "Demon Horn", "恶魔角", Color.RED, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_SUMMONING_CIRCLE, "Summoning Circle", "召唤阵", Color.PURPLE, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_DEMON_CORE, "Demon Core", "恶魔核心", Color.RED, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_DEMON_CLAW, "Demon Claw", "恶魔爪", Color.RED, Vector3(0.33, 0.33, 0.33))
	
	# 金库构件
	_add_component_property(ID_GOLD_PILE, "Gold Pile", "金币堆", Color.YELLOW, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_TREASURE_CHEST, "Treasure Chest", "宝箱", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_STORAGE_CRATE, "Storage Crate", "储物箱", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	
	# 箭塔构件
	_add_component_property(ID_ARROW_SLOT, "Arrow Slot", "箭槽", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_CROSSBOW, "Crossbow", "弩", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_AMMO_RACK, "Ammo Rack", "弹药架", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_BATTLE_STANDARD, "Battle Standard", "战旗", Color.RED, Vector3(0.33, 0.33, 0.05))
	
	# 通用建筑构件
	_add_component_property(ID_DOOR_WOOD, "Wood Door", "木门", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_DOOR_METAL, "Metal Door", "金属门", Color.GRAY, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_WINDOW_SMALL, "Small Window", "小窗户", Color.LIGHT_BLUE, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_WINDOW_LARGE, "Large Window", "大窗户", Color.LIGHT_BLUE, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_WALL_STONE, "Stone Wall", "石墙", Color.GRAY, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_WALL_WOOD, "Wood Wall", "木墙", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_FLOOR_STONE, "Stone Floor", "石地板", Color.GRAY, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_FLOOR_WOOD, "Wood Floor", "木地板", Color.BROWN, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_ROOF_TILE, "Roof Tile", "屋顶瓦", Color.RED, Vector3(0.33, 0.33, 0.05))


static func _add_component_property(id: int, name_en: String, name_cn: String, color: Color, size: Vector3):
	"""添加构件属性"""
	component_properties[id] = {
		"id": id,
		"name_en": name_en,
		"name_cn": name_cn,
		"color": color,
		"size": size
	}


static func get_component_name(id: int) -> String:
	"""获取构件名称"""
	var prop = component_properties.get(id)
	if prop:
		return prop.name_cn
	return "未知构件"


static func get_component_name_en(id: int) -> String:
	"""获取构件英文名称"""
	var prop = component_properties.get(id)
	if prop:
		return prop.name_en
	return "Unknown Component"


static func get_component_color(id: int) -> Color:
	"""获取构件颜色"""
	var prop = component_properties.get(id)
	if prop:
		return prop.color
	return Color.WHITE


static func get_component_size(id: int) -> Vector3:
	"""获取构件尺寸"""
	var prop = component_properties.get(id)
	if prop:
		return prop.size
	return Vector3(0.33, 0.33, 0.33)


static func is_wall_component(id: int) -> bool:
	"""检查是否为墙体构件"""
	return id in [ID_WALL_STONE, ID_WALL_WOOD, ID_WALL_METAL, ID_CORNER_STONE, ID_CORNER_WOOD, ID_CORNER_METAL]


static func is_floor_component(id: int) -> bool:
	"""检查是否为地板构件"""
	return id in [ID_FLOOR_STONE, ID_FLOOR_WOOD, ID_FLOOR_METAL]


static func is_door_component(id: int) -> bool:
	"""检查是否为门构件"""
	return id in [ID_DOOR_WOOD, ID_DOOR_METAL, ID_GATE_STONE]


static func is_window_component(id: int) -> bool:
	"""检查是否为窗户构件"""
	return id in [ID_WINDOW_SMALL, ID_WINDOW_LARGE]


static func is_roof_component(id: int) -> bool:
	"""检查是否为屋顶构件"""
	return id in [ID_ROOF_SLOPE, ID_ROOF_PEAK]


static func is_magic_component(id: int) -> bool:
	"""检查是否为魔法构件"""
	return id in [ID_MAGIC_CRYSTAL, ID_ENERGY_RUNE, ID_MAGIC_CORE, ID_SUMMONING_CIRCLE, ID_DEMON_HORN, ID_ENERGY_CONDUIT, ID_ENERGY_NODE, ID_STORAGE_CORE, ID_MANA_POOL, ID_MAGIC_ALTAR, ID_HELL_FIRE, ID_DEMON_CORE]


static func is_military_component(id: int) -> bool:
	"""检查是否为军事构件"""
	return id in [ID_ARROW_SLOT, ID_CROSSBOW, ID_AMMO_RACK, ID_WATCHTOWER, ID_BATTLE_STANDARD, ID_TRAINING_POST, ID_TRAINING_GROUND, ID_WAR_DRUM, ID_ORC_BONE, ID_DEMON_CLAW]


static func is_resource_component(id: int) -> bool:
	"""检查是否为资源构件"""
	return id in [ID_GOLD_PILE, ID_MANA_CRYSTAL, ID_RESOURCE_NODE, ID_STORAGE_CRATE, ID_TREASURE_CHEST]


static func is_academic_component(id: int) -> bool:
	"""检查是否为学术构件"""
	return id in [ID_ACADEMY_TOWER, ID_ACADEMIC_BANNER, ID_WISDOM_TOWER, ID_CLASSROOM_DESK, ID_TEACHER_PODIUM, ID_RESEARCH_LAB, ID_ACADEMIC_LIBRARY, ID_ACADEMY_ENTRANCE]


static func is_industrial_component(id: int) -> bool:
	"""检查是否为工业构件"""
	return id in [ID_TOOL_RACK, ID_WORKBENCH, ID_FORGE, ID_MATERIAL_PILE, ID_ASSEMBLY_LINE, ID_MACHINE_TOOL, ID_CONVEYOR_BELT, ID_QUALITY_CONTROL, ID_PACKAGING_STATION, ID_STEAM_ENGINE, ID_FACTORY_CHIMNEY, ID_FACTORY_ENTRANCE, ID_SMOKESTACK, ID_VENTILATION, ID_CONTROL_ROOM, ID_INDUSTRIAL_MACHINE, ID_RAW_MATERIALS, ID_FINISHED_GOODS]


static func get_all_component_ids() -> Array[int]:
	"""获取所有构件ID"""
	var ids: Array[int] = []
	for id in component_properties.keys():
		ids.append(id)
	ids.sort()
	return ids


static func print_all_components():
	"""打印所有构件信息（调试用）"""
	LogManager.info("=== Building Components ===")
	for id in get_all_component_ids():
		var prop = component_properties[id]
		LogManager.info("ID %d: %s (%s)" % [id, prop.name_cn, prop.name_en])
	LogManager.info("==========================")


# 静态初始化将在类首次加载时自动调用
# _static_init()  # 注释掉，因为不能在类定义外部调用
