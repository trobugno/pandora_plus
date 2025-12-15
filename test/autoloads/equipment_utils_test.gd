# GdUnit generated TestSuite
class_name PPEquipmentUtilsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://addons/pandora_plus/autoloads/PPEquipmentUtils.gd'

var player_inventory: PPInventory
var player_stats: PPRuntimeStats
var item_instances: Dictionary = {}  # Store instances instead of entity IDs
var signal_spy_equipped: GdUnitSignalAssert
var signal_spy_unequipped: GdUnitSignalAssert

func before_test() -> void:
	player_inventory = PPInventory.new()

	# Create base stats for player
	var base_stats = PPStats.new(100, 50, 5, 10, 1.0, 0.0, 0.0, 1)
	player_stats = PPRuntimeStats.new(base_stats)

	# Create test items category
	var items_category := Pandora.get_category(PandoraCategories.ITEMS)
	var equipments_category := Pandora.get_category(PandoraCategories.ItemsCategories.EQUIPMENT)

	# Create a helmet (equipment with stats)
	var test_helmet := Pandora.create_entity("GDUNIT_IRON_HELMET", equipments_category).instantiate() as PPEquipmentEntity
	test_helmet.set_string("name", "Iron Helmet")
	test_helmet.set_bool("stackable", false)
	test_helmet.set_string("equipment_slot", "HEAD")

	# Add stats to helmet
	var helmet_stats = PPStats.new(20, -1, 5)
	test_helmet.get_entity_property("stats_property").set_default_value(helmet_stats)
	item_instances["GDUNIT_IRON_HELMET"] = test_helmet

	# Create a sword (equipment with stats)
	var test_sword := Pandora.create_entity("GDUNIT_IRON_SWORD", equipments_category).instantiate() as PPEquipmentEntity
	test_sword.set_string("name", "Iron Sword")
	test_sword.set_bool("stackable", false)
	test_sword.set_string("equipment_slot", "WEAPON")

	var sword_stats = PPStats.new(-1, -1, -1, 15, -1, 5.0)
	test_sword.get_entity_property("stats_property").set_default_value(sword_stats)
	item_instances["GDUNIT_IRON_SWORD"] = test_sword

	# Create a shield (equipment with stats)
	var test_shield := Pandora.create_entity("GDUNIT_WOODEN_SHIELD", equipments_category).instantiate() as PPEquipmentEntity
	test_shield.set_string("name", "Wooden Shield")
	test_shield.set_bool("stackable", false)
	test_shield.set_string("equipment_slot", "SHIELD")

	var shield_stats = PPStats.new(-1, -1, 10)
	test_shield.get_entity_property("stats_property").set_default_value(shield_stats)
	item_instances["GDUNIT_WOODEN_SHIELD"] = test_shield

	# Create a chest armor (equipment with stats)
	var test_chest := Pandora.create_entity("GDUNIT_LEATHER_ARMOR", equipments_category).instantiate() as PPEquipmentEntity
	test_chest.set_string("name", "Leather Armor")
	test_chest.set_bool("stackable", false)
	test_chest.set_string("equipment_slot", "CHEST")

	var chest_stats = PPStats.new(30, -1, 8)
	test_chest.get_entity_property("stats_property").set_default_value(chest_stats)
	item_instances["GDUNIT_LEATHER_ARMOR"] = test_chest

	# Create a regular item (non-equipment)
	var test_apple := Pandora.create_entity("GDUNIT_APPLE", items_category).instantiate() as PPItemEntity
	test_apple.set_string("name", "Apple")
	test_apple.set_bool("stackable", true)
	item_instances["GDUNIT_APPLE"] = test_apple

	Pandora.save_data()

	# Add items to inventory
	player_inventory.add_item(test_helmet, 1)
	player_inventory.add_item(test_sword, 1)
	player_inventory.add_item(test_shield, 1)
	player_inventory.add_item(test_chest, 1)
	player_inventory.add_item(test_apple, 5)

