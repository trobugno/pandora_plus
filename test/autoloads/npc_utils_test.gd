# GdUnit generated TestSuite
class_name PPNPCUtilsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://addons/pandora_plus/autoloads/PPNPCUtils.gd'

var test_npcs: Dictionary = {}
var test_items: Dictionary = {}
var test_locations: Dictionary = {}
var test_runtime_npcs: Array[PPRuntimeNPC] = []
var player_inventory: PPInventory

func before_test() -> void:
	player_inventory = PPInventory.new()
	player_inventory.game_currency = 1000

	# Create test categories
	var npcs_category := Pandora.get_category(PandoraCategories.NPCS)
	var items_category := Pandora.get_category(PandoraCategories.ITEMS)
	var locations_category := Pandora.get_category(PandoraCategories.LOCATIONS)

	# Create test locations
	var town_location := Pandora.create_entity("GDUNIT_TOWN", locations_category).instantiate() as PPLocationEntity
	town_location.set_string("name", "Test Town")
	town_location.set_string("area_name", "Test Area")
	town_location.set_string("location_type", "Town")
	town_location.set_bool("is_safe_zone", true)
	test_locations["town"] = town_location

	# Create test items
	var test_sword := Pandora.create_entity("GDUNIT_NPC_TEST_SWORD", items_category).instantiate() as PPItemEntity
	test_sword.set_string("name", "Test Sword")
	test_sword.set_bool("stackable", false)
	test_sword.set_float("value", 100.0)
	test_items["sword"] = test_sword

	var test_potion := Pandora.create_entity("GDUNIT_NPC_TEST_POTION", items_category).instantiate() as PPItemEntity
	test_potion.set_string("name", "Test Potion")
	test_potion.set_bool("stackable", true)
	test_potion.set_float("value", 25.0)
	test_items["potion"] = test_potion

	# Create friendly NPC
	var friendly_npc_entity := Pandora.create_entity("GDUNIT_FRIENDLY_NPC", npcs_category).instantiate() as PPNPCEntity
	friendly_npc_entity.set_string("name", "Friendly Bob")
	friendly_npc_entity.set_string("faction", "Merchants")
	friendly_npc_entity.set_bool("is_hostile", false)
	friendly_npc_entity.set_reference("spawn_location", town_location)

	var friendly_stats := PPStats.new(100, 50, 10, 5)
	friendly_npc_entity.get_entity_property("base_stats").set_default_value(friendly_stats)
	test_npcs["friendly"] = friendly_npc_entity

	# Create hostile NPC
	var hostile_npc_entity := Pandora.create_entity("GDUNIT_HOSTILE_NPC", npcs_category).instantiate() as PPNPCEntity
	hostile_npc_entity.set_string("name", "Hostile Orc")
	hostile_npc_entity.set_string("faction", "Orcs")
	hostile_npc_entity.set_bool("is_hostile", true)
	hostile_npc_entity.set_reference("spawn_location", town_location)

	var hostile_stats := PPStats.new(150, 0, 20, 8)
	hostile_npc_entity.get_entity_property("base_stats").set_default_value(hostile_stats)
	test_npcs["hostile"] = hostile_npc_entity

	# Create quest giver NPC
	var quest_giver_entity := Pandora.create_entity("GDUNIT_QUEST_GIVER_NPC", npcs_category).instantiate() as PPNPCEntity
	quest_giver_entity.set_string("name", "Quest Master")
	quest_giver_entity.set_string("faction", "Guild")
	quest_giver_entity.set_bool("is_hostile", false)
	quest_giver_entity.set_reference("spawn_location", town_location)
	# Quest giver setup would require quest entities, simplified for now

	var quest_giver_stats := PPStats.new(100, 100, 10, 10)
	quest_giver_entity.get_entity_property("base_stats").set_default_value(quest_giver_stats)
	test_npcs["quest_giver"] = quest_giver_entity

	Pandora.save_data()

