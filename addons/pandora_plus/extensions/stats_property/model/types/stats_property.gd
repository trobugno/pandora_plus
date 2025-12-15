extends PandoraPropertyType

const SETTING_HEALTH_MIN_VALUE = "Min Health"
const SETTING_HEALTH_MAX_VALUE = "Max Health"
const SETTING_MANA_MIN_VALUE = "Min Mana"
const SETTING_MANA_MAX_VALUE = "Max Mana"
const SETTING_ATTACK_MIN_VALUE = "Min Attack"
const SETTING_ATTACK_MAX_VALUE = "Max Attack"
const SETTING_DEFENSE_MIN_VALUE = "Min Defense"
const SETTING_DEFENSE_MAX_VALUE = "Max Defense"
const SETTING_CRIT_RATE_MIN_VALUE = "Min Crit. Rate"
const SETTING_CRIT_RATE_MAX_VALUE = "Max Crit. Rate"
const SETTING_CRIT_DAMAGE_MIN_VALUE = "Min Crit. Damage"
const SETTING_CRIT_DAMAGE_MAX_VALUE = "Max Crit. Damage"
const SETTING_ATT_SPEED_MIN_VALUE = "Min Att. Speed"
const SETTING_ATT_SPEED_MAX_VALUE = "Max Att. Speed"
const SETTING_MOV_SPEED_MIN_VALUE = "Min Mov. Speed"
const SETTING_MOV_SPEED_MAX_VALUE = "Max Mov. Speed"
var SETTINGS = {
	SETTING_HEALTH_MIN_VALUE: {"type": "int", "value": 0},
	SETTING_HEALTH_MAX_VALUE: {"type": "int", "value": 9999999999},
	SETTING_MANA_MIN_VALUE: {"type": "int", "value": 0},
	SETTING_MANA_MAX_VALUE: {"type": "int", "value": 9999999999},
	SETTING_ATTACK_MIN_VALUE: {"type": "int", "value": 0},
	SETTING_ATTACK_MAX_VALUE: {"type": "int", "value": 9999999999},
	SETTING_DEFENSE_MIN_VALUE: {"type": "int", "value": 0},
	SETTING_DEFENSE_MAX_VALUE: {"type": "int", "value": 9999999999},
	SETTING_CRIT_RATE_MIN_VALUE: {"type": "int", "value": 0},
	SETTING_CRIT_RATE_MAX_VALUE: {"type": "int", "value": 9999999999},
	SETTING_CRIT_DAMAGE_MIN_VALUE: {"type": "int", "value": 0},
	SETTING_CRIT_DAMAGE_MAX_VALUE: {"type": "int", "value": 9999999999},
	SETTING_ATT_SPEED_MIN_VALUE: {"type": "int", "value": 0},
	SETTING_ATT_SPEED_MAX_VALUE: {"type": "int", "value": 9999999999},
	SETTING_MOV_SPEED_MIN_VALUE: {"type": "int", "value": 0},
	SETTING_MOV_SPEED_MAX_VALUE: {"type": "int", "value": 9999999999}
}

