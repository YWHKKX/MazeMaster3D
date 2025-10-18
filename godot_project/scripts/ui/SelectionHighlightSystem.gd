extends Node
class_name SelectionHighlightSystem

# 选择高亮系统 - 基于统一放置系统集成文档设计
# 提供智能的高亮提示和位置验证

# 预加载 TileManager
const TileManager = preload("res://scripts/managers/TileManager.gd")

# 高亮状态枚举
enum HighlightState {
	NONE, # 无高亮
	VALID, # 可以放置 - 绿色
	INVALID_TERRAIN, # 地形问题 - 红色
	INVALID_OCCUPIED, # 位置占用 - 橙色
	INVALID_RESOURCES, # 资源不足 - 黄色
	INVALID_DISTANCE, # 距离过远 - 紫色
	DIGGABLE # 可以挖掘 - 青色
}

# --- 内置高亮系统（合并自 TileHighlightSystem） ---
# 高亮颜色定义
const HIGHLIGHT_COLORS = {
	"GREEN": Color(0.0, 1.0, 0.0, 0.8),
	"YELLOW": Color(1.0, 1.0, 0.0, 0.8),
	"CYAN": Color(0.0, 1.0, 1.0, 0.8),
	"RED": Color(1.0, 0.0, 0.0, 0.8),
	"PURPLE": Color(0.8, 0.0, 1.0, 0.8),
	"ORANGE": Color(1.0, 0.5, 0.0, 0.8),
	"BROWN": Color(0.6, 0.4, 0.2, 0.8)
}

# 高亮类型枚举（渲染使用）
enum HighlightType {
	NONE,
	GREEN,
	YELLOW,
	CYAN,
	RED,
	PURPLE,
	ORANGE,
	BROWN
}

# 高亮模式
enum HighlightMode {
	OVERLAY,
	WIREFRAME,
	OUTLINE
}

# 高亮状态到高亮类型的映射
var highlight_to_type = {
	HighlightState.NONE: HighlightType.NONE,
	HighlightState.VALID: HighlightType.GREEN,
	HighlightState.INVALID_TERRAIN: HighlightType.RED,
	HighlightState.INVALID_OCCUPIED: HighlightType.ORANGE,
	HighlightState.INVALID_RESOURCES: HighlightType.YELLOW,
	HighlightState.INVALID_DISTANCE: HighlightType.PURPLE,
	HighlightState.DIGGABLE: HighlightType.CYAN
}

# 当前高亮状态
var current_state: HighlightState = HighlightState.NONE
var current_position: Vector3 = Vector3.ZERO
# current_highlight_color 已移除，不再需要

# 节点引用
@onready var tile_manager = get_node("/root/Main/TileManager")
@onready var character_manager = get_node("/root/Main/CharacterManager")
@onready var building_manager = get_node("/root/Main/BuildingManager")
@onready var highlight_container: Node3D = null

# 内置高亮渲染状态
var highlighted_map := {}
var highlight_mode: HighlightMode = HighlightMode.OVERLAY
var tile_size: Vector3 = Vector3(1.0, 1.0, 1.0)

# 当前选中的实体信息
var current_entity_id: String = ""
var current_entity_type: String = ""

# 当前高亮的瓦块位置（用于清除高亮）
var highlighted_tiles: Array[Vector3] = []


func _ready():
	"""初始化选择高亮系统"""
	# 等待一帧确保所有@onready变量都已初始化
	await get_tree().process_frame
	
	# 初始化高亮容器与瓦片尺寸
	if not highlight_container:
		highlight_container = Node3D.new()
		highlight_container.name = "TileHighlights"
		get_tree().current_scene.add_child(highlight_container)
		LogManager.info("高亮容器已创建")
	
	if tile_manager:
		tile_size = tile_manager.get_tile_size()
		LogManager.info("瓦片尺寸: " + str(tile_size))
	else:
		LogManager.error("TileManager未找到，高亮系统可能无法正常工作")
	
	# 设置默认高亮模式
	highlight_mode = HighlightMode.OVERLAY
	LogManager.info("高亮系统初始化完成，模式: " + str(highlight_mode))


func _clear_previous_highlights():
	"""清除之前的高亮效果"""
	# 清除内部高亮节点
	for pos_key in highlighted_map.keys():
		var data = highlighted_map[pos_key]
		if data.node and is_instance_valid(data.node):
			data.node.queue_free()
	highlighted_map.clear()
	highlighted_tiles.clear()
	# 减少日志输出以提高性能
	# LogManager.debug("高亮已清除")

