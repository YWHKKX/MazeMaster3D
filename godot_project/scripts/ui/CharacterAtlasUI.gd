extends BaseUI
class_name CharacterAtlasUI

## 角色图鉴UI - 书本样式设计
## 左页：怪物图鉴（防御方）
## 右页：英雄图鉴（入侵方）
## 支持翻页浏览

# UI配置（使用屏幕相对尺寸）
var ui_config = {
	"book_width_ratio": 0.9, # 屏幕宽度的90%
	"book_height_ratio": 0.85, # 屏幕高度的85%
	"page_margin": 30,
	"border_radius": 12
}

# 怪物数据配置（带图片路径）
var monsters_data = [
	{"name": "哥布林苦工", "image": "res://img/Monster/哥布林苦工.png", "cost": "80魔", "level": "⭐", "health": 600, "attack": 8, "armor": 0, "speed": 20, "special": "挖掘", "desc": "经济基础"},
	{"name": "地精工程师", "image": "res://img/Monster/地精工程师.png", "cost": "100魔", "level": "⭐⭐", "health": 800, "attack": 12, "armor": 2, "speed": 18, "special": "建造", "desc": "建造专家"},
	{"name": "小恶魔", "image": "res://img/Monster/小恶魔.png", "cost": "100魔", "level": "⭐⭐", "health": 800, "attack": 15, "armor": 2, "speed": 25, "special": "无", "desc": "基础战斗"},
	{"name": "兽人战士", "image": "res://img/Monster/兽人战士.png", "cost": "120魔", "level": "⭐⭐", "health": 900, "attack": 22, "armor": 4, "speed": 60, "special": "狂暴", "desc": "狂暴战士"},
	{"name": "石像鬼", "image": "res://img/Monster/石像鬼.png", "cost": "150魔", "level": "⭐⭐⭐", "health": 1200, "attack": 25, "armor": 6, "speed": 18, "special": "重击", "desc": "重装战士"},
	{"name": "暗影法师", "image": "res://img/Monster/暗影法师.png", "cost": "150魔", "level": "⭐⭐⭐", "health": 900, "attack": 22, "armor": 2, "speed": 18, "special": "穿透", "desc": "魔法攻击"},
	{"name": "地狱犬", "image": "res://img/Monster/地狱犬.png", "cost": "150魔", "level": "⭐⭐⭐", "health": 1100, "attack": 30, "armor": 3, "speed": 35, "special": "火焰", "desc": "高速猎手"},
	{"name": "火蜥蜴", "image": "res://img/Monster/火蜥蜴.png", "cost": "200魔", "level": "⭐⭐⭐", "health": 1000, "attack": 28, "armor": 3, "speed": 22, "special": "溅射", "desc": "远程火力"},
	{"name": "树人守护者", "image": "res://img/Monster/树人守护者.png", "cost": "200魔", "level": "⭐⭐⭐⭐", "health": 2000, "attack": 35, "armor": 10, "speed": 10, "special": "缠绕", "desc": "防守专家"},
	{"name": "魅魔", "image": "res://img/Monster/魅魔.png", "cost": "200魔", "level": "⭐⭐⭐⭐", "health": 1500, "attack": 32, "armor": 5, "speed": 22, "special": "魅惑", "desc": "心智控制"},
	{"name": "暗影领主", "image": "res://img/Monster/暗影领主.png", "cost": "400魔", "level": "⭐⭐⭐⭐⭐", "health": 3200, "attack": 55, "armor": 12, "speed": 25, "special": "形态切换", "desc": "全能战士"},
	{"name": "石魔像", "image": "res://img/Monster/石魔像.png", "cost": "400魔", "level": "⭐⭐⭐⭐⭐", "health": 4500, "attack": 45, "armor": 25, "speed": 8, "special": "岩石护盾", "desc": "无敌坦克"},
	{"name": "骨龙", "image": "res://img/Monster/骨龙.png", "cost": "600魔", "level": "⭐⭐⭐⭐⭐", "health": 4000, "attack": 60, "armor": 18, "speed": 30, "special": "骨刺风暴", "desc": "终极武器"}
]

