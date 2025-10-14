## 建筑状态管理类
##
## 此文件定义了建筑状态相关的常量和颜色配置
## 注意：这是一个静态类，不需要实例化

extends Object

## ============================================================================
## 建筑状态字符串
## ============================================================================

const STATUS_PLANNING = "planning" ## 规划中
const STATUS_UNDER_CONSTRUCTION = "under_construction" ## 建造中
const STATUS_OPERATIONAL = "operational" ## 运营中
const STATUS_IDLE = "idle" ## 空闲
const STATUS_ACTIVE = "active" ## 活跃
const STATUS_RELOADING = "reloading" ## 装填中
const STATUS_DAMAGED = "damaged" ## 损坏
const STATUS_DESTROYED = "destroyed" ## 摧毁

## ============================================================================
## 建筑状态颜色
## ============================================================================

const COLOR_PLANNING = Color(0.7, 0.7, 0.7) ## 规划中 - 灰色
const COLOR_UNDER_CONSTRUCTION = Color(0.8, 0.6, 0.0) ## 建造中 - 橙色
const COLOR_OPERATIONAL = Color(0.0, 0.8, 0.0) ## 运营中 - 绿色
const COLOR_IDLE = Color(0.8, 0.8, 0.8) ## 空闲 - 浅灰色
const COLOR_ACTIVE = Color(0.0, 1.0, 0.0) ## 活跃 - 亮绿色
const COLOR_RELOADING = Color(0.0, 0.6, 1.0) ## 装填中 - 蓝色
const COLOR_DAMAGED = Color(1.0, 0.6, 0.0) ## 损坏 - 黄橙色
const COLOR_DESTROYED = Color(1.0, 0.0, 0.0) ## 摧毁 - 红色

## ============================================================================
## 工具函数
## ============================================================================

static func get_status_name(status: String) -> String:
	"""获取状态的中文名称"""
	match status:
		STATUS_PLANNING: return "规划中"
		STATUS_UNDER_CONSTRUCTION: return "建造中"
		STATUS_OPERATIONAL: return "运营中"
		STATUS_IDLE: return "空闲"
		STATUS_ACTIVE: return "活跃"
		STATUS_RELOADING: return "装填中"
		STATUS_DAMAGED: return "损坏"
		STATUS_DESTROYED: return "摧毁"
		_: return "未知"

static func get_status_color(status: String) -> Color:
	"""获取状态的颜色"""
	match status:
		STATUS_PLANNING: return COLOR_PLANNING
		STATUS_UNDER_CONSTRUCTION: return COLOR_UNDER_CONSTRUCTION
		STATUS_OPERATIONAL: return COLOR_OPERATIONAL
		STATUS_IDLE: return COLOR_IDLE
		STATUS_ACTIVE: return COLOR_ACTIVE
		STATUS_RELOADING: return COLOR_RELOADING
		STATUS_DAMAGED: return COLOR_DAMAGED
		STATUS_DESTROYED: return COLOR_DESTROYED
		_: return Color.WHITE

static func is_operational_status(status: String) -> bool:
	"""检查是否为可操作状态"""
	return status in [STATUS_OPERATIONAL, STATUS_IDLE, STATUS_ACTIVE, STATUS_RELOADING]

static func is_damaged_status(status: String) -> bool:
	"""检查是否为损坏状态"""
	return status in [STATUS_DAMAGED, STATUS_DESTROYED]

static func is_construction_status(status: String) -> bool:
	"""检查是否为建造相关状态"""
	return status in [STATUS_PLANNING, STATUS_UNDER_CONSTRUCTION]
