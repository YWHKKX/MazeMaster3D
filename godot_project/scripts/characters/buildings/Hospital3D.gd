extends Building3D
class_name Hospital3D

## 🏗️ 医院3D - 3x3x3医疗建筑
## 基于Building3D，实现医院的3x3x3渲染

# 医疗系统
var healing_power: float = 2.5                     # 治疗效果倍率
var patient_capacity: int = 6                       # 患者容量
var medical_supply_rate: float = 1.2                # 医疗用品生成速度
var emergency_response_bonus: float = 0.4          # 紧急响应加成（40%）

# 医疗状态
var current_patients: Array = []                    # 当前患者
var medical_supplies: int = 100                     # 医疗用品库存
var is_emergency_mode: bool = false                 # 是否紧急模式


func _init():
	"""初始化医院3D"""
	super._init()
	
	# 基础属性
	building_name = "医院"
	building_type = BuildingTypes.HOSPITAL
	max_health = 350
	health = max_health
	armor = 4
	building_size = Vector2(1, 1)  # 保持原有尺寸用于碰撞检测
	cost_gold = 600
	engineer_cost = 300
	build_time = 250.0
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
	
	# 材质配置（医疗风格）
	building_3d_config.set_material_config(
		wall = Color(0.9, 0.9, 0.95),   # 白色墙体
		roof = Color(0.8, 0.8, 0.85),   # 浅灰色屋顶
		floor = Color(0.95, 0.95, 1.0)   # 淡蓝色地板
	)
	
	# 特殊功能配置
	building_3d_config.set_special_config(
		lighting = true,    # 有光照
		particles = true,   # 有粒子特效
		animations = true,  # 有动画
		sound = false       # 暂时无音效
	)


func _get_building_template() -> BuildingTemplate:
	"""获取医院建筑模板"""
	var template = BuildingTemplate.new("医院")
	template.building_type = BuildingTypes.HOSPITAL
	template.description = "洁净的3x3x3医疗医院，散发着治愈的气息"
	
	# 创建医疗结构
	template.create_hospital_structure(BuildingTypes.HOSPITAL)
	
	# 自定义医院元素
	# 顶层：医疗设备和手术室
	template.set_component(0, 2, 0, BuildingComponents.ID_MEDICAL_EQUIPMENT)
	template.set_component(1, 2, 0, BuildingComponents.ID_SURGICAL_TABLE)
	template.set_component(2, 2, 0, BuildingComponents.ID_MEDICAL_EQUIPMENT)
	template.set_component(0, 2, 1, BuildingComponents.ID_MEDICAL_EQUIPMENT)
	template.set_component(1, 2, 1, BuildingComponents.ID_OPERATING_ROOM)
	template.set_component(2, 2, 1, BuildingComponents.ID_MEDICAL_EQUIPMENT)
	template.set_component(0, 2, 2, BuildingComponents.ID_MEDICAL_EQUIPMENT)
	template.set_component(1, 2, 2, BuildingComponents.ID_SURGICAL_TABLE)
	template.set_component(2, 2, 2, BuildingComponents.ID_MEDICAL_EQUIPMENT)
	
	# 中层：病房和护理站
	template.set_component(0, 1, 0, BuildingComponents.ID_HOSPITAL_BED)
	template.set_component(1, 1, 0, BuildingComponents.ID_NURSING_STATION)
	template.set_component(2, 1, 0, BuildingComponents.ID_HOSPITAL_BED)
	template.set_component(0, 1, 1, BuildingComponents.ID_HOSPITAL_BED)
	template.set_component(1, 1, 1, BuildingComponents.ID_HEALING_CRYSTAL)
	template.set_component(2, 1, 1, BuildingComponents.ID_HOSPITAL_BED)
	template.set_component(0, 1, 2, BuildingComponents.ID_HOSPITAL_BED)
	template.set_component(1, 1, 2, BuildingComponents.ID_NURSING_STATION)
	template.set_component(2, 1, 2, BuildingComponents.ID_HOSPITAL_BED)
	
	# 底层：药房和入口
	template.set_component(0, 0, 0, BuildingComponents.ID_PHARMACY)
	template.set_component(1, 0, 0, BuildingComponents.ID_PHARMACY)
	template.set_component(2, 0, 0, BuildingComponents.ID_PHARMACY)
	template.set_component(0, 0, 1, BuildingComponents.ID_PHARMACY)
	template.set_component(1, 0, 1, BuildingComponents.ID_RECEPTION_DESK)
	template.set_component(2, 0, 1, BuildingComponents.ID_PHARMACY)
	template.set_component(0, 0, 2, BuildingComponents.ID_PHARMACY)
	template.set_component(1, 0, 2, BuildingComponents.ID_PHARMACY)
	template.set_component(2, 0, 2, BuildingComponents.ID_PHARMACY)
	
	return template


