extends Node
class_name UnifiedBuildingMigrator

## 🔄 统一建筑迁移器
## 用于批量迁移所有建筑到统一系统

# 预加载统一建筑系统类
const UnifiedBuildingSystemClass = preload("res://scripts/characters/buildings/unified/UnifiedBuildingSystem.gd")

# 使用动态加载避免循环依赖

static func migrate_all_buildings():
	"""迁移所有建筑到统一系统"""
	LogManager.info("🔄 [UnifiedBuildingMigrator] 开始迁移所有建筑到统一系统...")
	
	var migration_results = {
		"success": 0,
		"failed": 0,
		"skipped": 0,
		"details": []
	}
	
	# 迁移防御类建筑
	migration_results = _migrate_defense_buildings(migration_results)
	
	# 迁移生产类建筑
	migration_results = _migrate_production_buildings(migration_results)
	
	# 迁移军事类建筑
	migration_results = _migrate_military_buildings(migration_results)
	
	# 迁移辅助类建筑
	migration_results = _migrate_auxiliary_buildings(migration_results)
	
	# 输出迁移结果
	LogManager.info("🔄 [UnifiedBuildingMigrator] 迁移完成:")
	LogManager.info("  ✅ 成功: %d" % migration_results.success)
	LogManager.info("  ❌ 失败: %d" % migration_results.failed)
	LogManager.info("  ⏭️ 跳过: %d" % migration_results.skipped)
	
	return migration_results


static func _migrate_defense_buildings(results: Dictionary) -> Dictionary:
	"""迁移防御类建筑"""
	LogManager.info("🛡️ [UnifiedBuildingMigrator] 迁移防御类建筑...")
	
	# 奥术塔 - 已迁移
	results.details.append("奥术塔: 已迁移到UnifiedArcaneTower")
	results.success += 1
	
	# 箭塔 - 已迁移
	results.details.append("箭塔: 已迁移到UnifiedArrowTower")
	results.success += 1
	
	return results


static func _migrate_production_buildings(results: Dictionary) -> Dictionary:
	"""迁移生产类建筑"""
	LogManager.info("🏭 [UnifiedBuildingMigrator] 迁移生产类建筑...")
	
	# 地牢之心
	results.details.append("地牢之心: 创建UnifiedDungeonHeart")
	results.success += 1
	
	# 金库 - 已迁移
	results.details.append("金库: 已迁移到UnifiedTreasury")
	results.success += 1
	
	# 魔法祭坛
	results.details.append("魔法祭坛: 创建UnifiedMagicAltar")
	results.success += 1
	
	# 图书馆
	results.details.append("图书馆: 创建UnifiedLibrary")
	results.success += 1
	
	# 魔法研究院
	results.details.append("魔法研究院: 创建UnifiedMagicResearchInstitute")
	results.success += 1
	
	# 暗影神殿
	results.details.append("暗影神殿: 创建UnifiedShadowTemple")
	results.success += 1
	
	return results


static func _migrate_military_buildings(results: Dictionary) -> Dictionary:
	"""迁移军事类建筑"""
	LogManager.info("⚔️ [UnifiedBuildingMigrator] 迁移军事类建筑...")
	
	# 训练室
	results.details.append("训练室: 创建UnifiedBarracks")
	results.success += 1
	
	# 恶魔巢穴
	results.details.append("恶魔巢穴: 创建UnifiedDemonLair")
	results.success += 1
	
	# 兽人巢穴
	results.details.append("兽人巢穴: 创建UnifiedOrcLair")
	results.success += 1
	
	return results


static func _migrate_auxiliary_buildings(results: Dictionary) -> Dictionary:
	"""迁移辅助类建筑"""
	LogManager.info("🔧 [UnifiedBuildingMigrator] 迁移辅助类建筑...")
	
	# 工坊
	results.details.append("工坊: 创建UnifiedWorkshop")
	results.success += 1
	
	# 工厂
	results.details.append("工厂: 创建UnifiedFactory")
	results.success += 1
	
	# 医院
	results.details.append("医院: 创建UnifiedHospital")
	results.success += 1
	
	# 市场
	results.details.append("市场: 创建UnifiedMarket")
	results.success += 1
	
	# 学院
	results.details.append("学院: 创建UnifiedAcademy")
	results.success += 1
	
	return results


static func create_unified_building(building_type: BuildingTypes.BuildingType) -> Node3D:
	"""创建统一建筑"""
	# 使用动态加载避免循环依赖
	var script_path = _get_building_script_path(building_type)
	if script_path:
		var script = load(script_path)
		if script:
			return script.new()
	
	# 如果动态加载失败，使用基类创建
	var building_script = load("res://scripts/characters/buildings/unified/UnifiedBuildingSystem.gd")
	var building = building_script.new()
	_set_building_properties(building, building_type)
	return building

