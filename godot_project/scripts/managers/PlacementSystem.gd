extends Node
class_name PlacementSystem

# 统一放置系统 - 整合所有放置操作
# 参考 UNIFIED_PLACEMENT_INTEGRATION.md

# 导入必要的类
const CharacterManager = preload("res://scripts/managers/CharacterManager.gd")
const TileManager = preload("res://scripts/managers/TileManager.gd")
const ResourceManager = preload("res://scripts/managers/resource/ResourceManager.gd")
const BuildingManager = preload("res://scripts/managers/BuildingManager.gd")
const WorldConstants = preload("res://scripts/managers/WorldConstants.gd")

# 放置结果枚举
enum PlacementResult {
	SUCCESS,
	FAILED_TERRAIN,
	FAILED_OCCUPIED,
	FAILED_RESOURCES,
	FAILED_DISTANCE,
	FAILED_UNKNOWN
}

# 放置结果类
class PlacementResultInfo:
	var result: PlacementResult
	var message: String
	var success: bool
	
	func _init(res: PlacementResult, msg: String):
		result = res
		message = msg
		success = (res == PlacementResult.SUCCESS)

# 实体配置信息
class EntityConfig:
	var entity_id: String
	var cost: int
	var size: Vector2
	var can_place_on: Array[String] # 可以放置的地形类型
	var placement_type: String # "building", "monster", "logistics", "dig"
	
	func _init(id: String, c: int, s: Vector2, terrain: Array[String], p_type: String):
		entity_id = id
		cost = c
		size = s
		can_place_on = terrain
		placement_type = p_type

# 系统引用
var main_game: Node = null
var tile_manager: TileManager = null
var character_manager: CharacterManager = null
var resource_manager: ResourceManager = null
var building_manager: BuildingManager = null

# 🔧 [建造预览] 预览系统
var current_preview: BuildingPreview = null
var preview_enabled: bool = true

# 实体配置
var entity_configs: Dictionary = {}

func _ready():
	"""初始化统一放置系统"""
	_initialize_entity_configs()
	LogManager.info("统一放置系统已初始化")


# ===== 建筑预览系统 =====

func start_building_preview(entity_id: String) -> bool:
	"""开始建筑预览
	
	🔧 [建造预览] 在建造模式下显示虚化预览
	
	Args:
		entity_id: 实体ID（如 "building_training_room"）
	
	Returns:
		bool: 是否成功创建预览
	"""
	if not preview_enabled:
		return false
	
	# 取消现有预览
	cancel_building_preview()
	
	# 获取实体配置
	var config = entity_configs.get(entity_id)
	if not config or config.placement_type != "building":
		return false
	
	# 创建预览对象
	current_preview = BuildingPreview.new()
	
	# 获取建筑类型
	var building_type = _get_building_type_from_id(entity_id)
	if building_type == -1:
		current_preview.queue_free()
		current_preview = null
		return false
	
	# 设置预览参数
	current_preview.setup_preview(building_type, config.size)
	
	# 添加到场景树（跟随Main节点）
	if main_game:
		main_game.add_child(current_preview)
	
	LogManager.info("🔍 开始建筑预览: %s" % entity_id)
	return true


func update_building_preview(world_position: Vector3, entity_id: String = ""):
	"""更新建筑预览位置
	
	🔧 [建造预览] 跟随鼠标移动，实时检查位置合法性
	
	Args:
		world_position: 目标世界坐标（格子左下角）
		entity_id: 实体ID（用于验证）
	"""
	if not current_preview:
		return
	
	# 检查位置是否可建造
	var is_valid = false
	if entity_id != "":
		var check_result = can_place(entity_id, world_position)
		is_valid = check_result[0]
	
	# 🔧 [建筑渲染系统] 将格子左下角转换为格子中心
	# world_position 是格子左下角(x, 0, z)
	# 预览应该放在格子中心(x+0.5, 0.05, z+0.5)
	var preview_position = Vector3(
		world_position.x + 0.5,
		0.05,
		world_position.z + 0.5
	)
	
	# 更新预览
	current_preview.update_position(preview_position, is_valid)


