extends RefCounted
class_name MarketConfig

## 市场建筑配置
## 提供市场相关的组件和材质配置

# 市场组件配置
static func get_all_components() -> Dictionary:
	return {
		"Vendor_Stall": {
			"id": 1051,
			"name": "商贩摊位",
			"material": "wood",
			"texture": "vendor_stall",
			"color": Color(0.6, 0.4, 0.2),
			"roughness": 0.7,
			"metallic": 0.1
		},
		"Trading_Desk": {
			"id": 1052,
			"name": "交易台",
			"material": "wood",
			"texture": "trading_desk",
			"color": Color(0.4, 0.2, 0.1),
			"roughness": 0.6,
			"metallic": 0.2
		},
		"Display_Counter": {
			"id": 1053,
			"name": "展示柜台",
			"material": "metal",
			"texture": "display_counter",
			"color": Color(0.7, 0.7, 0.7),
			"roughness": 0.3,
			"metallic": 0.4
		},
		"Merchant_Cart": {
			"id": 1054,
			"name": "商贩推车",
			"material": "wood",
			"texture": "merchant_cart",
			"color": Color(0.5, 0.3, 0.1),
			"roughness": 0.8,
			"metallic": 0.1
		},
		"Goods_Storage": {
			"id": 1055,
			"name": "货物存储",
			"material": "wood",
			"texture": "goods_storage",
			"color": Color(0.4, 0.2, 0.1),
			"roughness": 0.7,
			"metallic": 0.1
		}
	}

# 市场材质配置
static func get_material_configs() -> Dictionary:
	return {
		"wood": {
			"albedo_color": Color(0.4, 0.2, 0.1),
			"roughness": 0.7,
			"metallic": 0.1
		},
		"metal": {
			"albedo_color": Color(0.7, 0.7, 0.7),
			"roughness": 0.3,
			"metallic": 0.4
		}
	}

# 市场建筑信息
static func get_building_info() -> Dictionary:
	return {
		"building_name": "市场",
		"building_type": "market",
		"building_size": Vector2(1, 1),
		"building_tier": 2,
		"building_category": "commerce",
		"building_theme": "trading"
	}
