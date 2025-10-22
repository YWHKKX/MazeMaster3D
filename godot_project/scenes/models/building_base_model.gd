extends Node3D
class_name BuildingBaseModel

## 建筑基础模型脚本
## 为所有建筑提供统一的3D渲染和材质管理

# 建筑配置
var building_color: Color = Color.WHITE
var building_size: Vector3 = Vector3(1.0, 0.8, 1.0)
var emission_enabled: bool = false
var emission_color: Color = Color.BLACK
var emission_energy: float = 0.0

# 3D组件
var main_mesh: MeshInstance3D = null
var detail_mesh: MeshInstance3D = null


func _ready():
	"""初始化建筑模型"""
	pass


func create_building_mesh(color: Color, size: Vector3, has_emission: bool = false, emission_col: Color = Color.BLACK, emission_power: float = 0.0):
	"""创建建筑主体网格
	
	Args:
		color: 建筑颜色
		size: 建筑尺寸 (x, y, z)
		has_emission: 是否发光
		emission_col: 发光颜色
		emission_power: 发光强度
	"""
	building_color = color
	building_size = size
	emission_enabled = has_emission
	emission_color = emission_col
	emission_energy = emission_power
	
	# 创建主体
	main_mesh = MeshInstance3D.new()
	main_mesh.name = "BuildingMainMesh"
	
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	main_mesh.mesh = box_mesh
	
	# 创建材质
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.7
	material.metallic = 0.2
	
	if has_emission:
		material.emission_enabled = true
		material.emission = emission_col
		material.emission_energy_multiplier = emission_power
	
	main_mesh.material_override = material
	main_mesh.position = Vector3(0, size.y / 2, 0) # 底部对齐地面
	
	add_child(main_mesh)


func create_tower_mesh(color: Color, base_size: Vector2, height: float, has_emission: bool = false):
	"""创建塔楼型建筑
	
	Args:
		color: 建筑颜色
		base_size: 底座尺寸 (x, z)
		height: 塔楼高度
		has_emission: 是否发光
	"""
	# 底座
	var base = MeshInstance3D.new()
	base.name = "TowerBase"
	var base_mesh = BoxMesh.new()
	base_mesh.size = Vector3(base_size.x, 0.2, base_size.y)
	base.mesh = base_mesh
	
	var base_material = StandardMaterial3D.new()
	base_material.albedo_color = color.darkened(0.3)
	base_material.roughness = 0.8
	base_material.metallic = 0.1
	base.material_override = base_material
	base.position = Vector3(0, 0.1, 0)
	add_child(base)
	
	# 塔身
	main_mesh = MeshInstance3D.new()
	main_mesh.name = "TowerBody"
	var tower_mesh = BoxMesh.new()
	tower_mesh.size = Vector3(base_size.x * 0.6, height, base_size.y * 0.6)
	main_mesh.mesh = tower_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.7
	material.metallic = 0.3
	
	if has_emission:
		material.emission_enabled = true
		material.emission = color.lightened(0.3)
		material.emission_energy_multiplier = 1.0
	
	main_mesh.material_override = material
	main_mesh.position = Vector3(0, 0.2 + height / 2, 0)
	add_child(main_mesh)
	
	# 塔顶
	var top = MeshInstance3D.new()
	top.name = "TowerTop"
	var top_mesh = CylinderMesh.new()
	top_mesh.top_radius = base_size.x * 0.4
	top_mesh.bottom_radius = base_size.x * 0.6
	top_mesh.height = 0.3
	top.mesh = top_mesh
	
	var top_material = StandardMaterial3D.new()
	top_material.albedo_color = color.lightened(0.2)
	top_material.roughness = 0.5
	top_material.metallic = 0.4
	top.material_override = top_material
	top.position = Vector3(0, 0.2 + height + 0.15, 0)
	add_child(top)


func set_building_color(color: Color):
	"""设置建筑颜色"""
	building_color = color
	if main_mesh and main_mesh.material_override:
		main_mesh.material_override.albedo_color = color


func set_transparency(alpha: float):
	"""设置透明度（用于建造进度）"""
	if main_mesh and main_mesh.material_override:
		var material = main_mesh.material_override as StandardMaterial3D
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		var new_color = building_color
		new_color.a = alpha
		material.albedo_color = new_color


func set_emission(enabled: bool, color: Color = Color.WHITE, energy: float = 1.0):
	"""设置发光效果"""
	if main_mesh and main_mesh.material_override:
		var material = main_mesh.material_override as StandardMaterial3D
		material.emission_enabled = enabled
		if enabled:
			material.emission = color
			material.emission_energy_multiplier = energy


func add_progress_indicator(progress: float):
	"""添加建造进度指示（可视化）"""
	# 根据进度调整透明度
	var alpha = 0.3 + progress * 0.7 # 30% → 100%
	set_transparency(alpha)
	
	# 根据进度调整发光
	if progress < 1.0:
		set_emission(true, Color(0.3, 0.5, 0.9), 0.5)
	else:
		set_emission(emission_enabled, emission_color, emission_energy)

