extends RefCounted
class_name ArcaneTowerMaterialConfig

## 🎨 奥术塔材质配置
## 紫色魔法主题的材质管理

# 材质配置字典
static var _material_configs = {
	"magic": {
		"albedo_color": Color(0.5, 0.2, 0.8), # 紫色
		"roughness": 0.1,
		"metallic": 0.0,
		"emission_enabled": true,
		"emission": Color(0.6, 0.3, 1.0),
		"emission_energy": 2.0
	},
	"dark_magic": {
		"albedo_color": Color(0.3, 0.1, 0.6), # 深紫色
		"roughness": 0.2,
		"metallic": 0.0,
		"emission_enabled": true,
		"emission": Color(0.4, 0.2, 0.8),
		"emission_energy": 1.5
	},
	"light_magic": {
		"albedo_color": Color(0.7, 0.4, 1.0), # 浅紫色
		"roughness": 0.0,
		"metallic": 0.0,
		"emission_enabled": true,
		"emission": Color(0.8, 0.5, 1.0),
		"emission_energy": 2.5
	},
	"arcane": {
		"albedo_color": Color(0.4, 0.1, 0.9, 0.9), # 奥术色
		"roughness": 0.0,
		"metallic": 0.0,
		"emission_enabled": true,
		"emission": Color(0.5, 0.2, 1.0),
		"emission_energy": 2.5,
		"transparency": BaseMaterial3D.TRANSPARENCY_ALPHA
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
		LogManager.warning("⚠️ [ArcaneTowerMaterialConfig] 未知材质: %s" % material_name)
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
	
	# 设置透明度
	if config.has("transparency"):
		material.transparency = config.transparency
	
	LogManager.info("🎨 [ArcaneTowerMaterialConfig] 创建材质: %s" % material_name)
	return material

static func create_default_material() -> StandardMaterial3D:
	"""创建默认材质"""
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.2, 0.8) # 紫色
	material.roughness = 0.1
	material.metallic = 0.0
	material.emission_enabled = true
	material.emission = Color(0.6, 0.3, 1.0)
	material.emission_energy = 2.0
	return material

static func get_available_materials() -> Array[String]:
	"""获取可用材质列表"""
	var materials: Array[String] = []
	for material_name in _material_configs.keys():
		materials.append(material_name)
	return materials