func _clear_highlights_except_position(keep_position: Vector3):
	"""清除除了指定位置外的所有高亮效果"""
	var pos_key_to_keep = _position_to_key(keep_position)
	var positions_to_remove = []
	
	# 找出需要移除的位置
	for pos_key in highlighted_map.keys():
		if pos_key != pos_key_to_keep:
			positions_to_remove.append(pos_key)
	
	# 移除不需要的高亮
	for pos_key in positions_to_remove:
		var data = highlighted_map[pos_key]
		if data.node and is_instance_valid(data.node):
			data.node.queue_free()
		highlighted_map.erase(pos_key)
	
	# 更新highlighted_tiles列表
	highlighted_tiles.clear()
	for pos_key in highlighted_map.keys():
		var data = highlighted_map[pos_key]
		highlighted_tiles.append(data.position)


func _set_tile_highlight(position: Vector3, state: HighlightState):
	"""设置瓦块的高亮效果"""
	# 获取对应的高亮类型
	var highlight_type = highlight_to_type.get(state, HighlightType.NONE)
	# 设置瓦块高亮
	_highlight_tile(position, highlight_type)
	# 记录高亮的瓦块位置
	if not highlighted_tiles.has(position):
		highlighted_tiles.append(position)

# ---------- 内联高亮渲染逻辑 ----------
func set_highlight_mode(mode: HighlightMode):
	highlight_mode = mode
	_refresh_all_highlights()

func _highlight_tile(position: Vector3, highlight_type: HighlightType):
	if highlight_type == HighlightType.NONE:
		_clear_tile_highlight(position)
		return
	
	# 确保高亮容器存在
	if not highlight_container:
		LogManager.error("❌ [高亮渲染] 高亮容器未初始化，无法创建高亮")
		return
	
	var pos_key = _position_to_key(position)
	if highlighted_map.has(pos_key):
		_update_tile_highlight(position, highlight_type)
	else:
		_create_tile_highlight(position, highlight_type)

func _clear_tile_highlight(position: Vector3):
	var pos_key = _position_to_key(position)
	if highlighted_map.has(pos_key):
		var data = highlighted_map[pos_key]
		if data.node and is_instance_valid(data.node):
			data.node.queue_free()
		highlighted_map.erase(pos_key)

func _create_tile_highlight(position: Vector3, highlight_type: HighlightType):
	var node = Node3D.new()
	node.name = "Highlight_" + str(position.x) + "_" + str(position.z)
	
	# 修正位置以匹配瓦片渲染（新坐标系：地面底部Y=0）
	# 获取瓦块类型来确定正确的Y坐标和高亮尺寸
	var tile_type = TileTypes.TileType.STONE_FLOOR if tile_manager else 0
	var y_position = 0.5 # 默认墙体高度
	if tile_manager:
		tile_type = tile_manager.get_tile_type(position)
		# 检查是否是全填充类型（墙体）
		if tile_type in [TileTypes.TileType.UNEXCAVATED, TileTypes.TileType.STONE_WALL,
						 TileTypes.TileType.GOLD_MINE]:
			y_position = 0.5 # 墙体中心
		else:
			y_position = 0.025 # 地面/建筑mesh中心
	
	# 🔧 修复：position是格子左下角坐标，需要+0.5到格子中心对齐瓦块
	var corrected_position = Vector3(position.x + 0.5, y_position, position.z + 0.5)
	node.position = corrected_position
	
	match highlight_mode:
		HighlightMode.OVERLAY:
			_create_overlay_highlight(node, highlight_type, tile_type)
		HighlightMode.WIREFRAME:
			_create_wireframe_highlight(node, highlight_type, tile_type)
		HighlightMode.OUTLINE:
			_create_outline_highlight(node, highlight_type, tile_type)
	
	# 确保高亮容器存在后再添加节点
	if highlight_container:
		highlight_container.add_child(node)
		# 🔧 修复：存储原始格子左下角坐标（整数），而不是修正后的坐标
		# 这样 _refresh_all_highlights 重新创建时不会再次偏移
		highlighted_map[_position_to_key(position)] = {"node": node, "type": highlight_type, "position": position}
	else:
		LogManager.error("❌ [高亮渲染] 高亮容器不存在，无法添加高亮节点")
		node.queue_free()

func _update_tile_highlight(position: Vector3, highlight_type: HighlightType):
	# 检查是否真的需要更新
	var pos_key = _position_to_key(position)
	if highlighted_map.has(pos_key):
		var current_type = highlighted_map[pos_key].type
		if current_type == highlight_type:
			return # 类型相同，不需要更新
	
	_clear_tile_highlight(position)
	_create_tile_highlight(position, highlight_type)

