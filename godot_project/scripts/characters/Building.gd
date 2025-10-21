extends Node3D
class_name Building

# 建筑基类 - 所有建筑的父类
# 参考 BUILDING_SYSTEM.md
#
# 🔧 [重构] 建筑状态常量已迁移到 BuildingStatus autoload

# 建筑基础属性
var building_id: String = ""
var building_name: String = ""
var building_type # 使用 BuildingTypes
var tile_x: int = 0
var tile_y: int = 0

# 建筑状态（使用 BuildingStatus autoload 常量）
var status: int = BuildingStatus.PLANNING
var build_progress: float = 0.0 # 建造进度（0.0 - 1.0）
var construction_gold_invested: int = 0 # 已投入的金币数量

# 建筑属性
var max_health: int = 100
var health: int = 100
var armor: int = 0
var is_active: bool = true

# 建筑尺寸（用于碰撞和交互范围）
var building_size: Vector2 = Vector2(1, 1) # 单位：格子数（1格 = 1单位）
var interaction_range: float = 0.01 # 基础交互范围（只需比碰撞距离稍大即可）

# 建造成本
var cost_gold: int = 0
var engineer_cost: int = 0
var build_time: float = 0.0
var engineer_required: int = 1

# 工程师管理
var assigned_engineers: Array = []

# 管理器引用
var resource_manager = null
var building_manager = null

# 🔧 [状态栏系统] 建筑状态栏（用于显示存储的金币数量）
var status_bar: Node3D = null

# 🔧 [存储系统] 存储建筑属性（子类会重写这些值）
var stored_gold: int = 0
var gold_storage_capacity: int = 0


func _init():
	"""初始化建筑"""
	pass


func _ready():
	"""场景准备就绪"""
	# 🔧 [建筑渲染系统] 参考金矿设计，严格限制建筑大小
	_setup_collision_and_interaction()
	
	# 🔧 [建造系统] 创建视觉表现
	_setup_visual()
	
	# ✅ [Step 7] 所有建筑都添加到通用组
	add_to_group(GameGroups.BUILDINGS)
	add_to_group(GameGroups.INTERACTABLE)
	
	# 🔧 [状态栏系统] 为存储建筑创建状态栏
	call_deferred("_setup_storage_status_bar")


func _setup_collision_and_interaction():
	"""设置碰撞体积和交互区域（参考金矿设计）
	
	🔧 [建筑渲染系统] 参考金矿的碰撞和交互设计：
	- Collision: StaticBody3D(1x1) 在 Layer 4（建筑层）
	- Interaction: Area3D(1.4x1.4) 监测 Layer 2（单位层）
	- 1x1建筑严格限制在1x1范围内
	"""
	# 1. 创建碰撞体（StaticBody3D）
	var static_body = StaticBody3D.new()
	static_body.name = "BuildingCollision"
	
	# 🔧 设置物理层：Layer 4（建筑层）
	static_body.collision_layer = 0
	static_body.set_collision_layer_value(4, true) # 建筑层
	static_body.collision_mask = 0 # 不主动检测其他物体
	
	# 创建碰撞形状（1x1 严格范围）
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(building_size.x, 0.8, building_size.y) # 高度0.8米
	collision_shape.shape = box_shape
	collision_shape.position = Vector3(0, 0.4, 0) # 碰撞体中心在Y=0.4
	
	static_body.add_child(collision_shape)
	add_child(static_body)
	
	# 2. 创建交互区域（Area3D）
	var interaction_area = Area3D.new()
	interaction_area.name = "BuildingInteractionArea"
	
	# 🔧 启用监控
	interaction_area.monitoring = true
	interaction_area.monitorable = false
	
	# 🔧 交互范围：1.4x1.4（覆盖相邻格子边缘）
	var interaction_size = Vector3(
		building_size.x + 0.4,
		1.0,
		building_size.y + 0.4
	)
	
	var area_shape = CollisionShape3D.new()
	var area_box = BoxShape3D.new()
	area_box.size = interaction_size
	area_shape.shape = area_box
	area_shape.position = Vector3(0, 0.5, 0) # Area3D中心
	
	interaction_area.add_child(area_shape)
	add_child(interaction_area)
	
	# 🔧 设置碰撞层：不在任何层，只监测单位
	interaction_area.collision_layer = 0
	interaction_area.collision_mask = 0
	interaction_area.set_collision_mask_value(2, true) # 监测Layer 2（单位）
	
	# 添加到交互区域组
	interaction_area.add_to_group(GameGroups.INTERACTION_ZONES)
	interaction_area.set_meta("building_type", building_type)
	interaction_area.set_meta("building_name", building_name)
	interaction_area.set_meta("building_position", global_position)


