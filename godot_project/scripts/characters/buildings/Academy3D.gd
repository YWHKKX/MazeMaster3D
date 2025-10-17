extends Building3D
class_name Academy3D

## 🏗️ 学院3D - 3x3x3教育建筑
## 基于Building3D，实现学院的3x3x3渲染

# 教育系统
var student_capacity: int = 8                    # 学生容量
var knowledge_generation_rate: float = 1.8       # 知识生成速度
var teaching_efficiency: float = 1.6             # 教学效率倍率
var research_bonus: float = 0.4                  # 研究加成（40%）

# 教育状态
var current_students: Array = []                  # 当前学生
var research_projects: Array = []                 # 研究项目
var academy_prestige: float = 0.0                # 学院声望
var knowledge_storage: int = 0                    # 知识存储


func _init():
	"""初始化学院3D"""
	super._init()
	
	# 基础属性
	building_name = "学院"
	building_type = BuildingTypes.ACADEMY
	max_health = 320
	health = max_health
	armor = 4
	building_size = Vector2(1, 1)  # 保持原有尺寸用于碰撞检测
	cost_gold = 700
	engineer_cost = 350
	build_time = 280.0
	engineer_required = 3
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
	
	# 材质配置（学术风格）
	building_3d_config.set_material_config(
		wall = Color(0.8, 0.8, 0.9),    # 浅蓝色墙体
		roof = Color(0.6, 0.7, 0.8),    # 深蓝色屋顶
		floor = Color(0.9, 0.9, 0.95)    # 白色地板
	)
	
	# 特殊功能配置
	building_3d_config.set_special_config(
		lighting = true,    # 有光照
		particles = true,   # 有粒子特效
		animations = true,  # 有动画
		sound = false       # 暂时无音效
	)


