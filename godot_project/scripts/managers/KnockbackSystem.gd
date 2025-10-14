extends Node
class_name KnockbackSystem

## ⚡ 击退系统
## 负责击退效果的计算、应用和动画

# 活跃的击退效果
var active_knockbacks: Dictionary = {} # unit_id -> knockback_state

# 物理系统引用
var physics_system = null

# 击退状态类
class KnockbackState:
	var unit_id: String
	var start_position: Vector3
	var target_position: Vector3
	var current_position: Vector3
	var knockback_type: int # PhysicsSystem.KnockbackType
	var duration: float
	var elapsed_time: float
	var speed: float
	var is_complete: bool = false
	
	func _init(uid: String, start_pos: Vector3, target_pos: Vector3, k_type: int, dur: float, spd: float):
		unit_id = uid
		start_position = start_pos
		target_position = target_pos
		current_position = start_pos
		knockback_type = k_type
		duration = dur
		elapsed_time = 0.0
		speed = spd
	
	func update(delta: float) -> Vector3:
		"""更新击退状态，返回新的位置"""
		if is_complete:
			return current_position
		
		elapsed_time += delta
		var progress = elapsed_time / duration
		
		if progress >= 1.0:
			progress = 1.0
			is_complete = true
		
		# 使用缓动函数 (ease-out)
		var eased_progress = 1.0 - pow(1.0 - progress, 3.0)
		
		# 插值计算当前位置
		current_position = start_position.lerp(target_position, eased_progress)
		
		return current_position

func _ready():
	"""初始化击退系统"""
	LogManager.info("KnockbackSystem - 击退系统初始化")

func set_physics_system(system):
	"""设置物理系统引用"""
	physics_system = system
	LogManager.info("KnockbackSystem - 物理系统引用已设置")

func apply_knockback(attacker_data: Dictionary, target_data: Dictionary, knockback_type: int, _damage: float) -> bool:
	"""应用击退效果"""
	var target_id = target_data.unit_id
	var target_node = target_data.unit_node
	
	# 检查击退免疫条件
	if _is_knockback_immune(target_data):
		return false
	
	# 计算击退距离
	var knockback_distance = _calculate_knockback_distance(attacker_data, target_data, knockback_type)
	
	if knockback_distance <= 0:
		return false
	
	# 计算击退方向
	var knockback_direction = _calculate_knockback_direction(attacker_data.position, target_data.position)
	
	# 计算目标位置
	var target_position = target_data.position + knockback_direction * knockback_distance
	
	# 边界检查
	target_position = _clamp_position_to_bounds(target_position)
	
	# 创建击退状态
	var knockback_state = KnockbackState.new(
		target_id,
		target_data.position,
		target_position,
		knockback_type,
		0.3, # 击退持续时间
		50.0 # 击退速度
	)
	
	# 添加到活跃击退列表
	active_knockbacks[target_id] = knockback_state
	
	# 禁用目标单位的移动控制
	_disable_unit_movement(target_node)
	
	# 创建击退视觉效果
	_create_knockback_effects(attacker_data.position, target_data.position, knockback_type)
	
	return true

func update_knockbacks(delta: float):
	"""更新所有击退效果"""
	var completed_knockbacks = []
	
	for unit_id in active_knockbacks:
		var knockback_state = active_knockbacks[unit_id]
		var new_position = knockback_state.update(delta)
		
		# 更新单位位置
		var unit_data = _get_unit_data(unit_id)
		if unit_data and unit_data.has("unit_node") and unit_data.unit_node:
			unit_data.unit_node.position = new_position
			unit_data.position = new_position
			
			# 检查击退是否完成
			if knockback_state.is_complete:
				completed_knockbacks.append(unit_id)
				_complete_knockback(unit_id, unit_data)
		else:
			# 单位数据无效，直接移除击退状态
			completed_knockbacks.append(unit_id)
	
	# 移除完成的击退效果
	for unit_id in completed_knockbacks:
		active_knockbacks.erase(unit_id)

func get_knockback_state(unit_id: String) -> KnockbackState:
	"""获取单位的击退状态"""
	if unit_id in active_knockbacks:
		return active_knockbacks[unit_id]
	return null

