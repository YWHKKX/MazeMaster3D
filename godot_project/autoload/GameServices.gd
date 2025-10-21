extends Node
## 🎮 游戏服务定位器（Autoload单例）
## 提供全局访问各个管理器的统一入口
## 替代硬编码的 get_node("/root/Main/XXX") 路径

# ============================================================================
# 游戏状态枚举（从Enums.gd迁移）
# ============================================================================

enum GameState {
	MENU, ## 菜单状态
	PLAYING, ## 游戏中
	PAUSED, ## 暂停
	GAME_OVER, ## 游戏结束
	VICTORY ## 胜利
}

# UI模式枚举（从Enums.gd迁移）
enum UIMode {
	NORMAL, ## 正常模式
	BUILD, ## 建造模式
	SUMMON, ## 召唤模式
	SELECT, ## 选择模式
	CAVITY_EDIT ## 空洞编辑模式
}

# 建造模式枚举（从Enums.gd迁移）
enum BuildMode {
	NONE, ## 无建造模式
	DIG, ## 挖掘模式
	TREASURY, ## 建造金库
	SUMMON, ## 召唤单位
	SUMMON_SELECTION, ## 怪物选择模式
	SUMMON_LOGISTICS, ## 后勤召唤模式
	
	## 建筑系统建造模式
	BUILD_INFRASTRUCTURE, ## 基础设施建筑
	BUILD_FUNCTIONAL, ## 功能性建筑
	BUILD_MILITARY, ## 军事建筑
	BUILD_MAGICAL, ## 魔法建筑
	BUILD_SPECIFIC, ## 特定建筑类型
	
	## 工程师相关模式
	SUMMON_ENGINEER, ## 召唤工程师
	
	## 空洞系统模式
	CAVITY_CREATE, ## 创建空洞
	CAVITY_EDIT, ## 编辑空洞
	CAVITY_DELETE ## 删除空洞
}

# [单例模式] 静态实例
static var instance: GameServices = null

# === 核心管理器 ===
# physics_system 已删除，使用 Godot 内置物理系统
var resource_manager: ResourceManager = null
var resource_collection_manager: ResourceCollectionManager = null
var building_manager: BuildingManager = null
var character_manager: CharacterManager = null
# gold_mine_manager 已整合到 resource_manager 中，但苦工和工程师仍需要独立的GoldMineManager
var gold_mine_manager: GoldMineManager = null
var tile_manager: TileManager = null
var grid_manager: GridManager = null
var placement_system: PlacementSystem = null
var combat_manager: CombatManager = null
var auto_assigner: AutoAssigner = null

# === 子系统 ===
var mining_manager: MiningManager = null
var unit_name_display_manager: UnitNameDisplayManager = null
var resource_trade_manager: ResourceTradeManager = null
var resource_prediction_manager: ResourcePredictionManager = null
var resource_allocation_manager: ResourceAllocationManager = null
var enhanced_resource_renderer: Node = null
# status_indicator_manager 已删除，状态指示器功能已整合到角色系统中

# 预加载类型（用于类型提示）
# PhysicsSystem 已删除，使用 Godot 内置物理系统
const ResourceManager = preload("res://scripts/managers/resource/ResourceManager.gd")
const ResourceCollectionManager = preload("res://scripts/managers/resource/ResourceCollectionManager.gd")
const ResourceTradeManager = preload("res://scripts/managers/resource/ResourceTradeManager.gd")
const ResourcePredictionManager = preload("res://scripts/managers/resource/ResourcePredictionManager.gd")
const ResourceAllocationManager = preload("res://scripts/managers/resource/ResourceAllocationManager.gd")
const BuildingManager = preload("res://scripts/managers/BuildingManager.gd")
const CharacterManager = preload("res://scripts/managers/CharacterManager.gd")
const GoldMineManager = preload("res://scripts/managers/resource/GoldMineManager.gd")
const TileManager = preload("res://scripts/managers/TileManager.gd")
const GridManager = preload("res://scripts/managers/GridManager.gd")
const PlacementSystem = preload("res://scripts/managers/PlacementSystem.gd")
const CombatManager = preload("res://scripts/managers/CombatManager.gd")
const AutoAssigner = preload("res://scripts/managers/AutoAssigner.gd")
const MiningManager = preload("res://scripts/managers/resource/MiningManager.gd")
const UnitNameDisplayManager = preload("res://scripts/managers/UnitNameDisplayManager.gd")
# StatusIndicatorManager 已删除，状态指示器功能已整合到角色系统中


func _ready():
	"""初始化服务定位器"""
	instance = self
	name = "GameServices"
	LogManager.info("GameServices - 服务定位器已初始化")


# === 服务注册API ===

