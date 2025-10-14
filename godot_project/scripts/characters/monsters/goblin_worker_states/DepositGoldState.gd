extends State
class_name GoblinWorkerDepositGoldState

## GoblinWorker 存放金币状态
## 
## 职责：将金币存入基地，瞬时完成
## 
## 转换条件：
## - 存钱完成 → IdleState

var target_base: Node = null

func enter(data: Dictionary = {}) -> void:
	var worker = state_machine.owner
	
	# 获取目标基地
	if data.has("target_base"):
		target_base = data["target_base"]
	
	# 停止移动
	worker.velocity = Vector3.ZERO
	
	# 播放存钱动画（如果有）
	if worker.has_node("AnimationPlayer"):
		var anim_player = worker.get_node("AnimationPlayer")
		if anim_player.has_animation("deposit"):
			anim_player.play("deposit")
	
	# 存放金币到基地
	
	# 存放金币
	_deposit_gold(worker)
	
	# 瞬时完成，立即返回空闲状态
	state_finished.emit(GameGroups.STATE_IDLE, {})

func _deposit_gold(worker: Node) -> void:
	"""将金币存入基地"""
	if not worker.has_deposited:
		# 使用 ResourceManager 存储金币到指定建筑
		if worker.resource_manager and target_base:
			var result = worker.resource_manager.add_gold(worker.carried_gold, target_base)
			if state_machine.debug_mode:
				if not result.get("success", false):
					# 存储失败，记录错误但不中断流程
					pass
		elif worker.resource_manager:
			# 后备方案：存储到默认建筑（地牢之心）
			worker.resource_manager.add_gold(worker.carried_gold)
			# 成功存入金币到默认建筑
		
		# 🔧 PersonalStorageManager 暂时禁用（苦工未注册，会报错）
		# 主要金币存储通过ResourceManager已完成
		# if worker.personal_storage_manager:
		# 	worker.personal_storage_manager.remove_gold(
		# 		worker.get_instance_id(),
		# 		worker.carried_gold
		# 	)
		
		# 清空背包
		worker.carried_gold = 0
		worker.has_deposited = true
		
		# 🔧 [状态栏系统] 更新金币显示
		if worker.has_method("_update_status_bar_gold"):
			worker._update_status_bar_gold()
		
		# 触发存钱事件（供其他系统监听）
		if worker.has_signal("gold_deposited"):
			worker.emit_signal("gold_deposited")
