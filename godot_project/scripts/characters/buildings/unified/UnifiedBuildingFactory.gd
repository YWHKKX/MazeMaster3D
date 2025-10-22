extends Node
class_name UnifiedBuildingFactory

## 🏭 统一建筑工厂
## 用于创建和管理统一建筑系统

static func create_building(building_type: BuildingTypes.BuildingType, render_mode: BuildingRenderMode.RenderMode = BuildingRenderMode.RenderMode.GRIDMAP) -> UnifiedBuildingSystem:
	"""创建统一建筑
	
	Args:
		building_type: 建筑类型
		render_mode: 渲染模式
		
	Returns:
		UnifiedBuildingSystem: 创建的建筑实例
	"""
	# 使用迁移器创建建筑
	var building = UnifiedBuildingMigrator.create_unified_building(building_type)
	
	if building:
		building.render_mode = render_mode
		LogManager.info("🏭 [UnifiedBuildingFactory] 创建建筑: %s (渲染模式: %s)" % [building.building_name, BuildingRenderMode.RenderMode.keys()[render_mode]])
	else:
		LogManager.warning("⚠️ [UnifiedBuildingFactory] 创建建筑失败: %s" % BuildingTypes.BuildingType.keys()[building_type])
	
	return building


static func create_arcane_tower(render_mode: BuildingRenderMode.RenderMode = BuildingRenderMode.RenderMode.GRIDMAP) -> UnifiedArcaneTower:
	"""创建奥术塔"""
	var tower = UnifiedArcaneTower.new()
	tower.render_mode = render_mode
	return tower


static func _create_arrow_tower() -> UnifiedArrowTower:
	"""创建箭塔"""
	var building = UnifiedArrowTower.new()
	return building


static func _create_treasury() -> UnifiedTreasury:
	"""创建金库"""
	var building = UnifiedTreasury.new()
	return building


static func _create_barracks() -> UnifiedBuildingSystem:
	"""创建兵营"""
	var building = UnifiedBuildingSystem.new()
	building.building_type = BuildingTypes.BuildingType.BARRACKS
	building.building_name = "兵营"
	building.max_health = 180
	building.health = 180
	building.armor = 4
	building.cost_gold = 600
	building.engineer_cost = 60
	building.build_time = 35.0
	building.engineer_required = 3
	building.building_size = Vector2(2, 2)
	return building


static func _create_library() -> UnifiedBuildingSystem:
	"""创建图书馆"""
	var building = UnifiedBuildingSystem.new()
	building.building_type = BuildingTypes.BuildingType.LIBRARY
	building.building_name = "图书馆"
	building.max_health = 160
	building.health = 160
	building.armor = 2
	building.cost_gold = 350
	building.engineer_cost = 35
	building.build_time = 22.0
	building.engineer_required = 2
	building.building_size = Vector2(1, 1)
	return building


static func _create_workshop() -> UnifiedBuildingSystem:
	"""创建工坊"""
	var building = UnifiedBuildingSystem.new()
	building.building_type = BuildingTypes.BuildingType.WORKSHOP
	building.building_name = "工坊"
	building.max_health = 140
	building.health = 140
	building.armor = 3
	building.cost_gold = 250
	building.engineer_cost = 25
	building.build_time = 18.0
	building.engineer_required = 1
	building.building_size = Vector2(1, 1)
	return building


static func _create_factory() -> UnifiedBuildingSystem:
	"""创建工厂"""
	var building = UnifiedBuildingSystem.new()
	building.building_type = BuildingTypes.BuildingType.FACTORY
	building.building_name = "工厂"
	building.max_health = 220
	building.health = 220
	building.armor = 6
	building.cost_gold = 800
	building.engineer_cost = 80
	building.build_time = 45.0
	building.engineer_required = 4
	building.building_size = Vector2(2, 2)
	return building


static func _create_hospital() -> UnifiedBuildingSystem:
	"""创建医院"""
	var building = UnifiedBuildingSystem.new()
	building.building_type = BuildingTypes.BuildingType.HOSPITAL
	building.building_name = "医院"
	building.max_health = 170
	building.health = 170
	building.armor = 2
	building.cost_gold = 450
	building.engineer_cost = 45
	building.build_time = 28.0
	building.engineer_required = 2
	building.building_size = Vector2(1, 1)
	return building


static func _create_market() -> UnifiedBuildingSystem:
	"""创建市场"""
	var building = UnifiedBuildingSystem.new()
	building.building_type = BuildingTypes.BuildingType.MARKET
	building.building_name = "市场"
	building.max_health = 150
	building.health = 150
	building.armor = 1
	building.cost_gold = 300
	building.engineer_cost = 30
	building.build_time = 20.0
	building.engineer_required = 1
	building.building_size = Vector2(1, 1)
	return building


static func _create_academy() -> UnifiedBuildingSystem:
	"""创建学院"""
	var building = UnifiedBuildingSystem.new()
	building.building_type = BuildingTypes.BuildingType.ACADEMY
	building.building_name = "学院"
	building.max_health = 190
	building.health = 190
	building.armor = 3
	building.cost_gold = 700
	building.engineer_cost = 70
	building.build_time = 40.0
	building.engineer_required = 3
	building.building_size = Vector2(2, 2)
	return building


