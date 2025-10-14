extends Node
# 日志管理器 - 简化的全局日志函数集合
# 提供 debug/info/warning/error 四个静态函数，无需初始化
static func _now() -> String:
	return Time.get_datetime_string_from_system()

static func _print_level(level: String, message: String) -> void:
	print("[" + _now() + "] [" + level + "] " + message)

# 无需初始化即可直接调用的全局日志函数
static func debug(message: String) -> void:
	_print_level("DEBUG", message)

static func info(message: String) -> void:
	_print_level("INFO", message)

static func warning(message: String) -> void:
	_print_level("WARNING", message)

static func error(message: String) -> void:
	_print_level("ERROR", message)

# 调试模式控制
static var debug_enabled: bool = true

static func is_debug_enabled() -> bool:
	return debug_enabled

static func set_debug_enabled(enabled: bool) -> void:
	debug_enabled = enabled

static func toggle_debug_mode() -> void:
	debug_enabled = !debug_enabled
	info("调试模式: " + ("开启" if debug_enabled else "关闭"))