func _get_building_config() -> BuildingConfig:
	"""获取医院建筑配置"""
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
	config.wall_color = Color(0.9, 0.9, 0.95)  # 白色
	config.roof_color = Color(0.8, 0.8, 0.85)    # 浅灰色
	config.floor_color = Color(0.95, 0.95, 1.0)   # 淡蓝色
	config.window_color = Color(0.9, 0.95, 1.0)  # 淡蓝色窗户
	config.door_color = Color(0.8, 0.8, 0.9)    # 浅蓝色门
	
	return config


func _load_building_specific_components():
	"""加载医院特定构件"""
	# 加载医疗构件
	_add_component_to_library("Medical_Equipment", BuildingComponents.ID_MEDICAL_EQUIPMENT)
	_add_component_to_library("Surgical_Table", BuildingComponents.ID_SURGICAL_TABLE)
	_add_component_to_library("Operating_Room", BuildingComponents.ID_OPERATING_ROOM)
	_add_component_to_library("Hospital_Bed", BuildingComponents.ID_HOSPITAL_BED)
	_add_component_to_library("Nursing_Station", BuildingComponents.ID_NURSING_STATION)
	_add_component_to_library("Healing_Crystal", BuildingComponents.ID_HEALING_CRYSTAL)
	_add_component_to_library("Pharmacy", BuildingComponents.ID_PHARMACY)
	_add_component_to_library("Reception_Desk", BuildingComponents.ID_RECEPTION_DESK)


func on_3d_building_ready():
	"""3D建筑准备就绪回调"""
	LogManager.info("🏥 [Hospital3D] 医院3D准备就绪")
	
	# 启动医院特效
	if effect_manager:
		effect_manager.start_functional_effects()


func on_3d_building_completed():
	"""3D建筑完成回调"""
	LogManager.info("🏥 [Hospital3D] 医院3D建造完成")
	
	# 启动医疗系统
	_start_medical_system()
	
	# 启动医院动画
	if construction_animator:
		construction_animator.play_function_animation("healing_activity")


