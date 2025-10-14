extends Node3D

## 箭塔模型脚本
## 创建箭塔的3D视觉表现

var tower_base: MeshInstance3D = null
var tower_body: MeshInstance3D = null
var tower_top: MeshInstance3D = null


func _ready():
	"""创建箭塔模型"""
	_create_tower_model()


func _create_tower_model():
	"""创建箭塔的3D模型
	
	设计：
	- 底座：0.8x0.2x0.8 石灰色
	- 塔身：0.5x0.6x0.5 石灰色
	- 塔顶：圆锥形，石灰色
	"""
	# 底座
	tower_base = MeshInstance3D.new()
	tower_base.name = "TowerBase"
	var base_mesh = BoxMesh.new()
	base_mesh.size = Vector3(0.8, 0.2, 0.8)
	tower_base.mesh = base_mesh
	
	var base_material = StandardMaterial3D.new()
	base_material.albedo_color = Color(0.827, 0.827, 0.827).darkened(0.2) # 深石灰色
	base_material.roughness = 0.8
	base_material.metallic = 0.1
	tower_base.material_override = base_material
	tower_base.position = Vector3(0, 0.1, 0)
	add_child(tower_base)
	
	# 塔身
	tower_body = MeshInstance3D.new()
	tower_body.name = "TowerBody"
	var body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(0.5, 0.6, 0.5)
	tower_body.mesh = body_mesh
	
	var body_material = StandardMaterial3D.new()
	body_material.albedo_color = Color(0.827, 0.827, 0.827) # 石灰色 #D3D3D3
	body_material.roughness = 0.7
	body_material.metallic = 0.2
	tower_body.material_override = body_material
	tower_body.position = Vector3(0, 0.5, 0)
	add_child(tower_body)
	
	# 塔顶
	tower_top = MeshInstance3D.new()
	tower_top.name = "TowerTop"
	var top_mesh = CylinderMesh.new()
	top_mesh.top_radius = 0.1
	top_mesh.bottom_radius = 0.35
	top_mesh.height = 0.3
	tower_top.mesh = top_mesh
	
	var top_material = StandardMaterial3D.new()
	top_material.albedo_color = Color(0.7, 0.7, 0.7)
	top_material.roughness = 0.6
	top_material.metallic = 0.3
	tower_top.material_override = top_material
	tower_top.position = Vector3(0, 0.95, 0)
	add_child(tower_top)


func set_construction_progress(progress: float):
	"""设置建造进度"""
	var alpha = 0.3 + progress * 0.7
	
	for mesh in [tower_base, tower_body, tower_top]:
		if mesh and mesh.material_override:
			var mat = mesh.material_override as StandardMaterial3D
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color.a = alpha

