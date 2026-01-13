extends Node

signal crafting_attempted(recipe_id: String, success: bool)

func can_craft(inventory: PPInventory, recipe: PPRecipe) -> bool:
	var ingredients_found : int = 0
	for ingredient in recipe.get_ingredients():
		for slot in inventory.all_items:
			if not slot or not slot.item:
				continue
			var item = slot.item
			var quantity = slot.quantity
			var instance = ingredient.get_item_entity() as PPItemEntity
			if instance and instance.get_entity_id() == item.get_entity_id() and quantity >= ingredient.get_quantity():
				ingredients_found += 1
	return ingredients_found == recipe.get_ingredients().size()

func craft_recipe(inventory: PPInventory, recipe: PPRecipe) -> bool:
	var result_item = recipe.get_result()
	if not result_item:
		push_error("Recipe has no valid result item")
		return false

	if not can_craft(inventory, recipe):
		crafting_attempted.emit(result_item.get_entity_name(), false)
		return false

	for ingredient in recipe.get_ingredients():
		inventory.remove_item(ingredient.get_item_entity(), ingredient.get_quantity())

	inventory.add_item(result_item)

	# Add waste item if defined
	var waste = recipe.get_waste()
	if waste:
		var waste_item = waste.get_item_entity()
		if waste_item:
			inventory.add_item(waste_item, waste.get_quantity())

	crafting_attempted.emit(result_item.get_entity_name(), true)
	return true
