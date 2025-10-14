extends Building
class_name DungeonHeart

# 地牢之心 - 玩家的核心建筑
# 存储金币和魔力，是资源的主要来源

# 资源存储
var stored_mana: int = 500 # 🔧 初始魔力（修改为500）

# 存储容量
var mana_storage_capacity: int = 2000

# 魔力生成
var mana_generation_rate: float = 1.0 # 每秒生成1点魔力

# 信号定义
signal gold_changed(amount: int, old_amount: int)
signal mana_changed(amount: int, old_amount: int)

# 🔧 2x2建筑：管理4个瓦片的位置
var tile_positions: Array[Vector3] = []


func _init():
	"""初始化地牢之心"""
	super._init()
	
	building_name = "地牢之心"
	building_type = BuildingTypes.DUNGEON_HEART
	
	# 地牢之心属性
	max_health = 1000
	health = max_health
	armor = 10
	
	# 2x2 建筑（占用 4 个地块）
	building_size = Vector2(2, 2)
	interaction_range = 2.0 # 🔧 增大基础交互范围（2x2 建筑，半径 1.0）
	
	# 建造成本（地牢之心不需要建造）
	cost_gold = 0
	engineer_cost = 0
	build_time = 0
	engineer_required = 0
	
	# 直接完成
	status = BuildingStatus.COMPLETED
	build_progress = 1.0
	
	# 设置存储属性
	stored_gold = 1000
	gold_storage_capacity = 5000


func _ready():
	"""场景准备就绪"""
	super._ready()
	
	# 🔧 初始化4个瓦片位置（2x2建筑）
	_setup_tile_positions()
	
	# 🔧 创建统一的2x2渲染（替代TileManager的4个独立渲染）
	_setup_visual_representation()
	
	# 🔧 碰撞体由TileManager的4个瓦片提供，建筑本身不需要额外的碰撞体或Area3D
	# 注：地牢之心是被动建筑，苦工通过距离判断来存放金币，不需要Area3D交互
	
	# 🔧 [状态栏系统] 初始化存储显示
	call_deferred("_update_storage_display")
	
	# 🔧 延迟链接瓦片，等待TileManager注册完成
	call_deferred("_try_link_tiles_delayed")
	
	# 🔧 资源管理器注册已移至main.gd（在add_child后立即注册，避免重复）
	# resource_manager = GameServices.resource_manager
	# if resource_manager:
	# 	resource_manager.register_dungeon_heart(self)
	
	# ✅ [Step 6] 添加到Groups
	GameGroups.add_node_to_group(self, GameGroups.DUNGEON_HEART)
	GameGroups.add_node_to_group(self, GameGroups.BUILDINGS)
	GameGroups.add_node_to_group(self, GameGroups.RESOURCE_BUILDINGS)


# ===== 资源管理 =====

func withdraw_gold(amount: int) -> int:
	"""从地牢之心取出金币（供工程师使用）
	
	🔧 [新建造系统] 直接从建筑扣除金币
	
	Args:
		amount: 要取出的金币数量
	
	Returns:
		int: 实际取出的金币数量
	"""
	var available = mini(stored_gold, amount)
	if available > 0:
		var old_amount = stored_gold
		stored_gold -= available
		LogManager.info("💰 地牢之心取出 %d 金币 | 剩余: %d/%d" % [
			available, stored_gold, gold_storage_capacity
		])
		# 发出金币变化信号
		gold_changed.emit(stored_gold, old_amount)
		
		# 🔧 [状态栏系统] 更新存储显示
		_update_storage_display()
	
	return available

func _setup_tile_positions():
	"""初始化4个瓦片位置（2x2建筑占用4个地块）"""
	tile_positions.clear()
	
	# 基于左下角位置（tile_x, tile_y）计算2x2区域
	for dx in range(2):
		for dz in range(2):
			var tile_pos = Vector3(tile_x + dx, 0, tile_y + dz)
			tile_positions.append(tile_pos)
	
	LogManager.info("🏰 [DungeonHeart] 初始化2x2瓦片位置: %s" % str(tile_positions))
	
	# 🔧 设置4个瓦片的building_ref指向本建筑
	_link_tiles_to_building()

func _try_link_tiles_delayed():
	"""延迟尝试链接瓦片，等待TileManager注册完成"""
	# 等待几帧，确保TileManager已经注册
	await get_tree().process_frame
	await get_tree().process_frame
	
	_link_tiles_to_building()

