extends UnifiedBuildingSystem
class_name UnifiedOrcLair

## 统一兽人巢穴建筑
## 使用统一建筑系统管理兽人巢穴

# 兽人巢穴专用属性
var orc_capacity: int = 8
var training_bonus: float = 1.3
var combat_boost: float = 1.2
var rage_generation: float = 2.0

func _init():
	super._init()
	building_type = BuildingTypes.BuildingType.ORC_LAIR
	building_name = "兽人巢穴"
	building_description = "兽人居住和训练的地方"
	
	# 建筑属性
	health = 100
	max_health = 100
	armor = 5
	cost_gold = 400
	
	# 兽人巢穴属性
	orc_capacity = 8
	training_bonus = 1.3
	combat_boost = 1.2
	rage_generation = 2.0

func _load_building_specific_components():
	"""加载兽人巢穴专用构件"""
	# 兽人构件
	_add_component_to_library("Orc_Banner", BuildingComponents.ID_ORC_BANNER)
	_add_component_to_library("War_Drum", BuildingComponents.ID_WAR_DRUM)
	_add_component_to_library("Training_Ground", BuildingComponents.ID_TRAINING_GROUND)
	_add_component_to_library("Weapon_Rack", BuildingComponents.ID_WEAPON_RACK)
	_add_component_to_library("Battle_Standard", BuildingComponents.ID_BATTLE_STANDARD)
	_add_component_to_library("War_Horn", BuildingComponents.ID_WAR_HORN)

func _get_building_template() -> Dictionary:
	"""获取兽人巢穴3x3x3模板"""
	return BuildingTemplateGenerator.generate_orc_lair_template()

func _setup_building_effects():
	"""设置建筑特效"""
	super._setup_building_effects()
	_setup_orc_lair_effects()

func _setup_orc_lair_effects():
	"""设置兽人巢穴效果"""
	# 添加战鼓音效
	var audio_player = AudioStreamPlayer3D.new()
	audio_player.name = "WarDrumAudio"
	add_child(audio_player)
	
	# 添加战斗粒子效果
	var particles = GPUParticles3D.new()
	particles.name = "BattleParticles"
	particles.emitting = true
	add_child(particles)

func train_orc(orc_character):
	"""训练兽人"""
	if orc_character and can_train():
		LogManager.info("⚔️ [UnifiedOrcLair] 训练兽人: %s" % orc_character.name)
		_apply_training_bonus(orc_character)
		return true
	return false

func can_train() -> bool:
	"""检查是否可以训练"""
	# 检查容量等条件
	return true

func _apply_training_bonus(character):
	"""应用训练加成"""
	if character.has_method("apply_combat_boost"):
		character.apply_combat_boost(combat_boost)
