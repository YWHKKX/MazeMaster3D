extends Building3D
class_name DungeonHeart3D

## 🏗️ 地牢之心3D - 3x3x3核心建筑
## 基于Building3D，实现地牢之心的3x3x3渲染

# 存储系统（继承原有逻辑）
var stored_mana: int = 500
var mana_storage_capacity: int = 2000
var mana_generation_rate: float = 1.0  # 每秒生成1点魔力


func _init():
	"""初始化地牢之心3D"""
	super._init()
	
	# 基础属性
	building_name = "地牢之心"
	building_type = BuildingTypes.DUNGEON_HEART
	max_health = 1000
	health = max_health
	armor = 10
	building_size = Vector2(2, 2)  # 保持原有2x2尺寸用于碰撞检测
	cost_gold = 0  # 地牢之心不需要建造
	engineer_cost = 0
	build_time = 0
	engineer_required = 0
	status = BuildingStatus.COMPLETED  # 直接完成
	
	# 3D配置
	_setup_3d_config()


func _setup_3d_config():
	"""设置3D配置"""
	# 基础配置
	building_3d_config.set_basic_config(building_name, building_type, Vector3(3, 3, 3))
	
	# 结构配置
	building_3d_config.set_structure_config(
		windows = false,   # 无窗户（核心建筑）
		door = false,      # 无门（核心建筑）
		roof = true,       # 有屋顶
		decorations = true # 有装饰
	)
	
	# 材质配置（深红色风格）
	building_3d_config.set_material_config(
		wall = Color(0.8, 0.2, 0.2),    # 深红色墙体
		roof = Color(0.6, 0.1, 0.1),    # 更深红色屋顶
		floor = Color(0.4, 0.1, 0.1)     # 暗红色地板
	)
	
	# 特殊功能配置
	building_3d_config.set_special_config(
		lighting = true,    # 有光照
		particles = true,   # 有粒子特效
		animations = true,  # 有动画
		sound = false       # 暂时无音效
	)


func _get_building_template() -> BuildingTemplate:
	"""获取地牢之心建筑模板"""
	var template = BuildingTemplate.new("地牢之心")
	template.building_type = BuildingTypes.DUNGEON_HEART
	template.description = "巨大的3x3x3核心建筑，散发着强大的能量"
	
	# 创建魔法结构
	template.create_magic_structure(BuildingTypes.DUNGEON_HEART)
	
	# 自定义核心元素
	# 顶层：能量水晶和魔力核心
	template.set_component(0, 2, 0, BuildingComponents.ID_MAGIC_CRYSTAL)
	template.set_component(1, 2, 0, BuildingComponents.ID_MAGIC_CORE)
	template.set_component(2, 2, 0, BuildingComponents.ID_MAGIC_CRYSTAL)
	template.set_component(0, 2, 1, BuildingComponents.ID_ENERGY_CONDUIT)
	template.set_component(1, 2, 1, BuildingComponents.ID_MAGIC_CORE)
	template.set_component(2, 2, 1, BuildingComponents.ID_ENERGY_CONDUIT)
	template.set_component(0, 2, 2, BuildingComponents.ID_MAGIC_CRYSTAL)
	template.set_component(1, 2, 2, BuildingComponents.ID_MAGIC_CORE)
	template.set_component(2, 2, 2, BuildingComponents.ID_MAGIC_CRYSTAL)
	
	# 中层：能量节点和存储核心
	template.set_component(1, 1, 0, BuildingComponents.ID_ENERGY_NODE)
	template.set_component(0, 1, 1, BuildingComponents.ID_ENERGY_NODE)
	template.set_component(1, 1, 1, BuildingComponents.ID_STORAGE_CORE)
	template.set_component(2, 1, 1, BuildingComponents.ID_ENERGY_NODE)
	template.set_component(1, 1, 2, BuildingComponents.ID_ENERGY_NODE)
	
	# 底层：坚固基础
	template.set_component(0, 0, 0, BuildingComponents.ID_WALL_STONE)
	template.set_component(1, 0, 0, BuildingComponents.ID_WALL_STONE)
	template.set_component(2, 0, 0, BuildingComponents.ID_WALL_STONE)
	template.set_component(0, 0, 1, BuildingComponents.ID_WALL_STONE)
	template.set_component(1, 0, 1, BuildingComponents.ID_FLOOR_STONE)
	template.set_component(2, 0, 1, BuildingComponents.ID_WALL_STONE)
	template.set_component(0, 0, 2, BuildingComponents.ID_WALL_STONE)
	template.set_component(1, 0, 2, BuildingComponents.ID_WALL_STONE)
	template.set_component(2, 0, 2, BuildingComponents.ID_WALL_STONE)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取地牢之心建筑配置"""
	var config = BuildingConfig.new()
	config.name = building_name
	config.width = 3
	config.depth = 3
	config.height = 3
	
	# 结构配置
	config.has_windows = false
	config.has_door = false
	config.has_roof = true
	config.has_decorations = true
	config.has_tower = false
	config.has_balcony = false
	
	# 材质配置
	config.wall_color = Color(0.8, 0.2, 0.2)  # 深红色
	config.roof_color = Color(0.6, 0.1, 0.1)    # 更深红色
	config.floor_color = Color(0.4, 0.1, 0.1)   # 暗红色
	config.window_color = Color.LIGHT_BLUE       # 不使用窗户
	config.door_color = Color.DARK_GRAY          # 不使用门
	
	return config


func _load_building_specific_components():
	"""加载地牢之心特定构件"""
	# 加载魔法构件
	_add_component_to_library("Magic_Crystal", BuildingComponents.ID_MAGIC_CRYSTAL)
	_add_component_to_library("Magic_Core", BuildingComponents.ID_MAGIC_CORE)
	_add_component_to_library("Energy_Conduit", BuildingComponents.ID_ENERGY_CONDUIT)
	_add_component_to_library("Energy_Node", BuildingComponents.ID_ENERGY_NODE)
	_add_component_to_library("Storage_Core", BuildingComponents.ID_STORAGE_CORE)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("🏰 [DungeonHeart3D] 地牢之心3D准备就绪")
	
	# 启动核心特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("🏰 [DungeonHeart3D] 地牢之心3D建造完成")
	
	# 启动核心系统
	_start_core_system()
	
	# 启动核心动画
	if construction_animator:
		construction_animator.play_function_animation("core_rotation")


func _start_core_system():
	"""启动核心系统"""
	# 设置魔力生成定时器
	var mana_timer = Timer.new()
	mana_timer.name = "ManaTimer"
	mana_timer.wait_time = 1.0  # 每秒更新一次
	mana_timer.timeout.connect(_generate_mana)
	mana_timer.autostart = true
	add_child(mana_timer)


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑"""
	# 调用父类方法
	super._update_3d_building_logic(delta)
	
	# 更新核心系统
	_update_core_system(delta)
	
	# 更新能量特效
	_update_energy_effects(delta)


