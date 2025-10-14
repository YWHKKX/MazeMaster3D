extends BaseUI
class_name GameUI

# 主游戏UI - 实现STANDALONE.md中的快捷键UI
# 参考UI_BEAUTIFICATION.md 和STANDALONE.md

# 导入UI工具类
const UIDesignConstants = preload("res://scripts/ui/UIDesignConstants.gd")

# UI面板引用
var resource_panel: Control
var build_panel: Control
var status_panel: Control
var game_info_panel: Control
var actions_sidebar: Control

# 主游戏引用
var main_game: Node = null

# UI配置
var ui_config = {"panel_width": 350, "panel_height": 200, "margin": 30, "show_shortcuts": true}

# 资源显示相关
var resource_labels: Dictionary = {} # 存储资源标签引用
var resource_manager = null # ResourceManager引用
var update_timer: Timer = null # 更新定时器


func _ready():
	"""初始化游戏UI"""
	LogManager.info("GameUI - 初始化开始")
	_setup_game_ui()
	
	# 等待一帧，确保GameServices和ResourceManager都已初始化
	await get_tree().process_frame
	
	# 从GameServices获取ResourceManager
	resource_manager = GameServices.resource_manager
	if resource_manager:
		LogManager.info("GameUI - ResourceManager已连接")
		# 连接资源变化信号
		resource_manager.resource_changed.connect(_on_resource_changed)
		resource_manager.resource_added.connect(_on_resource_added)
		resource_manager.resource_removed.connect(_on_resource_removed)
	else:
		LogManager.error("GameUI - 无法获取ResourceManager！")
	
	# 设置定期更新定时器
	_setup_update_timer()
	
	# 初始时隐藏，等待主菜单结束后再显示
	hide_ui()
	LogManager.info("GameUI - 初始化完成")


func _setup_game_ui():
	"""设置游戏UI"""
	# 设置全屏
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# 创建各个面板
	_create_resource_panel()
	_create_build_panel()
	_create_status_panel()
	_create_game_info_panel()
	_create_actions_sidebar()

	# 设置输入处理
	_setup_input_handling()


func _setup_update_timer():
	"""设置定期更新定时器"""
	update_timer = Timer.new()
	update_timer.wait_time = 0.5 # 每0.5秒更新一次
	update_timer.timeout.connect(_update_resource_display)
	add_child(update_timer)
	update_timer.start()
	LogManager.info("GameUI - 资源更新定时器已启动")


func _update_resource_display():
	"""更新资源显示"""
	if not resource_manager:
		return
	
	# 更新金币显示
	if "gold" in resource_labels:
		var gold_info = resource_manager.get_total_gold()
		var gold_amount = gold_info.total if gold_info else 0
		resource_labels["gold"].text = str(gold_amount)
		
		# 根据金币数量设置颜色
		var gold_capacity = gold_info.capacity if gold_info else 5000
		var gold_percentage = float(gold_amount) / float(gold_capacity) * 100.0
		if gold_percentage >= 80:
			resource_labels["gold"].modulate = UIDesignConstants.Colors.SUCCESS
		elif gold_percentage >= 50:
			resource_labels["gold"].modulate = UIDesignConstants.Colors.WARNING
		else:
			resource_labels["gold"].modulate = UIDesignConstants.Colors.ERROR
	
	# 更新魔力显示
	if "mana" in resource_labels:
		var mana_info = resource_manager.get_total_mana()
		var mana_amount = mana_info.total if mana_info else 0
		resource_labels["mana"].text = str(mana_amount)
		
		# 根据魔力数量设置颜色
		var mana_capacity = mana_info.capacity if mana_info else 2000
		var mana_percentage = float(mana_amount) / float(mana_capacity) * 100.0
		if mana_percentage >= 80:
			resource_labels["mana"].modulate = UIDesignConstants.Colors.SUCCESS
		elif mana_percentage >= 50:
			resource_labels["mana"].modulate = UIDesignConstants.Colors.WARNING
		else:
			resource_labels["mana"].modulate = UIDesignConstants.Colors.ERROR


# 信号处理函数
func _on_resource_changed(resource_type: int, amount: int, old_amount: int):
	"""资源变化信号处理"""
	# 立即更新显示
	_update_resource_display()


func _on_resource_added(resource_type: int, amount: int):
	"""资源添加信号处理"""
	# 立即更新显示
	_update_resource_display()


