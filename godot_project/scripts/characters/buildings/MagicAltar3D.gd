extends Building3D
class_name MagicAltar3D

## 🏗️ 魔法祭坛3D - 3x3x3魔力生成建筑
## 基于Building3D，实现魔法祭坛的3x3x3渲染

# 魔力生成系统
var mana_generation_rate: float = 0.5  # 每秒生成0.5法力


func _init():
	"""初始化魔法祭坛3D"""
	super._init()
	
	# 基础属性
	building_name = "魔法祭坛"
	building_type = BuildingTypes.MAGIC_ALTAR
	max_health = 300
	health = max_health
	armor = 4
	building_size = Vector2(1, 1)  # 保持原有尺寸用于碰撞检测
	cost_gold = 120
	engineer_cost = 60
	build_time = 160.0
	engineer_required = 1
	status = BuildingStatus.PLANNING
	
	# 3D配置
	_setup_3d_config()


func _setup_3d_config():
	"""设置3D配置"""
	# 基础配置
	building_3d_config.set_basic_config(building_name, building_type, Vector3(3, 3, 3))
	
	# 结构配置
	building_3d_config.set_structure_config(
		windows = false,   # 无窗户（祭坛结构）
		door = false,      # 无门（开放结构）
		roof = false,      # 无屋顶（开放天空）
		decorations = true # 有装饰
	)
	
	# 材质配置（神秘紫色风格）
	building_3d_config.set_material_config(
		wall = Color(0.4, 0.2, 0.6),    # 紫色墙体
		roof = Color(0.3, 0.1, 0.4),    # 深紫色
		floor = Color(0.2, 0.1, 0.3)     # 暗紫色地板
	)
	
	# 特殊功能配置
	building_3d_config.set_special_config(
		lighting = true,    # 有光照
		particles = true,   # 有粒子特效
		animations = true,  # 有动画
		sound = false       # 暂时无音效
	)


func _get_building_template() -> BuildingTemplate:
	"""获取魔法祭坛建筑模板"""
	var template = BuildingTemplate.new("魔法祭坛")
	template.building_type = BuildingTypes.MAGIC_ALTAR
	template.description = "神秘的3x3x3魔法祭坛，散发着魔力能量"
	
	# 创建魔法结构
	template.create_magic_structure(BuildingTypes.MAGIC_ALTAR)
	
	# 自定义祭坛元素
	# 顶层：魔法符文和祭坛
	template.set_component(0, 2, 0, BuildingComponents.ID_ENERGY_RUNE)
	template.set_component(1, 2, 0, BuildingComponents.ID_MAGIC_ALTAR)
	template.set_component(2, 2, 0, BuildingComponents.ID_ENERGY_RUNE)
	template.set_component(0, 2, 1, BuildingComponents.ID_ENERGY_RUNE)
	template.set_component(1, 2, 1, BuildingComponents.ID_MANA_POOL)
	template.set_component(2, 2, 1, BuildingComponents.ID_ENERGY_RUNE)
	template.set_component(0, 2, 2, BuildingComponents.ID_ENERGY_RUNE)
	template.set_component(1, 2, 2, BuildingComponents.ID_MAGIC_ALTAR)
	template.set_component(2, 2, 2, BuildingComponents.ID_ENERGY_RUNE)
	
	# 中层：石柱和祭坛台
	template.set_component(0, 1, 0, BuildingComponents.ID_PILLAR_STONE)
	template.set_component(1, 1, 0, BuildingComponents.ID_PILLAR_STONE)
	template.set_component(2, 1, 0, BuildingComponents.ID_PILLAR_STONE)
	template.set_component(0, 1, 1, BuildingComponents.ID_PILLAR_STONE)
	template.set_component(1, 1, 1, BuildingComponents.ID_MAGIC_ALTAR)
	template.set_component(2, 1, 1, BuildingComponents.ID_PILLAR_STONE)
	template.set_component(0, 1, 2, BuildingComponents.ID_PILLAR_STONE)
	template.set_component(1, 1, 2, BuildingComponents.ID_PILLAR_STONE)
	template.set_component(2, 1, 2, BuildingComponents.ID_PILLAR_STONE)
	
	# 底层：石基
	template.set_component(0, 0, 0, BuildingComponents.ID_FLOOR_STONE)
	template.set_component(1, 0, 0, BuildingComponents.ID_FLOOR_STONE)
	template.set_component(2, 0, 0, BuildingComponents.ID_FLOOR_STONE)
	template.set_component(0, 0, 1, BuildingComponents.ID_FLOOR_STONE)
	template.set_component(1, 0, 1, BuildingComponents.ID_FLOOR_STONE)
	template.set_component(2, 0, 1, BuildingComponents.ID_FLOOR_STONE)
	template.set_component(0, 0, 2, BuildingComponents.ID_FLOOR_STONE)
	template.set_component(1, 0, 2, BuildingComponents.ID_FLOOR_STONE)
	template.set_component(2, 0, 2, BuildingComponents.ID_FLOOR_STONE)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取魔法祭坛建筑配置"""
	var config = BuildingConfig.new()
	config.name = building_name
	config.width = 3
	config.depth = 3
	config.height = 3
	
	# 结构配置
	config.has_windows = false
	config.has_door = false
	config.has_roof = false
	config.has_decorations = true
	config.has_tower = false
	config.has_balcony = false
	
	# 材质配置
	config.wall_color = Color(0.4, 0.2, 0.6)  # 紫色
	config.roof_color = Color(0.3, 0.1, 0.4)    # 深紫色
	config.floor_color = Color(0.2, 0.1, 0.3)   # 暗紫色
	config.window_color = Color.LIGHT_BLUE       # 不使用窗户
	config.door_color = Color.DARK_GRAY          # 不使用门
	
	return config


func _load_building_specific_components():
	"""加载魔法祭坛特定构件"""
	# 加载魔法构件
	_add_component_to_library("Magic_Altar", BuildingComponents.ID_MAGIC_ALTAR)
	_add_component_to_library("Mana_Pool", BuildingComponents.ID_MANA_POOL)
	_add_component_to_library("Energy_Rune", BuildingComponents.ID_ENERGY_RUNE)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("🔮 [MagicAltar3D] 魔法祭坛3D准备就绪")
	
	# 启动魔法特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("🔮 [MagicAltar3D] 魔法祭坛3D建造完成")
	
	# 启动魔力生成系统
	_start_mana_generation()
	
	# 启动魔法动画
	if construction_animator:
		construction_animator.play_function_animation("mana_flow")


func _start_mana_generation():
	"""启动魔力生成系统"""
	# 设置魔力生成定时器
	var mana_timer = Timer.new()
	mana_timer.name = "ManaGenerationTimer"
	mana_timer.wait_time = 1.0  # 每秒生成一次
	mana_timer.timeout.connect(_generate_mana)
	mana_timer.autostart = true
	add_child(mana_timer)


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑"""
	# 调用父类方法
	super._update_3d_building_logic(delta)
	
	# 更新魔力生成系统
	_update_mana_generation(delta)
	
	# 更新魔法特效
	_update_magic_effects(delta)


