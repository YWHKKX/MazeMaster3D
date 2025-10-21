extends Control
class_name ResourceRenderPerformanceUI

## 📊 资源渲染性能监控UI
## 显示渲染系统的性能统计和质量调整信息

@onready var fps_label: Label = $VBoxContainer/FPSLabel
@onready var quality_label: Label = $VBoxContainer/QualityLabel
@onready var objects_label: Label = $VBoxContainer/ObjectsLabel
@onready var plants_label: Label = $VBoxContainer/PlantsLabel
@onready var minerals_label: Label = $VBoxContainer/MineralsLabel
@onready var resources_label: Label = $VBoxContainer/ResourcesLabel
@onready var performance_chart: Control = $VBoxContainer/PerformanceChart

var enhanced_resource_renderer = null
var update_timer: Timer = null
var fps_history: Array[float] = []
var max_history_length: int = 60

func _ready():
	"""初始化性能监控UI"""
	_setup_ui()
	_setup_timer()
	LogManager.info("ResourceRenderPerformanceUI - 性能监控UI初始化完成")

func _setup_ui():
	"""设置UI布局"""
	# 创建主容器
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	add_child(vbox)
	
	# 创建标签
	fps_label = Label.new()
	fps_label.name = "FPSLabel"
	fps_label.text = "FPS: --"
	vbox.add_child(fps_label)
	
	quality_label = Label.new()
	quality_label.name = "QualityLabel"
	quality_label.text = "质量: --"
	vbox.add_child(quality_label)
	
	objects_label = Label.new()
	objects_label.name = "ObjectsLabel"
	objects_label.text = "对象: --"
	vbox.add_child(objects_label)
	
	plants_label = Label.new()
	plants_label.name = "PlantsLabel"
	plants_label.text = "植物: --"
	vbox.add_child(plants_label)
	
	minerals_label = Label.new()
	minerals_label.name = "MineralsLabel"
	minerals_label.text = "矿物: --"
	vbox.add_child(minerals_label)
	
	resources_label = Label.new()
	resources_label.name = "ResourcesLabel"
	resources_label.text = "资源: --"
	vbox.add_child(resources_label)
	
	# 创建性能图表
	performance_chart = Control.new()
	performance_chart.name = "PerformanceChart"
	performance_chart.custom_minimum_size = Vector2(200, 100)
	vbox.add_child(performance_chart)

func _setup_timer():
	"""设置更新定时器"""
	update_timer = Timer.new()
	update_timer.wait_time = 0.5 # 每0.5秒更新一次
	update_timer.timeout.connect(_update_display)
	update_timer.autostart = true
	add_child(update_timer)

func set_enhanced_resource_renderer(renderer):
	"""设置增强资源渲染器引用"""
	enhanced_resource_renderer = renderer
	LogManager.info("ResourceRenderPerformanceUI - 渲染器引用已设置")

func _update_display():
	"""更新显示"""
	if not enhanced_resource_renderer:
		return
	
	var status = enhanced_resource_renderer.get_render_status()
	
	# 更新FPS显示
	var current_fps = status.get("current_fps", 0.0)
	var average_fps = status.get("average_fps", 0.0)
	fps_label.text = "FPS: %.1f (平均: %.1f)" % [current_fps, average_fps]
	
	# 更新质量级别
	var quality_level = status.get("quality_level", "unknown")
	quality_label.text = "质量: %s" % quality_level
	
	# 更新对象数量
	var total_objects = status.get("total_objects", 0)
	objects_label.text = "对象: %d" % total_objects
	
	# 更新各渲染器状态
	var plant_status = status.get("plant_status", {})
	var mineral_status = status.get("mineral_status", {})
	var resource_status = status.get("resource_status", {})
	
	var plant_count = plant_status.get("plant_count", 0)
	var mineral_count = mineral_status.get("mineral_count", 0)
	var resource_count = resource_status.get("marker_count", 0)
	
	plants_label.text = "植物: %d" % plant_count
	minerals_label.text = "矿物: %d" % mineral_count
	resources_label.text = "资源: %d" % resource_count
	
	# 更新FPS历史
	fps_history.append(current_fps)
	if fps_history.size() > max_history_length:
		fps_history.pop_front()
	
	# 更新性能图表
	_update_performance_chart()

func _update_performance_chart():
	"""更新性能图表"""
	if fps_history.size() < 2:
		return
	
	# 简单的FPS趋势显示
	# 清除之前的绘制
	performance_chart.queue_redraw()
	
	# 设置绘制回调
	performance_chart.draw.connect(_draw_performance_chart)

func _draw_performance_chart():
	"""绘制性能图表"""
	if fps_history.size() < 2:
		return
	
	var chart_width = performance_chart.size.x
	var chart_height = performance_chart.size.y
	
	# 计算FPS范围
	var min_fps = fps_history.min()
	var max_fps = fps_history.max()
	var fps_range = max_fps - min_fps
	if fps_range == 0:
		fps_range = 1
	
	# 绘制FPS曲线
	var points = PackedVector2Array()
	for i in range(fps_history.size()):
		var x = float(i) / (fps_history.size() - 1) * chart_width
		var y = chart_height - ((fps_history[i] - min_fps) / fps_range * chart_height)
		points.append(Vector2(x, y))
	
	# 绘制线条
	if points.size() > 1:
		performance_chart.draw_polyline(points, Color.GREEN, 2.0)
	
	# 绘制目标FPS线
	var target_fps = 60.0
	var target_y = chart_height - ((target_fps - min_fps) / fps_range * chart_height)
	performance_chart.draw_line(Vector2(0, target_y), Vector2(chart_width, target_y), Color.RED, 1.0)

func toggle_visibility():
	"""切换可见性"""
	visible = !visible
	LogManager.info("ResourceRenderPerformanceUI - 可见性: %s" % ("显示" if visible else "隐藏"))

func set_ui_position(pos: Vector2):
	"""设置UI位置"""
	position = pos

func set_ui_size(ui_size: Vector2):
	"""设置UI大小"""
	custom_minimum_size = ui_size
