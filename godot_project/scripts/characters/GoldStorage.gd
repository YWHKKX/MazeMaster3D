extends RefCounted
class_name GoldStorage

# 角色金币存储系统 - 基于GOLD_SYSTEM.md设计
# 为每个生物单位提供个人金币存储能力
# 日志管理器实例（全局变量）
# 金币存储属性
var current_gold: int = 0
var max_gold_capacity: int = 20
var creature_type: String = ""

# 信号
signal gold_added(amount: int, total: int)
signal gold_removed(amount: int, total: int)
signal gold_transferred(to_creature: String, amount: int)
signal storage_full()
signal storage_empty()


func _init(creature_type: String = "", initial_gold: int = 0):
	"""初始化金币存储"""
	self.creature_type = creature_type
	self.max_gold_capacity = _get_max_gold_storage(creature_type)
	self.current_gold = min(initial_gold, max_gold_capacity)


func add_gold(amount: int) -> int:
	"""添加金币到存储中"""
	if amount <= 0:
		return 0
	
	var old_amount = current_gold
	var available_space = max_gold_capacity - current_gold
	var actual_added = min(amount, available_space)
	
	current_gold += actual_added
	
	gold_added.emit(actual_added, current_gold)
	
	# 检查存储是否已满
	if current_gold >= max_gold_capacity:
		storage_full.emit()
	
	LogManager.log_resource_static("金币存储 - " + str(creature_type) + " 获得 " + str(actual_added) + " 金币，总计: " + str(current_gold))
	return actual_added


func remove_gold(amount: int) -> int:
	"""从存储中移除金币"""
	if amount <= 0:
		return 0
	
	var old_amount = current_gold
	var actual_removed = min(amount, current_gold)
	
	current_gold -= actual_removed
	
	gold_removed.emit(actual_removed, current_gold)
	
	# 检查存储是否为空
	if current_gold <= 0:
		storage_empty.emit()
	
	LogManager.log_resource_static("金币存储 - " + str(creature_type) + " 失去 " + str(actual_removed) + " 金币，总计: " + str(current_gold))
	return actual_removed


func can_store_gold(amount: int = 1) -> bool:
	"""检查是否可以存储指定数量的金币"""
	return (current_gold + amount) <= max_gold_capacity


func is_gold_storage_full() -> bool:
	"""检查金币存储是否已满"""
	return current_gold >= max_gold_capacity


func get_available_space() -> int:
	"""获取可用存储空间"""
	return max_gold_capacity - current_gold


func transfer_gold_to(target_storage: GoldStorage, amount: int = -1) -> int:
	"""将金币转移给目标单位"""
	if not target_storage:
		return 0
	
	# amount = -1 表示转移所有金币
	if amount == -1:
		amount = current_gold
	
	# 检查是否有足够的金币
	if amount > current_gold:
		amount = current_gold
	
	# 检查目标是否有足够空间
	var target_available = target_storage.get_available_space()
	var actual_transfer = min(amount, target_available)
	
	if actual_transfer > 0:
		# 从当前存储移除
		remove_gold(actual_transfer)
		# 添加到目标存储
		target_storage.add_gold(actual_transfer)
		
		gold_transferred.emit(target_storage.creature_type, actual_transfer)
		LogManager.log_resource_static("金币转移 - " + str(creature_type) + " -> " + str(target_storage.creature_type) + " 转移 " + str(actual_transfer) + " 金币")
	
	return actual_transfer


func get_gold_storage_info() -> Dictionary:
	"""获取金币存储信息"""
	return {
		"creature_type": creature_type,
		"current": current_gold,
		"max": max_gold_capacity,
		"available": get_available_space(),
		"percentage": float(current_gold) / float(max_gold_capacity) * 100.0,
		"is_full": is_gold_storage_full(),
		"is_empty": current_gold <= 0
	}


func _get_max_gold_storage(creature_type: String) -> int:
	"""获取生物的最大金币存储容量 - 基于GOLD_SYSTEM.md"""
	match creature_type:
		# 苦工和工程师
		"goblin_worker", "哥布林苦工":
			return 50
		"goblin_engineer", "地精工程师":
			return 60
		# 战斗单位
		"imp", "小恶魔":
			return 20
		"gargoyle", "石像鬼":
			return 30
		"salamander", "火蜥蜴":
			return 25
		"shadow_mage", "暗影法师":
			return 35
		"treant_guardian", "树人守护者":
			return 40
		"shadow_lord", "暗影领主":
			return 50
		"bone_dragon", "骨龙":
			return 60
		"hell_hound", "地狱犬":
			return 25
		"stone_golem", "石魔像":
			return 45
		"succubus", "魅魔":
			return 30
		"orc_warrior", "兽人战士":
			return 30
		# 英雄单位
		"knight", "骑士":
			return 30
		"archer", "弓箭手":
			return 25
		"mage", "法师":
			return 40
		"paladin", "圣骑士":
			return 35
		"assassin", "刺客":
			return 20
		"ranger", "游侠":
			return 30
		"archmage", "大法师":
			return 50
		"druid", "德鲁伊":
			return 35
		"dragon_knight", "龙骑士":
			return 45
		"shadow_blade", "暗影剑圣":
			return 25
		"berserker", "狂战士":
			return 20
		"priest", "牧师":
			return 30
		"thief", "盗贼":
			return 40
		"engineer", "工程师":
			return 60
		_:
			return 20 # 默认容量


# 调试功能
func debug_print_gold_info():
	"""调试：打印金币信息"""
	var info = get_gold_storage_info()
	LogManager.log_resource_static("=== 金币存储信息 ===")
	LogManager.log_resource_static("生物类型: " + str(info.creature_type))
	LogManager.log_resource_static("当前金币: " + str(info.current))
	LogManager.log_resource_static("最大容量: " + str(info.max))
	LogManager.log_resource_static("可用空间: " + str(info.available))
	LogManager.log_resource_static("存储百分比: " + str(info.percentage) + "%")
	LogManager.log_resource_static("是否已满: " + str(info.is_full))
	LogManager.log_resource_static("是否为空: " + str(info.is_empty))


func reset_gold():
	"""重置金币存储"""
	current_gold = 0
	LogManager.log_resource_static("金币存储已重置 - " + str(creature_type))


func set_gold(amount: int):
	"""直接设置金币数量"""
	current_gold = clamp(amount, 0, max_gold_capacity)
	LogManager.log_resource_static("金币存储设置 - " + str(creature_type) + " 设置为: " + str(current_gold))


func set_max_capacity(new_capacity: int):
	"""设置最大存储容量"""
	max_gold_capacity = max(1, new_capacity)
	current_gold = min(current_gold, max_gold_capacity)
	LogManager.log_resource_static("存储容量设置 - " + str(creature_type) + " 容量设置为: " + str(max_gold_capacity))
