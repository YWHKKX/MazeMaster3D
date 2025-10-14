extends Control
# 网格控制UI - 提供网格设置的图形界面

# 导入必要的类
const GridManager = preload("res://scripts/managers/GridManager.gd")
# 集成到主UI系统

@onready var grid_manager = $"../../CharacterManager/../GridManager"

# UI控件引用
var grid_toggle_button: Button
var coordinate_toggle_button: Button
var grid_style_option: OptionButton
var grid_size_slider: HSlider
var grid_size_label: Label
var color_picker_main: ColorPickerButton
var color_picker_minor: ColorPickerButton

# UI配置
var ui_config = {"panel_size": Vector2(250, 300), "button_size": Vector2(120, 30), "margin": 10}


func _ready():
	"""初始化网格控制UI"""
	LogManager.info("GridControlUI - 初始化开始")
	_setup_ui()
	_setup_connections()
	LogManager.info("GridControlUI - 初始化完成")


func _setup_ui():
	"""设置UI界面"""
	# 设置面板大小和位置
	custom_minimum_size = ui_config.panel_size
	position = Vector2(20, 150)

	# 创建背景
	var background = ColorRect.new()
	background.color = Color(0.1, 0.1, 0.1, 0.8)
	background.size = ui_config.panel_size
	add_child(background)

	# 创建标题
	var title = Label.new()
	title.text = "网格控制"
	title.position = Vector2(ui_config.margin, ui_config.margin)
	title.add_theme_font_size_override("font_size", 16)
	title.modulate = Color.WHITE
	add_child(title)

	var y_offset = 40

	# 网格开关按钮
	grid_toggle_button = Button.new()
	grid_toggle_button.text = "切换网格 (G)"
	grid_toggle_button.position = Vector2(ui_config.margin, y_offset)
	grid_toggle_button.size = ui_config.button_size
	add_child(grid_toggle_button)
	y_offset += 40

	# 坐标开关按钮
	coordinate_toggle_button = Button.new()
	coordinate_toggle_button.text = "切换坐标 (C)"
	coordinate_toggle_button.position = Vector2(ui_config.margin, y_offset)
	coordinate_toggle_button.size = ui_config.button_size
	add_child(coordinate_toggle_button)
	y_offset += 40

	# 网格样式选择
	var style_label = Label.new()
	style_label.text = "网格样式:"
	style_label.position = Vector2(ui_config.margin, y_offset)
	style_label.modulate = Color.WHITE
	add_child(style_label)
	y_offset += 25

	grid_style_option = OptionButton.new()
	grid_style_option.position = Vector2(ui_config.margin, y_offset)
	grid_style_option.size = Vector2(ui_config.button_size.x, 30)
	grid_style_option.add_item("虚线")
	grid_style_option.add_item("实线")
	grid_style_option.add_item("点线")
	add_child(grid_style_option)
	y_offset += 40

	# 网格大小控制
	var size_label = Label.new()
	size_label.text = "网格大小:"
	size_label.position = Vector2(ui_config.margin, y_offset)
	size_label.modulate = Color.WHITE
	add_child(size_label)
	y_offset += 25

	grid_size_slider = HSlider.new()
	grid_size_slider.position = Vector2(ui_config.margin, y_offset)
	grid_size_slider.size = Vector2(ui_config.button_size.x - 50, 20)
	grid_size_slider.min_value = 1.0
	grid_size_slider.max_value = 20.0
	grid_size_slider.step = 1.0
	grid_size_slider.value = 10.0
	add_child(grid_size_slider)

	grid_size_label = Label.new()
	grid_size_label.text = "10"
	grid_size_label.position = Vector2(ui_config.margin + ui_config.button_size.x - 40, y_offset)
	grid_size_label.size = Vector2(40, 20)
	grid_size_label.modulate = Color.WHITE
	add_child(grid_size_label)
	y_offset += 40

	# 颜色选择器
	var color_label = Label.new()
	color_label.text = "主网格颜色"
	color_label.position = Vector2(ui_config.margin, y_offset)
	color_label.modulate = Color.WHITE
	add_child(color_label)
	y_offset += 25

	color_picker_main = ColorPickerButton.new()
	color_picker_main.position = Vector2(ui_config.margin, y_offset)
	color_picker_main.size = Vector2(100, 30)
	color_picker_main.color = Color(1.0, 1.0, 1.0, 0.3)
	add_child(color_picker_main)
	y_offset += 40

	var color_label_minor = Label.new()
	color_label_minor.text = "次要网格颜色:"
	color_label_minor.position = Vector2(ui_config.margin, y_offset)
	color_label_minor.modulate = Color.WHITE
	add_child(color_label_minor)
	y_offset += 25

	color_picker_minor = ColorPickerButton.new()
	color_picker_minor.position = Vector2(ui_config.margin, y_offset)
	color_picker_minor.size = Vector2(100, 30)
	color_picker_minor.color = Color(1.0, 1.0, 1.0, 0.1)
	add_child(color_picker_minor)
	y_offset += 40

	# 重置按钮
	var reset_button = Button.new()
	reset_button.text = "重置设置"
	reset_button.position = Vector2(ui_config.margin, y_offset)
	reset_button.size = ui_config.button_size
	add_child(reset_button)

	# 连接重置按钮
	reset_button.pressed.connect(_on_reset_button_pressed)


