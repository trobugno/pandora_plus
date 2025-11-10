@tool
extends PandoraPropertyControl

const IngredientType = preload("uid://beng2jsfcas7d")

@onready var entity_picker: HBoxContainer = $HBoxContainer/EntityPicker
@onready var spin_box: SpinBox = $HBoxContainer/SpinBox
var current_property : PPIngredient = PPIngredient.new(null, 0)

func _ready() -> void:
	refresh()
	
	if _property != null:
		_property.setting_changed.connect(_setting_changed)
		_property.setting_cleared.connect(_setting_changed)
	entity_picker.focus_exited.connect(func(): unfocused.emit())
	entity_picker.focus_entered.connect(func(): focused.emit())
	entity_picker.entity_selected.connect(
		func(entity: PandoraEntity):
			current_property.set_entity(entity)
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))
	
	spin_box.focus_entered.connect(func(): focused.emit())
	spin_box.focus_exited.connect(func(): unfocused.emit())
	spin_box.value_changed.connect(
		func(value: float):
			current_property.set_quantity(int(value))
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))

func refresh() -> void:
	if _property != null:
		entity_picker.set_filter(_property.get_setting(IngredientType.SETTING_CATEGORY_FILTER) as String)
		spin_box.min_value = _property.get_setting(IngredientType.SETTING_MIN_VALUE) as int
		spin_box.max_value = _property.get_setting(IngredientType.SETTING_MAX_VALUE) as int
		if _property.get_default_value() != null:
			current_property = _property.get_default_value() as PPIngredient
			var entity = current_property.get_item_entity()
			
			if entity != null:
				entity_picker.select.call_deferred(entity)
				spin_box.value = current_property.get_quantity()

func _setting_changed(key:String) -> void:
	if key == IngredientType.SETTING_MIN_VALUE || key == IngredientType.SETTING_MAX_VALUE || key == IngredientType.SETTING_CATEGORY_FILTER:
		refresh()
