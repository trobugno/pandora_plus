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
	if _property != null:
		if _property.get_default_value() != null:
			current_property = _property.get_default_value() as PPStats
			health_spin.value = current_property._health
			mana_spin.value = current_property._mana
			attack_spin.value = current_property._attack
			defense_spin.value = current_property._defense
			att_speed_spin.value = current_property._att_speed
			crit_rate_spin.value = current_property._crit_rate
			crit_damage_spin.value = current_property._crit_damage
			mov_speed_spin.value = current_property._mov_speed

func _setting_changed(key:String) -> void:
	refresh()

func _on_update_fields_settings(property_type: String) -> void:
	if property_type == type:
		refresh()
