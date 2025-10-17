extends Building3D
class_name DemonLair3D

## 🏗️ 恶魔巢穴3D - 3x3x3恶魔召唤建筑
## 基于Building3D，实现恶魔巢穴的3x3x3渲染

# 召唤系统
var summon_cost: int = 20                    # 召唤成本
var summon_time: float = 60.0                # 召唤时间
var summon_progress: float = 0.0             # 召唤进度
var is_summoning: bool = false               # 是否正在召唤
var bound_demon: Node = null                 # 绑定的恶魔
var is_locked: bool = false                  # 锁定状态


func _init():
	"""初始化恶魔巢穴3D"""
	super._init()
	
	# 基础属性
	building_name = "恶魔巢穴"
	building_type = BuildingTypes.DEMON_LAIR
	max_health = 500
	health = max_health
	armor = 6
	building_size = Vector2(1, 1)  # 保持原有尺寸用于碰撞检测
	cost_gold = 300
	engineer_cost = 150
	build_time = 180.0
	engineer_required = 2
	status = BuildingStatus.PLANNING
	
	# 3D配置
	_setup_3d_config()


func _setup_3d_config():
	"""设置3D配置"""
	# 基础配置
	building_3d_config.set_basic_config(building_name, building_type, Vector3(3, 3, 3))
	
	# 结构配置
	building_3d_config.set_structure_config(
		windows = false,   # 无窗户（邪恶建筑）
		door = true,       # 有门
		roof = true,       # 有屋顶
		decorations = true # 有装饰
	)
	
	# 材质配置（邪恶风格）
	building_3d_config.set_material_config(
		wall = Color(0.3, 0.1, 0.1),    # 深红色墙体
		roof = Color(0.2, 0.05, 0.05),   # 更深红色屋顶
		floor = Color(0.4, 0.15, 0.15)    # 暗红色地板
	)
	
	# 特殊功能配置
	building_3d_config.set_special_config(
		lighting = true,    # 有光照
		particles = true,   # 有粒子特效
		animations = true,  # 有动画
		sound = false       # 暂时无音效
	)