func _update_mana_generation(delta: float):
	"""更新魔力生成系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 更新魔力生成进度
	_update_mana_generation_progress(delta)


func _update_mana_generation_progress(delta: float):
	"""更新魔力生成进度"""
	# 这里可以添加魔力生成的视觉进度指示
	pass


func _generate_mana():
	"""生成魔力"""
	if resource_manager:
		var mana_generated = mana_generation_rate
		resource_manager.add_mana(int(mana_generated))
		
		# 播放魔力生成特效
		_play_mana_generation_effect()


func _play_mana_generation_effect():
	"""播放魔力生成特效"""
	if not effect_manager:
		return
	
	# 创建魔力生成粒子效果
	effect_manager._create_particle_effect("mana_generation", global_position + Vector3(0, 2, 0), 1.5)


func _update_magic_effects(delta: float):
	"""更新魔法特效"""
	# 更新魔力流动效果
	_update_mana_flow(delta)
	
	# 更新符文发光
	_update_rune_glow(delta)


func _update_mana_flow(delta: float):
	"""更新魔力流动效果"""
	# 魔力流动动画
	if construction_animator:
		construction_animator.play_function_animation("mana_flow")
	
	# 根据魔力生成速率调整流动速度
	var flow_intensity = mana_generation_rate * 2.0
	
	if effect_manager and effect_manager.particle_systems.has("mana_particles"):
		var ps = effect_manager.particle_systems["mana_particles"]
		if ps and ps.emitting:
			# 调整粒子强度
			ps.amount = int(5 + flow_intensity * 10)


func _update_rune_glow(delta: float):
	"""更新符文发光"""
	# 符文发光动画
	if construction_animator:
		construction_animator.play_function_animation("rune_glow")
	
	# 根据魔力生成调整发光强度
	var glow_intensity = 0.5 + mana_generation_rate * 0.5
	
	if effect_manager and effect_manager.light_systems.has("rune_light"):
		var light = effect_manager.light_systems["rune_light"]
		if light and light.visible:
			light.light_energy = glow_intensity + sin(Time.get_time_dict_from_system()["second"] * 3) * 0.2


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新魔法祭坛特定特效
	_update_magic_altar_effects(delta)


func _update_magic_altar_effects(delta: float):
	"""更新魔法祭坛特效"""
	# 魔力脉冲效果
	var pulse_frequency = 1.5 + sin(Time.get_time_dict_from_system()["second"] * 1.5) * 0.3
	
	if effect_manager and effect_manager.light_systems.has("altar_glow"):
		var light = effect_manager.light_systems["altar_glow"]
		if light and light.visible:
			# 魔力脉冲
			light.light_energy = 0.8 + sin(Time.get_time_dict_from_system()["second"] * pulse_frequency) * 0.4
			light.light_color = Color(0.8, 0.4, 1.0)  # 紫色光


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加魔法祭坛特定信息
	base_info["mana_generation_rate"] = mana_generation_rate
	base_info["is_generating_mana"] = status == BuildingStatus.COMPLETED
	base_info["mana_per_second"] = mana_generation_rate
	
	return base_info


func _on_destroyed():
	"""建筑被摧毁时的回调（重写父类方法）"""
	# 调用父类方法
	super._on_destroyed()
	
	# 停止所有特效
	if effect_manager:
		effect_manager.stop_functional_effects()
	
	# 停止所有动画
	if construction_animator:
		construction_animator.stop_all_animations()
	
	LogManager.info("💀 [MagicAltar3D] 魔法祭坛被摧毁，所有特效已停止")
