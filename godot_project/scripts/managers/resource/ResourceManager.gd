extends Node
class_name ResourceManager

# 资源管理器 - 统一管理游戏中的资源获取和消耗
# 替代分散的 gold 和 mana 属性，从各个建筑中获取资源

# 资源类型枚举 - 三级分类体系
enum ResourceType {
	# 🥇 核心资源 (Core Resources) - 游戏核心机制，玩家生存必需
	GOLD, # 金币
	FOOD, # 食物
	
	# 🥈 基础资源 (Basic Resources) - 建筑和装备制作基础材料
	STONE, # 石头
	WOOD, # 木材
	IRON, # 铁矿
	
	# 🥉 特殊资源 (Special Resources) - 高级装备、魔法物品、特殊建筑
	GEM, # 宝石
	MAGIC_HERB, # 魔法草药
	MAGIC_CRYSTAL, # 魔法水晶
	DEMON_CORE, # 恶魔核心
	MANA # 魔力 - 由特殊建筑产生
}

# 资源分类枚举
enum ResourceCategory {
	CORE, # 核心资源
	BASIC, # 基础资源
	SPECIAL # 特殊资源
}

# 金矿状态枚举 - 与GoldMineManager保持一致
enum MineStatus {
	UNDISCOVERED, # 未发现
	ACTIVE, # 活跃中
	BEING_MINED, # 正在挖掘
	EXHAUSTED # 已枯竭
}

# 资源信息结构 - 包含分类和生成属性
class ResourceInfo:
	var total: int = 0
	var available: int = 0
	var capacity: int = 0
	var sources: Array = [] # Array of Dictionary
	var category: ResourceCategory = ResourceCategory.CORE
	var generation_probability: float = 0.0
	var respawn_time: float = 0.0
	var amount_range: Array = [1, 10] # [min, max] 采集量范围
	var terrain_types: Array = [] # 可生成的地形类型
	
	func _init(t: int = 0, a: int = 0, c: int = 0, s: Array = [], cat: ResourceCategory = ResourceCategory.CORE, prob: float = 0.0, respawn: float = 0.0, range_array: Array = [1, 10], terrains: Array = []):
		total = t
		available = a
		capacity = c
		sources = s
		category = cat
		generation_probability = prob
		respawn_time = respawn
		amount_range = range_array
		terrain_types = terrains

# 资源配置常量 - 根据重构计划定义
const RESOURCE_CONFIG = {
	ResourceType.GOLD: {
		"category": ResourceCategory.CORE,
		"probability": 0.25,
		"respawn_time": 120.0, # 2分钟
		"amount_range": [50, 200],
		"terrain_types": ["EMPTY", "STONE_FLOOR", "DIRT_FLOOR", "CORRIDOR", "CAVE", "FOREST", "WASTELAND", "SWAMP"]
	},
	ResourceType.FOOD: {
		"category": ResourceCategory.CORE,
		"probability": 0.20,
		"respawn_time": 180.0, # 3分钟
		"amount_range": [30, 100],
		"terrain_types": ["FOREST", "GRASS", "LAKE"]
	},
	ResourceType.STONE: {
		"category": ResourceCategory.BASIC,
		"probability": 0.18,
		"respawn_time": 300.0, # 5分钟
		"amount_range": [40, 120],
		"terrain_types": ["CAVE", "WASTELAND"]
	},
	ResourceType.WOOD: {
		"category": ResourceCategory.BASIC,
		"probability": 0.22,
		"respawn_time": 360.0, # 6分钟
		"amount_range": [35, 100],
		"terrain_types": ["FOREST", "GRASS"]
	},
	ResourceType.IRON: {
		"category": ResourceCategory.BASIC,
		"probability": 0.16,
		"respawn_time": 420.0, # 7分钟
		"amount_range": [25, 80],
		"terrain_types": ["CAVE", "WASTELAND"]
	},
	ResourceType.GEM: {
		"category": ResourceCategory.SPECIAL,
		"probability": 0.08,
		"respawn_time": 900.0, # 15分钟
		"amount_range": [5, 20],
		"terrain_types": ["CAVE_DEEP"]
	},
	ResourceType.MAGIC_HERB: {
		"category": ResourceCategory.SPECIAL,
		"probability": 0.06,
		"respawn_time": 1200.0, # 20分钟
		"amount_range": [3, 15],
		"terrain_types": ["FOREST_DEEP"]
	},
	ResourceType.MAGIC_CRYSTAL: {
		"category": ResourceCategory.SPECIAL,
		"probability": 0.04,
		"respawn_time": 1800.0, # 30分钟
		"amount_range": [2, 10],
		"terrain_types": ["DEAD_LAND", "MAGIC_AREA"]
	},
	ResourceType.DEMON_CORE: {
		"category": ResourceCategory.SPECIAL,
		"probability": 0.02,
		"respawn_time": 3600.0, # 60分钟
		"amount_range": [1, 3],
		"terrain_types": ["DEAD_LAND_DEEP"]
	},
	ResourceType.MANA: {
		"category": ResourceCategory.SPECIAL,
		"probability": 0.0, # 不由地形生成，由建筑产生
		"respawn_time": 0.0,
		"amount_range": [5, 15], # 每分钟产生量
		"terrain_types": [] # 无地形限制
	}
}

