extends UnifiedBuildingSystem
class_name UnifiedDungeonHeart

## 统一地牢之心建筑
## 使用自由组件系统管理地牢之心

# 预加载地牢之心配置
const DungeonHeartConfig = preload("res://scenes/buildings/dungeon_heart/DungeonHeartConfig.gd")
const DungeonHeartMaterialConfig = preload("res://scenes/buildings/dungeon_heart/materials/DungeonHeartMaterialConfig.gd")
const DungeonHeartTextures = preload("res://scenes/buildings/dungeon_heart/textures/DungeonHeartTextures.gd")

# 地牢之心专用属性
var mana_generation_rate: float = 10.0
var max_mana_capacity: int = 1000
var life_force: int = 100
var corruption_radius: float = 5.0

func _init():
	super._init()
	building_type = BuildingTypes.BuildingType.DUNGEON_HEART
	building_name = "地牢之心"
	building_description = "地牢的核心建筑，提供生命力和魔法能量"
	
	# 建筑属性
	health = 300
	max_health = 300
	armor = 10
	cost_gold = 1500
	
	# 资源存储属性
	gold_storage_capacity = 5000
	mana_storage_capacity = 2000
	stored_gold = 1000 # 初始金币
	stored_mana = 500 # 初始魔力
	
	# 建筑尺寸和主题
	building_size = Vector2(2, 2) # 2x2瓦块
	building_theme = "dungeon_heart"
	building_tier = 3
	building_category = "core"
	
	# 设置渲染模式为自由组件系统
	render_mode = RenderMode.TRADITIONAL
	allow_free_placement = true
	
	# 初始化自由组件
	_setup_dungeon_heart_components()

func _setup_dungeon_heart_components():
	"""设置地牢之心的自由组件"""
	LogManager.info("🏗️ [UnifiedDungeonHeart] 设置地牢之心自由组件")
	
	# 清空现有组件
	free_components.clear()
	
	# 添加地牢之心核心组件
	_add_heart_core_component()
	_add_energy_crystals()
	_add_mana_crystals()
	_add_magic_cores()
	_add_energy_conduits()
	_add_energy_nodes()
	_add_storage_core()
	_add_heart_entrance()
	_add_dungeon_stone_structure()
	
	# 更新边界框
	_update_bounds()
	
	LogManager.info("✅ [UnifiedDungeonHeart] 地牢之心自由组件设置完成 (组件数量: %d)" % free_components.size())

func _add_heart_core_component():
	"""添加地牢之心核心组件"""
	add_component(
		"Heart_Core",
		Vector3(1.0, 0.5, 1.0), # 🔧 修复：建筑中心位置 (2x2瓦块中心)
		Vector3(0.4, 0.4, 0.4), # 核心尺寸
		"decoration"
	)

func _add_energy_crystals():
	"""添加能量水晶组件"""
	var crystal_positions = [
		Vector3(0.2, 1.2, 0.2), # 🔧 修复：左上角，在2x2范围内
		Vector3(1.8, 1.2, 0.2), # 🔧 修复：右上角，在2x2范围内
		Vector3(0.2, 1.2, 1.8), # 🔧 修复：左下角，在2x2范围内
		Vector3(1.8, 1.2, 1.8) # 🔧 修复：右下角，在2x2范围内
	]
	
	for i in range(crystal_positions.size()):
		add_component(
			"Energy_Crystal_" + str(i + 1),
			crystal_positions[i],
			Vector3(0.2, 0.3, 0.2),
			"decoration"
		)

func _add_mana_crystals():
	"""添加魔力水晶组件"""
	var mana_positions = [
		Vector3(0.8, 1.6, 0.2),
		Vector3(0.8, 1.6, 1.4)
	]
	
	for i in range(mana_positions.size()):
		add_component(
			"Mana_Crystal_" + str(i + 1),
			mana_positions[i],
			Vector3(0.15, 0.25, 0.15),
			"decoration"
		)

func _add_magic_cores():
	"""添加魔法核心组件"""
	add_component(
		"Magic_Core",
		Vector3(0.8, 1.6, 0.8),
		Vector3(0.3, 0.3, 0.3),
		"decoration"
	)

func _add_energy_conduits():
	"""添加能量管道组件"""
	var conduit_positions = [
		Vector3(0.2, 1.6, 0.8),
		Vector3(1.4, 1.6, 0.8)
	]
	
	for i in range(conduit_positions.size()):
		add_component(
			"Energy_Conduit_" + str(i + 1),
			conduit_positions[i],
			Vector3(0.1, 0.2, 0.4),
			"decoration"
		)

