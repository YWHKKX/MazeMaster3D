## 角色基类（3D物理节点）
##
## 所有游戏角色的基础类，使用 CharacterBody3D 实现物理移动和碰撞。
## 集成了状态机、导航系统、战斗系统、物理系统等核心功能。
##
## 继承层次：
## CharacterBase → Monster / Hero → 具体单位（GoblinWorker, Knight 等）
##
## 场景结构：
## CharacterBase (CharacterBody3D)
class_name CharacterBase
## ├── Model (MeshInstance3D)
## ├── CollisionShape (CollisionShape3D)
## ├── NavigationAgent (NavigationAgent3D)
## ├── StateMachine (StateMachine)
## ├── AnimationPlayer (AnimationPlayer)
## └── StatusIndicator (Control)
extends CharacterBody3D

## ============================================================================
## 信号定义
## ============================================================================

## 生命值变化信号
signal health_changed(old_health: float, new_health: float)

## 死亡信号
signal died()

## 受到攻击信号
signal attacked(attacker: CharacterBase, damage: float)

## 攻击目标信号
signal target_acquired(target: Node3D)

## 状态变化信号
signal status_changed(old_status: int, new_status: int)

## ============================================================================
## 导出属性（可在编辑器中配置）
## ============================================================================

## 角色数据（Resource）
@export var character_data: CharacterData

## 阵营
@export var faction: int = FactionManager.Faction.MONSTERS

## 是否启用调试模式
@export var debug_mode: bool = false

## ============================================================================
## 基础属性（从 CharacterData 初始化）
## ============================================================================

## 当前生命值
var current_health: float = 100.0

## 最大生命值
var max_health: float = 100.0

## 攻击力
var attack: float = 10.0

## 防御力/护甲
var armor: float = 0.0

## 移动速度
var speed: float = 20.0

## 体型大小
var size: float = 15.0

## 攻击范围
var attack_range: float = 3.0

## 攻击冷却时间
var attack_cooldown: float = 1.0

## 检测范围
var detection_range: float = 10.0

## ============================================================================
## 战斗属性
## ============================================================================

## 当前目标
var current_target: Node3D = null

## 目标最后被看到的时间
var target_last_seen_time: float = 0.0

## 上次攻击时间
var last_attack_time: float = 0.0

## 是否在战斗中
var in_combat: bool = false

## 最后战斗时间
var last_combat_time: float = 0.0

## 是否为战斗单位
var is_combat_unit: bool = true

## ============================================================================
## 物理属性
## ============================================================================

## 碰撞半径（自动计算）
var collision_radius: float = 0.0

## 击退状态
var knockback_state: Dictionary = {}

## 地面悬浮系统
var enable_ground_hover: bool = true
var hover_height: float = 0.05
var hover_smooth_speed: float = 5.0

## 击退系统
var is_knockback: bool = false
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_decay_rate: float = 5.0

## 是否可以移动
var can_move: bool = true

## 是否可以攻击
var can_attack: bool = true

## 免疫标志
var immunities: int = 0

## ============================================================================
## 状态
## ============================================================================

## 当前状态
var current_status: int = 0 # MonstersTypes.MonsterStatus.IDLE

## 是否存活
var is_alive: bool = true

## ============================================================================
## 状态机系统
## ============================================================================

## 状态机引用
@onready var state_machine: StateMachine = get_node_or_null("StateMachine")

## 是否启用状态机
@export var enable_state_machine: bool = true

## ============================================================================
## 节点引用（使用 @onready 延迟初始化）
## ============================================================================

## 🔧 [移除] NavigationAgent3D 已废弃，统一使用 MovementHelper.process_navigation
# @onready var nav_agent: NavigationAgent3D = get_node_or_null("NavigationAgent3D")

## 动画播放器（可选）
@onready var animation_player: AnimationPlayer = get_node_or_null("AnimationPlayer")

## 模型（可选，可能是 MeshInstance3D 或 Node3D 包装器）
@onready var model: Node3D = get_node_or_null("Model")

## 碰撞形状（可选）
@onready var collision_shape: CollisionShape3D = get_node_or_null("CollisionShape")

