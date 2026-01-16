class_name PPRecipe extends RefCounted

var _ingredients: Array[PPIngredient]
var _result: PandoraReference
var _crafting_time: float
var _recipe_type: String
var _waste: PPIngredient = null

func _init(ingredients: Array[PPIngredient], result: PandoraReference, crafting_time: float, recipe_type: String) -> void:
	_ingredients = ingredients
	_result = result
	_crafting_time = crafting_time
	_recipe_type = recipe_type

func add_ingredient(ingredient: PPIngredient) -> void:
	if ingredient:
		_ingredients.append(ingredient)

func remove_ingredient(ingredient: PPIngredient) -> void:
	_ingredients.erase(ingredient)

func update_ingredient_at(idx: int, ingredient: PPIngredient) -> void:
	if _ingredients.size() < idx + 1:
		_ingredients.append(ingredient)
	else:
		_ingredients[idx] = ingredient

func set_result(entity: PandoraEntity) -> void:
	_result = PandoraReference.new(entity.get_entity_id(), PandoraReference.Type.ENTITY)

func set_crafting_time(crafting_time: float) -> void:
	_crafting_time = crafting_time

func set_recipe_type(recipe_type: String) -> void:
	_recipe_type = recipe_type

func get_ingredients() -> Array[PPIngredient]:
	return _ingredients

func get_result() -> PPItemEntity:
	if _result:
		return _result.get_entity() as PPItemEntity
	else:
		return null

func get_crafting_time() -> float:
	return _crafting_time

func get_recipe_type() -> String:
	return _recipe_type

func set_waste(waste: PPIngredient) -> void:
	_waste = waste

func get_waste() -> PPIngredient:
	return _waste

func load_data(data: Dictionary) -> void:
	if data.has("result"):
		_result = PandoraReference.new(data["result"]["_entity_id"], data["result"]["_type"])
	if data.has("crafting_time"):
		_crafting_time = data["crafting_time"]
	if data.has("recipe_type"):
		_recipe_type = data["recipe_type"]
	if data.has("ingredients"):
		var ingredients : Array[PPIngredient] = []
		for ing in data["ingredients"]:
			var ingredient := PPIngredient.new(PandoraReference.new(ing["item"]["_entity_id"], ing["item"]["_type"]), ing["quantity"])
			ingredients.append(ingredient)
		_ingredients = ingredients
	if data.has("waste") and data["waste"] is Dictionary:
		var waste_data = data["waste"] as Dictionary
		if waste_data.has("item") and waste_data["item"] is Dictionary:
			var item_ref = PandoraReference.new(waste_data["item"]["_entity_id"], waste_data["item"]["_type"])
			_waste = PPIngredient.new(item_ref, waste_data.get("quantity", 1))

func save_data(fields_settings: Array[Dictionary], ingredient_fields_settings: Array[Dictionary]) -> Dictionary:
	var result := {}

	# Safe field lookup
	var result_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Result")
	var recipe_type_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Recipe types")
	var ingredients_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Ingredients")
	var crafting_time_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Crafting Time")

	if ingredients_field_array.size() > 0:
		var ingredients_field_settings := ingredients_field_array[0] as Dictionary
		if ingredients_field_settings["enabled"]:
			var ingredients = _ingredients.map(func(ingredient: PPIngredient): return ingredient.save_data(ingredient_fields_settings))
			result["ingredients"] = ingredients

	if result_field_array.size() > 0:
		var result_field_settings := result_field_array[0] as Dictionary
		if result_field_settings["enabled"] and _result != null:
			result["result"] = _result.save_data()

	if crafting_time_field_array.size() > 0:
		var crafting_time_field_settings := crafting_time_field_array[0] as Dictionary
		if crafting_time_field_settings["enabled"]:
			result["crafting_time"] = _crafting_time

	if recipe_type_field_array.size() > 0:
		var recipe_type_field_settings := recipe_type_field_array[0] as Dictionary
		if recipe_type_field_settings["enabled"]:
			result["recipe_type"] = _recipe_type

	var waste_item_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Waste Item")
	if waste_item_field_array.size() > 0:
		var waste_item_field_settings := waste_item_field_array[0] as Dictionary
		if waste_item_field_settings["enabled"]:
			result["waste"] = null if not _waste else _waste.save_data(ingredient_fields_settings)

	return result

func duplicate() -> PPRecipe:
	var duplicated_ingredients: Array[PPIngredient] = []
	for ingredient in _ingredients:
		duplicated_ingredients.append(ingredient.duplicate())
	var duplicated_result: PandoraReference = null
	if _result != null:
		duplicated_result = PandoraReference.new(_result._entity_id, _result._type)
	var duplicated_recipe = PPRecipe.new(duplicated_ingredients, duplicated_result, _crafting_time, _recipe_type)
	if _waste != null:
		duplicated_recipe.set_waste(_waste.duplicate())
	return duplicated_recipe

func _to_string() -> String:
	return "<PPRecipe " + str(get_result()) + ">"
