extends Node3D
# 主游戏脚本 - MazeMaster3D
# 负责初始化游戏系统和协调各个管理器

# 导入必要的类
# Character 类已废弃，使用 CharacterBase 作为角色基类
const GridManager = preload("res://scripts/managers/GridManager.gd")

@onready var game_manager = $GameManager
@onready var tile_manager = $TileManager
@onready var map_generator = $MapGenerator
@onready var character_manager = $CharacterManager
@onready var grid_manager = $GridManager
# terrain_manager 已删除，使用 CavityManager 统一管理
@onready var camera = $World/Camera3D
@onready var world = $World
@onready var ui = $UI

# 日志管理器现在作为autoload使用

# UI系统引用
@onready var main_menu_ui = $UI/MainMenuUI
@onready var game_ui = $UI/GameUI
@onready var building_ui = $UI/BuildingSelectionUI
@onready var monster_ui = $UI/MonsterSelectionUI
@onready var logistics_ui = $UI/LogisticsSelectionUI
@onready var mining_ui = $UI/MiningSystemUI
@onready var resource_display_ui = $UI/ResourceDisplayUI
@onready var resource_visualization_ui = $UI/ResourceVisualizationUI
@onready var resource_collection_ui = $UI/ResourceCollectionUI
@onready var resource_density_ui = $UI/ResourceDensityUI
# gold_mine_manager 已整合到 resource_manager 中，但苦工和工程师仍需要独立的GoldMineManager
@onready var gold_mine_manager = null
@onready var building_manager = $BuildingManager
@onready var auto_assigner = $AutoAssigner
@onready var combat_manager = $CombatManager
@onready var resource_collection_manager = $ResourceCollectionManager
@onready var resource_trade_manager = $ResourceTradeManager
@onready var resource_prediction_manager = $ResourcePredictionManager
@onready var resource_allocation_manager = $ResourceAllocationManager
@onready var plant_renderer = $PlantRenderer
@onready var mineral_renderer = $MineralRenderer
@onready var enhanced_resource_renderer = $EnhancedResourceRenderer
@onready var resource_renderer = $ResourceRenderer
@onready var selection_highlight = $SelectionHighlightSystem
# LogManager is now an autoload

# 预加载管理器类型
const MiningManager = preload("res://scripts/managers/resource/MiningManager.gd")
# StatusIndicatorManager 已删除，状态指示器功能已整合到角色系统中
const ResourceManager = preload("res://scripts/managers/resource/ResourceManager.gd")
const ResourceCollectionManager = preload("res://scripts/managers/resource/ResourceCollectionManager.gd")
const ResourceTradeManager = preload("res://scripts/managers/resource/ResourceTradeManager.gd")
const ResourcePredictionManager = preload("res://scripts/managers/resource/ResourcePredictionManager.gd")
const ResourceAllocationManager = preload("res://scripts/managers/resource/ResourceAllocationManager.gd")
const PlantRenderer = preload("res://scripts/managers/rendering/PlantRenderer.gd")
const MineralRenderer = preload("res://scripts/managers/rendering/MineralRenderer.gd")
const EnhancedResourceRenderer = preload("res://scripts/managers/rendering/EnhancedResourceRenderer.gd")
const ResourceRenderer = preload("res://scripts/managers/ResourceRenderer.gd")
const UnitNameDisplayManager = preload("res://scripts/managers/UnitNameDisplayManager.gd")
const GoldMineManager = preload("res://scripts/managers/resource/GoldMineManager.gd")
# PhysicsSystem 已删除，使用 Godot 内置物理系统
const PlacementSystem = preload("res://scripts/managers/PlacementSystem.gd")
const BuildingManager = preload("res://scripts/managers/BuildingManager.gd")
const BuildingSelectionUI = preload("res://scripts/ui/BuildingSelectionUI.gd")
const CharacterAtlasUI = preload("res://scripts/ui/CharacterAtlasUI.gd")

# 管理器（动态创建）
# status_indicator_manager 已删除，状态指示器功能已整合到角色系统中
# physics_system 已删除，使用 Godot 内置物理系统
var placement_system: PlacementSystem = null
var building_selection_ui: BuildingSelectionUI = null
var character_atlas_ui: CharacterAtlasUI = null

# 挖矿管理器（动态创建）
var mining_manager: MiningManager = null

# 资源管理器（动态创建）
var resource_manager: ResourceManager = null

# 单位名称显示管理器（动态创建）
var unit_name_display_manager: UnitNameDisplayManager = null

var terrain_display_enabled: bool = false

# 游戏状态
var is_game_running = false
var is_paused = false
var current_build_mode = "none" # none, dig, build, summon_monster, summon_logistics
var is_main_menu_visible = true

# 选择的数据
var selected_logistics_data: Dictionary = {}
var selected_building_data: Dictionary = {}
var selected_monster_data: Dictionary = {}

# 输入状态
var mouse_position = Vector2.ZERO
var world_position = Vector3.ZERO


func _ready():
	# 等待一帧确保所有@onready变量都已初始化
	await get_tree().process_frame
	
	# 🔧 必须await，确保游戏初始化（包括地牢之心创建）完成后再显示主菜单
	await initialize_game()
	
	show_main_menu()


func _process(_delta):
	if is_game_running and not is_paused and not is_main_menu_visible:
		update_game_logic(_delta)


func _input(event):
	handle_input(event)

			
func initialize_game():
	"""初始化游戏系统"""
	LogManager.info("游戏系统初始化开始")
	
	# 初始化资源管理器（最先初始化，其他系统依赖它）
	_setup_resource_manager()
	
	# 初始化挖矿管理器
	_setup_mining_manager()
	
	# 初始化单位名称显示管理器
	_setup_unit_name_display_manager()
	
	# 状态指示器管理器已删除，状态指示器功能已整合到角色系统中
	
	# 物理系统已删除，使用 Godot 内置物理系统
	_setup_placement_system()
	_setup_building_manager()
	_setup_building_selection_ui()
	_setup_character_atlas_ui()
	
	# 初始化地形管理器
	
	# 初始化游戏管理器
	game_manager.initialize()

	# 同步网格系统的尺寸到地图尺寸
	if grid_manager and tile_manager:
		grid_manager.update_map_size(tile_manager.get_map_size())

	# 设置初始摄像机位置
	setup_camera()

	# 🔧 初始化渲染器（必须在注册服务之前）
	_initialize_renderers()

	setup_ui()

	# 不在这里创建地牢环境，等待用户点击开始游戏或重新生成地图
	LogManager.info("游戏初始化完成，等待用户操作")
	
	# ✅ 注册@onready管理器到GameServices
	_register_scene_managers()
	
	# ✅ 打印服务注册状态（调试用）
	call_deferred("_print_service_status")

	LogManager.info("游戏系统初始化完成（地牢之心已创建并注册）")