## 🔧 [状态栏系统] 头顶状态栏（已迁移到UnitDisplay）
# var status_bar: Node3D = null # 已移除，使用UnitDisplay系统

## ============================================================================
## 生命周期
## ============================================================================

func _ready() -> void:
	# 从 CharacterData 初始化属性
	if character_data:
		_init_from_character_data()
	else:
		_init_default_values()
	
	# 验证生物类型
	if not validate_creature_type():
		push_warning("角色 %s 的生物类型无效: %s" % [name, get_creature_type()])
	
	# 设置物理属性
	_setup_physics()
	
	# 🔧 [移除] 导航系统设置已废弃，统一使用 MovementHelper.process_navigation
	# _setup_navigation()
	
	# 设置碰撞层级
	_setup_collision_layers()
	
	# 🔧 创建默认模型（如果没有模型节点）
	call_deferred("_setup_default_model")
	
	# 🔧 应用模型缩放（延迟到下一帧，确保模型已加载）
	call_deferred("_apply_model_scale")
	
	# 🔧 [状态栏系统] 创建头顶状态栏
	call_deferred("_setup_status_bar")
	
	# 初始化状态机
	if enable_state_machine and state_machine:
		state_machine.debug_mode = debug_mode
		state_machine.auto_start = true
	
	# 角色初始化完成

func _physics_process(delta: float) -> void:
	# 🔧 锁定Y轴：确保单位只在水平面移动
	velocity.y = 0.0
	
	# 处理地面悬浮
	if enable_ground_hover:
		_update_ground_hover(delta)
	
	# 处理击退效果
	if is_knockback:
		_update_knockback(delta)
	else:
		# 🔧 关键修复：正常移动时调用 move_and_slide()
		# 状态机会设置 velocity，这里需要应用到实际移动
		if velocity.length() > 0.001: # 只有在有移动速度时才调用
			# 保存移动前的位置
			var pos_before = global_position
			
			# 🔧 修复1：根据移动方向旋转单位
			_update_rotation_from_velocity(delta)
			
			# 应用移动
			move_and_slide()
			
			# 🔧 移动后强制保持Y坐标在地面高度
			global_position.y = hover_height
			
			# 🔍 调试：检查是否真的移动了
			var pos_after = global_position
			var _moved_distance = pos_before.distance_to(pos_after)
			# 检查单位移动状态（调试用）
	
	# 子类可以重写此方法添加自定义物理逻辑
	pass

## ============================================================================
## 初始化方法
## ============================================================================

## 从 CharacterData 初始化属性
func _init_from_character_data() -> void:
	if not character_data:
		return
	
	# 基础属性
	max_health = character_data.max_health
	current_health = max_health
	attack = character_data.attack
	armor = character_data.armor
	speed = character_data.speed
	size = character_data.size
	
	# 战斗属性
	attack_range = character_data.attack_range
	attack_cooldown = character_data.attack_cooldown
	detection_range = character_data.detection_range
	
	# 物理属性
	collision_radius = character_data.get_collision_radius()
	immunities = character_data.immunities
	
	# 🔧 生命值显示已迁移到UnitDisplay系统
	# 不再需要手动更新状态栏
	
	# 从CharacterData加载角色信息

## 🔧 [默认模型系统] 创建默认3D模型
func _setup_default_model() -> void:
	"""如果没有模型节点，创建默认的圆柱形3D模型"""
	if model:
		# 如果已经有模型节点，不需要创建
		return
	
	# 创建圆柱形模型
	var cylinder_model = _create_cylinder_model()
	if not cylinder_model:
		push_warning("无法创建默认圆柱形模型")
		return
	
	# 设置模型名称和父节点
	cylinder_model.name = "Model"
	add_child(cylinder_model)
	model = cylinder_model
	
	# 设置模型位置（让脚底对齐地面）
	model.position = Vector3.ZERO
	
	# 应用初始缩放
	_apply_cylinder_scale()
	
	# 默认模型创建完成