func after_test() -> void:
	# Clear runtime NPCs
	test_runtime_npcs.clear()

	# Clean up entities
	var npcs_category := Pandora.get_category(PandoraCategories.NPCS)
	var items_category := Pandora.get_category(PandoraCategories.ITEMS)
	var locations_category := Pandora.get_category(PandoraCategories.LOCATIONS)

	for npc_name in ["GDUNIT_FRIENDLY_NPC", "GDUNIT_HOSTILE_NPC", "GDUNIT_QUEST_GIVER_NPC"]:
		var to_delete := Pandora.get_all_entities(npcs_category).filter(
			func(e: PandoraEntity): return e.get_entity_name() == npc_name)
		if to_delete.size() > 0:
			Pandora.delete_entity(to_delete[0])

	for item_name in ["GDUNIT_NPC_TEST_SWORD", "GDUNIT_NPC_TEST_POTION"]:
		var to_delete := Pandora.get_all_entities(items_category).filter(
			func(e: PandoraEntity): return e.get_entity_name() == item_name)
		if to_delete.size() > 0:
			Pandora.delete_entity(to_delete[0])

	for location_name in ["GDUNIT_TOWN"]:
		var to_delete := Pandora.get_all_entities(locations_category).filter(
			func(e: PandoraEntity): return e.get_entity_name() == location_name)
		if to_delete.size() > 0:
			Pandora.delete_entity(to_delete[0])

	Pandora.save_data()
	test_npcs.clear()
	test_items.clear()
	test_locations.clear()

# ============================================================================
# TEST: Lifecycle & Management - spawn_npc
# ============================================================================

func test_spawn_npc_success() -> void:
	var npc_entity = test_npcs["friendly"] as PPNPCEntity
	var runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

	assert_that(runtime_npc).is_not_null()
	assert_that(runtime_npc.is_alive()).is_true()
	assert_that(runtime_npc.npc_data.get("name")).is_equal("Friendly Bob")

func test_spawn_npc_null_entity() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(null)

	assert_that(runtime_npc).is_null()

func test_spawn_npc_initializes_stats() -> void:
	var npc_entity = test_npcs["friendly"] as PPNPCEntity
	var runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

	assert_that(runtime_npc.get_max_health()).is_equal(100.0)
	assert_that(runtime_npc.get_current_health()).is_equal(100.0)

# ============================================================================
# TEST: Lifecycle & Management - find NPCs
# ============================================================================

func test_find_npc_by_id() -> void:
	var npc_entity = test_npcs["friendly"] as PPNPCEntity
	var runtime_npc1 = PPNPCUtils.spawn_npc(npc_entity)
	var runtime_npc2 = PPNPCUtils.spawn_npc(test_npcs["hostile"])

	var npcs_list = [runtime_npc1, runtime_npc2]
	var found = PPNPCUtils.find_npc_by_id(npcs_list, npc_entity.get_entity_id())

	assert_that(found).is_not_null()
	assert_that(found.npc_data.get("name")).is_equal("Friendly Bob")

func test_find_npc_by_id_not_found() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	var npcs_list = [runtime_npc]

	var found = PPNPCUtils.find_npc_by_id(npcs_list, "non_existent_id")

	assert_that(found).is_null()

func test_find_npc_by_name() -> void:
	var runtime_npc1 = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	var runtime_npc2 = PPNPCUtils.spawn_npc(test_npcs["hostile"])

	var npcs_list = [runtime_npc1, runtime_npc2]
	var found = PPNPCUtils.find_npc_by_name(npcs_list, "Friendly Bob")

	assert_that(found).is_not_null()
	assert_that(found.npc_data.get("name")).is_equal("Friendly Bob")

func test_find_npc_by_name_not_found() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	var npcs_list = [runtime_npc]

	var found = PPNPCUtils.find_npc_by_name(npcs_list, "NonExistent")

	assert_that(found).is_null()

# ============================================================================
# TEST: Combat Operations - damage and heal
# ============================================================================