func _setup_visual():
	"""设置建筑视觉效果
	
	🔧 [建造系统] 根据建筑状态自动创建视觉表现
	- PLANNING/UNDER_CONSTRUCTION: 虚化半透明（蓝色）
	- COMPLETED: 实体（正常颜色）
	"""
	# 检查是否已有Model节点（场景中预设）
	if has_node("Model"):
		_update_existing_visual()
		return
	
	# 自动创建默认视觉（简单立方体）
	_create_default_visual()


func _create_default_visual():
	"""创建默认视觉（简单立方体）
	
	🔧 [建筑渲染系统] 参考金矿设计：
	- 1x1建筑：严格限制在1.0x0.8x1.0范围内
	- 2x2建筑：2.0x0.8x2.0范围
	- Mesh中心对齐建筑position
	"""
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "Model"
	
	# 🔧 创建立方体mesh（严格限制大小）
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(
		building_size.x, # 1x1建筑 = 1.0米
		0.8, # 固定高度0.8米
		building_size.y
	)
	mesh_instance.mesh = box_mesh
	
	# 🔧 Mesh位置：相对于Building节点的偏移
	# Building的global_position应该是格子中心(x+0.5, 0.05, z+0.5)
	# Mesh底部应该在Y=0，中心在Y=0.4
	# 相对于Building(Y=0.05)的偏移 = 0.4 - 0.05 = 0.35
	mesh_instance.position = Vector3(0, 0.35, 0)
	
	# 创建材质（根据建筑类型和状态）
	var material = StandardMaterial3D.new()
	
	if status == BuildingStatus.PLANNING or status == BuildingStatus.UNDER_CONSTRUCTION:
		# 🔧 虚化效果：半透明蓝色
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color(0.3, 0.5, 0.9, 0.4) # 蓝色半透明
		
		# 添加边缘发光
		material.emission_enabled = true
		material.emission = Color(0.1, 0.3, 0.7)
		material.emission_energy = 0.5
	else:
		# 🔧 实体效果：根据建筑类型使用不同颜色
		material.albedo_color = _get_building_color()
		material.roughness = 0.7
		material.metallic = 0.2
	
	mesh_instance.material_override = material
	
	add_child(mesh_instance)


func _update_existing_visual():
	"""更新已有视觉节点
	
	🔧 [建造系统] 如果场景中已有Model节点，更新其材质
	"""
	var model = get_node("Model")
	if not model is MeshInstance3D:
		return
	
	# 获取或创建材质
	var material = model.material_override
	if not material:
		material = StandardMaterial3D.new()
		model.material_override = material
	
	# 根据状态更新材质
	if status == BuildingStatus.PLANNING or status == BuildingStatus.UNDER_CONSTRUCTION:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(0.3, 0.5, 0.9, 0.4 + build_progress * 0.6)
	else:
		material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		material.albedo_color = Color(0.5, 0.4, 0.3)


func update_visual_by_progress():
	"""根据建造进度更新视觉
	
	🔧 [建造系统] 建造过程中逐渐变实体
	"""
	if not has_node("Model"):
		return
	
	var model = get_node("Model")
	if not model is MeshInstance3D:
		return
	
	var material = model.material_override
	if not material:
		return
	
	# 透明度从0.4逐渐到1.0
	var alpha = 0.4 + build_progress * 0.6
	material.albedo_color.a = alpha


func _update_visual_to_completed():
	"""更新视觉为完全实体
	
	🔧 [建造系统] 建造完成时，移除透明度和发光效果
	"""
	if not has_node("Model"):
		return
	
	var model = get_node("Model")
	if not model is MeshInstance3D:
		return
	
	var material = model.material_override
	if not material:
		return
	
	# 完全不透明
	material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	material.albedo_color = _get_building_color()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	
	# 移除发光效果
	material.emission_enabled = false
	material.emission_energy = 0.0


func _get_building_color() -> Color:
	"""根据建筑类型返回颜色
	
	🎨 [建筑渲染系统] 参考 BUILDING_SYSTEM.md 的颜色定义
	"""
	# 使用建筑类型枚举
	match building_type:
		BuildingTypes.BuildingType.TREASURY:
			return Color(1.0, 0.84, 0.0) # 金黄色 (#FFD700)
		BuildingTypes.BuildingType.TRAINING_ROOM:
			return Color(0.44, 0.5, 0.56) # 铁灰色 (#708090)
		BuildingTypes.BuildingType.LIBRARY:
			return Color(0.1, 0.1, 0.44) # 深蓝色 (#191970)
		BuildingTypes.BuildingType.LAIR:
			return Color(0.4, 0.26, 0.13) # 深棕色 (#654321)
		BuildingTypes.BuildingType.DEMON_LAIR:
			return Color(0.29, 0.0, 0.51) # 靛青色 (#4B0082)
		BuildingTypes.BuildingType.ORC_LAIR:
			return Color(0.55, 0.27, 0.07) # 马鞍棕色 (#8B4513)
		BuildingTypes.BuildingType.ARROW_TOWER:
			return Color(0.83, 0.83, 0.83) # 石灰色 (#D3D3D3)
		BuildingTypes.BuildingType.ARCANE_TOWER:
			return Color(0.54, 0.17, 0.89) # 紫色 (#8A2BE2)
		BuildingTypes.BuildingType.MAGIC_ALTAR:
			return Color(0.6, 0.4, 0.8) # 浅紫色（魔法）
		BuildingTypes.BuildingType.WORKSHOP:
			return Color(0.6, 0.5, 0.4) # 工坊棕
		_:
			return Color(0.5, 0.4, 0.3) # 默认建筑棕色


