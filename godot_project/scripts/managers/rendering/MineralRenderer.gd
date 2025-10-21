extends Node
class_name MineralRenderer

## ⛏️ 矿物资源渲染器
## 专门负责渲染各种矿物资源，包括金矿、铁矿、宝石等

# 矿物类型枚举
enum MineralType {
	GOLD_ORE, # 金矿
	IRON_ORE, # 铁矿
	STONE, # 石头
	GEM, # 宝石
	RARE_MINERAL, # 稀有矿物
	MAGIC_CRYSTAL, # 魔法水晶
	DEMON_CORE, # 恶魔核心
	SOUL_STONE, # 灵魂石
	CURSED_GEM, # 诅咒宝石
	PREHISTORIC_MINERAL, # 史前矿物
	FOSSIL, # 化石
	AMBER, # 琥珀
	PRIMITIVE_CRYSTAL, # 原始水晶
	DRAGON_BLOOD_STONE, # 龙血石
	ANCIENT_DRAGON_SCALE # 古龙鳞片
}

# 矿物渲染配置
var render_config = {
	"enabled": true,
	"max_minerals": 300,
	"lod_distance": 25.0,
	"batch_size": 30,
	"update_interval": 1.5,
	"enable_glow": true,
	"enable_particles": true,
	"glow_intensity": 0.3,
	"particle_density": 0.5,
	"enable_frustum_culling": true,
	"enable_occlusion_culling": false,
	"cull_distance": 80.0,
	"particle_distance": 40.0,
	"use_instancing": true,
	"max_instances_per_batch": 50
}

# 矿物数据
var mineral_instances: Dictionary = {} # {mineral_id: mineral_node}
var world_node: Node3D = null
var update_timer: Timer = null
var camera: Camera3D = null

# LOD系统
var lod_levels = {
	0: {"distance": 0.0, "scale": 1.0, "enable_particles": true, "enable_glow": true}, # 近距离
	1: {"distance": 12.0, "scale": 0.8, "enable_particles": true, "enable_glow": true}, # 中距离
	2: {"distance": 25.0, "scale": 0.6, "enable_particles": false, "enable_glow": true}, # 远距离
	3: {"distance": 40.0, "scale": 0.4, "enable_particles": false, "enable_glow": false} # 极远距离
}

# 实例化系统
var mineral_batches: Dictionary = {} # {mineral_type: MultiMeshInstance3D}

# 矿物模型映射
var mineral_models = {
	MineralType.GOLD_ORE: "res://assets/models/minerals/gold_ore.tscn",
	MineralType.IRON_ORE: "res://assets/models/minerals/iron_ore.tscn",
	MineralType.STONE: "res://assets/models/minerals/stone.tscn",
	MineralType.GEM: "res://assets/models/minerals/gem.tscn",
	MineralType.RARE_MINERAL: "res://assets/models/minerals/rare_mineral.tscn",
	MineralType.MAGIC_CRYSTAL: "res://assets/models/minerals/magic_crystal.tscn",
	MineralType.DEMON_CORE: "res://assets/models/minerals/demon_core.tscn",
	MineralType.SOUL_STONE: "res://assets/models/minerals/soul_stone.tscn",
	MineralType.CURSED_GEM: "res://assets/models/minerals/cursed_gem.tscn",
	MineralType.PREHISTORIC_MINERAL: "res://assets/models/minerals/prehistoric_mineral.tscn",
	MineralType.FOSSIL: "res://assets/models/minerals/fossil.tscn",
	MineralType.AMBER: "res://assets/models/minerals/amber.tscn",
	MineralType.PRIMITIVE_CRYSTAL: "res://assets/models/minerals/primitive_crystal.tscn",
	MineralType.DRAGON_BLOOD_STONE: "res://assets/models/minerals/dragon_blood_stone.tscn",
	MineralType.ANCIENT_DRAGON_SCALE: "res://assets/models/minerals/ancient_dragon_scale.tscn"
}

