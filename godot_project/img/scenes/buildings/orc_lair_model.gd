extends Node3D

## 兽人巢穴模型脚本

var main_body: MeshInstance3D = null
var banner: MeshInstance3D = null

func _ready():
	_create_orc_lair_model()

func _create_orc_lair_model():
	"""创建兽人巢穴模型 - 马鞍棕色战棚"""
	# 主体
	main_body = MeshInstance3D.new()
	var body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(0.9, 0.7, 0.9)
	main_body.mesh = body_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.545, 0.271, 0.075) # 马鞍棕色 #8B4513
	material.roughness = 0.8
	material.metallic = 0.1
	main_body.material_override = material
	main_body.position = Vector3(0, 0.35, 0)
	add_child(main_body)
	
	# 战旗
	banner = MeshInstance3D.new()
	var banner_mesh = BoxMesh.new()
	banner_mesh.size = Vector3(0.1, 0.4, 0.3)
	banner.mesh = banner_mesh
	
	var banner_material = StandardMaterial3D.new()
	banner_material.albedo_color = Color(0.6, 0.0, 0.0) # 深红色战旗
	banner_material.roughness = 0.9
	banner.material_override = banner_material
	banner.position = Vector3(0.4, 0.9, 0)
	add_child(banner)

func set_construction_progress(progress: float):
	var alpha = 0.3 + progress * 0.7
	if main_body and main_body.material_override:
		var mat = main_body.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = alpha