func _get_building_template() -> BuildingTemplate:
	"""获取学院建筑模板"""
	var template = BuildingTemplate.new("学院")
	template.building_type = BuildingTypes.ACADEMY
	template.description = "庄严的3x3x3教育学院，散发着智慧的气息"
	
	# 创建学术结构
	template.create_academy_structure(BuildingTypes.ACADEMY)
	
	# 自定义学院元素
	# 顶层：钟楼和学术旗帜
	template.set_component(0, 2, 0, BuildingComponents.ID_ACADEMY_TOWER)
	template.set_component(1, 2, 0, BuildingComponents.ID_ACADEMIC_BANNER)
	template.set_component(2, 2, 0, BuildingComponents.ID_ACADEMY_TOWER)
	template.set_component(0, 2, 1, BuildingComponents.ID_ACADEMIC_BANNER)
	template.set_component(1, 2, 1, BuildingComponents.ID_WISDOM_TOWER)
	template.set_component(2, 2, 1, BuildingComponents.ID_ACADEMIC_BANNER)
	template.set_component(0, 2, 2, BuildingComponents.ID_ACADEMY_TOWER)
	template.set_component(1, 2, 2, BuildingComponents.ID_ACADEMIC_BANNER)
	template.set_component(2, 2, 2, BuildingComponents.ID_ACADEMY_TOWER)
	
	# 中层：教室和实验室
	template.set_component(0, 1, 0, BuildingComponents.ID_CLASSROOM_DESK)
	template.set_component(1, 1, 0, BuildingComponents.ID_TEACHER_PODIUM)
	template.set_component(2, 1, 0, BuildingComponents.ID_CLASSROOM_DESK)
	template.set_component(0, 1, 1, BuildingComponents.ID_CLASSROOM_DESK)
	template.set_component(1, 1, 1, BuildingComponents.ID_RESEARCH_LAB)
	template.set_component(2, 1, 1, BuildingComponents.ID_CLASSROOM_DESK)
	template.set_component(0, 1, 2, BuildingComponents.ID_CLASSROOM_DESK)
	template.set_component(1, 1, 2, BuildingComponents.ID_TEACHER_PODIUM)
	template.set_component(2, 1, 2, BuildingComponents.ID_CLASSROOM_DESK)
	
	# 底层：图书馆和入口
	template.set_component(0, 0, 0, BuildingComponents.ID_ACADEMIC_LIBRARY)
	template.set_component(1, 0, 0, BuildingComponents.ID_ACADEMIC_LIBRARY)
	template.set_component(2, 0, 0, BuildingComponents.ID_ACADEMIC_LIBRARY)
	template.set_component(0, 0, 1, BuildingComponents.ID_ACADEMIC_LIBRARY)
	template.set_component(1, 0, 1, BuildingComponents.ID_ACADEMY_ENTRANCE)
	template.set_component(2, 0, 1, BuildingComponents.ID_ACADEMIC_LIBRARY)
	template.set_component(0, 0, 2, BuildingComponents.ID_ACADEMIC_LIBRARY)
	template.set_component(1, 0, 2, BuildingComponents.ID_ACADEMIC_LIBRARY)
	template.set_component(2, 0, 2, BuildingComponents.ID_ACADEMIC_LIBRARY)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取学院建筑配置"""
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
	config.wall_color = Color(0.8, 0.8, 0.9)  # 浅蓝色
	config.roof_color = Color(0.6, 0.7, 0.8)    # 深蓝色
	config.floor_color = Color(0.9, 0.9, 0.95)   # 白色
	config.window_color = Color(0.9, 0.95, 1.0)  # 淡蓝色窗户
	config.door_color = Color(0.7, 0.7, 0.8)    # 蓝色门
	
	return config


func _load_building_specific_components():
	"""加载学院特定构件"""
	# 加载学术构件
	_add_component_to_library("Academy_Tower", BuildingComponents.ID_ACADEMY_TOWER)
	_add_component_to_library("Academic_Banner", BuildingComponents.ID_ACADEMIC_BANNER)
	_add_component_to_library("Wisdom_Tower", BuildingComponents.ID_WISDOM_TOWER)
	_add_component_to_library("Classroom_Desk", BuildingComponents.ID_CLASSROOM_DESK)
	_add_component_to_library("Teacher_Podium", BuildingComponents.ID_TEACHER_PODIUM)
	_add_component_to_library("Research_Lab", BuildingComponents.ID_RESEARCH_LAB)
	_add_component_to_library("Academic_Library", BuildingComponents.ID_ACADEMIC_LIBRARY)
	_add_component_to_library("Academy_Entrance", BuildingComponents.ID_ACADEMY_ENTRANCE)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("🏫 [Academy3D] 学院3D准备就绪")
	
	# 启动学院特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("🏫 [Academy3D] 学院3D建造完成")
	
	# 启动教育系统
	_start_education_system()
	
	# 启动学院动画
	if construction_animator:
		construction_animator.play_function_animation("academic_activity")


func _start_education_system():
	"""启动教育系统"""
	# 设置教育更新定时器
	var education_timer = Timer.new()
	education_timer.name = "EducationTimer"
	education_timer.wait_time = 1.0  # 每秒更新一次
	education_timer.timeout.connect(_update_education)
	education_timer.autostart = true
	add_child(education_timer)
	
	# 设置知识生成定时器
	var knowledge_timer = Timer.new()
	knowledge_timer.name = "KnowledgeTimer"
	knowledge_timer.wait_time = 3.0  # 每3秒生成一次
	knowledge_timer.timeout.connect(_generate_knowledge)
	knowledge_timer.autostart = true
	add_child(knowledge_timer)
	
	# 初始化学院声望
	academy_prestige = 60.0


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑"""
	# 调用父类方法
	super._update_3d_building_logic(delta)
	
	# 更新教育系统
	_update_education_system(delta)
	
	# 更新学院特效
	_update_academy_effects(delta)


