extends UnifiedBuildingSystem
class_name UnifiedHospital

## 统一医院建筑
## 使用自由组件系统管理医院

# 医院专用属性
var healing_rate: float = 5.0
var max_patients: int = 10
var current_patients: int = 0
var medical_supplies: int = 100

func _init():
	super._init()
	building_type = BuildingTypes.BuildingType.HOSPITAL
	building_name = "医院"
	building_description = "医疗建筑，用于治疗和恢复"
	
	# 建筑属性
	health = 200
	max_health = 200
	armor = 5
	cost_gold = 800
	
	# 资源存储属性
	gold_storage_capacity = 2000
	mana_storage_capacity = 500
	stored_gold = 0
	stored_mana = 0
	
	# 建筑尺寸和主题
	building_size = Vector2(2, 2) # 2x2瓦块
	building_theme = "medical"
	building_tier = 2
	building_category = "healthcare"
	
	# 设置渲染模式为自由组件系统
	render_mode = RenderMode.TRADITIONAL
	allow_free_placement = true
	
	# 初始化自由组件
	_setup_hospital_components()

func _setup_hospital_components():
	"""设置医院自由组件"""
	# 医院主体结构
	add_component("Hospital_Main", Vector3(0.8, 0, 0.8), Vector3(1.2, 1.5, 1.2), "structure")
	add_component("Hospital_Roof", Vector3(0.8, 1.5, 0.8), Vector3(1.4, 0.2, 1.4), "structure")
	
	# 医疗设施
	add_component("Nursing_Station", Vector3(0.3, 0.1, 0.3), Vector3(0.6, 0.8, 0.4), "decoration")
	add_component("Hospital_Bed_1", Vector3(0.2, 0.1, 0.7), Vector3(0.5, 0.15, 0.3), "decoration")
	add_component("Hospital_Bed_2", Vector3(1.3, 0.1, 0.7), Vector3(0.5, 0.15, 0.3), "decoration")
	add_component("Medical_Equipment", Vector3(0.5, 0.1, 0.2), Vector3(0.3, 0.6, 0.2), "decoration")
	add_component("Surgical_Table", Vector3(1.0, 0.1, 0.2), Vector3(0.4, 0.8, 0.3), "decoration")
	add_component("Pharmacy", Vector3(1.5, 0.1, 1.0), Vector3(0.3, 0.6, 0.4), "decoration")
	add_component("Operating_Room", Vector3(0.2, 0.1, 1.3), Vector3(0.6, 0.8, 0.4), "decoration")
	
	# 治愈水晶
	add_component("Healing_Crystal", Vector3(0.8, 0.3, 0.8), Vector3(0.2, 0.4, 0.2), "decoration")
	
	LogManager.info("🏥 [UnifiedHospital] 设置医院自由组件完成")

func _ready():
	"""建筑准备就绪"""
	super._ready()
	setup_free_components()
	_setup_hospital_effects()

func _setup_hospital_effects():
	"""设置医院特效"""
	# 创建治愈光效
	var healing_light = OmniLight3D.new()
	healing_light.light_color = Color(0.3, 0.8, 0.3)
	healing_light.light_energy = 1.5
	healing_light.omni_range = 3.0
	healing_light.position = Vector3(0.8, 1.0, 0.8)
	add_child(healing_light)
	
	# 创建治愈粒子效果
	var healing_particles = GPUParticles3D.new()
	healing_particles.position = Vector3(0.8, 0.5, 0.8)
	healing_particles.emitting = true
	healing_particles.amount = 50
	healing_particles.lifetime = 2.0
	add_child(healing_particles)
	
	LogManager.info("🏥 [UnifiedHospital] 设置医院特效完成")

func _process(delta: float):
	"""医院处理逻辑"""
	_update_healing_system(delta)
	_update_medical_supplies(delta)

func _update_healing_system(delta: float):
	"""更新治疗系统"""
	if current_patients > 0 and medical_supplies > 0:
		# 治疗患者
		var healing_amount = healing_rate * delta
		# 这里可以添加具体的治疗逻辑
		medical_supplies = max(0, medical_supplies - int(healing_amount * 0.1))

func _update_medical_supplies(delta: float):
	"""更新医疗用品"""
	# 医疗用品自动补充
	if medical_supplies < 100:
		medical_supplies = min(100, medical_supplies + int(delta * 2))

func get_hospital_info() -> Dictionary:
	"""获取医院信息"""
	var info = get_building_info()
	info["healing_rate"] = healing_rate
	info["max_patients"] = max_patients
	info["current_patients"] = current_patients
	info["medical_supplies"] = medical_supplies
	info["free_components"] = free_components.size()
	return info