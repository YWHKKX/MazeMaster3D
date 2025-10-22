extends RefCounted
class_name FactoryConfig

## 工厂建筑配置
## 提供工厂相关的组件和材质配置

# 工厂组件配置
static func get_all_components() -> Dictionary:
	return {
		"Assembly_Line": {
			"id": 1101,
			"name": "装配线",
			"material": "metal",
			"texture": "assembly_line",
			"color": Color(0.5, 0.5, 0.5),
			"roughness": 0.4,
			"metallic": 0.6
		},
		"Conveyor_Belt": {
			"id": 1102,
			"name": "传送带",
			"material": "metal",
			"texture": "conveyor_belt",
			"color": Color(0.3, 0.3, 0.3),
			"roughness": 0.6,
			"metallic": 0.3
		},
		"Smokestack": {
			"id": 1103,
			"name": "烟囱",
			"material": "metal",
			"texture": "smokestack",
			"color": Color(0.4, 0.4, 0.4),
			"roughness": 0.7,
			"metallic": 0.4
		},
		"Resource_Node": {
			"id": 1104,
			"name": "资源节点",
			"material": "metal",
			"texture": "resource_node",
			"color": Color(0.6, 0.4, 0.2),
			"roughness": 0.5,
			"metallic": 0.3
		},
		"Ventilation": {
			"id": 1105,
			"name": "通风设备",
			"material": "metal",
			"texture": "ventilation",
			"color": Color(0.3, 0.3, 0.3),
			"roughness": 0.6,
			"metallic": 0.5
		}
	}

# 工厂材质配置
static func get_material_configs() -> Dictionary:
	return {
		"metal": {
			"albedo_color": Color(0.5, 0.5, 0.5),
			"roughness": 0.4,
			"metallic": 0.6
		}
	}

# 工厂建筑信息
static func get_building_info() -> Dictionary:
	return {
		"building_name": "工厂",
		"building_type": "factory",
		"building_size": Vector2(1, 1),
		"building_tier": 2,
		"building_category": "production",
		"building_theme": "industrial"
	}
