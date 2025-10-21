class_name ResourceDensityUI
extends Control

## 📊 资源密度可视化UI
## 显示地图上的资源密度分布

# 导入依赖
const UIDesignConstants = preload("res://scripts/ui/UIDesignConstants.gd")
const ResourceManager = preload("res://scripts/managers/resource/ResourceManager.gd")

# UI组件
var density_panel: Control = null
var density_chart: Control = null
var density_legend: VBoxContainer = null
var density_stats: VBoxContainer = null

# 配置
var ui_config = {
	"panel_width": 300,
	"panel_height": 400,
	"chart_height": 200,
	"margin": 10,
	"bar_width": 20,
	"bar_spacing": 5
}

# 数据
var density_data: Dictionary = {}
var resource_manager = null
var update_timer: Timer = null

func _ready():
	"""初始化资源密度UI"""
	LogManager.info("ResourceDensityUI - 初始化开始")
	
	_setup_ui()
	_setup_update_timer()
	
	# 等待一帧，确保GameServices和ResourceManager都已初始化
	await get_tree().process_frame
	
	# 从GameServices获取ResourceManager
	resource_manager = GameServices.resource_manager
	if resource_manager:
		_connect_signals()
		update_density_display()
	else:
		LogManager.error("ResourceDensityUI - 无法从GameServices获取ResourceManager！")
	
	LogManager.info("ResourceDensityUI - 初始化完成")

func _setup_ui():
	"""设置UI界面"""
	# 创建主面板
	density_panel = Control.new()
	density_panel.name = "DensityPanel"
	density_panel.custom_minimum_size = Vector2(ui_config.panel_width, ui_config.panel_height)
	add_child(density_panel)
	
	# 创建标题
	var title_label = Label.new()
	title_label.text = "资源密度分布"
	title_label.position = Vector2(ui_config.margin, ui_config.margin)
	title_label.add_theme_font_size_override("font_size", 16)
	density_panel.add_child(title_label)
	
	# 创建密度图表
	density_chart = Control.new()
	density_chart.name = "DensityChart"
	density_chart.position = Vector2(ui_config.margin, 40)
	density_chart.custom_minimum_size = Vector2(ui_config.panel_width - ui_config.margin * 2, ui_config.chart_height)
	density_panel.add_child(density_chart)
	
	# 创建图例
	density_legend = VBoxContainer.new()
	density_legend.name = "DensityLegend"
	density_legend.position = Vector2(ui_config.margin, 250)
	density_legend.custom_minimum_size = Vector2(ui_config.panel_width - ui_config.margin * 2, 100)
	density_panel.add_child(density_legend)
	
	# 创建统计信息
	density_stats = VBoxContainer.new()
	density_stats.name = "DensityStats"
	density_stats.position = Vector2(ui_config.margin, 360)
	density_stats.custom_minimum_size = Vector2(ui_config.panel_width - ui_config.margin * 2, 40)
	density_panel.add_child(density_stats)

func _setup_update_timer():
	"""设置更新定时器"""
	update_timer = Timer.new()
	update_timer.wait_time = 2.0 # 每2秒更新一次
	update_timer.timeout.connect(_on_update_timer_timeout)
	update_timer.autostart = true
	add_child(update_timer)

func _connect_signals():
	"""连接信号"""
	if resource_manager:
		resource_manager.resource_spawned.connect(_on_resource_spawned)
		resource_manager.resource_depleted.connect(_on_resource_depleted)

func _on_update_timer_timeout():
	"""更新定时器超时"""
	update_density_display()

func update_density_display():
	"""更新密度显示"""
	if not resource_manager:
		return
	
	_calculate_density_data()
	_draw_density_chart()
	_update_density_legend()
	_update_density_stats()

func _calculate_density_data():
	"""计算密度数据"""
	density_data.clear()
	var total_resources = 0
	var area_size = 100.0 # 100x100单位区域
	
	for resource_type in ResourceManager.ResourceType.values():
		var spawns = resource_manager.get_all_resource_spawns()
		var type_count = 0
		
		for spawn in spawns:
			if spawn.resource_type == resource_type and not spawn.get("is_depleted", false):
				type_count += 1
		
		var density = type_count / (area_size * area_size / 10000.0) # 每100x100区域的密度
		density_data[resource_type] = {
			"count": type_count,
			"density": density,
			"name": resource_manager.get_resource_name(resource_type),
			"icon": resource_manager.get_resource_icon(resource_type)
		}
		total_resources += type_count
	
	density_data["total"] = total_resources

