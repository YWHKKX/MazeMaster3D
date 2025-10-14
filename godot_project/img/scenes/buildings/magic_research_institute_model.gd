extends "res://img/scenes/models/building_base_model.gd"

## 🔮 魔法研究院 3D模型
## 显示深紫色魔法塔与研究装置

func _ready():
	super._ready()
	_create_magic_research_institute_model()

func _create_magic_research_institute_model():
	"""创建魔法研究院模型"""
	# 主建筑塔身（深紫色高塔）
	var tower = MeshInstance3D.new()
	tower.mesh = BoxMesh.new()
	tower.mesh.size = Vector3(0.6, 1.2, 0.6)
	var tower_material = StandardMaterial3D.new()
	tower_material.albedo_color = Color(0.29, 0.0, 0.51) # 深紫色 #4B0082
	tower_material.metallic = 0.3
	tower_material.roughness = 0.7
	tower.material_override = tower_material
	tower.position = Vector3(0, 0.6, 0)
	add_child(tower)
	
	# 魔法研究球体（顶部紫色能量球）
	var orb = MeshInstance3D.new()
	orb.mesh = SphereMesh.new()
	orb.mesh.radius = 0.2
	orb.mesh.height = 0.4
	var orb_material = StandardMaterial3D.new()
	orb_material.albedo_color = Color(0.6, 0.2, 0.8) # 亮紫色
	orb_material.emission_enabled = true
	orb_material.emission = Color(0.6, 0.2, 0.8)
	orb_material.emission_energy = 1.5
	orb.material_override = orb_material
	orb.position = Vector3(0, 1.4, 0)
	add_child(orb)
	
	# 研究平台（中层平台）
	var platform = MeshInstance3D.new()
	platform.mesh = BoxMesh.new()
	platform.mesh.size = Vector3(0.8, 0.1, 0.8)
	var platform_material = StandardMaterial3D.new()
	platform_material.albedo_color = Color(0.2, 0.0, 0.4) # 深紫色
	platform.material_override = platform_material
	platform.position = Vector3(0, 0.8, 0)
	add_child(platform)
	
	# 魔法书（4本浮动的魔法书环绕）
	for i in range(4):
		var book = MeshInstance3D.new()
		book.mesh = BoxMesh.new()
		book.mesh.size = Vector3(0.1, 0.15, 0.08)
		var book_material = StandardMaterial3D.new()
		book_material.albedo_color = Color(0.5, 0.3, 0.7) # 淡紫色
		book_material.emission_enabled = true
		book_material.emission = Color(0.5, 0.3, 0.7)
		book_material.emission_energy = 0.5
		book.material_override = book_material
		
		# 环绕排列
		var angle = i * PI / 2
		book.position = Vector3(cos(angle) * 0.5, 0.9, sin(angle) * 0.5)
		book.rotation = Vector3(0, angle + PI / 2, PI / 6)
		add_child(book)
	
	# 基座符文环（底部魔法阵）
	var rune_ring = MeshInstance3D.new()
	rune_ring.mesh = TorusMesh.new()
	rune_ring.mesh.inner_radius = 0.3
	rune_ring.mesh.outer_radius = 0.4
	var rune_material = StandardMaterial3D.new()
	rune_material.albedo_color = Color(0.4, 0.1, 0.6)
	rune_material.emission_enabled = true
	rune_material.emission = Color(0.6, 0.2, 0.8)
	rune_material.emission_energy = 1.0
	rune_ring.material_override = rune_material
	rune_ring.position = Vector3(0, 0.05, 0)
	rune_ring.rotation = Vector3(PI / 2, 0, 0)
	add_child(rune_ring)
	
	print("🔮 [MagicResearchInstituteModel] 魔法研究院模型已创建 | 组件数: %d" % get_child_count())