func cancel_building_preview():
	"""取消建筑预览
	
	🔧 [建造预览] 退出建造模式时清理预览
	"""
	if current_preview:
		current_preview.destroy()
		current_preview = null
		LogManager.info("🚫 取消建筑预览")


func confirm_building_preview() -> bool:
	"""确认建造（将预览转为实体建筑）
	
	🔧 [建造预览] 玩家确认建造时调用
	
	Returns:
		bool: 是否成功确认
	"""
	if not current_preview:
		return false
	
	# 预览会在place_entity后自动清理
	return true

func _initialize_entity_configs():
	"""初始化实体配置"""
	# 挖掘配置 - 使用SelectionHighlightSystem逻辑，配置列表不再重要
	var empty_terrain: Array[String] = []
	entity_configs["dig"] = EntityConfig.new(
		"dig",
		0,
		Vector2(1, 1),
		empty_terrain, # 空列表，因为使用SelectionHighlightSystem逻辑
		"dig"
	)
	
	# 🏗️ 建筑配置 - 基于BuildingManager配置
	# 🔧 [修复] 添加 EMPTY（空地）和CORRIDOR到允许地形，因为地图默认为 EMPTY，通道也可以建造
	var allowed_terrain: Array[String] = ["STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR", "EMPTY", "CORRIDOR"]
	
	# 基础设施建筑
	entity_configs["building_treasury"] = EntityConfig.new("building_treasury", 100, Vector2(1, 1), allowed_terrain, "building")
	entity_configs["building_lair"] = EntityConfig.new("building_lair", 150, Vector2(1, 1), allowed_terrain, "building")
	entity_configs["building_demon_lair"] = EntityConfig.new("building_demon_lair", 200, Vector2(1, 1), allowed_terrain, "building")
	entity_configs["building_orc_lair"] = EntityConfig.new("building_orc_lair", 200, Vector2(1, 1), allowed_terrain, "building")
	
	# 功能性建筑
	entity_configs["building_training_room"] = EntityConfig.new("building_training_room", 200, Vector2(1, 1), allowed_terrain, "building")
	entity_configs["building_library"] = EntityConfig.new("building_library", 250, Vector2(1, 1), allowed_terrain, "building")
	entity_configs["building_workshop"] = EntityConfig.new("building_workshop", 300, Vector2(1, 1), allowed_terrain, "building")
	
	# 军事建筑
	entity_configs["building_arrow_tower"] = EntityConfig.new("building_arrow_tower", 200, Vector2(1, 1), allowed_terrain, "building")
	entity_configs["building_arcane_tower"] = EntityConfig.new("building_arcane_tower", 200, Vector2(1, 1), allowed_terrain, "building")
	entity_configs["building_defense_works"] = EntityConfig.new("building_defense_works", 180, Vector2(1, 1), allowed_terrain, "building")
	entity_configs["building_prison"] = EntityConfig.new("building_prison", 200, Vector2(1, 1), allowed_terrain, "building")
	entity_configs["building_torture_chamber"] = EntityConfig.new("building_torture_chamber", 400, Vector2(1, 1), allowed_terrain, "building")
	
	# 魔法建筑
	entity_configs["building_magic_altar"] = EntityConfig.new("building_magic_altar", 120, Vector2(1, 1), allowed_terrain, "building")
	entity_configs["building_shadow_temple"] = EntityConfig.new("building_shadow_temple", 800, Vector2(1, 1), allowed_terrain, "building")
	entity_configs["building_magic_research_institute"] = EntityConfig.new("building_magic_research_institute", 600, Vector2(1, 1), allowed_terrain, "building")
	
	# 怪物配置 - 使用CharacterTypes常量
	# 🔧 修复：添加CORRIDOR到允许地形，与建筑放置条件一致
	var monster_terrain: Array[String] = ["EMPTY", "STONE_FLOOR", "DIRT_FLOOR", "MAGIC_FLOOR", "CORRIDOR"]
	
	# 基础怪物
	entity_configs[MonstersTypes.IMP] = EntityConfig.new(
		MonstersTypes.IMP,
		100,
		Vector2(1, 1),
		monster_terrain,
		"monster"
	)
	
	entity_configs[MonstersTypes.ORC_WARRIOR] = EntityConfig.new(
		MonstersTypes.ORC_WARRIOR,
		120,
		Vector2(1, 1),
		monster_terrain,
		"monster"
	)
	
	entity_configs[MonstersTypes.GARGOYLE] = EntityConfig.new(
		MonstersTypes.GARGOYLE,
		150,
		Vector2(1, 1),
		monster_terrain,
		"monster"
	)
	
	entity_configs[MonstersTypes.HELLHOUND] = EntityConfig.new(
		MonstersTypes.HELLHOUND,
		150,
		Vector2(1, 1),
		monster_terrain,
		"monster"
	)
	
	entity_configs[MonstersTypes.FIRE_LIZARD] = EntityConfig.new(
		MonstersTypes.FIRE_LIZARD,
		200,
		Vector2(1, 1),
		monster_terrain,
		"monster"
	)
	
	entity_configs[MonstersTypes.TREANT] = EntityConfig.new(
		MonstersTypes.TREANT,
		200,
		Vector2(1, 1),
		monster_terrain,
		"monster"
	)
	
	entity_configs[MonstersTypes.SUCCUBUS] = EntityConfig.new(
		MonstersTypes.SUCCUBUS,
		200,
		Vector2(1, 1),
		monster_terrain,
		"monster"
	)
	
	entity_configs[MonstersTypes.SHADOW_MAGE] = EntityConfig.new(
		MonstersTypes.SHADOW_MAGE,
		150,
		Vector2(1, 1),
		monster_terrain,
		"monster"
	)
	
	entity_configs[MonstersTypes.SHADOW_LORD] = EntityConfig.new(
		MonstersTypes.SHADOW_LORD,
		400,
		Vector2(1, 1),
		monster_terrain,
		"monster"
	)
	
	entity_configs[MonstersTypes.STONE_GOLEM] = EntityConfig.new(
		MonstersTypes.STONE_GOLEM,
		400,
		Vector2(1, 1),
		monster_terrain,
		"monster"
	)
	
	entity_configs[MonstersTypes.BONE_DRAGON] = EntityConfig.new(
		MonstersTypes.BONE_DRAGON,
		600,
		Vector2(1, 1),
		monster_terrain,
		"monster"
	)
	
	# 后勤单位配置 - 使用CharacterTypes常量
	entity_configs[MonstersTypes.GOBLIN_WORKER] = EntityConfig.new(
		MonstersTypes.GOBLIN_WORKER,
		80,
		Vector2(1, 1),
		monster_terrain,
		"logistics"
	)
	
	entity_configs[MonstersTypes.GOBLIN_ENGINEER] = EntityConfig.new(
		MonstersTypes.GOBLIN_ENGINEER,
		100,
		Vector2(1, 1),
		monster_terrain,
		"logistics"
	)

