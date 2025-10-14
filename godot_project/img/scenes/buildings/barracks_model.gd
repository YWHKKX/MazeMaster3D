extends Node3D

## 训练室模型脚本

var main_body: MeshInstance3D = null
var training_dummy: MeshInstance3D = null

func _ready():
	_create_barracks_model()

func _create_barracks_model():
	"""创建训练室模型 - 铁灰色训练场"""
	# 主体
	main_body = MeshInstance3D.new()
	var body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(0.9, 0.7, 0.9)
	main_body.mesh = body_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.439, 0.502, 0.565) # 铁灰色 #708090
	material.roughness = 0.7
	material.metallic = 0.4
	main_body.material_override = material
	main_body.position = Vector3(0, 0.35, 0)
	add_child(main_body)
	
	# 训练假人
	training_dummy = MeshInstance3D.new()
	var dummy_mesh = CylinderMesh.new()
	dummy_mesh.top_radius = 0.1
	dummy_mesh.bottom_radius = 0.15
	dummy_mesh.height = 0.4
	training_dummy.mesh = dummy_mesh
	
	var dummy_material = StandardMaterial3D.new()
	dummy_material.albedo_color = Color(0.6, 0.4, 0.2)
	dummy_material.roughness = 0.8
	training_dummy.material_override = dummy_material
	training_dummy.position = Vector3(0.3, 0.5, 0.3)
	add_child(training_dummy)

func set_construction_progress(progress: float):
	var alpha = 0.3 + progress * 0.7
	if main_body and main_body.material_override:
		var mat = main_body.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = alpha

