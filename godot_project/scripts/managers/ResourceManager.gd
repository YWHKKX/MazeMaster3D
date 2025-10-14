extends Node
class_name ResourceManager

# 资源管理器 - 统一管理游戏中的资源获取和消耗
# 替代分散的 gold 和 mana 属性，从各个建筑中获取资源

# 资源类型枚举
enum ResourceType {
	GOLD, # 金币
	MANA, # 魔力
	STONE, # 石头
	WOOD, # 木材
	IRON # 铁矿
}

# 资源信息数据结构
class ResourceInfo:
	var total: int = 0
	var available: int = 0
	var capacity: int = 0
	var sources: Array = [] # Array of Dictionary
	
	func _init(t: int = 0, a: int = 0, c: int = 0, s: Array = []):
		total = t
		available = a
		capacity = c
		sources = s

# 维护建筑列表
var gold_buildings: Array = [] # 存储金币的建筑列表（地牢之心、金库）
var mana_buildings: Array = [] # 存储魔力的建筑列表（地牢之心、魔法祭坛）

# 其他资源存储（直接存储，不依赖建筑）
var stored_stone: int = 0
var stored_wood: int = 0
var stored_iron: int = 0

# 游戏实例引用
var game_instance = null

# [修复] 信号定义（供ResourceDisplayUI使用）
signal resource_changed(resource_type: ResourceType, amount: int, old_amount: int)
signal resource_added(resource_type: ResourceType, amount: int)
signal resource_removed(resource_type: ResourceType, amount: int)
signal insufficient_resources(resource_type: ResourceType, required: int, available: int)


func _ready():
	"""初始化资源管理器"""
	LogManager.info("ResourceManager - 初始化完成")


# ===== 辅助函数 =====

# 🗑️ [已废弃] _building_type_to_string 函数已删除
# 现在直接使用整数枚举值进行比较，不再需要字符串转换
# 
# 枚举参考：
# 0 = DUNGEON_HEART (地牢之心)
# 1 = TREASURY (金库)
# 2 = LAIR (巢穴)
# ... (参见 BuildingManager.BuildingType)


# ===== 建筑注册管理 =====

func add_gold_building(building) -> void:
	"""添加存储金币的建筑到列表"""
	if building not in gold_buildings:
		gold_buildings.append(building)
		var building_name = building.building_name if "building_name" in building else "未知建筑"
		LogManager.info("ResourceManager - 已添加金币建筑: " + building_name)


func add_mana_building(building) -> void:
	"""添加存储魔力的建筑到列表"""
	if building not in mana_buildings:
		mana_buildings.append(building)
		var building_name = building.building_name if "building_name" in building else "未知建筑"
		LogManager.info("ResourceManager - 已添加魔力建筑: " + building_name)


func remove_gold_building(building) -> void:
	"""从金币建筑列表中移除建筑"""
	if building in gold_buildings:
		gold_buildings.erase(building)
		var building_name = building.building_name if "building_name" in building else "未知建筑"
		LogManager.info("ResourceManager - 已移除金币建筑: " + building_name)


func remove_mana_building(building) -> void:
	"""从魔力建筑列表中移除建筑"""
	if building in mana_buildings:
		mana_buildings.erase(building)
		var building_name = building.building_name if "building_name" in building else "未知建筑"
		LogManager.info("ResourceManager - 已移除魔力建筑: " + building_name)


func register_dungeon_heart(dungeon_heart) -> void:
	"""注册地牢之心到两个建筑列表"""
	add_gold_building(dungeon_heart)
	add_mana_building(dungeon_heart)
	LogManager.info("ResourceManager - 地牢之心已注册")


func register_treasury(treasury) -> void:
	"""注册金库到金币建筑列表"""
	add_gold_building(treasury)


func register_magic_altar(magic_altar) -> void:
	"""注册魔法祭坛到魔力建筑列表"""
	add_mana_building(magic_altar)


# ===== 资源查询 =====

func get_total_gold() -> ResourceInfo:
	"""获取总金币数量（从金币建筑列表中汇总）"""
	var sources = []
	var total_gold = 0
	var total_capacity = 0
	
	
	# 从金币建筑列表中获取金币
	for building in gold_buildings:
		if "stored_gold" in building:
			var building_name = building.building_name if "building_name" in building else "未知建筑"
			var building_type = building.building_type if "building_type" in building else null
			# 🔧 enum值是int，不是对象，不能访问.value
			var building_type_name = str(building_type) if building_type != null else "unknown"
			
			# 获取位置信息
			var position = ""
			if "tile_x" in building and "tile_y" in building:
				position = "(%d,%d)" % [building.tile_x, building.tile_y]
			
			var capacity = building.gold_storage_capacity if "gold_storage_capacity" in building else 0
			
			sources.append({
				"building": building_type_name,
				"name": building_name + position,
				"amount": building.stored_gold,
				"capacity": capacity,
				"available": building.stored_gold
			})
			total_gold += building.stored_gold
			total_capacity += capacity
	
	return ResourceInfo.new(total_gold, total_gold, total_capacity, sources)

