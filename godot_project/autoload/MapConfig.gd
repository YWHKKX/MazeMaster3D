extends Node

## 🗺️ 地图配置管理器
## 统一管理所有地图相关的配置参数，包括尺寸、区域占比等

# ============================================================================
# 地图基础配置
# ============================================================================

## 标准地图尺寸
static func get_map_size() -> Vector3:
	"""获取标准地图尺寸"""
	return Vector3(200, 1, 200)

## 瓦片尺寸
static func get_tile_size() -> Vector3:
	"""获取瓦片尺寸"""
	return Vector3(1.0, 1.0, 1.0)

# ============================================================================
# 地牢之心配置
# ============================================================================

## 地牢之心预留区域大小
static func get_dungeon_heart_reserve_size() -> int:
	"""获取地牢之心预留区域大小"""
	return 10

## 地牢之心中心位置
static func get_dungeon_heart_center(map_size: Vector3 = Vector3.ZERO) -> Vector3:
	"""获取地牢之心中心位置"""
	if map_size == Vector3.ZERO:
		map_size = get_map_size()
	return Vector3(int(map_size.x / 2), 0, int(map_size.z / 2))

# ============================================================================
# 四大区域配置
# ============================================================================

## 房间系统区域配置
static func get_room_system_area_size() -> int:
	"""获取房间系统区域大小"""
	return 100

## 迷宫系统区域配置
static func get_maze_system_area_size() -> int:
	"""获取迷宫系统区域大小"""
	return 80

## 生态系统区域配置
static func get_ecosystem_area_size() -> int:
	"""获取生态系统区域大小"""
	return 120

## 英雄营地区域配置
static func get_hero_camp_area_size() -> int:
	"""获取英雄营地区域大小"""
	return 60

# ============================================================================
# 区域占比配置
# ============================================================================

## 获取四大区域的占比配置
static func get_region_ratios() -> Dictionary:
	"""获取四大区域的占比配置"""
	return {
		"default_terrain": 0.40, # 默认地形占40%
		"ecosystem": 0.25, # 生态系统占25%
		"room_system": 0.15, # 房间系统占15%
		"maze_system": 0.15, # 迷宫系统占15%
		"hero_camp": 0.05 # 英雄营地占5%
	}

## 获取生态系统内部占比配置
static func get_ecosystem_ratios() -> Dictionary:
	"""获取生态系统内部占比配置"""
	return {
		"forest": 0.25, # 森林25%
		"grassland": 0.20, # 草地20%
		"lake": 0.15, # 湖泊15%
		"cave": 0.20, # 洞穴20%
		"wasteland": 0.15, # 荒地15%
		"dead_land": 0.05 # 死地5%
	}

# ============================================================================
# 噪声生成配置
# ============================================================================

## 获取噪声生成参数
static func get_noise_config() -> Dictionary:
	"""获取噪声生成参数"""
	return {
		"noise_scale": 0.1, # 噪声缩放
		"height_threshold": 0.5, # 高度阈值
		"humidity_threshold": 0.5, # 湿度阈值
		"temperature_threshold": 0.5 # 温度阈值
	}

# ============================================================================
# 房间生成配置
# ============================================================================

## 获取房间生成参数
static func get_room_generation_config() -> Dictionary:
	"""获取房间生成参数"""
	return {
		"max_room_count": 25, # 最大房间数量
		"min_room_size": 3, # 最小房间尺寸
		"max_room_size": 8, # 最大房间尺寸
		"room_connection_attempts": 15, # 房间连接尝试次数
		"corridor_width": 3 # 走廊宽度
	}

# ============================================================================
# 资源生成配置
# ============================================================================

## 获取资源生成参数
static func get_resource_config() -> Dictionary:
	"""获取资源生成参数"""
	return {
		"resource_density": 0.1, # 资源密度
		"gold_mine_density": 0.05, # 金矿密度
		"crystal_density": 0.03, # 水晶密度
		"gem_density": 0.02 # 宝石密度
	}

# ============================================================================
# 生物生成配置
# ============================================================================

## 获取生物生成参数
static func get_creature_config() -> Dictionary:
	"""获取生物生成参数"""
	return {
		"monster_density": 0.08, # 怪物密度
		"hero_density": 0.02, # 英雄密度
		"neutral_density": 0.05, # 中性生物密度
		"spawn_attempts": 100 # 生成尝试次数
	}

