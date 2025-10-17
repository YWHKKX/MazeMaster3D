extends Building3D
class_name MagicResearchInstitute3D

## 🏗️ 魔法研究院3D - 3x3x3高级研究建筑
## 基于Building3D，实现魔法研究院的3x3x3渲染

# 研究系统
var research_slots: int = 2                    # 同时研究项目数
var research_speed_multiplier: float = 1.5     # 研究速度倍率
var mana_generation_rate: float = 0.3          # 法力生成速度（每秒）
var spell_power_bonus: float = 0.20            # 法术威力加成（20%）

# 研究状态
var current_research: Array = []               # 当前研究项目
var completed_research: Array = []             # 已完成研究


func _init():
	"""初始化魔法研究院3D"""
	super._init()
	
	# 基础属性
	building_name = "魔法研究院"
	building_type = BuildingTypes.MAGIC_RESEARCH_INSTITUTE
	max_health = 350
	health = max_health
	armor = 6
	building_size = Vector2(1, 1)  # 保持原有尺寸用于碰撞检测
	cost_gold = 600
	engineer_cost = 300
	build_time = 240.0
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
	
	# 材质配置（研究风格）
	building_3d_config.set_material_config(
		wall = Color(0.4, 0.3, 0.6),    # 紫色墙体
		roof = Color(0.3, 0.2, 0.5),    # 深紫色屋顶
		floor = Color(0.5, 0.4, 0.7)     # 浅紫色地板
	)
	
	# 特殊功能配置
	building_3d_config.set_special_config(
		lighting = true,    # 有光照
		particles = true,   # 有粒子特效
		animations = true,  # 有动画
		sound = false       # 暂时无音效
	)


func _get_building_template() -> BuildingTemplate:
	"""获取魔法研究院建筑模板"""
	var template = BuildingTemplate.new("魔法研究院")
	template.building_type = BuildingTypes.MAGIC_RESEARCH_INSTITUTE
	template.description = "高级的3x3x3魔法研究建筑，散发着学者的智慧"
	
	# 创建魔法结构
	template.create_magic_structure(BuildingTypes.MAGIC_RESEARCH_INSTITUTE)
	
	# 自定义研究院元素
	# 顶层：研究设备和知识装饰
	template.set_component(0, 2, 0, BuildingComponents.ID_RESEARCH_TABLE)
	template.set_component(1, 2, 0, BuildingComponents.ID_WISDOM_CRYSTAL)
	template.set_component(2, 2, 0, BuildingComponents.ID_RESEARCH_TABLE)
	template.set_component(0, 2, 1, BuildingComponents.ID_ANCIENT_TEXT)
	template.set_component(1, 2, 1, BuildingComponents.ID_KNOWLEDGE_ORB)
	template.set_component(2, 2, 1, BuildingComponents.ID_ANCIENT_TEXT)
	template.set_component(0, 2, 2, BuildingComponents.ID_RESEARCH_TABLE)
	template.set_component(1, 2, 2, BuildingComponents.ID_WISDOM_CRYSTAL)
	template.set_component(2, 2, 2, BuildingComponents.ID_RESEARCH_TABLE)
	
	# 中层：书架和研究区
	template.set_component(0, 1, 0, BuildingComponents.ID_SCROLL_RACK)
	template.set_component(1, 1, 0, BuildingComponents.ID_STUDY_LAMP)
	template.set_component(2, 1, 0, BuildingComponents.ID_SCROLL_RACK)
	template.set_component(0, 1, 1, BuildingComponents.ID_BOOKSHELF)
	template.set_component(1, 1, 1, BuildingComponents.ID_RESEARCH_TABLE)
	template.set_component(2, 1, 1, BuildingComponents.ID_BOOKSHELF)
	template.set_component(0, 1, 2, BuildingComponents.ID_SCROLL_RACK)
	template.set_component(1, 1, 2, BuildingComponents.ID_STUDY_LAMP)
	template.set_component(2, 1, 2, BuildingComponents.ID_SCROLL_RACK)
	
	# 底层：入口和基础
	template.set_component(1, 0, 0, BuildingComponents.ID_DOOR_WOOD)
	template.set_component(0, 0, 1, BuildingComponents.ID_SCHOLAR_STATUE)
	template.set_component(1, 0, 1, BuildingComponents.ID_RESEARCH_TABLE)
	template.set_component(2, 0, 1, BuildingComponents.ID_SCHOLAR_STATUE)
	template.set_component(1, 0, 2, BuildingComponents.ID_BOOKSHELF)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取魔法研究院建筑配置"""
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
	config.wall_color = Color(0.4, 0.3, 0.6)  # 紫色
	config.roof_color = Color(0.3, 0.2, 0.5)    # 深紫色
	config.floor_color = Color(0.5, 0.4, 0.7)   # 浅紫色
	config.window_color = Color(0.8, 0.7, 1.0)  # 淡紫色窗户
	config.door_color = Color(0.3, 0.2, 0.4)    # 深紫色门
	
	return config


func _load_building_specific_components():
	"""加载魔法研究院特定构件"""
	# 加载研究构件
	_add_component_to_library("Research_Table", BuildingComponents.ID_RESEARCH_TABLE)
	_add_component_to_library("Wisdom_Crystal", BuildingComponents.ID_WISDOM_CRYSTAL)
	_add_component_to_library("Ancient_Text", BuildingComponents.ID_ANCIENT_TEXT)
	_add_component_to_library("Scholar_Statue", BuildingComponents.ID_SCHOLAR_STATUE)
	_add_component_to_library("Study_Lamp", BuildingComponents.ID_STUDY_LAMP)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("🔬 [MagicResearchInstitute3D] 魔法研究院3D准备就绪")
	
	# 启动研究特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("🔬 [MagicResearchInstitute3D] 魔法研究院3D建造完成")
	
	# 启动研究系统
	_start_research_system()
	
	# 启动研究动画
	if construction_animator:
		construction_animator.play_function_animation("research_activity")


func _start_research_system():
	"""启动研究系统"""
	# 设置研究更新定时器
	var research_timer = Timer.new()
	research_timer.name = "ResearchTimer"
	research_timer.wait_time = 1.0  # 每秒更新一次
	research_timer.timeout.connect(_process_research)
	research_timer.autostart = true
	add_child(research_timer)
	
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
	
	# 更新研究系统
	_update_research_system(delta)
	
	# 更新研究特效
	_update_research_effects(delta)


func _update_research_system(delta: float):
	"""更新研究系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 更新研究进度
	_update_research_progress(delta)