# 矿物颜色映射
var mineral_colors = {
	MineralType.GOLD_ORE: Color(1.0, 0.8, 0.0), # 金色
	MineralType.IRON_ORE: Color(0.6, 0.6, 0.6), # 铁灰色
	MineralType.STONE: Color(0.5, 0.5, 0.5), # 石灰色
	MineralType.GEM: Color(0.8, 0.2, 0.8), # 紫色
	MineralType.RARE_MINERAL: Color(0.2, 0.8, 1.0), # 蓝色
	MineralType.MAGIC_CRYSTAL: Color(0.0, 1.0, 1.0), # 青色
	MineralType.DEMON_CORE: Color(1.0, 0.2, 0.2), # 红色
	MineralType.SOUL_STONE: Color(0.8, 0.8, 1.0), # 淡紫色
	MineralType.CURSED_GEM: Color(0.4, 0.0, 0.4), # 深紫色
	MineralType.PREHISTORIC_MINERAL: Color(0.6, 0.4, 0.2), # 棕色
	MineralType.FOSSIL: Color(0.8, 0.6, 0.4), # 化石色
	MineralType.AMBER: Color(1.0, 0.6, 0.0), # 琥珀色
	MineralType.PRIMITIVE_CRYSTAL: Color(0.4, 0.8, 0.4), # 原始绿
	MineralType.DRAGON_BLOOD_STONE: Color(0.8, 0.0, 0.0), # 龙血色
	MineralType.ANCIENT_DRAGON_SCALE: Color(0.2, 0.2, 0.8) # 龙鳞色
}

# 矿物发光颜色映射
var mineral_glow_colors = {
	MineralType.GOLD_ORE: Color(1.0, 0.8, 0.0, 0.3),
	MineralType.IRON_ORE: Color(0.6, 0.6, 0.6, 0.1),
	MineralType.STONE: Color(0.5, 0.5, 0.5, 0.05),
	MineralType.GEM: Color(0.8, 0.2, 0.8, 0.4),
	MineralType.RARE_MINERAL: Color(0.2, 0.8, 1.0, 0.5),
	MineralType.MAGIC_CRYSTAL: Color(0.0, 1.0, 1.0, 0.6),
	MineralType.DEMON_CORE: Color(1.0, 0.2, 0.2, 0.7),
	MineralType.SOUL_STONE: Color(0.8, 0.8, 1.0, 0.4),
	MineralType.CURSED_GEM: Color(0.4, 0.0, 0.4, 0.8),
	MineralType.PREHISTORIC_MINERAL: Color(0.6, 0.4, 0.2, 0.2),
	MineralType.FOSSIL: Color(0.8, 0.6, 0.4, 0.1),
	MineralType.AMBER: Color(1.0, 0.6, 0.0, 0.3),
	MineralType.PRIMITIVE_CRYSTAL: Color(0.4, 0.8, 0.4, 0.4),
	MineralType.DRAGON_BLOOD_STONE: Color(0.8, 0.0, 0.0, 0.8),
	MineralType.ANCIENT_DRAGON_SCALE: Color(0.2, 0.2, 0.8, 0.5)
}

func _ready():
	"""初始化矿物渲染器"""
	_setup_timer()
	LogManager.info("MineralRenderer - 矿物渲染器初始化完成")

func _setup_timer():
	"""设置更新定时器"""
	update_timer = Timer.new()
	update_timer.wait_time = render_config.update_interval
	update_timer.timeout.connect(_update_minerals)
	update_timer.autostart = true
	add_child(update_timer)

func set_world_node(world: Node3D):
	"""设置世界节点引用"""
	world_node = world
	LogManager.info("MineralRenderer - 世界节点已设置")

func create_mineral(mineral_type: MineralType, position: Vector3, scale: float = 1.0) -> Node3D:
	"""创建矿物实例"""
	if not world_node:
		LogManager.error("MineralRenderer - 世界节点未设置")
		return null
	
	# 创建矿物节点
	var mineral_node = _create_mineral_node(mineral_type)
	if not mineral_node:
		return null
	
	# 设置位置和缩放
	mineral_node.position = position
	mineral_node.scale = Vector3(scale, scale, scale)
	
	# 添加到世界
	world_node.add_child(mineral_node)
	
	# 记录实例
	var mineral_id = _get_position_key(position)
	mineral_instances[mineral_id] = mineral_node
	
	LogManager.debug("MineralRenderer - 创建矿物: %s 在位置 %s" % [MineralType.keys()[mineral_type], str(position)])
	return mineral_node

