extends Node
class_name UIDesignConstants

# UI设计常量 - 统一的设计系统
# 参考UI_BEAUTIFICATION.md


# 颜色系统
class Colors:
	# 主色调
	const PRIMARY = Color(0.23, 0.51, 0.96) # 蓝色主题 (59, 130, 246)
	const PRIMARY_DARK = Color(0.18, 0.41, 0.77) # 深蓝色
	const PRIMARY_LIGHT = Color(0.35, 0.65, 1.0) # 浅蓝色

	# 背景色
	const BACKGROUND = Color(0.11, 0.11, 0.11) # 深色背景 (28, 28, 28)
	const SURFACE = Color(0.14, 0.14, 0.14) # 表面色(35, 35, 35)
	const CARD = Color(0.16, 0.16, 0.16) # 卡片背景 (40, 40, 40)
	const PANEL = Color(0.12, 0.12, 0.12) # 面板背景 (30, 30, 30)

	# 文字颜色
	const TEXT_PRIMARY = Color(0.95, 0.95, 0.95) # 主要文字 (242, 242, 242)
	const TEXT_SECONDARY = Color(0.7, 0.7, 0.7) # 次要文字 (179, 179, 179)
	const TEXT_MUTED = Color(0.5, 0.5, 0.5) # 静音文字 (128, 128, 128)

	# 功能色
	const SUCCESS = Color(0.13, 0.77, 0.37) # 成功绿色 (34, 197, 94)
	const WARNING = Color(0.96, 0.62, 0.04) # 警告黄色 (245, 158, 11)
	const ERROR = Color(0.94, 0.27, 0.27) # 错误红色 (239, 68, 68)
	const INFO = Color(0.23, 0.51, 0.96) # 信息蓝色 (59, 130, 246)

	# 交互色
	const HOVER = Color(0.2, 0.2, 0.2) # 悬停色
	const SELECTED = Color(0.23, 0.51, 0.96) # 选中色
	const DISABLED = Color(0.3, 0.3, 0.3) # 禁用色

	# 边框色
	const BORDER = Color(0.25, 0.25, 0.25) # 边框色
	const BORDER_LIGHT = Color(0.35, 0.35, 0.35) # 浅边框色
	const BORDER_DARK = Color(0.15, 0.15, 0.15) # 深边框色


# 字体大小层级
class FontSizes:
	const H1 = 48 # 主标题
	const H2 = 36 # 副标题
	const H3 = 28 # 三级标题
	const H4 = 24 # 四级标题
	const LARGE = 20 # 大文字
	const NORMAL = 16 # 正常文字
	const SMALL = 14 # 小文字
	const TINY = 12 # 极小文字


# 间距系统
class Spacing:
	const XS = 4 # 极小间距
	const SM = 8 # 小间距
	const MD = 12 # 中等间距
	const LG = 16 # 大间距
	const XL = 20 # 极大间距
	const XXL = 24 # 超大间距
	const XXXL = 32 # 超超大间距


# 圆角半径
class BorderRadius:
	const SMALL = 4 # 小圆角
	const MEDIUM = 8 # 中等圆角
	const LARGE = 12 # 大圆角
	const XLARGE = 16 # 超大圆角


# UI组件尺寸
class ComponentSizes:
	const BUTTON_HEIGHT = 40
	const INPUT_HEIGHT = 36
	const CARD_MIN_HEIGHT = 60
	const PANEL_MIN_WIDTH = 200
	const ICON_SIZE = 24
	const AVATAR_SIZE = 48


# 阴影配置
class Shadows:
	const SMALL = Vector2(0, 2)
	const MEDIUM = Vector2(0, 4)
	const LARGE = Vector2(0, 8)
	const COLOR = Color(0.0, 0.0, 0.0, 0.3)


# 动画配置
class Animations:
	const FAST = 0.15 # 快速动画
	const NORMAL = 0.25 # 正常动画
	const SLOW = 0.35 # 慢速动画
	const EASE_OUT = 0.25 # 缓出动画


# 透明度
class Alpha:
	const DISABLED = 0.5
	const HOVER = 0.8
	const OVERLAY = 0.9
	const TRANSPARENT = 0.0
	const OPAQUE = 1.0
