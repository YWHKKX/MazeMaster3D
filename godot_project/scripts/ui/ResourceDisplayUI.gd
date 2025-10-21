extends BaseUI
class_name ResourceDisplayUI

# 资源显示UI - 显示游戏中的各种资源
# 参考 UI_BEAUTIFICATION.md

# 导入UI工具类
const UIDesignConstants = preload("res://scripts/ui/UIDesignConstants.gd")
const ResourceManager = preload("res://scripts/managers/resource/ResourceManager.gd")

# UI配置
var ui_config = {
	"border_radius": 8,
	"panel_width": 300,
	"panel_height": 120,
	"margin": 10
}

# UI引用
var resource_panel: Control = null
var resource_container: VBoxContainer = null
var resource_labels: Dictionary = {}

# 节点引用（🔧 使用GameServices，确保是同一个实例）
var resource_manager = null

# 日志管理器现在作为autoload使用


func _ready():
	"""初始化资源显示UI"""
	LogManager.info("ResourceDisplayUI - 初始化开始")
	
	_setup_resource_ui()
	
	# 等待一帧，确保GameServices和ResourceManager都已初始化
	await get_tree().process_frame
	
	# 从GameServices获取ResourceManager（确保使用正确的实例）
	resource_manager = GameServices.resource_manager
	if resource_manager:
		# 连接信号（在获取正确实例后）
		_connect_signals()
	else:
		LogManager.error("无法从GameServices获取ResourceManager！")
	
	# 立即更新一次资源显示，显示初始值
	_update_all_resources()
	LogManager.info("ResourceDisplayUI - 初始化完成")


func _setup_resource_ui():
	"""设置资源UI"""
	# 创建主面板
	_create_main_panel()
	
	# 初始时隐藏
	visible = false


func _create_main_panel():
	"""创建主面板"""
	resource_panel = UIUtils.create_panel(Vector2(300, 120), UIDesignConstants.Colors.PANEL)
	resource_panel.position = Vector2(20, 20) # 左上角
	resource_panel.name = "ResourcePanel"
	
	# 设置透明度
	resource_panel.modulate.a = 0.9
	
	# 将面板添加到场景树
	add_child(resource_panel)
	
	# 创建标题
	_create_title_section()
	
	# 创建资源显示区域
	_create_resource_section()


