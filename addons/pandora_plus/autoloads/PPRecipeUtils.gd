extends Node

signal crafting_attempted(recipe_id: String, success: bool)

const ITEM_RECIPES_CATEGORY_NAME := "ItemRecipes"

func _get_item_recipes_category() -> PandoraCategory:
	var all_categories := Pandora.get_all_categories()
	var item_recipes_categories := all_categories.filter(func(cat: PandoraCategory): return cat.get_entity_name() == ITEM_RECIPES_CATEGORY_NAME)
	if item_recipes_categories.size() > 0:
		return item_recipes_categories[0]
	return null

func get_all_recipes() -> Array[PPRecipeEntity]:
	var recipes: Array[PPRecipeEntity] = []
	var category := _get_item_recipes_category()
	if category:
		var entities := Pandora.get_all_entities(category)
		for entity in entities:
			if entity is PPRecipeEntity:
				recipes.append(entity)
	return recipes

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

## Filters recipes by recipe type
## Returns an array of PPRecipeEntity matching the specified type
func get_recipes_by_type(recipe_type: String) -> Array[PPRecipeEntity]:
	var filtered: Array[PPRecipeEntity] = []
	var all_recipes := get_all_recipes()

	for recipe_entity in all_recipes:
		var recipe_property := recipe_entity.get_recipe_property()
		if recipe_property and recipe_property.get_recipe_type() == recipe_type:
			filtered.append(recipe_entity)

	return filtered
