extends Node3D

var main_body: MeshInstance3D
var book_shelf: MeshInstance3D

func _ready():
	# 主体 - 深蓝色
	main_body = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.9, 0.7, 0.9)
	main_body.mesh = mesh
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.098, 0.098, 0.439) # 深蓝色 #191970
	material.roughness = 0.6
	material.metallic = 0.2
	main_body.material_override = material
	main_body.position = Vector3(0, 0.35, 0)
	add_child(main_body)
	
	# 书架装饰
	book_shelf = MeshInstance3D.new()
	var shelf_mesh = BoxMesh.new()
	shelf_mesh.size = Vector3(0.7, 0.5, 0.2)
	book_shelf.mesh = shelf_mesh
	var shelf_mat = StandardMaterial3D.new()
	shelf_mat.albedo_color = Color(0.4, 0.3, 0.2)
	book_shelf.material_override = shelf_mat
	book_shelf.position = Vector3(0, 0.35, 0.4)
	add_child(book_shelf)

func set_construction_progress(progress: float):
	if main_body and main_body.material_override:
		var mat = main_body.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = 0.3 + progress * 0.7