## 🔧 [默认模型系统] 创建圆柱形模型
func _create_cylinder_model() -> Node3D:
	"""创建圆柱形3D模型，大小与goblin_worker相似"""
	# 创建MeshInstance3D节点
	var mesh_instance = MeshInstance3D.new()
	
	# 创建圆柱体网格
	var cylinder_mesh = CylinderMesh.new()
	
	# 设置圆柱体参数（参考goblin_worker的大小）
	# goblin_worker大约18厘米高，所以圆柱体高度设为0.18米
	cylinder_mesh.height = 0.18 # 18厘米高度
	cylinder_mesh.top_radius = 0.08 # 顶部半径8厘米
	cylinder_mesh.bottom_radius = 0.08 # 底部半径8厘米
	cylinder_mesh.radial_segments = 8 # 8个径向分段
	cylinder_mesh.rings = 1 # 1个环
	
	# 设置网格
	mesh_instance.mesh = cylinder_mesh
	
	# 根据阵营设置颜色
	var material = StandardMaterial3D.new()
	match faction:
		FactionManager.Faction.MONSTERS:
			material.albedo_color = Color(0.8, 0.2, 0.2) # 红色（怪物）
		FactionManager.Faction.HEROES:
			material.albedo_color = Color(0.2, 0.2, 0.8) # 蓝色（英雄）
		FactionManager.Faction.BEASTS:
			material.albedo_color = Color(0.2, 0.8, 0.2) # 绿色（野兽）
		FactionManager.Faction.NEUTRAL:
			material.albedo_color = Color(0.6, 0.6, 0.6) # 灰色（中立）
		_:
			material.albedo_color = Color(0.5, 0.5, 0.5) # 默认灰色
	
	# 应用材质
	mesh_instance.material_override = material
	
	# 调整位置，让圆柱体底部对齐地面
	mesh_instance.position.y = cylinder_mesh.height / 2.0
	
	return mesh_instance

## 🔧 [默认模型系统] 应用圆柱形模型缩放
func _apply_cylinder_scale() -> void:
	"""根据size属性缩放圆柱形模型"""
	if not model or not is_instance_valid(model):
		return
	
	# 根据size计算缩放比例
	# size=18对应0.18米高度，所以缩放比例 = size / 18
	var scale_factor = size / 18.0
	model.scale = Vector3(scale_factor, scale_factor, scale_factor)
	
	# 重新调整位置，确保底部对齐地面
	if model.has_method("get_mesh") and model.get_mesh() is CylinderMesh:
		var cylinder_mesh = model.get_mesh() as CylinderMesh
		model.position.y = (cylinder_mesh.height * scale_factor) / 2.0

## 🔧 [默认模型系统] 根据阵营获取默认模型路径（已废弃）
func _get_default_model_path() -> String:
	"""根据角色阵营返回对应的默认模型路径（已废弃，现在使用程序生成的圆柱形模型）"""
	# 子类可以重写此方法来自定义模型路径
	if has_method("get_custom_model_path"):
		var custom_path = call("get_custom_model_path")
		if custom_path and custom_path != "":
			return custom_path
	
	# 现在使用程序生成的圆柱形模型，不再需要外部模型路径
	return ""

## 🔧 [默认模型系统] 检查模型是否已正确设置
func has_model() -> bool:
	"""检查角色是否有有效的3D模型"""
	return model != null and is_instance_valid(model)

## 🔧 [默认模型系统] 获取模型信息（调试用）
func get_model_info() -> Dictionary:
	"""获取模型信息，用于调试"""
	if not has_model():
		return {"has_model": false, "model_name": "none"}
	
	return {
		"has_model": true,
		"model_name": model.name,
		"model_position": model.position,
		"model_scale": model.scale,
		"model_type": model.get_class()
	}

## 应用模型缩放和位置
func _apply_model_scale() -> void:
	"""根据 size 属性缩放 3D 模型并调整位置让脚底对齐地面"""
	if not model or not is_instance_valid(model):
		return
	
	# 检查是否为圆柱形模型
	if model.get_class() == "MeshInstance3D" and model.mesh is CylinderMesh:
		# 使用圆柱形模型的专用缩放方法
		_apply_cylinder_scale()
		return
	
	# 对于其他类型的模型（如外部加载的.glb模型）
	if model.has_method("apply_size_scale"):
		model.apply_size_scale(size)
	
	# 🔧 关键修复：将模型向下偏移，让脚底对齐地面
	# CharacterBody3D.position.y = 0.05（单位脚底悬浮位置）
	# 模型原点可能在中心，需要向下偏移让脚底对齐地面（y=0）
	# 对于 Goblin 模型，使用固定偏移
	model.position.y = 0.0 # 不偏移，让模型原点对齐单位位置
	
	# 应用模型缩放和位置