# 维护建筑列表
var gold_buildings: Array = [] # 存储金币的建筑列表（地牢之心、金库）
var mana_buildings: Array = [] # 存储魔力的建筑列表（地牢之心、魔法祭坛）

# 资源存储系统 - 支持三级分类
var resource_storage: Dictionary = {} # 存储所有资源类型
var resource_spawns: Array = [] # 存储资源生成点信息
var resource_visualization_enabled: bool = true # 是否启用资源可视化

# 自动资源生成系统
var auto_spawn_timer: Timer = null # 自动生成定时器
var auto_spawn_enabled: bool = true # 是否启用自动生成
var spawn_interval: float = 30.0 # 生成间隔（秒）
var max_spawns_per_interval: int = 5 # 每次生成的最大数量

# 金矿系统集成
var gold_mines: Array = [] # 存储金矿信息
var mine_counter: int = 0 # 金矿计数器
var gold_mine_config = {
	"discovery_chance": 0.08, # 8%概率发现金矿
	"initial_gold": 500, # 初始黄金储量
	"mining_rate": 2, # 每秒挖掘2金币
	"carry_capacity": 20, # 携带容量
	"mine_radius": 100.0, # 金矿检测半径
	"max_mines": 50 # 最大金矿数量
}

# 地形概率倍数配置
const TERRAIN_MULTIPLIERS = {
	"EMPTY": 0.5,
	"STONE_FLOOR": 0.8,
	"DIRT_FLOOR": 1.0,
	"CORRIDOR": 0.3,
	"FOREST": 1.5,
	"CAVE": 1.2,
	"WASTELAND": 0.8,
	"SWAMP": 1.0,
	"GRASS": 1.2,
	"LAKE": 1.0,
	"FOREST_DEEP": 2.0,
	"CAVE_DEEP": 1.8,
	"DEAD_LAND": 0.6,
	"MAGIC_AREA": 1.5,
	"DEAD_LAND_DEEP": 0.4
}

# 游戏实例引用
var game_instance = null

# [修复] 信号定义（供ResourceDisplayUI使用）
signal resource_changed(resource_type: ResourceType, amount: int, old_amount: int)
signal resource_added(resource_type: ResourceType, amount: int)
signal resource_removed(resource_type: ResourceType, amount: int)
signal insufficient_resources(resource_type: ResourceType, required: int, available: int)
signal resource_spawned(resource_type: ResourceType, position: Vector2, amount: int)
signal resource_depleted(resource_type: ResourceType, position: Vector2)
signal resource_respawned(resource_type: ResourceType, position: Vector2, amount: int)

# 金矿系统信号
signal gold_mine_discovered(position: Vector3, gold_amount: int)
signal gold_mine_exhausted(position: Vector3)
signal gold_mined(position: Vector3, amount: int)


