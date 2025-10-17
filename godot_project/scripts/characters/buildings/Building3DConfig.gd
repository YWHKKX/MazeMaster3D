extends RefCounted
class_name Building3DConfig

## 🏗️ 3x3x3建筑配置类
## 定义建筑的3D配置参数

# 基础配置
var name: String = ""
var building_type: int = 0
var size: Vector3 = Vector3(3, 3, 3)  # 3x3x3空间
var cell_size: float = 0.33  # 每个子瓦片的尺寸

# 结构配置
var has_windows: bool = true
var has_door: bool = true
var has_roof: bool = true
var has_decorations: bool = false
var has_tower: bool = false
var has_balcony: bool = false

# 材质配置
var wall_color: Color = Color.WHITE
var roof_color: Color = Color.RED
var floor_color: Color = Color.GRAY
var window_color: Color = Color.LIGHT_BLUE
var door_color: Color = Color.BROWN

# 特殊功能配置
var has_lighting: bool = true
var has_particles: bool = false
var has_animations: bool = true
var has_sound_effects: bool = false

# 性能配置
var lod_enabled: bool = true
var collision_optimized: bool = true
var shadow_casting: bool = true


func _init(config_name: String = ""):
	name = config_name


func set_basic_config(building_name: String, building_type_id: int, building_size: Vector3 = Vector3(3, 3, 3)):
	"""设置基础配置"""
	name = building_name
	building_type = building_type_id
	size = building_size


func set_structure_config(windows: bool = true, door: bool = true, roof: bool = true, decorations: bool = false):
	"""设置结构配置"""
	has_windows = windows
	has_door = door
	has_roof = roof
	has_decorations = decorations


func set_material_config(wall: Color = Color.WHITE, roof: Color = Color.RED, floor: Color = Color.GRAY):
	"""设置材质配置"""
	wall_color = wall
	roof_color = roof
	floor_color = floor


func set_special_config(lighting: bool = true, particles: bool = false, animations: bool = true, sound: bool = false):
	"""设置特殊功能配置"""
	has_lighting = lighting
	has_particles = particles
	has_animations = animations
	has_sound_effects = sound


func set_performance_config(lod: bool = true, collision: bool = true, shadow: bool = true):
	"""设置性能配置"""
	lod_enabled = lod
	collision_optimized = collision
	shadow_casting = shadow


func to_dict() -> Dictionary:
	"""转换为字典"""
	return {
		"name": name,
		"building_type": building_type,
		"size": size,
		"cell_size": cell_size,
		"has_windows": has_windows,
		"has_door": has_door,
		"has_roof": has_roof,
		"has_decorations": has_decorations,
		"has_tower": has_tower,
		"has_balcony": has_balcony,
		"wall_color": wall_color,
		"roof_color": roof_color,
		"floor_color": floor_color,
		"window_color": window_color,
		"door_color": door_color,
		"has_lighting": has_lighting,
		"has_particles": has_particles,
		"has_animations": has_animations,
		"has_sound_effects": has_sound_effects,
		"lod_enabled": lod_enabled,
		"collision_optimized": collision_optimized,
		"shadow_casting": shadow_casting
	}


func from_dict(data: Dictionary):
	"""从字典加载"""
	name = data.get("name", "")
	building_type = data.get("building_type", 0)
	size = data.get("size", Vector3(3, 3, 3))
	cell_size = data.get("cell_size", 0.33)
	has_windows = data.get("has_windows", true)
	has_door = data.get("has_door", true)
	has_roof = data.get("has_roof", true)
	has_decorations = data.get("has_decorations", false)
	has_tower = data.get("has_tower", false)
	has_balcony = data.get("has_balcony", false)
	wall_color = data.get("wall_color", Color.WHITE)
	roof_color = data.get("roof_color", Color.RED)
	floor_color = data.get("floor_color", Color.GRAY)
	window_color = data.get("window_color", Color.LIGHT_BLUE)
	door_color = data.get("door_color", Color.BROWN)
	has_lighting = data.get("has_lighting", true)
	has_particles = data.get("has_particles", false)
	has_animations = data.get("has_animations", true)
	has_sound_effects = data.get("has_sound_effects", false)
	lod_enabled = data.get("lod_enabled", true)
	collision_optimized = data.get("collision_optimized", true)
	shadow_casting = data.get("shadow_casting", true)