func _update_research_progress(delta: float):
	"""更新研究进度"""
	# 这里可以添加研究进度的视觉指示
	pass


func _process_research():
	"""处理研究"""
	if resource_manager:
		# 处理当前研究项目
		for research_project in current_research:
			_advance_research(research_project, 1.0)


func _generate_mana():
	"""生成魔力"""
	if resource_manager:
		var mana_generated = mana_generation_rate
		resource_manager.add_mana(int(mana_generated))
		
		# 播放魔力生成特效
		_play_mana_generation_effect()


func _advance_research(project: Dictionary, delta: float):
	"""推进研究项目"""
	if not project.has("progress"):
		project["progress"] = 0.0
	
	project["progress"] += delta * research_speed_multiplier
	
	# 检查研究是否完成
	if project["progress"] >= 100.0:
		_complete_research(project)


func _complete_research(project: Dictionary):
	"""完成研究项目"""
	current_research.erase(project)
	completed_research.append(project)
	
	# 播放研究完成特效
	_play_research_complete_effect()
	
	LogManager.info("🔬 [MagicResearchInstitute3D] 研究项目完成: %s" % project.get("name", "未知"))


func _play_mana_generation_effect():
	"""播放魔力生成特效"""
	if not effect_manager:
		return
	
	# 创建魔力生成粒子效果
	effect_manager._create_particle_effect("mana_research", global_position + Vector3(0, 2, 0), 1.2)


func _play_research_complete_effect():
	"""播放研究完成特效"""
	if not effect_manager:
		return
	
	# 创建研究完成粒子效果
	effect_manager._create_particle_effect("research_complete", global_position + Vector3(0, 2, 0), 3.0)


func _update_research_effects(delta: float):
	"""更新研究特效"""
	# 更新研究活动效果
	_update_research_activity(delta)
	
	# 更新智慧水晶发光
	_update_wisdom_crystal_glow(delta)


func _update_research_activity(delta: float):
	"""更新研究活动效果"""
	# 根据研究项目数量调整活动强度
	var activity_intensity = float(current_research.size()) / float(research_slots)
	
	# 研究活动动画
	if construction_animator:
		construction_animator.play_function_animation("research_activity")
	
	# 根据活动强度调整特效
	if effect_manager and effect_manager.particle_systems.has("research_particles"):
		var ps = effect_manager.particle_systems["research_particles"]
		if ps and ps.emitting:
			# 调整粒子强度
			ps.amount = int(8 + activity_intensity * 12)


func _update_wisdom_crystal_glow(delta: float):
	"""更新智慧水晶发光"""
	# 智慧水晶发光动画
	if construction_animator:
		construction_animator.play_function_animation("crystal_glow")
	
	# 根据研究进度调整发光强度
	var research_progress = _get_total_research_progress()
	
	if effect_manager and effect_manager.light_systems.has("wisdom_light"):
		var light = effect_manager.light_systems["wisdom_light"]
		if light and light.visible:
			light.light_energy = 0.8 + research_progress * 0.7
			light.light_color = Color(0.7, 0.5, 1.0)  # 紫色智慧光


func _get_total_research_progress() -> float:
	"""获取总研究进度"""
	var total_progress = 0.0
	for project in current_research:
		total_progress += project.get("progress", 0.0)
	return total_progress / 100.0


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新魔法研究院特定特效
	_update_research_institute_effects(delta)


func _update_research_institute_effects(delta: float):
	"""更新魔法研究院特效"""
	# 研究脉冲效果
	var research_count = current_research.size()
	var pulse_frequency = 1.0 + research_count * 0.3
	
	if effect_manager and effect_manager.light_systems.has("research_glow"):
		var light = effect_manager.light_systems["research_glow"]
		if light and light.visible:
			# 研究脉冲
			light.light_energy = 0.7 + sin(Time.get_time_dict_from_system()["second"] * pulse_frequency) * 0.3
			light.light_color = Color(0.7, 0.5, 1.0)  # 紫色研究光


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加魔法研究院特定信息
	base_info["research_slots"] = research_slots
	base_info["research_speed_multiplier"] = research_speed_multiplier
	base_info["mana_generation_rate"] = mana_generation_rate
	base_info["spell_power_bonus"] = spell_power_bonus
	base_info["current_research_count"] = current_research.size()
	base_info["completed_research_count"] = completed_research.size()
	base_info["research_capacity_ratio"] = float(current_research.size()) / float(research_slots)
	
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
	
	LogManager.info("💀 [MagicResearchInstitute3D] 魔法研究院被摧毁，所有特效已停止")
