# GdUnit generated TestSuite
class_name PPQuestUtilsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://addons/pandora_plus/autoloads/PPQuestUtils.gd'

var test_quests: Dictionary = {}
var test_items: Dictionary = {}
var test_npcs: Dictionary = {}
var test_inventory: PPInventory

func before_test() -> void:
	test_inventory = PPInventory.new()

	# Create test categories
	var quests_category := Pandora.get_category(PandoraCategories.QUESTS)
	var items_category := Pandora.get_category(PandoraCategories.ITEMS)

	# Create test items for rewards and objectives
	var test_sword := Pandora.create_entity("GDUNIT_TEST_SWORD", items_category).instantiate() as PPItemEntity
	test_sword.set_string("name", "Test Sword")
	test_sword.set_bool("stackable", false)
	test_items["sword"] = test_sword

	var test_potion := Pandora.create_entity("GDUNIT_TEST_POTION", items_category).instantiate() as PPItemEntity
	test_potion.set_string("name", "Test Potion")
	test_potion.set_bool("stackable", true)
	test_items["potion"] = test_potion

	# Create a simple quest entity
	var simple_quest_entity := Pandora.create_entity("GDUNIT_SIMPLE_QUEST", quests_category).instantiate() as PPQuestEntity
	var simple_quest_data := PPQuest.new()
	simple_quest_data.set_quest_id("quest_simple")
	simple_quest_data.set_quest_name("Simple Test Quest")
	simple_quest_data.set_description("A simple quest for testing")
	simple_quest_data.set_quest_type(PPQuest.QuestType.SIDE_QUEST)
	simple_quest_data.set_auto_complete(false)  # Set to false to test quest_ready_to_complete signal

	# Add a simple objective
	var objective1 := PPQuestObjective.new(
		"collect_potions",  # objective_id
		PPObjectiveEntity.ObjectiveType.COLLECT,  # objective_type
		"Collect 5 potions",  # description
		PandoraReference.new(test_potion.get_entity_id(), PandoraReference.Type.ENTITY),  # target_reference
		5,  # target_quantity
		false  # optional (false = required)
	)
	simple_quest_data.add_objective(objective1)

	# Add a reward
	var reward1 := PPQuestReward.new()
	reward1.set_reward_name("Test Sword Reward")
	reward1.set_reward_type(PPQuestReward.RewardType.ITEM)
	reward1.set_reward_entity_reference(PandoraReference.new(test_sword.get_entity_id(), PandoraReference.Type.ENTITY))
	reward1.set_quantity(1)
	simple_quest_data.add_reward(reward1)

	simple_quest_entity.get_entity_property("quest_data").set_default_value(simple_quest_data)
	test_quests["simple"] = simple_quest_entity

	# Create a quest with prerequisites
	var prereq_quest_entity := Pandora.create_entity("GDUNIT_PREREQ_QUEST", quests_category).instantiate() as PPQuestEntity
	var prereq_quest_data := PPQuest.new()
	prereq_quest_data.set_quest_id("quest_prereq")
	prereq_quest_data.set_quest_name("Quest With Prerequisites")
	prereq_quest_data.set_description("Requires completing simple quest")
	prereq_quest_data.add_prerequisite(PandoraReference.new(simple_quest_entity.get_entity_id(), PandoraReference.Type.ENTITY))

	prereq_quest_entity.get_entity_property("quest_data").set_default_value(prereq_quest_data)
	test_quests["prereq"] = prereq_quest_entity

	# Create a quest with currency rewards
	var reward_quest_entity := Pandora.create_entity("GDUNIT_REWARD_QUEST", quests_category).instantiate() as PPQuestEntity
	var reward_quest_data := PPQuest.new()
	reward_quest_data.set_quest_id("quest_rewards")
	reward_quest_data.set_quest_name("Quest With Various Rewards")

	var currency_reward := PPQuestReward.new()
	currency_reward.set_reward_name("Currency Reward")
	currency_reward.set_reward_type(PPQuestReward.RewardType.CURRENCY)
	currency_reward.set_currency_amount(50)
	reward_quest_data.add_reward(currency_reward)

	var item_reward := PPQuestReward.new()
	item_reward.set_reward_name("Item Reward")
	item_reward.set_reward_type(PPQuestReward.RewardType.ITEM)
	item_reward.set_reward_entity_reference(PandoraReference.new(test_potion.get_entity_id(), PandoraReference.Type.ENTITY))
	item_reward.set_quantity(3)
	reward_quest_data.add_reward(item_reward)

	reward_quest_entity.get_entity_property("quest_data").set_default_value(reward_quest_data)
	test_quests["rewards"] = reward_quest_entity

	Pandora.save_data()