# 英雄数据配置（带图片路径和性别）
var heroes_data = [
	{"name": "骑士", "image_male": "res://img/Hero/骑士_男.png", "image_female": "res://img/Hero/骑士_女.png", "level": "⭐⭐", "health": 900, "attack": 18, "armor": 5, "speed": 20, "range": 35, "special": "无", "desc": "平衡战士"},
	{"name": "弓箭手", "image_male": "res://img/Hero/弓箭手_男.png", "image_female": "res://img/Hero/弓箭手_女.png", "level": "⭐⭐", "health": 700, "attack": 16, "armor": 2, "speed": 25, "range": 120, "special": "精准射击", "desc": "远程输出"},
	{"name": "法师", "image_male": "res://img/Hero/法师_男.png", "image_female": "res://img/Hero/法师_女.png", "level": "⭐⭐", "health": 500, "attack": 22, "armor": 1, "speed": 18, "range": 100, "special": "火球术", "desc": "高伤法师"},
	{"name": "牧师", "image_male": "res://img/Hero/牧师_男.png", "image_female": "res://img/Hero/牧师_女.png", "level": "⭐⭐", "health": 800, "attack": 10, "armor": 3, "speed": 18, "range": 80, "special": "治疗术", "desc": "辅助治疗"},
	{"name": "盗贼", "image_male": "res://img/Hero/盗贼_男.png", "image_female": "res://img/Hero/盗贼_女.png", "level": "⭐⭐", "health": 600, "attack": 28, "armor": 1, "speed": 40, "range": 25, "special": "偷窃", "desc": "快速击杀"},
	{"name": "圣骑士", "image_male": "res://img/Hero/圣骑士_男.png", "image_female": "res://img/Hero/圣骑士_女.png", "level": "⭐⭐⭐", "health": 1600, "attack": 28, "armor": 10, "speed": 15, "range": 40, "special": "神圣光环", "desc": "坦克角色"},
	{"name": "刺客", "image_male": "res://img/Hero/刺客_男.png", "image_female": "res://img/Hero/刺客_女.png", "level": "⭐⭐⭐", "health": 900, "attack": 38, "armor": 3, "speed": 35, "range": 25, "special": "暗杀", "desc": "极高攻击"},
	{"name": "游侠", "image_male": "res://img/Hero/游侠_男.png", "image_female": "res://img/Hero/游侠_女.png", "level": "⭐⭐⭐", "health": 1000, "attack": 25, "armor": 4, "speed": 22, "range": 150, "special": "追踪箭", "desc": "超远射程"},
	{"name": "大法师", "image_male": "res://img/Hero/大法师_男.png", "image_female": "res://img/Hero/大法师_女.png", "level": "⭐⭐⭐", "health": 800, "attack": 35, "armor": 2, "speed": 16, "range": 120, "special": "连锁闪电", "desc": "范围魔法"},
	{"name": "德鲁伊", "image_male": "res://img/Hero/德鲁伊_男.png", "image_female": "res://img/Hero/德鲁伊_女.png", "level": "⭐⭐⭐", "health": 1300, "attack": 22, "armor": 6, "speed": 20, "range": 80, "special": "自然形态", "desc": "自然魔法"},
	{"name": "狂战士", "image_male": "res://img/Hero/狂战士_男.png", "image_female": "res://img/Hero/狂战士_女.png", "level": "⭐⭐⭐", "health": 1200, "attack": 42, "armor": 3, "speed": 28, "range": 30, "special": "狂暴", "desc": "正面冲锋"},
	{"name": "工程师", "image_male": "res://img/Hero/工程师_男.png", "image_female": "res://img/Hero/工程师_女.png", "level": "⭐⭐⭐", "health": 1100, "attack": 20, "armor": 6, "speed": 15, "range": 60, "special": "建造炮台", "desc": "防守专家"},
	{"name": "龙骑士", "image_male": "res://img/Hero/龙骑士_男.png", "image_female": "res://img/Hero/龙骑士_女.png", "level": "⭐⭐⭐⭐", "health": 2200, "attack": 48, "armor": 12, "speed": 25, "range": 45, "special": "龙息", "desc": "全能战士"},
	{"name": "暗影剑圣", "image_male": "res://img/Hero/暗影剑圣_男.png", "image_female": "res://img/Hero/暗影剑圣_女.png", "level": "⭐⭐⭐⭐⭐", "health": 1400, "attack": 58, "armor": 8, "speed": 30, "range": 35, "special": "暗影步", "desc": "最高攻击"}
]

