extends PandoraPropertyType

const SETTING_CATEGORY_FILTER = "Target Category Filter"
const SETTING_MIN_VALUE = "Min Quantity"
const SETTING_MAX_VALUE = "Max Quantity"
var SETTINGS = {
	SETTING_CATEGORY_FILTER: {"type": "reference", "value": ""},
	SETTING_MIN_VALUE: {"type": "int", "value": -9999999999},
	SETTING_MAX_VALUE: {"type": "int", "value": 9999999999}
}

func _init() -> void:
	super("quest_objective_property", SETTINGS, null, "res://addons/pandora_plus/assets/icons/icon_flag.png")
	Pandora.update_fields_settings.connect(_on_update_fields_settings)
	_update_fields_settings()

func _on_update_fields_settings(type: String) -> void:
	if _type_name == type:
		_update_fields_settings()

func _update_fields_settings() -> void:
	var extension_configuration := PandoraSettings.find_extension_configuration_property(_type_name)
	var fields_settings := extension_configuration["fields"] as Array
	for field_settings in fields_settings:
		if field_settings["name"] == "Min Quantity":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_MIN_VALUE)
			else:
				if !SETTINGS.has(SETTING_MIN_VALUE):
					SETTINGS[SETTING_MIN_VALUE] = {"type": "int", "value": field_settings["settings"]["min_value"]}
		elif field_settings["name"] == "Max Quantity":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_MAX_VALUE)
			else:
				if !SETTINGS.has(SETTING_MAX_VALUE):
					SETTINGS[SETTING_MAX_VALUE] = {"type": "int", "value": field_settings["settings"]["max_value"]}
		elif field_settings["name"] == "Item":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_CATEGORY_FILTER)
			else:
				if !SETTINGS.has(SETTING_CATEGORY_FILTER):
					SETTINGS[SETTING_CATEGORY_FILTER] = {"type": "reference", "value": ""}
	_settings = SETTINGS

func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var objective_id = variant.get("objective_id", "")
		var objective_type = variant.get("objective_type", -1)
		var description = variant.get("description", "")
		var target_reference = null if not variant.has("target_reference") else PandoraReference.new(variant["target_reference"]["_entity_id"], variant["target_reference"]["_type"])
		var target_quantity = variant.get("target_quantity", 1)
		var optional = variant.get("optional", false)
		var hidden = variant.get("hidden", false)
		var sequential = variant.get("sequential", false)
		var order_index = variant.get("order_index", 0)
		var custom_script = variant.get("custom_script", "")
		
		return PPQuestObjective.new(objective_id, objective_type, description, target_reference, target_quantity, \
			optional, custom_script)
	return variant

func write_value(variant: Variant) -> Variant:
	if variant is PPQuestObjective:
		var extension_configuration := PandoraSettings.find_extension_configuration_property(_type_name)
		var fields_settings := extension_configuration["fields"] as Array
		return variant.save_data(fields_settings)
	return variant

func is_valid(variant: Variant) -> bool:
	return variant is PPQuestObjective
