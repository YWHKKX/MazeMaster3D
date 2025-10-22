extends UnifiedBuildingSystem
class_name UnifiedAcademy

## 统一学院建筑
## 使用自由组件系统管理学院

# 学院专用属性
var education_level: int = 1
var max_students: int = 20
var current_students: int = 0
var research_progress: float = 0.0
var wisdom_points: int = 0

func _init():
	super._init()
	building_type = BuildingTypes.BuildingType.ACADEMY
	building_name = "学院"
	building_description = "教育建筑，用于高级学习和研究"
	
	# 建筑属性
	health = 250
	max_health = 250
	armor = 8
	cost_gold = 1200
	
	# 资源存储属性
	gold_storage_capacity = 3000
	mana_storage_capacity = 1000
	stored_gold = 0
	stored_mana = 0
	
	# 建筑尺寸和主题
	building_size = Vector2(3, 3) # 3x3瓦块
	building_theme = "academic"
	building_tier = 3
	building_category = "education"
	
	# 设置渲染模式为自由组件系统
	render_mode = RenderMode.TRADITIONAL
	allow_free_placement = true
	
	# 初始化自由组件
	_setup_academy_components()

func _setup_academy_components():
	"""设置学院自由组件"""
	# 学院主体结构
	add_component("Academy_Main", Vector3(1.2, 0, 1.2), Vector3(0.6, 2.0, 0.6), "structure")
	add_component("Academy_Tower", Vector3(1.2, 2.0, 1.2), Vector3(0.8, 1.0, 0.8), "structure")
	add_component("Academy_Entrance", Vector3(1.2, 0, 0.3), Vector3(0.6, 1.5, 0.2), "structure")
	
	# 教育设施
	add_component("Classroom_Desk_1", Vector3(0.5, 0.1, 0.5), Vector3(0.6, 0.4, 0.3), "decoration")
	add_component("Classroom_Desk_2", Vector3(1.8, 0.1, 0.5), Vector3(0.6, 0.4, 0.3), "decoration")
	add_component("Classroom_Desk_3", Vector3(0.5, 0.1, 1.8), Vector3(0.6, 0.4, 0.3), "decoration")
	add_component("Classroom_Desk_4", Vector3(1.8, 0.1, 1.8), Vector3(0.6, 0.4, 0.3), "decoration")
	add_component("Teacher_Podium", Vector3(1.2, 0.1, 0.8), Vector3(0.4, 0.6, 0.3), "decoration")
	add_component("Research_Lab", Vector3(0.3, 0.1, 1.2), Vector3(0.6, 0.8, 0.4), "decoration")
	add_component("Academic_Library", Vector3(1.8, 0.1, 1.2), Vector3(0.4, 0.8, 0.6), "decoration")
	
	# 学术装饰
	add_component("Scholar_Statue", Vector3(1.2, 0.1, 1.5), Vector3(0.3, 0.8, 0.3), "decoration")
	add_component("Academic_Banner", Vector3(0.2, 0.8, 0.2), Vector3(0.2, 0.8, 0.1), "decoration")
	add_component("Wisdom_Tower", Vector3(2.2, 0.1, 2.2), Vector3(0.4, 1.2, 0.4), "decoration")
	
	# 🔧 验证坐标系统一致性
	validate_coordinate_system()

func _ready():
	"""建筑准备就绪"""
	super._ready()
	setup_free_components()
	_setup_academy_effects()

func _setup_academy_effects():
	"""设置学院特效"""
	# 创建智慧光效
	var wisdom_light = OmniLight3D.new()
	wisdom_light.light_color = Color(0.3, 0.6, 0.9)
	wisdom_light.light_energy = 1.8
	wisdom_light.omni_range = 4.0
	wisdom_light.position = Vector3(1.2, 1.5, 1.2)
	add_child(wisdom_light)
	
	# 创建智慧粒子效果
	var wisdom_particles = GPUParticles3D.new()
	wisdom_particles.position = Vector3(1.2, 0.8, 1.2)
	wisdom_particles.emitting = true
	wisdom_particles.amount = 60
	wisdom_particles.lifetime = 3.0
	add_child(wisdom_particles)
	
	LogManager.info("🎓 [UnifiedAcademy] 设置学院特效完成")

func _process(delta: float):
	"""学院处理逻辑"""
	_update_education_system(delta)
	_update_research_progress(delta)

func _update_education_system(delta: float):
	"""更新教育系统"""
	if current_students > 0:
		# 教育学生
		var education_amount = education_level * delta
		# 这里可以添加具体的教育逻辑
		wisdom_points = min(1000, wisdom_points + int(education_amount * 0.1))

func _update_research_progress(delta: float):
	"""更新研究进度"""
	if current_students > 0:
		# 进行研究
		var research_amount = education_level * current_students * delta / 100.0
		research_progress = min(100.0, research_progress + research_amount)

func get_academy_info() -> Dictionary:
	"""获取学院信息"""
	var info = get_building_info()
	info["education_level"] = education_level
	info["max_students"] = max_students
	info["current_students"] = current_students
	info["research_progress"] = research_progress
	info["wisdom_points"] = wisdom_points
	info["free_components"] = free_components.size()
	return info