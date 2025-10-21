extends Node
class_name UnitNameDisplayManager

## 🏷️ 单位名称显示管理器
## 统一管理所有单位的名称显示，提供批量操作和性能优化
## 参考生命值显示系统的架构设计

# 显示配置
var global_config = {
	"enabled": true, # 全局启用/禁用
	"show_names": true, # 显示单位名称
	"show_health": true, # 启用生命值显示
	"show_faction": false, # 显示阵营
	"update_interval": 0.5, # 更新间隔
	"max_displays": 100, # 最大显示数量
	"performance_mode": true, # 性能模式
	"auto_cleanup": true # 自动清理死亡单位
}

# 样式配置
var global_style = {
	"name_color": Color.WHITE,
	"health_color": Color.GREEN,
	"low_health_color": Color.RED,
	"faction_color": Color.YELLOW,
	"font_size": 16,
	"offset_y": 2.0, # 🔧 缩小头顶偏移
	"fade_distance": 50.0,
	"hide_distance": 100.0
}

# 单位显示映射
var unit_displays: Dictionary = {} # unit_id -> UnitDisplay

# 性能优化
var update_timer: float = 0.0
var update_batch_size: int = 10 # 每帧更新的数量
var current_batch_index: int = 0

# 相机引用
var camera: Camera3D = null

# 场景引用
var world_scene: Node3D = null

## ============================================================================
## 生命周期
## ============================================================================

func _ready():
	"""初始化管理器"""
	# 获取相机引用
	_find_camera()
	
	# 获取世界场景引用
	_find_world_scene()
	
	# 连接到游戏服务
	_setup_game_services_connection()

func _process(delta: float):
	"""每帧更新"""
	if not global_config.enabled:
		return
	
	# 更新定时器
	update_timer += delta
	if update_timer >= global_config.update_interval:
		update_timer = 0.0
		_update_batch()

## ============================================================================
## 公共接口
## ============================================================================

## 为指定单位创建名称显示
func create_display_for_unit(unit: CharacterBase, custom_config: Dictionary = {}) -> UnitDisplay:
	"""为指定单位创建名称显示"""
	if not unit or not is_instance_valid(unit):
		return null
	
	# 检查是否已存在
	var unit_id = unit.get_instance_id()
	if unit_id in unit_displays:
		return unit_displays[unit_id]
	
	# 合并配置
	var config = global_config.duplicate(true)
	config.merge(custom_config, true)
	
	# 创建显示组件
	var display = UnitDisplay.new()
	display.update_display_config(config)
	display.update_style_config(global_style)
	display.set_target_unit(unit)
	
	# 添加到场景
	if world_scene:
		world_scene.add_child(display)
	
	# 记录映射
	unit_displays[unit_id] = display
	
	return display

## 为所有单位创建名称显示
func create_displays_for_all_units(custom_config: Dictionary = {}) -> Array[UnitDisplay]:
	"""为所有单位创建名称显示"""
	var displays: Array[UnitDisplay] = []
	
	# 获取所有角色单位
	var characters = _get_all_character_units()
	
	for character in characters:
		var display = create_display_for_unit(character, custom_config)
		if display:
			displays.append(display)
	
	return displays

## 移除指定单位的名称显示
func remove_display_for_unit(unit: CharacterBase) -> void:
	"""移除指定单位的名称显示"""
	if not unit:
		return
	
	var unit_id = unit.get_instance_id()
	if unit_id in unit_displays:
		var display = unit_displays[unit_id]
		if display and is_instance_valid(display):
			display.queue_free()
		
		unit_displays.erase(unit_id)

## 移除所有名称显示
func remove_all_displays() -> void:
	"""移除所有名称显示"""
	for unit_id in unit_displays.keys():
		var display = unit_displays[unit_id]
		if display and is_instance_valid(display):
			display.queue_free()
	
	unit_displays.clear()

