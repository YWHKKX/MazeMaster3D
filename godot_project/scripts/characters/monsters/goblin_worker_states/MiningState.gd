extends State
class_name GoblinWorkerMiningState

## GoblinWorker 挖矿状态
## 
## 职责：定时从金矿采集金币，直到背包满载或金矿枯竭
## 
## 转换条件：
## - 背包满载 → ReturnToBaseState
## - 金矿枯竭 → IdleState
## - 发现敌人 → EscapeState

var target_mine = null # GoldMine (RefCounted) 类型
var mining_timer: Timer = null
var mining_interval: float = 1.0 # 🔧 挖矿速度：每1秒挖一次，配合mining_power=4实现4金币/秒

func enter(data: Dictionary = {}) -> void:
	var worker = state_machine.owner
	
	# 获取目标金矿
	if data.has("target_mine"):
		target_mine = data["target_mine"]
	else:
		state_finished.emit(GameGroups.STATE_IDLE)
		return
	
	worker.current_mine = target_mine
	
	# 停止移动
	worker.velocity = Vector3.ZERO
	
	# 播放挖矿动画（使用 work 动画）
	if worker.has_node("Model") and worker.get_node("Model").has_method("play_animation"):
		worker.get_node("Model").play_animation("work")
	elif worker.has_node("AnimationPlayer"):
		worker.get_node("AnimationPlayer").play(GameGroups.ANIM_WORK)
	
	# 创建挖矿计时器
	mining_timer = Timer.new()
	mining_timer.wait_time = mining_interval
	mining_timer.timeout.connect(_on_mining_tick)
	add_child(mining_timer)
	mining_timer.start()
	
	# 开始挖矿

func update(_delta: float) -> void:
	var worker = state_machine.owner
	
	# 检查金矿是否有效
	if not is_instance_valid(target_mine) or target_mine.is_exhausted():
		# 金矿枯竭，返回空闲
		state_finished.emit(GameGroups.STATE_IDLE, {})
		return
	
	# 检查是否有敌人
	if _has_nearby_enemies(worker):
		state_finished.emit(GameGroups.STATE_ESCAPE, {})
		return
	
	# 检查是否满载（由_on_mining_tick处理，这里作为额外检查）
	if worker.carried_gold >= worker.worker_config.carry_capacity:
		# 背包满载，返回基地
		state_finished.emit("ReturnToBaseState", {})
		return

func _on_mining_tick() -> void:
	"""挖矿定时器触发"""
	var worker = state_machine.owner
	
	# 从金矿采集金币（使用 mine_gold 而非 extract_gold）
	var gold_gathered = target_mine.mine_gold(worker.mining_power)
	worker.carried_gold = mini(worker.carried_gold + gold_gathered, worker.worker_config.carry_capacity)
	
	# 🔧 [状态栏系统] 更新金币显示
	if worker.has_method("_update_status_bar_gold"):
		worker._update_status_bar_gold()
	
	# 挖掘金币
	
	# 检查是否满载
	if worker.carried_gold >= worker.worker_config.carry_capacity:
		# 背包满载，返回基地
		state_finished.emit("ReturnToBaseState", {})
		return
	
	# 检查金矿是否枯竭
	if target_mine.is_exhausted():
		# 金矿枯竭，返回空闲
		state_finished.emit(GameGroups.STATE_IDLE, {})
		return

func exit() -> void:
	# 清理计时器
	if mining_timer:
		mining_timer.stop()
		mining_timer.queue_free()
		mining_timer = null

func _has_nearby_enemies(worker: Node) -> bool:
	"""检查是否有敌人在附近"""
	# 使用 MonsterBase 的 find_nearest_enemy 方法
	var enemy = worker.find_nearest_enemy()
	if enemy and worker.global_position.distance_to(enemy.global_position) < 15.0:
		return true
	
	return false
