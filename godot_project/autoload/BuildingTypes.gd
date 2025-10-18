extends Node
## 🏗️ 建筑类型常量（Autoload单例）
## 定义所有建筑类型枚举值，避免魔法数字
## 与 BuildingManager.BuildingType 保持同步

# === 建筑类型枚举常量 ===
# 🔧 与 BuildingManager.BuildingType 枚举值保持一致

# 建筑类型枚举
enum BuildingType {
	DUNGEON_HEART = 0, ## 地牢之心
	TREASURY = 1, ## 金库
	LAIR = 2, ## 巢穴
	DEMON_LAIR = 3, ## 恶魔巢穴
	ORC_LAIR = 4, ## 兽人巢穴
	TRAINING_ROOM = 5, ## 训练室
	LIBRARY = 6, ## 图书馆
	WORKSHOP = 7, ## 工坊
	PRISON = 8, ## 监狱
	TORTURE_CHAMBER = 9, ## 刑房
	ARROW_TOWER = 10, ## 箭塔
	ARCANE_TOWER = 11, ## 奥术塔
	DEFENSE_WORKS = 12, ## 防御工事
	MAGIC_ALTAR = 23, ## 魔法祭坛
	SHADOW_TEMPLE = 24, ## 暗影神殿
	MAGIC_RESEARCH_INSTITUTE = 25, ## 魔法研究院
	ACADEMY = 26, ## 学院
	HOSPITAL = 27, ## 医院
	FACTORY = 28, ## 工厂
	MARKET = 29 ## 市场
}

# 建筑状态枚举
enum BuildingStatus {
	INCOMPLETE, ## 未完成建筑
	COMPLETED, ## 完成建筑
	DESTROYED, ## 被摧毁建筑
	NEEDS_REPAIR, ## 需要修复建筑
	NO_AMMUNITION, ## 空弹药
	TREASURY_FULL, ## 金库爆满
	NEEDS_MAGE, ## 需要法师辅助
	MANA_FULL, ## 法力存储池已满
	MANA_GENERATION, ## 魔力生成状态
	TRAINING, ## 训练状态
	SUMMONING, ## 召唤状态
	SUMMONING_PAUSED, ## 暂停召唤状态
	LOCKED, ## 锁定状态
	READY_TO_TRAIN, ## 准备训练
	READY_TO_SUMMON, ## 准备召唤
	ACCEPTING_GOLD ## 接受金币
}


func _ready():
	"""初始化建筑类型常量"""
	name = "BuildingTypes"
	LogManager.info("BuildingTypes - 建筑类型常量已初始化")


# === 辅助函数 ===

static func get_building_name(building_type: BuildingType) -> String:
	"""获取建筑类型名称
	
	Args:
		building_type: 建筑类型枚举值
	
	Returns:
		建筑类型名称（中文）
	"""
	match building_type:
		BuildingType.DUNGEON_HEART: return "地牢之心"
		BuildingType.TREASURY: return "金库"
		BuildingType.LAIR: return "巢穴"
		BuildingType.DEMON_LAIR: return "恶魔巢穴"
		BuildingType.ORC_LAIR: return "兽人巢穴"
		BuildingType.TRAINING_ROOM: return "训练室"
		BuildingType.LIBRARY: return "图书馆"
		BuildingType.WORKSHOP: return "工坊"
		BuildingType.PRISON: return "监狱"
		BuildingType.TORTURE_CHAMBER: return "刑房"
		BuildingType.ARROW_TOWER: return "箭塔"
		BuildingType.ARCANE_TOWER: return "奥术塔"
		BuildingType.DEFENSE_WORKS: return "防御工事"
		BuildingType.MAGIC_ALTAR: return "魔法祭坛"
		BuildingType.SHADOW_TEMPLE: return "暗影神殿"
		BuildingType.MAGIC_RESEARCH_INSTITUTE: return "魔法研究院"
		BuildingType.ACADEMY: return "学院"
		BuildingType.HOSPITAL: return "医院"
		BuildingType.FACTORY: return "工厂"
		BuildingType.MARKET: return "市场"
		_: return "未知建筑"


static func is_infrastructure_building(building_type: int) -> bool:
	"""检查是否为基础设施建筑"""
	return building_type in [BuildingType.TREASURY, BuildingType.LAIR, BuildingType.DEMON_LAIR, BuildingType.ORC_LAIR]


static func is_functional_building(building_type: int) -> bool:
	"""检查是否为功能性建筑"""
	return building_type in [BuildingType.TRAINING_ROOM, BuildingType.LIBRARY, BuildingType.WORKSHOP]


static func is_military_building(building_type: int) -> bool:
	"""检查是否为军事建筑"""
	return building_type in [BuildingType.PRISON, BuildingType.TORTURE_CHAMBER, BuildingType.ARROW_TOWER, BuildingType.ARCANE_TOWER, BuildingType.DEFENSE_WORKS]


static func is_magic_building(building_type: int) -> bool:
	"""检查是否为魔法建筑"""
	return building_type in [BuildingType.MAGIC_ALTAR, BuildingType.SHADOW_TEMPLE, BuildingType.MAGIC_RESEARCH_INSTITUTE]


static func get_all_building_types() -> Array[int]:
	"""获取所有建筑类型"""
	var types: Array[int] = [
		BuildingType.DUNGEON_HEART,
		BuildingType.TREASURY, BuildingType.LAIR, BuildingType.DEMON_LAIR, BuildingType.ORC_LAIR,
		BuildingType.TRAINING_ROOM, BuildingType.LIBRARY, BuildingType.WORKSHOP,
		BuildingType.PRISON, BuildingType.TORTURE_CHAMBER, BuildingType.ARROW_TOWER, BuildingType.ARCANE_TOWER, BuildingType.DEFENSE_WORKS,
		BuildingType.MAGIC_ALTAR, BuildingType.SHADOW_TEMPLE, BuildingType.MAGIC_RESEARCH_INSTITUTE,
		BuildingType.ACADEMY, BuildingType.HOSPITAL, BuildingType.FACTORY, BuildingType.MARKET
	]
	return types


# === 调试信息 ===

func print_building_types():
	"""打印所有建筑类型"""
	LogManager.info("=== Building Types ===")
	for type in get_all_building_types():
		LogManager.info("%d: %s" % [type, get_building_name(type)])
	LogManager.info("=====================")
