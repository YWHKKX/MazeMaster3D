extends MeshInstance3D
class_name ProceduralRenderer

## 🏗️ 程序化渲染器
## 负责使用程序化网格生成方式渲染3x3x3建筑

# 渲染配置
var building_config: BuildingConfig = null
var cell_size: float = 0.33
var grid_size: Vector3 = Vector3(3, 3, 3)

# LOD系统
var lod_level: int = 2  # 0=最低, 1=中等, 2=最高
var lod_enabled: bool = true

# 材质系统
var wall_material: StandardMaterial3D
var floor_material: StandardMaterial3D
var roof_material: StandardMaterial3D
var window_material: StandardMaterial3D
var door_material: StandardMaterial3D

# 性能优化
var mesh_cache: Dictionary = {}
var collision_generated: bool = false


func _init():
	"""初始化程序化渲染器"""
	name = "ProceduralRenderer"


func _ready():
	"""场景准备就绪"""
	# 初始化材质
	_initialize_materials()


func _initialize_materials():
	"""初始化材质"""
	# 墙体材质
	wall_material = StandardMaterial3D.new()
	wall_material.albedo_color = Color.WHITE
	wall_material.roughness = 0.7
	wall_material.metallic = 0.2
	
	# 地板材质
	floor_material = StandardMaterial3D.new()
	floor_material.albedo_color = Color.GRAY
	floor_material.roughness = 0.8
	floor_material.metallic = 0.1
	
	# 屋顶材质
	roof_material = StandardMaterial3D.new()
	roof_material.albedo_color = Color.RED
	roof_material.roughness = 0.6
	roof_material.metallic = 0.3
	
	# 窗户材质
	window_material = StandardMaterial3D.new()
	window_material.albedo_color = Color.LIGHT_BLUE
	window_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	window_material.albedo_color.a = 0.3
	
	# 门材质
	door_material = StandardMaterial3D.new()
	door_material.albedo_color = Color.BROWN
	door_material.roughness = 0.5
	door_material.metallic = 0.1


func generate_from_config(config: BuildingConfig):
	"""根据配置生成建筑"""
	if not config:
		LogManager.warning("⚠️ [ProceduralRenderer] 配置为空")
		return
	
	building_config = config
	
	# 应用配置到材质
	_apply_config_to_materials(config)
	
	# 生成建筑网格
	var building_mesh = _create_building_mesh(config)
	mesh = building_mesh
	
	# 生成碰撞体
	if not collision_generated:
		_generate_collision()
	
	LogManager.info("✅ [ProceduralRenderer] 已生成建筑: %s" % config.name)


func _apply_config_to_materials(config: BuildingConfig):
	"""应用配置到材质"""
	wall_material.albedo_color = config.wall_color
	roof_material.albedo_color = config.roof_color
	floor_material.albedo_color = config.floor_color


func _create_building_mesh(config: BuildingConfig) -> ArrayMesh:
	"""创建建筑网格"""
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# 计算实际尺寸
	var w = grid_size.x * cell_size
	var d = grid_size.z * cell_size
	var h = grid_size.y * cell_size
	
	# 根据LOD级别生成不同复杂度的网格
	match lod_level:
		0:  # 最低细节：简单立方体
			_generate_simple_box(st, w, d, h)
		1:  # 中等细节：带门窗的立方体
			_generate_medium_detail(st, w, d, h, config)
		2:  # 最高细节：完整建筑结构
			_generate_high_detail(st, w, d, h, config)
	
	# 生成法线和UV
	st.generate_normals()
	st.generate_tangents()
	
	return st.commit()


