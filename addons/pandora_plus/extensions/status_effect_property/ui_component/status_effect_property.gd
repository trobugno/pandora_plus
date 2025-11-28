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
	if _property != null:
		status_duration.min_value = _property.get_setting(StatusEffectType.SETTING_MIN_DURATION) as float
		status_duration.max_value = _property.get_setting(StatusEffectType.SETTING_MAX_DURATION) as float
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
	if key == StatusEffectType.SETTING_MIN_DURATION || key == StatusEffectType.SETTING_MAX_DURATION:
		refresh()

func _on_update_fields_settings(property_type: String) -> void:
	if property_type == type:
		refresh()