func _initialize_renderers():
	"""初始化渲染器系统"""
	LogManager.info("🔧 初始化渲染器系统...")
	
	# 初始化增强资源渲染器
	if enhanced_resource_renderer:
		enhanced_resource_renderer.set_world_node(world)
		if resource_manager:
			enhanced_resource_renderer.set_resource_manager(resource_manager)
		LogManager.info("✅ EnhancedResourceRenderer 初始化完成")
	else:
		LogManager.error("❌ EnhancedResourceRenderer 节点未找到！")
	
	# 初始化资源渲染器
	if resource_renderer:
		resource_renderer.set_world_node(world)
		if resource_manager:
			resource_renderer.set_resource_manager(resource_manager)
		LogManager.info("✅ ResourceRenderer 初始化完成")
	else:
		LogManager.warning("⚠️ ResourceRenderer 节点未找到")

func _register_scene_managers():
	"""注册场景中的@onready管理器到GameServices"""
	# 这些管理器是从场景树获取的，在_ready()中已经可用
	
	# 注册动态创建的管理器
	if resource_manager:
		GameServices.register("resource_manager", resource_manager)
		LogManager.info("✅ ResourceManager 已注册到 GameServices")
	else:
		LogManager.error("❌ ResourceManager 未找到！")
	
	if tile_manager:
		GameServices.register("tile_manager", tile_manager)
	
	if character_manager:
		GameServices.register("character_manager", character_manager)
	
	if grid_manager:
		GameServices.register("grid_manager", grid_manager)
	
	# 创建独立的GoldMineManager供苦工和工程师使用
	if not gold_mine_manager:
		gold_mine_manager = GoldMineManager.new()
		gold_mine_manager.name = "GoldMineManager"
		add_child(gold_mine_manager)
		GameServices.register("gold_mine_manager", gold_mine_manager)
	
	if building_manager:
		GameServices.register("building_manager", building_manager)
	
	if combat_manager:
		GameServices.register("combat_manager", combat_manager)
	
	if auto_assigner:
		GameServices.register("auto_assigner", auto_assigner)
	
	if resource_collection_manager:
		GameServices.register("resource_collection_manager", resource_collection_manager)
	
	if resource_trade_manager:
		GameServices.register("resource_trade_manager", resource_trade_manager)
	
	if resource_prediction_manager:
		GameServices.register("resource_prediction_manager", resource_prediction_manager)
	
	if resource_allocation_manager:
		GameServices.register("resource_allocation_manager", resource_allocation_manager)
	
	# plant_renderer 和 mineral_renderer 由 EnhancedResourceRenderer 内部管理，不需要单独注册
	
	if enhanced_resource_renderer:
		GameServices.register("enhanced_resource_renderer", enhanced_resource_renderer)
		LogManager.info("✅ EnhancedResourceRenderer 已注册到 GameServices")
	else:
		LogManager.error("❌ EnhancedResourceRenderer 节点未找到！")
	
	LogManager.info("地形高亮功能已整合到 TerrainHighlightSystem")
	
	LogManager.info("GameServices - 所有场景管理器已注册")


func _print_service_status():
	"""打印服务注册状态（调试用）"""
	LogManager.info("=== GameServices 服务状态 ===")
	GameServices.print_service_status()
	LogManager.info("================================")

func _ensure_renderers_ready():
	"""确保所有渲染器在地图生成前准备就绪"""
	LogManager.info("🔧 确保渲染器准备就绪...")
	
	# 检查增强资源渲染器是否已注册
	var enhanced_renderer = GameServices.get_enhanced_resource_renderer()
	if not enhanced_renderer:
		LogManager.error("❌ EnhancedResourceRenderer 未注册到 GameServices！")
		return false
	
	# 检查渲染器是否已设置世界节点
	if not enhanced_renderer.world_node:
		LogManager.warning("⚠️ EnhancedResourceRenderer 世界节点未设置，重新设置...")
		enhanced_renderer.set_world_node(world)
	
	# 检查渲染器是否已设置资源管理器
	if not enhanced_renderer.resource_manager:
		LogManager.warning("⚠️ EnhancedResourceRenderer 资源管理器未设置，重新设置...")
		enhanced_renderer.set_resource_manager(resource_manager)
	
	# 验证渲染器组件
	var components_ready = true
	if not enhanced_renderer.plant_renderer:
		LogManager.warning("⚠️ PlantRenderer 未初始化")
		components_ready = false
	
	if not enhanced_renderer.mineral_renderer:
		LogManager.warning("⚠️ MineralRenderer 未初始化")
		components_ready = false
	
	if not enhanced_renderer.resource_renderer:
		LogManager.warning("⚠️ ResourceRenderer 未初始化")
		components_ready = false
	
	if components_ready:
		LogManager.info("✅ 所有渲染器组件已准备就绪")
	else:
		LogManager.error("❌ 部分渲染器组件未准备就绪")
	
	return components_ready


func _setup_resource_manager():
	"""设置资源管理器"""
	if not resource_manager:
		resource_manager = ResourceManager.new()
		resource_manager.name = "ResourceManager"
		add_child(resource_manager)
		GameServices.register("resource_manager", resource_manager) # ✅ 注册服务
		LogManager.info("资源管理器已初始化")


func _setup_mining_manager():
	"""设置挖矿管理器"""
	if not mining_manager:
		mining_manager = preload("res://scripts/managers/resource/MiningManager.gd").new()
		mining_manager.name = "MiningManager"
		add_child(mining_manager)
		
		# 设置管理器引用
		if tile_manager:
			mining_manager.set_tile_manager(tile_manager)
		if resource_manager:
			mining_manager.set_resource_manager(resource_manager)
		
		GameServices.register("mining_manager", mining_manager) # ✅ 注册服务
		LogManager.info("挖矿管理器已初始化")


func _setup_unit_name_display_manager():
	"""设置单位名称显示管理器"""
	if not unit_name_display_manager:
		unit_name_display_manager = UnitNameDisplayManager.new()
		unit_name_display_manager.name = "UnitNameDisplayManager"
		add_child(unit_name_display_manager)
		
		# 设置默认配置
		var config = {
			"enabled": true,
			"show_names": true,
			"show_health": true, # 🔧 启用生命值显示
			"show_faction": false,
			"update_interval": 0.5,
			"max_displays": 100,
			"performance_mode": true,
			"auto_cleanup": true
		}
		unit_name_display_manager.update_global_config(config)
		
		GameServices.register("unit_name_display_manager", unit_name_display_manager) # ✅ 注册服务
		
		# 🔧 为现有角色创建名称显示
		call_deferred("_create_displays_for_existing_characters")
		
		LogManager.info("单位名称显示管理器已初始化")


func _create_displays_for_existing_characters():
	"""为现有角色创建名称显示"""
	if not unit_name_display_manager:
		return
	
	# 获取所有现有角色
	var characters = _get_all_existing_characters()
	
	# 为每个角色创建名称显示
	for character in characters:
		if character and is_instance_valid(character):
			unit_name_display_manager.create_display_for_unit(character)
	
	LogManager.info("🏷️ [Main] 为 %d 个现有角色创建了名称显示" % characters.size())

