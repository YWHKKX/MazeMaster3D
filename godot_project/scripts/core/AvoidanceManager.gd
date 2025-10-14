extends Node
class_name AvoidanceController

## 高级避障管理器
## 
## 实现基于 steering behaviors 的避障系统
## 解决两个单位相向移动时的卡住问题

# 🔧 [动态避障配置] 可调整的避障参数
var AVOIDANCE_RADIUS = 1.5 # 避障检测半径（米）
var AVOIDANCE_FORCE = 6.0 # 避障力强度
var SEPARATION_FORCE = 8.0 # 分离力强度

# 力场权重
var AVOIDANCE_WEIGHT = 1.0
var SEPARATION_WEIGHT = 0.8

# 🔧 [性能优化配置]
var ENABLE_AVOIDANCE = true # 是否启用避障系统
var MAX_NEIGHBORS = 8 # 最大邻居数量（性能限制）
var UPDATE_FREQUENCY = 1 # 更新频率（每N帧更新一次）

# 单例（通过自动加载访问）
# 不需要手动管理单例，Godot自动加载会处理

## 计算动态避障力（分层避障系统）
## @param character: 当前角色
## @param target_velocity: 目标速度向量（来自AStarGrid2D路径）
## @param delta: 时间间隔
## @return: 避障调整后的速度向量
func calculate_avoidance_force(character: CharacterBody3D, target_velocity: Vector3, _delta: float) -> Vector3:
	if not character or not ENABLE_AVOIDANCE:
		return target_velocity
	
	# 🔧 [性能优化] 更新频率控制
	if not character.has_meta("_avoidance_frame_counter"):
		character.set_meta("_avoidance_frame_counter", 0)
	
	var frame_counter = character.get_meta("_avoidance_frame_counter")
	frame_counter += 1
	character.set_meta("_avoidance_frame_counter", frame_counter)
	
	if frame_counter % UPDATE_FREQUENCY != 0:
		return target_velocity
	
	# 🔧 [动态避障] 分层处理：全局路径 + 局部避障
	var avoidance_force = Vector3.ZERO
	var separation_force = Vector3.ZERO
	
	# 获取附近的动态单位
	var nearby_characters = _get_nearby_characters(character)
	
	if nearby_characters.size() == 0:
		return target_velocity
	
	# 🔧 [性能优化] 限制处理的邻居数量
	var processed_count = 0
	
	# 🔧 [动态避障] 简化的分层避障算法
	for other_character in nearby_characters:
		if not is_instance_valid(other_character) or other_character == character:
			continue
		
		# 🔧 [性能优化] 限制处理的邻居数量
		if processed_count >= MAX_NEIGHBORS:
			break
		processed_count += 1
		
		var distance = character.global_position.distance_to(other_character.global_position)
		if distance > AVOIDANCE_RADIUS:
			continue
		
		var direction_to_other = (other_character.global_position - character.global_position).normalized()
		
		# 1. 基础避障力（避免碰撞）
		var avoidance_factor = 1.0 - (distance / AVOIDANCE_RADIUS)
		avoidance_force -= direction_to_other * avoidance_factor * AVOIDANCE_FORCE
		
		# 2. 分离力（保持最小距离）
		if distance < AVOIDANCE_RADIUS * 0.5:
			var separation_factor = (AVOIDANCE_RADIUS * 0.5 - distance) / (AVOIDANCE_RADIUS * 0.5)
			separation_force -= direction_to_other * separation_factor * SEPARATION_FORCE
	
	# 组合避障力
	var total_avoidance = avoidance_force * AVOIDANCE_WEIGHT + separation_force * SEPARATION_WEIGHT
	
	# 限制避障力强度，避免过度偏转
	total_avoidance = total_avoidance.limit_length(AVOIDANCE_FORCE * 1.5)
	
	# 🔧 [关键] 返回纯避障力，由MovementHelper进行智能混合
	return total_avoidance

## 获取附近的角色（性能优化版本）
## @param character: 当前角色
## @return: 附近角色数组
func _get_nearby_characters(character: CharacterBody3D) -> Array:
	var nearby = []
	var character_pos = character.global_position
	
	# 🔧 [性能优化] 使用空间分区思想：只检查特定区域内的单位
	var detection_radius = AVOIDANCE_RADIUS * 2.5 # 检测半径
	
	# 获取所有单位（通过GameGroups）
	var all_characters = []
	all_characters.append_array(GameGroups.get_nodes(GameGroups.GOBLIN_WORKERS))
	all_characters.append_array(GameGroups.get_nodes(GameGroups.GOBLIN_ENGINEERS))
	all_characters.append_array(GameGroups.get_nodes(GameGroups.HEROES))
	
	# 🔧 [性能优化] 快速距离筛选，避免不必要的计算
	for other in all_characters:
		if not is_instance_valid(other) or other == character:
			continue
		
		# 使用平方距离进行快速筛选（避免开方运算）
		var distance_squared = character_pos.distance_squared_to(other.global_position)
		if distance_squared <= detection_radius * detection_radius:
			nearby.append(other)
	
	return nearby

## 🔧 [动态避障配置] 运行时调整避障参数
func configure_avoidance(
	avoidance_radius: float = 1.5,
	avoidance_force: float = 6.0,
	separation_force: float = 8.0,
	max_neighbors: int = 8,
	update_frequency: int = 1,
	enable: bool = true
) -> void:
	"""动态调整避障系统参数"""
	AVOIDANCE_RADIUS = avoidance_radius
	AVOIDANCE_FORCE = avoidance_force
	SEPARATION_FORCE = separation_force
	MAX_NEIGHBORS = max_neighbors
	UPDATE_FREQUENCY = update_frequency
	ENABLE_AVOIDANCE = enable
	
	# 避障配置已更新

## 检测是否会与另一个角色相撞
## @param character: 当前角色
## @param target_position: 目标位置
## @return: 是否会相撞
func will_collide_with_character(character: CharacterBody3D, target_position: Vector3) -> bool:
	var nearby = _get_nearby_characters(character)
	
	for other in nearby:
		if not is_instance_valid(other) or other == character:
			continue
		
		var distance_to_target = target_position.distance_to(other.global_position)
		var collision_radius = 0.2 # 角色碰撞半径
		
		if distance_to_target < collision_radius * 2.0:
			return true
	
	return false

## 获取避障后的目标位置
## @param character: 当前角色
## @param original_target: 原始目标位置
## @param delta: 时间间隔
## @return: 调整后的目标位置
func get_avoidance_target(character: CharacterBody3D, original_target: Vector3, delta: float) -> Vector3:
	if not character:
		return original_target
	
	var direction_to_target = (original_target - character.global_position).normalized()
	var target_velocity = direction_to_target * character.speed
	
	# 计算避障力
	var adjusted_velocity = calculate_avoidance_force(character, target_velocity, delta)
	
	# 转换为目标位置
	return character.global_position + adjusted_velocity * delta
