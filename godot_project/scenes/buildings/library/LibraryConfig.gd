extends RefCounted
class_name LibraryConfig

## 图书馆建筑配置
## 提供图书馆相关的组件和材质配置

# 图书馆组件配置
static func get_all_components() -> Dictionary:
	return {
		"Bookshelf": {
			"id": 1061,
			"name": "书架",
			"material": "wood",
			"texture": "bookshelf",
			"color": Color(0.4, 0.2, 0.1),
			"roughness": 0.8,
			"metallic": 0.0
		},
		"Reading_Desk": {
			"id": 1062,
			"name": "阅读桌",
			"material": "wood",
			"texture": "reading_desk",
			"color": Color(0.4, 0.2, 0.1),
			"roughness": 0.7,
			"metallic": 0.1
		},
		"Book_Pile": {
			"id": 1063,
			"name": "书堆",
			"material": "cloth",
			"texture": "book_pile",
			"color": Color(0.6, 0.4, 0.2),
			"roughness": 0.8,
			"metallic": 0.0
		},
		"Study_Lamp": {
			"id": 1064,
			"name": "学习灯",
			"material": "metal",
			"texture": "study_lamp",
			"color": Color(0.8, 0.8, 0.2),
			"roughness": 0.2,
			"metallic": 0.3,
			"emission": Color(1.0, 1.0, 0.4),
			"emission_energy": 2.5
		},
		"Knowledge_Orb": {
			"id": 1065,
			"name": "知识宝珠",
			"material": "magic",
			"texture": "knowledge_orb",
			"color": Color(0.2, 0.2, 0.8, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.3, 0.3, 1.0),
			"emission_energy": 2.0
		}
	}

# 图书馆材质配置
static func get_material_configs() -> Dictionary:
	return {
		"wood": {
			"albedo_color": Color(0.4, 0.2, 0.1),
			"roughness": 0.8,
			"metallic": 0.0
		},
		"cloth": {
			"albedo_color": Color(0.6, 0.4, 0.2),
			"roughness": 0.8,
			"metallic": 0.0
		},
		"metal": {
			"albedo_color": Color(0.8, 0.8, 0.2),
			"roughness": 0.2,
			"metallic": 0.3
		},
		"magic": {
			"albedo_color": Color(0.2, 0.2, 0.8, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.3, 0.3, 1.0),
			"emission_energy": 2.0
		}
	}

# 图书馆建筑信息
static func get_building_info() -> Dictionary:
	return {
		"building_name": "图书馆",
		"building_type": "library",
		"building_size": Vector2(1, 1),
		"building_tier": 2,
		"building_category": "education",
		"building_theme": "academic"
	}
