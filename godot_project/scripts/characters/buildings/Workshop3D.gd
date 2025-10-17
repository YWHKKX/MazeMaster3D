extends Building3D
class_name Workshop3D

## 🏗️ 工坊3D - 3x3x3制造和陷阱建筑
## 基于Building3D，实现工坊的3x3x3渲染

# 制造系统
var crafting_slots: int = 3                    # 同时制造项目数
var crafting_speed_multiplier: float = 1.5     # 制造速度倍率
var trap_crafting_bonus: float = 0.3          # 陷阱制造加成（30%）
var equipment_crafting_bonus: float = 0.2     # 装备制造加成（20%）

# 制造状态
var active_crafting_projects: Array = []       # 当前制造项目
var available_recipes: Array = []              # 可用配方
var material_storage: Dictionary = {}          # 材料存储


func _init():
	"""初始化工坊3D"""
	super._init()
	
	# 基础属性
	building_name = "工坊"
	building_type = BuildingTypes.WORKSHOP
	max_health = 300
	health = max_health
	armor = 5
	building_size = Vector2(1, 1)  # 保持原有尺寸用于碰撞检测
	cost_gold = 400
	engineer_cost = 200
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
		windows = true,    # 有窗户（采光）
		door = true,       # 有门
		roof = true,       # 有屋顶
		decorations = true # 有装饰
	)
	
	# 材质配置（工业风格）
	building_3d_config.set_material_config(
		wall = Color(0.5, 0.4, 0.3),    # 棕色墙体
		roof = Color(0.4, 0.3, 0.2),    # 深棕色屋顶
		floor = Color(0.6, 0.5, 0.4)     # 浅棕色地板
	)
	
	# 特殊功能配置
	building_3d_config.set_special_config(
		lighting = true,    # 有光照
		particles = true,   # 有粒子特效
		animations = true,  # 有动画
		sound = false       # 暂时无音效
	)