func _ready():
	"""初始化资源管理器"""
	initialize_resource_storage()
	_setup_auto_spawn_system()
	_initialize_gold_mine_system()
	LogManager.info("ResourceManager - 初始化完成，支持三级资源分类体系")

func initialize_resource_storage():
	"""初始化资源存储系统"""
	for resource_type in ResourceType.values():
		resource_storage[resource_type] = 0
	
	LogManager.info("ResourceManager - 资源存储系统初始化完成，支持 %d 种资源类型" % ResourceType.size())

func _setup_auto_spawn_system():
	"""设置自动资源生成系统"""
	if not auto_spawn_enabled:
		return
	
	# 创建自动生成定时器
	auto_spawn_timer = Timer.new()
	auto_spawn_timer.wait_time = spawn_interval
	auto_spawn_timer.timeout.connect(_on_auto_spawn_timer_timeout)
	auto_spawn_timer.autostart = true
	add_child(auto_spawn_timer)
	
	LogManager.info("ResourceManager - 自动资源生成系统已启动，间隔: %.1f秒" % spawn_interval)

func _on_auto_spawn_timer_timeout():
	"""自动生成定时器超时回调"""
	if not auto_spawn_enabled:
		return
	
	_auto_spawn_resources()

func _auto_spawn_resources():
	"""自动生成资源"""
	if not GameServices.has_method("get_tile_manager"):
		return
	
	var tile_manager = GameServices.get_tile_manager()
	if not tile_manager:
		return
	
	# 获取地图信息
	var map_size = tile_manager.get_map_size()
	if map_size == Vector3.ZERO:
		return
	
	var spawned_count = 0
	var max_attempts = max_spawns_per_interval * 3 # 允许更多尝试次数
	
	for attempt in range(max_attempts):
		if spawned_count >= max_spawns_per_interval:
			break
		
		# 随机选择位置
		var x = randi_range(0, int(map_size.x) - 1)
		var z = randi_range(0, int(map_size.z) - 1)
		var position = Vector2(x, z)
		
		# 获取地形类型
		var terrain_type = tile_manager.get_tile_type(Vector3(x, 0, z))
		if terrain_type == TileTypes.TileType.EMPTY:
			continue
		
		# 随机选择资源类型（排除MANA，因为它由建筑产生）
		var available_resources = []
		for resource_type in ResourceType.values():
			if resource_type != ResourceType.MANA:
				var config = get_resource_config(resource_type)
				if not config.is_empty() and terrain_type in config.get("terrain_types", []):
					available_resources.append(resource_type)
		
		if available_resources.is_empty():
			continue
		
		# 随机选择资源类型
		var resource_type = available_resources[randi() % available_resources.size()]
		
		# 尝试生成资源
		if spawn_resource(resource_type, position, terrain_type):
			spawned_count += 1
	
	if spawned_count > 0:
		LogManager.info("ResourceManager - 自动生成了 %d 个资源点" % spawned_count)


# ===== 辅助函数 =====

func get_resource_category(resource_type: ResourceType) -> ResourceCategory:
	"""获取资源分类"""
	if resource_type in RESOURCE_CONFIG:
		return RESOURCE_CONFIG[resource_type].category
	return ResourceCategory.CORE

func get_resource_config(resource_type: ResourceType) -> Dictionary:
	"""获取资源配置信息"""
	if resource_type in RESOURCE_CONFIG:
		return RESOURCE_CONFIG[resource_type]
	return {}

func calculate_resource_probability(resource_type: ResourceType, terrain_type: String) -> float:
	"""计算资源生成概率"""
	var config = get_resource_config(resource_type)
	if config.is_empty():
		return 0.0
	
	var base_probability = config.get("probability", 0.0)
	var terrain_multiplier = TERRAIN_MULTIPLIERS.get(terrain_type, 1.0)
	var density_modifier = get_area_density_modifier()
	
	return base_probability * terrain_multiplier * density_modifier

func get_area_density_modifier() -> float:
	"""获取区域密度修正值"""
	# 可以根据当前区域资源密度动态调整
	# 资源稀少时增加生成概率，资源丰富时降低生成概率
	return 1.0 # 默认值，可以后续优化