func _create_mineral_node(mineral_type: MineralType) -> Node3D:
	"""创建矿物节点"""
	var mineral_node = Node3D.new()
	mineral_node.name = "Mineral_" + MineralType.keys()[mineral_type]
	
	# 创建基础几何体
	var mesh_instance = MeshInstance3D.new()
	var mesh = _create_mineral_mesh(mineral_type)
	mesh_instance.mesh = mesh
	
	# 创建材质
	var material = StandardMaterial3D.new()
	material.albedo_color = mineral_colors.get(mineral_type, Color.WHITE)
	material.metallic = 0.9
	material.roughness = 0.1
	material.emission = mineral_glow_colors.get(mineral_type, Color.BLACK) * render_config.glow_intensity
	mesh_instance.material_override = material
	
	mineral_node.add_child(mesh_instance)
	
	# 添加粒子效果（如果启用）
	if render_config.enable_particles:
		_add_mineral_particles(mineral_node, mineral_type)
	
	# 添加发光效果
	if render_config.enable_glow:
		_add_mineral_glow(mineral_node, mineral_type)
	
	return mineral_node

func _create_mineral_mesh(mineral_type: MineralType) -> Mesh:
	"""创建矿物网格"""
	var mesh = null
	
	match mineral_type:
		MineralType.GOLD_ORE:
			mesh = _create_gold_ore_mesh()
		MineralType.IRON_ORE:
			mesh = _create_iron_ore_mesh()
		MineralType.STONE:
			mesh = _create_stone_mesh()
		MineralType.GEM:
			mesh = _create_gem_mesh()
		MineralType.RARE_MINERAL:
			mesh = _create_rare_mineral_mesh()
		MineralType.MAGIC_CRYSTAL:
			mesh = _create_magic_crystal_mesh()
		MineralType.DEMON_CORE:
			mesh = _create_demon_core_mesh()
		MineralType.SOUL_STONE:
			mesh = _create_soul_stone_mesh()
		MineralType.CURSED_GEM:
			mesh = _create_cursed_gem_mesh()
		MineralType.PREHISTORIC_MINERAL:
			mesh = _create_prehistoric_mineral_mesh()
		MineralType.FOSSIL:
			mesh = _create_fossil_mesh()
		MineralType.AMBER:
			mesh = _create_amber_mesh()
		MineralType.PRIMITIVE_CRYSTAL:
			mesh = _create_primitive_crystal_mesh()
		MineralType.DRAGON_BLOOD_STONE:
			mesh = _create_dragon_blood_stone_mesh()
		MineralType.ANCIENT_DRAGON_SCALE:
			mesh = _create_ancient_dragon_scale_mesh()
		_:
			mesh = _create_default_mineral_mesh()
	
	return mesh

func _create_gold_ore_mesh() -> Mesh:
	"""创建金矿网格"""
	var gold_mesh = BoxMesh.new()
	gold_mesh.size = Vector3(0.8, 0.6, 0.8)
	return gold_mesh

func _create_iron_ore_mesh() -> Mesh:
	"""创建铁矿网格"""
	var iron_mesh = BoxMesh.new()
	iron_mesh.size = Vector3(0.7, 0.5, 0.7)
	return iron_mesh

func _create_stone_mesh() -> Mesh:
	"""创建石头网格"""
	var stone_mesh = BoxMesh.new()
	stone_mesh.size = Vector3(1.0, 0.8, 1.0)
	return stone_mesh

func _create_gem_mesh() -> Mesh:
	"""创建宝石网格"""
	var gem_mesh = SphereMesh.new()
	gem_mesh.radius = 0.3
	gem_mesh.height = 0.4
	return gem_mesh

func _create_rare_mineral_mesh() -> Mesh:
	"""创建稀有矿物网格"""
	var rare_mesh = BoxMesh.new()
	rare_mesh.size = Vector3(0.6, 0.4, 0.6)
	return rare_mesh

func _create_magic_crystal_mesh() -> Mesh:
	"""创建魔法水晶网格"""
	var crystal_mesh = BoxMesh.new()
	crystal_mesh.size = Vector3(0.4, 0.8, 0.4)
	return crystal_mesh

