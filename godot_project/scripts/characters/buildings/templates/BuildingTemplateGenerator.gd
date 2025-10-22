extends RefCounted
class_name BuildingTemplateGenerator

## 🏗️ 建筑模板生成器
## 支持自由组件和传统网格建筑模板生成

# ========================================
# 自由组件建筑模板生成方法
# ========================================

static func generate_free_dungeon_heart_template() -> Dictionary:
	"""生成自由组件地牢之心模板 (2x2瓦块)"""
	var template = {
		"building_size": Vector3(2, 2, 2),
		"components": [],
		"allow_free_placement": true
	}
	
	# 添加地牢之心核心组件
	template["components"].append({
		"name": "Heart_Core",
		"position": Vector3(0.8, 0.8, 0.8),
		"size": Vector3(0.4, 0.4, 0.4),
		"type": "decoration"
	})
	
	# 添加能量水晶
	var crystal_positions = [
		Vector3(0.2, 1.6, 0.2),
		Vector3(1.4, 1.6, 0.2),
		Vector3(0.2, 1.6, 1.4),
		Vector3(1.4, 1.6, 1.4)
	]
	
	for i in range(crystal_positions.size()):
		template["components"].append({
			"name": "Energy_Crystal_" + str(i + 1),
			"position": crystal_positions[i],
			"size": Vector3(0.2, 0.3, 0.2),
			"type": "decoration"
		})
	
	# 添加魔力水晶
	var mana_positions = [
		Vector3(0.8, 1.6, 0.2),
		Vector3(0.8, 1.6, 1.4)
	]
	
	for i in range(mana_positions.size()):
		template["components"].append({
			"name": "Mana_Crystal_" + str(i + 1),
			"position": mana_positions[i],
			"size": Vector3(0.15, 0.25, 0.15),
			"type": "decoration"
		})
	
	# 添加魔法核心
	template["components"].append({
		"name": "Magic_Core",
		"position": Vector3(0.8, 1.6, 0.8),
		"size": Vector3(0.3, 0.3, 0.3),
		"type": "decoration"
	})
	
	# 添加能量管道
	var conduit_positions = [
		Vector3(0.2, 1.6, 0.8),
		Vector3(1.4, 1.6, 0.8)
	]
	
	for i in range(conduit_positions.size()):
		template["components"].append({
			"name": "Energy_Conduit_" + str(i + 1),
			"position": conduit_positions[i],
			"size": Vector3(0.1, 0.2, 0.4),
			"type": "decoration"
		})
	
	# 添加能量节点
	var node_positions = [
		Vector3(0.8, 0.8, 0.2),
		Vector3(0.2, 0.8, 0.8),
		Vector3(1.4, 0.8, 0.8),
		Vector3(0.8, 0.8, 1.4)
	]
	
	for i in range(node_positions.size()):
		template["components"].append({
			"name": "Energy_Node_" + str(i + 1),
			"position": node_positions[i],
			"size": Vector3(0.15, 0.15, 0.15),
			"type": "decoration"
		})
	
	# 添加存储核心
	template["components"].append({
		"name": "Storage_Core",
		"position": Vector3(0.8, 0.4, 0.8),
		"size": Vector3(0.3, 0.2, 0.3),
		"type": "decoration"
	})
	
	# 添加地牢之心入口
	template["components"].append({
		"name": "Heart_Entrance",
		"position": Vector3(0.8, 0, 0.8),
		"size": Vector3(0.4, 0.8, 0.1),
		"type": "door"
	})
	
	# 添加地牢石结构
	var stone_positions = [
		# 底部层
		Vector3(0, 0, 0), Vector3(0.8, 0, 0), Vector3(1.6, 0, 0),
		Vector3(0, 0, 0.8), Vector3(1.6, 0, 0.8),
		Vector3(0, 0, 1.6), Vector3(0.8, 0, 1.6), Vector3(1.6, 0, 1.6),
		# 中间层
		Vector3(0, 0.8, 0), Vector3(1.6, 0.8, 0),
		Vector3(0, 0.8, 1.6), Vector3(1.6, 0.8, 1.6),
		# 顶部层
		Vector3(0, 1.6, 0), Vector3(0.8, 1.6, 0), Vector3(1.6, 1.6, 0),
		Vector3(0, 1.6, 0.8), Vector3(1.6, 1.6, 0.8),
		Vector3(0, 1.6, 1.6), Vector3(0.8, 1.6, 1.6), Vector3(1.6, 1.6, 1.6)
	]
	
	for i in range(stone_positions.size()):
		template["components"].append({
			"name": "Dungeon_Stone_" + str(i + 1),
			"position": stone_positions[i],
			"size": Vector3(0.8, 0.8, 0.8),
			"type": "structure"
		})
	
	return template


static func generate_free_treasury_template() -> Dictionary:
	"""生成自由组件金库模板 (1x1瓦块)"""
	var template = {
		"building_size": Vector3(1, 1, 1),
		"components": [],
		"allow_free_placement": true
	}
	
	# 添加金库核心组件 - 坐标相对于建筑中心 (0.5, 0, 0.5)
	template["components"].append({
		"name": "Treasury_Main",
		"position": Vector3(0.2, 0, 0.2),
		"size": Vector3(0.6, 1.2, 0.6),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Treasury_Roof",
		"position": Vector3(0.1, 1.2, 0.1),
		"size": Vector3(0.8, 0.1, 0.8),
		"type": "structure"
	})
	
	# 添加金币存储组件
	template["components"].append({
		"name": "Gold_Vault",
		"position": Vector3(0.3, 0.1, 0.3),
		"size": Vector3(0.4, 0.6, 0.4),
		"type": "decoration"
	})
	
	# 添加金币堆
	for i in range(4):
		var positions = [
			Vector3(0.1, 0.05, 0.1),
			Vector3(0.7, 0.05, 0.1),
			Vector3(0.1, 0.05, 0.7),
			Vector3(0.7, 0.05, 0.7)
		]
		template["components"].append({
			"name": "Gold_Pile_" + str(i + 1),
			"position": positions[i],
			"size": Vector3(0.2, 0.1, 0.2),
			"type": "decoration"
		})
	
	# 添加安全特性
	template["components"].append({
		"name": "Security_Lock",
		"position": Vector3(0.4, 0.3, 0.1),
		"size": Vector3(0.2, 0.1, 0.05),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Security_Crystal",
		"position": Vector3(0.4, 0.8, 0.4),
		"size": Vector3(0.2, 0.2, 0.2),
		"type": "decoration"
	})
	
	# 添加入口
	template["components"].append({
		"name": "Treasury_Door",
		"position": Vector3(0.3, 0, 0.1),
		"size": Vector3(0.4, 0.8, 0.1),
		"type": "door"
	})
	
	return template