func after_test() -> void:
	# Clean up created entities
	var quests_category := Pandora.get_category(PandoraCategories.QUESTS)
	var items_category := Pandora.get_category(PandoraCategories.ITEMS)

	for quest_name in ["GDUNIT_SIMPLE_QUEST", "GDUNIT_PREREQ_QUEST", "GDUNIT_REWARD_QUEST"]:
		var to_delete := Pandora.get_all_entities(quests_category).filter(
			func(e: PandoraEntity): return e.get_entity_name() == quest_name)
		if to_delete.size() > 0:
			Pandora.delete_entity(to_delete[0])

	for item_name in ["GDUNIT_TEST_SWORD", "GDUNIT_TEST_POTION"]:
		var to_delete := Pandora.get_all_entities(items_category).filter(
			func(e: PandoraEntity): return e.get_entity_name() == item_name)
		if to_delete.size() > 0:
			Pandora.delete_entity(to_delete[0])

	Pandora.save_data()
	test_quests.clear()
	test_items.clear()

# ============================================================================
# TEST: Quest Lifecycle - start_quest
# ============================================================================

func test_start_quest_success() -> void:
	var quest_entity = test_quests["simple"] as PPQuestEntity
	var runtime_quest = PPQuestUtils.start_quest(quest_entity, [])

	assert_that(runtime_quest).is_not_null()
	assert_that(runtime_quest.is_active()).is_true()
	assert_that(runtime_quest.get_quest_id()).is_equal("quest_simple")

func test_start_quest_missing_prerequisites() -> void:
	var quest_entity = test_quests["prereq"] as PPQuestEntity
	var runtime_quest = PPQuestUtils.start_quest(quest_entity, [])  # No completed quests

	assert_that(runtime_quest).is_null()

func test_start_quest_with_prerequisites_met() -> void:
	var quest_entity = test_quests["prereq"] as PPQuestEntity
	var runtime_quest = PPQuestUtils.start_quest(quest_entity, ["quest_simple"])

	assert_that(runtime_quest).is_not_null()
	assert_that(runtime_quest.is_active()).is_true()

func test_start_quest_emits_signal() -> void:
	var quest_entity = test_quests["simple"] as PPQuestEntity

	var signal_received := []
	var signal_handler = func(quest): signal_received.append(quest)

	PPQuestUtils.quest_started.connect(signal_handler)
	PPQuestUtils.start_quest(quest_entity, [])
	PPQuestUtils.quest_started.disconnect(signal_handler)

	assert_that(signal_received.size()).is_equal(1)
	assert_that(signal_received[0].get_quest_id()).is_equal("quest_simple")

func test_start_quest_from_data() -> void:
	var quest_entity = test_quests["simple"] as PPQuestEntity
	var quest_data = quest_entity.get_quest_data()

	var runtime_quest = PPQuestUtils.start_quest_from_data(quest_data, [])

	assert_that(runtime_quest).is_not_null()
	assert_that(runtime_quest.is_active()).is_true()

# ============================================================================
# TEST: Validation - can_start_quest
# ============================================================================

func test_can_start_quest_valid() -> void:
	var quest_entity = test_quests["simple"] as PPQuestEntity
	var quest_data = quest_entity.get_quest_data()

	var can_start = PPQuestUtils.can_start_quest(quest_data, [])

	assert_that(can_start).is_true()

# ============================================================================
# TEST: Validation - check_prerequisites
# ============================================================================

func test_check_prerequisites_no_prereqs() -> void:
	var quest_entity = test_quests["simple"] as PPQuestEntity
	var quest_data = quest_entity.get_quest_data()

	var has_prereqs = PPQuestUtils.check_prerequisites(quest_data, [])

	assert_that(has_prereqs).is_true()

func test_check_prerequisites_with_prereqs() -> void:
	var quest_entity = test_quests["prereq"] as PPQuestEntity
	var quest_data = quest_entity.get_quest_data()

	assert_that(PPQuestUtils.check_prerequisites(quest_data, [])).is_false()
	assert_that(PPQuestUtils.check_prerequisites(quest_data, ["quest_simple"])).is_true()
	assert_that(PPQuestUtils.check_prerequisites(quest_data, ["other_quest"])).is_false()

# ============================================================================
# TEST: Validation - can_complete_quest
# ============================================================================

func test_can_complete_quest_no_objectives_completed() -> void:
	var quest_entity = test_quests["simple"] as PPQuestEntity
	var runtime_quest = PPQuestUtils.start_quest(quest_entity, [])

	var can_complete = PPQuestUtils.can_complete_quest(runtime_quest)

	assert_that(can_complete).is_false()

func test_can_complete_quest_objectives_completed() -> void:
	var quest_entity = test_quests["simple"] as PPQuestEntity
	var runtime_quest = PPQuestUtils.start_quest(quest_entity, [])

	# Complete all objectives manually
	for obj in runtime_quest.get_runtime_objectives():
		obj.complete()

	var can_complete = PPQuestUtils.can_complete_quest(runtime_quest)

	assert_that(can_complete).is_true()