func _update_education_system(delta: float):
	"""更新教育系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 更新教学进度
	_update_teaching_progress(delta)


func _update_teaching_progress(delta: float):
	"""更新教学进度"""
	# 这里可以添加教学进度的视觉指示
	pass


func _update_education():
	"""更新教育"""
	# 教育当前学生
	for student in current_students:
		if is_instance_valid(student):
			_teach_student(student, 1.0)
	
	# 处理研究项目
	_process_research_projects()


func _teach_student(student: Node, delta: float):
	"""教育学生"""
	if student.has_method("apply_teaching"):
		var teaching_amount = teaching_efficiency * delta
		if academy_prestige > 80.0:
			teaching_amount *= 1.2  # 高声望加成
		
		student.apply_teaching(teaching_amount)
		
		# 播放教学特效
		_play_teaching_effect()


func _process_research_projects():
	"""处理研究项目"""
	for project in research_projects:
		if is_instance_valid(project):
			_advance_research_project(project, 1.0)


func _advance_research_project(project: Dictionary, delta: float):
	"""推进研究项目"""
	if not project.has("progress"):
		project["progress"] = 0.0
	
	var research_speed = teaching_efficiency * (1.0 + research_bonus)
	project["progress"] += delta * research_speed
	
	# 检查研究是否完成
	if project["progress"] >= 100.0:
		_complete_research_project(project)


func _complete_research_project(project: Dictionary):
	"""完成研究项目"""
	var project_value = project.get("value", 100)
	research_projects.erase(project)
	
	# 增加学院声望和知识存储
	academy_prestige += project_value * 0.02
	knowledge_storage += project_value
	
	# 播放完成特效
	_play_research_complete_effect()
	
	LogManager.info("🏫 [Academy3D] 研究项目完成: %s, 价值: %d" % [project.get("name", "未知"), project_value])


func _generate_knowledge():
	"""生成知识"""
	var knowledge_generated = int(knowledge_generation_rate * (1.0 + academy_prestige * 0.01))
	knowledge_storage += knowledge_generated
	knowledge_storage = min(knowledge_storage, 1000)  # 最大存储1000
	
	# 播放知识生成特效
	_play_knowledge_generation_effect()


func _play_teaching_effect():
	"""播放教学特效"""
	if not effect_manager:
		return
	
	# 创建教学粒子效果
	effect_manager._create_particle_effect("teaching", global_position + Vector3(0, 1, 0), 1.5)


func _play_research_complete_effect():
	"""播放研究完成特效"""
	if not effect_manager:
		return
	
	# 创建研究完成粒子效果
	effect_manager._create_particle_effect("research_complete", global_position + Vector3(0, 2, 0), 4.0)


func _play_knowledge_generation_effect():
	"""播放知识生成特效"""
	if not effect_manager:
		return
	
	# 创建知识生成粒子效果
	effect_manager._create_particle_effect("knowledge_generation", global_position + Vector3(0, 1.5, 0), 2.5)


func can_admit_student() -> bool:
	"""检查是否可以接收新学生"""
	return current_students.size() < student_capacity and status == BuildingStatus.COMPLETED


func admit_student(student: Node) -> bool:
	"""接收学生"""
	if can_admit_student():
		current_students.append(student)
		_play_student_admission_effect()
		return true
	return false


func graduate_student(student: Node):
	"""毕业学生"""
	current_students.erase(student)
	academy_prestige += 5.0  # 毕业生增加声望


func start_research_project(project_name: String, project_type: String, project_value: int) -> bool:
	"""开始研究项目"""
	var project = {
		"name": project_name,
		"type": project_type,
		"value": project_value,
		"progress": 0.0,
		"start_time": Time.get_time_dict_from_system()["second"]
	}
	research_projects.append(project)
	_play_research_start_effect()
	return true


func _play_student_admission_effect():
	"""播放学生入学特效"""
	if not effect_manager:
		return
	
	# 创建学生入学粒子效果
	effect_manager._create_particle_effect("student_admission", global_position + Vector3(0, 1, 0), 2.0)


func _play_research_start_effect():
	"""播放研究开始特效"""
	if not effect_manager:
		return
	
	# 创建研究开始粒子效果
	effect_manager._create_particle_effect("research_start", global_position + Vector3(0, 1.5, 0), 3.0)


func _update_academy_effects(delta: float):
	"""更新学院特效"""
	# 更新智慧塔动画
	_update_wisdom_tower_animation(delta)
	
	# 更新教室活动
	_update_classroom_activity(delta)


func _update_wisdom_tower_animation(delta: float):
	"""更新智慧塔动画"""
	# 智慧塔动画
	if construction_animator:
		construction_animator.play_function_animation("wisdom_tower")
	
	# 根据学生数量和研究项目调整智慧塔发光
	var academic_intensity = (float(current_students.size()) / float(student_capacity) + 
							 float(research_projects.size()) / 3.0) * 0.5
	
	if effect_manager and effect_manager.light_systems.has("wisdom_tower_light"):
		var light = effect_manager.light_systems["wisdom_tower_light"]
		if light and light.visible:
			light.light_energy = 0.7 + academic_intensity * 1.0
			light.light_color = Color(0.7, 0.8, 1.0)  # 淡蓝色智慧光


func _update_classroom_activity(delta: float):
	"""更新教室活动"""
	# 教室活动动画
	if construction_animator:
		construction_animator.play_function_animation("classroom_activity")
	
	# 根据学生数量和研究项目调整活动强度
	var activity_intensity = float(current_students.size()) / float(student_capacity)
	
	if effect_manager and effect_manager.particle_systems.has("academic_particles"):
		var ps = effect_manager.particle_systems["academic_particles"]
		if ps and ps.emitting:
			# 调整粒子强度
			ps.amount = int(3 + activity_intensity * 12)


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新学院特定特效
	_update_academy_specific_effects(delta)


func _update_academy_specific_effects(delta: float):
	"""更新学院特定特效"""
	# 学院脉冲效果
	var academic_count = current_students.size() + research_projects.size()
	var pulse_frequency = 1.0 + academic_count * 0.3
	
	if effect_manager and effect_manager.light_systems.has("academy_glow"):
		var light = effect_manager.light_systems["academy_glow"]
		if light and light.visible:
			# 学院脉冲
			light.light_energy = 0.6 + sin(Time.get_time_dict_from_system()["second"] * pulse_frequency) * 0.3
			light.light_color = Color(0.8, 0.9, 1.0)  # 淡蓝色学院光


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加学院特定信息
	base_info["student_capacity"] = student_capacity
	base_info["knowledge_generation_rate"] = knowledge_generation_rate
	base_info["teaching_efficiency"] = teaching_efficiency
	base_info["research_bonus"] = research_bonus
	base_info["current_students_count"] = current_students.size()
	base_info["research_projects_count"] = research_projects.size()
	base_info["academy_prestige"] = academy_prestige
	base_info["knowledge_storage"] = knowledge_storage
	base_info["can_admit_student"] = can_admit_student()
	base_info["student_capacity_ratio"] = float(current_students.size()) / float(student_capacity)
	
	return base_info


func _on_destroyed():
	"""建筑被摧毁时的回调（重写父类方法）"""
	# 调用父类方法
	super._on_destroyed()
	
	# 释放所有学生
	for student in current_students:
		if is_instance_valid(student):
			graduate_student(student)
	
	# 停止所有研究项目
	research_projects.clear()
	
	# 停止所有特效
	if effect_manager:
		effect_manager.stop_functional_effects()
	
	# 停止所有动画
	if construction_animator:
		construction_animator.stop_all_animations()
	
	LogManager.info("💀 [Academy3D] 学院被摧毁，所有特效已停止")