func get_gold() -> int:
	"""获取当前可用金币总数（便捷方法）"""
	var gold_info = get_total_gold()
	if gold_info:
		return gold_info.total
	return 0

func remove_gold(amount: int) -> bool:
	"""移除指定数量的金币（便捷方法，调用 consume_gold）
	
	Returns:
		bool: 是否成功移除
	"""
	var result = consume_gold(amount)
	return result.success


func get_total_mana() -> ResourceInfo:
	"""获取总魔力数量（从魔力建筑列表中汇总）"""
	var sources = []
	var total_mana = 0
	var total_capacity = 0
	
	# 从魔力建筑列表中获取魔力
	for building in mana_buildings:
		if "stored_mana" in building:
			var building_name = building.building_name if "building_name" in building else "未知建筑"
			var building_type = building.building_type if "building_type" in building else null
			# 🔧 enum值是int，不是对象，不能访问.value
			var building_type_name = str(building_type) if building_type != null else "unknown"
			
			# 获取位置信息
			var position = ""
			if "tile_x" in building and "tile_y" in building:
				position = "(%d,%d)" % [building.tile_x, building.tile_y]
			
			var capacity = building.mana_storage_capacity if "mana_storage_capacity" in building else 0
			
			sources.append({
				"building": building_type_name,
				"name": building_name + position,
				"amount": building.stored_mana,
				"capacity": capacity,
				"available": building.stored_mana
			})
			total_mana += building.stored_mana
			total_capacity += capacity
	
	return ResourceInfo.new(total_mana, total_mana, total_capacity, sources)


func can_afford(gold_cost: int = 0, mana_cost: int = 0) -> bool:
	"""检查是否有足够的资源"""
	var gold_info = get_total_gold()
	var mana_info = get_total_mana()
	
	return gold_info.available >= gold_cost and mana_info.available >= mana_cost


# ===== 资源消耗 =====

func consume_gold(amount: int, priority_sources: Array = []) -> Dictionary:
	"""消耗金币（按优先级从金币建筑列表中消耗）
	
	Args:
		amount: 要消耗的金币数量
		priority_sources: 优先级来源列表（整数枚举数组），如 [0, 1] (DUNGEON_HEART, TREASURY)
	
	Returns:
		Dictionary: 消耗结果
	"""
	# 🔧 使用 BuildingTypes autoload 常量
	if priority_sources.is_empty():
		priority_sources = [BuildingTypes.DUNGEON_HEART, BuildingTypes.TREASURY]
	
	var remaining_amount = amount
	var consumed_sources = []
	
	# 按优先级消耗金币
	for source_type in priority_sources:
		if remaining_amount <= 0:
			break
		
		for building in gold_buildings:
			if remaining_amount <= 0:
				break
			
			# 检查建筑类型是否匹配优先级
			var building_type = building.building_type if "building_type" in building else null
			# 🔧 修复：直接用整数比较枚举值
			if building_type != null and building_type == source_type:
				if "stored_gold" in building and building.stored_gold > 0:
					var available = building.stored_gold
					var consume_amount = min(remaining_amount, available)
					
					if consume_amount > 0:
						building.stored_gold -= consume_amount
						remaining_amount -= consume_amount
						
						# 🔧 [状态栏系统] 更新建筑存储显示
						if building.has_method("_update_storage_display"):
							building._update_storage_display()
						
						# 获取位置信息
						var position = ""
						if "tile_x" in building and "tile_y" in building:
							position = "(%d,%d)" % [building.tile_x, building.tile_y]
						
						# 🔧 修复：使用建筑名称而不是枚举数字
						var building_name = building.building_name if "building_name" in building else "建筑"
						consumed_sources.append({
							"source": building_name + position,
							"amount": consume_amount,
							"remaining": building.stored_gold
						})
	
	# 发射信号通知UI更新
	if amount - remaining_amount > 0:
		var consumed = amount - remaining_amount
		resource_removed.emit(ResourceType.GOLD, consumed)
		# 获取当前总金币并发出变化信号
		var current_gold = get_total_gold()
		resource_changed.emit(ResourceType.GOLD, current_gold.total, current_gold.total + consumed)
	
	# 如果资源不足，发射警告信号
	if remaining_amount > 0:
		var gold_check = get_total_gold()
		var available = gold_check.available if gold_check else 0
		insufficient_resources.emit(ResourceType.GOLD, amount, available)
	
	return {
		"success": remaining_amount == 0,
		"requested": amount,
		"consumed": amount - remaining_amount,
		"remaining_needed": remaining_amount,
		"sources": consumed_sources
	}