func test_damage_npc() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	var initial_health = runtime_npc.get_current_health()

	PPNPCUtils.damage_npc(runtime_npc, 30.0, "test")

	assert_that(runtime_npc.get_current_health()).is_equal(initial_health - 30.0)

func test_heal_npc() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	PPNPCUtils.damage_npc(runtime_npc, 50.0)

	var damaged_health = runtime_npc.get_current_health()
	PPNPCUtils.heal_npc(runtime_npc, 20.0)

	assert_that(runtime_npc.get_current_health()).is_equal(damaged_health + 20.0)

func test_kill_npc() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(test_npcs["friendly"])

	PPNPCUtils.kill_npc(runtime_npc)

	assert_that(runtime_npc.is_alive()).is_false()

func test_kill_npc_emits_signal() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(test_npcs["friendly"])

	var signal_received := []
	PPNPCUtils.npc_died.connect(func(npc): signal_received.append(npc))

	PPNPCUtils.kill_npc(runtime_npc)

	PPNPCUtils.npc_died.disconnect(PPNPCUtils.npc_died.get_connections()[0]["callable"])

	assert_that(signal_received.size()).is_equal(1)

func test_revive_npc() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	PPNPCUtils.kill_npc(runtime_npc)

	PPNPCUtils.revive_npc(runtime_npc, 0.5)

	assert_that(runtime_npc.is_alive()).is_true()
	assert_that(runtime_npc.get_current_health()).is_equal(50.0)  # 50% of 100

func test_revive_npc_emits_signal() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	PPNPCUtils.kill_npc(runtime_npc)

	var signal_received := []
	PPNPCUtils.npc_revived.connect(func(npc): signal_received.append(npc))

	PPNPCUtils.revive_npc(runtime_npc)

	PPNPCUtils.npc_revived.disconnect(PPNPCUtils.npc_revived.get_connections()[0]["callable"])

	assert_that(signal_received.size()).is_equal(1)

func test_can_engage_combat_hostile() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(test_npcs["hostile"])

	var can_engage = PPNPCUtils.can_engage_combat(runtime_npc)

	assert_that(can_engage).is_true()

func test_can_engage_combat_friendly() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(test_npcs["friendly"])

	var can_engage = PPNPCUtils.can_engage_combat(runtime_npc)

	assert_that(can_engage).is_false()

func test_can_engage_combat_dead_npc() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(test_npcs["hostile"])
	PPNPCUtils.kill_npc(runtime_npc)

	var can_engage = PPNPCUtils.can_engage_combat(runtime_npc)

	assert_that(can_engage).is_false()

func test_can_interact_with_npc_alive() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(test_npcs["friendly"])

	var can_interact = PPNPCUtils.can_interact_with_npc(runtime_npc)

	assert_that(can_interact).is_true()

func test_can_interact_with_npc_dead() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	PPNPCUtils.kill_npc(runtime_npc)

	var can_interact = PPNPCUtils.can_interact_with_npc(runtime_npc)

	assert_that(can_interact).is_false()

func test_can_interact_with_hostile_npc() -> void:
	var runtime_npc = PPNPCUtils.spawn_npc(test_npcs["hostile"])

	var can_interact = PPNPCUtils.can_interact_with_npc(runtime_npc)

	assert_that(can_interact).is_false()

# ============================================================================
# TEST: Filtering & Sorting
# ============================================================================

func test_filter_by_faction() -> void:
	var npc1 = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	var npc2 = PPNPCUtils.spawn_npc(test_npcs["quest_giver"])
	var npc3 = PPNPCUtils.spawn_npc(test_npcs["hostile"])

	var npcs_list = [npc1, npc2, npc3]
	var merchants_faction = PPNPCUtils.filter_by_faction(npcs_list, "Merchants")

	assert_that(merchants_faction.size()).is_equal(1)