# ===== 建筑状态管理 =====

func needs_construction() -> bool:
	"""检查是否需要建造
	
	🔧 [建造系统] 判断建筑是否处于建造阶段
	"""
	return status == BuildingStatus.UNDER_CONSTRUCTION or status == BuildingStatus.PLANNING


func get_construction_cost_remaining() -> int:
	"""获取剩余建造成本
	
	🔧 [建造系统] 返回还需要投入的金币数量
	"""
	return max(0, cost_gold - construction_gold_invested)


func add_construction_progress(gold_amount: int) -> int:
	"""添加建造进度（工程师投入金币）
	
	🔧 [建造系统] 工程师每次投入金币推进建造进度
	
	Args:
		gold_amount: 工程师携带的金币数量
	
	Returns:
		int: 实际消耗的金币数量
	"""
	if status != BuildingStatus.UNDER_CONSTRUCTION and status != BuildingStatus.PLANNING:
		return 0
	
	# 切换到建造中状态
	if status == BuildingStatus.PLANNING:
		status = BuildingStatus.UNDER_CONSTRUCTION
		LogManager.info("🏗️ 开始建造: %s" % building_name)
	
	# 计算还需要多少金币
	var remaining_cost = get_construction_cost_remaining()
	var gold_to_invest = min(gold_amount, remaining_cost)
	
	# 投入金币
	construction_gold_invested += gold_to_invest
	
	# 更新建造进度（0.0 - 1.0）
	if cost_gold > 0:
		build_progress = float(construction_gold_invested) / float(cost_gold)
	
	# 🔧 [建造系统] 更新视觉表现（逐渐变实体）
	update_visual_by_progress()
	
	# 检查是否建造完成
	if construction_gold_invested >= cost_gold:
		_complete_construction()
	
	return gold_to_invest


func _complete_construction() -> void:
	"""建造完成
	
	🔧 [建造系统] 建筑建造完成后的初始化
	"""
	status = BuildingStatus.COMPLETED
	build_progress = 1.0
	health = max_health
	is_active = true
	
	# 🔧 [建造系统] 更新视觉为完全实体
	_update_visual_to_completed()
	
	LogManager.info("✅ 建造完成: %s" % building_name)
	
	# 触发建造完成事件（子类可重写）
	_on_construction_completed()


func _on_construction_completed() -> void:
	"""建造完成回调（子类重写）"""
	pass


func needs_repair() -> bool:
	"""检查是否需要维修"""
	return health < max_health and status == BuildingStatus.COMPLETED


func get_repair_cost() -> int:
	"""获取维修成本"""
	var missing_health = max_health - health
	return int(missing_health * (cost_gold * 0.001))


func repair(amount: int):
	"""维修建筑"""
	var repair_amount = min(amount, max_health - health)
	health += repair_amount
	if health >= max_health:
		status = BuildingStatus.COMPLETED


func take_damage(amount: int):
	"""受到伤害"""
	var actual_damage = max(1, amount - armor)
	health -= actual_damage
	
	if health <= 0:
		health = 0
		status = BuildingStatus.DESTROYED
		_on_destroyed()
	elif health < max_health * 0.5:
		status = BuildingStatus.DAMAGED


func is_destroyed() -> bool:
	"""检查建筑是否被摧毁
	
	🔧 [建造系统] 用于工程师状态机判断
	"""
	return status == BuildingStatus.DESTROYED or not is_active


func _on_destroyed():
	"""建筑被摧毁时的回调"""
	is_active = false
	LogManager.info("建筑被摧毁: " + building_name)


# ===== 工程师管理 =====

func can_accept_engineer() -> bool:
	"""检查是否可以接受工程师"""
	return assigned_engineers.size() < engineer_required


func assign_engineer(engineer) -> bool:
	"""分配工程师"""
	if not can_accept_engineer():
		return false
	
	if engineer not in assigned_engineers:
		assigned_engineers.append(engineer)
		return true
	return false


