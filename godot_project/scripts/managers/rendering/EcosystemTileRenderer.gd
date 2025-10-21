extends Node
class_name EcosystemTileRenderer

## 🌍 生态系统地块渲染器
## 专门负责渲染生态系统地块的特殊效果和装饰

# 渲染配置
var render_config = {
	"enabled": true,
	"max_decorations_per_tile": 3,
	"decoration_density": 0.3,
	"enable_particles": true,
	"enable_animations": true,
	"lod_distance": 30.0
}

# 地块装饰配置
var tile_decorations = {
	# 森林生态系统装饰
	TileTypes.TileType.FOREST_CLEARING: ["grass_patch", "small_rock"],
	TileTypes.TileType.DENSE_FOREST: ["fallen_leaves", "moss"],
	TileTypes.TileType.FOREST_EDGE: ["wildflowers", "bark_chips"],
	TileTypes.TileType.ANCIENT_FOREST: ["ancient_moss", "glowing_mushrooms"],
	
	# 草地生态系统装饰
	TileTypes.TileType.GRASSLAND_PLAINS: ["wildflowers", "grass_clumps"],
	TileTypes.TileType.GRASSLAND_HILLS: ["rocks", "grass_patches"],
	TileTypes.TileType.GRASSLAND_WETLANDS: ["water_plants", "mud_patches"],
	TileTypes.TileType.GRASSLAND_FIELDS: ["crop_stalks", "furrows"],
	
	# 湖泊生态系统装饰
	TileTypes.TileType.LAKE_SHALLOW: ["water_ripples", "pebbles"],
	TileTypes.TileType.LAKE_DEEP: ["deep_water_effect", "bubbles"],
	TileTypes.TileType.LAKE_SHORE: ["sand", "driftwood"],
	TileTypes.TileType.LAKE_ISLAND: ["island_vegetation", "beach_rocks"],
	
	# 洞穴生态系统装饰
	TileTypes.TileType.CAVE_DEEP: ["deep_cave_effect", "mineral_veins"],
	TileTypes.TileType.CAVE_CRYSTAL: ["crystal_formations", "glowing_crystals"],
	TileTypes.TileType.CAVE_UNDERGROUND_LAKE: ["underground_water", "cave_reflections"],
	
	# 荒地生态系统装饰
	TileTypes.TileType.WASTELAND_DESERT: ["sand_dunes", "cactus"],
	TileTypes.TileType.WASTELAND_ROCKS: ["rock_piles", "dust"],
	TileTypes.TileType.WASTELAND_RUINS: ["ruin_fragments", "weathered_stones"],
	TileTypes.TileType.WASTELAND_TOXIC: ["toxic_pools", "corrupted_plants"],
	
	# 死地生态系统装饰
	TileTypes.TileType.DEAD_LAND_SWAMP: ["swamp_gas", "dead_roots"],
	TileTypes.TileType.DEAD_LAND_GRAVEYARD: ["gravestones", "dead_flowers"],
	
	# 原始生态系统装饰
	TileTypes.TileType.PRIMITIVE_JUNGLE: ["jungle_vines", "ancient_trees"],
	TileTypes.TileType.PRIMITIVE_VOLCANO: ["lava_flows", "volcanic_rocks"],
	TileTypes.TileType.PRIMITIVE_SWAMP: ["swamp_gas", "primitive_plants"],
}

# 粒子效果配置
var particle_effects = {
	TileTypes.TileType.ANCIENT_FOREST: "glowing_particles",
	TileTypes.TileType.CAVE_CRYSTAL: "crystal_sparkles",
	TileTypes.TileType.WASTELAND_TOXIC: "toxic_fumes",
	TileTypes.TileType.DEAD_LAND_SWAMP: "swamp_mist",
	TileTypes.TileType.PRIMITIVE_VOLCANO: "lava_sparks",
}

var world_node: Node3D = null
var decoration_instances: Dictionary = {} # {tile_position: [decoration_nodes]}

func _ready():
	"""初始化生态系统地块渲染器"""
	LogManager.info("EcosystemTileRenderer - 生态系统地块渲染器初始化完成")

func set_world_node(world: Node3D):
	"""设置世界节点引用"""
	world_node = world
	LogManager.info("EcosystemTileRenderer - 世界节点已设置")

