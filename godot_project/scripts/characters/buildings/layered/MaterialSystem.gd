extends Node
class_name MaterialSystem

## 🎨 高级材质系统
## 管理PBR材质、动态光照和环境光遮蔽

signal material_created(material_name: String)
signal material_updated(material_name: String)

var material_cache: Dictionary = {}
var shader_cache: Dictionary = {}
var texture_cache: Dictionary = {}

# 材质类型
enum MaterialType {
	STANDARD, # 标准材质
	PBR, # PBR材质
	EMISSIVE, # 发光材质
	TRANSPARENT, # 透明材质
	ANIMATED # 动画材质
}

func _ready():
	"""初始化材质系统"""
	_setup_default_materials()
	_setup_shaders()
	LogManager.info("🎨 [MaterialSystem] 高级材质系统初始化完成")


func _setup_default_materials():
	"""设置默认材质"""
	# 石质材质
	_create_material("stone_default", MaterialType.PBR, {
		"albedo_color": Color(0.6, 0.6, 0.6),
		"roughness": 0.8,
		"metallic": 0.1,
		"texture_scale": Vector2(1.0, 1.0)
	})
	
	# 木质材质
	_create_material("wood_default", MaterialType.PBR, {
		"albedo_color": Color(0.6, 0.4, 0.2),
		"roughness": 0.6,
		"metallic": 0.0,
		"texture_scale": Vector2(2.0, 2.0)
	})
	
	# 金属材质
	_create_material("metal_default", MaterialType.PBR, {
		"albedo_color": Color(0.7, 0.7, 0.8),
		"roughness": 0.2,
		"metallic": 0.9,
		"texture_scale": Vector2(1.5, 1.5)
	})
	
	# 魔法材质
	_create_material("magic_default", MaterialType.EMISSIVE, {
		"albedo_color": Color(0.3, 0.1, 0.8),
		"roughness": 0.1,
		"metallic": 0.0,
		"emission": Color(0.2, 0.1, 0.6),
		"emission_energy": 0.5
	})
	
	# 玻璃材质
	_create_material("glass_default", MaterialType.TRANSPARENT, {
		"albedo_color": Color(0.8, 0.9, 1.0),
		"roughness": 0.0,
		"metallic": 0.0,
		"transparency": 0.3
	})


func _setup_shaders():
	"""设置着色器"""
	# 环境光遮蔽着色器
	var ao_shader = Shader.new()
	ao_shader.code = """
		shader_type canvas_item;
		
		uniform float ao_strength : hint_range(0.0, 1.0) = 0.5;
		uniform sampler2D ao_texture : hint_default_black;
		
		void fragment() {
			vec4 color = texture(TEXTURE, UV);
			float ao = texture(ao_texture, UV).r;
			color.rgb *= mix(1.0, ao, ao_strength);
			COLOR = color;
		}
	"""
	shader_cache["ao_shader"] = ao_shader
	
	# 动画材质着色器
	var animated_shader = Shader.new()
	animated_shader.code = """
		shader_type canvas_item;
		
		uniform float time_scale : hint_range(0.0, 10.0) = 1.0;
		uniform vec4 color1 : source_color = vec4(1.0, 0.0, 0.0, 1.0);
		uniform vec4 color2 : source_color = vec4(0.0, 0.0, 1.0, 1.0);
		
		void fragment() {
			float time = TIME * time_scale;
			float wave = sin(time + UV.x * 10.0) * 0.5 + 0.5;
			vec4 color = mix(color1, color2, wave);
			COLOR = color;
		}
	"""
	shader_cache["animated_shader"] = animated_shader


func _create_material(material_name: String, material_type: MaterialType, properties: Dictionary) -> StandardMaterial3D:
	"""创建材质"""
	var material = StandardMaterial3D.new()
	
	# 设置基础属性
	if properties.has("albedo_color"):
		material.albedo_color = properties.albedo_color
	if properties.has("roughness"):
		material.roughness = properties.roughness
	if properties.has("metallic"):
		material.metallic = properties.metallic
	
	# 根据材质类型设置特殊属性
	match material_type:
		MaterialType.EMISSIVE:
			if properties.has("emission"):
				material.emission = properties.emission
			if properties.has("emission_energy"):
				material.emission_energy = properties.emission_energy
			material.emission_enabled = true
		
		MaterialType.TRANSPARENT:
			if properties.has("transparency"):
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				material.albedo_color.a = 1.0 - properties.transparency
		
		MaterialType.ANIMATED:
			if shader_cache.has("animated_shader"):
				material.shader = shader_cache["animated_shader"]
				# 设置着色器参数
				if properties.has("time_scale"):
					material.set_shader_parameter("time_scale", properties.time_scale)
				if properties.has("color1"):
					material.set_shader_parameter("color1", properties.color1)
				if properties.has("color2"):
					material.set_shader_parameter("color2", properties.color2)
	
	# 设置纹理
	if properties.has("texture_scale"):
		material.uv1_tile = properties.texture_scale
	
	# 缓存材质
	material_cache[material_name] = material
	
	material_created.emit(material_name)
	LogManager.info("🎨 [MaterialSystem] 创建材质: %s" % material_name)
	
	return material


