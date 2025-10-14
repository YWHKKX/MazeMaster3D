extends Node

## 建筑模型工厂
## 为所有建筑类型生成统一的3D模型

class_name BuildingModelFactory

## 建筑模型配置
class BuildingModelConfig:
	var name: String
	var color: Color
	var size: Vector3
	var style: String # "box", "tower", "temple"
	var emission: bool = false
	var emission_color: Color = Color.BLACK
	var emission_energy: float = 0.0
	var special_features: Array = []
	
	func _init(n: String, c: Color, s: Vector3, st: String = "box"):
		name = n
		color = c
		size = s
		style = st


static func create_box_building(config: BuildingModelConfig) -> Node3D:
	"""创建箱型建筑"""
	var root = Node3D.new()
	
	var mesh_inst = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = config.size
	mesh_inst.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = config.color
	material.roughness = 0.7
	material.metallic = 0.2
	
	if config.emission:
		material.emission_enabled = true
		material.emission = config.emission_color
		material.emission_energy_multiplier = config.emission_energy
	
	mesh_inst.material_override = material
	mesh_inst.position = Vector3(0, config.size.y / 2, 0)
	root.add_child(mesh_inst)
	
	return root


static func create_tower_building(config: BuildingModelConfig) -> Node3D:
	"""创建塔型建筑"""
	var root = Node3D.new()
	
	# 底座
	var base = MeshInstance3D.new()
	var base_mesh = BoxMesh.new()
	base_mesh.size = Vector3(config.size.x, 0.2, config.size.z)
	base.mesh = base_mesh
	
	var base_material = StandardMaterial3D.new()
	base_material.albedo_color = config.color.darkened(0.3)
	base_material.roughness = 0.8
	base.material_override = base_material
	base.position = Vector3(0, 0.1, 0)
	root.add_child(base)
	
	# 塔身
	var body = MeshInstance3D.new()
	var body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(config.size.x * 0.6, config.size.y - 0.4, config.size.z * 0.6)
	body.mesh = body_mesh
	
	var body_material = StandardMaterial3D.new()
	body_material.albedo_color = config.color
	body_material.roughness = 0.7
	body_material.metallic = 0.3
	
	if config.emission:
		body_material.emission_enabled = true
		body_material.emission = config.emission_color
		body_material.emission_energy_multiplier = config.emission_energy
	
	body.material_override = body_material
	body.position = Vector3(0, 0.2 + (config.size.y - 0.4) / 2, 0)
	root.add_child(body)
	
	# 塔顶
	var top = MeshInstance3D.new()
	var top_mesh = CylinderMesh.new()
	top_mesh.top_radius = config.size.x * 0.3
	top_mesh.bottom_radius = config.size.x * 0.6
	top_mesh.height = 0.3
	top.mesh = top_mesh
	
	var top_material = StandardMaterial3D.new()
	top_material.albedo_color = config.color.lightened(0.2)
	top_material.roughness = 0.6
	top.material_override = top_material
	top.position = Vector3(0, config.size.y - 0.05, 0)
	root.add_child(top)
	
	return root


static func create_temple_building(config: BuildingModelConfig) -> Node3D:
	"""创建神殿型建筑"""
	var root = Node3D.new()
	
	# 主体（扁平）
	var base = MeshInstance3D.new()
	var base_mesh = BoxMesh.new()
	base_mesh.size = Vector3(config.size.x, config.size.y * 0.6, config.size.z)
	base.mesh = base_mesh
	
	var base_material = StandardMaterial3D.new()
	base_material.albedo_color = config.color
	base_material.roughness = 0.5
	base_material.metallic = 0.3
	base.material_override = base_material
	base.position = Vector3(0, config.size.y * 0.3, 0)
	root.add_child(base)
	
	# 顶部水晶
	var crystal = MeshInstance3D.new()
	var crystal_mesh = BoxMesh.new()
	crystal_mesh.size = Vector3(config.size.x * 0.4, config.size.y * 0.5, config.size.z * 0.4)
	crystal.mesh = crystal_mesh
	
	var crystal_material = StandardMaterial3D.new()
	crystal_material.albedo_color = config.color.lightened(0.3)
	crystal_material.roughness = 0.3
	crystal_material.metallic = 0.6
	crystal_material.emission_enabled = true
	crystal_material.emission = config.emission_color if config.emission else config.color.lightened(0.5)
	crystal_material.emission_energy_multiplier = config.emission_energy if config.emission else 1.0
	crystal.material_override = crystal_material
	crystal.position = Vector3(0, config.size.y * 0.6 + config.size.y * 0.25, 0)
	crystal.rotation = Vector3(deg_to_rad(15), deg_to_rad(45), 0)
	root.add_child(crystal)
	
	# 旋转动画
	var tween = root.create_tween()
	tween.set_loops()
	tween.tween_property(crystal, "rotation:y", TAU, 6.0)
	
	return root