func _add_energy_nodes():
	"""添加能量节点组件"""
	var node_positions = [
		Vector3(0.8, 0.8, 0.2),
		Vector3(0.2, 0.8, 0.8),
		Vector3(1.4, 0.8, 0.8),
		Vector3(0.8, 0.8, 1.4)
	]
	
	for i in range(node_positions.size()):
		add_component(
			"Energy_Node_" + str(i + 1),
			node_positions[i],
			Vector3(0.15, 0.15, 0.15),
			"decoration"
		)

func _add_storage_core():
	"""添加存储核心组件"""
	add_component(
		"Storage_Core",
		Vector3(0.8, 0.4, 0.8),
		Vector3(0.3, 0.2, 0.3),
		"decoration"
	)

func _add_heart_entrance():
	"""添加地牢之心入口组件"""
	add_component(
		"Heart_Entrance",
		Vector3(0.8, 0, 0.8),
		Vector3(0.4, 0.8, 0.1),
		"door"
	)

func _add_dungeon_stone_structure():
	"""添加地牢石结构组件"""
	# 底部石墙
	var stone_positions = [
		# 底部层
		Vector3(0, 0, 0), Vector3(0.8, 0, 0), Vector3(1.6, 0, 0),
		Vector3(0, 0, 0.8), Vector3(1.6, 0, 0.8),
		Vector3(0, 0, 1.6), Vector3(0.8, 0, 1.6), Vector3(1.6, 0, 1.6),
		# 中间层
		Vector3(0, 0.8, 0), Vector3(1.6, 0.8, 0),
		Vector3(0, 0.8, 1.6), Vector3(1.6, 0.8, 1.6),
		# 顶部层
		Vector3(0, 1.6, 0), Vector3(0.8, 1.6, 0), Vector3(1.6, 1.6, 0),
		Vector3(0, 1.6, 0.8), Vector3(1.6, 1.6, 0.8),
		Vector3(0, 1.6, 1.6), Vector3(0.8, 1.6, 1.6), Vector3(1.6, 1.6, 1.6)
	]
	
	for i in range(stone_positions.size()):
		add_component(
			"Dungeon_Stone_" + str(i + 1),
			stone_positions[i],
			Vector3(0.8, 0.8, 0.8),
			"structure"
		)

func _ready():
	"""初始化地牢之心"""
	super._ready()
	
	# 设置自由组件系统
	setup_free_components()
	
	# 设置地牢之心特效
	_setup_dungeon_heart_effects()
	
	# 🔧 调试坐标系统
	debug_coordinate_system()
	
	# 🔧 验证坐标系统一致性
	validate_coordinate_system()
	
	LogManager.info("✅ [UnifiedDungeonHeart] 地牢之心初始化完成")

func _setup_dungeon_heart_effects():
	"""设置地牢之心效果"""
	# 添加黑暗能量效果
	var dark_particles = GPUParticles3D.new()
	dark_particles.name = "DarkEnergy"
	dark_particles.emitting = true
	add_child(dark_particles)
	
	# 添加心跳音效
	var audio_player = AudioStreamPlayer3D.new()
	audio_player.name = "HeartbeatAudio"
	add_child(audio_player)
	
	# 添加腐蚀光环
	var corruption_area = Area3D.new()
	corruption_area.name = "CorruptionArea"
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = corruption_radius
	collision_shape.shape = sphere_shape
	corruption_area.add_child(collision_shape)
	add_child(corruption_area)

func generate_mana() -> float:
	"""生成魔法值"""
	var generated = mana_generation_rate * get_process_delta_time()
	# 这里应该更新实际的魔法值
	return generated

func consume_life_force(amount: float) -> bool:
	"""消耗生命力"""
	if life_force >= amount:
		life_force -= amount
		return true
	return false

func get_corruption_level() -> float:
	"""获取腐蚀等级"""
	return life_force / 100.0

func get_dungeon_heart_info() -> Dictionary:
	"""获取地牢之心信息"""
	var info = get_building_info()
	info["mana_generation_rate"] = mana_generation_rate
	info["max_mana_capacity"] = max_mana_capacity
	info["life_force"] = life_force
	info["corruption_radius"] = corruption_radius
	info["free_components_count"] = free_components.size()
	info["component_bounds"] = component_bounds
	return info
