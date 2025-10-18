extends Control
class_name MapConfigUI

## 🗺️ 地图配置UI
## 提供MapConfig.gd中所有配置的图形界面

# UI控件引用
var region_sliders: Dictionary = {}
var cavity_sliders: Dictionary = {}
var room_sliders: Dictionary = {}
var resource_sliders: Dictionary = {}
var creature_sliders: Dictionary = {}

# 配置数据
var current_config: Dictionary = {}

func _ready():
	"""初始化地图配置UI"""
	_load_current_config()
	_create_ui()

func _load_current_config():
	"""加载当前配置"""
	current_config = {
		"region_ratios": MapConfig.get_region_ratios(),
		"cavity_config": MapConfig.get_cavity_excavation_config(),
		"room_config": MapConfig.get_room_generation_config(),
		"resource_config": MapConfig.get_resource_config(),
		"creature_config": MapConfig.get_creature_config()
	}

func _create_ui():
	"""创建UI界面"""
	# 创建滚动容器
	var scroll_container = ScrollContainer.new()
	scroll_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll_container)

	# 创建主容器
	var main_container = VBoxContainer.new()
	main_container.add_theme_constant_override("separation", 20)
	main_container.custom_minimum_size = Vector2(750, 1000)
	scroll_container.add_child(main_container)

	# 创建各个配置组
	_create_region_config_group(main_container)
	_create_cavity_config_group(main_container)
	_create_room_config_group(main_container)
	_create_resource_config_group(main_container)
	_create_creature_config_group(main_container)
	
	# 创建按钮组
	_create_button_group(main_container)

func _get_region_display_name(key: String) -> String:
	"""获取区域显示名称"""
	match key:
		"default_terrain": return "默认地形"
		"ecosystem": return "生态系统"
		"room_system": return "房间"
		"maze_system": return "迷宫"
		"hero_camp": return "英雄营地"
		_: return key

func _create_region_config_group(parent: VBoxContainer):
	"""创建区域配置组"""
	var group = _create_group_panel("区域占比配置", parent)
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 8)
	container.position = Vector2(10, 35)
	group.add_child(container)

	var region_ratios = current_config.region_ratios
	for key in region_ratios.keys():
		# 创建滑块行并存储引用
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)
		hbox.custom_minimum_size = Vector2(660, 30)
		
		# 标签
		var label = Label.new()
		label.text = _get_region_display_name(key) + ":"
		label.custom_minimum_size = Vector2(120, 0)
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
		hbox.add_child(label)
		
		# 滑块
		var slider = HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01
		slider.value = region_ratios[key]
		slider.custom_minimum_size = Vector2(300, 0)
		slider.value_changed.connect(_on_region_ratio_changed.bind(key))
		hbox.add_child(slider)
		
		# 数值标签
		var value_label = Label.new()
		value_label.text = "%.0f%%" % (region_ratios[key] * 100)
		value_label.custom_minimum_size = Vector2(80, 0)
		value_label.add_theme_font_size_override("font_size", 14)
		value_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		hbox.add_child(value_label)
		
		# 连接滑块和标签
		slider.value_changed.connect(func(value): value_label.text = "%.0f%%" % (value * 100))
		
		container.add_child(hbox)
		region_sliders[key] = {"slider": slider, "label": value_label}

func _create_cavity_config_group(parent: VBoxContainer):
	"""创建空洞配置组"""
	var group = _create_group_panel("空洞挖掘系统配置", parent)
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 8)
	container.position = Vector2(10, 35)
	group.add_child(container)

	var cavity_config = current_config.cavity_config
	
	# 空洞密度
	_create_slider_row(container, "空洞密度", cavity_config.cavity_density, 0.0, 0.5, 0.01,
		func(value): _on_cavity_config_changed("cavity_density", value))
	
	# 最小空洞半径
	_create_slider_row(container, "最小空洞半径", cavity_config.min_cavity_radius, 1.0, 20.0, 0.5,
		func(value): _on_cavity_config_changed("min_cavity_radius", value))
	
	# 最大空洞半径
	_create_slider_row(container, "最大空洞半径", cavity_config.max_cavity_radius, 10.0, 50.0, 1.0,
		func(value): _on_cavity_config_changed("max_cavity_radius", value))
	
	# 平均空洞半径
	_create_slider_row(container, "平均空洞半径", cavity_config.average_cavity_radius, 5.0, 30.0, 0.5,
		func(value): _on_cavity_config_changed("average_cavity_radius", value))
	
	# 最小空洞间距
	_create_slider_row(container, "最小空洞间距", cavity_config.min_cavity_distance, 10.0, 50.0, 1.0,
		func(value): _on_cavity_config_changed("min_cavity_distance", value))
	
	# 噪声频率
	_create_slider_row(container, "噪声频率", cavity_config.noise_frequency, 0.01, 0.5, 0.01,
		func(value): _on_cavity_config_changed("noise_frequency", value))
	
	# 噪声幅度
	_create_slider_row(container, "噪声幅度", cavity_config.noise_amplitude, 0.1, 1.0, 0.05,
		func(value): _on_cavity_config_changed("noise_amplitude", value))
	
	# 形状不规则度
	_create_slider_row(container, "形状不规则度", cavity_config.shape_irregularity, 0.1, 1.0, 0.05,
		func(value): _on_cavity_config_changed("shape_irregularity", value))

