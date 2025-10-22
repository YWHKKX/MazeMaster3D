extends Node
class_name PlantRenderer

## 🌿 植物渲染器
## 专门负责渲染各种植物资源，包括树木、草药、蘑菇等

# 植物类型枚举
enum PlantType {
	TREE, # 树木
	BUSH, # 灌木
	HERB, # 草药
	MUSHROOM, # 蘑菇
	FLOWER, # 花朵
	GRASS, # 草地
	AQUATIC_PLANT, # 水生植物
	CROP, # 作物
	CORRUPTED_PLANT # 腐化植物
}

# 植物渲染配置
var render_config = {
	"enabled": true,
	"max_plants": 500,
	"lod_distance": 30.0,
	"batch_size": 50,
	"update_interval": 2.0,
	"enable_animations": true,
	"enable_wind_effect": true,
	"wind_strength": 0.5,
	"enable_frustum_culling": true,
	"enable_occlusion_culling": false,
	"cull_distance": 100.0,
	"animation_distance": 50.0,
	"use_instancing": true,
	"max_instances_per_batch": 100
}

# 植物数据
var plant_instances: Dictionary = {} # {plant_id: plant_node}
var world_node: Node3D = null
var update_timer: Timer = null
var camera: Camera3D = null

# LOD系统
var lod_levels = {
	0: {"distance": 0.0, "scale": 1.0, "enable_animation": true}, # 近距离
	1: {"distance": 15.0, "scale": 0.8, "enable_animation": true}, # 中距离
	2: {"distance": 30.0, "scale": 0.6, "enable_animation": false}, # 远距离
	3: {"distance": 50.0, "scale": 0.4, "enable_animation": false} # 极远距离
}

# 实例化系统
var plant_batches: Dictionary = {} # {plant_type: MultiMeshInstance3D}
var plant_meshes: Dictionary = {} # {plant_type: ArrayMesh}

# 植物模型映射
var plant_models = {
	PlantType.TREE: "res://scenes/models/plants/tree.tscn",
	PlantType.BUSH: "res://scenes/models/plants/bush.tscn",
	PlantType.HERB: "res://scenes/models/plants/herb.tscn",
	PlantType.MUSHROOM: "res://scenes/models/plants/mushroom.tscn",
	PlantType.FLOWER: "res://scenes/models/plants/flower.tscn",
	PlantType.GRASS: "res://scenes/models/plants/grass.tscn",
	PlantType.AQUATIC_PLANT: "res://scenes/models/plants/aquatic_plant.tscn",
	PlantType.CROP: "res://scenes/models/plants/crop.tscn",
	PlantType.CORRUPTED_PLANT: "res://scenes/models/plants/corrupted_plant.tscn"
}

# 植物颜色映射
var plant_colors = {
	PlantType.TREE: Color(0.2, 0.6, 0.2), # 深绿色
	PlantType.BUSH: Color(0.3, 0.7, 0.3), # 绿色
	PlantType.HERB: Color(0.4, 0.8, 0.4), # 浅绿色
	PlantType.MUSHROOM: Color(0.8, 0.6, 0.4), # 棕色
	PlantType.FLOWER: Color(1.0, 0.4, 0.8), # 粉红色
	PlantType.GRASS: Color(0.5, 0.8, 0.3), # 草绿色
	PlantType.AQUATIC_PLANT: Color(0.2, 0.8, 0.6), # 青绿色
	PlantType.CROP: Color(0.6, 0.8, 0.2), # 黄绿色
	PlantType.CORRUPTED_PLANT: Color(0.6, 0.2, 0.2) # 暗红色
}

func _ready():
	"""初始化植物渲染器"""
	_setup_timer()
	LogManager.info("PlantRenderer - 植物渲染器初始化完成")

func _setup_timer():
	"""设置更新定时器"""
	update_timer = Timer.new()
	update_timer.wait_time = render_config.update_interval
	update_timer.timeout.connect(_update_plants)
	update_timer.autostart = true
	add_child(update_timer)

func set_world_node(world: Node3D):
	"""设置世界节点引用"""
	world_node = world
	LogManager.info("PlantRenderer - 世界节点已设置")

