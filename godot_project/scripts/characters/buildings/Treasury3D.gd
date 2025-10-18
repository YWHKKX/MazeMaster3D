extends Building3D
class_name Treasury3D

## 🏗️ 金库3D - 3x3x3金币存储建筑
## 基于Building3D，实现金库的3x3x3渲染

# 存储系统（继承原有逻辑）
# gold_storage_capacity 已在父类 Building 中定义


func _init():
	"""初始化金库3D"""
	super._init()
	
	# 基础属性
	building_name = "金库"
	building_type = BuildingTypes.BuildingType.TREASURY
	max_health = 400
	health = max_health
	armor = 6
	building_size = Vector2(1, 1) # 保持原有尺寸用于碰撞检测
	cost_gold = 100
	engineer_cost = 50
	build_time = 60.0
	engineer_required = 1
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
	
	# 材质配置（金色风格）
	building_3d_config.wall_color = Color(1.0, 0.84, 0.0) # 金黄色墙体
	building_3d_config.roof_color = Color(0.8, 0.6, 0.2) # 深金色屋顶
	building_3d_config.floor_color = Color(0.9, 0.7, 0.1) # 金色地板
	
	# 特殊功能配置
	building_3d_config.has_lighting = true
	building_3d_config.has_particles = true
	building_3d_config.has_animations = true
	building_3d_config.has_sound_effects = false


func _get_building_template():
	"""获取金库建筑模板"""
	var template = BuildingTemplateClass.new("金库")
	template.building_type = BuildingTypes.BuildingType.TREASURY
	template.description = "安全的3x3x3金币存储建筑，具有豪华的金色外观"
	
	# 创建简单房屋结构
	template.create_simple_house(BuildingTypes.BuildingType.TREASURY)
	
	# 自定义金库元素
	# 顶层：金币堆
	template.set_component(0, 2, 0, BuildingComponents.ID_GOLD_PILE)
	template.set_component(1, 2, 0, BuildingComponents.ID_GOLD_PILE)
	template.set_component(2, 2, 0, BuildingComponents.ID_GOLD_PILE)
	template.set_component(0, 2, 1, BuildingComponents.ID_GOLD_PILE)
	template.set_component(1, 2, 1, BuildingComponents.ID_TREASURE_CHEST)
	template.set_component(2, 2, 1, BuildingComponents.ID_GOLD_PILE)
	template.set_component(0, 2, 2, BuildingComponents.ID_GOLD_PILE)
	template.set_component(1, 2, 2, BuildingComponents.ID_GOLD_PILE)
	template.set_component(2, 2, 2, BuildingComponents.ID_GOLD_PILE)
	
	# 中层：存储箱和金币堆
	template.set_component(1, 1, 0, BuildingComponents.ID_STORAGE_CRATE)
	template.set_component(0, 1, 1, BuildingComponents.ID_STORAGE_CRATE)
	template.set_component(1, 1, 1, BuildingComponents.ID_GOLD_PILE)
	template.set_component(2, 1, 1, BuildingComponents.ID_STORAGE_CRATE)
	template.set_component(1, 1, 2, BuildingComponents.ID_STORAGE_CRATE)
	
	# 底层：坚固门和基础
	template.set_component(1, 0, 0, BuildingComponents.ID_DOOR_METAL)
	template.set_component(1, 0, 1, BuildingComponents.ID_TREASURE_CHEST)
	template.set_component(1, 0, 2, BuildingComponents.ID_TREASURE_CHEST)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取金库建筑配置"""
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
	config.wall_color = Color(1.0, 0.84, 0.0) # 金黄色
	config.roof_color = Color(0.8, 0.6, 0.2) # 深金色
	config.floor_color = Color(0.9, 0.7, 0.1) # 金色
	config.window_color = Color.LIGHT_BLUE # 不使用窗户
	config.door_color = Color(0.6, 0.4, 0.2) # 深棕色门
	
	return config


func _load_building_specific_components():
	"""加载金库特定构件"""
	# 加载资源构件
	_add_component_to_library("Gold_Pile", BuildingComponents.ID_GOLD_PILE)
	_add_component_to_library("Treasure_Chest", BuildingComponents.ID_TREASURE_CHEST)
	_add_component_to_library("Storage_Crate", BuildingComponents.ID_STORAGE_CRATE)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("💰 [Treasury3D] 金库3D准备就绪")
	
	# 启动金币特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("💰 [Treasury3D] 金库3D建造完成")
	
	# 启动存储系统
	_start_storage_system()
	
	# 启动金币动画
	if construction_animator:
		construction_animator.play_function_animation("gold_sparkle")


func _start_storage_system():
	"""启动存储系统"""
	# 设置存储更新定时器
	var storage_timer = Timer.new()
	storage_timer.name = "StorageTimer"
	storage_timer.wait_time = 1.0 # 每秒更新一次
	storage_timer.timeout.connect(_update_storage_display)
	storage_timer.autostart = true
	add_child(storage_timer)


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑"""
	# 调用父类方法
	super._update_3d_building_logic(delta)
	
	# 更新存储系统
	_update_storage_system(delta)
	
	# 更新金币特效
	_update_gold_effects(delta)


