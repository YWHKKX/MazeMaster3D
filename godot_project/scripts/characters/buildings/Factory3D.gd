extends Building3D
class_name Factory3D

## 🏗️ 工厂3D - 3x3x3大规模生产建筑
## 基于Building3D，实现工厂的3x3x3渲染

# 生产系统
var production_lines: int = 4                     # 生产线数量
var production_efficiency: float = 2.0           # 生产效率倍率
var automation_level: float = 0.8                # 自动化程度（80%）
var quality_control_bonus: float = 0.25          # 质量控制加成（25%）

# 生产状态
var active_production_lines: Array = []          # 当前活跃生产线
var production_queue: Array = []                 # 生产队列
var resource_consumption_rate: float = 1.5       # 资源消耗速度


func _init():
	"""初始化工厂3D"""
	super._init()
	
	# 基础属性
	building_name = "工厂"
	building_type = BuildingTypes.FACTORY
	max_health = 500
	health = max_health
	armor = 6
	building_size = Vector2(1, 1)  # 保持原有尺寸用于碰撞检测
	cost_gold = 1200
	engineer_cost = 600
	build_time = 400.0
	engineer_required = 4
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
	
	# 材质配置（工业风格）
	building_3d_config.set_material_config(
		wall = Color(0.4, 0.4, 0.4),    # 灰色墙体
		roof = Color(0.3, 0.3, 0.3),    # 深灰色屋顶
		floor = Color(0.5, 0.5, 0.5)     # 浅灰色地板
	)
	
	# 特殊功能配置
	building_3d_config.set_special_config(
		lighting = true,    # 有光照
		particles = true,   # 有粒子特效
		animations = true,  # 有动画
		sound = false       # 暂时无音效
	)


