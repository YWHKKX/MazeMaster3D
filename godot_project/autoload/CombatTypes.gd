extends Node

## CombatTypes - 战斗相关类型常量（Autoload单例）
## 
## 统一管理战斗相关的类型、状态、效果等常量

# ============================================================================
# 伤害类型枚举（从Enums.gd迁移）
# ============================================================================

enum DamageType {
	PHYSICAL, ## 物理伤害
	MAGICAL, ## 魔法伤害
	TRUE ## 真实伤害（无视护甲）
}

# 攻击类型枚举（从Enums.gd迁移）
enum AttackType {
	NORMAL, ## 普通攻击
	HEAVY, ## 重击攻击
	AREA, ## 范围攻击
	MAGIC, ## 魔法攻击
	PIERCING, ## 穿透攻击
	RANGED, ## 远程攻击
	## 详细分类（参考战斗系统.md）
	MELEE_SWORD, ## 近战-剑类
	MELEE_SPEAR, ## 近战-矛类
	MELEE_AXE, ## 近战-斧类
	RANGED_BOW, ## 远程-弓箭
	RANGED_GUN, ## 远程-火枪
	RANGED_CROSSBOW, ## 远程-弩
	MAGIC_SINGLE, ## 单体魔法
	MAGIC_AOE, ## 范围魔法
	MAGIC_HEAL, ## 治疗魔法
	## 空洞系统攻击类型
	CAVITY_EXCAVATE ## 空洞挖掘攻击
}

# 击退类型枚举（从Enums.gd迁移）
enum KnockbackType {
	NONE, ## 无击退
	WEAK, ## 弱击退
	NORMAL, ## 普通击退
	STRONG ## 强击退
}

# 技能类型枚举（从Enums.gd迁移）
enum SkillType {
	PASSIVE, ## 被动技能
	ACTIVE, ## 主动技能
	ULTIMATE ## 终极技能
}

# ============================================================================
# 扩展伤害类型（向后兼容）
# ============================================================================

const FIRE_DAMAGE = 2 # 火焰伤害
const ICE_DAMAGE = 3 # 冰霜伤害
const LIGHTNING_DAMAGE = 4 # 闪电伤害
const POISON_DAMAGE = 5 # 毒素伤害
const HOLY_DAMAGE = 6 # 神圣伤害
const SHADOW_DAMAGE = 7 # 暗影伤害

# ============================================================================
# 扩展攻击类型（向后兼容）
# ============================================================================

const SPLASH_ATTACK = 4 # 溅射攻击

# ============================================================================
# 防御类型
# ============================================================================

const LIGHT_ARMOR = 0 # 轻型护甲
const MEDIUM_ARMOR = 1 # 中型护甲
const HEAVY_ARMOR = 2 # 重型护甲
const MAGIC_RESISTANCE = 3 # 魔法抗性
const UNARMORED = 4 # 无护甲

# ============================================================================
# 战斗状态
# ============================================================================

const IDLE_COMBAT = 0 # 空闲
const ENGAGING = 1 # 交战中
const ATTACKING = 2 # 攻击中
const DEFENDING = 3 # 防御中
const RETREATING = 4 # 撤退中
const STUNNED = 5 # 眩晕中
const DEAD_COMBAT = 6 # 死亡

# ============================================================================
# 状态效果类型
# ============================================================================

const BUFF = 0 # 增益效果
const DEBUFF = 1 # 减益效果
const DOT = 2 # 持续伤害
const HOT = 3 # 持续治疗
const CROWD_CONTROL = 4 # 控制效果

# ============================================================================
# 具体状态效果
# ============================================================================

const STUN = "stun" # 眩晕
const SLOW = "slow" # 减速
const ROOT = "root" # 定身
const SILENCE = "silence" # 沉默
const BLIND = "blind" # 致盲
const FEAR = "fear" # 恐惧
const CHARM = "charm" # 魅惑
const SLEEP = "sleep" # 睡眠

const POISON = "poison" # 中毒
const BURN = "burn" # 灼烧
const BLEED = "bleed" # 流血
const FREEZE = "freeze" # 冻结
const SHOCK = "shock" # 电击

const HASTE = "haste" # 加速
const STRENGTHEN = "strengthen" # 强化
const SHIELD = "shield" # 护盾
const REGENERATION = "regen" # 再生
const INVULNERABLE = "invuln" # 无敌

# ============================================================================
# 技能类型
# ============================================================================

const ACTIVE_SKILL = 0 # 主动技能
const PASSIVE_SKILL = 1 # 被动技能
const ULTIMATE_SKILL = 2 # 终极技能
const AURA_SKILL = 3 # 光环技能

# ============================================================================
# 目标类型
# ============================================================================

const TARGET_SELF = 0 # 自己
const TARGET_ALLY = 1 # 友军
const TARGET_ENEMY = 2 # 敌人
const TARGET_ALL = 3 # 所有单位
const TARGET_GROUND = 4 # 地面位置

# ============================================================================
# 初始化
# ============================================================================

func _ready():
	name = "CombatTypes"
	LogManager.info("CombatTypes - 战斗类型常量已初始化")

# ============================================================================
# 工具函数 - 伤害类型
# ============================================================================