static func _create_demon_lair() -> UnifiedBuildingSystem:
	"""创建恶魔巢穴"""
	var building = UnifiedBuildingSystem.new()
	building.building_type = BuildingTypes.BuildingType.DEMON_LAIR
	building.building_name = "恶魔巢穴"
	building.max_health = 200
	building.health = 200
	building.armor = 5
	building.cost_gold = 600
	building.engineer_cost = 60
	building.build_time = 35.0
	building.engineer_required = 3
	building.building_size = Vector2(2, 2)
	return building


static func _create_orc_lair() -> UnifiedBuildingSystem:
	"""创建兽人巢穴"""
	var building = UnifiedBuildingSystem.new()
	building.building_type = BuildingTypes.BuildingType.ORC_LAIR
	building.building_name = "兽人巢穴"
	building.max_health = 180
	building.health = 180
	building.armor = 4
	building.cost_gold = 500
	building.engineer_cost = 50
	building.build_time = 30.0
	building.engineer_required = 2
	building.building_size = Vector2(2, 2)
	return building


static func _create_shadow_temple() -> UnifiedBuildingSystem:
	"""创建暗影神殿"""
	var building = UnifiedBuildingSystem.new()
	building.building_type = BuildingTypes.BuildingType.SHADOW_TEMPLE
	building.building_name = "暗影神殿"
	building.max_health = 250
	building.health = 250
	building.armor = 7
	building.cost_gold = 1000
	building.engineer_cost = 100
	building.build_time = 60.0
	building.engineer_required = 5
	building.building_size = Vector2(3, 3)
	return building


static func _create_dungeon_heart() -> UnifiedBuildingSystem:
	"""创建地牢之心"""
	var building = UnifiedBuildingSystem.new()
	building.building_type = BuildingTypes.BuildingType.DUNGEON_HEART
	building.building_name = "地牢之心"
	building.max_health = 300
	building.health = 300
	building.armor = 10
	building.cost_gold = 1500
	building.engineer_cost = 150
	building.build_time = 90.0
	building.engineer_required = 8
	building.building_size = Vector2(3, 3)
	return building


static func _create_magic_altar() -> UnifiedBuildingSystem:
	"""创建魔法祭坛"""
	var building = UnifiedBuildingSystem.new()
	building.building_type = BuildingTypes.BuildingType.MAGIC_ALTAR
	building.building_name = "魔法祭坛"
	building.max_health = 120
	building.health = 120
	building.armor = 2
	building.cost_gold = 200
	building.engineer_cost = 20
	building.build_time = 15.0
	building.engineer_required = 1
	building.building_size = Vector2(1, 1)
	return building


static func _create_magic_research_institute() -> UnifiedBuildingSystem:
	"""创建魔法研究院"""
	var building = UnifiedBuildingSystem.new()
	building.building_type = BuildingTypes.BuildingType.MAGIC_RESEARCH_INSTITUTE
	building.building_name = "魔法研究院"
	building.max_health = 220
	building.health = 220
	building.armor = 4
	building.cost_gold = 900
	building.engineer_cost = 90
	building.build_time = 50.0
	building.engineer_required = 4
	building.building_size = Vector2(2, 2)
	return building


static func get_supported_building_types() -> Array[BuildingTypes.BuildingType]:
	"""获取支持的建筑类型列表"""
	return [
		BuildingTypes.BuildingType.ARCANE_TOWER,
		BuildingTypes.BuildingType.ARROW_TOWER,
		BuildingTypes.BuildingType.TREASURY,
		BuildingTypes.BuildingType.BARRACKS,
		BuildingTypes.BuildingType.LIBRARY,
		BuildingTypes.BuildingType.WORKSHOP,
		BuildingTypes.BuildingType.FACTORY,
		BuildingTypes.BuildingType.HOSPITAL,
		BuildingTypes.BuildingType.MARKET,
		BuildingTypes.BuildingType.ACADEMY,
		BuildingTypes.BuildingType.DEMON_LAIR,
		BuildingTypes.BuildingType.ORC_LAIR,
		BuildingTypes.BuildingType.SHADOW_TEMPLE,
		BuildingTypes.BuildingType.DUNGEON_HEART,
		BuildingTypes.BuildingType.MAGIC_ALTAR,
		BuildingTypes.BuildingType.MAGIC_RESEARCH_INSTITUTE
	]


static func get_render_mode_recommendations() -> Dictionary:
	"""获取渲染模式推荐"""
	return {
		BuildingTypes.BuildingType.ARCANE_TOWER: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.ARROW_TOWER: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.TREASURY: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.BARRACKS: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.LIBRARY: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.WORKSHOP: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.FACTORY: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.HOSPITAL: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.MARKET: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.ACADEMY: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.DEMON_LAIR: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.ORC_LAIR: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.SHADOW_TEMPLE: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.DUNGEON_HEART: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.MAGIC_ALTAR: BuildingRenderMode.RenderMode.GRIDMAP,
		BuildingTypes.BuildingType.MAGIC_RESEARCH_INSTITUTE: BuildingRenderMode.RenderMode.GRIDMAP
	}
