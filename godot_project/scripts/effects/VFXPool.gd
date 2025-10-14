extends Node
class_name VFXPool

## 特效对象池 - 管理频繁创建/销毁的特效
##
## 使用对象池技术避免内存抖动和GC压力
## 参考：战斗系统.md

## 池化的特效场景
var vfx_scene: PackedScene

## 对象池
var pool: Array[Node3D] = []

## 正在使用的特效
var active_effects: Array[Node3D] = []

## 池配置
var pool_config = {
	"initial_size": 10,
	"max_size": 50,
	"auto_return_time": 3.0 # 3秒后自动回收
}

## 统计数据
var stats = {
	"total_spawned": 0,
	"total_returned": 0,
	"peak_active": 0,
	"pool_hits": 0,
	"pool_misses": 0
}

func _init(effect_scene: PackedScene, initial_size: int = 10):
	vfx_scene = effect_scene
	pool_config.initial_size = initial_size
	_preallocate_pool()

func _preallocate_pool():
	"""预分配对象池"""
	if not vfx_scene:
		return
	
	for i in range(pool_config.initial_size):
		var effect = vfx_scene.instantiate()
		effect.hide()
		effect.set_process(false)
		pool.append(effect)

func get_effect() -> Node3D:
	"""从池中获取特效"""
	var effect: Node3D
	
	if pool.is_empty():
		# 池为空，创建新实例
		if not vfx_scene:
			return null
		effect = vfx_scene.instantiate()
		stats.pool_misses += 1
	else:
		# 从池中取出
		effect = pool.pop_back()
		stats.pool_hits += 1
	
	# 激活特效
	effect.show()
	effect.set_process(true)
	active_effects.append(effect)
	stats.total_spawned += 1
	
	# 更新峰值统计
	if active_effects.size() > stats.peak_active:
		stats.peak_active = active_effects.size()
	
	return effect

func return_effect(effect: Node3D):
	"""归还特效到池中"""
	if not effect or not is_instance_valid(effect):
		return
	
	# 从活跃列表移除
	var idx = active_effects.find(effect)
	if idx >= 0:
		active_effects.remove_at(idx)
	
	# 重置特效状态
	effect.hide()
	effect.set_process(false)
	
	# 如果池未满，归还到池中
	if pool.size() < pool_config.max_size:
		pool.append(effect)
		stats.total_returned += 1
	else:
		# 池已满，销毁实例
		effect.queue_free()

func spawn_at(position: Vector3, rotation_euler: Vector3 = Vector3.ZERO) -> Node3D:
	"""在指定位置生成特效"""
	var effect = get_effect()
	if not effect:
		return null
	
	effect.global_position = position
	effect.rotation = rotation_euler
	
	# 设置自动回收计时器
	_setup_auto_return(effect)
	
	return effect

func _setup_auto_return(effect: Node3D):
	"""设置特效自动回收"""
	var timer = Timer.new()
	timer.wait_time = pool_config.auto_return_time
	timer.one_shot = true
	timer.timeout.connect(func(): return_effect(effect))
	effect.add_child(timer)
	timer.start()

func clear_all():
	"""清空所有活跃特效"""
	for effect in active_effects.duplicate():
		return_effect(effect)

func get_stats() -> Dictionary:
	"""获取统计信息"""
	return {
		"pool_size": pool.size(),
		"active_count": active_effects.size(),
		"total_spawned": stats.total_spawned,
		"total_returned": stats.total_returned,
		"peak_active": stats.peak_active,
		"hit_rate": float(stats.pool_hits) / max(1, stats.pool_hits + stats.pool_misses)
	}
