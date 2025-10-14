extends BaseUI
class_name LogisticsSelectionUI

# 后勤召唤UI - 对应STANDALONE.md中的5键后勤召唤
# 参考UI_BEAUTIFICATION.md

# 导入UI工具类
const UIDesignConstants = preload("res://scripts/ui/UIDesignConstants.gd")

# UI配置
var ui_config = {
	"border_radius": 8,
	"panel_width": 800,
	"panel_height": 500,
	"margin": 30
}

# 后勤单位配置
var logistics_types = [
	{
		"emoji": "⛏️",
		"name": "哥布林苦工",
		"cost": 80,
		"type": "worker",
		"description": "自动挖掘金矿",
		"ability": "挖掘"
	},
	{
		"emoji": "🔧",
		"name": "地精工程师",
		"cost": 100,
		"type": "engineer",
		"description": "建造和维护建筑",
		"ability": "建造"
	},
	{
		"emoji": "🕯️",
		"name": "邪教徒",
		"cost": 120,
		"type": "cultist",
		"description": "黑暗仪式与辅助",
		"ability": "仪式"
	},
	{
		"emoji": "🩸",
		"name": "血教徒",
		"cost": 150,
		"type": "blood_cultist",
		"description": "牺牲换取增益",
		"ability": "献祭"
	}
]

# UI引用
var logistics_panel: Control = null
var logistics_grid: GridContainer = null

# 回调函数
var on_logistics_selected: Callable = Callable()


func _ready():
	"""初始化后勤召唤UI"""
	# LogManager.info("LogisticsSelectionUI - 初始化开始")
	_setup_logistics_ui()
	# LogManager.info("LogisticsSelectionUI - 初始化完成")


func _setup_logistics_ui():
	"""设置后勤UI"""
	# 使本UI节点填满视口，确保子面板的锚点基于全屏
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# 初始时隐藏
	visible = false

	# 创建主面板
	_create_main_panel()

	# 设置输入处理
	_setup_input_handling()


func _create_main_panel():
	"""创建主面板 - 右上侧显示以贴近操作区域"""
	logistics_panel = UIUtils.create_panel(Vector2(700, 400), UIDesignConstants.Colors.PANEL)
	logistics_panel.name = "LogisticsPanel"

	# 右上角锚定（与 MonsterSelectionUI 一致风格）
	logistics_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT, true)
	logistics_panel.custom_minimum_size = Vector2(700, 400)
	logistics_panel.offset_right = - UIDesignConstants.Spacing.XXL
	logistics_panel.offset_top = UIDesignConstants.Spacing.XXL
	logistics_panel.offset_left = logistics_panel.offset_right - 700
	logistics_panel.offset_bottom = logistics_panel.offset_top + 400

	# 加入场景树以显示
	add_child(logistics_panel)

	# 创建标题区域
	_create_title_section()

	# 创建后勤网格
	_create_logistics_grid()

	# 创建底部信息
	_create_bottom_section()


