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
	super("item_drop", SETTINGS, null, "res://addons/pandora_plus/assets/icons/icon_money_bag.png")

func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var reference = PandoraReference.new(variant["item"]["_entity_id"], variant["item"]["_type"])
		var min_quantity = variant["min_quantity"]
		var max_quantity = variant["max_quantity"]
		return PPItemDrop.new(reference, min_quantity, max_quantity)
	return variant

func write_value(variant: Variant) -> Variant:
	if variant is PPItemDrop:
		return variant.save_data()
	return variant

func is_valid(variant: Variant) -> bool:
	return variant is PPItemDrop
