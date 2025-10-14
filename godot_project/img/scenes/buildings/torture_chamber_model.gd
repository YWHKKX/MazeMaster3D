extends Node3D

var main_body: MeshInstance3D
var chains: Array = []

func _ready():
	# 主体 - 深红色
	main_body = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.9, 0.7, 0.9)
	main_body.mesh = mesh
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.4, 0.1, 0.1)
	material.roughness = 0.8
	material.emission_enabled = true
	material.emission = Color(0.3, 0.05, 0.05)
	material.emission_energy_multiplier = 0.5
	main_body.material_override = material
	main_body.position = Vector3(0, 0.35, 0)
	add_child(main_body)
	
	# 锁链装饰
	for i in range(4):
		var chain = MeshInstance3D.new()
		var chain_mesh = CylinderMesh.new()
		chain_mesh.top_radius = 0.02
		chain_mesh.bottom_radius = 0.02
		chain_mesh.height = 0.4
		chain.mesh = chain_mesh
		var chain_mat = StandardMaterial3D.new()
		chain_mat.albedo_color = Color(0.3, 0.3, 0.3)
		chain_mat.metallic = 0.8
		chain.material_override = chain_mat
		var angle = (TAU / 4.0) * i
		chain.position = Vector3(cos(angle) * 0.35, 0.5, sin(angle) * 0.35)
		add_child(chain)
		chains.append(chain)

func set_construction_progress(progress: float):
	if main_body and main_body.material_override:
		var mat = main_body.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = 0.3 + progress * 0.7

