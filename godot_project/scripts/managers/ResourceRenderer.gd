extends Node
class_name ResourceRenderer

## 🎨 资源渲染管理器
## 负责在地图上渲染和显示所有资源

# 资源标记场景
const ResourceMarkerScene = preload("res://img/scenes/ui/resource_marker.tscn")

# 渲染配置
var render_config = {
	"enabled": true,
	"show_all_resources": true,
	"show_depleted_resources": false,
	"marker_scale": Vector3(1.0, 1.0, 1.0),
	"marker_height": 0.5,
	"update_interval": 1.0, # 更新间隔（秒）
	"max_markers": 1000 # 最大标记数量
}

# 渲染状态
var resource_markers: Dictionary = {} # {resource_id: marker_node}
var world_node: Node3D = null
var resource_manager = null
var update_timer: Timer = null

# 资源类型到标记类型的映射
var resource_type_mapping = {
	ResourceManager.ResourceType.GOLD: 0, # RESOURCE_TYPE_GOLD
	ResourceManager.ResourceType.FOOD: 1, # RESOURCE_TYPE_FOOD
	ResourceManager.ResourceType.STONE: 2, # RESOURCE_TYPE_STONE
	ResourceManager.ResourceType.WOOD: 3, # RESOURCE_TYPE_WOOD
	ResourceManager.ResourceType.IRON: 4, # RESOURCE_TYPE_IRON
	ResourceManager.ResourceType.GEM: 5, # RESOURCE_TYPE_GEM
	ResourceManager.ResourceType.MAGIC_HERB: 6, # RESOURCE_TYPE_MAGIC_HERB
	ResourceManager.ResourceType.MANA: 9 # RESOURCE_TYPE_MANA
}

func _ready():
	"""初始化资源渲染器"""
	_setup_timer()
	LogManager.info("ResourceRenderer - 初始化完成")

func _setup_timer():
	"""设置更新定时器"""
	update_timer = Timer.new()
	update_timer.wait_time = render_config.update_interval
	update_timer.timeout.connect(_update_resource_markers)
	update_timer.autostart = true
	add_child(update_timer)

func set_world_node(world: Node3D):
	"""设置世界节点引用"""
	world_node = world
	LogManager.info("ResourceRenderer - 世界节点已设置")

func set_resource_manager(manager):
	"""设置资源管理器引用"""
	resource_manager = manager
	LogManager.info("ResourceRenderer - 资源管理器已设置")

func _update_resource_markers():
	"""更新资源标记"""
	if not render_config.enabled or not world_node or not resource_manager:
		return
	
	# 获取所有资源生成点
	var resource_spawns = resource_manager.get_all_resource_spawns()
	
	# 清理已不存在的标记
	_cleanup_old_markers(resource_spawns)
	
	# 创建新标记
	_create_new_markers(resource_spawns)

func _cleanup_old_markers(resource_spawns: Array):
	"""清理已不存在的资源标记"""
	var active_positions = []
	
	# 收集所有活跃资源的位置
	for spawn in resource_spawns:
		if not spawn.get("is_depleted", false):
			var pos_key = _get_position_key(spawn.position)
			active_positions.append(pos_key)
	
	# 移除不再存在的标记
	var markers_to_remove = []
	for marker_id in resource_markers.keys():
		if marker_id not in active_positions:
			markers_to_remove.append(marker_id)
	
	for marker_id in markers_to_remove:
		var marker = resource_markers[marker_id]
		if marker and is_instance_valid(marker):
			marker.queue_free()
		resource_markers.erase(marker_id)

func _create_new_markers(resource_spawns: Array):
	"""创建新的资源标记"""
	for spawn in resource_spawns:
		if spawn.get("is_depleted", false) and not render_config.show_depleted_resources:
			continue
		
		var pos_key = _get_position_key(spawn.position)
		
		# 如果标记已存在，跳过
		if pos_key in resource_markers:
			continue
		
		# 检查标记数量限制
		if resource_markers.size() >= render_config.max_markers:
			break
		
		# 创建新标记
		_create_resource_marker(spawn)

func _create_resource_marker(spawn):
	"""创建资源标记"""
	if not ResourceMarkerScene:
		LogManager.error("ResourceRenderer - ResourceMarker场景未找到")
		return
	
	var marker = ResourceMarkerScene.instantiate()
	if not marker:
		LogManager.error("ResourceRenderer - 无法实例化ResourceMarker")
		return
	
	# 设置标记属性
	var resource_type = spawn.resource_type
	var marker_type = resource_type_mapping.get(resource_type, 0)
	
	marker.resource_type = marker_type
	marker.resource_amount = spawn.get("amount", 0)
	marker.resource_position = Vector2(spawn.position.x, spawn.position.z)
	marker.is_collectible = not spawn.get("is_depleted", false)
	
	# 设置位置
	var world_pos = Vector3(spawn.position.x, render_config.marker_height, spawn.position.z)
	marker.position = world_pos
	marker.scale = render_config.marker_scale
	
	# 添加到世界
	world_node.add_child(marker)
	
	# 记录标记
	var pos_key = _get_position_key(spawn.position)
	resource_markers[pos_key] = marker
	
	LogManager.debug("ResourceRenderer - 创建资源标记: %s 在位置 %s" % [resource_type, str(spawn.position)])

func _get_position_key(position) -> String:
	"""获取位置键值"""
	if position is Vector3:
		return "%d_%d" % [int(position.x), int(position.z)]
	elif position is Vector2:
		return "%d_%d" % [int(position.x), int(position.y)]
	else:
		return str(position)

func toggle_rendering():
	"""切换渲染状态"""
	render_config.enabled = !render_config.enabled
	
	if render_config.enabled:
		_update_resource_markers()
	else:
		_clear_all_markers()
	
	LogManager.info("ResourceRenderer - 渲染状态: %s" % ("开启" if render_config.enabled else "关闭"))

func _clear_all_markers():
	"""清除所有标记"""
	for marker in resource_markers.values():
		if marker and is_instance_valid(marker):
			marker.queue_free()
	resource_markers.clear()

func set_render_config(new_config: Dictionary):
	"""设置渲染配置"""
	render_config.merge(new_config, true)
	
	# 更新定时器间隔
	if update_timer:
		update_timer.wait_time = render_config.update_interval
	
	LogManager.info("ResourceRenderer - 渲染配置已更新")

func get_render_status() -> Dictionary:
	"""获取渲染状态"""
	return {
		"enabled": render_config.enabled,
		"marker_count": resource_markers.size(),
		"max_markers": render_config.max_markers,
		"update_interval": render_config.update_interval
	}
