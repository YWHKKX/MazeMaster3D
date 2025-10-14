## 游戏常量和配置
##
## 此文件定义了游戏中所有的基础常量，包括地图大小、战斗参数、
## 物理系统常量、UI常量等。保持与Python版本的constants.py一致。
class_name Constants
extends Object

## ============================================================================
## 地图和世界设置
## ============================================================================

const MAP_WIDTH: int = 50
const MAP_HEIGHT: int = 30
const TILE_SIZE: float = 2.0 # Godot 3D中的网格大小
const FPS_TARGET: int = 60

## ============================================================================
## 窗口设置
## ============================================================================

const WINDOW_WIDTH: int = 1200
const WINDOW_HEIGHT: int = 800

## ============================================================================
## 战斗系统常量
## ============================================================================

const DEFAULT_ATTACK_RANGE: float = 3.0 # 3D空间中的攻击范围
const DEFAULT_UNIT_SIZE: float = 1.5
const DEFAULT_CREATURE_DETECTION_RANGE: float = 15.0

## 追击范围倍数
const MELEE_PURSUIT_MULTIPLIER: float = 2.5 # 近战单位追击范围倍数
const RANGED_PURSUIT_MULTIPLIER: float = 1.0 # 远程单位追击范围倍数

## 移动和追击常量
const FLEE_DISTANCE: float = 10.0
const MAP_BORDER_BUFFER: float = 5.0
const APPROACH_BUFFER: float = 1.0
const TARGET_SWITCH_BUFFER: float = 1.5
const PURSUIT_RANGE_MULTIPLIER: float = 2.5 # 追击范围是攻击范围的倍数

## 速度倍数
const DEFAULT_SPEED_MULTIPLIER: float = 1.0
const COMBAT_SPEED_MULTIPLIER: float = 1.2
const PATROL_SPEED_MULTIPLIER: float = 0.6
const WANDER_SPEED_MULTIPLIER: float = 0.5

## 血量阈值
const FLEE_HEALTH_THRESHOLD: float = 0.3 # 30%血量以下逃跑

## ============================================================================
## 时间常量
## ============================================================================

const FRAME_TIME_MS: float = 16.67 # 60 FPS的帧时间
const DELTA_TIME_DEFAULT: float = 16.67 # 默认delta_time

## ============================================================================
## 物理系统常量
## ============================================================================

const COLLISION_RADIUS_MULTIPLIER: float = 0.6
const MIN_COLLISION_RADIUS: float = 0.5 # 3D空间中的最小碰撞半径

## 击退系统常量 - 固定距离机制
const KNOCKBACK_DISTANCE_WEAK: float = 0.8 # 弱击退距离
const KNOCKBACK_DISTANCE_NORMAL: float = 1.5 # 普通击退距离
const KNOCKBACK_DISTANCE_STRONG: float = 3.0 # 强击退距离
const KNOCKBACK_DURATION: float = 0.3 # 击退持续时间
const KNOCKBACK_SPEED: float = 5.0 # 击退速度
const WALL_COLLISION_DAMAGE_RATIO: float = 0.15
const MIN_WALL_DAMAGE: float = 2.0
const MAX_WALL_DAMAGE: float = 15.0
const WALL_BOUNCE_RATIO: float = 0.6
const MIN_BOUNCE_DISTANCE: float = 0.8
const SPATIAL_HASH_CELL_SIZE: float = 5.0
const MAX_UNITS_PER_CELL: int = 20
const UPDATE_FREQUENCY: int = 60

## ============================================================================
## 移动系统常量
## ============================================================================

const STUCK_THRESHOLD: int = 30
const PATH_UPDATE_INTERVAL: float = 0.5
const MIN_DISTANCE_THRESHOLD: float = 2.0
const PATHFINDING_TIMEOUT: float = 2.0
const ARRIVAL_DISTANCE: float = 1.5
const SIDE_MOVE_DISTANCE: float = 0.5
const WANDER_ATTEMPT_COUNT: int = 10
const WANDER_RANGE: int = 3

## ============================================================================
## 建筑系统常量
## ============================================================================

const DEFAULT_BUILD_TIME: float = 60.0
const DEFAULT_BUILD_HEALTH: float = 200.0
const DEFAULT_BUILD_ARMOR: float = 5.0
const UPGRADE_TIME_MULTIPLIER: float = 0.5
const EFFICIENCY_UPGRADE_BONUS: float = 0.1
const MAX_EFFICIENCY: float = 2.0

## ============================================================================
## UI常量
## ============================================================================

const PANEL_ALPHA: float = 0.86 # 220/255
const HEALTH_BAR_HEIGHT: int = 4
const HEALTH_BAR_WIDTH: int = 20
const HEALTH_COLOR_HEALTHY: float = 0.6
const HEALTH_COLOR_WARNING: float = 0.3
const SCROLL_SPEED: int = 20
const BUTTON_HEIGHT: int = 25
const ITEM_HEIGHT: int = 20
const LIST_ITEM_HEIGHT: int = 30
const TEXT_LINE_SPACING: int = 20
const BUTTON_PADDING: int = 10
const TEXT_RIGHT_OFFSET: int = 80
const STARS_RIGHT_OFFSET: int = 100

## ============================================================================
## 实体系统常量
## ============================================================================

const REGENERATION_DELAY: float = 10.0 # 脱离战斗后开始回血的延迟时间
const REGENERATION_RATE: float = 1.0 # 每秒回血量
const TARGET_SEARCH_COOLDOWN: float = 0.5 # 目标搜索冷却时间
const TARGET_VALIDITY_TIME: float = 3.0 # 目标有效性时间