func _get_all_existing_characters() -> Array:
	"""获取所有现有角色"""
	var characters = []
	
	# 从CharacterManager获取
	if character_manager and character_manager.has_method("get_all_characters"):
		var nodes = character_manager.get_all_characters()
		for node in nodes:
			if node is CharacterBase:
				characters.append(node)
	
	return characters


# _setup_status_indicator_manager() 已删除，状态指示器功能已整合到角色系统中

# _setup_physics_system() 已删除，使用 Godot 内置物理系统

func _setup_placement_system():
	"""设置统一放置系统"""
	placement_system = PlacementSystem.new()
	placement_system.name = "PlacementSystem"
	add_child(placement_system)
	
	placement_system.initialize_systems(self, tile_manager, character_manager, resource_manager, building_manager)
	
	GameServices.register("placement_system", placement_system) # ✅ 注册服务
	LogManager.info("统一放置系统已初始化")

func _setup_building_manager():
	"""设置建筑管理器"""
	# 如果场景中没有 BuildingManager 节点，创建一个
	if not building_manager:
		building_manager = BuildingManager.new()
		building_manager.name = "BuildingManager"
		add_child(building_manager)
	
	if building_manager:
		building_manager.initialize_systems(self, tile_manager, character_manager, resource_manager)
		GameServices.register("building_manager", building_manager) # ✅ 注册服务
		LogManager.info("建筑管理器已初始化")

func _setup_building_selection_ui():
	"""设置建筑选择UI"""
	building_selection_ui = BuildingSelectionUI.new()
	building_selection_ui.name = "BuildingSelectionUI"
	add_child(building_selection_ui)
	
	# 设置回调函数
	building_selection_ui.set_building_selected_callback(_on_building_selected)
	building_selection_ui.set_main_game_reference(self)
	
	LogManager.info("建筑选择UI已初始化")

	
func _setup_character_atlas_ui():
	"""设置角色图鉴UI"""
	character_atlas_ui = CharacterAtlasUI.new()
	character_atlas_ui.name = "CharacterAtlasUI"
	add_child(character_atlas_ui)
	
	# 设置主游戏引用
	character_atlas_ui.set_main_game_reference(self)
	
	LogManager.info("角色图鉴UI已初始化")


func show_main_menu():
	"""显示主菜单"""
	if main_menu_ui:
		main_menu_ui.set_main_game_reference(self)
		main_menu_ui.show_ui()
		is_main_menu_visible = true
		is_game_running = false


func start_game():
	"""开始游戏"""
	if main_menu_ui:
		main_menu_ui.hide_ui()

	# 检查是否已有地图，如果没有则生成
	if not _has_existing_map():
		LogManager.info("未检测到现有地图，开始生成地图...")
		await create_initial_dungeon()
	else:
		LogManager.info("检测到现有地图，直接开始游戏")

	# 显示游戏UI
	if game_ui:
		game_ui.show_ui()

	# 显示资源面板
	if resource_display_ui and resource_display_ui.has_method("show_ui"):
		resource_display_ui.show_ui()

	is_main_menu_visible = false
	is_game_running = true
	LogManager.info("开始游戏")

func _has_existing_map() -> bool:
	"""检查是否已有地图"""
	if not tile_manager:
		return false
	
	# 检查是否有非空的地形数据
	var map_size = tile_manager.get_map_size()
	for x in range(int(map_size.x)):
		for z in range(int(map_size.z)):
			var tile_data = tile_manager.get_tile_data(Vector3(x, 0, z))
			if tile_data and tile_data.type != TileTypes.TileType.EMPTY:
				return true
	
	return false

func regenerate_map():
	"""重新生成地图"""
	LogManager.info("重新生成地图...")
	
	# 清理现有地图
	if map_generator:
		# 🔧 确保渲染器在地图生成前完全初始化
		_ensure_renderers_ready()
		
		# 清理现有地形
		_clear_existing_map()
		
		# 重新生成地图
		var config = MapGenerator.MapGeneratorConfig.new(MapConfig.get_map_size())
		await map_generator.generate_map(config)
		
		register_terrain_from_cavities()
		
		# 重新创建地牢之心
		create_dungeon_heart()
		
		# 重置摄像机位置
		setup_camera()
		
		LogManager.info("地图重新生成完成")
	else:
		LogManager.error("MapGenerator 未找到，无法重新生成地图")

func register_terrain_from_cavities():
	"""从空洞系统注册地形到地形管理器"""
	LogManager.info("=== 开始地形注册过程 ===")
	
	
	# 获取空洞管理器
	var cavity_manager = get_node("MapGenerator/CavityManager")
	if not cavity_manager:
		LogManager.warning("CavityManager 未找到，无法注册地形")
		LogManager.info("尝试从 MapGenerator 子节点中查找 CavityManager...")
		if map_generator and map_generator.has_node("CavityManager"):
			cavity_manager = map_generator.get_node("CavityManager")
			LogManager.info("✅ 从 MapGenerator 中找到 CavityManager")
		else:
			LogManager.warning("❌ 在 MapGenerator 中也未找到 CavityManager")
			return
	
	LogManager.info("找到 CavityManager，开始获取空洞列表...")
	
	# 获取所有空洞
	var all_cavities = cavity_manager.get_all_cavities()
	LogManager.info("CavityManager 返回了 %d 个空洞" % all_cavities.size())
	
	if all_cavities.size() == 0:
		LogManager.warning("⚠️ 没有找到任何空洞！可能的原因:")
		LogManager.warning("  1. 空洞生成失败")
		LogManager.warning("  2. 空洞未正确注册到 CavityManager")
		LogManager.warning("  3. 地图生成过程中断")
		return
	
	# 注册空洞到地形管理器
	LogManager.info("开始注册空洞到地形管理器...")
	var terrain_manager = map_generator.get_node("TerrainManager")
	if not terrain_manager:
		LogManager.error("未找到 TerrainManager 节点")
		return
	
	var registered_count = 0
	for cavity in all_cavities:
		if terrain_manager.register_terrain_from_cavity(cavity.id):
			registered_count += 1
	
	LogManager.info("地形注册完成: 成功注册 %d/%d 个空洞" % [registered_count, all_cavities.size()])
	
	# 调试空洞信息
	LogManager.info("=== 空洞统计信息 ===")
	LogManager.info("总空洞数: %d" % all_cavities.size())
	
	var type_counts = {}
	for cavity in all_cavities:
		if not type_counts.has(cavity.type):
			type_counts[cavity.type] = 0
		type_counts[cavity.type] += 1
	
	for type_name in type_counts.keys():
		LogManager.info("%s 类型: %d 个" % [type_name, type_counts[type_name]])
	
	LogManager.info("==================")
	
	LogManager.info("=== 地形注册过程完成 ===")