func _generate_simple_box(st: SurfaceTool, w: float, d: float, h: float):
	"""生成简单立方体（LOD 0）"""
	# 使用墙体材质
	_add_material(st, wall_material)
	
	# 生成6个面
	_add_quad(st, Vector3(0, 0, 0), Vector3(w, 0, 0), Vector3(w, 0, d), Vector3(0, 0, d))  # 底面
	_add_quad(st, Vector3(0, h, 0), Vector3(0, h, d), Vector3(w, h, d), Vector3(w, h, 0))  # 顶面
	_add_quad(st, Vector3(0, 0, 0), Vector3(0, h, 0), Vector3(w, h, 0), Vector3(w, 0, 0))  # 前面
	_add_quad(st, Vector3(0, 0, d), Vector3(w, 0, d), Vector3(w, h, d), Vector3(0, h, d))  # 后面
	_add_quad(st, Vector3(0, 0, 0), Vector3(0, 0, d), Vector3(0, h, d), Vector3(0, h, 0))  # 左面
	_add_quad(st, Vector3(w, 0, 0), Vector3(w, h, 0), Vector3(w, h, d), Vector3(w, 0, d))  # 右面


func _generate_medium_detail(st: SurfaceTool, w: float, d: float, h: float, config: BuildingConfig):
	"""生成中等细节建筑（LOD 1）"""
	# 地板
	_add_material(st, floor_material)
	_add_quad(st, Vector3(0, 0, 0), Vector3(w, 0, 0), Vector3(w, 0, d), Vector3(0, 0, d))
	
	# 屋顶
	_add_material(st, roof_material)
	_add_quad(st, Vector3(0, h, 0), Vector3(0, h, d), Vector3(w, h, d), Vector3(w, h, 0))
	
	# 墙体（带门窗）
	_add_material(st, wall_material)
	_add_wall_with_opening(st, Vector3(0, 0, 0), Vector3(0, h, 0), Vector3(w, h, 0), Vector3(w, 0, 0), config.has_door, config.has_windows)  # 前面
	_add_quad(st, Vector3(0, 0, d), Vector3(w, 0, d), Vector3(w, h, d), Vector3(0, h, d))  # 后面
	_add_quad(st, Vector3(0, 0, 0), Vector3(0, 0, d), Vector3(0, h, d), Vector3(0, h, 0))  # 左面
	_add_quad(st, Vector3(w, 0, 0), Vector3(w, h, 0), Vector3(w, h, d), Vector3(w, 0, d))  # 右面


func _generate_high_detail(st: SurfaceTool, w: float, d: float, h: float, config: BuildingConfig):
	"""生成高细节建筑（LOD 2）"""
	# 地板
	_add_material(st, floor_material)
	_add_quad(st, Vector3(0, 0, 0), Vector3(w, 0, 0), Vector3(w, 0, d), Vector3(0, 0, d))
	
	# 屋顶
	_add_material(st, roof_material)
	if config.has_roof:
		_add_sloped_roof(st, w, d, h)
	else:
		_add_quad(st, Vector3(0, h, 0), Vector3(0, h, d), Vector3(w, h, d), Vector3(w, h, 0))
	
	# 墙体（带门窗和装饰）
	_add_material(st, wall_material)
	_add_wall_with_opening(st, Vector3(0, 0, 0), Vector3(0, h, 0), Vector3(w, h, 0), Vector3(w, 0, 0), config.has_door, config.has_windows)  # 前面
	_add_wall_with_opening(st, Vector3(0, 0, d), Vector3(w, 0, d), Vector3(w, h, d), Vector3(0, h, d), false, config.has_windows)  # 后面
	_add_wall_with_opening(st, Vector3(0, 0, 0), Vector3(0, 0, d), Vector3(0, h, d), Vector3(0, h, 0), false, config.has_windows)  # 左面
	_add_wall_with_opening(st, Vector3(w, 0, 0), Vector3(w, h, 0), Vector3(w, h, d), Vector3(w, 0, d), false, config.has_windows)  # 右面
	
	# 装饰元素
	if config.has_decorations:
		_add_decorations(st, w, d, h)


