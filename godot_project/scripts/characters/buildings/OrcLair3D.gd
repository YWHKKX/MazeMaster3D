extends Building3D
class_name OrcLair3D

## 🏗️ 兽人巢穴3D - 3x3x3兽人训练建筑
## 基于Building3D，实现兽人巢穴的3x3x3渲染

# 兽人训练系统
var orc_training_cost: int = 30                    # 训练成本
var orc_training_time: float = 90.0               # 训练时间
var orc_training_progress: float = 0.0            # 训练进度
var is_training_orc: bool = false                 # 是否正在训练
var max_training_slots: int = 2                   # 最大训练槽位
var current_trainees: Array = []                  # 当前训练中的兽人
var war_drum_bonus: float = 1.3                  # 战鼓加成（30%训练速度）


func _init():
	"""初始化兽人巢穴3D"""
	super._init()
	
	# 基础属性
	building_name = "兽人巢穴"
	building_type = BuildingTypes.ORC_LAIR
	max_health = 450
	health = max_health
	armor = 7
	building_size = Vector2(1, 1)  # 保持原有尺寸用于碰撞检测
	cost_gold = 350
	engineer_cost = 175
	build_time = 200.0
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
		windows = true,    # 有窗户（通风）
		door = true,       # 有门
		roof = true,       # 有屋顶
		decorations = true # 有装饰
	)
	
	# 材质配置（原始风格）
	building_3d_config.set_material_config(
		wall = Color(0.4, 0.3, 0.2),    # 棕色墙体
		roof = Color(0.3, 0.2, 0.1),    # 深棕色屋顶
		floor = Color(0.5, 0.4, 0.3)     # 浅棕色地板
	)
	
	# 特殊功能配置
	building_3d_config.set_special_config(
		lighting = true,    # 有光照
		particles = true,   # 有粒子特效
		animations = true,  # 有动画
		sound = false       # 暂时无音效
	)


func _get_building_template() -> BuildingTemplate:
	"""获取兽人巢穴建筑模板"""
	var template = BuildingTemplate.new("兽人巢穴")
	template.building_type = BuildingTypes.ORC_LAIR
	template.description = "原始的3x3x3兽人巢穴，散发着野性的力量"
	
	# 创建原始结构
	template.create_orc_structure(BuildingTypes.ORC_LAIR)
	
	# 自定义兽人巢穴元素
	# 顶层：兽骨和战鼓
	template.set_component(0, 2, 0, BuildingComponents.ID_ORC_BONE)
	template.set_component(1, 2, 0, BuildingComponents.ID_WAR_DRUM)
	template.set_component(2, 2, 0, BuildingComponents.ID_ORC_BONE)
	template.set_component(0, 2, 1, BuildingComponents.ID_ORC_BONE)
	template.set_component(1, 2, 1, BuildingComponents.ID_WAR_DRUM)
	template.set_component(2, 2, 1, BuildingComponents.ID_ORC_BONE)
	template.set_component(0, 2, 2, BuildingComponents.ID_ORC_BONE)
	template.set_component(1, 2, 2, BuildingComponents.ID_WAR_DRUM)
	template.set_component(2, 2, 2, BuildingComponents.ID_ORC_BONE)
	
	# 中层：木栅和训练场
	template.set_component(0, 1, 0, BuildingComponents.ID_WOODEN_PALISADE)
	template.set_component(1, 1, 0, BuildingComponents.ID_WOODEN_PALISADE)
	template.set_component(2, 1, 0, BuildingComponents.ID_WOODEN_PALISADE)
	template.set_component(0, 1, 1, BuildingComponents.ID_WOODEN_PALISADE)
	template.set_component(1, 1, 1, BuildingComponents.ID_TRAINING_GROUND)
	template.set_component(2, 1, 1, BuildingComponents.ID_WOODEN_PALISADE)
	template.set_component(0, 1, 2, BuildingComponents.ID_WOODEN_PALISADE)
	template.set_component(1, 1, 2, BuildingComponents.ID_WOODEN_PALISADE)
	template.set_component(2, 1, 2, BuildingComponents.ID_WOODEN_PALISADE)
	
	# 底层：入口和基础
	template.set_component(1, 0, 0, BuildingComponents.ID_WOODEN_GATE)
	template.set_component(0, 0, 1, BuildingComponents.ID_WOODEN_PALISADE)
	template.set_component(1, 0, 1, BuildingComponents.ID_TRAINING_GROUND)
	template.set_component(2, 0, 1, BuildingComponents.ID_WOODEN_PALISADE)
	template.set_component(1, 0, 2, BuildingComponents.ID_WOODEN_PALISADE)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取兽人巢穴建筑配置"""
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
	config.wall_color = Color(0.4, 0.3, 0.2)  # 棕色
	config.roof_color = Color(0.3, 0.2, 0.1)    # 深棕色
	config.floor_color = Color(0.5, 0.4, 0.3)   # 浅棕色
	config.window_color = Color(0.8, 0.7, 0.6)  # 淡棕色窗户
	config.door_color = Color(0.3, 0.2, 0.1)    # 深棕色门
	
	return config


func _load_building_specific_components():
	"""加载兽人巢穴特定构件"""
	# 加载兽人构件
	_add_component_to_library("Orc_Bone", BuildingComponents.ID_ORC_BONE)
	_add_component_to_library("War_Drum", BuildingComponents.ID_WAR_DRUM)
	_add_component_to_library("Wooden_Palisade", BuildingComponents.ID_WOODEN_PALISADE)
	_add_component_to_library("Training_Ground", BuildingComponents.ID_TRAINING_GROUND)
	_add_component_to_library("Wooden_Gate", BuildingComponents.ID_WOODEN_GATE)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("🗡️ [OrcLair3D] 兽人巢穴3D准备就绪")
	
	# 启动兽人特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("🗡️ [OrcLair3D] 兽人巢穴3D建造完成")
	
	# 启动训练系统
	_start_training_system()
	
	# 启动兽人动画
	if construction_animator:
		construction_animator.play_function_animation("orc_training")


func _start_training_system():
	"""启动训练系统"""
	# 设置训练更新定时器
	var training_timer = Timer.new()
	training_timer.name = "TrainingTimer"
	training_timer.wait_time = 0.5  # 每0.5秒更新一次
	training_timer.timeout.connect(_update_training)
	training_timer.autostart = true
	add_child(training_timer)
	
	# 设置战鼓更新定时器
	var drum_timer = Timer.new()
	drum_timer.name = "DrumTimer"
	drum_timer.wait_time = 2.0  # 每2秒更新一次
	drum_timer.timeout.connect(_play_war_drum)
	drum_timer.autostart = true
	add_child(drum_timer)


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑"""
	# 调用父类方法
	super._update_3d_building_logic(delta)
	
	# 更新训练系统
	_update_training_system(delta)
	
	# 更新兽人特效
	_update_orc_effects(delta)


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
	# 训练中的兽人
	for trainee in current_trainees:
		if is_instance_valid(trainee):
			_train_orc(trainee, 0.5)


