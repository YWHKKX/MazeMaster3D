extends Node
class_name PhysicsSystem

## 🌍 War for the Overworld - 完整物理系统
## 基于PHYSICS_SYSTEM.md设计的统一物理系统
## 包含碰撞检测、击退效果、体型物理和环境交互

# 预加载子系统类
const CollisionSystem = preload("res://scripts/managers/CollisionSystem.gd")
const KnockbackSystem = preload("res://scripts/managers/KnockbackSystem.gd")
const SizeBasedPhysics = preload("res://scripts/managers/SizeBasedPhysics.gd")

# 系统组件
var collision_system: CollisionSystem
var knockback_system: KnockbackSystem
var size_physics: SizeBasedPhysics

# 物理配置
var physics_config = {
	# 碰撞检测配置
	# [修复] 更新为正确的碰撞半径计算：(size/100) * 0.4 = size * 0.004
	"collision_radius_factor": 0.004, # 碰撞半径 = 单位大小 × 0.004 (考虑size/100转换)
	"min_collision_radius": 0.15, # 最小0.15格（防止太小导致卡住）
	"max_collision_radius": 0.5, # 最大0.5格
	"collision_precision": 0.01, # 精度0.01格
	
	# 击退配置
	"weak_knockback_distance": 8.0,
	"normal_knockback_distance": 15.0,
	"strong_knockback_distance": 30.0,
	"knockback_duration": 0.3,
	"knockback_speed": 50.0,
	
	# 空间哈希配置
	"spatial_hash_cell_size": 50.0,
	"max_units_per_cell": 20,
	
	# 更新配置
	"update_frequency": 60.0,
	"physics_delta": 1.0 / 60.0
}

# 注册的单位
var registered_units: Dictionary = {} # unit_id -> unit_data
var spatial_hash: Dictionary = {} # cell_key -> Array[unit_ids]

# 性能监控
var performance_stats = {
	"frame_time": 0.0,
	"collision_checks": 0,
	"knockback_updates": 0,
	"spatial_hash_queries": 0,
	"last_update_time": 0.0
}

# 击退类型枚举
enum KnockbackType {
	NORMAL = 0, # 普通击退 (15像素)
	STRONG = 1, # 强击退 (30像素)
	WEAK = 2, # 弱击退 (8像素)
	NONE = 3 # 无击退 (0像素)
}

# 体型分类枚举
enum SizeCategory {
	MICRO = 0, # 超小型 (≤12)
	SMALL = 1, # 小型 (13-17)
	MEDIUM = 2, # 中型 (18-25)
	LARGE = 3 # 大型 (>25)
}

func _ready():
	"""初始化物理系统"""
	LogManager.info("PhysicsSystem - 物理系统初始化开始")
	
	# 初始化子系统
	_initialize_subsystems()
	
	# 设置更新频率
	Engine.max_fps = int(physics_config.update_frequency)
	
	LogManager.info("PhysicsSystem - 物理系统初始化完成")

func _initialize_subsystems():
	"""初始化所有子系统"""
	# 创建碰撞系统
	collision_system = CollisionSystem.new()
	collision_system.name = "CollisionSystem"
	add_child(collision_system)
	
	# 创建击退系统
	knockback_system = KnockbackSystem.new()
	knockback_system.name = "KnockbackSystem"
	add_child(knockback_system)
	# 传递单位数据访问接口
	knockback_system.set_physics_system(self)
	
	# 创建体型物理系统
	size_physics = SizeBasedPhysics.new()
	size_physics.name = "SizeBasedPhysics"
	add_child(size_physics)
	
	LogManager.info("PhysicsSystem - 所有子系统初始化完成")

func _process(delta: float):
	"""物理系统主循环"""
	var start_time = Time.get_ticks_usec()
	
	# 更新击退效果
	if knockback_system:
		knockback_system.update_knockbacks(delta)
		performance_stats.knockback_updates = knockback_system.get_active_knockback_count()
	
	# 更新碰撞检测
	if collision_system:
		collision_system.update_collisions(delta, registered_units, spatial_hash)
		performance_stats.collision_checks = collision_system.get_collision_check_count()
	
	# 记录帧时间
	var end_time = Time.get_ticks_usec()
	performance_stats.frame_time = (end_time - start_time) / 1000.0 # 转换为毫秒
	performance_stats.last_update_time = Time.get_ticks_msec()

# =============================================================================
# 单位注册管理
# =============================================================================

