extends UnifiedBuildingSystem
class_name UnifiedLibrary

## 统一图书馆建筑
## 使用自由组件系统管理图书馆

# 图书馆专用属性
var knowledge_storage: int = 1000
var research_efficiency: float = 1.5
var max_scholars: int = 6
var current_scholars: int = 0
var book_count: int = 200

func _init():
	super._init()
	building_type = BuildingTypes.BuildingType.LIBRARY
	building_name = "图书馆"
	building_description = "知识建筑，用于学习和研究"
	
	# 建筑属性
	health = 120
	max_health = 120
	armor = 2
	cost_gold = 600
	
	# 资源存储属性
	gold_storage_capacity = 1000
	mana_storage_capacity = 800
	stored_gold = 0
	stored_mana = 0
	
	# 建筑尺寸和主题
	building_size = Vector2(2, 2) # 2x2瓦块
	building_theme = "academic"
	building_tier = 2
	building_category = "education"
	
	# 设置渲染模式为自由组件系统
	render_mode = RenderMode.TRADITIONAL
	allow_free_placement = true
	
	# 初始化自由组件
	_setup_library_components()

func _setup_library_components():
	"""设置图书馆自由组件"""
	# 图书馆主体结构
	add_component("Library_Main", Vector3(0.8, 0, 0.8), Vector3(1.2, 1.3, 1.2), "structure")
	add_component("Library_Roof", Vector3(0.8, 1.3, 0.8), Vector3(1.4, 0.2, 1.4), "structure")
	
	# 学术设施
	add_component("Reading_Desk_1", Vector3(0.3, 0.1, 0.3), Vector3(0.6, 0.4, 0.3), "decoration")
	add_component("Reading_Desk_2", Vector3(1.3, 0.1, 0.3), Vector3(0.6, 0.4, 0.3), "decoration")
	add_component("Research_Table", Vector3(0.5, 0.1, 0.7), Vector3(0.8, 0.5, 0.4), "decoration")
	add_component("Bookshelf_1", Vector3(0.2, 0.1, 0.8), Vector3(0.2, 0.8, 0.8), "decoration")
	add_component("Bookshelf_2", Vector3(1.5, 0.1, 0.8), Vector3(0.2, 0.8, 0.8), "decoration")
	add_component("Scroll_Rack", Vector3(0.8, 0.1, 0.2), Vector3(0.4, 0.6, 0.2), "decoration")
	
	# 知识水晶和装饰
	add_component("Knowledge_Orb", Vector3(0.8, 0.3, 0.8), Vector3(0.3, 0.3, 0.3), "decoration")
	add_component("Wisdom_Crystal", Vector3(0.3, 0.2, 1.3), Vector3(0.2, 0.4, 0.2), "decoration")
	add_component("Study_Lamp", Vector3(1.2, 0.2, 1.3), Vector3(0.2, 0.3, 0.2), "decoration")
	
	LogManager.info("📚 [UnifiedLibrary] 设置图书馆自由组件完成")

func _ready():
	"""建筑准备就绪"""
	super._ready()
	setup_free_components()
	_setup_library_effects()

func _setup_library_effects():
	"""设置图书馆特效"""
	# 创建知识光效
	var knowledge_light = OmniLight3D.new()
	knowledge_light.light_color = Color(0.2, 0.6, 0.9)
	knowledge_light.light_energy = 1.3
	knowledge_light.omni_range = 2.8
	knowledge_light.position = Vector3(0.8, 0.8, 0.8)
	add_child(knowledge_light)
	
	# 创建知识粒子效果
	var knowledge_particles = GPUParticles3D.new()
	knowledge_particles.position = Vector3(0.8, 0.4, 0.8)
	knowledge_particles.emitting = true
	knowledge_particles.amount = 40
	knowledge_particles.lifetime = 2.5
	add_child(knowledge_particles)
	
	LogManager.info("📚 [UnifiedLibrary] 设置图书馆特效完成")

func _process(delta: float):
	"""图书馆处理逻辑"""
	_update_research_system(delta)
	_update_knowledge_storage(delta)

func _update_research_system(delta: float):
	"""更新研究系统"""
	if current_scholars > 0 and book_count > 0:
		# 进行研究
		var research_amount = research_efficiency * delta
		# 这里可以添加具体的研究逻辑
		knowledge_storage = min(1000, knowledge_storage + int(research_amount * 0.1))

func _update_knowledge_storage(delta: float):
	"""更新知识存储"""
	# 知识自动增长
	if current_scholars > 0:
		var knowledge_gain = research_efficiency * current_scholars * delta / 10.0
		knowledge_storage = min(1000, knowledge_storage + int(knowledge_gain))

func get_library_info() -> Dictionary:
	"""获取图书馆信息"""
	var info = get_building_info()
	info["knowledge_storage"] = knowledge_storage
	info["research_efficiency"] = research_efficiency
	info["max_scholars"] = max_scholars
	info["current_scholars"] = current_scholars
	info["book_count"] = book_count
	info["free_components"] = free_components.size()
	return info