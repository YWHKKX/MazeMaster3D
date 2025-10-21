extends Node
# 网格对象池 - 复用Mesh对象，减少内存分配
# 使用单例模式，统一管理所有网格资源

class_name MeshPool

# 网格缓存池
var _mesh_pools: Dictionary = {}

# 网格配置
var _mesh_configs: Dictionary = {}
var _created_mesh_count: Dictionary = {} # 🔧 [优化] 用于限制调试日志输出

func _ready():
	"""初始化网格池"""
	LogManager.info("MeshPool - 初始化开始")
	_initialize_mesh_configs()
	LogManager.info("MeshPool - 初始化完成，预加载 %d 种网格" % _mesh_configs.size())

func _initialize_mesh_configs():
	"""初始化所有网格配置"""
	_mesh_configs = {
		# 基础网格
		"cube_full": {
			"type": "box",
			"size": Vector3(1.0, 1.0, 1.0),
			"description": "完整立方体 - 用于墙体、金矿等"
		},
		"cube_half": {
			"type": "box",
			"size": Vector3(1.0, 0.8, 1.0),
			"description": "半高立方体 - 用于建筑主体"
		},
		"cube_tower": {
			"type": "box",
			"size": Vector3(0.6, 1.0, 0.6),
			"description": "塔楼立方体 - 用于防御塔"
		},
		"cube_heart": {
			"type": "box",
			"size": Vector3(1.8, 1.0, 1.8),
			"description": "地牢之心立方体 - 用于地牢之心"
		},
		"cube_crystal": {
			"type": "box",
			"size": Vector3(0.8, 0.8, 0.8),
			"description": "水晶立方体 - 用于魔力水晶"
		},
		
		# 地面网格
		"floor_thin": {
			"type": "box",
			"size": Vector3(1.0, 0.05, 1.0),
			"description": "薄地面 - 用于所有地面类型"
		},
		"floor_empty": {
			"type": "box",
			"size": Vector3(1.0, 0.05, 1.0),
			"description": "空地面 - 用于EMPTY类型"
		},
		
		# 生态系统地块网格
		"floor_forest": {
			"type": "box",
			"size": Vector3(1.0, 0.05, 1.0),
			"description": "森林地面 - 用于所有森林地块"
		},
		"floor_grassland": {
			"type": "box",
			"size": Vector3(1.0, 0.05, 1.0),
			"description": "草地地面 - 用于所有草地地块"
		},
		"floor_water": {
			"type": "box",
			"size": Vector3(1.0, 0.05, 1.0),
			"description": "水域地面 - 用于所有湖泊地块"
		},
		"floor_cave": {
			"type": "box",
			"size": Vector3(1.0, 0.05, 1.0),
			"description": "洞穴地面 - 用于所有洞穴地块"
		},
		"floor_wasteland": {
			"type": "box",
			"size": Vector3(1.0, 0.05, 1.0),
			"description": "荒地地面 - 用于所有荒地地块"
		},
		"floor_deadland": {
			"type": "box",
			"size": Vector3(1.0, 0.05, 1.0),
			"description": "死地地面 - 用于所有死地地块"
		},
		"floor_primitive": {
			"type": "box",
			"size": Vector3(1.0, 0.05, 1.0),
			"description": "原始地面 - 用于所有原始地块"
		}
	}

func get_mesh(mesh_name: String) -> Mesh:
	"""获取指定名称的网格（带缓存）"""
	# 检查缓存池
	if not _mesh_pools.has(mesh_name):
		_mesh_pools[mesh_name] = []
	
	var pool = _mesh_pools[mesh_name]
	
	# 如果池中有可用网格，直接返回
	if pool.size() > 0:
		return pool.pop_back()
	
	# 创建新网格
	var mesh = _create_mesh_from_config(mesh_name)
	# 🔧 [优化] 减少调试日志输出，只在创建前几种网格类型时输出
	if _created_mesh_count.get(mesh_name, 0) < 5:
		_created_mesh_count[mesh_name] = _created_mesh_count.get(mesh_name, 0) + 1
	return mesh

func return_mesh(mesh_name: String, mesh: Mesh) -> void:
	"""归还网格到池中"""
	if not _mesh_pools.has(mesh_name):
		_mesh_pools[mesh_name] = []
	
	# 限制池大小，避免内存过多占用
	var max_pool_size = 50
	if _mesh_pools[mesh_name].size() < max_pool_size:
		_mesh_pools[mesh_name].append(mesh)

func _create_mesh_from_config(mesh_name: String) -> Mesh:
	"""根据配置创建网格"""
	if not _mesh_configs.has(mesh_name):
		LogManager.warning("⚠️ [MeshPool] 网格配置不存在: %s" % mesh_name)
		return _create_default_mesh()
	
	var config = _mesh_configs[mesh_name]
	
	match config["type"]:
		"box":
			var box_mesh = BoxMesh.new()
			box_mesh.size = config["size"]
			return box_mesh
		_:
			LogManager.warning("⚠️ [MeshPool] 未知网格类型: %s" % config["type"])
			return _create_default_mesh()

func _create_default_mesh() -> Mesh:
	"""创建默认网格"""
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(1.0, 1.0, 1.0)
	return box_mesh

func get_tile_mesh(tile_type: int, is_base_layer: bool = false) -> Mesh:
	"""根据瓦片类型获取对应网格"""
	if is_base_layer:
		# 基础层（地面）统一使用薄地面
		return get_mesh("floor_thin")
	
	# 🔧 [简化] 直接使用 TileTypes 的方法
	var mesh_name = TileTypes.get_mesh_name(tile_type)
	return get_mesh(mesh_name)

func clear_pools():
	"""清理所有网格池"""
	for pool_name in _mesh_pools.keys():
		_mesh_pools[pool_name].clear()
	LogManager.info("MeshPool - 所有网格池已清理")

func get_pool_stats() -> Dictionary:
	"""获取池统计信息"""
	var stats = {}
	for pool_name in _mesh_pools.keys():
		stats[pool_name] = _mesh_pools[pool_name].size()
	return stats

func get_total_pooled_meshes() -> int:
	"""获取池中网格总数"""
	var total = 0
	for pool in _mesh_pools.values():
		total += pool.size()
	return total

func get_available_meshes() -> Array[String]:
	"""获取所有可用的网格名称"""
	var meshes: Array[String] = []
	for mesh_name in _mesh_configs.keys():
		meshes.append(mesh_name)
	return meshes
