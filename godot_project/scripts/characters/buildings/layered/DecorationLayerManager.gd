extends Node
class_name DecorationLayerManager

## 🏗️ 装饰层管理器
## 专门处理家具、灯光等装饰性元素

signal decoration_updated(cell_count: int)

var gridmap: GridMap
var decoration_config: Dictionary = {}
var decoration_components: Dictionary = {}

# 装饰组件类型
enum DecorationType {
	# 地牢之心专用装饰
	HEART_CORE, # 地牢之心核心
	ENERGY_CRYSTAL, # 能量水晶
	MANA_CRYSTAL, # 魔力水晶
	MAGIC_CORE, # 魔法核心
	ENERGY_CONDUIT, # 能量导管
	ENERGY_NODE, # 能量节点
	STORAGE_CORE, # 存储核心
	POWER_NODE, # 能量节点
	CORE_CHAMBER, # 核心密室
	ENERGY_FLOW, # 能量流动
	HEART_ENTRANCE, # 地牢之心入口
	
	# 魔法装饰
	MAGIC_CRYSTAL, # 魔法水晶
	MAGIC_ALTAR, # 魔法祭坛
	ENERGY_RUNE, # 能量符文
	SUMMONING_CIRCLE, # 召唤阵
	MANA_POOL, # 魔力池
	
	# 家具装饰
	CHANDELIER, # 吊灯
	FOUNTAIN, # 喷泉
	STATUE, # 雕像
	BANNER, # 旗帜
	ORNAMENT, # 装饰品
	
	# 功能装饰
	TORCH, # 火把
	LAMP, # 灯具
	PILLAR, # 柱子
	THRONE, # 王座
	ALTAR, # 祭坛
	
	# 特殊装饰
	PORTAL, # 传送门
	RITUAL_CIRCLE, # 仪式圈
	MAGIC_FOUNTAIN, # 魔法喷泉
	CRYSTAL_GROWTH, # 水晶生长
	SHADOW_VEIL # 暗影面纱
}

func _ready():
	"""初始化装饰层管理器"""
	_setup_decoration_components()
	LogManager.info("🏗️ [DecorationLayerManager] 装饰层管理器初始化完成")


func set_gridmap(gridmap_node: GridMap):
	"""设置GridMap引用"""
	gridmap = gridmap_node
	_setup_mesh_library()

func _setup_mesh_library():
	"""设置MeshLibrary"""
	if not gridmap:
		return
	
	var mesh_library = MeshLibrary.new()
	
	# 为每种装饰类型创建网格
	for decoration_type in decoration_components:
		var component = decoration_components[decoration_type]
		var mesh = _create_decoration_mesh(component)
		if mesh:
			mesh_library.create_item(component.id)
			mesh_library.set_item_mesh(component.id, mesh)
	
	gridmap.mesh_library = mesh_library
	LogManager.info("🔧 [DecorationLayerManager] MeshLibrary已设置，包含 %d 个网格" % mesh_library.get_item_list().size())

func _create_decoration_mesh(component: Dictionary) -> Mesh:
	"""创建装饰网格"""
	var box_mesh = BoxMesh.new()
	box_mesh.size = component.get("size", Vector3(0.33, 0.33, 0.33))
	
	# 创建材质
	var material = StandardMaterial3D.new()
	material.albedo_color = component.get("color", Color.WHITE)
	material.roughness = component.get("roughness", 0.8)
	material.metallic = component.get("metallic", 0.1)
	
	# 如果有发光属性
	if component.has("emission") and component.get("emission_energy", 0.0) > 0.0:
		material.emission_enabled = true
		material.emission = component.emission
		material.emission_energy = component.emission_energy
	
	# 如果有透明度
	if component.get("color", Color.WHITE).a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	box_mesh.surface_set_material(0, material)
	return box_mesh


