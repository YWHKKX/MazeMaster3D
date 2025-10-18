extends Node
class_name BuildingEffectManager

## 🏗️ 建筑特效管理器
## 负责管理3x3x3建筑的特效系统

# 特效系统
var particle_systems: Dictionary = {}
var light_systems: Dictionary = {}
var sound_systems: Dictionary = {}

# LOD系统
var lod_level: int = 2
var lod_enabled: bool = true

# 目标建筑
var target_building: Building3D = null

# 特效配置
var effect_configs: Dictionary = {}


func _init():
	"""初始化建筑特效管理器"""
	name = "EffectManager"


func _ready():
	"""场景准备就绪"""
	_initialize_effect_configs()


func _initialize_effect_configs():
	"""初始化特效配置"""
	# 魔法建筑特效
	effect_configs[BuildingTypes.BuildingType.ARCANE_TOWER] = {
		"particles": ["magic_energy", "sparkles"],
		"lights": ["magic_glow"],
		"sounds": ["magic_hum"]
	}
	
	# 金库特效
	effect_configs[BuildingTypes.BuildingType.TREASURY] = {
		"particles": ["gold_sparkles", "coin_flash"],
		"lights": ["golden_glow"],
		"sounds": ["coin_chime"]
	}
	
	# 箭塔特效
	effect_configs[BuildingTypes.BuildingType.ARROW_TOWER] = {
		"particles": ["arrow_trail"],
		"lights": ["torch_light"],
		"sounds": ["bow_string"]
	}
	
	# 恶魔巢穴特效
	effect_configs[BuildingTypes.BuildingType.DEMON_LAIR] = {
		"particles": ["flames", "dark_energy"],
		"lights": ["fire_glow"],
		"sounds": ["demon_growl"]
	}
	
	# 暗影神殿特效
	effect_configs[BuildingTypes.BuildingType.SHADOW_TEMPLE] = {
		"particles": ["shadow_wisps", "dark_mist"],
		"lights": ["shadow_glow"],
		"sounds": ["dark_whisper"]
	}


func set_target_building(building: Building3D):
	"""设置目标建筑"""
	target_building = building


func play_completion_effect():
	"""播放建造完成特效"""
	if not target_building:
		return
	
	# 根据建筑类型播放不同的完成特效
	match target_building.building_type:
		BuildingTypes.BuildingType.ARCANE_TOWER:
			_play_magic_completion_effect()
		BuildingTypes.BuildingType.TREASURY:
			_play_treasury_completion_effect()
		BuildingTypes.BuildingType.ARROW_TOWER:
			_play_tower_completion_effect()
		BuildingTypes.BuildingType.DEMON_LAIR:
			_play_demon_completion_effect()
		_:
			_play_generic_completion_effect()


func _play_magic_completion_effect():
	"""魔法建筑完成特效"""
	# 创建魔法能量爆发
	_create_particle_effect("magic_burst", Vector3.ZERO, 3.0)
	
	# 创建魔法光环
	_create_light_effect("magic_aura", Vector3.ZERO, Color.PURPLE, 2.0)
	
	# 播放魔法音效
	_play_sound_effect("magic_completion")


func _play_treasury_completion_effect():
	"""金库完成特效"""
	# 创建金币爆发
	_create_particle_effect("gold_burst", Vector3.ZERO, 2.0)
	
	# 创建金色光环
	_create_light_effect("golden_aura", Vector3.ZERO, Color.GOLD, 1.5)
	
	# 播放金币音效
	_play_sound_effect("treasure_found")


func _play_tower_completion_effect():
	"""箭塔完成特效"""
	# 创建箭矢特效
	_create_particle_effect("arrow_celebration", Vector3.ZERO, 2.0)
	
	# 创建火炬光
	_create_light_effect("torch_flame", Vector3(0, 1.5, 0), Color.ORANGE, 1.0)
	
	# 播放建造完成音效
	_play_sound_effect("tower_complete")


