extends Building3D
class_name Library3D

## 🏗️ 图书馆3D - 3x3x3知识建筑
## 基于Building3D，实现图书馆的3x3x3渲染

# 知识系统
var mana_generation_rate: float = 0.2  # 每秒生成0.2法力
var spell_power_bonus: float = 0.15    # 15%法术增强
var research_bonus: float = 0.1        # 10%研究速度加成


func _init():
	"""初始化图书馆3D"""
	super._init()
	
	# 基础属性
	building_name = "图书馆"
	building_type = BuildingTypes.LIBRARY
	max_health = 200
	health = max_health
	armor = 5
	building_size = Vector2(1, 1)  # 保持原有尺寸用于碰撞检测
	cost_gold = 250
	engineer_cost = 125
	build_time = 150.0
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
		windows = true,    # 有窗户（采光）
		door = true,       # 有门
		roof = true,       # 有屋顶
		decorations = true # 有装饰
	)
	
	# 材质配置（知识风格）
	building_3d_config.set_material_config(
		wall = Color(0.6, 0.5, 0.4),    # 棕色墙体
		roof = Color(0.4, 0.3, 0.2),    # 深棕色屋顶
		floor = Color(0.5, 0.4, 0.3)     # 棕色地板
	)
	
	# 特殊功能配置
	building_3d_config.set_special_config(
		lighting = true,    # 有光照
		particles = true,   # 有粒子特效
		animations = true,  # 有动画
		sound = false       # 暂时无音效
	)


func _get_building_template() -> BuildingTemplate:
	"""获取图书馆建筑模板"""
	var template = BuildingTemplate.new("图书馆")
	template.building_type = BuildingTypes.LIBRARY
	template.description = "知识的3x3x3图书馆，散发着智慧的光芒"
	
	# 创建简单房屋结构
	template.create_simple_house(BuildingTypes.LIBRARY)
	
	# 自定义图书馆元素
	# 顶层：书堆和知识装饰
	template.set_component(0, 2, 0, BuildingComponents.ID_BOOK_PILE)
	template.set_component(1, 2, 0, BuildingComponents.ID_BOOK_PILE)
	template.set_component(2, 2, 0, BuildingComponents.ID_BOOK_PILE)
	template.set_component(0, 2, 1, BuildingComponents.ID_BOOK_PILE)
	template.set_component(1, 2, 1, BuildingComponents.ID_KNOWLEDGE_ORB)
	template.set_component(2, 2, 1, BuildingComponents.ID_BOOK_PILE)
	template.set_component(0, 2, 2, BuildingComponents.ID_BOOK_PILE)
	template.set_component(1, 2, 2, BuildingComponents.ID_BOOK_PILE)
	template.set_component(2, 2, 2, BuildingComponents.ID_BOOK_PILE)
	
	# 中层：书架和阅读区
	template.set_component(0, 1, 0, BuildingComponents.ID_BOOKSHELF)
	template.set_component(1, 1, 0, BuildingComponents.ID_BOOKSHELF)
	template.set_component(2, 1, 0, BuildingComponents.ID_BOOKSHELF)
	template.set_component(0, 1, 1, BuildingComponents.ID_BOOKSHELF)
	template.set_component(1, 1, 1, BuildingComponents.ID_READING_DESK)
	template.set_component(2, 1, 1, BuildingComponents.ID_BOOKSHELF)
	template.set_component(0, 1, 2, BuildingComponents.ID_BOOKSHELF)
	template.set_component(1, 1, 2, BuildingComponents.ID_BOOKSHELF)
	template.set_component(2, 1, 2, BuildingComponents.ID_BOOKSHELF)
	
	# 底层：入口和基础
	template.set_component(1, 0, 0, BuildingComponents.ID_DOOR_WOOD)
	template.set_component(0, 0, 1, BuildingComponents.ID_BOOKSHELF)
	template.set_component(1, 0, 1, BuildingComponents.ID_READING_DESK)
	template.set_component(2, 0, 1, BuildingComponents.ID_BOOKSHELF)
	template.set_component(1, 0, 2, BuildingComponents.ID_BOOKSHELF)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取图书馆建筑配置"""
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
	config.wall_color = Color(0.6, 0.5, 0.4)  # 棕色
	config.roof_color = Color(0.4, 0.3, 0.2)    # 深棕色
	config.floor_color = Color(0.5, 0.4, 0.3)   # 棕色
	config.window_color = Color(0.8, 0.9, 1.0)  # 淡蓝色窗户
	config.door_color = Color(0.4, 0.3, 0.2)    # 深棕色门
	
	return config


func _load_building_specific_components():
	"""加载图书馆特定构件"""
	# 加载知识构件
	_add_component_to_library("Book_Pile", BuildingComponents.ID_BOOK_PILE)
	_add_component_to_library("Bookshelf", BuildingComponents.ID_BOOKSHELF)
	_add_component_to_library("Reading_Desk", BuildingComponents.ID_READING_DESK)
	_add_component_to_library("Knowledge_Orb", BuildingComponents.ID_KNOWLEDGE_ORB)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("📚 [Library3D] 图书馆3D准备就绪")
	
	# 启动知识特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("📚 [Library3D] 图书馆3D建造完成")
	
	# 启动知识系统
	_start_knowledge_system()
	
	# 启动知识动画
	if construction_animator:
		construction_animator.play_function_animation("book_glow")


func _start_knowledge_system():
	"""启动知识系统"""
	# 设置知识生成定时器
	var knowledge_timer = Timer.new()
	knowledge_timer.name = "KnowledgeTimer"
	knowledge_timer.wait_time = 1.0  # 每秒更新一次
	knowledge_timer.timeout.connect(_generate_knowledge)
	knowledge_timer.autostart = true
	add_child(knowledge_timer)


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑"""
	# 调用父类方法
	super._update_3d_building_logic(delta)
	
	# 更新知识系统
	_update_knowledge_system(delta)
	
	# 更新知识特效
	_update_knowledge_effects(delta)