func _link_tiles_to_building():
	"""将4个瓦片链接到本建筑对象"""
	var tile_manager = GameServices.tile_manager
	if not tile_manager:
		LogManager.warning("⚠️ [DungeonHeart] TileManager不存在，无法链接瓦片")
		return
	
	var linked_count = 0
	for tile_pos in tile_positions:
		if tile_manager.set_tile_building_ref(tile_pos, self):
			linked_count += 1
	
	LogManager.info("🏰 [DungeonHeart] 已链接 %d/4 个瓦片到建筑对象" % linked_count)

func _setup_visual_representation():
	"""创建统一的2x2视觉表现
	
	🔧 [修正] 建筑position已经是2x2中心，子节点position相对于中心
	
	设计：
	- 底座：2x2薄层地面（石质）
	- 核心：1.6x1.0x1.6的红色立方体（发光）
	- 位置：建筑position就是2x2中心
	"""
	# 创建底座（2x2薄层）
	var base = MeshInstance3D.new()
	base.name = "DungeonHeartBase"
	var base_mesh = BoxMesh.new()
	base_mesh.size = Vector3(2.0, 0.1, 2.0) # 2x2底座，薄层
	base.mesh = base_mesh
	
	var base_material = StandardMaterial3D.new()
	base_material.albedo_color = Color(0.3, 0.3, 0.35) # 深灰色石质
	base_material.roughness = 0.8
	base_material.metallic = 0.1
	base.material_override = base_material
	
	# 🔧 底座位置：建筑position就是2x2中心，底座Y=0（地面）
	base.position = Vector3(0, 0, 0) # 相对于建筑position(2x2中心)
	add_child(base)
	
	# 创建核心（发光的红色立方体）
	var core = MeshInstance3D.new()
	core.name = "DungeonHeartCore"
	var core_mesh = BoxMesh.new()
	core_mesh.size = Vector3(1.6, 1.0, 1.6) # 比2x2稍小，突出中心感
	core.mesh = core_mesh
	
	var core_material = StandardMaterial3D.new()
	core_material.albedo_color = Color(0.9, 0.15, 0.15) # 鲜红色
	core_material.emission = Color(0.6, 0.1, 0.1) # 红色发光
	core_material.emission_energy = 1.5 # 强烈发光
	core_material.roughness = 0.2
	core_material.metallic = 0.3
	core.material_override = core_material
	
	# 🔧 核心位置：建筑position就是2x2中心，核心底部在底座上方0.1
	core.position = Vector3(0, 0.55, 0) # 底部0.05(地面) + 0.05(底座) + 0.5(核心高度一半) = 0.6，但相对于建筑Y=0.05，所以是0.55
	add_child(core)
	
	# 🎨 添加旋转动画（核心慢速旋转）
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(core, "rotation:y", TAU, 8.0) # 8秒旋转一圈
	
	LogManager.info("🏰 [DungeonHeart] 已创建2x2统一渲染: 底座2x2x0.1 + 核心1.6x1.0x1.6（建筑position=2x2中心）")

func _update_logic(delta: float):
	"""更新地牢之心逻辑"""
	# 自动生成魔力
	_generate_mana(delta)


func _generate_mana(delta: float):
	"""生成魔力"""
	if stored_mana < mana_storage_capacity:
		var generated = mana_generation_rate * delta
		stored_mana = min(stored_mana + int(generated), mana_storage_capacity)


# ===== 资源管理（只读接口，实际操作通过 ResourceManager）=====

func get_gold_fill_percentage() -> float:
	"""获取金币填充百分比"""
	return float(stored_gold) / float(gold_storage_capacity) if gold_storage_capacity > 0 else 0.0


func get_mana_fill_percentage() -> float:
	"""获取魔力填充百分比"""
	return float(stored_mana) / float(mana_storage_capacity) if mana_storage_capacity > 0 else 0.0


# ===== 地牢之心特殊能力 =====

func _on_destroyed():
	"""地牢之心被摧毁 = 游戏失败"""
	super._on_destroyed()
	LogManager.info("💀 地牢之心被摧毁！游戏结束！")
	# 这里可以触发游戏失败逻辑


# ===== 调试信息 =====

func get_building_info() -> Dictionary:
	"""获取地牢之心信息"""
	var info = super.get_building_info()
	info["stored_gold"] = stored_gold
	info["stored_mana"] = stored_mana
	info["gold_capacity"] = gold_storage_capacity
	info["mana_capacity"] = mana_storage_capacity
	info["gold_fill"] = "%.1f%%" % (get_gold_fill_percentage() * 100)
	info["mana_fill"] = "%.1f%%" % (get_mana_fill_percentage() * 100)
	return info
