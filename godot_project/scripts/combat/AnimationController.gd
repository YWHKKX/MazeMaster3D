extends Node
class_name AnimationController

## 动画控制器 - 管理角色动画状态和过渡
##
## 集成 AnimationTree 和 AnimationPlayer
## 参考：战斗系统.md

## 动画组件引用
@onready var animation_tree: AnimationTree = $"../AnimationTree"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

## 状态机（从AnimationTree获取）
var state_machine: AnimationNodeStateMachinePlayback

## 当前动画状态
var current_animation: String = "idle"

## 动画配置
var animation_config = {
	"blend_time": 0.2, # 动画过渡时间
	"attack_blend_time": 0.1, # 攻击过渡更快
}

func _ready():
	if animation_tree:
		animation_tree.active = true
		state_machine = animation_tree.get("parameters/playback")
	
	# 连接动画结束信号
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)

## ============================================================================
## 公共接口
## ============================================================================

func play_idle():
	"""播放待机动画"""
	_travel_to("idle")
	current_animation = "idle"

func play_move():
	"""播放移动动画"""
	_travel_to("move")
	current_animation = "move"

func play_attack():
	"""播放攻击动画"""
	_travel_to("attack")
	current_animation = "attack"

func play_hit():
	"""播放受击动画"""
	_travel_to("hit")
	current_animation = "hit"

func play_death():
	"""播放死亡动画"""
	_travel_to("death")
	current_animation = "death"

func play_work():
	"""播放工作动画（挖矿/建造）"""
	_travel_to("work")
	current_animation = "work"

## ============================================================================
## 内部方法
## ============================================================================

func _travel_to(state_name: String):
	"""切换动画状态"""
	if state_machine:
		state_machine.travel(state_name)
	elif animation_player and animation_player.has_animation(state_name):
		# 回退方案：直接播放动画
		animation_player.play(state_name)

func _on_animation_finished(anim_name: String):
	"""动画结束回调"""
	match anim_name:
		"attack":
			# 攻击结束，返回待机
			play_idle()
		"hit":
			# 受击结束，返回待机
			play_idle()
		"death":
			# 死亡动画结束
			get_parent().set_physics_process(false)

## ============================================================================
## 辅助方法
## ============================================================================

func is_playing_attack() -> bool:
	"""检查是否在播放攻击动画"""
	return current_animation == "attack"

func is_playing_death() -> bool:
	"""检查是否在播放死亡动画"""
	return current_animation == "death"

func get_current_animation() -> String:
	"""获取当前动画名称"""
	return current_animation

func set_animation_speed(speed: float):
	"""设置动画播放速度"""
	if animation_tree:
		animation_tree.set("parameters/TimeScale/scale", speed)
	elif animation_player:
		animation_player.speed_scale = speed
