# GdUnit generated TestSuite
class_name PPRecipeUtilsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://addons/pandora_plus/autoloads/PPRecipeUtils.gd'

var player_inventory : PPInventory
var item_entity_ids : Dictionary = {}
var item_instances : Dictionary = {}  # Store instances instead of IDs

func before_test() -> void:
	player_inventory = PPInventory.new()

	var items_category := Pandora.get_category(PandoraCategories.ITEMS)

	var test_wood := Pandora.create_entity("GDUNIT_WOOD", items_category).instantiate() as PPItemEntity
	test_wood.set_string("name", "Wood")
	test_wood.set_bool("stackable", true)
	item_entity_ids["GDUNIT_WOOD"] = test_wood.get_entity_id()
	item_instances["wood"] = test_wood

	var test_stone := Pandora.create_entity("GDUNIT_STONE", items_category).instantiate() as PPItemEntity
	test_stone.set_string("name", "Stone")
	test_stone.set_bool("stackable", true)
	item_entity_ids["GDUNIT_STONE"] = test_stone.get_entity_id()
	item_instances["stone"] = test_stone

	var test_sword := Pandora.create_entity("GDUNIT_STONE_SWORD", items_category).instantiate() as PPItemEntity
	test_sword.set_string("name", "Stone Sword")
	test_sword.set_bool("stackable", false)
	item_entity_ids["GDUNIT_STONE_SWORD"] = test_sword.get_entity_id()
	item_instances["sword"] = test_sword

	Pandora.save_data()

	player_inventory.add_item(test_wood, 1)
	player_inventory.add_item(test_stone, 3)

func after_test() -> void:
	var items_category := Pandora.get_category(PandoraCategories.ITEMS)
	for entity_name in ["GDUNIT_WOOD", "GDUNIT_STONE", "GDUNIT_STONE_SWORD"]:
		var to_delete := Pandora.get_all_entities(items_category).filter( \
			func(e: PandoraEntity): return e.get_entity_name() == entity_name)
		Pandora.delete_entity(to_delete[0])
	Pandora.save_data()
	item_entity_ids.clear()

func test_can_craft() -> void:
	var test_wood := item_instances["wood"] as PPItemEntity
	var test_stone := item_instances["stone"] as PPItemEntity
	var test_sword := item_instances["sword"] as PPItemEntity
	var wood_ingredient := PPIngredient.new(PandoraReference.new(test_wood.get_entity_id(), PandoraReference.Type.ENTITY), 2)
	var stone_ingredient := PPIngredient.new(PandoraReference.new(test_stone.get_entity_id(), PandoraReference.Type.ENTITY), 3)
	var sword_result = PandoraReference.new(test_sword.get_entity_id(), PandoraReference.Type.ENTITY)
	var ingredients : Array[PPIngredient] = [wood_ingredient, stone_ingredient]
	var recipe := PPRecipe.new(ingredients, sword_result, 0, "CRAFTING")
	
	assert_that(PPRecipeUtils.can_craft(player_inventory, recipe)).is_equal(false)
	player_inventory.add_item(test_wood, 1)
	assert_that(player_inventory.has_item(test_wood, 2)).is_equal(true)
	assert_that(PPRecipeUtils.can_craft(player_inventory, recipe)).is_equal(true)

func test_craft_recipe() -> void:
	var test_wood := item_instances["wood"] as PPItemEntity
	var test_stone := item_instances["stone"] as PPItemEntity
	var test_sword := item_instances["sword"] as PPItemEntity
	var wood_ingredient := PPIngredient.new(PandoraReference.new(test_wood.get_entity_id(), PandoraReference.Type.ENTITY), 2)
	var stone_ingredient := PPIngredient.new(PandoraReference.new(test_stone.get_entity_id(), PandoraReference.Type.ENTITY), 3)
	var sword_result = PandoraReference.new(test_sword.get_entity_id(), PandoraReference.Type.ENTITY)
	var ingredients : Array[PPIngredient] = [wood_ingredient, stone_ingredient]
	var recipe := PPRecipe.new(ingredients, sword_result, 0, "CRAFTING")
	
	player_inventory.add_item(test_wood, 1)
	assert_that(player_inventory.has_item(test_wood, 2)).is_equal(true)
	assert_that(PPRecipeUtils.can_craft(player_inventory, recipe)).is_equal(true)
	
	PPRecipeUtils.craft_recipe(player_inventory, recipe)
	assert_that(player_inventory.has_item(test_sword)).is_equal(true)
	assert_that(player_inventory.has_item(test_wood)).is_equal(false)
	assert_that(player_inventory.has_item(test_stone)).is_equal(false)

func test_crafting_attempted_signal_success() -> void:
	var test_wood := item_instances["wood"] as PPItemEntity
	var test_stone := item_instances["stone"] as PPItemEntity
	var test_sword := item_instances["sword"] as PPItemEntity
	var wood_ingredient := PPIngredient.new(PandoraReference.new(test_wood.get_entity_id(), PandoraReference.Type.ENTITY), 2)
	var stone_ingredient := PPIngredient.new(PandoraReference.new(test_stone.get_entity_id(), PandoraReference.Type.ENTITY), 3)
	var sword_result = PandoraReference.new(test_sword.get_entity_id(), PandoraReference.Type.ENTITY)
	var ingredients : Array[PPIngredient] = [wood_ingredient, stone_ingredient]
	var recipe := PPRecipe.new(ingredients, sword_result, 0, "CRAFTING")

	player_inventory.add_item(test_wood, 1)

	var signal_received := []
	var signal_handler = func(recipe_id: String, success: bool): signal_received.append([recipe_id, success])

	PPRecipeUtils.crafting_attempted.connect(signal_handler)
	PPRecipeUtils.craft_recipe(player_inventory, recipe)
	PPRecipeUtils.crafting_attempted.disconnect(signal_handler)

	assert_that(signal_received.size()).is_equal(1)
	assert_that(signal_received[0][0]).is_equal("GDUNIT_STONE_SWORD")
	assert_that(signal_received[0][1]).is_true()

func test_crafting_attempted_signal_failure() -> void:
	var test_wood := item_instances["wood"] as PPItemEntity
	var test_stone := item_instances["stone"] as PPItemEntity
	var test_sword := item_instances["sword"] as PPItemEntity
	var wood_ingredient := PPIngredient.new(PandoraReference.new(test_wood.get_entity_id(), PandoraReference.Type.ENTITY), 2)
	var stone_ingredient := PPIngredient.new(PandoraReference.new(test_stone.get_entity_id(), PandoraReference.Type.ENTITY), 3)
	var sword_result = PandoraReference.new(test_sword.get_entity_id(), PandoraReference.Type.ENTITY)
	var ingredients : Array[PPIngredient] = [wood_ingredient, stone_ingredient]
	var recipe := PPRecipe.new(ingredients, sword_result, 0, "CRAFTING")

	# Don't add extra wood, so we only have 1 instead of required 2

	var signal_received := []
	var signal_handler = func(recipe_id: String, success: bool): signal_received.append([recipe_id, success])

	PPRecipeUtils.crafting_attempted.connect(signal_handler)
	var result = PPRecipeUtils.craft_recipe(player_inventory, recipe)
	PPRecipeUtils.crafting_attempted.disconnect(signal_handler)

	assert_that(result).is_false()
	assert_that(signal_received.size()).is_equal(1)
	assert_that(signal_received[0][0]).is_equal("GDUNIT_STONE_SWORD")
	assert_that(signal_received[0][1]).is_false()
