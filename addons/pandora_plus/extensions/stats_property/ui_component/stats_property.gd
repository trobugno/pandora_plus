@tool
extends PandoraPropertyControl

const StatsType = preload("uid://bvjvnrq0h0dpo")

@onready var health_spin: SpinBox = $VBoxContainer/FirstLine/Health/SpinBox
@onready var mana_spin: SpinBox = $VBoxContainer/FirstLine/Mana/SpinBox
@onready var attack_spin: SpinBox = $VBoxContainer/SecondLine/Attack/SpinBox
@onready var defense_spin: SpinBox = $VBoxContainer/SecondLine/Defense/SpinBox
@onready var crit_rate_spin: SpinBox = $VBoxContainer/ThirdLine/CritRate/SpinBox
@onready var crit_damage_spin: SpinBox = $VBoxContainer/ThirdLine/CritDamage/SpinBox
@onready var att_speed_spin: SpinBox = $VBoxContainer/FourthLine/AttSpeed/SpinBox
@onready var mov_speed_spin: SpinBox = $VBoxContainer/FourthLine/MovSpeed/SpinBox

@onready var health: VBoxContainer = $VBoxContainer/FirstLine/Health
@onready var mana: VBoxContainer = $VBoxContainer/FirstLine/Mana
@onready var attack: VBoxContainer = $VBoxContainer/SecondLine/Attack
@onready var defense: VBoxContainer = $VBoxContainer/SecondLine/Defense
@onready var crit_rate: VBoxContainer = $VBoxContainer/ThirdLine/CritRate
@onready var crit_damage: VBoxContainer = $VBoxContainer/ThirdLine/CritDamage
@onready var att_speed: VBoxContainer = $VBoxContainer/FourthLine/AttSpeed
@onready var mov_speed: VBoxContainer = $VBoxContainer/FourthLine/MovSpeed

var current_property : PPStats = PPStats.new(0, 0, 0, 0, 0, 0, 0, 0)

func _ready() -> void:
	refresh()
	Pandora.update_fields_settings.connect(_on_update_fields_settings)
	
	for child in get_children():
		if child is SpinBox:
			var spin_box = child as SpinBox
			spin_box.focus_entered.connect(func(): focused.emit())
			spin_box.focus_exited.connect(func(): unfocused.emit())
	
	health_spin.value_changed.connect(
		func(value: float):
			current_property._health = int(value)
			_set_property_value())
	
	mana_spin.value_changed.connect(
		func(value: float):
			current_property._mana = int(value)
			_set_property_value())
	
	attack_spin.value_changed.connect(
		func(value: float):
			current_property._attack = int(value)
			_set_property_value())
	
	defense_spin.value_changed.connect(
		func(value: float):
			current_property._defense = int(value)
			_set_property_value())
	
	att_speed_spin.value_changed.connect(
		func(value: float):
			current_property._att_speed = value
			_set_property_value())
	
	crit_rate_spin.value_changed.connect(
		func(value: float):
			current_property._crit_rate = value
			_set_property_value())
	
	crit_damage_spin.value_changed.connect(
		func(value: float):
			current_property._crit_damage = int(value)
			_set_property_value())
	
	mov_speed_spin.value_changed.connect(
		func(value: float):
			current_property._mov_speed = int(value)
			_set_property_value())

func _set_property_value() -> void:
	_property.set_default_value(current_property)
	property_value_changed.emit(current_property)