func _get_building_template() -> BuildingTemplate:
	"""获取恶魔巢穴建筑模板"""
	var template = BuildingTemplate.new("恶魔巢穴")
	template.building_type = BuildingTypes.DEMON_LAIR
	template.description = "邪恶的3x3x3恶魔巢穴，散发着地狱的气息"
	
	# 创建魔法结构
	template.create_magic_structure(BuildingTypes.DEMON_LAIR)
	
	# 自定义恶魔巢穴元素
	# 顶层：恶魔角和召唤阵
	template.set_component(0, 2, 0, BuildingComponents.ID_DEMON_HORN)
	template.set_component(1, 2, 0, BuildingComponents.ID_SUMMONING_CIRCLE)
	template.set_component(2, 2, 0, BuildingComponents.ID_DEMON_HORN)
	template.set_component(0, 2, 1, BuildingComponents.ID_DEMON_HORN)
	template.set_component(1, 2, 1, BuildingComponents.ID_SUMMONING_CIRCLE)
	template.set_component(2, 2, 1, BuildingComponents.ID_DEMON_HORN)
	template.set_component(0, 2, 2, BuildingComponents.ID_DEMON_HORN)
	template.set_component(1, 2, 2, BuildingComponents.ID_SUMMONING_CIRCLE)
	template.set_component(2, 2, 2, BuildingComponents.ID_DEMON_HORN)
	
	# 中层：火焰和恶魔核心
	template.set_component(0, 1, 0, BuildingComponents.ID_HELL_FIRE)
	template.set_component(1, 1, 0, BuildingComponents.ID_DEMON_CORE)
	template.set_component(2, 1, 0, BuildingComponents.ID_HELL_FIRE)
	template.set_component(0, 1, 1, BuildingComponents.ID_HELL_FIRE)
	template.set_component(1, 1, 1, BuildingComponents.ID_DEMON_CORE)
	template.set_component(2, 1, 1, BuildingComponents.ID_HELL_FIRE)
	template.set_component(0, 1, 2, BuildingComponents.ID_HELL_FIRE)
	template.set_component(1, 1, 2, BuildingComponents.ID_DEMON_CORE)
	template.set_component(2, 1, 2, BuildingComponents.ID_HELL_FIRE)
	
	# 底层：入口和基础
	template.set_component(1, 0, 0, BuildingComponents.ID_DOOR_METAL)
	template.set_component(0, 0, 1, BuildingComponents.ID_DEMON_CLAW)
	template.set_component(1, 0, 1, BuildingComponents.ID_DEMON_CORE)
	template.set_component(2, 0, 1, BuildingComponents.ID_DEMON_CLAW)
	template.set_component(1, 0, 2, BuildingComponents.ID_DEMON_CLAW)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取恶魔巢穴建筑配置"""
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
	config.wall_color = Color(0.3, 0.1, 0.1)  # 深红色
	config.roof_color = Color(0.2, 0.05, 0.05)    # 更深红色
	config.floor_color = Color(0.4, 0.15, 0.15)   # 暗红色
	config.window_color = Color.LIGHT_BLUE       # 不使用窗户
	config.door_color = Color(0.1, 0.05, 0.05)    # 深黑色门
	
	return config


func _load_building_specific_components():
	"""加载恶魔巢穴特定构件"""
	# 加载恶魔构件
	_add_component_to_library("Demon_Horn", BuildingComponents.ID_DEMON_HORN)
	_add_component_to_library("Summoning_Circle", BuildingComponents.ID_SUMMONING_CIRCLE)
	_add_component_to_library("Demon_Core", BuildingComponents.ID_DEMON_CORE)
	_add_component_to_library("Hell_Fire", BuildingComponents.ID_HELL_FIRE)
	_add_component_to_library("Demon_Claw", BuildingComponents.ID_DEMON_CLAW)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("👹 [DemonLair3D] 恶魔巢穴3D准备就绪")
	
	# 启动恶魔特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("👹 [DemonLair3D] 恶魔巢穴3D建造完成")
	
	# 启动召唤系统
	_start_summoning_system()
	
	# 启动恶魔动画
	if construction_animator:
		construction_animator.play_function_animation("demon_ritual")


func _start_summoning_system():
	"""启动召唤系统"""
	# 设置召唤更新定时器
	var summon_timer = Timer.new()
	summon_timer.name = "SummoningTimer"
	summon_timer.wait_time = 0.5  # 每0.5秒更新一次
	summon_timer.timeout.connect(_update_summoning)
	summon_timer.autostart = true
	add_child(summon_timer)


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑"""
	# 调用父类方法
	super._update_3d_building_logic(delta)
	
	# 更新召唤系统
	_update_summoning_system(delta)
	
	# 更新恶魔特效
	_update_demon_effects(delta)