func register_unit(unit_id: String, unit_node: Node3D, unit_data: Dictionary):
	"""注册单位到物理系统"""
	# 计算碰撞半径
	var collision_radius = _calculate_collision_radius(unit_data.get("size", 15))
	
	# 创建单位数据
	var physics_data = {
		"unit_id": unit_id,
		"unit_node": unit_node,
		"position": unit_node.position,
		"size": unit_data.get("size", 15),
		"collision_radius": collision_radius,
		"size_category": _get_size_category(unit_data.get("size", 15)),
		"knockback_resistance": _get_knockback_resistance(unit_data.get("size", 15)),
		"knockback_type": unit_data.get("knockback_type", KnockbackType.NORMAL),
		"has_strong_knockback": unit_data.get("has_strong_knockback", false),
		"has_weak_knockback": unit_data.get("has_weak_knockback", false),
		"has_no_knockback": unit_data.get("has_no_knockback", false),
		"is_knocked_back": false,
		"knockback_state": null
	}
	
	# 注册到系统
	registered_units[unit_id] = physics_data
	_add_to_spatial_hash(unit_id, unit_node.position)

func unregister_unit(unit_id: String):
	"""从物理系统注销单位"""
	if unit_id in registered_units:
		_remove_from_spatial_hash(unit_id)
		registered_units.erase(unit_id)

func update_unit_position(unit_id: String, new_position: Vector3):
	"""更新单位位置"""
	if unit_id in registered_units:
		registered_units[unit_id].position = new_position
		
		# 更新空间哈希
		_remove_from_spatial_hash(unit_id)
		_add_to_spatial_hash(unit_id, new_position)

# =============================================================================
# 碰撞检测API
# =============================================================================

func check_collision(unit_id: String, target_id: String) -> bool:
	"""检查两个单位是否碰撞"""
	if unit_id not in registered_units or target_id not in registered_units:
		return false
	
	var unit_data = registered_units[unit_id]
	var target_data = registered_units[target_id]
	
	return collision_system.check_collision(unit_data, target_data)

func get_collision_radius(unit_id: String) -> float:
	"""获取单位碰撞半径"""
	if unit_id in registered_units:
		return registered_units[unit_id].collision_radius
	return physics_config.min_collision_radius

func get_nearby_units(unit_id: String, radius: float) -> Array:
	"""获取附近的单位"""
	if unit_id not in registered_units:
		return []
	
	var unit_position = registered_units[unit_id].position
	return collision_system.get_nearby_units(unit_position, radius, registered_units, spatial_hash)

# =============================================================================
# 击退系统API
# =============================================================================

func apply_knockback(attacker_id: String, target_id: String, damage: float, is_critical: bool = false):
	"""应用击退效果"""
	if attacker_id not in registered_units or target_id not in registered_units:
		return false
	
	var attacker_data = registered_units[attacker_id]
	var target_data = registered_units[target_id]
	
	# 确定击退类型
	var knockback_type = _determine_knockback_type(attacker_data, is_critical)
	
	# 应用击退
	var success = knockback_system.apply_knockback(attacker_data, target_data, knockback_type, damage)
	
	if success:
		# 更新目标状态
		target_data.is_knocked_back = true
		target_data.knockback_state = knockback_system.get_knockback_state(target_id)
	
	return success

func is_unit_knocked_back(unit_id: String) -> bool:
	"""检查单位是否处于击退状态"""
	if unit_id in registered_units:
		return registered_units[unit_id].is_knocked_back
	return false

func get_knockback_info(unit_id: String) -> Dictionary:
	"""获取单位击退信息"""
	if unit_id not in registered_units:
		return {}
	
	var unit_data = registered_units[unit_id]
	return {
		"knockback_type": unit_data.knockback_type,
		"has_strong_knockback": unit_data.has_strong_knockback,
		"has_weak_knockback": unit_data.has_weak_knockback,
		"has_no_knockback": unit_data.has_no_knockback,
		"knockback_resistance": unit_data.knockback_resistance,
		"available_types": _get_available_knockback_types(unit_data),
		"distances": _get_knockback_distances()
	}

# =============================================================================
# 体型物理API
# =============================================================================

func get_size_category(size: int) -> SizeCategory:
	"""获取体型分类"""
	return _get_size_category(size)

func get_knockback_resistance(size: int) -> float:
	"""获取击退抗性"""
	return _get_knockback_resistance(size)

func calculate_knockback_distance(attacker_size: int, target_size: int, knockback_type: KnockbackType) -> float:
	"""计算击退距离"""
	return size_physics.calculate_knockback_distance(attacker_size, target_size, knockback_type, physics_config)

# =============================================================================
# 内部辅助函数
# =============================================================================

func _calculate_collision_radius(size: int) -> float:
	"""计算碰撞半径"""
	var radius = size * physics_config.collision_radius_factor
	return clamp(radius, physics_config.min_collision_radius, physics_config.max_collision_radius)