func _setup_decoration_components():
	"""设置装饰组件"""
	decoration_components = {
		# 地牢之心专用装饰组件 - 黑色底座 + 红色魔力管道 + 红色魔力核心
		DecorationType.HEART_CORE: {
			"id": 0,
			"name": "地牢之心核心",
			"material": "magic",
			"texture": "heart_core",
			"color": Color(0.9, 0.1, 0.1), # 深红色核心
			"roughness": 0.1,
			"metallic": 0.9,
			"emission": Color(1.0, 0.2, 0.2), # 强烈红色发光
			"emission_energy": 2.5,
			"size": Vector3(0.25, 0.4, 0.25)
		},
		DecorationType.ENERGY_CRYSTAL: {
			"id": 1,
			"name": "能量水晶",
			"material": "crystal",
			"texture": "energy_crystal",
			"color": Color(0.8, 0.1, 0.1), # 红色水晶
			"roughness": 0.05,
			"metallic": 0.0,
			"emission": Color(0.9, 0.2, 0.2), # 红色发光
			"emission_energy": 2.0,
			"size": Vector3(0.33, 0.33, 0.33)
		},
		DecorationType.MANA_CRYSTAL: {
			"id": 2,
			"name": "魔力水晶",
			"material": "crystal",
			"texture": "mana_crystal",
			"color": Color(0.7, 0.1, 0.1), # 深红色魔力水晶
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.8, 0.2, 0.2), # 红色发光
			"emission_energy": 1.8,
			"size": Vector3(0.33, 0.33, 0.33)
		},
		DecorationType.MAGIC_CORE: {
			"id": 3,
			"name": "魔法核心",
			"material": "magic",
			"texture": "magic_core",
			"color": Color(0.9, 0.1, 0.1), # 深红色魔法核心
			"roughness": 0.2,
			"metallic": 0.8,
			"emission": Color(1.0, 0.2, 0.2), # 强烈红色发光
			"emission_energy": 2.2,
			"size": Vector3(0.33, 0.33, 0.33)
		},
		DecorationType.ENERGY_CONDUIT: {
			"id": 4,
			"name": "能量导管",
			"material": "magic",
			"texture": "energy_conduit",
			"color": Color(0.6, 0.1, 0.1), # 深红色导管
			"roughness": 0.3,
			"metallic": 0.6,
			"emission": Color(0.8, 0.2, 0.2), # 红色发光
			"emission_energy": 1.5,
			"size": Vector3(0.3, 0.2, 0.3)
		},
		DecorationType.ENERGY_NODE: {
			"id": 5,
			"name": "能量节点",
			"material": "magic",
			"texture": "energy_node",
			"color": Color(0.5, 0.1, 0.1), # 深红色节点
			"roughness": 0.1,
			"metallic": 0.4,
			"emission": Color(0.7, 0.2, 0.2), # 红色发光
			"emission_energy": 1.6,
			"size": Vector3(0.33, 0.33, 0.33)
		},
		DecorationType.STORAGE_CORE: {
			"id": 6,
			"name": "存储核心",
			"material": "magic",
			"texture": "storage_core",
			"color": Color(0.4, 0.1, 0.1), # 深红色存储核心
			"roughness": 0.2,
			"metallic": 0.7,
			"emission": Color(0.6, 0.2, 0.2), # 红色发光
			"emission_energy": 1.4,
			"size": Vector3(0.33, 0.33, 0.33)
		},
		DecorationType.POWER_NODE: {
			"id": 7,
			"name": "能量节点",
			"material": "magic",
			"texture": "power_node",
			"color": Color(0.7, 0.1, 0.1), # 深红色能量节点
			"roughness": 0.2,
			"metallic": 0.8,
			"emission": Color(0.9, 0.2, 0.2), # 红色发光
			"emission_energy": 1.8,
			"size": Vector3(0.2, 0.25, 0.2)
		},
		DecorationType.CORE_CHAMBER: {
			"id": 8,
			"name": "核心密室",
			"material": "metal",
			"texture": "core_chamber",
			"color": Color(0.1, 0.1, 0.1), # 黑色底座
			"roughness": 0.8,
			"metallic": 0.9,
			"emission": Color(0.0, 0.0, 0.0), # 不发光
			"emission_energy": 0.0,
			"size": Vector3(0.28, 0.35, 0.28)
		},
		DecorationType.ENERGY_FLOW: {
			"id": 9,
			"name": "能量流动",
			"material": "magic",
			"texture": "energy_flow",
			"color": Color(0.6, 0.1, 0.1), # 深红色能量流动
			"roughness": 0.1,
			"metallic": 0.3,
			"emission": Color(0.8, 0.2, 0.2), # 红色发光
			"emission_energy": 1.6,
			"size": Vector3(0.25, 0.15, 0.25)
		},
		DecorationType.HEART_ENTRANCE: {
			"id": 10,
			"name": "地牢之心入口",
			"material": "wood",
			"texture": "heart_entrance",
			"color": Color(0.2, 0.1, 0.1), # 深红色木质入口
			"roughness": 0.7,
			"metallic": 0.0,
			"emission": Color(0.3, 0.1, 0.1), # 微弱红色发光
			"emission_energy": 0.3,
			"size": Vector3(0.3, 0.33, 0.05)
		},
		
		# 通用魔法装饰组件
		DecorationType.MAGIC_CRYSTAL: {
			"id": 30,
			"name": "魔法水晶",
			"material": "magic",
			"texture": "magic_crystal",
			"color": Color(0.3, 0.1, 0.8),
			"roughness": 0.1,
			"metallic": 0.0,
			"emission": Color(0.2, 0.1, 0.6),
			"emission_energy": 1.0,
			"size": Vector3(0.2, 0.3, 0.2)
		},
		DecorationType.MAGIC_ALTAR: {
			"id": 31,
			"name": "魔法祭坛",
			"material": "stone",
			"texture": "magic_altar",
			"color": Color(0.4, 0.2, 0.6),
			"roughness": 0.3,
			"metallic": 0.1,
			"emission": Color(0.1, 0.05, 0.3),
			"emission_energy": 0.3,
			"size": Vector3(0.3, 0.2, 0.3)
		},
		DecorationType.ENERGY_RUNE: {
			"id": 32,
			"name": "能量符文",
			"material": "magic",
			"texture": "energy_rune",
			"color": Color(0.8, 0.8, 0.2),
			"roughness": 0.0,
			"metallic": 0.0,
			"emission": Color(0.6, 0.6, 0.1),
			"emission_energy": 0.8,
			"size": Vector3(0.3, 0.05, 0.3)
		},
		DecorationType.SUMMONING_CIRCLE: {
			"id": 33,
			"name": "召唤阵",
			"material": "magic",
			"texture": "summoning_circle",
			"color": Color(0.6, 0.1, 0.1),
			"roughness": 0.0,
			"metallic": 0.0,
			"emission": Color(0.4, 0.05, 0.05),
			"emission_energy": 0.6,
			"size": Vector3(0.3, 0.05, 0.3)
		},
		DecorationType.MANA_POOL: {
			"id": 34,
			"name": "魔力池",
			"material": "magic",
			"texture": "mana_pool",
			"color": Color(0.1, 0.3, 0.8),
			"roughness": 0.0,
			"metallic": 0.0,
			"emission": Color(0.05, 0.2, 0.6),
			"emission_energy": 0.7,
			"size": Vector3(0.3, 0.1, 0.3)
		},
		DecorationType.CHANDELIER: {
			"id": 35,
			"name": "吊灯",
			"material": "metal",
			"texture": "chandelier",
			"color": Color(0.8, 0.7, 0.4),
			"roughness": 0.2,
			"metallic": 0.8,
			"emission": Color(1.0, 0.9, 0.7),
			"emission_energy": 1.2,
			"size": Vector3(0.2, 0.3, 0.2)
		},
		DecorationType.FOUNTAIN: {
			"id": 36,
			"name": "喷泉",
			"material": "stone",
			"texture": "fountain",
			"color": Color(0.7, 0.7, 0.8),
			"roughness": 0.4,
			"metallic": 0.1,
			"size": Vector3(0.3, 0.4, 0.3)
		},
		DecorationType.STATUE: {
			"id": 37,
			"name": "雕像",
			"material": "stone",
			"texture": "statue",
			"color": Color(0.8, 0.8, 0.9),
			"roughness": 0.3,
			"metallic": 0.0,
			"size": Vector3(0.2, 0.5, 0.2)
		},
		DecorationType.BANNER: {
			"id": 38,
			"name": "旗帜",
			"material": "fabric",
			"texture": "banner",
			"color": Color(0.8, 0.2, 0.2),
			"roughness": 0.9,
			"metallic": 0.0,
			"size": Vector3(0.1, 0.4, 0.3)
		},
		DecorationType.ORNAMENT: {
			"id": 39,
			"name": "装饰品",
			"material": "decorative",
			"texture": "ornament",
			"color": Color(0.9, 0.7, 0.3),
			"roughness": 0.5,
			"metallic": 0.3,
			"size": Vector3(0.15, 0.15, 0.15)
		},
		DecorationType.TORCH: {
			"id": 40,
			"name": "火把",
			"material": "wood",
			"texture": "torch",
			"color": Color(0.6, 0.4, 0.2),
			"roughness": 0.7,
			"metallic": 0.0,
			"emission": Color(1.0, 0.6, 0.2),
			"emission_energy": 0.8,
			"size": Vector3(0.1, 0.3, 0.1)
		},
		DecorationType.LAMP: {
			"id": 41,
			"name": "灯具",
			"material": "metal",
			"texture": "lamp",
			"color": Color(0.7, 0.7, 0.8),
			"roughness": 0.3,
			"metallic": 0.6,
			"emission": Color(1.0, 0.9, 0.8),
			"emission_energy": 1.0,
			"size": Vector3(0.15, 0.2, 0.15)
		},
		DecorationType.PILLAR: {
			"id": 42,
			"name": "柱子",
			"material": "stone",
			"texture": "pillar",
			"color": Color(0.7, 0.7, 0.7),
			"roughness": 0.5,
			"metallic": 0.1,
			"size": Vector3(0.2, 0.8, 0.2)
		},
		DecorationType.THRONE: {
			"id": 43,
			"name": "王座",
			"material": "stone",
			"texture": "throne",
			"color": Color(0.6, 0.4, 0.8),
			"roughness": 0.4,
			"metallic": 0.2,
			"emission": Color(0.3, 0.2, 0.4),
			"emission_energy": 0.3,
			"size": Vector3(0.3, 0.6, 0.3)
		},
		DecorationType.ALTAR: {
			"id": 44,
			"name": "祭坛",
			"material": "stone",
			"texture": "altar",
			"color": Color(0.5, 0.3, 0.6),
			"roughness": 0.3,
			"metallic": 0.1,
			"emission": Color(0.2, 0.1, 0.3),
			"emission_energy": 0.2,
			"size": Vector3(0.3, 0.3, 0.3)
		},
		DecorationType.PORTAL: {
			"id": 45,
			"name": "传送门",
			"material": "magic",
			"texture": "portal",
			"color": Color(0.2, 0.8, 0.9),
			"roughness": 0.0,
			"metallic": 0.0,
			"emission": Color(0.1, 0.6, 0.7),
			"emission_energy": 1.5,
			"size": Vector3(0.3, 0.6, 0.1)
		},
		DecorationType.RITUAL_CIRCLE: {
			"id": 46,
			"name": "仪式圈",
			"material": "magic",
			"texture": "ritual_circle",
			"color": Color(0.8, 0.2, 0.8),
			"roughness": 0.0,
			"metallic": 0.0,
			"emission": Color(0.6, 0.1, 0.6),
			"emission_energy": 0.9,
			"size": Vector3(0.3, 0.05, 0.3)
		},
		DecorationType.MAGIC_FOUNTAIN: {
			"id": 47,
			"name": "魔法喷泉",
			"material": "magic",
			"texture": "magic_fountain",
			"color": Color(0.3, 0.6, 0.9),
			"roughness": 0.2,
			"metallic": 0.1,
			"emission": Color(0.2, 0.4, 0.7),
			"emission_energy": 0.6,
			"size": Vector3(0.3, 0.4, 0.3)
		},
		DecorationType.CRYSTAL_GROWTH: {
			"id": 48,
			"name": "水晶生长",
			"material": "crystal",
			"texture": "crystal_growth",
			"color": Color(0.4, 0.2, 0.9),
			"roughness": 0.0,
			"metallic": 0.0,
			"emission": Color(0.3, 0.1, 0.7),
			"emission_energy": 1.1,
			"size": Vector3(0.25, 0.4, 0.25)
		},
		DecorationType.SHADOW_VEIL: {
			"id": 49,
			"name": "暗影面纱",
			"material": "shadow",
			"texture": "shadow_veil",
			"color": Color(0.1, 0.1, 0.2),
			"roughness": 0.0,
			"metallic": 0.0,
			"emission": Color(0.05, 0.05, 0.1),
			"emission_energy": 0.4,
			"transparency": 0.7,
			"size": Vector3(0.3, 0.3, 0.3)
		}
	}


