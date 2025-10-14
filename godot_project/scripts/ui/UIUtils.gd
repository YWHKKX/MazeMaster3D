extends Node
class_name UIUtils

# UI工具类 - 提供统一的UI创建函数
# 避免重复代码，统一UI风格


# 创建面板
static func create_panel(size: Vector2, color: Color = Color(0.2, 0.2, 0.3, 0.9)) -> Panel:
	"""创建面板"""
	var panel = Panel.new()
	panel.custom_minimum_size = size
	panel.size = size

	# 设置样式
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.4, 0.4, 0.5, 1.0)

	panel.add_theme_stylebox_override("panel", style)
	return panel


# 创建标签
static func create_label(text: String, font_size: int = 14, color: Color = Color.WHITE) -> Label:
	"""创建标签"""
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


# 创建按钮
static func create_button(
	text: String, size: Vector2 = Vector2(100, 30), callback: Callable = Callable()
) -> Button:
	"""创建按钮"""
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = size
	button.size = size

	# 设置按钮样式
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.3, 0.3, 0.4, 0.9)
	style_normal.corner_radius_top_left = 6
	style_normal.corner_radius_top_right = 6
	style_normal.corner_radius_bottom_left = 6
	style_normal.corner_radius_bottom_right = 6

	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.4, 0.4, 0.5, 0.9)
	style_hover.corner_radius_top_left = 6
	style_hover.corner_radius_top_right = 6
	style_hover.corner_radius_bottom_left = 6
	style_hover.corner_radius_bottom_right = 6

	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = Color(0.2, 0.2, 0.3, 0.9)
	style_pressed.corner_radius_top_left = 6
	style_pressed.corner_radius_top_right = 6
	style_pressed.corner_radius_bottom_left = 6
	style_pressed.corner_radius_bottom_right = 6

	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)

	if callback.is_valid():
		button.pressed.connect(callback)

	return button


# 创建水平容器
static func create_hbox_container(spacing: int = 0) -> HBoxContainer:
	"""创建水平容器"""
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", spacing)
	return container


# 创建垂直容器
static func create_vbox_container(spacing: int = 0) -> VBoxContainer:
	"""创建垂直容器"""
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", spacing)
	return container


# 创建网格容器
static func create_grid_container(columns: int = 2, spacing: int = 10) -> GridContainer:
	"""创建网格容器"""
	var container = GridContainer.new()
	container.columns = columns
	container.add_theme_constant_override("h_separation", spacing)
	container.add_theme_constant_override("v_separation", spacing)
	return container


# 创建滚动容器
static func create_scroll_container() -> ScrollContainer:
	"""创建滚动容器"""
	var container = ScrollContainer.new()
	container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	return container


# 创建分隔线
static func create_separator(vertical: bool = false) -> Separator:
	"""创建分隔线"""
	var separator = VSeparator.new() if vertical else HSeparator.new()
	return separator


# 创建进度条
static func create_progress_bar(
	min_value: float = 0.0, max_value: float = 100.0, value: float = 0.0
) -> ProgressBar:
	"""创建进度条"""
	var progress = ProgressBar.new()
	progress.min_value = min_value
	progress.max_value = max_value
	progress.value = value
	progress.custom_minimum_size = Vector2(100, 20)
	return progress


# 创建输入框
static func create_line_edit(placeholder: String = "", text: String = "") -> LineEdit:
	"""创建输入框"""
	var line_edit = LineEdit.new()
	line_edit.placeholder_text = placeholder
	line_edit.text = text
	line_edit.custom_minimum_size = Vector2(150, 30)
	return line_edit


# 创建复选框
static func create_check_box(text: String = "", pressed: bool = false) -> CheckBox:
	"""创建复选框"""
	var check_box = CheckBox.new()
	check_box.text = text
	check_box.button_pressed = pressed
	return check_box


# 创建选项按钮
static func create_option_button(items: Array = []) -> OptionButton:
	"""创建选项按钮"""
	var option_button = OptionButton.new()
	for item in items:
		option_button.add_item(str(item))
	option_button.custom_minimum_size = Vector2(120, 30)
	return option_button
