@tool
class_name PPRecipeEntity extends PandoraEntity

func get_description() -> String:
	return get_string("description")

func get_recipe_property() -> PPRecipe:
	return get_entity_property("recipe_property").get_default_value() as PPRecipe

func get_waste() -> PPIngredient:
	var recipe_property := get_recipe_property()
	if recipe_property.get_waste():
		return recipe_property.get_waste() as PPIngredient
	return null

func get_recipe() -> Array[PPInventorySlot]:
	var item_recipes : Array[PPInventorySlot] = []
	var recipe_property := get_recipe_property()
	for ingredient in recipe_property.get_ingredients():
		var slot_resource := PPInventorySlot.new()
		slot_resource.item = ingredient.get_item_entity()
		slot_resource.quantity = ingredient.get_quantity()
		item_recipes.append(slot_resource)
	return item_recipes