func get_resource_icon(resource_type: ResourceType) -> String:
	"""获取资源图标"""
	match resource_type:
		ResourceType.GOLD:
			return "💰"
		ResourceType.FOOD:
			return "🍖"
		ResourceType.STONE:
			return "🔳" # 使用方块替代石头
		ResourceType.WOOD:
			return "📦" # 使用箱子替代木材
		ResourceType.IRON:
			return "⛏️"
		ResourceType.GEM:
			return "💎"
		ResourceType.MAGIC_HERB:
			return "🌿"
		ResourceType.MAGIC_CRYSTAL:
			return "✨"
		ResourceType.DEMON_CORE:
			return "👹"
		ResourceType.MANA:
			return "✨"
		_:
			return "❓"

func get_resource_name(resource_type: ResourceType) -> String:
	"""获取资源名称"""
	match resource_type:
		ResourceType.GOLD:
			return "金币"
		ResourceType.FOOD:
			return "食物"
		ResourceType.STONE:
			return "石头"
		ResourceType.WOOD:
			return "木材"
		ResourceType.IRON:
			return "铁矿"
		ResourceType.GEM:
			return "宝石"
		ResourceType.MAGIC_HERB:
			return "魔法草药"
		ResourceType.MAGIC_CRYSTAL:
			return "魔法水晶"
		ResourceType.DEMON_CORE:
			return "恶魔核心"
		ResourceType.MANA:
			return "魔力"
		_:
			return "未知资源"

# ===== 资源生成系统 =====

func spawn_resource(resource_type: ResourceType, position: Vector2, terrain_type: String) -> bool:
	"""生成资源点"""
	var config = get_resource_config(resource_type)
	if config.is_empty():
		return false
	
	# 检查地形是否支持该资源生成
	var supported_terrains = config.get("terrain_types", [])
	if not supported_terrains.is_empty() and terrain_type not in supported_terrains:
		return false
	
	# 计算生成概率
	var probability = calculate_resource_probability(resource_type, terrain_type)
	if randf() > probability:
		return false
	
	# 生成资源数量
	var amount_range = config.get("amount_range", [1, 10])
	var amount = randi_range(amount_range[0], amount_range[1])
	
	# 创建资源生成点
	var resource_spawn = {
		"resource_type": resource_type,
		"position": position,
		"amount": amount,
		"max_amount": amount,
		"terrain_type": terrain_type,
		"spawn_time": Time.get_unix_time_from_system(),
		"respawn_time": config.get("respawn_time", 0.0),
		"is_depleted": false
	}
	
	resource_spawns.append(resource_spawn)
	
	# 🌿 创建视觉资源对象
	_create_visual_resource_object(resource_type, Vector3(position.x, 0, position.y), amount)
	
	# 发射信号
	resource_spawned.emit(resource_type, position, amount)
	
	LogManager.info("ResourceManager - 生成资源: %s 在位置 %s，数量: %d" % [get_resource_name(resource_type), str(position), amount])
	return true

func collect_resource(position: Vector2) -> Dictionary:
	"""采集资源"""
	for spawn in resource_spawns:
		if spawn.position == position and not spawn.is_depleted:
			var resource_type = spawn.resource_type
			var amount = spawn.amount
			
			# 标记为已耗尽
			spawn.is_depleted = true
			
			# 添加到存储
			resource_storage[resource_type] += amount
			
			# 发射信号
			resource_depleted.emit(resource_type, position)
			resource_added.emit(resource_type, amount)
			
			# 设置重生定时器
			if spawn.respawn_time > 0:
				var timer = Timer.new()
				timer.wait_time = spawn.respawn_time
				timer.one_shot = true
				timer.timeout.connect(_on_resource_respawn.bind(spawn))
				add_child(timer)
				timer.start()
			
			LogManager.info("ResourceManager - 采集资源: %s 数量: %d" % [get_resource_name(resource_type), amount])
			
			return {
				"success": true,
				"resource_type": resource_type,
				"amount": amount,
				"position": position
			}
	
	return {
		"success": false,
		"message": "该位置没有可采集的资源"
	}

