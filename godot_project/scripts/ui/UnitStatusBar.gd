extends Node3D
class_name UnitStatusBar

## 单位头顶状态栏
## 显示血条和携带金币数量
## 使用Sprite3D（Billboard）+ Label3D实现

# 🔧 血条配置
var health_bar_sprite: Sprite3D
var health_bar_material: ShaderMaterial
var health_ratio: float = 1.0

# 🔧 金币文本配置
var gold_label: Label3D
var carried_gold: int = 0
var show_gold: bool = false # 是否显示金币（工程师和苦工显示，其他单位不显示）

# 🔧 状态栏尺寸
const BAR_WIDTH: float = 1.0
const BAR_HEIGHT: float = 0.1
const LABEL_OFFSET_Y: float = 0.2

# 🔧 血条颜色
const COLOR_HEALTH_HIGH: Color = Color(0.2, 0.8, 0.2) # 绿色
const COLOR_HEALTH_MEDIUM: Color = Color(0.9, 0.7, 0.2) # 黄色
const COLOR_HEALTH_LOW: Color = Color(0.9, 0.2, 0.2) # 红色


func _ready():
	"""初始化状态栏"""
	_create_health_bar()
	_create_gold_label()


func _create_health_bar():
	"""创建血条（使用Sprite3D + Shader）"""
	# 创建Sprite3D
	health_bar_sprite = Sprite3D.new()
	health_bar_sprite.name = "HealthBar"
	add_child(health_bar_sprite)
	
	# 🔧 Billboard模式：始终面向摄像机
	health_bar_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	# 设置位置（单位头顶）
	health_bar_sprite.position = Vector3(0, 1.2, 0)
	
	# 🔧 [尺寸调整] pixel_size根据单位size动态计算
	# 默认0.002，但会在set_unit_size()中调整
	health_bar_sprite.pixel_size = 0.002
	
	# 创建血条纹理（简单矩形）
	var bar_texture = _create_bar_texture()
	health_bar_sprite.texture = bar_texture
	
	# 创建着色器材质
	_create_health_shader()


func _create_bar_texture() -> ImageTexture:
	"""创建血条背景纹理（200x20像素的矩形）"""
	var width = 200
	var height = 20
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	
	# 填充颜色
	for y in range(height):
		for x in range(width):
			if x < 2 or x >= width - 2 or y < 2 or y >= height - 2:
				# 边框：深色
				image.set_pixel(x, y, Color(0.1, 0.1, 0.1, 1.0))
			else:
				# 内部：稍亮的背景色
				image.set_pixel(x, y, Color(0.2, 0.2, 0.2, 0.8))
	
	return ImageTexture.create_from_image(image)


func _create_health_shader():
	"""创建血条着色器材质"""
	var shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform sampler2D texture_albedo : source_color;
uniform float health_ratio : hint_range(0.0, 1.0) = 1.0;
uniform vec3 health_color : source_color = vec3(0.2, 0.8, 0.2);

