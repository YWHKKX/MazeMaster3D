extends Node3D
class_name UnitNameDisplay

## 🏷️ 单位名称显示系统
## 参考生命值显示系统架构，为每个单位生成3D名称标签
## 支持动态更新、LOD优化和样式配置

# 显示配置
var display_config = {
	"show_names": true, # 是否显示名称
	"show_health": true, # 是否显示生命值
	"show_faction": false, # 是否显示阵营
	"font_size": 16, # 字体大小
	"offset_y": 2.5, # 头顶偏移
	"fade_distance": 50.0, # 淡出距离
	"hide_distance": 100.0, # 隐藏距离
	"update_interval": 0.5 # 更新间隔（秒）
}

# 3D标签组件
var name_label: Label3D = null
var health_label: Label3D = null
var faction_label: Label3D = null

# 目标单位引用
var target_unit: CharacterBase = null

# 相机引用（用于距离计算）
var camera: Camera3D = null

# 更新定时器
var update_timer: float = 0.0

# 样式配置
var style_config = {
	"name_color": Color.WHITE,
	"health_color": Color.GREEN,
	"low_health_color": Color.RED,
	"faction_color": Color.YELLOW,
	"background_color": Color(0, 0, 0, 0.5),
	"outline_color": Color.BLACK,
	"outline_width": 1
}

## ============================================================================
## 生命周期
## ============================================================================

func _init():
	"""初始化单位名称显示"""
	# 设置为3D节点
	set_as_top_level(true)

func _ready():
	"""准备就绪"""
	# 获取相机引用
	_find_camera()
	
	# 创建3D标签
	_create_3d_labels()

func _process(delta: float):
	"""每帧更新"""
	if not target_unit or not is_instance_valid(target_unit):
		return
	
	# 更新定时器
	update_timer += delta
	if update_timer >= display_config.update_interval:
		update_timer = 0.0
		_update_display()

## ============================================================================
## 公共接口
## ============================================================================

## 设置目标单位
func set_target_unit(unit: CharacterBase) -> void:
	"""设置要显示名称的目标单位"""
	target_unit = unit
	if target_unit:
		# 连接到单位信号
		_connect_unit_signals()
		
		# 初始更新
		_update_display()

## 更新显示配置
func update_display_config(config: Dictionary) -> void:
	"""更新显示配置"""
	display_config.merge(config, true)
	
	# 重新创建标签以应用新配置
	_recreate_labels()

## 更新样式配置
func update_style_config(style: Dictionary) -> void:
	"""更新样式配置"""
	style_config.merge(style, true)
	_apply_styles()

## 设置显示状态
func set_name_visible(name_visible: bool) -> void:
	"""设置名称显示可见性"""
	display_config.show_names = name_visible
	_update_visibility()

## 设置生命值显示状态
func set_health_visible(health_visible: bool) -> void:
	"""设置生命值显示可见性"""
	display_config.show_health = health_visible
	_update_visibility()

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

## 创建3D标签
func _create_3d_labels() -> void:
	"""创建3D标签组件"""
	# 清理现有标签
	_clear_labels()
	
	# 创建名称标签
	if display_config.show_names:
		name_label = Label3D.new()
		name_label.name = "NameLabel"
		name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		name_label.no_depth_test = true
		name_label.pixel_size = 0.008 # 🔧 调整字体大小与生命值显示匹配
		add_child(name_label)
	
	# 创建生命值标签
	if display_config.show_health:
		health_label = Label3D.new()
		health_label.name = "HealthLabel"
		health_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		health_label.no_depth_test = true
		health_label.pixel_size = 0.006 # 生命值标签稍小一些
		add_child(health_label)
	
	# 创建阵营标签
	if display_config.show_faction:
		faction_label = Label3D.new()
		faction_label.name = "FactionLabel"
		faction_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		faction_label.no_depth_test = true
		faction_label.pixel_size = 0.006
		add_child(faction_label)
	
	# 应用样式
	_apply_styles()

## 清理标签
func _clear_labels() -> void:
	"""清理现有标签"""
	if name_label and is_instance_valid(name_label):
		name_label.queue_free()
		name_label = null
	
	if health_label and is_instance_valid(health_label):
		health_label.queue_free()
		health_label = null
	
	if faction_label and is_instance_valid(faction_label):
		faction_label.queue_free()
		faction_label = null

## 重新创建标签
func _recreate_labels() -> void:
	"""重新创建标签以应用新配置"""
	_create_3d_labels()

## 连接单位信号
func _connect_unit_signals() -> void:
	"""连接目标单位的信号"""
	if not target_unit:
		return
	
	# 连接生命值变化信号
	if target_unit.has_signal("health_changed"):
		if not target_unit.health_changed.is_connected(_on_health_changed):
			target_unit.health_changed.connect(_on_health_changed)
	
	# 连接死亡信号
	if target_unit.has_signal("died"):
		if not target_unit.died.is_connected(_on_unit_died):
			target_unit.died.connect(_on_unit_died)

## 更新显示
func _update_display() -> void:
	"""更新显示内容"""
	if not target_unit or not is_instance_valid(target_unit):
		return
	
	# 计算距离并应用LOD
	var distance = _calculate_distance_to_camera()
	var lod_level = _calculate_lod_level(distance)
	
	# 根据距离调整可见性
	_update_visibility_by_distance(distance)
	
	# 更新位置
	_update_position()
	
	# 更新内容
	_update_content(lod_level)

