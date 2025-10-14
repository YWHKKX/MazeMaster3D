extends Node
class_name CollisionSystem

## 🔍 碰撞检测系统
## 负责单位间的碰撞检测和空间优化

var collision_check_count: int = 0
var last_reset_time: float = 0.0

func _ready():
	"""初始化碰撞系统"""
	LogManager.info("CollisionSystem - 碰撞系统初始化")

func update_collisions(_delta: float, registered_units: Dictionary, spatial_hash: Dictionary):
	"""更新碰撞检测"""
	collision_check_count = 0
	var current_time = Time.get_time_dict_from_system()
	var time_seconds = current_time.hour * 3600 + current_time.minute * 60 + current_time.second
	
	# 每秒重置计数器
	if time_seconds != last_reset_time:
		last_reset_time = time_seconds
		collision_check_count = 0
	
	# 批量碰撞检测
	_batch_collision_detection(registered_units, spatial_hash)

func check_collision(unit_data: Dictionary, target_data: Dictionary) -> bool:
	"""检查两个单位是否发生碰撞"""
	collision_check_count += 1
	
	var distance = unit_data.position.distance_to(target_data.position)
	var radius_sum = unit_data.collision_radius + target_data.collision_radius
	
	return distance <= radius_sum

func check_collision_optimized(unit_data: Dictionary, target_data: Dictionary) -> bool:
	"""优化的碰撞检测（避免开方运算）"""
	collision_check_count += 1
	
	var dx = unit_data.position.x - target_data.position.x
	var dz = unit_data.position.z - target_data.position.z
	var distance_squared = dx * dx + dz * dz
	
	var radius_sum = unit_data.collision_radius + target_data.collision_radius
	var radius_sum_squared = radius_sum * radius_sum
	
	return distance_squared <= radius_sum_squared

func get_nearby_units(position: Vector3, radius: float, registered_units: Dictionary, spatial_hash: Dictionary) -> Array:
	"""获取附近的单位"""
	var nearby_units = []
	var search_radius = radius + 50.0 # 增加搜索半径确保覆盖
	
	# 计算需要检查的单元格范围
	var cell_size = 50.0 # 与PhysicsSystem中的spatial_hash_cell_size一致
	var min_cell_x = int((position.x - search_radius) / cell_size)
	var max_cell_x = int((position.x + search_radius) / cell_size)
	var min_cell_z = int((position.z - search_radius) / cell_size)
	var max_cell_z = int((position.z + search_radius) / cell_size)
	
	# 检查范围内的所有单元格
	for cell_x in range(min_cell_x, max_cell_x + 1):
		for cell_z in range(min_cell_z, max_cell_z + 1):
			var cell_key = str(cell_x) + "," + str(cell_z)
			
			if cell_key in spatial_hash:
				for unit_id in spatial_hash[cell_key]:
					if unit_id in registered_units:
						var unit_data = registered_units[unit_id]
						if position.distance_to(unit_data.position) <= radius:
							nearby_units.append(unit_id)
	
	return nearby_units

func get_collision_info(unit_id: String, registered_units: Dictionary, spatial_hash: Dictionary) -> Dictionary:
	"""获取单位的碰撞信息"""
	if unit_id not in registered_units:
		return {}
	
	var unit_data = registered_units[unit_id]
	var nearby_units = get_nearby_units(unit_data.position, unit_data.collision_radius * 2, registered_units, spatial_hash)
	
	var collisions = []
	for nearby_id in nearby_units:
		if nearby_id != unit_id and nearby_id in registered_units:
			var nearby_data = registered_units[nearby_id]
			if check_collision_optimized(unit_data, nearby_data):
				collisions.append({
					"unit_id": nearby_id,
					"distance": unit_data.position.distance_to(nearby_data.position),
					"overlap": (unit_data.collision_radius + nearby_data.collision_radius) - unit_data.position.distance_to(nearby_data.position)
				})
	
	return {
		"unit_id": unit_id,
		"collision_radius": unit_data.collision_radius,
		"position": unit_data.position,
		"collisions": collisions,
		"nearby_units": nearby_units.size()
	}

func _batch_collision_detection(registered_units: Dictionary, spatial_hash: Dictionary):
	"""批量碰撞检测（优化版 - 使用空间哈希）"""
	# 使用空间哈希优化，只检测同一单元格和相邻单元格的单位
	var checked_pairs = {} # 避免重复检测
	
	for cell_key in spatial_hash:
		var units_in_cell = spatial_hash[cell_key]
		
		# 检测同一单元格内的单位碰撞
		for i in range(units_in_cell.size()):
			for j in range(i + 1, units_in_cell.size()):
				var unit1_id = units_in_cell[i]
				var unit2_id = units_in_cell[j]
				
				var pair_key = _get_pair_key(unit1_id, unit2_id)
				if pair_key in checked_pairs:
					continue
				
				checked_pairs[pair_key] = true
				
				if unit1_id in registered_units and unit2_id in registered_units:
					var unit1_data = registered_units[unit1_id]
					var unit2_data = registered_units[unit2_id]
					
					if check_collision_optimized(unit1_data, unit2_data):
						_handle_collision_event(unit1_id, unit2_id, unit1_data, unit2_data)

func _get_pair_key(unit1_id: String, unit2_id: String) -> String:
	"""生成单位对的唯一键值（用于避免重复检测）"""
	if unit1_id < unit2_id:
		return unit1_id + "|" + unit2_id
	else:
		return unit2_id + "|" + unit1_id

func _handle_collision_event(_unit1_id: String, _unit2_id: String, _unit1_data: Dictionary, _unit2_data: Dictionary):
	"""处理碰撞事件"""
	# 可以在这里添加碰撞后的处理逻辑
	# 比如单位重叠时的分离等
	pass

func get_collision_check_count() -> int:
	"""获取碰撞检测次数"""
	return collision_check_count

func reset_collision_count():
	"""重置碰撞检测计数"""
	collision_check_count = 0