func _get_building_template() -> BuildingTemplate:
	"""获取工厂建筑模板"""
	var template = BuildingTemplate.new("工厂")
	template.building_type = BuildingTypes.FACTORY
	template.description = "现代化的3x3x3工业工厂，散发着机械的气息"
	
	# 创建工业结构
	template.create_factory_structure(BuildingTypes.FACTORY)
	
	# 自定义工厂元素
	# 顶层：烟囱和通风系统
	template.set_component(0, 2, 0, BuildingComponents.ID_SMOKESTACK)
	template.set_component(1, 2, 0, BuildingComponents.ID_VENTILATION)
	template.set_component(2, 2, 0, BuildingComponents.ID_SMOKESTACK)
	template.set_component(0, 2, 1, BuildingComponents.ID_VENTILATION)
	template.set_component(1, 2, 1, BuildingComponents.ID_CONTROL_ROOM)
	template.set_component(2, 2, 1, BuildingComponents.ID_VENTILATION)
	template.set_component(0, 2, 2, BuildingComponents.ID_SMOKESTACK)
	template.set_component(1, 2, 2, BuildingComponents.ID_VENTILATION)
	template.set_component(2, 2, 2, BuildingComponents.ID_SMOKESTACK)
	
	# 中层：生产线和机械
	template.set_component(0, 1, 0, BuildingComponents.ID_ASSEMBLY_LINE)
	template.set_component(1, 1, 0, BuildingComponents.ID_CONVEYOR_BELT)
	template.set_component(2, 1, 0, BuildingComponents.ID_ASSEMBLY_LINE)
	template.set_component(0, 1, 1, BuildingComponents.ID_CONVEYOR_BELT)
	template.set_component(1, 1, 1, BuildingComponents.ID_INDUSTRIAL_MACHINE)
	template.set_component(2, 1, 1, BuildingComponents.ID_CONVEYOR_BELT)
	template.set_component(0, 1, 2, BuildingComponents.ID_ASSEMBLY_LINE)
	template.set_component(1, 1, 2, BuildingComponents.ID_CONVEYOR_BELT)
	template.set_component(2, 1, 2, BuildingComponents.ID_ASSEMBLY_LINE)
	
	# 底层：原料存储和成品输出
	template.set_component(0, 0, 0, BuildingComponents.ID_RAW_MATERIALS)
	template.set_component(1, 0, 0, BuildingComponents.ID_RAW_MATERIALS)
	template.set_component(2, 0, 0, BuildingComponents.ID_RAW_MATERIALS)
	template.set_component(0, 0, 1, BuildingComponents.ID_FINISHED_GOODS)
	template.set_component(1, 0, 1, BuildingComponents.ID_QUALITY_CONTROL)
	template.set_component(2, 0, 1, BuildingComponents.ID_FINISHED_GOODS)
	template.set_component(0, 0, 2, BuildingComponents.ID_RAW_MATERIALS)
	template.set_component(1, 0, 2, BuildingComponents.ID_RAW_MATERIALS)
	template.set_component(2, 0, 2, BuildingComponents.ID_RAW_MATERIALS)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取工厂建筑配置"""
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
	config.wall_color = Color(0.4, 0.4, 0.4)  # 灰色
	config.roof_color = Color(0.3, 0.3, 0.3)    # 深灰色
	config.floor_color = Color(0.5, 0.5, 0.5)   # 浅灰色
	config.window_color = Color(0.7, 0.7, 0.7)  # 淡灰色窗户
	config.door_color = Color(0.3, 0.3, 0.3)    # 深灰色门
	
	return config


func _load_building_specific_components():
	"""加载工厂特定构件"""
	# 加载工业构件
	_add_component_to_library("Smokestack", BuildingComponents.ID_SMOKESTACK)
	_add_component_to_library("Ventilation", BuildingComponents.ID_VENTILATION)
	_add_component_to_library("Control_Room", BuildingComponents.ID_CONTROL_ROOM)
	_add_component_to_library("Assembly_Line", BuildingComponents.ID_ASSEMBLY_LINE)
	_add_component_to_library("Conveyor_Belt", BuildingComponents.ID_CONVEYOR_BELT)
	_add_component_to_library("Industrial_Machine", BuildingComponents.ID_INDUSTRIAL_MACHINE)
	_add_component_to_library("Raw_Materials", BuildingComponents.ID_RAW_MATERIALS)
	_add_component_to_library("Finished_Goods", BuildingComponents.ID_FINISHED_GOODS)
	_add_component_to_library("Quality_Control", BuildingComponents.ID_QUALITY_CONTROL)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("🏭 [Factory3D] 工厂3D准备就绪")
	
	# 启动工厂特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("🏭 [Factory3D] 工厂3D建造完成")
	
	# 启动生产系统
	_start_production_system()
	
	# 启动工厂动画
	if construction_animator:
		construction_animator.play_function_animation("factory_production")


func _start_production_system():
	"""启动生产系统"""
	# 设置生产更新定时器
	var production_timer = Timer.new()
	production_timer.name = "ProductionTimer"
	production_timer.wait_time = 0.5  # 每0.5秒更新一次
	production_timer.timeout.connect(_update_production)
	production_timer.autostart = true
	add_child(production_timer)
	
	# 设置质量控制定时器
	var quality_timer = Timer.new()
	quality_timer.name = "QualityTimer"
	quality_timer.wait_time = 3.0  # 每3秒更新一次
	quality_timer.timeout.connect(_update_quality_control)
	quality_timer.autostart = true
	add_child(quality_timer)
	
	# 初始化生产线
	_initialize_production_lines()


func _initialize_production_lines():
	"""初始化生产线"""
	for i in range(production_lines):
		var line = {
			"id": i,
			"status": "idle",
			"current_product": null,
			"progress": 0.0,
			"efficiency": production_efficiency
		}
		active_production_lines.append(line)


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑"""
	# 调用父类方法
	super._update_3d_building_logic(delta)
	
	# 更新生产系统
	_update_production_system(delta)
	
	# 更新工厂特效
	_update_factory_effects(delta)


