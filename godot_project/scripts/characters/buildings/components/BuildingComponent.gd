extends MeshInstance3D

## 🏗️ 建筑构件基类
## 支持自由尺寸和位置的构件系统

@export var component_type: String = "floor" # floor, wall, corner, door, window, decoration
@export var component_material: String = "stone" # stone, wood, metal, magic, military
@export var component_id: int = 0
@export var component_size: Vector3 = Vector3(0.33, 0.33, 0.33) # 自由尺寸
@export var component_position: Vector3 = Vector3.ZERO # 自由位置

func _ready():
	"""构件准备就绪"""
	name = "BuildingComponent"
	
	# 设置位置和尺寸
	position = component_position
	
	# 创建碰撞体
	_create_collision_shape()


func _create_collision_shape():
	"""创建碰撞形状"""
	var static_body = StaticBody3D.new()
	static_body.name = "ComponentCollision"
	
	# 设置碰撞层
	static_body.collision_layer = 0
	static_body.set_collision_layer_value(4, true) # 建筑层
	
	# 创建碰撞形状
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	
	# 使用自由尺寸
	box_shape.size = component_size
	
	collision_shape.shape = box_shape
	static_body.add_child(collision_shape)
	add_child(static_body)


func set_component_properties(type: String, material: String, size: Vector3, pos: Vector3):
	"""设置构件属性"""
	component_type = type
	component_material = material
	component_size = size
	component_position = pos
	
	# 更新位置
	position = pos
	
	# 重新创建碰撞体
	_recreate_collision_shape()


func _recreate_collision_shape():
	"""重新创建碰撞形状"""
	# 移除旧的碰撞体
	var old_collision = get_node_or_null("ComponentCollision")
	if old_collision:
		old_collision.queue_free()
	
	# 创建新的碰撞体
	_create_collision_shape()


func get_component_info() -> Dictionary:
	"""获取构件信息"""
	return {
		"type": component_type,
		"material": component_material,
		"id": component_id,
		"size": component_size,
		"position": component_position
	}
