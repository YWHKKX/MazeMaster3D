extends Node

## BuildingStatus - 建筑状态常量（Autoload单例）
## 
## 统一管理建筑状态枚举值，消除魔法数字

# ============================================================================
# 建筑状态枚举
# ============================================================================

const PLANNING = 0 # 规划中（刚放置，等待建造）
const UNDER_CONSTRUCTION = 1 # 建造中（工程师正在建造）
const COMPLETED = 2 # 已完成（可正常使用）
const DAMAGED = 3 # 受损（需要维修）
const DESTROYED = 4 # 被摧毁（需要重建）

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	name = "BuildingStatus"
	LogManager.info("BuildingStatus - 建筑状态常量已初始化")

# ============================================================================
# 工具函数
# ============================================================================

## 获取状态名称（中文）
static func get_status_name(status: int) -> String:
	match status:
		PLANNING:
			return "规划中"
		UNDER_CONSTRUCTION:
			return "建造中"
		COMPLETED:
			return "已完成"
		DAMAGED:
			return "受损"
		DESTROYED:
			return "被摧毁"
		_:
			return "未知状态"

## 获取状态名称（英文）
static func get_status_name_en(status: int) -> String:
	match status:
		PLANNING:
			return "Planning"
		UNDER_CONSTRUCTION:
			return "Under Construction"
		COMPLETED:
			return "Completed"
		DAMAGED:
			return "Damaged"
		DESTROYED:
			return "Destroyed"
		_:
			return "Unknown"

## 检查建筑是否可以建造
static func is_buildable(status: int) -> bool:
	"""检查建筑是否处于可建造状态"""
	return status in [PLANNING, UNDER_CONSTRUCTION]

## 检查建筑是否可以正常工作
static func is_functional(status: int) -> bool:
	"""检查建筑是否可以正常工作"""
	return status == COMPLETED

## 检查建筑是否需要维修
static func needs_repair(status: int) -> bool:
	"""检查建筑是否需要维修"""
	return status == DAMAGED

## 检查建筑是否已被摧毁
static func is_destroyed(status: int) -> bool:
	"""检查建筑是否已被摧毁"""
	return status == DESTROYED

## 检查建筑是否正在建造
static func is_under_construction(status: int) -> bool:
	"""检查建筑是否正在建造"""
	return status == UNDER_CONSTRUCTION

## 获取状态图标（用于UI显示）
static func get_status_icon(status: int) -> String:
	match status:
		PLANNING:
			return "📐" # 规划图标
		UNDER_CONSTRUCTION:
			return "🔨" # 建造图标
		COMPLETED:
			return "✅" # 完成图标
		DAMAGED:
			return "⚠️" # 受损图标
		DESTROYED:
			return "💥" # 摧毁图标
		_:
			return "❓"

## 获取状态颜色（用于UI显示）
static func get_status_color(status: int) -> Color:
	match status:
		PLANNING:
			return Color(0.5, 0.5, 1.0) # 蓝色
		UNDER_CONSTRUCTION:
			return Color(1.0, 0.8, 0.0) # 黄色
		COMPLETED:
			return Color(0.0, 1.0, 0.0) # 绿色
		DAMAGED:
			return Color(1.0, 0.5, 0.0) # 橙色
		DESTROYED:
			return Color(1.0, 0.0, 0.0) # 红色
		_:
			return Color(0.5, 0.5, 0.5) # 灰色
