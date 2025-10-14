extends Node3D
class_name StatusIndicatorUI

# 状态指示器 - 为所有单位提供可视化状态反馈
# 使用3D透明光圈显示在单位脚底

# 导入常量
const WorkerConstants = preload("res://scripts/characters/WorkerConstants.gd")

# 当前状态
var current_state: String = "idle"
var is_visible: bool = true

# 3D组件
var mesh_instance: MeshInstance3D
var material: StandardMaterial3D

func _ready():
	"""初始化状态指示器"""
	# 默认显示
	visible = true
	is_visible = true
	
	# 创建3D光圈组件
	_create_3d_components()
	
	# 设置初始状态
	update_appearance()

func _create_3d_components():
	"""创建3D空心光圈组件（横向圆环）"""
	# 创建环形网格（TorusMesh默认是站立的，需要旋转）
	var torus_mesh = TorusMesh.new()
	torus_mesh.inner_radius = 0.8 # 内圈半径
	torus_mesh.outer_radius = 1.0 # 外圈半径（环宽度=0.2）
	torus_mesh.rings = 48 # 圆形精度（更平滑）
	torus_mesh.ring_segments = 6 # 环截面精度
	
	# 创建网格实例
	mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "StatusRing"
	mesh_instance.mesh = torus_mesh
	add_child(mesh_instance)
	
	# 创建发光材质
	material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED # 无光照，始终可见
	material.albedo_color = Color(1, 1, 1, 0.8) # 半透明白色
	material.cull_mode = BaseMaterial3D.CULL_DISABLED # 双面显示
	
	# 发光效果
	material.emission_enabled = true
	material.emission = Color.WHITE
	material.emission_energy_multiplier = 2.0 # 更强的发光
	
	mesh_instance.material_override = material
	
	# 关键：旋转让圆环平放在地面
	# TorusMesh默认沿Y轴站立，绕X轴+Y轴各旋转90度让它完全平躺
	mesh_instance.rotation = Vector3(PI / 2, PI / 2, 0) # 使用弧度 (绕X+Y)
	
	# 设置位置在脚底下方一点点（避免Z-fighting）
	mesh_instance.position = Vector3(0, -0.4, 0) # Y=-0.4相对于角色中心

func set_state(state: String):
	"""设置当前状态"""
	current_state = state
	update_appearance()

func get_color(state: String) -> Color:
	"""获取状态对应的颜色"""
	return WorkerConstants.get_status_color(state)

func update_appearance():
	"""更新外观"""
	if not material:
		return
		
	visible = is_visible
	var color = get_color(current_state)
	
	# 设置材质颜色和发光
	material.albedo_color = color
	material.emission = color # 发光颜色也跟随状态

func show_indicator():
	"""显示指示器"""
	is_visible = true
	visible = true

func hide_indicator():
	"""隐藏指示器"""
	is_visible = false
	visible = false

func get_status_description(state: String) -> String:
	"""获取状态的文字描述"""
	return WorkerConstants.get_status_description(state)

func get_all_states() -> Array:
	"""获取所有支持的状态列表"""
	return WorkerConstants.STATUS_COLORS.keys()

func set_custom_color(_state: String, _color: Color):
	"""设置自定义状态颜色"""
	# 注意：现在颜色在 WorkerConstants 中定义，这个方法保留用于兼容性
	push_warning("set_custom_color 已废弃，请在 WorkerConstants 中修改颜色定义")

func get_status_info(state: String) -> Dictionary:
	"""获取状态的完整信息"""
	return {
		"state": state,
		"color": get_color(state),
		"description": get_status_description(state)
	}
