extends RefCounted
class_name ArcaneTowerConfig

## 🔮 奥术塔建筑配置
## 紫色魔法主题的1x1瓦块建筑

# 奥术塔组件配置
static func get_all_components() -> Dictionary:
	"""获取所有奥术塔组件配置"""
	return {
		"Crystal_Ball": {
			"id": 1011,
			"name": "水晶球",
			"layer": "decoration",
			"material": "magic",
			"texture": "crystal_ball",
			"description": "充满魔力的水晶球"
		},
		"Magic_Circle": {
			"id": 1012,
			"name": "魔法阵",
			"layer": "floor",
			"material": "magic",
			"texture": "magic_circle",
			"description": "绘制在地面的魔法阵"
		},
		"Arcane_Orb": {
			"id": 1013,
			"name": "奥术球",
			"layer": "decoration",
			"material": "magic",
			"texture": "arcane_orb",
			"description": "悬浮的奥术能量球"
		},
		"Spell_Book": {
			"id": 1014,
			"name": "法术书",
			"layer": "decoration",
			"material": "magic",
			"texture": "spell_book",
			"description": "记录法术的魔法书籍"
		},
		"Rune_Stone": {
			"id": 1015,
			"name": "符文石",
			"layer": "decoration",
			"material": "magic",
			"texture": "rune_stone",
			"description": "刻有符文的魔法石"
		}
	}

# 奥术塔主题配置
static func get_theme_config() -> Dictionary:
	"""获取奥术塔主题配置"""
	return {
		"primary_color": Color(0.5, 0.2, 0.8), # 紫色
		"secondary_color": Color(0.3, 0.1, 0.6), # 深紫色
		"accent_color": Color(0.7, 0.4, 1.0), # 浅紫色
		"emission_color": Color(0.6, 0.3, 1.0), # 发光紫色
		"emission_energy": 2.0,
		"roughness": 0.1,
		"metallic": 0.0
	}

# 奥术塔建筑属性
static func get_building_properties() -> Dictionary:
	"""获取奥术塔建筑属性"""
	return {
		"building_size": Vector2(1, 1), # 1x1瓦块
		"building_theme": "arcane_tower",
		"building_tier": 2,
		"building_category": "magic",
		"max_health": 300,
		"armor": 3,
		"cost_gold": 600,
		"attack_damage": 40.0,
		"attack_range": 100.0,
		"mana_cost_per_attack": 1.0
	}