func test_get_alive_npcs() -> void:
	var npc1 = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	var npc2 = PPNPCUtils.spawn_npc(test_npcs["hostile"])
	PPNPCUtils.kill_npc(npc2)

	var npcs_list = [npc1, npc2]
	var alive = PPNPCUtils.get_alive_npcs(npcs_list)

	assert_that(alive.size()).is_equal(1)
	assert_that(alive[0].npc_data.get("name")).is_equal("Friendly Bob")

func test_get_dead_npcs() -> void:
	var npc1 = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	var npc2 = PPNPCUtils.spawn_npc(test_npcs["hostile"])
	PPNPCUtils.kill_npc(npc2)

	var npcs_list = [npc1, npc2]
	var dead = PPNPCUtils.get_dead_npcs(npcs_list)

	assert_that(dead.size()).is_equal(1)
	assert_that(dead[0].npc_data.get("name")).is_equal("Hostile Orc")

func test_get_hostile_npcs() -> void:
	var npc1 = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	var npc2 = PPNPCUtils.spawn_npc(test_npcs["hostile"])

	var npcs_list = [npc1, npc2]
	var hostile = PPNPCUtils.get_hostile_npcs(npcs_list)

	assert_that(hostile.size()).is_equal(1)
	assert_that(hostile[0].npc_data.get("name")).is_equal("Hostile Orc")

func test_sort_npcs_by_name() -> void:
	var npc1 = PPNPCUtils.spawn_npc(test_npcs["hostile"])  # "Hostile Orc"
	var npc2 = PPNPCUtils.spawn_npc(test_npcs["friendly"])  # "Friendly Bob"

	var npcs_list = [npc1, npc2]
	var sorted = PPNPCUtils.sort_npcs(npcs_list, "name")

	assert_that(sorted[0].npc_data.get("name")).is_equal("Friendly Bob")
	assert_that(sorted[1].npc_data.get("name")).is_equal("Hostile Orc")

func test_sort_npcs_by_health() -> void:
	var npc1 = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	var npc2 = PPNPCUtils.spawn_npc(test_npcs["hostile"])

	PPNPCUtils.damage_npc(npc1, 50)

	var npcs_list = [npc1, npc2]
	var sorted = PPNPCUtils.sort_npcs(npcs_list, "health")

	assert_that(sorted[0].get_current_health()).is_greater_equal(sorted[1].get_current_health())

# ============================================================================
# TEST: Statistics & Analytics
# ============================================================================

func test_calculate_npc_stats() -> void:
	var npc1 = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	var npc2 = PPNPCUtils.spawn_npc(test_npcs["hostile"])
	var npc3 = PPNPCUtils.spawn_npc(test_npcs["quest_giver"])

	var npcs_list = [npc1, npc2, npc3]
	var stats = PPNPCUtils.calculate_npc_stats(npcs_list)

	assert_that(stats["total_npcs"]).is_equal(3)
	assert_that(stats["alive_count"]).is_equal(3)
	assert_that(stats["dead_count"]).is_equal(0)
	assert_that(stats["hostile_count"]).is_equal(1)

func test_calculate_npc_stats_empty() -> void:
	var npcs_list: Array = []
	var stats = PPNPCUtils.calculate_npc_stats(npcs_list)

	assert_that(stats["total_npcs"]).is_equal(0)

func test_get_most_common_faction() -> void:
	var npc1 = PPNPCUtils.spawn_npc(test_npcs["friendly"])
	var npc2 = PPNPCUtils.spawn_npc(test_npcs["quest_giver"])
	var npc3 = PPNPCUtils.spawn_npc(test_npcs["hostile"])

	var npcs_list = [npc1, npc2, npc3]
	var most_common = PPNPCUtils.get_most_common_faction(npcs_list)

	# Now we should have 1 Merchants, 1 Guild, 1 Orcs
	# So the result should be one of them (not deterministic with ties)
	assert_that(most_common).is_not_equal("")

func test_get_most_common_faction_empty() -> void:
	var npcs_list: Array = []
	var most_common = PPNPCUtils.get_most_common_faction(npcs_list)

	assert_that(most_common).is_equal("")
