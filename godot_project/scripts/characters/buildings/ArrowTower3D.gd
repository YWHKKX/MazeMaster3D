extends Building3D
class_name ArrowTower3D

## 🏗️ 箭塔3D - 3x3x3防御塔楼
## 基于Building3D，实现箭塔的3x3x3渲染

# 攻击系统（继承原有逻辑）
var attack_damage: float = 25.0
var attack_range: float = 80.0
var attack_interval: float = 2.0
var crit_rate: float = 0.25  # 25%暴击率
var crit_multiplier: float = 2.0
var ammo_count: int = 50
var max_ammo: int = 50
var last_attack_time: float = 0.0


func _init():
	"""初始化箭塔3D"""
	super._init()
	
	# 基础属性
	building_name = "箭塔"
	building_type = BuildingTypes.ARROW_TOWER
	max_health = 600
	health = max_health
	armor = 8
	building_size = Vector2(1, 1)  # 保持原有尺寸用于碰撞检测
	cost_gold = 150
	engineer_cost = 75
	build_time = 90.0
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
		windows = true,    # 有射箭口
		door = true,       # 有门
		roof = true,       # 有屋顶
		decorations = true # 有军事装饰
	)
	
	# 材质配置（军事风格）
	building_3d_config.set_material_config(
		wall = Color(0.83, 0.83, 0.83),  # 石灰色墙体
		roof = Color(0.6, 0.3, 0.2),     # 棕红色屋顶
		floor = Color(0.5, 0.5, 0.5)     # 灰色地板
	)
	
	# 特殊功能配置
	building_3d_config.set_special_config(
		lighting = true,    # 有光照
		particles = false,  # 无粒子特效
		animations = true,  # 有动画
		sound = false       # 暂时无音效
	)


func _get_building_template() -> BuildingTemplate:
	"""获取箭塔建筑模板"""
	var template = BuildingTemplate.new("箭塔")
	template.building_type = BuildingTypes.ARROW_TOWER
	template.description = "坚固的3x3x3军事防御塔，具有强大的远程攻击能力"
	
	# 创建军事塔楼结构
	template.create_military_structure(BuildingTypes.ARROW_TOWER)
	
	# 自定义军事元素
	# 顶层：射箭口和弩机
	template.set_component(0, 2, 0, BuildingComponents.ID_ARROW_SLOT)
	template.set_component(1, 2, 0, BuildingComponents.ID_CROSSBOW)
	template.set_component(2, 2, 0, BuildingComponents.ID_ARROW_SLOT)
	template.set_component(0, 2, 1, BuildingComponents.ID_ARROW_SLOT)
	template.set_component(2, 2, 1, BuildingComponents.ID_ARROW_SLOT)
	template.set_component(0, 2, 2, BuildingComponents.ID_ARROW_SLOT)
	template.set_component(1, 2, 2, BuildingComponents.ID_CROSSBOW)
	template.set_component(2, 2, 2, BuildingComponents.ID_ARROW_SLOT)
	
	# 中层：弹药架和军事窗户
	template.set_component(1, 1, 0, BuildingComponents.ID_AMMO_RACK)
	template.set_component(0, 1, 1, BuildingComponents.ID_WINDOW_SMALL)
	template.set_component(2, 1, 1, BuildingComponents.ID_WINDOW_SMALL)
	template.set_component(1, 1, 2, BuildingComponents.ID_AMMO_RACK)
	
	# 底层：军事门和基础
	template.set_component(1, 0, 0, BuildingComponents.ID_DOOR_METAL)
	template.set_component(1, 0, 1, BuildingComponents.ID_BATTLE_STANDARD)
	template.set_component(1, 0, 2, BuildingComponents.ID_BATTLE_STANDARD)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取箭塔建筑配置"""
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
	config.has_tower = true
	config.tower_height = 1.2
	
	# 材质配置
	config.wall_color = Color(0.83, 0.83, 0.83)  # 石灰色
	config.roof_color = Color(0.6, 0.3, 0.2)     # 棕红色
	config.floor_color = Color(0.5, 0.5, 0.5)    # 灰色
	config.window_color = Color.LIGHT_GRAY        # 浅灰色窗户
	config.door_color = Color.DARK_GRAY           # 深灰色门
	
	return config


func _load_building_specific_components():
	"""加载箭塔特定构件"""
	# 加载军事构件
	_add_component_to_library("Arrow_Slot", BuildingComponents.ID_ARROW_SLOT)
	_add_component_to_library("Crossbow", BuildingComponents.ID_CROSSBOW)
	_add_component_to_library("Ammo_Rack", BuildingComponents.ID_AMMO_RACK)
	_add_component_to_library("Battle_Standard", BuildingComponents.ID_BATTLE_STANDARD)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("🏹 [ArrowTower3D] 箭塔3D准备就绪")
	
	# 启动军事特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("🏹 [ArrowTower3D] 箭塔3D建造完成")
	
	# 启动攻击系统
	_start_attack_system()
	
	# 启动军事动画
	if construction_animator:
		construction_animator.play_function_animation("arrow_reload")


func _start_attack_system():
	"""启动攻击系统"""
	# 设置攻击定时器
	var attack_timer = Timer.new()
	attack_timer.name = "AttackTimer"
	attack_timer.wait_time = attack_interval
	attack_timer.timeout.connect(_try_attack)
	attack_timer.autostart = true
	add_child(attack_timer)


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑"""
	# 调用父类方法
	super._update_3d_building_logic(delta)
	
	# 更新攻击系统
	_update_attack_system(delta)
	
	# 更新军事特效
	_update_military_effects(delta)


