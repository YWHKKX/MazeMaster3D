extends Node3D
class_name GoblinWorkerModel

## Goblin Worker 模型包装器
## 用于映射游戏逻辑动画名称到实际的 Goblin 模型动画名称

## 动画映射表（Goblin 模型来自 Sketchfab）
const ANIMATION_MAP = {
	"idle": "G_Idle1", # 待机动画
	"move": "G_Walk", # 行走动画
	"work": "G_Attack", # 工作动画（挖矿/建造）⭐
	"attack": "G_Attack", # 攻击动画（战斗，复用 G_Attack）
	"dance": "G_Dance", # 舞蹈动画（备用/庆祝）
	"idle2": "G_Idle2", # 备用待机
	"run": "G_Walk" # 奔跑（使用 G_Walk，可加速播放）
}

@onready var animation_player: AnimationPlayer = null
@onready var skeleton: Skeleton3D = null

func _ready():
	# 🔧 关键修复：只在当前节点的子树中搜索 AnimationPlayer
	# 不要向上查找到场景树根节点，否则所有单位会共享第一个 AnimationPlayer！
	animation_player = _find_animation_player(self)
	skeleton = _find_skeleton(self)
	
	# 删除环境地面节点（如果存在）
	_remove_landscape()
	
	# 🎨 应用苦工专属颜色（棕色）
	set_model_color(Color(0.6, 0.4, 0.2))
	
	# 注意：缩放由 CharacterBase._apply_model_scale() 统一处理
	# 不在这里硬编码缩放值
	
	if animation_player:
		# 自动播放待机动画
		play_animation("idle")
		if OS.is_debug_build():
			print("GoblinWorkerModel [%s]: 已加载 AnimationPlayer，动画列表: %s" % [
				get_instance_id(), animation_player.get_animation_list()
			])
	else:
		push_error("GoblinWorkerModel [%s]: 严重错误 - 未找到 AnimationPlayer！" % get_instance_id())

## ❌ 已移除 _find_scene_root() 
## 原因：向上查找场景根会导致所有单位共享同一个 AnimationPlayer
## 正确做法：只在当前节点的子树中搜索

## 删除 Landscape 环境节点
func _remove_landscape():
	# 查找并删除所有名称包含 "Landscape" 的节点
	var landscape = _find_node_by_name_pattern(self, "Landscape")
	if landscape:
		landscape.queue_free()
		print("GoblinWorkerModel: 已删除环境地面节点")

## 递归查找包含特定名称模式的节点
func _find_node_by_name_pattern(node: Node, pattern: String) -> Node:
	if pattern.to_lower() in node.name.to_lower():
		return node
	
	for child in node.get_children():
		var result = _find_node_by_name_pattern(child, pattern)
		if result:
			return result
	
	return null

## 播放动画（自动映射名称）
func play_animation(logical_name: String, speed: float = 1.0) -> bool:
	"""
	播放动画（自动将逻辑名称映射到实际名称）
	
	@param logical_name: 游戏逻辑中的动画名称（如 "idle", "move", "work"）
	@param speed: 播放速度（1.0 = 正常，2.0 = 2倍速，用于快速移动）
	@return: 是否成功播放
	"""
	if not animation_player:
		return false
	
	# 映射到实际动画名称
	var actual_name = ANIMATION_MAP.get(logical_name, logical_name)
	
	# 🔧 检查动画是否已经在播放（避免重复播放导致卡顿）
	var current_anim = animation_player.current_animation
	if current_anim == actual_name and animation_player.is_playing():
		# 动画已经在播放，只更新速度
		animation_player.speed_scale = speed
		return true
	
	# 尝试播放映射后的动画
	if animation_player.has_animation(actual_name):
		# 获取动画库
		var anim_library = animation_player.get_animation_library("")
		if anim_library:
			var animation = anim_library.get_animation(actual_name)
			if animation:
				# 🔧 设置循环模式（持续循环的动画）
				if logical_name in ["idle", "move", "work", "run"]:
					animation.loop_mode = Animation.LOOP_LINEAR # 循环播放
				else:
					animation.loop_mode = Animation.LOOP_NONE # 单次播放
		
		animation_player.play(actual_name)
		animation_player.speed_scale = speed
		return true
	
	# 如果映射失败，尝试直接使用逻辑名称（兼容性）
	if animation_player.has_animation(logical_name):
		animation_player.play(logical_name)
		animation_player.speed_scale = speed
		return true
	
	push_warning("动画不存在: %s (映射为: %s)" % [logical_name, actual_name])
	return false

## 检查动画是否存在
func has_animation(logical_name: String) -> bool:
	if not animation_player:
		return false
	
	var actual_name = ANIMATION_MAP.get(logical_name, logical_name)
	return animation_player.has_animation(actual_name)

## 获取 AnimationPlayer 引用（供外部访问）
func get_animation_player() -> AnimationPlayer:
	return animation_player

## 获取 Skeleton3D 引用（供外部访问）
func get_skeleton() -> Skeleton3D:
	return skeleton

## 应用体型缩放
func apply_size_scale(size_value: float):
	"""
	根据角色的 size 属性设置模型缩放
	
	@param size_value: CharacterData.size 值（范围 1-200，默认15）
	
	缩放公式：scale = size_value * 0.01
	- size=15 → scale=0.15（标准人形约1.5米高）
	- size=18 → scale=0.18（哥布林约1.8米高）
	- size=20 → scale=0.20（大型单位约2米高）
	"""
	var scale_factor = size_value * 0.01
	scale = Vector3(scale_factor, scale_factor, scale_factor)
	print("GoblinWorkerModel: 应用缩放 size=%f → scale=%f" % [size_value, scale_factor])

## 递归查找 AnimationPlayer 节点
func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	
	for child in node.get_children():
		var result = _find_animation_player(child)
		if result:
			return result
	
	return null

## 递归查找 Skeleton3D 节点
func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	
	for child in node.get_children():
		var result = _find_skeleton(child)
		if result:
			return result
	
	return null


## 🎨 设置模型颜色（苦工专属棕色）
func set_model_color(color: Color):
	"""
	递归设置所有 MeshInstance3D 的材质颜色
	
	@param color: 目标颜色（苦工默认使用棕色区分工程师）
	"""
	_apply_color_to_meshes(self, color)


## 递归应用颜色到所有 MeshInstance3D
func _apply_color_to_meshes(node: Node, color: Color):
	"""
	递归遍历子节点，找到所有 MeshInstance3D 并修改材质颜色
	"""
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		
		# 遍历所有表面材质
		for i in range(mesh_instance.mesh.get_surface_count() if mesh_instance.mesh else 0):
			var material = mesh_instance.get_surface_override_material(i)
			
			# 如果没有覆盖材质，创建新材质
			if not material:
				# 尝试获取原始材质
				if mesh_instance.mesh:
					material = mesh_instance.mesh.surface_get_material(i)
				
				# 如果仍然没有，创建新的 StandardMaterial3D
				if not material:
					material = StandardMaterial3D.new()
				else:
					# 复制原始材质（避免修改共享资源）
					material = material.duplicate()
			else:
				# 复制覆盖材质
				material = material.duplicate()
			
			# 修改颜色
			if material is StandardMaterial3D:
				material.albedo_color = color
				mesh_instance.set_surface_override_material(i, material)
	
	# 递归处理子节点
	for child in node.get_children():
		_apply_color_to_meshes(child, color)
