# GdUnit generated TestSuite
class_name PPInventoryUtilsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://addons/pandora_plus/autoloads/PPInventoryUtils.gd'

var player_inventory : PPInventory
var chest_inventory : PPInventory
var item_entity_ids : Dictionary = {}
var item_instances : Dictionary = {}  # Store instances instead of IDs

func before_test() -> void:
	player_inventory = PPInventory.new()
	chest_inventory = PPInventory.new()
	
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
	test_apple.set_float("value", 5.0)
	test_apple.set_float("weight", 0.5)
	item_entity_ids["GDUNIT_APPLE"] = test_apple.get_entity_id()
	item_instances["apple"] = test_apple

	var test_skull := Pandora.create_entity("GDUNIT_SKULL", items_category).instantiate() as PPItemEntity
	test_skull.set_string("name", "Skull")
	test_skull.set_bool("stackable", true)
	test_skull.set_reference("rarity", test_rare)
	test_skull.set_float("value", 20.0)
	test_skull.set_float("weight", 2.0)
	item_entity_ids["GDUNIT_SKULL"] = test_skull.get_entity_id()
	item_instances["skull"] = test_skull

	var test_master_sword := Pandora.create_entity("GDUNIT_MASTER_SWORD", items_category).instantiate() as PPItemEntity
	test_master_sword.set_string("name", "Master Sword")
	test_master_sword.set_bool("stackable", false)
	test_master_sword.set_reference("rarity", test_epic)
	test_master_sword.set_float("value", 100.0)
	test_master_sword.set_float("weight", 5.0)
	item_entity_ids["GDUNIT_MASTER_SWORD"] = test_master_sword.get_entity_id()
	item_instances["master_sword"] = test_master_sword

	Pandora.save_data()

	player_inventory.add_item(test_apple, 3)
	player_inventory.add_item(test_skull, 1)

	chest_inventory.add_item(test_skull, 1)
	chest_inventory.add_item(test_master_sword, 1)

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

func test_sort_inventory() -> void:
	PPInventoryUtils.sort_inventory(player_inventory, "rarity")
	assert_that(player_inventory.all_items[0].item.get_item_name()).is_equal("Skull")
	
	PPInventoryUtils.sort_inventory(player_inventory, "quantity")
	assert_that(player_inventory.all_items[0].item.get_item_name()).is_equal("Apple")
	
	PPInventoryUtils.sort_inventory(chest_inventory, "name")
	assert_that(chest_inventory.all_items[0].item.get_item_name()).is_equal("Master Sword")

func test_compact_inventory() -> void:
	var test_apple := Pandora.get_entity(item_entity_ids["GDUNIT_APPLE"]) as PPItemEntity
	player_inventory.add_item(test_apple, 1, true)
	
	assert_that(player_inventory.all_items.size()).is_equal(3)
	PPInventoryUtils.compact_inventory(player_inventory)
	assert_that(player_inventory.all_items.size()).is_equal(2)
	assert_that(player_inventory.all_items[0].quantity).is_equal(4)

func test_transfer_items() -> void:
	var test_skull := Pandora.get_entity(item_entity_ids["GDUNIT_SKULL"]) as PPItemEntity
	PPInventoryUtils.transfer_items(chest_inventory, player_inventory, test_skull)
	assert_that(player_inventory.has_item(test_skull, 2)).is_equal(true)

func test_transfer_all() -> void:
	var test_apple := Pandora.get_entity(item_entity_ids["GDUNIT_APPLE"]) as PPItemEntity
	var test_skull := Pandora.get_entity(item_entity_ids["GDUNIT_SKULL"]) as PPItemEntity
	var test_master_sword := Pandora.get_entity(item_entity_ids["GDUNIT_MASTER_SWORD"]) as PPItemEntity
	var transfered_count = PPInventoryUtils.transfer_all(chest_inventory, player_inventory)
	assert_that(transfered_count).is_equal(2)
	assert_that(player_inventory.all_items.size()).is_equal(3)
	assert_that(player_inventory.has_item(test_apple, 3)).is_equal(true)
	assert_that(player_inventory.has_item(test_skull, 2)).is_equal(true)
	assert_that(player_inventory.has_item(test_master_sword, 1)).is_equal(true)
	assert_that(chest_inventory.all_items.size()).is_equal(0)

func test_calculate_total_value() -> void:
	# player_inventory has: 3 apples (3 * 5 = 15) and 1 skull (1 * 20 = 20) = 35 total
	var total_value = PPInventoryUtils.calculate_total_value(player_inventory)

	assert_that(total_value).is_equal(35.0)

func test_calculate_total_value_empty_inventory() -> void:
	var empty_inventory := PPInventory.new()
	var total_value = PPInventoryUtils.calculate_total_value(empty_inventory)

	assert_that(total_value).is_equal(0.0)

func test_calculate_total_weight() -> void:
	# player_inventory has: 3 apples (3 * 0.5 = 1.5) and 1 skull (1 * 2.0 = 2.0) = 3.5 total
	var total_weight = PPInventoryUtils.calculate_total_weight(player_inventory)

	assert_that(total_weight).is_equal(3.5)

func test_calculate_total_weight_empty_inventory() -> void:
	var empty_inventory := PPInventory.new()
	var total_weight = PPInventoryUtils.calculate_total_weight(empty_inventory)

	assert_that(total_weight).is_equal(0.0)

func test_sort_inventory_by_value() -> void:
	var test_apple := item_instances["apple"] as PPItemEntity

	chest_inventory.add_item(test_apple, 1)

	# chest_inventory now has: skull (20), master_sword (100), apple (5)
	# After sorting by value (descending): master_sword (100), skull (20), apple (5)
	PPInventoryUtils.sort_inventory(chest_inventory, "value")

	assert_that(chest_inventory.all_items[0].item.get_item_name()).is_equal("Master Sword")
	assert_that(chest_inventory.all_items[1].item.get_item_name()).is_equal("Skull")
	assert_that(chest_inventory.all_items[2].item.get_item_name()).is_equal("Apple")

func test_sort_inventory_by_weight() -> void:
	var test_apple := item_instances["apple"] as PPItemEntity

	chest_inventory.add_item(test_apple, 1)

	# chest_inventory now has: skull (2.0), master_sword (5.0), apple (0.5)
	# After sorting by weight (ascending): apple (0.5), skull (2.0), master_sword (5.0)
	PPInventoryUtils.sort_inventory(chest_inventory, "weight")

	assert_that(chest_inventory.all_items[0].item.get_item_name()).is_equal("Apple")
	assert_that(chest_inventory.all_items[1].item.get_item_name()).is_equal("Skull")
	assert_that(chest_inventory.all_items[2].item.get_item_name()).is_equal("Master Sword")
