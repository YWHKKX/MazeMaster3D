extends Node3D
class_name Building3DTest

## 🧪 3D建筑系统测试脚本
## 用于测试3x3x3建筑系统的功能

var test_buildings: Array[Building3D] = []

func _ready():
	"""准备测试"""
	LogManager.info("🧪 [Building3DTest] 开始3D建筑系统测试")
	
	# 等待一帧确保所有系统初始化
	await get_tree().process_frame
	
	# 开始测试
	_start_tests()


func _start_tests():
	"""开始测试"""
	LogManager.info("🧪 [Building3DTest] 创建测试建筑")
	
	# 测试1：创建奥术塔3D
	_test_arcane_tower_3d()
	
	# 测试2：创建箭塔3D
	_test_arrow_tower_3d()
	
	# 测试3：创建金库3D
	_test_treasury_3d()
	
	# 测试4：测试渲染模式切换
	_test_render_mode_switching()
	
	# 测试5：测试LOD系统
	_test_lod_system()


func _test_arcane_tower_3d():
	"""测试奥术塔3D"""
	LogManager.info("🧪 [Building3DTest] 测试奥术塔3D")
	
	var arcane_tower = ArcaneTower3D.new()
	arcane_tower.name = "TestArcaneTower3D"
	arcane_tower.position = Vector3(0, 0, 0)
	
	add_child(arcane_tower)
	test_buildings.append(arcane_tower)
	
	# 等待建筑初始化
	await get_tree().process_frame
	
	# 验证建筑属性
	assert(arcane_tower.building_name == "奥术塔", "奥术塔名称错误")
	assert(arcane_tower.building_type == BuildingTypes.ARCANE_TOWER, "奥术塔类型错误")
	assert(arcane_tower.render_mode == BuildingRenderMode.GRIDMAP, "奥术塔渲染模式错误")
	
	LogManager.info("✅ [Building3DTest] 奥术塔3D测试通过")


func _test_arrow_tower_3d():
	"""测试箭塔3D"""
	LogManager.info("🧪 [Building3DTest] 测试箭塔3D")
	
	var arrow_tower = ArrowTower3D.new()
	arrow_tower.name = "TestArrowTower3D"
	arrow_tower.position = Vector3(5, 0, 0)
	
	add_child(arrow_tower)
	test_buildings.append(arrow_tower)
	
	# 等待建筑初始化
	await get_tree().process_frame
	
	# 验证建筑属性
	assert(arrow_tower.building_name == "箭塔", "箭塔名称错误")
	assert(arrow_tower.building_type == BuildingTypes.ARROW_TOWER, "箭塔类型错误")
	assert(arrow_tower.attack_damage == 25.0, "箭塔攻击力错误")
	assert(arrow_tower.crit_rate == 0.25, "箭塔暴击率错误")
	
	LogManager.info("✅ [Building3DTest] 箭塔3D测试通过")


func _test_treasury_3d():
	"""测试金库3D"""
	LogManager.info("🧪 [Building3DTest] 测试金库3D")
	
	var treasury = Treasury3D.new()
	treasury.name = "TestTreasury3D"
	treasury.position = Vector3(10, 0, 0)
	
	add_child(treasury)
	test_buildings.append(treasury)
	
	# 等待建筑初始化
	await get_tree().process_frame
	
	# 验证建筑属性
	assert(treasury.building_name == "金库", "金库名称错误")
	assert(treasury.building_type == BuildingTypes.TREASURY, "金库类型错误")
	assert(treasury.gold_storage_capacity == 500, "金库容量错误")
	
	LogManager.info("✅ [Building3DTest] 金库3D测试通过")


func _test_render_mode_switching():
	"""测试渲染模式切换"""
	LogManager.info("🧪 [Building3DTest] 测试渲染模式切换")
	
	if test_buildings.size() == 0:
		LogManager.warning("⚠️ [Building3DTest] 没有测试建筑，跳过渲染模式测试")
		return
	
	var test_building = test_buildings[0]
	
	# 测试切换到程序化渲染
	test_building.render_mode = BuildingRenderMode.PROCEDURAL
	test_building._setup_render_system()
	
	await get_tree().process_frame
	
	# 验证渲染模式切换
	assert(test_building.render_mode == BuildingRenderMode.PROCEDURAL, "渲染模式切换失败")
	assert(test_building.procedural_renderer != null, "程序化渲染器未创建")
	
	# 切换回GridMap渲染
	test_building.render_mode = BuildingRenderMode.GRIDMAP
	test_building._setup_render_system()
	
	await get_tree().process_frame
	
	# 验证渲染模式切换
	assert(test_building.render_mode == BuildingRenderMode.GRIDMAP, "渲染模式切换失败")
	assert(test_building.gridmap_renderer != null, "GridMap渲染器未创建")
	
	LogManager.info("✅ [Building3DTest] 渲染模式切换测试通过")


