extends RefCounted
class_name CavityConfigManager

## 🔧 空洞系统统一配置管理器
## 集中管理所有空洞相关组件的配置参数

# ============================================================================
# 单例模式
# ============================================================================

static var _instance: CavityConfigManager = null

static func get_instance() -> CavityConfigManager:
	"""获取单例实例"""
	if _instance == null:
		_instance = CavityConfigManager.new()
	return _instance

# ============================================================================
# 配置缓存
# ============================================================================

var cavity_config: Dictionary = {}
var type_configs: Dictionary = {}
var ecosystem_configs: Dictionary = {}
var is_loaded: bool = false

# ============================================================================
# 初始化
# ============================================================================

func _init():
	"""初始化配置管理器"""
	_load_all_configs()

# ============================================================================
# 配置加载
# ============================================================================

func _load_all_configs() -> void:
	"""加载所有配置"""
	if MapConfig:
		cavity_config = MapConfig.get_cavity_excavation_config()
		type_configs = MapConfig.get_cavity_type_configs()
		ecosystem_configs = MapConfig.get_ecosystem_cavity_configs()
		is_loaded = true
		LogManager.info("CavityConfigManager - 已加载所有配置")
	else:
		LogManager.warning("CavityConfigManager - MapConfig未找到，使用默认配置")
		_load_default_configs()

func _load_default_configs() -> void:
	"""加载默认配置"""
	cavity_config = {
		"cavity_density": 0.18,
		"min_cavity_size": 5.0,
		"max_cavity_size": 15.0,
		"average_cavity_size": 8.0,
		"min_distance": 20.0,
		"poisson_k_attempts": 30,
		"noise_frequency": 0.1,
		"noise_amplitude": 0.5,
		"shape_irregularity": 0.4
	}
	
	type_configs = {
		"critical": {"ratio": 0.05, "min_size": 3, "max_size": 8},
		"functional": {"ratio": 0.25, "min_size": 5, "max_size": 15},
		"ecosystem": {"ratio": 0.70, "min_size": 8, "max_size": 20}
	}
	
	ecosystem_configs = {
		"FOREST": {"color": Color(0.2, 0.8, 0.2), "priority": 1},
		"LAKE": {"color": Color(0.2, 0.6, 1.0), "priority": 2},
		"CAVE": {"color": Color(0.4, 0.2, 0.4), "priority": 3},
		"WASTELAND": {"color": Color(0.8, 0.6, 0.2), "priority": 4},
		"SWAMP": {"color": Color(0.4, 0.6, 0.2), "priority": 5},
		"DEAD_LAND": {"color": Color(0.3, 0.3, 0.3), "priority": 6}
	}
	
	is_loaded = true

# ============================================================================
# 配置获取方法
# ============================================================================

func get_cavity_config() -> Dictionary:
	"""获取空洞配置"""
	return cavity_config

func get_type_configs() -> Dictionary:
	"""获取类型配置"""
	return type_configs

func get_ecosystem_configs() -> Dictionary:
	"""获取生态系统配置"""
	return ecosystem_configs

func get_config_value(key: String, default_value = null):
	"""获取配置值"""
	return cavity_config.get(key, default_value)

func get_type_config(type: String) -> Dictionary:
	"""获取特定类型配置"""
	return type_configs.get(type, {})

func get_ecosystem_config(ecosystem: String) -> Dictionary:
	"""获取特定生态系统配置"""
	return ecosystem_configs.get(ecosystem, {})

# ============================================================================
# 配置验证
# ============================================================================

func validate_configs() -> bool:
	"""验证配置有效性"""
	if not is_loaded:
		LogManager.error("CavityConfigManager - 配置未加载")
		return false
	
	# 验证空洞配置
	var required_keys = ["cavity_density", "min_cavity_size", "max_cavity_size", "min_distance"]
	for key in required_keys:
		if not cavity_config.has(key):
			LogManager.error("CavityConfigManager - 缺少必要配置: %s" % key)
			return false
	
	# 验证类型配置
	var required_types = ["critical", "functional", "ecosystem"]
	for type in required_types:
		if not type_configs.has(type):
			LogManager.error("CavityConfigManager - 缺少类型配置: %s" % type)
			return false
	
	LogManager.info("CavityConfigManager - 配置验证通过")
	return true

# ============================================================================
# 配置更新
# ============================================================================

func reload_configs() -> void:
	"""重新加载配置"""
	is_loaded = false
	_load_all_configs()
	LogManager.info("CavityConfigManager - 配置已重新加载")

func update_config(key: String, value) -> void:
	"""更新配置值"""
	cavity_config[key] = value
	LogManager.info("CavityConfigManager - 配置已更新: %s = %s" % [key, str(value)])

# ============================================================================
# 调试方法
# ============================================================================

func print_configs() -> void:
	"""打印所有配置"""
	LogManager.info("=== CavityConfigManager 配置信息 ===")
	LogManager.info("空洞配置: %s" % str(cavity_config))
	LogManager.info("类型配置: %s" % str(type_configs))
	LogManager.info("生态系统配置: %s" % str(ecosystem_configs))
	LogManager.info("配置加载状态: %s" % str(is_loaded))
