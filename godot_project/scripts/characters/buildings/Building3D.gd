extends Building
class_name Building3D

## 🏗️ 3x3x3建筑基础类
## 基于原有Building类，扩展支持3x3x3空间的精细化建筑设计
## 参考 docs/3X3X3_BUILDING_DESIGN.md

# 预加载依赖类
const GridMapRendererClass = preload("res://scripts/characters/buildings/GridMapRenderer.gd")
const ProceduralRendererClass = preload("res://scripts/characters/buildings/ProceduralRenderer.gd")
const BuildingRenderModeClass = preload("res://scripts/characters/buildings/BuildingRenderMode.gd")
const BuildingAnimatorClass = preload("res://scripts/characters/buildings/BuildingAnimator.gd")
const BuildingEffectManagerClass = preload("res://scripts/characters/buildings/BuildingEffectManager.gd")
const BuildingTemplateClass = preload("res://scripts/characters/buildings/BuildingTemplate.gd")

# 3x3x3建筑配置
var building_3d_config: Building3DConfig
var cell_size: float = 0.33 # 每个子瓦片的尺寸
var grid_size: Vector3 = Vector3(3, 3, 3) # 3x3x3网格

# 渲染系统
var gridmap_renderer = null
var procedural_renderer = null
var render_mode = 0 # 0=GRIDMAP, 1=PROCEDURAL

# 建筑构件库
var mesh_library: MeshLibrary = null

# 动画和特效
var construction_animator = null
var effect_manager = null

# LOD系统
var lod_level: int = 2 # 0=最低, 1=中等, 2=最高
var distance_to_camera: float = 0.0


func _init():
	super._init()
	# 初始化3x3x3建筑配置
	building_3d_config = Building3DConfig.new()


func _ready():
	# 先调用父类的_ready()
	super._ready()
	
	# 初始化3x3x3建筑系统
	_setup_3d_building_system()


func _setup_3d_building_system():
	"""初始化3x3x3建筑系统"""
	LogManager.info("🏗️ [Building3D] 初始化3x3x3建筑系统: %s" % building_name)
	
	# 1. 创建构件库
	_setup_mesh_library()
	
	# 2. 初始化渲染系统
	_setup_render_system()
	
	# 3. 初始化动画系统
	_setup_animation_system()
	
	# 4. 初始化特效系统
	_setup_effect_system()
	
	# 5. 生成初始建筑
	_generate_building()


func _setup_mesh_library():
	"""创建建筑构件库"""
	mesh_library = MeshLibrary.new()
	
	# 加载基础构件
	_load_basic_components()
	
	# 加载建筑特定构件
	_load_building_specific_components()


func _load_basic_components():
	"""加载基础构件"""
	# 基础结构构件
	_add_component_to_library("Floor_Stone", BuildingComponents.ID_FLOOR_STONE)
	_add_component_to_library("Floor_Wood", BuildingComponents.ID_FLOOR_WOOD)
	_add_component_to_library("Floor_Metal", BuildingComponents.ID_FLOOR_METAL)
	_add_component_to_library("Wall_Stone", BuildingComponents.ID_WALL_STONE)
	_add_component_to_library("Wall_Wood", BuildingComponents.ID_WALL_WOOD)
	_add_component_to_library("Wall_Metal", BuildingComponents.ID_WALL_METAL)
	_add_component_to_library("Corner_Stone", BuildingComponents.ID_CORNER_STONE)
	_add_component_to_library("Corner_Wood", BuildingComponents.ID_CORNER_WOOD)
	_add_component_to_library("Corner_Metal", BuildingComponents.ID_CORNER_METAL)
	
	# 门窗构件
	_add_component_to_library("Door_Wood", BuildingComponents.ID_DOOR_WOOD)
	_add_component_to_library("Door_Metal", BuildingComponents.ID_DOOR_METAL)
	_add_component_to_library("Window_Small", BuildingComponents.ID_WINDOW_SMALL)
	_add_component_to_library("Window_Large", BuildingComponents.ID_WINDOW_LARGE)
	_add_component_to_library("Gate_Stone", BuildingComponents.ID_GATE_STONE)
	
	# 装饰构件
	_add_component_to_library("Pillar_Stone", BuildingComponents.ID_PILLAR_STONE)
	_add_component_to_library("Pillar_Wood", BuildingComponents.ID_PILLAR_WOOD)
	_add_component_to_library("Torch_Wall", BuildingComponents.ID_TORCH_WALL)
	_add_component_to_library("Banner_Cloth", BuildingComponents.ID_BANNER_CLOTH)
	_add_component_to_library("Statue_Stone", BuildingComponents.ID_STATUE_STONE)
	
	# 特殊构件
	_add_component_to_library("Stairs_Wood", BuildingComponents.ID_STAIRS_WOOD)
	_add_component_to_library("Stairs_Stone", BuildingComponents.ID_STAIRS_STONE)
	_add_component_to_library("Roof_Slope", BuildingComponents.ID_ROOF_SLOPE)
	_add_component_to_library("Roof_Peak", BuildingComponents.ID_ROOF_PEAK)
	_add_component_to_library("Floor_Trap", BuildingComponents.ID_FLOOR_TRAP)