func assemble_layer(decoration_data: Dictionary):
	"""组装装饰层"""
	if not gridmap:
		LogManager.error("❌ [DecorationLayerManager] GridMap未设置")
		return
	
	LogManager.info("🏗️ [DecorationLayerManager] 开始组装装饰层，数据量: %d" % decoration_data.size())
	
	var cell_count = 0
	for pos_str in decoration_data:
		var pos = _parse_position(pos_str)
		var decoration_type = decoration_data[pos_str]
		
		if decoration_type in decoration_components:
			var component = decoration_components[decoration_type]
			gridmap.set_cell_item(Vector3i(pos.x, pos.y, pos.z), component.id)
			cell_count += 1
		else:
			LogManager.warning("⚠️ [DecorationLayerManager] 未知装饰类型: %s" % str(decoration_type))
	
	decoration_updated.emit(cell_count)
	LogManager.info("✅ [DecorationLayerManager] 装饰层组装完成，放置了 %d 个装饰组件" % cell_count)


func place_decoration_component(position: Vector3i, decoration_type: DecorationType):
	"""放置装饰组件"""
	if not gridmap:
		LogManager.error("❌ [DecorationLayerManager] GridMap未设置")
		return false
	
	if decoration_type in decoration_components:
		var component = decoration_components[decoration_type]
		gridmap.set_cell_item(position, component.id)
		LogManager.info("🏗️ [DecorationLayerManager] 放置装饰组件: %s 在位置 %s" % [component.name, str(position)])
		return true
	else:
		LogManager.warning("⚠️ [DecorationLayerManager] 未知装饰类型: %s" % str(decoration_type))
		return false


