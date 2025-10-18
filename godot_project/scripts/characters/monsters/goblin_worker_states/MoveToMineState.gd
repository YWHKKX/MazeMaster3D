extends State
class_name GoblinWorkerMoveToMineState

## GoblinWorker 移动到金矿状态
## 
## 职责：使用 GridPathFinder 移动到金矿旁边的可通行位置
## 
## 转换条件：
## - 到达金矿交互范围（1.1x1.1） → MiningState
## - 金矿失效（被摧毁/枯竭） → IdleState
## - 发现敌人 → EscapeState

var target_mine = null # GoldMine (RefCounted) 类型
var mine_building: Node3D = null # 🔧 金矿建筑包装器

# 🔧 [统一移动API] 使用 process_interaction_movement() 进行两阶段移动
# 不再需要手动管理 current_path 和 current_waypoint

func enter(data: Dictionary = {}) -> void:
	var worker = state_machine.owner_node
	
	# 获取目标金矿
	if data.has("target_mine"):
		target_mine = data["target_mine"]
	else:
		# 没有目标，返回空闲
		state_finished.emit(GameGroups.STATE_IDLE)
		return
	
	# 🔧 [统一移动API] 创建金矿建筑包装器，使用统一的交互移动API
	mine_building = _create_mine_building_wrapper(target_mine)
	
	# 获取金矿建筑包装器
	
	# 🔧 [统一移动API] 重置交互移动状态（新状态开始）
	MovementHelper.reset_interaction_movement(worker)
	
	# 播放行走动画
	if worker.has_node("Model") and worker.get_node("Model").has_method("play_animation"):
		worker.get_node("Model").play_animation("move")
	elif worker.has_node("AnimationPlayer"):
		worker.get_node("AnimationPlayer").play(GameGroups.ANIM_MOVE)
	
	worker.current_mine = target_mine
	
func physics_update(_delta: float) -> void:
	var worker = state_machine.owner_node
	
	# 检查目标金矿是否有效
	if not is_instance_valid(target_mine) or target_mine.is_exhausted():
		state_finished.emit(GameGroups.STATE_IDLE, {})
		return
	
	# 检查是否有敌人
	if _has_nearby_enemies(worker):
		state_finished.emit(GameGroups.STATE_ESCAPE, {})
		return
	
	# 🔧 [统一移动API] 使用两阶段交互移动逻辑（与工程师保持一致）
	var move_result = MovementHelper.process_interaction_movement(
		worker,
		mine_building,
		_delta,
		"MoveToMineState" if state_machine.debug_mode else ""
	)
	
	# 根据移动结果处理状态转换
	match move_result:
		MovementHelper.InteractionMoveResult.REACHED_INTERACTION:
			# 已到达交互范围，开始挖矿
			state_finished.emit(GameGroups.STATE_MINING, {"target_mine": target_mine})
			return
		MovementHelper.InteractionMoveResult.FAILED_NO_PATH, MovementHelper.InteractionMoveResult.FAILED_STUCK:
			# 寻路失败或卡住，标记金矿失败
			worker.failed_mines[target_mine.position] = Time.get_ticks_msec()
			state_finished.emit(GameGroups.STATE_IDLE, {})
		# MOVING_TO_ADJACENT 和 MOVING_TO_INTERACTION 继续移动

func exit() -> void:
	var worker = state_machine.owner_node
	worker.velocity = Vector3.ZERO
	
	# 🔧 [清理] 移除金矿建筑包装器
	if mine_building and is_instance_valid(mine_building):
		mine_building.queue_free()
		mine_building = null


func _create_mine_building_wrapper(mine: RefCounted) -> Node3D:
	"""创建金矿的建筑包装器，用于适配 process_interaction_movement API
	
	Args:
		mine: 金矿对象
		
	Returns:
		Node3D: 临时的建筑包装器
	"""
	var wrapper = Node3D.new()
	wrapper.name = "MineWrapper"
	
	# 设置金矿位置
	var mine_pos = Vector3(
		floor(mine.position.x) + 0.5,
		0.05,
		floor(mine.position.z) + 0.5
	)
	
	# 🔧 [修复] 设置位置（先设置 position，再添加到场景树）
	wrapper.position = mine_pos
	
	# 添加到场景树以确保位置设置生效
	var scene_tree = Engine.get_main_loop() as SceneTree
	if scene_tree and scene_tree.current_scene:
		scene_tree.current_scene.add_child(wrapper)
	
	# 设置金矿建筑包装器位置
	
	# 添加建筑大小方法（金矿是1x1）
	wrapper.set_meta("building_size", Vector2(1, 1))
	
	# 添加 get_building_size 方法
	wrapper.set_script(load("res://scripts/core/BuildingWrapper.gd"))
	
	return wrapper

func _has_nearby_enemies(worker: Node) -> bool:
	"""检查是否有敌人在附近"""
	# 使用 MonsterBase 的 find_nearest_enemy 方法
	var enemy = worker.find_nearest_enemy()
	if enemy and worker.global_position.distance_to(enemy.global_position) < 15.0:
		return true
	
	return false
