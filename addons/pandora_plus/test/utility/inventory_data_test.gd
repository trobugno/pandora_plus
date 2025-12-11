# GdUnit generated TestSuite
class_name PPInventoryTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://addons/pandora_plus/utility/inventory_data.gd'

var inventory : PPInventory
var item_entity_ids : Dictionary = {}

func before_test() -> void:
	inventory = PPInventory.new()
	var rarities_category := Pandora.get_category(PandoraCategories.RARITY)
	var items_category := Pandora.get_category(PandoraCategories.ITEMS)
	
	var test_common := Pandora.create_entity("GDUNIT_COMMON", rarities_category).instantiate() as PPRarityEntity
	test_common.set_string("name", "Common")
	test_common.set_float("percentage", 60.0)
	
	var test_rare := Pandora.create_entity("GDUNIT_RARE", rarities_category).instantiate() as PPRarityEntity
	test_rare.set_string("name", "Rare")
	test_rare.set_float("percentage", 30.0)
	
	var test_epic := Pandora.create_entity("GDUNIT_EPIC", rarities_category).instantiate() as PPRarityEntity
	test_epic.set_string("name", "Epic")
	test_epic.set_float("percentage", 10.0)
	
	var test_apple := Pandora.create_entity("GDUNIT_APPLE", items_category).instantiate() as PPItemEntity
	test_apple.set_string("name", "Apple")
	test_apple.set_bool("stackable", true)
	test_apple.set_reference("rarity", test_common)
	item_entity_ids["GDUNIT_APPLE"] = test_apple.get_entity_id()
	
	var test_skull := Pandora.create_entity("GDUNIT_SKULL", items_category).instantiate() as PPItemEntity
	test_skull.set_string("name", "Skull")
	test_skull.set_bool("stackable", true)
	test_skull.set_reference("rarity", test_rare)
	item_entity_ids["GDUNIT_SKULL"] = test_skull.get_entity_id()
	
	var test_master_sword := Pandora.create_entity("GDUNIT_MASTER_SWORD", items_category).instantiate() as PPItemEntity
	test_master_sword.set_string("name", "Master Sword")
	test_master_sword.set_bool("stackable", false)
	test_master_sword.set_reference("rarity", test_epic)
	item_entity_ids["GDUNIT_MASTER_SWORD"] = test_master_sword.get_entity_id()
	
	Pandora.save_data()
	
	inventory.add_item(test_apple, 3)
	inventory.add_item(test_skull, 2)
	inventory.add_item(test_master_sword, 1)

func after_test() -> void:
	var rarities_category := Pandora.get_category(PandoraCategories.RARITY)
	for entity_name in ["GDUNIT_COMMON", "GDUNIT_RARE", "GDUNIT_EPIC"]:
		var to_delete := Pandora.get_all_entities(rarities_category).filter( \
			func(e: PandoraEntity): return e.get_entity_name() == entity_name)
		Pandora.delete_entity(to_delete[0])
	
	var items_category := Pandora.get_category(PandoraCategories.ITEMS)
	for entity_name in ["GDUNIT_APPLE", "GDUNIT_SKULL", "GDUNIT_MASTER_SWORD"]:
		var to_delete := Pandora.get_all_entities(items_category).filter( \
			func(e: PandoraEntity): return e.get_entity_name() == entity_name)
		Pandora.delete_entity(to_delete[0])
	Pandora.save_data()
	item_entity_ids.clear()

func test_add_item() -> void:
	var items_category := Pandora.get_category(PandoraCategories.ITEMS)
	var test_item := Pandora.create_entity("GDUNIT_ITEM_TEST", items_category).instantiate() as PPItemEntity
	test_item.set_string("name", "GDUNIT_ITEM_TEST")
	Pandora.save_data()
	
	inventory.add_item(test_item, 1)
	assert_that(inventory.all_items.is_empty()).is_equal(false)
	assert_that(inventory.all_items.size()).is_equal(4)
	
	Pandora.delete_entity(test_item)
	Pandora.save_data()

func test_add_item_2() -> void:
	var test_apple := Pandora.get_entity(item_entity_ids["GDUNIT_APPLE"]) as PPItemEntity
	inventory.add_item(test_apple, 1)
	assert_that(inventory.all_items.size()).is_equal(3)

func test_has_item() -> void:
	var test_apple := Pandora.get_entity(item_entity_ids["GDUNIT_APPLE"]) as PPItemEntity
	assert_that(inventory.has_item(test_apple, 3)).is_equal(true)

func test_has_item_2() -> void:
	var test_apple := Pandora.get_entity(item_entity_ids["GDUNIT_APPLE"]) as PPItemEntity
	inventory.add_item(test_apple, 1)
	assert_that(inventory.has_item(test_apple, 4)).is_equal(true)

func test_remove_item() -> void:
	var test_apple := Pandora.get_entity(item_entity_ids["GDUNIT_APPLE"]) as PPItemEntity
	inventory.remove_item(test_apple, 2)
	assert_that(inventory.has_item(test_apple, 1)).is_equal(true)

func test_remove_single_item_by() -> void:
	var test_apple := Pandora.get_entity(item_entity_ids["GDUNIT_APPLE"]) as PPItemEntity
	inventory.remove_single_item_by(0)
	assert_that(inventory.has_item(test_apple, 2)).is_equal(true)