func _on_resource_respawn(spawn: Dictionary):
	"""资源重生回调"""
	var config = get_resource_config(spawn.resource_type)
	var amount_range = config.get("amount_range", [1, 10])
	var new_amount = randi_range(amount_range[0], amount_range[1])
	
	spawn.amount = new_amount
	spawn.max_amount = new_amount
	spawn.is_depleted = false
	spawn.spawn_time = Time.get_unix_time_from_system()
	
	# 发射信号
	resource_respawned.emit(spawn.resource_type, spawn.position, new_amount)
	
	LogManager.info("ResourceManager - 资源重生: %s 在位置 %s，数量: %d" % [get_resource_name(spawn.resource_type), str(spawn.position), new_amount])

func _create_visual_resource_object(resource_type: ResourceType, position: Vector3, amount: int) -> void:
	"""创建视觉资源对象"""
	# 获取增强资源渲染器
	var enhanced_renderer = GameServices.get_enhanced_resource_renderer()
	if not enhanced_renderer:
		LogManager.warning("ResourceManager - EnhancedResourceRenderer未找到，跳过视觉对象创建")
		return
	
	# 创建视觉对象
	var visual_object = enhanced_renderer.create_resource_object(resource_type, position, amount)
	if visual_object:
		LogManager.debug("ResourceManager - 创建视觉资源对象: %s 在位置 %s" % [get_resource_name(resource_type), str(position)])

func get_resources_at_position(position: Vector2) -> Array:
	"""获取指定位置的资源"""
	var resources = []
	for spawn in resource_spawns:
		if spawn.position == position and not spawn.is_depleted:
			resources.append(spawn)
	return resources

func get_all_resource_spawns() -> Array:
	"""获取所有资源生成点"""
	return resource_spawns

func toggle_resource_visualization():
	"""切换资源可视化显示"""
	resource_visualization_enabled = !resource_visualization_enabled
	LogManager.info("ResourceManager - 资源可视化: %s" % ("开启" if resource_visualization_enabled else "关闭"))

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
		priority_sources = [BuildingTypes.BuildingType.DUNGEON_HEART, BuildingTypes.BuildingType.TREASURY]
	
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
		priority_sources = [BuildingTypes.BuildingType.DUNGEON_HEART, BuildingTypes.BuildingType.MAGIC_ALTAR]
	
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
		_:
			# 其他资源类型直接添加到存储
			var old_amount = resource_storage.get(resource_type, 0)
			resource_storage[resource_type] = old_amount + amount
			
			# 发射信号
			resource_added.emit(resource_type, amount)
			resource_changed.emit(resource_type, resource_storage[resource_type], old_amount)
			
			return amount


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
			if building_type != null and building_type == BuildingTypes.BuildingType.DUNGEON_HEART:
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
			if building_type != null and building_type == BuildingTypes.BuildingType.DUNGEON_HEART:
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
		_:
			return resource_storage.get(resource_type, 0)


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
		_:
			var current_amount = resource_storage.get(resource_type, 0)
			if current_amount >= amount:
				var old_amount = current_amount
				resource_storage[resource_type] = current_amount - amount
				
				# 发射信号
				resource_removed.emit(resource_type, amount)
				resource_changed.emit(resource_type, resource_storage[resource_type], old_amount)
				
				return true
			else:
				# 资源不足，发射警告信号
				insufficient_resources.emit(resource_type, amount, current_amount)
	return false