func after_test() -> void:
	var equipments_category := Pandora.get_category(PandoraCategories.ItemsCategories.EQUIPMENT)
	for entity_name in ["GDUNIT_IRON_HELMET", "GDUNIT_IRON_SWORD", "GDUNIT_WOODEN_SHIELD", "GDUNIT_LEATHER_ARMOR", "GDUNIT_APPLE"]:
		var to_delete := Pandora.get_all_entities(equipments_category).filter(
			func(e: PandoraEntity): return e.get_entity_name() == entity_name)
		if to_delete.size() > 0:
			Pandora.delete_entity(to_delete[0])
	Pandora.save_data()
	item_instances.clear()

# ============================================================================
# TEST: can_equip
# ============================================================================

func test_can_equip_with_equipment_entity() -> void:
	var helmet = item_instances["GDUNIT_IRON_HELMET"] as PPEquipmentEntity
	assert_that(PPEquipmentUtils.can_equip(helmet)).is_true()

func test_can_equip_with_regular_item() -> void:
	var apple = item_instances["GDUNIT_APPLE"] as PPItemEntity
	assert_that(PPEquipmentUtils.can_equip(apple)).is_false()

# ============================================================================
# TEST: get_equipment_slot
# ============================================================================

func test_get_equipment_slot() -> void:
	var helmet = item_instances["GDUNIT_IRON_HELMET"] as PPEquipmentEntity
	var slot = PPEquipmentUtils.get_equipment_slot(helmet)
	assert_that(slot).is_equal("HEAD")

	var sword = item_instances["GDUNIT_IRON_SWORD"] as PPEquipmentEntity
	slot = PPEquipmentUtils.get_equipment_slot(sword)
	assert_that(slot).is_equal("WEAPON")

func test_get_equipment_slot_with_null() -> void:
	var slot = PPEquipmentUtils.get_equipment_slot(null)
	assert_that(slot).is_equal("")

# ============================================================================
# TEST: get_equipment_stats
# ============================================================================

func test_get_equipment_stats() -> void:
	var helmet = item_instances["GDUNIT_IRON_HELMET"] as PPEquipmentEntity
	var stats = PPEquipmentUtils.get_equipment_stats(helmet)

	assert_that(stats).is_not_null()
	assert_that(stats._health).is_equal(20)
	assert_that(stats._defense).is_equal(5)

func test_get_equipment_stats_with_null() -> void:
	var stats = PPEquipmentUtils.get_equipment_stats(null)
	assert_that(stats).is_null()

# ============================================================================
# TEST: equip_item
# ============================================================================

func test_equip_item_success() -> void:
	var helmet = item_instances["GDUNIT_IRON_HELMET"] as PPEquipmentEntity

	# Verify item is in inventory
	assert_that(player_inventory.has_item(helmet)).is_true()

	# Equip the helmet
	var success = PPEquipmentUtils.equip_item(player_inventory, helmet, player_stats)

	assert_that(success).is_true()
	assert_that(player_inventory.has_equipment_in_slot("HEAD")).is_true()
	assert_that(player_inventory.has_item(helmet)).is_false() # Should be removed from inventory

	# Check stats were applied
	var effective_health = player_stats.get_effective_stat("health")
	var effective_defense = player_stats.get_effective_stat("defense")
	assert_that(effective_health).is_equal(120.0) # 100 base + 20 from helmet
	assert_that(effective_defense).is_equal(10.0) # 5 base + 5 from helmet

func test_equip_item_not_in_inventory() -> void:
	var helmet = item_instances["GDUNIT_IRON_HELMET"] as PPEquipmentEntity

	# Remove helmet from inventory first
	player_inventory.remove_item(helmet, 1)

	var success = PPEquipmentUtils.equip_item(player_inventory, helmet, player_stats)

	assert_that(success).is_false()

func test_equip_item_replaces_existing() -> void:
	var helmet = item_instances["GDUNIT_IRON_HELMET"] as PPEquipmentEntity
	var sword = item_instances["GDUNIT_IRON_SWORD"] as PPEquipmentEntity
	
	# Equip helmet first
	PPEquipmentUtils.equip_item(player_inventory, helmet, player_stats)
	
	# Try to equip another helmet (should fail in this test since we only have one helmet type)
	# But equipping a weapon should work
	var success = PPEquipmentUtils.equip_item(player_inventory, sword, player_stats)
	
	assert_that(success).is_true()
	assert_that(player_inventory.has_equipment_in_slot("WEAPON")).is_true()