# ============================================================================
# TEST: Objective Tracking - track_item_collected
# ============================================================================

func test_track_item_collected() -> void:
	var quest_entity = test_quests["simple"] as PPQuestEntity
	var runtime_quest = PPQuestUtils.start_quest(quest_entity, [])
	var potion = test_items["potion"] as PPItemEntity

	# Track collecting 3 potions
	PPQuestUtils.track_item_collected(runtime_quest, potion, 3)

	var objectives = runtime_quest.get_runtime_objectives()
	assert_that(objectives[0].get_current_progress()).is_equal(3)

func test_track_item_collected_emits_signal() -> void:
	var quest_entity = test_quests["simple"] as PPQuestEntity
	var runtime_quest = PPQuestUtils.start_quest(quest_entity, [])
	var potion = test_items["potion"] as PPItemEntity

	var signal_received := []
	PPQuestUtils.quest_objective_progressed.connect(
		func(qid, idx, prog, targ): signal_received.append([qid, idx, prog, targ])
	)

	PPQuestUtils.track_item_collected(runtime_quest, potion, 2)

	PPQuestUtils.quest_objective_progressed.disconnect(
		PPQuestUtils.quest_objective_progressed.get_connections()[0]["callable"]
	)

	assert_that(signal_received.size()).is_equal(1)
	assert_that(signal_received[0][2]).is_equal(2)  # Progress = 2

func test_track_item_collected_quest_ready_to_complete() -> void:
	var potion = test_items["potion"] as PPItemEntity

	# Create a local quest with auto_complete = false
	var local_quest_data := PPQuest.new()
	local_quest_data.set_quest_id("quest_ready_test")
	local_quest_data.set_quest_name("Ready Test Quest")
	local_quest_data.set_auto_complete(false)  # CRITICAL: Must be false

	# Add objective
	var objective := PPQuestObjective.new(
		"collect_potions",
		PPObjectiveEntity.ObjectiveType.COLLECT,
		"Collect 5 potions",
		PandoraReference.new(potion.get_entity_id(), PandoraReference.Type.ENTITY),
		5,
		false  # not optional = required
	)
	local_quest_data.add_objective(objective)

	# Start quest directly from data (bypasses entity serialization)
	var runtime_quest = PPQuestUtils.start_quest_from_data(local_quest_data, [])

	var ready_signals := []
	PPQuestUtils.quest_ready_to_complete.connect(func(qid): ready_signals.append(qid))

	# Complete the objective (5 potions)
	PPQuestUtils.track_item_collected(runtime_quest, potion, 5)

	PPQuestUtils.quest_ready_to_complete.disconnect(
		PPQuestUtils.quest_ready_to_complete.get_connections()[0]["callable"]
	)

	assert_that(ready_signals.size()).is_equal(1)

# ============================================================================
# TEST: Reward Management - grant_reward
# ============================================================================

func test_grant_reward_item() -> void:
	var quest_entity = test_quests["rewards"] as PPQuestEntity
	var quest_data = quest_entity.get_quest_data()
	var item_reward = quest_data.get_rewards()[1]  # Item reward (potion x3)

	var success = PPQuestUtils.grant_reward(item_reward, test_inventory, "quest_rewards")

	assert_that(success).is_true()
	assert_that(test_inventory.has_item(test_items["potion"])).is_true()

func test_grant_reward_item_without_inventory() -> void:
	var quest_entity = test_quests["rewards"] as PPQuestEntity
	var quest_data = quest_entity.get_quest_data()
	var item_reward = quest_data.get_rewards()[1]

	var success = PPQuestUtils.grant_reward(item_reward, null, "quest_rewards")

	assert_that(success).is_false()

func test_grant_reward_currency() -> void:
	var quest_entity = test_quests["rewards"] as PPQuestEntity
	var quest_data = quest_entity.get_quest_data()
	var currency_reward = quest_data.get_rewards()[1]

	var success = PPQuestUtils.grant_reward(currency_reward, test_inventory, "quest_rewards")

	assert_that(success).is_true()

# ============================================================================
# TEST: Reward Management - grant_quest_rewards
# ============================================================================

func test_grant_quest_rewards() -> void:
	var quest_entity = test_quests["rewards"] as PPQuestEntity
	var quest_data = quest_entity.get_quest_data()

	var granted = PPQuestUtils.grant_quest_rewards(quest_data, test_inventory)

	assert_that(granted.size()).is_equal(2)
	assert_that(test_inventory.has_item(test_items["potion"])).is_true()