# ============================================================================
# 空洞挖掘系统配置
# ============================================================================

## 获取空洞挖掘系统参数
static func get_cavity_excavation_config() -> Dictionary:
	"""获取空洞挖掘系统参数"""
	return {
		# 密度配置
		"cavity_density": 0.18, # 空洞密度（占地图面积比例）
		"min_cavity_distance": 20.0, # 最小空洞间距
		"poisson_k_attempts": 30, # 泊松采样候选点数
		
		# 大小配置
		"min_cavity_radius": 5.0, # 最小空洞半径
		"max_cavity_radius": 15.0, # 最大空洞半径
		"average_cavity_radius": 8.0, # 平均空洞半径
		"cavity_size_variance": 0.3, # 空洞大小变化系数
		
		# 形状配置
		"noise_frequency": 0.1, # 噪声频率
		"noise_amplitude": 0.5, # 噪声幅度
		"shape_irregularity": 0.7, # 形状不规则度（增强自然感）
		
		# 类型分布
		"critical_cavity_ratio": 0.05, # 关键空洞占比
		"functional_cavity_ratio": 0.25, # 功能空洞占比
		"ecosystem_cavity_ratio": 0.70, # 生态系统空洞占比
		
		# 生成约束
		"max_generation_attempts": 1000, # 最大生成尝试次数
		"cavity_overlap_threshold": 0.1, # 空洞重叠阈值
		"edge_margin": 10.0 # 边缘留白距离
	}

## 获取不同类型空洞的特定配置
static func get_cavity_type_configs() -> Dictionary:
	"""获取不同类型空洞的特定配置"""
	return {
		"critical": {
			"min_radius": 3.0,
			"max_radius": 8.0,
			"density": 0.02,
			"priority": 1,
			"is_fixed": true
		},
		"functional": {
			"min_radius": 8.0,
			"max_radius": 20.0,
			"density": 0.08,
			"priority": 2,
			"is_fixed": false
		},
		"ecosystem": {
			"min_radius": 6.0,
			"max_radius": 18.0,
			"density": 0.12,
			"priority": 3,
			"is_fixed": false
		}
	}

## 获取生态系统空洞子类型配置
static func get_ecosystem_cavity_configs() -> Dictionary:
	"""获取生态系统空洞子类型配置"""
	return {
		"forest": {
			"min_radius": 8.0,
			"max_radius": 18.0,
			"density": 0.03,
			"shape_irregularity": 0.8, # 森林形状更不规则
			"highlight_color": [0.0, 0.8, 0.0, 0.6]
		},
		"lake": {
			"min_radius": 5.0,
			"max_radius": 15.0,
			"density": 0.025,
			"shape_irregularity": 0.9, # 湖泊形状最不规则
			"highlight_color": [0.0, 0.6, 1.0, 0.6]
		},
		"cave": {
			"min_radius": 10.0,
			"max_radius": 22.0,
			"density": 0.04,
			"shape_irregularity": 0.85, # 洞穴形状不规则
			"highlight_color": [0.5, 0.3, 0.1, 0.6]
		},
		"wasteland": {
			"min_radius": 6.0,
			"max_radius": 16.0,
			"density": 0.025,
			"shape_irregularity": 0.75, # 荒地形状不规则
			"highlight_color": [0.8, 0.8, 0.0, 0.6]
		},
		"swamp": {
			"min_radius": 7.0,
			"max_radius": 17.0,
			"density": 0.02,
			"shape_irregularity": 0.8, # 沼泽形状不规则
			"highlight_color": [0.2, 0.6, 0.2, 0.6]
		},
		"grassland": {
			"min_radius": 6.0,
			"max_radius": 14.0,
			"density": 0.03,
			"shape_irregularity": 0.6, # 草地形状相对规则
			"highlight_color": [0.4, 0.8, 0.4, 0.6]
		},
		"dead_land": {
			"min_radius": 8.0,
			"max_radius": 20.0,
			"density": 0.015,
			"shape_irregularity": 0.9, # 死地形状最不规则
			"highlight_color": [0.3, 0.3, 0.3, 0.6]
		}
	}

# ============================================================================
# 地图生成流程配置
# ============================================================================

## 获取分块系统配置
static func get_chunk_config() -> Dictionary:
	"""获取分块系统配置"""
	return {
		"chunk_size": 16, # 分块大小
		"max_loaded_chunks": 9, # 最大加载分块数
		"loading_distance": 2 # 加载距离
	}

