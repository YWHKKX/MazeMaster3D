extends BaseUI
class_name BuildingSelectionUI

# 建筑选择UI - 参考怪物召唤界面设计
# 参考 BUILDING_SYSTEM.md

# UI配置
var ui_config = {
	"border_radius": 8,
	"panel_width": 1000,
	"panel_height": 700,
	"margin": 30
}

# 建筑类型配置 - 基于BUILDING_SYSTEM.md 和 BuildingManager配置
var building_types = [
	# 基础设施建筑
	{"emoji": "💰", "name": "金库", "cost": 100, "type": "infrastructure", "description": "金币存储", "build_time": 60, "engineer_cost": 50, "level": "⭐⭐", "health": 200, "armor": 5, "entity_id": "building_treasury"},
	{"emoji": "🏠", "name": "巢穴", "cost": 150, "type": "infrastructure", "description": "怪物休息", "build_time": 90, "engineer_cost": 75, "level": "⭐⭐", "health": 250, "armor": 4, "entity_id": "building_lair"},
	{"emoji": "👿", "name": "恶魔巢穴", "cost": 200, "type": "infrastructure", "description": "召唤恶魔", "build_time": 180, "engineer_cost": 100, "level": "⭐⭐⭐⭐", "health": 450, "armor": 6, "entity_id": "building_demon_lair"},
	{"emoji": "🗡️", "name": "兽人巢穴", "cost": 200, "type": "infrastructure", "description": "训练兽人", "build_time": 150, "engineer_cost": 100, "level": "⭐⭐⭐", "health": 500, "armor": 6, "entity_id": "building_orc_lair"},
	
	# 功能性建筑
	{"emoji": "🏋️", "name": "训练室", "cost": 200, "type": "functional", "description": "怪物训练", "build_time": 120, "engineer_cost": 100, "level": "⭐⭐⭐", "health": 300, "armor": 6, "entity_id": "building_training_room"},
	{"emoji": "📚", "name": "图书馆", "cost": 250, "type": "functional", "description": "法力研究", "build_time": 150, "engineer_cost": 125, "level": "⭐⭐⭐", "health": 200, "armor": 5, "entity_id": "building_library"},
	{"emoji": "🔨", "name": "工坊", "cost": 300, "type": "functional", "description": "陷阱制造", "build_time": 180, "engineer_cost": 150, "level": "⭐⭐⭐", "health": 250, "armor": 6, "entity_id": "building_workshop"},
	
	# 军事建筑
	{"emoji": "🏹", "name": "箭塔", "cost": 200, "type": "military", "description": "自动攻击", "build_time": 100, "engineer_cost": 100, "level": "⭐⭐⭐", "health": 800, "armor": 5, "entity_id": "building_arrow_tower"},
	{"emoji": "🔮", "name": "奥术塔", "cost": 200, "type": "military", "description": "魔法攻击", "build_time": 100, "engineer_cost": 100, "level": "⭐⭐⭐", "health": 800, "armor": 5, "entity_id": "building_arcane_tower"},
	{"emoji": "🛡️", "name": "防御工事", "cost": 180, "type": "military", "description": "区域防御", "build_time": 80, "engineer_cost": 90, "level": "⭐⭐", "health": 600, "armor": 8, "entity_id": "building_defense_works"},
	{"emoji": "🔒", "name": "监狱", "cost": 200, "type": "military", "description": "俘虏关押", "build_time": 100, "engineer_cost": 100, "level": "⭐⭐⭐", "health": 400, "armor": 7, "entity_id": "building_prison"},
	{"emoji": "⛓️", "name": "刑房", "cost": 400, "type": "military", "description": "转换加速", "build_time": 200, "engineer_cost": 200, "level": "⭐⭐⭐⭐", "health": 350, "armor": 6, "entity_id": "building_torture_chamber"},
	
	# 魔法建筑
	{"emoji": "⚡", "name": "魔法祭坛", "cost": 120, "type": "magic", "description": "法力生成", "build_time": 160, "engineer_cost": 60, "level": "⭐⭐⭐⭐", "health": 300, "armor": 4, "entity_id": "building_magic_altar"},
	{"emoji": "🕋", "name": "暗影神殿", "cost": 800, "type": "magic", "description": "高级魔法", "build_time": 300, "engineer_cost": 400, "level": "⭐⭐⭐⭐⭐", "health": 500, "armor": 8, "entity_id": "building_shadow_temple"},
	{"emoji": "🧪", "name": "魔法研究院", "cost": 600, "type": "magic", "description": "法术研究", "build_time": 240, "engineer_cost": 300, "level": "⭐⭐⭐⭐", "health": 350, "armor": 6, "entity_id": "building_magic_research_institute"}
]

