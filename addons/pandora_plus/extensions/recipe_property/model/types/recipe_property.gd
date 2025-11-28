extends PandoraPropertyType

const SETTING_CATEGORY_FILTER = "Category Filter"
const SETTINGS = {
	SETTING_CATEGORY_FILTER: {"type": "reference", "value": ""}
}

func _init() -> void:
	super("recipe_property", SETTINGS, null, "res://addons/pandora_plus/assets/icons/icon_parchment.png")

func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var reference = PandoraReference.new(variant["result"]["_entity_id"], variant["result"]["_type"])
		var crafting_time = variant["crafting_time"]
		var recipe_type = variant["recipe_type"]
		var ingredients : Array[PPIngredient] = []
		for ing in variant["ingredients"]:
			var entity_id = ing["item"]["_entity_id"]
			var entity_type = ing["item"]["_type"]
			var quantity = ing["quantity"]
			var ingredient := PPIngredient.new(PandoraReference.new(entity_id, entity_type), quantity)
			ingredients.append(ingredient)
		return PPRecipe.new(ingredients, reference, crafting_time, recipe_type)
	return variant

func write_value(variant: Variant) -> Variant:
	if variant is PPRecipe:
		var extension_configuration := PandoraSettings.find_extension_configuration_property(_type_name)
		var ingredient_configuration := PandoraSettings.find_extension_configuration_property("ingredient_property")
		var fields_settings := extension_configuration["fields"] as Array
		var ingredient_fields_settings := ingredient_configuration["fields"] as Array
		return variant.save_data(fields_settings, ingredient_fields_settings)
	return variant

func is_valid(variant: Variant) -> bool:
	return variant is PPRecipe
