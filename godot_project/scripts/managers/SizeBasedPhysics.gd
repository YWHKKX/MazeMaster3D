extends Node
class_name SizeBasedPhysics

## 🧮 体型物理系统
## 负责基于体型差异的物理计算

func _ready():
	"""初始化体型物理系统"""
	LogManager.info("SizeBasedPhysics - 体型物理系统初始化")

func calculate_knockback_distance(attacker_size: int, target_size: int, knockback_type: int, physics_config: Dictionary) -> float:
	"""计算击退距离"""
	var base_distance = 0.0
	
	# 获取基础击退距离
	match knockback_type:
		0: # NORMAL
			base_distance = physics_config.get("normal_knockback_distance", 15.0)
		1: # STRONG
			base_distance = physics_config.get("strong_knockback_distance", 30.0)
		2: # WEAK
			base_distance = physics_config.get("weak_knockback_distance", 8.0)
		3: # NONE
			return 0.0
	
	# 只有强击退受目标抗性影响
	if knockback_type == 1: # STRONG
		var target_resistance = get_knockback_resistance(target_size)
		base_distance = base_distance / target_resistance
	
	return base_distance

func get_size_category(size: int) -> int:
	"""获取体型分类"""
	if size <= 12:
		return 0 # MICRO
	elif size <= 17:
		return 1 # SMALL
	elif size <= 25:
		return 2 # MEDIUM
	else:
		return 3 # LARGE

func get_knockback_resistance(size: int) -> float:
	"""获取击退抗性"""
	match get_size_category(size):
		0: # MICRO
			return 0.5
		1: # SMALL
			return 0.7
		2: # MEDIUM
			return 1.0
		3: # LARGE
			return 1.5
		_:
			return 1.0

func get_collision_radius(size: int, physics_config: Dictionary) -> float:
	"""计算碰撞半径
	
	[修复] 更新为正确的碰撞半径计算
	radius_factor = 0.004 相当于 (size/100) * 0.4
	"""
	var radius_factor = physics_config.get("collision_radius_factor", 0.004)
	var min_radius = physics_config.get("min_collision_radius", 0.15)
	var max_radius = physics_config.get("max_collision_radius", 0.5)
	
	var radius = size * radius_factor
	return clamp(radius, min_radius, max_radius)

func calculate_size_ratio(attacker_size: int, target_size: int) -> float:
	"""计算体型比例"""
	if target_size <= 0:
		return 1.0
	return float(attacker_size) / float(target_size)

func get_size_category_name(size: int) -> String:
	"""获取体型分类名称"""
	match get_size_category(size):
		0:
			return "超小型"
		1:
			return "小型"
		2:
			return "中型"
		3:
			return "大型"
		_:
			return "未知"

func get_size_stats() -> Dictionary:
	"""获取体型统计信息"""
	return {
		"micro_units": 0, # 可以统计各种体型的单位数量
		"small_units": 0,
		"medium_units": 0,
		"large_units": 0,
		"total_units": 0
	}
