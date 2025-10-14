extends Node
class_name ProjectileManager

## 投射物管理器 - 统一管理所有投射物
##
## 负责投射物的创建、池化和清理

## 投射物场景（延迟加载）
var ArrowScene = null
var FireballScene = null
var BulletScene = null

## 投射物容器
var projectiles_container: Node3D

## 活跃的投射物
var active_projectiles: Array[Projectile] = []

func _ready():
	_setup_container()
	_load_projectile_scenes()

func _load_projectile_scenes():
	"""延迟加载投射物场景"""
	if ResourceLoader.exists("res://scenes/projectiles/Arrow.tscn"):
		ArrowScene = load("res://scenes/projectiles/Arrow.tscn")
	if ResourceLoader.exists("res://scenes/projectiles/Fireball.tscn"):
		FireballScene = load("res://scenes/projectiles/Fireball.tscn")
	if ResourceLoader.exists("res://scenes/projectiles/Bullet.tscn"):
		BulletScene = load("res://scenes/projectiles/Bullet.tscn")

func _setup_container():
	projectiles_container = Node3D.new()
	projectiles_container.name = "Projectiles"
	add_child(projectiles_container)

## ============================================================================
## 公共接口
## ============================================================================

func spawn_arrow(from: Vector3, to: Vector3, shooter: CharacterBase, damage: float = 10.0) -> Projectile:
	"""生成箭矢"""
	return _spawn_projectile(ArrowScene, from, to, shooter, damage)

func spawn_fireball(from: Vector3, to: Vector3, shooter: CharacterBase, damage: float = 25.0) -> Projectile:
	"""生成火球"""
	return _spawn_projectile(FireballScene, from, to, shooter, damage)

func spawn_bullet(from: Vector3, to: Vector3, shooter: CharacterBase, damage: float = 15.0) -> Projectile:
	"""生成子弹"""
	return _spawn_projectile(BulletScene, from, to, shooter, damage)

func _spawn_projectile(scene: PackedScene, from: Vector3, to: Vector3, shooter: CharacterBase, damage: float) -> Projectile:
	"""生成投射物（内部方法）"""
	if not scene:
		push_warning("ProjectileManager: 投射物场景为空")
		return null
	
	var projectile = scene.instantiate() as Projectile
	if not projectile:
		return null
	
	projectile.global_position = from
	projectile.damage = damage
	projectile.set_shooter(shooter)
	projectile.set_target_direction(from, to)
	
	projectiles_container.add_child(projectile)
	active_projectiles.append(projectile)
	
	# 连接销毁信号进行清理
	projectile.tree_exiting.connect(func(): _on_projectile_destroyed(projectile))
	
	return projectile

func _on_projectile_destroyed(projectile: Projectile):
	"""投射物被销毁时清理"""
	var idx = active_projectiles.find(projectile)
	if idx >= 0:
		active_projectiles.remove_at(idx)

func clear_all():
	"""清空所有投射物"""
	for projectile in active_projectiles.duplicate():
		if is_instance_valid(projectile):
			projectile.queue_free()
	active_projectiles.clear()

func get_projectile_count() -> int:
	return active_projectiles.size()
