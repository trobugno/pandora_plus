@tool
extends PandoraPropertyControl

const ItemDropType = preload("uid://choybfjlf8irq")

@onready var entity_picker: HBoxContainer = $HBoxContainer/EntityPicker
@onready var min_quantity: SpinBox = $HBoxContainer/MinQuantity
@onready var max_quantity: SpinBox = $HBoxContainer/MaxQuantity
var current_property : PPItemDrop = PPItemDrop.new(null, 0, 0)

func _ready() -> void:
	refresh()
	Pandora.update_fields_settings.connect(_on_update_fields_settings)
	
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
	
	min_quantity.focus_entered.connect(func(): focused.emit())
	min_quantity.focus_exited.connect(func(): unfocused.emit())
	min_quantity.value_changed.connect(
		func(value: float):
			current_property.set_min_quantity(int(value))
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))
	
	max_quantity.focus_entered.connect(func(): focused.emit())
	max_quantity.focus_exited.connect(func(): unfocused.emit())
	max_quantity.value_changed.connect(
		func(value: float):
			current_property.set_max_quantity(int(value))
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))

func refresh() -> void:
	if _fields_settings:
		for field_settings in _fields_settings:
			if field_settings["name"] == "Item":
				entity_picker.visible = field_settings["enabled"]
			elif field_settings["name"] == "Min Quantity":
				min_quantity.visible = field_settings["enabled"]
			elif field_settings["name"] == "Max Quantity":
				max_quantity.visible = field_settings["enabled"]
	
	if _property != null:
		if _property.get_setting(ItemDropType.SETTING_CATEGORY_FILTER):
			entity_picker.set_filter(_property.get_setting(ItemDropType.SETTING_CATEGORY_FILTER) as String)
		if _property.get_setting(ItemDropType.SETTING_MIN_VALUE):
			min_quantity.min_value = _property.get_setting(ItemDropType.SETTING_MIN_VALUE) as int
			max_quantity.min_value = _property.get_setting(ItemDropType.SETTING_MIN_VALUE) as int
		if _property.get_setting(ItemDropType.SETTING_MAX_VALUE):
			min_quantity.max_value = _property.get_setting(ItemDropType.SETTING_MAX_VALUE) as int
			max_quantity.max_value = _property.get_setting(ItemDropType.SETTING_MAX_VALUE) as int
		if _property.get_default_value() != null:
			var default_value = _property.get_default_value() as PPItemDrop
			current_property = default_value.duplicate()
			var entity = current_property.get_item_entity()
			min_quantity.value = current_property.get_min_quantity()
			max_quantity.value = current_property.get_max_quantity()

			if entity != null:
				entity_picker.select.call_deferred(entity)

func _setting_changed(key:String) -> void:
	if key == ItemDropType.SETTING_MIN_VALUE || key == ItemDropType.SETTING_MAX_VALUE || key == ItemDropType.SETTING_CATEGORY_FILTER:
		refresh()

func _on_update_fields_settings(property_type: String) -> void:
	if property_type == type:
		refresh()