func get_resource_summary() -> Dictionary:
	"""获取资源汇总信息 - 按三级分类组织"""
	var summary = {
		"core_resources": {},
		"basic_resources": {},
		"special_resources": {}
	}
	
	# 遍历所有资源类型
	for resource_type in ResourceType.values():
		var category = get_resource_category(resource_type)
		var amount = get_resource_amount(resource_type)
		var config = get_resource_config(resource_type)
		var resource_info = {
			"type": resource_type,
			"name": get_resource_name(resource_type),
			"icon": get_resource_icon(resource_type),
			"total": amount,
			"available": amount,
			"capacity": 999999, # 默认无限容量
			"category": category,
			"config": config
		}
		
		# 根据分类添加到对应组
		match category:
			ResourceCategory.CORE:
				summary.core_resources[resource_type] = resource_info
			ResourceCategory.BASIC:
				summary.basic_resources[resource_type] = resource_info
			ResourceCategory.SPECIAL:
				summary.special_resources[resource_type] = resource_info
	
	# 特殊处理金币和魔力（来自建筑）
	var gold_info = get_total_gold()
	if gold_info:
		summary.core_resources[ResourceType.GOLD].update({
			"capacity": gold_info.capacity,
			"sources": gold_info.sources
		})
	
	var mana_info = get_total_mana()
	if mana_info:
		summary.special_resources[ResourceType.MANA].update({
			"capacity": mana_info.capacity,
			"sources": mana_info.sources
		})
	
	return summary


# ===== 调试功能 =====

func debug_print_resources():
	"""调试：打印所有资源信息 - 按三级分类显示"""
	LogManager.info("=== 资源管理器调试信息 ===")
	
	var summary = get_resource_summary()
	
	# 核心资源
	LogManager.info("🥇 核心资源:")
	for resource_type in summary.core_resources:
		var info = summary.core_resources[resource_type]
		LogManager.info("  %s %s: %d" % [info.icon, info.name, info.total])
	
	# 基础资源
	LogManager.info("🥈 基础资源:")
	for resource_type in summary.basic_resources:
		var info = summary.basic_resources[resource_type]
		LogManager.info("  %s %s: %d" % [info.icon, info.name, info.total])
	
	# 特殊资源
	LogManager.info("🥉 特殊资源:")
	for resource_type in summary.special_resources:
		var info = summary.special_resources[resource_type]
		LogManager.info("  %s %s: %d" % [info.icon, info.name, info.total])
	
	# 资源生成点信息
	LogManager.info("资源生成点数量: %d" % resource_spawns.size())
	var active_spawns = 0
	for spawn in resource_spawns:
		if not spawn.is_depleted:
			active_spawns += 1
	LogManager.info("活跃资源点数量: %d" % active_spawns)

func get_resources_by_category(category: ResourceCategory) -> Array:
	"""根据分类获取资源列表"""
	var resources = []
	for resource_type in ResourceType.values():
		if get_resource_category(resource_type) == category:
			resources.append({
				"type": resource_type,
				"name": get_resource_name(resource_type),
				"icon": get_resource_icon(resource_type),
				"amount": get_resource_amount(resource_type),
				"config": get_resource_config(resource_type)
			})
	return resources

# ===== 自动生成系统控制接口 =====

func toggle_auto_spawn():
	"""切换自动生成状态"""
	auto_spawn_enabled = !auto_spawn_enabled
	if auto_spawn_timer:
		auto_spawn_timer.paused = !auto_spawn_enabled
	LogManager.info("ResourceManager - 自动资源生成: %s" % ("开启" if auto_spawn_enabled else "关闭"))

func set_spawn_interval(interval: float):
	"""设置生成间隔"""
	spawn_interval = interval
	if auto_spawn_timer:
		auto_spawn_timer.wait_time = interval
	LogManager.info("ResourceManager - 资源生成间隔设置为: %.1f秒" % interval)

func set_max_spawns_per_interval(max_spawns: int):
	"""设置每次生成的最大数量"""
	max_spawns_per_interval = max_spawns
	LogManager.info("ResourceManager - 每次生成最大数量设置为: %d" % max_spawns)

func force_spawn_resources(count: int = 1):
	"""强制生成指定数量的资源"""
	var spawned_count = 0
	var max_attempts = count * 5
	
	for attempt in range(max_attempts):
		if spawned_count >= count:
			break
		
		if GameServices.has_method("get_tile_manager"):
			var tile_manager = GameServices.get_tile_manager()
			if tile_manager:
				var map_size = tile_manager.get_map_size()
				if map_size != Vector3.ZERO:
					var x = randi_range(0, int(map_size.x) - 1)
					var z = randi_range(0, int(map_size.z) - 1)
					var position = Vector2(x, z)
					var terrain_type = tile_manager.get_tile_type(Vector3(x, 0, z))
					
					if terrain_type != TileTypes.TileType.EMPTY:
						# 随机选择资源类型
						var resource_types = [ResourceType.GOLD, ResourceType.FOOD, ResourceType.STONE, ResourceType.WOOD, ResourceType.IRON]
						var resource_type = resource_types[randi() % resource_types.size()]
						
						if spawn_resource(resource_type, position, terrain_type):
							spawned_count += 1
	
	LogManager.info("ResourceManager - 强制生成了 %d 个资源点" % spawned_count)