func _get_building_template() -> BuildingTemplate:
	"""获取工坊建筑模板"""
	var template = BuildingTemplate.new("工坊")
	template.building_type = BuildingTypes.WORKSHOP
	template.description = "实用的3x3x3制造工坊，散发着工业的气息"
	
	# 创建工业结构
	template.create_workshop_structure(BuildingTypes.WORKSHOP)
	
	# 自定义工坊元素
	# 顶层：工具架和工作台
	template.set_component(0, 2, 0, BuildingComponents.ID_TOOL_RACK)
	template.set_component(1, 2, 0, BuildingComponents.ID_TOOL_RACK)
	template.set_component(2, 2, 0, BuildingComponents.ID_TOOL_RACK)
	template.set_component(0, 2, 1, BuildingComponents.ID_TOOL_RACK)
	template.set_component(1, 2, 1, BuildingComponents.ID_WORKBENCH)
	template.set_component(2, 2, 1, BuildingComponents.ID_TOOL_RACK)
	template.set_component(0, 2, 2, BuildingComponents.ID_TOOL_RACK)
	template.set_component(1, 2, 2, BuildingComponents.ID_TOOL_RACK)
	template.set_component(2, 2, 2, BuildingComponents.ID_TOOL_RACK)
	
	# 中层：工作台和锻造炉
	template.set_component(0, 1, 0, BuildingComponents.ID_WORKBENCH)
	template.set_component(1, 1, 0, BuildingComponents.ID_WORKBENCH)
	template.set_component(2, 1, 0, BuildingComponents.ID_WORKBENCH)
	template.set_component(0, 1, 1, BuildingComponents.ID_WORKBENCH)
	template.set_component(1, 1, 1, BuildingComponents.ID_FORGE)
	template.set_component(2, 1, 1, BuildingComponents.ID_WORKBENCH)
	template.set_component(0, 1, 2, BuildingComponents.ID_WORKBENCH)
	template.set_component(1, 1, 2, BuildingComponents.ID_WORKBENCH)
	template.set_component(2, 1, 2, BuildingComponents.ID_WORKBENCH)
	
	# 底层：材料堆和入口
	template.set_component(0, 0, 0, BuildingComponents.ID_MATERIAL_PILE)
	template.set_component(1, 0, 0, BuildingComponents.ID_MATERIAL_PILE)
	template.set_component(2, 0, 0, BuildingComponents.ID_MATERIAL_PILE)
	template.set_component(0, 0, 1, BuildingComponents.ID_MATERIAL_PILE)
	template.set_component(1, 0, 1, BuildingComponents.ID_WORKBENCH)
	template.set_component(2, 0, 1, BuildingComponents.ID_MATERIAL_PILE)
	template.set_component(0, 0, 2, BuildingComponents.ID_MATERIAL_PILE)
	template.set_component(1, 0, 2, BuildingComponents.ID_MATERIAL_PILE)
	template.set_component(2, 0, 2, BuildingComponents.ID_MATERIAL_PILE)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取工坊建筑配置"""
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
	config.wall_color = Color(0.5, 0.4, 0.3)  # 棕色
	config.roof_color = Color(0.4, 0.3, 0.2)    # 深棕色
	config.floor_color = Color(0.6, 0.5, 0.4)   # 浅棕色
	config.window_color = Color(0.8, 0.7, 0.6)  # 淡棕色窗户
	config.door_color = Color(0.4, 0.3, 0.2)    # 深棕色门
	
	return config


func _load_building_specific_components():
	"""加载工坊特定构件"""
	# 加载工业构件
	_add_component_to_library("Tool_Rack", BuildingComponents.ID_TOOL_RACK)
	_add_component_to_library("Workbench", BuildingComponents.ID_WORKBENCH)
	_add_component_to_library("Forge", BuildingComponents.ID_FORGE)
	_add_component_to_library("Material_Pile", BuildingComponents.ID_MATERIAL_PILE)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("🔨 [Workshop3D] 工坊3D准备就绪")
	
	# 启动工坊特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("🔨 [Workshop3D] 工坊3D建造完成")
	
	# 启动制造系统
	_start_crafting_system()
	
	# 启动工坊动画
	if construction_animator:
		construction_animator.play_function_animation("crafting_activity")


func _start_crafting_system():
	"""启动制造系统"""
	# 设置制造更新定时器
	var crafting_timer = Timer.new()
	crafting_timer.name = "CraftingTimer"
	crafting_timer.wait_time = 0.5  # 每0.5秒更新一次
	crafting_timer.timeout.connect(_update_crafting)
	crafting_timer.autostart = true
	add_child(crafting_timer)
	
	# 设置锻造更新定时器
	var forge_timer = Timer.new()
	forge_timer.name = "ForgeTimer"
	forge_timer.wait_time = 2.0  # 每2秒更新一次
	forge_timer.timeout.connect(_update_forge)
	forge_timer.autostart = true
	add_child(forge_timer)
	
	# 初始化材料存储
	_initialize_material_storage()


func _initialize_material_storage():
	"""初始化材料存储"""
	material_storage = {
		"wood": 0,
		"stone": 0,
		"metal": 0,
		"cloth": 0,
		"leather": 0
	}


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑"""
	# 调用父类方法
	super._update_3d_building_logic(delta)
	
	# 更新制造系统
	_update_crafting_system(delta)
	
	# 更新工坊特效
	_update_workshop_effects(delta)


