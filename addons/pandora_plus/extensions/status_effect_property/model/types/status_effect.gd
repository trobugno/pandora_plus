extends PandoraPropertyType

const SETTING_MIN_DURATION = "Min Duration"
const SETTING_MAX_DURATION = "Max Duration"
const SETTINGS = {
	SETTING_MIN_DURATION: {"type": "int", "value": -1},
	SETTING_MAX_DURATION: {"type": "int", "value": 3600}
}

func _init() -> void:
	super("status_effect", SETTINGS, null, "res://addons/pandora_plus/assets/icons/icon_particle.png")

func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var status_ID = variant["status_ID"]
		var status_key = variant["status_key"]
		var description = variant["description"]
		var duration = variant["duration"]
		var damage_in_percentage = variant["damage_in_percentage"]
		var damage_per_tick = variant["damage_per_tick"]
		var ticks = variant["ticks"]
		return PPStatusEffect.new(status_ID, status_key, description, \
			duration, damage_in_percentage, damage_per_tick, ticks)
	return variant

func write_value(variant: Variant) -> Variant:
	if variant is PPStatusEffect:
		return variant.save_data()
	return variant

func is_valid(variant: Variant) -> bool:
	return variant is PPStatusEffect