void fragment() {
	vec4 tex_color = texture(texture_albedo, UV);
	
	// 根据UV.x和health_ratio决定是否显示
	float bar_start = 0.01; // 左边框
	float bar_end = 0.99;   // 右边框
	float bar_width = bar_end - bar_start;
	float current_end = bar_start + bar_width * health_ratio;
	
	// 边框部分
	if (UV.x < bar_start || UV.x > bar_end || UV.y < 0.1 || UV.y > 0.9) {
		ALBEDO = tex_color.rgb * 0.5; // 边框颜色
		ALPHA = tex_color.a;
	}
	// 血条部分
	else if (UV.x <= current_end) {
		ALBEDO = health_color;
		ALPHA = 1.0;
	}
	// 背景部分
	else {
		ALBEDO = tex_color.rgb;
		ALPHA = tex_color.a * 0.5;
	}
}
"""
	
	health_bar_material = ShaderMaterial.new()
	health_bar_material.shader = shader
	health_bar_material.set_shader_parameter("health_ratio", 1.0)
	health_bar_material.set_shader_parameter("health_color", COLOR_HEALTH_HIGH)
	
	health_bar_sprite.material_override = health_bar_material


func _create_gold_label():
	"""创建金币数量标签"""
	gold_label = Label3D.new()
	gold_label.name = "GoldLabel"
	add_child(gold_label)
	
	# 🔧 Billboard模式
	gold_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	# 设置位置（血条下方）
	gold_label.position = Vector3(0, 1.0, 0)
	
	# 🔧 [尺寸调整] 文本属性根据单位size动态计算
	# 默认值，会在set_unit_size()中调整
	gold_label.pixel_size = 0.002
	gold_label.font_size = 20
	gold_label.outline_size = 3
	gold_label.outline_modulate = Color.BLACK
	gold_label.modulate = Color(1.0, 0.84, 0.0) # 金色
	
	# 初始隐藏
	gold_label.visible = false


func update_health(current_health: float, max_health: float):
	"""更新血条显示
	
	Args:
		current_health: 当前生命值
		max_health: 最大生命值
	"""
	if not health_bar_material:
		return
	
	health_ratio = clampf(current_health / max_health, 0.0, 1.0)
	health_bar_material.set_shader_parameter("health_ratio", health_ratio)
	
	# 根据血量比例改变颜色
	var health_color: Color
	if health_ratio > 0.6:
		health_color = COLOR_HEALTH_HIGH
	elif health_ratio > 0.3:
		health_color = COLOR_HEALTH_MEDIUM
	else:
		health_color = COLOR_HEALTH_LOW
	
	health_bar_material.set_shader_parameter("health_color", health_color)


func update_gold(amount: int):
	"""更新金币数量显示
	
	Args:
		amount: 携带金币数量
	"""
	carried_gold = amount
	
	if show_gold and amount > 0:
		gold_label.text = "💰 %d" % amount
		gold_label.visible = true
	else:
		gold_label.visible = false


func set_show_gold(enabled: bool):
	"""设置是否显示金币
	
	Args:
		enabled: 是否显示
	"""
	show_gold = enabled
	if not enabled:
		gold_label.visible = false


func update_storage(current: int, maximum: int):
	"""更新存储显示（用于建筑）
	
	Args:
		current: 当前存储数量
		maximum: 最大存储容量
	"""
	if show_gold and current >= 0:
		gold_label.text = "💰 %d/%d" % [current, maximum]
		gold_label.visible = true
	else:
		gold_label.visible = false


func set_storage_text(text: String):
	"""设置存储文本（用于建筑）
	
	Args:
		text: 要显示的文本
	"""
	if show_gold and text != "":
		gold_label.text = "💰 " + text
		gold_label.visible = true
	else:
		gold_label.visible = false


func set_offset_y(offset: float):
	"""设置整体Y轴偏移（适应不同体型的单位）
	
	Args:
		offset: Y轴偏移量
	"""
	if health_bar_sprite:
		health_bar_sprite.position.y = offset + 0.2
	if gold_label:
		gold_label.position.y = offset


func set_unit_size(unit_size: float):
	"""根据单位size设置状态栏尺寸
	
	🔧 [尺寸系统] 状态栏大小与单位体型成比例
	
	Args:
		unit_size: 单位体型大小（如 18）
	"""
	# 🔧 pixel_size缩放：基础值 0.001，根据size调整
	# size=18 -> pixel_size=0.001 * (18/20) = 0.0009
	var scale_factor = unit_size / 20.0 # 标准size=20
	
	if health_bar_sprite:
		health_bar_sprite.pixel_size = 0.001 * scale_factor
	
	if gold_label:
		gold_label.pixel_size = 0.001 * scale_factor
		gold_label.font_size = int(20 * scale_factor)
		gold_label.outline_size = max(2, int(3 * scale_factor))


func hide_bar():
	"""隐藏状态栏"""
	visible = false


func show_bar():
	"""显示状态栏"""
	visible = true
