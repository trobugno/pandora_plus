extends PandoraPropertyType

const SETTING_CATEGORY_FILTER = "Category Filter"
const SETTING_MIN_VALUE = "Min Quantity"
const SETTING_MAX_VALUE = "Max Quantity"
const SETTINGS = {
	SETTING_CATEGORY_FILTER: {"type": "reference", "value": ""},
	SETTING_MIN_VALUE: {"type": "int", "value": -9999999999},
	SETTING_MAX_VALUE: {"type": "int", "value": 9999999999}
}

func _init() -> void:
	super("ingredient", SETTINGS, null, "res://addons/pandora_plus/assets/icons/icon_crate.png")

func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var reference = PandoraReference.new(variant["item"]["_entity_id"], variant["item"]["_type"])
		var quantity = variant["quantity"]
		return PPIngredient.new(reference, quantity)
	return variant

func write_value(variant: Variant) -> Variant:
	if variant is PPIngredient:
		return variant.save_data()
	return variant

func is_valid(variant: Variant) -> bool:
	return variant is PPIngredient
