extends BaseUI
class_name MiningSystemUI

# 挖掘系统UI - 显示金矿和苦工状态
# 参考MINING_SYSTEM.md

# 导入UI工具类
const UIDesignConstants = preload("res://scripts/ui/UIDesignConstants.gd")
# 日志管理器实例（全局变量）
# UI配置
var ui_config = {
	"panel_width": 400,
	"panel_height": 250,
	"margin": 30,
	"show_worker_details": true,
	"show_mine_details": true
}

# UI引用
var mining_panel: Control = null
var worker_list: VBoxContainer = null
var mine_list: VBoxContainer = null

# 管理器引用
var gold_mine_manager: ResourceManager = null
var character_manager: CharacterManager = null


func _ready():
	"""初始化挖掘系统UI"""
	LogManager.info("MiningSystemUI - 初始化开始")
	_setup_mining_ui()
	LogManager.info("MiningSystemUI - 初始化完成")


func _setup_mining_ui():
	"""设置挖掘UI"""
	# 初始时隐藏
	visible = false

	# 创建主面板
	_create_main_panel()

	# 设置输入处理
	_setup_input_handling()


func _create_main_panel():
	"""创建主面板"""
	mining_panel = create_panel(
		Vector2(ui_config.panel_width, ui_config.panel_height), UIDesignConstants.Colors.PANEL
	)
	mining_panel.position = Vector2(
		get_viewport().size.x - ui_config.panel_width - ui_config.margin, \
		ui_config.margin + 200 # 在右上角，建筑面板下方
	)
	mining_panel.name = "MiningPanel"

	# 创建标题区域
	_create_title_section()

	# 创建内容区域
	_create_content_section()


