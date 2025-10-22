extends Resource
class_name DungeonHeartConfig

## 🏰 地牢之心配置
## 统一管理地牢之心的所有配置参数

# 地牢之心基础配置
const DUNGEON_HEART_CONFIG = {
	"building_name": "地牢之心",
	"building_type": "DUNGEON_HEART",
	"building_size": Vector3(2, 3, 2), # 2x2瓦块，3层高
	"component_size": Vector3(0.33, 0.33, 0.33), # 每个组件的大小
	
	# 建筑属性
	"health": 300,
	"max_health": 300,
	"armor": 10,
	"cost_gold": 1500,
	
	# 地牢之心特殊属性
	"mana_generation_rate": 10.0,
	"max_mana_capacity": 1000,
	"life_force": 100,
	"corruption_radius": 5.0,
	
	# 渲染配置
	"render_mode": "LAYERED",
	"use_layered_rendering": true,
	"enable_emission": true,
	"enable_transparency": true,
	
	# 视觉主题配置
	"theme": "black_base_red_magic",
	"base_color": Color(0.1, 0.1, 0.1), # 黑色底座
	"magic_color": Color(0.9, 0.1, 0.1), # 红色魔力
	"conduit_color": Color(0.6, 0.1, 0.1), # 深红色管道
	
	# 组件配置
	"components": {
		"heart_core": {
			"id": 821,
			"layer": "decoration",
			"position": Vector3(1, 1, 1), # 中心位置
			"material": "heart_core",
			"texture": "heart_core_texture"
		},
		"energy_crystal": {
			"id": 148,
			"layer": "decoration",
			"positions": [Vector3(0, 2, 0), Vector3(2, 2, 0), Vector3(0, 2, 2), Vector3(2, 2, 2)],
			"material": "energy_crystal",
			"texture": "energy_crystal_texture"
		},
		"mana_crystal": {
			"id": 144,
			"layer": "decoration",
			"positions": [Vector3(1, 2, 0), Vector3(1, 2, 2)],
			"material": "mana_crystal",
			"texture": "mana_crystal_texture"
		},
		"magic_core": {
			"id": 133,
			"layer": "decoration",
			"positions": [Vector3(1, 2, 1)],
			"material": "magic_core",
			"texture": "magic_core_texture"
		},
		"energy_conduit": {
			"id": 134,
			"layer": "decoration",
			"positions": [Vector3(0, 2, 1), Vector3(2, 2, 1)],
			"material": "energy_conduit",
			"texture": "energy_conduit_texture"
		},
		"energy_node": {
			"id": 135,
			"layer": "decoration",
			"positions": [Vector3(1, 1, 0), Vector3(0, 1, 1), Vector3(2, 1, 1), Vector3(1, 1, 2)],
			"material": "energy_node",
			"texture": "energy_node_texture"
		},
		"storage_core": {
			"id": 136,
			"layer": "decoration",
			"positions": [Vector3(1, 1, 1)],
			"material": "storage_core",
			"texture": "storage_core_texture"
		},
		"heart_entrance": {
			"id": 51,
			"layer": "wall",
			"positions": [Vector3(1, 0, 1)],
			"material": "heart_entrance",
			"texture": "heart_entrance_texture"
		},
		"dungeon_stone": {
			"id": 4,
			"layer": "wall",
			"positions": [
				Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(2, 0, 0),
				Vector3(0, 0, 1), Vector3(2, 0, 1),
				Vector3(0, 0, 2), Vector3(1, 0, 2), Vector3(2, 0, 2),
				Vector3(0, 1, 0), Vector3(2, 1, 0),
				Vector3(0, 1, 2), Vector3(2, 1, 2)
			],
			"material": "dungeon_stone",
			"texture": "dungeon_stone_texture"
		}
	},
	
	# 层配置
	"layers": {
		"floor": {
			"enabled": true,
			"priority": 1,
			"material": "dungeon_stone",
			"texture": "dungeon_stone_texture"
		},
		"wall": {
			"enabled": true,
			"priority": 2,
			"material": "dungeon_stone",
			"texture": "dungeon_stone_texture"
		},
		"ceiling": {
			"enabled": true,
			"priority": 3,
			"material": "dungeon_stone",
			"texture": "dungeon_stone_texture"
		},
		"decoration": {
			"enabled": true,
			"priority": 4,
			"materials": ["heart_core", "energy_crystal", "mana_crystal", "magic_core", "energy_conduit", "energy_node", "storage_core"],
			"textures": ["heart_core_texture", "energy_crystal_texture", "mana_crystal_texture", "magic_core_texture", "energy_conduit_texture", "energy_node_texture", "storage_core_texture"]
		}
	}
}

# 获取配置
static func get_config() -> Dictionary:
	"""获取完整配置"""
	return DUNGEON_HEART_CONFIG

# 获取建筑属性
static func get_building_properties() -> Dictionary:
	"""获取建筑属性"""
	return {
		"health": DUNGEON_HEART_CONFIG.health,
		"max_health": DUNGEON_HEART_CONFIG.max_health,
		"armor": DUNGEON_HEART_CONFIG.armor,
		"cost_gold": DUNGEON_HEART_CONFIG.cost_gold,
		"mana_generation_rate": DUNGEON_HEART_CONFIG.mana_generation_rate,
		"max_mana_capacity": DUNGEON_HEART_CONFIG.max_mana_capacity,
		"life_force": DUNGEON_HEART_CONFIG.life_force,
		"corruption_radius": DUNGEON_HEART_CONFIG.corruption_radius
	}

# 获取组件配置
static func get_component_config(component_name: String) -> Dictionary:
	"""获取指定组件的配置"""
	return DUNGEON_HEART_CONFIG.components.get(component_name, {})

# 获取所有组件配置
static func get_all_components() -> Dictionary:
	"""获取所有组件配置"""
	return DUNGEON_HEART_CONFIG.components

# 获取层配置
static func get_layer_config(layer_name: String) -> Dictionary:
	"""获取指定层的配置"""
	return DUNGEON_HEART_CONFIG.layers.get(layer_name, {})

# 获取所有层配置
static func get_all_layers() -> Dictionary:
	"""获取所有层配置"""
	return DUNGEON_HEART_CONFIG.layers

# 获取渲染配置
static func get_render_config() -> Dictionary:
	"""获取渲染配置"""
	return {
		"render_mode": DUNGEON_HEART_CONFIG.render_mode,
		"use_layered_rendering": DUNGEON_HEART_CONFIG.use_layered_rendering,
		"enable_emission": DUNGEON_HEART_CONFIG.enable_emission,
		"enable_transparency": DUNGEON_HEART_CONFIG.enable_transparency
	}