func _draw_density_chart():
	"""绘制密度图表"""
	# 清除旧的图表
	for child in density_chart.get_children():
		child.queue_free()
	
	if density_data.is_empty():
		return
	
	# 计算最大密度值用于缩放
	var max_density = 0.0
	for resource_type in ResourceManager.ResourceType.values():
		if density_data.has(resource_type):
			max_density = max(max_density, density_data[resource_type].density)
	
	if max_density == 0.0:
		return
	
	# 绘制条形图
	var bar_index = 0
	var chart_width = density_chart.custom_minimum_size.x
	var chart_height = density_chart.custom_minimum_size.y
	var bar_area_width = chart_width - ui_config.margin * 2
	var available_width = bar_area_width - (ResourceManager.ResourceType.size() - 1) * ui_config.bar_spacing
	var bar_width = available_width / ResourceManager.ResourceType.size()
	
	for resource_type in ResourceManager.ResourceType.values():
		if not density_data.has(resource_type):
			continue
		
		var data = density_data[resource_type]
		var bar_height = (data.density / max_density) * (chart_height - ui_config.margin * 2)
		
		# 创建条形
		var bar = ColorRect.new()
		bar.name = "Bar_" + str(resource_type)
		bar.position = Vector2(
			ui_config.margin + bar_index * (bar_width + ui_config.bar_spacing),
			chart_height - bar_height - ui_config.margin
		)
		bar.size = Vector2(bar_width, bar_height)
		bar.color = _get_resource_color(resource_type)
		density_chart.add_child(bar)
		
		# 添加数值标签
		var value_label = Label.new()
		value_label.text = str(data.count)
		value_label.position = Vector2(bar.position.x, bar.position.y - 20)
		value_label.size = Vector2(bar_width, 20)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value_label.add_theme_font_size_override("font_size", 10)
		density_chart.add_child(value_label)
		
		bar_index += 1

func _update_density_legend():
	"""更新密度图例"""
	# 清除旧的图例
	for child in density_legend.get_children():
		child.queue_free()
	
	var legend_title = Label.new()
	legend_title.text = "图例"
	legend_title.add_theme_font_size_override("font_size", 12)
	density_legend.add_child(legend_title)
	
	for resource_type in ResourceManager.ResourceType.values():
		if not density_data.has(resource_type):
			continue
		
		var data = density_data[resource_type]
		var legend_item = HBoxContainer.new()
		
		# 颜色指示器
		var color_indicator = ColorRect.new()
		color_indicator.custom_minimum_size = Vector2(16, 16)
		color_indicator.color = _get_resource_color(resource_type)
		legend_item.add_child(color_indicator)
		
		# 资源信息
		var info_label = Label.new()
		info_label.text = "%s %s (%d个, 密度%.2f)" % [data.icon, data.name, data.count, data.density]
		info_label.add_theme_font_size_override("font_size", 10)
		legend_item.add_child(info_label)
		
		density_legend.add_child(legend_item)

func _update_density_stats():
	"""更新密度统计"""
	# 清除旧的统计
	for child in density_stats.get_children():
		child.queue_free()
	
	if density_data.has("total"):
		var total_label = Label.new()
		total_label.text = "总资源点: %d个" % density_data.total
		total_label.add_theme_font_size_override("font_size", 12)
		density_stats.add_child(total_label)
		
		var avg_density = density_data.total / (100.0 * 100.0 / 10000.0) # 平均密度
		var avg_label = Label.new()
		avg_label.text = "平均密度: %.2f/100x100区域" % avg_density
		avg_label.add_theme_font_size_override("font_size", 10)
		density_stats.add_child(avg_label)

func _get_resource_color(resource_type: ResourceManager.ResourceType) -> Color:
	"""获取资源颜色"""
	match resource_type:
		ResourceManager.ResourceType.GOLD:
			return Color.YELLOW
		ResourceManager.ResourceType.FOOD:
			return Color.ORANGE
		ResourceManager.ResourceType.STONE:
			return Color.GRAY
		ResourceManager.ResourceType.WOOD:
			return Color.BROWN
		ResourceManager.ResourceType.IRON:
			return Color.SILVER
		ResourceManager.ResourceType.GEM:
			return Color.MAGENTA
		ResourceManager.ResourceType.MAGIC_HERB:
			return Color.GREEN
		ResourceManager.ResourceType.MAGIC_CRYSTAL:
			return Color.CYAN
		ResourceManager.ResourceType.DEMON_CORE:
			return Color.RED
		ResourceManager.ResourceType.MANA:
			return Color.PURPLE
		_:
			return Color.WHITE

# ===== 信号处理 =====

func _on_resource_spawned(resource_type: ResourceManager.ResourceType, position: Vector2, amount: int):
	"""资源生成信号处理"""
	call_deferred("update_density_display")

func _on_resource_depleted(resource_type: ResourceManager.ResourceType, position: Vector2):
	"""资源枯竭信号处理"""
	call_deferred("update_density_display")

# ===== 公共接口 =====

func toggle_visibility():
	"""切换可见性"""
	visible = !visible

func set_update_interval(interval: float):
	"""设置更新间隔"""
	if update_timer:
		update_timer.wait_time = interval

func get_density_data() -> Dictionary:
	"""获取密度数据"""
	return density_data

func export_density_report() -> String:
	"""导出密度报告"""
	var report = "资源密度报告\n"
	report += "==================\n"
	
	for resource_type in ResourceManager.ResourceType.values():
		if density_data.has(resource_type):
			var data = density_data[resource_type]
			report += "%s: %d个 (密度: %.2f)\n" % [data.name, data.count, data.density]
	
	report += "总计: %d个资源点" % density_data.get("total", 0)
	return report