# UI节点引用
@onready var canvas_layer: CanvasLayer = CanvasLayer.new()
var book_panel: Panel = null
var left_page: Panel = null # 怪物页
var right_page: Panel = null # 英雄页
var monster_scroll: ScrollContainer = null
var hero_scroll: ScrollContainer = null
var page_number_label: Label = null

# 翻页状态
var current_monster_page: int = 0
var current_hero_page: int = 0
var monsters_per_page: int = 6 # 从4增加到6
var heroes_per_page: int = 6 # 从4增加到6

# 性别显示状态（按英雄索引存储，true=女性，false=男性）
var hero_gender_state: Dictionary = {}

func _ready():
	"""初始化角色图鉴UI"""
	_build_book_ui()
	hide_ui()

func _build_book_ui():
	"""构建书本样式UI"""
	# 创建CanvasLayer
	canvas_layer.layer = 15 # 高层级，确保在最上层
	add_child(canvas_layer)
	
	# 创建书本主面板
	book_panel = _create_book_panel()
	canvas_layer.add_child(book_panel)
	
	# 创建左页（怪物）
	left_page = _create_left_page()
	book_panel.add_child(left_page)
	
	# 创建右页（英雄）
	right_page = _create_right_page()
	book_panel.add_child(right_page)
	
	# 创建控制按钮
	_create_control_buttons()

func _create_book_panel() -> Panel:
	"""创建书本主面板"""
	var panel = Panel.new()
	
	# 根据屏幕尺寸计算书本大小
	var screen_size = get_viewport().get_visible_rect().size
	var book_width = screen_size.x * ui_config.book_width_ratio
	var book_height = screen_size.y * ui_config.book_height_ratio
	
	# 使用锚点居中（更精确）
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.position = Vector2(-book_width / 2, -book_height / 2)
	panel.size = Vector2(book_width, book_height)
	
	# 书本背景样式（复古羊皮纸色）
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.95, 0.9, 0.8, 0.98) # 羊皮纸色
	style.corner_radius_top_left = ui_config.border_radius
	style.corner_radius_top_right = ui_config.border_radius
	style.corner_radius_bottom_left = ui_config.border_radius
	style.corner_radius_bottom_right = ui_config.border_radius
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.4, 0.3, 0.2) # 棕色边框
	style.shadow_size = 8
	style.shadow_color = Color(0, 0, 0, 0.5)
	panel.add_theme_stylebox_override("panel", style)
	
	return panel

func _create_left_page() -> Panel:
	"""创建左页（怪物图鉴）"""
	# 计算尺寸（一次性）
	var screen_size = get_viewport().get_visible_rect().size
	var book_width = screen_size.x * ui_config.book_width_ratio
	var book_height = screen_size.y * ui_config.book_height_ratio
	var page_width = (book_width - ui_config.page_margin * 3 - 10) / 2
	
	var page = Panel.new()
	page.custom_minimum_size = Vector2(page_width, book_height - 60)
	page.position = Vector2(ui_config.page_margin, 30)
	
	# 左页样式
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.98, 0.95, 0.88, 1.0)
	style.corner_radius_top_left = 8
	style.corner_radius_bottom_left = 8
	style.border_width_right = 2
	style.border_color = Color(0.6, 0.5, 0.4, 0.5) # 中缝线
	page.add_theme_stylebox_override("panel", style)
	
	# 创建垂直容器
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	page.add_child(vbox)
	
	# 标题
	var title = Label.new()
	title.text = "📖 怪物图鉴"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.3, 0.1, 0.1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# 分隔线
	var separator = HSeparator.new()
	separator.add_theme_constant_override("separation", 3)
	vbox.add_child(separator)
	
	# 滚动容器（使用前面计算的尺寸）
	var scroll_height = book_height - 200
	monster_scroll = ScrollContainer.new()
	monster_scroll.custom_minimum_size = Vector2(0, scroll_height)
	monster_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	monster_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(monster_scroll)
	
	# 怪物列表容器
	var monster_list = VBoxContainer.new()
	monster_list.add_theme_constant_override("separation", 8) # 从15缩小到8
	monster_scroll.add_child(monster_list)
	
	# 填充当前页的怪物
	_populate_monster_page(monster_list)
	
	# 翻页按钮
	var nav_hbox = HBoxContainer.new()
	nav_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(nav_hbox)
	
	var prev_btn = Button.new()
	prev_btn.text = "◀ 上一页"
	prev_btn.pressed.connect(_on_monster_prev_page)
	nav_hbox.add_child(prev_btn)
	
	var page_label = Label.new()
	page_label.text = "第 1 页"
	page_label.custom_minimum_size = Vector2(100, 0)
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_label.add_theme_color_override("font_color", Color(0.3, 0.1, 0.1))
	page_label.name = "MonsterPageLabel"
	nav_hbox.add_child(page_label)
	
	var next_btn = Button.new()
	next_btn.text = "下一页 ▶"
	next_btn.pressed.connect(_on_monster_next_page)
	nav_hbox.add_child(next_btn)
	
	return page