func create_plant(plant_type: PlantType, position: Vector3, scale: float = 1.0) -> Node3D:
	"""创建植物实例"""
	if not world_node:
		LogManager.error("PlantRenderer - 世界节点未设置")
		return null
	
	# 检查实例数量限制
	if plant_instances.size() >= render_config.max_plants:
		LogManager.warning("PlantRenderer - 达到最大植物数量限制")
		return null
	
	var plant_node = null
	
	# 使用实例化渲染（如果启用）
	if render_config.use_instancing:
		plant_node = _create_instanced_plant(plant_type, position, scale)
	else:
		plant_node = _create_individual_plant(plant_type, position, scale)
	
	if plant_node:
		# 记录实例
		var plant_id = _get_position_key(position)
		plant_instances[plant_id] = plant_node
		
		LogManager.info("✅ PlantRenderer - 创建植物: %s 在位置 %s" % [PlantType.keys()[plant_type], str(position)])
	else:
		LogManager.warning("❌ PlantRenderer - 植物创建失败: %s 在位置 %s" % [PlantType.keys()[plant_type], str(position)])
	
	return plant_node

func _create_instanced_plant(plant_type: PlantType, position: Vector3, scale: float) -> Node3D:
	"""创建实例化植物"""
	# 获取或创建植物批次
	if not plant_type in plant_batches:
		_create_plant_batch(plant_type)
	
	var batch = plant_batches[plant_type]
	if not batch:
		return null
	
	# 添加实例到批次
	var transform = Transform3D()
	transform.origin = position
	transform.basis = transform.basis.scaled(Vector3(scale, scale, scale))
	
	var instance_count = batch.multimesh.instance_count
	batch.multimesh.instance_count = instance_count + 1
	batch.multimesh.set_instance_transform(instance_count, transform)
	
	# 创建虚拟节点用于管理
	var virtual_node = Node3D.new()
	virtual_node.name = "PlantInstance_" + PlantType.keys()[plant_type]
	virtual_node.position = position
	virtual_node.scale = Vector3(scale, scale, scale)
	
	return virtual_node

func _create_individual_plant(plant_type: PlantType, position: Vector3, scale: float) -> Node3D:
	"""创建独立植物节点"""
	var plant_node = _create_plant_node(plant_type)
	if not plant_node:
		return null
	
	# 设置位置和缩放
	plant_node.position = position
	plant_node.scale = Vector3(scale, scale, scale)
	
	# 添加到世界
	world_node.add_child(plant_node)
	
	return plant_node

func _create_plant_batch(plant_type: PlantType):
	"""创建植物批次"""
	var batch = MultiMeshInstance3D.new()
	batch.name = "PlantBatch_" + PlantType.keys()[plant_type]
	
	# 创建MultiMesh
	var multimesh = MultiMesh.new()
	multimesh.mesh = _create_plant_mesh(plant_type)
	multimesh.instance_count = 0
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	
	batch.multimesh = multimesh
	
	# 创建材质
	var material = StandardMaterial3D.new()
	material.albedo_color = plant_colors.get(plant_type, Color.GREEN)
	material.metallic = 0.0
	material.roughness = 0.8
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	batch.material_override = material
	
	# 添加到世界
	world_node.add_child(batch)
	
	# 记录批次
	plant_batches[plant_type] = batch

func _create_plant_node(plant_type: PlantType) -> Node3D:
	"""创建植物节点"""
	# 尝试加载场景文件
	var scene_path = plant_models.get(plant_type, "")
	if scene_path != "":
		var plant_scene = load(scene_path)
		if plant_scene:
			var plant_node = plant_scene.instantiate()
			plant_node.name = "Plant_" + PlantType.keys()[plant_type]
			
			# 应用植物颜色到所有MeshInstance3D子节点
			_apply_plant_colors(plant_node, plant_type)
			
			# 🌿 添加碰撞检测（根据植物类型决定是否阻挡）
			_add_plant_collision(plant_node, plant_type)
			
			# 添加动画（如果启用）
			if render_config.enable_animations:
				_add_plant_animation(plant_node, plant_type)
			
			return plant_node
	
	# 如果场景文件加载失败，使用程序化网格作为后备
	LogManager.warning("PlantRenderer - 无法加载植物场景: %s，使用程序化网格" % scene_path)
	return _create_procedural_plant_node(plant_type)

