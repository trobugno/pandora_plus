extends PandoraPropertyType

const SETTING_OPTIONS = "Options"

var SETTINGS = {
	SETTING_OPTIONS: {"type": "string", "value": "Option A,Option B,Option C"},
}


func _init() -> void:
	super("option_property", SETTINGS, null, "res://addons/pandora_plus/assets/icons/icon_grid.png")


func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is String:
		return variant
	return ""


func write_value(variant: Variant) -> Variant:
	if variant is String:
		return variant
	return ""


func is_valid(variant: Variant) -> bool:
	return variant is String
