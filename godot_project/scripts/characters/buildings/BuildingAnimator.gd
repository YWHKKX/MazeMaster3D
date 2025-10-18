extends Node
class_name BuildingAnimator

## 🏗️ 建筑动画器
## 负责管理3x3x3建筑的动画效果

# 动画状态
var is_playing: bool = false
var current_animation: String = ""
var animation_tween: Tween = null

# 建造动画
var construction_progress: float = 0.0
var construction_animation_duration: float = 2.0

# 功能动画
var function_animations: Dictionary = {}
var loop_animations: Array[String] = []

# 目标节点
var target_building: Building3D = null


func _init():
	"""初始化建筑动画器"""
	name = "BuildingAnimator"


func _ready():
	"""场景准备就绪"""
	# 创建Tween
	animation_tween = create_tween()
	animation_tween.set_parallel(true) # 允许并行动画


func set_target_building(building: Building3D):
	"""设置目标建筑"""
	target_building = building


func play_completion_animation():
	"""播放建造完成动画"""
	if not target_building:
		return
	
	current_animation = "completion"
	is_playing = true
	
	# 创建新的Tween
	animation_tween = create_tween()
	animation_tween.set_parallel(true)
	
	# 获取建筑模型节点
	var model_node = target_building.get_node("Model")
	if not model_node:
		return
	
	# 建造完成效果：缩放 + 发光
	animation_tween.tween_method(_animate_completion_scale, 0.0, 1.0, 1.0)
	animation_tween.tween_method(_animate_completion_glow, 0.0, 1.0, 1.0)
	
	# 动画完成回调
	animation_tween.finished.connect(_on_completion_animation_finished)


func _animate_completion_scale(progress: float):
	"""建造完成缩放动画"""
	if not target_building:
		return
	
	var model_node = target_building.get_node("Model")
	if not model_node:
		return
	
	# 缩放效果：从0.8到1.2再到1.0
	var scale_value = 0.8 + sin(progress * PI) * 0.4
	model_node.scale = Vector3.ONE * scale_value


func _animate_completion_glow(progress: float):
	"""建造完成发光动画"""
	if not target_building:
		return
	
	var model_node = target_building.get_node("Model")
	if not model_node or not model_node is MeshInstance3D:
		return
	
	var material = model_node.material_override
	if not material:
		return
	
	# 发光效果
	material.emission_enabled = true
	material.emission_energy = sin(progress * PI * 2) * 2.0


func _on_completion_animation_finished():
	"""建造完成动画结束"""
	is_playing = false
	current_animation = ""
	
	# 重置模型状态
	if target_building:
		var model_node = target_building.get_node("Model")
		if model_node:
			model_node.scale = Vector3.ONE
			
			# 重置发光
			if model_node is MeshInstance3D:
				var material = model_node.material_override
				if material:
					material.emission_enabled = false
					material.emission_energy = 0.0


func update_construction_progress(progress: float):
	"""更新建造进度动画"""
	construction_progress = progress
	
	# 播放建造进度动画
	_animate_construction_progress(progress)


func _animate_construction_progress(progress: float):
	"""建造进度动画"""
	if not target_building:
		return
	
	# 根据建筑类型播放不同的建造动画
	match target_building.building_type:
		BuildingTypes.BuildingType.ARROW_TOWER:
			_animate_tower_construction(progress)
		BuildingTypes.BuildingType.ARCANE_TOWER:
			_animate_magic_construction(progress)
		BuildingTypes.BuildingType.TREASURY:
			_animate_treasury_construction(progress)
		_:
			_animate_generic_construction(progress)


func _animate_tower_construction(progress: float):
	"""塔楼建造动画"""
	if not target_building:
		return
	
	var model_node = target_building.get_node("Model")
	if not model_node:
		return
	
	# 塔楼从下往上建造
	var height_scale = progress
	model_node.scale.y = height_scale
	
	# 添加旋转效果
	model_node.rotation.y = sin(progress * PI * 4) * 0.1


func _animate_magic_construction(progress: float):
	"""魔法建筑建造动画"""
	if not target_building:
		return
	
	var model_node = target_building.get_node("Model")
	if not model_node:
		return
	
	# 魔法建筑：闪烁 + 缩放
	var scale_factor = 0.5 + progress * 0.5
	model_node.scale = Vector3.ONE * scale_factor
	
	# 透明度效果
	if model_node is MeshInstance3D:
		var material = model_node.material_override
		if material:
			material.albedo_color.a = 0.3 + progress * 0.7


func _animate_treasury_construction(progress: float):
	"""金库建造动画"""
	if not target_building:
		return
	
	var model_node = target_building.get_node("Model")
	if not model_node:
		return
	
	# 金库：金币闪光效果
	if model_node is MeshInstance3D:
		var material = model_node.material_override
		if material:
			# 金色发光
			material.emission_enabled = true
			material.emission = Color.GOLD
			material.emission_energy = sin(progress * PI * 6) * 1.5


func _animate_generic_construction(progress: float):
	"""通用建造动画"""
	if not target_building:
		return
	
	var model_node = target_building.get_node("Model")
	if not model_node:
		return
	
	# 通用：缩放 + 透明度
	var scale_factor = 0.3 + progress * 0.7
	model_node.scale = Vector3.ONE * scale_factor
	
	# 透明度效果
	if model_node is MeshInstance3D:
		var material = model_node.material_override
		if material:
			material.albedo_color.a = 0.2 + progress * 0.8