func is_unit_knocked_back(unit_id: String) -> bool:
	"""检查单位是否处于击退状态"""
	return unit_id in active_knockbacks

func get_active_knockback_count() -> int:
	"""获取活跃击退数量"""
	return active_knockbacks.size()

# =============================================================================
# 内部辅助函数
# =============================================================================

func _calculate_knockback_distance(_attacker_data: Dictionary, target_data: Dictionary, knockback_type: int) -> float:
	"""计算击退距离"""
	var base_distance = 0.0
	
	match knockback_type:
		0: # NORMAL
			base_distance = 15.0
		1: # STRONG
			base_distance = 30.0
		2: # WEAK
			base_distance = 8.0
		3: # NONE
			return 0.0
	
	# 只有强击退受目标抗性影响
	if knockback_type == 1: # STRONG
		var resistance = target_data.get("knockback_resistance", 1.0)
		base_distance = base_distance / resistance
	
	return base_distance

func _calculate_knockback_direction(attacker_pos: Vector3, target_pos: Vector3) -> Vector3:
	"""计算击退方向"""
	var direction = target_pos - attacker_pos
	
	# 如果距离为0，随机选择方向
	if direction.length() < 0.001:
		var angle = randf() * 2.0 * PI
		direction = Vector3(cos(angle), 0, sin(angle))
	
	# 标准化方向向量
	direction.y = 0 # 确保水平击退
	return direction.normalized()

func _clamp_position_to_bounds(position: Vector3) -> Vector3:
	"""限制位置在地图边界内"""
	# 这里可以添加地图边界检查
	# 暂时简单实现
	var clamped_pos = position
	clamped_pos.x = clamp(clamped_pos.x, -1000, 1000)
	clamped_pos.z = clamp(clamped_pos.z, -1000, 1000)
	return clamped_pos

func _is_knockback_immune(target_data: Dictionary) -> bool:
	"""检查击退免疫条件"""
	# 死亡单位不能被击退
	if target_data.get("is_dead", false):
		return true
	
	# 建筑物不能被击退
	if target_data.get("is_building", false):
		return true
	
	# 特殊状态免疫击退
	if target_data.get("is_immune_to_knockback", false):
		return true
	
	# 扎根状态免疫击退 (树人守护者等)
	if target_data.get("is_rooted", false):
		return true
	
	return false

func _disable_unit_movement(unit_node: Node3D):
	"""禁用单位移动控制"""
	# 这里可以设置移动禁用标志
	# 具体实现取决于移动系统
	if unit_node.has_method("set_movement_disabled"):
		unit_node.set_movement_disabled(true)

func _enable_unit_movement(unit_node: Node3D):
	"""启用单位移动控制"""
	if unit_node.has_method("set_movement_disabled"):
		unit_node.set_movement_disabled(false)

func _complete_knockback(unit_id: String, unit_data: Dictionary):
	"""完成击退效果"""
	# 启用单位移动控制
	if unit_data and unit_data.unit_node:
		_enable_unit_movement(unit_data.unit_node)
	
	# 更新单位状态
	if unit_data:
		unit_data.is_knocked_back = false
		unit_data.knockback_state = null

func _create_knockback_effects(_attacker_pos: Vector3, _target_pos: Vector3, _knockback_type: int):
	"""创建击退视觉效果"""
	# 这里可以创建粒子效果、屏幕震动等
	# 具体实现取决于视觉效果系统
	pass

func _get_unit_data(unit_id: String):
	"""获取单位数据（返回Dictionary或null）"""
	if physics_system and physics_system.registered_units.has(unit_id):
		return physics_system.registered_units[unit_id]
	return null

# =============================================================================
# 调试和统计
# =============================================================================

func get_knockback_stats() -> Dictionary:
	"""获取击退统计信息"""
	return {
		"active_knockbacks": active_knockbacks.size(),
		"completed_this_frame": 0, # 可以添加统计
		"total_knockbacks_applied": 0 # 可以添加统计
	}

func debug_knockback_state():
	"""调试击退状态"""
	for unit_id in active_knockbacks:
		var state = active_knockbacks[unit_id]
		pass # 可选：添加进度监控逻辑
