extends Node
# 材质管理器 - 统一管理所有瓦片材质
# 使用单例模式，避免重复创建相同材质

class_name MaterialManager

# 材质缓存
var _material_cache: Dictionary = {}

# 材质配置数据
var _material_configs: Dictionary = {}
var _created_material_count: Dictionary = {} # 🔧 [优化] 用于限制调试日志输出

func _ready():
	"""初始化材质管理器"""
	LogManager.info("MaterialManager - 初始化开始")
	_initialize_material_configs()
	LogManager.info("MaterialManager - 初始化完成，预加载 %d 种材质" % _material_configs.size())

func _initialize_material_configs():
	"""初始化所有材质配置"""
	_material_configs = {
		# 基础地面材质
		"empty": {
			"albedo_color": Color(1.0, 1.0, 1.0, 0.0),
			"roughness": 0.8,
			"metallic": 0.0,
			"transparency": BaseMaterial3D.TRANSPARENCY_ALPHA,
			"emission": Color.BLACK,
			"emission_energy": 0.0
		},
		"stone_floor": {
			"albedo_color": Color(0.6, 0.6, 0.7),
			"roughness": 0.8,
			"metallic": 0.05,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color.BLACK,
			"emission_energy": 0.0
		},
		"dirt_floor": {
			"albedo_color": Color(0.4, 0.3, 0.2),
			"roughness": 0.9,
			"metallic": 0.0,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color.BLACK,
			"emission_energy": 0.0
		},
		"magic_floor": {
			"albedo_color": Color(0.3, 0.2, 0.6),
			"roughness": 0.7,
			"metallic": 0.2,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color(0.1, 0.05, 0.2),
			"emission_energy": 0.3
		},
		"corridor": {
			"albedo_color": Color(0.4, 0.4, 0.42),
			"roughness": 0.8,
			"metallic": 0.1,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color.BLACK,
			"emission_energy": 0.0
		},
		
		# 墙体材质
		"stone_wall": {
			"albedo_color": Color(0.7, 0.7, 0.75),
			"roughness": 0.9,
			"metallic": 0.1,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color.BLACK,
			"emission_energy": 0.0
		},
		"unexcavated": {
			"albedo_color": Color(0.4, 0.35, 0.25),
			"roughness": 0.9,
			"metallic": 0.02,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color(0.02, 0.01, 0.0),
			"emission_energy": 0.05
		},
		
		# 资源材质
		"gold_mine": {
			"albedo_color": Color(0.8, 0.6, 0.2),
			"roughness": 0.3,
			"metallic": 0.8,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color(0.4, 0.3, 0.1),
			"emission_energy": 0.2
		},
		"mana_crystal": {
			"albedo_color": Color(0.3, 0.5, 0.9),
			"roughness": 0.1,
			"metallic": 0.3,
			"transparency": BaseMaterial3D.TRANSPARENCY_ALPHA,
			"emission": Color(0.1, 0.2, 0.4),
			"emission_energy": 0.8,
			"alpha": 0.8
		},
		
		# 建筑材质
		"building": {
			"albedo_color": Color(0.5, 0.4, 0.3),
			"roughness": 0.7,
			"metallic": 0.2,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color.BLACK,
			"emission_energy": 0.0
		},
		"workshop": {
			"albedo_color": Color(0.4, 0.35, 0.3),
			"roughness": 0.6,
			"metallic": 0.4,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color(0.1, 0.05, 0.0),
			"emission_energy": 0.1
		},
		"magic_lab": {
			"albedo_color": Color(0.3, 0.4, 0.6),
			"roughness": 0.5,
			"metallic": 0.3,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color(0.05, 0.1, 0.2),
			"emission_energy": 0.3
		},
		"defense_tower": {
			"albedo_color": Color(0.6, 0.5, 0.4),
			"roughness": 0.8,
			"metallic": 0.3,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color.BLACK,
			"emission_energy": 0.0
		},
		"food_farm": {
			"albedo_color": Color(0.2, 0.5, 0.2),
			"roughness": 0.8,
			"metallic": 0.0,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color.BLACK,
			"emission_energy": 0.0
		},
		"dungeon_heart": {
			"albedo_color": Color(0.8, 0.2, 0.2),
			"roughness": 0.3,
			"metallic": 0.2,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color(0.4, 0.1, 0.1),
			"emission_energy": 1.0
		},
		
		# 特殊材质
		"trap": {
			"albedo_color": Color(0.5, 0.2, 0.2),
			"roughness": 0.9,
			"metallic": 0.1,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color(0.1, 0.0, 0.0),
			"emission_energy": 0.1
		},
		"secret_passage": {
			"albedo_color": Color(0.2, 0.2, 0.25),
			"roughness": 0.9,
			"metallic": 0.05,
			"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED,
			"emission": Color.BLACK,
			"emission_energy": 0.0
		}
	}

func get_material(material_name: String) -> StandardMaterial3D:
	"""获取指定名称的材质（带缓存）"""
	# 检查缓存
	if _material_cache.has(material_name):
		return _material_cache[material_name]
	
	# 检查配置是否存在
	if not _material_configs.has(material_name):
		LogManager.warning("⚠️ [MaterialManager] 材质配置不存在: %s" % material_name)
		return _create_default_material()
	
	# 创建新材质
	var material = _create_material_from_config(_material_configs[material_name])
	_material_cache[material_name] = material
	
	# 🔧 [优化] 减少调试日志输出，只在创建前几种材质类型时输出
	if _created_material_count.get(material_name, 0) < 3:
		_created_material_count[material_name] = _created_material_count.get(material_name, 0) + 1
	return material

func _create_material_from_config(config: Dictionary) -> StandardMaterial3D:
	"""根据配置创建材质"""
	var material = StandardMaterial3D.new()
	
	# 基础属性
	material.albedo_color = config.get("albedo_color", Color.WHITE)
	material.roughness = config.get("roughness", 0.8)
	material.metallic = config.get("metallic", 0.0)
	material.transparency = config.get("transparency", BaseMaterial3D.TRANSPARENCY_DISABLED)
	
	# 发光属性
	var emission = config.get("emission", Color.BLACK)
	var emission_energy = config.get("emission_energy", 0.0)
	if emission != Color.BLACK and emission_energy > 0.0:
		material.emission = emission
		material.emission_energy = emission_energy
	
	# Alpha透明度
	if config.has("alpha"):
		material.albedo_color.a = config["alpha"]
	
	return material

func _create_default_material() -> StandardMaterial3D:
	"""创建默认材质"""
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.WHITE
	material.roughness = 0.8
	material.metallic = 0.0
	return material

func get_tile_material(tile_type: int) -> StandardMaterial3D:
	"""根据瓦片类型获取对应材质"""
	# 🔧 [简化] 直接使用 TileTypes 的方法
	var material_name = TileTypes.get_material_name(tile_type)
	return get_material(material_name)

func clear_cache():
	"""清理材质缓存"""
	_material_cache.clear()
	LogManager.info("MaterialManager - 材质缓存已清理")

func get_cache_size() -> int:
	"""获取缓存大小"""
	return _material_cache.size()

func get_available_materials() -> Array[String]:
	"""获取所有可用的材质名称"""
	var materials: Array[String] = []
	for material_name in _material_configs.keys():
		materials.append(material_name)
	return materials