func initialize_systems(main: Node, tile_mgr, char_mgr, res_mgr, building_mgr = null):
	"""初始化系统引用"""
	main_game = main
	tile_manager = tile_mgr
	character_manager = char_mgr
	resource_manager = res_mgr
	building_manager = building_mgr
	LogManager.info("统一放置系统引用已设置")

func can_place(entity_id: String, position: Vector3) -> Array:
	"""检查是否可以放置实体"""
	# 返回 [can_place: bool, reason: String]
	
	if not entity_id in entity_configs:
		return [false, "未知实体类型: " + entity_id]
	
	var config = entity_configs[entity_id]
	var tile_data = tile_manager.get_tile_data(position)
	
	if not tile_data:
		return [false, "无效位置"]
	
	# 检查地形类型 - 挖掘操作直接使用SelectionHighlightSystem逻辑
	if config.placement_type == "dig":
		# 挖掘操作：直接调用SelectionHighlightSystem的判断逻辑
		var highlight_system = get_node("/root/Main/SelectionHighlightSystem")
		if highlight_system and highlight_system.has_method("_compute_dig_highlight_state"):
			var highlight_state = highlight_system._compute_dig_highlight_state(position)
			match highlight_state:
				highlight_system.HighlightState.DIGGABLE:
					pass # 可挖掘，继续检查其他条件
				highlight_system.HighlightState.INVALID_RESOURCES:
					return [false, "空地已挖掘"]
				highlight_system.HighlightState.INVALID_TERRAIN:
					return [false, "地形不适合"]
				_:
					return [false, "未知状态"]
		else:
			LogManager.error("SelectionHighlightSystem未找到，无法进行挖掘判断")
			return [false, "系统错误"]
	else:
		# 其他操作：与 SelectionHighlightSystem 一致，优先按可行走判定
		if config.placement_type == "monster" or config.placement_type == "logistics" or config.placement_type == "building":
			if not tile_data.is_walkable:
				var tile_type_str_walk = _get_tile_type_string(tile_data.type)
				return [false, "地形不适合: " + tile_type_str_walk]
		else:
			# 其他类型仍使用配置的地形类型列表
			var tile_type_str = _get_tile_type_string(tile_data.type)
			if not tile_type_str in config.can_place_on:
				return [false, "地形不适合: " + tile_type_str]
	
	# 检查位置是否被占用
	if _is_position_occupied(position):
		return [false, "位置已被占用"]
	
	# 检查资源
	if not _has_sufficient_resources(config):
		return [false, "资源不足，需要: " + str(config.cost) + "金"]
	
	# 距离限制检查已移除，如需要可在此处添加
	
	return [true, "可以放置"]

