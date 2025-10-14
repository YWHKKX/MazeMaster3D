extends Node
## 🎯 游戏事件总线（Autoload单例）
## 使用信号进行解耦通信，避免直接引用
## 所有游戏事件都通过这里发送和监听

# === 资源事件 ===
signal resource_changed(resource_type: String, amount: int, total: int)
signal resource_insufficient(resource_type: String, required: int, current: int)
signal resource_collected(resource_type: String, amount: int, collector)
signal resource_spent(resource_type: String, amount: int, reason: String)

# === 建筑事件 ===
signal building_placed(building, position: Vector3)
signal building_completed(building)
signal building_destroyed(building, destroyer)
signal building_upgraded(building, new_level: int)
signal building_damaged(building, damage: int, attacker)

# === 角色事件 ===
signal character_spawned(character)
signal character_died(character, killer)
signal character_moved(character, from_pos: Vector3, to_pos: Vector3)
signal character_task_assigned(character, task_type: String, task_data: Dictionary)
signal character_task_completed(character, task_type: String)
signal character_state_changed(character, old_state: int, new_state: int)

# === 挖矿事件 ===
signal gold_mine_discovered(mine_position: Vector3, gold_amount: int)
signal gold_mine_depleted(mine_position: Vector3)
signal mining_started(character, mine_position: Vector3)
signal mining_progress(character, mine_position: Vector3, progress: float)
signal mining_completed(character, gold_collected: int)

# === 战斗事件 ===
signal combat_started(attacker, target)
signal damage_dealt(attacker, target, damage: int, is_critical: bool)
signal unit_healed(unit, amount: int, healer)
signal unit_killed(victim, killer)
signal knockback_applied(unit, direction: Vector3, distance: float)

# === 地图事件 ===
signal map_generated() # 地图生成完成
signal map_modified(position: Vector3, old_type: int, new_type: int) # 地图修改（挖掘/建造）
signal tiles_changed(positions: Array) # 批量地块改变

# === 游戏状态事件 ===
signal game_started()
signal game_paused()
signal game_resumed()
signal game_over(result: String)
signal game_speed_changed(new_speed: float)
signal day_changed(day_number: int)

# === UI事件 ===
signal selection_changed(selected_objects: Array)
signal ui_mode_changed(mode: String)
signal notification_shown(title: String, message: String, type: String)


func _ready():
	"""初始化事件总线"""
	name = "GameEvents"
	LogManager.info("GameEvents - 事件总线已初始化")


# === 便捷发射API ===

func emit_resource_change(type: String, amount: int, total: int):
	"""发射资源变化事件"""
	resource_changed.emit(type, amount, total)

func emit_building_complete(building):
	"""发射建筑完成事件"""
	building_completed.emit(building)

func emit_character_spawn(character):
	"""发射角色生成事件"""
	character_spawned.emit(character)

func emit_mining_complete(character, gold: int):
	"""发射挖矿完成事件"""
	mining_completed.emit(character, gold)

func emit_combat_start(attacker, target):
	"""发射战斗开始事件"""
	combat_started.emit(attacker, target)


# === 调试信息 ===

func get_all_signals() -> Array:
	"""获取所有信号列表（重命名避免与Object.get_signal_list()冲突）"""
	return [
		"resource_changed", "resource_insufficient", "resource_collected", "resource_spent",
		"building_placed", "building_completed", "building_destroyed", "building_upgraded", "building_damaged",
		"character_spawned", "character_died", "character_moved", "character_task_assigned",
		"character_task_completed", "character_state_changed",
		"gold_mine_discovered", "gold_mine_depleted", "mining_started", "mining_progress", "mining_completed",
		"combat_started", "damage_dealt", "unit_healed", "unit_killed", "knockback_applied",
		"game_started", "game_paused", "game_resumed", "game_over", "game_speed_changed", "day_changed",
		"selection_changed", "ui_mode_changed", "notification_shown"
	]

func print_signal_connections():
	"""打印所有信号的连接数（用于调试）"""
	LogManager.info("=== GameEvents Signal Connections ===")
	for signal_name in get_all_signals():
		var connections = get_signal_connection_list(signal_name)
		LogManager.info(signal_name + ": " + str(connections.size()) + " connections")
	LogManager.info("=====================================")
