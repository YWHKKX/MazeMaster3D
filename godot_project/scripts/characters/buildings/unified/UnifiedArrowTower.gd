extends UnifiedBuildingSystem
class_name UnifiedArrowTower

## 🏹 统一箭塔
## 使用UnifiedBuildingSystem的箭塔实现

# 攻击系统
var attack_damage: float = 25.0
var attack_range: float = 80.0
var attack_interval: float = 2.0
var crit_rate: float = 0.25 # 25%暴击率
var crit_multiplier: float = 2.0
var ammo_count: int = 50
var max_ammo: int = 50
var last_attack_time: float = 0.0

# 军事特效
var military_energy_level: float = 1.0
var arrow_glow: float = 0.0


func _init():
	"""初始化箭塔"""
	super._init()
	
	# 基础属性
	building_type = BuildingTypes.BuildingType.ARROW_TOWER
	building_name = "箭塔"
	
	# 建筑属性
	max_health = 600
	health = 600
	armor = 8
	
	# 建造成本
	cost_gold = 150
	engineer_cost = 75
	build_time = 80.0
	engineer_required = 1
	
	# 建筑尺寸
	building_size = Vector2(1, 1)
	
	# 存储系统
	gold_storage_capacity = 0  # 箭塔不存储金币


func _ready():
	"""场景准备就绪"""
	# 设置渲染模式（推荐使用3D系统）
	render_mode = BuildingRenderMode.RenderMode.GRIDMAP
	
	# 调用父类初始化
	super._ready()
	
	# 箭塔特定初始化
	_setup_arrow_tower_specific()


func _setup_arrow_tower_specific():
	"""设置箭塔特定功能"""
	# 设置军事特效
	if building_3d:
		_setup_military_effects()
	
	# 设置攻击系统
	_setup_attack_system()


func _setup_military_effects():
	"""设置军事特效"""
	if not building_3d:
		return
	
	# 启动军事粒子效果
	if building_3d.effect_manager:
		building_3d.effect_manager.start_functional_effects()
	
	# 设置军事光效
	_setup_military_lighting()


func _setup_military_lighting():
	"""设置军事光照"""
	# 创建军事光源
	var military_light = OmniLight3D.new()
	military_light.name = "MilitaryLight"
	military_light.light_energy = 0.6
	military_light.light_color = Color(1.0, 0.8, 0.4) # 橙黄色
	military_light.omni_range = 4.0
	military_light.position = Vector3(0, 1.5, 0)
	
	add_child(military_light)


func _setup_attack_system():
	"""设置攻击系统"""
	# 设置攻击定时器
	var attack_timer = Timer.new()
	attack_timer.name = "AttackTimer"
	attack_timer.wait_time = attack_interval
	attack_timer.timeout.connect(_try_attack)
	attack_timer.autostart = true
	add_child(attack_timer)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("🏹 [UnifiedArrowTower] 箭塔3D准备就绪")
	
	# 启动军事特效
	_setup_military_effects()
	
	# 启动攻击系统
	_setup_attack_system()


func on_traditional_building_ready():
	"""传统建筑准备就绪回调"""
	LogManager.info("🏹 [UnifiedArrowTower] 箭塔传统准备就绪")
	
	# 传统系统的军事效果
	_setup_traditional_military_effects()


func _setup_traditional_military_effects():
	"""设置传统军事效果"""
	if not traditional_visual:
		return
	
	# 设置军事材质
	var material = traditional_visual.material_override
	if material:
		material.emission_enabled = true
		material.emission = Color(1.0, 0.8, 0.4)
		material.emission_energy = 0.2


func _on_construction_completed():
	"""建造完成回调"""
	super._on_construction_completed()
	
	# 箭塔建造完成后的特殊处理
	LogManager.info("🏹 [UnifiedArrowTower] 箭塔建造完成，军事系统激活")
	
	# 根据当前渲染系统执行相应逻辑
	if is_using_3d_system():
		on_3d_building_ready()
	else:
		on_traditional_building_ready()


func switch_to_3d_system():
	"""切换到3D系统"""
	super.switch_to_3d_system()
	
	# 箭塔特定的3D切换逻辑
	on_3d_building_ready()


func switch_to_traditional_system():
	"""切换到传统系统"""
	super.switch_to_traditional_system()
	
	# 箭塔特定的传统切换逻辑
	on_traditional_building_ready()


func _process(delta: float):
	"""每帧更新"""
	super._process(delta)
	
	# 更新攻击系统
	_update_attack_system(delta)
	
	# 更新军事特效
	_update_military_effects(delta)