func _update_storage_system(delta: float):
	"""更新存储系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 根据存储量调整视觉效果
	_update_gold_pile_visuals()


func _update_gold_pile_visuals():
	"""更新金币堆视觉效果"""
	var storage_ratio = float(stored_gold) / float(gold_storage_capacity)
	
	# 根据存储比例调整特效强度
	if effect_manager and effect_manager.particle_systems.has("gold_sparkles"):
		var ps = effect_manager.particle_systems["gold_sparkles"]
		if ps and ps.emitting:
			# 存储越多，特效越强
			ps.amount = int(10 + storage_ratio * 20)
	
	# 根据存储比例调整光效强度
	if effect_manager and effect_manager.light_systems.has("golden_glow"):
		var light = effect_manager.light_systems["golden_glow"]
		if light and light.visible:
			light.light_energy = 0.8 + storage_ratio * 1.2


func _update_storage_display():
	"""更新存储显示"""
	# 更新状态栏显示
	if status_bar and is_instance_valid(status_bar):
		if status_bar.has_method("update_storage"):
			status_bar.update_storage(stored_gold, gold_storage_capacity)
		elif status_bar.has_method("update_gold"):
			status_bar.update_gold(stored_gold)


func _update_gold_effects(delta: float):
	"""更新金币特效"""
	# 更新金币闪光效果
	_update_gold_sparkle(delta)
	
	# 更新存储指示
	_update_storage_indicator(delta)


func _update_gold_sparkle(delta: float):
	"""更新金币闪光效果"""
	# 存储量越高，闪光频率越快
	var sparkle_frequency = 1.0 + (float(stored_gold) / float(gold_storage_capacity)) * 2.0
	
	if effect_manager and effect_manager.particle_systems.has("gold_sparkles"):
		var ps = effect_manager.particle_systems["gold_sparkles"]
		if ps and ps.emitting:
			# 调整粒子生命周期以改变闪光频率
			ps.lifetime = 3.0 / sparkle_frequency


func _update_storage_indicator(delta: float):
	"""更新存储指示"""
	# 存储接近满时显示红色警告
	if stored_gold >= gold_storage_capacity * 0.9:
		if effect_manager and effect_manager.light_systems.has("golden_glow"):
			var light = effect_manager.light_systems["golden_glow"]
			if light and light.visible:
				# 红色警告光
				light.light_color = Color.RED
				light.light_energy = 1.5 + sin(Time.get_time_dict_from_system()["second"] * 6) * 0.5
	else:
		# 正常金色光
		if effect_manager and effect_manager.light_systems.has("golden_glow"):
			var light = effect_manager.light_systems["golden_glow"]
			if light and light.visible:
				light.light_color = Color.GOLD
				light.light_energy = 0.8 + (float(stored_gold) / float(gold_storage_capacity)) * 1.2


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新金库特定特效
	_update_treasury_effects(delta)


func _update_treasury_effects(delta: float):
	"""更新金库特效"""
	# 金币闪光动画
	if construction_animator:
		construction_animator.play_function_animation("gold_sparkle")
	
	# 根据存储量调整建筑外观
	var storage_ratio = float(stored_gold) / float(gold_storage_capacity)
	
	# 存储量高时，建筑更亮
	if gridmap_renderer:
		# 可以调整材质亮度
		pass


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加金库特定信息
	base_info["stored_gold"] = stored_gold
	base_info["gold_storage_capacity"] = gold_storage_capacity
	base_info["storage_ratio"] = float(stored_gold) / float(gold_storage_capacity)
	base_info["is_full"] = stored_gold >= gold_storage_capacity
	
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
	
	LogManager.info("💀 [Treasury3D] 金库被摧毁，所有特效已停止")