## 🔧 [状态栏系统] 创建头顶状态栏（已迁移到UnitDisplay）
func _setup_status_bar() -> void:
	"""创建并设置头顶状态栏"""
	# 使用UnitNameDisplayManager创建名称和生命值显示
	if GameServices.has_unit_name_display_manager():
		var display_manager = GameServices.get_unit_name_display_manager()
		if display_manager:
			# 为当前角色创建名称和生命值显示
			display_manager.create_display_for_unit(self)


## 🔧 [状态栏系统] 更新状态栏血量显示（已移除）
func _update_status_bar_health() -> void:
	"""更新状态栏的血量显示（已迁移到UnitDisplay系统）"""
	# 生命值显示已迁移到UnitDisplay系统
	# 不再需要手动更新状态栏
	pass

## 获取交互范围（基于单位碰撞半径）
func get_interaction_range(target_radius: float = 0.5, buffer: float = 0.3) -> float:
	"""计算与目标的交互范围
	
	@param target_radius: 目标半径（如金矿=0.5，建筑可能更大）
	@param buffer: 缓冲距离（额外的安全距离）
	@return: 有效交互范围
	
	公式：交互范围 = 单位半径 + 目标半径 + 缓冲
	"""
	# 🔧 使用 collision_radius（已根据 size 动态计算）
	return collision_radius + target_radius + buffer

## 使用默认值初始化
func _init_default_values() -> void:
	max_health = 100.0
	current_health = 100.0
	attack = 10.0
	armor = 0.0
	speed = 20.0
	size = 15.0
	attack_range = 3.0
	attack_cooldown = 1.0
	detection_range = 10.0
	collision_radius = 0.3
	
	# 使用默认值初始化

## ============================================================================
## 系统设置
## ============================================================================

## 设置物理系统
func _setup_physics() -> void:
	# 设置运动模式为浮动（不受重力影响，适合俯视角RTS）
	motion_mode = MOTION_MODE_FLOATING
	
	# 🔧 根据 size 动态计算碰撞半径
	# 修复：size应该代表单位的实际大小（厘米）
	# size=18 → 0.18米 = 18厘米（合理的角色大小）
	# 🔧 [避障优化] 缩小碰撞半径，减少碰撞频率
	# 碰撞半径 = size / 200（单位换算，缩小50%）
	var actual_collision_radius = size / 200.0 # size=18 → 0.09米（原来0.18米）
	
	# 创建或更新碰撞形状
	if collision_shape:
		var capsule = CapsuleShape3D.new()
		capsule.radius = actual_collision_radius
		capsule.height = actual_collision_radius * 4.0 # 高度 = 半径的4倍
		collision_shape.shape = capsule
		
		# 🔧 碰撞体位置：让碰撞体底部对齐地面
		# position.y = 半径 × 倍数（让胶囊体底部刚好在 y=0）
		collision_shape.position.y = actual_collision_radius * 0.8
		
		# 设置碰撞体积
	
	# 更新 collision_radius（供其他系统使用）
	collision_radius = actual_collision_radius
	
	# 设置安全边距
	safe_margin = 0.15
	
	# 启用地面悬浮（用于贴合地形起伏）
	enable_ground_hover = true
	hover_height = 0.05 # 悬浮高度（从胶囊体底部开始）

## 🔧 [移除] 导航系统设置已废弃，统一使用 MovementHelper.process_navigation
# func _setup_navigation() -> void:
# 	if not nav_agent:
# 		return
# 	
# 	# 配置导航代理
# 	nav_agent.path_desired_distance = 0.3
# 	nav_agent.target_desired_distance = 1.0
# 	nav_agent.max_speed = speed
# 	nav_agent.radius = collision_radius
# 	nav_agent.height = collision_radius * 2.0
# 	nav_agent.avoidance_enabled = true
# 	nav_agent.path_postprocessing = NavigationPathQueryParameters3D.PATH_POSTPROCESSING_EDGECENTERED
	
	# 🔧 [移除] 导航系统延迟设置已废弃
	# call_deferred("_setup_navigation_deferred")