func _update_attack_system(delta: float):
	"""更新攻击系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 检查弹药
	if ammo_count <= 0:
		_reload_ammo()
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
	
	if nearest_enemy:
		# 消耗弹药
		ammo_count -= 1
		
		# 计算伤害（包括暴击）
		var damage = attack_damage
		var is_crit = randf() < crit_rate
		if is_crit:
			damage *= crit_multiplier
		
		# 播放攻击特效
		_play_attack_effect(nearest_enemy, is_crit)
		
		# 攻击逻辑
		if nearest_enemy.has_method("take_damage"):
			nearest_enemy.take_damage(damage)
			
			var crit_text = " (暴击!)" if is_crit else ""
			LogManager.info("🏹 [UnifiedArrowTower] 箭矢攻击: %.1f 伤害%s" % [damage, crit_text])


func _play_attack_effect(target: Node, is_crit: bool = false):
	"""播放攻击特效"""
	# 创建攻击粒子效果
	var target_pos = target.global_position if target else global_position + Vector3(0, 1.5, 0)
	
	# 根据当前渲染系统播放特效
	if is_using_3d_system() and building_3d and building_3d.effect_manager:
		var effect_name = "arrow_crit" if is_crit else "arrow_shot"
		building_3d.effect_manager._create_particle_effect(effect_name, target_pos, 1.0)
	else:
		# 传统系统的简单特效
		_play_traditional_attack_effect(target_pos, is_crit)


func _play_traditional_attack_effect(target_pos: Vector3, is_crit: bool = false):
	"""播放传统攻击特效"""
	# 简单的发光效果
	if traditional_visual:
		var material = traditional_visual.material_override
		if material:
			var tween = create_tween()
			var intensity = 3.0 if is_crit else 1.5
			tween.tween_property(material, "emission_energy", intensity, 0.1)
			tween.tween_property(material, "emission_energy", 0.2, 0.3)


func _reload_ammo():
	"""重新装弹"""
	if ammo_count < max_ammo:
		ammo_count = min(max_ammo, ammo_count + 10)
		LogManager.info("🏹 [UnifiedArrowTower] 重新装弹: %d/%d" % [ammo_count, max_ammo])


func _update_military_effects(delta: float):
	"""更新军事特效"""
	# 更新军事能量流动
	_update_military_energy_flow(delta)
	
	# 更新箭矢发光
	_update_arrow_glow(delta)


func _update_military_energy_flow(delta: float):
	"""更新军事能量流动"""
	# 军事能量波动
	military_energy_level = 1.0 + sin(Time.get_time_dict_from_system()["second"] * 1.5) * 0.2
	
	# 根据当前渲染系统更新特效
	if is_using_3d_system() and building_3d and building_3d.effect_manager:
		_update_3d_military_effects()
	else:
		_update_traditional_military_effects()


func _update_3d_military_effects():
	"""更新3D军事特效"""
	if building_3d and building_3d.effect_manager:
		# 更新粒子系统
		if building_3d.effect_manager.particle_systems.has("military_energy"):
			var ps = building_3d.effect_manager.particle_systems["military_energy"]
			if ps and ps.emitting:
				ps.amount = int(15 + sin(Time.get_time_dict_from_system()["second"] * 1.5) * 3)
		
		# 更新光照系统
		if building_3d.effect_manager.light_systems.has("military_glow"):
			var light = building_3d.effect_manager.light_systems["military_glow"]
			if light and light.visible:
				light.light_energy = military_energy_level


func _update_traditional_military_effects():
	"""更新传统军事特效"""
	if traditional_visual:
		var material = traditional_visual.material_override
		if material and material.emission_enabled:
			material.emission_energy = 0.2 + sin(Time.get_time_dict_from_system()["second"] * 1.5) * 0.1


func _update_arrow_glow(delta: float):
	"""更新箭矢发光"""
	arrow_glow = sin(Time.get_time_dict_from_system()["second"] * 2) * 0.3 + 0.7


func get_military_power() -> int:
	"""获取军事力量值"""
	return 80 + (health * 1.5)


func can_attack() -> bool:
	"""检查是否可以攻击"""
	return status == BuildingStatus.COMPLETED and is_active and ammo_count > 0


func get_ammo_percentage() -> float:
	"""获取弹药百分比"""
	return float(ammo_count) / float(max_ammo)


func get_building_info() -> Dictionary:
	"""获取建筑信息"""
	var info = super.get_building_info() if super.has_method("get_building_info") else {}
	
	info["attack_damage"] = attack_damage
	info["attack_range"] = attack_range
	info["crit_rate"] = crit_rate
	info["crit_multiplier"] = crit_multiplier
	info["ammo_count"] = ammo_count
	info["max_ammo"] = max_ammo
	info["ammo_percentage"] = get_ammo_percentage()
	info["last_attack_time"] = last_attack_time
	info["next_attack_in"] = max(0, attack_interval - last_attack_time)
	info["military_power"] = get_military_power()
	info["can_attack"] = can_attack()
	info["render_mode"] = BuildingRenderMode.RenderMode.keys()[render_mode]
	info["is_3d_system"] = is_using_3d_system()
	info["is_traditional_system"] = is_using_traditional_system()
	
	return info


func _on_destroyed():
	"""建筑被摧毁时的回调"""
	# 调用父类方法
	super._on_destroyed()
	
	# 停止所有特效
	if building_3d and building_3d.effect_manager:
		building_3d.effect_manager.stop_functional_effects()
	
	# 停止攻击定时器
	var attack_timer = get_node_or_null("AttackTimer")
	if attack_timer:
		attack_timer.stop()
		attack_timer.queue_free()
	
	LogManager.info("💀 [UnifiedArrowTower] 箭塔被摧毁，所有特效已停止")
