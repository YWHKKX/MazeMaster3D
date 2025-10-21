extends Control
class_name ResourceCollectionUI

## 🎯 资源采集UI
## 处理资源采集交互和反馈

# 导入UI工具类
const UIDesignConstants = preload("res://scripts/ui/UIDesignConstants.gd")
const ResourceManager = preload("res://scripts/managers/resource/ResourceManager.gd")

# UI配置
var ui_config = {
	"collection_radius": 50.0, # 采集半径
	"auto_collect": true, # 自动采集
	"collection_speed": 1.0, # 采集速度（秒）
	"feedback_duration": 2.0 # 反馈显示时长
}

# UI引用
var collection_panel: Control = null
var collection_status: Label = null
var collection_progress: ProgressBar = null

# 节点引用
var resource_manager = null
var resource_collection_manager = null
var player_node: Node3D = null
var collection_timer: Timer = null

# 采集状态
var is_collecting: bool = false
var current_collection_target = null
var collection_progress_value: float = 0.0

func _ready():
	"""初始化资源采集UI"""
	LogManager.info("ResourceCollectionUI - 初始化开始")
	
	_setup_collection_ui()
	
	# 等待一帧，确保GameServices和ResourceManager都已初始化
	await get_tree().process_frame
	
	# 从GameServices获取ResourceManager
	resource_manager = GameServices.resource_manager
	if resource_manager:
		_connect_signals()
	else:
		LogManager.error("无法从GameServices获取ResourceManager！")
	
	# 从GameServices获取ResourceCollectionManager
	if GameServices.has_method("get_resource_collection_manager"):
		resource_collection_manager = GameServices.get_resource_collection_manager()
		if resource_collection_manager:
			_connect_collection_manager_signals()
	
	# 设置采集定时器
	_setup_collection_timer()
	
	LogManager.info("ResourceCollectionUI - 初始化完成")

func _setup_collection_ui():
	"""设置资源采集UI"""
	# 创建主面板
	_create_main_panel()
	
	# 初始时隐藏
	visible = false

func _create_main_panel():
	"""创建主面板"""
	collection_panel = UIUtils.create_panel(
		Vector2(250, 100),
		UIDesignConstants.Colors.PANEL
	)
	collection_panel.position = Vector2(20, 300) # 左上角，在资源可视化面板下方
	collection_panel.name = "ResourceCollectionPanel"
	
	# 设置透明度
	collection_panel.modulate.a = 0.9
	
	# 将面板添加到场景树
	add_child(collection_panel)
	
	# 创建UI元素
	_create_collection_elements()

