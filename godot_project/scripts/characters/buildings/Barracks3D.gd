extends Building3D
class_name Barracks3D

## 🏗️ 训练室3D - 3x3x3军事训练建筑
## 基于Building3D，实现训练室的3x3x3渲染

# 训练系统
var training_speed_multiplier: float = 1.5 # 训练速度倍率
var max_trainees: int = 3 # 最多同时训练3个怪物
var current_trainees: Array = [] # 当前训练中的怪物


func _init():
	"""初始化训练室3D"""
	super._init()
	
	# 基础属性
	building_name = "训练室"
	building_type = BuildingTypes.BuildingType.TRAINING_ROOM
	max_health = 300
	health = max_health
	armor = 6
	building_size = Vector2(1, 1) # 保持原有尺寸用于碰撞检测
	cost_gold = 200
	engineer_cost = 100
	build_time = 120.0
	engineer_required = 1
	status = BuildingStatus.PLANNING
	
	# 3D配置
	_setup_3d_config()


func _setup_3d_config():
	"""设置3D配置"""
	# 基础配置
	building_3d_config.set_basic_config(building_name, building_type, Vector3(3, 3, 3))
	
	# 结构配置
	building_3d_config.has_windows = true
	building_3d_config.has_door = true
	building_3d_config.has_roof = true
	building_3d_config.has_decorations = true
	
	# 材质配置（军事风格）
	building_3d_config.wall_color = Color(0.5, 0.4, 0.3) # 棕色墙体
	building_3d_config.roof_color = Color(0.4, 0.3, 0.2) # 深棕色屋顶
	building_3d_config.floor_color = Color(0.6, 0.5, 0.4) # 浅棕色地板
	
	# 特殊功能配置
	building_3d_config.has_lighting = true
	building_3d_config.has_particles = true
	building_3d_config.has_animations = true
	building_3d_config.has_sound_effects = false


func _get_building_template():
	"""获取训练室建筑模板"""
	var template = BuildingTemplateClass.new("训练室")
	template.building_type = BuildingTypes.BuildingType.TRAINING_ROOM
	template.description = "坚固的3x3x3军事训练建筑，提升怪物战斗力"
	
	# 创建军事结构
	template.create_military_structure(BuildingTypes.BuildingType.TRAINING_ROOM)
	
	# 自定义训练室元素
	# 顶层：旗帜和训练台
	template.set_component(0, 2, 0, BuildingComponents.ID_BATTLE_STANDARD)
	template.set_component(1, 2, 0, BuildingComponents.ID_BATTLE_STANDARD)
	template.set_component(2, 2, 0, BuildingComponents.ID_BATTLE_STANDARD)
	template.set_component(0, 2, 1, BuildingComponents.ID_TRAINING_POST)
	template.set_component(1, 2, 1, BuildingComponents.ID_TRAINING_POST)
	template.set_component(2, 2, 1, BuildingComponents.ID_TRAINING_POST)
	template.set_component(0, 2, 2, BuildingComponents.ID_BATTLE_STANDARD)
	template.set_component(1, 2, 2, BuildingComponents.ID_BATTLE_STANDARD)
	template.set_component(2, 2, 2, BuildingComponents.ID_BATTLE_STANDARD)
	
	# 中层：训练设备和窗户
	template.set_component(0, 1, 0, BuildingComponents.ID_TRAINING_POST)
	template.set_component(1, 1, 0, BuildingComponents.ID_WINDOW_SMALL)
	template.set_component(2, 1, 0, BuildingComponents.ID_TRAINING_POST)
	template.set_component(0, 1, 1, BuildingComponents.ID_TRAINING_POST)
	template.set_component(1, 1, 1, BuildingComponents.ID_TRAINING_GROUND)
	template.set_component(2, 1, 1, BuildingComponents.ID_TRAINING_POST)
	template.set_component(0, 1, 2, BuildingComponents.ID_TRAINING_POST)
	template.set_component(1, 1, 2, BuildingComponents.ID_WINDOW_SMALL)
	template.set_component(2, 1, 2, BuildingComponents.ID_TRAINING_POST)
	
	# 底层：入口和基础
	template.set_component(1, 0, 0, BuildingComponents.ID_DOOR_WOOD)
	template.set_component(0, 0, 1, BuildingComponents.ID_TRAINING_POST)
	template.set_component(1, 0, 1, BuildingComponents.ID_TRAINING_GROUND)
	template.set_component(2, 0, 1, BuildingComponents.ID_TRAINING_POST)
	template.set_component(1, 0, 2, BuildingComponents.ID_TRAINING_POST)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取训练室建筑配置"""
	var config = BuildingConfig.new()
	config.name = building_name
	config.width = 3
	config.depth = 3
	config.height = 3
	
	# 结构配置
	config.has_windows = true
	config.has_door = true
	config.has_roof = true
	config.has_decorations = true
	config.has_tower = false
	config.has_balcony = false
	
	# 材质配置
	config.wall_color = Color(0.5, 0.4, 0.3) # 棕色
	config.roof_color = Color(0.4, 0.3, 0.2) # 深棕色
	config.floor_color = Color(0.6, 0.5, 0.4) # 浅棕色
	config.window_color = Color(0.8, 0.8, 0.9) # 淡灰色窗户
	config.door_color = Color(0.3, 0.2, 0.1) # 深棕色门
	
	return config


func _load_building_specific_components():
	"""加载训练室特定构件"""
	# 加载军事构件
	_add_component_to_library("Training_Post", BuildingComponents.ID_TRAINING_POST)
	_add_component_to_library("Training_Ground", BuildingComponents.ID_TRAINING_GROUND)
	_add_component_to_library("Battle_Standard", BuildingComponents.ID_BATTLE_STANDARD)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("🏋️ [Barracks3D] 训练室3D准备就绪")
	
	# 启动训练特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("🏋️ [Barracks3D] 训练室3D建造完成")
	
	# 启动训练系统
	_start_training_system()
	
	# 启动训练动画
	if construction_animator:
		construction_animator.play_function_animation("training_activity")


func _start_training_system():
	"""启动训练系统"""
	# 设置训练更新定时器
	var training_timer = Timer.new()
	training_timer.name = "TrainingTimer"
	training_timer.wait_time = 0.5 # 每0.5秒更新一次
	training_timer.timeout.connect(_update_training)
	training_timer.autostart = true
	add_child(training_timer)


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑"""
	# 调用父类方法
	super._update_3d_building_logic(delta)
	
	# 更新训练系统
	_update_training_system(delta)
	
	# 更新训练特效
	_update_training_effects(delta)


