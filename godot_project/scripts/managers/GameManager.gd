extends Node
# 游戏管理 - 负责协调各个游戏系统
# 这是游戏的核心管理器，协调所有子系统

# 子系统引 
var building_manager: Node
var character_manager: Node
var tile_manager: Node
var grid_manager: Node

# 游戏状 
var game_time: float = 0.0
var game_speed: float = 1.0
var is_initialized: bool = false


func _ready():
	LogManager.info("GameManager - 初始化开始")


func initialize():
	"""初始化游戏管理器"""
	if is_initialized:
		return

	# 初始化各个子系统
	initialize_managers()

	# 初始化输入映射（确保快捷键可用）
	_setup_input_actions()

	# 设置初始游戏状 
	setup_initial_state()

	is_initialized = true
	LogManager.info("GameManager - 初始化完成")


func initialize_managers():
	"""初始化各个管理器（使用 GameServices API）"""
	LogManager.info("子系统管理器初始化完成")

	# 使用 GameServices 获取管理器引用
	tile_manager = GameServices.tile_manager
	building_manager = GameServices.building_manager
	character_manager = GameServices.character_manager
	grid_manager = GameServices.grid_manager


func setup_initial_state():
	"""设置初始游戏状"""
	game_time = 0.0
	game_speed = 1.0

	# 设置初始资源
	setup_initial_resources()

	LogManager.info("初始游戏状态设置完成")


func setup_initial_resources():
	"""设置初始资源"""
	# 这里将设置游戏开始时的初始资 
	# resource_manager.set_gold(1000)
	# resource_manager.set_mana(500)
	# resource_manager.set_food(200)

	LogManager.info("初始资源设置完成")


func _setup_input_actions():
	"""设置输入映射，确保快捷键存在（可重复调用且幂等）"""
	var action := "ui_summon_monster"
	if not InputMap.has_action(action):
		InputMap.add_action(action)
		# 绑定数字 
		var ev4 := InputEventKey.new()
		ev4.physical_keycode = KEY_4
		InputMap.action_add_event(action, ev4)
		# 绑定备用 M
		var evm := InputEventKey.new()
		evm.physical_keycode = KEY_M
		InputMap.action_add_event(action, evm)


func update(_delta: float):
	"""更新游戏管理器"""
	if not is_initialized:
		return

	# 更新游戏时间
	game_time += _delta * game_speed

	# 更新各个子系 
	update_managers(_delta)

	# 处理游戏逻辑
	process_game_logic(_delta)


func update_managers(_delta: float):
	"""更新各个管理器"""
	# [新架构] 角色由场景树自动管理，不需要手动更新
	# 角色的 _process() 和 _physics_process() 会自动调用
	pass
func process_game_logic(_delta: float):
	"""处理游戏逻辑"""
	# 处理资源生成
	process_resource_generation(_delta)

	# 处理建筑生产
	process_building_production(_delta)

	# 处理角色AI
	process_character_ai(_delta)

	# 处理战斗系统
	process_combat_system(_delta)


func process_resource_generation(_delta: float):
	"""处理资源生成"""
	# 这里将处理各种资源的自动生成
func process_building_production(_delta: float):
	"""处理建筑生产"""
	# 这里将处理建筑的生产逻辑
func process_character_ai(_delta: float):
	"""处理角色AI"""
	# 这里将处理所有角色的AI逻辑
func process_combat_system(_delta: float):
	"""处理战斗系统"""
	# 这里将处理战斗相关的逻辑
func set_game_speed(speed: float):
	"""设置游戏速度"""
	game_speed = clamp(speed, 0.1, 5.0)
	LogManager.info("游戏速度设置  " + " " + str(game_speed))


func get_game_time() -> float:
	"""获取游戏时间"""
	return game_time


func get_game_speed() -> float:
	"""获取游戏速度"""
	return game_speed


func save_game():
	"""保存游戏"""
	LogManager.info("保存游戏")


func load_game():
	"""加载游戏"""
	LogManager.info("加载游戏")


func reset_game():
	"""重置游戏"""
	is_initialized = false
	game_time = 0.0
	game_speed = 1.0
	LogManager.info("游戏重置")