## 计算到相机的距离
func _calculate_distance_to_camera() -> float:
	"""计算到相机的距离"""
	if not camera or not target_unit:
		return 0.0
	
	return global_position.distance_to(camera.global_position)

## 计算LOD级别
func _calculate_lod_level(distance: float) -> int:
	"""计算LOD级别"""
	if distance < 20.0:
		return 2 # 高细节
	elif distance < 50.0:
		return 1 # 中等细节
	else:
		return 0 # 低细节

## 根据距离更新可见性
func _update_visibility_by_distance(distance: float) -> void:
	"""根据距离更新可见性"""
	if distance > display_config.hide_distance:
		visible = false
		return
	
	visible = true
	
	# 应用距离淡出效果
	var alpha = 1.0
	if distance > display_config.fade_distance:
		alpha = 1.0 - (distance - display_config.fade_distance) / (display_config.hide_distance - display_config.fade_distance)
	
	_apply_alpha(alpha)

## 应用透明度
func _apply_alpha(alpha: float) -> void:
	"""应用透明度到所有标签"""
	var color = Color(1, 1, 1, alpha)
	
	if name_label:
		name_label.modulate = color
	
	if health_label:
		health_label.modulate = color
	
	if faction_label:
		faction_label.modulate = color

## 更新位置
func _update_position() -> void:
	"""更新显示位置"""
	if not target_unit:
		return
	
	# 设置到单位头顶
	global_position = target_unit.global_position + Vector3(0, display_config.offset_y, 0)
	
	# 调整标签位置（垂直堆叠）
	var offset = 0.0
	if name_label:
		name_label.position = Vector3(0, offset, 0)
		offset += 0.3
	
	if health_label:
		health_label.position = Vector3(0, offset, 0)
		offset += 0.25
	
	if faction_label:
		faction_label.position = Vector3(0, offset, 0)

## 更新内容
func _update_content(lod_level: int) -> void:
	"""更新显示内容"""
	if not target_unit:
		return
	
	# 更新名称标签
	if name_label and lod_level >= 1:
		var unit_name = target_unit.get_character_name()
		name_label.text = unit_name
	else:
		if name_label:
			name_label.text = ""
	
	# 更新生命值标签
	if health_label and display_config.show_health and lod_level >= 1:
		var health_percent = target_unit.get_health_percent()
		var health_text = "%d/%d" % [int(target_unit.current_health), int(target_unit.max_health)]
		health_label.text = health_text
		
		# 根据生命值百分比设置颜色
		if health_percent > 0.6:
			health_label.modulate = style_config.health_color
		elif health_percent > 0.3:
			health_label.modulate = Color.YELLOW
		else:
			health_label.modulate = style_config.low_health_color
	else:
		if health_label:
			health_label.text = ""
	
	# 更新阵营标签
	if faction_label and display_config.show_faction and lod_level >= 2:
		var faction_name = FactionManager.get_faction_name(target_unit.faction)
		faction_label.text = faction_name
	else:
		if faction_label:
			faction_label.text = ""

## 应用样式
func _apply_styles() -> void:
	"""应用样式到所有标签"""
	if name_label:
		name_label.modulate = style_config.name_color
	
	if health_label:
		health_label.modulate = style_config.health_color
	
	if faction_label:
		faction_label.modulate = style_config.faction_color

## 更新可见性
func _update_visibility() -> void:
	"""更新整体可见性"""
	visible = display_config.show_names or display_config.show_health or display_config.show_faction

## ============================================================================
## 信号处理
## ============================================================================

## 生命值变化处理
func _on_health_changed(_old_health: float, _new_health: float) -> void:
	"""处理生命值变化信号"""
	# 立即更新生命值显示
	if health_label and display_config.show_health:
		var health_percent = target_unit.get_health_percent()
		var health_text = "%d/%d" % [int(target_unit.current_health), int(target_unit.max_health)]
		health_label.text = health_text
		
		# 根据生命值百分比设置颜色
		if health_percent > 0.6:
			health_label.modulate = style_config.health_color
		elif health_percent > 0.3:
			health_label.modulate = Color.YELLOW
		else:
			health_label.modulate = style_config.low_health_color

## 单位死亡处理
func _on_unit_died() -> void:
	"""处理单位死亡信号"""
	# 隐藏显示
	visible = false
	
	# 延迟清理
	await get_tree().create_timer(2.0).timeout
	queue_free()

## ============================================================================
## 静态工具函数
## ============================================================================

## 为指定单位创建名称显示
static func create_for_unit(unit: CharacterBase, config: Dictionary = {}) -> UnitNameDisplay:
	"""为指定单位创建名称显示"""
	var display = UnitNameDisplay.new()
	display.update_display_config(config)
	display.set_target_unit(unit)
	
	# 添加到场景
	if unit.get_parent():
		unit.get_parent().add_child(display)
	
	return display

## 批量创建单位名称显示
static func create_for_units(units: Array[CharacterBase], config: Dictionary = {}) -> Array[UnitNameDisplay]:
	"""批量创建单位名称显示"""
	var displays: Array[UnitNameDisplay] = []
	
	for unit in units:
		var display = create_for_unit(unit, config)
		displays.append(display)
	
	return displays