func _apply_plant_colors(plant_node: Node3D, plant_type: PlantType) -> void:
	"""为植物节点应用颜色"""
	var plant_color = plant_colors.get(plant_type, Color.GREEN)
	
	# 递归查找所有MeshInstance3D节点并应用颜色
	_apply_color_to_mesh_instances(plant_node, plant_color)

func _apply_color_to_mesh_instances(node: Node3D, color: Color) -> void:
	"""递归为MeshInstance3D节点应用颜色"""
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		var material = StandardMaterial3D.new()
		material.albedo_color = color
		material.metallic = 0.0
		material.roughness = 0.8
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		mesh_instance.material_override = material
	
	# 递归处理子节点
	for child in node.get_children():
		if child is Node3D:
			_apply_color_to_mesh_instances(child, color)

func _create_procedural_plant_node(plant_type: PlantType) -> Node3D:
	"""创建程序化植物节点（改进的后备方案）"""
	var plant_node = Node3D.new()
	plant_node.name = "Plant_" + PlantType.keys()[plant_type]
	
	# 🎨 根据植物类型创建更详细的几何体
	match plant_type:
		PlantType.TREE:
			_create_detailed_tree(plant_node)
		PlantType.BUSH:
			_create_detailed_bush(plant_node)
		PlantType.HERB:
			_create_detailed_herb(plant_node)
		PlantType.MUSHROOM:
			_create_detailed_mushroom(plant_node)
		PlantType.CROP:
			_create_detailed_crop(plant_node)
		PlantType.AQUATIC_PLANT:
			_create_detailed_aquatic_plant(plant_node)
		PlantType.CORRUPTED_PLANT:
			_create_detailed_corrupted_plant(plant_node)
		PlantType.FLOWER:
			_create_detailed_flower(plant_node)
		PlantType.GRASS:
			_create_detailed_grass(plant_node)
		_:
			_create_simple_plant(plant_node, plant_type)
	
	# 🌿 添加碰撞检测（根据植物类型决定是否阻挡）
	_add_plant_collision(plant_node, plant_type)
	
	# 添加动画（如果启用）
	if render_config.enable_animations:
		_add_plant_animation(plant_node, plant_type)
	
	return plant_node

func _add_plant_collision(plant_node: Node3D, plant_type: PlantType) -> void:
	"""添加植物碰撞检测"""
	# 根据植物类型决定碰撞行为
	var collision_config = _get_plant_collision_config(plant_type)
	
	if collision_config.has_collision:
		# 创建静态碰撞体
		var static_body = StaticBody3D.new()
		static_body.name = "PlantCollision"
		
		# 创建碰撞形状
		var collision_shape = CollisionShape3D.new()
		var shape = collision_config.shape
		collision_shape.shape = shape
		
		static_body.add_child(collision_shape)
		plant_node.add_child(static_body)
		
		# 设置碰撞层
		static_body.collision_layer = collision_config.collision_layer
		static_body.collision_mask = collision_config.collision_mask
		
		# 添加到植物组
		static_body.add_to_group("plants")
		static_body.set_meta("plant_type", plant_type)

func _get_plant_collision_config(_plant_type: PlantType) -> Dictionary:
	"""获取植物碰撞配置"""
	# 🌿 所有植物都不阻挡移动，取消碰撞体积
	return {
		"has_collision": false,
		"shape": null,
		"collision_layer": 0,
		"collision_mask": 0
	}