func play_function_animation(animation_name: String):
	"""播放功能动画"""
	if not target_building:
		return
	
	current_animation = animation_name
	is_playing = true
	
	match animation_name:
		"magic_energy":
			_play_magic_energy_animation()
		"arrow_reload":
			_play_arrow_reload_animation()
		"gold_sparkle":
			_play_gold_sparkle_animation()
		"training":
			_play_training_animation()
		"summoning":
			_play_summoning_animation()
		_:
			LogManager.warning("⚠️ [BuildingAnimator] 未知动画: %s" % animation_name)


func _play_magic_energy_animation():
	"""魔法能量动画"""
	if not target_building:
		return
	
	# 创建循环动画
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_animate_magic_energy, 0.0, 1.0, 2.0)
	
	# 添加到循环动画列表
	if not "magic_energy" in loop_animations:
		loop_animations.append("magic_energy")


func _animate_magic_energy(progress: float):
	"""魔法能量动画效果"""
	if not target_building:
		return
	
	var model_node = target_building.get_node("Model")
	if not model_node or not model_node is MeshInstance3D:
		return
	
	var material = model_node.material_override
	if not material:
		return
	
	# 能量流动效果
	material.emission_enabled = true
	material.emission = Color.PURPLE
	material.emission_energy = 0.5 + sin(progress * PI * 4) * 1.0


func _play_arrow_reload_animation():
	"""箭塔装弹动画"""
	if not target_building:
		return
	
	# 创建装弹动画
	var tween = create_tween()
	tween.tween_method(_animate_arrow_reload, 0.0, 1.0, 1.0)
	tween.finished.connect(_on_arrow_reload_finished)


func _animate_arrow_reload(progress: float):
	"""箭塔装弹动画效果"""
	if not target_building:
		return
	
	var model_node = target_building.get_node("Model")
	if not model_node:
		return
	
	# 装弹效果：轻微震动
	var shake_intensity = sin(progress * PI * 8) * 0.05
	model_node.position = Vector3(shake_intensity, 0, 0)


func _on_arrow_reload_finished():
	"""箭塔装弹动画结束"""
	if target_building:
		var model_node = target_building.get_node("Model")
		if model_node:
			model_node.position = Vector3.ZERO


func _play_gold_sparkle_animation():
	"""金币闪光动画"""
	if not target_building:
		return
	
	# 创建循环闪光动画
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_animate_gold_sparkle, 0.0, 1.0, 1.5)
	
	# 添加到循环动画列表
	if not "gold_sparkle" in loop_animations:
		loop_animations.append("gold_sparkle")


func _animate_gold_sparkle(progress: float):
	"""金币闪光动画效果"""
	if not target_building:
		return
	
	var model_node = target_building.get_node("Model")
	if not model_node or not model_node is MeshInstance3D:
		return
	
	var material = model_node.material_override
	if not material:
		return
	
	# 金色闪光效果
	material.emission_enabled = true
	material.emission = Color.GOLD
	material.emission_energy = sin(progress * PI * 6) * 2.0


func _play_training_animation():
	"""训练动画"""
	if not target_building:
		return
	
	# 创建训练动画
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_animate_training, 0.0, 1.0, 3.0)
	
	# 添加到循环动画列表
	if not "training" in loop_animations:
		loop_animations.append("training")


func _animate_training(progress: float):
	"""训练动画效果"""
	if not target_building:
		return
	
	var model_node = target_building.get_node("Model")
	if not model_node:
		return
	
	# 训练效果：轻微震动 + 旋转
	var shake_intensity = sin(progress * PI * 4) * 0.02
	model_node.position = Vector3(shake_intensity, 0, shake_intensity)
	model_node.rotation.y = sin(progress * PI * 2) * 0.05


func _play_summoning_animation():
	"""召唤动画"""
	if not target_building:
		return
	
	# 创建召唤动画
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_animate_summoning, 0.0, 1.0, 2.0)
	
	# 添加到循环动画列表
	if not "summoning" in loop_animations:
		loop_animations.append("summoning")


func _animate_summoning(progress: float):
	"""召唤动画效果"""
	if not target_building:
		return
	
	var model_node = target_building.get_node("Model")
	if not model_node:
		return
	
	# 召唤效果：缩放 + 发光
	var scale_factor = 1.0 + sin(progress * PI * 4) * 0.1
	model_node.scale = Vector3.ONE * scale_factor
	
	# 发光效果
	if model_node is MeshInstance3D:
		var material = model_node.material_override
		if material:
			material.emission_enabled = true
			material.emission = Color.DARK_MAGENTA
			material.emission_energy = sin(progress * PI * 6) * 1.5


func stop_animation(animation_name: String = ""):
	"""停止动画"""
	if animation_name == "":
		# 停止所有动画
		stop_all_animations()
	else:
		# 停止指定动画
		_stop_specific_animation(animation_name)


func stop_all_animations():
	"""停止所有动画"""
	# 停止Tween
	if animation_tween:
		animation_tween.kill()
	
	# 清空循环动画
	loop_animations.clear()
	
	# 重置状态
	is_playing = false
	current_animation = ""
	
	# 重置模型状态
	if target_building:
		var model_node = target_building.get_node("Model")
		if model_node:
			model_node.scale = Vector3.ONE
			model_node.position = Vector3.ZERO
			model_node.rotation = Vector3.ZERO


func _stop_specific_animation(animation_name: String):
	"""停止指定动画"""
	if animation_name in loop_animations:
		loop_animations.erase(animation_name)
	
	if current_animation == animation_name:
		current_animation = ""
		is_playing = false


func update(delta: float):
	"""更新动画器"""
	# 这里可以添加每帧更新的动画逻辑
	pass


func get_animation_info() -> Dictionary:
	"""获取动画信息"""
	return {
		"is_playing": is_playing,
		"current_animation": current_animation,
		"construction_progress": construction_progress,
		"loop_animations": loop_animations,
		"has_target_building": target_building != null
	}
