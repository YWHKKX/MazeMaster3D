extends Area3D
class_name Projectile

## 投射物基类 - 处理远程攻击的飞行物
##
## 用于箭矢、火球、子弹等

## 投射物配置
@export var speed: float = 20.0
@export var damage: float = 10.0
@export var max_distance: float = 50.0
@export var pierce_count: int = 0 # 穿透次数，0表示命中即消失

## 运动参数
var direction: Vector3 = Vector3.FORWARD
var traveled_distance: float = 0.0
var pierce_remaining: int = 0

## 发射者
var shooter: CharacterBase = null

## 命中过的目标（避免重复命中）
var hit_targets: Array[CharacterBase] = []

## 特效
var trail_effect: Node3D = null

func _ready():
	pierce_remaining = pierce_count
	
	# 连接碰撞信号
	body_entered.connect(_on_body_entered)
	
	# 设置碰撞检测
	set_collision_layer_value(5, true) # projectiles层
	set_collision_mask_value(1, true) # 检测环境
	set_collision_mask_value(2, true) # 检测玩家单位
	set_collision_mask_value(3, true) # 检测敌方单位
	set_collision_mask_value(6, true) # 检测建筑

func _physics_process(delta: float):
	# 向前飞行
	var movement = direction * speed * delta
	global_position += movement
	traveled_distance += movement.length()
	
	# 超出最大距离，销毁
	if traveled_distance >= max_distance:
		_destroy()

func _on_body_entered(body: Node3D):
	"""碰撞检测"""
	# 击中环境，销毁（使用 GameGroups 常量）
	if body.is_in_group(GameGroups.ENVIRONMENT):
		_destroy()
		return
	
	# 击中角色
	if body is CharacterBase:
		var target = body as CharacterBase
		
		# 跳过已命中的目标
		if target in hit_targets:
			return
		
		# 跳过友军
		if shooter and target.faction == shooter.faction:
			return
		
		# 应用伤害
		target.take_damage(int(damage), shooter)
		hit_targets.append(target)
		
		# 触发命中特效
		_spawn_hit_effect(global_position)
		
		# 处理穿透
		if pierce_remaining > 0:
			pierce_remaining -= 1
		else:
			_destroy()

func set_shooter(attacker: CharacterBase):
	"""设置发射者"""
	shooter = attacker

func set_target_direction(from: Vector3, to: Vector3):
	"""设置飞行方向"""
	direction = (to - from).normalized()
	look_at(global_position + direction)

func _spawn_hit_effect(_position: Vector3):
	"""生成命中特效"""
	# TODO: 与VFXManager集成
	pass

func _destroy():
	"""销毁投射物"""
	queue_free()
