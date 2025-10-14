extends Node
## 🏗️ 建筑类型常量（Autoload单例）
## 定义所有建筑类型枚举值，避免魔法数字
## 与 BuildingManager.BuildingType 保持同步

# === 建筑类型枚举常量 ===
# 🔧 与 BuildingManager.BuildingType 枚举值保持一致

# 核心建筑
const DUNGEON_HEART = 0 # 地牢之心

# 基础设施建筑
const TREASURY = 1 # 金库
const LAIR = 2 # 巢穴
const DEMON_LAIR = 3 # 恶魔巢穴
const ORC_LAIR = 4 # 兽人巢穴

# 功能性建筑
const TRAINING_ROOM = 5 # 训练室
const LIBRARY = 6 # 图书馆
const WORKSHOP = 7 # 工坊

# 军事建筑
const PRISON = 8 # 监狱
const TORTURE_CHAMBER = 9 # 刑房
const ARROW_TOWER = 10 # 箭塔
const ARCANE_TOWER = 11 # 奥术塔
const DEFENSE_WORKS = 12 # 防御工事

# 魔法建筑
const MAGIC_ALTAR = 23 # 魔法祭坛
const SHADOW_TEMPLE = 24 # 暗影神殿
const MAGIC_RESEARCH_INSTITUTE = 25 # 魔法研究院


func _ready():
	"""初始化建筑类型常量"""
	name = "BuildingTypes"
	LogManager.info("BuildingTypes - 建筑类型常量已初始化")


# === 辅助函数 ===

static func get_building_name(building_type: int) -> String:
	"""获取建筑类型名称
	
	Args:
		building_type: 建筑类型枚举值
	
	Returns:
		建筑类型名称（中文）
	"""
	match building_type:
		DUNGEON_HEART: return "地牢之心"
		TREASURY: return "金库"
		LAIR: return "巢穴"
		DEMON_LAIR: return "恶魔巢穴"
		ORC_LAIR: return "兽人巢穴"
		TRAINING_ROOM: return "训练室"
		LIBRARY: return "图书馆"
		WORKSHOP: return "工坊"
		PRISON: return "监狱"
		TORTURE_CHAMBER: return "刑房"
		ARROW_TOWER: return "箭塔"
		ARCANE_TOWER: return "奥术塔"
		DEFENSE_WORKS: return "防御工事"
		MAGIC_ALTAR: return "魔法祭坛"
		SHADOW_TEMPLE: return "暗影神殿"
		MAGIC_RESEARCH_INSTITUTE: return "魔法研究院"
		_: return "未知建筑"


static func is_infrastructure_building(building_type: int) -> bool:
	"""检查是否为基础设施建筑"""
	return building_type in [TREASURY, LAIR, DEMON_LAIR, ORC_LAIR]


static func is_functional_building(building_type: int) -> bool:
	"""检查是否为功能性建筑"""
	return building_type in [TRAINING_ROOM, LIBRARY, WORKSHOP]


static func is_military_building(building_type: int) -> bool:
	"""检查是否为军事建筑"""
	return building_type in [PRISON, TORTURE_CHAMBER, ARROW_TOWER, ARCANE_TOWER, DEFENSE_WORKS]


static func is_magic_building(building_type: int) -> bool:
	"""检查是否为魔法建筑"""
	return building_type in [MAGIC_ALTAR, SHADOW_TEMPLE, MAGIC_RESEARCH_INSTITUTE]


static func get_all_building_types() -> Array[int]:
	"""获取所有建筑类型"""
	var types: Array[int] = [
		DUNGEON_HEART,
		TREASURY, LAIR, DEMON_LAIR, ORC_LAIR,
		TRAINING_ROOM, LIBRARY, WORKSHOP,
		PRISON, TORTURE_CHAMBER, ARROW_TOWER, ARCANE_TOWER, DEFENSE_WORKS,
		MAGIC_ALTAR, SHADOW_TEMPLE, MAGIC_RESEARCH_INSTITUTE
	]
	return types


# === 调试信息 ===

func print_building_types():
	"""打印所有建筑类型"""
	LogManager.info("=== Building Types ===")
	for type in get_all_building_types():
		LogManager.info("%d: %s" % [type, get_building_name(type)])
	LogManager.info("=====================")
