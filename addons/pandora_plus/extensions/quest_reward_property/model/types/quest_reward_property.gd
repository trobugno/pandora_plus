extends PandoraPropertyType

const SETTING_REWARD_ENTITY_FILTER = "Reward Entity Category Filter"
const SETTING_MIN_QUANTITY = "Min Quantity"
const SETTING_MAX_QUANTITY = "Max Quantity"
const SETTING_MIN_CURRENCY = "Min Currency"
const SETTING_MAX_CURRENCY = "Max Currency"

var SETTINGS = {
	SETTING_REWARD_ENTITY_FILTER: {"type": "reference", "value": ""},
	SETTING_MIN_QUANTITY: {"type": "int", "value": 1},
	SETTING_MAX_QUANTITY: {"type": "int", "value": 999},
	SETTING_MIN_CURRENCY: {"type": "int", "value": 0},
	SETTING_MAX_CURRENCY: {"type": "int", "value": 9999999}
}

func _init() -> void:
	super("quest_reward_property", SETTINGS, null, "res://addons/pandora_plus/assets/icons/icon_chest.png")
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
		if field_settings["name"] == "Min Quantity":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_MIN_QUANTITY)
			else:
				if not SETTINGS.has(SETTING_MIN_QUANTITY):
					SETTINGS[SETTING_MIN_QUANTITY] = {"type": "int", "value": field_settings.get("settings", {}).get("min_value", 1)}
		elif field_settings["name"] == "Max Quantity":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_MAX_QUANTITY)
			else:
				if not SETTINGS.has(SETTING_MAX_QUANTITY):
					SETTINGS[SETTING_MAX_QUANTITY] = {"type": "int", "value": field_settings.get("settings", {}).get("max_value", 999)}
		elif field_settings["name"] == "Reward Entity":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_REWARD_ENTITY_FILTER)
			else:
				if not SETTINGS.has(SETTING_REWARD_ENTITY_FILTER):
					SETTINGS[SETTING_REWARD_ENTITY_FILTER] = {"type": "reference", "value": ""}
	_settings = SETTINGS

func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var reward = PPQuestReward.new()
		reward.load_data(variant)
		return reward
	elif variant is PPQuestReward:
		# Return a deep copy to avoid reference sharing
		return variant.duplicate()
	return variant

func write_value(variant: Variant) -> Variant:
	if variant is PPQuestReward:
		var extension_configuration := PandoraSettings.find_extension_configuration_property(_type_name)
		if extension_configuration:
			var fields_settings := extension_configuration.get("fields", []) as Array
			return variant.save_data(fields_settings)
		else:
			# Fallback if extension not configured
			return variant.save_data([])
	return variant

func is_valid(variant: Variant) -> bool:
	return variant is PPQuestReward