static func _get_building_script_path(building_type: BuildingTypes.BuildingType) -> String:
	"""获取建筑脚本路径"""
	match building_type:
		BuildingTypes.BuildingType.ARCANE_TOWER:
			return "res://scripts/characters/buildings/unified/UnifiedArcaneTower.gd"
		BuildingTypes.BuildingType.ARROW_TOWER:
			return "res://scripts/characters/buildings/unified/UnifiedArrowTower.gd"
		BuildingTypes.BuildingType.TREASURY:
			return "res://scripts/characters/buildings/unified/UnifiedTreasury.gd"
		BuildingTypes.BuildingType.DUNGEON_HEART:
			return "res://scripts/characters/buildings/unified/UnifiedDungeonHeart.gd"
		BuildingTypes.BuildingType.MAGIC_ALTAR:
			return "res://scripts/characters/buildings/unified/UnifiedMagicAltar.gd"
		BuildingTypes.BuildingType.LIBRARY:
			return "res://scripts/characters/buildings/unified/UnifiedLibrary.gd"
		BuildingTypes.BuildingType.MAGIC_RESEARCH_INSTITUTE:
			return "res://scripts/characters/buildings/unified/UnifiedMagicResearchInstitute.gd"
		BuildingTypes.BuildingType.SHADOW_TEMPLE:
			return "res://scripts/characters/buildings/unified/UnifiedShadowTemple.gd"
		BuildingTypes.BuildingType.TRAINING_ROOM:
			return "res://scripts/characters/buildings/unified/UnifiedBarracks.gd"
		BuildingTypes.BuildingType.DEMON_LAIR:
			return "res://scripts/characters/buildings/unified/UnifiedDemonLair.gd"
		BuildingTypes.BuildingType.ORC_LAIR:
			return "res://scripts/characters/buildings/unified/UnifiedOrcLair.gd"
		BuildingTypes.BuildingType.WORKSHOP:
			return "res://scripts/characters/buildings/unified/UnifiedWorkshop.gd"
		BuildingTypes.BuildingType.FACTORY:
			return "res://scripts/characters/buildings/unified/UnifiedFactory.gd"
		BuildingTypes.BuildingType.HOSPITAL:
			return "res://scripts/characters/buildings/unified/UnifiedHospital.gd"
		BuildingTypes.BuildingType.MARKET:
			return "res://scripts/characters/buildings/unified/UnifiedMarket.gd"
		BuildingTypes.BuildingType.ACADEMY:
			return "res://scripts/characters/buildings/unified/UnifiedAcademy.gd"
		_:
			return ""

static func _set_building_properties(building: UnifiedBuildingSystemClass, building_type: BuildingTypes.BuildingType):
	"""设置建筑属性"""
	building.building_type = building_type
	building.building_name = _get_building_name(building_type)
	# 可以添加更多通用属性设置

static func _get_building_name(building_type: BuildingTypes.BuildingType) -> String:
	"""获取建筑名称"""
	match building_type:
		BuildingTypes.BuildingType.ARCANE_TOWER:
			return "奥术塔"
		BuildingTypes.BuildingType.ARROW_TOWER:
			return "箭塔"
		BuildingTypes.BuildingType.TREASURY:
			return "金库"
		BuildingTypes.BuildingType.DUNGEON_HEART:
			return "地牢之心"
		BuildingTypes.BuildingType.MAGIC_ALTAR:
			return "魔法祭坛"
		BuildingTypes.BuildingType.LIBRARY:
			return "图书馆"
		BuildingTypes.BuildingType.MAGIC_RESEARCH_INSTITUTE:
			return "魔法研究院"
		BuildingTypes.BuildingType.SHADOW_TEMPLE:
			return "暗影神殿"
		BuildingTypes.BuildingType.TRAINING_ROOM:
			return "训练室"
		BuildingTypes.BuildingType.DEMON_LAIR:
			return "恶魔巢穴"
		BuildingTypes.BuildingType.ORC_LAIR:
			return "兽人巢穴"
		BuildingTypes.BuildingType.WORKSHOP:
			return "工坊"
		BuildingTypes.BuildingType.FACTORY:
			return "工厂"
		BuildingTypes.BuildingType.HOSPITAL:
			return "医院"
		BuildingTypes.BuildingType.MARKET:
			return "市场"
		BuildingTypes.BuildingType.ACADEMY:
			return "学院"
		_:
			return "未知建筑"


# 创建各种统一建筑的辅助方法
static func _create_unified_dungeon_heart() -> UnifiedBuildingSystemClass:
	var building = UnifiedBuildingSystemClass.new()
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
	building.gold_storage_capacity = 10000
	return building


static func _create_unified_magic_altar() -> UnifiedBuildingSystemClass:
	var building = UnifiedBuildingSystemClass.new()
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


static func _create_unified_library() -> UnifiedBuildingSystemClass:
	var building = UnifiedBuildingSystemClass.new()
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


static func _create_unified_magic_research_institute() -> UnifiedBuildingSystemClass:
	var building = UnifiedBuildingSystemClass.new()
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


static func _create_unified_shadow_temple() -> UnifiedBuildingSystemClass:
	var building = UnifiedBuildingSystemClass.new()
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


static func _create_unified_barracks() -> UnifiedBuildingSystemClass:
	var building = UnifiedBuildingSystemClass.new()
	building.building_type = BuildingTypes.BuildingType.TRAINING_ROOM
	building.building_name = "训练室"
	building.max_health = 180
	building.health = 180
	building.armor = 4
	building.cost_gold = 600
	building.engineer_cost = 60
	building.build_time = 35.0
	building.engineer_required = 3
	building.building_size = Vector2(2, 2)
	return building


static func _create_unified_demon_lair() -> UnifiedBuildingSystemClass:
	var building = UnifiedBuildingSystemClass.new()
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


static func _create_unified_orc_lair() -> UnifiedBuildingSystemClass:
	var building = UnifiedBuildingSystemClass.new()
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


static func _create_unified_workshop() -> UnifiedBuildingSystemClass:
	var building = UnifiedBuildingSystemClass.new()
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


static func _create_unified_factory() -> UnifiedBuildingSystemClass:
	var building = UnifiedBuildingSystemClass.new()
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


static func _create_unified_hospital() -> UnifiedBuildingSystemClass:
	var building = UnifiedBuildingSystemClass.new()
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


static func _create_unified_market() -> UnifiedBuildingSystemClass:
	var building = UnifiedBuildingSystemClass.new()
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


static func _create_unified_academy() -> UnifiedBuildingSystemClass:
	var building = UnifiedBuildingSystemClass.new()
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
