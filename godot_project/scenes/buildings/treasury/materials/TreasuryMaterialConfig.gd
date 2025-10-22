extends RefCounted
class_name TreasuryMaterialConfig

## 🎨 金库材质配置
## 金色财富主题的材质管理

# 材质配置字典
static var _material_configs = {
	"gold": {
		"albedo_color": Color(1.0, 0.84, 0.0), # 金色
		"roughness": 0.2,
		"metallic": 0.9,
		"emission_enabled": true,
		"emission": Color(1.0, 0.9, 0.3),
		"emission_energy": 1.5
	},
	"dark_gold": {
		"albedo_color": Color(0.8, 0.6, 0.0), # 深金色
		"roughness": 0.3,
		"metallic": 0.8,
		"emission_enabled": true,
		"emission": Color(0.9, 0.7, 0.2),
		"emission_energy": 1.0
	},
	"light_gold": {
		"albedo_color": Color(1.0, 1.0, 0.8), # 浅金色
		"roughness": 0.1,
		"metallic": 0.7,
		"emission_enabled": true,
		"emission": Color(1.0, 1.0, 0.9),
		"emission_energy": 2.0
	},
	"metal": {
		"albedo_color": Color(0.6, 0.6, 0.6), # 金属色
		"roughness": 0.3,
		"metallic": 0.9,
		"emission_enabled": false
	},
	"stone": {
		"albedo_color": Color(0.4, 0.4, 0.4), # 石质色
		"roughness": 0.8,
		"metallic": 0.1,
		"emission_enabled": false
	}
}

static func create_material(material_name: String) -> StandardMaterial3D:
	"""创建指定名称的材质"""
	if not _material_configs.has(material_name):
		LogManager.warning("⚠️ [TreasuryMaterialConfig] 未知材质: %s" % material_name)
		return create_default_material()
	
	var config = _material_configs[material_name]
	var material = StandardMaterial3D.new()
	
	# 设置基础属性
	material.albedo_color = config.get("albedo_color", Color.WHITE)
	material.roughness = config.get("roughness", 0.5)
	material.metallic = config.get("metallic", 0.0)
	
	# 设置发光属性
	if config.get("emission_enabled", false):
		material.emission_enabled = true
		material.emission = config.get("emission", Color.WHITE)
		material.emission_energy = config.get("emission_energy", 1.0)
	
	LogManager.info("🎨 [TreasuryMaterialConfig] 创建材质: %s" % material_name)
	return material

static func create_default_material() -> StandardMaterial3D:
	"""创建默认材质"""
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.84, 0.0) # 金色
	material.roughness = 0.2
	material.metallic = 0.9
	material.emission_enabled = true
	material.emission = Color(1.0, 0.9, 0.3)
	material.emission_energy = 1.5
	return material

static func get_available_materials() -> Array[String]:
	"""获取可用材质列表"""
	var materials: Array[String] = []
	for material_name in _material_configs.keys():
		materials.append(material_name)
	return materials