func _create_overlay_highlight(parent: Node3D, highlight_type: HighlightType, tile_type: int = 0):
	var mi := MeshInstance3D.new()
	mi.name = "OverlayMesh"
	var mesh := BoxMesh.new()
	
	# 根据瓦块类型确定高亮高度（新坐标系）
	var highlight_height = tile_size.y # 默认
	if tile_manager:
		# 检查是否是全填充类型（墙体）
		if tile_type in [TileTypes.TileType.UNEXCAVATED, TileTypes.TileType.STONE_WALL,
						 TileTypes.TileType.GOLD_MINE]:
			highlight_height = 1.0 # 墙体高度
		else:
			highlight_height = 0.05 # 地面高度
	
	mesh.size = Vector3(tile_size.x * 1.01, highlight_height * 1.01, tile_size.z * 1.01)
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	var color := _get_highlight_color(highlight_type)
	
	# 设置材质属性确保高亮可见
	mat.albedo_color = color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.flags_unshaded = true
	mat.flags_transparent = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.emission = color * 0.5 # 增加发光强度
	mat.emission_energy = 1.0 # 增加发光能量
	mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS # 确保深度绘制
	
	mi.material_override = mat
	parent.add_child(mi)
	
	# LogManager.debug("创建高亮覆盖层: " + str(highlight_type) + " 颜色: " + str(color))

func _create_wireframe_highlight(parent: Node3D, highlight_type: HighlightType, tile_type: int = 0):
	var mi := MeshInstance3D.new()
	mi.name = "WireframeMesh"
	
	# 根据瓦块类型确定高亮高度
	var highlight_height = tile_size.y
	if tile_manager:
		if tile_type in [TileTypes.TileType.UNEXCAVATED, TileTypes.TileType.STONE_WALL,
						 TileTypes.TileType.GOLD_MINE]:
			highlight_height = 1.0
		else:
			highlight_height = 0.05
	
	mi.mesh = _create_wireframe_box_mesh(highlight_height)
	var mat := StandardMaterial3D.new()
	var color := _get_highlight_color(highlight_type)
	mat.albedo_color = color
	mat.flags_unshaded = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.emission = color
	mat.emission_energy = 1.0
	mi.material_override = mat
	parent.add_child(mi)

func _create_outline_highlight(parent: Node3D, highlight_type: HighlightType, tile_type: int = 0):
	# 根据瓦块类型确定高亮高度
	var highlight_height = tile_size.y
	if tile_manager:
		if tile_type in [TileTypes.TileType.UNEXCAVATED, TileTypes.TileType.STONE_WALL,
						 TileTypes.TileType.GOLD_MINE]:
			highlight_height = 1.0
		else:
			highlight_height = 0.05
	
	var faces = [
		_create_outline_face(Vector3(0, highlight_height / 2, 0), Vector3(tile_size.x, 0.01, tile_size.z)),
		_create_outline_face(Vector3(0, -highlight_height / 2, 0), Vector3(tile_size.x, 0.01, tile_size.z)),
		_create_outline_face(Vector3(0, 0, tile_size.z / 2), Vector3(tile_size.x, highlight_height, 0.01)),
		_create_outline_face(Vector3(0, 0, -tile_size.z / 2), Vector3(tile_size.x, highlight_height, 0.01)),
		_create_outline_face(Vector3(-tile_size.x / 2, 0, 0), Vector3(0.01, highlight_height, tile_size.z)),
		_create_outline_face(Vector3(tile_size.x / 2, 0, 0), Vector3(0.01, highlight_height, tile_size.z))
	]
	for i in range(faces.size()):
		var face_mi := MeshInstance3D.new()
		face_mi.name = "OutlineFace_" + str(i)
		face_mi.mesh = faces[i]
		var mat := StandardMaterial3D.new()
		var color := _get_highlight_color(highlight_type)
		mat.albedo_color = color
		mat.flags_unshaded = true
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.emission = color
		mat.emission_energy = 0.8
		face_mi.material_override = mat
		parent.add_child(face_mi)

