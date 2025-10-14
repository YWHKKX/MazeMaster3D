extends Node
## 🎮 游戏服务定位器（Autoload单例）
## 提供全局访问各个管理器的统一入口
## 替代硬编码的 get_node("/root/Main/XXX") 路径

# [单例模式] 静态实例
static var instance: GameServices = null

# === 核心管理器 ===
var physics_system: PhysicsSystem = null
var resource_manager: ResourceManager = null
var building_manager: BuildingManager = null
var character_manager: CharacterManager = null
var gold_mine_manager: GoldMineManager = null
var tile_manager: TileManager = null
var grid_manager: GridManager = null
var placement_system: PlacementSystem = null
var combat_manager: CombatManager = null
var auto_assigner: AutoAssigner = null

# === 子系统 ===
var mining_manager: MiningManager = null
var status_indicator_manager: StatusIndicatorManager = null

# 预加载类型（用于类型提示）
const PhysicsSystem = preload("res://scripts/managers/PhysicsSystem.gd")
const ResourceManager = preload("res://scripts/managers/ResourceManager.gd")
const BuildingManager = preload("res://scripts/managers/BuildingManager.gd")
const CharacterManager = preload("res://scripts/managers/CharacterManager.gd")
const GoldMineManager = preload("res://scripts/managers/GoldMineManager.gd")
const TileManager = preload("res://scripts/managers/TileManager.gd")
const GridManager = preload("res://scripts/managers/GridManager.gd")
const PlacementSystem = preload("res://scripts/managers/PlacementSystem.gd")
const CombatManager = preload("res://scripts/managers/CombatManager.gd")
const AutoAssigner = preload("res://scripts/managers/AutoAssigner.gd")
const MiningManager = preload("res://scripts/managers/MiningManager.gd")
const StatusIndicatorManager = preload("res://scripts/managers/StatusIndicatorManager.gd")


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
		"physics_system": physics_system = service
		"resource_manager": resource_manager = service
		"building_manager": building_manager = service
		"character_manager": character_manager = service
		"gold_mine_manager": gold_mine_manager = service
		"tile_manager": tile_manager = service
		"grid_manager": grid_manager = service
		"placement_system": placement_system = service
		"combat_manager": combat_manager = service
		"auto_assigner": auto_assigner = service
		"mining_manager": mining_manager = service
		"status_indicator_manager": status_indicator_manager = service
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

func get_physics() -> PhysicsSystem:
	"""获取物理系统"""
	return physics_system

func get_resources() -> ResourceManager:
	"""获取资源管理器"""
	return resource_manager

func get_buildings() -> BuildingManager:
	"""获取建筑管理器"""
	return building_manager

func get_characters() -> CharacterManager:
	"""获取角色管理器"""
	return character_manager

func get_gold_mines() -> GoldMineManager:
	"""获取金矿管理器"""
	return gold_mine_manager

func get_tiles() -> TileManager:
	"""获取地图管理器"""
	return tile_manager


# === 调试信息 ===

func get_registered_services() -> Dictionary:
	"""获取所有已注册服务的状态"""
	return {
		"physics_system": physics_system != null,
		"resource_manager": resource_manager != null,
		"building_manager": building_manager != null,
		"character_manager": character_manager != null,
		"gold_mine_manager": gold_mine_manager != null,
		"tile_manager": tile_manager != null,
		"grid_manager": grid_manager != null,
		"placement_system": placement_system != null,
		"combat_manager": combat_manager != null,
		"auto_assigner": auto_assigner != null,
		"mining_manager": mining_manager != null,
		"status_indicator_manager": status_indicator_manager != null
	}


func print_service_status():
	"""打印所有服务的注册状态"""
	LogManager.info("=== GameServices Status ===")
	var services = get_registered_services()
	for service_name in services:
		var status = "✅" if services[service_name] else "❌"
		LogManager.info(status + " " + service_name)
	LogManager.info("==========================")