func _create_collection_elements():
	"""创建采集UI元素"""
	# 标题
	var title = UIUtils.create_label(
		"🎯 资源采集", UIDesignConstants.FontSizes.H3, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	title.position = Vector2(UIDesignConstants.Spacing.SM, UIDesignConstants.Spacing.SM)
	collection_panel.add_child(title)
	
	# 采集状态
	collection_status = UIUtils.create_label(
		"等待采集...", UIDesignConstants.FontSizes.NORMAL, UIDesignConstants.Colors.TEXT_SECONDARY
	)
	collection_status.position = Vector2(UIDesignConstants.Spacing.SM, 35)
	collection_panel.add_child(collection_status)
	
	# 采集进度条
	collection_progress = ProgressBar.new()
	collection_progress.position = Vector2(UIDesignConstants.Spacing.SM, 60)
	collection_progress.custom_minimum_size = Vector2(200, 20)
	collection_progress.value = 0
	collection_progress.max_value = 100
	collection_progress.visible = false
	collection_panel.add_child(collection_progress)

func _setup_collection_timer():
	"""设置采集定时器"""
	collection_timer = Timer.new()
	collection_timer.wait_time = ui_config.collection_speed
	collection_timer.one_shot = true
	collection_timer.timeout.connect(_on_collection_complete)
	add_child(collection_timer)

func _connect_signals():
	"""连接信号"""
	if resource_manager:
		resource_manager.resource_spawned.connect(_on_resource_spawned)
		resource_manager.resource_depleted.connect(_on_resource_depleted)
		resource_manager.resource_respawned.connect(_on_resource_respawned)

func _connect_collection_manager_signals():
	"""连接资源采集管理器信号"""
	if resource_collection_manager:
		resource_collection_manager.task_created.connect(_on_task_created)
		resource_collection_manager.task_assigned.connect(_on_task_assigned)
		resource_collection_manager.task_completed.connect(_on_task_completed)
		resource_collection_manager.collection_started.connect(_on_collection_started)
		resource_collection_manager.collection_finished.connect(_on_collection_finished)

# 信号处理函数
func _on_resource_spawned(resource_type: ResourceManager.ResourceType, position: Vector2, amount: int):
	"""资源生成回调"""
	_show_collection_notification("发现资源: " + resource_manager.get_resource_name(resource_type))

func _on_resource_depleted(resource_type: ResourceManager.ResourceType, position: Vector2):
	"""资源耗尽回调"""
	_show_collection_notification("资源已采集完毕")

func _on_resource_respawned(resource_type: ResourceManager.ResourceType, position: Vector2, amount: int):
	"""资源重生回调"""
	_show_collection_notification("资源已重生: " + resource_manager.get_resource_name(resource_type))

# 采集逻辑
func start_collection(target_position: Vector2):
	"""开始采集资源"""
	if is_collecting:
		return
	
	# 检查目标位置是否有资源
	var resources = resource_manager.get_resources_at_position(target_position) if resource_manager else []
	if resources.is_empty():
		_show_collection_notification("该位置没有可采集的资源")
		return
	
	var resource = resources[0] # 采集第一个资源
	current_collection_target = resource
	
	# 开始采集
	is_collecting = true
	collection_progress_value = 0.0
	collection_progress.visible = true
	collection_progress.value = 0
	
	# 更新状态
	collection_status.text = "正在采集: " + resource_manager.get_resource_name(resource.resource_type)
	
	# 开始进度动画
	_start_collection_progress()
	
	# 启动采集定时器
	collection_timer.start()

func _start_collection_progress():
	"""开始采集进度动画"""
	var tween = create_tween()
	tween.tween_method(_update_collection_progress, 0.0, 100.0, ui_config.collection_speed)

func _update_collection_progress(value: float):
	"""更新采集进度"""
	collection_progress_value = value
	collection_progress.value = value

func _on_collection_complete():
	"""采集完成"""
	if not current_collection_target:
		return
	
	var collection_result = resource_manager.collect_resource(current_collection_target.position)
	
	if collection_result.success:
		var resource_name = resource_manager.get_resource_name(collection_result.resource_type)
		var amount = collection_result.amount
		
		_show_collection_notification("采集成功: " + resource_name + " x" + str(amount))
		_show_collection_effect(collection_result.position, "+" + str(amount), UIDesignConstants.Colors.SUCCESS)
	else:
		_show_collection_notification("采集失败: " + collection_result.message)
	
	# 重置状态
	_reset_collection_state()

func _reset_collection_state():
	"""重置采集状态"""
	is_collecting = false
	current_collection_target = null
	collection_progress_value = 0.0
	collection_progress.visible = false
	collection_progress.value = 0
	collection_status.text = "等待采集..."

# 交互处理
func handle_click(position: Vector2):
	"""处理点击事件"""
	if ui_config.auto_collect:
		start_collection(position)
	else:
		_show_collection_notification("点击位置: " + str(position))

func handle_hover(position: Vector2):
	"""处理悬停事件"""
	var resources = resource_manager.get_resources_at_position(position) if resource_manager else []
	if not resources.is_empty():
		var resource = resources[0]
		var resource_name = resource_manager.get_resource_name(resource.resource_type)
		collection_status.text = "可采集: " + resource_name + " (" + str(resource.amount) + ")"
	else:
		collection_status.text = "等待采集..."

# 反馈系统
func _show_collection_notification(message: String):
	"""显示采集通知"""
	collection_status.text = message
	
	# 创建通知动画
	var tween = create_tween()
	tween.tween_property(collection_status, "modulate:a", 1.0, 0.2)
	tween.tween_delay(ui_config.feedback_duration)
	tween.tween_property(collection_status, "modulate:a", 0.5, 0.5)

func _show_collection_effect(position: Vector2, text: String, color: Color):
	"""显示采集效果"""
	# 创建3D文本效果
	var label_3d = Label3D.new()
	label_3d.text = text
	label_3d.modulate = color
	label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_3d.position = Vector3(position.x, 1.0, position.y)
	label_3d.scale = Vector3(0.3, 0.3, 0.3)
	
	# 添加到场景
	get_tree().current_scene.add_child(label_3d)
	
	# 创建动画
	var tween = create_tween()
	tween.tween_property(label_3d, "position", label_3d.position + Vector3(0, 2.0, 0), 1.0)
	tween.parallel().tween_property(label_3d, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label_3d.queue_free)

# 配置管理
func set_collection_radius(radius: float):
	"""设置采集半径"""
	ui_config.collection_radius = radius

func set_auto_collect(enabled: bool):
	"""设置自动采集"""
	ui_config.auto_collect = enabled

func set_collection_speed(speed: float):
	"""设置采集速度"""
	ui_config.collection_speed = speed
	if collection_timer:
		collection_timer.wait_time = speed

# 公共接口
func show_ui():
	"""显示UI"""
	visible = true

func hide_ui():
	"""隐藏UI"""
	visible = false

func toggle_ui():
	"""切换UI显示"""
	if visible:
		hide_ui()
	else:
		show_ui()

func get_collection_status() -> String:
	"""获取采集状态"""
	if is_collecting:
		return "正在采集"
	else:
		return "空闲"

func get_collection_progress() -> float:
	"""获取采集进度"""
	return collection_progress_value

func is_currently_collecting() -> bool:
	"""是否正在采集"""
	return is_collecting

# ===== 资源采集管理器信号处理 =====

func _on_task_created(task):
	"""任务创建回调"""
	_show_collection_notification("创建采集任务: " + _get_resource_name_from_type(task.resource_type))

func _on_task_assigned(task, collector):
	"""任务分配回调"""
	_show_collection_notification("分配采集任务: %s -> %s" % [_get_resource_name_from_type(task.resource_type), collector.name])

func _on_task_completed(task, collected_amount: int):
	"""任务完成回调"""
	_show_collection_notification("采集完成: %s x%d" % [_get_resource_name_from_type(task.resource_type), collected_amount])

func _on_collection_started(resource_type: ResourceManager.ResourceType, position: Vector2, collector: Object):
	"""采集开始回调"""
	_show_collection_notification("开始采集: %s" % _get_resource_name_from_type(resource_type))

func _on_collection_finished(resource_type: ResourceManager.ResourceType, position: Vector2, collected_amount: int):
	"""采集完成回调"""
	_show_collection_notification("采集完成: %s x%d" % [_get_resource_name_from_type(resource_type), collected_amount])

# ===== 辅助函数 =====

func _get_resource_name_from_type(resource_type: ResourceManager.ResourceType) -> String:
	"""根据资源类型获取资源名称"""
	if resource_manager:
		return resource_manager.get_resource_name(resource_type)
	else:
		return str(resource_type)

# ===== 统一采集接口 =====

func create_collection_task(resource_type: ResourceManager.ResourceType, position: Vector2):
	"""创建采集任务"""
	if resource_collection_manager:
		var task = resource_collection_manager.create_manual_collection_task(resource_type, position)
		_show_collection_notification("手动创建采集任务: " + _get_resource_name_from_type(resource_type))
		return task
	else:
		LogManager.warning("ResourceCollectionUI - ResourceCollectionManager不可用")
		return null

func get_collection_statistics() -> Dictionary:
	"""获取采集统计信息"""
	if resource_collection_manager:
		return resource_collection_manager.get_task_statistics()
	else:
		return {}

func toggle_auto_collection(enabled: bool):
	"""切换自动采集"""
	if resource_collection_manager:
		resource_collection_manager.toggle_auto_collection(enabled)
		_show_collection_notification("自动采集: %s" % ("开启" if enabled else "关闭"))