func render_tile_decorations(tile_type: int, position: Vector3) -> void:
	"""为地块添加装饰效果"""
	if not render_config.enabled or not world_node:
		return
	
	# 检查是否有装饰配置
	if not tile_decorations.has(tile_type):
		return
	
	var decorations = tile_decorations[tile_type]
	var tile_key = _get_tile_key(position)
	
	# 避免重复添加装饰
	if decoration_instances.has(tile_key):
		return
	
	var decoration_nodes: Array[Node3D] = []
	
	# 随机选择装饰
	var num_decorations = randi_range(1, render_config.max_decorations_per_tile)
	for i in range(num_decorations):
		if randf() < render_config.decoration_density:
			var decoration_type = decorations[randi() % decorations.size()]
			var decoration_node = _create_decoration(decoration_type, position)
			if decoration_node:
				world_node.add_child(decoration_node)
				decoration_nodes.append(decoration_node)
	
	# 添加粒子效果
	if render_config.enable_particles and particle_effects.has(tile_type):
		var particle_node = _create_particle_effect(particle_effects[tile_type], position)
		if particle_node:
			world_node.add_child(particle_node)
			decoration_nodes.append(particle_node)
	
	# 记录装饰实例
	if decoration_nodes.size() > 0:
		decoration_instances[tile_key] = decoration_nodes

func _create_decoration(decoration_type: String, position: Vector3) -> Node3D:
	"""创建装饰对象"""
	var decoration_node = Node3D.new()
	decoration_node.name = "Decoration_" + decoration_type
	decoration_node.position = position + Vector3(randf_range(-0.3, 0.3), 0, randf_range(-0.3, 0.3))
	
	# 根据装饰类型创建不同的几何体
	match decoration_type:
		"grass_patch":
			_add_grass_patch(decoration_node)
		"small_rock":
			_add_small_rock(decoration_node)
		"fallen_leaves":
			_add_fallen_leaves(decoration_node)
		"wildflowers":
			_add_wildflowers(decoration_node)
		"water_ripples":
			_add_water_ripples(decoration_node)
		"crystal_formations":
			_add_crystal_formations(decoration_node)
		"sand_dunes":
			_add_sand_dunes(decoration_node)
		"swamp_gas":
			_add_swamp_gas(decoration_node)
		"gravestones":
			_add_gravestones(decoration_node)
		"jungle_vines":
			_add_jungle_vines(decoration_node)
		"lava_flows":
			_add_lava_flows(decoration_node)
		_:
			_add_default_decoration(decoration_node)
	
	return decoration_node

func _add_grass_patch(parent: Node3D):
	"""添加草地补丁"""
	var mesh_instance = MeshInstance3D.new()
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(0.3, 0.3)
	mesh_instance.mesh = quad_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.7, 0.3)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = material
	
	parent.add_child(mesh_instance)

func _add_small_rock(parent: Node3D):
	"""添加小石头"""
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.1, 0.1, 0.1)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.5, 0.4)
	material.roughness = 0.9
	mesh_instance.material_override = material
	
	parent.add_child(mesh_instance)

func _add_fallen_leaves(parent: Node3D):
	"""添加落叶"""
	for i in range(3):
		var mesh_instance = MeshInstance3D.new()
		var quad_mesh = QuadMesh.new()
		quad_mesh.size = Vector2(0.1, 0.1)
		mesh_instance.mesh = quad_mesh
		mesh_instance.position = Vector3(randf_range(-0.2, 0.2), 0, randf_range(-0.2, 0.2))
		mesh_instance.rotation.y = randf() * TAU
		
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.6, 0.4, 0.2)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		mesh_instance.material_override = material
		
		parent.add_child(mesh_instance)

func _add_wildflowers(parent: Node3D):
	"""添加野花"""
	for i in range(2):
		var mesh_instance = MeshInstance3D.new()
		var cylinder_mesh = CylinderMesh.new()
		cylinder_mesh.top_radius = 0.02
		cylinder_mesh.bottom_radius = 0.02
		cylinder_mesh.height = 0.1
		mesh_instance.mesh = cylinder_mesh
		mesh_instance.position = Vector3(randf_range(-0.2, 0.2), 0.05, randf_range(-0.2, 0.2))
		
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(randf_range(0.8, 1.0), randf_range(0.3, 0.8), randf_range(0.3, 0.8))
		mesh_instance.material_override = material
		
		parent.add_child(mesh_instance)

