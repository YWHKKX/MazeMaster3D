## 角色数据资源
##
## 使用 Godot Resource 存储角色的静态数据。
## 这些数据可以在编辑器中创建和编辑，也可以序列化保存。
##
## 使用方法：
## 1. 在编辑器中: 创建 → 资源 → CharacterData
## 2. 在代码中: var data = CharacterData.new()
class_name CharacterData
extends Resource

## ============================================================================
## 基础信息
## ============================================================================

## 角色名称（如"哥布林苦工"、"骑士"）
@export var character_name: String = "未命名"

## 角色类型（使用整数类型，兼容所有角色类型系统）
@export var creature_type: int = 0

## 角色图标
@export var icon: Texture2D

## 角色描述
@export_multiline var description: String = ""

## ============================================================================
## 基础属性
## ============================================================================

## 最大生命值
@export_range(10, 10000, 10) var max_health: float = 100.0

## 攻击力
@export_range(0, 500, 1) var attack: float = 10.0

## 防御力/护甲值
@export_range(0, 100, 1) var armor: float = 0.0

## 移动速度
@export_range(1, 100, 1) var speed: float = 20.0

## 体型大小（影响碰撞半径和渲染大小）
@export_range(1, 200, 1) var size: float = 15.0

## ============================================================================
## 战斗属性
## ============================================================================

## 攻击范围
@export_range(0.5, 50, 0.5) var attack_range: float = 3.0

## 攻击冷却时间（秒）
@export_range(0.1, 10, 0.1) var attack_cooldown: float = 1.0

## 检测范围（感知敌人的范围）
@export_range(1, 50, 1) var detection_range: float = 10.0

## 攻击类型
@export var attack_type: CombatTypes.AttackType = CombatTypes.AttackType.NORMAL

## 伤害类型
@export var damage_type: CombatTypes.DamageType = CombatTypes.DamageType.PHYSICAL

## ============================================================================
## 特效和动画资源
## ============================================================================

## 攻击特效场景
@export var attack_vfx: PackedScene

## 命中特效场景
@export var hit_vfx: PackedScene

## 投射物场景（远程攻击用）
@export var projectile_scene: PackedScene

## ============================================================================
## 动画资源
## ============================================================================

## 攻击动画名称
@export var attack_animation: String = "attack"

## 死亡动画名称
@export var death_animation: String = "death"

## 移动动画名称
@export var move_animation: String = "move"

## 待机动画名称
@export var idle_animation: String = "idle"

## 受击动画名称
@export var hit_animation: String = "hit"

## ============================================================================
## 经济属性
## ============================================================================

## 召唤成本（金币）
@export_range(0, 1000, 10) var cost_gold: int = 100

## 召唤成本（魔力）
@export_range(0, 100, 1) var cost_mana: int = 0

## 维护费用（每秒消耗）
@export_range(0, 10, 0.1) var upkeep: float = 0.5

## ============================================================================
## 特殊能力
## ============================================================================

## 特殊能力描述
@export_multiline var special_ability: String = "无"

## 技能列表（预留，用于技能系统）
@export var abilities: Array[String] = []

## ============================================================================
## 视觉属性
## ============================================================================

## 角色颜色（用于材质）
@export var color: Color = Color.WHITE

## 发光颜色（用于特殊效果）
@export var glow_color: Color = Color.TRANSPARENT

## ============================================================================
## 物理属性
## ============================================================================

## 击退类型
@export var knockback_type: CombatTypes.KnockbackType = CombatTypes.KnockbackType.NORMAL

## 免疫列表
@export_flags("击退", "眩晕", "减速", "中毒", "燃烧", "冰冻") var immunities: int = 0

## 是否可以飞行
@export var can_fly: bool = false

## 是否受重力影响
@export var affected_by_gravity: bool = false

## ============================================================================
## 工作属性（工人单位）
## ============================================================================

## 是否是工作单位
@export var is_worker: bool = false

## 挖矿速度（如果是矿工）
@export_range(0, 10, 0.1) var mining_speed: float = 2.0

## 携带容量（如果是工人）
@export_range(0, 200, 10) var carry_capacity: int = 20

## 建造速度（如果是工程师）
@export_range(0, 10, 0.1) var building_speed: float = 1.0

## ============================================================================
## 生态适应属性
## ============================================================================

## 原始环境适应
@export var primitive_adaptation: bool = false

## 多样化觅食
@export var versatile_feeding: bool = false

## 掠食者特化
@export var predator_specialization: bool = false

## 杂食适应
@export var omnivore_adaptation: bool = false

## 食物适应性（0.0-1.0）
@export_range(0.0, 1.0, 0.1) var food_versatility: float = 0.5

## 主动狩猎
@export var active_hunting: bool = false

## 狩猎半径
@export_range(1.0, 100.0, 1.0) var hunting_radius: float = 20.0

## 狩猎持续时间（秒）
@export_range(1.0, 60.0, 1.0) var hunting_duration: float = 10.0

## 咆哮半径
@export_range(1.0, 100.0, 1.0) var roar_radius: float = 15.0

## 咆哮伤害
@export_range(0, 50, 1) var roar_damage: int = 5