func place_entity(entity_id: String, position: Vector3) -> PlacementResultInfo:
	"""放置实体"""
	var config = entity_configs.get(entity_id)
	if not config:
		return PlacementResultInfo.new(PlacementResult.FAILED_UNKNOWN, "未知实体类型: " + entity_id)
	
	# 预检查
	var can_place_result = can_place(entity_id, position)
	if not can_place_result[0]:
		var result_type = _determine_failure_type(can_place_result[1])
		return PlacementResultInfo.new(result_type, can_place_result[1])
	
	# 执行放置
	var success = false
	var message = ""
	
	match config.placement_type:
		"dig":
			success = _execute_dig(position)
			message = "挖掘" + ("成功" if success else "失败")
		"building":
			success = _execute_build(entity_id, position)
			message = "建造" + entity_id + ("成功" if success else "失败")
		"monster":
			success = _execute_summon_monster(entity_id, position)
			message = "召唤" + entity_id + ("成功" if success else "失败")
		"logistics":
			success = _execute_summon_logistics(entity_id, position)
			message = "召唤" + entity_id + ("成功" if success else "失败")
		_:
			return PlacementResultInfo.new(PlacementResult.FAILED_UNKNOWN, "未知放置类型: " + config.placement_type)
	
	if success:
		# 🔧 [新建造系统] 建筑放置时不扣除金币，由工程师在建造时提供
		# 只有非建筑类型（如召唤怪物）才扣除资源
		if config.placement_type != "building":
			_deduct_resources(config)
		else:
			LogManager.info("💰 建筑放置成功，金币将由工程师在建造时提供（成本: %d）" % config.cost)
		
		# 🔧 [建造预览] 建造成功后清理预览
		if config.placement_type == "building":
			cancel_building_preview()
		
		return PlacementResultInfo.new(PlacementResult.SUCCESS, message)
	else:
		return PlacementResultInfo.new(PlacementResult.FAILED_UNKNOWN, message)

