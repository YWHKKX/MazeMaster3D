class_name ResourceMarker
extends Node3D

## 资源标记3D节点
## 用于在地图上显示资源位置和状态

# 资源类型常量（避免循环依赖）
const RESOURCE_TYPE_GOLD = 0
const RESOURCE_TYPE_FOOD = 1
const RESOURCE_TYPE_STONE = 2
const RESOURCE_TYPE_WOOD = 3
const RESOURCE_TYPE_IRON = 4
const RESOURCE_TYPE_GEM = 5
const RESOURCE_TYPE_MAGIC_HERB = 6
const RESOURCE_TYPE_MAGIC_CRYSTAL = 7
const RESOURCE_TYPE_DEMON_CORE = 8
const RESOURCE_TYPE_MANA = 9

signal resource_collected(resource_type: int, position: Vector2)
signal resource_clicked(resource_type: int, position: Vector2)

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var label_3d: Label3D = $Label3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var resource_type: int = RESOURCE_TYPE_GOLD
var resource_amount: int = 1
var resource_position: Vector2 = Vector2.ZERO
var is_collectible: bool = true
var collection_radius: float = 2.0

# 资源图标映射
var RESOURCE_ICONS = {
	RESOURCE_TYPE_GOLD: "💰",
	RESOURCE_TYPE_FOOD: "🍖",
	RESOURCE_TYPE_STONE: "🔳", # 使用方块替代石头
	RESOURCE_TYPE_WOOD: "📦", # 使用箱子替代木材
	RESOURCE_TYPE_IRON: "⛏️",
	RESOURCE_TYPE_GEM: "💎",
	RESOURCE_TYPE_MAGIC_HERB: "🌿",
	RESOURCE_TYPE_MAGIC_CRYSTAL: "✨",
	RESOURCE_TYPE_DEMON_CORE: "👹",
	RESOURCE_TYPE_MANA: "✨"
}

# 资源颜色映射
var RESOURCE_COLORS = {
	RESOURCE_TYPE_GOLD: Color.YELLOW,
	RESOURCE_TYPE_FOOD: Color.ORANGE,
	RESOURCE_TYPE_STONE: Color.GRAY,
	RESOURCE_TYPE_WOOD: Color.BROWN,
	RESOURCE_TYPE_IRON: Color.SILVER,
	RESOURCE_TYPE_GEM: Color.MAGENTA,
	RESOURCE_TYPE_MAGIC_HERB: Color.GREEN,
	RESOURCE_TYPE_MAGIC_CRYSTAL: Color.CYAN,
	RESOURCE_TYPE_DEMON_CORE: Color.RED,
	RESOURCE_TYPE_MANA: Color.PURPLE
}

func _ready():
	"""初始化资源标记"""
	_setup_marker()
	_setup_interaction()

func _setup_marker():
	"""设置标记外观"""
	if label_3d:
		label_3d.text = RESOURCE_ICONS.get(resource_type, "❓")
		label_3d.modulate = RESOURCE_COLORS.get(resource_type, Color.WHITE)
	
	if mesh_instance:
		# 创建材质
		var material = StandardMaterial3D.new()
		material.albedo_color = RESOURCE_COLORS.get(resource_type, Color.WHITE)
		material.metallic = 0.8 if resource_type == 0 or resource_type == 2 else 0.2 # 0=GOLD, 2=IRON
		material.roughness = 0.3
		material.emission = RESOURCE_COLORS.get(resource_type, Color.WHITE) * 0.2
		mesh_instance.material_override = material

func _setup_interaction():
	"""设置交互"""
	# 添加输入事件处理
	set_process_input(true)

func _input_event(camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""处理输入事件"""
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_on_marker_clicked()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_on_marker_right_clicked()

func _on_marker_clicked():
	"""标记被点击"""
	if is_collectible:
		resource_clicked.emit(resource_type, resource_position)

func _on_marker_right_clicked():
	"""标记被右键点击"""
	# 显示资源信息
	_show_resource_info()

func _show_resource_info():
	"""显示资源信息"""
	if GameServices.has_method("get_resource_manager"):
		var resource_manager = GameServices.get_resource_manager()
		if resource_manager:
			var resource_name = resource_manager.get_resource_name(resource_type)
			LogManager.info("资源信息: %s x%d 在位置 %s" % [resource_name, resource_amount, str(resource_position)])

func setup_resource(resource_type_param: int, amount: int, position: Vector2):
	"""设置资源信息"""
	resource_type = resource_type_param
	resource_amount = amount
	resource_position = position
	
	# 更新显示
	_setup_marker()
	
	# 设置位置
	global_position = Vector3(position.x, 0.5, position.y)

func collect_resource(collector_position: Vector3) -> int:
	"""收集资源"""
	if not is_collectible:
		return 0
	
	# 检查收集距离
	var distance = global_position.distance_to(collector_position)
	if distance > collection_radius:
		LogManager.warning("ResourceMarker - 距离太远，无法收集资源")
		return 0
	
	# 播放收集动画
	_play_collect_animation()
	
	# 发射收集信号
	resource_collected.emit(resource_type, resource_position)
	
	var collected_amount = resource_amount
	is_collectible = false
	
	LogManager.info("ResourceMarker - 收集资源: %s x%d" % [RESOURCE_ICONS.get(resource_type, "?"), collected_amount])
	
	return collected_amount

func _play_collect_animation():
	"""播放收集动画"""
	if animation_player and animation_player.has_animation("collect"):
		animation_player.play("collect")

func _play_idle_animation():
	"""播放空闲动画"""
	if animation_player and animation_player.has_animation("idle"):
		animation_player.play("idle")

func set_collectible(collectible: bool):
	"""设置是否可收集"""
	is_collectible = collectible
	if mesh_instance:
		mesh_instance.modulate = Color.WHITE if collectible else Color.GRAY
	if label_3d:
		label_3d.modulate = Color.WHITE if collectible else Color.GRAY

func get_resource_info() -> Dictionary:
	"""获取资源信息"""
	return {
		"type": resource_type,
		"amount": resource_amount,
		"position": resource_position,
		"is_collectible": is_collectible,
		"world_position": global_position
	}

func update_amount(new_amount: int):
	"""更新资源数量"""
	resource_amount = new_amount
	if resource_amount <= 0:
		is_collectible = false
		_play_collect_animation()
		# 延迟销毁
		await get_tree().create_timer(1.0).timeout
		queue_free()

# 静态方法
static func create_resource_marker(resource_type: int, amount: int, position: Vector2) -> ResourceMarker:
	"""创建资源标记"""
	# 动态加载场景文件
	var marker_scene = load("res://scenes/ui/resource_marker.tscn")
	if not marker_scene:
		# 如果场景文件不存在，创建一个简单的标记
		var marker = ResourceMarker.new()
		marker.setup_resource(resource_type, amount, position)
		return marker
	
	var marker = marker_scene.instantiate() as ResourceMarker
	if marker:
		marker.setup_resource(resource_type, amount, position)
	return marker
