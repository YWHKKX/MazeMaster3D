extends RefCounted
class_name HospitalConfig

## 医院建筑配置
## 提供医院相关的组件和材质配置

# 医院组件配置
static func get_all_components() -> Dictionary:
	return {
		"Hospital_Bed": {
			"id": 1041,
			"name": "病床",
			"material": "cloth",
			"texture": "hospital_bed",
			"color": Color(0.9, 0.9, 0.9),
			"roughness": 0.6,
			"metallic": 0.0
		},
		"Medical_Equipment": {
			"id": 1042,
			"name": "医疗设备",
			"material": "metal",
			"texture": "medical_equipment",
			"color": Color(0.8, 0.8, 0.8),
			"roughness": 0.2,
			"metallic": 0.8
		},
		"Healing_Crystal": {
			"id": 1043,
			"name": "治疗水晶",
			"material": "magic",
			"texture": "healing_crystal",
			"color": Color(0.2, 0.8, 0.4, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.3, 1.0, 0.5),
			"emission_energy": 2.0
		},
		"Surgical_Table": {
			"id": 1044,
			"name": "手术台",
			"material": "metal",
			"texture": "surgical_table",
			"color": Color(0.9, 0.9, 0.9),
			"roughness": 0.3,
			"metallic": 0.6
		},
		"Potion_Bottle": {
			"id": 1045,
			"name": "药水瓶",
			"material": "magic",
			"texture": "potion_bottle",
			"color": Color(0.8, 0.2, 0.2, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(1.0, 0.3, 0.3),
			"emission_energy": 1.5
		}
	}

# 医院材质配置
static func get_material_configs() -> Dictionary:
	return {
		"cloth": {
			"albedo_color": Color(0.9, 0.9, 0.9),
			"roughness": 0.6,
			"metallic": 0.0
		},
		"metal": {
			"albedo_color": Color(0.8, 0.8, 0.8),
			"roughness": 0.2,
			"metallic": 0.8
		},
		"magic": {
			"albedo_color": Color(0.2, 0.8, 0.4, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.3, 1.0, 0.5),
			"emission_energy": 2.0
		}
	}

# 医院建筑信息
static func get_building_info() -> Dictionary:
	return {
		"building_name": "医院",
		"building_type": "hospital",
		"building_size": Vector2(1, 1),
		"building_tier": 2,
		"building_category": "healthcare",
		"building_theme": "medical"
	}
