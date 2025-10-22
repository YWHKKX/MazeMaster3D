extends Resource
class_name DungeonHeartMaterialConfig

## 🎨 地牢之心专用材质配置
## 定义地牢之心所有组件的材质参数

# 地牢之心材质配置
const DUNGEON_HEART_MATERIALS = {
	# 核心组件材质 - 红色魔力核心
	"heart_core": {
		"albedo_color": Color(0.9, 0.1, 0.1), # 深红色核心
		"roughness": 0.1, # 低粗糙度（光滑）
		"metallic": 0.9, # 高金属度
		"emission_enabled": true,
		"emission": Color(1.0, 0.2, 0.2), # 强烈红色发光
		"emission_energy": 2.5, # 最高发光强度
		"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED
	},
	
	"energy_crystal": {
		"albedo_color": Color(0.8, 0.1, 0.1), # 红色水晶
		"roughness": 0.05, # 极低粗糙度（水晶般光滑）
		"metallic": 0.0, # 非金属
		"emission_enabled": true,
		"emission": Color(0.9, 0.2, 0.2), # 红色发光
		"emission_energy": 2.0, # 高发光强度
		"transparency": BaseMaterial3D.TRANSPARENCY_ALPHA,
		"alpha": 0.8 # 半透明
	},
	
	"mana_crystal": {
		"albedo_color": Color(0.7, 0.1, 0.1), # 深红色魔力水晶
		"roughness": 0.1, # 低粗糙度
		"metallic": 0.0, # 非金属
		"emission_enabled": true,
		"emission": Color(0.8, 0.2, 0.2), # 红色发光
		"emission_energy": 1.8, # 中高发光强度
		"transparency": BaseMaterial3D.TRANSPARENCY_ALPHA,
		"alpha": 0.9 # 轻微透明
	},
	
	"magic_core": {
		"albedo_color": Color(0.9, 0.1, 0.1), # 深红色魔法核心
		"roughness": 0.2, # 低粗糙度
		"metallic": 0.8, # 高金属度
		"emission_enabled": true,
		"emission": Color(1.0, 0.2, 0.2), # 强烈红色发光
		"emission_energy": 2.2, # 高发光强度
		"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED
	},
	
	"energy_conduit": {
		"albedo_color": Color(0.6, 0.1, 0.1), # 深红色导管
		"roughness": 0.3, # 中等粗糙度
		"metallic": 0.6, # 高金属度
		"emission_enabled": true,
		"emission": Color(0.8, 0.2, 0.2), # 红色发光
		"emission_energy": 1.5, # 中等发光强度
		"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED
	},
	
	"energy_node": {
		"albedo_color": Color(0.2, 0.6, 0.9), # 蓝色
		"roughness": 0.1, # 低粗糙度
		"metallic": 0.3, # 低金属度
		"emission_enabled": true,
		"emission": Color(0.3, 0.7, 0.9), # 蓝色发光
		"emission_energy": 1.4, # 中高发光强度
		"transparency": BaseMaterial3D.TRANSPARENCY_ALPHA,
		"alpha": 0.7 # 半透明
	},
	
	"storage_core": {
		"albedo_color": Color(0.6, 0.3, 0.8), # 紫色
		"roughness": 0.2, # 低粗糙度
		"metallic": 0.5, # 中等金属度
		"emission_enabled": true,
		"emission": Color(0.7, 0.4, 0.9), # 紫色发光
		"emission_energy": 1.3, # 中等发光强度
		"transparency": BaseMaterial3D.TRANSPARENCY_ALPHA,
		"alpha": 0.8 # 半透明
	},
	
	"heart_entrance": {
		"albedo_color": Color(0.4, 0.2, 0.1), # 深棕色
		"roughness": 0.7, # 高粗糙度（木质）
		"metallic": 0.0, # 非金属
		"emission_enabled": false,
		"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED
	},
	
	# 结构材质
	"dungeon_stone": {
		"albedo_color": Color(0.4, 0.4, 0.4), # 深灰色
		"roughness": 0.9, # 高粗糙度（石质）
		"metallic": 0.0, # 非金属
		"emission_enabled": false,
		"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED
	},
	
	"dungeon_metal": {
		"albedo_color": Color(0.5, 0.5, 0.6), # 金属灰色
		"roughness": 0.3, # 中等粗糙度
		"metallic": 0.8, # 高金属度
		"emission_enabled": false,
		"transparency": BaseMaterial3D.TRANSPARENCY_DISABLED
	}
}

# 获取材质配置
static func get_material_config(material_name: String) -> Dictionary:
	"""获取指定材质的配置"""
	return DUNGEON_HEART_MATERIALS.get(material_name, {})

# 获取所有材质配置
static func get_all_materials() -> Dictionary:
	"""获取所有材质配置"""
	return DUNGEON_HEART_MATERIALS

# 创建材质
static func create_material(material_name: String) -> StandardMaterial3D:
	"""根据配置创建材质"""
	var config = get_material_config(material_name)
	if config.is_empty():
		LogManager.warning("⚠️ [DungeonHeartMaterialConfig] 未找到材质配置: %s" % material_name)
		return null
	
	var material = StandardMaterial3D.new()
	
	# 设置基础属性
	if config.has("albedo_color"):
		material.albedo_color = config.albedo_color
	if config.has("roughness"):
		material.roughness = config.roughness
	if config.has("metallic"):
		material.metallic = config.metallic
	
	# 设置发光属性
	if config.has("emission_enabled") and config.emission_enabled:
		material.emission_enabled = true
		if config.has("emission"):
			material.emission = config.emission
		if config.has("emission_energy"):
			material.emission_energy = config.emission_energy
	
	# 设置透明属性
	if config.has("transparency"):
		material.transparency = config.transparency
	if config.has("alpha"):
		material.albedo_color.a = config.alpha
	
	LogManager.info("🎨 [DungeonHeartMaterialConfig] 创建材质: %s" % material_name)
	return material