func _create_plant_mesh(plant_type: PlantType) -> Mesh:
	"""创建植物网格"""
	var mesh = null
	
	match plant_type:
		PlantType.TREE:
			mesh = _create_tree_mesh()
		PlantType.BUSH:
			mesh = _create_bush_mesh()
		PlantType.HERB:
			mesh = _create_herb_mesh()
		PlantType.MUSHROOM:
			mesh = _create_mushroom_mesh()
		PlantType.FLOWER:
			mesh = _create_flower_mesh()
		PlantType.GRASS:
			mesh = _create_grass_mesh()
		PlantType.AQUATIC_PLANT:
			mesh = _create_aquatic_plant_mesh()
		PlantType.CROP:
			mesh = _create_crop_mesh()
		PlantType.CORRUPTED_PLANT:
			mesh = _create_corrupted_plant_mesh()
		_:
			mesh = _create_default_plant_mesh()
	
	return mesh

func _create_tree_mesh() -> Mesh:
	"""创建树木网格"""
	var tree_mesh = BoxMesh.new()
	tree_mesh.size = Vector3(0.5, 2.0, 0.5)
	return tree_mesh

func _create_bush_mesh() -> Mesh:
	"""创建灌木网格"""
	var bush_mesh = SphereMesh.new()
	bush_mesh.radius = 0.8
	bush_mesh.height = 1.2
	return bush_mesh

func _create_herb_mesh() -> Mesh:
	"""创建草药网格"""
	var herb_mesh = CylinderMesh.new()
	herb_mesh.top_radius = 0.1
	herb_mesh.bottom_radius = 0.1
	herb_mesh.height = 0.3
	return herb_mesh

func _create_mushroom_mesh() -> Mesh:
	"""创建蘑菇网格"""
	var mushroom_mesh = CapsuleMesh.new()
	mushroom_mesh.radius = 0.2
	mushroom_mesh.height = 0.4
	return mushroom_mesh

func _create_flower_mesh() -> Mesh:
	"""创建花朵网格"""
	var flower_mesh = SphereMesh.new()
	flower_mesh.radius = 0.15
	flower_mesh.height = 0.3
	return flower_mesh

func _create_grass_mesh() -> Mesh:
	"""创建草地网格"""
	var grass_mesh = QuadMesh.new()
	grass_mesh.size = Vector2(0.2, 0.3)
	return grass_mesh

func _create_aquatic_plant_mesh() -> Mesh:
	"""创建水生植物网格"""
	var aquatic_mesh = CylinderMesh.new()
	aquatic_mesh.top_radius = 0.05
	aquatic_mesh.bottom_radius = 0.1
	aquatic_mesh.height = 0.6
	return aquatic_mesh

func _create_crop_mesh() -> Mesh:
	"""创建作物网格"""
	var crop_mesh = BoxMesh.new()
	crop_mesh.size = Vector3(0.3, 0.8, 0.3)
	return crop_mesh

func _create_corrupted_plant_mesh() -> Mesh:
	"""创建腐化植物网格"""
	var corrupted_mesh = SphereMesh.new()
	corrupted_mesh.radius = 0.4
	corrupted_mesh.height = 0.8
	return corrupted_mesh

func _create_default_plant_mesh() -> Mesh:
	"""创建默认植物网格"""
	var default_mesh = CylinderMesh.new()
	default_mesh.top_radius = 0.1
	default_mesh.bottom_radius = 0.1
	default_mesh.height = 0.5
	return default_mesh

func _add_plant_animation(plant_node: Node3D, _plant_type: PlantType):
	"""添加植物动画"""
	var animation_player = AnimationPlayer.new()
	plant_node.add_child(animation_player)
	
	# 创建简单的摇摆动画
	var animation = Animation.new()
	animation.length = 2.0
	animation.loop_mode = Animation.LOOP_LINEAR
	
	# 添加旋转轨道
	var rotation_track = animation.add_track(Animation.TYPE_ROTATION_3D)
	animation.track_set_path(rotation_track, NodePath("."))
	
	# 设置关键帧
	var rotation_amount = 0.1 if render_config.enable_wind_effect else 0.0
	
	animation.track_insert_key(rotation_track, 0.0, Vector3(0, 0, rotation_amount))
	animation.track_insert_key(rotation_track, 1.0, Vector3(0, 0, -rotation_amount))
	animation.track_insert_key(rotation_track, 2.0, Vector3(0, 0, rotation_amount))
	
	# 添加动画到播放器
	animation_player.add_animation("sway", animation)
	animation_player.play("sway")