func _play_demon_completion_effect():
	"""恶魔巢穴完成特效"""
	# 创建火焰爆发
	_create_particle_effect("fire_burst", Vector3.ZERO, 2.5)
	
	# 创建地狱光
	_create_light_effect("hell_glow", Vector3.ZERO, Color.DARK_RED, 2.0)
	
	# 播放恶魔音效
	_play_sound_effect("demon_summon")


func _play_generic_completion_effect():
	"""通用完成特效"""
	# 创建通用粒子效果
	_create_particle_effect("construction_dust", Vector3.ZERO, 1.5)
	
	# 创建通用光效
	_create_light_effect("completion_glow", Vector3.ZERO, Color.WHITE, 1.0)
	
	# 播放通用音效
	_play_sound_effect("building_complete")


func start_functional_effects():
	"""启动功能特效"""
	if not target_building:
		return
	
	var config = effect_configs.get(target_building.building_type)
	if not config:
		return
	
	# 启动粒子特效
	for particle_name in config.get("particles", []):
		_start_particle_system(particle_name)
	
	# 启动光效
	for light_name in config.get("lights", []):
		_start_light_system(light_name)
	
	# 启动音效
	for sound_name in config.get("sounds", []):
		_start_sound_system(sound_name)


func stop_functional_effects():
	"""停止功能特效"""
	# 停止所有粒子系统
	for particle_system in particle_systems.values():
		if is_instance_valid(particle_system):
			particle_system.emitting = false
	
	# 停止所有光效
	for light_system in light_systems.values():
		if is_instance_valid(light_system):
			light_system.visible = false
	
	# 停止所有音效
	for sound_system in sound_systems.values():
		if is_instance_valid(sound_system):
			sound_system.stop()


func _create_particle_effect(effect_name: String, position: Vector3, duration: float):
	"""创建粒子特效"""
	var gp = GPUParticles3D.new()
	gp.name = effect_name
	gp.position = position
	
	# 配置粒子系统
	_configure_particle_system(gp, effect_name)
	
	add_child(gp)
	
	# 播放特效
	gp.emitting = true
	
	# 自动清理
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(func(): gp.queue_free())
	add_child(timer)
	timer.start()


func _configure_particle_system(gp: GPUParticles3D, effect_name: String):
	"""配置粒子系统"""
	match effect_name:
		"magic_burst":
			_configure_magic_burst_particles(gp)
		"gold_burst":
			_configure_gold_burst_particles(gp)
		"fire_burst":
			_configure_fire_burst_particles(gp)
		"construction_dust":
			_configure_dust_particles(gp)
		_:
			_configure_generic_particles(gp)


func _configure_magic_burst_particles(gp: GPUParticles3D):
	"""配置魔法爆发粒子"""
	gp.amount = 100
	gp.lifetime = 2.0
	gp.emitting = true
	gp.explosiveness = 1.0
	gp.direction = Vector3(0, 1, 0)
	gp.spread = 45.0
	gp.initial_velocity_min = 2.0
	gp.initial_velocity_max = 5.0
	gp.gravity = Vector3(0, -2.0, 0)


func _configure_gold_burst_particles(gp: GPUParticles3D):
	"""配置金币爆发粒子"""
	gp.amount = 50
	gp.lifetime = 3.0
	gp.emitting = true
	gp.explosiveness = 1.0
	gp.direction = Vector3(0, 1, 0)
	gp.spread = 60.0
	gp.initial_velocity_min = 1.0
	gp.initial_velocity_max = 3.0
	gp.gravity = Vector3(0, -1.0, 0)


func _configure_fire_burst_particles(gp: GPUParticles3D):
	"""配置火焰爆发粒子"""
	gp.amount = 200
	gp.lifetime = 1.5
	gp.emitting = true
	gp.explosiveness = 1.0
	gp.direction = Vector3(0, 1, 0)
	gp.spread = 30.0
	gp.initial_velocity_min = 3.0
	gp.initial_velocity_max = 8.0
	gp.gravity = Vector3(0, -5.0, 0)