func _clear_existing_map():
	"""清理现有地图"""
	LogManager.info("清理现有地图...")
	
	# 清理地形瓦片
	if tile_manager:
		tile_manager.clear_all_tiles()
	
	# 清理建筑物
	if building_manager:
		building_manager.clear_all_buildings()
	
	# 清理角色
	if character_manager:
		character_manager.clear_all_characters()
	
	# 清理金矿（金矿系统已整合到资源管理器）
	if resource_manager:
		# 清理金矿数据
		resource_manager.gold_mines.clear()
	
	LogManager.info("现有地图清理完成")


func setup_camera():
	"""设置摄像机"""
	var size = tile_manager.get_map_size() if tile_manager else MapConfig.get_map_size()
	var center = Vector3(int(size.x) / 2, 0, int(size.z) / 2)
	# 将摄像机放置在地图中心上方，并向中心看
	camera.position = center + Vector3(0, 35, 40)
	camera.look_at(center, Vector3.UP)

	# 确保摄像机是当前活跃的摄像机
	camera.current = true


func setup_ui():
	"""初始化UI系统"""
	_initialize_ui_system()


func _initialize_ui_system():
	"""初始化UI系统"""
	if game_ui:
		game_ui.set_main_game_reference(self)

	if building_ui:
		building_ui.set_building_selected_callback(_on_building_selected)
	
	# 怪物UI防护：若节点未挂脚本或不存在，动态创建并挂载
	if monster_ui == null or not monster_ui.has_method("toggle_ui"):
		if Engine.has_singleton("MonsterSelectionUI"):
			# 忽略：无全局单例
			pass
		else:
			var MonsterSelectionUIScript = preload("res://scripts/ui/MonsterSelectionUI.gd")
			var ms = MonsterSelectionUIScript.new()
			ms.name = "MonsterSelectionUI"
			if ui and ui.has_node("."):
				ui.add_child(ms)
				monster_ui = ms
				LogManager.info("已动态创建 MonsterSelectionUI 节点并挂载脚本")

	if monster_ui and monster_ui.has_method("set_monster_selected_callback"):
		monster_ui.set_monster_selected_callback(_on_monster_selected)
	
	if logistics_ui:
		logistics_ui.set_logistics_selected_callback(_on_logistics_selected)

	# 初始化资源可视化UI
	if resource_visualization_ui:
		# 设置世界节点引用，用于添加3D标记
		if world:
			resource_visualization_ui.set_world_node(world)
		LogManager.info("ResourceVisualizationUI 初始化完成")

	# 初始化资源采集UI
	if resource_collection_ui:
		LogManager.info("ResourceCollectionUI 初始化完成")

	# 初始化资源密度UI
	if resource_density_ui:
		LogManager.info("ResourceDensityUI 初始化完成")

	# 渲染器初始化已移至 _initialize_renderers() 函数

	# 初始化挖掘系统（金矿系统已整合到资源管理器）
	if resource_manager and character_manager:
		if character_manager.has_method("set_gold_mine_manager"):
			character_manager.set_gold_mine_manager(resource_manager)

	# 初始化建筑系统
	if building_manager and character_manager:
		if character_manager.has_method("set_building_manager"):
			character_manager.set_building_manager(building_manager)
	
	# 设置TileManager引用（用于移动碰撞检测）
	if tile_manager and character_manager:
		character_manager.tile_manager = tile_manager
		LogManager.info("CharacterManager - TileManager引用已设置")

	# [新架构] 所有管理器通过 GameServices 自动获取引用
	# 不再需要手动调用 set_managers()
	
	# UI 仍需要设置管理器（UI不使用GameServices，避免循环依赖）
	if mining_ui:
		mining_ui.set_managers(resource_manager, character_manager) # 金矿系统已整合到资源管理器


func create_initial_dungeon():
	"""创建初始地牢环境"""
	if map_generator:
		# 🔧 确保渲染器在地图生成前完全初始化
		_ensure_renderers_ready()
		
		# 🔧 直接调用 generate_map（便捷函数已删除）
		var config = MapGenerator.MapGeneratorConfig.new(MapConfig.get_map_size())
		await map_generator.generate_map(config)
		
		register_terrain_from_cavities()
		
		# 生成后重置摄像机到地图中心
		setup_camera()
	else:
		LogManager.error("MapGenerator 未找到！")
	
	create_dungeon_heart()


func create_dungeon_heart():
	"""创建地牢之心建筑对象"""
	# 获取地图中心位置（地牢之心的位置）
	var map_size = tile_manager.get_map_size() if tile_manager else MapConfig.get_map_size()
	var center_x = int(map_size.x / 2)
	var center_z = int(map_size.z / 2)
	
	# 🔧 修复：2x2建筑应该占据 (center_x, center_z) 到 (center_x+1, center_z+1)
	# 建筑位置应该是2x2区域的几何中心
	var building_position = Vector3(
		center_x + 1.0, # 2x2区域的X中心
		0.05, # Y坐标固定在地面表面
		center_z + 1.0 # 2x2区域的Z中心
	)
	
	# 使用统一建筑系统创建地牢之心
	var dungeon_heart = UnifiedBuildingMigrator.create_unified_building(BuildingTypes.BuildingType.DUNGEON_HEART)
	
	# 🔧 修复：设置正确的建筑位置和瓦片坐标
	dungeon_heart.position = building_position
	dungeon_heart.tile_x = center_x # 2x2区域的左下角X坐标
	dungeon_heart.tile_y = center_z # 2x2区域的左下角Z坐标
	dungeon_heart.building_id = "dungeon_heart_main"
	
	LogManager.info("🏰 [Main] 创建地牢之心对象: 位置=(%f, %f, %f), 2x2中心, 瓦片左下=(%d, %d)" % [
		dungeon_heart.position.x,
		dungeon_heart.position.y,
		dungeon_heart.position.z,
		center_x,
		center_z
	])
	
	# 添加到场景树
	add_child(dungeon_heart)
	
	# 注册到 BuildingManager（会自动注册到ResourceManager）
	if building_manager:
		building_manager.register_building(dungeon_heart)
		LogManager.info("✅ 地牢之心已注册")
	else:
		LogManager.warning("⚠️ BuildingManager 不存在，无法注册地牢之心")
	
	return dungeon_heart


func create_initial_area():
	"""创建初始挖掘区域"""
	# 初始挖掘区域由TileManager自动创建
	LogManager.info("初始挖掘区域创建完成")


func update_game_logic(_delta: float):
	"""更新游戏逻辑"""
	# 更新游戏管理器
	game_manager.update(_delta)

	# 更新摄像机
	update_camera(_delta)

	# 更新UI
	# update_ui(delta)  # 暂时注释掉，UI系统还未实现