## 获取地图复杂度配置
static func get_complexity_config() -> Dictionary:
	"""获取地图复杂度配置"""
	return {
		"base_complexity": 0.5, # 基础复杂度
		"terrain_variation": 0.3, # 地形变化
		"feature_density": 0.4, # 特征密度
		"connection_complexity": 0.6 # 连接复杂度
	}

# ============================================================================
# 配置验证和工具函数
# ============================================================================

## 验证配置参数
static func validate_config() -> bool:
	"""验证配置参数的合理性"""
	var region_ratios = get_region_ratios()
	var total_ratio = 0.0
	
	for ratio in region_ratios.values():
		total_ratio += ratio
	
	if abs(total_ratio - 1.0) > 0.01:
		LogManager.error("区域占比总和不为1.0: %f" % total_ratio)
		return false
	
	var ecosystem_ratios = get_ecosystem_ratios()
	var ecosystem_total = 0.0
	
	for ratio in ecosystem_ratios.values():
		ecosystem_total += ratio
	
	if abs(ecosystem_total - 1.0) > 0.01:
		LogManager.error("生态系统占比总和不为1.0: %f" % ecosystem_total)
		return false
	
	LogManager.info("✅ 地图配置验证通过")
	return true

## 获取配置摘要
static func get_config_summary() -> String:
	"""获取配置摘要信息"""
	var map_size = get_map_size()
	var region_ratios = get_region_ratios()
	var room_config = get_room_generation_config()
	var cavity_config = get_cavity_excavation_config()
	
	var summary = "🗺️ 地图配置摘要:\n"
	summary += "  地图尺寸: %dx%d\n" % [map_size.x, map_size.z]
	summary += "  地牢之心预留区域: %dx%d\n" % [get_dungeon_heart_reserve_size(), get_dungeon_heart_reserve_size()]
	summary += "  房间系统区域: %dx%d\n" % [get_room_system_area_size(), get_room_system_area_size()]
	summary += "  最大房间数量: %d\n" % room_config.max_room_count
	summary += "  区域占比: 默认地形%.0f%%, 生态%.0f%%, 房间%.0f%%, 迷宫%.0f%%, 英雄营地%.0f%%\n" % [
		region_ratios.default_terrain * 100,
		region_ratios.ecosystem * 100,
		region_ratios.room_system * 100,
		region_ratios.maze_system * 100,
		region_ratios.hero_camp * 100
	]
	summary += "  🏗️ 空洞挖掘系统:\n"
	summary += "    空洞密度: %.1f%%\n" % (cavity_config.cavity_density * 100)
	summary += "    空洞大小: %.1f-%.1f (平均%.1f)\n" % [cavity_config.min_cavity_radius, cavity_config.max_cavity_radius, cavity_config.average_cavity_radius]
	summary += "    最小间距: %.1f\n" % cavity_config.min_cavity_distance
	summary += "    类型分布: 关键%.1f%%, 功能%.1f%%, 生态%.1f%%" % [
		cavity_config.critical_cavity_ratio * 100,
		cavity_config.functional_cavity_ratio * 100,
		cavity_config.ecosystem_cavity_ratio * 100
	]
	
	return summary

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	"""初始化配置管理器"""
	LogManager.info("MapConfig 初始化开始")
	
	# 尝试加载用户设置
	_load_user_settings()
	
	# 验证配置
	if validate_config():
		LogManager.info(get_config_summary())
	else:
		LogManager.error("MapConfig 配置验证失败")
	
	LogManager.info("MapConfig 初始化完成")

func _load_user_settings():
	"""加载用户设置"""
	var config_file = FileAccess.open("user://map_settings.json", FileAccess.READ)
	if config_file:
		var json_string = config_file.get_as_text()
		config_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var user_settings = json.data
			LogManager.info("已加载用户地图设置")
			# 注意：这里只是加载了设置，实际应用需要在生成地图时使用
		else:
			LogManager.warning("用户设置文件格式错误，使用默认配置")
	else:
		LogManager.info("未找到用户设置文件，使用默认配置")

## 获取用户设置（如果存在）
static func get_user_settings() -> Dictionary:
	"""获取用户设置"""
	var config_file = FileAccess.open("user://map_settings.json", FileAccess.READ)
	if config_file:
		var json_string = config_file.get_as_text()
		config_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			return json.data
	
	return {}
