extends UnifiedBuildingSystem
class_name UnifiedBarracks

## 🏰 统一兵营建筑
## 使用自由组件系统的兵营实现，2x2瓦块建筑

# 预加载兵营配置
const BarracksConfig = preload("res://scenes/buildings/barracks/BarracksConfig.gd")

# 兵营专用属性
var training_capacity: int = 10
var morale_bonus: float = 1.2
var training_speed_multiplier: float = 1.5

func _init():
	"""初始化兵营"""
	super._init()
	
	# 基础属性
	building_type = BuildingTypes.BuildingType.BARRACKS
	building_name = "兵营"
	building_description = "训练士兵，提升战斗能力"
	
	# 建筑属性
	max_health = 250
	health = 250
	armor = 4
	cost_gold = 400
	
	# 建筑尺寸和主题
	building_size = Vector2(2, 2) # 2x2瓦块
	building_theme = "barracks"
	building_tier = 2
	building_category = "military"
	
	# 兵营专用属性
	training_capacity = 10
	morale_bonus = 1.2
	
	# 设置渲染模式为自由组件系统
	render_mode = RenderMode.TRADITIONAL
	allow_free_placement = true
	
	# 初始化自由组件
	_setup_barracks_components()

func _setup_barracks_components():
	"""设置兵营的自由组件"""
	LogManager.info("🏰 [UnifiedBarracks] 设置兵营自由组件")
	
	# 清空现有组件
	free_components.clear()
	
	# 添加兵营核心组件
	_add_barracks_structure()
	_add_training_ground()
	_add_weapon_racks()
	_add_military_flags()
	_add_campfire()
	_add_armor_stands()
	_add_barracks_bunks()
	_add_shield_racks()
	
	# 更新边界框
	_update_bounds()
	
	LogManager.info("✅ [UnifiedBarracks] 兵营自由组件设置完成 (组件数量: %d)" % free_components.size())

func _add_barracks_structure():
	"""添加兵营主体结构"""
	# 主建筑体
	add_component(
		"Barracks_Main",
		Vector3(0.5, 0, 0.5),
		Vector3(1.0, 1.5, 1.0),
		"structure"
	)
	
	# 屋顶
	add_component(
		"Barracks_Roof",
		Vector3(0.3, 1.5, 0.3),
		Vector3(1.4, 0.1, 1.4),
		"structure"
	)

func _add_training_ground():
	"""添加训练场地组件"""
	# 训练场地
	add_component(
		"Training_Ground",
		Vector3(0.2, 0.05, 0.2),
		Vector3(1.6, 0.1, 1.6),
		"floor"
	)
	
	# 训练桩
	add_component(
		"Training_Post_1",
		Vector3(0.3, 0.1, 0.3),
		Vector3(0.1, 0.8, 0.1),
		"decoration"
	)
	
	add_component(
		"Training_Post_2",
		Vector3(1.3, 0.1, 0.3),
		Vector3(0.1, 0.8, 0.1),
		"decoration"
	)
	
	add_component(
		"Training_Post_3",
		Vector3(0.3, 0.1, 1.3),
		Vector3(0.1, 0.8, 0.1),
		"decoration"
	)
	
	add_component(
		"Training_Post_4",
		Vector3(1.3, 0.1, 1.3),
		Vector3(0.1, 0.8, 0.1),
		"decoration"
	)

func _add_weapon_racks():
	"""添加武器架组件"""
	# 武器架1
	add_component(
		"Weapon_Rack_1",
		Vector3(0.1, 0.1, 0.8),
		Vector3(0.1, 0.6, 0.1),
		"decoration"
	)
	
	# 武器架2
	add_component(
		"Weapon_Rack_2",
		Vector3(1.7, 0.1, 0.8),
		Vector3(0.1, 0.6, 0.1),
		"decoration"
	)

func _add_military_flags():
	"""添加军旗组件"""
	# 军旗1
	add_component(
		"Military_Flag_1",
		Vector3(0.8, 0.1, 0.1),
		Vector3(0.1, 0.8, 0.1),
		"decoration"
	)
	
	# 军旗2
	add_component(
		"Military_Flag_2",
		Vector3(0.8, 0.1, 1.7),
		Vector3(0.1, 0.8, 0.1),
		"decoration"
	)

func _add_campfire():
	"""添加营火组件"""
	add_component(
		"Campfire",
		Vector3(0.8, 0.05, 0.8),
		Vector3(0.4, 0.3, 0.4),
		"decoration"
	)