func get_placement_info(entity_id: String) -> Dictionary:
	"""获取实体放置信息"""
	var config = entity_configs.get(entity_id)
	if config:
		return {
			"cost": config.cost,
			"size": config.size,
			"can_place_on": config.can_place_on,
			"placement_type": config.placement_type
		}
	return {}

func list_available_entities() -> Array:
	"""列出所有可用实体"""
	return entity_configs.keys()

# =============================================================================
# 私有辅助方法
# =============================================================================

func _get_tile_type_string(tile_type: int) -> String:
	"""将瓦片类型转换为字符串（仅用于非挖掘操作）"""
	match tile_type:
		TileTypes.TileType.EMPTY:
			return "EMPTY"
		TileTypes.TileType.STONE_FLOOR:
			return "STONE_FLOOR"
		TileTypes.TileType.STONE_WALL:
			return "STONE_WALL"
		TileTypes.TileType.DIRT_FLOOR:
			return "DIRT_FLOOR"
		TileTypes.TileType.MAGIC_FLOOR:
			return "MAGIC_FLOOR"
		TileTypes.TileType.UNEXCAVATED:
			return "UNEXCAVATED"
		TileTypes.TileType.GOLD_MINE:
			return "GOLD_MINE"
		TileTypes.TileType.MANA_CRYSTAL:
			return "MANA_CRYSTAL"
		TileTypes.TileType.CORRIDOR:
			return "CORRIDOR"
		TileTypes.TileType.LAVA:
			return "LAVA"
		TileTypes.TileType.WATER:
			return "WATER"
		TileTypes.TileType.BRIDGE:
			return "BRIDGE"
		TileTypes.TileType.PORTAL:
			return "PORTAL"
		TileTypes.TileType.TRAP:
			return "TRAP"
		TileTypes.TileType.SECRET_PASSAGE:
			return "SECRET_PASSAGE"
		TileTypes.TileType.DUNGEON_HEART:
			return "DUNGEON_HEART"
		TileTypes.TileType.BARRACKS:
			return "BARRACKS"
		TileTypes.TileType.WORKSHOP:
			return "WORKSHOP"
		TileTypes.TileType.MAGIC_LAB:
			return "MAGIC_LAB"
		TileTypes.TileType.DEFENSE_TOWER:
			return "DEFENSE_TOWER"
		TileTypes.TileType.FOOD_FARM:
			return "FOOD_FARM"
		TileTypes.TileType.FOREST:
			return "FOREST"
		TileTypes.TileType.WASTELAND:
			return "WASTELAND"
		TileTypes.TileType.SWAMP:
			return "SWAMP"
		TileTypes.TileType.CAVE:
			return "CAVE"
		TileTypes.TileType.CAVITY_EMPTY:
			return "CAVITY_EMPTY"
		TileTypes.TileType.CAVITY_BOUNDARY:
			return "CAVITY_BOUNDARY"
		TileTypes.TileType.CAVITY_CENTER:
			return "CAVITY_CENTER"
		TileTypes.TileType.CAVITY_ENTRANCE:
			return "CAVITY_ENTRANCE"
		_:
			return "UNKNOWN"

func _is_position_occupied(position: Vector3) -> bool:
	"""检查位置是否被占用"""
	# 检查是否有单位在该位置
	if character_manager:
		var characters = character_manager.get_all_characters()
		for character in characters:
			if character.position.distance_to(position) < 1.0:
				return true
	
	# 🔧 [修复] 检查是否有建筑在该位置
	if building_manager:
		var buildings = building_manager.get_all_buildings()
		for building in buildings:
			if not is_instance_valid(building):
				continue
			
			# 检查目标位置
			var target_tile = Vector2i(int(position.x), int(position.z))
			
			# 方案1：检查 tile_positions（DungeonHeart 2x2建筑使用）
			if "tile_positions" in building and building.tile_positions:
				for tile_pos in building.tile_positions:
					var tile_2d = Vector2i(int(tile_pos.x), int(tile_pos.z))
					if tile_2d == target_tile:
						return true
			
			# 方案2：检查 occupied_tiles（其他建筑可能使用）
			elif "occupied_tiles" in building and building.occupied_tiles:
				for tile in building.occupied_tiles:
					if tile == target_tile:
						return true
			
			# 方案3：使用 tile_x, tile_y（1x1建筑的后备方案）
			elif "tile_x" in building and "tile_y" in building:
				var building_tile = Vector2i(building.tile_x, building.tile_y)
				if building_tile == target_tile:
					return true
	
	return false