func _start_medical_system():
	"""启动医疗系统"""
	# 设置医疗更新定时器
	var medical_timer = Timer.new()
	medical_timer.name = "MedicalTimer"
	medical_timer.wait_time = 1.0  # 每秒更新一次
	medical_timer.timeout.connect(_update_medical)
	medical_timer.autostart = true
	add_child(medical_timer)
	
	# 设置医疗用品生成定时器
	var supply_timer = Timer.new()
	supply_timer.name = "SupplyTimer"
	supply_timer.wait_time = 5.0  # 每5秒生成一次
	supply_timer.timeout.connect(_generate_medical_supplies)
	supply_timer.autostart = true
	add_child(supply_timer)


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑"""
	# 调用父类方法
	super._update_3d_building_logic(delta)
	
	# 更新医疗系统
	_update_medical_system(delta)
	
	# 更新医院特效
	_update_hospital_effects(delta)


func _update_medical_system(delta: float):
	"""更新医疗系统"""
	if status != BuildingStatus.COMPLETED:
		return
	
	# 更新治疗效果
	_update_healing_effects(delta)


func _update_healing_effects(delta: float):
	"""更新治疗效果"""
	# 这里可以添加治疗效果的视觉指示
	pass


func _update_medical():
	"""更新医疗"""
	# 治疗当前患者
	for patient in current_patients:
		if is_instance_valid(patient):
			_heal_patient(patient, 1.0)


func _heal_patient(patient: Node, delta: float):
	"""治疗患者"""
	if patient.has_method("apply_healing"):
		var healing_amount = healing_power * delta
		if is_emergency_mode:
			healing_amount *= (1.0 + emergency_response_bonus)
		
		patient.apply_healing(healing_amount)
		
		# 播放治疗特效
		_play_healing_effect()


func _generate_medical_supplies():
	"""生成医疗用品"""
	medical_supplies += int(medical_supply_rate)
	medical_supplies = min(medical_supplies, 200)  # 最大库存200
	
	# 播放医疗用品生成特效
	_play_supply_generation_effect()


func _play_healing_effect():
	"""播放治疗特效"""
	if not effect_manager:
		return
	
	# 创建治疗粒子效果
	effect_manager._create_particle_effect("healing", global_position + Vector3(0, 1, 0), 1.5)


func _play_supply_generation_effect():
	"""播放医疗用品生成特效"""
	if not effect_manager:
		return
	
	# 创建医疗用品生成粒子效果
	effect_manager._create_particle_effect("medical_supply", global_position + Vector3(0, 0.5, 0), 2.0)


func can_admit_patient() -> bool:
	"""检查是否可以接收新患者"""
	return current_patients.size() < patient_capacity and status == BuildingStatus.COMPLETED


func admit_patient(patient: Node) -> bool:
	"""接收患者"""
	if can_admit_patient():
		current_patients.append(patient)
		_play_patient_admission_effect()
		return true
	return false


func discharge_patient(patient: Node):
	"""出院患者"""
	current_patients.erase(patient)


func _play_patient_admission_effect():
	"""播放患者入院特效"""
	if not effect_manager:
		return
	
	# 创建患者入院粒子效果
	effect_manager._create_particle_effect("patient_admission", global_position + Vector3(0, 1, 0), 2.5)


func activate_emergency_mode():
	"""激活紧急模式"""
	is_emergency_mode = true
	_play_emergency_effect()
	LogManager.info("🏥 [Hospital3D] 紧急模式已激活")


func deactivate_emergency_mode():
	"""停用紧急模式"""
	is_emergency_mode = false
	_play_emergency_effect()
	LogManager.info("🏥 [Hospital3D] 紧急模式已停用")


func _play_emergency_effect():
	"""播放紧急模式特效"""
	if not effect_manager:
		return
	
	# 创建紧急模式粒子效果
	effect_manager._create_particle_effect("emergency_mode", global_position + Vector3(0, 2, 0), 4.0)


func _update_hospital_effects(delta: float):
	"""更新医院特效"""
	# 更新治疗水晶动画
	_update_healing_crystal_animation(delta)
	
	# 更新医疗设备活动
	_update_medical_equipment_activity(delta)


func _update_healing_crystal_animation(delta: float):
	"""更新治疗水晶动画"""
	# 治疗水晶动画
	if construction_animator:
		construction_animator.play_function_animation("healing_crystal")
	
	# 根据患者数量调整水晶发光
	var patient_intensity = float(current_patients.size()) / float(patient_capacity)
	
	if effect_manager and effect_manager.light_systems.has("healing_crystal_light"):
		var light = effect_manager.light_systems["healing_crystal_light"]
		if light and light.visible:
			light.light_energy = 0.7 + patient_intensity * 1.0
			light.light_color = Color(0.6, 0.9, 1.0)  # 淡蓝色治疗光


func _update_medical_equipment_activity(delta: float):
	"""更新医疗设备活动"""
	# 医疗设备活动动画
	if construction_animator:
		construction_animator.play_function_animation("medical_equipment")
	
	# 根据患者数量和紧急模式调整活动强度
	var activity_intensity = float(current_patients.size()) / float(patient_capacity)
	if is_emergency_mode:
		activity_intensity *= 1.5
	
	if effect_manager and effect_manager.particle_systems.has("medical_particles"):
		var ps = effect_manager.particle_systems["medical_particles"]
		if ps and ps.emitting:
			# 调整粒子强度
			ps.amount = int(3 + activity_intensity * 12)


func _update_functional_effects(delta: float):
	"""更新功能特效（重写父类方法）"""
	# 调用父类方法
	super._update_functional_effects(delta)
	
	# 更新医院特定特效
	_update_hospital_specific_effects(delta)


func _update_hospital_specific_effects(delta: float):
	"""更新医院特定特效"""
	# 医院脉冲效果
	var patient_count = current_patients.size()
	var pulse_frequency = 1.0 + patient_count * 0.5
	if is_emergency_mode:
		pulse_frequency *= 1.5
	
	if effect_manager and effect_manager.light_systems.has("hospital_glow"):
		var light = effect_manager.light_systems["hospital_glow"]
		if light and light.visible:
			# 医院脉冲
			light.light_energy = 0.5 + sin(Time.get_time_dict_from_system()["second"] * pulse_frequency) * 0.3
			light.light_color = Color(0.8, 0.9, 1.0)  # 淡蓝色医院光


func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加医院特定信息
	base_info["healing_power"] = healing_power
	base_info["patient_capacity"] = patient_capacity
	base_info["medical_supply_rate"] = medical_supply_rate
	base_info["emergency_response_bonus"] = emergency_response_bonus
	base_info["current_patients_count"] = current_patients.size()
	base_info["medical_supplies"] = medical_supplies
	base_info["is_emergency_mode"] = is_emergency_mode
	base_info["can_admit_patient"] = can_admit_patient()
	base_info["patient_capacity_ratio"] = float(current_patients.size()) / float(patient_capacity)
	
	return base_info


func _on_destroyed():
	"""建筑被摧毁时的回调（重写父类方法）"""
	# 调用父类方法
	super._on_destroyed()
	
	# 释放所有患者
	for patient in current_patients:
		if is_instance_valid(patient):
			discharge_patient(patient)
	
	# 停止所有特效
	if effect_manager:
		effect_manager.stop_functional_effects()
	
	# 停止所有动画
	if construction_animator:
		construction_animator.stop_all_animations()
	
	LogManager.info("💀 [Hospital3D] 医院被摧毁，所有特效已停止")