static func generate_free_arcane_tower_template() -> Dictionary:
	"""生成自由组件奥术塔模板 (1x1瓦块)"""
	var template = {
		"building_size": Vector3(1, 1, 1),
		"components": [],
		"allow_free_placement": true
	}
	
	# 添加塔体结构
	template["components"].append({
		"name": "Tower_Base",
		"position": Vector3(0.2, 0, 0.2),
		"size": Vector3(0.6, 0.3, 0.6),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Tower_Body",
		"position": Vector3(0.25, 0.3, 0.25),
		"size": Vector3(0.5, 1.0, 0.5),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Tower_Top",
		"position": Vector3(0.3, 1.3, 0.3),
		"size": Vector3(0.4, 0.4, 0.4),
		"type": "structure"
	})
	
	# 添加魔法水晶
	template["components"].append({
		"name": "Magic_Crystal_Main",
		"position": Vector3(0.4, 1.4, 0.4),
		"size": Vector3(0.2, 0.3, 0.2),
		"type": "decoration"
	})
	
	# 添加辅助水晶
	var crystal_positions = [
		Vector3(0.1, 0.8, 0.1),
		Vector3(0.75, 0.8, 0.1),
		Vector3(0.1, 0.8, 0.75),
		Vector3(0.75, 0.8, 0.75)
	]
	
	for i in range(crystal_positions.size()):
		template["components"].append({
			"name": "Magic_Crystal_" + str(i + 1),
			"position": crystal_positions[i],
			"size": Vector3(0.15, 0.2, 0.15),
			"type": "decoration"
		})
	
	# 添加奥术球
	template["components"].append({
		"name": "Arcane_Orb_1",
		"position": Vector3(0.2, 0.5, 0.4),
		"size": Vector3(0.1, 0.1, 0.1),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Arcane_Orb_2",
		"position": Vector3(0.7, 0.5, 0.4),
		"size": Vector3(0.1, 0.1, 0.1),
		"type": "decoration"
	})
	
	# 添加符文石
	template["components"].append({
		"name": "Rune_Stone_1",
		"position": Vector3(0.4, 0.1, 0.1),
		"size": Vector3(0.2, 0.1, 0.1),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Rune_Stone_2",
		"position": Vector3(0.4, 0.1, 0.8),
		"size": Vector3(0.2, 0.1, 0.1),
		"type": "decoration"
	})
	
	# 添加法术书
	template["components"].append({
		"name": "Spell_Book_1",
		"position": Vector3(0.1, 0.2, 0.4),
		"size": Vector3(0.1, 0.15, 0.1),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Spell_Book_2",
		"position": Vector3(0.8, 0.2, 0.4),
		"size": Vector3(0.1, 0.15, 0.1),
		"type": "decoration"
	})
	
	# 添加魔法阵
	template["components"].append({
		"name": "Magic_Circle",
		"position": Vector3(0.3, 0.05, 0.3),
		"size": Vector3(0.4, 0.05, 0.4),
		"type": "decoration"
	})
	
	return template