func _create_right_page() -> Panel:
	"""创建右页（英雄图鉴）"""
	# 计算尺寸（一次性）
	var screen_size = get_viewport().get_visible_rect().size
	var book_width = screen_size.x * ui_config.book_width_ratio
	var book_height = screen_size.y * ui_config.book_height_ratio
	var page_width = (book_width - ui_config.page_margin * 3 - 10) / 2
	var scroll_height = book_height - 200
	
	var page = Panel.new()
	
	page.custom_minimum_size = Vector2(page_width, book_height - 60)
	page.position = Vector2(page_width + ui_config.page_margin + 10, 30)
	
	# 右页样式
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.98, 0.95, 0.88, 1.0)
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	page.add_theme_stylebox_override("panel", style)
	
	# 创建垂直容器
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	page.add_child(vbox)
	
	# 标题
	var title = Label.new()
	title.text = "⚔️ 英雄图鉴"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.1, 0.1, 0.3))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# 分隔线
	var separator = HSeparator.new()
	separator.add_theme_constant_override("separation", 3)
	vbox.add_child(separator)
	
	# 滚动容器（使用前面计算的尺寸）
	hero_scroll = ScrollContainer.new()
	hero_scroll.custom_minimum_size = Vector2(0, scroll_height)
	hero_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	hero_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(hero_scroll)
	
	# 英雄列表容器
	var hero_list = VBoxContainer.new()
	hero_list.add_theme_constant_override("separation", 8) # 从15缩小到8
	hero_scroll.add_child(hero_list)
	
	# 填充当前页的英雄
	_populate_hero_page(hero_list)
	
	# 翻页按钮
	var nav_hbox = HBoxContainer.new()
	nav_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(nav_hbox)
	
	var prev_btn = Button.new()
	prev_btn.text = "◀ 上一页"
	prev_btn.pressed.connect(_on_hero_prev_page)
	nav_hbox.add_child(prev_btn)
	
	var page_label = Label.new()
	page_label.text = "第 1 页"
	page_label.custom_minimum_size = Vector2(100, 0)
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.3))
	page_label.name = "HeroPageLabel"
	nav_hbox.add_child(page_label)
	
	var next_btn = Button.new()
	next_btn.text = "下一页 ▶"
	next_btn.pressed.connect(_on_hero_next_page)
	nav_hbox.add_child(next_btn)
	
	return page

func _populate_monster_page(container: VBoxContainer):
	"""填充怪物页"""
	# 清空容器
	for child in container.get_children():
		child.queue_free()
	
	# 计算当前页的数据范围
	var start_idx = current_monster_page * monsters_per_page
	var end_idx = min(start_idx + monsters_per_page, monsters_data.size())
	
	# 添加怪物卡片
	for i in range(start_idx, end_idx):
		var monster = monsters_data[i]
		var card = _create_monster_card(monster)
		container.add_child(card)

func _populate_hero_page(container: VBoxContainer):
	"""填充英雄页"""
	# 清空容器
	for child in container.get_children():
		child.queue_free()
	
	# 计算当前页的数据范围
	var start_idx = current_hero_page * heroes_per_page
	var end_idx = min(start_idx + heroes_per_page, heroes_data.size())
	
	# 添加英雄卡片
	for i in range(start_idx, end_idx):
		var hero = heroes_data[i]
		var card = _create_hero_card(hero)
		container.add_child(card)

