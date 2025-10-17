extends GridMap
class_name GridMapRenderer

## 🏗️ GridMap渲染器
## 负责使用GridMap模块化拼接方式渲染3x3x3建筑

# 渲染配置
var cell_size: Vector3 = Vector3(0.33, 0.33, 0.33)
var mesh_library: MeshLibrary = null
var current_template: BuildingTemplate = null

# LOD系统
var lod_level: int = 2  # 0=最低, 1=中等, 2=最高
var lod_enabled: bool = true

# 性能优化
var batch_update_enabled: bool = true
var pending_updates: Array = []


func _init():
	"""初始化GridMap渲染器"""
	name = "GridMapRenderer"
	
	# 配置GridMap属性
	self.cell_size = cell_size
	self.cell_center_x = true
	self.cell_center_y = false  # 底部对齐
	self.cell_center_z = true


func _ready():
	"""场景准备就绪"""
	# 设置碰撞层
	collision_layer = 0
	collision_mask = 0


func set_mesh_library(library: MeshLibrary):
	"""设置MeshLibrary"""
	mesh_library = library
	self.mesh_library = library


func apply_template(template: BuildingTemplate):
	"""应用建筑模板"""
	if not template:
		LogManager.warning("⚠️ [GridMapRenderer] 模板为空")
		return
	
	current_template = template
	
	# 清空现有内容
	clear()
	
	# 批量更新开始
	if batch_update_enabled:
		start_batch_update()
	
	# 应用模板
	_apply_template_data(template)
	
	# 批量更新结束
	if batch_update_enabled:
		end_batch_update()
	
	LogManager.info("✅ [GridMapRenderer] 已应用模板: %s" % template.name)


func _apply_template_data(template: BuildingTemplate):
	"""应用模板数据"""
	for y in range(3):
		for z in range(3):
			for x in range(3):
				var component_id = template.get_component(x, y, z)
				if component_id != BuildingComponents.ID_EMPTY:
					_set_cell_component(x, y, z, component_id)


func _set_cell_component(x: int, y: int, z: int, component_id: int):
	"""设置单元格构件"""
	# 检查构件是否存在于MeshLibrary中
	if not mesh_library or not mesh_library.has_item(component_id):
		LogManager.warning("⚠️ [GridMapRenderer] 构件不存在: ID %d" % component_id)
		return
	
	# 根据LOD级别决定是否放置构件
	if lod_enabled and not _should_render_component(component_id):
		return
	
	# 设置单元格
	set_cell_item(Vector3i(x, y, z), component_id, 0)


func _should_render_component(component_id: int) -> bool:
	"""根据LOD级别判断是否应该渲染构件"""
	match lod_level:
		0:  # 最低细节：只渲染主要结构
			return _is_essential_component(component_id)
		1:  # 中等细节：渲染主要结构和重要装饰
			return _is_essential_component(component_id) or _is_important_component(component_id)
		2:  # 最高细节：渲染所有构件
			return true
		_:
			return true


func _is_essential_component(component_id: int) -> bool:
	"""检查是否为必要构件（结构构件）"""
	return BuildingComponents.is_wall_component(component_id) or \
		   BuildingComponents.is_floor_component(component_id) or \
		   BuildingComponents.is_roof_component(component_id)


func _is_important_component(component_id: int) -> bool:
	"""检查是否为重要构件（门窗）"""
	return BuildingComponents.is_door_component(component_id) or \
		   BuildingComponents.is_window_component(component_id)


func start_batch_update():
	"""开始批量更新"""
	pending_updates.clear()


func end_batch_update():
	"""结束批量更新"""
	# 应用所有待处理的更新
	for update in pending_updates:
		_apply_pending_update(update)
	
	pending_updates.clear()


func _apply_pending_update(update: Dictionary):
	"""应用待处理的更新"""
	var pos = update.get("position", Vector3i.ZERO)
	var component_id = update.get("component_id", BuildingComponents.ID_EMPTY)
	var rotation = update.get("rotation", 0)
	
	set_cell_item(pos, component_id, rotation)


func set_lod_level(level: int):
	"""设置LOD级别"""
	if lod_level == level:
		return
	
	lod_level = level
	
	# 重新应用当前模板以更新LOD
	if current_template:
		apply_template(current_template)
	
	LogManager.debug("🔧 [GridMapRenderer] LOD级别已更新: %d" % lod_level)


func enable_lod(enabled: bool):
	"""启用/禁用LOD系统"""
	lod_enabled = enabled
	
	# 重新应用当前模板
	if current_template:
		apply_template(current_template)


