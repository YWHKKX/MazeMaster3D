extends RefCounted
class_name BuildingRenderMode

## 🏗️ 建筑渲染模式枚举
## 定义3x3x3建筑的渲染方式

enum RenderMode {
	GRIDMAP,      # GridMap模块化拼接
	PROCEDURAL    # 程序化网格生成
}

# 渲染模式名称映射
static var mode_names: Dictionary = {
	RenderMode.GRIDMAP: "GridMap模块化拼接",
	RenderMode.PROCEDURAL: "程序化网格生成"
}

# 渲染模式描述
static var mode_descriptions: Dictionary = {
	RenderMode.GRIDMAP: "使用预制的建筑构件在3D网格中拼接，适合快速搭建和修改",
	RenderMode.PROCEDURAL: "通过算法动态生成建筑网格，适合复杂结构和参数化设计"
}

# 渲染模式优势
static var mode_advantages: Dictionary = {
	RenderMode.GRIDMAP: [
		"快速搭建",
		"易于修改",
		"性能良好",
		"模块化设计"
	],
	RenderMode.PROCEDURAL: [
		"高度灵活",
		"参数化设计",
		"动态生成",
		"内存效率"
	]
}

# 渲染模式适用场景
static var mode_use_cases: Dictionary = {
	RenderMode.GRIDMAP: [
		"结构规整的建筑",
		"快速原型设计",
		"需要频繁修改的建筑",
		"开发初期阶段"
	],
	RenderMode.PROCEDURAL: [
		"生产环境的最终建筑",
		"复杂几何结构",
		"高性能要求场景",
		"动态生成需求"
	]
}


static func get_mode_name(mode: RenderMode) -> String:
	"""获取渲染模式名称"""
	return mode_names.get(mode, "未知模式")


static func get_mode_description(mode: RenderMode) -> String:
	"""获取渲染模式描述"""
	return mode_descriptions.get(mode, "无描述")


static func get_mode_advantages(mode: RenderMode) -> Array[String]:
	"""获取渲染模式优势"""
	return mode_advantages.get(mode, [])


static func get_mode_use_cases(mode: RenderMode) -> Array[String]:
	"""获取渲染模式适用场景"""
	return mode_use_cases.get(mode, [])


static func get_all_modes() -> Array[RenderMode]:
	"""获取所有渲染模式"""
	return [RenderMode.GRIDMAP, RenderMode.PROCEDURAL]


static func print_mode_info(mode: RenderMode):
	"""打印渲染模式信息"""
	LogManager.info("=== 渲染模式: %s ===" % get_mode_name(mode))
	LogManager.info("描述: %s" % get_mode_description(mode))
	LogManager.info("优势:")
	for advantage in get_mode_advantages(mode):
		LogManager.info("  - %s" % advantage)
	LogManager.info("适用场景:")
	for use_case in get_mode_use_cases(mode):
		LogManager.info("  - %s" % use_case)
	LogManager.info("==========================")


static func print_all_modes():
	"""打印所有渲染模式信息"""
	LogManager.info("=== 所有建筑渲染模式 ===")
	for mode in get_all_modes():
		print_mode_info(mode)
	LogManager.info("==========================")