static func generate_free_barracks_template() -> Dictionary:
	"""生成自由组件兵营模板 (2x2瓦块)"""
	var template = {
		"building_size": Vector3(2, 2, 2),
		"components": [],
		"allow_free_placement": true
	}
	
	# 添加兵营主体结构
	template["components"].append({
		"name": "Barracks_Main",
		"position": Vector3(0.5, 0, 0.5),
		"size": Vector3(1.0, 1.5, 1.0),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Barracks_Roof",
		"position": Vector3(0.3, 1.5, 0.3),
		"size": Vector3(1.4, 0.1, 1.4),
		"type": "structure"
	})
	
	# 添加训练场地
	template["components"].append({
		"name": "Training_Ground",
		"position": Vector3(0.2, 0.05, 0.2),
		"size": Vector3(1.6, 0.1, 1.6),
		"type": "floor"
	})
	
	# 添加训练桩
	var post_positions = [
		Vector3(0.3, 0.1, 0.3),
		Vector3(1.3, 0.1, 0.3),
		Vector3(0.3, 0.1, 1.3),
		Vector3(1.3, 0.1, 1.3)
	]
	
	for i in range(post_positions.size()):
		template["components"].append({
			"name": "Training_Post_" + str(i + 1),
			"position": post_positions[i],
			"size": Vector3(0.1, 0.8, 0.1),
			"type": "decoration"
		})
	
	# 添加武器架
	template["components"].append({
		"name": "Weapon_Rack_1",
		"position": Vector3(0.1, 0.1, 0.8),
		"size": Vector3(0.1, 0.6, 0.1),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Weapon_Rack_2",
		"position": Vector3(1.7, 0.1, 0.8),
		"size": Vector3(0.1, 0.6, 0.1),
		"type": "decoration"
	})
	
	# 添加军旗
	template["components"].append({
		"name": "Military_Flag_1",
		"position": Vector3(0.8, 0.1, 0.1),
		"size": Vector3(0.1, 0.8, 0.1),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Military_Flag_2",
		"position": Vector3(0.8, 0.1, 1.7),
		"size": Vector3(0.1, 0.8, 0.1),
		"type": "decoration"
	})
	
	# 添加营火
	template["components"].append({
		"name": "Campfire",
		"position": Vector3(0.8, 0.05, 0.8),
		"size": Vector3(0.4, 0.3, 0.4),
		"type": "decoration"
	})
	
	# 添加盔甲架
	template["components"].append({
		"name": "Armor_Stand_1",
		"position": Vector3(0.2, 0.1, 0.2),
		"size": Vector3(0.2, 0.7, 0.2),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Armor_Stand_2",
		"position": Vector3(1.4, 0.1, 0.2),
		"size": Vector3(0.2, 0.7, 0.2),
		"type": "decoration"
	})
	
	# 添加床铺
	template["components"].append({
		"name": "Barracks_Bunk_1",
		"position": Vector3(0.2, 0.1, 1.4),
		"size": Vector3(0.6, 0.2, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Barracks_Bunk_2",
		"position": Vector3(1.0, 0.1, 1.4),
		"size": Vector3(0.6, 0.2, 0.3),
		"type": "decoration"
	})
	
	# 添加盾牌架
	template["components"].append({
		"name": "Shield_Rack_1",
		"position": Vector3(0.1, 0.1, 0.4),
		"size": Vector3(0.1, 0.5, 0.1),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Shield_Rack_2",
		"position": Vector3(1.7, 0.1, 0.4),
		"size": Vector3(0.1, 0.5, 0.1),
		"type": "decoration"
	})
	
	return template


static func generate_free_workshop_template() -> Dictionary:
	"""生成自由组件工坊模板 (1x1瓦块)"""
	var template = {
		"building_size": Vector3(1, 1, 1),
		"components": [],
		"allow_free_placement": true
	}
	
	# 添加工坊主体结构
	template["components"].append({
		"name": "Workshop_Main",
		"position": Vector3(0.2, 0, 0.2),
		"size": Vector3(0.6, 1.0, 0.6),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Workshop_Roof",
		"position": Vector3(0.1, 1.0, 0.1),
		"size": Vector3(0.8, 0.1, 0.8),
		"type": "structure"
	})
	
	# 添加熔炉组件
	template["components"].append({
		"name": "Forge_Main",
		"position": Vector3(0.3, 0.1, 0.3),
		"size": Vector3(0.4, 0.6, 0.4),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Forge_Flame",
		"position": Vector3(0.35, 0.7, 0.35),
		"size": Vector3(0.3, 0.2, 0.3),
		"type": "decoration"
	})
	
	# 添加工作台组件
	template["components"].append({
		"name": "Workbench_Main",
		"position": Vector3(0.1, 0.1, 0.6),
		"size": Vector3(0.3, 0.1, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Tool_Shelf",
		"position": Vector3(0.6, 0.1, 0.1),
		"size": Vector3(0.3, 0.1, 0.3),
		"type": "decoration"
	})
	
	# 添加工具架
	template["components"].append({
		"name": "Tool_Rack_1",
		"position": Vector3(0.1, 0.2, 0.1),
		"size": Vector3(0.1, 0.6, 0.1),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Tool_Rack_2",
		"position": Vector3(0.8, 0.2, 0.1),
		"size": Vector3(0.1, 0.6, 0.1),
		"type": "decoration"
	})
	
	# 添加材料存储
	template["components"].append({
		"name": "Material_Pile_1",
		"position": Vector3(0.1, 0.05, 0.8),
		"size": Vector3(0.2, 0.1, 0.2),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Material_Pile_2",
		"position": Vector3(0.7, 0.05, 0.8),
		"size": Vector3(0.2, 0.1, 0.2),
		"type": "decoration"
	})
	
	# 添加制作工具
	template["components"].append({
		"name": "Anvil",
		"position": Vector3(0.4, 0.05, 0.6),
		"size": Vector3(0.2, 0.15, 0.2),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Hammer",
		"position": Vector3(0.5, 0.2, 0.5),
		"size": Vector3(0.1, 0.3, 0.1),
		"type": "decoration"
	})
	
	return template


static func generate_free_magic_altar_template() -> Dictionary:
	"""生成自由组件魔法祭坛模板 (1x1瓦块)"""
	var template = {
		"building_size": Vector3(1, 1, 1),
		"components": [],
		"allow_free_placement": true
	}
	
	# 添加祭坛主体结构
	template["components"].append({
		"name": "Altar_Base",
		"position": Vector3(0.2, 0, 0.2),
		"size": Vector3(0.6, 0.2, 0.6),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Altar_Top",
		"position": Vector3(0.1, 0.2, 0.1),
		"size": Vector3(0.8, 0.1, 0.8),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Altar_Pillar",
		"position": Vector3(0.4, 0.3, 0.4),
		"size": Vector3(0.2, 0.8, 0.2),
		"type": "structure"
	})
	
	# 添加魔法水晶
	template["components"].append({
		"name": "Magic_Crystal_Main",
		"position": Vector3(0.4, 1.1, 0.4),
		"size": Vector3(0.2, 0.3, 0.2),
		"type": "decoration"
	})
	
	# 添加辅助水晶
	var crystal_positions = [
		Vector3(0.1, 0.3, 0.1),
		Vector3(0.75, 0.3, 0.1),
		Vector3(0.1, 0.3, 0.75),
		Vector3(0.75, 0.3, 0.75)
	]
	
	for i in range(crystal_positions.size()):
		template["components"].append({
			"name": "Magic_Crystal_" + str(i + 1),
			"position": crystal_positions[i],
			"size": Vector3(0.15, 0.2, 0.15),
			"type": "decoration"
		})
	
	# 添加符文圈
	template["components"].append({
		"name": "Rune_Circle_Outer",
		"position": Vector3(0.2, 0.05, 0.2),
		"size": Vector3(0.6, 0.05, 0.6),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Rune_Circle_Inner",
		"position": Vector3(0.35, 0.1, 0.35),
		"size": Vector3(0.3, 0.05, 0.3),
		"type": "decoration"
	})
	
	# 添加仪式蜡烛
	var candle_positions = [
		Vector3(0.3, 0.3, 0.3),
		Vector3(0.65, 0.3, 0.3),
		Vector3(0.3, 0.3, 0.65),
		Vector3(0.65, 0.3, 0.65)
	]
	
	for i in range(candle_positions.size()):
		template["components"].append({
			"name": "Ritual_Candle_" + str(i + 1),
			"position": candle_positions[i],
			"size": Vector3(0.05, 0.2, 0.05),
			"type": "decoration"
		})
	
	# 添加魔法光环
	template["components"].append({
		"name": "Magic_Aura",
		"position": Vector3(0.4, 0.05, 0.4),
		"size": Vector3(0.2, 0.1, 0.2),
		"type": "decoration"
	})
	
	return template


static func generate_free_shadow_temple_template() -> Dictionary:
	"""生成自由组件暗影神殿模板 (3x3瓦块)"""
	var template = {
		"building_size": Vector3(3, 3, 3),
		"components": [],
		"allow_free_placement": true
	}
	
	# 添加神殿主体结构
	template["components"].append({
		"name": "Temple_Base",
		"position": Vector3(0.5, 0, 0.5),
		"size": Vector3(2.0, 0.3, 2.0),
		"type": "structure"
	})
	
	# 添加神殿墙壁
	template["components"].append({
		"name": "Temple_Wall_North",
		"position": Vector3(0.5, 0.3, 0.1),
		"size": Vector3(2.0, 1.5, 0.2),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Temple_Wall_South",
		"position": Vector3(0.5, 0.3, 2.7),
		"size": Vector3(2.0, 1.5, 0.2),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Temple_Wall_East",
		"position": Vector3(2.7, 0.3, 0.5),
		"size": Vector3(0.2, 1.5, 2.0),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Temple_Wall_West",
		"position": Vector3(0.1, 0.3, 0.5),
		"size": Vector3(0.2, 1.5, 2.0),
		"type": "structure"
	})
	
	# 添加神殿屋顶
	template["components"].append({
		"name": "Temple_Roof",
		"position": Vector3(0.2, 1.8, 0.2),
		"size": Vector3(2.6, 0.2, 2.6),
		"type": "structure"
	})
	
	# 添加暗影祭坛
	template["components"].append({
		"name": "Shadow_Altar",
		"position": Vector3(1.2, 0.3, 1.2),
		"size": Vector3(0.6, 0.8, 0.6),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Altar_Top",
		"position": Vector3(1.1, 1.1, 1.1),
		"size": Vector3(0.8, 0.1, 0.8),
		"type": "decoration"
	})
	
	# 添加主暗影水晶
	template["components"].append({
		"name": "Dark_Crystal_Main",
		"position": Vector3(1.3, 1.2, 1.3),
		"size": Vector3(0.4, 0.6, 0.4),
		"type": "decoration"
	})
	
	# 添加辅助暗影水晶
	var crystal_positions = [
		Vector3(0.5, 0.5, 0.5),
		Vector3(2.0, 0.5, 0.5),
		Vector3(0.5, 0.5, 2.0),
		Vector3(2.0, 0.5, 2.0),
		Vector3(1.0, 0.5, 0.5),
		Vector3(1.5, 0.5, 0.5),
		Vector3(1.0, 0.5, 2.0),
		Vector3(1.5, 0.5, 2.0)
	]
	
	for i in range(crystal_positions.size()):
		template["components"].append({
			"name": "Dark_Crystal_" + str(i + 1),
			"position": crystal_positions[i],
			"size": Vector3(0.2, 0.4, 0.2),
			"type": "decoration"
		})
	
	# 添加暗影支柱
	var pillar_positions = [
		Vector3(0.3, 0.3, 0.3),
		Vector3(2.5, 0.3, 0.3),
		Vector3(0.3, 0.3, 2.5),
		Vector3(2.5, 0.3, 2.5)
	]
	
	for i in range(pillar_positions.size()):
		template["components"].append({
			"name": "Shadow_Pillar_" + str(i + 1),
			"position": pillar_positions[i],
			"size": Vector3(0.2, 1.2, 0.2),
			"type": "decoration"
		})
	
	# 添加黑暗仪式组件
	template["components"].append({
		"name": "Dark_Ritual_Circle",
		"position": Vector3(0.8, 0.05, 0.8),
		"size": Vector3(1.4, 0.1, 1.4),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Dark_Runes",
		"position": Vector3(1.0, 0.1, 1.0),
		"size": Vector3(1.0, 0.05, 1.0),
		"type": "decoration"
	})
	
	# 添加暗影光环
	template["components"].append({
		"name": "Shadow_Aura",
		"position": Vector3(1.2, 0.05, 1.2),
		"size": Vector3(0.6, 0.1, 0.6),
		"type": "decoration"
	})
	
	return template


# ========================================
# 传统网格建筑模板生成方法 (保留兼容性)
# ========================================

static func generate_arcane_tower_template() -> Dictionary:
	"""生成奥术塔3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 魔法防御层
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_MAGIC_CRYSTAL
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_ENERGY_RUNE
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_MAGIC_CRYSTAL
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_ENERGY_RUNE
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_MAGIC_CORE # 攻击平台
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_ENERGY_RUNE
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_MAGIC_CRYSTAL
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_ENERGY_RUNE
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_MAGIC_CRYSTAL
	
	# 层2 (中层) - 主体结构
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_WINDOW_SMALL
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_SUMMONING_CIRCLE # 魔法符文
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_WINDOW_SMALL
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_WALL_STONE
	
	# 层1 (底层) - 基础结构
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_WALL_STONE
	
	return template


static func generate_arrow_tower_template() -> Dictionary:
	"""生成箭塔3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 射击平台
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_ARROW_SLOT # 箭垛
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_CROSSBOW # 射箭口
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_ARROW_SLOT
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_CROSSBOW
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_CROSSBOW # 弩机
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_CROSSBOW
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_ARROW_SLOT
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_CROSSBOW
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_ARROW_SLOT
	
	# 层2 (中层) - 弹药存储
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_AMMO_RACK # 弹药架
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_TRAINING_POST # 旋转台
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_AMMO_RACK
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_WALL_STONE
	
	# 层1 (底层) - 基础结构
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_WALL_STONE
	
	return template


static func generate_treasury_template() -> Dictionary:
	"""生成金库3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 金币存储
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_GOLD_PILE # 金顶
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_GOLD_PILE
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_GOLD_PILE
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_GOLD_PILE
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_TREASURE_CHEST # 金币堆
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_GOLD_PILE
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_GOLD_PILE
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_GOLD_PILE
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_GOLD_PILE
	
	# 层2 (中层) - 金墙
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_WALL_STONE # 金墙
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_TREASURE_CHEST # 金币堆
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_WALL_STONE
	
	# 层1 (底层) - 基础结构
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_WALL_STONE
	
	return template


static func generate_magic_altar_template() -> Dictionary:
	"""生成魔法祭坛3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 祭坛层
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_ENERGY_RUNE # 魔法符文
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_MAGIC_ALTAR # 祭坛
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_ENERGY_RUNE
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_ENERGY_RUNE
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_MANA_POOL # 魔力池
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_ENERGY_RUNE
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_ENERGY_RUNE
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_MAGIC_ALTAR
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_ENERGY_RUNE
	
	# 层2 (中层) - 石柱支撑
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_PILLAR_STONE
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_PILLAR_STONE
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_PILLAR_STONE
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_PILLAR_STONE
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_MAGIC_ALTAR # 祭坛台
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_PILLAR_STONE
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_PILLAR_STONE
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_PILLAR_STONE
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_PILLAR_STONE
	
	# 层1 (底层) - 石基
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_FLOOR_STONE # 石基
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	
	return template


static func generate_library_template() -> Dictionary:
	"""生成图书馆3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 知识层
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_BOOK_PILE
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_BOOK_PILE
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_BOOK_PILE
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_BOOK_PILE
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_KNOWLEDGE_ORB # 知识球
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_BOOK_PILE
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_BOOK_PILE
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_BOOK_PILE
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_BOOK_PILE
	
	# 层2 (中层) - 书架层
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_READING_DESK # 阅读桌
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_BOOKSHELF
	
	# 层1 (底层) - 入口层
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_BOOKSHELF
	
	return template


static func generate_demon_lair_template() -> Dictionary:
	"""生成恶魔巢穴3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 恶魔召唤层
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_DEMON_HORN
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_DEMON_HORN
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_DEMON_HORN
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_DEMON_HORN
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_SUMMONING_CIRCLE # 召唤阵
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_DEMON_HORN
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_DEMON_HORN
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_DEMON_HORN
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_DEMON_HORN
	
	# 层2 (中层) - 地狱火焰层
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_DARK_FLAME # 地狱火焰
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_DARK_FLAME
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_DARK_FLAME
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_DARK_FLAME
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_DEMON_CORE # 恶魔核心
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_DARK_FLAME
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_DARK_FLAME
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_DARK_FLAME
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_DARK_FLAME
	
	# 层1 (底层) - 恶魔爪层
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_DEMON_CLAW
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_DEMON_CLAW
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_DEMON_CLAW
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_DEMON_CLAW
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_DEMON_CLAW
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_DEMON_CLAW
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_DEMON_CLAW
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_DEMON_CLAW
	
	return template


static func generate_workshop_template() -> Dictionary:
	"""生成工坊3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 工具层
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_TOOL_RACK
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_TOOL_RACK
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_TOOL_RACK
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_TOOL_RACK
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_WORKBENCH # 工作台
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_TOOL_RACK
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_TOOL_RACK
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_TOOL_RACK
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_TOOL_RACK
	
	# 层2 (中层) - 工作层
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_WORKBENCH
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_WORKBENCH
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_WORKBENCH
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_WORKBENCH
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_FORGE # 锻造炉
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_WORKBENCH
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_WORKBENCH
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_WORKBENCH
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_WORKBENCH
	
	# 层1 (底层) - 材料层
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_MATERIAL_PILE
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_MATERIAL_PILE
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_MATERIAL_PILE
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_MATERIAL_PILE
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_MATERIAL_PILE
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_MATERIAL_PILE
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_MATERIAL_PILE
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_MATERIAL_PILE
	
	return template


static func generate_dungeon_heart_template() -> Dictionary:
	"""生成地牢之心2x2x3模板（2x2瓦块，每瓦块3x3组件）"""
	var template = {}
	
	# 瓦块1: (0,0) 到 (2,2) - 左上角
	# 层3 (顶层) - 能量核心层
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_ENERGY_CRYSTAL
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_MANA_CRYSTAL
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_ENERGY_CRYSTAL
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_ENERGY_CONDUIT
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_MAGIC_CORE # 主核心
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_ENERGY_CONDUIT
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_ENERGY_CRYSTAL
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_MANA_CRYSTAL
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_ENERGY_CRYSTAL
	
	# 层2 (中层) - 能量节点层
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_STORAGE_CORE # 存储核心
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_WALL_STONE
	
	# 层1 (底层) - 基础结构
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_WALL_STONE
	
	# 瓦块2: (3,0) 到 (5,2) - 右上角
	# 层3 (顶层)
	template[Vector3(3, 2, 0)] = BuildingComponents.ID_ENERGY_CRYSTAL
	template[Vector3(4, 2, 0)] = BuildingComponents.ID_MANA_CRYSTAL
	template[Vector3(5, 2, 0)] = BuildingComponents.ID_ENERGY_CRYSTAL
	template[Vector3(3, 2, 1)] = BuildingComponents.ID_ENERGY_CONDUIT
	template[Vector3(4, 2, 1)] = BuildingComponents.ID_MAGIC_CORE
	template[Vector3(5, 2, 1)] = BuildingComponents.ID_ENERGY_CONDUIT
	template[Vector3(3, 2, 2)] = BuildingComponents.ID_ENERGY_CRYSTAL
	template[Vector3(4, 2, 2)] = BuildingComponents.ID_MANA_CRYSTAL
	template[Vector3(5, 2, 2)] = BuildingComponents.ID_ENERGY_CRYSTAL
	
	# 层2 (中层)
	template[Vector3(3, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(4, 1, 0)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(5, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(3, 1, 1)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(4, 1, 1)] = BuildingComponents.ID_STORAGE_CORE
	template[Vector3(5, 1, 1)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(3, 1, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(4, 1, 2)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(5, 1, 2)] = BuildingComponents.ID_WALL_STONE
	
	# 层1 (底层)
	template[Vector3(3, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(4, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(5, 0, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(3, 0, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(4, 0, 1)] = BuildingComponents.ID_DOOR_WOOD
	template[Vector3(5, 0, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(3, 0, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(4, 0, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(5, 0, 2)] = BuildingComponents.ID_WALL_STONE
	
	# 瓦块3: (0,3) 到 (2,5) - 左下角
	# 层3 (顶层)
	template[Vector3(0, 2, 3)] = BuildingComponents.ID_ENERGY_CRYSTAL
	template[Vector3(1, 2, 3)] = BuildingComponents.ID_MANA_CRYSTAL
	template[Vector3(2, 2, 3)] = BuildingComponents.ID_ENERGY_CRYSTAL
	template[Vector3(0, 2, 4)] = BuildingComponents.ID_ENERGY_CONDUIT
	template[Vector3(1, 2, 4)] = BuildingComponents.ID_MAGIC_CORE
	template[Vector3(2, 2, 4)] = BuildingComponents.ID_ENERGY_CONDUIT
	template[Vector3(0, 2, 5)] = BuildingComponents.ID_ENERGY_CRYSTAL
	template[Vector3(1, 2, 5)] = BuildingComponents.ID_MANA_CRYSTAL
	template[Vector3(2, 2, 5)] = BuildingComponents.ID_ENERGY_CRYSTAL
	
	# 层2 (中层)
	template[Vector3(0, 1, 3)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 3)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(2, 1, 3)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 4)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(1, 1, 4)] = BuildingComponents.ID_STORAGE_CORE
	template[Vector3(2, 1, 4)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(0, 1, 5)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 5)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(2, 1, 5)] = BuildingComponents.ID_WALL_STONE
	
	# 层1 (底层)
	template[Vector3(0, 0, 3)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 3)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(2, 0, 3)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 0, 4)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 4)] = BuildingComponents.ID_DOOR_WOOD
	template[Vector3(2, 0, 4)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 0, 5)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 0, 5)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(2, 0, 5)] = BuildingComponents.ID_WALL_STONE
	
	# 瓦块4: (3,3) 到 (5,5) - 右下角
	# 层3 (顶层)
	template[Vector3(3, 2, 3)] = BuildingComponents.ID_ENERGY_CRYSTAL
	template[Vector3(4, 2, 3)] = BuildingComponents.ID_MANA_CRYSTAL
	template[Vector3(5, 2, 3)] = BuildingComponents.ID_ENERGY_CRYSTAL
	template[Vector3(3, 2, 4)] = BuildingComponents.ID_ENERGY_CONDUIT
	template[Vector3(4, 2, 4)] = BuildingComponents.ID_MAGIC_CORE
	template[Vector3(5, 2, 4)] = BuildingComponents.ID_ENERGY_CONDUIT
	template[Vector3(3, 2, 5)] = BuildingComponents.ID_ENERGY_CRYSTAL
	template[Vector3(4, 2, 5)] = BuildingComponents.ID_MANA_CRYSTAL
	template[Vector3(5, 2, 5)] = BuildingComponents.ID_ENERGY_CRYSTAL
	
	# 层2 (中层)
	template[Vector3(3, 1, 3)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(4, 1, 3)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(5, 1, 3)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(3, 1, 4)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(4, 1, 4)] = BuildingComponents.ID_STORAGE_CORE
	template[Vector3(5, 1, 4)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(3, 1, 5)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(4, 1, 5)] = BuildingComponents.ID_ENERGY_NODE
	template[Vector3(5, 1, 5)] = BuildingComponents.ID_WALL_STONE
	
	# 层1 (底层)
	template[Vector3(3, 0, 3)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(4, 0, 3)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(5, 0, 3)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(3, 0, 4)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(4, 0, 4)] = BuildingComponents.ID_DOOR_WOOD
	template[Vector3(5, 0, 4)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(3, 0, 5)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(4, 0, 5)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(5, 0, 5)] = BuildingComponents.ID_WALL_STONE
	
	return template


static func generate_magic_research_institute_template() -> Dictionary:
	"""生成魔法研究院3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 研究层
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_RESEARCH_TABLE
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_WISDOM_CRYSTAL
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_RESEARCH_TABLE
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_ANCIENT_TEXT
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_KNOWLEDGE_ORB # 知识球
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_ANCIENT_TEXT
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_RESEARCH_TABLE
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_WISDOM_CRYSTAL
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_RESEARCH_TABLE
	
	# 层2 (中层) - 学习层
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_SCROLL_RACK
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_STUDY_LAMP
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_SCROLL_RACK
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_RESEARCH_TABLE # 研究桌
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_BOOKSHELF
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_SCROLL_RACK
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_STUDY_LAMP
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_SCROLL_RACK
	
	# 层1 (底层) - 学者层
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_SCHOLAR_STATUE
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_SCHOLAR_STATUE
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_SCHOLAR_STATUE
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_SCHOLAR_STATUE
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_SCHOLAR_STATUE
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_SCHOLAR_STATUE
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_SCHOLAR_STATUE
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_SCHOLAR_STATUE
	
	return template


static func generate_shadow_temple_template() -> Dictionary:
	"""生成暗影神殿3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 暗影仪式层
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_SHADOW_RUNE
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_SHADOW_CORE
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_SHADOW_RUNE
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_SHADOW_RUNE
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_SHADOW_ALTAR # 神殿祭坛
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_SHADOW_RUNE
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_SHADOW_RUNE
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_SHADOW_CORE
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_SHADOW_RUNE
	
	# 层2 (中层) - 暗影墙层
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_SHADOW_WALL
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_SHADOW_WALL
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_SHADOW_WALL
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_SHADOW_WALL
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_SHADOW_POOL # 暗影池
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_SHADOW_WALL
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_SHADOW_WALL
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_SHADOW_WALL
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_SHADOW_WALL
	
	# 层1 (底层) - 暗影基础
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_SHADOW_WALL
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_SHADOW_WALL
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_SHADOW_WALL
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_SHADOW_WALL
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_SHADOW_WALL
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_SHADOW_WALL
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_SHADOW_WALL
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_SHADOW_WALL
	
	return template


static func generate_barracks_template() -> Dictionary:
	"""生成训练室3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 战旗层
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_BATTLE_STANDARD
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_BATTLE_STANDARD
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_BATTLE_STANDARD
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_TRAINING_POST
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_TRAINING_POST # 训练台
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_TRAINING_POST
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_BATTLE_STANDARD
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_BATTLE_STANDARD
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_BATTLE_STANDARD
	
	# 层2 (中层) - 训练层
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_TRAINING_POST
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_WINDOW_SMALL
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_TRAINING_POST
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_TRAINING_POST
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_TRAINING_GROUND # 训练场
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_TRAINING_POST
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_TRAINING_POST
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_WINDOW_SMALL
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_TRAINING_POST
	
	# 层1 (底层) - 基础层
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_TRAINING_POST
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_TRAINING_POST
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_TRAINING_POST
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_TRAINING_POST
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_TRAINING_POST
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_TRAINING_POST
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_TRAINING_POST
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_TRAINING_POST
	
	return template


static func generate_orc_lair_template() -> Dictionary:
	"""生成兽人巢穴3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 兽骨层
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_ORC_BONE
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_ORC_BONE
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_ORC_BONE
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_ORC_BONE
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_WAR_DRUM # 战鼓
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_ORC_BONE
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_ORC_BONE
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_ORC_BONE
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_ORC_BONE
	
	# 层2 (中层) - 木栅层
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_WOODEN_PALISADE
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_WOODEN_PALISADE
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_WOODEN_PALISADE
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_WOODEN_PALISADE
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_TRAINING_GROUND # 训练场
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_WOODEN_PALISADE
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_WOODEN_PALISADE
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_WOODEN_PALISADE
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_WOODEN_PALISADE
	
	# 层1 (底层) - 木栅基础
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_WOODEN_PALISADE
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_WOODEN_PALISADE
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_WOODEN_PALISADE
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_WOODEN_PALISADE
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_WOODEN_PALISADE
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_WOODEN_PALISADE
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_WOODEN_PALISADE
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_WOODEN_PALISADE
	
	return template


static func generate_factory_template() -> Dictionary:
	"""生成工厂3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 工业层
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_SMOKESTACK
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_VENTILATION
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_SMOKESTACK
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_ASSEMBLY_LINE
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_ASSEMBLY_LINE # 装配线
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_ASSEMBLY_LINE
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_SMOKESTACK
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_VENTILATION
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_SMOKESTACK
	
	# 层2 (中层) - 生产线层
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_CONVEYOR_BELT
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_CONVEYOR_BELT
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_CONVEYOR_BELT
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_CONVEYOR_BELT
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_RESEARCH_LAB # 控制台
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_CONVEYOR_BELT
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_CONVEYOR_BELT
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_CONVEYOR_BELT
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_CONVEYOR_BELT
	
	# 层1 (底层) - 工具层
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_ANVIL
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_HAMMER
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_CHISEL
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_ANVIL
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_CHISEL
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_ANVIL
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_HAMMER
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_CHISEL
	
	return template


static func generate_hospital_template() -> Dictionary:
	"""生成医院3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 手术层
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_SURGICAL_TABLE
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_SURGICAL_TABLE
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_SURGICAL_TABLE
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_OPERATING_ROOM
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_OPERATING_ROOM # 手术室
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_OPERATING_ROOM
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_NURSING_STATION
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_NURSING_STATION
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_NURSING_STATION
	
	# 层2 (中层) - 医疗层
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_MEDICAL_EQUIPMENT
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_MEDICAL_EQUIPMENT
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_MEDICAL_EQUIPMENT
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_HOSPITAL_BED
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_HOSPITAL_BED # 医院床位
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_HOSPITAL_BED
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_MEDICAL_EQUIPMENT
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_MEDICAL_EQUIPMENT
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_MEDICAL_EQUIPMENT
	
	# 层1 (底层) - 药房层
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_PHARMACY
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_RECEPTION_DESK
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_PHARMACY
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_PHARMACY
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_PHARMACY
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_PHARMACY
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_RECEPTION_DESK
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_PHARMACY
	
	return template


static func generate_market_template() -> Dictionary:
	"""生成市场3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 市场层
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_MARKET_BANNER
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_MARKET_BANNER
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_MARKET_BANNER
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_TRADING_DESK
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_TRADING_DESK # 交易台
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_TRADING_DESK
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_MARKET_SIGN
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_GOLDEN_CREST # 金色徽章
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_MARKET_SIGN
	
	# 层2 (中层) - 商贩层
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_VENDOR_STALL
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_VENDOR_STALL
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_VENDOR_STALL
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_DISPLAY_COUNTER
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_DISPLAY_COUNTER # 展示柜台
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_DISPLAY_COUNTER
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_VENDOR_STALL
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_VENDOR_STALL
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_VENDOR_STALL
	
	# 层1 (底层) - 存储层
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_GOODS_STORAGE
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_COIN_COUNTER
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_GOODS_STORAGE
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_GOODS_STORAGE
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_GOODS_STORAGE
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_WELCOME_MAT
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_MERCHANT_CART
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_WELCOME_MAT
	
	return template


static func generate_academy_template() -> Dictionary:
	"""生成学院3x3x3模板"""
	var template = {}
	
	# 层3 (顶层) - 学术层
	template[Vector3(0, 2, 0)] = BuildingComponents.ID_ACADEMY_TOWER
	template[Vector3(1, 2, 0)] = BuildingComponents.ID_WISDOM_TOWER
	template[Vector3(2, 2, 0)] = BuildingComponents.ID_ACADEMY_TOWER
	template[Vector3(0, 2, 1)] = BuildingComponents.ID_RESEARCH_LAB
	template[Vector3(1, 2, 1)] = BuildingComponents.ID_RESEARCH_LAB # 研究实验室
	template[Vector3(2, 2, 1)] = BuildingComponents.ID_RESEARCH_LAB
	template[Vector3(0, 2, 2)] = BuildingComponents.ID_ACADEMIC_BANNER
	template[Vector3(1, 2, 2)] = BuildingComponents.ID_ACADEMIC_BANNER
	template[Vector3(2, 2, 2)] = BuildingComponents.ID_ACADEMIC_BANNER
	
	# 层2 (中层) - 教学层
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_CLASSROOM_DESK
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_CLASSROOM_DESK
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_CLASSROOM_DESK
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_TEACHER_PODIUM
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_TEACHER_PODIUM # 教师讲台
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_TEACHER_PODIUM
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_CLASSROOM_DESK
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_CLASSROOM_DESK
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_CLASSROOM_DESK
	
	# 层1 (底层) - 图书馆层
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_ACADEMIC_LIBRARY
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_ACADEMY_ENTRANCE
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_ACADEMIC_LIBRARY
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_ACADEMIC_LIBRARY
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_DOOR_WOOD # 入口
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_ACADEMIC_LIBRARY
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_STUDY_LAMP
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_SCHOLAR_STATUE
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_STUDY_LAMP
	
	return template


# ========================================
# 通用模板生成方法
# ========================================

static func generate_template_for_building(building_type: BuildingTypes.BuildingType) -> Dictionary:
	"""根据建筑类型生成对应的3x3x3模板"""
	match building_type:
		BuildingTypes.BuildingType.ARCANE_TOWER:
			return generate_arcane_tower_template()
		BuildingTypes.BuildingType.ARROW_TOWER:
			return generate_arrow_tower_template()
		BuildingTypes.BuildingType.TREASURY:
			return generate_treasury_template()
		BuildingTypes.BuildingType.MAGIC_ALTAR:
			return generate_magic_altar_template()
		BuildingTypes.BuildingType.LIBRARY:
			return generate_library_template()
		BuildingTypes.BuildingType.DEMON_LAIR:
			return generate_demon_lair_template()
		BuildingTypes.BuildingType.WORKSHOP:
			return generate_workshop_template()
		BuildingTypes.BuildingType.DUNGEON_HEART:
			return generate_dungeon_heart_template()
		BuildingTypes.BuildingType.MAGIC_RESEARCH_INSTITUTE:
			return generate_magic_research_institute_template()
		BuildingTypes.BuildingType.SHADOW_TEMPLE:
			return generate_shadow_temple_template()
		BuildingTypes.BuildingType.TRAINING_ROOM:
			return generate_barracks_template()
		BuildingTypes.BuildingType.ORC_LAIR:
			return generate_orc_lair_template()
		BuildingTypes.BuildingType.FACTORY:
			return generate_factory_template()
		BuildingTypes.BuildingType.HOSPITAL:
			return generate_hospital_template()
		BuildingTypes.BuildingType.MARKET:
			return generate_market_template()
		BuildingTypes.BuildingType.ACADEMY:
			return generate_academy_template()
		_:
			LogManager.warning("⚠️ [BuildingTemplateGenerator] 未找到建筑类型模板: %s" % BuildingTypes.BuildingType.keys()[building_type])
			return {}


static func get_template_info(template: Dictionary) -> Dictionary:
	"""获取模板信息"""
	var info = {
		"total_components": template.size(),
		"component_types": {},
		"layers": {
			"top": 0, # Y=2
			"middle": 0, # Y=1
			"bottom": 0 # Y=0
		}
	}
	
	for pos in template:
		var component_id = template[pos]
		var y = pos.y
		
		# 统计组件类型
		if not info.component_types.has(component_id):
			info.component_types[component_id] = 0
		info.component_types[component_id] += 1
		
		# 统计层级
		if y == 2:
			info.layers.top += 1
		elif y == 1:
			info.layers.middle += 1
		elif y == 0:
			info.layers.bottom += 1
	
	return info

# ========================================
# 1x1瓦块建筑模板生成方法
# ========================================

static func generate_1x1_treasury_template() -> Dictionary:
	"""生成金库1x1瓦块模板 (3x3x3)"""
	var template = {}
	
	# 层0 (地面层) - 金色财富主题
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_TREASURE_CHEST # 主金库
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	
	# 层1 (装饰层) - 财富装饰
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_GOLD_PILE
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_GOLD_BAR # 金条装饰
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_GOLD_PILE
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_WALL_STONE
	
	return template

static func generate_1x1_arcane_tower_template() -> Dictionary:
	"""生成奥术塔1x1瓦块模板 (3x3x3)"""
	var template = {}
	
	# 层0 (地面层) - 魔法基础
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_MAGIC_CIRCLE # 魔法阵
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	
	# 层1 (装饰层) - 魔法装饰
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_MAGIC_CRYSTAL
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_CRYSTAL_BALL # 水晶球
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_MAGIC_CRYSTAL
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_WALL_STONE
	
	return template

static func generate_1x1_barracks_template() -> Dictionary:
	"""生成兵营1x1瓦块模板 (3x3x3)"""
	var template = {}
	
	# 层0 (地面层) - 军事基础
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_TRAINING_GROUND # 训练场
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	
	# 层1 (装饰层) - 军事装饰
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_WEAPON_RACK
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_MILITARY_FLAG # 军旗
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_WEAPON_RACK
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_WALL_STONE
	
	return template

static func generate_1x1_workshop_template() -> Dictionary:
	"""生成工坊1x1瓦块模板 (3x3x3)"""
	var template = {}
	
	# 层0 (地面层) - 工坊基础
	template[Vector3(0, 0, 0)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(1, 0, 0)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(2, 0, 0)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(0, 0, 1)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(1, 0, 1)] = BuildingComponents.ID_WORKBENCH # 工作台
	template[Vector3(2, 0, 1)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(0, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(1, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	template[Vector3(2, 0, 2)] = BuildingComponents.ID_FLOOR_STONE
	
	# 层1 (装饰层) - 工具装饰
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_TOOL_RACK
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_FORGE # 熔炉
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_TOOL_RACK
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_WALL_STONE
	
	return template

# ========================================
# 通用1x1瓦块模板生成方法
# ========================================

static func generate_1x1_building_template(building_type: int) -> Dictionary:
	"""根据建筑类型生成1x1瓦块模板"""
	match building_type:
		BuildingTypes.BuildingType.TREASURY:
			return generate_1x1_treasury_template()
		BuildingTypes.BuildingType.ARCANE_TOWER:
			return generate_1x1_arcane_tower_template()
		BuildingTypes.BuildingType.BARRACKS:
			return generate_1x1_barracks_template()
		BuildingTypes.BuildingType.WORKSHOP:
			return generate_1x1_workshop_template()
		_:
			# 默认简单模板
			return generate_default_1x1_template()

static func generate_default_1x1_template() -> Dictionary:
	"""生成默认1x1瓦块模板"""
	var template = {}
	
	# 层0 (地面层) - 基础地面
	for x in range(3):
		for z in range(3):
			template[Vector3(x, 0, z)] = BuildingComponents.ID_FLOOR_STONE
	
	# 层1 (装饰层) - 简单装饰
	template[Vector3(0, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(2, 1, 0)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 1)] = BuildingComponents.ID_MAGIC_CRYSTAL # 中心装饰
	template[Vector3(2, 1, 1)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(0, 1, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(1, 1, 2)] = BuildingComponents.ID_WALL_STONE
	template[Vector3(2, 1, 2)] = BuildingComponents.ID_WALL_STONE
	
	return template

# ========================================
# 新增建筑自由组件模板生成方法
# ========================================

static func generate_free_hospital_template() -> Dictionary:
	"""生成自由组件医院模板 (2x2瓦块)"""
	var template = {
		"building_size": Vector3(2, 2, 2),
		"components": [],
		"allow_free_placement": true
	}
	
	# 医院主体结构
	template["components"].append({
		"name": "Hospital_Main",
		"position": Vector3(0.8, 0, 0.8),
		"size": Vector3(1.2, 1.5, 1.2),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Hospital_Roof",
		"position": Vector3(0.8, 1.5, 0.8),
		"size": Vector3(1.4, 0.2, 1.4),
		"type": "structure"
	})
	
	# 医疗设施
	template["components"].append({
		"name": "Nursing_Station",
		"position": Vector3(0.3, 0.1, 0.3),
		"size": Vector3(0.6, 0.8, 0.4),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Hospital_Bed_1",
		"position": Vector3(0.2, 0.1, 0.7),
		"size": Vector3(0.5, 0.15, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Hospital_Bed_2",
		"position": Vector3(1.3, 0.1, 0.7),
		"size": Vector3(0.5, 0.15, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Medical_Equipment",
		"position": Vector3(0.5, 0.1, 0.2),
		"size": Vector3(0.3, 0.6, 0.2),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Surgical_Table",
		"position": Vector3(1.0, 0.1, 0.2),
		"size": Vector3(0.4, 0.8, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Pharmacy",
		"position": Vector3(1.5, 0.1, 1.0),
		"size": Vector3(0.3, 0.6, 0.4),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Operating_Room",
		"position": Vector3(0.2, 0.1, 1.3),
		"size": Vector3(0.6, 0.8, 0.4),
		"type": "decoration"
	})
	
	# 治愈水晶
	template["components"].append({
		"name": "Healing_Crystal",
		"position": Vector3(0.8, 0.3, 0.8),
		"size": Vector3(0.2, 0.4, 0.2),
		"type": "decoration"
	})
	
	return template

static func generate_free_market_template() -> Dictionary:
	"""生成自由组件市场模板 (2x2瓦块)"""
	var template = {
		"building_size": Vector3(2, 2, 2),
		"components": [],
		"allow_free_placement": true
	}
	
	# 市场主体结构
	template["components"].append({
		"name": "Market_Main",
		"position": Vector3(0.8, 0, 0.8),
		"size": Vector3(1.2, 1.2, 1.2),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Market_Roof",
		"position": Vector3(0.8, 1.2, 0.8),
		"size": Vector3(1.4, 0.2, 1.4),
		"type": "structure"
	})
	
	# 交易设施
	template["components"].append({
		"name": "Trading_Desk",
		"position": Vector3(0.3, 0.1, 0.3),
		"size": Vector3(0.8, 0.6, 0.4),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Vendor_Stall_1",
		"position": Vector3(0.2, 0.1, 0.7),
		"size": Vector3(0.4, 0.5, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Vendor_Stall_2",
		"position": Vector3(1.3, 0.1, 0.7),
		"size": Vector3(0.4, 0.5, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Display_Counter",
		"position": Vector3(0.5, 0.1, 0.2),
		"size": Vector3(0.6, 0.4, 0.2),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Goods_Storage",
		"position": Vector3(1.0, 0.1, 0.2),
		"size": Vector3(0.4, 0.6, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Merchant_Cart",
		"position": Vector3(0.2, 0.1, 1.3),
		"size": Vector3(0.5, 0.4, 0.3),
		"type": "decoration"
	})
	
	# 金币和装饰
	template["components"].append({
		"name": "Coin_Counter",
		"position": Vector3(0.8, 0.1, 0.3),
		"size": Vector3(0.3, 0.2, 0.2),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Coin_Stack",
		"position": Vector3(1.2, 0.1, 1.0),
		"size": Vector3(0.2, 0.3, 0.2),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Market_Banner",
		"position": Vector3(0.8, 0.8, 0.2),
		"size": Vector3(0.4, 0.6, 0.1),
		"type": "decoration"
	})
	
	return template

static func generate_free_library_template() -> Dictionary:
	"""生成自由组件图书馆模板 (2x2瓦块)"""
	var template = {
		"building_size": Vector3(2, 2, 2),
		"components": [],
		"allow_free_placement": true
	}
	
	# 图书馆主体结构
	template["components"].append({
		"name": "Library_Main",
		"position": Vector3(0.8, 0, 0.8),
		"size": Vector3(1.2, 1.3, 1.2),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Library_Roof",
		"position": Vector3(0.8, 1.3, 0.8),
		"size": Vector3(1.4, 0.2, 1.4),
		"type": "structure"
	})
	
	# 学术设施
	template["components"].append({
		"name": "Reading_Desk_1",
		"position": Vector3(0.3, 0.1, 0.3),
		"size": Vector3(0.6, 0.4, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Reading_Desk_2",
		"position": Vector3(1.3, 0.1, 0.3),
		"size": Vector3(0.6, 0.4, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Research_Table",
		"position": Vector3(0.5, 0.1, 0.7),
		"size": Vector3(0.8, 0.5, 0.4),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Bookshelf_1",
		"position": Vector3(0.2, 0.1, 0.8),
		"size": Vector3(0.2, 0.8, 0.8),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Bookshelf_2",
		"position": Vector3(1.5, 0.1, 0.8),
		"size": Vector3(0.2, 0.8, 0.8),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Scroll_Rack",
		"position": Vector3(0.8, 0.1, 0.2),
		"size": Vector3(0.4, 0.6, 0.2),
		"type": "decoration"
	})
	
	# 知识水晶和装饰
	template["components"].append({
		"name": "Knowledge_Orb",
		"position": Vector3(0.8, 0.3, 0.8),
		"size": Vector3(0.3, 0.3, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Wisdom_Crystal",
		"position": Vector3(0.3, 0.2, 1.3),
		"size": Vector3(0.2, 0.4, 0.2),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Study_Lamp",
		"position": Vector3(1.2, 0.2, 1.3),
		"size": Vector3(0.2, 0.3, 0.2),
		"type": "decoration"
	})
	
	return template

static func generate_free_academy_template() -> Dictionary:
	"""生成自由组件学院模板 (3x3瓦块)"""
	var template = {
		"building_size": Vector3(3, 3, 3),
		"components": [],
		"allow_free_placement": true
	}
	
	# 学院主体结构
	template["components"].append({
		"name": "Academy_Main",
		"position": Vector3(1.2, 0, 1.2),
		"size": Vector3(0.6, 2.0, 0.6),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Academy_Tower",
		"position": Vector3(1.2, 2.0, 1.2),
		"size": Vector3(0.8, 1.0, 0.8),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Academy_Entrance",
		"position": Vector3(1.2, 0, 0.3),
		"size": Vector3(0.6, 1.5, 0.2),
		"type": "structure"
	})
	
	# 教育设施
	template["components"].append({
		"name": "Classroom_Desk_1",
		"position": Vector3(0.5, 0.1, 0.5),
		"size": Vector3(0.6, 0.4, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Classroom_Desk_2",
		"position": Vector3(1.8, 0.1, 0.5),
		"size": Vector3(0.6, 0.4, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Classroom_Desk_3",
		"position": Vector3(0.5, 0.1, 1.8),
		"size": Vector3(0.6, 0.4, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Classroom_Desk_4",
		"position": Vector3(1.8, 0.1, 1.8),
		"size": Vector3(0.6, 0.4, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Teacher_Podium",
		"position": Vector3(1.2, 0.1, 0.8),
		"size": Vector3(0.4, 0.6, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Research_Lab",
		"position": Vector3(0.3, 0.1, 1.2),
		"size": Vector3(0.6, 0.8, 0.4),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Academic_Library",
		"position": Vector3(1.8, 0.1, 1.2),
		"size": Vector3(0.4, 0.8, 0.6),
		"type": "decoration"
	})
	
	# 学术装饰
	template["components"].append({
		"name": "Scholar_Statue",
		"position": Vector3(1.2, 0.1, 1.5),
		"size": Vector3(0.3, 0.8, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Academic_Banner",
		"position": Vector3(0.2, 0.8, 0.2),
		"size": Vector3(0.2, 0.8, 0.1),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Wisdom_Tower",
		"position": Vector3(2.5, 0.1, 2.5),
		"size": Vector3(0.4, 1.2, 0.4),
		"type": "decoration"
	})
	
	return template

static func generate_free_factory_template() -> Dictionary:
	"""生成自由组件工厂模板 (3x3瓦块)"""
	var template = {
		"building_size": Vector3(3, 3, 3),
		"components": [],
		"allow_free_placement": true
	}
	
	# 工厂主体结构
	template["components"].append({
		"name": "Factory_Main",
		"position": Vector3(1.2, 0, 1.2),
		"size": Vector3(0.6, 1.5, 0.6),
		"type": "structure"
	})
	
	template["components"].append({
		"name": "Smokestack",
		"position": Vector3(1.2, 1.5, 1.2),
		"size": Vector3(0.2, 0.8, 0.2),
		"type": "structure"
	})
	
	# 生产设施
	template["components"].append({
		"name": "Assembly_Line",
		"position": Vector3(0.5, 0.1, 0.5),
		"size": Vector3(1.0, 0.2, 0.3),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Conveyor_Belt",
		"position": Vector3(1.8, 0.1, 0.5),
		"size": Vector3(0.8, 0.1, 0.2),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Storage_Crate_1",
		"position": Vector3(0.3, 0.1, 1.0),
		"size": Vector3(0.4, 0.6, 0.4),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Storage_Crate_2",
		"position": Vector3(2.0, 0.1, 1.0),
		"size": Vector3(0.4, 0.6, 0.4),
		"type": "decoration"
	})
	
	template["components"].append({
		"name": "Ventilation",
		"position": Vector3(1.2, 0.8, 0.2),
		"size": Vector3(0.3, 0.4, 0.1),
		"type": "decoration"
	})
	
	return template
