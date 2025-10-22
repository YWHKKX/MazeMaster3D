extends Node3D
class_name BuildingPreview

## 建筑预览系统
## 
## 🔧 [建造系统] 实现建造前的虚化预览效果
## - 透明度调制（半透明）
## - 颜色反馈（绿色=可建造，红色=不可建造）
## - 动态跟随鼠标/目标位置

# 预览状态
enum PreviewState {
	VALID, # 可以建造（绿色）
	INVALID, # 不能建造（红色）
	NEUTRAL # 中性（蓝色）
}

# 预览配置
var building_type: int = -1
var building_size: Vector2 = Vector2(1, 1)
var preview_state: PreviewState = PreviewState.NEUTRAL

# 视觉节点
var preview_mesh: MeshInstance3D = null
var preview_material: StandardMaterial3D = null

# 颜色配置
const COLOR_VALID = Color(0.0, 1.0, 0.0, 0.5) # 绿色半透明
const COLOR_INVALID = Color(1.0, 0.0, 0.0, 0.5) # 红色半透明
const COLOR_NEUTRAL = Color(0.0, 0.8, 1.0, 0.5) # 蓝色半透明

# 动画效果
var pulse_timer: float = 0.0
var pulse_speed: float = 2.0


func _ready():
	"""初始化预览"""
	_create_preview_mesh()


func setup_preview(b_type: int, b_size: Vector2 = Vector2(1, 1)):
	"""设置预览参数
	
	Args:
		b_type: 建筑类型
		b_size: 建筑尺寸（格子数）
	"""
	building_type = b_type
	building_size = b_size
	
	# 重新创建合适尺寸的mesh
	_create_preview_mesh()
	
	# 设置初始状态
	set_preview_state(PreviewState.NEUTRAL)


func _create_preview_mesh():
	"""创建预览网格
	
	🔧 创建半透明的立方体作为建筑预览
	"""
	# 清理旧mesh
	if preview_mesh:
		preview_mesh.queue_free()
	
	# 创建新mesh
	preview_mesh = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	
	# 根据建筑尺寸设置mesh大小
	box_mesh.size = Vector3(
		building_size.x, # X方向
		0.8, # 高度（稍微矮一点显示是虚影）
		building_size.y # Z方向
	)
	
	preview_mesh.mesh = box_mesh
	
	# 创建半透明材质
	preview_material = StandardMaterial3D.new()
	preview_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	preview_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED # 无光照，更亮
	preview_material.albedo_color = COLOR_NEUTRAL
	
	preview_mesh.material_override = preview_material
	
	# 添加到场景树
	add_child(preview_mesh)
	
	# 🔧 [建筑渲染系统] 调整位置（与UnifiedBuildingSystem保持一致）
	# UnifiedBuildingSystem的global_position在格子中心(x+0.5, 0.05, z+0.5)
	# Mesh底部在Y=0，中心在Y=0.4
	# 相对于Building(Y=0.05)的偏移 = 0.4 - 0.05 = 0.35
	preview_mesh.position = Vector3(0, 0.35, 0)


func set_preview_state(state: PreviewState):
	"""设置预览状态（更新颜色）
	
	Args:
		state: 预览状态
	"""
	preview_state = state
	
	if not preview_material:
		return
	
	match state:
		PreviewState.VALID:
			preview_material.albedo_color = COLOR_VALID
		PreviewState.INVALID:
			preview_material.albedo_color = COLOR_INVALID
		PreviewState.NEUTRAL:
			preview_material.albedo_color = COLOR_NEUTRAL


func update_position(world_pos: Vector3, is_valid: bool):
	"""更新预览位置和状态
	
	Args:
		world_pos: 世界坐标
		is_valid: 该位置是否可建造
	"""
	global_position = world_pos
	
	# 更新状态颜色
	if is_valid:
		set_preview_state(PreviewState.VALID)
	else:
		set_preview_state(PreviewState.INVALID)


func _process(delta: float):
	"""添加脉冲动画效果
	
	🔧 让预览有呼吸感，更明显
	"""
	if not preview_material:
		return
	
	pulse_timer += delta * pulse_speed
	
	# 透明度在0.3-0.7之间脉动
	var base_alpha = 0.5
	var pulse_alpha = sin(pulse_timer) * 0.2
	var current_color = preview_material.albedo_color
	current_color.a = base_alpha + pulse_alpha
	preview_material.albedo_color = current_color


func show_preview():
	"""显示预览"""
	visible = true


func hide_preview():
	"""隐藏预览"""
	visible = false


func destroy():
	"""销毁预览"""
	queue_free()