## 设置碰撞层级
func _setup_collision_layers() -> void:
	# 清空所有层
	collision_layer = 0
	collision_mask = 0
	
	# 根据阵营设置碰撞层
	match faction:
		FactionManager.Faction.MONSTERS:
			set_collision_layer_value(2, true) # 怪物阵营层
		FactionManager.Faction.HEROES:
			set_collision_layer_value(3, true) # 英雄阵营层
		FactionManager.Faction.BEASTS:
			set_collision_layer_value(4, true) # 野兽阵营层
		FactionManager.Faction.NEUTRAL:
			set_collision_layer_value(5, true) # 中立阵营层
	
	# 设置碰撞掩码：检测哪些层
	set_collision_mask_value(1, true) # 检测环境层（墙壁、地形）
	set_collision_mask_value(2, true) # 检测怪物阵营
	set_collision_mask_value(3, true) # 检测英雄阵营
	set_collision_mask_value(4, true) # 检测野兽阵营
	set_collision_mask_value(5, true) # 检测中立阵营
	set_collision_mask_value(6, true) # 检测建筑层

## ============================================================================
## 移动相关
## ============================================================================

## 🔧 [移除] 移动到目标位置函数已废弃，统一使用 MovementHelper.process_navigation
# func move_to_position(target_pos: Vector3) -> void:
# 	if not nav_agent:
# 		return
# 	nav_agent.target_position = target_pos

## 获取网格位置（2D坐标）
## 用于与旧系统兼容，将 3D 位置转换为 2D 网格坐标
func get_grid_position() -> Vector2i:
	return Vector2i(int(global_position.x), int(global_position.z))

## 🔧 [移除] 停止移动和到达检查函数已废弃，统一使用 MovementHelper.process_navigation
# func stop_movement() -> void:
# 	velocity = Vector3.ZERO
# 	if nav_agent:
# 		nav_agent.target_position = global_position
# 
# ## 检查是否到达目标
# func is_at_target() -> bool:
# 	if not nav_agent:
# 		return true
# 	return nav_agent.is_navigation_finished()

## ============================================================================
## 战斗相关
## ============================================================================

## 受到伤害
func take_damage(damage: float, attacker: CharacterBase = null) -> void:
	if not is_alive:
		return
	
	# 计算护甲减免
	var armor_reduction = 1.0 - min(armor * GameBalance.ARMOR_DAMAGE_REDUCTION, GameBalance.MAX_ARMOR_REDUCTION)
	var actual_damage = damage * armor_reduction
	
	var old_health = current_health
	current_health = max(0.0, current_health - actual_damage)
	
	# 🔧 [状态栏系统] 生命值显示已迁移到UnitDisplay系统
	# 不再需要手动更新状态栏
	
	# 发出信号
	health_changed.emit(old_health, current_health)
	attacked.emit(attacker, actual_damage)
	
	# 进入战斗状态
	in_combat = true
	last_combat_time = Time.get_ticks_msec() / 1000.0
	
	# 检查死亡
	if current_health <= 0:
		die()
	
	# 角色受到伤害

## 治疗
func heal(amount: float) -> void:
	if not is_alive:
		return
	
	var old_health = current_health
	current_health = min(max_health, current_health + amount)
	health_changed.emit(old_health, current_health)

## 死亡
func die() -> void:
	if not is_alive:
		return
	
	is_alive = false
	current_health = 0.0
	current_status = 0 # MonstersTypes.MonsterStatus.IDLE - 死亡后重置状态
	died.emit()
	
	# 角色死亡

## 检查是否可以攻击目标
func can_attack_target(target: Node3D) -> bool:
	if not is_alive or not can_attack:
		return false
	if not target or not is_instance_valid(target):
		return false
	
	# 检查距离
	var distance = global_position.distance_to(target.global_position)
	return distance <= attack_range

## ============================================================================
## 目标管理
## ============================================================================