func update_camera(_delta: float):
	"""更新摄像机"""
	# 处理摄像机移动
	handle_camera_movement(_delta)

	# 处理摄像机旋转
	handle_camera_rotation(_delta)


func handle_camera_movement(_delta: float):
	"""处理摄像机移动"""
	var movement = Vector3.ZERO
	var move_speed = 15.0 * _delta

	# WASD进行水平移动（保持在同一高度）
	var forward_direction = (
		Vector3(camera.transform.basis.z.x, 0, camera.transform.basis.z.z).normalized()
	)
	var right_direction = (
		Vector3(camera.transform.basis.x.x, 0, camera.transform.basis.x.z).normalized()
	)

	if Input.is_action_pressed("move_forward"): # W键
		movement += forward_direction * -1
	if Input.is_action_pressed("move_backward"): # S键
		movement += forward_direction
	if Input.is_action_pressed("move_left"): # A键
		movement += right_direction * -1
	if Input.is_action_pressed("move_right"): # D键
		movement += right_direction

	# 应用水平移动
	if movement != Vector3.ZERO:
		camera.position += movement.normalized() * move_speed


func handle_height_movement(direction: int):
	"""处理高度移动（鼠标滚轮）
	
	direction: 1 = 向上滚轮（拉近），-1 = 向下滚轮（推远）
	"""
	# 🔧 减小缩放倍数：从 2.0 改为 0.8（更平滑）
	var height_change = direction * 0.8
	camera.position.y += height_change

	# 限制高度范围
	camera.position.y = clamp(camera.position.y, 1.0, 50.0)


func handle_camera_rotation(_delta: float):
	"""处理摄像机旋转 - 使用HOTKEY_CONFIG配置"""
	var rotation_speed = 60.0 * _delta # 每秒60度
	
	# 逆时针旋转（左转）
	if Input.is_key_pressed(HOTKEY_CONFIG.camera_rotate_left):
		camera.rotate_y(rotation_speed * PI / 180.0)
	
	# 顺时针旋转（右转）
	if Input.is_key_pressed(HOTKEY_CONFIG.camera_rotate_right):
		camera.rotate_y(-rotation_speed * PI / 180.0)


func handle_input(event: InputEvent):
	"""处理输入事件"""
	if event is InputEventMouseMotion:
		mouse_position = event.position
		update_world_position()
		
	elif event is InputEventMouseButton:
		handle_mouse_click(event)

		# 🔧 处理鼠标滚轮进行高度移动（俯视角缩放）
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			handle_height_movement(-1) # 向上滚轮 = 拉近视角（降低摄像机高度）
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			handle_height_movement(1) # 向下滚轮 = 推远视角（升高摄像机高度）

	elif event is InputEventKey and event.pressed:
		handle_key_input(event)
		handle_grid_input(event)


func update_world_position():
	"""更新世界坐标 - 智能射线投射版本，正确处理遮挡关系"""
	
	# 🔧 优化：如果没有建造模式，不需要更新高亮
	if current_build_mode == "none":
		return
	
	# 使用智能射线投射获取鼠标指向的3D位置
	var space_state = get_world_3d().direct_space_state
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * 1000

	# 创建射线查询参数
	var query = PhysicsRayQueryParameters3D.create(from, to)
	# 🔧 关键：只检测环境层（Layer 1），忽略角色和建筑
	query.collision_mask = 1 # 只检测第1层（环境/地块）
	
	# 对于挖掘模式，我们需要特殊处理遮挡关系
	if current_build_mode == "dig":
		var best_hit = _find_best_tile_hit(space_state, from, to)
		if best_hit:
			world_position = _snap_to_tile_center(best_hit.position)
			world_position.y = 0.0
			_update_selection_highlight()
		else:
			# 如果没有击中任何瓦片，尝试从地面投射
			world_position = _get_ground_projection()
			_update_selection_highlight()
	else:
		# 其他模式使用标准射线投射
		var result = space_state.intersect_ray(query)
		if result:
			var hit_position = result.position
			world_position = _snap_to_tile_center(hit_position)
			world_position.y = 0.0
			_update_selection_highlight()
			# 🔧 [建造预览] 更新建筑预览位置
			_update_building_preview()
		else:
			world_position = _get_ground_projection()
			_update_selection_highlight()
			# 🔧 [建造预览] 更新建筑预览位置
			_update_building_preview()


func handle_mouse_click(event: InputEventMouseButton):
	"""处理鼠标点击"""
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		handle_left_click()
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		handle_right_click()


func handle_left_click():
	"""处理左键点击 - 使用统一放置系统"""
	if not placement_system:
		LogManager.error("统一放置系统未初始化")
		return
	
	_handle_click_with_placement_system()


func handle_right_click():
	"""处理右键点击"""
	# 取消当前建造模式
	current_build_mode = "none"
	
	# 🔧 [建造预览] 取消预览
	if placement_system:
		placement_system.cancel_building_preview()
	
	LogManager.info("取消建造模式")
	# 🔧 清除高亮（确保立即隐藏）
	if selection_highlight:
		selection_highlight.hide_highlight()

func _handle_click_with_placement_system():
	"""使用统一放置系统处理点击"""
	var entity_id = _get_current_entity_id()
	if entity_id == "":
		LogManager.error("无法确定当前实体ID，建造模式: " + current_build_mode)
		return
	
	# 使用统一放置系统执行放置
	var result = placement_system.place_entity(entity_id, world_position)
	
	if result.success:
		LogManager.info("✅ " + result.message)
	else:
		LogManager.warning("放置失败: " + result.message + " 实体ID: " + entity_id + " 位置: " + str(world_position))


func _get_current_entity_id() -> String:
	"""获取当前实体ID"""
	match current_build_mode:
		"dig":
			return "dig"
		"summon_monster":
			# 根据选中的怪物数据返回对应的ID
			if not selected_monster_data.is_empty():
				var monster_name = selected_monster_data.get("name", "")
				return _map_monster_name_to_entity_id(monster_name)
			return "imp" # 默认返回imp
		"summon_logistics":
			# 根据选中的后勤单位返回ID - 使用MonstersTypes常量
			if not selected_logistics_data.is_empty():
				var logistics_type = selected_logistics_data.get("type", "worker")
				match logistics_type:
					"worker":
						return "goblin_worker"
					"engineer":
						return "goblin_engineer"
					_:
						return "goblin_worker"
			return "goblin_worker"
		"build":
			# 🔧 [API更新] 优先使用建筑数据中的 entity_id 字段
			if not selected_building_data.is_empty():
				# 如果建筑数据包含 entity_id，直接使用它
				if selected_building_data.has("entity_id"):
					return selected_building_data.entity_id
				
				# 回退方案：通过名称映射（兼容旧数据）
				var building_name = selected_building_data.get("name", "")
				return _map_building_name_to_entity_id(building_name)
			
			return "building_treasury" # 默认返回金库
		_:
			return ""

