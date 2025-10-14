extends BaseUI
class_name MonsterSelectionUI

# 怪物选择UI（CanvasLayer + 自动布局容器）
# 导入UI工具类
const UIDesignConstants = preload("res://scripts/ui/UIDesignConstants.gd")

# UI配置
var ui_config = {
	"border_radius": 8,
	"panel_width": 900,
	"panel_height": 600,
	"margin": 30
}

# 怪物类型配置 - 基于CHARACTER_DESIGN.md
var monster_types = [
	# 战斗单位
	{"emoji": "👹", "name": "小恶魔", "cost": 100, "type": "combat", "description": "基础战斗单位", "health": 800, "attack": 15, "armor": 2, "speed": 25, "range": 30, "pursuit": 75},
	{"emoji": "🛡️", "name": "兽人战士", "cost": 120, "type": "combat", "description": "重装战士", "health": 900, "attack": 22, "armor": 4, "speed": 60, "range": 35, "pursuit": 88},
	{"emoji": "🦇", "name": "石像鬼", "cost": 150, "type": "combat", "description": "飞行战士", "health": 1200, "attack": 25, "armor": 6, "speed": 18, "range": 35, "pursuit": 88},
	{"emoji": "🔥", "name": "地狱犬", "cost": 150, "type": "combat", "description": "高速猎手", "health": 1100, "attack": 30, "armor": 3, "speed": 35, "range": 25, "pursuit": 63},
	{"emoji": "🦎", "name": "火蜥蜴", "cost": 200, "type": "combat", "description": "远程火力", "health": 1000, "attack": 28, "armor": 3, "speed": 22, "range": 85, "pursuit": 85},
	{"emoji": "🌳", "name": "树人守护者", "cost": 200, "type": "combat", "description": "防守专家", "health": 2000, "attack": 35, "armor": 10, "speed": 10, "range": 40, "pursuit": 100},
	{"emoji": "👻", "name": "魅魔", "cost": 200, "type": "combat", "description": "心智控制", "health": 1500, "attack": 32, "armor": 5, "speed": 22, "range": 70, "pursuit": 70},
	{"emoji": "👑", "name": "暗影领主", "cost": 400, "type": "combat", "description": "全能战士", "health": 3200, "attack": 55, "armor": 12, "speed": 25, "range": 60, "pursuit": 60},
	{"emoji": "🗿", "name": "石魔像", "cost": 400, "type": "combat", "description": "无敌坦克", "health": 4500, "attack": 45, "armor": 25, "speed": 8, "range": 40, "pursuit": 100},
	{"emoji": "🐲", "name": "骨龙", "cost": 600, "type": "combat", "description": "终极武器", "health": 4000, "attack": 60, "armor": 18, "speed": 30, "range": 50, "pursuit": 125},
	# 魔法单位
	{"emoji": "🔮", "name": "暗影法师", "cost": 150, "type": "magic", "description": "魔法攻击", "health": 900, "attack": 22, "armor": 2, "speed": 18, "range": 100, "pursuit": 100}
]

# Canvas层与容器引用
@onready var canvas_layer: CanvasLayer = CanvasLayer.new()
var root_margin: MarginContainer = null
var monster_panel: Control = null
var monster_grid: GridContainer = null

# 回调函数
var on_monster_selected: Callable = Callable()


func _ready():
	"""初始化怪物选择UI（创建CanvasLayer与容器结构）"""
	_build_root_layer()
	_setup_monster_ui()


func _setup_monster_ui():
	"""设置怪物UI"""
	# 初始时隐藏
	canvas_layer.visible = false

	# 创建主面板
	_create_main_panel()

	# 设置输入处理
	_setup_input_handling()


