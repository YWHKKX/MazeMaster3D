extends RefCounted

## 🏗️ 建筑配置类
## 支持自由组件的建筑配置参数

# 基础配置
var name: String = ""
var width: int = 1
var depth: int = 1
var height: int = 1
var building_size: Vector3 = Vector3(1, 1, 1) # 自由尺寸

# 自由组件配置
var components: Array[Dictionary] = [] # 自由组件列表
var component_bounds: AABB = AABB() # 组件边界框
var allow_free_placement: bool = true # 允许自由放置

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

# 特殊功能
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


func set_basic_config(building_name: String, building_width: int = 1, building_depth: int = 1, building_height: int = 1):
	"""设置基础配置"""
	name = building_name
	width = building_width
	depth = building_depth
	height = building_height
	building_size = Vector3(building_width, building_height, building_depth)


func add_component(component_name: String, position: Vector3, size: Vector3, component_type: String = "decoration"):
	"""添加自由组件"""
	var component = {
		"name": component_name,
		"position": position,
		"size": size,
		"type": component_type
	}
	components.append(component)
	_update_bounds()


func remove_component(component_name: String):
	"""移除组件"""
	for i in range(components.size() - 1, -1, -1):
		if components[i]["name"] == component_name:
			components.remove_at(i)
	_update_bounds()


func _update_bounds():
	"""更新组件边界框"""
	if components.is_empty():
		component_bounds = AABB()
		return
	
	var min_pos = Vector3.INF
	var max_pos = Vector3(-INF, -INF, -INF)
	
	for component in components:
		var pos = component["position"]
		var size = component["size"]
		var end_pos = pos + size
		
		min_pos = Vector3(min(min_pos.x, pos.x), min(min_pos.y, pos.y), min(min_pos.z, pos.z))
		max_pos = Vector3(max(max_pos.x, end_pos.x), max(max_pos.y, end_pos.y), max(max_pos.z, end_pos.z))
	
	component_bounds = AABB(min_pos, max_pos - min_pos)


func get_building_bounds() -> AABB:
	"""获取建筑边界框"""
	return component_bounds


func validate_component_placement(component: Dictionary) -> bool:
	"""验证组件放置是否有效"""
	var bounds = get_building_bounds()
	var component_pos = component["position"]
	var component_size = component["size"]
	
	# 检查组件是否在建筑边界内
	return bounds.encloses(AABB(component_pos, component_size))


func generate_free_template() -> Dictionary:
	"""生成自由组件建筑模板"""
	return {
		"building_name": name,
		"building_size": building_size,
		"components": components,
		"bounds": get_building_bounds(),
		"allow_free_placement": allow_free_placement
	}


func set_structure_config(windows: bool = true, door: bool = true, roof: bool = true, decorations: bool = false, tower: bool = false, balcony: bool = false):
	"""设置结构配置"""
	has_windows = windows
	has_door = door
	has_roof = roof
	has_decorations = decorations
	has_tower = tower
	has_balcony = balcony


func set_material_config(wall: Color = Color.WHITE, roof: Color = Color.RED, floor_clr: Color = Color.GRAY, window: Color = Color.LIGHT_BLUE, door: Color = Color.BROWN):
	"""设置材质配置"""
	wall_color = wall
	roof_color = roof
	floor_color = floor_clr
	window_color = window
	door_color = door


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
		"width": width,
		"depth": depth,
		"height": height,
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
	width = data.get("width", 3)
	depth = data.get("depth", 3)
	height = data.get("height", 3)
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