# Canvas层与容器引用
@onready var canvas_layer: CanvasLayer = CanvasLayer.new()
var root_margin: MarginContainer = null
var building_panel: Control = null
var building_grid: GridContainer = null

# 回调函数
var on_building_selected: Callable = Callable()

func _ready():
	"""初始化建筑选择UI"""
	_build_root_layer()
	_setup_building_ui()

func _build_root_layer():
	"""构建根层结构"""
	# 创建CanvasLayer作为根容器
	canvas_layer.layer = 10
	add_child(canvas_layer)
	
	# 创建MarginContainer作为根容器
	root_margin = MarginContainer.new()
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", ui_config.margin)
	root_margin.add_theme_constant_override("margin_right", ui_config.margin)
	root_margin.add_theme_constant_override("margin_top", ui_config.margin)
	root_margin.add_theme_constant_override("margin_bottom", ui_config.margin)
	canvas_layer.add_child(root_margin)

func _setup_building_ui():
	"""设置建筑UI"""
	# 创建主面板
	building_panel = _create_main_panel()
	root_margin.add_child(building_panel)
	
	# 创建标题
	var title_label = _create_title_label()
	building_panel.add_child(title_label)
	
	# 创建建筑网格
	building_grid = _create_building_grid()
	building_panel.add_child(building_grid)
	
	# 创建关闭按钮
	var close_button = _create_close_button()
	building_panel.add_child(close_button)
	
	# 默认隐藏
	hide_ui()

func _create_main_panel() -> Control:
	"""创建主面板"""
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(ui_config.panel_width, ui_config.panel_height)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	# 设置样式
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	style_box.corner_radius_top_left = ui_config.border_radius
	style_box.corner_radius_top_right = ui_config.border_radius
	style_box.corner_radius_bottom_left = ui_config.border_radius
	style_box.corner_radius_bottom_right = ui_config.border_radius
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.0, 0.5, 1.0)
	
	panel.add_theme_stylebox_override("panel", style_box)
	return panel

func _create_title_label() -> Label:
	"""创建标题标签"""
	var label = Label.new()
	label.text = "🏗️ 建筑建造"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	label.custom_minimum_size = Vector2(0, 60)
	return label

func _create_building_grid() -> GridContainer:
	"""创建建筑网格"""
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 15)
	grid.add_theme_constant_override("v_separation", 15)
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grid.offset_top = 80
	grid.offset_bottom = -60
	
	# 创建建筑卡片
	for building_data in building_types:
		var card = _create_building_card(building_data)
		grid.add_child(card)
	
	return grid