## 设置目标
func set_target(target: Node3D) -> void:
	if current_target != target:
		current_target = target
		target_acquired.emit(target)

## 清除目标
func clear_target() -> void:
	current_target = null

## 检查目标是否有效
func is_target_valid() -> bool:
	return current_target != null and is_instance_valid(current_target)

## ============================================================================
## 状态管理
## ============================================================================

## 改变状态
func change_status(new_status: int) -> void:
	if current_status != new_status:
		var old_status = current_status
		current_status = new_status
		status_changed.emit(old_status, new_status)
		
		# 角色状态变化

## 状态转字符串（调试用）
func _status_to_string(status: int) -> String:
	match status:
		0: return "IDLE" # MonstersTypes.MonsterStatus.IDLE
		1: return "WANDERING" # MonstersTypes.MonsterStatus.WANDERING
		2: return "MOVING" # MonstersTypes.MonsterStatus.MOVING
		3: return "FIGHTING" # MonstersTypes.MonsterStatus.FIGHTING
		4: return "FLEEING" # MonstersTypes.MonsterStatus.FLEEING
		5: return "MINING" # MonstersTypes.MonsterStatus.MINING
		6: return "BUILDING" # MonstersTypes.MonsterStatus.BUILDING
		7: return "DEPOSITING" # MonstersTypes.MonsterStatus.DEPOSITING
		8: return "FETCHING" # MonstersTypes.MonsterStatus.FETCHING
		_: return "UNKNOWN"

## ============================================================================
## 阵营判断
## ============================================================================

## 判断是否为敌人
func is_enemy_of(other: CharacterBase) -> bool:
	if not other or not is_instance_valid(other):
		return false
	
	# 统一阵营系统：不同阵营即为敌人
	# 特殊情况：野兽阵营对所有阵营都是中立的
	if faction == FactionManager.Faction.BEASTS or other.faction == FactionManager.Faction.BEASTS:
		return false
	
	return faction != other.faction

## 判断是否为友军
func is_friend_of(other: CharacterBase) -> bool:
	if not other or not is_instance_valid(other):
		return false
	
	# 相同阵营为友军
	return faction == other.faction

## 判断是否为中立
func is_neutral_to(other: CharacterBase) -> bool:
	if not other or not is_instance_valid(other):
		return false
	
	# 野兽阵营对所有阵营都是中立的
	if faction == FactionManager.Faction.BEASTS:
		return true
	
	# 中立阵营对所有阵营都是中立的
	if faction == FactionManager.Faction.NEUTRAL:
		return true
	
	return false

## ============================================================================
## 查询方法
## ============================================================================

## 获取角色名称
func get_character_name() -> String:
	if character_data:
		return character_data.character_name
	return "Unknown"

## 获取生物类型
func get_creature_type() -> int:
	if character_data:
		return character_data.creature_type
	return 0

## 获取生物类型名称
func get_creature_type_name() -> String:
	# 简化实现，返回类型编号
	return "Type_%d" % get_creature_type()

## 获取生物类型图标
func get_creature_type_icon() -> String:
	# 简化实现，返回默认图标
	return "default_icon"

## 检查是否为特定生物类型
func is_creature_type(creature_type: int) -> bool:
	return get_creature_type() == creature_type

## 验证生物类型是否有效
func validate_creature_type() -> bool:
	var creature_type = get_creature_type()
	# 检查是否为有效的生物类型
	return creature_type != null and creature_type >= 0

## 获取生命值百分比
func get_health_percent() -> float:
	if max_health <= 0:
		return 0.0
	return current_health / max_health

## 是否血量过低
func is_low_health() -> bool:
	return get_health_percent() < Constants.FLEE_HEALTH_THRESHOLD

## 获取角色信息（调试用）
func get_character_info() -> Dictionary:
	var target_name := "none"
	if current_target and is_instance_valid(current_target):
		target_name = current_target.name
	
	return {
		"name": get_character_name(),
		"faction": "Faction_%d" % faction,
		"status": _status_to_string(current_status),
		"health": "%d/%d" % [current_health, max_health],
		"position": global_position,
		"is_alive": is_alive,
		"current_target": target_name
	}

## ============================================================================
## 实用方法
## ============================================================================

