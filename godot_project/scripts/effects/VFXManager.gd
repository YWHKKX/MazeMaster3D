extends Node
class_name VFXManager

## 特效管理器 - 统一管理所有游戏特效
##
## 负责：
## - 特效池管理
## - 特效播放
## - 性能优化（LOD、池化）

## 特效池字典
var effect_pools: Dictionary = {} # effect_name -> VFXPool

## 特效场景预加载
var effect_scenes = {
	"hit_melee": "res://effects/hit_melee.tscn",
	"hit_ranged": "res://effects/hit_ranged.tscn",
	"hit_magic": "res://effects/hit_magic.tscn",
	"muzzle_flash": "res://effects/muzzle_flash.tscn",
	"explosion": "res://effects/explosion.tscn",
	"heal": "res://effects/heal.tscn",
	"blood_splash": "res://effects/blood_splash.tscn",
	"death": "res://effects/death.tscn"
}

## 父节点（所有特效添加到此节点下）
var effects_container: Node3D

func _ready():
	_setup_effects_container()
	_initialize_pools()

func _setup_effects_container():
	"""设置特效容器"""
	effects_container = Node3D.new()
	effects_container.name = "Effects"
	add_child(effects_container)

func _initialize_pools():
	"""初始化所有特效池"""
	for effect_name in effect_scenes.keys():
		var scene_path = effect_scenes[effect_name]
		if ResourceLoader.exists(scene_path):
			var scene = load(scene_path)
			var pool = VFXPool.new(scene, 5)
			pool.name = effect_name + "_Pool"
			add_child(pool)
			effect_pools[effect_name] = pool

## ============================================================================
## 公共接口
## ============================================================================

func play_hit_effect(position: Vector3, attack_type: Enums.AttackType):
	"""播放命中特效"""
	var effect_name = _get_hit_effect_name(attack_type)
	spawn_effect(effect_name, position)

func play_muzzle_flash(position: Vector3, direction: Vector3):
	"""播放枪口火焰特效"""
	var effect = spawn_effect("muzzle_flash", position)
	if effect:
		effect.look_at(position + direction)

func play_death_effect(position: Vector3):
	"""播放死亡特效"""
	spawn_effect("death", position)

func play_heal_effect(position: Vector3):
	"""播放治疗特效"""
	spawn_effect("heal", position)

func spawn_effect(effect_name: String, position: Vector3, rotation: Vector3 = Vector3.ZERO) -> Node3D:
	"""生成特效"""
	if not effect_pools.has(effect_name):
		push_warning("VFXManager: 特效池不存在: " + effect_name)
		return null
	
	var pool: VFXPool = effect_pools[effect_name]
	var effect = pool.spawn_at(position, rotation)
	
	if effect and effects_container:
		effects_container.add_child(effect)
	
	return effect

func _get_hit_effect_name(attack_type: Enums.AttackType) -> String:
	"""根据攻击类型获取命中特效名称"""
	match attack_type:
		Enums.AttackType.MELEE_SWORD, Enums.AttackType.MELEE_SPEAR, Enums.AttackType.MELEE_AXE:
			return "hit_melee"
		Enums.AttackType.RANGED_BOW, Enums.AttackType.RANGED_GUN, Enums.AttackType.RANGED_CROSSBOW:
			return "hit_ranged"
		Enums.AttackType.MAGIC_SINGLE, Enums.AttackType.MAGIC_AOE:
			return "hit_magic"
		_:
			return "hit_melee"

## ============================================================================
## 统计
## ============================================================================

func get_stats() -> Dictionary:
	"""获取所有特效池的统计信息"""
	var all_stats = {}
	for effect_name in effect_pools.keys():
		all_stats[effect_name] = effect_pools[effect_name].get_stats()
	return all_stats

func clear_all_effects():
	"""清空所有活跃特效"""
	for pool in effect_pools.values():
		pool.clear_all()