func remove_decoration_component(position: Vector3i):
	"""移除装饰组件"""
	if not gridmap:
		LogManager.error("❌ [DecorationLayerManager] GridMap未设置")
		return false
	
	gridmap.set_cell_item(position, -1)
	LogManager.info("🗑️ [DecorationLayerManager] 移除位置 %s 的装饰组件" % str(position))
	return true


func get_decoration_component_info(position: Vector3i) -> Dictionary:
	"""获取装饰组件信息"""
	if not gridmap:
		return {}
	
	var item_id = gridmap.get_cell_item(position)
	if item_id == -1:
		return {}
	
	# 查找对应的组件信息
	for decoration_type in decoration_components:
		if decoration_components[decoration_type].id == item_id:
			return decoration_components[decoration_type]
	
	return {}


func set_config(config: Dictionary):
	"""设置装饰层配置"""
	decoration_config = config
	LogManager.info("⚙️ [DecorationLayerManager] 装饰层配置已更新")


func get_layer_info() -> Dictionary:
	"""获取装饰层信息"""
	if not gridmap:
		return {"cell_count": 0, "components": []}
	
	var used_cells = gridmap.get_used_cells()
	var components = []
	
	for cell in used_cells:
		var item_id = gridmap.get_cell_item(cell)
		var component_info = get_decoration_component_info(cell)
		if not component_info.is_empty():
			components.append({
				"position": cell,
				"component": component_info
			})
	
	return {
		"cell_count": used_cells.size(),
		"components": components
	}


func _parse_position(pos_str: String) -> Vector3:
	"""解析位置字符串"""
	var parts = pos_str.split(",")
	if parts.size() == 3:
		return Vector3(float(parts[0]), float(parts[1]), float(parts[2]))
	return Vector3.ZERO
