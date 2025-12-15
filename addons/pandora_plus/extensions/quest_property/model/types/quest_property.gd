extends PandoraPropertyType

const SETTING_QUEST_GIVER_FILTER = "Quest Giver Category Filter"

var SETTINGS = {
	SETTING_QUEST_GIVER_FILTER: {"type": "reference", "value": ""}
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
		if field_settings["name"] == "Quest Giver":
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
			var fields_settings : Array[Dictionary]
			var objective_fields_settings : Array[Dictionary]
			var reward_fields_settings : Array[Dictionary]
			fields_settings.assign(extension_configuration.get("fields", []) as Array)
			objective_fields_settings.assign(objective_configuration.get("fields", []) as Array)
			reward_fields_settings.assign(reward_configuration.get("fields", []) as Array)
			return variant.save_data(fields_settings, objective_fields_settings, reward_fields_settings)
		else:
			# Fallback if extensions not configured
			return variant.save_data([], [], [])
	return variant

func is_valid(variant: Variant) -> bool:
	return variant is PPQuest
