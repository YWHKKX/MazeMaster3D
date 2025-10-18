extends Building3D
class_name ShadowTemple3D

## 🏗️ 暗影神殿3D - 3x3x3高级暗影魔法建筑
## 基于Building3D，实现暗影神殿的3x3x3渲染

# 暗影魔法系统
var shadow_mana_generation_rate: float = 1.0 # 暗影魔力生成速度（每秒）
var shadow_power_multiplier: float = 2.0 # 暗影法术威力倍率（200%）
var shadow_stealth_bonus: float = 0.5 # 暗影隐身加成（50%）
var shadow_ritual_slots: int = 3 # 同时进行的暗影仪式数量

# 暗影仪式状态
var active_shadow_rituals: Array = [] # 当前活跃的暗影仪式
var shadow_energy_level: float = 0.0 # 暗影能量等级
var is_shadow_veil_active: bool = false # 暗影面纱是否激活


func _init():
	"""初始化暗影神殿3D"""
	super._init()
	
	# 基础属性
	building_name = "暗影神殿"
	building_type = BuildingTypes.BuildingType.SHADOW_TEMPLE
	max_health = 400
	health = max_health
	armor = 8
	building_size = Vector2(1, 1) # 保持原有尺寸用于碰撞检测
	cost_gold = 800
	engineer_cost = 400
	build_time = 300.0
	engineer_required = 3
	status = BuildingStatus.PLANNING
	
	# 3D配置
	_setup_3d_config()


func _setup_3d_config():
	"""设置3D配置"""
	# 基础配置
	building_3d_config.set_basic_config(building_name, building_type, Vector3(3, 3, 3))
	
	# 结构配置
	building_3d_config.has_windows = false
	building_3d_config.has_door = true
	building_3d_config.has_roof = true
	building_3d_config.has_decorations = true
	
	# 材质配置（暗影风格）
	building_3d_config.wall_color = Color(0.2, 0.1, 0.3) # 深紫色墙体
	building_3d_config.roof_color = Color(0.1, 0.05, 0.2) # 更深紫色屋顶
	building_3d_config.floor_color = Color(0.3, 0.15, 0.4) # 暗紫色地板
	
	# 特殊功能配置
	building_3d_config.has_lighting = true
	building_3d_config.has_particles = true
	building_3d_config.has_animations = true
	building_3d_config.has_sound_effects = false