func _update_attack_system(delta: float):
	"""更新攻击系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	last_attack_time += delta
	if last_attack_time >= attack_interval:
		_try_attack()
		last_attack_time = 0.0


func _try_attack():
	"""尝试攻击敌人"""
	var enemies = GameGroups.get_nodes(GameGroups.HEROES)
	var nearest_enemy = null
	var min_distance = attack_range
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest_enemy = enemy
	
	if nearest_enemy and ammo_count > 0:
		# 消耗弹药
		ammo_count -= 1
		
		# 播放攻击特效
		_play_attack_effect(nearest_enemy)
		
		# 攻击逻辑
		if nearest_enemy.has_method("take_damage"):
			var damage = attack_damage
			
			# 暴击判定
			if randf() < crit_rate:
				damage *= crit_multiplier
				LogManager.info("🏹 [ArrowTower3D] 暴击攻击: %.1f 伤害" % damage)
			else:
				LogManager.info("🏹 [ArrowTower3D] 普通攻击: %.1f 伤害" % damage)
			
			nearest_enemy.take_damage(damage)
			
			# 播放装弹动画
			if construction_animator:
				construction_animator.play_function_animation("arrow_reload")


func _play_attack_effect(target: Node):
	"""播放攻击特效"""
	if not effect_manager:
		return
	
	# 创建攻击粒子效果
	var target_pos = target.global_position if target else global_position + Vector3(0, 2, 0)
	effect_manager._create_particle_effect("arrow_trail", target_pos, 1.0)


func _update_military_effects(delta: float):
	"""更新军事特效"""
	# 更新弹药架显示
	_update_ammo_display(delta)
	
	# 更新射箭口状态
	_update_arrow_slots(delta)


func _update_ammo_display(delta: float):
	"""更新弹药架显示"""
	# 这里可以添加弹药架发光的视觉效果
	pass


func _update_arrow_slots(delta: float):
	"""更新射箭口状态"""
	# 这里可以添加射箭口的状态指示
	pass


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新箭塔特定特效
	_update_arrow_tower_effects(delta)


func _update_arrow_tower_effects(delta: float):
	"""更新箭塔特效"""
	# 弹药不足警告
	if ammo_count < max_ammo * 0.2:  # 弹药低于20%
		if effect_manager and effect_manager.light_systems.has("torch_light"):
			var light = effect_manager.light_systems["torch_light"]
			if light and light.visible:
				# 红色警告光
				light.light_color = Color.RED
				light.light_energy = 1.5 + sin(Time.get_time_dict_from_system()["second"] * 4) * 0.5
	else:
		# 正常黄色光
		if effect_manager and effect_manager.light_systems.has("torch_light"):
			var light = effect_manager.light_systems["torch_light"]
			if light and light.visible:
				light.light_color = Color.YELLOW
				light.light_energy = 0.6


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加箭塔特定信息
	base_info["attack_damage"] = attack_damage
	base_info["attack_range"] = attack_range
	base_info["crit_rate"] = crit_rate
	base_info["ammo_count"] = ammo_count
	base_info["max_ammo"] = max_ammo
	base_info["last_attack_time"] = last_attack_time
	base_info["next_attack_in"] = max(0, attack_interval - last_attack_time)
	
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
	
	LogManager.info("💀 [ArrowTower3D] 箭塔被摧毁，所有特效已停止")