func _create_title_section():
	"""创建标题区域"""
	var title_container = UIUtils.create_hbox_container(UIDesignConstants.Spacing.SM)
	title_container.position = Vector2(UIDesignConstants.Spacing.SM, UIDesignConstants.Spacing.SM)
	resource_panel.add_child(title_container)
	
	# 标题
	var title = UIUtils.create_label(
		"💰 资源状态", UIDesignConstants.FontSizes.H2, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	title_container.add_child(title)


func _create_resource_section():
	"""创建资源显示区域"""
	resource_container = UIUtils.create_vbox_container(UIDesignConstants.Spacing.XS)
	resource_container.position = Vector2(UIDesignConstants.Spacing.SM, 40)
	resource_container.custom_minimum_size = Vector2(280, 70)
	resource_panel.add_child(resource_container)
	
	# 创建资源标签
	_create_resource_labels()


func _create_resource_labels():
	"""创建资源标签 - 按三级分类显示"""
	if not resource_manager:
		return
	
	# 创建分类标题和资源标签
	_create_resource_category_section("🥇 核心资源", ResourceManager.ResourceCategory.CORE)
	_create_resource_category_section("🥈 基础资源", ResourceManager.ResourceCategory.BASIC)
	_create_resource_category_section("🥉 特殊资源", ResourceManager.ResourceCategory.SPECIAL)

func _create_resource_category_section(title: String, category: ResourceManager.ResourceCategory):
	"""创建资源分类区域"""
	# 分类标题
	var category_label = UIUtils.create_label(
		title, UIDesignConstants.FontSizes.NORMAL, UIDesignConstants.Colors.TEXT_SECONDARY
	)
	resource_container.add_child(category_label)
	
	# 获取该分类的资源
	var resources = resource_manager.get_resources_by_category(category)
	
	for resource_info in resources:
		_create_resource_label_from_info(resource_info)

func _create_resource_label_from_info(resource_info: Dictionary):
	"""从资源信息创建标签"""
	var label_container = UIUtils.create_hbox_container(UIDesignConstants.Spacing.SM)
	resource_container.add_child(label_container)
	
	# 资源图标和名称
	var icon_label = UIUtils.create_label(
		resource_info.icon, UIDesignConstants.FontSizes.LARGE, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	
	var name_label = UIUtils.create_label(
		resource_info.name + ":", UIDesignConstants.FontSizes.LARGE, UIDesignConstants.Colors.TEXT_PRIMARY
	)
	
	var amount_label = UIUtils.create_label(
		"0", UIDesignConstants.FontSizes.LARGE, UIDesignConstants.Colors.SUCCESS
	)
	
	label_container.add_child(icon_label)
	label_container.add_child(name_label)
	label_container.add_child(amount_label)
	
	# 存储标签引用
	resource_labels[resource_info.type] = amount_label


# 已废弃：_create_resource_label函数已删除
# 现在使用_create_resource_label_from_info函数统一处理


func _connect_signals():
	"""连接信号"""
	if resource_manager:
		resource_manager.resource_changed.connect(_on_resource_changed)
		resource_manager.resource_added.connect(_on_resource_added)
		resource_manager.resource_removed.connect(_on_resource_removed)
		resource_manager.insufficient_resources.connect(_on_insufficient_resources)


func _on_resource_changed(resource_type: ResourceManager.ResourceType, amount: int, old_amount: int):
	"""资源变化回调"""
	_update_resource_display(resource_type)


func _on_resource_added(resource_type: ResourceManager.ResourceType, amount: int):
	"""资源增加回调"""
	_update_resource_display(resource_type)
	_show_resource_effect(resource_type, "+" + str(amount), UIDesignConstants.Colors.SUCCESS)


func _on_resource_removed(resource_type: ResourceManager.ResourceType, amount: int):
	"""资源移除回调"""
	_update_resource_display(resource_type)
	_show_resource_effect(resource_type, "-" + str(amount), UIDesignConstants.Colors.ERROR)


func _on_insufficient_resources(resource_type: ResourceManager.ResourceType, requested: int, available: int):
	"""资源不足回调"""
	_show_resource_effect(resource_type, "不足!", UIDesignConstants.Colors.ERROR)


func _update_resource_display(resource_type: ResourceManager.ResourceType):
	"""更新资源显示"""
	if resource_type in resource_labels:
		if not resource_manager:
			return
			
		var amount = resource_manager.get_resource_amount(resource_type)
		var limit = _get_resource_capacity(resource_type)
		
		var label = resource_labels[resource_type]
		label.text = str(amount)
		
		# 根据资源数量设置颜色
		var percentage = float(amount) / float(limit) * 100.0
		if percentage >= 80:
			label.modulate = UIDesignConstants.Colors.SUCCESS
		elif percentage >= 50:
			label.modulate = UIDesignConstants.Colors.WARNING
		else:
			label.modulate = UIDesignConstants.Colors.ERROR


func _show_resource_effect(resource_type: ResourceManager.ResourceType, text: String, color: Color):
	"""显示资源变化效果"""
	if resource_type in resource_labels:
		var label = resource_labels[resource_type]
		
		# 创建临时效果标签
		var effect_label = UIUtils.create_label(text, UIDesignConstants.FontSizes.SMALL, color)
		effect_label.position = label.position + Vector2(50, -20)
		resource_container.add_child(effect_label)
		
		# 创建动画
		var tween = create_tween()
		tween.tween_property(effect_label, "position", effect_label.position + Vector2(0, -30), 1.0)
		tween.parallel().tween_property(effect_label, "modulate:a", 0.0, 1.0)
		tween.tween_callback(effect_label.queue_free)


func _get_resource_icon_name(resource_type: ResourceManager.ResourceType) -> String:
	"""获取资源图标"""
	if resource_manager:
		return resource_manager.get_resource_icon(resource_type)
	
	# 备用图标（如果ResourceManager不可用）
	match resource_type:
		ResourceManager.ResourceType.GOLD:
			return "💰"
		ResourceManager.ResourceType.FOOD:
			return "🍖"
		ResourceManager.ResourceType.STONE:
			return "🔳" # 使用方块替代石头
		ResourceManager.ResourceType.WOOD:
			return "📦" # 使用箱子替代木材
		ResourceManager.ResourceType.IRON:
			return "⛏️"
		ResourceManager.ResourceType.GEM:
			return "💎"
		ResourceManager.ResourceType.MAGIC_HERB:
			return "🌿"
		ResourceManager.ResourceType.MAGIC_CRYSTAL:
			return "✨"
		ResourceManager.ResourceType.DEMON_CORE:
			return "👹"
		ResourceManager.ResourceType.MANA:
			return "✨"
		_:
			return "❓"


func _get_resource_display_name(resource_type: ResourceManager.ResourceType) -> String:
	"""获取资源显示名称"""
	if resource_manager:
		return resource_manager.get_resource_name(resource_type) + ":"
	
	# 备用名称（如果ResourceManager不可用）
	match resource_type:
		ResourceManager.ResourceType.GOLD:
			return "金币:"
		ResourceManager.ResourceType.FOOD:
			return "食物:"
		ResourceManager.ResourceType.STONE:
			return "石头:"
		ResourceManager.ResourceType.WOOD:
			return "木材:"
		ResourceManager.ResourceType.IRON:
			return "铁矿:"
		ResourceManager.ResourceType.GEM:
			return "宝石:"
		ResourceManager.ResourceType.MAGIC_HERB:
			return "魔法草药:"
		ResourceManager.ResourceType.MAGIC_CRYSTAL:
			return "魔法水晶:"
		ResourceManager.ResourceType.DEMON_CORE:
			return "恶魔核心:"
		ResourceManager.ResourceType.MANA:
			return "魔力:"
		_:
			return "未知:"


func _get_resource_capacity(resource_type: ResourceManager.ResourceType) -> int:
	"""获取资源容量
	
	Args:
		resource_type: 资源类型
	
	Returns:
		int: 资源容量
	"""
	match resource_type:
		ResourceManager.ResourceType.GOLD:
			if resource_manager:
				var gold_info = resource_manager.get_total_gold()
				return gold_info.capacity if gold_info else 5000
			return 5000
		ResourceManager.ResourceType.MANA:
			if resource_manager:
				var mana_info = resource_manager.get_total_mana()
				return mana_info.capacity if mana_info else 2000
			return 2000
		_:
			# 其他资源类型使用无限容量
			return 999999


# 公共接口
func show_ui():
	"""显示资源UI"""
	if not is_visible:
		visible = true
		is_visible = true
		fade_in()
		
		# 等待地牢之心注册完成（异步初始化可能还没完成）
		await get_tree().process_frame
		await get_tree().process_frame
		
		# 确保使用正确的ResourceManager实例（从GameServices）
		if not resource_manager:
			resource_manager = GameServices.resource_manager
			
			# 重新连接信号（使用正确的实例）
			if resource_manager:
				_connect_signals()
		
		# 强制刷新资源显示，确保显示最新值
		_update_all_resources()


func hide_ui():
	"""隐藏资源UI"""
	if is_visible:
		fade_out()
		is_visible = false


func toggle_ui():
	"""切换UI显示"""
	if is_visible:
		hide_ui()
	else:
		show_ui()


func _update_all_resources():
	"""更新所有资源显示"""
	for resource_type in resource_labels:
		_update_resource_display(resource_type)


func refresh_display():
	"""刷新显示"""
	_update_all_resources()


# 扩展功能
func add_resource_type(resource_type: ResourceManager.ResourceType):
	"""动态添加资源类型显示"""
	if not resource_type in resource_labels:
		# 使用新的函数创建资源标签
		var resource_info = {
			"type": resource_type,
			"name": _get_resource_display_name(resource_type).replace(":", ""),
			"icon": _get_resource_icon_name(resource_type)
		}
		_create_resource_label_from_info(resource_info)
		_update_resource_display(resource_type)


func remove_resource_type(resource_type: ResourceManager.ResourceType):
	"""移除资源类型显示"""
	if resource_type in resource_labels:
		var label = resource_labels[resource_type]
		label.queue_free()
		resource_labels.erase(resource_type)


func set_resource_position(pos: Vector2):
	"""设置资源面板位置"""
	if resource_panel:
		resource_panel.position = pos


func set_panel_size(size: Vector2):
	"""设置面板大小"""
	if resource_panel:
		resource_panel.custom_minimum_size = size
