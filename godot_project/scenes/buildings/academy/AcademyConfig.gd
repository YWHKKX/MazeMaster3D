extends RefCounted
class_name AcademyConfig

## 学院建筑配置
## 提供学院相关的组件和材质配置

# 学院组件配置
static func get_all_components() -> Dictionary:
	return {
		"Teacher_Podium": {
			"id": 1091,
			"name": "讲台",
			"material": "wood",
			"texture": "teacher_podium",
			"color": Color(0.4, 0.2, 0.1),
			"roughness": 0.7,
			"metallic": 0.1
		},
		"Classroom_Desk": {
			"id": 1092,
			"name": "课桌",
			"material": "wood",
			"texture": "classroom_desk",
			"color": Color(0.4, 0.2, 0.1),
			"roughness": 0.8,
			"metallic": 0.0
		},
		"Research_Table": {
			"id": 1093,
			"name": "研究桌",
			"material": "wood",
			"texture": "research_table",
			"color": Color(0.4, 0.2, 0.1),
			"roughness": 0.6,
			"metallic": 0.1
		},
		"Scholar_Statue": {
			"id": 1094,
			"name": "学者雕像",
			"material": "stone",
			"texture": "scholar_statue",
			"color": Color(0.7, 0.7, 0.7),
			"roughness": 0.8,
			"metallic": 0.1
		},
		"Wisdom_Crystal": {
			"id": 1095,
			"name": "智慧水晶",
			"material": "magic",
			"texture": "wisdom_crystal",
			"color": Color(0.2, 0.6, 0.8, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.3, 0.8, 1.0),
			"emission_energy": 2.0
		}
	}

# 学院材质配置
static func get_material_configs() -> Dictionary:
	return {
		"wood": {
			"albedo_color": Color(0.4, 0.2, 0.1),
			"roughness": 0.7,
			"metallic": 0.1
		},
		"stone": {
			"albedo_color": Color(0.7, 0.7, 0.7),
			"roughness": 0.8,
			"metallic": 0.1
		},
		"magic": {
			"albedo_color": Color(0.2, 0.6, 0.8, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.3, 0.8, 1.0),
			"emission_energy": 2.0
		}
	}

# 学院建筑信息
static func get_building_info() -> Dictionary:
	return {
		"building_name": "学院",
		"building_type": "academy",
		"building_size": Vector2(1, 1),
		"building_tier": 3,
		"building_category": "education",
		"building_theme": "academic"
	}