func _configure_dust_particles(gp: GPUParticles3D):
	"""配置灰尘粒子"""
	gp.amount = 30
	gp.lifetime = 4.0
	gp.emitting = true
	gp.explosiveness = 0.8
	gp.direction = Vector3(0, 1, 0)
	gp.spread = 90.0
	gp.initial_velocity_min = 0.5
	gp.initial_velocity_max = 2.0
	gp.gravity = Vector3(0, -0.5, 0)


func _configure_generic_particles(gp: GPUParticles3D):
	"""配置通用粒子"""
	gp.amount = 20
	gp.lifetime = 2.0
	gp.emitting = true
	gp.explosiveness = 0.5
	gp.direction = Vector3(0, 1, 0)
	gp.spread = 45.0
	gp.initial_velocity_min = 1.0
	gp.initial_velocity_max = 3.0
	gp.gravity = Vector3(0, -1.0, 0)


func _create_light_effect(light_name: String, position: Vector3, color: Color, intensity: float):
	"""创建光效"""
	var light = OmniLight3D.new()
	light.name = light_name
	light.position = position
	light.light_color = color
	light.light_energy = intensity
	light.omni_range = 5.0
	
	add_child(light)
	
	# 添加到光效系统
	light_systems[light_name] = light


func _play_sound_effect(sound_name: String):
	"""播放音效"""
	var audio = AudioStreamPlayer3D.new()
	audio.name = sound_name
	audio.position = Vector3.ZERO
	
	# 加载音效资源（这里使用默认音效）
	var sound_resource = _load_sound_resource(sound_name)
	if sound_resource:
		audio.stream = sound_resource
		audio.play()
		
		# 添加到音效系统
		sound_systems[sound_name] = audio
		
		# 自动清理
		audio.finished.connect(func(): audio.queue_free())


func _load_sound_resource(sound_name: String) -> AudioStream:
	"""加载音效资源"""
	# 这里应该加载实际的音效文件
	# 目前返回null，表示没有音效文件
	return null


func _start_particle_system(particle_name: String):
	"""启动粒子系统"""
	if particle_name in particle_systems:
		var ps = particle_systems[particle_name]
		if is_instance_valid(ps):
			ps.emitting = true
	else:
		# 创建新的粒子系统
		_create_functional_particle_system(particle_name)


func _create_functional_particle_system(particle_name: String):
	"""创建功能粒子系统"""
	var gp = GPUParticles3D.new()
	gp.name = particle_name
	
	# 配置功能粒子
	_configure_functional_particles(gp, particle_name)
	
	add_child(gp)
	particle_systems[particle_name] = gp


func _configure_functional_particles(gp: GPUParticles3D, particle_name: String):
	"""配置功能粒子"""
	match particle_name:
		"magic_energy":
			gp.amount = 20
			gp.lifetime = 3.0
			gp.emitting = true
			gp.direction = Vector3(0, 1, 0)
			gp.spread = 15.0
			gp.initial_velocity_min = 0.5
			gp.initial_velocity_max = 1.5
		"gold_sparkles":
			gp.amount = 10
			gp.lifetime = 2.0
			gp.emitting = true
			gp.direction = Vector3(0, 1, 0)
			gp.spread = 30.0
			gp.initial_velocity_min = 0.3
			gp.initial_velocity_max = 1.0
		"flames":
			gp.amount = 50
			gp.lifetime = 1.0
			gp.emitting = true
			gp.direction = Vector3(0, 1, 0)
			gp.spread = 20.0
			gp.initial_velocity_min = 1.0
			gp.initial_velocity_max = 3.0
		_:
			gp.amount = 5
			gp.lifetime = 2.0
			gp.emitting = true


func _start_light_system(light_name: String):
	"""启动光效系统"""
	if light_name in light_systems:
		var light = light_systems[light_name]
		if is_instance_valid(light):
			light.visible = true
	else:
		# 创建新的光效
		_create_functional_light_system(light_name)


func _create_functional_light_system(light_name: String):
	"""创建功能光效"""
	var light = OmniLight3D.new()
	light.name = light_name
	
	# 配置功能光效
	_configure_functional_light(light, light_name)
	
	add_child(light)
	light_systems[light_name] = light