func _create_room_config_group(parent: VBoxContainer):
	"""创建房间配置组"""
	var group = _create_group_panel("房间生成配置", parent)
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 8)
	container.position = Vector2(10, 35)
	group.add_child(container)

	var room_config = current_config.room_config
	
	# 最大房间数量
	_create_slider_row(container, "最大房间数量", room_config.max_room_count, 5, 50, 1,
		func(value): _on_room_config_changed("max_room_count", value))
	
	# 最小房间尺寸
	_create_slider_row(container, "最小房间尺寸", room_config.min_room_size, 2, 10, 1,
		func(value): _on_room_config_changed("min_room_size", value))
	
	# 最大房间尺寸
	_create_slider_row(container, "最大房间尺寸", room_config.max_room_size, 5, 15, 1,
		func(value): _on_room_config_changed("max_room_size", value))
	
	# 房间连接尝试次数
	_create_slider_row(container, "连接尝试次数", room_config.room_connection_attempts, 5, 30, 1,
		func(value): _on_room_config_changed("room_connection_attempts", value))
	
	# 走廊宽度
	_create_slider_row(container, "走廊宽度", room_config.corridor_width, 1, 5, 1,
		func(value): _on_room_config_changed("corridor_width", value))

func _create_resource_config_group(parent: VBoxContainer):
	"""创建资源配置组"""
	var group = _create_group_panel("资源生成配置", parent)
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 8)
	container.position = Vector2(10, 35)
	group.add_child(container)

	var resource_config = current_config.resource_config
	
	# 资源密度
	_create_slider_row(container, "资源密度", resource_config.resource_density, 0.01, 0.3, 0.01,
		func(value): _on_resource_config_changed("resource_density", value))
	
	# 金矿密度
	_create_slider_row(container, "金矿密度", resource_config.gold_mine_density, 0.01, 0.2, 0.01,
		func(value): _on_resource_config_changed("gold_mine_density", value))
	
	# 水晶密度
	_create_slider_row(container, "水晶密度", resource_config.crystal_density, 0.01, 0.15, 0.01,
		func(value): _on_resource_config_changed("crystal_density", value))
	
	# 宝石密度
	_create_slider_row(container, "宝石密度", resource_config.gem_density, 0.01, 0.1, 0.01,
		func(value): _on_resource_config_changed("gem_density", value))

func _create_creature_config_group(parent: VBoxContainer):
	"""创建生物配置组"""
	var group = _create_group_panel("生物生成配置", parent)
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 8)
	container.position = Vector2(10, 35)
	group.add_child(container)

	var creature_config = current_config.creature_config
	
	# 怪物密度
	_create_slider_row(container, "怪物密度", creature_config.monster_density, 0.01, 0.3, 0.01,
		func(value): _on_creature_config_changed("monster_density", value))
	
	# 英雄密度
	_create_slider_row(container, "英雄密度", creature_config.hero_density, 0.01, 0.1, 0.01,
		func(value): _on_creature_config_changed("hero_density", value))
	
	# 中性生物密度
	_create_slider_row(container, "中性生物密度", creature_config.neutral_density, 0.01, 0.2, 0.01,
		func(value): _on_creature_config_changed("neutral_density", value))
	
	# 生成尝试次数
	_create_slider_row(container, "生成尝试次数", creature_config.spawn_attempts, 50, 500, 10,
		func(value): _on_creature_config_changed("spawn_attempts", value))

func _create_button_group(parent: VBoxContainer):
	"""创建按钮组"""
	var group = _create_group_panel("操作", parent)
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 16)
	container.position = Vector2(10, 35)
	group.add_child(container)

	# 重置按钮
	var reset_button = Button.new()
	reset_button.text = "重置为默认"
	reset_button.custom_minimum_size = Vector2(120, 40)
	reset_button.pressed.connect(_on_reset_pressed)
	container.add_child(reset_button)

	# 应用按钮
	var apply_button = Button.new()
	apply_button.text = "应用配置"
	apply_button.custom_minimum_size = Vector2(120, 40)
	apply_button.pressed.connect(_on_apply_pressed)
	container.add_child(apply_button)

	# 重新生成地图按钮
	var regenerate_button = Button.new()
	regenerate_button.text = "重新生成地图"
	regenerate_button.custom_minimum_size = Vector2(120, 40)
	regenerate_button.pressed.connect(_on_regenerate_pressed)
	container.add_child(regenerate_button)