func _update_plants():
	"""更新植物渲染"""
	if not render_config.enabled or not world_node:
		return
	
	# 查找相机
	if not camera:
		_find_camera()
	
	if camera:
		# 更新LOD和可见性
		_update_plant_lod()
		_update_plant_visibility()

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

func _update_plant_lod():
	"""更新植物LOD"""
	if not camera:
		return
	
	var camera_pos = camera.global_position
	
	for plant_id in plant_instances.keys():
		var plant = plant_instances[plant_id]
		if not plant or not is_instance_valid(plant):
			continue
		
		var distance = camera_pos.distance_to(plant.global_position)
		var lod_level = _get_lod_level(distance)
		var lod_config = lod_levels[lod_level]
		
		# 更新缩放
		plant.scale = Vector3(lod_config.scale, lod_config.scale, lod_config.scale)
		
		# 更新动画状态
		var animation_player = plant.get_node_or_null("AnimationPlayer")
		if animation_player:
			if lod_config.enable_animation and distance <= render_config.animation_distance:
				if not animation_player.is_playing():
					animation_player.play("sway")
			else:
				if animation_player.is_playing():
					animation_player.stop()

func _get_lod_level(distance: float) -> int:
	"""获取LOD级别"""
	for i in range(lod_levels.size() - 1, -1, -1):
		if distance >= lod_levels[i].distance:
			return i
	return 0

func _update_plant_visibility():
	"""更新植物可见性"""
	if not camera or not render_config.enable_frustum_culling:
		return
	
	var camera_pos = camera.global_position
	
	for plant_id in plant_instances.keys():
		var plant = plant_instances[plant_id]
		if not plant or not is_instance_valid(plant):
			continue
		
		var distance = camera_pos.distance_to(plant.global_position)
		
		# 距离剔除
		if distance > render_config.cull_distance:
			plant.visible = false
		else:
			plant.visible = true

func _get_position_key(position: Vector3) -> String:
	"""获取位置键值"""
	return "%d_%d_%d" % [int(position.x), int(position.y), int(position.z)]

func remove_plant(position: Vector3):
	"""移除植物"""
	var plant_id = _get_position_key(position)
	if plant_id in plant_instances:
		var plant = plant_instances[plant_id]
		if plant and is_instance_valid(plant):
			plant.queue_free()
		plant_instances.erase(plant_id)

func clear_all_plants():
	"""清除所有植物"""
	for plant in plant_instances.values():
		if plant and is_instance_valid(plant):
			plant.queue_free()
	plant_instances.clear()

func set_render_config(new_config: Dictionary):
	"""设置渲染配置"""
	render_config.merge(new_config, true)
	
	if update_timer:
		update_timer.wait_time = render_config.update_interval
	
	LogManager.info("PlantRenderer - 渲染配置已更新")

func get_render_status() -> Dictionary:
	"""获取渲染状态"""
	return {
		"enabled": render_config.enabled,
		"plant_count": plant_instances.size(),
		"max_plants": render_config.max_plants,
		"update_interval": render_config.update_interval
	}

# ============================================================================
# 详细植物生成函数（改进的程序化生成）
# ============================================================================

func _create_detailed_tree(parent_node: Node3D):
	"""创建详细的树木模型"""
	# 树干
	var trunk_mesh = MeshInstance3D.new()
	trunk_mesh.mesh = _create_cylinder_mesh(0.2, 1.5, 8)
	var trunk_material = StandardMaterial3D.new()
	trunk_material.albedo_color = Color(0.4, 0.2, 0.1) # 棕色
	trunk_material.roughness = 0.9
	trunk_mesh.material_override = trunk_material
	trunk_mesh.position = Vector3(0, 0.75, 0)
	parent_node.add_child(trunk_mesh)
	
	# 树叶（多个球体组合）
	for i in range(3):
		var leaf_mesh = MeshInstance3D.new()
		leaf_mesh.mesh = _create_sphere_mesh(0.8 - i * 0.2, 8)
		var leaf_material = StandardMaterial3D.new()
		leaf_material.albedo_color = Color(0.2, 0.6, 0.2) # 绿色
		leaf_material.roughness = 0.8
		leaf_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		leaf_material.alpha = 0.8
		leaf_mesh.material_override = leaf_material
		leaf_mesh.position = Vector3(0, 1.2 + i * 0.3, 0)
		parent_node.add_child(leaf_mesh)

