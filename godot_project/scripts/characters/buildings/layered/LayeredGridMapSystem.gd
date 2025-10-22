extends Node3D
class_name LayeredGridMapSystem

## 🏗️ 分层GridMap管理系统
## 管理多个GridMap层，实现复杂建筑的模块化构建

signal layer_updated(layer_name: String, cell_count: int)
signal building_assembled(building_name: String)

# 分层GridMap节点
var floor_layer: GridMap
var wall_layer: GridMap
var ceiling_layer: GridMap
var decoration_layer: GridMap

# 层管理器
var floor_manager: FloorLayerManager
var wall_manager: WallLayerManager
var ceiling_manager: CeilingLayerManager
var decoration_manager: DecorationLayerManager

# 组件变体管理器
var component_variant_manager: ComponentVariantManager
var material_system: MaterialSystem

# 建筑配置
var building_config: Dictionary = {}
var layer_configs: Dictionary = {}

func _ready():
	"""初始化分层GridMap系统"""
	_setup_layers()
	_setup_managers()
	_setup_material_system()
	
	# 延迟设置GridMap引用，确保管理器完全初始化
	call_deferred("_setup_gridmap_references")
	
	LogManager.info("🏗️ [LayeredGridMapSystem] 分层GridMap系统初始化完成")


func _setup_layers():
	"""设置各层GridMap"""
	# 创建各层GridMap节点
	floor_layer = GridMap.new()
	wall_layer = GridMap.new()
	ceiling_layer = GridMap.new()
	decoration_layer = GridMap.new()
	
	# 地面层设置
	floor_layer.name = "FloorLayer"
	floor_layer.cell_size = Vector3(0.33, 0.33, 0.33)
	# 暂时使用空的MeshLibrary，稍后由层管理器设置
	floor_layer.mesh_library = MeshLibrary.new()
	add_child(floor_layer)
	
	# 墙壁层设置
	wall_layer.name = "WallLayer"
	wall_layer.cell_size = Vector3(0.33, 0.33, 0.33)
	wall_layer.mesh_library = MeshLibrary.new()
	add_child(wall_layer)
	
	# 天花板层设置
	ceiling_layer.name = "CeilingLayer"
	ceiling_layer.cell_size = Vector3(0.33, 0.33, 0.33)
	ceiling_layer.mesh_library = MeshLibrary.new()
	add_child(ceiling_layer)
	
	# 装饰层设置
	decoration_layer.name = "DecorationLayer"
	decoration_layer.cell_size = Vector3(0.33, 0.33, 0.33)
	decoration_layer.mesh_library = MeshLibrary.new()
	add_child(decoration_layer)


func _setup_managers():
	"""设置层管理器"""
	floor_manager = FloorLayerManager.new()
	wall_manager = WallLayerManager.new()
	ceiling_manager = CeilingLayerManager.new()
	decoration_manager = DecorationLayerManager.new()
	
	# 先添加到场景树
	add_child(floor_manager)
	add_child(wall_manager)
	add_child(ceiling_manager)
	add_child(decoration_manager)

func _setup_gridmap_references():
	"""设置GridMap引用"""
	# 设置层引用
	floor_manager.set_gridmap(floor_layer)
	wall_manager.set_gridmap(wall_layer)
	ceiling_manager.set_gridmap(ceiling_layer)
	decoration_manager.set_gridmap(decoration_layer)
	
	LogManager.info("🔧 [LayeredGridMapSystem] GridMap引用设置完成")


func _setup_material_system():
	"""设置材质系统"""
	material_system = MaterialSystem.new()
	component_variant_manager = ComponentVariantManager.new()
	
	add_child(material_system)
	add_child(component_variant_manager)


func assemble_building(building_template: Dictionary, building_name: String):
	"""组装建筑"""
	LogManager.info("🏗️ [LayeredGridMapSystem] 开始组装建筑: %s" % building_name)
	
	# 清空所有层
	clear_all_layers()
	
	# 解析建筑模板
	var floor_data = building_template.get("floor", {})
	var wall_data = building_template.get("wall", {})
	var ceiling_data = building_template.get("ceiling", {})
	var decoration_data = building_template.get("decoration", {})
	
	# 组装各层
	floor_manager.assemble_layer(floor_data)
	wall_manager.assemble_layer(wall_data)
	ceiling_manager.assemble_layer(ceiling_data)
	decoration_manager.assemble_layer(decoration_data)
	
	# 发射完成信号
	building_assembled.emit(building_name)
	LogManager.info("✅ [LayeredGridMapSystem] 建筑组装完成: %s" % building_name)


func clear_all_layers():
	"""清空所有层"""
	floor_layer.clear()
	wall_layer.clear()
	ceiling_layer.clear()
	decoration_layer.clear()
	
	LogManager.info("🧹 [LayeredGridMapSystem] 所有层已清空")


func get_layer_by_name(layer_name: String) -> GridMap:
	"""根据名称获取层"""
	match layer_name:
		"floor":
			return floor_layer
		"wall":
			return wall_layer
		"ceiling":
			return ceiling_layer
		"decoration":
			return decoration_layer
		_:
			LogManager.warning("⚠️ [LayeredGridMapSystem] 未知层名称: %s" % layer_name)
			return null


func get_layer_manager_by_name(layer_name: String) -> Node:
	"""根据名称获取层管理器"""
	match layer_name:
		"floor":
			return floor_manager
		"wall":
			return wall_manager
		"ceiling":
			return ceiling_manager
		"decoration":
			return decoration_manager
		_:
			LogManager.warning("⚠️ [LayeredGridMapSystem] 未知层管理器名称: %s" % layer_name)
			return null


func set_building_config(config: Dictionary):
	"""设置建筑配置"""
	building_config = config
	layer_configs = config.get("layers", {})
	
	# 应用层配置
	for layer_name in layer_configs:
		var manager = get_layer_manager_by_name(layer_name)
		if manager:
			manager.set_config(layer_configs[layer_name])


func get_building_info() -> Dictionary:
	"""获取建筑信息"""
	return {
		"floor_cells": floor_layer.get_used_cells().size(),
		"wall_cells": wall_layer.get_used_cells().size(),
		"ceiling_cells": ceiling_layer.get_used_cells().size(),
		"decoration_cells": decoration_layer.get_used_cells().size(),
		"total_cells": floor_layer.get_used_cells().size() + wall_layer.get_used_cells().size() + ceiling_layer.get_used_cells().size() + decoration_layer.get_used_cells().size()
	}
