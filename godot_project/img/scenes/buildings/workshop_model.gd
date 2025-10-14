extends Node3D

var main_body: MeshInstance3D
var chimney: MeshInstance3D

func _ready():
	# 主体 - 灰棕色
	main_body = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.9, 0.7, 0.9)
	main_body.mesh = mesh
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.4, 0.3)
	material.roughness = 0.8
	material.metallic = 0.3
	main_body.material_override = material
	main_body.position = Vector3(0, 0.35, 0)
	add_child(main_body)
	
	# 烟囱
	chimney = MeshInstance3D.new()
	var chimney_mesh = CylinderMesh.new()
	chimney_mesh.top_radius = 0.08
	chimney_mesh.bottom_radius = 0.1
	chimney_mesh.height = 0.4
	chimney.mesh = chimney_mesh
	var chimney_mat = StandardMaterial3D.new()
	chimney_mat.albedo_color = Color(0.3, 0.3, 0.3)
	chimney.material_override = chimney_mat
	chimney.position = Vector3(0.3, 0.9, 0.3)
	add_child(chimney)

func set_construction_progress(progress: float):
	if main_body and main_body.material_override:
		var mat = main_body.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = 0.3 + progress * 0.7