func _update_crafting_system(delta: float):
	"""更新制造系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 更新制造进度
	_update_crafting_progress(delta)


func _update_crafting_progress(delta: float):
	"""更新制造进度"""
	# 这里可以添加制造进度的视觉指示
	pass


func _update_crafting():
	"""更新制造"""
	# 处理当前活跃的制造项目
	for project in active_crafting_projects:
		if is_instance_valid(project):
			_advance_crafting_project(project, 0.5)


func _advance_crafting_project(project: Dictionary, delta: float):
	"""推进制造项目"""
	if not project.has("progress"):
		project["progress"] = 0.0
	
	var speed_bonus = crafting_speed_multiplier
	if project.get("type") == "trap":
		speed_bonus += trap_crafting_bonus
	elif project.get("type") == "equipment":
		speed_bonus += equipment_crafting_bonus
	
	project["progress"] += delta * speed_bonus
	
	# 检查项目是否完成
	if project["progress"] >= 100.0:
		_complete_crafting_project(project)


func _complete_crafting_project(project: Dictionary):
	"""完成制造项目"""
	active_crafting_projects.erase(project)
	
	# 播放完成特效
	_play_crafting_complete_effect()
	
	LogManager.info("🔨 [Workshop3D] 制造项目完成: %s" % project.get("name", "未知"))


func _update_forge():
	"""更新锻造炉"""
	# 播放锻造特效
	_play_forge_effect()
	
	# 锻造声效（如果有音效系统）
	# AudioManager.play_sound("forge_hammer")


func _play_forge_effect():
	"""播放锻造特效"""
	if not effect_manager:
		return
	
	# 创建锻造粒子效果
	effect_manager._create_particle_effect("forge_fire", global_position + Vector3(0, 1, 0), 2.0)


func _play_crafting_complete_effect():
	"""播放制造完成特效"""
	if not effect_manager:
		return
	
	# 创建制造完成粒子效果
	effect_manager._create_particle_effect("crafting_complete", global_position + Vector3(0, 1.5, 0), 3.0)


func can_start_crafting() -> bool:
	"""检查是否可以开始新的制造项目"""
	return active_crafting_projects.size() < crafting_slots and status == BuildingStatus.COMPLETED


func start_crafting_project(project_name: String, project_type: String) -> bool:
	"""开始制造项目"""
	if can_start_crafting():
		var project = {
			"name": project_name,
			"type": project_type,
			"progress": 0.0,
			"start_time": Time.get_time_dict_from_system()["second"]
		}
		active_crafting_projects.append(project)
		_play_crafting_start_effect()
		return true
	return false


func _play_crafting_start_effect():
	"""播放制造开始特效"""
	if not effect_manager:
		return
	
	# 创建制造开始粒子效果
	effect_manager._create_particle_effect("crafting_start", global_position + Vector3(0, 1, 0), 2.5)


func _update_workshop_effects(delta: float):
	"""更新工坊特效"""
	# 更新锻造炉动画
	_update_forge_animation(delta)
	
	# 更新工作台活动
	_update_workbench_activity(delta)


func _update_forge_animation(delta: float):
	"""更新锻造炉动画"""
	# 锻造炉动画
	if construction_animator:
		construction_animator.play_function_animation("forge_fire")
	
	# 根据制造强度调整锻造炉发光
	var crafting_intensity = float(active_crafting_projects.size()) / float(crafting_slots)
	
	if effect_manager and effect_manager.light_systems.has("forge_light"):
		var light = effect_manager.light_systems["forge_light"]
		if light and light.visible:
			light.light_energy = 0.6 + crafting_intensity * 1.0
			light.light_color = Color(1.0, 0.5, 0.2)  # 橙红色锻造光


func _update_workbench_activity(delta: float):
	"""更新工作台活动"""
	# 工作台活动动画
	if construction_animator:
		construction_animator.play_function_animation("workbench_activity")
	
	# 根据制造项目数量调整活动强度
	var activity_intensity = float(active_crafting_projects.size()) / float(crafting_slots)
	
	if effect_manager and effect_manager.particle_systems.has("crafting_particles"):
		var ps = effect_manager.particle_systems["crafting_particles"]
		if ps and ps.emitting:
			# 调整粒子强度
			ps.amount = int(4 + activity_intensity * 10)


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新工坊特定特效
	_update_workshop_specific_effects(delta)


func _update_workshop_specific_effects(delta: float):
	"""更新工坊特定特效"""
	# 工坊脉冲效果
	var crafting_count = active_crafting_projects.size()
	var pulse_frequency = 1.0 + crafting_count * 0.4
	
	if effect_manager and effect_manager.light_systems.has("workshop_glow"):
		var light = effect_manager.light_systems["workshop_glow"]
		if light and light.visible:
			# 工坊脉冲
			light.light_energy = 0.5 + sin(Time.get_time_dict_from_system()["second"] * pulse_frequency) * 0.3
			light.light_color = Color(1.0, 0.6, 0.3)  # 橙黄色工坊光


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加工坊特定信息
	base_info["crafting_slots"] = crafting_slots
	base_info["crafting_speed_multiplier"] = crafting_speed_multiplier
	base_info["trap_crafting_bonus"] = trap_crafting_bonus
	base_info["equipment_crafting_bonus"] = equipment_crafting_bonus
	base_info["active_projects_count"] = active_crafting_projects.size()
	base_info["can_start_crafting"] = can_start_crafting()
	base_info["crafting_capacity_ratio"] = float(active_crafting_projects.size()) / float(crafting_slots)
	base_info["material_storage"] = material_storage
	
	return base_info


func _on_destroyed():
	"""建筑被摧毁时的回调（重写父类方法）"""
	# 调用父类方法
	super._on_destroyed()
	
	# 停止所有制造项目
	active_crafting_projects.clear()
	
	# 停止所有特效
	if effect_manager:
		effect_manager.stop_functional_effects()
	
	# 停止所有动画
	if construction_animator:
		construction_animator.stop_all_animations()
	
	LogManager.info("💀 [Workshop3D] 工坊被摧毁，所有特效已停止")
