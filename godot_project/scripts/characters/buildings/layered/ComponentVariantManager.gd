extends Node
class_name ComponentVariantManager

## 🎨 组件变体管理器
## 管理组件的多种变体和风格

signal variant_created(variant_name: String, component_type: String)
signal variant_updated(variant_name: String, component_type: String)

var component_variants: Dictionary = {}
var material_variants: Dictionary = {}
var color_variants: Dictionary = {}
var size_variants: Dictionary = {}

# 材质类型
enum MaterialType {
	STONE, # 石质
	WOOD, # 木质
	METAL, # 金属
	MAGIC, # 魔法
	GLASS, # 玻璃
	FABRIC, # 织物
	CRYSTAL, # 水晶
	SHADOW, # 暗影
	DECORATIVE # 装饰
}

# 颜色主题
enum ColorTheme {
	CLASSIC, # 经典
	MAGICAL, # 魔法
	DARK, # 黑暗
	BRIGHT, # 明亮
	EARTHY, # 大地
	OCEANIC, # 海洋
	FIRE, # 火焰
	ICE # 冰霜
}

func _ready():
	"""初始化组件变体管理器"""
	_setup_material_variants()
	_setup_color_variants()
	_setup_size_variants()
	LogManager.info("🎨 [ComponentVariantManager] 组件变体管理器初始化完成")


func _setup_material_variants():
	"""设置材质变体"""
	material_variants = {
		MaterialType.STONE: {
			"name": "石质",
			"base_color": Color(0.6, 0.6, 0.6),
			"roughness": 0.8,
			"metallic": 0.1,
			"texture_scale": Vector2(1.0, 1.0)
		},
		MaterialType.WOOD: {
			"name": "木质",
			"base_color": Color(0.6, 0.4, 0.2),
			"roughness": 0.6,
			"metallic": 0.0,
			"texture_scale": Vector2(2.0, 2.0)
		},
		MaterialType.METAL: {
			"name": "金属",
			"base_color": Color(0.7, 0.7, 0.8),
			"roughness": 0.2,
			"metallic": 0.9,
			"texture_scale": Vector2(1.5, 1.5)
		},
		MaterialType.MAGIC: {
			"name": "魔法",
			"base_color": Color(0.3, 0.1, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.2, 0.1, 0.6),
			"emission_energy": 0.5,
			"texture_scale": Vector2(1.0, 1.0)
		},
		MaterialType.GLASS: {
			"name": "玻璃",
			"base_color": Color(0.8, 0.9, 1.0),
			"roughness": 0.0,
			"metallic": 0.0,
			"transparency": 0.3,
			"texture_scale": Vector2(1.0, 1.0)
		},
		MaterialType.FABRIC: {
			"name": "织物",
			"base_color": Color(0.8, 0.2, 0.2),
			"roughness": 0.9,
			"metallic": 0.0,
			"texture_scale": Vector2(3.0, 3.0)
		},
		MaterialType.CRYSTAL: {
			"name": "水晶",
			"base_color": Color(0.4, 0.2, 0.9),
			"roughness": 0.0,
			"metallic": 0.0,
			"emission": Color(0.3, 0.1, 0.7),
			"emission_energy": 1.0,
			"texture_scale": Vector2(1.0, 1.0)
		},
		MaterialType.SHADOW: {
			"name": "暗影",
			"base_color": Color(0.1, 0.1, 0.2),
			"roughness": 0.0,
			"metallic": 0.0,
			"emission": Color(0.05, 0.05, 0.1),
			"emission_energy": 0.3,
			"transparency": 0.7,
			"texture_scale": Vector2(1.0, 1.0)
		},
		MaterialType.DECORATIVE: {
			"name": "装饰",
			"base_color": Color(0.8, 0.6, 0.4),
			"roughness": 0.7,
			"metallic": 0.2,
			"texture_scale": Vector2(1.5, 1.5)
		}
	}


func _setup_color_variants():
	"""设置颜色变体"""
	color_variants = {
		ColorTheme.CLASSIC: {
			"name": "经典",
			"color_modifier": Color(1.0, 1.0, 1.0),
			"description": "经典的中性色调"
		},
		ColorTheme.MAGICAL: {
			"name": "魔法",
			"color_modifier": Color(0.8, 0.6, 1.2),
			"description": "神秘的魔法色调"
		},
		ColorTheme.DARK: {
			"name": "黑暗",
			"color_modifier": Color(0.4, 0.4, 0.6),
			"description": "阴暗的黑暗色调"
		},
		ColorTheme.BRIGHT: {
			"name": "明亮",
			"color_modifier": Color(1.2, 1.2, 1.0),
			"description": "明亮的阳光色调"
		},
		ColorTheme.EARTHY: {
			"name": "大地",
			"color_modifier": Color(1.1, 0.9, 0.7),
			"description": "自然的大地色调"
		},
		ColorTheme.OCEANIC: {
			"name": "海洋",
			"color_modifier": Color(0.7, 0.9, 1.1),
			"description": "清新的海洋色调"
		},
		ColorTheme.FIRE: {
			"name": "火焰",
			"color_modifier": Color(1.2, 0.8, 0.6),
			"description": "炽热的火焰色调"
		},
		ColorTheme.ICE: {
			"name": "冰霜",
			"color_modifier": Color(0.8, 1.0, 1.2),
			"description": "冰冷的冰霜色调"
		}
	}


