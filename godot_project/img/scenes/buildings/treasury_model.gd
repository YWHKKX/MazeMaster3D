extends Node3D

## 金库模型脚本
## 创建金库的3D视觉表现

var main_body: MeshInstance3D = null
var door: MeshInstance3D = null
var lock_detail: MeshInstance3D = null


func _ready():
	"""创建金库模型"""
	_create_treasury_model()


func _create_treasury_model():
	"""创建金库的3D模型
	
	设计：
	- 主体：0.9x0.8x0.9 金色立方体
	- 门：0.5x0.6x0.05 深色门板
	- 锁：0.15x0.15x0.1 金色锁扣
	"""
	# 主体
	main_body = MeshInstance3D.new()
	main_body.name = "TreasuryBody"
	var body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(0.9, 0.8, 0.9)
	main_body.mesh = body_mesh
	
	var body_material = StandardMaterial3D.new()
	body_material.albedo_color = Color(1.0, 0.84, 0.0) # 金色 #FFD700
	body_material.roughness = 0.4
	body_material.metallic = 0.7
	body_material.emission_enabled = true
	body_material.emission = Color(0.8, 0.67, 0.0)
	body_material.emission_energy_multiplier = 0.3
	main_body.material_override = body_material
	main_body.position = Vector3(0, 0.4, 0)
	add_child(main_body)
	
	# 门板
	door = MeshInstance3D.new()
	door.name = "TreasuryDoor"
	var door_mesh = BoxMesh.new()
	door_mesh.size = Vector3(0.5, 0.6, 0.05)
	door.mesh = door_mesh
	
	var door_material = StandardMaterial3D.new()
	door_material.albedo_color = Color(0.3, 0.2, 0.1) # 深棕色
	door_material.roughness = 0.8
	door_material.metallic = 0.1
	door.material_override = door_material
	door.position = Vector3(0, 0.4, 0.48) # 前面
	add_child(door)
	
	# 锁扣
	lock_detail = MeshInstance3D.new()
	lock_detail.name = "TreasuryLock"
	var lock_mesh = BoxMesh.new()
	lock_mesh.size = Vector3(0.15, 0.15, 0.1)
	lock_detail.mesh = lock_mesh
	
	var lock_material = StandardMaterial3D.new()
	lock_material.albedo_color = Color(0.9, 0.8, 0.3) # 黄铜色
	lock_material.roughness = 0.3
	lock_material.metallic = 0.9
	lock_material.emission_enabled = true
	lock_material.emission = Color(0.7, 0.6, 0.2)
	lock_material.emission_energy_multiplier = 0.5
	lock_detail.material_override = lock_material
	lock_detail.position = Vector3(0, 0.4, 0.53) # 门上
	add_child(lock_detail)


func set_construction_progress(progress: float):
	"""设置建造进度（可视化）"""
	var alpha = 0.3 + progress * 0.7
	
	if main_body and main_body.material_override:
		var mat = main_body.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = alpha
	
	if door and door.material_override:
		var mat = door.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = alpha
	
	if lock_detail and lock_detail.material_override:
		var mat = lock_detail.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = alpha
	
	# 建造中发光效果
	if progress < 1.0:
		if main_body and main_body.material_override:
			var mat = main_body.material_override as StandardMaterial3D
			mat.emission = Color(0.3, 0.5, 0.9)
			mat.emission_energy_multiplier = 0.8


func set_completed_state():
	"""设置为完成状态"""
	if main_body and main_body.material_override:
		var mat = main_body.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		mat.albedo_color = Color(1.0, 0.84, 0.0, 1.0)
		mat.emission = Color(0.8, 0.67, 0.0)
		mat.emission_energy_multiplier = 0.3
	
	if door and door.material_override:
		var mat = door.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		mat.albedo_color.a = 1.0
	
	if lock_detail and lock_detail.material_override:
		var mat = lock_detail.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		mat.albedo_color.a = 1.0

