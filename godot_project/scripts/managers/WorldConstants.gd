extends Node
class_name WorldConstants

## 🌍 世界常量定义
## 统一管理游戏世界的关键高度和尺寸

# ===== 地面高度系统 =====
## 地面薄层厚度（渲染和碰撞）
const FLOOR_THICKNESS: float = 0.05 # 米

## 地面底部高度
const FLOOR_BOTTOM: float = 0.0 # 米（新基准）

## 地面表面高度（角色站立位置）
const GROUND_SURFACE: float = FLOOR_BOTTOM + FLOOR_THICKNESS # 0.05 米

## 地面mesh中心高度
const FLOOR_CENTER: float = FLOOR_BOTTOM + FLOOR_THICKNESS / 2.0 # 0.025 米

## 瓦片节点中心高度
const TILE_CENTER: float = 0.5 # 米（上移0.5）

# ===== 碰撞高度配置 =====
## 墙体碰撞高度
const WALL_COLLISION_HEIGHT: float = 1.0 # 米

## 建筑碰撞高度
const BUILDING_COLLISION_HEIGHT: float = 0.8 # 米

## 地面碰撞高度
const FLOOR_COLLISION_HEIGHT: float = FLOOR_THICKNESS # 0.05 米

# ===== 角色对齐 =====
## 角色初始Y坐标（应该在地面表面）
const CHARACTER_SPAWN_Y: float = GROUND_SURFACE # -0.45 米

## 哥布林网格偏移（使底部对齐地面）
const GOBLIN_MESH_OFFSET_Y: float = 0.5 # 米

## 人形网格偏移
const HUMANOID_MESH_OFFSET_Y: float = 0.8 # 米

# ===== 辅助函数 =====
static func get_ground_surface_height() -> float:
	"""获取地面表面高度"""
	return GROUND_SURFACE

static func get_character_spawn_position(x: float, z: float) -> Vector3:
	"""获取角色生成位置（自动设置正确的Y坐标并居中到格子中心）
	
	@param x: 格子的X坐标（整数或左下角坐标）
	@param z: 格子的Z坐标（整数或左下角坐标）
	@return: 格子中心的世界坐标 (x+0.5, CHARACTER_SPAWN_Y, z+0.5)
	"""
	# 🔧 修复：将单位放在格子中心，而不是左下角
	# floor() 确保即使传入浮点数也能正确对齐
	var grid_x = floor(x)
	var grid_z = floor(z)
	return Vector3(grid_x + 0.5, CHARACTER_SPAWN_Y, grid_z + 0.5)

static func get_floor_render_offset() -> float:
	"""获取地面渲染偏移"""
	return FLOOR_CENTER

static func is_on_ground(y_position: float, tolerance: float = 0.1) -> bool:
	"""检查Y坐标是否在地面上"""
	return abs(y_position - GROUND_SURFACE) <= tolerance

# ===== 调试信息 =====
static func print_height_info():
	"""打印高度信息（用于调试）"""
	# 世界高度系统信息