func _create_demon_core_mesh() -> Mesh:
	"""创建恶魔核心网格"""
	var core_mesh = SphereMesh.new()
	core_mesh.radius = 0.5
	core_mesh.height = 0.6
	return core_mesh

func _create_soul_stone_mesh() -> Mesh:
	"""创建灵魂石网格"""
	var soul_mesh = BoxMesh.new()
	soul_mesh.size = Vector3(0.5, 0.3, 0.5)
	return soul_mesh

func _create_cursed_gem_mesh() -> Mesh:
	"""创建诅咒宝石网格"""
	var cursed_mesh = SphereMesh.new()
	cursed_mesh.radius = 0.25
	cursed_mesh.height = 0.3
	return cursed_mesh

func _create_prehistoric_mineral_mesh() -> Mesh:
	"""创建史前矿物网格"""
	var prehistoric_mesh = BoxMesh.new()
	prehistoric_mesh.size = Vector3(0.9, 0.7, 0.9)
	return prehistoric_mesh

func _create_fossil_mesh() -> Mesh:
	"""创建化石网格"""
	var fossil_mesh = BoxMesh.new()
	fossil_mesh.size = Vector3(0.6, 0.2, 0.8)
	return fossil_mesh

func _create_amber_mesh() -> Mesh:
	"""创建琥珀网格"""
	var amber_mesh = SphereMesh.new()
	amber_mesh.radius = 0.35
	amber_mesh.height = 0.4
	return amber_mesh

func _create_primitive_crystal_mesh() -> Mesh:
	"""创建原始水晶网格"""
	var primitive_mesh = BoxMesh.new()
	primitive_mesh.size = Vector3(0.3, 0.6, 0.3)
	return primitive_mesh

func _create_dragon_blood_stone_mesh() -> Mesh:
	"""创建龙血石网格"""
	var dragon_mesh = SphereMesh.new()
	dragon_mesh.radius = 0.4
	dragon_mesh.height = 0.5
	return dragon_mesh

func _create_ancient_dragon_scale_mesh() -> Mesh:
	"""创建古龙鳞片网格"""
	var scale_mesh = BoxMesh.new()
	scale_mesh.size = Vector3(0.2, 0.1, 0.4)
	return scale_mesh

func _create_default_mineral_mesh() -> Mesh:
	"""创建默认矿物网格"""
	var default_mesh = BoxMesh.new()
	default_mesh.size = Vector3(0.5, 0.4, 0.5)
	return default_mesh

func _add_mineral_particles(mineral_node: Node3D, _mineral_type: MineralType):
	"""添加矿物粒子效果"""
	var particles = GPUParticles3D.new()
	mineral_node.add_child(particles)
	
	# 设置粒子属性
	particles.emitting = true
	particles.amount = int(50 * render_config.particle_density)
	particles.lifetime = 2.0
	particles.position = Vector3(0, 0.5, 0)
	
	# 设置粒子材质
	var particle_material = ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, 1, 0)
	particle_material.initial_velocity_min = 0.1
	particle_material.initial_velocity_max = 0.3
	particle_material.gravity = Vector3(0, -0.5, 0)
	particle_material.scale_min = 0.1
	particle_material.scale_max = 0.2
	
	particles.process_material = particle_material