func _get_size_category(size: int) -> SizeCategory:
	"""获取体型分类"""
	if size <= 12:
		return SizeCategory.MICRO
	elif size <= 17:
		return SizeCategory.SMALL
	elif size <= 25:
		return SizeCategory.MEDIUM
	else:
		return SizeCategory.LARGE

func _get_knockback_resistance(size: int) -> float:
	"""获取击退抗性"""
	match _get_size_category(size):
		SizeCategory.MICRO:
			return 0.5
		SizeCategory.SMALL:
			return 0.7
		SizeCategory.MEDIUM:
			return 1.0
		SizeCategory.LARGE:
			return 1.5
		_:
			return 1.0

func _determine_knockback_type(attacker_data: Dictionary, is_critical: bool) -> KnockbackType:
	"""确定击退类型"""
	# 显式设置优先
	if attacker_data.has("knockback_type") and attacker_data.knockback_type != KnockbackType.NORMAL:
		return attacker_data.knockback_type
	
	# 强击退能力
	if attacker_data.has_strong_knockback:
		return KnockbackType.STRONG if is_critical else KnockbackType.NORMAL
	
	# 弱击退能力
	if attacker_data.has_weak_knockback:
		return KnockbackType.WEAK
	
	# 无击退能力
	if attacker_data.has_no_knockback:
		return KnockbackType.NONE
	
	# 默认普通击退
	return KnockbackType.NORMAL

func _get_available_knockback_types(unit_data: Dictionary) -> Array:
	"""获取可用的击退类型"""
	var types = []
	
	if unit_data.has_strong_knockback:
		types.append(KnockbackType.STRONG)
	if unit_data.has_weak_knockback:
		types.append(KnockbackType.WEAK)
	if unit_data.has_no_knockback:
		types.append(KnockbackType.NONE)
	
	if types.is_empty():
		types.append(KnockbackType.NORMAL)
	
	return types

func _get_knockback_distances() -> Dictionary:
	"""获取击退距离"""
	return {
		"weak": physics_config.weak_knockback_distance,
		"normal": physics_config.normal_knockback_distance,
		"strong": physics_config.strong_knockback_distance
	}

# =============================================================================
# 空间哈希管理
# =============================================================================

func _add_to_spatial_hash(unit_id: String, position: Vector3):
	"""添加单位到空间哈希"""
	var cell_key = _get_cell_key(position)
	if cell_key not in spatial_hash:
		spatial_hash[cell_key] = []
	
	if unit_id not in spatial_hash[cell_key]:
		spatial_hash[cell_key].append(unit_id)

func _remove_from_spatial_hash(unit_id: String):
	"""从空间哈希移除单位"""
	for cell_key in spatial_hash:
		if unit_id in spatial_hash[cell_key]:
			spatial_hash[cell_key].erase(unit_id)
			break

func _get_cell_key(position: Vector3) -> String:
	"""获取空间哈希单元格键值"""
	var cell_x = int(position.x / physics_config.spatial_hash_cell_size)
	var cell_z = int(position.z / physics_config.spatial_hash_cell_size)
	return str(cell_x) + "," + str(cell_z)

# =============================================================================
# 调试和统计
# =============================================================================

func get_physics_stats() -> Dictionary:
	"""获取物理系统统计信息"""
	return {
		"registered_units": registered_units.size(),
		"spatial_hash_cells": spatial_hash.size(),
		"active_knockbacks": knockback_system.get_active_knockback_count() if knockback_system else 0,
		"collision_checks_per_frame": collision_system.get_collision_check_count() if collision_system else 0,
		"frame_time_ms": performance_stats.frame_time,
		"last_update_time": performance_stats.last_update_time
	}

func get_performance_stats() -> Dictionary:
	"""获取详细的性能统计信息"""
	var stats = performance_stats.duplicate()
	stats["fps"] = Engine.get_frames_per_second()
	stats["registered_units"] = registered_units.size()
	stats["spatial_hash_cells"] = spatial_hash.size()
	stats["avg_units_per_cell"] = float(registered_units.size()) / max(spatial_hash.size(), 1)
	return stats

func debug_physics_state():
	"""调试物理系统状态"""
	var stats = get_physics_stats()
	LogManager.info("PhysicsSystem - 统计信息: " + str(stats))
	
	for unit_id in registered_units:
		var unit_data = registered_units[unit_id]
		LogManager.info("  单位 %s: 半径=%.2f 击退抗性=%.1f" % [
			unit_id, unit_data.collision_radius, unit_data.knockback_resistance
		])