# ==================== 快捷键配置管理 ====================
# 统一管理所有快捷键，避免冲突
const HOTKEY_CONFIG = {
	# 游戏模式切换
	"dig": KEY_1, # 挖掘模式
	"building_ui": KEY_2, # 建筑面板（旧系统）
	
	# UI面板切换
	"monster_ui": KEY_3, # 怪物召唤UI
	"logistics_ui": KEY_4, # 后勤召唤UI
	"atlas_ui": KEY_B, # 角色图鉴
	"mining_ui": KEY_I, # 挖掘系统UI
	
	# 备用快捷键
	"build_alt": KEY_TAB, # 建筑面板（备用）
	"monster_alt": KEY_M, # 怪物召唤UI（备用）
	
	# 系统功能
	"debug": KEY_P, # 调试模式
	"log_level": KEY_L, # 日志级别切换
	"cancel": KEY_ESCAPE, # 取消/关闭
	
	# 摄像机控制
	"camera_rotate_left": KEY_Q, # 逆时针旋转
	"camera_rotate_right": KEY_E, # 顺时针旋转
	
	# 测试功能
	"test_highlight": KEY_H, # 测试高亮系统
	"save_map": KEY_F9, # 保存地图为场景（用于编辑器预览）
	
	# 地形高亮
	"terrain_display_toggle": KEY_V, # 地形显示切换（开启/清除）
}

func _on_building_selected(building_data: Dictionary):
	"""建筑选择回调函数"""
	# 设置建造模式
	current_build_mode = "build"
	
	# 存储选中的建筑数据
	selected_building_data = building_data
	
	# 🔧 [建造预览] 开始建筑预览
	if placement_system:
		# 获取建筑实体ID
		var entity_id = _get_building_entity_id_from_data(building_data)
		if entity_id != "":
			placement_system.start_building_preview(entity_id)
			LogManager.info("🔍 建造预览开始: %s (成本: %d金)" % [building_data.name, building_data.cost])
		else:
			LogManager.info("选择建筑: " + building_data.name + " (成本: " + str(building_data.cost) + "金)")
	else:
		LogManager.info("选择建筑: " + building_data.name + " 成本: " + str(building_data.cost) + "金")


func _get_building_entity_id_from_data(building_data: Dictionary) -> String:
	"""根据建筑数据获取实体ID
	
	🔧 [API更新] 优先使用 entity_id 字段，回退到名称映射
	"""
	# 如果建筑数据包含 entity_id，直接使用它
	if building_data.has("entity_id"):
		return building_data.entity_id
	
	# 回退方案：通过名称映射（兼容旧数据）
	var building_name = building_data.get("name", "")
	return _map_building_name_to_entity_id(building_name)


func _map_monster_name_to_entity_id(monster_name: String) -> String:
	"""怪物名称到实体ID的映射 - 使用MonstersTypes常量"""
	match monster_name:
		"小恶魔":
			return "imp"
		"兽人战士":
			return "orc_warrior"
		"石像鬼":
			return "gargoyle"
		"地狱犬":
			return "hellhound"
		"火蜥蜴":
			return "fire_lizard"
		"树人守护者":
			return "treant"
		"魅魔":
			return "succubus"
		"暗影领主":
			return "shadow_lord"
		"石魔像":
			return "stone_golem"
		"骨龙":
			return "bone_dragon"
		"暗影法师":
			return "shadow_mage"
		_:
			LogManager.warning("未知怪物名称: " + monster_name)
			return "imp" # 默认返回imp

func _map_building_name_to_entity_id(building_name: String) -> String:
	"""建筑名称到实体ID的映射（完整版本）
	
	🔧 [API更新] 包含所有15种建筑的映射
	"""
	match building_name:
		# 基础设施建筑
		"金库":
			return "building_treasury"
		"恶魔巢穴":
			return "building_demon_lair"
		"兽人巢穴":
			return "building_orc_lair"
		
		# 功能性建筑
		"训练室":
			return "building_training_room"
		"图书馆":
			return "building_library"
		"工坊":
			return "building_workshop"
		
		# 军事建筑
		"箭塔":
			return "building_arrow_tower"
		"奥术塔":
			return "building_arcane_tower"
		"防御工事":
			return "building_defense_works"
		"监狱":
			return "building_prison"
		"刑房":
			return "building_torture_chamber"
		
		# 魔法建筑
		"魔法祭坛":
			return "building_magic_altar"
		"暗影神殿":
			return "building_shadow_temple"
		"魔法研究院":
			return "building_magic_research_institute"
		
		_:
			return ""


func _update_building_preview():
	"""更新建筑预览位置
	
	🔧 [建造预览] 鼠标移动时实时更新预览位置和颜色
	"""
	if not placement_system or current_build_mode != "build":
		return
	
	# 获取当前建筑实体ID
	var entity_id = _get_current_entity_id()
	if entity_id == "" or not entity_id.begins_with("building_"):
		return
	
	# 更新预览位置（自动检查合法性并更新颜色）
	placement_system.update_building_preview(world_position, entity_id)


func handle_key_input(event: InputEventKey):
	"""统一处理所有键盘输入 - 使用HOTKEY_CONFIG配置"""
	# 忽略按键回响，避免一次按下被处理多次导致开关闪烁
	if event.echo:
		return
	
	var keycode = event.keycode
	
	# === 游戏模式切换 ===
	if keycode == HOTKEY_CONFIG.dig:
		current_build_mode = "dig"
		_update_selection_highlight()
	
	# === UI面板切换 ===
	elif keycode == HOTKEY_CONFIG.monster_ui or keycode == HOTKEY_CONFIG.monster_alt:
		if monster_ui:
			monster_ui.toggle_ui()
	
	elif keycode == HOTKEY_CONFIG.building_ui:
		if building_selection_ui:
			building_selection_ui.toggle_ui()
	
	elif keycode == HOTKEY_CONFIG.build_alt:
		if building_ui:
			building_ui.toggle_ui()
	
	elif keycode == HOTKEY_CONFIG.logistics_ui:
		if logistics_ui:
			logistics_ui.toggle_ui()
	
	elif keycode == HOTKEY_CONFIG.atlas_ui:
		if character_atlas_ui:
			character_atlas_ui.toggle_ui()
	
	elif keycode == HOTKEY_CONFIG.mining_ui:
		if mining_ui:
			mining_ui.toggle_ui()
	
	# === 系统功能 ===
	elif keycode == HOTKEY_CONFIG.debug:
		toggle_debug_mode()
	
	elif keycode == HOTKEY_CONFIG.log_level:
		toggle_log_level()
	
	elif keycode == HOTKEY_CONFIG.test_highlight:
		if selection_highlight and selection_highlight.has_method("test_highlight_system"):
			selection_highlight.test_highlight_system()
	
	elif keycode == HOTKEY_CONFIG.save_map:
		# 保存地图为场景文件
		if map_generator:
			map_generator.save_map_to_scene()
			LogManager.info("📁 地图保存完成，可在 scenes/GeneratedDungeon.tscn 中查看")
	
	# === 地形高亮控制 ===
	elif keycode == HOTKEY_CONFIG.terrain_display_toggle:
		toggle_terrain_display()
	
	elif keycode == HOTKEY_CONFIG.cancel:
		current_build_mode = "none"
		# 🔧 直接隐藏高亮
		if selection_highlight:
			selection_highlight.hide_highlight()
		_close_all_ui()