func _create_detailed_bush(parent_node: Node3D):
	"""创建详细的灌木模型"""
	var bush_mesh = MeshInstance3D.new()
	bush_mesh.mesh = _create_sphere_mesh(0.6, 8)
	var bush_material = StandardMaterial3D.new()
	bush_material.albedo_color = Color(0.1, 0.5, 0.1) # 深绿色
	bush_material.roughness = 0.8
	bush_mesh.material_override = bush_material
	bush_mesh.position = Vector3(0, 0.3, 0)
	parent_node.add_child(bush_mesh)

func _create_detailed_herb(parent_node: Node3D):
	"""创建详细的草药模型"""
	# 主茎
	var stem_mesh = MeshInstance3D.new()
	stem_mesh.mesh = _create_cylinder_mesh(0.05, 0.3, 6)
	var stem_material = StandardMaterial3D.new()
	stem_material.albedo_color = Color(0.3, 0.4, 0.2) # 草绿色
	stem_mesh.material_override = stem_material
	stem_mesh.position = Vector3(0, 0.15, 0)
	parent_node.add_child(stem_mesh)
	
	# 叶片（小平面）
	for i in range(4):
		var leaf_mesh = MeshInstance3D.new()
		leaf_mesh.mesh = _create_plane_mesh(0.2, 0.1)
		var leaf_material = StandardMaterial3D.new()
		leaf_material.albedo_color = Color(0.2, 0.6, 0.2)
		leaf_material.roughness = 0.7
		leaf_mesh.material_override = leaf_material
		leaf_mesh.position = Vector3(0, 0.2, 0)
		leaf_mesh.rotation = Vector3(0, i * PI / 2, 0)
		parent_node.add_child(leaf_mesh)

func _create_detailed_mushroom(parent_node: Node3D):
	"""创建详细的蘑菇模型"""
	# 菌柄
	var stem_mesh = MeshInstance3D.new()
	stem_mesh.mesh = _create_cylinder_mesh(0.1, 0.4, 6)
	var stem_material = StandardMaterial3D.new()
	stem_material.albedo_color = Color(0.8, 0.7, 0.6) # 米色
	stem_mesh.material_override = stem_material
	stem_mesh.position = Vector3(0, 0.2, 0)
	parent_node.add_child(stem_mesh)
	
	# 菌盖
	var cap_mesh = MeshInstance3D.new()
	cap_mesh.mesh = _create_sphere_mesh(0.3, 8)
	var cap_material = StandardMaterial3D.new()
	cap_material.albedo_color = Color(0.6, 0.4, 0.2) # 棕色
	cap_material.roughness = 0.8
	cap_mesh.material_override = cap_material
	cap_mesh.position = Vector3(0, 0.5, 0)
	cap_mesh.scale = Vector3(1, 0.6, 1)
	parent_node.add_child(cap_mesh)

func _create_detailed_crop(parent_node: Node3D):
	"""创建详细的作物模型"""
	var crop_mesh = MeshInstance3D.new()
	crop_mesh.mesh = _create_cylinder_mesh(0.15, 0.6, 6)
	var crop_material = StandardMaterial3D.new()
	crop_material.albedo_color = Color(0.4, 0.7, 0.2) # 绿色
	crop_material.roughness = 0.8
	crop_mesh.material_override = crop_material
	crop_mesh.position = Vector3(0, 0.3, 0)
	parent_node.add_child(crop_mesh)

func _create_detailed_aquatic_plant(parent_node: Node3D):
	"""创建详细的水生植物模型"""
	var aquatic_mesh = MeshInstance3D.new()
	aquatic_mesh.mesh = _create_cylinder_mesh(0.1, 0.8, 8)
	var aquatic_material = StandardMaterial3D.new()
	aquatic_material.albedo_color = Color(0.1, 0.5, 0.3) # 深绿色
	aquatic_material.roughness = 0.9
	aquatic_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	aquatic_material.alpha = 0.7
	aquatic_mesh.material_override = aquatic_material
	aquatic_mesh.position = Vector3(0, 0.4, 0)
	parent_node.add_child(aquatic_mesh)

