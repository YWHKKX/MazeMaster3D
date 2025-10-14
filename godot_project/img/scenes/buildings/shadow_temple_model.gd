extends Node3D

var temple_base: MeshInstance3D
var shadow_orb: MeshInstance3D

func _ready():
	# 神殿基座 - 深紫黑色
	temple_base = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.9, 0.6, 0.9)
	temple_base.mesh = mesh
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.0, 0.15)
	material.roughness = 0.4
	material.metallic = 0.5
	temple_base.material_override = material
	temple_base.position = Vector3(0, 0.3, 0)
	add_child(temple_base)
	
	# 暗影球
	shadow_orb = MeshInstance3D.new()
	var orb_mesh = SphereMesh.new()
	orb_mesh.radius = 0.2
	orb_mesh.height = 0.4
	shadow_orb.mesh = orb_mesh
	var orb_mat = StandardMaterial3D.new()
	orb_mat.albedo_color = Color(0.2, 0.0, 0.3, 0.8)
	orb_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	orb_mat.emission_enabled = true
	orb_mat.emission = Color(0.5, 0.0, 0.8)
	orb_mat.emission_energy_multiplier = 2.5
	shadow_orb.material_override = orb_mat
	shadow_orb.position = Vector3(0, 0.8, 0)
	add_child(shadow_orb)
	
	# 暗影球缓慢旋转和脉动
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(shadow_orb, "rotation:y", TAU, 5.0)
	
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(shadow_orb, "scale", Vector3(1.2, 1.2, 1.2), 2.0)
	pulse_tween.tween_property(shadow_orb, "scale", Vector3(1.0, 1.0, 1.0), 2.0)

func set_construction_progress(progress: float):
	if temple_base and temple_base.material_override:
		var mat = temple_base.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = 0.3 + progress * 0.7