func _create_main_panel():
	"""创建主面板（居中对齐和响应式）"""
	monster_panel = UIUtils.create_panel(Vector2(ui_config.panel_width, ui_config.panel_height), UIDesignConstants.Colors.PANEL)
	monster_panel.name = "MonsterPanel"

	# 右侧靠近操作侧栏显示：固定在右侧上方
	monster_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT, true)
	monster_panel.custom_minimum_size = Vector2(ui_config.panel_width, ui_config.panel_height)
	monster_panel.offset_right = - UIDesignConstants.Spacing.XXL
	monster_panel.offset_top = UIDesignConstants.Spacing.XXL
	monster_panel.offset_left = monster_panel.offset_right - ui_config.panel_width
	monster_panel.offset_bottom = monster_panel.offset_top + ui_config.panel_height

	# 创建标题区域
	_create_title_section()

	# 创建怪物网格
	_create_monster_grid()

	# 创建底部信息
	_create_bottom_section()


func _create_title_section():
	"""创建标题区域"""
	var title_container = UIUtils.create_hbox_container(UIDesignConstants.Spacing.MD)
	title_container.position = Vector2(UIDesignConstants.Spacing.MD, UIDesignConstants.Spacing.MD)
	monster_panel.add_child(title_container)

	# 标题
	var title = UIUtils.create_label(
		"👹 怪物召唤", UIDesignConstants.FontSizes.H2, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	title_container.add_child(title)

	# 关闭按钮
	var close_button = UIUtils.create_button(
		"×", Vector2(30, 30), Callable(self, "_on_close_button_pressed")
	)
	title_container.add_child(close_button)


func _create_monster_grid():
	"""创建怪物网格"""
	monster_grid = UIUtils.create_grid_container(4, UIDesignConstants.Spacing.SM)
	monster_grid.position = Vector2(UIDesignConstants.Spacing.MD, 80)
	monster_grid.custom_minimum_size = Vector2(720, 420)
	monster_panel.add_child(monster_grid)

	# 创建怪物选项
	for monster in monster_types:
		_create_monster_option(monster)


func _create_monster_option(monster_data: Dictionary):
	"""创建怪物选项"""
	var option_card = UIUtils.create_panel(Vector2(180, 140), UIDesignConstants.Colors.CARD)
	option_card.custom_minimum_size = Vector2(180, 140)

	# 根据怪物类型设置不同的背景色
	var card_color = UIDesignConstants.Colors.CARD
	match monster_data.type:
		"combat":
			card_color = Color(
				UIDesignConstants.Colors.CARD.r,
				UIDesignConstants.Colors.CARD.g * 0.8,
				UIDesignConstants.Colors.CARD.b * 0.8
			)
		"magic":
			card_color = Color(
				UIDesignConstants.Colors.CARD.r,
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
	var content_container = UIUtils.create_vbox_container(UIDesignConstants.Spacing.XS)
	content_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_container.add_theme_constant_override("separation", UIDesignConstants.Spacing.XS)
	option_card.add_child(content_container)

	# 标题行 - emoji和名称
	var header_container = UIUtils.create_hbox_container(UIDesignConstants.Spacing.SM)
	content_container.add_child(header_container)

	var emoji_label = UIUtils.create_label(
		monster_data.emoji, UIDesignConstants.FontSizes.H2, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	var name_label = UIUtils.create_label(
		monster_data.name, UIDesignConstants.FontSizes.NORMAL, UIDesignConstants.Colors.TEXT_PRIMARY
	)

	header_container.add_child(emoji_label)
	header_container.add_child(name_label)

	# 成本
	var cost_label = UIUtils.create_label(
		"💰 " + str(monster_data.cost),
		UIDesignConstants.FontSizes.SMALL,
		UIDesignConstants.Colors.WARNING
	)
	content_container.add_child(cost_label)

	# 属性行
	var stats_container = UIUtils.create_hbox_container(UIDesignConstants.Spacing.XS)
	content_container.add_child(stats_container)

	# 生命值
	var health_label = UIUtils.create_label(
		"❤️ " + str(monster_data.health),
		UIDesignConstants.FontSizes.SMALL,
		UIDesignConstants.Colors.ERROR
	)
	# 攻击力
	var attack_label = UIUtils.create_label(
		"⚔️ " + str(monster_data.attack),
		UIDesignConstants.FontSizes.SMALL,
		UIDesignConstants.Colors.ERROR
	)
	# 护甲
	var armor_label = UIUtils.create_label(
		"🛡️ " + str(monster_data.armor),
		UIDesignConstants.FontSizes.SMALL,
		UIDesignConstants.Colors.INFO
	)

	stats_container.add_child(health_label)
	stats_container.add_child(attack_label)
	stats_container.add_child(armor_label)

	# 描述
	var desc_label = UIUtils.create_label(
		monster_data.description,
		UIDesignConstants.FontSizes.SMALL,
		UIDesignConstants.Colors.TEXT_SECONDARY
	)
	content_container.add_child(desc_label)

	# 添加点击事件（Godot 4: 在event 后绑定的数据）
	option_card.gui_input.connect(_on_monster_option_clicked.bind(monster_data))

	monster_grid.add_child(option_card)


func _create_bottom_section():
	"""创建底部信息"""
	var bottom_container = UIUtils.create_hbox_container(UIDesignConstants.Spacing.MD)
	bottom_container.position = Vector2(UIDesignConstants.Spacing.MD, 520)
	monster_panel.add_child(bottom_container)

	# 将面板加入根容器
	if root_margin:
		root_margin.add_child(monster_panel)

	# 提示信息
	var tip_label = UIUtils.create_label(
		"💡 点击怪物图标进行召唤，ESC取消",
		UIDesignConstants.FontSizes.SMALL,
		UIDesignConstants.Colors.TEXT_SECONDARY
	)
	bottom_container.add_child(tip_label)

	# 当前法力值
	var mana_label = UIUtils.create_label(
		"🔮 法力: 0", UIDesignConstants.FontSizes.SMALL, UIDesignConstants.Colors.INFO
	)
	bottom_container.add_child(mana_label)


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


func _on_monster_option_clicked(event: InputEvent, monster_data: Dictionary):
	"""怪物选项被点击"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		LogManager.info("选择怪物: " + str(monster_data.name))

		# 触发回调
		if on_monster_selected.is_valid():
			on_monster_selected.call(monster_data)

		# 隐藏UI
		hide_ui()


func _on_close_button_pressed():
	"""关闭按钮被按下"""
	hide_ui()


# 公共接口
func show_ui():
	"""显示怪物选择UI"""
	if canvas_layer and not canvas_layer.visible:
		canvas_layer.visible = true
		is_visible = true
		fade_in()


func hide_ui():
	"""隐藏怪物选择UI"""
	if canvas_layer and canvas_layer.visible:
		fade_out()
		is_visible = false
		canvas_layer.visible = false


func toggle_ui():
	"""切换UI显示"""
	if canvas_layer and canvas_layer.visible:
		hide_ui()
	else:
		show_ui()


func set_monster_selected_callback(callback: Callable):
	"""设置怪物选择回调"""
	on_monster_selected = callback


func update_mana_display(mana: int):
	"""更新法力显示"""
	var bottom_container = monster_panel.get_child(2) # 底部容器
	if bottom_container and bottom_container.get_child_count() > 1:
		var mana_label = bottom_container.get_child(1)
		mana_label.text = "🔮 法力: " + str(mana)


# ---- 私有：根层与容器 ----
func _build_root_layer():
	"""创建CanvasLayer + MarginContainer根结构，自动布局并与3D世界解耦"""
	if not canvas_layer.get_parent():
		add_child(canvas_layer)

	# MarginContainer 负责与屏幕边缘留白
	root_margin = MarginContainer.new()
	root_margin.name = "MonsterUIRoot"
	root_margin.add_theme_constant_override("margin_left", ui_config.margin)
	root_margin.add_theme_constant_override("margin_top", ui_config.margin)
	root_margin.add_theme_constant_override("margin_right", ui_config.margin)
	root_margin.add_theme_constant_override("margin_bottom", ui_config.margin)

	# 全屏锚定，响应式适配
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	canvas_layer.add_child(root_margin)
