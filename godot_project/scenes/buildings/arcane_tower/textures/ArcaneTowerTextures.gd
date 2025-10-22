extends RefCounted
class_name ArcaneTowerTextures

## 🖼️ 奥术塔纹理配置
## 紫色魔法主题的纹理管理

# 纹理路径配置
static var _texture_paths = {
	"crystal_ball": "res://scenes/buildings/arcane_tower/textures/crystal_ball.png",
	"magic_circle": "res://scenes/buildings/arcane_tower/textures/magic_circle.png",
	"arcane_orb": "res://scenes/buildings/arcane_tower/textures/arcane_orb.png",
	"spell_book": "res://scenes/buildings/arcane_tower/textures/spell_book.png",
	"rune_stone": "res://scenes/buildings/arcane_tower/textures/rune_stone.png"
}

static func apply_texture_to_material(material: StandardMaterial3D, texture_name: String):
	"""将纹理应用到材质"""
	if not _texture_paths.has(texture_name):
		LogManager.warning("⚠️ [ArcaneTowerTextures] 未知纹理: %s" % texture_name)
		return
	
	var texture_path = _texture_paths[texture_name]
	var texture = load(texture_path)
	
	if texture:
		material.albedo_texture = texture
		LogManager.info("🖼️ [ArcaneTowerTextures] 应用纹理: %s" % texture_name)
	else:
		LogManager.warning("⚠️ [ArcaneTowerTextures] 无法加载纹理: %s" % texture_path)

static func get_texture_path(texture_name: String) -> String:
	"""获取纹理路径"""
	return _texture_paths.get(texture_name, "")

static func get_available_textures() -> Array[String]:
	"""获取可用纹理列表"""
	var textures: Array[String] = []
	for texture_name in _texture_paths.keys():
		textures.append(texture_name)
	return textures
