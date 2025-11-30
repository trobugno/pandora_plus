class_name PPRecipe extends RefCounted

var _ingredients: Array[PPIngredient]
var _result: PandoraReference
var _crafting_time: float
var _recipe_type: String

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

func save_data(fields_settings: Array[Dictionary], ingredient_fields_settings: Array[Dictionary]) -> Dictionary:
	var result := {}
	var result_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Result")[0] as Dictionary
	var recipe_type_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Recipe types")[0] as Dictionary
	var ingredients_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Ingredients")[0] as Dictionary
	var crafting_time_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Crafting Time")[0] as Dictionary
	
	if ingredients_field_settings["enabled"]:
		var ingredients = _ingredients.map(func(ingredient: PPIngredient): return ingredient.save_data(ingredient_fields_settings))
		result["ingredients"] = ingredients
	if result_field_settings["enabled"]:
		result["result"] = _result.save_data()
	if crafting_time_field_settings["enabled"]:
		result["crafting_time"] = _crafting_time
	if recipe_type_field_settings["enabled"]:
		result["recipe_type"] = _recipe_type
	return result

func _to_string() -> String:
	return "<PPRecipe " + str(get_result()) + ">"