func _add_armor_stands():
	"""添加盔甲架组件"""
	# 盔甲架1
	add_component(
		"Armor_Stand_1",
		Vector3(0.2, 0.1, 0.2),
		Vector3(0.2, 0.7, 0.2),
		"decoration"
	)
	
	# 盔甲架2
	add_component(
		"Armor_Stand_2",
		Vector3(1.4, 0.1, 0.2),
		Vector3(0.2, 0.7, 0.2),
		"decoration"
	)

func _add_barracks_bunks():
	"""添加兵营床铺组件"""
	# 床铺1
	add_component(
		"Barracks_Bunk_1",
		Vector3(0.2, 0.1, 1.4),
		Vector3(0.6, 0.2, 0.3),
		"decoration"
	)
	
	# 床铺2
	add_component(
		"Barracks_Bunk_2",
		Vector3(1.0, 0.1, 1.4),
		Vector3(0.6, 0.2, 0.3),
		"decoration"
	)

func _add_shield_racks():
	"""添加盾牌架组件"""
	# 盾牌架1
	add_component(
		"Shield_Rack_1",
		Vector3(0.1, 0.1, 0.4),
		Vector3(0.1, 0.5, 0.1),
		"decoration"
	)
	
	# 盾牌架2
	add_component(
		"Shield_Rack_2",
		Vector3(1.7, 0.1, 0.4),
		Vector3(0.1, 0.5, 0.1),
		"decoration"
	)

func _ready():
	"""初始化兵营"""
	super._ready()
	
	# 设置自由组件系统
	setup_free_components()
	
	# 设置兵营特效
	_setup_barracks_effects()
	
	LogManager.info("✅ [UnifiedBarracks] 兵营初始化完成")

func _setup_barracks_effects():
	"""设置兵营特效"""
	# 添加营火光源
	var fire_light = OmniLight3D.new()
	fire_light.name = "FireLight"
	fire_light.light_energy = 1.5
	fire_light.light_color = Color(1.0, 0.5, 0.0) # 橙色火光
	fire_light.omni_range = 3.0
	fire_light.position = Vector3(1.0, 0.2, 1.0)
	add_child(fire_light)
	
	# 添加训练粒子效果
	var training_particles = GPUParticles3D.new()
	training_particles.name = "TrainingParticles"
	training_particles.emitting = true
	training_particles.position = Vector3(1.0, 0.5, 1.0)
	add_child(training_particles)

func _process(delta: float):
	"""每帧更新"""
	
	# 更新营火效果
	_update_campfire_effects(delta)

func _update_campfire_effects(delta: float):
	"""更新营火效果"""
	# 更新营火闪烁
	var fire_intensity = 1.0 + sin(Time.get_time_dict_from_system()["second"] * 6) * 0.3
	
	# 更新光源强度
	var fire_light = get_node_or_null("FireLight")
	if fire_light:
		fire_light.light_energy = 1.2 + fire_intensity * 0.3

func start_training(character):
	"""开始训练角色"""
	if character and character.has_method("apply_training_boost"):
		character.apply_training_boost(training_speed_multiplier)
		LogManager.info("🏋️ [UnifiedBarracks] 开始训练角色: %s" % character.name)

func stop_training(character):
	"""停止训练角色"""
	if character and character.has_method("remove_training_boost"):
		character.remove_training_boost()
		LogManager.info("🏋️ [UnifiedBarracks] 停止训练角色: %s" % character.name)

func get_training_capacity() -> int:
	"""获取训练容量"""
	return training_capacity

func get_morale_bonus() -> float:
	"""获取士气加成"""
	return morale_bonus

func get_barracks_info() -> Dictionary:
	"""获取兵营信息"""
	var info = get_building_info()
	info["training_capacity"] = training_capacity
	info["morale_bonus"] = morale_bonus
	info["training_speed_multiplier"] = training_speed_multiplier
	info["free_components_count"] = free_components.size()
	info["component_bounds"] = component_bounds
	return info

func _load_building_specific_components():
	"""加载兵营专用构件"""
	# 使用兵营配置加载组件
	var config = BarracksConfig.get_all_components()
	
	for component_name in config:
		var component_config = config[component_name]
		var component_id = component_config.get("id", 0)
		
		# 加载组件到库
		_add_component_to_library(component_name, component_id)

func _get_building_template() -> Dictionary:
	"""获取训练室3x3x3模板"""
	return BuildingTemplateGenerator.generate_barracks_template()

func _setup_building_effects():
	"""设置建筑特效"""
	super._setup_building_effects()
	_setup_training_effects()

func _setup_training_effects():
	"""设置训练效果"""
	# 添加训练音效
	var audio_player = AudioStreamPlayer3D.new()
	audio_player.name = "TrainingAudio"
	add_child(audio_player)
	
	# 添加训练粒子效果
	var particles = GPUParticles3D.new()
	particles.name = "TrainingParticles"
	particles.emitting = true
	add_child(particles)