func remove_engineer(engineer):
	"""移除工程师"""
	var index = assigned_engineers.find(engineer)
	if index >= 0:
		assigned_engineers.erase(engineer)


# ===== 交互范围检查 =====

func is_in_interaction_range(target_position: Vector3, unit_collision_radius: float = 0.0) -> bool:
	"""检查目标位置是否在交互范围内
	
	【边缘距离判定】基于物体边缘的实际距离，而不是中心距离
	
	计算公式：
	1. 中心距离 = distance(单位中心, 建筑中心)
	2. 碰撞距离 = 单位半径 + 建筑半径
	3. 边缘距离 = 中心距离 - 碰撞距离
	4. 判定：边缘距离 <= 交互范围
	
	等价于：中心距离 <= 碰撞距离 + 交互范围
	
	Args:
		target_position: 单位的中心位置
		unit_collision_radius: 单位的碰撞半径
	
	Returns:
		bool: 是否在交互范围内
	"""
	# 计算XZ平面的中心距离
	var center_distance = Vector2(
		target_position.x - position.x,
		target_position.z - position.z
	).length()
	
	# 建筑半径 = max(宽度, 长度) / 2
	var building_radius = max(building_size.x, building_size.y) / 2.0
	
	# 碰撞距离 = 两个物体接触时的中心距离
	var collision_distance = building_radius + unit_collision_radius
	
	# 边缘距离 = 中心距离 - 碰撞距离
	var edge_distance = center_distance - collision_distance
	
	# 交互判定：边缘距离 <= 交互范围
	var can_interact = edge_distance <= interaction_range
	
	return can_interact


func get_interaction_range() -> float:
	"""获取基础交互范围（不包含建筑和单位大小）
	
	[物理迁移] 返回基础交互范围，实际交互需要考虑建筑和单位的碰撞半径
	"""
	return interaction_range


func get_effective_interaction_range(unit_collision_radius: float = 0.0) -> float:
	"""获取有效交互范围（包含建筑和单位大小）
	
	[物理迁移] 新增方法，计算实际的交互中心距离阈值
	
	Args:
		unit_collision_radius: 单位的碰撞半径
	
	Returns:
		float: 有效交互的中心距离阈值
	"""
	var building_radius = max(building_size.x, building_size.y) / 2.0
	return interaction_range + building_radius + unit_collision_radius


# ===== 更新逻辑 =====

func update_building(delta: float):
	"""更新建筑（每帧调用）"""
	if not is_active:
		return
	
	# 子类可以重写此方法实现特定逻辑
	_update_logic(delta)


func _update_logic(_delta: float):
	"""建筑特定的更新逻辑（子类重写）"""
	pass


# ===== 调试信息 =====

func get_building_info() -> Dictionary:
	"""获取建筑信息"""
	return {
		"id": building_id,
		"name": building_name,
		"type": building_type,
		"position": position,
		"size": building_size,
		"status": status,
		"health": health,
		"max_health": max_health,
		"interaction_range": get_interaction_range(),
		"assigned_engineers": assigned_engineers.size(),
		"is_active": is_active
	}

## 🔧 获取建筑大小（瓦片数量）
func get_building_size() -> Vector2:
	"""获取建筑大小（瓦片数量）
	
	🔧 [修复] 为MovementHelper提供正确的建筑大小信息
	"""
	return building_size

# ============================================================================
# 🔧 [状态栏系统] 建筑存储状态栏
# ============================================================================

func _setup_storage_status_bar() -> void:
	"""为存储建筑创建状态栏"""
	# 只对存储建筑创建状态栏
	if not _is_storage_building():
		return
	
	# UnitStatusBar.gd已被删除，状态栏功能已整合到建筑系统中
	# 如果需要状态栏功能，请使用内置的UI系统
	# 初始化日志已移除，避免重复输出
	
	# 初始化显示
	_update_storage_display()


func _is_storage_building() -> bool:
	"""检查是否为存储建筑"""
	return building_type in [BuildingTypes.BuildingType.DUNGEON_HEART, BuildingTypes.BuildingType.TREASURY]


func _update_storage_display() -> void:
	"""更新存储显示"""
	if not status_bar or not is_instance_valid(status_bar):
		return
	
	# 获取存储信息
	var current_gold = stored_gold
	var max_gold = gold_storage_capacity
	
	# 更新状态栏显示
	if status_bar.has_method("update_storage"):
		status_bar.update_storage(current_gold, max_gold)
	elif status_bar.has_method("update_gold"):
		# 使用金币显示方法，显示格式为 "当前/最大"
		status_bar.update_gold(current_gold)
		# 如果有文本标签，更新为 "当前/最大" 格式
		if status_bar.has_method("set_storage_text"):
			status_bar.set_storage_text("%d/%d" % [current_gold, max_gold])
