extends PandoraPropertyType

const SETTING_QUEST_GIVER_FILTER = "Quest Giver Category Filter"
const SETTING_MIN_LEVEL = "Min Level"
const SETTING_MAX_LEVEL = "Max Level"

var SETTINGS = {
	SETTING_QUEST_GIVER_FILTER: {"type": "reference", "value": ""},
	SETTING_MIN_LEVEL: {"type": "int", "value": 1},
	SETTING_MAX_LEVEL: {"type": "int", "value": 100}
}

func _init() -> void:
	super("quest_property", SETTINGS, null, "res://addons/pandora_plus/assets/icons/icon_interrogation.png")
	Pandora.update_fields_settings.connect(_on_update_fields_settings)
	_update_fields_settings()

func _on_update_fields_settings(type: String) -> void:
	if _type_name == type:
		_update_fields_settings()

func _update_fields_settings() -> void:
	var extension_configuration := PandoraSettings.find_extension_configuration_property(_type_name)
	if not extension_configuration:
		return

	var fields_settings := extension_configuration.get("fields", []) as Array
	for field_settings in fields_settings:
		if field_settings["name"] == "Min Level":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_MIN_LEVEL)
			else:
				if not SETTINGS.has(SETTING_MIN_LEVEL):
					SETTINGS[SETTING_MIN_LEVEL] = {"type": "int", "value": field_settings.get("settings", {}).get("min_value", 1)}
		elif field_settings["name"] == "Max Level":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_MAX_LEVEL)
			else:
				if not SETTINGS.has(SETTING_MAX_LEVEL):
					SETTINGS[SETTING_MAX_LEVEL] = {"type": "int", "value": field_settings.get("settings", {}).get("max_value", 100)}
		elif field_settings["name"] == "Quest Giver":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_QUEST_GIVER_FILTER)
			else:
				if not SETTINGS.has(SETTING_QUEST_GIVER_FILTER):
					SETTINGS[SETTING_QUEST_GIVER_FILTER] = {"type": "reference", "value": ""}
	_settings = SETTINGS

func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var quest = PPQuest.new()
		quest.load_data(variant)
		return quest
	return variant

func write_value(variant: Variant) -> Variant:
	if variant is PPQuest:
		var extension_configuration := PandoraSettings.find_extension_configuration_property(_type_name)
		var objective_configuration := PandoraSettings.find_extension_configuration_property("quest_objective_property")
		var reward_configuration := PandoraSettings.find_extension_configuration_property("quest_reward_property")

		if extension_configuration and objective_configuration and reward_configuration:
			var fields_settings := extension_configuration.get("fields", []) as Array
			var objective_fields_settings := objective_configuration.get("fields", []) as Array
			var reward_fields_settings := reward_configuration.get("fields", []) as Array
			return variant.save_data(fields_settings, objective_fields_settings, reward_fields_settings)
		else:
			# Fallback if extensions not configured
			return variant.save_data([], [], [])
	return variant

func is_valid(variant: Variant) -> bool:
	return variant is PPQuest