func _update_knowledge_system(delta: float):
	"""更新知识系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 更新知识生成进度
	_update_knowledge_generation_progress(delta)


func _update_knowledge_generation_progress(delta: float):
	"""更新知识生成进度"""
	# 这里可以添加知识生成的视觉进度指示
	pass


func _generate_knowledge():
	"""生成知识（法力）"""
	if resource_manager:
		var mana_generated = mana_generation_rate
		resource_manager.add_mana(int(mana_generated))
		
		# 播放知识生成特效
		_play_knowledge_generation_effect()


func _play_knowledge_generation_effect():
	"""播放知识生成特效"""
	if not effect_manager:
		return
	
	# 创建知识生成粒子效果
	effect_manager._create_particle_effect("knowledge_glow", global_position + Vector3(0, 2, 0), 1.0)


func _update_knowledge_effects(delta: float):
	"""更新知识特效"""
	# 更新书籍发光效果
	_update_book_glow(delta)
	
	# 更新知识流动
	_update_knowledge_flow(delta)


func _update_book_glow(delta: float):
	"""更新书籍发光效果"""
	# 书籍发光动画
	if construction_animator:
		construction_animator.play_function_animation("book_glow")
	
	# 根据知识生成速率调整发光强度
	var glow_intensity = 0.3 + mana_generation_rate * 0.7
	
	if effect_manager and effect_manager.light_systems.has("book_light"):
		var light = effect_manager.light_systems["book_light"]
		if light and light.visible:
			light.light_energy = glow_intensity + sin(Time.get_time_dict_from_system()["second"] * 2) * 0.1
			light.light_color = Color(0.9, 0.8, 0.6)  # 温暖的书本光


func _update_knowledge_flow(delta: float):
	"""更新知识流动"""
	# 知识流动动画
	if construction_animator:
		construction_animator.play_function_animation("knowledge_flow")
	
	# 根据知识生成调整流动速度
	var flow_speed = 0.5 + mana_generation_rate * 1.5
	
	if effect_manager and effect_manager.particle_systems.has("knowledge_particles"):
		var ps = effect_manager.particle_systems["knowledge_particles"]
		if ps and ps.emitting:
			# 调整粒子强度
			ps.amount = int(3 + flow_speed * 8)


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新图书馆特定特效
	_update_library_effects(delta)


func _update_library_effects(delta: float):
	"""更新图书馆特效"""
	# 知识脉冲效果
	var pulse_frequency = 1.0 + sin(Time.get_time_dict_from_system()["second"] * 1.0) * 0.2
	
	if effect_manager and effect_manager.light_systems.has("library_glow"):
		var light = effect_manager.light_systems["library_glow"]
		if light and light.visible:
			# 知识脉冲
			light.light_energy = 0.6 + sin(Time.get_time_dict_from_system()["second"] * pulse_frequency) * 0.2
			light.light_color = Color(0.9, 0.8, 0.6)  # 温暖的知识光


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加图书馆特定信息
	base_info["mana_generation_rate"] = mana_generation_rate
	base_info["spell_power_bonus"] = spell_power_bonus
	base_info["research_bonus"] = research_bonus
	base_info["is_generating_knowledge"] = status == BuildingStatus.COMPLETED
	base_info["knowledge_per_second"] = mana_generation_rate
	
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
	
	LogManager.info("💀 [Library3D] 图书馆被摧毁，所有特效已停止")