func get_auto_spawn_status() -> Dictionary:
	"""获取自动生成系统状态"""
	return {
		"enabled": auto_spawn_enabled,
		"interval": spawn_interval,
		"max_spawns_per_interval": max_spawns_per_interval,
		"timer_active": auto_spawn_timer != null and auto_spawn_timer.time_left > 0,
		"time_until_next_spawn": auto_spawn_timer.time_left if auto_spawn_timer else 0.0
	}

func collect_resource_at_position(resource_type: ResourceType, position: Vector2) -> int:
	"""在指定位置收集资源"""
	var collected_amount = 0
	
	# 查找指定位置的资源
	for i in range(resource_spawns.size() - 1, -1, -1):
		var spawn = resource_spawns[i]
		if spawn.position == position and spawn.resource_type == resource_type:
			if not spawn.is_depleted:
				collected_amount = spawn.amount
				
				# 标记为已枯竭
				spawn.is_depleted = true
				
				# 发射资源枯竭信号
				resource_depleted.emit(resource_type, position)
				
				# 设置重生定时器
				if spawn.respawn_time > 0:
					var timer = Timer.new()
					timer.wait_time = spawn.respawn_time
					timer.one_shot = true
					timer.timeout.connect(_on_resource_respawn.bind(spawn))
					add_child(timer)
					timer.start()
				else:
					# 如果没有重生时间，直接移除
					resource_spawns.remove_at(i)
				
				# 添加到资源存储
				add_resource(resource_type, collected_amount)
				
				LogManager.info("ResourceManager - 收集资源: %s x%d 在位置 %s" % [get_resource_name(resource_type), collected_amount, str(position)])
				break
	
	return collected_amount

# ===== 金矿系统集成 =====

func _initialize_gold_mine_system():
	"""初始化金矿系统"""
	LogManager.info("ResourceManager - 金矿系统已集成到统一资源管理")
	# 金矿系统将在需要时动态创建

func rescan_gold_mines():
	"""重新扫描金矿（地图生成完成后调用）"""
	LogManager.info("ResourceManager - 开始重新扫描金矿")
	
	# 清空现有金矿数据
	gold_mines.clear()
	mine_counter = 0
	
	# 扫描地图上的金矿瓦片
	var tile_manager = GameServices.get_tile_manager()
	if not tile_manager:
		LogManager.error("ResourceManager - TileManager未设置，无法扫描金矿")
		return
	
	var map_size = tile_manager.get_map_size()
	var found_mines = 0
	
	# 扫描整个地图寻找金矿瓦片
	for x in range(int(map_size.x)):
		for z in range(int(map_size.z)):
			var pos = Vector3(x, 0, z)
			var tile_data = tile_manager.get_tile_data(pos)
			
			if tile_data and tile_data.type == TileTypes.TileType.GOLD_MINE:
				# 找到金矿瓦片，创建对应的逻辑金矿对象
				var gold_amount = gold_mine_config.initial_gold
				if tile_data.resources.has("gold_amount"):
					gold_amount = tile_data.resources["gold_amount"]
				
				var mine_data = {
					"position": pos,
					"gold_amount": gold_amount,
					"status": MineStatus.ACTIVE,
					"discovered": true,
					"mine_id": mine_counter,
					"work_slots": []
				}
				
				gold_mines.append(mine_data)
				mine_counter += 1
				found_mines += 1
				
				# 发射发现信号
				gold_mine_discovered.emit(pos, gold_amount)
	
	LogManager.info("ResourceManager - 金矿扫描完成，发现 %d 个金矿" % found_mines)