func _update_core_system(delta: float):
	"""更新核心系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 根据存储量调整视觉效果
	_update_energy_visuals()


func _update_energy_visuals():
	"""更新能量视觉效果"""
	var mana_ratio = float(stored_mana) / float(mana_storage_capacity)
	var gold_ratio = float(stored_gold) / float(gold_storage_capacity)
	
	# 根据存储比例调整特效强度
	if effect_manager and effect_manager.particle_systems.has("energy_particles"):
		var ps = effect_manager.particle_systems["energy_particles"]
		if ps and ps.emitting:
			# 存储越多，特效越强
			ps.amount = int(20 + (mana_ratio + gold_ratio) * 30)
	
	# 根据存储比例调整光效强度
	if effect_manager and effect_manager.light_systems.has("core_glow"):
		var light = effect_manager.light_systems["core_glow"]
		if light and light.visible:
			light.light_energy = 1.0 + (mana_ratio + gold_ratio) * 2.0


func _generate_mana():
	"""生成魔力"""
	if resource_manager:
		var mana_generated = mana_generation_rate
		resource_manager.add_mana(int(mana_generated))
		
		# 更新存储显示
		_update_storage_display()


func _update_storage_display():
	"""更新存储显示"""
	# 更新状态栏显示
	if status_bar and is_instance_valid(status_bar):
		if status_bar.has_method("update_storage"):
			status_bar.update_storage(stored_gold, gold_storage_capacity)
		elif status_bar.has_method("update_gold"):
			status_bar.update_gold(stored_gold)
		if status_bar.has_method("update_mana"):
			status_bar.update_mana(stored_mana)


func _update_energy_effects(delta: float):
	"""更新能量特效"""
	# 更新能量流动效果
	_update_energy_flow(delta)
	
	# 更新核心旋转
	_update_core_rotation(delta)


func _update_energy_flow(delta: float):
	"""更新能量流动效果"""
	# 能量流动动画
	if construction_animator:
		construction_animator.play_function_animation("energy_flow")
	
	# 根据存储量调整流动速度
	var storage_ratio = (float(stored_mana) + float(stored_gold)) / (float(mana_storage_capacity) + float(gold_storage_capacity))
	var flow_speed = 1.0 + storage_ratio * 2.0
	
	if effect_manager and effect_manager.particle_systems.has("energy_particles"):
		var ps = effect_manager.particle_systems["energy_particles"]
		if ps and ps.emitting:
			# 调整粒子速度
			ps.initial_velocity_min = flow_speed
			ps.initial_velocity_max = flow_speed * 1.5


func _update_core_rotation(delta: float):
	"""更新核心旋转"""
	# 核心慢速旋转动画
	if construction_animator:
		construction_animator.play_function_animation("core_rotation")


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新地牢之心特定特效
	_update_dungeon_heart_effects(delta)


func _update_dungeon_heart_effects(delta: float):
	"""更新地牢之心特效"""
	# 能量脉冲效果
	var pulse_frequency = 2.0 + sin(Time.get_time_dict_from_system()["second"] * 2) * 0.5
	
	if effect_manager and effect_manager.light_systems.has("core_glow"):
		var light = effect_manager.light_systems["core_glow"]
		if light and light.visible:
			# 能量脉冲
			light.light_energy = 1.0 + sin(Time.get_time_dict_from_system()["second"] * pulse_frequency) * 0.5


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加地牢之心特定信息
	base_info["stored_mana"] = stored_mana
	base_info["mana_storage_capacity"] = mana_storage_capacity
	base_info["mana_generation_rate"] = mana_generation_rate
	base_info["mana_ratio"] = float(stored_mana) / float(mana_storage_capacity)
	base_info["total_storage_ratio"] = (float(stored_mana) + float(stored_gold)) / (float(mana_storage_capacity) + float(gold_storage_capacity))
	
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
	
	LogManager.info("💀 [DungeonHeart3D] 地牢之心被摧毁，所有特效已停止")
