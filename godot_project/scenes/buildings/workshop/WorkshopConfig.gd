extends RefCounted
class_name WorkshopConfig

## 工坊建筑配置
## 提供工坊相关的组件和材质配置

# 工坊组件配置
static func get_all_components() -> Dictionary:
	return {
		"Workbench": {
			"id": 1031,
			"name": "工作台",
			"material": "wood",
			"texture": "workbench",
			"color": Color(0.4, 0.2, 0.1),
			"roughness": 0.8,
			"metallic": 0.0
		},
		"Forge": {
			"id": 1032,
			"name": "熔炉",
			"material": "metal",
			"texture": "forge",
			"color": Color(0.6, 0.3, 0.1),
			"roughness": 0.3,
			"metallic": 0.7,
			"emission": Color(1.0, 0.4, 0.0),
			"emission_energy": 2.0
		},
		"Tool_Rack": {
			"id": 1033,
			"name": "工具架",
			"material": "wood",
			"texture": "tool_rack",
			"color": Color(0.4, 0.2, 0.1),
			"roughness": 0.7,
			"metallic": 0.1
		},
		"Anvil": {
			"id": 1034,
			"name": "铁砧",
			"material": "metal",
			"texture": "anvil",
			"color": Color(0.3, 0.3, 0.3),
			"roughness": 0.4,
			"metallic": 0.9
		},
		"Material_Pile": {
			"id": 1035,
			"name": "材料堆",
			"material": "stone",
			"texture": "material_pile",
			"color": Color(0.5, 0.4, 0.3),
			"roughness": 0.8,
			"metallic": 0.2
		}
	}

# 工坊材质配置
static func get_material_configs() -> Dictionary:
	return {
		"wood": {
			"albedo_color": Color(0.4, 0.2, 0.1),
			"roughness": 0.8,
			"metallic": 0.0
		},
		"metal": {
			"albedo_color": Color(0.5, 0.5, 0.5),
			"roughness": 0.4,
			"metallic": 0.7
		},
		"stone": {
			"albedo_color": Color(0.5, 0.4, 0.3),
			"roughness": 0.8,
			"metallic": 0.2
		}
	}

# 工坊建筑信息
static func get_building_info() -> Dictionary:
	return {
		"building_name": "工坊",
		"building_type": "workshop",
		"building_size": Vector2(1, 1),
		"building_tier": 2,
		"building_category": "production",
		"building_theme": "industrial"
	}
