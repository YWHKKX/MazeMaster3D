extends UnifiedBuildingSystem
class_name UnifiedFactory

## 统一工厂建筑
## 使用自由组件系统管理工厂

# 工厂专用属性
var production_rate: float = 2.0
var max_workers: int = 15
var current_workers: int = 0
var production_queue: Array = []
var raw_materials: int = 100
var finished_goods: int = 0

func _init():
	super._init()
	building_type = BuildingTypes.BuildingType.FACTORY
	building_name = "工厂"
	building_description = "工业建筑，用于大规模生产"
	
	# 建筑属性
	health = 350
	max_health = 350
	armor = 10
	cost_gold = 2500
	
	# 资源存储属性
	gold_storage_capacity = 5000
	mana_storage_capacity = 500
	stored_gold = 0
	stored_mana = 0
	
	# 建筑尺寸和主题
	building_size = Vector2(3, 3) # 3x3瓦块
	building_theme = "industrial"
	building_tier = 3
	building_category = "production"
	
	# 设置渲染模式为自由组件系统
	render_mode = RenderMode.TRADITIONAL
	allow_free_placement = true
	
	# 初始化自由组件
	_setup_factory_components()

func _setup_factory_components():
	"""设置工厂自由组件"""
	# 工厂主体结构
	add_component("Factory_Main", Vector3(1.2, 0, 1.2), Vector3(0.6, 1.5, 0.6), "structure")
	add_component("Smokestack", Vector3(1.2, 1.5, 1.2), Vector3(0.2, 0.8, 0.2), "structure")
	
	# 生产设施
	add_component("Assembly_Line", Vector3(0.5, 0.1, 0.5), Vector3(1.0, 0.2, 0.3), "decoration")
	add_component("Conveyor_Belt", Vector3(1.8, 0.1, 0.5), Vector3(0.8, 0.1, 0.2), "decoration")
	add_component("Storage_Crate_1", Vector3(0.3, 0.1, 1.0), Vector3(0.4, 0.6, 0.4), "decoration")
	add_component("Storage_Crate_2", Vector3(1.8, 0.1, 1.0), Vector3(0.4, 0.6, 0.4), "decoration")
	add_component("Ventilation", Vector3(1.2, 0.8, 0.2), Vector3(0.3, 0.4, 0.1), "decoration")
	
	# 🔧 验证坐标系统一致性
	validate_coordinate_system()

func _ready():
	"""建筑准备就绪"""
	super._ready()
	setup_free_components()
	_setup_factory_effects()

func _setup_factory_effects():
	"""设置工厂特效"""
	# 创建工业光效
	var industrial_light = OmniLight3D.new()
	industrial_light.light_color = Color(0.8, 0.8, 0.9)
	industrial_light.light_energy = 1.5
	industrial_light.omni_range = 3.5
	industrial_light.position = Vector3(1.2, 1.0, 1.2)
	add_child(industrial_light)
	
	# 创建工业粒子效果
	var industrial_particles = GPUParticles3D.new()
	industrial_particles.position = Vector3(1.2, 1.8, 1.2)
	industrial_particles.emitting = true
	industrial_particles.amount = 80
	industrial_particles.lifetime = 4.0
	add_child(industrial_particles)
	
	LogManager.info("🏭 [UnifiedFactory] 设置工厂特效完成")

func _process(delta: float):
	"""工厂处理逻辑"""
	_update_production_system(delta)
	_update_assembly_line(delta)

func _update_production_system(delta: float):
	"""更新生产系统"""
	if current_workers > 0 and raw_materials > 0:
		# 进行生产
		var production_amount = production_rate * current_workers * delta
		raw_materials = max(0, raw_materials - int(production_amount * 0.1))
		finished_goods = min(1000, finished_goods + int(production_amount * 0.05))

func _update_assembly_line(delta: float):
	"""更新装配线"""
	# 装配线移动效果
	# 这里可以添加具体的装配线动画逻辑
	pass

func get_factory_info() -> Dictionary:
	"""获取工厂信息"""
	var info = get_building_info()
	info["production_rate"] = production_rate
	info["max_workers"] = max_workers
	info["current_workers"] = current_workers
	info["raw_materials"] = raw_materials
	info["finished_goods"] = finished_goods
	info["production_queue_size"] = production_queue.size()
	info["free_components"] = free_components.size()
	return info