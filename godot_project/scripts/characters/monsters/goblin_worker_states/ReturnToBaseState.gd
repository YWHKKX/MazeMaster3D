extends State
class_name GoblinWorkerReturnToBaseState

## GoblinWorker 返回基地状态
## 
## 职责：携带金币返回最近的基地/金库
## 
## 转换条件：
## - 到达基地交互范围 → DepositGoldState
## - 基地被摧毁 → IdleState
## - 发现敌人 → EscapeState

var target_base: Node = null
var target_position: Vector3 = Vector3.ZERO # 🔧 目标可通行位置

# 🔧 [统一移动API] 使用 process_interaction_movement() 进行两阶段移动
# 不再需要手动管理 current_path 和 current_waypoint

func enter(data: Dictionary = {}) -> void:
	var worker = state_machine.owner_node
	
	# 获取目标基地
	if data.has("target_base"):
		target_base = data["target_base"]
	else:
		# 查找最近的基地
		target_base = BuildingFinder.get_nearest_storage_building(worker)
	
	if not target_base:
		# 没有基地，返回空闲
		state_finished.emit(GameGroups.STATE_IDLE)
		return
	
	# 找到基地
	
	# 配置导航到基地
	
	# 🔧 [统一交互移动API] 重置交互移动状态（新状态开始）
	MovementHelper.reset_interaction_movement(worker)
	
	# 播放行走动画
	if worker.has_node("Model") and worker.get_node("Model").has_method("play_animation"):
		worker.get_node("Model").play_animation("move")
	elif worker.has_node("AnimationPlayer"):
		worker.get_node("AnimationPlayer").play(GameGroups.ANIM_MOVE)
	
	worker.target_base = target_base
	worker.has_deposited = false # 重置存储标志

func physics_update(delta: float) -> void:
	var worker = state_machine.owner_node
	
	# 检查基地是否有效
	if not is_instance_valid(target_base):
		state_finished.emit(GameGroups.STATE_IDLE, {})
		return
	
	# 检查是否有敌人
	if _has_nearby_enemies(worker):
		state_finished.emit(GameGroups.STATE_ESCAPE, {})
		return
	
	# 🔧 [统一交互移动API] 使用两阶段移动逻辑
	var move_result = MovementHelper.process_interaction_movement(
		worker,
		target_base,
		delta,
		"ReturnToBaseState" if state_machine.debug_mode else ""
	)
	
	# 根据移动结果处理状态转换
	match move_result:
		MovementHelper.InteractionMoveResult.REACHED_INTERACTION:
			# 已到达交互范围，开始存放金币
			state_finished.emit("DepositGoldState", {"target_base": target_base})
			return
		MovementHelper.InteractionMoveResult.FAILED_NO_PATH, MovementHelper.InteractionMoveResult.FAILED_STUCK:
			# 寻路失败或卡住，返回空闲
			state_finished.emit(GameGroups.STATE_IDLE, {})
		# MOVING_TO_ADJACENT 和 MOVING_TO_INTERACTION 继续移动

func exit() -> void:
	var worker = state_machine.owner_node
	worker.velocity = Vector3.ZERO


func _get_accessible_position_near_base(base: Node) -> Vector3:
	"""获取基地附近的可通行位置
	
	🔧 [关键修复] 地牢之心是2x2建筑，需要找到Area3D范围内的位置
	"""
	# 地牢之心是2x2建筑，position在中心 (50.5, 0.05, 50.5)
	# 🔧 [关键修复] 地牢之心是2x2建筑，需要在地牢之心外部寻找可通行位置
	# 地牢之心占据 (50,50), (50,51), (51,50), (51,51)
	# 我们需要在地牢之心外部寻找位置，距离约1.5米
	var offsets = [
		Vector3(-1.5, 0, 0), Vector3(1.5, 0, 0), # 左、右
		Vector3(0, 0, -1.5), Vector3(0, 0, 1.5), # 上、下
		Vector3(-1.5, 0, -1.5), Vector3(1.5, 0, -1.5), # 左上、右上
		Vector3(-1.5, 0, 1.5), Vector3(1.5, 0, 1.5) # 左下、右下
	]
	
	# 寻找地牢之心附近可通行位置
	
	# 🔧 使用TileManager找到可通行的位置
	var tile_manager = GameServices.tile_manager
	if tile_manager:
		for i in range(offsets.size()):
			var offset = offsets[i]
			var test_pos = base.global_position + offset
			test_pos.y = 0.05 # 确保在地面高度
			
			# 检查是否在地图范围内
			var grid_x = int(test_pos.x)
			var grid_z = int(test_pos.z)
			if grid_x >= 0 and grid_x < 100 and grid_z >= 0 and grid_z < 100:
				# 检查是否可通行
				var world_pos_int = Vector3(grid_x, 0, grid_z)
				if tile_manager.is_walkable(world_pos_int):
					return test_pos
	
	# 🔧 [关键修复] 如果周围没有可通行位置，直接返回地牢之心中心！
	# 地牢之心本身应该可通行（如果不可通行，说明有问题）
	return base.global_position

func _check_in_base_interaction_area(worker: Node, _base: Node) -> bool:
	"""检查Worker是否在基地的Area3D交互范围内
	
	🔧 [方案C] 主动查询Area3D重叠，无需信号连接
	
	注意：地牢之心的Area3D不在DungeonHeart对象的子节点中，
	而是挂在独立的tile_object上（由TileManager创建）
	需要通过INTERACTION_ZONES Group查找
	"""
	# 查找所有交互区域（地牢之心的瓦片Area3D）
	var interaction_areas = GameGroups.get_nodes(GameGroups.INTERACTION_ZONES)
	
	# 检查苦工是否在基地交互区域内
	
	# 🔧 [修复] 检查所有类型的基地Area3D（地牢之心 + 金库）
	for i in range(interaction_areas.size()):
		var area = interaction_areas[i]
		# 检查是否是目标基地的Area3D（通过meta标记）
		var area_building_type = area.get_meta("building_type")
		var is_target_building = false
		
		# 检查是否是地牢之心
		if area.has_meta("building_type") and (area_building_type == BuildingTypes.BuildingType.DUNGEON_HEART or str(area_building_type) == str(BuildingTypes.BuildingType.DUNGEON_HEART)):
			is_target_building = true
		# 🔧 [新增] 检查是否是金库
		elif area.has_meta("building_type") and (area_building_type == BuildingTypes.BuildingType.TREASURY or str(area_building_type) == str(BuildingTypes.BuildingType.TREASURY)):
			is_target_building = true
		
		if is_target_building:
			# 检查Worker是否在Area3D内
			var overlapping = area.get_overlapping_bodies()
			var distance_to_area = worker.global_position.distance_to(area.global_position)
			
			# 检查苦工是否在此交互区域内
			
			if worker in overlapping:
				return true
	
	# 🔧 [新增] 如果Area3D检测失败，使用距离检测作为后备方案
	var distance = worker.global_position.distance_to(_base.global_position)
	if distance <= 1.0: # 1米交互范围
		return true
	
	return false

func _has_nearby_enemies(worker: Node) -> bool:
	"""检查是否有敌人在附近"""
	# 使用 MonsterBase 的 find_nearest_enemy 方法
	var enemy = worker.find_nearest_enemy()
	if enemy and worker.global_position.distance_to(enemy.global_position) < 15.0:
		return true
	
	return false