## 各单位搜索范围
const SEARCH_RANGE_IMP: float = 12.0
const SEARCH_RANGE_GARGOYLE: float = 15.0
const SEARCH_RANGE_FIRE_SALAMANDER: float = 14.0
const SEARCH_RANGE_SHADOW_MAGE: float = 16.0
const SEARCH_RANGE_TREE_GUARDIAN: float = 10.0
const SEARCH_RANGE_SHADOW_LORD: float = 18.0
const SEARCH_RANGE_BONE_DRAGON: float = 20.0
const SEARCH_RANGE_HELLHOUND: float = 13.0
const SEARCH_RANGE_STONE_GOLEM: float = 11.0
const SEARCH_RANGE_SUCCUBUS: float = 14.0
const SEARCH_RANGE_GOBLIN_ENGINEER: float = 8.0
const SEARCH_RANGE_GOBLIN_WORKER: float = 8.0

## 各单位游荡速度倍数
const WANDER_SPEED_IMP: float = 0.6
const WANDER_SPEED_GARGOYLE: float = 0.4
const WANDER_SPEED_FIRE_SALAMANDER: float = 0.7
const WANDER_SPEED_SHADOW_MAGE: float = 0.5
const WANDER_SPEED_TREE_GUARDIAN: float = 0.3
const WANDER_SPEED_SHADOW_LORD: float = 0.8
const WANDER_SPEED_BONE_DRAGON: float = 0.6
const WANDER_SPEED_HELLHOUND: float = 0.7
const WANDER_SPEED_STONE_GOLEM: float = 0.4
const WANDER_SPEED_SUCCUBUS: float = 0.7
const WANDER_SPEED_GOBLIN_ENGINEER: float = 0.5
const WANDER_SPEED_GOBLIN_WORKER: float = 0.5

## ============================================================================
## 金矿系统常量
## ============================================================================

const GOLD_MINE_MAX_STORAGE: int = 500

## ============================================================================
## 颜色定义 (使用Godot的Color类型)
## ============================================================================

class Colors:
	const BACKGROUND := Color(0.102, 0.102, 0.102) # (26, 26, 26)
	const ROCK := Color(0.267, 0.267, 0.267) # (68, 68, 68)
	const GROUND := Color(0.4, 0.4, 0.4) # (102, 102, 102)
	const GOLD_VEIN := Color(0.722, 0.525, 0.043) # (184, 134, 11)
	const TREASURY := Color(1.0, 0.667, 0.0) # (255, 170, 0)
	const UI_BG := Color(0.0, 0.0, 0.0, 0.784) # (0, 0, 0, 200)
	const UI_BORDER := Color(0.4, 0.4, 0.4) # (102, 102, 102)
	const TEXT := Color(1.0, 1.0, 1.0) # (255, 255, 255)
	const HIGHLIGHT_GREEN := Color(0.0, 1.0, 0.0) # (0, 255, 0)
	const HIGHLIGHT_RED := Color(1.0, 0.0, 0.0) # (255, 0, 0)
	const HIGHLIGHT_GOLD := Color(1.0, 0.843, 0.0) # (255, 215, 0)
	
	## 状态条颜色
	const STATUS_AMMUNITION := Color(1.0, 0.647, 0.0) # 橙色 - 弹药/金币
	const STATUS_GOLD := Color(1.0, 1.0, 0.0) # 黄色
	const STATUS_DEFAULT := Color(1.0, 1.0, 1.0) # 白色

## ============================================================================
## 状态条常量
## ============================================================================

const STATUS_BAR_HEIGHT: int = 2 # 状态条高度（像素）
const STATUS_BAR_OFFSET: int = 4 # 状态条偏移量（像素）
const STATUS_BAR_PADDING: int = 8 # 状态条内边距（像素）

## ============================================================================
## 建筑渲染常量
## ============================================================================

const BUILDING_BORDER_WIDTH: int = 2 # 建筑边框宽度
const BUILDING_PADDING: int = 4 # 建筑内边距
const BUILDING_OFFSET: int = 8 # 建筑偏移量
const BUILDING_FOUNDATION_HEIGHT: int = 3 # 建筑地基高度
const BUILDING_FOUNDATION_OFFSET: int = 2 # 建筑地基偏移量

## 箭塔渲染常量
const ARROW_TOWER_BASE_OFFSET: int = 8
const ARROW_TOWER_ROOF_OFFSET: int = 6
const ARROW_TOWER_SLOT_WIDTH: int = 8
const ARROW_TOWER_SLOT_HEIGHT: int = 4
const ARROW_TOWER_FLAG_HEIGHT: int = 6
const ARROW_TOWER_FLAG_OFFSET: int = 4
const ARROW_TOWER_BRICK_WIDTH: int = 4
const ARROW_TOWER_BRICK_HEIGHT: int = 3
const ARROW_TOWER_BRICK_OFFSET: int = 8

## 地牢之心渲染常量
const DUNGEON_HEART_BORDER_WIDTH: int = 3
const DUNGEON_HEART_BORDER_OFFSET: int = 3
const DUNGEON_HEART_CORNER_SIZE: int = 5
const DUNGEON_HEART_CORNER_OFFSET: int = 2
const DUNGEON_HEART_LINE_WIDTH: int = 2
const DUNGEON_HEART_LINE_OFFSET: int = 10
const DUNGEON_HEART_HEALTH_BAR_OFFSET: int = 12

## 金库渲染常量
const TREASURY_SAFE_WIDTH: int = 16
const TREASURY_SAFE_HEIGHT: int = 12
const TREASURY_DOOR_WIDTH: int = 12
const TREASURY_DOOR_HEIGHT: int = 8
const TREASURY_HANDLE_WIDTH: int = 3
const TREASURY_HANDLE_HEIGHT: int = 2
const TREASURY_CORNER_SIZE: int = 3
const TREASURY_COIN_OFFSET: int = 8
