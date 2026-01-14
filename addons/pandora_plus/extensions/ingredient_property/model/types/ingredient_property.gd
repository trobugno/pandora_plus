extends PandoraPropertyType

const SETTING_CATEGORY_FILTER = "Category Filter"
const SETTING_MIN_VALUE = "Min Quantity"
const SETTING_MAX_VALUE = "Max Quantity"
var SETTINGS = {
	SETTING_CATEGORY_FILTER: {"type": "reference", "value": ""},
	SETTING_MIN_VALUE: {"type": "int", "value": -9999999999},
	SETTING_MAX_VALUE: {"type": "int", "value": 9999999999}
}

func _init() -> void:
	super("ingredient_property", SETTINGS, null, "res://addons/pandora_plus/assets/icons/icon_crate.png")
	Pandora.update_fields_settings.connect(_on_update_fields_settings)
	_update_fields_settings()

func _on_update_fields_settings(type: String) -> void:
	if _type_name == type:
		_update_fields_settings()

func _update_fields_settings() -> void:
	var extension_configuration := PandoraSettings.find_extension_configuration_property(_type_name)
	var fields_settings : Array[Dictionary]
	fields_settings.assign(extension_configuration["fields"] as Array)
	for field_settings in fields_settings:
		if field_settings["name"] == "Quantity":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_MAX_VALUE)
				SETTINGS.erase(SETTING_MIN_VALUE)
			else:
				if !SETTINGS.has(SETTING_MAX_VALUE) or !SETTINGS.has(SETTING_MIN_VALUE):
					SETTINGS[SETTING_MAX_VALUE] = {"type": "int", "value": field_settings["settings"]["max_value"]}
					SETTINGS[SETTING_MIN_VALUE] = {"type": "int", "value": field_settings["settings"]["min_value"]}
		elif field_settings["name"] == "Item":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_CATEGORY_FILTER)
			else:
				if !SETTINGS.has(SETTING_CATEGORY_FILTER):
					SETTINGS[SETTING_CATEGORY_FILTER] = {"type": "reference", "value": ""}
	_settings = SETTINGS

func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var reference = null if not variant.has("item") else PandoraReference.new(variant["item"]["_entity_id"], variant["item"]["_type"])
		var quantity = 0 if not variant.has("quantity") else variant["quantity"]
		return PPIngredient.new(reference, quantity)
	return variant

func write_value(variant: Variant) -> Variant:
	if variant is PPIngredient:
		var extension_configuration := PandoraSettings.find_extension_configuration_property(_type_name)
		var fields_settings : Array[Dictionary]
		fields_settings.assign(extension_configuration["fields"] as Array)
		return variant.save_data(fields_settings)
	return variant

func is_valid(variant: Variant) -> bool:
	return variant is PPIngredient
