extends Building3D
class_name ArcaneTower3D

## 🏗️ 奥术塔3D - 3x3x3魔法防御塔
## 基于Building3D，实现奥术塔的3x3x3渲染

# 攻击系统（继承原有逻辑）
var attack_damage: float = 40.0
var attack_range: float = 100.0
var attack_interval: float = 2.5
var mana_cost_per_attack: float = 1.0
var last_attack_time: float = 0.0


func _init():
	"""初始化奥术塔3D"""
	super._init()
	
	# 基础属性
	building_name = "奥术塔"
	building_type = BuildingTypes.BuildingType.ARCANE_TOWER
	max_health = 800
	health = max_health
	armor = 5
	building_size = Vector2(1, 1) # 保持原有尺寸用于碰撞检测
	cost_gold = 200
	engineer_cost = 100
	build_time = 100.0
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
	
	# 材质配置（魔法风格）
	building_3d_config.wall_color = Color(0.54, 0.17, 0.89) # 紫色墙体
	building_3d_config.roof_color = Color(0.8, 0.2, 0.9) # 深紫色屋顶
	building_3d_config.floor_color = Color(0.3, 0.1, 0.4) # 深紫色地板
	
	# 特殊功能配置
	building_3d_config.has_lighting = true
	building_3d_config.has_particles = true
	building_3d_config.has_animations = true
	building_3d_config.has_sound_effects = false


func _get_building_template():
	"""获取奥术塔建筑模板"""
	var template = BuildingTemplateClass.new("奥术塔")
	template.building_type = BuildingTypes.BuildingType.ARCANE_TOWER
	template.description = "神秘的3x3x3魔法防御塔，具有强大的奥术攻击能力"
	
	# 创建魔法塔楼结构
	template.create_magic_structure(BuildingTypes.BuildingType.ARCANE_TOWER)
	
	# 自定义魔法元素
	# 顶层：魔法水晶和奥术核心
	template.set_component(0, 2, 0, BuildingComponents.ID_MAGIC_CRYSTAL)
	template.set_component(1, 2, 0, BuildingComponents.ID_MAGIC_CORE)
	template.set_component(2, 2, 0, BuildingComponents.ID_MAGIC_CRYSTAL)
	template.set_component(0, 2, 1, BuildingComponents.ID_ENERGY_RUNE)
	template.set_component(2, 2, 1, BuildingComponents.ID_ENERGY_RUNE)
	template.set_component(0, 2, 2, BuildingComponents.ID_MAGIC_CRYSTAL)
	template.set_component(1, 2, 2, BuildingComponents.ID_MAGIC_CORE)
	template.set_component(2, 2, 2, BuildingComponents.ID_MAGIC_CRYSTAL)
	
	# 中层：魔法窗户和符文
	template.set_component(1, 1, 0, BuildingComponents.ID_WINDOW_LARGE)
	template.set_component(0, 1, 1, BuildingComponents.ID_WINDOW_LARGE)
	template.set_component(2, 1, 1, BuildingComponents.ID_WINDOW_LARGE)
	template.set_component(1, 1, 2, BuildingComponents.ID_WINDOW_LARGE)
	
	# 底层：魔法门和基础
	template.set_component(1, 0, 0, BuildingComponents.ID_GATE_STONE)
	template.set_component(1, 0, 1, BuildingComponents.ID_TORCH_WALL)
	template.set_component(1, 0, 2, BuildingComponents.ID_TORCH_WALL)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取奥术塔建筑配置"""
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
	config.tower_height = 1.5
	
	# 材质配置
	config.wall_color = Color(0.54, 0.17, 0.89) # 紫色
	config.roof_color = Color(0.8, 0.2, 0.9) # 深紫色
	config.floor_color = Color(0.3, 0.1, 0.4) # 深紫色
	config.window_color = Color.CYAN # 青色窗户
	config.door_color = Color.DARK_MAGENTA # 深紫色门
	
	return config


func _load_building_specific_components():
	"""加载奥术塔特定构件"""
	# 加载魔法构件
	_add_component_to_library("Magic_Crystal", BuildingComponents.ID_MAGIC_CRYSTAL)
	_add_component_to_library("Energy_Rune", BuildingComponents.ID_ENERGY_RUNE)
	_add_component_to_library("Magic_Core", BuildingComponents.ID_MAGIC_CORE)
	_add_component_to_library("Summoning_Circle", BuildingComponents.ID_SUMMONING_CIRCLE)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("🔮 [ArcaneTower3D] 奥术塔3D准备就绪")
	
	# 启动魔法特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("🔮 [ArcaneTower3D] 奥术塔3D建造完成")
	
	# 启动攻击系统
	_start_attack_system()
	
	# 启动魔法动画
	if construction_animator:
		construction_animator.play_function_animation("magic_energy")


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
	
	# 更新魔法特效
	_update_magic_effects(delta)


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
	
	if nearest_enemy and resource_manager:
		# 检查魔力
		if resource_manager.get_mana() >= mana_cost_per_attack:
			resource_manager.remove_mana(int(mana_cost_per_attack))
			
			# 播放攻击特效
			_play_attack_effect(nearest_enemy)
			
			# 攻击逻辑
			if nearest_enemy.has_method("take_damage"):
				nearest_enemy.take_damage(attack_damage)
				
				LogManager.info("🔮 [ArcaneTower3D] 奥术攻击: %.1f 伤害" % attack_damage)


func _play_attack_effect(target: Node):
	"""播放攻击特效"""
	if not effect_manager:
		return
	
	# 创建攻击粒子效果
	var target_pos = target.global_position if target else global_position + Vector3(0, 2, 0)
	effect_manager._create_particle_effect("magic_bolt", target_pos, 1.0)
	
	# 播放攻击动画
	if construction_animator:
		construction_animator.play_function_animation("magic_energy")


func _update_magic_effects(delta: float):
	"""更新魔法特效"""
	# 更新魔法能量流动
	_update_magic_energy_flow(delta)
	
	# 更新魔法水晶发光
	_update_magic_crystal_glow(delta)


func _update_magic_energy_flow(delta: float):
	"""更新魔法能量流动"""
	# 这里可以添加魔法能量流动的视觉效果
	pass


func _update_magic_crystal_glow(delta: float):
	"""更新魔法水晶发光"""
	# 这里可以添加魔法水晶发光的视觉效果
	pass


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新奥术塔特定特效
	_update_arcane_effects(delta)


func _update_arcane_effects(delta: float):
	"""更新奥术特效"""
	# 魔法能量波动
	if effect_manager and effect_manager.particle_systems.has("magic_energy"):
		var ps = effect_manager.particle_systems["magic_energy"]
		if ps and ps.emitting:
			# 调整粒子参数
			ps.amount = int(20 + sin(Time.get_time_dict_from_system()["second"] * 2) * 5)
	
	# 魔法光效波动
	if effect_manager and effect_manager.light_systems.has("magic_glow"):
		var light = effect_manager.light_systems["magic_glow"]
		if light and light.visible:
			# 调整光强度
			light.light_energy = 1.0 + sin(Time.get_time_dict_from_system()["second"] * 3) * 0.3


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加奥术塔特定信息
	base_info["attack_damage"] = attack_damage
	base_info["attack_range"] = attack_range
	base_info["mana_cost_per_attack"] = mana_cost_per_attack
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
	
	LogManager.info("💀 [ArcaneTower3D] 奥术塔被摧毁，所有特效已停止")