# ============================================================================
# 地形高亮控制功能
# ============================================================================

func toggle_terrain_display():
	"""切换地形显示状态"""
	# 使用 TerrainHighlightSystem 进行地形高亮
	LogManager.info("使用 TerrainHighlightSystem 进行地形高亮")
	
	# 尝试获取 TerrainHighlightSystem
	var terrain_highlight_system = get_node_or_null("MapGenerator/TerrainHighlightSystem")
	if terrain_highlight_system:
		terrain_display_enabled = !terrain_display_enabled
		
		if terrain_display_enabled:
			# 高亮所有地形类型
			terrain_highlight_system.highlight_all_terrain_types()
			LogManager.info("🎯 地形高亮已开启 (快捷键: V)")
			_show_terrain_highlight_status("开启")
		else:
			# 清除所有高亮
			terrain_highlight_system.clear_all_highlights()
			LogManager.info("🧹 地形高亮已清除 (快捷键: V)")
			_show_terrain_highlight_status("清除")
	else:
		LogManager.warning("无法获取 TerrainHighlightSystem")

func toggle_cavity_highlight():
	"""切换空洞高亮状态"""
	var terrain_highlight_system = get_node_or_null("MapGenerator/TerrainHighlightSystem")
	if terrain_highlight_system:
		# 高亮所有空洞边界
		terrain_highlight_system.highlight_all_cavity_boundaries()
		LogManager.info("🎯 空洞边界高亮已开启 (快捷键: B)")
	else:
		LogManager.warning("无法获取 TerrainHighlightSystem")

func toggle_terrain_highlight():
	"""切换地形区域高亮状态"""
	var terrain_highlight_system = get_node_or_null("MapGenerator/TerrainHighlightSystem")
	if terrain_highlight_system:
		# 高亮所有地形区域
		terrain_highlight_system.highlight_terrain_regions()
		LogManager.info("🎯 地形区域高亮已开启 (快捷键: T)")
	else:
		LogManager.warning("无法获取 TerrainHighlightSystem")

func _show_terrain_highlight_status(terrain_type: String):
	"""显示地形高亮状态提示"""
	var status_label = Label.new()
	status_label.text = "🎯 地形高亮: %s" % terrain_type
	status_label.position = Vector2(20, 50)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.modulate = Color.WHITE
	
	add_child(status_label)
	
	# 2秒后自动移除
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(func():
		if status_label and is_instance_valid(status_label):
			status_label.queue_free()
		if timer and is_instance_valid(timer):
			timer.queue_free()
	)
	add_child(timer)
	timer.start()


func toggle_bestiary():
	"""切换角色图鉴"""
	LogManager.info("切换角色图鉴")


func toggle_debug_mode():
	"""切换调试模式"""
	LogManager.info("切换调试模式")

func toggle_log_level():
	"""切换日志级别"""
	LogManager.toggle_debug_mode()


func pause_game():
	"""暂停游戏"""
	is_paused = true
	LogManager.info("游戏暂停")


func resume_game():
	"""恢复游戏"""
	is_paused = false
	LogManager.info("游戏恢复")


func spawn_test_characters():
	"""生成测试角色"""
	LogManager.info("生成测试角色...")

	# 生成一些英雄（入侵者）- 暂时注释，等待实现
	# character_manager.create_hero(Vector3(5, 0, 5), Hero.HeroType.KNIGHT)
	# character_manager.create_hero(Vector3(8, 0, 5), Hero.HeroType.ARCHER)
	# character_manager.create_hero(Vector3(11, 0, 5), Hero.HeroType.MAGE)
	# character_manager.create_hero(Vector3(14, 0, 5), Hero.HeroType.PALADIN)

	# 生成一些怪物（防御者）- 暂时注释，等待实现
	# character_manager.create_monster(Vector3(25, 0, 5), Monster.MonsterType.IMP)
	# character_manager.create_monster(Vector3(28, 0, 5), Monster.MonsterType.ORC_WARRIOR)
	# character_manager.create_monster(Vector3(31, 0, 5), Monster.MonsterType.GARGOYLE)
	# character_manager.create_monster(Vector3(34, 0, 5), Monster.MonsterType.HELLHOUND)
	# character_manager.create_monster(Vector3(37, 0, 5), Monster.MonsterType.SHADOW_MAGE)

	# 生成一些非战斗单位
	character_manager.create_goblin_worker(Vector3(20, 0, 20))
	character_manager.create_goblin_engineer(Vector3(22, 0, 22))

	LogManager.info("测试角色生成完成，总共 " + str(character_manager.get_stats().total_characters) + " 个角色")


func handle_grid_input(event: InputEventKey):
	"""处理网格相关输入"""
	if not grid_manager:
		return
	
	if event.keycode == KEY_G:
		grid_manager.toggle_grid()


func _unhandled_input(event: InputEvent) -> void:
	"""处理未处理的输入事件"""
	# 所有快捷键已统一在handle_key_input中管理
	pass


# UI回调函数 - 重复函数已删除，使用第620行的版本


func _on_monster_selected(monster_data: Dictionary):
	"""怪物选择回调"""
	LogManager.info("召唤怪物: " + str(monster_data.name) + " 成本: " + str(monster_data.cost))
	
	# 存储选择的怪物数据
	selected_monster_data = monster_data
	current_build_mode = "summon_monster"
	
	LogManager.info("已选择怪物: " + monster_data.name + " (类型: " + monster_data.get("type", "unknown") + ")")


func _on_logistics_selected(logistics_data: Dictionary):
	"""后勤选择回调"""
	LogManager.info("选择后勤单位: " + str(logistics_data.name))
	current_build_mode = "summon_logistics"
	
	# 存储选择的后勤数据，供summon_logistics函数使用
	selected_logistics_data = logistics_data
	
	# 更新选择高亮
	_update_selection_highlight()


func set_build_mode(mode: String):
	"""设置建造模式"""
	current_build_mode = mode
	
	# 🔧 [建造预览] 建造模式切换时处理预览
	if placement_system:
		if mode.begins_with("building_"):
			# 开始建筑预览
			placement_system.start_building_preview(mode)
		else:
			# 取消预览（切换到非建筑模式）
			placement_system.cancel_building_preview()
	
	_update_selection_highlight()


