extends RefCounted
class_name TreasuryTextures

## 🖼️ 金库纹理配置
## 金色财富主题的纹理管理

# 纹理路径配置
static var _texture_paths = {
	"treasure_chest": "res://scenes/buildings/treasury/textures/treasure_chest.png",
	"gold_pile": "res://scenes/buildings/treasury/textures/gold_pile.png",
	"gold_bar": "res://scenes/buildings/treasury/textures/gold_bar.png",
	"vault_door": "res://scenes/buildings/treasury/textures/vault_door.png",
	"gold_coin": "res://scenes/buildings/treasury/textures/gold_coin.png"
}

static func apply_texture_to_material(material: StandardMaterial3D, texture_name: String):
	"""将纹理应用到材质"""
	if not _texture_paths.has(texture_name):
		LogManager.warning("⚠️ [TreasuryTextures] 未知纹理: %s" % texture_name)
		return
	
	var texture_path = _texture_paths[texture_name]
	var texture = load(texture_path)
	
	if texture:
		material.albedo_texture = texture
		LogManager.info("🖼️ [TreasuryTextures] 应用纹理: %s" % texture_name)
	else:
		LogManager.warning("⚠️ [TreasuryTextures] 无法加载纹理: %s" % texture_path)

static func get_texture_path(texture_name: String) -> String:
	"""获取纹理路径"""
	return _texture_paths.get(texture_name, "")

static func get_available_textures() -> Array[String]:
	"""获取可用纹理列表"""
	var textures: Array[String] = []
	for texture_name in _texture_paths.keys():
		textures.append(texture_name)
	return textures
