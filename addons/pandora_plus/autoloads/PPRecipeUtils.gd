extends Node

signal crafting_attempted(recipe_id: String, success: bool)

func can_craft(inventory: PPInventory, recipe: PPRecipe) -> bool:
	var ingredients_found : int = 0
	for ing in recipe.get_ingredients():
		for slot in inventory.all_items:
			var item = slot.item
			var quantity = slot.quantity
			if ing.get_item_entity().get_item_name() == item.get_item_name() and quantity >= ing.get_quantity():
				ingredients_found += 1
	return ingredients_found == recipe.get_ingredients().size()

func craft_recipe(inventory: PPInventory, recipe: PPRecipe) -> bool:
	if not can_craft(inventory, recipe):
		crafting_attempted.emit(recipe.get_result().get_item_name() if recipe.has("recipe_name") else "", false)
		return false
	
	for ingredient in recipe.get_ingredients():
		inventory.remove_item(ingredient.get_item_entity(), ingredient.quantity)
	
	inventory.add_item(recipe.get_result())
	crafting_attempted.emit(recipe.get_result().get_item_name() if recipe.has("recipe_name") else "", true)
	return true
