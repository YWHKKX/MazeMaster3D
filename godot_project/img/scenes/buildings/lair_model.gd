extends Node3D

## 巢穴模型脚本
## 创建巢穴的3D视觉表现

var main_body: MeshInstance3D = null
var entrance: MeshInstance3D = null


func _ready():
	"""创建巢穴模型"""
	_create_lair_model()


func _create_lair_model():
	"""创建巢穴的3D模型
	
	设计：
	- 主体：0.9x0.6x0.9 深棕色低矮建筑
	- 入口：0.4x0.4x0.1 暗色洞穴入口
	"""
	# 主体
	main_body = MeshInstance3D.new()
	main_body.name = "LairBody"
	var body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(0.9, 0.6, 0.9)
	main_body.mesh = body_mesh
	
	var body_material = StandardMaterial3D.new()
	body_material.albedo_color = Color(0.396, 0.263, 0.129) # 深棕色 #654321
	body_material.roughness = 0.9
	body_material.metallic = 0.0
	main_body.material_override = body_material
	main_body.position = Vector3(0, 0.3, 0)
	add_child(main_body)
	
	# 入口
	entrance = MeshInstance3D.new()
	entrance.name = "LairEntrance"
	var entrance_mesh = BoxMesh.new()
	entrance_mesh.size = Vector3(0.4, 0.4, 0.1)
	entrance.mesh = entrance_mesh
	
	var entrance_material = StandardMaterial3D.new()
	entrance_material.albedo_color = Color(0.1, 0.05, 0.03) # 很暗的洞口
	entrance_material.roughness = 1.0
	entrance.material_override = entrance_material
	entrance.position = Vector3(0, 0.2, 0.48)
	add_child(entrance)


func set_construction_progress(progress: float):
	"""设置建造进度"""
	var alpha = 0.3 + progress * 0.7
	
	if main_body and main_body.material_override:
		var mat = main_body.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = alpha

