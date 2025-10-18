class_name WorkerConstants
extends Object

## 工人常量定义 - GoblinWorker 和 GoblinEngineer 的状态常量
##
## 使用独立的常量类避免与 MonstersTypes.MonsterStatus 冲突
## 这些是专门为工人系统设计的业务状态

# 苦工状态常量
class WorkerStatus:
	const IDLE = 0 # 空闲
	const MOVING_TO_MINE = 1 # 移动到挖掘点
	const MINING = 2 # 挖掘中
	const RETURNING_TO_BASE = 3 # 返回基地
	const FLEEING = 4 # 逃跑中
	const WANDERING = 5 # 游荡中
	const STUNNED = 6 # 眩晕状态

# 工程师状态常量
class EngineerStatus:
	const IDLE = 0 # 空闲
	const WANDERING = 1 # 游荡中
	const FETCHING_RESOURCES = 2 # 获取资源
	const MOVING_TO_SITE = 3 # 前往工地
	const CONSTRUCTING = 4 # 建造中
	const REPAIRING = 5 # 修理中
	const UPGRADING = 6 # 升级中
	const RELOADING = 7 # 装填中
	const DEPOSITING_GOLD = 8 # 存储金币
	const RETURNING_TO_BASE = 9 # 返回基地

# 状态颜色配置
const STATUS_COLORS = {
	# 战斗状态
	"fighting": Color(1.0, 0.2, 0.2, 0.6), # 半透明红色
	"moving": Color(0.2, 1.0, 0.2, 0.6), # 半透明绿色
	
	# 苦工状态（符合COMBAT_SYSTEM.md文档）
	"moving_to_mine": Color(0.2, 1.0, 0.2, 0.6), # 半透明绿色 🟢
	"mining": Color(1.0, 1.0, 0.0, 0.6), # 半透明黄色 🟡 (文档要求)
	"fleeing": Color(0.25, 0.25, 0.25, 0.6), # 半透明深灰色 ⚫
	"returning_to_base": Color(0.0, 1.0, 1.0, 0.6), # 半透明青色
	"wandering": Color(1.0, 0.5, 0.0, 0.6), # 半透明橙色 🟠
	"idle": Color(1.0, 1.0, 1.0, 0.3), # 半透明白色
	
	# 工程师状态
	"moving_to_site": Color(0.2, 1.0, 0.2, 0.6), # 半透明绿色
	"constructing": Color(0.545, 0.271, 0.075, 0.6), # 半透明深棕色
	"repairing": Color(1.0, 1.0, 0.0, 0.6), # 半透明黄色
	"upgrading": Color(0.541, 0.169, 0.886, 0.6), # 半透明紫色
	"returning": Color(0.0, 1.0, 1.0, 0.6), # 半透明青色
	"fetching_resources": Color(0.0, 0.5, 0.0, 0.6), # 半透明深绿色
	"depositing_gold": Color(1.0, 0.843, 0.0, 0.6), # 半透明金色
	"reloading": Color(0.0, 0.0, 0.545, 0.6), # 半透明深蓝色
	"moving_to_training": Color(0.2, 1.0, 0.2, 0.6), # 半透明绿色
	"training": Color(0.545, 0.271, 0.075, 0.6), # 半透明深棕色
	
	# 默认状态
	"default": Color(0.5, 0.5, 0.5, 0.3) # 半透明灰色
}

# 状态描述
const STATUS_DESCRIPTIONS = {
	"fighting": "战斗中",
	"moving": "移动中",
	"moving_to_mine": "前往金矿",
	"mining": "挖掘中",
	"fleeing": "逃跑中",
	"returning_to_base": "返回基地",
	"wandering": "游荡中",
	"idle": "空闲",
	"moving_to_site": "前往工地",
	"constructing": "建造中",
	"repairing": "修理中",
	"upgrading": "升级中",
	"returning": "返回中",
	"fetching_resources": "获取资源",
	"depositing_gold": "存储金币",
	"reloading": "装填弹药",
	"moving_to_training": "前往训练",
	"training": "训练中",
	"default": "未知状态"
}

# 辅助函数
static func get_status_color(state: String) -> Color:
	"""获取状态对应的颜色"""
	if state in STATUS_COLORS:
		return STATUS_COLORS[state]
	return STATUS_COLORS["default"]

static func get_status_description(state: String) -> String:
	"""获取状态的文字描述"""
	if state in STATUS_DESCRIPTIONS:
		return STATUS_DESCRIPTIONS[state]
	return STATUS_DESCRIPTIONS["default"]