func _update_production_system(delta: float):
	"""更新生产系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 更新生产进度
	_update_production_progress(delta)


func _update_production_progress(delta: float):
	"""更新生产进度"""
	# 这里可以添加生产进度的视觉指示
	pass


func _update_production():
	"""更新生产"""
	# 处理当前活跃的生产线
	for line in active_production_lines:
		if is_instance_valid(line):
			_process_production_line(line, 0.5)


func _process_production_line(line: Dictionary, delta: float):
	"""处理生产线"""
	if line["status"] == "idle" and production_queue.size() > 0:
		# 开始新的生产任务
		_start_production_task(line)
	elif line["status"] == "producing":
		# 继续当前生产任务
		_advance_production(line, delta)


func _start_production_task(line: Dictionary):
	"""开始生产任务"""
	var task = production_queue.pop_front()
	line["current_product"] = task
	line["status"] = "producing"
	line["progress"] = 0.0
	
	_play_production_start_effect()
	LogManager.info("🏭 [Factory3D] 生产线 %d 开始生产: %s" % [line["id"], task.get("name", "未知产品")])


func _advance_production(line: Dictionary, delta: float):
	"""推进生产进度"""
	var efficiency = line["efficiency"] * (1.0 + automation_level)
	line["progress"] += delta * efficiency
	
	# 检查生产是否完成
	if line["progress"] >= 100.0:
		_complete_production(line)


func _complete_production(line: Dictionary):
	"""完成生产"""
	var product = line["current_product"]
	line["current_product"] = null
	line["status"] = "idle"
	line["progress"] = 0.0
	
	# 播放完成特效
	_play_production_complete_effect()
	
	LogManager.info("🏭 [Factory3D] 生产线 %d 完成生产: %s" % [line["id"], product.get("name", "未知产品")])


func _update_quality_control():
	"""更新质量控制"""
	# 播放质量控制特效
	_play_quality_control_effect()
	
	# 质量控制声效（如果有音效系统）
	# AudioManager.play_sound("quality_check")


func _play_production_start_effect():
	"""播放生产开始特效"""
	if not effect_manager:
		return
	
	# 创建生产开始粒子效果
	effect_manager._create_particle_effect("production_start", global_position + Vector3(0, 1, 0), 2.0)


func _play_production_complete_effect():
	"""播放生产完成特效"""
	if not effect_manager:
		return
	
	# 创建生产完成粒子效果
	effect_manager._create_particle_effect("production_complete", global_position + Vector3(0, 1.5, 0), 3.0)


func _play_quality_control_effect():
	"""播放质量控制特效"""
	if not effect_manager:
		return
	
	# 创建质量控制粒子效果
	effect_manager._create_particle_effect("quality_control", global_position + Vector3(0, 0.5, 0), 1.5)


func can_add_production_task() -> bool:
	"""检查是否可以添加新的生产任务"""
	return production_queue.size() < production_lines * 2 and status == BuildingStatus.COMPLETED


func add_production_task(task_name: String, task_type: String) -> bool:
	"""添加生产任务"""
	if can_add_production_task():
		var task = {
			"name": task_name,
			"type": task_type,
			"priority": 1,
			"quality_target": 0.8 + quality_control_bonus
		}
		production_queue.append(task)
		return true
	return false


func _update_factory_effects(delta: float):
	"""更新工厂特效"""
	# 更新烟囱动画
	_update_smokestack_animation(delta)
	
	# 更新生产线活动
	_update_assembly_line_activity(delta)


func _update_smokestack_animation(delta: float):
	"""更新烟囱动画"""
	# 烟囱动画
	if construction_animator:
		construction_animator.play_function_animation("smokestack_smoke")
	
	# 根据生产强度调整烟囱发光
	var production_intensity = float(active_production_lines.size()) / float(production_lines)
	
	if effect_manager and effect_manager.light_systems.has("smokestack_light"):
		var light = effect_manager.light_systems["smokestack_light"]
		if light and light.visible:
			light.light_energy = 0.5 + production_intensity * 0.8
			light.light_color = Color(0.8, 0.8, 0.8)  # 灰白色烟囱光


func _update_assembly_line_activity(delta: float):
	"""更新生产线活动"""
	# 生产线活动动画
	if construction_animator:
		construction_animator.play_function_animation("assembly_line_movement")
	
	# 根据生产任务数量调整活动强度
	var activity_intensity = float(production_queue.size()) / float(production_lines * 2)
	
	if effect_manager and effect_manager.particle_systems.has("factory_particles"):
		var ps = effect_manager.particle_systems["factory_particles"]
		if ps and ps.emitting:
			# 调整粒子强度
			ps.amount = int(5 + activity_intensity * 15)


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新工厂特定特效
	_update_factory_specific_effects(delta)


func _update_factory_specific_effects(delta: float):
	"""更新工厂特定特效"""
	# 工厂脉冲效果
	var production_count = production_queue.size()
	var pulse_frequency = 1.2 + production_count * 0.3
	
	if effect_manager and effect_manager.light_systems.has("factory_glow"):
		var light = effect_manager.light_systems["factory_glow"]
		if light and light.visible:
			# 工厂脉冲
			light.light_energy = 0.6 + sin(Time.get_time_dict_from_system()["second"] * pulse_frequency) * 0.3
			light.light_color = Color(0.8, 0.8, 0.8)  # 灰白色工厂光


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加工厂特定信息
	base_info["production_lines"] = production_lines
	base_info["production_efficiency"] = production_efficiency
	base_info["automation_level"] = automation_level
	base_info["quality_control_bonus"] = quality_control_bonus
	base_info["active_lines_count"] = active_production_lines.size()
	base_info["queue_size"] = production_queue.size()
	base_info["can_add_task"] = can_add_production_task()
	base_info["production_capacity_ratio"] = float(production_queue.size()) / float(production_lines * 2)
	
	return base_info


func _on_destroyed():
	"""建筑被摧毁时的回调（重写父类方法）"""
	# 调用父类方法
	super._on_destroyed()
	
	# 停止所有生产线
	active_production_lines.clear()
	production_queue.clear()
	
	# 停止所有特效
	if effect_manager:
		effect_manager.stop_functional_effects()
	
	# 停止所有动画
	if construction_animator:
		construction_animator.stop_all_animations()
	
	LogManager.info("💀 [Factory3D] 工厂被摧毁，所有特效已停止")