func _add_mineral_glow(mineral_node: Node3D, mineral_type: MineralType):
	"""添加矿物发光效果"""
	var glow_node = Node3D.new()
	glow_node.name = "Glow"
	mineral_node.add_child(glow_node)
	
	# 创建发光几何体
	var glow_mesh = MeshInstance3D.new()
	var glow_sphere = SphereMesh.new()
	glow_sphere.radius = 1.2
	glow_mesh.mesh = glow_sphere
	
	# 创建发光材质
	var glow_material = StandardMaterial3D.new()
	glow_material.albedo_color = mineral_glow_colors.get(mineral_type, Color.WHITE)
	glow_material.emission = mineral_glow_colors.get(mineral_type, Color.WHITE) * render_config.glow_intensity
	glow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	glow_mesh.material_override = glow_material
	
	glow_node.add_child(glow_mesh)
	
	# 添加发光动画
	var animation_player = AnimationPlayer.new()
	glow_node.add_child(animation_player)
	
	var animation = Animation.new()
	animation.length = 3.0
	animation.loop_mode = Animation.LOOP_LINEAR
	
	var scale_track = animation.add_track(Animation.TYPE_SCALE_3D)
	animation.track_set_path(scale_track, NodePath("."))
	
	animation.track_insert_key(scale_track, 0.0, Vector3(1.0, 1.0, 1.0))
	animation.track_insert_key(scale_track, 1.5, Vector3(1.2, 1.2, 1.2))
	animation.track_insert_key(scale_track, 3.0, Vector3(1.0, 1.0, 1.0))
	
	animation_player.add_animation("glow_pulse", animation)
	animation_player.play("glow_pulse")

func _update_minerals():
	"""更新矿物渲染"""
	if not render_config.enabled or not world_node:
		return
	
	# 查找相机
	if not camera:
		_find_camera()
	
	if camera:
		# 更新LOD和可见性
		_update_mineral_lod()
		_update_mineral_visibility()

func _find_camera():
	"""查找场景中的相机"""
	var cameras = get_tree().get_nodes_in_group("camera")
	if cameras.size() > 0:
		camera = cameras[0]
		return
	
	# 如果没找到，尝试从主场景获取
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("get_camera"):
		camera = main_scene.get_camera()

func _update_mineral_lod():
	"""更新矿物LOD"""
	if not camera:
		return
	
	var camera_pos = camera.global_position
	
	for mineral_id in mineral_instances.keys():
		var mineral = mineral_instances[mineral_id]
		if not mineral or not is_instance_valid(mineral):
			continue
		
		var distance = camera_pos.distance_to(mineral.global_position)
		var lod_level = _get_lod_level(distance)
		var lod_config = lod_levels[lod_level]
		
		# 更新缩放
		mineral.scale = Vector3(lod_config.scale, lod_config.scale, lod_config.scale)
		
		# 更新粒子效果
		var particles = mineral.get_node_or_null("GPUParticles3D")
		if particles:
			if lod_config.enable_particles and distance <= render_config.particle_distance:
				particles.emitting = true
			else:
				particles.emitting = false
		
		# 更新发光效果
		var glow_node = mineral.get_node_or_null("Glow")
		if glow_node:
			glow_node.visible = lod_config.enable_glow

func _get_lod_level(distance: float) -> int:
	"""获取LOD级别"""
	for i in range(lod_levels.size() - 1, -1, -1):
		if distance >= lod_levels[i].distance:
			return i
	return 0

func _update_mineral_visibility():
	"""更新矿物可见性"""
	if not camera or not render_config.enable_frustum_culling:
		return
	
	var camera_pos = camera.global_position
	
	for mineral_id in mineral_instances.keys():
		var mineral = mineral_instances[mineral_id]
		if not mineral or not is_instance_valid(mineral):
			continue
		
		var distance = camera_pos.distance_to(mineral.global_position)
		
		# 距离剔除
		if distance > render_config.cull_distance:
			mineral.visible = false
		else:
			mineral.visible = true

func _get_position_key(position: Vector3) -> String:
	"""获取位置键值"""
	return "%d_%d_%d" % [int(position.x), int(position.y), int(position.z)]

func remove_mineral(position: Vector3):
	"""移除矿物"""
	var mineral_id = _get_position_key(position)
	if mineral_id in mineral_instances:
		var mineral = mineral_instances[mineral_id]
		if mineral and is_instance_valid(mineral):
			mineral.queue_free()
		mineral_instances.erase(mineral_id)

func clear_all_minerals():
	"""清除所有矿物"""
	for mineral in mineral_instances.values():
		if mineral and is_instance_valid(mineral):
			mineral.queue_free()
	mineral_instances.clear()

func set_render_config(new_config: Dictionary):
	"""设置渲染配置"""
	render_config.merge(new_config, true)
	
	if update_timer:
		update_timer.wait_time = render_config.update_interval
	
	LogManager.info("MineralRenderer - 渲染配置已更新")