func _load_building_specific_components():
	"""加载建筑特定构件（子类重写）"""
	# 默认不加载特定构件，子类可以重写此方法
	pass


func _add_component_to_library(component_name: String, component_id: int):
	"""添加构件到MeshLibrary"""
	var component_path = "res://img/scenes/buildings/components/" + component_name + ".tscn"
	
	# 检查构件文件是否存在
	if not ResourceLoader.exists(component_path):
		LogManager.warning("⚠️ [Building3D] 构件文件不存在: %s" % component_path)
		return
	
	# 加载构件场景
	var component_scene = load(component_path)
	var component_instance = component_scene.instantiate()
	
	# 获取构件的MeshInstance3D
	var mesh_instance = _find_mesh_instance(component_instance)
	if not mesh_instance:
		LogManager.warning("⚠️ [Building3D] 构件中没有找到MeshInstance3D: %s" % component_name)
		component_instance.queue_free()
		return
	
	# 添加到MeshLibrary
	mesh_library.create_item(component_id)
	mesh_library.set_item_mesh(component_id, mesh_instance.mesh)
	
	# 清理临时实例
	component_instance.queue_free()
	
func _find_mesh_instance(node: Node) -> MeshInstance3D:
	"""递归查找MeshInstance3D节点"""
	if node is MeshInstance3D:
		return node
	
	for child in node.get_children():
		var result = _find_mesh_instance(child)
		if result:
			return result
	
	return null


func _setup_render_system():
	"""初始化渲染系统"""
	match render_mode:
		0: # GRIDMAP
			_setup_gridmap_renderer()
		1: # PROCEDURAL
			_setup_procedural_renderer()


func _setup_gridmap_renderer():
	"""设置GridMap渲染器"""
	gridmap_renderer = GridMapRendererClass.new()
	gridmap_renderer.name = "GridMapRenderer"
	gridmap_renderer.building_cell_size = Vector3(cell_size, cell_size, cell_size)
	gridmap_renderer.set_building_mesh_library(mesh_library)
	add_child(gridmap_renderer)


func _setup_procedural_renderer():
	"""设置程序化渲染器"""
	procedural_renderer = ProceduralRendererClass.new()
	procedural_renderer.name = "ProceduralRenderer"
	procedural_renderer.building_config = building_3d_config
	add_child(procedural_renderer)


func _setup_animation_system():
	"""初始化动画系统"""
	construction_animator = BuildingAnimatorClass.new()
	construction_animator.name = "ConstructionAnimator"
	add_child(construction_animator)


func _setup_effect_system():
	"""初始化特效系统"""
	effect_manager = BuildingEffectManagerClass.new()
	effect_manager.name = "EffectManager"
	add_child(effect_manager)


func _generate_building():
	"""生成建筑（根据渲染模式）"""
	match render_mode:
		0: # GRIDMAP
			_generate_gridmap_building()
		1: # PROCEDURAL
			_generate_procedural_building()