func consume_mana(amount: int, priority_sources: Array = []) -> Dictionary:
	"""消耗魔力（按优先级从魔力建筑列表中消耗）
	
	Args:
		amount: 要消耗的魔力数量
		priority_sources: 优先级来源列表（整数枚举数组），如 [0, 23] (DUNGEON_HEART, MAGIC_ALTAR)
	
	Returns:
		Dictionary: 消耗结果
	"""
	# 🔧 使用 BuildingTypes autoload 常量
	if priority_sources.is_empty():
		priority_sources = [BuildingTypes.DUNGEON_HEART, BuildingTypes.MAGIC_ALTAR]
	
	var remaining_amount = amount
	var consumed_sources = []
	
	# 按优先级消耗魔力
	for source_type in priority_sources:
		if remaining_amount <= 0:
			break
		
		for building in mana_buildings:
			if remaining_amount <= 0:
				break
			
			# 检查建筑类型是否匹配优先级
			var building_type = building.building_type if "building_type" in building else null
			# 🔧 修复：直接用整数比较枚举值
			if building_type != null and building_type == source_type:
				if "stored_mana" in building and building.stored_mana > 0:
					var available = building.stored_mana
					var consume_amount = min(remaining_amount, available)
					
					if consume_amount > 0:
						building.stored_mana -= consume_amount
						remaining_amount -= consume_amount
						
						# 获取位置信息
						var position = ""
						if "tile_x" in building and "tile_y" in building:
							position = "(%d,%d)" % [building.tile_x, building.tile_y]
						
						# 🔧 修复：使用建筑名称而不是枚举数字
						var building_name = building.building_name if "building_name" in building else "建筑"
						consumed_sources.append({
							"source": building_name + position,
							"amount": consume_amount,
							"remaining": building.stored_mana
						})
	
	return {
		"success": remaining_amount == 0,
		"requested": amount,
		"consumed": amount - remaining_amount,
		"remaining_needed": remaining_amount,
		"sources": consumed_sources
	}


# ===== 资源添加 =====

func add_resource(resource_type: ResourceType, amount: int, target_building = null) -> int:
	"""添加资源（统一接口）
	
	Args:
		resource_type: 资源类型
		amount: 要添加的数量
		target_building: 目标建筑，如果为null则添加到地牢之心（仅 GOLD/MANA）
	
	Returns:
		int: 实际添加的数量
	"""
	match resource_type:
		ResourceType.GOLD:
			var result = add_gold(amount, target_building)
			return result.get("amount", 0) if result.get("success", false) else 0
		ResourceType.MANA:
			var result = add_mana(amount, target_building)
			return result.get("amount", 0) if result.get("success", false) else 0
		ResourceType.STONE:
			stored_stone += amount
			return amount
		ResourceType.WOOD:
			stored_wood += amount
			return amount
		ResourceType.IRON:
			stored_iron += amount
			return amount
	return 0


func add_gold(amount: int, target_building = null) -> Dictionary:
	"""添加金币到指定建筑
	
	Args:
		amount: 要添加的金币数量
		target_building: 目标建筑对象，如果为null则添加到地牢之心
	
	Returns:
		Dictionary: 添加结果
	"""
	# 如果没有指定目标建筑，默认添加到地牢之心
	if target_building == null:
		for building in gold_buildings:
			var building_type = building.building_type if "building_type" in building else null
			# 🔧 使用 BuildingTypes autoload 常量
			if building_type != null and building_type == BuildingTypes.DUNGEON_HEART:
				target_building = building
				break
	
	if target_building and "stored_gold" in target_building:
		var old_amount = target_building.stored_gold
		target_building.stored_gold += amount
		
		# 🔧 [状态栏系统] 更新建筑存储显示
		if target_building.has_method("_update_storage_display"):
			target_building._update_storage_display()
		
		# [修复] 发射信号通知UI更新
		resource_added.emit(ResourceType.GOLD, amount)
		resource_changed.emit(ResourceType.GOLD, target_building.stored_gold, old_amount)
		
		var building_name = target_building.building_name if "building_name" in target_building else "未知建筑"
		return {
			"success": true,
			"amount": amount,
			"old_amount": old_amount,
			"new_amount": target_building.stored_gold,
			"target": building_name
		}
	
	return {
		"success": false,
		"amount": 0,
		"message": "无法添加金币到指定建筑"
	}