func _has_sufficient_resources(config: EntityConfig) -> bool:
	"""检查是否有足够资源"""
	if resource_manager:
		var gold_info = resource_manager.get_total_gold()
		return gold_info.available >= config.cost
	return true


func _determine_failure_type(reason: String) -> PlacementResult:
	"""根据失败原因确定失败类型"""
	if "地形" in reason:
		return PlacementResult.FAILED_TERRAIN
	elif "占用" in reason:
		return PlacementResult.FAILED_OCCUPIED
	elif "资源" in reason:
		return PlacementResult.FAILED_RESOURCES
	elif "距离" in reason:
		return PlacementResult.FAILED_DISTANCE
	else:
		return PlacementResult.FAILED_UNKNOWN

func _deduct_resources(config: EntityConfig):
	"""扣除资源（从地牢之心/金库中扣除）"""
	if resource_manager:
		var result = resource_manager.consume_gold(config.cost)
		if result.success:
			LogManager.info("✅ 资源扣除成功: %d 金币（来源: %s）" % [
				result.consumed,
				JSON.stringify(result.sources)
			])
		else:
			LogManager.warning("⚠️ 资源扣除失败: 需要 %d 金币，实际扣除 %d" % [
				config.cost, result.consumed
			])

# =============================================================================
# 具体执行方法
# =============================================================================

func _execute_dig(position: Vector3) -> bool:
	"""执行挖掘"""
	if tile_manager:
		var tile_data = tile_manager.get_tile_data(position)
		if tile_data and tile_data.is_diggable:
			if tile_data.type == TileTypes.TileType.UNEXCAVATED:
				tile_manager.set_tile_type(position, TileTypes.TileType.EMPTY)
				
				# 🔧 关键优化：先更新可达性，再重新烘焙导航网格
				# 1. 更新地块可达性（从地牢之心开始洪水填充）
				tile_manager.call_deferred("update_tile_reachability")
				
				# 2. 标记金矿可达性缓存为脏
				var gold_mine_manager = get_node_or_null("/root/Main/GoldMineManager")
				if gold_mine_manager:
					gold_mine_manager.mark_cache_dirty()
				
				# 3. 触发导航网格重新烘焙（已废弃 - 使用 GridPathFinder）
				# 🔧 [重构] NavigationManager 已废弃，GridPathFinder 自动更新网格
				# GridPathFinder 会通过 tile_manager 的信号自动更新寻路网格
				# 无需手动触发重新烘焙
				
				return true
	return false

func _execute_build(entity_id: String, position: Vector3) -> bool:
	"""执行建造"""
	if not building_manager:
		LogManager.error("PlacementSystem: 建筑管理器未初始化")
		return false
	
	# 根据entity_id确定建筑类型
	var building_type = _get_building_type_from_id(entity_id)
	if building_type == -1:
		LogManager.error("PlacementSystem: 未知建筑类型: " + entity_id)
		return false
	
	# 🔧 [建造系统] 放置建筑（PLANNING状态，需要工程师建造）
	var building = building_manager.place_building(building_type, position)
	if building:
		LogManager.info("✅ 建筑已放置（规划中）: " + entity_id + " at " + str(position))
		LogManager.info("   需要工程师建造，成本: %d 金币" % building.cost_gold)
		return true
	else:
		LogManager.error("❌ PlacementSystem: 建筑放置失败: " + entity_id)
		return false