func get_render_status() -> Dictionary:
	"""获取渲染状态"""
	return {
		"enabled": render_config.enabled,
		"mineral_count": mineral_instances.size(),
		"max_minerals": render_config.max_minerals,
		"update_interval": render_config.update_interval
	}

# ============================================================================
# 详细矿物生成函数（改进的程序化生成）
# ============================================================================

func _create_detailed_gold_ore(parent_node: Node3D):
	"""创建详细的金矿模型"""
	# 主矿体
	var main_mesh = MeshInstance3D.new()
	main_mesh.mesh = _create_irregular_ore_mesh(0.4, 0.6, 0.5)
	var main_material = StandardMaterial3D.new()
	main_material.albedo_color = Color(1.0, 0.8, 0.0) # 金色
	main_material.metallic = 0.9
	main_material.roughness = 0.1
	main_material.emission = Color(0.2, 0.1, 0.0)
	main_material.emission_energy = 0.3
	main_mesh.material_override = main_material
	parent_node.add_child(main_mesh)
	
	# 金块细节
	for i in range(3):
		var detail_mesh = MeshInstance3D.new()
		detail_mesh.mesh = _create_small_cube_mesh(0.1)
		var detail_material = StandardMaterial3D.new()
		detail_material.albedo_color = Color(1.0, 0.9, 0.2)
		detail_material.metallic = 0.95
		detail_material.roughness = 0.05
		detail_mesh.material_override = detail_material
		detail_mesh.position = Vector3(randf_range(-0.2, 0.2), randf_range(-0.2, 0.2), randf_range(-0.2, 0.2))
		parent_node.add_child(detail_mesh)

func _create_detailed_iron_ore(parent_node: Node3D):
	"""创建详细的铁矿模型"""
	var iron_mesh = MeshInstance3D.new()
	iron_mesh.mesh = _create_irregular_ore_mesh(0.5, 0.7, 0.6)
	var iron_material = StandardMaterial3D.new()
	iron_material.albedo_color = Color(0.6, 0.6, 0.6) # 铁灰色
	iron_material.metallic = 0.8
	iron_material.roughness = 0.3
	iron_mesh.material_override = iron_material
	parent_node.add_child(iron_mesh)

func _create_detailed_gem(parent_node: Node3D):
	"""创建详细的宝石模型"""
	var gem_mesh = MeshInstance3D.new()
	gem_mesh.mesh = _create_crystal_mesh(0.3, 0.8)
	var gem_material = StandardMaterial3D.new()
	gem_material.albedo_color = Color(0.8, 0.2, 0.8) # 紫色
	gem_material.metallic = 0.0
	gem_material.roughness = 0.0
	gem_material.emission = Color(0.3, 0.1, 0.3)
	gem_material.emission_energy = 0.5
	gem_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gem_material.alpha = 0.8
	gem_mesh.material_override = gem_material
	parent_node.add_child(gem_mesh)

func _create_detailed_magic_crystal(parent_node: Node3D):
	"""创建详细的魔法水晶模型"""
	# 主水晶
	var main_crystal = MeshInstance3D.new()
	main_crystal.mesh = _create_crystal_mesh(0.4, 1.0)
	var crystal_material = StandardMaterial3D.new()
	crystal_material.albedo_color = Color(0.0, 1.0, 1.0) # 青色
	crystal_material.metallic = 0.0
	crystal_material.roughness = 0.0
	crystal_material.emission = Color(0.0, 0.5, 0.5)
	crystal_material.emission_energy = 0.8
	crystal_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	crystal_material.alpha = 0.9
	main_crystal.material_override = crystal_material
	parent_node.add_child(main_crystal)
	
	# 能量环
	for i in range(3):
		var ring_mesh = MeshInstance3D.new()
		ring_mesh.mesh = _create_torus_mesh(0.3 + i * 0.1, 0.05)
		var ring_material = StandardMaterial3D.new()
		ring_material.albedo_color = Color(0.0, 0.8, 0.8)
		ring_material.emission = Color(0.0, 0.3, 0.3)
		ring_material.emission_energy = 0.6
		ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring_material.alpha = 0.7
		ring_mesh.material_override = ring_material
		ring_mesh.position = Vector3(0, 0, 0)
		ring_mesh.rotation = Vector3(PI / 2, i * PI / 3, 0)
		parent_node.add_child(ring_mesh)