## 更新回血（脱离战斗后自动回血）
func update_regeneration(delta: float) -> void:
	if not is_alive:
		return
	
	# 检查是否脱离战斗足够长时间
	var current_time = Time.get_ticks_msec() / 1000.0
	if not in_combat and (current_time - last_combat_time) > Constants.REGENERATION_DELAY:
		# 自动回血
		if current_health < max_health:
			heal(Constants.REGENERATION_RATE * delta)

## 检查敌人是否在范围内
func is_enemy_in_range(enemy: CharacterBase, check_range: float) -> bool:
	if not enemy or not is_instance_valid(enemy) or not enemy.is_alive:
		return false
	return global_position.distance_to(enemy.global_position) <= check_range

## ============================================================================
## 物理系统高级功能
## ============================================================================

## 地面悬浮更新（射线检测贴地）
func _update_ground_hover(delta: float) -> void:
	# 向地面发射射线，检测高度差
	var ray_origin = global_position + Vector3.UP * 10.0
	var ray_target = global_position - Vector3.UP * 20.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
	query.collision_mask = 1 # 只检测环境层
	
	var result = space_state.intersect_ray(query)
	
	if result:
		# 🔧 目标高度 = 地面高度 + 悬浮高度
		# 注意：CharacterBody3D 的 global_position 现在表示脚底位置（因为碰撞形状已向上偏移）
		var target_height = result.position.y + hover_height
		# 平滑地调整单位高度，模拟悬浮
		var new_y = lerp(global_position.y, target_height, hover_smooth_speed * delta)
		global_position.y = new_y

## 根据速度更新旋转（朝向移动方向）
func _update_rotation_from_velocity(delta: float) -> void:
	"""根据移动速度自动旋转单位朝向移动方向
	
	参考：Godot 4 最佳实践 - 使用 atan2 计算Y轴旋转
	"""
	if velocity.length() < 0.001:
		return
	
	# 获取水平移动方向（忽略Y轴）
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	if horizontal_velocity.length() < 0.001:
		return
	
	var movement_direction = horizontal_velocity.normalized()
	
	# 🔧 使用 atan2 计算目标旋转角度
	# atan2(x, z) 计算从 Z 轴正方向到目标方向的角度
	# Godot 的前方是 -Z 轴，所以使用 atan2(x, z)
	var target_rotation = atan2(movement_direction.x, movement_direction.z)
	
	# 🔧 平滑旋转（使用 lerp_angle 处理角度环绕）
	var rotation_speed = 10.0 # 旋转速度（可调整，值越大转向越快）
	rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)

## 击退效果更新
func _update_knockback(delta: float) -> void:
	# 应用击退速度
	velocity = knockback_velocity
	move_and_slide()
	
	# 击退速度衰减
	knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, knockback_decay_rate * delta)
	
	# 当击退速度很小时，结束击退状态
	if knockback_velocity.length() < 0.1:
		is_knockback = false
		knockback_velocity = Vector3.ZERO

## 应用击退效果
func apply_knockback(direction: Vector3, force: float):
	"""应用击退效果（从攻击者方向被击退）"""
	is_knockback = true
	knockback_velocity = direction.normalized() * force
	
	# 触发击退动画（如果有AnimationPlayer）
	if animation_player and animation_player.has_animation("hit"):
		animation_player.play("hit")

## ============================================================================
## 虚方法（子类需要实现）
## ============================================================================

## 更新逻辑（子类重写）
func update_logic(_delta: float) -> void:
	pass

## 获取特定单位的搜索范围（子类重写）
func get_search_range() -> float:
	return detection_range

## 获取游荡速度倍数（子类重写）
func get_wander_speed_multiplier() -> float:
	return Constants.WANDER_SPEED_MULTIPLIER

## ============================================================================
## 远程攻击接口
## ============================================================================

