extends RefCounted
class_name ShadowTempleConfig

## 暗影神殿建筑配置
## 提供暗影神殿相关的组件和材质配置

# 暗影神殿组件配置
static func get_all_components() -> Dictionary:
	return {
		"Shadow_Altar": {
			"id": 1081,
			"name": "暗影祭坛",
			"material": "stone",
			"texture": "shadow_altar",
			"color": Color(0.05, 0.05, 0.05),
			"roughness": 0.9,
			"metallic": 0.1,
			"emission": Color(0.1, 0.0, 0.1),
			"emission_energy": 1.5
		},
		"Shadow_Core": {
			"id": 1082,
			"name": "暗影核心",
			"material": "magic",
			"texture": "shadow_core",
			"color": Color(0.1, 0.0, 0.1, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.3, 0.0, 0.3),
			"emission_energy": 2.5
		},
		"Shadow_Flame": {
			"id": 1083,
			"name": "暗影火焰",
			"material": "magic",
			"texture": "shadow_flame",
			"color": Color(0.2, 0.0, 0.2, 0.6),
			"roughness": 0.0,
			"metallic": 0.0,
			"emission": Color(0.5, 0.0, 0.5),
			"emission_energy": 3.0
		},
		"Shadow_Pool": {
			"id": 1084,
			"name": "暗影池",
			"material": "magic",
			"texture": "shadow_pool",
			"color": Color(0.05, 0.0, 0.1, 0.7),
			"roughness": 0.0,
			"metallic": 0.0,
			"emission": Color(0.1, 0.0, 0.2),
			"emission_energy": 1.5
		},
		"Shadow_Rune": {
			"id": 1085,
			"name": "暗影符文",
			"material": "magic",
			"texture": "shadow_rune",
			"color": Color(0.1, 0.0, 0.1, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.2, 0.0, 0.2),
			"emission_energy": 2.0
		}
	}

# 暗影神殿材质配置
static func get_material_configs() -> Dictionary:
	return {
		"stone": {
			"albedo_color": Color(0.05, 0.05, 0.05),
			"roughness": 0.9,
			"metallic": 0.1
		},
		"magic": {
			"albedo_color": Color(0.1, 0.0, 0.1, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.3, 0.0, 0.3),
			"emission_energy": 2.5
		}
	}

# 暗影神殿建筑信息
static func get_building_info() -> Dictionary:
	return {
		"building_name": "暗影神殿",
		"building_type": "shadow_temple",
		"building_size": Vector2(1, 1),
		"building_tier": 3,
		"building_category": "magic",
		"building_theme": "shadow"
	}
