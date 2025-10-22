extends Node3D

## 🧪 地牢之心自由组件测试脚本
## 测试地牢之心的自由组件渲染系统

func _ready():
	"""测试地牢之心自由组件系统"""
	LogManager.info("🧪 [TestDungeonHeart] 开始测试地牢之心自由组件系统")
	
	# 创建地牢之心实例
	var dungeon_heart = UnifiedDungeonHeart.new()
	add_child(dungeon_heart)
	
	# 设置位置
	dungeon_heart.position = Vector3(0, 0, 0)
	
	# 等待一帧让组件初始化
	await get_tree().process_frame
	
	# 测试自由组件系统
	_test_free_component_system(dungeon_heart)
	
	# 测试组件操作
	_test_component_operations(dungeon_heart)
	
	# 测试边界框
	_test_bounds_system(dungeon_heart)
	
	LogManager.info("✅ [TestDungeonHeart] 地牢之心自由组件系统测试完成")

func _test_free_component_system(dungeon_heart: UnifiedDungeonHeart):
	"""测试自由组件系统"""
	LogManager.info("🔍 [TestDungeonHeart] 测试自由组件系统")
	
	# 检查组件数量
	var component_count = dungeon_heart.free_components.size()
	LogManager.info("📊 [TestDungeonHeart] 组件数量: %d" % component_count)
	
	# 检查边界框
	var bounds = dungeon_heart.get_building_bounds()
	LogManager.info("📦 [TestDungeonHeart] 边界框: %s" % str(bounds))
	
	# 检查组件节点
	var component_nodes = dungeon_heart.free_component_nodes.size()
	LogManager.info("🎯 [TestDungeonHeart] 组件节点数量: %d" % component_nodes)
	
	# 验证组件是否正确创建
	assert(component_count > 0, "地牢之心应该有组件")
	assert(component_nodes > 0, "地牢之心应该有组件节点")
	assert(bounds.size != Vector3.ZERO, "地牢之心应该有有效的边界框")

func _test_component_operations(dungeon_heart: UnifiedDungeonHeart):
	"""测试组件操作"""
	LogManager.info("🔧 [TestDungeonHeart] 测试组件操作")
	
	# 测试添加组件
	var initial_count = dungeon_heart.free_components.size()
	dungeon_heart.add_component("Test_Component", Vector3(1, 1, 1), Vector3(0.2, 0.2, 0.2), "test")
	var new_count = dungeon_heart.free_components.size()
	
	assert(new_count == initial_count + 1, "添加组件后数量应该增加")
	LogManager.info("✅ [TestDungeonHeart] 添加组件测试通过")
	
	# 测试移除组件
	dungeon_heart.remove_component("Test_Component")
	var final_count = dungeon_heart.free_components.size()
	
	assert(final_count == initial_count, "移除组件后数量应该恢复")
	LogManager.info("✅ [TestDungeonHeart] 移除组件测试通过")

func _test_bounds_system(dungeon_heart: UnifiedDungeonHeart):
	"""测试边界框系统"""
	LogManager.info("📐 [TestDungeonHeart] 测试边界框系统")
	
	# 获取边界框
	var bounds = dungeon_heart.get_building_bounds()
	
	# 测试组件放置验证
	var valid_component = {
		"position": Vector3(0.5, 0.5, 0.5),
		"size": Vector3(0.1, 0.1, 0.1)
	}
	
	var invalid_component = {
		"position": Vector3(10, 10, 10),
		"size": Vector3(1, 1, 1)
	}
	
	var valid_placement = dungeon_heart.validate_component_placement(valid_component)
	var invalid_placement = dungeon_heart.validate_component_placement(invalid_component)
	
	assert(valid_placement, "有效位置应该通过验证")
	assert(not invalid_placement, "无效位置应该不通过验证")
	
	LogManager.info("✅ [TestDungeonHeart] 边界框系统测试通过")

func _test_template_generation():
	"""测试模板生成"""
	LogManager.info("📋 [TestDungeonHeart] 测试模板生成")
	
	# 生成自由组件模板
	var template = BuildingTemplateGenerator.generate_free_dungeon_heart_template()
	
	# 验证模板结构
	assert(template.has("building_size"), "模板应该有建筑尺寸")
	assert(template.has("components"), "模板应该有组件列表")
	assert(template.has("allow_free_placement"), "模板应该允许自由放置")
	
	var components = template["components"]
	assert(components.size() > 0, "模板应该有组件")
	
	LogManager.info("✅ [TestDungeonHeart] 模板生成测试通过")

func _input(event):
	"""处理输入事件"""
	if event.is_action_pressed("ui_accept"):
		LogManager.info("🔄 [TestDungeonHeart] 重新运行测试")
		_test_template_generation()
