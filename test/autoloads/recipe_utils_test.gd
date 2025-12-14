# GdUnit generated TestSuite
class_name PPRecipeUtilsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://addons/pandora_plus/autoloads/PPRecipeUtils.gd'

var player_inventory : PPInventory
var item_entity_ids : Dictionary = {}

func before_test() -> void:
	player_inventory = PPInventory.new()
	
	var items_category := Pandora.get_category(PandoraCategories.ITEMS)
	
	var test_wood := Pandora.create_entity("GDUNIT_WOOD", items_category).instantiate() as PPItemEntity
	test_wood.set_string("name", "Wood")
	test_wood.set_bool("stackable", true)
	item_entity_ids["GDUNIT_WOOD"] = test_wood.get_entity_id()
	
	var test_stone := Pandora.create_entity("GDUNIT_STONE", items_category).instantiate() as PPItemEntity
	test_stone.set_string("name", "Stone")
	test_stone.set_bool("stackable", true)
	item_entity_ids["GDUNIT_STONE"] = test_stone.get_entity_id()
	
	var test_sword := Pandora.create_entity("GDUNIT_STONE_SWORD", items_category).instantiate() as PPItemEntity
	test_sword.set_string("name", "Stone Sword")
	test_sword.set_bool("stackable", false)
	item_entity_ids["GDUNIT_STONE_SWORD"] = test_sword.get_entity_id()
	
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
	var test_wood := Pandora.get_entity(item_entity_ids["GDUNIT_WOOD"]) as PPItemEntity
	var test_stone := Pandora.get_entity(item_entity_ids["GDUNIT_STONE"]) as PPItemEntity
	var test_sword := Pandora.get_entity(item_entity_ids["GDUNIT_STONE_SWORD"]) as PPItemEntity
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
	var test_wood := Pandora.get_entity(item_entity_ids["GDUNIT_WOOD"]) as PPItemEntity
	var test_stone := Pandora.get_entity(item_entity_ids["GDUNIT_STONE"]) as PPItemEntity
	var test_sword := Pandora.get_entity(item_entity_ids["GDUNIT_STONE_SWORD"]) as PPItemEntity
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
