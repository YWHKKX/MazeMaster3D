extends Control
class_name BaseUI

# UI基类 - 所有UI组件的基类
# 提供通用的UI功能和接口
# 导入UI工具类
const UIUtils = preload("res://scripts/ui/UIUtils.gd")

# UI状态
var is_visible: bool = false
var is_enabled: bool = true


# 初始化
func _ready():
	"""UI初始化"""
	_initialize_ui()
	_setup_ui_events()


func _initialize_ui():
	"""初始化UI组件"""


func _setup_ui_events():
	"""设置UI事件"""


# 显示/隐藏
func show_ui():
	"""显示UI"""
	visible = true
	is_visible = true
	_on_ui_shown()


func hide_ui():
	"""隐藏UI"""
	visible = false
	is_visible = false
	_on_ui_hidden()


func toggle_ui():
	"""切换UI显示状态"""
	if is_visible:
		hide_ui()
	else:
		show_ui()


# 启用/禁用
func enable_ui():
	"""启用UI"""
	modulate = Color.WHITE
	is_enabled = true
	_on_ui_enabled()


func disable_ui():
	"""禁用UI"""
	modulate = Color(0.5, 0.5, 0.5, 0.5)
	is_enabled = false
	_on_ui_disabled()


# 回调函数（子类可以重写）
func _on_ui_shown():
	"""UI显示时的回调"""


func _on_ui_hidden():
	"""UI隐藏时的回调"""


func _on_ui_enabled():
	"""UI启用时的回调"""


func _on_ui_disabled():
	"""UI禁用时的回调"""


# 更新UI
func update_ui():
	"""更新UI显示"""


# 淡入淡出效果
func fade_in():
	"""淡入效果"""
	visible = true
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)


func fade_out():
	"""淡出效果"""
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): visible = false)


# UI创建方法
func create_panel(size: Vector2, color: Color) -> Panel:
	"""创建面板"""
	var panel = Panel.new()
	panel.custom_minimum_size = size
	panel.modulate = color
	return panel


func create_hbox_container(spacing: int = 0) -> HBoxContainer:
	"""创建水平容器"""
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", spacing)
	return container


func create_vbox_container(spacing: int = 0) -> VBoxContainer:
	"""创建垂直容器"""
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", spacing)
	return container


func create_label(text: String, font_size: int = 16, color: Color = Color.WHITE) -> Label:
	"""创建标签"""
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = color
	return label


func create_button(text: String, callback: Callable = Callable()) -> Button:
	"""创建按钮"""
	var button = Button.new()
	button.text = text
	if callback.is_valid():
		button.pressed.connect(callback)
	return button