func _create_monster_card(data: Dictionary) -> Panel:
	"""创建怪物卡片"""
	var card = Panel.new()
	card.custom_minimum_size = Vector2(550, 120) # 从600x180缩小到550x120
	
	# 卡片样式（浅色背景）
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.92, 0.88, 0.8, 0.9)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.5, 0.4, 0.3)
	card.add_theme_stylebox_override("panel", style)
	
	# 水平布局
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 10) # 从15缩小到10
	card.add_child(hbox)
	
	# 图片
	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(100, 100) # 从150x150缩小到100x100
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(data.image):
		texture_rect.texture = load(data.image)
	hbox.add_child(texture_rect)
	
	# 信息区域
	var info_vbox = VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 3) # 从5缩小到3
	hbox.add_child(info_vbox)
	
	# 名称和等级
	var name_hbox = HBoxContainer.new()
	info_vbox.add_child(name_hbox)
	
	var name_label = Label.new()
	name_label.text = data.name
	name_label.add_theme_font_size_override("font_size", 16) # 从20缩小到16
	name_label.add_theme_color_override("font_color", Color(0.2, 0.0, 0.0))
	name_hbox.add_child(name_label)
	
	var level_label = Label.new()
	level_label.text = data.level
	level_label.add_theme_font_size_override("font_size", 13) # 从16缩小到13
	level_label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.0))
	name_hbox.add_child(level_label)
	
	# 成本
	var cost_label = Label.new()
	cost_label.text = "💰 " + data.cost
	cost_label.add_theme_font_size_override("font_size", 12) # 从14缩小到12
	cost_label.add_theme_color_override("font_color", Color(0.4, 0.2, 0.0))
	info_vbox.add_child(cost_label)
	
	# 属性
	_add_stat_line(info_vbox, "❤️ 生命: " + str(data.health) + "  ⚔️ 攻击: " + str(data.attack))
	_add_stat_line(info_vbox, "🛡️ 护甲: " + str(data.armor) + "  ⚡ 速度: " + str(data.speed))
	_add_stat_line(info_vbox, "✨ 特殊: " + data.special)
	
	# 描述
	var desc_label = Label.new()
	desc_label.text = data.desc
	desc_label.add_theme_font_size_override("font_size", 10) # 从12缩小到10
	desc_label.add_theme_color_override("font_color", Color(0.3, 0.2, 0.1))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(400, 0)
	info_vbox.add_child(desc_label)
	
	return card

func _create_hero_card(data: Dictionary) -> Panel:
	"""创建英雄卡片"""
	var card = Panel.new()
	card.custom_minimum_size = Vector2(550, 120) # 从600x180缩小到550x120
	
	# 卡片样式（蓝色调）
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.88, 0.9, 0.95, 0.9)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.3, 0.4, 0.6)
	card.add_theme_stylebox_override("panel", style)
	
	# 水平布局
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 10) # 从15缩小到10
	card.add_child(hbox)
	
	# 图片（可点击切换性别）
	var texture_btn = TextureButton.new()
	texture_btn.custom_minimum_size = Vector2(100, 100) # 从150x150缩小到100x100
	texture_btn.ignore_texture_size = true
	texture_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	# 确定显示哪个性别
	var hero_index = heroes_data.find(data)
	var show_female = hero_gender_state.get(hero_index, false)
	var image_path = data.image_female if show_female else data.image_male
	
	# 加载图片
	if ResourceLoader.exists(image_path):
		var texture = load(image_path)
		texture_btn.texture_normal = texture
		texture_btn.texture_hover = texture
		texture_btn.texture_pressed = texture
	
	# 点击切换性别
	texture_btn.pressed.connect(_on_hero_gender_toggle.bind(hero_index))
	
	hbox.add_child(texture_btn)
	
	# 信息区域
	var info_vbox = VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 3) # 从5缩小到3
	hbox.add_child(info_vbox)
	
	# 名称和等级
	var name_hbox = HBoxContainer.new()
	info_vbox.add_child(name_hbox)
	
	var name_label = Label.new()
	name_label.text = data.name
	name_label.add_theme_font_size_override("font_size", 16) # 从20缩小到16
	name_label.add_theme_color_override("font_color", Color(0.0, 0.0, 0.3))
	name_hbox.add_child(name_label)
	
	var level_label = Label.new()
	level_label.text = data.level
	level_label.add_theme_font_size_override("font_size", 13) # 从16缩小到13
	level_label.add_theme_color_override("font_color", Color(0.8, 0.0, 0.0))
	name_hbox.add_child(level_label)
	
	# 属性（合并到一行）
	_add_stat_line(info_vbox, "❤️" + str(data.health) + " ⚔️" + str(data.attack) + " 🛡️" + str(data.armor) + " ⚡" + str(data.speed) + " 🎯" + str(data.range), Color(0.1, 0.1, 0.3))
	_add_stat_line(info_vbox, "✨ " + data.special + " | " + data.desc, Color(0.1, 0.1, 0.3))
	
	return card