func _create_title_section():
	"""创建标题区域"""
	var title_container = UIUtils.create_hbox_container(UIDesignConstants.Spacing.MD)
	title_container.position = Vector2(UIDesignConstants.Spacing.MD, UIDesignConstants.Spacing.MD)
	logistics_panel.add_child(title_container)

	# 标题
	var title = UIUtils.create_label(
		"🎒 后勤召唤", UIDesignConstants.FontSizes.H2, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	title_container.add_child(title)

	# 关闭按钮
	var close_button = UIUtils.create_button(
		"×", Vector2(30, 30), Callable(self, "_on_close_button_pressed")
	)
	title_container.add_child(close_button)


func _create_logistics_grid():
	"""创建后勤网格"""
	logistics_grid = UIUtils.create_grid_container(2, UIDesignConstants.Spacing.LG)
	logistics_grid.position = Vector2(UIDesignConstants.Spacing.MD, 80)
	logistics_grid.custom_minimum_size = Vector2(460, 150)
	logistics_panel.add_child(logistics_grid)

	# 创建后勤选项
	for logistics in logistics_types:
		_create_logistics_option(logistics)


func _create_logistics_option(logistics_data: Dictionary):
	"""创建后勤选项"""
	var option_card = UIUtils.create_panel(Vector2(220, 120), UIDesignConstants.Colors.CARD)
	option_card.custom_minimum_size = Vector2(220, 120)

	# 根据类型设置背景色
	var card_color = UIDesignConstants.Colors.CARD
	match logistics_data.type:
		"worker":
			card_color = Color(
				UIDesignConstants.Colors.CARD.r * 0.8,
				UIDesignConstants.Colors.CARD.g,
				UIDesignConstants.Colors.CARD.b * 0.8
			)
		"engineer":
			card_color = Color(
				UIDesignConstants.Colors.CARD.r * 0.8,
				UIDesignConstants.Colors.CARD.g * 0.8,
				UIDesignConstants.Colors.CARD.b
			)

	# 重新设置背景色
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = card_color
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = UIDesignConstants.Colors.BORDER_LIGHT
	style_box.corner_radius_top_left = ui_config.border_radius
	style_box.corner_radius_top_right = ui_config.border_radius
	style_box.corner_radius_bottom_left = ui_config.border_radius
	style_box.corner_radius_bottom_right = ui_config.border_radius
	option_card.add_theme_stylebox_override("panel", style_box)

	# 创建内容容器
	var content_container = UIUtils.create_vbox_container(UIDesignConstants.Spacing.SM)
	content_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_container.add_theme_constant_override("separation", UIDesignConstants.Spacing.SM)
	option_card.add_child(content_container)

	# 标题行
	var header_container = UIUtils.create_hbox_container(UIDesignConstants.Spacing.MD)
	content_container.add_child(header_container)

	var emoji_label = UIUtils.create_label(
		logistics_data.emoji, UIDesignConstants.FontSizes.H2, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	var name_label = UIUtils.create_label(
		logistics_data.name, UIDesignConstants.FontSizes.H3, UIDesignConstants.Colors.TEXT_PRIMARY
	)

	header_container.add_child(emoji_label)
	header_container.add_child(name_label)

	# 成本和能力行
	var info_container = UIUtils.create_hbox_container(UIDesignConstants.Spacing.MD)
	content_container.add_child(info_container)

	var cost_label = UIUtils.create_label(
		"💰 " + str(logistics_data.cost),
		UIDesignConstants.FontSizes.LARGE,
		UIDesignConstants.Colors.WARNING
	)
	var ability_label = UIUtils.create_label(
		"⚡ " + logistics_data.ability,
		UIDesignConstants.FontSizes.LARGE,
		UIDesignConstants.Colors.SUCCESS
	)

	info_container.add_child(cost_label)
	info_container.add_child(ability_label)

	# 描述
	var desc_label = UIUtils.create_label(
		logistics_data.description,
		UIDesignConstants.FontSizes.NORMAL,
		UIDesignConstants.Colors.TEXT_SECONDARY
	)
	content_container.add_child(desc_label)

	# 添加点击事件
	option_card.gui_input.connect(_on_logistics_option_clicked.bind(logistics_data))

	logistics_grid.add_child(option_card)


func _create_bottom_section():
	"""创建底部信息"""
	var bottom_container = UIUtils.create_hbox_container(UIDesignConstants.Spacing.MD)
	bottom_container.position = Vector2(UIDesignConstants.Spacing.MD, 250)
	logistics_panel.add_child(bottom_container)

	# 提示信息
	var tip_label = UIUtils.create_label(
		"💡 点击单位图标进行召唤，ESC取消",
		UIDesignConstants.FontSizes.SMALL,
		UIDesignConstants.Colors.TEXT_SECONDARY
	)
	bottom_container.add_child(tip_label)

	# 当前资源
	var resource_label = UIUtils.create_label(
		"💰 黄金: 0", UIDesignConstants.FontSizes.SMALL, UIDesignConstants.Colors.INFO
	)
	bottom_container.add_child(resource_label)


# 输入处理
func _setup_input_handling():
	"""设置输入处理"""
	set_process_input(true)


func _input(event: InputEvent):
	"""处理输入事件"""
	if not is_visible:
		return

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				hide_ui()


func _on_logistics_option_clicked(event: InputEvent, logistics_data: Dictionary):
	"""后勤选项被点击"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 触发回调
		if on_logistics_selected.is_valid():
			on_logistics_selected.call(logistics_data)

		# 隐藏UI
		hide_ui()


func _on_close_button_pressed():
	"""关闭按钮被按下"""
	hide_ui()


# 公共接口
func show_ui():
	"""显示后勤召唤UI"""
	if not is_visible:
		visible = true
		is_visible = true
		fade_in()


func hide_ui():
	"""隐藏后勤召唤UI"""
	if is_visible:
		fade_out()
		is_visible = false


func toggle_ui():
	"""切换UI显示"""
	if is_visible:
		hide_ui()
	else:
		show_ui()


func set_logistics_selected_callback(callback: Callable):
	"""设置后勤选择回调"""
	on_logistics_selected = callback


func update_resource_display(gold: int):
	"""更新资源显示"""
	var bottom_container = logistics_panel.get_child(2) # 底部容器
	if bottom_container and bottom_container.get_child_count() > 1:
		var resource_label = bottom_container.get_child(1)
		resource_label.text = "💰 黄金: " + str(gold)
