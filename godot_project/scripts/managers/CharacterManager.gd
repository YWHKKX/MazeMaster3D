extends Node
class_name CharacterManager

## 角色管理器 - 负责管理所有角色的创建和查询
## 
## [已重构] 使用场景实例化和组系统

# 场景引用（延迟加载，避免循环依赖）
var GoblinWorkerScene = null
var GoblinEngineerScene = null
var ImpScene = null
var OrcWarriorScene = null

# 节点引用
var world: Node3D = null
var character_container: Node3D

# 管理器引用（通过 GameServices 访问）
var building_manager = null
var auto_assigner = null
var gold_mine_manager = null
var tile_manager = null

func _ready():
	_setup_world_reference()
	_setup_character_container()
	
	# 延迟加载场景
	GoblinWorkerScene = load("res://img/scenes/characters/GoblinWorker.tscn")
	GoblinEngineerScene = load("res://img/scenes/characters/GoblinEngineer.tscn")
	ImpScene = load("res://img/scenes/characters/Imp.tscn")
	OrcWarriorScene = load("res://img/scenes/characters/OrcWarrior.tscn")
	
	# 使用 GameServices 获取管理器
	call_deferred("_setup_manager_references")

func _setup_world_reference():
	"""获取 World 节点引用"""
	world = get_node_or_null("/root/Main/World")
	if not world:
		LogManager.error("CharacterManager - World 节点未找到")

func _setup_character_container():
	"""设置角色容器"""
	if not world:
		return
		
	if world.has_node("Characters"):
		character_container = world.get_node("Characters")
	else:
		character_container = Node3D.new()
		character_container.name = "Characters"
		world.add_child(character_container)

func _setup_manager_references():
	"""使用 GameServices 设置管理器引用"""
	building_manager = GameServices.building_manager
	auto_assigner = GameServices.auto_assigner
	gold_mine_manager = GameServices.gold_mine_manager
	tile_manager = GameServices.tile_manager

# ============================================================================
# 创建接口 - 使用场景实例化
# ============================================================================

func create_goblin_worker(pos: Vector3) -> GoblinWorker:
	var worker = GoblinWorkerScene.instantiate()
	character_container.add_child(worker)
	# 必须先 add_child 再设置 global_position
	worker.global_position = pos
	# [新架构] Worker 通过 GameServices 自动获取管理器引用
	return worker

func create_goblin_engineer(pos: Vector3) -> GoblinEngineer:
	var engineer = GoblinEngineerScene.instantiate()
	character_container.add_child(engineer)
	# 必须先 add_child 再设置 global_position
	engineer.global_position = pos
	# [新架构] Engineer 通过 GameServices 自动获取管理器引用
	return engineer

# ============================================================================
# 通用怪物创建方法 - 使用脚本实例化
# ============================================================================

func create_monster_by_type(monster_type: String, pos: Vector3) -> MonsterBase:
	"""根据类型创建怪物 - 优先使用场景文件，回退到脚本实例化"""
	var monster: MonsterBase = null
	
	match monster_type:
		MonstersTypes.IMP:
			if ImpScene:
				monster = ImpScene.instantiate()
			else:
				monster = Imp.new()
		MonstersTypes.ORC_WARRIOR:
			if OrcWarriorScene:
				monster = OrcWarriorScene.instantiate()
			else:
				monster = OrcWarrior.new()
		MonstersTypes.GARGOYLE:
			monster = Gargoyle.new()
		MonstersTypes.HELLHOUND:
			monster = Hellhound.new()
		MonstersTypes.FIRE_LIZARD:
			monster = FireLizard.new()
		MonstersTypes.TREANT:
			monster = Treant.new()
		MonstersTypes.SUCCUBUS:
			monster = Succubus.new()
		MonstersTypes.SHADOW_MAGE:
			monster = ShadowMage.new()
		MonstersTypes.SHADOW_LORD:
			monster = ShadowLord.new()
		MonstersTypes.STONE_GOLEM:
			monster = StoneGolem.new()
		MonstersTypes.BONE_DRAGON:
			monster = BoneDragon.new()
		_:
			LogManager.error("CharacterManager: 未知怪物类型: " + monster_type)
			return null
	
	if monster:
		character_container.add_child(monster)
		monster.global_position = pos
		LogManager.info("✅ 怪物创建成功: " + monster_type + " 位置: " + str(pos))
		return monster
	else:
		LogManager.error("❌ 怪物创建失败: " + monster_type)
		return null

# 便捷方法
func create_imp(pos: Vector3) -> Imp:
	return create_monster_by_type(MonstersTypes.IMP, pos) as Imp

func create_orc_warrior(pos: Vector3) -> OrcWarrior:
	return create_monster_by_type(MonstersTypes.ORC_WARRIOR, pos) as OrcWarrior