func _setup_connections():
	"""设置信号连接"""
	# 按钮连接
	grid_toggle_button.pressed.connect(_on_grid_toggle_pressed)
	coordinate_toggle_button.pressed.connect(_on_coordinate_toggle_pressed)

	# 选项按钮连接
	grid_style_option.item_selected.connect(_on_grid_style_changed)

	# 滑块连接
	grid_size_slider.value_changed.connect(_on_grid_size_changed)

	# 颜色选择器连接
	color_picker_main.color_changed.connect(_on_main_color_changed)
	color_picker_minor.color_changed.connect(_on_minor_color_changed)


# 信号处理函数
func _on_grid_toggle_pressed():
	"""网格切换按钮按下"""
	if grid_manager:
		grid_manager.toggle_grid()
		_update_button_states()


func _on_coordinate_toggle_pressed():
	"""坐标切换按钮按下"""
	if grid_manager:
		grid_manager.toggle_coordinates()
		_update_button_states()


func _on_grid_style_changed(index: int):
	"""网格样式改变"""
	if grid_manager:
		var style = GridManager.GridStyle.DASHED
		match index:
			0:
				style = GridManager.GridStyle.DASHED
			1:
				style = GridManager.GridStyle.SOLID
			2:
				style = GridManager.GridStyle.DOTTED
		grid_manager.set_grid_style(style)


func _on_grid_size_changed(value: float):
	"""网格大小改变"""
	grid_size_label.text = str(int(value))
	if grid_manager:
		grid_manager.set_grid_size(value)


func _on_main_color_changed(color: Color):
	"""主网格颜色改变"""
	if grid_manager:
		grid_manager.set_grid_colors(color, grid_manager.grid_config.minor_grid_color)


func _on_minor_color_changed(color: Color):
	"""次要网格颜色改变"""
	if grid_manager:
		grid_manager.set_grid_colors(grid_manager.grid_config.main_grid_color, color)


func _on_reset_button_pressed():
	"""重置按钮按下"""
	if grid_manager:
		_reset_to_defaults()
		_update_ui_values()


# 状态更新
func _update_button_states():
	"""更新按钮状态"""
	if not grid_manager:
		return

	var grid_info = grid_manager.get_grid_info()

	# 更新按钮文本
	if grid_info.enabled:
		grid_toggle_button.text = "禁用网格 (G)"
	else:
		grid_toggle_button.text = "启用网格 (G)"

	if grid_info.show_coordinates:
		coordinate_toggle_button.text = "隐藏坐标 (C)"
	else:
		coordinate_toggle_button.text = "显示坐标 (C)"


func _update_ui_values():
	"""更新UI值"""
	if not grid_manager:
		return

	var grid_info = grid_manager.get_grid_info()

	# 更新滑块值
	grid_size_slider.value = grid_info.main_grid_size
	grid_size_label.text = str(int(grid_info.main_grid_size))

	# 更新样式选择
	match grid_info.style:
		GridManager.GridStyle.DASHED:
			grid_style_option.selected = 0
		GridManager.GridStyle.SOLID:
			grid_style_option.selected = 1
		GridManager.GridStyle.DOTTED:
			grid_style_option.selected = 2

	# 更新颜色选择器
	color_picker_main.color = grid_manager.grid_config.main_grid_color
	color_picker_minor.color = grid_manager.grid_config.minor_grid_color


func _reset_to_defaults():
	"""重置为默认设置"""
	if not grid_manager:
		return

	grid_manager.grid_config = {
		"enabled": true,
		"main_grid_size": 10.0,
		"minor_grid_size": 2.0,
		"main_grid_color": Color(1.0, 1.0, 1.0, 0.3),
		"minor_grid_color": Color(1.0, 1.0, 1.0, 0.1),
		"coordinate_color": Color(0.8, 0.8, 1.0, 0.6),
		"grid_style": GridManager.GridStyle.DASHED,
		"show_coordinates": false,
		"grid_height": 0.1
	}

	grid_manager._generate_grid()
	LogManager.info("网格设置已重置为默认")


# 输入处理
func _input(event: InputEvent):
	"""处理输入事件"""
	# 仅在设置面板中可见时响应本地快捷键，避免与全局(main.gd)重复处理
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_G:
				_on_grid_toggle_pressed()


# 可见性控制
func toggle_visibility():
	"""切换UI可见性"""
	visible = not visible


func show_ui():
	"""显示UI"""
	visible = true


func hide_ui():
	"""隐藏UI"""
	visible = false

# 日志管理器实例（全局变量）
# LogManager 现在是自动加载的全局单例
