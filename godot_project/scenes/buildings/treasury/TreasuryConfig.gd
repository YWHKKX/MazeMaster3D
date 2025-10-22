extends RefCounted
class_name TreasuryConfig

## 🏦 金库建筑配置
## 金色财富主题的1x1瓦块建筑

# 金库组件配置
static func get_all_components() -> Dictionary:
	"""获取所有金库组件配置"""
	return {
		"Treasure_Chest": {
			"id": 1001,
			"name": "金库宝箱",
			"layer": "floor",
			"material": "gold",
			"texture": "treasure_chest",
			"description": "存储金币的主要宝箱"
		},
		"Gold_Pile": {
			"id": 1002,
			"name": "金币堆",
			"layer": "decoration",
			"material": "gold",
			"texture": "gold_pile",
			"description": "闪闪发光的金币堆"
		},
		"Gold_Bar": {
			"id": 1003,
			"name": "金条",
			"layer": "decoration",
			"material": "gold",
			"texture": "gold_bar",
			"description": "珍贵的金条装饰"
		},
		"Vault_Door": {
			"id": 1004,
			"name": "金库门",
			"layer": "wall",
			"material": "metal",
			"texture": "vault_door",
			"description": "坚固的金库大门"
		},
		"Gold_Coin": {
			"id": 1005,
			"name": "金币",
			"layer": "decoration",
			"material": "gold",
			"texture": "gold_coin",
			"description": "散落的金币装饰"
		}
	}

# 金库主题配置
static func get_theme_config() -> Dictionary:
	"""获取金库主题配置"""
	return {
		"primary_color": Color(1.0, 0.84, 0.0), # 金色
		"secondary_color": Color(0.8, 0.6, 0.0), # 深金色
		"accent_color": Color(1.0, 1.0, 0.8), # 浅金色
		"emission_color": Color(1.0, 0.9, 0.3), # 发光金色
		"emission_energy": 1.5,
		"roughness": 0.2,
		"metallic": 0.9
	}

# 金库建筑属性
static func get_building_properties() -> Dictionary:
	"""获取金库建筑属性"""
	return {
		"building_size": Vector2(1, 1), # 1x1瓦块
		"building_theme": "treasury",
		"building_tier": 2,
		"building_category": "economic",
		"max_health": 200,
		"armor": 5,
		"cost_gold": 500,
		"storage_capacity": 10000, # 金币存储容量
		"security_level": 3 # 安全等级
	}