## 咆哮持续时间（秒）
@export_range(1.0, 30.0, 1.0) var roar_duration: float = 3.0

## ============================================================================
## 辅助方法
## ============================================================================

## 计算碰撞半径
func get_collision_radius() -> float:
	return size * Constants.COLLISION_RADIUS_MULTIPLIER / 100.0 * Constants.TILE_SIZE

## 计算实际伤害（考虑护甲）
func calculate_damage_dealt(base_damage: float) -> float:
	return base_damage * (1.0 + attack / 100.0)

## 计算受到的伤害（考虑护甲）
func calculate_damage_taken(incoming_damage: float) -> float:
	var armor_reduction = 1.0 - min(armor * GameBalance.ARMOR_DAMAGE_REDUCTION, GameBalance.MAX_ARMOR_REDUCTION)
	return incoming_damage * armor_reduction

## 检查是否有特定免疫
func has_immunity(immunity_type: int) -> bool:
	return (immunities & (1 << immunity_type)) != 0

## 克隆数据（创建副本）
func clone() -> CharacterData:
	var new_data = CharacterData.new()
	new_data.character_name = character_name
	new_data.creature_type = creature_type
	new_data.max_health = max_health
	new_data.attack = attack
	new_data.armor = armor
	new_data.speed = speed
	new_data.size = size
	new_data.attack_range = attack_range
	new_data.attack_cooldown = attack_cooldown
	new_data.detection_range = detection_range
	new_data.cost_gold = cost_gold
	new_data.cost_mana = cost_mana
	new_data.upkeep = upkeep
	new_data.color = color
	new_data.knockback_type = knockback_type
	new_data.can_fly = can_fly
	new_data.affected_by_gravity = affected_by_gravity
	new_data.is_worker = is_worker
	new_data.mining_speed = mining_speed
	new_data.carry_capacity = carry_capacity
	new_data.building_speed = building_speed
	new_data.primitive_adaptation = primitive_adaptation
	new_data.versatile_feeding = versatile_feeding
	new_data.predator_specialization = predator_specialization
	new_data.omnivore_adaptation = omnivore_adaptation
	new_data.food_versatility = food_versatility
	new_data.active_hunting = active_hunting
	new_data.hunting_radius = hunting_radius
	new_data.hunting_duration = hunting_duration
	new_data.roar_radius = roar_radius
	new_data.roar_damage = roar_damage
	new_data.roar_duration = roar_duration
	return new_data

## 转换为字典（用于调试和序列化）
func to_dict() -> Dictionary:
	return {
		"character_name": character_name,
		"creature_type": creature_type,
		"max_health": max_health,
		"attack": attack,
		"armor": armor,
		"speed": speed,
		"size": size,
		"attack_range": attack_range,
		"attack_cooldown": attack_cooldown,
		"detection_range": detection_range,
		"cost_gold": cost_gold,
		"cost_mana": cost_mana,
		"upkeep": upkeep,
		"special_ability": special_ability,
		"is_worker": is_worker,
		"primitive_adaptation": primitive_adaptation,
		"versatile_feeding": versatile_feeding,
		"predator_specialization": predator_specialization,
		"omnivore_adaptation": omnivore_adaptation,
		"food_versatility": food_versatility,
		"active_hunting": active_hunting,
		"hunting_radius": hunting_radius,
		"hunting_duration": hunting_duration,
		"roar_radius": roar_radius,
		"roar_damage": roar_damage,
		"roar_duration": roar_duration
	}

## 从字典加载（用于反序列化）
func from_dict(data: Dictionary) -> void:
	if data.has("character_name"): character_name = data["character_name"]
	if data.has("max_health"): max_health = data["max_health"]
	if data.has("attack"): attack = data["attack"]
	if data.has("armor"): armor = data["armor"]
	if data.has("speed"): speed = data["speed"]
	if data.has("size"): size = data["size"]
	if data.has("attack_range"): attack_range = data["attack_range"]
	if data.has("attack_cooldown"): attack_cooldown = data["attack_cooldown"]
	if data.has("cost_gold"): cost_gold = data["cost_gold"]
	if data.has("cost_mana"): cost_mana = data["cost_mana"]
	if data.has("upkeep"): upkeep = data["upkeep"]
	if data.has("special_ability"): special_ability = data["special_ability"]
	if data.has("is_worker"): is_worker = data["is_worker"]
	if data.has("primitive_adaptation"): primitive_adaptation = data["primitive_adaptation"]
	if data.has("versatile_feeding"): versatile_feeding = data["versatile_feeding"]
	if data.has("predator_specialization"): predator_specialization = data["predator_specialization"]
	if data.has("omnivore_adaptation"): omnivore_adaptation = data["omnivore_adaptation"]
	if data.has("food_versatility"): food_versatility = data["food_versatility"]
	if data.has("active_hunting"): active_hunting = data["active_hunting"]
	if data.has("hunting_radius"): hunting_radius = data["hunting_radius"]
	if data.has("hunting_duration"): hunting_duration = data["hunting_duration"]
	if data.has("roar_radius"): roar_radius = data["roar_radius"]
	if data.has("roar_damage"): roar_damage = data["roar_damage"]
	if data.has("roar_duration"): roar_duration = data["roar_duration"]
