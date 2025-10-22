extends Resource
class_name DungeonHeartTextures

## 🖼️ 地牢之心专用纹理配置
## 定义地牢之心所有组件的纹理参数

# 纹理配置
const DUNGEON_HEART_TEXTURES = {
	# 核心纹理
	"heart_core_texture": {
		"texture_path": "res://scenes/buildings/dungeon_heart/textures/heart_core.png",
		"uv_scale": Vector2(2.0, 2.0),
		"uv_offset": Vector2(0.0, 0.0),
		"normal_strength": 1.0,
		"roughness_texture": "res://scenes/buildings/dungeon_heart/textures/heart_core_roughness.png"
	},
	
	"energy_crystal_texture": {
		"texture_path": "res://scenes/buildings/dungeon_heart/textures/energy_crystal.png",
		"uv_scale": Vector2(1.0, 1.0),
		"uv_offset": Vector2(0.0, 0.0),
		"normal_strength": 0.5,
		"roughness_texture": "res://scenes/buildings/dungeon_heart/textures/energy_crystal_roughness.png"
	},
	
	"mana_crystal_texture": {
		"texture_path": "res://scenes/buildings/dungeon_heart/textures/mana_crystal.png",
		"uv_scale": Vector2(1.0, 1.0),
		"uv_offset": Vector2(0.0, 0.0),
		"normal_strength": 0.3,
		"roughness_texture": "res://scenes/buildings/dungeon_heart/textures/mana_crystal_roughness.png"
	},
	
	"magic_core_texture": {
		"texture_path": "res://scenes/buildings/dungeon_heart/textures/magic_core.png",
		"uv_scale": Vector2(1.5, 1.5),
		"uv_offset": Vector2(0.0, 0.0),
		"normal_strength": 0.8,
		"roughness_texture": "res://scenes/buildings/dungeon_heart/textures/magic_core_roughness.png"
	},
	
	"energy_conduit_texture": {
		"texture_path": "res://scenes/buildings/dungeon_heart/textures/energy_conduit.png",
		"uv_scale": Vector2(2.0, 1.0),
		"uv_offset": Vector2(0.0, 0.0),
		"normal_strength": 0.6,
		"roughness_texture": "res://scenes/buildings/dungeon_heart/textures/energy_conduit_roughness.png"
	},
	
	"energy_node_texture": {
		"texture_path": "res://scenes/buildings/dungeon_heart/textures/energy_node.png",
		"uv_scale": Vector2(1.0, 1.0),
		"uv_offset": Vector2(0.0, 0.0),
		"normal_strength": 0.4,
		"roughness_texture": "res://scenes/buildings/dungeon_heart/textures/energy_node_roughness.png"
	},
	
	"storage_core_texture": {
		"texture_path": "res://scenes/buildings/dungeon_heart/textures/storage_core.png",
		"uv_scale": Vector2(1.0, 1.0),
		"uv_offset": Vector2(0.0, 0.0),
		"normal_strength": 0.5,
		"roughness_texture": "res://scenes/buildings/dungeon_heart/textures/storage_core_roughness.png"
	},
	
	"heart_entrance_texture": {
		"texture_path": "res://scenes/buildings/dungeon_heart/textures/heart_entrance.png",
		"uv_scale": Vector2(1.0, 2.0),
		"uv_offset": Vector2(0.0, 0.0),
		"normal_strength": 1.0,
		"roughness_texture": "res://scenes/buildings/dungeon_heart/textures/heart_entrance_roughness.png"
	},
	
	# 结构纹理
	"dungeon_stone_texture": {
		"texture_path": "res://scenes/buildings/dungeon_heart/textures/dungeon_stone.png",
		"uv_scale": Vector2(4.0, 4.0),
		"uv_offset": Vector2(0.0, 0.0),
		"normal_strength": 1.2,
		"roughness_texture": "res://scenes/buildings/dungeon_heart/textures/dungeon_stone_roughness.png"
	},
	
	"dungeon_metal_texture": {
		"texture_path": "res://scenes/buildings/dungeon_heart/textures/dungeon_metal.png",
		"uv_scale": Vector2(2.0, 2.0),
		"uv_offset": Vector2(0.0, 0.0),
		"normal_strength": 0.8,
		"roughness_texture": "res://scenes/buildings/dungeon_heart/textures/dungeon_metal_roughness.png"
	}
}

# 获取纹理配置
static func get_texture_config(texture_name: String) -> Dictionary:
	"""获取指定纹理的配置"""
	return DUNGEON_HEART_TEXTURES.get(texture_name, {})

# 获取所有纹理配置
static func get_all_textures() -> Dictionary:
	"""获取所有纹理配置"""
	return DUNGEON_HEART_TEXTURES

# 加载纹理
static func load_texture(texture_name: String) -> Texture2D:
	"""根据配置加载纹理"""
	var config = get_texture_config(texture_name)
	if config.is_empty():
		LogManager.warning("⚠️ [DungeonHeartTextures] 未找到纹理配置: %s" % texture_name)
		return null
	
	var texture_path = config.get("texture_path", "")
	if texture_path.is_empty():
		LogManager.warning("⚠️ [DungeonHeartTextures] 纹理路径为空: %s" % texture_name)
		return null
	
	var texture = load(texture_path)
	if not texture:
		LogManager.warning("⚠️ [DungeonHeartTextures] 无法加载纹理: %s" % texture_path)
		return null
	
	LogManager.info("🖼️ [DungeonHeartTextures] 加载纹理: %s" % texture_name)
	return texture

# 应用纹理到材质
static func apply_texture_to_material(material: StandardMaterial3D, texture_name: String):
	"""将纹理应用到材质"""
	var config = get_texture_config(texture_name)
	if config.is_empty():
		return
	
	# 加载主纹理
	var texture = load_texture(texture_name)
	if texture:
		material.albedo_texture = texture
	
	# 设置UV参数
	if config.has("uv_scale"):
		material.uv1_tile = config.uv_scale
	if config.has("uv_offset"):
		material.uv1_offset = config.uv_offset
	
	# 加载法线贴图
	if config.has("normal_strength"):
		material.normal_enabled = true
		material.normal_scale = config.normal_strength
	
	# 加载粗糙度贴图
	if config.has("roughness_texture"):
		var roughness_texture = load(config.roughness_texture)
		if roughness_texture:
			material.roughness_texture = roughness_texture
