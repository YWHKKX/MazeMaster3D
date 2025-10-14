extends Node3D

var wall: MeshInstance3D
var spikes: Array = []

func _ready():
	# 围墙
	wall = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.9, 0.6, 0.2)
	wall.mesh = mesh
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.4, 0.4, 0.4)
	material.roughness = 0.9
	material.metallic = 0.2
	wall.material_override = material
	wall.position = Vector3(0, 0.3, 0)
	add_child(wall)
	
	# 尖刺
	for i in range(5):
		var spike = MeshInstance3D.new()
		var spike_mesh = CylinderMesh.new()
		spike_mesh.top_radius = 0.02
		spike_mesh.bottom_radius = 0.06
		spike_mesh.height = 0.3
		spike.mesh = spike_mesh
		var spike_mat = StandardMaterial3D.new()
		spike_mat.albedo_color = Color(0.3, 0.3, 0.3)
		spike.material_override = spike_mat
		spike.position = Vector3(-0.4 + i * 0.2, 0.75, 0)
		add_child(spike)
		spikes.append(spike)

func set_construction_progress(progress: float):
	if wall and wall.material_override:
		var mat = wall.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = 0.3 + progress * 0.7