func refresh() -> void:
	if _fields_settings:
		for field_settings in _fields_settings:
			if field_settings["name"] == "Health":
				health.visible = field_settings["enabled"]
			elif field_settings["name"] == "Mana":
				mana.visible = field_settings["enabled"]
			elif field_settings["name"] == "Attack":
				attack.visible = field_settings["enabled"]
			elif field_settings["name"] == "Defense":
				defense.visible = field_settings["enabled"]
			elif field_settings["name"] == "Crit.Rate":
				crit_rate.visible = field_settings["enabled"]
			elif field_settings["name"] == "Crit.Damage":
				crit_damage.visible = field_settings["enabled"]
			elif field_settings["name"] == "Att.Speed":
				att_speed.visible = field_settings["enabled"]
			elif field_settings["name"] == "Mov.Speed":
				mov_speed.visible = field_settings["enabled"]
	
	if _property != null:
		if _property.get_setting(StatsType.SETTING_HEALTH_MIN_VALUE):
			health_spin.min_value = _property.get_setting(StatsType.SETTING_HEALTH_MIN_VALUE) as float
		if _property.get_setting(StatsType.SETTING_HEALTH_MAX_VALUE):
			health_spin.max_value = _property.get_setting(StatsType.SETTING_HEALTH_MAX_VALUE) as float
		if _property.get_setting(StatsType.SETTING_MANA_MIN_VALUE):
			mana_spin.min_value = _property.get_setting(StatsType.SETTING_MANA_MIN_VALUE) as float
		if _property.get_setting(StatsType.SETTING_MANA_MAX_VALUE):
			mana_spin.max_value = _property.get_setting(StatsType.SETTING_MANA_MAX_VALUE) as float
		if _property.get_setting(StatsType.SETTING_ATTACK_MIN_VALUE):
			attack_spin.min_value = _property.get_setting(StatsType.SETTING_ATTACK_MIN_VALUE) as float
		if _property.get_setting(StatsType.SETTING_ATTACK_MAX_VALUE):
			attack_spin.max_value = _property.get_setting(StatsType.SETTING_ATTACK_MAX_VALUE) as float
		if _property.get_setting(StatsType.SETTING_DEFENSE_MIN_VALUE):
			defense_spin.min_value = _property.get_setting(StatsType.SETTING_DEFENSE_MIN_VALUE) as float
		if _property.get_setting(StatsType.SETTING_DEFENSE_MAX_VALUE):
			defense_spin.max_value = _property.get_setting(StatsType.SETTING_DEFENSE_MAX_VALUE) as float
		if _property.get_setting(StatsType.SETTING_CRIT_RATE_MIN_VALUE):
			crit_rate_spin.min_value = _property.get_setting(StatsType.SETTING_CRIT_RATE_MIN_VALUE) as float
		if _property.get_setting(StatsType.SETTING_CRIT_RATE_MAX_VALUE):
			crit_rate_spin.max_value = _property.get_setting(StatsType.SETTING_CRIT_RATE_MAX_VALUE) as float
		if _property.get_setting(StatsType.SETTING_CRIT_DAMAGE_MIN_VALUE):
			crit_damage_spin.min_value = _property.get_setting(StatsType.SETTING_CRIT_DAMAGE_MIN_VALUE) as float
		if _property.get_setting(StatsType.SETTING_CRIT_DAMAGE_MAX_VALUE):
			crit_damage_spin.max_value = _property.get_setting(StatsType.SETTING_CRIT_DAMAGE_MAX_VALUE) as float
		if _property.get_setting(StatsType.SETTING_ATT_SPEED_MIN_VALUE):
			att_speed_spin.min_value = _property.get_setting(StatsType.SETTING_ATT_SPEED_MIN_VALUE) as float
		if _property.get_setting(StatsType.SETTING_ATT_SPEED_MAX_VALUE):
			att_speed_spin.max_value = _property.get_setting(StatsType.SETTING_ATT_SPEED_MAX_VALUE) as float
		if _property.get_setting(StatsType.SETTING_MOV_SPEED_MIN_VALUE):
			mov_speed_spin.min_value = _property.get_setting(StatsType.SETTING_MOV_SPEED_MIN_VALUE) as float
		if _property.get_setting(StatsType.SETTING_MOV_SPEED_MAX_VALUE):
			mov_speed_spin.max_value = _property.get_setting(StatsType.SETTING_MOV_SPEED_MAX_VALUE) as float
		
		if _property.get_default_value() != null:
			var default_value = _property.get_default_value() as PPStats
			current_property = default_value.duplicate()
			health_spin.value = current_property._health
			mana_spin.value = current_property._mana
			attack_spin.value = current_property._attack
			defense_spin.value = current_property._defense
			att_speed_spin.value = current_property._att_speed
			crit_rate_spin.value = current_property._crit_rate
			crit_damage_spin.value = current_property._crit_damage
			mov_speed_spin.value = current_property._mov_speed

func _setting_changed(key:String) -> void:
	if key == StatsType.SETTING_ATT_SPEED_MAX_VALUE or key == StatsType.SETTING_ATT_SPEED_MIN_VALUE or \
		key == StatsType.SETTING_ATTACK_MIN_VALUE or key == StatsType.SETTING_ATTACK_MAX_VALUE or \
		key == StatsType.SETTING_CRIT_DAMAGE_MAX_VALUE or key == StatsType.SETTING_CRIT_DAMAGE_MIN_VALUE or \
		key == StatsType.SETTING_CRIT_RATE_MIN_VALUE or key == StatsType.SETTING_CRIT_RATE_MAX_VALUE or \
		key == StatsType.SETTING_DEFENSE_MAX_VALUE or StatsType.SETTING_DEFENSE_MIN_VALUE or \
		key == StatsType.SETTING_HEALTH_MAX_VALUE or StatsType.SETTING_HEALTH_MIN_VALUE or \
		key == StatsType.SETTING_MANA_MAX_VALUE or StatsType.SETTING_MANA_MIN_VALUE:
		refresh()

func _on_update_fields_settings(property_type: String) -> void:
	if property_type == type:
		refresh()
