extends BaseUI
class_name MainMenuUI

# 主菜单UI - 游戏启动界面
# 包含开始游戏、设置、退出游戏等选项
# 依赖
const GridControlUIScript = preload("res://scripts/ui/GridControlUI.gd")
const MapConfigUI = preload("res://scripts/ui/MapConfigUI.gd")


# UI控件引用
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var exit_button: Button = $VBoxContainer/ExitButton
@onready var version_label: Label = $VBoxContainer/VersionLabel

# 主游戏引用
var main_game: Node3D = null
var settings_panel: Panel = null
var grid_control_ui: Control = null
var map_config_ui: MapConfigUI = null


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
		settings_panel.custom_minimum_size = Vector2(800, 600)
		# 使用更精确的居中定位
		settings_panel.set_anchors_preset(Control.PRESET_CENTER)
		settings_panel.set_offsets_preset(Control.PRESET_CENTER)
		settings_panel.offset_left = -400
		settings_panel.offset_top = -300
		settings_panel.offset_right = 400
		settings_panel.offset_bottom = 300
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
		title.text = "游戏设置"
		title.add_theme_font_size_override("font_size", 24)
		header.add_child(title)
		var close_btn = Button.new()
		close_btn.text = "关闭"
		close_btn.pressed.connect(func(): settings_panel.visible = false)
		header.add_child(close_btn)
		settings_panel.add_child(header)

		# 创建滚动容器
		var scroll_container = ScrollContainer.new()
		scroll_container.position = Vector2(16, 60)
		scroll_container.size = Vector2(768, 520)
		settings_panel.add_child(scroll_container)

		# 创建主内容容器
		var main_content = VBoxContainer.new()
		main_content.add_theme_constant_override("separation", 16)
		scroll_container.add_child(main_content)

		# 创建标签页容器
		var tab_container = TabContainer.new()
		tab_container.custom_minimum_size = Vector2(750, 500)
		main_content.add_child(tab_container)

		# 地图配置标签页
		_create_map_config_tab(tab_container)
		
		# 网格控制标签页
		_create_grid_control_tab(tab_container)
		
		# 游戏设置标签页
		_create_game_settings_tab(tab_container)

		add_child(settings_panel)

	settings_panel.visible = true

func _create_map_config_tab(tab_container: TabContainer):
	"""创建地图配置标签页"""
	var map_tab = Control.new()
	map_tab.name = "地图配置"
	tab_container.add_child(map_tab)

	# 使用新的MapConfigUI（只创建一次）
	if not map_config_ui:
		map_config_ui = MapConfigUI.new()
		map_config_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		map_config_ui.regenerate_map_requested.connect(_on_regenerate_map_pressed)
	
	map_tab.add_child(map_config_ui)

func _create_grid_control_tab(tab_container: TabContainer):
	"""创建网格控制标签页"""
	var grid_tab = Control.new()
	grid_tab.name = "网格控制"
	tab_container.add_child(grid_tab)

	# 嵌入原有的GridControlUI（只创建一次）
	if not grid_control_ui:
		grid_control_ui = GridControlUIScript.new()
		grid_control_ui.visible = true
		grid_control_ui.position = Vector2(20, 20)
	
	grid_tab.add_child(grid_control_ui)

func _create_game_settings_tab(tab_container: TabContainer):
	"""创建游戏设置标签页"""
	var game_tab = Control.new()
	game_tab.name = "游戏设置"
	tab_container.add_child(game_tab)

	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	content.position = Vector2(20, 20)
	content.size = Vector2(700, 450)
	game_tab.add_child(content)

	# 游戏难度
	var difficulty_group = _create_group_box("游戏难度", content)
	var difficulty_container = VBoxContainer.new()
	difficulty_group.add_child(difficulty_container)
	
	var difficulty_option = OptionButton.new()
	difficulty_option.add_item("简单")
	difficulty_option.add_item("普通")
	difficulty_option.add_item("困难")
	difficulty_option.selected = 1
	difficulty_container.add_child(difficulty_option)

	# 视觉效果
	var visual_group = _create_group_box("视觉效果", content)
	var visual_container = VBoxContainer.new()
	visual_group.add_child(visual_container)
	
	var shadows_checkbox = CheckBox.new()
	shadows_checkbox.text = "启用阴影"
	shadows_checkbox.button_pressed = true
	visual_container.add_child(shadows_checkbox)
	
	var particles_checkbox = CheckBox.new()
	particles_checkbox.text = "启用粒子效果"
	particles_checkbox.button_pressed = true
	visual_container.add_child(particles_checkbox)

	# 音效设置
	var audio_group = _create_group_box("音效设置", content)
	var audio_container = VBoxContainer.new()
	audio_group.add_child(audio_container)
	
	var master_volume_hbox = HBoxContainer.new()
	var master_label = Label.new()
	master_label.text = "主音量:"
	master_label.custom_minimum_size = Vector2(100, 0)
	master_volume_hbox.add_child(master_label)
	
	var master_slider = HSlider.new()
	master_slider.min_value = 0.0
	master_slider.max_value = 1.0
	master_slider.step = 0.1
	master_slider.value = 0.8
	master_slider.custom_minimum_size = Vector2(200, 0)
	master_volume_hbox.add_child(master_slider)
	audio_container.add_child(master_volume_hbox)

func _create_group_box(title: String, parent: Control) -> Panel:
	"""创建分组框"""
	var group = Panel.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	group.add_theme_stylebox_override("panel", style)
	group.custom_minimum_size = Vector2(700, 100)
	
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.position = Vector2(10, 5)
	group.add_child(title_label)
	
	parent.add_child(group)
	return group

func _on_regenerate_map_pressed():
	"""重新生成地图按钮点击"""
	LogManager.info("重新生成地图...")
	
	# 通知主游戏重新生成地图
	if main_game and main_game.has_method("regenerate_map"):
		await main_game.regenerate_map()
		LogManager.info("地图重新生成完成")
		
		# 关闭设置面板
		if settings_panel:
			settings_panel.visible = false
	else:
		LogManager.warning("无法重新生成地图：主游戏引用无效")


func _on_exit_button_pressed():
	"""退出游戏按钮点击"""
	LogManager.info("退出游戏...")
	get_tree().quit()


func set_main_game_reference(game: Node3D):
	"""设置主游戏引用"""
	main_game = game