func _get_building_template():
	"""获取暗影神殿建筑模板"""
	var template = BuildingTemplateClass.new("暗影神殿")
	template.building_type = BuildingTypes.BuildingType.SHADOW_TEMPLE
	template.description = "神秘的3x3x3暗影神殿，散发着黑暗的力量"
	
	# 创建暗影结构
	template.create_shadow_structure(BuildingTypes.BuildingType.SHADOW_TEMPLE)
	
	# 自定义暗影神殿元素
	# 顶层：暗影符文和神殿祭坛
	template.set_component(0, 2, 0, BuildingComponents.ID_SHADOW_RUNE)
	template.set_component(1, 2, 0, BuildingComponents.ID_SHADOW_CORE)
	template.set_component(2, 2, 0, BuildingComponents.ID_SHADOW_RUNE)
	template.set_component(0, 2, 1, BuildingComponents.ID_SHADOW_RUNE)
	template.set_component(1, 2, 1, BuildingComponents.ID_SHADOW_ALTAR)
	template.set_component(2, 2, 1, BuildingComponents.ID_SHADOW_RUNE)
	template.set_component(0, 2, 2, BuildingComponents.ID_SHADOW_RUNE)
	template.set_component(1, 2, 2, BuildingComponents.ID_SHADOW_CORE)
	template.set_component(2, 2, 2, BuildingComponents.ID_SHADOW_RUNE)
	
	# 中层：暗影墙和暗影池
	template.set_component(0, 1, 0, BuildingComponents.ID_SHADOW_WALL)
	template.set_component(1, 1, 0, BuildingComponents.ID_SHADOW_WALL)
	template.set_component(2, 1, 0, BuildingComponents.ID_SHADOW_WALL)
	template.set_component(0, 1, 1, BuildingComponents.ID_SHADOW_WALL)
	template.set_component(1, 1, 1, BuildingComponents.ID_SHADOW_POOL)
	template.set_component(2, 1, 1, BuildingComponents.ID_SHADOW_WALL)
	template.set_component(0, 1, 2, BuildingComponents.ID_SHADOW_WALL)
	template.set_component(1, 1, 2, BuildingComponents.ID_SHADOW_WALL)
	template.set_component(2, 1, 2, BuildingComponents.ID_SHADOW_WALL)
	
	# 底层：入口和基础
	template.set_component(1, 0, 0, BuildingComponents.ID_DOOR_METAL)
	template.set_component(0, 0, 1, BuildingComponents.ID_SHADOW_WALL)
	template.set_component(1, 0, 1, BuildingComponents.ID_SHADOW_WALL)
	template.set_component(2, 0, 1, BuildingComponents.ID_SHADOW_WALL)
	template.set_component(1, 0, 2, BuildingComponents.ID_SHADOW_WALL)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取暗影神殿建筑配置"""
	var config = BuildingConfig.new()
	config.name = building_name
	config.width = 3
	config.depth = 3
	config.height = 3
	
	# 结构配置
	config.has_windows = false
	config.has_door = true
	config.has_roof = true
	config.has_decorations = true
	config.has_tower = false
	config.has_balcony = false
	
	# 材质配置
	config.wall_color = Color(0.2, 0.1, 0.3) # 深紫色
	config.roof_color = Color(0.1, 0.05, 0.2) # 更深紫色
	config.floor_color = Color(0.3, 0.15, 0.4) # 暗紫色
	config.window_color = Color.LIGHT_BLUE # 不使用窗户
	config.door_color = Color(0.05, 0.02, 0.1) # 深黑色门
	
	return config


func _load_building_specific_components():
	"""加载暗影神殿特定构件"""
	# 加载暗影构件
	_add_component_to_library("Shadow_Rune", BuildingComponents.ID_SHADOW_RUNE)
	_add_component_to_library("Shadow_Core", BuildingComponents.ID_SHADOW_CORE)
	_add_component_to_library("Shadow_Altar", BuildingComponents.ID_SHADOW_ALTAR)
	_add_component_to_library("Shadow_Pool", BuildingComponents.ID_SHADOW_POOL)
	_add_component_to_library("Shadow_Wall", BuildingComponents.ID_SHADOW_WALL)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("🏛️ [ShadowTemple3D] 暗影神殿3D准备就绪")
	
	# 启动暗影特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("🏛️ [ShadowTemple3D] 暗影神殿3D建造完成")
	
	# 启动暗影系统
	_start_shadow_system()
	
	# 启动暗影动画
	if construction_animator:
		construction_animator.play_function_animation("shadow_ritual")


func _start_shadow_system():
	"""启动暗影系统"""
	# 设置暗影更新定时器
	var shadow_timer = Timer.new()
	shadow_timer.name = "ShadowTimer"
	shadow_timer.wait_time = 1.0 # 每秒更新一次
	shadow_timer.timeout.connect(_process_shadow_energy)
	shadow_timer.autostart = true
	add_child(shadow_timer)
	
	# 设置暗影魔力生成定时器
	var mana_timer = Timer.new()
	mana_timer.name = "ShadowManaTimer"
	mana_timer.wait_time = 1.0 # 每秒生成一次
	mana_timer.timeout.connect(_generate_shadow_mana)
	mana_timer.autostart = true
	add_child(mana_timer)
	
	# 设置暗影仪式更新定时器
	var ritual_timer = Timer.new()
	ritual_timer.name = "RitualTimer"
	ritual_timer.wait_time = 0.5 # 每0.5秒更新一次
	ritual_timer.timeout.connect(_update_shadow_rituals)
	ritual_timer.autostart = true
	add_child(ritual_timer)


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑"""
	# 调用父类方法
	super._update_3d_building_logic(delta)
	
	# 更新暗影系统
	_update_shadow_system(delta)
	
	# 更新暗影特效
	_update_shadow_effects(delta)