func _init() -> void:
	super("stats_property", SETTINGS, null, "res://addons/pandora_plus/assets/icons/icon_star.png")
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
		if field_settings["name"] == "Health":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_HEALTH_MAX_VALUE)
				SETTINGS.erase(SETTING_HEALTH_MIN_VALUE)
			else:
				if !SETTINGS.has(SETTING_HEALTH_MAX_VALUE) or !SETTINGS.has(SETTING_HEALTH_MIN_VALUE):
					SETTINGS[SETTING_HEALTH_MAX_VALUE] = {"type": "int", "value": field_settings["settings"]["max_value"]}
					SETTINGS[SETTING_HEALTH_MIN_VALUE] = {"type": "int", "value": field_settings["settings"]["min_value"]}
		elif field_settings["name"] == "Mana":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_MANA_MAX_VALUE)
				SETTINGS.erase(SETTING_MANA_MIN_VALUE)
			else:
				if !SETTINGS.has(SETTING_MANA_MAX_VALUE) or !SETTINGS.has(SETTING_MANA_MIN_VALUE):
					SETTINGS[SETTING_MANA_MAX_VALUE] = {"type": "int", "value": field_settings["settings"]["max_value"]}
					SETTINGS[SETTING_MANA_MIN_VALUE] = {"type": "int", "value": field_settings["settings"]["min_value"]}
		elif field_settings["name"] == "Attack":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_ATTACK_MAX_VALUE)
				SETTINGS.erase(SETTING_ATTACK_MIN_VALUE)
			else:
				if !SETTINGS.has(SETTING_ATTACK_MAX_VALUE) or !SETTINGS.has(SETTING_ATTACK_MIN_VALUE):
					SETTINGS[SETTING_ATTACK_MAX_VALUE] = {"type": "int", "value": field_settings["settings"]["max_value"]}
					SETTINGS[SETTING_ATTACK_MIN_VALUE] = {"type": "int", "value": field_settings["settings"]["min_value"]}
		elif field_settings["name"] == "Defense":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_DEFENSE_MAX_VALUE)
				SETTINGS.erase(SETTING_DEFENSE_MIN_VALUE)
			else:
				if !SETTINGS.has(SETTING_DEFENSE_MAX_VALUE) or !SETTINGS.has(SETTING_DEFENSE_MIN_VALUE):
					SETTINGS[SETTING_DEFENSE_MAX_VALUE] = {"type": "int", "value": field_settings["settings"]["max_value"]}
					SETTINGS[SETTING_DEFENSE_MIN_VALUE] = {"type": "int", "value": field_settings["settings"]["min_value"]}
		elif field_settings["name"] == "Crit.Rate":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_CRIT_RATE_MAX_VALUE)
				SETTINGS.erase(SETTING_CRIT_RATE_MIN_VALUE)
			else:
				if !SETTINGS.has(SETTING_CRIT_RATE_MAX_VALUE) or !SETTINGS.has(SETTING_CRIT_RATE_MIN_VALUE):
					SETTINGS[SETTING_CRIT_RATE_MAX_VALUE] = {"type": "int", "value": field_settings["settings"]["max_value"]}
					SETTINGS[SETTING_CRIT_RATE_MIN_VALUE] = {"type": "int", "value": field_settings["settings"]["min_value"]}
		elif field_settings["name"] == "Crit.Damage":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_CRIT_DAMAGE_MAX_VALUE)
				SETTINGS.erase(SETTING_CRIT_DAMAGE_MIN_VALUE)
			else:
				if !SETTINGS.has(SETTING_CRIT_DAMAGE_MAX_VALUE) or !SETTINGS.has(SETTING_CRIT_DAMAGE_MIN_VALUE):
					SETTINGS[SETTING_CRIT_DAMAGE_MAX_VALUE] = {"type": "int", "value": field_settings["settings"]["max_value"]}
					SETTINGS[SETTING_CRIT_DAMAGE_MIN_VALUE] = {"type": "int", "value": field_settings["settings"]["min_value"]}
		elif field_settings["name"] == "Att.Speed":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_ATT_SPEED_MAX_VALUE)
				SETTINGS.erase(SETTING_ATT_SPEED_MIN_VALUE)
			else:
				if !SETTINGS.has(SETTING_ATT_SPEED_MAX_VALUE) or !SETTINGS.has(SETTING_ATT_SPEED_MIN_VALUE):
					SETTINGS[SETTING_ATT_SPEED_MAX_VALUE] = {"type": "int", "value": field_settings["settings"]["max_value"]}
					SETTINGS[SETTING_ATT_SPEED_MIN_VALUE] = {"type": "int", "value": field_settings["settings"]["min_value"]}
		elif field_settings["name"] == "Mov.Speed":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_MOV_SPEED_MAX_VALUE)
				SETTINGS.erase(SETTING_MOV_SPEED_MIN_VALUE)
			else:
				if !SETTINGS.has(SETTING_MOV_SPEED_MAX_VALUE) or !SETTINGS.has(SETTING_MOV_SPEED_MIN_VALUE):
					SETTINGS[SETTING_MOV_SPEED_MAX_VALUE] = {"type": "int", "value": field_settings["settings"]["max_value"]}
					SETTINGS[SETTING_MOV_SPEED_MIN_VALUE] = {"type": "int", "value": field_settings["settings"]["min_value"]}

func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var health = 0 if not variant.has("health") else variant["health"]
		var mana = 0 if not variant.has("mana") else variant["mana"]
		var defense = 0 if not variant.has("defense") else variant["defense"]
		var attack = 0 if not variant.has("attack") else variant["attack"]
		var att_speed = 0 if not variant.has("att_speed") else variant["att_speed"]
		var crit_rate = 0 if not variant.has("crit_rate") else variant["crit_rate"]
		var crit_damage = 0 if not variant.has("crit_damage") else variant["crit_damage"]
		var mov_speed = 0 if not variant.has("mov_speed") else variant["mov_speed"]
		return PPStats.new(health, mana, defense, attack, att_speed, crit_rate, crit_damage, mov_speed)
	return variant

func write_value(variant: Variant) -> Variant:
	if variant is PPStats:
		var extension_configuration := PandoraSettings.find_extension_configuration_property(_type_name)
		var fields_settings : Array[Dictionary]
		fields_settings.assign(extension_configuration["fields"] as Array)
		return variant.save_data(fields_settings)
	return variant

func is_valid(variant: Variant) -> bool:
	return variant is PPStats