func _create_wireframe_box_mesh(height: float = 0.0) -> ArrayMesh:
	var array_mesh := ArrayMesh.new()
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	# 使用传入的高度或默认tile_size.y
	var actual_height = height if height > 0 else tile_size.y
	var half_size := Vector3(tile_size.x * 0.5, actual_height * 0.5, tile_size.z * 0.5)
	var corners = [
		Vector3(-half_size.x, -half_size.y, -half_size.z),
		Vector3(half_size.x, -half_size.y, -half_size.z),
		Vector3(half_size.x, half_size.y, -half_size.z),
		Vector3(-half_size.x, half_size.y, -half_size.z),
		Vector3(-half_size.x, -half_size.y, half_size.z),
		Vector3(half_size.x, -half_size.y, half_size.z),
		Vector3(half_size.x, half_size.y, half_size.z),
		Vector3(-half_size.x, half_size.y, half_size.z)
	]
	for c in corners:
		vertices.append(c)
	var edges = [[0, 1], [1, 2], [2, 3], [3, 0], [4, 5], [5, 6], [6, 7], [7, 4], [0, 4], [1, 5], [2, 6], [3, 7]]
	for e in edges:
		indices.append_array(e)
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	return array_mesh

func _create_outline_face(center: Vector3, size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh

func _get_highlight_color(t: HighlightType) -> Color:
	var color: Color
	match t:
		HighlightType.GREEN:
			color = HIGHLIGHT_COLORS["GREEN"]
		HighlightType.YELLOW:
			color = HIGHLIGHT_COLORS["YELLOW"]
		HighlightType.CYAN:
			color = HIGHLIGHT_COLORS["CYAN"]
		HighlightType.RED:
			color = HIGHLIGHT_COLORS["RED"]
		HighlightType.PURPLE:
			color = HIGHLIGHT_COLORS["PURPLE"]
		HighlightType.ORANGE:
			color = HIGHLIGHT_COLORS["ORANGE"]
		HighlightType.BROWN:
			color = HIGHLIGHT_COLORS["BROWN"]
		_:
			color = Color.WHITE
	
	return color

func _position_to_key(position: Vector3) -> String:
	return str(int(position.x)) + "_" + str(int(position.z))

func _refresh_all_highlights():
	var old_map = highlighted_map.duplicate()
	_clear_previous_highlights()
	for pos_key in old_map.keys():
		var data = old_map[pos_key]
		_create_tile_highlight(data.position, data.type)


func update_highlight(position: Vector3, entity_id: String = "", entity_type: String = "", highlight_color: String = ""):
	"""更新高亮显示 - 优化版本，消除重复计算
	
	注意：传入的 position 已经在 main.gd 中对齐为格子左下角整数坐标
	"""
	# 🔧 统一使用传入的位置（已经对齐过）
	var actual_position = position
	
	# 检查是否真的需要更新高亮
	if current_position == actual_position and current_entity_id == entity_id and current_entity_type == entity_type:
		return # 位置和实体都没变，不需要更新
	
	current_position = actual_position
	current_entity_id = entity_id
	current_entity_type = entity_type
	
	# 高亮更新
	
	# 智能清除：只清除不在新位置的高亮，保留当前位置的高亮
	_clear_highlights_except_position(actual_position)
	
	# 挖掘模式：使用内部逻辑，忽略外部颜色参数
	if entity_type == "dig":
		var dig_state = _compute_dig_highlight_state(actual_position)
		_set_tile_highlight(actual_position, dig_state)
		current_state = dig_state
		return
	
	# 其他模式（建造/召唤）：使用外部传入的颜色参数
	if highlight_color == "":
		highlight_color = "green" # 默认颜色
	
	var highlight_state = _color_to_highlight_state(highlight_color)
	_set_tile_highlight(actual_position, highlight_state)
	current_state = highlight_state


func _color_to_highlight_state(highlight_color: String) -> HighlightState:
	"""将颜色字符串转换为高亮状态枚举"""
	match highlight_color:
		"green":
			return HighlightState.VALID
		"red":
			return HighlightState.INVALID_TERRAIN
		"yellow":
			return HighlightState.INVALID_RESOURCES
		"orange":
			return HighlightState.INVALID_OCCUPIED
		"purple":
			return HighlightState.INVALID_DISTANCE
		"cyan":
			return HighlightState.DIGGABLE
		_:
			return HighlightState.VALID


func hide_highlight():
	"""隐藏高亮"""
	_clear_previous_highlights()
	current_state = HighlightState.NONE


func _force_maintain_highlight():
	"""强制保持高亮状态，防止被其他系统覆盖"""
	# 设置一个标志，表示当前高亮应该被保持
	# 这可以防止其他系统意外清除高亮
	if current_state != HighlightState.NONE:
		# 确保高亮容器存在且可见
		if highlight_container and highlight_container.visible:
			# 高亮状态有效，不需要额外操作
			pass


func _is_position_in_bounds(position: Vector3) -> bool:
	"""检查位置是否在地图范围内 - 放宽限制版本"""
	if not tile_manager:
		return false
	
	var map_size = tile_manager.get_map_size()
	# 放宽限制：只检查X和Z坐标，Y坐标不限制
	return (position.x >= 0 and position.x < map_size.x and
			position.z >= 0 and position.z < map_size.z)


func _check_terrain_conditions(position: Vector3, entity_type: String) -> bool:
	"""检查地形条件（放宽限制）"""
	if not tile_manager:
		return false
	
	var tile_data = tile_manager.get_tile_data(position)
	if not tile_data:
		return false
	
	match entity_type:
		"dig":
			# 放宽挖掘限制：允许更多类型的地块尝试挖掘
			return (tile_data.is_diggable or
					tile_data.type == TileTypes.TileType.EMPTY)
		"build":
			# 放宽建造限制：允许更多类型的地块建造
			return (tile_data.type == TileTypes.TileType.STONE_WALL or
					tile_data.type == TileTypes.TileType.STONE_FLOOR or
					tile_data.type == TileTypes.TileType.EMPTY or
					tile_data.is_walkable)
		"summon_monster", "summon_logistics":
			# 放宽召唤限制：允许更多类型的地块召唤
			return (tile_data.is_walkable or
					tile_data.type == TileTypes.TileType.EMPTY or
					tile_data.type == TileTypes.TileType.STONE_FLOOR)
		_:
			return true


func _is_position_occupied(position: Vector3) -> bool:
	"""检查位置是否被占用"""
	# 检查是否有角色
	if character_manager and character_manager.has_method("get_character_at_position"):
		var character = character_manager.get_character_at_position(position, 0.5)
		if character:
			return true
	
	# 检查是否有建筑
	if building_manager:
		var building = building_manager.get_building_at_position(position)
		if building:
			return true
	
	return false


# 已移除 _set_highlight_state 函数，现在直接使用 _set_tile_highlight


# 已移除 get_highlight_color 函数，现在直接通过 TileManager 管理颜色


func _snap_to_tile_center(position: Vector3) -> Vector3:
	"""将位置对齐到格子左下角坐标（整数） - 用于高亮系统
	
	注意：返回格子左下角坐标 (x, 0, z)，不是瓦块中心
	      瓦块中心坐标由 _create_tile_highlight 函数添加 +0.5
	"""
	if not tile_manager:
		return position
	
	var tile_size = tile_manager.get_tile_size()
	var map_size = tile_manager.get_map_size()
	
	# 对齐到格子左下角（整数坐标）
	var snapped_x = floor(position.x / tile_size.x) * tile_size.x
	var snapped_z = floor(position.z / tile_size.z) * tile_size.z
	
	# 单层地图约束：Y坐标严格为0
	var snapped_y = 0.0
	
	# 边界检查：确保位置在地图范围内
	snapped_x = clamp(snapped_x, 0, map_size.x - 1)
	snapped_z = clamp(snapped_z, 0, map_size.z - 1)
	
	return Vector3(snapped_x, snapped_y, snapped_z)


func _compute_dig_highlight_state(position: Vector3) -> HighlightState:
	"""计算挖掘模式下的高亮状态 - 放宽限制版本"""
	# 放宽位置约束：允许Y坐标不为0的位置
	var check_position = Vector3(position.x, 0.0, position.z)
	
	# 放宽边界检查：只检查X和Z坐标
	if not tile_manager:
		LogManager.error("❌ [高亮分析] TileManager未初始化")
		return HighlightState.INVALID_TERRAIN
	
	var map_size = tile_manager.get_map_size()
	
	if check_position.x < 0 or check_position.x >= map_size.x or check_position.z < 0 or check_position.z >= map_size.z:
		return HighlightState.INVALID_TERRAIN
	
	var tile_data = tile_manager.get_tile_data(check_position)
	if not tile_data:
		return HighlightState.INVALID_TERRAIN
	
	# 特殊处理：EMPTY -> 黄色（已挖掘，不需要再挖掘）
	if tile_data.type == TileTypes.TileType.EMPTY:
		return HighlightState.INVALID_RESOURCES
	
	# 建筑类型 -> 黄色（资源问题）
	if tile_data.is_building:
		return HighlightState.INVALID_RESOURCES
	
	# 可挖掘 -> 青色
	if tile_data.is_diggable:
		return HighlightState.DIGGABLE
	
	# 不可挖掘 -> 红色
	return HighlightState.INVALID_TERRAIN