func _update_shadow_system(delta: float):
	"""更新暗影系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 更新暗影能量等级
	_update_shadow_energy_level(delta)
	
	# 更新暗影面纱状态
	_update_shadow_veil(delta)


func _update_shadow_energy_level(delta: float):
	"""更新暗影能量等级"""
	# 根据活跃仪式数量调整能量等级
	var ritual_count = active_shadow_rituals.size()
	shadow_energy_level = min(ritual_count * 0.33, 1.0)


func _update_shadow_veil(delta: float):
	"""更新暗影面纱状态"""
	# 当能量等级达到一定阈值时激活暗影面纱
	if shadow_energy_level >= 0.7 and not is_shadow_veil_active:
		_activate_shadow_veil()
	elif shadow_energy_level < 0.3 and is_shadow_veil_active:
		_deactivate_shadow_veil()


func _activate_shadow_veil():
	"""激活暗影面纱"""
	is_shadow_veil_active = true
	_play_shadow_veil_effect()
	LogManager.info("🏛️ [ShadowTemple3D] 暗影面纱已激活")


func _deactivate_shadow_veil():
	"""停用暗影面纱"""
	is_shadow_veil_active = false
	_play_shadow_veil_effect()
	LogManager.info("🏛️ [ShadowTemple3D] 暗影面纱已停用")


func _process_shadow_energy():
	"""处理暗影能量"""
	# 根据暗影能量等级调整建筑特效
	_update_shadow_energy_effects()


func _generate_shadow_mana():
	"""生成暗影魔力"""
	if resource_manager:
		var mana_generated = shadow_mana_generation_rate * (1.0 + shadow_energy_level)
		resource_manager.add_mana(int(mana_generated))
		
		# 播放暗影魔力生成特效
		_play_shadow_mana_effect()


func _update_shadow_rituals():
	"""更新暗影仪式"""
	# 处理当前活跃的暗影仪式
	for ritual in active_shadow_rituals:
		if is_instance_valid(ritual):
			_advance_shadow_ritual(ritual, 0.5)


func _advance_shadow_ritual(ritual: Dictionary, delta: float):
	"""推进暗影仪式"""
	if not ritual.has("progress"):
		ritual["progress"] = 0.0
	
	ritual["progress"] += delta * shadow_power_multiplier
	
	# 检查仪式是否完成
	if ritual["progress"] >= 100.0:
		_complete_shadow_ritual(ritual)


func _complete_shadow_ritual(ritual: Dictionary):
	"""完成暗影仪式"""
	active_shadow_rituals.erase(ritual)
	
	# 播放仪式完成特效
	_play_ritual_complete_effect()
	
	LogManager.info("🏛️ [ShadowTemple3D] 暗影仪式完成: %s" % ritual.get("name", "未知"))


func _play_shadow_mana_effect():
	"""播放暗影魔力生成特效"""
	if not effect_manager:
		return
	
	# 创建暗影魔力生成粒子效果
	effect_manager._create_particle_effect("shadow_mana", global_position + Vector3(0, 2, 0), 1.5)


func _play_shadow_veil_effect():
	"""播放暗影面纱特效"""
	if not effect_manager:
		return
	
	# 创建暗影面纱粒子效果
	effect_manager._create_particle_effect("shadow_veil", global_position + Vector3(0, 1.5, 0), 3.0)


func _play_ritual_complete_effect():
	"""播放仪式完成特效"""
	if not effect_manager:
		return
	
	# 创建仪式完成粒子效果
	effect_manager._create_particle_effect("ritual_complete", global_position + Vector3(0, 2, 0), 4.0)


func _update_shadow_effects(delta: float):
	"""更新暗影特效"""
	# 更新暗影能量流动
	_update_shadow_energy_flow(delta)
	
	# 更新暗影核心发光
	_update_shadow_core_glow(delta)


func _update_shadow_energy_flow(delta: float):
	"""更新暗影能量流动"""
	# 暗影能量流动动画
	if construction_animator:
		construction_animator.play_function_animation("shadow_energy_flow")
	
	# 根据能量等级调整流动强度
	var flow_intensity = 0.5 + shadow_energy_level * 1.5
	
	if effect_manager and effect_manager.particle_systems.has("shadow_energy_particles"):
		var ps = effect_manager.particle_systems["shadow_energy_particles"]
		if ps and ps.emitting:
			# 调整粒子强度
			ps.amount = int(5 + flow_intensity * 15)


func _update_shadow_core_glow(delta: float):
	"""更新暗影核心发光"""
	# 暗影核心发光动画
	if construction_animator:
		construction_animator.play_function_animation("shadow_core_glow")
	
	# 根据能量等级调整发光强度
	var glow_intensity = 0.6 + shadow_energy_level * 1.4
	
	if effect_manager and effect_manager.light_systems.has("shadow_core_light"):
		var light = effect_manager.light_systems["shadow_core_light"]
		if light and light.visible:
			light.light_energy = glow_intensity
			light.light_color = Color(0.4, 0.2, 0.8) # 暗紫色光


func _update_shadow_energy_effects():
	"""更新暗影能量特效"""
	# 根据暗影面纱状态调整建筑外观
	if is_shadow_veil_active:
		# 激活暗影面纱时的特效
		if effect_manager and effect_manager.light_systems.has("shadow_veil_light"):
			var light = effect_manager.light_systems["shadow_veil_light"]
			if light and light.visible:
				light.light_energy = 0.8 + sin(Time.get_time_dict_from_system()["second"] * 2) * 0.3
				light.light_color = Color(0.3, 0.1, 0.6) # 暗紫色面纱光


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新暗影神殿特定特效
	_update_shadow_temple_effects(delta)


func _update_shadow_temple_effects(delta: float):
	"""更新暗影神殿特效"""
	# 暗影脉冲效果
	var ritual_count = active_shadow_rituals.size()
	var pulse_frequency = 1.2 + ritual_count * 0.4
	
	if effect_manager and effect_manager.light_systems.has("temple_glow"):
		var light = effect_manager.light_systems["temple_glow"]
		if light and light.visible:
			# 暗影脉冲
			light.light_energy = 0.7 + sin(Time.get_time_dict_from_system()["second"] * pulse_frequency) * 0.3
			light.light_color = Color(0.4, 0.2, 0.8) # 暗紫色神殿光


func can_start_shadow_ritual() -> bool:
	"""检查是否可以开始暗影仪式"""
	return active_shadow_rituals.size() < shadow_ritual_slots and status == BuildingStatus.COMPLETED


func start_shadow_ritual(ritual_name: String) -> bool:
	"""开始暗影仪式"""
	if can_start_shadow_ritual():
		var ritual = {
			"name": ritual_name,
			"progress": 0.0,
			"start_time": Time.get_time_dict_from_system()["second"]
		}
		active_shadow_rituals.append(ritual)
		_play_shadow_veil_effect()
		return true
	return false


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加暗影神殿特定信息
	base_info["shadow_mana_generation_rate"] = shadow_mana_generation_rate
	base_info["shadow_power_multiplier"] = shadow_power_multiplier
	base_info["shadow_stealth_bonus"] = shadow_stealth_bonus
	base_info["shadow_ritual_slots"] = shadow_ritual_slots
	base_info["active_rituals_count"] = active_shadow_rituals.size()
	base_info["shadow_energy_level"] = shadow_energy_level
	base_info["is_shadow_veil_active"] = is_shadow_veil_active
	base_info["can_start_ritual"] = can_start_shadow_ritual()
	
	return base_info


func _on_destroyed():
	"""建筑被摧毁时的回调（重写父类方法）"""
	# 调用父类方法
	super._on_destroyed()
	
	# 停止所有暗影仪式
	active_shadow_rituals.clear()
	is_shadow_veil_active = false
	
	# 停止所有特效
	if effect_manager:
		effect_manager.stop_functional_effects()
	
	# 停止所有动画
	if construction_animator:
		construction_animator.stop_all_animations()
	
	LogManager.info("💀 [ShadowTemple3D] 暗影神殿被摧毁，所有特效已停止")