func _add_stat_line(container: VBoxContainer, text: String, color: Color = Color(0.3, 0.2, 0.1)):
	"""添加属性行"""
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 11) # 从14缩小到11
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(420, 0)
	container.add_child(label)

func _create_control_buttons():
	"""创建控制按钮"""
	# 计算书本尺寸
	var screen_size = get_viewport().get_visible_rect().size
	var book_width = screen_size.x * ui_config.book_width_ratio
	
	# 关闭按钮（右上角）
	var close_btn = Button.new()
	close_btn.text = "✖"
	close_btn.custom_minimum_size = Vector2(40, 40)
	close_btn.position = Vector2(book_width - 60, 10)
	close_btn.pressed.connect(hide_ui)
	
	# 按钮样式
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.8, 0.3, 0.3, 0.9)
	btn_style.corner_radius_top_left = 4
	btn_style.corner_radius_top_right = 4
	btn_style.corner_radius_bottom_left = 4
	btn_style.corner_radius_bottom_right = 4
	close_btn.add_theme_stylebox_override("normal", btn_style)
	
	book_panel.add_child(close_btn)

# ==================== 翻页功能 ====================

func _on_monster_prev_page():
	"""怪物上一页"""
	if current_monster_page > 0:
		current_monster_page -= 1
		_refresh_monster_page()

func _on_monster_next_page():
	"""怪物下一页"""
	var max_pages = ceil(float(monsters_data.size()) / monsters_per_page)
	if current_monster_page < max_pages - 1:
		current_monster_page += 1
		_refresh_monster_page()

func _on_hero_prev_page():
	"""英雄上一页"""
	if current_hero_page > 0:
		current_hero_page -= 1
		_refresh_hero_page()

func _on_hero_next_page():
	"""英雄下一页"""
	var max_pages = ceil(float(heroes_data.size()) / heroes_per_page)
	if current_hero_page < max_pages - 1:
		current_hero_page += 1
		_refresh_hero_page()

func _refresh_monster_page():
	"""刷新怪物页"""
	if monster_scroll and monster_scroll.get_child_count() > 0:
		var monster_list = monster_scroll.get_child(0)
		_populate_monster_page(monster_list)
		
		# 更新页码
		var nav_box = left_page.get_child(0).get_child(3)
		if nav_box and nav_box.get_child_count() > 1:
			var page_label = nav_box.get_child(1)
			page_label.text = "第 %d 页" % (current_monster_page + 1)

func _refresh_hero_page():
	"""刷新英雄页"""
	if hero_scroll and hero_scroll.get_child_count() > 0:
		var hero_list = hero_scroll.get_child(0)
		_populate_hero_page(hero_list)
		
		# 更新页码
		var nav_box = right_page.get_child(0).get_child(3)
		if nav_box and nav_box.get_child_count() > 1:
			var page_label = nav_box.get_child(1)
			page_label.text = "第 %d 页" % (current_hero_page + 1)

# ==================== 输入处理 ====================

func _input(event: InputEvent):
	"""处理输入事件"""
	if not canvas_layer.visible:
		return
	
	# 阻止滚轮事件传递到地图（问题3）
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			get_viewport().set_input_as_handled()
			return
	
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				# 仅ESC键关闭，B键由main.gd处理
				hide_ui()
				get_viewport().set_input_as_handled()
			KEY_LEFT, KEY_A:
				_on_monster_prev_page()
			KEY_RIGHT, KEY_D:
				_on_hero_next_page()

# ==================== 显示控制 ====================

func show_ui():
	"""显示角色图鉴UI"""
	canvas_layer.visible = true

func hide_ui():
	"""隐藏角色图鉴UI"""
	canvas_layer.visible = false

func toggle_ui():
	"""切换角色图鉴UI显示状态"""
	canvas_layer.visible = !canvas_layer.visible

func _on_hero_gender_toggle(hero_index: int):
	"""切换英雄性别显示"""
	# 切换性别状态
	hero_gender_state[hero_index] = not hero_gender_state.get(hero_index, false)
	
	# 刷新英雄页
	_refresh_hero_page()

func set_main_game_reference(_main_game_ref: Node):
	"""设置主游戏引用"""
	pass