## 获取伤害类型名称（中文）
static func get_damage_type_name(damage_type: int) -> String:
	match damage_type:
		DamageType.PHYSICAL:
			return "物理伤害"
		DamageType.MAGICAL:
			return "魔法伤害"
		FIRE_DAMAGE:
			return "火焰伤害"
		ICE_DAMAGE:
			return "冰霜伤害"
		LIGHTNING_DAMAGE:
			return "闪电伤害"
		POISON_DAMAGE:
			return "毒素伤害"
		HOLY_DAMAGE:
			return "神圣伤害"
		SHADOW_DAMAGE:
			return "暗影伤害"
		DamageType.TRUE:
			return "真实伤害"
		_:
			return "未知伤害"

## 获取伤害类型颜色
static func get_damage_type_color(damage_type: int) -> Color:
	match damage_type:
		DamageType.PHYSICAL:
			return Color(0.8, 0.8, 0.8) # 灰白
		DamageType.MAGICAL:
			return Color(0.5, 0.5, 1.0) # 蓝色
		FIRE_DAMAGE:
			return Color(1.0, 0.3, 0.0) # 橙红
		ICE_DAMAGE:
			return Color(0.3, 0.8, 1.0) # 冰蓝
		LIGHTNING_DAMAGE:
			return Color(1.0, 1.0, 0.3) # 亮黄
		POISON_DAMAGE:
			return Color(0.3, 0.8, 0.3) # 毒绿
		HOLY_DAMAGE:
			return Color(1.0, 0.9, 0.5) # 金黄
		SHADOW_DAMAGE:
			return Color(0.4, 0.2, 0.6) # 暗紫
		DamageType.TRUE:
			return Color(1.0, 1.0, 1.0) # 纯白
		_:
			return Color(1.0, 0.0, 1.0) # 品红

## 检查伤害类型是否是魔法系
static func is_magical_damage(damage_type: int) -> bool:
	return damage_type in [DamageType.MAGICAL, FIRE_DAMAGE, ICE_DAMAGE, LIGHTNING_DAMAGE, HOLY_DAMAGE, SHADOW_DAMAGE]

## 检查伤害类型是否是元素系
static func is_elemental_damage(damage_type: int) -> bool:
	return damage_type in [FIRE_DAMAGE, ICE_DAMAGE, LIGHTNING_DAMAGE]

# ============================================================================
# 工具函数 - 攻击类型
# ============================================================================

## 获取攻击类型名称（中文）
static func get_attack_type_name(attack_type: int) -> String:
	match attack_type:
		AttackType.NORMAL:
			return "近战攻击"
		AttackType.RANGED:
			return "远程攻击"
		AttackType.MAGIC:
			return "魔法攻击"
		AttackType.AREA:
			return "范围攻击"
		SPLASH_ATTACK:
			return "溅射攻击"
		_:
			return "未知攻击"

# ============================================================================
# 工具函数 - 状态效果
# ============================================================================

## 获取状态效果名称（中文）
static func get_effect_name(effect: String) -> String:
	match effect:
		STUN:
			return "眩晕"
		SLOW:
			return "减速"
		ROOT:
			return "定身"
		SILENCE:
			return "沉默"
		BLIND:
			return "致盲"
		FEAR:
			return "恐惧"
		CHARM:
			return "魅惑"
		SLEEP:
			return "睡眠"
		POISON:
			return "中毒"
		BURN:
			return "灼烧"
		BLEED:
			return "流血"
		FREEZE:
			return "冻结"
		SHOCK:
			return "电击"
		HASTE:
			return "加速"
		STRENGTHEN:
			return "强化"
		SHIELD:
			return "护盾"
		REGENERATION:
			return "再生"
		INVULNERABLE:
			return "无敌"
		_:
			return "未知效果"

## 检查是否是控制效果
static func is_crowd_control(effect: String) -> bool:
	return effect in [STUN, ROOT, SILENCE, BLIND, FEAR, CHARM, SLEEP, FREEZE]

## 检查是否是负面效果
static func is_debuff_effect(effect: String) -> bool:
	return effect in [STUN, SLOW, ROOT, SILENCE, BLIND, FEAR, POISON, BURN, BLEED, FREEZE, SHOCK]

## 检查是否是增益效果
static func is_buff_effect(effect: String) -> bool:
	return effect in [HASTE, STRENGTHEN, SHIELD, REGENERATION, INVULNERABLE]

## 检查是否是持续伤害效果
static func is_dot_effect(effect: String) -> bool:
	return effect in [POISON, BURN, BLEED]

# ============================================================================
# 工具函数 - 目标类型
# ============================================================================

## 获取目标类型名称（中文）
static func get_target_type_name(target_type: int) -> String:
	match target_type:
		TARGET_SELF:
			return "自己"
		TARGET_ALLY:
			return "友军"
		TARGET_ENEMY:
			return "敌人"
		TARGET_ALL:
			return "所有单位"
		TARGET_GROUND:
			return "地面"
		_:
			return "未知目标"

# ============================================================================
# 战斗计算相关
# ============================================================================

## 计算护甲减伤
static func calculate_armor_reduction(armor: int) -> float:
	"""计算护甲提供的伤害减免百分比"""
	return armor / (armor + 100.0)

## 计算实际伤害
static func calculate_actual_damage(base_damage: float, armor: int, damage_type: int) -> float:
	"""计算考虑护甲后的实际伤害"""
	if damage_type == DamageType.TRUE:
		return base_damage # 真实伤害无视护甲
	
	var reduction = calculate_armor_reduction(armor)
	return base_damage * (1.0 - reduction)

## 计算暴击伤害
static func calculate_critical_damage(base_damage: float, crit_multiplier: float = 2.0) -> float:
	"""计算暴击伤害"""
	return base_damage * crit_multiplier
