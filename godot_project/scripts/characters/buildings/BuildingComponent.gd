extends MeshInstance3D
class_name BuildingComponent

## 🏗️ 建筑构件基类
## 用于3x3x3建筑系统的构件

@export var component_type: String = "floor" # floor, wall, corner, door, window, decoration
@export var component_material: String = "stone" # stone, wood, metal, magic, military
@export var component_id: int = 0

func _ready():
	"""构件准备就绪"""
	name = "BuildingComponent"
	
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
	
	# 根据构件类型设置碰撞形状
	match component_type:
		"floor":
			box_shape.size = Vector3(0.33, 0.05, 0.33)
		"wall":
			box_shape.size = Vector3(0.33, 0.33, 0.05)
		"corner":
			box_shape.size = Vector3(0.33, 0.33, 0.33)
		"door":
			box_shape.size = Vector3(0.33, 0.33, 0.05)
		"window":
			box_shape.size = Vector3(0.33, 0.33, 0.05)
		"decoration":
			box_shape.size = Vector3(0.33, 0.33, 0.33)
		_:
			box_shape.size = Vector3(0.33, 0.33, 0.33)
	
	collision_shape.shape = box_shape
	static_body.add_child(collision_shape)
	add_child(static_body)


func get_component_info() -> Dictionary:
	"""获取构件信息"""
	return {
		"type": component_type,
		"material": component_material,
		"id": component_id,
		"size": mesh.get("size") if mesh else Vector3.ZERO
	}