func _add_wall_with_opening(st: SurfaceTool, v1: Vector3, v2: Vector3, v3: Vector3, v4: Vector3, has_door: bool, has_windows: bool):
	"""添加带开口的墙体"""
	if has_door:
		_add_wall_with_door(st, v1, v2, v3, v4)
	elif has_windows:
		_add_wall_with_windows(st, v1, v2, v3, v4)
	else:
		_add_quad(st, v1, v2, v3, v4)


func _add_wall_with_door(st: SurfaceTool, v1: Vector3, v2: Vector3, v3: Vector3, v4: Vector3):
	"""添加带门的墙体"""
	# 计算门的位置和尺寸
	var door_width = cell_size * 0.6
	var door_height = cell_size * 1.6
	var wall_center = (v1 + v3) / 2
	var door_bottom = v1.y + 0.1
	var door_top = door_bottom + door_height
	
	# 门的左右边界
	var door_left = wall_center.x - door_width / 2
	var door_right = wall_center.x + door_width / 2
	
	# 生成带门洞的墙体（简化实现）
	_add_quad(st, v1, v2, v3, v4)
	
	# 添加门
	_add_material(st, door_material)
	var door_v1 = Vector3(door_left, door_bottom, v1.z)
	var door_v2 = Vector3(door_left, door_top, v2.z)
	var door_v3 = Vector3(door_right, door_top, v3.z)
	var door_v4 = Vector3(door_right, door_bottom, v4.z)
	_add_quad(st, door_v1, door_v2, door_v3, door_v4)


func _add_wall_with_windows(st: SurfaceTool, v1: Vector3, v2: Vector3, v3: Vector3, v4: Vector3):
	"""添加带窗户的墙体"""
	# 添加墙体
	_add_quad(st, v1, v2, v3, v4)
	
	# 添加窗户（简化实现）
	_add_material(st, window_material)
	var window_size = cell_size * 0.4
	var window_height = cell_size * 0.6
	var wall_center = (v1 + v3) / 2
	var window_center_y = v1.y + cell_size * 1.5
	
	# 窗户位置
	var window_v1 = Vector3(wall_center.x - window_size/2, window_center_y - window_height/2, v1.z)
	var window_v2 = Vector3(wall_center.x - window_size/2, window_center_y + window_height/2, v2.z)
	var window_v3 = Vector3(wall_center.x + window_size/2, window_center_y + window_height/2, v3.z)
	var window_v4 = Vector3(wall_center.x + window_size/2, window_center_y - window_height/2, v4.z)
	_add_quad(st, window_v1, window_v2, window_v3, window_v4)


func _add_sloped_roof(st: SurfaceTool, w: float, d: float, h: float):
	"""添加斜屋顶"""
	# 计算屋顶顶点
	var roof_height = cell_size * 0.5
	var roof_top = h + roof_height
	var roof_center = Vector3(w/2, roof_top, d/2)
	
	# 生成4个三角形组成金字塔屋顶
	_add_triangle(st, Vector3(0, h, 0), roof_center, Vector3(w, h, 0))  # 前三角
	_add_triangle(st, Vector3(w, h, 0), roof_center, Vector3(w, h, d))  # 右三角
	_add_triangle(st, Vector3(w, h, d), roof_center, Vector3(0, h, d))  # 后三角
	_add_triangle(st, Vector3(0, h, d), roof_center, Vector3(0, h, 0))  # 左三角


func _add_decorations(st: SurfaceTool, w: float, d: float, h: float):
	"""添加装饰元素"""
	# 添加角柱
	var pillar_size = cell_size * 0.2
	var pillar_height = h * 0.8
	
	# 四个角的柱子
	_add_pillar(st, Vector3(pillar_size/2, 0, pillar_size/2), pillar_size, pillar_height)
	_add_pillar(st, Vector3(w - pillar_size/2, 0, pillar_size/2), pillar_size, pillar_height)
	_add_pillar(st, Vector3(pillar_size/2, 0, d - pillar_size/2), pillar_size, pillar_height)
	_add_pillar(st, Vector3(w - pillar_size/2, 0, d - pillar_size/2), pillar_size, pillar_height)