func clear():
	"""清空GridMap内容"""
	super.clear()


func get_cell_component(x: int, y: int, z: int) -> int:
	"""获取指定位置的构件ID"""
	var cell_item = get_cell_item(Vector3i(x, y, z))
	return cell_item if cell_item != INVALID_CELL_ITEM else BuildingComponents.ID_EMPTY


func get_building_bounds() -> AABB:
	"""获取建筑边界"""
	if not current_template:
		return AABB()
	
	# 计算建筑的实际边界
	var min_pos = Vector3.ZERO
	var max_pos = Vector3(3, 3, 3) * cell_size
	
	return AABB(min_pos, max_pos - min_pos)


func get_component_count(component_id: int) -> int:
	"""获取指定构件的数量"""
	var count = 0
	
	for y in range(3):
		for z in range(3):
			for x in range(3):
				if get_cell_component(x, y, z) == component_id:
					count += 1
	
	return count


func get_building_statistics() -> Dictionary:
	"""获取建筑统计信息"""
	if not current_template:
		return {}
	
	var stats = {
		"template_name": current_template.name,
		"total_cells": 27,  # 3x3x3 = 27
		"empty_cells": 0,
		"component_counts": {}
	}
	
	# 统计各构件数量
	for y in range(3):
		for z in range(3):
			for x in range(3):
				var component_id = get_cell_component(x, y, z)
				if component_id == BuildingComponents.ID_EMPTY:
					stats.empty_cells += 1
				else:
					var component_name = BuildingComponents.get_component_name(component_id)
					if not stats.component_counts.has(component_name):
						stats.component_counts[component_name] = 0
					stats.component_counts[component_name] += 1
	
	return stats


func print_building_structure():
	"""打印建筑结构（调试用）"""
	if not current_template:
		LogManager.info("⚠️ [GridMapRenderer] 没有应用模板")
		return
	
	LogManager.info("=== GridMap建筑结构: %s ===" % current_template.name)
	for y in range(2, -1, -1):  # 从顶层开始打印
		LogManager.info("层 %d (Y=%d):" % [y, y])
		for z in range(3):
			var row = ""
			for x in range(3):
				var component_id = get_cell_component(x, y, z)
				var component_name = BuildingComponents.get_component_name(component_id)
				row += "[%s] " % component_name.substr(0, 3)  # 只显示前3个字符
			LogManager.info("  %s" % row)
	LogManager.info("===============================")


func optimize_for_performance():
	"""性能优化"""
	# 合并相同构件的网格
	_merge_identical_components()
	
	# 简化LOD
	if lod_level > 1:
		set_lod_level(1)


func _merge_identical_components():
	"""合并相同构件的网格（性能优化）"""
	# 这里可以实现网格合并逻辑
	# 目前Godot的GridMap已经做了优化，暂时不需要额外处理
	pass


func update_component_at(x: int, y: int, z: int, new_component_id: int):
	"""更新指定位置的构件"""
	if not _is_valid_position(x, y, z):
		LogManager.warning("⚠️ [GridMapRenderer] 位置无效: (%d, %d, %d)" % [x, y, z])
		return
	
	# 检查构件是否存在
	if not mesh_library or not mesh_library.has_item(new_component_id):
		LogManager.warning("⚠️ [GridMapRenderer] 构件不存在: ID %d" % new_component_id)
		return
	
	# 更新单元格
	set_cell_item(Vector3i(x, y, z), new_component_id, 0)
	
	# 更新模板（如果存在）
	if current_template:
		current_template.set_component(x, y, z, new_component_id)
	
	LogManager.debug("🔧 [GridMapRenderer] 已更新构件: (%d, %d, %d) -> %s" % [
		x, y, z, BuildingComponents.get_component_name(new_component_id)
	])


func _is_valid_position(x: int, y: int, z: int) -> bool:
	"""检查位置是否有效"""
	return x >= 0 and x < 3 and y >= 0 and y < 3 and z >= 0 and z < 3


func get_render_info() -> Dictionary:
	"""获取渲染信息"""
	return {
		"renderer_type": "GridMapRenderer",
		"cell_size": cell_size,
		"mesh_library_items": mesh_library.get_item_list().size() if mesh_library else 0,
		"lod_level": lod_level,
		"lod_enabled": lod_enabled,
		"batch_update_enabled": batch_update_enabled,
		"current_template": current_template.name if current_template else "None"
	}