func _create_building_card(building_data: Dictionary) -> Control:
	"""创建建筑卡片"""
	var card = Panel.new()
	card.custom_minimum_size = Vector2(280, 180)
	
	# 卡片样式
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.15, 0.15, 0.15, 0.95)
	card_style.corner_radius_top_left = 6
	card_style.corner_radius_top_right = 6
	card_style.corner_radius_bottom_left = 6
	card_style.corner_radius_bottom_right = 6
	card_style.border_width_left = 1
	card_style.border_width_right = 1
	card_style.border_width_top = 1
	card_style.border_width_bottom = 1
	card_style.border_color = Color(0.3, 0.3, 0.3)
	card.add_theme_stylebox_override("panel", card_style)
	
	# 创建垂直容器
	var vbox = VBoxContainer.new()
	card.add_child(vbox)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("margin_left", 15)
	vbox.add_theme_constant_override("margin_right", 15)
	vbox.add_theme_constant_override("margin_top", 15)
	vbox.add_theme_constant_override("margin_bottom", 15)
	
	# 建筑名称和图标
	var header_hbox = HBoxContainer.new()
	vbox.add_child(header_hbox)
	
	var emoji_label = Label.new()
	emoji_label.text = building_data.emoji
	emoji_label.add_theme_font_size_override("font_size", 24)
	header_hbox.add_child(emoji_label)
	
	var name_label = Label.new()
	name_label.text = building_data.name
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	header_hbox.add_child(name_label)
	
	# 建筑等级
	var level_label = Label.new()
	level_label.text = building_data.level
	level_label.add_theme_font_size_override("font_size", 12)
	level_label.add_theme_color_override("font_color", Color(0.0, 0.5, 1.0))
	header_hbox.add_child(level_label)
	
	# 描述
	var desc_label = Label.new()
	desc_label.text = building_data.description
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(desc_label)
	
	# 建筑类型标签
	var type_label = Label.new()
	type_label.text = "类型: " + building_data.type
	type_label.add_theme_font_size_override("font_size", 12)
	type_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(type_label)
	
	# 成本信息
	var cost_hbox = HBoxContainer.new()
	vbox.add_child(cost_hbox)
	
	var cost_label = Label.new()
	cost_label.text = "💰 " + str(building_data.cost) + "金"
	cost_label.add_theme_font_size_override("font_size", 12)
	cost_label.add_theme_color_override("font_color", Color.GREEN)
	cost_hbox.add_child(cost_label)
	
	var engineer_cost_label = Label.new()
	engineer_cost_label.text = "👷 " + str(building_data.engineer_cost) + "金"
	engineer_cost_label.add_theme_font_size_override("font_size", 12)
	engineer_cost_label.add_theme_color_override("font_color", Color.YELLOW)
	cost_hbox.add_child(engineer_cost_label)
	
	# 建造时间
	var time_label = Label.new()
	time_label.text = "⏱️ " + str(building_data.build_time) + "秒"
	time_label.add_theme_font_size_override("font_size", 12)
	time_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(time_label)
	
	# 生命值和护甲
	var stats_label = Label.new()
	stats_label.text = "❤️ " + str(building_data.health) + " 🛡️ " + str(building_data.armor)
	stats_label.add_theme_font_size_override("font_size", 12)
	stats_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(stats_label)
	
	# 添加点击事件（使用lambda正确传递参数顺序）
	card.gui_input.connect(func(event): _on_building_card_clicked(event, building_data))
	
	# 添加悬停效果
	card.mouse_entered.connect(_on_building_card_hover.bind(card, true))
	card.mouse_exited.connect(_on_building_card_hover.bind(card, false))
	
	return card

func _create_close_button() -> Button:
	"""创建关闭按钮"""
	var button = Button.new()
	button.text = "❌ 关闭"
	button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	button.custom_minimum_size = Vector2(100, 40)
	button.offset_right = -20
	button.offset_bottom = -10
	button.pressed.connect(_on_close_button_pressed)
	return button

func _on_building_card_clicked(event: InputEvent, building_data: Dictionary):
	"""建筑卡片点击事件"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 调用回调函数
		if on_building_selected.is_valid():
			on_building_selected.call(building_data)
		
		# 关闭UI
		hide_ui()

func _on_building_card_hover(card: Control, is_hovered: bool):
	"""建筑卡片悬停效果"""
	var style_box = card.get_theme_stylebox("panel")
	if style_box:
		if is_hovered:
			style_box.border_color = Color(0.0, 0.5, 1.0)
			style_box.border_width_left = 2
			style_box.border_width_right = 2
			style_box.border_width_top = 2
			style_box.border_width_bottom = 2
		else:
			style_box.border_color = Color(0.3, 0.3, 0.3)
			style_box.border_width_left = 1
			style_box.border_width_right = 1
			style_box.border_width_top = 1
			style_box.border_width_bottom = 1

func _on_close_button_pressed():
	"""关闭按钮点击事件"""
	hide_ui()

func _input(event: InputEvent):
	"""处理输入事件"""
	if not canvas_layer.visible:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_4:
			hide_ui()
			get_viewport().set_input_as_handled()

func show_ui():
	"""显示建筑选择UI"""
	canvas_layer.visible = true

func hide_ui():
	"""隐藏建筑选择UI"""
	canvas_layer.visible = false

func toggle_ui():
	"""切换建筑选择UI显示状态"""
	canvas_layer.visible = !canvas_layer.visible

func set_building_selected_callback(callback: Callable):
	"""设置建筑选择回调函数"""
	on_building_selected = callback

# 继承自BaseUI的方法
func set_main_game_reference(_main_game_ref: Node):
	"""设置主游戏引用"""
	# 可以在这里添加需要主游戏引用的逻辑
	pass
