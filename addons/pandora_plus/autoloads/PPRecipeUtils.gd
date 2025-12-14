extends Node

signal crafting_attempted(recipe_id: String, success: bool)

func can_craft(inventory: PPInventory, recipe: PPRecipe) -> bool:
	var ingredients_found : int = 0
	for ingredient in recipe.get_ingredients():
		for slot in inventory.all_items:
			var item = slot.item
			var quantity = slot.quantity
			var instance = ingredient.get_item_entity() as PPItemEntity
			if instance.get_entity_id() == item.get_entity_id() and quantity >= ingredient.get_quantity():
				ingredients_found += 1
	return ingredients_found == recipe.get_ingredients().size()

func craft_recipe(inventory: PPInventory, recipe: PPRecipe) -> bool:
	if not can_craft(inventory, recipe):
		crafting_attempted.emit(recipe.get_result().get_item_name(), false)
		return false
	
	for ingredient in recipe.get_ingredients():
		inventory.remove_item(ingredient.get_item_entity(), ingredient.get_quantity())
	
	inventory.add_item(recipe.get_result())
	crafting_attempted.emit(recipe.get_result().get_item_name(), true)
	return true