func _train_orc(orc: Node, delta: float):
	"""训练兽人"""
	if orc.has_method("apply_training"):
		var training_speed = war_drum_bonus * delta
		orc.apply_training(training_speed)
		
		# 播放训练特效
		_play_training_effect()


func _play_war_drum():
	"""播放战鼓"""
	# 播放战鼓特效
	_play_drum_effect()
	
	# 战鼓声效（如果有音效系统）
	# AudioManager.play_sound("war_drum")


func _play_training_effect():
	"""播放训练特效"""
	if not effect_manager:
		return
	
	# 创建训练粒子效果
	effect_manager._create_particle_effect("orc_training", global_position + Vector3(0, 0.5, 0), 1.0)


func _play_drum_effect():
	"""播放战鼓特效"""
	if not effect_manager:
		return
	
	# 创建战鼓粒子效果
	effect_manager._create_particle_effect("war_drum", global_position + Vector3(0, 2, 0), 2.0)


func can_accept_trainee() -> bool:
	"""检查是否可以接收新的训练者"""
	return current_trainees.size() < max_training_slots and status == BuildingStatus.COMPLETED


func add_trainee(orc: Node) -> bool:
	"""添加训练者"""
	if can_accept_trainee():
		current_trainees.append(orc)
		_play_training_start_effect()
		return true
	return false


func remove_trainee(orc: Node):
	"""移除训练者"""
	current_trainees.erase(orc)


func _play_training_start_effect():
	"""播放训练开始特效"""
	if not effect_manager:
		return
	
	# 创建训练开始粒子效果
	effect_manager._create_particle_effect("training_start", global_position + Vector3(0, 1, 0), 2.5)


func _update_orc_effects(delta: float):
	"""更新兽人特效"""
	# 更新战鼓动画
	_update_war_drum_animation(delta)
	
	# 更新训练场活动
	_update_training_ground_activity(delta)


func _update_war_drum_animation(delta: float):
	"""更新战鼓动画"""
	# 战鼓动画
	if construction_animator:
		construction_animator.play_function_animation("war_drum")
	
	# 根据训练强度调整战鼓发光
	var training_intensity = float(current_trainees.size()) / float(max_training_slots)
	
	if effect_manager and effect_manager.light_systems.has("drum_light"):
		var light = effect_manager.light_systems["drum_light"]
		if light and light.visible:
			light.light_energy = 0.4 + training_intensity * 0.8
			light.light_color = Color(0.8, 0.4, 0.2)  # 橙红色战鼓光


func _update_training_ground_activity(delta: float):
	"""更新训练场活动"""
	# 训练场活动动画
	if construction_animator:
		construction_animator.play_function_animation("training_activity")
	
	# 根据训练者数量调整活动强度
	var activity_intensity = float(current_trainees.size()) / float(max_training_slots)
	
	if effect_manager and effect_manager.particle_systems.has("training_particles"):
		var ps = effect_manager.particle_systems["training_particles"]
		if ps and ps.emitting:
			# 调整粒子强度
			ps.amount = int(3 + activity_intensity * 12)


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新兽人巢穴特定特效
	_update_orc_lair_effects(delta)


func _update_orc_lair_effects(delta: float):
	"""更新兽人巢穴特效"""
	# 兽人脉冲效果
	var training_count = current_trainees.size()
	var pulse_frequency = 1.0 + training_count * 0.5
	
	if effect_manager and effect_manager.light_systems.has("lair_glow"):
		var light = effect_manager.light_systems["lair_glow"]
		if light and light.visible:
			# 兽人脉冲
			light.light_energy = 0.6 + sin(Time.get_time_dict_from_system()["second"] * pulse_frequency) * 0.3
			light.light_color = Color(0.8, 0.4, 0.2)  # 橙红色兽人光


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加兽人巢穴特定信息
	base_info["orc_training_cost"] = orc_training_cost
	base_info["orc_training_time"] = orc_training_time
	base_info["max_training_slots"] = max_training_slots
	base_info["current_trainees_count"] = current_trainees.size()
	base_info["war_drum_bonus"] = war_drum_bonus
	base_info["can_accept_trainee"] = can_accept_trainee()
	base_info["training_capacity_ratio"] = float(current_trainees.size()) / float(max_training_slots)
	
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
	
	LogManager.info("💀 [OrcLair3D] 兽人巢穴被摧毁，所有特效已停止")