func test_grant_quest_rewards_emits_signal() -> void:
	var quest_entity = test_quests["rewards"] as PPQuestEntity
	var quest_data = quest_entity.get_quest_data()

	var signal_received := []
	PPQuestUtils.rewards_granted.connect(func(qid, rewards): signal_received.append([qid, rewards]))

	PPQuestUtils.grant_quest_rewards(quest_data, test_inventory)

	PPQuestUtils.rewards_granted.disconnect(PPQuestUtils.rewards_granted.get_connections()[0]["callable"])

	assert_that(signal_received.size()).is_equal(1)
	assert_that(signal_received[0][1].size()).is_equal(2)

# ============================================================================
# TEST: Reward Management - calculate functions
# ============================================================================

func test_calculate_total_currency() -> void:
	var quest_entity = test_quests["rewards"] as PPQuestEntity
	var quest_data = quest_entity.get_quest_data()

	var total_currency = PPQuestUtils.calculate_total_currency(quest_data)

	assert_that(total_currency).is_equal(50)

func test_get_item_rewards() -> void:
	var quest_entity = test_quests["rewards"] as PPQuestEntity
	var quest_data = quest_entity.get_quest_data()

	var item_rewards = PPQuestUtils.get_item_rewards(quest_data)

	assert_that(item_rewards.size()).is_equal(1)
	assert_that(item_rewards[0]["quantity"]).is_equal(3)

# ============================================================================
# TEST: Filtering - get_available_quests
# ============================================================================

func test_get_available_quests() -> void:
	var all_quests = [
		test_quests["simple"],
		test_quests["prereq"]
	]

	var available = PPQuestUtils.get_available_quests(all_quests, [])

	assert_that(available.size()).is_equal(1)
	assert_that(available[0].get_quest_id()).is_equal("quest_simple")

# ============================================================================
# TEST: Filtering - get_active_quests and get_completed_quests
# ============================================================================

func test_get_active_quests() -> void:
	var quest1 = PPQuestUtils.start_quest(test_quests["simple"], [])
	var quest2 = PPQuestUtils.start_quest(test_quests["rewards"], [])

	var all_runtime_quests: Array[PPRuntimeQuest] = [quest1, quest2]
	var active = PPQuestUtils.get_active_quests(all_runtime_quests)

	assert_that(active.size()).is_equal(2)

func test_get_completed_quests() -> void:
	var quest1 = PPQuestUtils.start_quest(test_quests["simple"], [])
	quest1.complete()

	var quest2 = PPQuestUtils.start_quest(test_quests["rewards"], [])

	var all_runtime_quests: Array[PPRuntimeQuest] = [quest1, quest2]
	var completed = PPQuestUtils.get_completed_quests(all_runtime_quests)

	assert_that(completed.size()).is_equal(1)
	assert_that(completed[0].get_quest_id()).is_equal("quest_simple")

# ============================================================================
# TEST: Sorting - sort_quests
# ============================================================================

func test_sort_quests_by_name() -> void:
	var quest1 = PPQuestUtils.start_quest(test_quests["simple"], [])
	var quest2 = PPQuestUtils.start_quest(test_quests["rewards"], [])

	var quests: Array[PPRuntimeQuest] = [quest2, quest1]  # Unsorted
	PPQuestUtils.sort_quests(quests, "name")

	assert_that(quests[0].get_quest_name()).is_equal("Quest With Various Rewards")
	assert_that(quests[1].get_quest_name()).is_equal("Simple Test Quest")

# ============================================================================
# TEST: Statistics - calculate_quest_stats
# ============================================================================

func test_calculate_quest_stats_empty() -> void:
	var completed: Array[PPRuntimeQuest] = []
	var stats = PPQuestUtils.calculate_quest_stats(completed)

	assert_that(stats["total_quests"]).is_equal(0)

func test_calculate_quest_stats() -> void:
	var quest1 = PPQuestUtils.start_quest(test_quests["simple"], [])
	quest1.complete()

	var quest2 = PPQuestUtils.start_quest(test_quests["rewards"], [])
	quest2.complete()

	var completed: Array[PPRuntimeQuest] = [quest1, quest2]
	var stats = PPQuestUtils.calculate_quest_stats(completed)

	assert_that(stats["total_quests"]).is_equal(2)
	assert_that(stats["total_currency"]).is_equal(50)

func test_get_most_completed_quest_type() -> void:
	var quest1 = PPQuestUtils.start_quest(test_quests["simple"], [])
	quest1.complete()

	var quest2 = PPQuestUtils.start_quest(test_quests["rewards"], [])
	quest2.complete()

	var completed: Array[PPRuntimeQuest] = [quest1, quest2]
	var most_type = PPQuestUtils.get_most_completed_quest_type(completed)

	# Should return a valid quest type
	assert_that(most_type).is_not_equal(-1)
