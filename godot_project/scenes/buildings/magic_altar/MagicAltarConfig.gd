extends RefCounted
class_name MagicAltarConfig

## 魔法祭坛建筑配置
## 提供魔法祭坛相关的组件和材质配置

# 魔法祭坛组件配置
static func get_all_components() -> Dictionary:
	return {
		"Magic_Altar": {
			"id": 1071,
			"name": "魔法祭坛",
			"material": "magic",
			"texture": "magic_altar",
			"color": Color(0.1, 0.05, 0.2),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.3, 0.1, 0.6),
			"emission_energy": 2.5
		},
		"Summoning_Circle": {
			"id": 1072,
			"name": "召唤法阵",
			"material": "magic",
			"texture": "summoning_circle",
			"color": Color(0.8, 0.1, 0.1, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(1.0, 0.2, 0.2),
			"emission_energy": 3.0
		},
		"Energy_Rune": {
			"id": 1073,
			"name": "能量符文",
			"material": "magic",
			"texture": "energy_rune",
			"color": Color(0.1, 0.8, 0.1, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.2, 1.0, 0.2),
			"emission_energy": 2.0
		},
		"Magic_Scroll": {
			"id": 1074,
			"name": "魔法卷轴",
			"material": "cloth",
			"texture": "magic_scroll",
			"color": Color(0.8, 0.6, 0.4),
			"roughness": 0.8,
			"metallic": 0.0,
			"emission": Color(1.0, 0.8, 0.4),
			"emission_energy": 1.0
		},
		"Mana_Pool": {
			"id": 1075,
			"name": "魔法池",
			"material": "magic",
			"texture": "mana_pool",
			"color": Color(0.1, 0.1, 0.8, 0.6),
			"roughness": 0.0,
			"metallic": 0.0,
			"emission": Color(0.2, 0.2, 1.0),
			"emission_energy": 2.0
		}
	}

# 魔法祭坛材质配置
static func get_material_configs() -> Dictionary:
	return {
		"magic": {
			"albedo_color": Color(0.1, 0.05, 0.2),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.3, 0.1, 0.6),
			"emission_energy": 2.5
		},
		"cloth": {
			"albedo_color": Color(0.8, 0.6, 0.4),
			"roughness": 0.8,
			"metallic": 0.0
		}
	}

# 魔法祭坛建筑信息
static func get_building_info() -> Dictionary:
	return {
		"building_name": "魔法祭坛",
		"building_type": "magic_altar",
		"building_size": Vector2(1, 1),
		"building_tier": 3,
		"building_category": "magic",
		"building_theme": "arcane"
	}