func _update_summoning_system(delta: float):
	"""更新召唤系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 更新召唤进度
	_update_summoning_progress(delta)


func _update_summoning_progress(delta: float):
	"""更新召唤进度"""
	# 这里可以添加召唤进度的视觉指示
	pass


func _update_summoning():
	"""更新召唤"""
	if is_summoning:
		summon_progress += 0.5
		
		# 检查召唤是否完成
		if summon_progress >= summon_time:
			_complete_summoning()
		
		# 播放召唤特效
		_play_summoning_effect()


func _complete_summoning():
	"""完成召唤"""
	is_summoning = false
	summon_progress = 0.0
	
	# 播放召唤完成特效
	_play_summoning_complete_effect()
	
	# 这里应该创建恶魔单位
	_create_demon()
	
	LogManager.info("👹 [DemonLair3D] 恶魔召唤完成")


func _create_demon():
	"""创建恶魔"""
	# 这里应该实例化恶魔单位
	# var demon_scene = preload("res://scenes/units/demon.tscn")
	# var demon = demon_scene.instantiate()
	# 添加到游戏世界
	
	# 绑定恶魔到巢穴
	# bound_demon = demon
	# is_locked = true


func can_start_summoning() -> bool:
	"""检查是否可以开始召唤"""
	return not is_summoning and status == BuildingStatus.COMPLETED and not is_locked


func start_summoning() -> bool:
	"""开始召唤"""
	if can_start_summoning():
		is_summoning = true
		summon_progress = 0.0
		_play_summoning_start_effect()
		return true
	return false


func _play_summoning_start_effect():
	"""播放召唤开始特效"""
	if not effect_manager:
		return
	
	# 创建召唤开始粒子效果
	effect_manager._create_particle_effect("summoning_start", global_position + Vector3(0, 1, 0), 2.5)


func _play_summoning_effect():
	"""播放召唤特效"""
	if not effect_manager:
		return
	
	# 创建召唤粒子效果
	effect_manager._create_particle_effect("summoning_ritual", global_position + Vector3(0, 1, 0), 1.5)


func _play_summoning_complete_effect():
	"""播放召唤完成特效"""
	if not effect_manager:
		return
	
	# 创建召唤完成粒子效果
	effect_manager._create_particle_effect("summoning_complete", global_position + Vector3(0, 1, 0), 4.0)


func _update_demon_effects(delta: float):
	"""更新恶魔特效"""
	# 更新地狱火焰效果
	_update_hell_fire(delta)
	
	# 更新恶魔核心发光
	_update_demon_core_glow(delta)


func _update_hell_fire(delta: float):
	"""更新地狱火焰效果"""
	# 地狱火焰动画
	if construction_animator:
		construction_animator.play_function_animation("hell_fire")
	
	# 根据召唤状态调整火焰强度
	var fire_intensity = 1.0 + (float(summon_progress) / float(summon_time)) * 2.0
	
	if effect_manager and effect_manager.particle_systems.has("hell_fire_particles"):
		var ps = effect_manager.particle_systems["hell_fire_particles"]
		if ps and ps.emitting:
			# 调整粒子强度
			ps.amount = int(10 + fire_intensity * 20)


func _update_demon_core_glow(delta: float):
	"""更新恶魔核心发光"""
	# 恶魔核心发光动画
	if construction_animator:
		construction_animator.play_function_animation("demon_core_glow")
	
	# 根据召唤进度调整发光强度
	var summon_ratio = float(summon_progress) / float(summon_time)
	
	if effect_manager and effect_manager.light_systems.has("demon_light"):
		var light = effect_manager.light_systems["demon_light"]
		if light and light.visible:
			light.light_energy = 0.5 + summon_ratio * 1.5
			light.light_color = Color(1.0, 0.2, 0.2)  # 红色恶魔光


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新恶魔巢穴特定特效
	_update_demon_lair_effects(delta)


func _update_demon_lair_effects(delta: float):
	"""更新恶魔巢穴特效"""
	# 恶魔脉冲效果
	var summon_activity = 1.0 if is_summoning else 0.3
	var pulse_frequency = 1.5 + summon_activity * 1.0
	
	if effect_manager and effect_manager.light_systems.has("lair_glow"):
		var light = effect_manager.light_systems["lair_glow"]
		if light and light.visible:
			# 恶魔脉冲
			light.light_energy = 0.6 + sin(Time.get_time_dict_from_system()["second"] * pulse_frequency) * 0.4
			light.light_color = Color(1.0, 0.2, 0.2)  # 红色恶魔光


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加恶魔巢穴特定信息
	base_info["summon_cost"] = summon_cost
	base_info["summon_time"] = summon_time
	base_info["summon_progress"] = summon_progress
	base_info["is_summoning"] = is_summoning
	base_info["can_start_summoning"] = can_start_summoning()
	base_info["summon_progress_ratio"] = float(summon_progress) / float(summon_time)
	base_info["is_locked"] = is_locked
	base_info["has_bound_demon"] = bound_demon != null
	
	return base_info


func _on_destroyed():
	"""建筑被摧毁时的回调（重写父类方法）"""
	# 调用父类方法
	super._on_destroyed()
	
	# 释放绑定的恶魔
	if bound_demon and is_instance_valid(bound_demon):
		# 释放恶魔
		bound_demon = null
		is_locked = false
	
	# 停止召唤
	is_summoning = false
	
	# 停止所有特效
	if effect_manager:
		effect_manager.stop_functional_effects()
	
	# 停止所有动画
	if construction_animator:
		construction_animator.stop_all_animations()
	
	LogManager.info("💀 [DemonLair3D] 恶魔巢穴被摧毁，所有特效已停止")