func _update_selection_highlight():
	"""更新选择高亮 - 使用统一放置系统"""
	if not selection_highlight:
		return
	
	# 根据建造模式决定是否显示高亮
	if current_build_mode == "none":
		selection_highlight.hide_highlight()
		return
	
	# 使用统一放置系统检查
	if not placement_system:
		LogManager.error("统一放置系统未初始化")
		selection_highlight.hide_highlight()
		return
	
	_update_highlight_with_placement_system()

func _update_highlight_with_placement_system():
	"""使用统一放置系统更新高亮"""
	var entity_id = _get_current_entity_id()
	if entity_id == "":
		selection_highlight.hide_highlight()
		return
	
	# 挖掘模式直接使用SelectionHighlightSystem的逻辑，避免双重计算
	if current_build_mode == "dig":
		selection_highlight.update_highlight(world_position, entity_id, current_build_mode)
		return
	
	# 其他模式使用统一放置系统检查是否可以放置
	var can_place_result = placement_system.can_place(entity_id, world_position)
	var can_place = can_place_result[0]
	var reason = can_place_result[1]
	
	# 根据检查结果设置高亮颜色
	var highlight_color = "green" # 默认绿色
	if not can_place:
		# 根据失败原因设置颜色
		if "地形" in reason:
			highlight_color = "red"
		elif "占用" in reason:
			highlight_color = "orange"
		elif "资源" in reason:
			highlight_color = "yellow"
		elif "距离" in reason:
			highlight_color = "purple"
		elif "空地已挖掘" in reason:
			highlight_color = "yellow"
		else:
			highlight_color = "red"
	
	# 更新高亮
	selection_highlight.update_highlight(world_position, entity_id, current_build_mode, highlight_color)


func _find_best_tile_hit(space_state, from: Vector3, to: Vector3):
	"""寻找最佳的瓦片击中点，考虑遮挡关系"""
	var query = PhysicsRayQueryParameters3D.create(from, to)
	# 🔧 只检测环境层
	query.collision_mask = 1
	
	# 首先尝试标准射线投射
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_position = result.position
		var snapped_pos = _snap_to_tile_center(hit_position)
		
		if tile_manager and tile_manager.get_tile_data(snapped_pos):
			return result
	
	# 如果标准射线投射失败，尝试多重射线投射
	return _try_multi_raycast(space_state, from, to)

func _try_multi_raycast(space_state, from: Vector3, to: Vector3):
	"""尝试多重射线投射，检测可能被遮挡的瓦片"""
	var directions = [
		(to - from).normalized(), # 原始方向
		Vector3(0, -1, 0), # 向下
		Vector3(0, 0, -1), # 向后
		Vector3(1, 0, 0), # 向右
		Vector3(-1, 0, 0), # 向左
		Vector3(0, 0, 1), # 向前
	]
	
	for direction in directions:
		var ray_end = from + direction * 1000
		var query = PhysicsRayQueryParameters3D.create(from, ray_end)
		# 🔧 只检测环境层
		query.collision_mask = 1
		var result = space_state.intersect_ray(query)
		
		if result:
			var hit_position = result.position
			var snapped_pos = _snap_to_tile_center(hit_position)
			
			if tile_manager and tile_manager.get_tile_data(snapped_pos):
				return result
	
	return null

func _get_ground_projection():
	"""从鼠标位置向地面投射，获取瓦片位置"""
	if not tile_manager:
		return Vector3.ZERO
	
	# 从摄像机位置向鼠标指向的地面投射
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * 1000
	
	# 创建一个虚拟的地面平面进行射线检测
	var ground_y = 0.0
	var ground_plane = Plane(Vector3.UP, ground_y)
	
	# 计算射线与地面平面的交点
	var ray_direction = (to - from).normalized()
	var intersection = ground_plane.intersects_ray(from, ray_direction)
	
	if intersection:
		var snapped_pos = _snap_to_tile_center(intersection)
		if tile_manager.get_tile_data(snapped_pos):
			return snapped_pos
	
	# 如果地面投射失败，尝试使用屏幕坐标直接计算
	return _get_screen_to_tile_projection()

func _get_screen_to_tile_projection():
	"""使用屏幕坐标直接计算瓦片位置"""
	if not tile_manager:
		return Vector3.ZERO
	
	var map_size = tile_manager.get_map_size()
	var tile_size = tile_manager.get_tile_size()
	
	# 将屏幕坐标转换为世界坐标（Y=0平面）
	var world_pos = camera.project_position(mouse_position, camera.position.y)
	
	# 🔧 修复：使用 floor() 对齐到格子左下角（与其他对齐方法保持一致）
	var snapped_x = floor(world_pos.x / tile_size.x) * tile_size.x
	var snapped_z = floor(world_pos.z / tile_size.z) * tile_size.z
	var snapped_y = 0.0
	
	snapped_x = clamp(snapped_x, 0, map_size.x - 1)
	snapped_z = clamp(snapped_z, 0, map_size.z - 1)
	
	return Vector3(snapped_x, snapped_y, snapped_z)

func _snap_to_tile_center(position: Vector3) -> Vector3:
	"""将位置对齐到格子左下角坐标（整数） - 与高亮系统保持一致
	
	注意：返回格子左下角坐标 (x, 0, z)，使用 floor() 确保稳定性
		  避免使用 round() 导致的边界跳跃问题
	"""
	if not tile_manager:
		return position
	
	var tile_size = tile_manager.get_tile_size()
	var map_size = tile_manager.get_map_size()
	
	# 🔧 修复：使用 floor() 而非 round()，对齐到格子左下角（整数坐标）
	# floor() 确保在格子内的任何位置都会返回同一个格子坐标
	# 这与 SelectionHighlightSystem._snap_to_tile_center() 保持一致
	var snapped_x = floor(position.x / tile_size.x) * tile_size.x
	var snapped_z = floor(position.z / tile_size.z) * tile_size.z
	
	var snapped_y = 0.0
	
	snapped_x = clamp(snapped_x, 0, map_size.x - 1)
	snapped_z = clamp(snapped_z, 0, map_size.z - 1)
	
	return Vector3(snapped_x, snapped_y, snapped_z)


func _show_monster_selection_ui():
	"""显示怪物选择UI"""
	if monster_ui:
		monster_ui.toggle_ui()
		LogManager.info("显示怪物选择UI")


func _show_worker_selection_ui():
	"""显示苦工选择UI"""
	if logistics_ui:
		logistics_ui.toggle_ui()
		LogManager.info("显示苦工选择UI")


func _close_all_ui():
	"""关闭所有UI"""
	if building_ui and building_ui.is_visible:
		building_ui.hide_ui()
	if monster_ui and monster_ui.is_visible:
		monster_ui.hide_ui()
	if logistics_ui and logistics_ui.is_visible:
		logistics_ui.hide_ui()
	if mining_ui and mining_ui.is_visible:
		mining_ui.hide_ui()
	
	# 🔧 [建造预览] 关闭UI时取消预览
	if placement_system:
		placement_system.cancel_building_preview()
	
	LogManager.info("关闭所有UI")