func _configure_functional_light(light: OmniLight3D, light_name: String):
	"""配置功能光效"""
	match light_name:
		"magic_glow":
			light.light_color = Color.PURPLE
			light.light_energy = 1.0
			light.omni_range = 3.0
		"golden_glow":
			light.light_color = Color.GOLD
			light.light_energy = 0.8
			light.omni_range = 2.5
		"fire_glow":
			light.light_color = Color.ORANGE
			light.light_energy = 1.2
			light.omni_range = 4.0
		"torch_light":
			light.light_color = Color.YELLOW
			light.light_energy = 0.6
			light.omni_range = 2.0
		_:
			light.light_color = Color.WHITE
			light.light_energy = 0.5
			light.omni_range = 2.0


func _start_sound_system(sound_name: String):
	"""启动音效系统"""
	if sound_name in sound_systems:
		var sound = sound_systems[sound_name]
		if is_instance_valid(sound):
			sound.play()
	else:
		# 创建新的音效
		_create_functional_sound_system(sound_name)


func _create_functional_sound_system(sound_name: String):
	"""创建功能音效"""
	var audio = AudioStreamPlayer3D.new()
	audio.name = sound_name
	audio.position = Vector3.ZERO
	
	# 加载音效资源
	var sound_resource = _load_sound_resource(sound_name)
	if sound_resource:
		audio.stream = sound_resource
		audio.autoplay = true
		
		add_child(audio)
		sound_systems[sound_name] = audio


func set_lod_level(level: int):
	"""设置LOD级别"""
	lod_level = level
	
	# 根据LOD级别调整特效
	_update_effects_for_lod()


func _update_effects_for_lod():
	"""根据LOD级别更新特效"""
	match lod_level:
		0: # 最低细节：禁用所有特效
			_disable_all_effects()
		1: # 中等细节：只保留重要特效
			_enable_important_effects()
		2: # 最高细节：启用所有特效
			_enable_all_effects()


func _disable_all_effects():
	"""禁用所有特效"""
	for ps in particle_systems.values():
		if is_instance_valid(ps):
			ps.emitting = false
	
	for light in light_systems.values():
		if is_instance_valid(light):
			light.visible = false


func _enable_important_effects():
	"""启用重要特效"""
	# 只启用光效
	for light in light_systems.values():
		if is_instance_valid(light):
			light.visible = true
	
	# 禁用粒子特效
	for ps in particle_systems.values():
		if is_instance_valid(ps):
			ps.emitting = false


func _enable_all_effects():
	"""启用所有特效"""
	for ps in particle_systems.values():
		if is_instance_valid(ps):
			ps.emitting = true
	
	for light in light_systems.values():
		if is_instance_valid(light):
			light.visible = true


func update(delta: float):
	"""更新特效管理器"""
	# 清理无效的特效
	_cleanup_invalid_effects()


func _cleanup_invalid_effects():
	"""清理无效的特效"""
	# 清理粒子系统
	var invalid_particles = []
	for name in particle_systems.keys():
		if not is_instance_valid(particle_systems[name]):
			invalid_particles.append(name)
	
	for name in invalid_particles:
		particle_systems.erase(name)
	
	# 清理光效
	var invalid_lights = []
	for name in light_systems.keys():
		if not is_instance_valid(light_systems[name]):
			invalid_lights.append(name)
	
	for name in invalid_lights:
		light_systems.erase(name)
	
	# 清理音效
	var invalid_sounds = []
	for name in sound_systems.keys():
		if not is_instance_valid(sound_systems[name]):
			invalid_sounds.append(name)
	
	for name in invalid_sounds:
		sound_systems.erase(name)


func get_effect_info() -> Dictionary:
	"""获取特效信息"""
	return {
		"particle_systems": particle_systems.size(),
		"light_systems": light_systems.size(),
		"sound_systems": sound_systems.size(),
		"lod_level": lod_level,
		"lod_enabled": lod_enabled,
		"has_target_building": target_building != null
	}