func _create_detailed_corrupted_plant(parent_node: Node3D):
	"""创建详细的腐化植物模型"""
	var corrupted_mesh = MeshInstance3D.new()
	corrupted_mesh.mesh = _create_sphere_mesh(0.5, 8)
	var corrupted_material = StandardMaterial3D.new()
	corrupted_material.albedo_color = Color(0.3, 0.1, 0.3) # 紫色
	corrupted_material.roughness = 0.9
	corrupted_material.emission = Color(0.1, 0.0, 0.1)
	corrupted_material.emission_energy = 0.2
	corrupted_mesh.material_override = corrupted_material
	corrupted_mesh.position = Vector3(0, 0.25, 0)
	parent_node.add_child(corrupted_mesh)

func _create_detailed_flower(parent_node: Node3D):
	"""创建详细的花朵模型"""
	# 花茎
	var stem_mesh = MeshInstance3D.new()
	stem_mesh.mesh = _create_cylinder_mesh(0.03, 0.3, 6)
	var stem_material = StandardMaterial3D.new()
	stem_material.albedo_color = Color(0.3, 0.5, 0.2) # 绿色
	stem_mesh.material_override = stem_material
	stem_mesh.position = Vector3(0, 0.15, 0)
	parent_node.add_child(stem_mesh)
	
	# 花瓣
	for i in range(5):
		var petal_mesh = MeshInstance3D.new()
		petal_mesh.mesh = _create_plane_mesh(0.15, 0.1)
		var petal_material = StandardMaterial3D.new()
		petal_material.albedo_color = Color(0.8, 0.2, 0.8) # 紫色
		petal_material.roughness = 0.6
		petal_mesh.material_override = petal_material
		petal_mesh.position = Vector3(0, 0.25, 0)
		petal_mesh.rotation = Vector3(0, i * 2 * PI / 5, 0)
		parent_node.add_child(petal_mesh)

func _create_detailed_grass(parent_node: Node3D):
	"""创建详细的草地模型"""
	var grass_mesh = MeshInstance3D.new()
	grass_mesh.mesh = _create_cylinder_mesh(0.02, 0.2, 4)
	var grass_material = StandardMaterial3D.new()
	grass_material.albedo_color = Color(0.2, 0.6, 0.2) # 绿色
	grass_material.roughness = 0.8
	grass_mesh.material_override = grass_material
	grass_mesh.position = Vector3(0, 0.1, 0)
	parent_node.add_child(grass_mesh)

func _create_simple_plant(parent_node: Node3D, plant_type: PlantType):
	"""创建简单的植物模型（通用后备）"""
	var plant_mesh = MeshInstance3D.new()
	plant_mesh.mesh = _create_sphere_mesh(0.4, 8)
	var plant_material = StandardMaterial3D.new()
	plant_material.albedo_color = plant_colors.get(plant_type, Color.GREEN)
	plant_material.roughness = 0.8
	plant_mesh.material_override = plant_material
	plant_mesh.position = Vector3(0, 0.2, 0)
	parent_node.add_child(plant_mesh)

# ============================================================================
# 辅助几何体生成函数
# ============================================================================

func _create_cylinder_mesh(radius: float, height: float, segments: int) -> CylinderMesh:
	"""创建圆柱体网格"""
	var mesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	return mesh

func _create_sphere_mesh(radius: float, segments: int) -> SphereMesh:
	"""创建球体网格"""
	var mesh = SphereMesh.new()
	mesh.radius = radius
	mesh.radial_segments = segments
	mesh.rings = segments / 2
	return mesh

func _create_plane_mesh(width: float, height: float) -> PlaneMesh:
	"""创建平面网格"""
	var mesh = PlaneMesh.new()
	mesh.size = Vector2(width, height)
	return mesh
