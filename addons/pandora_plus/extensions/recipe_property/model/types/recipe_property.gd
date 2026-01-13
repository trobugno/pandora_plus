extends PandoraPropertyType

const SETTING_RESULT_FILTER = "Result Filter"
const SETTING_INGREDIENTS_FILTER = "Ingredients Filter"
const SETTING_MIN_VALUE = "Min Crafting Time"
const SETTING_MAX_VALUE = "Max Crafting Time"
var SETTINGS = {
	SETTING_RESULT_FILTER: {"type": "reference", "value": ""},
	SETTING_INGREDIENTS_FILTER: {"type": "reference", "value": ""},
	SETTING_MIN_VALUE: {"type": "int", "value": 0},
	SETTING_MAX_VALUE: {"type": "int", "value": 9999999999}
}

func _init() -> void:
	super("recipe_property", SETTINGS, null, "res://addons/pandora_plus/assets/icons/icon_parchment.png")
	Pandora.update_fields_settings.connect(_on_update_fields_settings)
	_update_fields_settings()

func _on_update_fields_settings(type: String) -> void:
	if _type_name == type:
		_update_fields_settings()

func _update_fields_settings() -> void:
	var extension_configuration := PandoraSettings.find_extension_configuration_property(_type_name)
	var fields_settings := extension_configuration["fields"] as Array
	for field_settings in fields_settings:
		if field_settings["name"] == "Crafting Time":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_MAX_VALUE)
				SETTINGS.erase(SETTING_MIN_VALUE)
			else:
				if !SETTINGS.has(SETTING_MAX_VALUE) or !SETTINGS.has(SETTING_MIN_VALUE):
					SETTINGS[SETTING_MAX_VALUE] = {"type": "int", "value": field_settings["settings"]["max_value"]}
					SETTINGS[SETTING_MIN_VALUE] = {"type": "int", "value": field_settings["settings"]["min_value"]}
		elif field_settings["name"] == "Result":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_RESULT_FILTER)
			else:
				if !SETTINGS.has(SETTING_RESULT_FILTER):
					SETTINGS[SETTING_RESULT_FILTER] = {"type": "reference", "value": ""}
		elif field_settings["name"] == "Ingredients":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_INGREDIENTS_FILTER)
			else:
				if !SETTINGS.has(SETTING_INGREDIENTS_FILTER):
					SETTINGS[SETTING_INGREDIENTS_FILTER] = {"type": "reference", "value": ""}
	_settings = SETTINGS

func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var reference = null if not variant.has("result") else PandoraReference.new(variant["result"]["_entity_id"], variant["result"]["_type"])
		var crafting_time = 0 if not variant.has("crafting_time") else variant["crafting_time"]
		var recipe_type =  "" if not variant.has("recipe_type") else variant["recipe_type"]
		var ingredients : Array[PPIngredient] = []
		if variant.has("ingredients"):
			for ing in variant["ingredients"]:
				var entity_id = ing["item"]["_entity_id"]
				var entity_type = ing["item"]["_type"]
				var quantity = ing["quantity"]
				var ingredient := PPIngredient.new(PandoraReference.new(entity_id, entity_type), quantity)
				ingredients.append(ingredient)
		var recipe := PPRecipe.new(ingredients, reference, crafting_time, recipe_type)
		# Parse waste if present
		if variant.has("waste") and variant["waste"] is Dictionary:
			var waste_data = variant["waste"] as Dictionary
			if waste_data.has("item") and waste_data["item"] is Dictionary:
				var waste_ref = PandoraReference.new(waste_data["item"]["_entity_id"], waste_data["item"]["_type"])
				var waste_quantity = waste_data.get("quantity", 1)
				recipe.set_waste(PPIngredient.new(waste_ref, waste_quantity))
		return recipe
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