func _create_detailed_demon_core(parent_node: Node3D):
	"""创建详细的恶魔核心模型"""
	var core_mesh = MeshInstance3D.new()
	core_mesh.mesh = _create_sphere_mesh(0.5)
	var core_material = StandardMaterial3D.new()
	core_material.albedo_color = Color(1.0, 0.2, 0.2) # 红色
	core_material.metallic = 0.3
	core_material.roughness = 0.4
	core_material.emission = Color(0.5, 0.1, 0.1)
	core_material.emission_energy = 0.7
	core_mesh.material_override = core_material
	parent_node.add_child(core_mesh)
	
	# 邪恶能量
	var energy_mesh = MeshInstance3D.new()
	energy_mesh.mesh = _create_sphere_mesh(0.7)
	var energy_material = StandardMaterial3D.new()
	energy_material.albedo_color = Color(0.8, 0.0, 0.0)
	energy_material.emission = Color(0.8, 0.0, 0.0)
	energy_material.emission_energy = 0.4
	energy_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	energy_material.alpha = 0.3
	energy_mesh.material_override = energy_material
	parent_node.add_child(energy_mesh)

func _create_detailed_soul_stone(parent_node: Node3D):
	"""创建详细的灵魂石模型"""
	var stone_mesh = MeshInstance3D.new()
	stone_mesh.mesh = _create_irregular_ore_mesh(0.4, 0.5, 0.4)
	var stone_material = StandardMaterial3D.new()
	stone_material.albedo_color = Color(0.8, 0.8, 1.0) # 淡紫色
	stone_material.metallic = 0.2
	stone_material.roughness = 0.6
	stone_material.emission = Color(0.2, 0.2, 0.4)
	stone_material.emission_energy = 0.4
	stone_mesh.material_override = stone_material
	parent_node.add_child(stone_mesh)

func _create_simple_mineral(parent_node: Node3D, mineral_type: MineralType):
	"""创建简单的矿物模型（通用后备）"""
	var mineral_mesh = MeshInstance3D.new()
	mineral_mesh.mesh = _create_box_mesh(0.5, 0.4, 0.5)
	var mineral_material = StandardMaterial3D.new()
	mineral_material.albedo_color = mineral_colors.get(mineral_type, Color.GRAY)
	mineral_material.metallic = 0.8
	mineral_material.roughness = 0.2
	mineral_material.emission = mineral_glow_colors.get(mineral_type, Color.BLACK)
	mineral_material.emission_energy = render_config.glow_intensity
	mineral_mesh.material_override = mineral_material
	parent_node.add_child(mineral_mesh)

# ============================================================================
# 辅助几何体生成函数
# ============================================================================

func _create_irregular_ore_mesh(width: float, height: float, depth: float) -> BoxMesh:
	"""创建不规则矿石网格"""
	var mesh = BoxMesh.new()
	mesh.size = Vector3(width, height, depth)
	return mesh

func _create_crystal_mesh(radius: float, height: float) -> CylinderMesh:
	"""创建水晶网格"""
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.1
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	return mesh

func _create_sphere_mesh(radius: float) -> SphereMesh:
	"""创建球体网格"""
	var mesh = SphereMesh.new()
	mesh.radius = radius
	mesh.radial_segments = 12
	mesh.rings = 6
	return mesh

func _create_box_mesh(width: float, height: float, depth: float) -> BoxMesh:
	"""创建立方体网格"""
	var mesh = BoxMesh.new()
	mesh.size = Vector3(width, height, depth)
	return mesh

func _create_small_cube_mesh(size: float) -> BoxMesh:
	"""创建小立方体网格"""
	var mesh = BoxMesh.new()
	mesh.size = Vector3(size, size, size)
	return mesh

func _create_torus_mesh(radius: float, thickness: float) -> TorusMesh:
	"""创建环形网格"""
	var mesh = TorusMesh.new()
	mesh.inner_radius = radius - thickness
	mesh.outer_radius = radius + thickness
	mesh.radial_segments = 16
	mesh.rings = 8
	return mesh