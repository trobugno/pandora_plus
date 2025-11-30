@tool
extends PandoraPropertyControl

const StatusEffectType = preload("uid://6bu42fycocwg")

@onready var status_ID: LineEdit = $VBoxContainer/FirstLine/StatusID/LineEdit
@onready var status_key: OptionButton = $VBoxContainer/FirstLine/StatusKey/OptionButton
@onready var status_description: LineEdit = $VBoxContainer/SecondLine/StatusDescription/LineEdit
@onready var status_duration: SpinBox = $VBoxContainer/SecondLine/StatusDuration/SpinBox

@onready var damage_container: VBoxContainer = $VBoxContainer/DamageContainer
@onready var ticks: SpinBox = $VBoxContainer/DamageContainer/MarginContainer/HBoxContainer/Ticks/SpinBox
@onready var damage_per_tick: SpinBox = $VBoxContainer/DamageContainer/MarginContainer/HBoxContainer/DamagePerTick/SpinBox
@onready var damage_in_percentage: CheckButton = $VBoxContainer/DamageContainer/MarginContainer/HBoxContainer/DamageInPercentage

@onready var status_id_container: VBoxContainer = $VBoxContainer/FirstLine/StatusID
@onready var status_key_container: VBoxContainer = $VBoxContainer/FirstLine/StatusKey
@onready var status_description_container: VBoxContainer = $VBoxContainer/SecondLine/StatusDescription
@onready var status_duration_container: VBoxContainer = $VBoxContainer/SecondLine/StatusDuration
@onready var ticks_container: VBoxContainer = $VBoxContainer/DamageContainer/MarginContainer/HBoxContainer/Ticks
@onready var damage_per_tick_container: VBoxContainer = $VBoxContainer/DamageContainer/MarginContainer/HBoxContainer/DamagePerTick

var current_property : PPStatusEffect = PPStatusEffect.new("", 0, "", 0, false, 0, 0)

func _ready() -> void:
	refresh()
	Pandora.update_fields_settings.connect(_on_update_fields_settings)
	
	if _property != null:
		_property.setting_changed.connect(_setting_changed)
		_property.setting_cleared.connect(_setting_changed)
	status_ID.focus_entered.connect(func(): focused.emit())
	status_ID.focus_exited.connect(func(): unfocused.emit())
	status_ID.text_changed.connect(
		func(value: String):
			current_property._status_ID = value
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))
	
	status_key.focus_entered.connect(func(): focused.emit())
	status_key.focus_exited.connect(func(): unfocused.emit())
	status_key.get_popup().id_pressed.connect(
		func(value: int):
			current_property._status_key = value
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))
	
	status_description.focus_entered.connect(func(): focused.emit())
	status_description.focus_exited.connect(func(): unfocused.emit())
	status_description.text_changed.connect(
		func(value: String):
			current_property._description = value
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))
	
	status_duration.focus_entered.connect(func(): focused.emit())
	status_duration.focus_exited.connect(func(): unfocused.emit())
	status_duration.value_changed.connect(
		func(value: float):
			current_property._duration = int(value)
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))
	
	ticks.focus_entered.connect(func(): focused.emit())
	ticks.focus_exited.connect(func(): unfocused.emit())
	ticks.value_changed.connect(
		func(value: float):
			current_property._ticks = int(value)
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))
	
	damage_per_tick.focus_entered.connect(func(): focused.emit())
	damage_per_tick.focus_exited.connect(func(): unfocused.emit())
	damage_per_tick.value_changed.connect(
		func(value: float):
			current_property._damage_per_tick = value
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))
	
	damage_in_percentage.focus_entered.connect(func(): focused.emit())
	damage_in_percentage.focus_exited.connect(func(): unfocused.emit())
	damage_in_percentage.toggled.connect(
		func(value: bool):
			current_property._damage_in_percentage = value
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))

func refresh() -> void:
	if _fields_settings:
		for field_settings in _fields_settings:
			if field_settings["name"] == "Status ID":
				status_id_container.visible = field_settings["enabled"]
			elif field_settings["name"] == "Status Key":
				status_key_container.visible = field_settings["enabled"]
				
				status_key.clear()
				for option_value in field_settings["settings"]["options"]:
					status_key.add_item(option_value)
			elif field_settings["name"] == "Status Description":
				status_description_container.visible = field_settings["enabled"]
			elif field_settings["name"] == "Status Duration":
				status_duration_container.visible = field_settings["enabled"]
			elif field_settings["name"] == "Ticks":
				ticks_container.visible = field_settings["enabled"]
			elif field_settings["name"] == "Damage per Tick":
				damage_per_tick_container.visible = field_settings["enabled"]
				damage_in_percentage.visible = field_settings["enabled"]
	
	if _property != null:
		if _property.get_setting(StatusEffectType.SETTING_MIN_DURATION):
			status_duration.min_value = _property.get_setting(StatusEffectType.SETTING_MIN_DURATION) as float
		if _property.get_setting(StatusEffectType.SETTING_MAX_DURATION):
			status_duration.max_value = _property.get_setting(StatusEffectType.SETTING_MAX_DURATION) as float
		if _property.get_setting(StatusEffectType.SETTING_MIN_DAMAGE_PER_TICKS):
			damage_per_tick.min_value = _property.get_setting(StatusEffectType.SETTING_MIN_DAMAGE_PER_TICKS) as float
		if _property.get_setting(StatusEffectType.SETTING_MAX_DAMAGE_PER_TICKS):
			damage_per_tick.max_value = _property.get_setting(StatusEffectType.SETTING_MAX_DAMAGE_PER_TICKS) as float
		if _property.get_setting(StatusEffectType.SETTING_MIN_TICKS):
			ticks.min_value = _property.get_setting(StatusEffectType.SETTING_MIN_TICKS) as int
		if _property.get_setting(StatusEffectType.SETTING_MAX_TICKS):
			ticks.max_value = _property.get_setting(StatusEffectType.SETTING_MAX_TICKS) as int
		
		if _property.get_default_value() != null:
			current_property = _property.get_default_value() as PPStatusEffect
			status_duration.value = current_property._duration
			status_ID.text = current_property._status_ID
			status_key.select(current_property._status_key) 
			status_description.text = current_property._description
			status_duration.value = current_property._duration
			damage_in_percentage.button_pressed = current_property._damage_in_percentage
			damage_per_tick.value = current_property._damage_per_tick
			ticks.value = current_property._ticks
			status_ID.caret_column = current_property._status_ID.length()
			status_description.caret_column = current_property._description.length()

func _setting_changed(key:String) -> void:
	if key == StatusEffectType.SETTING_MIN_DURATION or key == StatusEffectType.SETTING_MAX_DURATION or \
		key == StatusEffectType.SETTING_MAX_DAMAGE_PER_TICKS or key == StatusEffectType.SETTING_MIN_DAMAGE_PER_TICKS or \
		key == StatusEffectType.SETTING_MAX_TICKS or key == StatusEffectType.SETTING_MIN_TICKS:
		refresh()

func _on_update_fields_settings(property_type: String) -> void:
	if property_type == type:
		refresh()