func create_gargoyle(pos: Vector3) -> Gargoyle:
	return create_monster_by_type(MonstersTypes.GARGOYLE, pos) as Gargoyle

func create_hellhound(pos: Vector3) -> Hellhound:
	return create_monster_by_type(MonstersTypes.HELLHOUND, pos) as Hellhound

func create_fire_lizard(pos: Vector3) -> FireLizard:
	return create_monster_by_type(MonstersTypes.FIRE_LIZARD, pos) as FireLizard

func create_treant(pos: Vector3) -> Treant:
	return create_monster_by_type(MonstersTypes.TREANT, pos) as Treant

func create_succubus(pos: Vector3) -> Succubus:
	return create_monster_by_type(MonstersTypes.SUCCUBUS, pos) as Succubus

func create_shadow_mage(pos: Vector3) -> ShadowMage:
	return create_monster_by_type(MonstersTypes.SHADOW_MAGE, pos) as ShadowMage

func create_shadow_lord(pos: Vector3) -> ShadowLord:
	return create_monster_by_type(MonstersTypes.SHADOW_LORD, pos) as ShadowLord

func create_stone_golem(pos: Vector3) -> StoneGolem:
	return create_monster_by_type(MonstersTypes.STONE_GOLEM, pos) as StoneGolem

func create_bone_dragon(pos: Vector3) -> BoneDragon:
	return create_monster_by_type(MonstersTypes.BONE_DRAGON, pos) as BoneDragon

# ============================================================================
# 查询接口 - 使用组系统
# ============================================================================

func get_all_characters() -> Array[Node]:
	var chars: Array[Node] = []
	chars.append_array(GameGroups.get_nodes(GameGroups.MONSTERS))
	chars.append_array(GameGroups.get_nodes(GameGroups.HEROES))
	return chars

func get_all_heroes() -> Array[Node]:
	return GameGroups.get_nodes(GameGroups.HEROES)

func get_all_monsters() -> Array[Node]:
	return GameGroups.get_nodes(GameGroups.MONSTERS)

func get_all_goblin_workers() -> Array[Node]:
	return GameGroups.get_nodes(GameGroups.GOBLIN_WORKERS)

func get_all_goblin_engineers() -> Array[Node]:
	return GameGroups.get_nodes(GameGroups.GOBLIN_ENGINEERS)

func get_alive_characters() -> Array[Node]:
	var alive: Array[Node] = []
	for char in get_all_characters():
		if char.has_method("is_alive") and char.is_alive():
			alive.append(char)
	return alive

func get_combat_units() -> Array[Node]:
	var combat: Array[Node] = []
	for char in get_all_characters():
		if char.get("is_combat_unit") == true:
			combat.append(char)
	return combat

func get_non_combat_units() -> Array[Node]:
	var non_combat: Array[Node] = []
	for char in get_all_characters():
		if char.get("is_combat_unit") == false:
			non_combat.append(char)
	return non_combat

func get_characters_in_range(center: Vector3, range_distance: float) -> Array[Node]:
	var in_range: Array[Node] = []
	for char in get_all_characters():
		if char.global_position.distance_to(center) <= range_distance:
			in_range.append(char)
	return in_range

func get_nearest_enemy(character: CharacterBase) -> CharacterBase:
	var enemies = get_enemies_of(character)
	if enemies.is_empty():
		return null
	
	var nearest: CharacterBase = null
	var min_dist = INF
	
	for enemy in enemies:
		var dist = character.global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy
	
	return nearest

func get_enemies_of(character: CharacterBase) -> Array[CharacterBase]:
	var enemies: Array[CharacterBase] = []
	var char_faction = character.get("faction")
	
	for other in get_all_characters():
		if other == character:
			continue
		if not other.has_method("is_alive") or not other.is_alive():
			continue
		
		var other_faction = other.get("faction")
		if char_faction != other_faction:
			enemies.append(other)
	
	return enemies

# ============================================================================
# 管理器设置（已移除 - 现在通过 GameServices 自动获取）
# ============================================================================

# ============================================================================
# 统计
# ============================================================================

func get_stats() -> Dictionary:
	var all_chars = get_all_characters()
	var alive_count = 0
	
	for char in all_chars:
		if char.has_method("is_alive") and char.is_alive():
			alive_count += 1
	
	return {
		"total_characters": all_chars.size(),
		"heroes_count": get_all_heroes().size(),
		"monsters_count": get_all_monsters().size(),
		"alive_count": alive_count,
		"dead_count": all_chars.size() - alive_count
	}

func clear_all_characters():
	"""清空所有角色"""
	LogManager.info("CharacterManager - 清空所有角色...")
	
	# 获取所有角色
	var all_chars = get_all_characters()
	
	# 销毁所有角色
	for char in all_chars:
		if char and is_instance_valid(char):
			char.queue_free()
	
	LogManager.info("CharacterManager - 所有角色已清空")
