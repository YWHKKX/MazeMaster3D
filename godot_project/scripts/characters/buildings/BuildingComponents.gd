extends RefCounted
class_name BuildingComponents

## 🏗️ 建筑构件常量类
## 定义所有建筑构件的ID和属性

# 空构件
const ID_EMPTY = 0

# 基础结构构件 (1-20)
const ID_FLOOR_STONE = 1
const ID_FLOOR_WOOD = 2
const ID_FLOOR_METAL = 3
const ID_WALL_STONE = 4
const ID_WALL_WOOD = 5
const ID_WALL_METAL = 6
const ID_CORNER_STONE = 7
const ID_CORNER_WOOD = 8
const ID_CORNER_METAL = 9

# 门窗构件 (21-30)
const ID_DOOR_WOOD = 21
const ID_DOOR_METAL = 22
const ID_WINDOW_SMALL = 23
const ID_WINDOW_LARGE = 24
const ID_GATE_STONE = 25

# 装饰构件 (31-40)
const ID_PILLAR_STONE = 31
const ID_PILLAR_WOOD = 32
const ID_TORCH_WALL = 33
const ID_BANNER_CLOTH = 34
const ID_STATUE_STONE = 35

# 特殊构件 (41-50)
const ID_STAIRS_WOOD = 41
const ID_STAIRS_STONE = 42
const ID_ROOF_SLOPE = 43
const ID_ROOF_PEAK = 44
const ID_FLOOR_TRAP = 45

# 魔法构件 (51-60)
const ID_MAGIC_CRYSTAL = 51
const ID_ENERGY_RUNE = 52
const ID_MAGIC_CORE = 53
const ID_SUMMONING_CIRCLE = 54
const ID_DEMON_HORN = 55

# 军事构件 (61-70)
const ID_ARROW_SLOT = 61
const ID_CROSSBOW = 62
const ID_AMMO_RACK = 63
const ID_WATCHTOWER = 64
const ID_BATTLE_STANDARD = 65

# 资源构件 (71-80)
const ID_GOLD_PILE = 71
const ID_MANA_CRYSTAL = 72
const ID_RESOURCE_NODE = 73
const ID_STORAGE_CRATE = 74
const ID_TREASURE_CHEST = 75


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
	
	# 军事构件
	_add_component_property(ID_ARROW_SLOT, "Arrow Slot", "射箭口", Color.GRAY, Vector3(0.33, 0.33, 0.05))
	_add_component_property(ID_CROSSBOW, "Crossbow", "弩机", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_AMMO_RACK, "Ammo Rack", "弹药架", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_WATCHTOWER, "Watchtower", "瞭望台", Color.GRAY, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_BATTLE_STANDARD, "Battle Standard", "战旗", Color.RED, Vector3(0.33, 0.33, 0.33))
	
	# 资源构件
	_add_component_property(ID_GOLD_PILE, "Gold Pile", "金币堆", Color.GOLD, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_MANA_CRYSTAL, "Mana Crystal", "魔力水晶", Color.BLUE, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_RESOURCE_NODE, "Resource Node", "资源节点", Color.GREEN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_STORAGE_CRATE, "Storage Crate", "存储箱", Color.BROWN, Vector3(0.33, 0.33, 0.33))
	_add_component_property(ID_TREASURE_CHEST, "Treasure Chest", "宝箱", Color(0.8, 0.6, 0.2), Vector3(0.33, 0.33, 0.33))


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
	return id in [ID_MAGIC_CRYSTAL, ID_ENERGY_RUNE, ID_MAGIC_CORE, ID_SUMMONING_CIRCLE, ID_DEMON_HORN]


static func is_military_component(id: int) -> bool:
	"""检查是否为军事构件"""
	return id in [ID_ARROW_SLOT, ID_CROSSBOW, ID_AMMO_RACK, ID_WATCHTOWER, ID_BATTLE_STANDARD]


static func is_resource_component(id: int) -> bool:
	"""检查是否为资源构件"""
	return id in [ID_GOLD_PILE, ID_MANA_CRYSTAL, ID_RESOURCE_NODE, ID_STORAGE_CRATE, ID_TREASURE_CHEST]


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


# 初始化静态数据
_static_init()