func _on_resource_removed(resource_type: int, amount: int):
	"""资源移除信号处理"""
	# 立即更新显示
	_update_resource_display()
	
	# 更新其他资源显示（暂时保持静态）
	if "food" in resource_labels:
		resource_labels["food"].text = "0"
	if "raw_gold" in resource_labels:
		resource_labels["raw_gold"].text = "0"
	if "monsters" in resource_labels:
		resource_labels["monsters"].text = "0"
	if "score" in resource_labels:
		resource_labels["score"].text = "0"


func _create_resource_panel():
	"""创建资源面板 (左上角)"""
	resource_panel = UIUtils.create_panel(
		Vector2(ui_config.panel_width, ui_config.panel_height), UIDesignConstants.Colors.PANEL
	)
	resource_panel.position = Vector2(ui_config.margin, ui_config.margin)
	resource_panel.name = "ResourcePanel"

	# 创建标题
	var title = UIUtils.create_label(
		"📊 资源状态", UIDesignConstants.FontSizes.H3, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	title.position = Vector2(UIDesignConstants.Spacing.MD, UIDesignConstants.Spacing.MD)
	resource_panel.add_child(title)

	# 创建资源列表
	var resource_container = UIUtils.create_vbox_container(UIDesignConstants.Spacing.SM)
	resource_container.position = Vector2(
		UIDesignConstants.Spacing.MD, UIDesignConstants.Spacing.XL
	)
	resource_panel.add_child(resource_container)

	# 资源项目 - 存储标签引用以便更新
	resource_labels["gold"] = _create_resource_item(resource_container, "💰", "黄金", "0")
	resource_labels["mana"] = _create_resource_item(resource_container, "🔮", "法力", "0")
	resource_labels["food"] = _create_resource_item(resource_container, "🍖", "食物", "0")
	resource_labels["raw_gold"] = _create_resource_item(resource_container, "⚒️", "原始黄金", "0")
	resource_labels["monsters"] = _create_resource_item(resource_container, "👹", "怪物数量", "0")
	resource_labels["score"] = _create_resource_item(resource_container, "🏆", "当前分数", "0")


func _create_build_panel():
	"""创建建造面板(右上角)"""
	build_panel = UIUtils.create_panel(
		Vector2(ui_config.panel_width, 200), UIDesignConstants.Colors.PANEL
	)
	build_panel.position = Vector2(
		get_viewport().size.x - ui_config.panel_width - ui_config.margin, ui_config.margin
	)
	build_panel.name = "BuildPanel"

	# 创建标题
	var title = UIUtils.create_label(
		"🏗️ 建造选项", UIDesignConstants.FontSizes.H3, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	title.position = Vector2(UIDesignConstants.Spacing.MD, UIDesignConstants.Spacing.MD)
	build_panel.add_child(title)

	# 创建建造选项容器
	var build_container = UIUtils.create_vbox_container(UIDesignConstants.Spacing.SM)
	build_container.position = Vector2(UIDesignConstants.Spacing.MD, UIDesignConstants.Spacing.XL)
	build_panel.add_child(build_container)

	# 建造选项 (对应STANDALONE.md中的快捷键)
	_create_build_option(build_container, "1", "⛏️", "挖掘模式", "挖掘岩石，消耗10金币", 10)
	_create_build_option(build_container, "2", "🏗️", "建筑面板", "打开建筑面板，建造各种建筑", 0)
	_create_build_option(build_container, "4/M", "👹", "召唤怪物", "召唤怪物，弹出选择界面", 0)
	_create_build_option(build_container, "5/W", "🎒", "后勤召唤", "后勤召唤面板，选择工程师或苦工", 0)


func _create_status_panel():
	"""创建状态面板(左下角)"""
	status_panel = UIUtils.create_panel(Vector2(300, 120), UIDesignConstants.Colors.PANEL)
	status_panel.position = Vector2(
		ui_config.margin, get_viewport().size.y - 120 - ui_config.margin
	)
	status_panel.name = "StatusPanel"

	# 创建标题
	var title = UIUtils.create_label(
		"📹 状态信息", UIDesignConstants.FontSizes.H3, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	title.position = Vector2(UIDesignConstants.Spacing.MD, UIDesignConstants.Spacing.MD)
	status_panel.add_child(title)

	# 创建状态信息容器
	var status_container = UIUtils.create_vbox_container(UIDesignConstants.Spacing.XS)
	status_container.position = Vector2(UIDesignConstants.Spacing.MD, UIDesignConstants.Spacing.XL)
	status_panel.add_child(status_container)

	# 状态信息项目
	_create_status_item(status_container, "🖱️", "鼠标坐标", "0, 0")
	_create_status_item(status_container, "🌍", "世界坐标", "0, 0, 0")
	_create_status_item(status_container, "📹", "相机位置", "0, 0, 0")
	_create_status_item(status_container, "🔧", "当前模式", "空闲")


func _create_game_info_panel():
	"""创建游戏信息面板 (右下角)"""
	game_info_panel = UIUtils.create_panel(Vector2(250, 100), UIDesignConstants.Colors.PANEL)
	game_info_panel.position = Vector2(
		get_viewport().size.x - 250 - ui_config.margin,
		get_viewport().size.y - 100 - ui_config.margin
	)
	game_info_panel.name = "GameInfoPanel"

	# 创建标题
	var title = UIUtils.create_label(
		"🎮 游戏信息", UIDesignConstants.FontSizes.H3, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	title.position = Vector2(UIDesignConstants.Spacing.MD, UIDesignConstants.Spacing.MD)
	game_info_panel.add_child(title)

	# 创建游戏信息容器
	var info_container = UIUtils.create_vbox_container(UIDesignConstants.Spacing.XS)
	info_container.position = Vector2(UIDesignConstants.Spacing.MD, UIDesignConstants.Spacing.XL)
	game_info_panel.add_child(info_container)

	# 游戏信息项目
	_create_info_item(info_container, "⌨️", "WASD", "移动相机")
	_create_info_item(info_container, "🖱️", "滚轮", "高度移动")
	_create_info_item(info_container, "⌨️", "ESC", "取消模式")


# 辅助创建方法
func _create_resource_item(container: VBoxContainer, emoji: String, name: String, value: String) -> Label:
	"""创建资源项目，返回数值标签引用"""
	var hbox = UIUtils.create_hbox_container(0)

	var emoji_label = UIUtils.create_label(
		emoji, UIDesignConstants.FontSizes.LARGE, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	var name_label = UIUtils.create_label(
		name, UIDesignConstants.FontSizes.NORMAL, UIDesignConstants.Colors.TEXT_SECONDARY
	)
	var value_label = UIUtils.create_label(
		value, UIDesignConstants.FontSizes.NORMAL, UIDesignConstants.Colors.SUCCESS
	)

	# 设置标签宽度
	name_label.custom_minimum_size.x = 80
	value_label.custom_minimum_size.x = 60
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	hbox.add_child(emoji_label)
	hbox.add_child(name_label)
	hbox.add_child(value_label)

	container.add_child(hbox)
	
	# 返回数值标签引用，用于后续更新
	return value_label


func _create_build_option(
	container: VBoxContainer, key: String, emoji: String, name: String, desc: String, cost: int
):
	"""创建建造选项"""
	var hbox = UIUtils.create_hbox_container(UIDesignConstants.Spacing.SM)

	# 快捷键标签
	var key_label = UIUtils.create_label(
		"[" + key + "]", UIDesignConstants.FontSizes.SMALL, UIDesignConstants.Colors.WARNING
	)
	key_label.custom_minimum_size.x = 30

	# emoji和名称
	var emoji_label = UIUtils.create_label(
		emoji, UIDesignConstants.FontSizes.LARGE, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	var name_label = UIUtils.create_label(
		name, UIDesignConstants.FontSizes.NORMAL, UIDesignConstants.Colors.TEXT_PRIMARY
	)

	# 成本标签
	var cost_label = UIUtils.create_label(
		"", UIDesignConstants.FontSizes.SMALL, UIDesignConstants.Colors.WARNING
	)
	if cost > 0:
		cost_label.text = "💰" + str(cost)

	hbox.add_child(key_label)
	hbox.add_child(emoji_label)
	hbox.add_child(name_label)
	hbox.add_child(cost_label)

	container.add_child(hbox)


func _create_status_item(container: VBoxContainer, emoji: String, name: String, value: String):
	"""创建状态项目"""
	var hbox = UIUtils.create_hbox_container(0)

	var emoji_label = UIUtils.create_label(
		emoji, UIDesignConstants.FontSizes.NORMAL, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	var name_label = UIUtils.create_label(
		name, UIDesignConstants.FontSizes.SMALL, UIDesignConstants.Colors.TEXT_SECONDARY
	)
	var value_label = UIUtils.create_label(
		value, UIDesignConstants.FontSizes.SMALL, UIDesignConstants.Colors.TEXT_PRIMARY
	)

	name_label.custom_minimum_size.x = 80
	value_label.custom_minimum_size.x = 120
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	hbox.add_child(emoji_label)
	hbox.add_child(name_label)
	hbox.add_child(value_label)

	container.add_child(hbox)


func _create_info_item(container: VBoxContainer, emoji: String, key: String, desc: String):
	"""创建信息项目"""
	var hbox = UIUtils.create_hbox_container(0)

	var emoji_label = UIUtils.create_label(
		emoji, UIDesignConstants.FontSizes.NORMAL, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	var key_label = UIUtils.create_label(
		key, UIDesignConstants.FontSizes.SMALL, UIDesignConstants.Colors.WARNING
	)
	var desc_label = UIUtils.create_label(
		desc, UIDesignConstants.FontSizes.SMALL, UIDesignConstants.Colors.TEXT_SECONDARY
	)

	key_label.custom_minimum_size.x = 60

	hbox.add_child(emoji_label)
	hbox.add_child(key_label)
	hbox.add_child(desc_label)

	container.add_child(hbox)


# 输入处理
func _setup_input_handling():
	"""设置输入处理"""
	set_process_input(true)


func _input(event: InputEvent):
	"""处理输入事件"""
	if event is InputEventKey and event.pressed:
		_handle_keyboard_input(event)


func _handle_keyboard_input(event: InputEventKey):
	"""处理键盘输入"""
	match event.keycode:
		KEY_1:
			_trigger_build_mode("dig")
			_update_current_mode("挖掘模式")
		KEY_2:
			_trigger_build_mode("build")
			_update_current_mode("建筑面板")
		KEY_4:
			_trigger_build_mode("summon_monster")
			_update_current_mode("召唤怪物")
		KEY_5:
			_trigger_build_mode("summon_logistics")
			_update_current_mode("后勤召唤")
		KEY_ESCAPE:
			_trigger_build_mode("none")
			_update_current_mode("空闲")


# 游戏逻辑接口
func _trigger_build_mode(mode: String):
	"""触发建造模式"""
	if main_game and main_game.has_method("set_build_mode"):
		main_game.set_build_mode(mode)
	LogManager.info("切换到建造模式: " + str(mode))


func _update_current_mode(mode: String):
	"""更新当前模式显示"""
	# 安全检查：确保status_panel有足够的子节点
	if status_panel.get_child_count() < 2:
		return
		
	var status_container = status_panel.get_child(1) # 状态容器（索引1）
	if status_container and status_container.get_child_count() > 3:
		var mode_item = status_container.get_child(3) # 当前模式项目
		if mode_item and mode_item.get_child_count() > 2:
			var value_label = mode_item.get_child(2) # 值标签
			value_label.text = mode


# 更新方法
func update_resource_display(resources: Dictionary):
	"""更新资源显示"""
	var resource_container = resource_panel.get_child(1) # 资源容器
	if not resource_container:
		return

	var resource_items = [
		{"emoji": "💰", "name": "黄金", "key": "gold"},
		{"emoji": "🔮", "name": "法力", "key": "mana"},
		{"emoji": "🍖", "name": "食物", "key": "food"},
		{"emoji": "⚒️", "name": "原始黄金", "key": "raw_gold"},
		{"emoji": "👹", "name": "怪物数量", "key": "monsters"},
		{"emoji": "🏆", "name": "当前分数", "key": "score"}
	]

	for i in range(min(resource_items.size(), resource_container.get_child_count())):
		var item = resource_items[i]
		var container = resource_container.get_child(i)
		if container and container.get_child_count() > 2:
			var value_label = container.get_child(2)
			value_label.text = str(resources.get(item.key, 0))


func update_mouse_position(mouse_pos: Vector2, world_pos: Vector3):
	"""更新鼠标位置显示"""
	var status_container = status_panel.get_child(1) # 状态容器
	if not status_container:
		return

	# 更新鼠标坐标
	if status_container.get_child_count() > 0:
		var mouse_item = status_container.get_child(0)
		if mouse_item and mouse_item.get_child_count() > 2:
			var value_label = mouse_item.get_child(2)
			value_label.text = str(int(mouse_pos.x)) + ", " + str(int(mouse_pos.y))

	# 更新世界坐标
	if status_container.get_child_count() > 1:
		var world_item = status_container.get_child(1)
		if world_item and world_item.get_child_count() > 2:
			var value_label = world_item.get_child(2)
			value_label.text = (
				str(int(world_pos.x)) + ", " + str(int(world_pos.y)) + ", " + str(int(world_pos.z))
			)


func update_camera_position(camera_pos: Vector3):
	"""更新相机位置显示"""
	var status_container = status_panel.get_child(1) # 状态容器
	if not status_container:
		return

	if status_container.get_child_count() > 2:
		var camera_item = status_container.get_child(2)
		if camera_item and camera_item.get_child_count() > 2:
			var value_label = camera_item.get_child(2)
			value_label.text = (
				str(int(camera_pos.x))
				+", "
				+ str(int(camera_pos.y))
				+", "
				+ str(int(camera_pos.z))
			)


# 公共接口
func set_main_game_reference(game: Node):
	"""设置主游戏引用"""
	main_game = game


func toggle_ui_visibility():
	"""切换UI可见性"""
	visible = not visible


func show_ui():
	"""显示UI"""
	visible = true
	
	# 立即更新一次资源显示
	_update_resource_display()


func hide_ui():
	"""隐藏UI"""
	visible = false


func _create_actions_sidebar():
	"""创建右侧操作侧栏(固定在右侧中间)"""
	actions_sidebar = UIUtils.create_panel(Vector2(180, 280), UIDesignConstants.Colors.PANEL)
	actions_sidebar.name = "ActionsSidebar"

	# 右侧中部定位
	actions_sidebar.set_anchors_preset(Control.PRESET_RIGHT_WIDE, true)
	actions_sidebar.offset_right = - ui_config.margin
	actions_sidebar.offset_left = actions_sidebar.offset_right - actions_sidebar.custom_minimum_size.x
	var center_y = get_viewport().size.y * 0.5
	actions_sidebar.offset_top = center_y - actions_sidebar.custom_minimum_size.y * 0.5
	actions_sidebar.offset_bottom = actions_sidebar.offset_top + actions_sidebar.custom_minimum_size.y

	# 标题
	var title = UIUtils.create_label("📐 操作", UIDesignConstants.FontSizes.H3, UIDesignConstants.Colors.TEXT_PRIMARY)
	title.position = Vector2(UIDesignConstants.Spacing.MD, UIDesignConstants.Spacing.MD)
	actions_sidebar.add_child(title)

	# 选项列表
	var list = UIUtils.create_vbox_container(UIDesignConstants.Spacing.SM)
	list.position = Vector2(UIDesignConstants.Spacing.MD, UIDesignConstants.Spacing.XL)
	actions_sidebar.add_child(list)

	_add_action_button(list, "⛏️ 挖掘模式", func(): _on_action_selected("dig"))
	_add_action_button(list, "🏗️ 建筑面板", func(): _on_action_selected("build"))
	_add_action_button(list, "👹 召唤怪物", func(): _on_action_selected("summon_monster"))
	_add_action_button(list, "🎒 后勤召唤", func(): _on_action_selected("summon_logistics"))
	_add_action_button(list, "📘 图鉴", func(): _on_action_selected("bestiary"))

	add_child(actions_sidebar)


func _add_action_button(container: VBoxContainer, text: String, callback: Callable):
	"""加入一个操作按钮"""
	var btn = UIUtils.create_button(text, Vector2(150, 36), callback)
	container.add_child(btn)


func _on_action_selected(action: String):
	"""处理右侧侧栏的选项点击"""
	match action:
		"dig":
			_trigger_build_mode("dig")
			_update_current_mode("挖掘模式")
		"build":
			_trigger_build_mode("build")
			_update_current_mode("建筑面板")
			if main_game and main_game.building_ui:
				main_game.building_ui.toggle_ui()
		"summon_monster":
			_trigger_build_mode("summon_monster")
			_update_current_mode("召唤怪物")
			if main_game and main_game.monster_ui:
				if main_game.monster_ui.has_method("toggle_ui"):
					main_game.monster_ui.call("toggle_ui")
				elif main_game.monster_ui is Control:
					main_game.monster_ui.visible = not main_game.monster_ui.visible
		"summon_logistics":
			_trigger_build_mode("summon_logistics")
			_update_current_mode("后勤召唤")
			if main_game and main_game.logistics_ui:
				main_game.logistics_ui.toggle_ui()
		"bestiary":
			_update_current_mode("图鉴")
			if main_game and main_game.has_method("toggle_bestiary"):
				main_game.toggle_bestiary()
