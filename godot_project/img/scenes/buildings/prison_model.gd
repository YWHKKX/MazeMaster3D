extends Node3D

var cage: MeshInstance3D
var bars: Array = []

func _ready():
	# 笼子主体
	cage = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.8, 0.7, 0.8)
	cage.mesh = mesh
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.3, 0.3, 0.5)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.8
	cage.material_override = material
	cage.position = Vector3(0, 0.35, 0)
	add_child(cage)
	
	# 铁栏杆
	for i in range(6):
		var bar = MeshInstance3D.new()
		var bar_mesh = BoxMesh.new()
		bar_mesh.size = Vector3(0.05, 0.7, 0.05)
		bar.mesh = bar_mesh
		var bar_mat = StandardMaterial3D.new()
		bar_mat.albedo_color = Color(0.2, 0.2, 0.2)
		bar_mat.metallic = 0.7
		bar.material_override = bar_mat
		var angle = (TAU / 6.0) * i
		bar.position = Vector3(cos(angle) * 0.4, 0.35, sin(angle) * 0.4)
		add_child(bar)
		bars.append(bar)

func set_construction_progress(progress: float):
	if cage and cage.material_override:
		var mat = cage.material_override as StandardMaterial3D
		mat.albedo_color.a = 0.3 + progress * 0.7