func get_material(material_name: String) -> StandardMaterial3D:
	"""获取材质"""
	return material_cache.get(material_name, null)


func create_custom_material(material_name: String, properties: Dictionary) -> StandardMaterial3D:
	"""创建自定义材质"""
	var material = StandardMaterial3D.new()
	
	# 设置所有属性
	for key in properties:
		match key:
			"albedo_color":
				material.albedo_color = properties[key]
			"roughness":
				material.roughness = properties[key]
			"metallic":
				material.metallic = properties[key]
			"emission":
				material.emission = properties[key]
			"emission_energy":
				material.emission_energy = properties[key]
			"transparency":
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				material.albedo_color.a = 1.0 - properties[key]
			"texture_scale":
				material.uv1_tile = properties[key]
	
	# 缓存材质
	material_cache[material_name] = material
	
	material_created.emit(material_name)
	LogManager.info("🎨 [MaterialSystem] 创建自定义材质: %s" % material_name)
	
	return material


func update_material(material_name: String, updates: Dictionary) -> bool:
	"""更新材质"""
	if not material_name in material_cache:
		LogManager.warning("⚠️ [MaterialSystem] 材质不存在: %s" % material_name)
		return false
	
	var material = material_cache[material_name]
	
	# 更新属性
	for key in updates:
		match key:
			"albedo_color":
				material.albedo_color = updates[key]
			"roughness":
				material.roughness = updates[key]
			"metallic":
				material.metallic = updates[key]
			"emission":
				material.emission = updates[key]
			"emission_energy":
				material.emission_energy = updates[key]
			"transparency":
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				material.albedo_color.a = 1.0 - updates[key]
			"texture_scale":
				material.uv1_tile = updates[key]
	
	material_updated.emit(material_name)
	LogManager.info("🎨 [MaterialSystem] 更新材质: %s" % material_name)
	
	return true


func create_material_variant(base_material_name: String, variant_name: String, modifications: Dictionary) -> StandardMaterial3D:
	"""创建材质变体"""
	var base_material = get_material(base_material_name)
	if not base_material:
		LogManager.warning("⚠️ [MaterialSystem] 基础材质不存在: %s" % base_material_name)
		return null
	
	# 复制基础材质
	var variant = base_material.duplicate()
	
	# 应用修改
	for key in modifications:
		match key:
			"albedo_color":
				variant.albedo_color = modifications[key]
			"roughness":
				variant.roughness = modifications[key]
			"metallic":
				variant.metallic = modifications[key]
			"emission":
				variant.emission = modifications[key]
			"emission_energy":
				variant.emission_energy = modifications[key]
			"transparency":
				variant.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				variant.albedo_color.a = 1.0 - modifications[key]
			"texture_scale":
				variant.uv1_tile = modifications[key]
	
	# 缓存变体
	material_cache[variant_name] = variant
	
	material_created.emit(variant_name)
	LogManager.info("🎨 [MaterialSystem] 创建材质变体: %s" % variant_name)
	
	return variant


func apply_ao_to_material(material: StandardMaterial3D, ao_texture: Texture2D, ao_strength: float = 0.5) -> StandardMaterial3D:
	"""为材质应用环境光遮蔽"""
	if not shader_cache.has("ao_shader"):
		LogManager.warning("⚠️ [MaterialSystem] AO着色器不存在")
		return material
	
	material.shader = shader_cache["ao_shader"]
	material.set_shader_parameter("ao_strength", ao_strength)
	material.set_shader_parameter("ao_texture", ao_texture)
	
	LogManager.info("🎨 [MaterialSystem] 应用环境光遮蔽到材质")
	
	return material


func create_animated_material(material_name: String, color1: Color, color2: Color, time_scale: float = 1.0) -> StandardMaterial3D:
	"""创建动画材质"""
	var material = StandardMaterial3D.new()
	
	if shader_cache.has("animated_shader"):
		material.shader = shader_cache["animated_shader"]
		material.set_shader_parameter("time_scale", time_scale)
		material.set_shader_parameter("color1", color1)
		material.set_shader_parameter("color2", color2)
	
	material_cache[material_name] = material
	
	material_created.emit(material_name)
	LogManager.info("🎨 [MaterialSystem] 创建动画材质: %s" % material_name)
	
	return material


func get_all_materials() -> Dictionary:
	"""获取所有材质"""
	return material_cache


func get_material_count() -> int:
	"""获取材质数量"""
	return material_cache.size()


func delete_material(material_name: String) -> bool:
	"""删除材质"""
	if not material_name in material_cache:
		LogManager.warning("⚠️ [MaterialSystem] 材质不存在: %s" % material_name)
		return false
	
	material_cache.erase(material_name)
	LogManager.info("🗑️ [MaterialSystem] 删除材质: %s" % material_name)
	
	return true
