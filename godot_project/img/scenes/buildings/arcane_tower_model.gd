extends Node3D

var tower_body: MeshInstance3D
var crystal: MeshInstance3D

func _ready():
	# 塔身 - 紫色
	tower_body = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.5, 0.8, 0.5)
	tower_body.mesh = mesh
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.541, 0.169, 0.886) # 紫色 #8A2BE2
	material.roughness = 0.5
	material.metallic = 0.4
	material.emission_enabled = true
	material.emission = Color(0.6, 0.2, 1.0)
	material.emission_energy_multiplier = 1.0
	tower_body.material_override = material
	tower_body.position = Vector3(0, 0.4, 0)
	add_child(tower_body)
	
	# 顶部水晶
	crystal = MeshInstance3D.new()
	var crystal_mesh = BoxMesh.new()
	crystal_mesh.size = Vector3(0.2, 0.3, 0.2)
	crystal.mesh = crystal_mesh
	var crystal_mat = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.8, 0.4, 1.0, 0.8)
	crystal_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(1.0, 0.5, 1.0)
	crystal_mat.emission_energy_multiplier = 2.0
	crystal.material_override = crystal_mat
	crystal.position = Vector3(0, 1.0, 0)
	crystal.rotation = Vector3(deg_to_rad(45), deg_to_rad(45), 0)
	add_child(crystal)
	
	# 水晶旋转
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(crystal, "rotation:y", TAU, 3.0)

func set_construction_progress(progress: float):
	if tower_body and tower_body.material_override:
		var mat = tower_body.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = 0.3 + progress * 0.7

