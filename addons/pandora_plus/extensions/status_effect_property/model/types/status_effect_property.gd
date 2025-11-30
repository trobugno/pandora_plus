extends PandoraPropertyType

const SETTING_MIN_DURATION = "Min Duration"
const SETTING_MAX_DURATION = "Max Duration"
const SETTING_MIN_TICKS = "Min Ticks"
const SETTING_MAX_TICKS = "Max Ticks"
const SETTING_MIN_DAMAGE_PER_TICKS = "Min Damage per Ticks"
const SETTING_MAX_DAMAGE_PER_TICKS = "Max Damage per Ticks"
var SETTINGS = {
	SETTING_MIN_DURATION: {"type": "int", "value": -1},
	SETTING_MAX_DURATION: {"type": "int", "value": 3600},
	SETTING_MIN_TICKS: {"type": "int", "value": 0},
	SETTING_MAX_TICKS: {"type": "int", "value": 9999999999},
	SETTING_MIN_DAMAGE_PER_TICKS: {"type": "int", "value": 0},
	SETTING_MAX_DAMAGE_PER_TICKS: {"type": "int", "value": 9999999999}
}

func _init() -> void:
	super("status_effect_property", SETTINGS, null, "res://addons/pandora_plus/assets/icons/icon_particle.png")
	Pandora.update_fields_settings.connect(_on_update_fields_settings)
	_update_fields_settings()

func _on_update_fields_settings(type: String) -> void:
	if _type_name == type:
		_update_fields_settings()

func _update_fields_settings() -> void:
	var extension_configuration := PandoraSettings.find_extension_configuration_property(_type_name)
	var fields_settings := extension_configuration["fields"] as Array
	for field_settings in fields_settings:
		if field_settings["name"] == "Status Duration":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_MAX_DURATION)
				SETTINGS.erase(SETTING_MIN_DURATION)
			else:
				if !SETTINGS.has(SETTING_MAX_DURATION) or !SETTINGS.has(SETTING_MIN_DURATION):
					SETTINGS[SETTING_MAX_DURATION] = {"type": "int", "value": field_settings["settings"]["max_value"]}
					SETTINGS[SETTING_MIN_DURATION] = {"type": "int", "value": field_settings["settings"]["min_value"]}
		elif field_settings["name"] == "Ticks":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_MAX_TICKS)
				SETTINGS.erase(SETTING_MIN_TICKS)
			else:
				if !SETTINGS.has(SETTING_MAX_TICKS) or !SETTINGS.has(SETTING_MIN_TICKS):
					SETTINGS[SETTING_MAX_TICKS] = {"type": "int", "value": field_settings["settings"]["max_value"]}
					SETTINGS[SETTING_MIN_TICKS] = {"type": "int", "value": field_settings["settings"]["min_value"]}
		elif field_settings["name"] == "Damage per Tick":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_MAX_DAMAGE_PER_TICKS)
				SETTINGS.erase(SETTING_MIN_DAMAGE_PER_TICKS)
			else:
				if !SETTINGS.has(SETTING_MAX_DAMAGE_PER_TICKS) or !SETTINGS.has(SETTING_MIN_DAMAGE_PER_TICKS):
					SETTINGS[SETTING_MAX_DAMAGE_PER_TICKS] = {"type": "int", "value": field_settings["settings"]["max_value"]}
					SETTINGS[SETTING_MIN_DAMAGE_PER_TICKS] = {"type": "int", "value": field_settings["settings"]["min_value"]}

func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var status_ID = "" if not variant.has("status_ID") else variant["status_ID"]
		var status_key = "" if not variant.has("status_key") else variant["status_key"]
		var description = "" if not variant.has("description") else variant["description"]
		var duration = 0 if not variant.has("duration") else variant["duration"]
		var damage_in_percentage = false if not variant.has("damage_in_percentage") else variant["damage_in_percentage"]
		var damage_per_tick = 0 if not variant.has("damage_per_tick") else variant["damage_per_tick"]
		var ticks = 0 if not variant.has("ticks") else variant["ticks"]
		return PPStatusEffect.new(status_ID, status_key, description, \
			duration, damage_in_percentage, damage_per_tick, ticks)
	return variant

func write_value(variant: Variant) -> Variant:
	if variant is PPStatusEffect:
		var extension_configuration := PandoraSettings.find_extension_configuration_property(_type_name)
		var fields_settings := extension_configuration["fields"] as Array
		return variant.save_data(fields_settings)
	return variant

func is_valid(variant: Variant) -> bool:
	return variant is PPStatusEffect
