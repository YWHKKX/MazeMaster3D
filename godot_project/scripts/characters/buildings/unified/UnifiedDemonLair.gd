extends UnifiedBuildingSystem
class_name UnifiedDemonLair

## 统一恶魔巢穴建筑
## 使用统一建筑系统管理恶魔巢穴

# 恶魔巢穴专用属性
var summon_cost: int = 20
var summon_cooldown: float = 5.0
var max_demons: int = 10
var current_demons: int = 0
var last_summon_time: float = 0.0

func _init():
	super._init()
	building_type = BuildingTypes.BuildingType.DEMON_LAIR
	building_name = "恶魔巢穴"
	building_description = "召唤小恶魔，每个20金币"
	
	# 建筑属性
	health = 80
	max_health = 80
	armor = 3
	
	# 建筑尺寸和主题
	building_size = Vector2(1, 1)
	building_theme = "demon"
	building_tier = 2
	building_category = "military"
	
	# 设置渲染模式为分层GridMap系统
	render_mode = RenderMode.LAYERED

func _load_building_specific_components():
	"""加载恶魔巢穴专用构件"""
	# 恶魔装饰
	_add_component_to_library("Demon_Horn", BuildingComponents.ID_DEMON_HORN)
	_add_component_to_library("Demon_Core", BuildingComponents.ID_DEMON_CORE)
	_add_component_to_library("Demon_Claw", BuildingComponents.ID_DEMON_CLAW)
	_add_component_to_library("Blood_Pool", BuildingComponents.ID_BLOOD_POOL)
	_add_component_to_library("Blood_Ritual", BuildingComponents.ID_BLOOD_RITUAL)
	_add_component_to_library("Soul_Cage", BuildingComponents.ID_SOUL_CAGE)
	_add_component_to_library("Skull_Pile", BuildingComponents.ID_SKULL_PILE)
	_add_component_to_library("Infernal_Altar", BuildingComponents.ID_INFERNAL_ALTAR)

func _get_building_template() -> Dictionary:
	"""获取恶魔巢穴3x3x3模板"""
	return BuildingTemplateGenerator.generate_demon_lair_template()

func _setup_building_effects():
	"""设置建筑特效"""
	super._setup_building_effects()
	_setup_demon_effects()

func _setup_demon_effects():
	"""设置恶魔效果"""
	# 添加地狱火焰效果
	var fire_particles = GPUParticles3D.new()
	fire_particles.name = "HellFire"
	fire_particles.emitting = true
	add_child(fire_particles)
	
	# 添加召唤音效
	var audio_player = AudioStreamPlayer3D.new()
	audio_player.name = "SummonAudio"
	add_child(audio_player)

func summon_demon():
	"""召唤恶魔"""
	if can_summon():
		LogManager.info("👹 [UnifiedDemonLair] 开始召唤恶魔...")
		_play_summon_animation()
		return true
	return false

func can_summon() -> bool:
	"""检查是否可以召唤"""
	# 检查金币、冷却时间等条件
	return true

func _play_summon_animation():
	"""播放召唤动画"""
	# 实现召唤动画逻辑
	pass