func _update_training_system(delta: float):
	"""更新训练系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 更新训练进度
	_update_training_progress(delta)


func _update_training_progress(delta: float):
	"""更新训练进度"""
	# 这里可以添加训练进度的视觉指示
	pass


func _update_training():
	"""更新训练"""
	# 训练中的怪物
	for trainee in current_trainees:
		if is_instance_valid(trainee):
			_train_monster(trainee, 0.5)


func can_accept_trainee() -> bool:
	"""检查是否可以接收新的训练者"""
	return current_trainees.size() < max_trainees and status == BuildingStatus.COMPLETED


func add_trainee(monster: Node) -> bool:
	"""添加训练者"""
	if can_accept_trainee():
		current_trainees.append(monster)
		_play_training_start_effect()
		return true
	return false


func remove_trainee(monster: Node):
	"""移除训练者"""
	current_trainees.erase(monster)


func _train_monster(monster: Node, delta: float):
	"""训练怪物"""
	if monster.has_method("apply_training"):
		monster.apply_training(training_speed_multiplier * delta)
		
		# 播放训练特效
		_play_training_effect()


func _play_training_start_effect():
	"""播放训练开始特效"""
	if not effect_manager:
		return
	
	# 创建训练开始粒子效果
	effect_manager._create_particle_effect("training_start", global_position + Vector3(0, 1, 0), 2.0)


func _play_training_effect():
	"""播放训练特效"""
	if not effect_manager:
		return
	
	# 创建训练粒子效果
	effect_manager._create_particle_effect("training_dust", global_position + Vector3(0, 0.5, 0), 1.0)


func _update_training_effects(delta: float):
	"""更新训练特效"""
	# 更新训练活动效果
	_update_training_activity(delta)
	
	# 更新旗帜飘动
	_update_banner_animation(delta)


func _update_training_activity(delta: float):
	"""更新训练活动效果"""
	# 根据训练者数量调整活动强度
	var activity_intensity = float(current_trainees.size()) / float(max_trainees)
	
	# 训练活动动画
	if construction_animator:
		construction_animator.play_function_animation("training_activity")
	
	# 根据活动强度调整特效
	if effect_manager and effect_manager.particle_systems.has("training_particles"):
		var ps = effect_manager.particle_systems["training_particles"]
		if ps and ps.emitting:
			# 调整粒子强度
			ps.amount = int(5 + activity_intensity * 15)


func _update_banner_animation(delta: float):
	"""更新旗帜飘动"""
	# 旗帜飘动动画
	if construction_animator:
		construction_animator.play_function_animation("banner_wave")
	
	# 根据训练强度调整旗帜发光
	var training_intensity = float(current_trainees.size()) / float(max_trainees)
	
	if effect_manager and effect_manager.light_systems.has("banner_light"):
		var light = effect_manager.light_systems["banner_light"]
		if light and light.visible:
			light.light_energy = 0.3 + training_intensity * 0.7
			light.light_color = Color(0.8, 0.6, 0.4) # 温暖的军事光


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新训练室特定特效
	_update_barracks_effects(delta)


func _update_barracks_effects(delta: float):
	"""更新训练室特效"""
	# 训练脉冲效果
	var training_count = current_trainees.size()
	var pulse_frequency = 1.0 + training_count * 0.5
	
	if effect_manager and effect_manager.light_systems.has("training_glow"):
		var light = effect_manager.light_systems["training_glow"]
		if light and light.visible:
			# 训练脉冲
			light.light_energy = 0.5 + sin(Time.get_time_dict_from_system()["second"] * pulse_frequency) * 0.3
			light.light_color = Color(0.8, 0.6, 0.4) # 军事训练光


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加训练室特定信息
	base_info["training_speed_multiplier"] = training_speed_multiplier
	base_info["max_trainees"] = max_trainees
	base_info["current_trainees"] = current_trainees.size()
	base_info["can_accept_trainee"] = can_accept_trainee()
	base_info["training_capacity_ratio"] = float(current_trainees.size()) / float(max_trainees)
	
	return base_info


func _on_destroyed():
	"""建筑被摧毁时的回调（重写父类方法）"""
	# 调用父类方法
	super._on_destroyed()
	
	# 释放所有训练者
	for trainee in current_trainees:
		if is_instance_valid(trainee):
			remove_trainee(trainee)
	
	# 停止所有特效
	if effect_manager:
		effect_manager.stop_functional_effects()
	
	# 停止所有动画
	if construction_animator:
		construction_animator.stop_all_animations()
	
	LogManager.info("💀 [Barracks3D] 训练室被摧毁，所有特效已停止")