func register(service_name: String, service: Node):
	"""注册服务到全局访问点
	
	Args:
		service_name: 服务名称（如 "physics_system"）
		service: 服务实例
	"""
	match service_name:
		# "physics_system": physics_system = service  # 已删除
		"resource_manager": resource_manager = service
		"resource_collection_manager": resource_collection_manager = service
		"building_manager": building_manager = service
		"character_manager": character_manager = service
		"gold_mine_manager": gold_mine_manager = service
		"tile_manager": tile_manager = service
		"grid_manager": grid_manager = service
		"placement_system": placement_system = service
		"combat_manager": combat_manager = service
		"auto_assigner": auto_assigner = service
		"mining_manager": mining_manager = service
		"unit_name_display_manager": unit_name_display_manager = service
		"resource_trade_manager": resource_trade_manager = service
		"resource_prediction_manager": resource_prediction_manager = service
		"resource_allocation_manager": resource_allocation_manager = service
		"enhanced_resource_renderer": enhanced_resource_renderer = service
		# "status_indicator_manager": status_indicator_manager = service  # 已删除
		_:
			LogManager.warning("GameServices - 未知服务名称: " + service_name)
			return
	
	LogManager.debug("GameServices - 服务已注册: " + service_name)


func get_service(service_name: String) -> Node:
	"""获取服务实例
	
	Args:
		service_name: 服务名称
		
	Returns:
		服务实例，如果不存在则返回null
	"""
	return get(service_name)


func is_service_ready(service_name: String) -> bool:
	"""检查服务是否已注册且可用
	
	Args:
		service_name: 服务名称
		
	Returns:
		服务是否可用
	"""
	var service = get(service_name)
	return service != null


# === 便捷访问API ===

# get_physics() 已删除，使用 Godot 内置物理系统

func get_resources() -> ResourceManager:
	"""获取资源管理器"""
	return resource_manager

func get_resource_manager() -> ResourceManager:
	"""获取资源管理器（别名函数）"""
	return resource_manager

func get_resource_collection_manager() -> ResourceCollectionManager:
	"""获取资源采集管理器"""
	return resource_collection_manager

func get_buildings() -> BuildingManager:
	"""获取建筑管理器"""
	return building_manager

func get_characters() -> CharacterManager:
	"""获取角色管理器"""
	return character_manager

func get_gold_mines() -> GoldMineManager:
	"""获取金矿管理器（独立的GoldMineManager）"""
	return gold_mine_manager

func get_enhanced_resource_renderer():
	"""获取增强资源渲染器"""
	return get_service("enhanced_resource_renderer")

func get_tiles() -> TileManager:
	"""获取地图管理器"""
	return tile_manager

func get_tile_manager() -> TileManager:
	"""获取瓦片管理器（别名函数）"""
	return tile_manager

func get_unit_name_display_manager() -> UnitNameDisplayManager:
	"""获取单位名称显示管理器"""
	return unit_name_display_manager

func has_unit_name_display_manager() -> bool:
	"""检查是否有单位名称显示管理器"""
	return unit_name_display_manager != null

func get_resource_trade_manager() -> ResourceTradeManager:
	"""获取资源交易管理器"""
	return resource_trade_manager

func get_resource_prediction_manager() -> ResourcePredictionManager:
	"""获取资源预测管理器"""
	return resource_prediction_manager

func get_resource_allocation_manager() -> ResourceAllocationManager:
	"""获取资源分配管理器"""
	return resource_allocation_manager

func get_grid_manager() -> GridManager:
	"""获取网格管理器"""
	return grid_manager

func get_placement_system() -> PlacementSystem:
	"""获取放置系统"""
	return placement_system

func get_combat_manager() -> CombatManager:
	"""获取战斗管理器"""
	return combat_manager

func get_auto_assigner() -> AutoAssigner:
	"""获取自动分配器"""
	return auto_assigner

func get_mining_manager() -> MiningManager:
	"""获取挖矿管理器"""
	return mining_manager


# === 调试信息 ===

func get_registered_services() -> Dictionary:
	"""获取所有已注册服务的状态"""
	return {
		# "physics_system": physics_system != null,  # 已删除
		"resource_manager": resource_manager != null,
		"resource_collection_manager": resource_collection_manager != null,
		"building_manager": building_manager != null,
		"character_manager": character_manager != null,
		"gold_mine_manager": gold_mine_manager != null,
		"tile_manager": tile_manager != null,
		"grid_manager": grid_manager != null,
		"placement_system": placement_system != null,
		"combat_manager": combat_manager != null,
		"auto_assigner": auto_assigner != null,
		"mining_manager": mining_manager != null,
		"unit_name_display_manager": unit_name_display_manager != null,
		"resource_trade_manager": resource_trade_manager != null,
		"resource_prediction_manager": resource_prediction_manager != null,
		"resource_allocation_manager": resource_allocation_manager != null,
		"enhanced_resource_renderer": enhanced_resource_renderer != null # 🔧 修复：添加渲染器状态检查
		# "status_indicator_manager": status_indicator_manager != null  # 已删除
	}


func print_service_status():
	"""打印所有服务的注册状态"""
	LogManager.info("=== GameServices Status ===")
	var services = get_registered_services()
	for service_name in services:
		var status = "✅" if services[service_name] else "❌"
		LogManager.info(status + " " + service_name)
	LogManager.info("==========================")