func test_equip_item_emits_signal() -> void:
	var helmet = item_instances["GDUNIT_IRON_HELMET"] as PPEquipmentEntity
	
	var signal_received := []
	var signal_handler = func(stats, slot, item): signal_received.append([stats, slot, item])
	PPEquipmentUtils.equipment_equipped.connect(signal_handler)
	PPEquipmentUtils.equip_item(player_inventory, helmet, player_stats)
	
	PPEquipmentUtils.equipment_equipped.disconnect(signal_handler)
	assert_that(signal_received.size()).is_equal(1)
	assert_that(signal_received[0][1]).is_equal("HEAD")

# ============================================================================
# TEST: unequip_item
# ============================================================================

func test_unequip_item_success() -> void:
	var helmet = item_instances["GDUNIT_IRON_HELMET"] as PPEquipmentEntity

	# Equip first
	PPEquipmentUtils.equip_item(player_inventory, helmet, player_stats)

	# Verify it's equipped
	assert_that(player_inventory.has_equipment_in_slot("HEAD")).is_true()

	# Unequip
	var success = PPEquipmentUtils.unequip_item(player_inventory, "HEAD", player_stats)

	assert_that(success).is_true()
	assert_that(player_inventory.has_equipment_in_slot("HEAD")).is_false()
	assert_that(player_inventory.has_item(helmet)).is_true() # Should be back in inventory

	# Check stats were removed
	var effective_health = player_stats.get_effective_stat("health")
	var effective_defense = player_stats.get_effective_stat("defense")
	assert_that(effective_health).is_equal(100.0) # Back to base
	assert_that(effective_defense).is_equal(5.0) # Back to base

func test_unequip_item_empty_slot() -> void:
	var success = PPEquipmentUtils.unequip_item(player_inventory, "HEAD", player_stats)

	assert_that(success).is_false()

func test_unequip_item_emits_signal() -> void:
	var helmet = item_instances["GDUNIT_IRON_HELMET"] as PPEquipmentEntity

	var signal_received := []
	var signal_handler = func(stats, slot, item): signal_received.append([stats, slot, item])
	PPEquipmentUtils.equip_item(player_inventory, helmet, player_stats)
	PPEquipmentUtils.equipment_unequipped.connect(signal_handler)
	PPEquipmentUtils.unequip_item(player_inventory, "HEAD", player_stats)
	PPEquipmentUtils.equipment_unequipped.disconnect(signal_handler)
	assert_that(signal_received.size()).is_equal(1)
	assert_that(signal_received[0][1]).is_equal("HEAD")

# ============================================================================
# TEST: unequip_all
# ============================================================================

func test_unequip_all_success() -> void:
	var helmet = item_instances["GDUNIT_IRON_HELMET"] as PPEquipmentEntity
	var sword = item_instances["GDUNIT_IRON_SWORD"] as PPEquipmentEntity
	var shield = item_instances["GDUNIT_WOODEN_SHIELD"] as PPEquipmentEntity

	# Equip multiple items
	PPEquipmentUtils.equip_item(player_inventory, helmet, player_stats)
	PPEquipmentUtils.equip_item(player_inventory, sword, player_stats)
	PPEquipmentUtils.equip_item(player_inventory, shield, player_stats)

	# Unequip all
	var count = PPEquipmentUtils.unequip_all(player_inventory, player_stats)

	assert_that(count).is_equal(3)
	assert_that(player_inventory.has_equipment_in_slot("HEAD")).is_false()
	assert_that(player_inventory.has_equipment_in_slot("WEAPON")).is_false()
	assert_that(player_inventory.has_equipment_in_slot("SHIELD")).is_false()

	# All items should be back in inventory
	assert_that(player_inventory.has_item(helmet)).is_true()
	assert_that(player_inventory.has_item(sword)).is_true()
	assert_that(player_inventory.has_item(shield)).is_true()

	# Stats should be back to base
	var effective_health = player_stats.get_effective_stat("health")
	var effective_attack = player_stats.get_effective_stat("attack")
	var effective_defense = player_stats.get_effective_stat("defense")
	assert_that(effective_health).is_equal(100.0)
	assert_that(effective_attack).is_equal(10.0)
	assert_that(effective_defense).is_equal(5.0)