func _create_title_section():
	"""创建标题区域"""
	var title_container = create_hbox_container(UIDesignConstants.Spacing.MD)
	title_container.position = Vector2(UIDesignConstants.Spacing.MD, UIDesignConstants.Spacing.MD)
	mining_panel.add_child(title_container)

	# 标题
	var title = create_label(
		"⛏️ 挖掘系统", UIDesignConstants.FontSizes.H3, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	title_container.add_child(title)

	# 关闭按钮
	var close_button = create_button("×", Callable(self, "_on_close_button_pressed"))
	close_button.custom_minimum_size = Vector2(30, 30)
	title_container.add_child(close_button)


func _create_content_section():
	"""创建内容区域"""
	var content_container = create_vbox_container(UIDesignConstants.Spacing.SM)
	content_container.position = Vector2(UIDesignConstants.Spacing.MD, 60)
	content_container.custom_minimum_size = Vector2(260, 120)
	mining_panel.add_child(content_container)

	# 统计信息
	_create_statistics_section(content_container)

	# 苦工列表
	_create_worker_list_section(content_container)

	# 金矿列表
	_create_mine_list_section(content_container)


func _create_statistics_section(container: VBoxContainer):
	"""创建统计信息区域"""
	var stats_container = create_hbox_container(UIDesignConstants.Spacing.SM)
	container.add_child(stats_container)

	# 苦工数量
	var worker_count_label = create_label(
		"👷 苦工: 0", UIDesignConstants.FontSizes.SMALL, UIDesignConstants.Colors.TEXT_SECONDARY
	)
	stats_container.add_child(worker_count_label)

	# 金矿数量
	var mine_count_label = create_label(
		"⛏️ 金矿: 0", UIDesignConstants.FontSizes.SMALL, UIDesignConstants.Colors.TEXT_SECONDARY
	)
	stats_container.add_child(mine_count_label)


func _create_worker_list_section(container: VBoxContainer):
	"""创建苦工列表区域"""
	var worker_section = create_vbox_container(UIDesignConstants.Spacing.XS)
	container.add_child(worker_section)

	var section_title = create_label(
		"苦工状态", UIDesignConstants.FontSizes.SMALL, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	worker_section.add_child(section_title)

	worker_list = create_vbox_container(0)
	worker_list.custom_minimum_size = Vector2(240, 40)
	worker_section.add_child(worker_list)


func _create_mine_list_section(container: VBoxContainer):
	"""创建金矿列表区域"""
	var mine_section = create_vbox_container(UIDesignConstants.Spacing.XS)
	container.add_child(mine_section)

	var section_title = create_label(
		"金矿状态", UIDesignConstants.FontSizes.SMALL, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	mine_section.add_child(section_title)

	mine_list = create_vbox_container(0)
	mine_list.custom_minimum_size = Vector2(240, 40)
	mine_section.add_child(mine_list)


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
			KEY_Q:
				hide_ui()


func _on_close_button_pressed():
	"""关闭按钮被按下"""
	hide_ui()


# 更新方法
func update_mining_info():
	"""更新挖掘信息"""
	if not is_visible:
		return

	_update_worker_list()
	_update_mine_list()
	_update_statistics()


func _update_worker_list():
	"""更新苦工列表"""
	if not worker_list or not character_manager:
		return

	# 清空现有列表
	for child in worker_list.get_children():
		child.queue_free()

	# 获取所有哥布林苦工
	var goblin_workers = character_manager.get_all_goblin_workers()

	for worker in goblin_workers:
		if worker.has_method("get_worker_info"):
			var info = worker.get_worker_info()
			_create_worker_item(info)


func _update_mine_list():
	"""更新金矿列表"""
	if not mine_list or not gold_mine_manager:
		return

	# 清空现有列表
	for child in mine_list.get_children():
		child.queue_free()

	# 获取金矿统计信息
	var stats = gold_mine_manager.get_mine_statistics()
	_create_mine_summary_item(stats)


func _update_statistics():
	"""更新统计信息"""
	if not mining_panel:
		return

	var stats_container = mining_panel.get_child(1).get_child(0) # 统计容器
	if not stats_container or stats_container.get_child_count() < 2:
		return

	var worker_count = 0
	var mine_count = 0

	if character_manager:
		worker_count = character_manager.get_all_goblin_workers().size()

	if gold_mine_manager:
		var mine_stats = gold_mine_manager.get_mine_statistics()
		mine_count = mine_stats.active_mines

	# 更新苦工数量
	var worker_label = stats_container.get_child(0)
	worker_label.text = "👷 苦工: " + str(worker_count)

	# 更新金矿数量
	var mine_label = stats_container.get_child(1)
	mine_label.text = "⛏️ 金矿: " + str(mine_count)


func _create_worker_item(worker_info: Dictionary):
	"""创建苦工项目"""
	var worker_item = create_hbox_container(0)
	worker_list.add_child(worker_item)

	# 状态指示器
	var status_color = worker_info.get("status_color", Color.WHITE)
	var status_indicator = create_label("●", UIDesignConstants.FontSizes.SMALL, status_color)
	status_indicator.custom_minimum_size.x = 20
	worker_item.add_child(status_indicator)

	# 苦工信息
	var info_text = (
		"位置: " + str(int(worker_info.position.x)) + "," + str(int(worker_info.position.z))
	)
	info_text += " 携带: " + str(worker_info.carried_gold) + "金"
	info_text += " 生命: " + str(int(worker_info.health))

	var info_label = create_label(
		info_text, UIDesignConstants.FontSizes.TINY, UIDesignConstants.Colors.TEXT_SECONDARY
	)
	worker_item.add_child(info_label)


func _create_mine_summary_item(stats: Dictionary):
	"""创建金矿摘要项目"""
	var mine_item = create_hbox_container(0)
	mine_list.add_child(mine_item)

	var summary_text = "活跃: " + str(stats.active_mines) + " 枯竭: " + str(stats.exhausted_mines)
	summary_text += " 剩余黄金: " + str(stats.remaining_gold)

	var summary_label = create_label(
		summary_text, UIDesignConstants.FontSizes.TINY, UIDesignConstants.Colors.TEXT_SECONDARY
	)
	mine_item.add_child(summary_label)


# 公共接口
func show_ui():
	"""显示挖掘系统UI"""
	if not is_visible:
		visible = true
		is_visible = true
		update_mining_info()
		fade_in()


func hide_ui():
	"""隐藏挖掘系统UI"""
	if is_visible:
		fade_out()
		is_visible = false


func toggle_ui():
	"""切换UI显示"""
	if is_visible:
		hide_ui()
	else:
		show_ui()


func set_managers(gold_mine_mgr: ResourceManager, char_mgr: CharacterManager):
	"""设置管理器引用"""
	gold_mine_manager = gold_mine_mgr
	character_manager = char_mgr


func _process(_delta):
	"""每帧更新"""
	if is_visible:
		update_mining_info()