func add_mana(amount: int, target_building = null) -> Dictionary:
	"""添加魔力到指定建筑
	
	Args:
		amount: 要添加的魔力数量
		target_building: 目标建筑对象，如果为null则添加到地牢之心
	
	Returns:
		Dictionary: 添加结果
	"""
	# 如果没有指定目标建筑，默认添加到地牢之心
	if target_building == null:
		for building in mana_buildings:
			var building_type = building.building_type if "building_type" in building else null
			# 🔧 使用 BuildingTypes autoload 常量
			if building_type != null and building_type == BuildingTypes.DUNGEON_HEART:
				target_building = building
				break
	
	if target_building and "stored_mana" in target_building:
		var old_amount = target_building.stored_mana
		target_building.stored_mana += amount
		
		var building_name = target_building.building_name if "building_name" in target_building else "未知建筑"
		return {
			"success": true,
			"amount": amount,
			"old_amount": old_amount,
			"new_amount": target_building.stored_mana,
			"target": building_name
		}
	
	return {
		"success": false,
		"amount": 0,
		"message": "无法添加魔力到指定建筑"
	}


# ===== 资源汇总 =====

func get_resource_amount(resource_type: ResourceType) -> int:
	"""获取指定资源的数量
	
	Args:
		resource_type: 资源类型
	
	Returns:
		int: 资源数量
	"""
	match resource_type:
		ResourceType.GOLD:
			var gold_info = get_total_gold()
			return gold_info.total if gold_info else 0
		ResourceType.MANA:
			var mana_info = get_total_mana()
			return mana_info.total if mana_info else 0
		ResourceType.STONE:
			return stored_stone
		ResourceType.WOOD:
			return stored_wood
		ResourceType.IRON:
			return stored_iron
	return 0


func consume_resource(resource_type: ResourceType, amount: int) -> bool:
	"""消耗指定资源
	
	Args:
		resource_type: 资源类型
		amount: 要消耗的数量
	
	Returns:
		bool: 是否成功消耗
	"""
	match resource_type:
		ResourceType.GOLD:
			var result = consume_gold(amount)
			return result.success
		ResourceType.MANA:
			var result = consume_mana(amount)
			return result.success
		ResourceType.STONE:
			if stored_stone >= amount:
				stored_stone -= amount
				return true
			return false
		ResourceType.WOOD:
			if stored_wood >= amount:
				stored_wood -= amount
				return true
			return false
		ResourceType.IRON:
			if stored_iron >= amount:
				stored_iron -= amount
				return true
			return false
	return false


func get_resource_summary() -> Dictionary:
	"""获取资源汇总信息"""
	var gold_info = get_total_gold()
	var mana_info = get_total_mana()
	
	return {
		"gold": {
			"total": gold_info.total if gold_info else 0,
			"available": gold_info.available if gold_info else 0,
			"capacity": gold_info.capacity if gold_info else 0,
			"sources": gold_info.sources if gold_info else []
		},
		"mana": {
			"total": mana_info.total if mana_info else 0,
			"available": mana_info.available if mana_info else 0,
			"capacity": mana_info.capacity if mana_info else 0,
			"sources": mana_info.sources if mana_info else []
		},
		"stone": {
			"total": stored_stone,
			"available": stored_stone,
			"capacity": 999999
		},
		"wood": {
			"total": stored_wood,
			"available": stored_wood,
			"capacity": 999999
		},
		"iron": {
			"total": stored_iron,
			"available": stored_iron,
			"capacity": 999999
		}
	}


# ===== 调试功能 =====

func debug_print_resources():
	"""调试：打印所有资源信息"""
	LogManager.info("=== 资源管理器调试信息 ===")
	
	var gold_info = get_total_gold()
	if gold_info:
		LogManager.info("金币总量: " + str(gold_info.total) + " / " + str(gold_info.capacity))
		for source in gold_info.sources:
			LogManager.info("  - " + source.name + ": " + str(source.amount))
	else:
		LogManager.info("金币总量: 0 (ResourceInfo为空)")
	
	var mana_info = get_total_mana()
	if mana_info:
		LogManager.info("魔力总量: " + str(mana_info.total) + " / " + str(mana_info.capacity))
		for source in mana_info.sources:
			LogManager.info("  - " + source.name + ": " + str(source.amount))
	else:
		LogManager.info("魔力总量: 0 (ResourceInfo为空)")