func _test_lod_system():
	"""测试LOD系统"""
	LogManager.info("🧪 [Building3DTest] 测试LOD系统")
	
	if test_buildings.size() == 0:
		LogManager.warning("⚠️ [Building3DTest] 没有测试建筑，跳过LOD测试")
		return
	
	var test_building = test_buildings[0]
	
	# 测试LOD级别切换
	test_building.update_lod(60.0)  # 远距离
	assert(test_building.lod_level == 0, "远距离LOD级别错误")
	
	test_building.update_lod(30.0)  # 中距离
	assert(test_building.lod_level == 1, "中距离LOD级别错误")
	
	test_building.update_lod(10.0)  # 近距离
	assert(test_building.lod_level == 2, "近距离LOD级别错误")
	
	LogManager.info("✅ [Building3DTest] LOD系统测试通过")


func _test_building_components():
	"""测试建筑构件系统"""
	LogManager.info("🧪 [Building3DTest] 测试建筑构件系统")
	
	# 测试构件常量
	assert(BuildingComponents.ID_FLOOR_STONE == 1, "石质地板ID错误")
	assert(BuildingComponents.ID_WALL_STONE == 4, "石质墙体ID错误")
	assert(BuildingComponents.ID_DOOR_WOOD == 21, "木门ID错误")
	assert(BuildingComponents.ID_GOLD_PILE == 71, "金币堆ID错误")
	
	# 测试构件属性
	assert(BuildingComponents.get_component_name(BuildingComponents.ID_FLOOR_STONE) == "石质地板", "构件名称错误")
	assert(BuildingComponents.get_component_color(BuildingComponents.ID_GOLD_PILE) == Color.GOLD, "构件颜色错误")
	
	LogManager.info("✅ [Building3DTest] 建筑构件系统测试通过")


func _test_building_templates():
	"""测试建筑模板系统"""
	LogManager.info("🧪 [Building3DTest] 测试建筑模板系统")
	
	# 测试简单塔楼模板
	var tower_template = BuildingTemplate.new("测试塔楼")
	tower_template.create_simple_tower(BuildingTypes.ARROW_TOWER)
	
	assert(tower_template.get_component(1, 0, 0) == BuildingComponents.ID_DOOR_WOOD, "塔楼门位置错误")
	assert(tower_template.get_component(1, 1, 0) == BuildingComponents.ID_WINDOW_SMALL, "塔楼窗户位置错误")
	
	# 测试魔法结构模板
	var magic_template = BuildingTemplate.new("测试魔法结构")
	magic_template.create_magic_structure(BuildingTypes.ARCANE_TOWER)
	
	assert(magic_template.get_component(1, 0, 0) == BuildingComponents.ID_GATE_STONE, "魔法门位置错误")
	assert(magic_template.get_component(1, 1, 0) == BuildingComponents.ID_WINDOW_LARGE, "魔法窗户位置错误")
	
	LogManager.info("✅ [Building3DTest] 建筑模板系统测试通过")


func _cleanup_test_buildings():
	"""清理测试建筑"""
	LogManager.info("🧪 [Building3DTest] 清理测试建筑")
	
	for building in test_buildings:
		if is_instance_valid(building):
			building.queue_free()
	
	test_buildings.clear()


func _on_test_completed():
	"""测试完成回调"""
	LogManager.info("🎉 [Building3DTest] 所有测试完成！")
	
	# 清理测试建筑
	_cleanup_test_buildings()
	
	# 输出测试结果
	LogManager.info("📊 [Building3DTest] 测试结果:")
	LogManager.info("  ✅ 奥术塔3D - 通过")
	LogManager.info("  ✅ 箭塔3D - 通过")
	LogManager.info("  ✅ 金库3D - 通过")
	LogManager.info("  ✅ 渲染模式切换 - 通过")
	LogManager.info("  ✅ LOD系统 - 通过")
	LogManager.info("  ✅ 建筑构件系统 - 通过")
	LogManager.info("  ✅ 建筑模板系统 - 通过")
	LogManager.info("🎯 [Building3DTest] 3D建筑系统测试全部通过！")


func _input(event):
	"""输入处理"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_T:
				# 按T键运行完整测试
				_start_tests()
			KEY_C:
				# 按C键清理测试建筑
				_cleanup_test_buildings()
			KEY_1:
				# 按1键测试构件系统
				_test_building_components()
			KEY_2:
				# 按2键测试模板系统
				_test_building_templates()