func _setup_size_variants():
	"""设置尺寸变体"""
	size_variants = {
		"small": {
			"name": "小型",
			"scale": Vector3(0.5, 0.5, 0.5),
			"description": "小型组件"
		},
		"normal": {
			"name": "标准",
			"scale": Vector3(1.0, 1.0, 1.0),
			"description": "标准尺寸组件"
		},
		"large": {
			"name": "大型",
			"scale": Vector3(1.5, 1.5, 1.5),
			"description": "大型组件"
		},
		"huge": {
			"name": "巨型",
			"scale": Vector3(2.0, 2.0, 2.0),
			"description": "巨型组件"
		}
	}


func create_component_variant(base_component: Dictionary, material_type: MaterialType, color_theme: ColorTheme, size_variant: String = "normal") -> Dictionary:
	"""创建组件变体"""
	var variant = base_component.duplicate(true)
	
	# 应用材质变体
	var material_data = material_variants.get(material_type, {})
	if not material_data.is_empty():
		variant["material"] = material_data.name
		variant["base_color"] = material_data.base_color
		variant["roughness"] = material_data.roughness
		variant["metallic"] = material_data.metallic
		if material_data.has("emission"):
			variant["emission"] = material_data.emission
		if material_data.has("emission_energy"):
			variant["emission_energy"] = material_data.emission_energy
		if material_data.has("transparency"):
			variant["transparency"] = material_data.transparency
		if material_data.has("texture_scale"):
			variant["texture_scale"] = material_data.texture_scale
	
	# 应用颜色变体
	var color_data = color_variants.get(color_theme, {})
	if not color_data.is_empty():
		variant["color_modifier"] = color_data.color_modifier
		variant["color_theme"] = color_data.name
		# 调整基础颜色
		if variant.has("base_color"):
			variant["base_color"] = variant["base_color"] * color_data.color_modifier
	
	# 应用尺寸变体
	var size_data = size_variants.get(size_variant, {})
	if not size_data.is_empty():
		variant["size_variant"] = size_data.name
		variant["scale"] = size_data.scale
		# 调整尺寸
		if variant.has("size"):
			variant["size"] = variant["size"] * size_data.scale
	
	# 生成变体名称
	var variant_name = "%s_%s_%s_%s" % [base_component.get("name", "Unknown"), material_data.get("name", "Unknown"), color_data.get("name", "Unknown"), size_data.get("name", "Unknown")]
	variant["variant_name"] = variant_name
	
	# 存储变体
	component_variants[variant_name] = variant
	
	variant_created.emit(variant_name, base_component.get("name", "Unknown"))
	LogManager.info("🎨 [ComponentVariantManager] 创建组件变体: %s" % variant_name)
	
	return variant


func get_component_variant(variant_name: String) -> Dictionary:
	"""获取组件变体"""
	return component_variants.get(variant_name, {})


func get_all_variants_for_component(component_name: String) -> Array[Dictionary]:
	"""获取组件的所有变体"""
	var variants: Array[Dictionary] = []
	
	for variant_name in component_variants:
		var variant = component_variants[variant_name]
		if variant.get("name", "").begins_with(component_name):
			variants.append(variant)
	
	return variants


func get_material_variants() -> Dictionary:
	"""获取所有材质变体"""
	return material_variants


func get_color_variants() -> Dictionary:
	"""获取所有颜色变体"""
	return color_variants


func get_size_variants() -> Dictionary:
	"""获取所有尺寸变体"""
	return size_variants


func create_custom_variant(base_component: Dictionary, custom_properties: Dictionary) -> Dictionary:
	"""创建自定义变体"""
	var variant = base_component.duplicate(true)
	
	# 应用自定义属性
	for key in custom_properties:
		variant[key] = custom_properties[key]
	
	# 生成变体名称
	var variant_name = "%s_custom_%d" % [base_component.get("name", "Unknown"), Time.get_unix_time_from_system()]
	variant["variant_name"] = variant_name
	variant["is_custom"] = true
	
	# 存储变体
	component_variants[variant_name] = variant
	
	variant_created.emit(variant_name, base_component.get("name", "Unknown"))
	LogManager.info("🎨 [ComponentVariantManager] 创建自定义变体: %s" % variant_name)
	
	return variant


func update_variant(variant_name: String, updates: Dictionary) -> bool:
	"""更新变体"""
	if not variant_name in component_variants:
		LogManager.warning("⚠️ [ComponentVariantManager] 变体不存在: %s" % variant_name)
		return false
	
	# 更新变体属性
	for key in updates:
		component_variants[variant_name][key] = updates[key]
	
	variant_updated.emit(variant_name, component_variants[variant_name].get("name", "Unknown"))
	LogManager.info("🎨 [ComponentVariantManager] 更新变体: %s" % variant_name)
	
	return true


func delete_variant(variant_name: String) -> bool:
	"""删除变体"""
	if not variant_name in component_variants:
		LogManager.warning("⚠️ [ComponentVariantManager] 变体不存在: %s" % variant_name)
		return false
	
	component_variants.erase(variant_name)
	LogManager.info("🗑️ [ComponentVariantManager] 删除变体: %s" % variant_name)
	
	return true


func get_variant_count() -> int:
	"""获取变体数量"""
	return component_variants.size()


func get_all_variants() -> Dictionary:
	"""获取所有变体"""
	return component_variants