func _get_building_type_from_id(entity_id: String) -> int:
	"""根据实体ID获取建筑类型"""
	match entity_id:
		# 基础设施建筑
		"building_treasury":
			return BuildingTypes.BuildingType.TREASURY
		"building_lair":
			return BuildingTypes.BuildingType.LAIR
		"building_demon_lair":
			return BuildingTypes.BuildingType.DEMON_LAIR
		"building_orc_lair":
			return BuildingTypes.BuildingType.ORC_LAIR
		
		# 功能性建筑
		"building_training_room":
			return BuildingTypes.BuildingType.TRAINING_ROOM
		"building_library":
			return BuildingTypes.BuildingType.LIBRARY
		"building_workshop":
			return BuildingTypes.BuildingType.WORKSHOP
		
		# 军事建筑
		"building_arrow_tower":
			return BuildingTypes.BuildingType.ARROW_TOWER
		"building_arcane_tower":
			return BuildingTypes.BuildingType.ARCANE_TOWER
		"building_defense_works":
			return BuildingTypes.BuildingType.DEFENSE_WORKS
		"building_prison":
			return BuildingTypes.BuildingType.PRISON
		"building_torture_chamber":
			return BuildingTypes.BuildingType.TORTURE_CHAMBER
		
		# 魔法建筑
		"building_magic_altar":
			return BuildingTypes.BuildingType.MAGIC_ALTAR
		"building_shadow_temple":
			return BuildingTypes.BuildingType.SHADOW_TEMPLE
		"building_magic_research_institute":
			return BuildingTypes.BuildingType.MAGIC_RESEARCH_INSTITUTE
		_:
			return -1

func _execute_summon_monster(entity_id: String, position: Vector3) -> bool:
	"""执行召唤怪物"""
	if not character_manager:
		LogManager.error("PlacementSystem: CharacterManager未初始化")
		return false
	
	# 调整Y坐标到地面表面（使用WorldConstants）
	var spawn_position = WorldConstants.get_character_spawn_position(position.x, position.z)
	
	# 根据entity_id直接调用对应的创建函数
	var character = null
	match entity_id:
		# 后勤单位（已实现）
		MonstersTypes.GOBLIN_WORKER:
			character = character_manager.create_goblin_worker(spawn_position)
		MonstersTypes.GOBLIN_ENGINEER:
			character = character_manager.create_goblin_engineer(spawn_position)
		
		# 怪物单位 - 使用CharacterManager的通用创建方法
		MonstersTypes.IMP:
			character = character_manager.create_imp(spawn_position)
		MonstersTypes.ORC_WARRIOR:
			character = character_manager.create_orc_warrior(spawn_position)
		MonstersTypes.GARGOYLE:
			character = character_manager.create_gargoyle(spawn_position)
		MonstersTypes.HELLHOUND:
			character = character_manager.create_hellhound(spawn_position)
		MonstersTypes.FIRE_LIZARD:
			character = character_manager.create_fire_lizard(spawn_position)
		MonstersTypes.TREANT:
			character = character_manager.create_treant(spawn_position)
		MonstersTypes.SUCCUBUS:
			character = character_manager.create_succubus(spawn_position)
		MonstersTypes.SHADOW_MAGE:
			character = character_manager.create_shadow_mage(spawn_position)
		MonstersTypes.SHADOW_LORD:
			character = character_manager.create_shadow_lord(spawn_position)
		MonstersTypes.STONE_GOLEM:
			character = character_manager.create_stone_golem(spawn_position)
		MonstersTypes.BONE_DRAGON:
			character = character_manager.create_bone_dragon(spawn_position)
		
		_:
			LogManager.error("PlacementSystem: 未知角色类型: " + entity_id)
			return false
	
	return character != null

func _execute_summon_logistics(entity_id: String, position: Vector3) -> bool:
	"""执行召唤后勤 - 复用怪物召唤逻辑"""
	return _execute_summon_monster(entity_id, position)