## 更新全局配置
func update_global_config(config: Dictionary) -> void:
	"""更新全局配置"""
	global_config.merge(config, true)
	
	# 应用到所有现有显示
	_apply_global_config_to_all()

## 更新全局样式
func update_global_style(style: Dictionary) -> void:
	"""更新全局样式"""
	global_style.merge(style, true)
	
	# 应用到所有现有显示
	_apply_global_style_to_all()

## 设置启用状态
func set_enabled(enabled: bool) -> void:
	"""设置全局启用状态"""
	global_config.enabled = enabled
	_update_all_visibility()

## 设置显示模式
func set_display_mode(names: bool, health: bool, faction: bool) -> void:
	"""设置显示模式"""
	global_config.show_names = names
	global_config.show_health = health
	global_config.show_faction = faction
	
	# 重新创建所有显示以应用新模式
	_recreate_all_displays()

## 获取统计信息
func get_statistics() -> Dictionary:
	"""获取统计信息"""
	var active_displays = 0
	var dead_units = 0
	
	for unit_id in unit_displays.keys():
		var display = unit_displays[unit_id]
		if display and is_instance_valid(display):
			active_displays += 1
		else:
			dead_units += 1
	
	return {
		"total_displays": unit_displays.size(),
		"active_displays": active_displays,
		"dead_units": dead_units,
		"enabled": global_config.enabled,
		"performance_mode": global_config.performance_mode
	}

## ============================================================================
## 内部实现
## ============================================================================

## 查找相机
func _find_camera() -> void:
	"""查找场景中的相机"""
	# 从场景树中查找相机
	var cameras = get_tree().get_nodes_in_group("camera")
	if cameras.size() > 0:
		camera = cameras[0]
		return
	
	# 如果没找到，尝试从主场景获取
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("get_camera"):
		camera = main_scene.get_camera()

## 查找世界场景
func _find_world_scene() -> void:
	"""查找世界场景节点"""
	var main_scene = get_tree().current_scene
	if main_scene:
		world_scene = main_scene.get_node_or_null("World")

## 设置游戏服务连接
func _setup_game_services_connection() -> void:
	"""设置与游戏服务的连接"""
	# 🔧 连接GameEvents信号（角色生成和死亡）
	if GameEvents.has_signal("character_spawned"):
		GameEvents.character_spawned.connect(_on_character_spawned)
	if GameEvents.has_signal("character_died"):
		GameEvents.character_died.connect(_on_character_died)

## 获取所有角色单位
func _get_all_character_units() -> Array[CharacterBase]:
	"""获取所有角色单位"""
	var characters: Array[CharacterBase] = []
	
	# 从角色管理器获取
	if GameServices.is_service_ready("character_manager"):
		var character_manager = GameServices.get_characters()
		if character_manager.has_method("get_all_characters"):
			var nodes = character_manager.get_all_characters()
			for n in nodes:
				if n is CharacterBase:
					characters.append(n)
	
	# 如果角色管理器不可用，从场景树查找
	if characters.is_empty():
		characters = _find_characters_in_scene()
	
	return characters

## 从场景中查找角色
func _find_characters_in_scene() -> Array[CharacterBase]:
	"""从场景中查找所有角色"""
	var characters: Array[CharacterBase] = []
	
	# 递归查找所有CharacterBase节点
	_find_characters_recursive(get_tree().current_scene, characters)
	
	return characters

## 递归查找角色
func _find_characters_recursive(node: Node, characters: Array[CharacterBase]) -> void:
	"""递归查找角色节点"""
	if node is CharacterBase:
		characters.append(node)
	
	for child in node.get_children():
		_find_characters_recursive(child, characters)