func _add_pillar(st: SurfaceTool, position: Vector3, size: float, height: float):
	"""添加柱子"""
	# 柱子的8个顶点
	var half_size = size / 2
	var vertices = [
		Vector3(position.x - half_size, position.y, position.z - half_size),
		Vector3(position.x + half_size, position.y, position.z - half_size),
		Vector3(position.x + half_size, position.y, position.z + half_size),
		Vector3(position.x - half_size, position.y, position.z + half_size),
		Vector3(position.x - half_size, position.y + height, position.z - half_size),
		Vector3(position.x + half_size, position.y + height, position.z - half_size),
		Vector3(position.x + half_size, position.y + height, position.z + half_size),
		Vector3(position.x - half_size, position.y + height, position.z + half_size)
	]
	
	# 生成柱子的6个面（简化实现）
	_add_quad(st, vertices[0], vertices[1], vertices[5], vertices[4])  # 前面
	_add_quad(st, vertices[2], vertices[3], vertices[7], vertices[6])  # 后面
	_add_quad(st, vertices[0], vertices[4], vertices[7], vertices[3])  # 左面
	_add_quad(st, vertices[1], vertices[2], vertices[6], vertices[5])  # 右面
	_add_quad(st, vertices[0], vertices[3], vertices[2], vertices[1])  # 底面
	_add_quad(st, vertices[4], vertices[5], vertices[6], vertices[7])  # 顶面


func _add_quad(st: SurfaceTool, v1: Vector3, v2: Vector3, v3: Vector3, v4: Vector3):
	"""添加四边形（两个三角形）"""
	# 第一个三角形
	st.add_vertex(v1)
	st.add_vertex(v2)
	st.add_vertex(v3)
	
	# 第二个三角形
	st.add_vertex(v1)
	st.add_vertex(v3)
	st.add_vertex(v4)


func _add_triangle(st: SurfaceTool, v1: Vector3, v2: Vector3, v3: Vector3):
	"""添加三角形"""
	st.add_vertex(v1)
	st.add_vertex(v2)
	st.add_vertex(v3)


func _add_material(st: SurfaceTool, material: StandardMaterial3D):
	"""添加材质"""
	st.set_material(material)


func _generate_collision():
	"""生成碰撞体"""
	if collision_generated:
		return
	
	# 创建碰撞体
	create_trimesh_collision()
	collision_generated = true


func set_lod_level(level: int):
	"""设置LOD级别"""
	if lod_level == level:
		return
	
	lod_level = level
	
	# 重新生成建筑
	if building_config:
		generate_from_config(building_config)
	
	LogManager.debug("🔧 [ProceduralRenderer] LOD级别已更新: %d" % lod_level)


func enable_lod(enabled: bool):
	"""启用/禁用LOD系统"""
	lod_enabled = enabled
	
	# 重新生成建筑
	if building_config:
		generate_from_config(building_config)


func update_material_color(material_type: String, color: Color):
	"""更新材质颜色"""
	match material_type:
		"wall":
			wall_material.albedo_color = color
		"floor":
			floor_material.albedo_color = color
		"roof":
			roof_material.albedo_color = color
		"window":
			window_material.albedo_color = color
		"door":
			door_material.albedo_color = color
	
	# 重新生成建筑以应用新材质
	if building_config:
		generate_from_config(building_config)


func get_render_info() -> Dictionary:
	"""获取渲染信息"""
	return {
		"renderer_type": "ProceduralRenderer",
		"cell_size": cell_size,
		"grid_size": grid_size,
		"lod_level": lod_level,
		"lod_enabled": lod_enabled,
		"collision_generated": collision_generated,
		"building_config": building_config.name if building_config else "None"
	}