func _generate_gridmap_building():
	"""使用GridMap生成建筑"""
	if not gridmap_renderer:
		return
	
	# 获取建筑模板
	var template = _get_building_template()
	if not template:
		LogManager.warning("⚠️ [Building3D] 未找到建筑模板: %s" % building_name)
		return
	
	# 应用模板到GridMap
	gridmap_renderer.apply_template(template)


func _generate_procedural_building():
	"""使用程序化生成建筑"""
	if not procedural_renderer:
		return
	
	# 设置建筑配置
	var config = _get_building_config()
	procedural_renderer.generate_from_config(config)


func _get_building_template():
	"""获取建筑模板（子类重写）"""
	# 默认返回空模板，子类需要重写
	return BuildingTemplateClass.new()


func _get_building_config() -> BuildingConfig:
	"""获取建筑配置（子类重写）"""
	# 默认返回基础配置，子类需要重写
	return BuildingConfig.new()


# ===== 建造系统扩展 =====

func _complete_construction() -> void:
	"""建造完成（重写父类方法）"""
	# 调用父类方法
	super._complete_construction()
	
	# 播放建造完成动画
	if construction_animator:
		construction_animator.play_completion_animation()
	
	# 添加建造完成特效
	if effect_manager:
		effect_manager.play_completion_effect()


func update_visual_by_progress():
	"""根据建造进度更新视觉（重写父类方法）"""
	# 调用父类方法
	super.update_visual_by_progress()
	
	# 更新3D建筑进度
	if construction_animator:
		construction_animator.update_construction_progress(build_progress)


# ===== LOD系统 =====

func update_lod(distance: float):
	"""更新LOD级别"""
	distance_to_camera = distance
	
	var new_lod = _calculate_lod_level(distance)
	if new_lod != lod_level:
		_switch_lod_level(new_lod)


func _calculate_lod_level(distance: float) -> int:
	"""计算LOD级别"""
	if distance > 50.0:
		return 0 # 最低细节
	elif distance > 20.0:
		return 1 # 中等细节
	else:
		return 2 # 最高细节


func _switch_lod_level(new_lod: int):
	"""切换LOD级别"""
	lod_level = new_lod
	
	# 更新渲染器LOD
	if gridmap_renderer:
		gridmap_renderer.set_lod_level(lod_level)
	
	if procedural_renderer:
		procedural_renderer.set_lod_level(lod_level)
	
	# 更新特效LOD
	if effect_manager:
		effect_manager.set_lod_level(lod_level)


# ===== 更新逻辑 =====

func _update_logic(delta: float):
	"""更新建筑逻辑（重写父类方法）"""
	# 调用父类方法
	super._update_logic(delta)
	
	# 更新3D建筑特定逻辑
	_update_3d_building_logic(delta)


func _update_3d_building_logic(delta: float):
	"""更新3D建筑特定逻辑（子类重写）"""
	# 更新动画
	if construction_animator:
		construction_animator.update(delta)
	
	# 更新特效
	if effect_manager:
		effect_manager.update(delta)
	
	# 更新功能特效
	_update_functional_effects(delta)


func _update_functional_effects(delta: float):
	"""更新功能特效（子类重写）"""
	# 默认不更新功能特效，子类可以重写
	pass


# ===== 调试信息 =====

func get_building_info() -> Dictionary:
	"""获取建筑信息（重写父类方法）"""
	var base_info = super.get_building_info()
	
	# 添加3D建筑信息
	base_info["render_mode"] = "GRIDMAP" if render_mode == 0 else "PROCEDURAL"
	base_info["lod_level"] = lod_level
	base_info["distance_to_camera"] = distance_to_camera
	base_info["has_gridmap_renderer"] = gridmap_renderer != null
	base_info["has_procedural_renderer"] = procedural_renderer != null
	
	return base_info


# ===== 建筑类型特定方法（子类重写）=====

func get_building_3d_config() -> Building3DConfig:
	"""获取3D建筑配置（子类重写）"""
	return building_3d_config


func on_3d_building_ready():
	"""3D建筑准备就绪回调（子类重写）"""
	pass


func on_3d_building_completed():
	"""3D建筑完成回调（子类重写）"""
	pass