## 批量更新
func _update_batch() -> void:
	"""批量更新显示"""
	if not global_config.performance_mode:
		# 非性能模式：更新所有显示
		_update_all_displays()
		return
	
	# 性能模式：分批更新
	var display_keys = unit_displays.keys()
	if display_keys.is_empty():
		return
	
	# 计算当前批次范围
	var start_index = current_batch_index
	var end_index = min(start_index + update_batch_size, display_keys.size())
	
	# 更新当前批次
	for i in range(start_index, end_index):
		var unit_id = display_keys[i]
		var display = unit_displays.get(unit_id)
		if display and is_instance_valid(display):
			display._update_display()
	
	# 更新批次索引
	current_batch_index = end_index
	if current_batch_index >= display_keys.size():
		current_batch_index = 0

## 更新所有显示
func _update_all_displays() -> void:
	"""更新所有显示"""
	for unit_id in unit_displays.keys():
		var display = unit_displays[unit_id]
		if display and is_instance_valid(display):
			display._update_display()

## 应用全局配置到所有显示
func _apply_global_config_to_all() -> void:
	"""应用全局配置到所有显示"""
	for unit_id in unit_displays.keys():
		var display = unit_displays[unit_id]
		if display and is_instance_valid(display):
			display.update_display_config(global_config)

## 应用全局样式到所有显示
func _apply_global_style_to_all() -> void:
	"""应用全局样式到所有显示"""
	for unit_id in unit_displays.keys():
		var display = unit_displays[unit_id]
		if display and is_instance_valid(display):
			display.update_style_config(global_style)

## 更新所有可见性
func _update_all_visibility() -> void:
	"""更新所有显示的可见性"""
	for unit_id in unit_displays.keys():
		var display = unit_displays[unit_id]
		if display and is_instance_valid(display):
			display.set_visible(global_config.enabled)

## 重新创建所有显示
func _recreate_all_displays() -> void:
	"""重新创建所有显示"""
	# 保存现有单位引用
	var units: Array[CharacterBase] = []
	for unit_id in unit_displays.keys():
		var display = unit_displays[unit_id]
		if display and is_instance_valid(display) and display.target_unit:
			units.append(display.target_unit)
	
	# 清理现有显示
	remove_all_displays()
	
	# 重新创建显示
	for unit in units:
		create_display_for_unit(unit)

## 清理死亡单位
func _cleanup_dead_units() -> void:
	"""清理死亡单位的显示"""
	if not global_config.auto_cleanup:
		return
	
	var dead_units: Array = []
	
	for unit_id in unit_displays.keys():
		var display = unit_displays[unit_id]
		if not display or not is_instance_valid(display):
			dead_units.append(unit_id)
		elif display.target_unit and not is_instance_valid(display.target_unit):
			dead_units.append(unit_id)
	
	for unit_id in dead_units:
		unit_displays.erase(unit_id)

## ============================================================================
## 信号处理
## ============================================================================

## 角色生成处理
func _on_character_spawned(character: CharacterBase) -> void:
	"""处理角色生成信号"""
	if global_config.enabled:
		create_display_for_unit(character)

## 角色死亡处理
func _on_character_died(character: CharacterBase) -> void:
	"""处理角色死亡信号"""
	# 延迟移除显示，让玩家看到死亡效果
	await get_tree().create_timer(2.0).timeout
	remove_display_for_unit(character)

## ============================================================================
## 静态工具函数
## ============================================================================

## 获取全局管理器实例
static func get_instance() -> UnitNameDisplayManager:
	"""获取全局管理器实例"""
	# 尝试从GameServices获取
	if GameServices.has_unit_name_display_manager():
		return GameServices.get_unit_name_display_manager()
	
	# 如果不存在，创建新实例
	var manager = UnitNameDisplayManager.new()
	manager.name = "UnitNameDisplayManager"
	
	return manager

## 快速启用所有单位名称显示
static func enable_all_unit_names(config: Dictionary = {}) -> UnitNameDisplayManager:
	"""快速启用所有单位名称显示"""
	var manager = get_instance()
	manager.set_enabled(true)
	manager.create_displays_for_all_units(config)
	return manager

## 快速禁用所有单位名称显示
static func disable_all_unit_names() -> void:
	"""快速禁用所有单位名称显示"""
	var manager = get_instance()
	manager.set_enabled(false)