func execute_ranged_attack(target: CharacterBase, projectile_manager: Node) -> void:
	"""执行远程攻击（生成投射物）"""
	if not projectile_manager or not target:
		return
	
	# 获取枪口位置（如果有）
	var muzzle_pos = global_position + Vector3.UP * (collision_radius * 1.5)
	
	# 根据攻击类型生成不同投射物
	match get("attack_type"):
		CombatTypes.AttackType.RANGED_BOW:
			projectile_manager.spawn_arrow(muzzle_pos, target.global_position, self, attack)
		CombatTypes.AttackType.RANGED_GUN:
			projectile_manager.spawn_bullet(muzzle_pos, target.global_position, self, attack)
		CombatTypes.AttackType.MAGIC_SINGLE:
			projectile_manager.spawn_fireball(muzzle_pos, target.global_position, self, attack)
		_:
			# 默认使用箭矢
			projectile_manager.spawn_arrow(muzzle_pos, target.global_position, self, attack)

## ============================================================================
## 状态机辅助方法
## ============================================================================

## 设置移动目标
func set_movement_target(target_position: Vector3) -> void:
	"""设置移动目标位置"""
	if has_method("move_towards"):
		# 如果角色有move_towards方法，使用它
		pass
	else:
		# 默认实现：直接设置velocity
		var direction = (target_position - global_position).normalized()
		velocity = direction * speed

## 移动到目标位置
func move_towards(target_position: Vector3, _delta: float) -> void:
	"""移动到目标位置"""
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

## 获取攻击范围
func get_attack_range() -> float:
	"""获取攻击范围"""
	return attack_range

## 获取攻击力
func get_attack_power() -> float:
	"""获取攻击力"""
	return attack

## 获取健康百分比
func get_health_percentage() -> float:
	"""获取健康百分比"""
	if max_health <= 0:
		return 0.0
	return current_health / max_health

## 恢复健康
func restore_health(amount: float) -> void:
	"""恢复健康"""
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health - amount, current_health)

## 恢复饥饿度（野兽用）
func restore_hunger(_amount: float) -> void:
	"""恢复饥饿度"""
	# 默认实现：无操作
	# 子类可以重写此方法
	pass

## 恢复体力（野兽用）
func restore_stamina(_amount: float) -> void:
	"""恢复体力"""
	# 默认实现：无操作
	# 子类可以重写此方法
	pass

## 获取饥饿度（野兽用）
func get_hunger_level() -> float:
	"""获取饥饿度"""
	# 默认实现：返回0（不饥饿）
	# 子类可以重写此方法
	return 0.0

## 获取体力（野兽用）
func get_stamina_level() -> float:
	"""获取体力"""
	# 默认实现：返回1（满体力）
	# 子类可以重写此方法
	return 1.0

## 检查是否死亡
func is_dead() -> bool:
	"""检查是否死亡"""
	return not is_alive

## 治疗目标（英雄用）
func heal_target(target: Node) -> void:
	"""治疗目标"""
	if target and target.has_method("restore_health"):
		var heal_amount = attack * 0.5 # 治疗量基于攻击力
		target.restore_health(heal_amount)

## ============================================================================
## 生物类型特殊行为
## ============================================================================

## 检查是否为野兽类型
func is_beast() -> bool:
	# 简化实现，基于阵营判断
	return faction == FactionManager.Faction.BEASTS

## 检查是否为怪物类型
func is_monster() -> bool:
	# 简化实现，基于阵营判断
	return faction == FactionManager.Faction.MONSTERS

## 检查是否为英雄类型
func is_hero() -> bool:
	# 简化实现，基于阵营判断
	return faction == FactionManager.Faction.HEROES

## 检查是否为水生生物
func is_aquatic() -> bool:
	# 简化实现，基于阵营和类型判断
	return is_beast() and get_creature_type() in [10, 11, 12, 13, 14, 15, 16] # 水生生物类型编号

## 检查是否为飞行生物
func can_fly() -> bool:
	if character_data and character_data.has_method("get") and character_data.get("can_fly"):
		return character_data.can_fly
	return false

## 检查是否为掠食者
func is_predator() -> bool:
	if character_data and character_data.has_method("get") and character_data.get("is_predator"):
		return character_data.is_predator
	return false

## 获取生物类型描述
func get_creature_description() -> String:
	# 简化实现，返回通用描述
	if is_beast():
		return "生态系统中的野生动物"
	elif is_monster():
		return "敌对怪物单位"
	elif is_hero():
		return "友方英雄单位"
	else:
		return "未知生物类型"
