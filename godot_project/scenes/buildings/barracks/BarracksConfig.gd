extends RefCounted
class_name BarracksConfig

## 🏰 兵营建筑配置
## 军事风格主题的1x1瓦块建筑

# 兵营组件配置
static func get_all_components() -> Dictionary:
	"""获取所有兵营组件配置"""
	return {
		"Military_Flag": {
			"id": 1021,
			"name": "军旗",
			"layer": "decoration",
			"material": "cloth",
			"texture": "military_flag",
			"description": "代表军队的旗帜"
		},
		"Campfire": {
			"id": 1022,
			"name": "营火",
			"layer": "decoration",
			"material": "fire",
			"texture": "campfire",
			"description": "提供温暖和照明的营火"
		},
		"Barracks_Bunk": {
			"id": 1023,
			"name": "军营床铺",
			"layer": "decoration",
			"material": "wood",
			"texture": "barracks_bunk",
			"description": "士兵休息的床铺"
		},
		"Armor_Stand": {
			"id": 1024,
			"name": "盔甲架",
			"layer": "decoration",
			"material": "metal",
			"texture": "armor_stand",
			"description": "存放盔甲的架子"
		},
		"Shield_Rack": {
			"id": 1025,
			"name": "盾牌架",
			"layer": "decoration",
			"material": "wood",
			"texture": "shield_rack",
			"description": "存放盾牌的架子"
		}
	}

# 兵营主题配置
static func get_theme_config() -> Dictionary:
	"""获取兵营主题配置"""
	return {
		"primary_color": Color(0.6, 0.4, 0.2), # 棕色
		"secondary_color": Color(0.4, 0.2, 0.1), # 深棕色
		"accent_color": Color(0.8, 0.1, 0.1), # 红色
		"emission_color": Color(1.0, 0.4, 0.0), # 橙色火光
		"emission_energy": 3.0,
		"roughness": 0.7,
		"metallic": 0.3
	}

# 兵营建筑属性
static func get_building_properties() -> Dictionary:
	"""获取兵营建筑属性"""
	return {
		"building_size": Vector2(1, 1), # 1x1瓦块
		"building_theme": "barracks",
		"building_tier": 2,
		"building_category": "military",
		"max_health": 250,
		"armor": 4,
		"cost_gold": 400,
		"training_capacity": 10,
		"morale_bonus": 1.2
	}