func _create_group_panel(title: String, parent: VBoxContainer) -> Panel:
	"""创建分组面板"""
	var panel = Panel.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.4, 1.0)
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(700, 120)
	
	# 创建标题容器
	var title_container = HBoxContainer.new()
	title_container.position = Vector2(10, 5)
	title_container.size = Vector2(680, 30)
	panel.add_child(title_container)
	
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	title_container.add_child(title_label)
	
	parent.add_child(panel)
	return panel

func _create_slider_row(parent: VBoxContainer, label_text: String, initial_value: float,
	min_value: float, max_value: float, step: float, callback: Callable):
	"""创建滑块行"""
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	hbox.custom_minimum_size = Vector2(660, 30)
	
	# 标签
	var label = Label.new()
	label.text = label_text + ":"
	label.custom_minimum_size = Vector2(120, 0)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	hbox.add_child(label)
	
	# 滑块
	var slider = HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = initial_value
	slider.custom_minimum_size = Vector2(300, 0)
	slider.value_changed.connect(callback)
	hbox.add_child(slider)
	
	# 数值标签
	var value_label = Label.new()
	value_label.text = "%.2f" % initial_value
	value_label.custom_minimum_size = Vector2(80, 0)
	value_label.add_theme_font_size_override("font_size", 14)
	value_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hbox.add_child(value_label)
	
	# 连接滑块和标签
	slider.value_changed.connect(func(value): value_label.text = "%.2f" % value)
	
	parent.add_child(hbox)

# 信号处理函数
func _on_region_ratio_changed(key: String, value: float):
	"""区域占比改变"""
	current_config.region_ratios[key] = value
	# 更新UI显示（如果存在）
	if region_sliders.has(key):
		region_sliders[key].label.text = "%.0f%%" % (value * 100)

func _on_cavity_config_changed(key: String, value: float):
	"""空洞配置改变"""
	current_config.cavity_config[key] = value

func _on_room_config_changed(key: String, value: float):
	"""房间配置改变"""
	current_config.room_config[key] = value

func _on_resource_config_changed(key: String, value: float):
	"""资源配置改变"""
	current_config.resource_config[key] = value

func _on_creature_config_changed(key: String, value: float):
	"""生物配置改变"""
	current_config.creature_config[key] = value

func _on_reset_pressed():
	"""重置为默认配置"""
	_load_current_config()
	_refresh_ui()

func _on_apply_pressed():
	"""应用配置"""
	LogManager.info("应用地图配置...")
	
	# 验证配置
	if not _validate_config():
		LogManager.warning("配置验证失败，请检查参数")
		return
	
	# 应用配置到MapConfig（注意：MapConfig是静态的，需要重新加载）
	_apply_config_to_mapconfig()
	
	LogManager.info("地图配置已应用")

func _validate_config():
	"""验证配置参数"""
	# 验证区域占比总和为1.0
	var region_total = 0.0
	for key in current_config.region_ratios.keys():
		region_total += current_config.region_ratios[key]
	
	if abs(region_total - 1.0) > 0.01:
		LogManager.error("区域占比总和不为1.0: %f" % region_total)
		return false
	
	# 验证空洞配置
	var cavity = current_config.cavity_config
	if cavity.min_cavity_radius >= cavity.max_cavity_radius:
		LogManager.error("最小空洞半径必须小于最大空洞半径")
		return false
	
	if cavity.average_cavity_radius < cavity.min_cavity_radius or cavity.average_cavity_radius > cavity.max_cavity_radius:
		LogManager.error("平均空洞半径必须在最小和最大半径之间")
		return false
	
	return true

func _apply_config_to_mapconfig():
	"""将配置应用到MapConfig"""
	# 注意：由于MapConfig是静态的，我们无法直接修改其配置
	# 这里我们保存配置到用户设置中，供地图生成时使用
	var user_settings = {
		"region_ratios": current_config.region_ratios,
		"cavity_config": current_config.cavity_config,
		"room_config": current_config.room_config,
		"resource_config": current_config.resource_config,
		"creature_config": current_config.creature_config
	}
	
	# 保存到用户设置文件
	var config_file = FileAccess.open("user://map_settings.json", FileAccess.WRITE)
	if config_file:
		config_file.store_string(JSON.stringify(user_settings))
		config_file.close()
		LogManager.info("配置已保存到用户设置")
	else:
		LogManager.error("无法保存配置到文件")

func _on_regenerate_pressed():
	"""重新生成地图"""
	LogManager.info("重新生成地图...")
	# 发送信号通知主游戏重新生成地图
	regenerate_map_requested.emit()

func _refresh_ui():
	"""刷新UI显示"""
	# 重新加载配置
	_load_current_config()
	
	# 刷新所有滑块的值
	for key in region_sliders.keys():
		if current_config.region_ratios.has(key):
			var value = current_config.region_ratios[key]
			region_sliders[key].slider.value = value
			region_sliders[key].label.text = "%.0f%%" % (value * 100)

# 信号定义
signal regenerate_map_requested
