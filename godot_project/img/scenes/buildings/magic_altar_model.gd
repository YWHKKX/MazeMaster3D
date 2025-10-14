extends Node3D

var altar_base: MeshInstance3D
var crystal: MeshInstance3D

func _ready():
	# 祭坛底座 - 青色
	altar_base = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.8, 0.3, 0.8)
	altar_base.mesh = mesh
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.0, 0.502, 0.502) # 青色 #008080
	material.roughness = 0.5
	material.metallic = 0.4
	altar_base.material_override = material
	altar_base.position = Vector3(0, 0.15, 0)
	add_child(altar_base)
	
	# 漂浮水晶
	crystal = MeshInstance3D.new()
	var crystal_mesh = BoxMesh.new()
	crystal_mesh.size = Vector3(0.25, 0.35, 0.25)
	crystal.mesh = crystal_mesh
	var crystal_mat = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.2, 0.8, 0.8, 0.9)
	crystal_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(0.3, 1.0, 1.0)
	crystal_mat.emission_energy_multiplier = 2.0
	crystal.material_override = crystal_mat
	crystal.position = Vector3(0, 0.6, 0)
	crystal.rotation = Vector3(deg_to_rad(30), deg_to_rad(45), deg_to_rad(15))
	add_child(crystal)
	
	# 水晶旋转和上下浮动
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(crystal, "rotation:y", TAU, 4.0)
	
	var float_tween = create_tween()
	float_tween.set_loops()
	float_tween.tween_property(crystal, "position:y", 0.7, 2.0)
	float_tween.tween_property(crystal, "position:y", 0.6, 2.0)

func set_construction_progress(progress: float):
	if altar_base and altar_base.material_override:
		var mat = altar_base.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = 0.3 + progress * 0.7

