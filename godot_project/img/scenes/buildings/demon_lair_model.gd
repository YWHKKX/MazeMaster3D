extends Node3D

## 恶魔巢穴模型脚本

var main_body: MeshInstance3D = null
var portal: MeshInstance3D = null

func _ready():
	_create_demon_lair_model()

func _create_demon_lair_model():
	"""创建恶魔巢穴模型 - 靛青色召唤门"""
	# 主体
	main_body = MeshInstance3D.new()
	var body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(0.9, 0.7, 0.9)
	main_body.mesh = body_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.294, 0.0, 0.51) # 靛青色 #4B0082
	material.roughness = 0.5
	material.metallic = 0.4
	material.emission_enabled = true
	material.emission = Color(0.4, 0.0, 0.6)
	material.emission_energy_multiplier = 1.2
	main_body.material_override = material
	main_body.position = Vector3(0, 0.35, 0)
	add_child(main_body)
	
	# 传送门效果
	portal = MeshInstance3D.new()
	var portal_mesh = BoxMesh.new()
	portal_mesh.size = Vector3(0.4, 0.5, 0.05)
	portal.mesh = portal_mesh
	
	var portal_material = StandardMaterial3D.new()
	portal_material.albedo_color = Color(0.5, 0.0, 0.8, 0.8)
	portal_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	portal_material.emission_enabled = true
	portal_material.emission = Color(0.7, 0.2, 1.0)
	portal_material.emission_energy_multiplier = 2.0
	portal.material_override = portal_material
	portal.position = Vector3(0, 0.35, 0.48)
	add_child(portal)
	
	# 传送门旋转动画
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(portal, "rotation:y", TAU, 4.0)

func set_construction_progress(progress: float):
	var alpha = 0.3 + progress * 0.7
	if main_body and main_body.material_override:
		var mat = main_body.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = alpha