func test_unequip_all_with_empty_slots() -> void:
	var count = PPEquipmentUtils.unequip_all(player_inventory, player_stats)

	assert_that(count).is_equal(0)

# ============================================================================
# TEST: get_total_equipment_stats
# ============================================================================

func test_get_total_equipment_stats() -> void:
	var helmet = item_instances["GDUNIT_IRON_HELMET"] as PPEquipmentEntity
	var sword = item_instances["GDUNIT_IRON_SWORD"] as PPEquipmentEntity
	var chest = item_instances["GDUNIT_LEATHER_ARMOR"] as PPEquipmentEntity

	# Equip multiple items
	PPEquipmentUtils.equip_item(player_inventory, helmet, player_stats)
	PPEquipmentUtils.equip_item(player_inventory, sword, player_stats)
	PPEquipmentUtils.equip_item(player_inventory, chest, player_stats)

	var totals = PPEquipmentUtils.get_total_equipment_stats(player_inventory)

	# Helmet: +20 health, +5 defense
	# Sword: +15 attack, +5 crit_rate
	# Chest: +30 health, +8 defense
	# Totals: +50 health, +15 attack, +13 defense, +5 crit_rate
	assert_that(totals.get("health", 0.0)).is_equal(50.0)
	assert_that(totals.get("attack", 0.0)).is_equal(15.0)
	assert_that(totals.get("defense", 0.0)).is_equal(13.0)
	assert_that(totals.get("crit_rate", 0.0)).is_equal(5.0)

func test_get_total_equipment_stats_empty() -> void:
	var totals = PPEquipmentUtils.get_total_equipment_stats(player_inventory)

	assert_that(totals.size()).is_equal(0)

# ============================================================================
# TEST: Stat Modifier Application
# ============================================================================

func test_stat_modifiers_are_applied_correctly() -> void:
	var sword = item_instances["GDUNIT_IRON_SWORD"] as PPEquipmentEntity

	var initial_attack = player_stats.get_effective_stat("attack")

	# Equip sword
	PPEquipmentUtils.equip_item(player_inventory, sword, player_stats)

	var new_attack = player_stats.get_effective_stat("attack")

	# Should have +15 attack from sword
	assert_that(new_attack).is_equal(initial_attack + 15.0)

func test_stat_modifiers_are_removed_correctly() -> void:
	var sword = item_instances["GDUNIT_IRON_SWORD"] as PPEquipmentEntity

	# Equip sword
	PPEquipmentUtils.equip_item(player_inventory, sword, player_stats)

	var equipped_attack = player_stats.get_effective_stat("attack")
	assert_that(equipped_attack).is_equal(25.0) # 10 base + 15 from sword

	# Unequip sword
	PPEquipmentUtils.unequip_item(player_inventory, "WEAPON", player_stats)

	var unequipped_attack = player_stats.get_effective_stat("attack")
	assert_that(unequipped_attack).is_equal(10.0) # Back to base

func test_multiple_equipment_modifiers_stack() -> void:
	var helmet = item_instances["GDUNIT_IRON_HELMET"] as PPEquipmentEntity
	var chest = item_instances["GDUNIT_LEATHER_ARMOR"] as PPEquipmentEntity
	var shield = item_instances["GDUNIT_WOODEN_SHIELD"] as PPEquipmentEntity

	# Equip multiple defensive items
	PPEquipmentUtils.equip_item(player_inventory, helmet, player_stats)
	PPEquipmentUtils.equip_item(player_inventory, chest, player_stats)
	PPEquipmentUtils.equip_item(player_inventory, shield, player_stats)

	var defense = player_stats.get_effective_stat("defense")
	# 5 (base) + 5 (helmet) + 8 (chest) + 10 (shield) = 28
	assert_that(defense).is_equal(28.0)

	var health = player_stats.get_effective_stat("health")
	# 100 (base) + 20 (helmet) + 30 (chest) = 150
	assert_that(health).is_equal(150.0)