func _add_water_ripples(parent: Node3D):
	"""添加水波纹"""
	var mesh_instance = MeshInstance3D.new()
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(0.4, 0.4)
	mesh_instance.mesh = quad_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.6, 0.8, 0.3)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = material
	
	parent.add_child(mesh_instance)

func _add_crystal_formations(parent: Node3D):
	"""添加水晶结构"""
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.2, 0.3, 0.2)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.6, 0.4, 0.8)
	material.roughness = 0.1
	material.metallic = 0.3
	material.emission = Color(0.2, 0.1, 0.3)
	material.emission_energy = 0.5
	mesh_instance.material_override = material
	
	parent.add_child(mesh_instance)

func _add_sand_dunes(parent: Node3D):
	"""添加沙丘"""
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.6, 0.1, 0.6)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.7, 0.4)
	material.roughness = 0.9
	mesh_instance.material_override = material
	
	parent.add_child(mesh_instance)

func _add_swamp_gas(parent: Node3D):
	"""添加沼泽气体"""
	var mesh_instance = MeshInstance3D.new()
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(0.4, 0.4)
	mesh_instance.mesh = quad_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.4, 0.2, 0.4)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission = Color(0.1, 0.2, 0.1)
	material.emission_energy = 0.2
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = material
	
	parent.add_child(mesh_instance)

func _add_gravestones(parent: Node3D):
	"""添加墓碑"""
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.1, 0.2, 0.05)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.3, 0.2)
	material.roughness = 0.9
	mesh_instance.material_override = material
	
	parent.add_child(mesh_instance)

func _add_jungle_vines(parent: Node3D):
	"""添加丛林藤蔓"""
	var mesh_instance = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = 0.02
	cylinder_mesh.bottom_radius = 0.02
	cylinder_mesh.height = 0.3
	mesh_instance.mesh = cylinder_mesh
	mesh_instance.rotation.z = randf_range(-0.3, 0.3)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.5, 0.2)
	mesh_instance.material_override = material
	
	parent.add_child(mesh_instance)

func _add_lava_flows(parent: Node3D):
	"""添加熔岩流"""
	var mesh_instance = MeshInstance3D.new()
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(0.6, 0.6)
	mesh_instance.mesh = quad_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.6, 0.2, 0.1)
	material.emission = Color(0.3, 0.1, 0.0)
	material.emission_energy = 0.4
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = material
	
	parent.add_child(mesh_instance)

func _add_default_decoration(parent: Node3D):
	"""添加默认装饰"""
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.1, 0.1, 0.1)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.5, 0.5)
	mesh_instance.material_override = material
	
	parent.add_child(mesh_instance)

func _create_particle_effect(effect_type: String, position: Vector3) -> Node3D:
	"""创建粒子效果"""
	var particle_node = Node3D.new()
	particle_node.name = "ParticleEffect_" + effect_type
	particle_node.position = position
	
	# 这里可以添加实际的粒子系统
	# 目前使用简单的发光效果代替
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.1
	mesh_instance.mesh = sphere_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 1.0, 1.0, 0.3)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission = Color(1.0, 1.0, 1.0)
	material.emission_energy = 0.5
	mesh_instance.material_override = material
	
	particle_node.add_child(mesh_instance)
	
	return particle_node

func _get_tile_key(position: Vector3) -> String:
	"""获取地块位置键值"""
	return "%d_%d_%d" % [int(position.x), int(position.y), int(position.z)]

func remove_tile_decorations(position: Vector3) -> void:
	"""移除地块装饰"""
	var tile_key = _get_tile_key(position)
	if decoration_instances.has(tile_key):
		for decoration_node in decoration_instances[tile_key]:
			if decoration_node and is_instance_valid(decoration_node):
				decoration_node.queue_free()
		decoration_instances.erase(tile_key)

func clear_all_decorations() -> void:
	"""清除所有装饰"""
	for tile_key in decoration_instances.keys():
		for decoration_node in decoration_instances[tile_key]:
			if decoration_node and is_instance_valid(decoration_node):
				decoration_node.queue_free()
	decoration_instances.clear()
	LogManager.info("EcosystemTileRenderer - 所有装饰已清除")

func set_render_config(config_name: String, value) -> void:
	"""设置渲染配置"""
	if render_config.has(config_name):
		render_config[config_name] = value
		LogManager.info("EcosystemTileRenderer - 配置更新: %s = %s" % [config_name, str(value)])
	else:
		LogManager.warning("EcosystemTileRenderer - 未知配置项: %s" % config_name)