func discover_gold_mine(position: Vector3) -> Dictionary:
	"""发现金矿"""
	var gold_amount = gold_mine_config.initial_gold
	var mine_data = {
		"position": position,
		"gold_amount": gold_amount,
		"max_gold": gold_amount,
		"mine_id": mine_counter,
		"status": MineStatus.ACTIVE,
		"discovered": true,
		"miners": [],
		"work_slots": []
	}
	
	gold_mines.append(mine_data)
	mine_counter += 1
	
	# 发射信号
	gold_mine_discovered.emit(position, gold_amount)
	
	LogManager.info("ResourceManager - 发现金矿: 位置 %s, 储量 %d" % [str(position), gold_amount])
	return mine_data

func mine_gold_at_position(position: Vector3, amount: int) -> int:
	"""在指定位置挖掘金矿"""
	var mined_amount = 0
	
	for mine in gold_mines:
		if mine.position == position and mine.gold_amount > 0:
			mined_amount = min(amount, mine.gold_amount)
			mine.gold_amount -= mined_amount
			
			# 添加到资源存储
			add_resource(ResourceType.GOLD, mined_amount)
			
			# 发射信号
			gold_mined.emit(position, mined_amount)
			
			# 检查是否枯竭
			if mine.gold_amount <= 0:
				mine.status = MineStatus.EXHAUSTED
				gold_mine_exhausted.emit(position)
				LogManager.info("ResourceManager - 金矿枯竭: 位置 %s" % str(position))
			
			LogManager.info("ResourceManager - 挖掘金矿: 位置 %s, 挖掘 %d, 剩余 %d" % [str(position), mined_amount, mine.gold_amount])
			break
	
	return mined_amount

func get_gold_mine_at_position(position: Vector3) -> Dictionary:
	"""获取指定位置的金矿信息"""
	for mine in gold_mines:
		if mine.position == position:
			return mine
	return {}

func get_all_gold_mines() -> Array:
	"""获取所有金矿"""
	return gold_mines

func get_active_gold_mines() -> Array:
	"""获取活跃的金矿"""
	var active_mines = []
	for mine in gold_mines:
		if mine.status == MineStatus.ACTIVE and mine.gold_amount > 0:
			active_mines.append(mine)
	return active_mines

func get_nearest_gold_mine(position: Vector3, max_distance: float = 100.0) -> Dictionary:
	"""获取最近的金矿"""
	var nearest_mine = {}
	var nearest_distance = max_distance
	
	for mine in gold_mines:
		if mine.status == MineStatus.ACTIVE and mine.gold_amount > 0:
			var distance = position.distance_to(mine.position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_mine = mine
	
	return nearest_mine

func add_miner_to_gold_mine(position: Vector3, miner) -> bool:
	"""向金矿添加挖掘者"""
	var mine = get_gold_mine_at_position(position)
	if mine.is_empty():
		return false
	
	if mine.miners.size() < 3: # 最多3个挖掘者
		mine.miners.append(miner)
		LogManager.info("ResourceManager - 挖掘者 %s 加入金矿 %s" % [str(miner), str(position)])
		return true
	
	return false

func remove_miner_from_gold_mine(position: Vector3, miner):
	"""从金矿移除挖掘者"""
	var mine = get_gold_mine_at_position(position)
	if not mine.is_empty():
		mine.miners.erase(miner)
		LogManager.info("ResourceManager - 挖掘者 %s 离开金矿 %s" % [str(miner), str(position)])

func can_mine_at_position(position: Vector3) -> bool:
	"""检查指定位置是否可以挖掘"""
	var mine = get_gold_mine_at_position(position)
	return not mine.is_empty() and mine.status == MineStatus.ACTIVE and mine.gold_amount > 0

func get_gold_mine_status(position: Vector3) -> String:
	"""获取金矿状态"""
	var mine = get_gold_mine_at_position(position)
	if mine.is_empty():
		return "not_found"
	
	if mine.gold_amount <= 0:
		return "exhausted"
	elif mine.miners.size() >= 3:
		return "full"
	elif mine.miners.size() > 0:
		return "busy"
	else:
		return "available"
