extends BaseUI
class_name MainMenuUI

# 主菜单UI - 游戏启动界面
# 包含开始游戏、设置、退出游戏等选项
# 依赖
const GridControlUIScript = preload("res://scripts/ui/GridControlUI.gd")


# UI控件引用
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var exit_button: Button = $VBoxContainer/ExitButton
@onready var version_label: Label = $VBoxContainer/VersionLabel

# 主游戏引用
var main_game: Node3D = null
var settings_panel: Panel = null
var grid_control_ui: Control = null


func _ready():
	"""初始化主菜单"""
	super._ready()
	_initialize_ui()
	_setup_ui_events()


func _initialize_ui():
	"""初始化UI组件"""
	# 设置版本信息
	version_label.text = "MazeMaster3D v1.0.0"

	# 设置标题字体大小
	var title_label = $VBoxContainer/TitleLabel
	var subtitle_label = $VBoxContainer/SubtitleLabel
	title_label.add_theme_font_size_override("font_size", 36)
	subtitle_label.add_theme_font_size_override("font_size", 20)

	# 设置按钮样式
	_setup_button_style(start_button, "开始游戏", Color(0.2, 0.8, 0.2))
	_setup_button_style(settings_button, "设置", Color(0.2, 0.6, 0.8))
	_setup_button_style(exit_button, "退出游戏", Color(0.8, 0.2, 0.2))


func _setup_button_style(button: Button, text: String, color: Color):
	"""设置按钮样式"""
	button.text = text
	button.custom_minimum_size = Vector2(300, 60)
	button.add_theme_font_size_override("font_size", 18)

	# 设置按钮颜色
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = color
	style_normal.corner_radius_top_left = 10
	style_normal.corner_radius_top_right = 10
	style_normal.corner_radius_bottom_left = 10
	style_normal.corner_radius_bottom_right = 10

	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = color.lightened(0.2)
	style_hover.corner_radius_top_left = 10
	style_hover.corner_radius_top_right = 10
	style_hover.corner_radius_bottom_left = 10
	style_hover.corner_radius_bottom_right = 10

	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = color.darkened(0.2)
	style_pressed.corner_radius_top_left = 10
	style_pressed.corner_radius_top_right = 10
	style_pressed.corner_radius_bottom_left = 10
	style_pressed.corner_radius_bottom_right = 10

	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)


func _setup_ui_events():
	"""设置UI事件"""
	# 检查是否已经连接过，避免重复连接
	if not start_button.pressed.is_connected(_on_start_button_pressed):
		start_button.pressed.connect(_on_start_button_pressed)
	if not settings_button.pressed.is_connected(_on_settings_button_pressed):
		settings_button.pressed.connect(_on_settings_button_pressed)
	if not exit_button.pressed.is_connected(_on_exit_button_pressed):
		exit_button.pressed.connect(_on_exit_button_pressed)


func _on_start_button_pressed():
	"""开始游戏按钮点击"""
	LogManager.info("开始游戏...")
	hide_ui()

	# 通知主游戏开始
	if main_game:
		main_game.start_game()


func _on_settings_button_pressed():
	"""设置按钮点击"""
	LogManager.info("打开设置...")
	_show_settings_panel()


func _show_settings_panel():
	"""显示设置面板（在主菜单内弹出）"""
	if settings_panel == null:
		settings_panel = Panel.new()
		settings_panel.name = "SettingsPanel"
		settings_panel.custom_minimum_size = Vector2(600, 500)
		settings_panel.set_anchors_preset(Control.PRESET_CENTER, true)
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.12, 0.12, 0.12, 0.95)
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_left = 10
		style.corner_radius_bottom_right = 10
		settings_panel.add_theme_stylebox_override("panel", style)

		# Header
		var header = HBoxContainer.new()
		header.add_theme_constant_override("separation", 12)
		header.position = Vector2(16, 16)
		var title = Label.new()
		title.text = "设置"
		title.add_theme_font_size_override("font_size", 24)
		header.add_child(title)
		var close_btn = Button.new()
		close_btn.text = "关闭"
		close_btn.pressed.connect(func(): settings_panel.visible = false)
		header.add_child(close_btn)
		settings_panel.add_child(header)

		# Content
		var content = VBoxContainer.new()
		content.add_theme_constant_override("separation", 8)
		content.position = Vector2(16, 60)
		settings_panel.add_child(content)

		# Grid Control UI (embedded in settings)
		grid_control_ui = GridControlUIScript.new()
		grid_control_ui.visible = true
		content.add_child(grid_control_ui)

		add_child(settings_panel)

	settings_panel.visible = true


func _on_exit_button_pressed():
	"""退出游戏按钮点击"""
	LogManager.info("退出游戏...")
	get_tree().quit()


func set_main_game_reference(game: Node3D):
	"""设置主游戏引用"""
	main_game = game