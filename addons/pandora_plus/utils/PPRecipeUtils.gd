extends Node

func can_craft(inventory: Array[Dictionary], recipe: PPRecipe) -> bool:
	var ingredients_found : int = 0
	for ing in recipe.get_ingredients():
		for slot in inventory:
			var item = slot["item"] as PPItemEntity
			var quantity = slot["quantity"] as int
			if ing.get_item_entity().get_item_name() == item.get_item_name() and quantity >= ing.get_quantity():
				ingredients_found += 1
	return ingredients_found == recipe.get_ingredients().size()
