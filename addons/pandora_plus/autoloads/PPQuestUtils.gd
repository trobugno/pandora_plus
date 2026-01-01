extends Node

## PPQuestUtils
## Utility autoload for quest management in Pandora+
## Provides helpers for quest validation, reward management, objective tracking, and more

## Signals

# Validation signals
signal quest_validation_failed(quest_id: String, reason: String)
signal quest_validation_passed(quest_id: String)

# Quest lifecycle signals
signal quest_started(runtime_quest: PPRuntimeQuest)
signal quest_objective_progressed(quest_id: String, objective_index: int, progress: int, target: int)
signal quest_ready_to_complete(quest_id: String)

# Reward signals
signal rewards_granted(quest_id: String, rewards: Array)
signal reward_grant_failed(quest_id: String, reward: PPQuestReward, reason: String)

## Quest Lifecycle Management

## Starts a quest from a QuestEntity
## Returns the created PPRuntimeQuest or null if validation fails
func start_quest(quest_entity: PPQuestEntity, completed_quest_ids: Array[String] = []) -> PPRuntimeQuest:
	var quest_data = quest_entity.get_quest_data()
	if not quest_data:
		push_error("Quest entity has no quest data")
		return null

	# Validate quest can be started
	if not can_start_quest(quest_data, completed_quest_ids):
		return null

	# Create runtime quest
	var runtime_quest = PPRuntimeQuest.new(quest_data)
	runtime_quest.start()

	quest_started.emit(runtime_quest)
	return runtime_quest

## Starts a quest from PPQuest data
func start_quest_from_data(quest_data: PPQuest, completed_quest_ids: Array[String] = []) -> PPRuntimeQuest:
	if not can_start_quest(quest_data, completed_quest_ids):
		return null

	var runtime_quest = PPRuntimeQuest.new(quest_data)
	runtime_quest.start()

	quest_started.emit(runtime_quest)
	return runtime_quest

## Validation

## Checks if a quest can be started by the player
func can_start_quest(quest: PPQuest, completed_quest_ids: Array[String] = []) -> bool:
	var quest_id = quest.get_quest_id()

	# Check prerequisites
	if not check_prerequisites(quest, completed_quest_ids):
		quest_validation_failed.emit(quest_id, "Prerequisites not met")
		return false

	quest_validation_passed.emit(quest_id)
	return true

## Checks if all quest prerequisites are met
func check_prerequisites(quest: PPQuest, completed_quest_ids: Array[String]) -> bool:
	var prerequisites = quest.get_prerequisites()

	for prereq in prerequisites:
		if prereq is PandoraReference:
			var prereq_entity = prereq.get_entity() as PPQuestEntity
			if prereq_entity:
				var prereq_id = prereq_entity.get_quest_id()
				if prereq_id not in completed_quest_ids:
					return false
		elif prereq is Dictionary:
			# Handle serialized reference
			var entity = Pandora.get_entity(prereq.get("_entity_id", ""))
			if entity is PPQuestEntity:
				if entity.get_quest_id() not in completed_quest_ids:
					return false

	return true

## Checks if a runtime quest can be completed
func can_complete_quest(runtime_quest: PPRuntimeQuest) -> bool:
	return runtime_quest.are_all_required_objectives_completed()

## Objective Tracking

## Generic method to track progress on any objective type
func track_objective_progress(runtime_quest: PPRuntimeQuest, objective_type: int, entity_id: String, quantity: int = 1) -> void:
	if not runtime_quest or not runtime_quest.is_active():
		return

	var objectives = runtime_quest.get_runtime_objectives()
	for i in range(objectives.size()):
		var runtime_objective = objectives[i]
		var objective_data = runtime_objective.get_quest_objective_instance()

		# Check if objective matches type and target
		if objective_data.get_objective_type() == objective_type:
			var target_ref = objective_data.get_target_reference()

			# Match target entity
			if target_ref and target_ref.get_entity():
				var target_entity_id = target_ref.get_entity().get_entity_id()
				if target_entity_id == entity_id:
					runtime_objective.add_progress(quantity)

					quest_objective_progressed.emit(
						runtime_quest.get_quest_id(),
						i,
						runtime_objective.get_current_progress(),
						objective_data.get_target_quantity()
					)

					# Check if quest is ready to complete
					if runtime_quest.are_all_required_objectives_completed() and not runtime_quest.is_auto_complete():
						quest_ready_to_complete.emit(runtime_quest.get_quest_id())

## Tracks item collection for COLLECT objectives
func track_item_collected(runtime_quest: PPRuntimeQuest, item: PPItemEntity, quantity: int = 1) -> void:
	track_objective_progress(runtime_quest, PPObjectiveEntity.ObjectiveType.COLLECT, item.get_entity_id(), quantity)

## Tracks enemy kills for KILL objectives
func track_enemy_killed(runtime_quest: PPRuntimeQuest, enemy_entity: PandoraEntity) -> void:
	track_objective_progress(runtime_quest, PPObjectiveEntity.ObjectiveType.KILL, enemy_entity.get_entity_id(), 1)

## Tracks NPC dialogue for TALK objectives
func track_npc_talked(runtime_quest: PPRuntimeQuest, npc: PandoraEntity) -> void:
	if not runtime_quest or not runtime_quest.is_active():
		return

	var objectives = runtime_quest.get_runtime_objectives()
	for i in range(objectives.size()):
		var runtime_objective = objectives[i]
		var objective_data = runtime_objective.get_quest_objective_instance()

		# Check for TALK type
		if objective_data.get_objective_type() == PPObjectiveEntity.ObjectiveType.TALK:
			var target_ref = objective_data.get_target_reference()

			if target_ref and target_ref.get_entity():
				if target_ref.get_entity().get_entity_id() == npc.get_entity_id():
					runtime_objective.complete()
					quest_objective_progressed.emit(
						runtime_quest.get_quest_id(),
						i,
						runtime_objective.get_current_progress(),
						objective_data.get_target_quantity()
					)


## Tracks multiple active quests for a specific action
## Useful for tracking objectives across all active quests simultaneously
func track_across_quests(active_quests: Array[PPRuntimeQuest], tracker_func: Callable) -> void:
	for quest in active_quests:
		if quest.is_active():
			tracker_func.call(quest)

## Example: PPQuestUtils.track_across_quests(active_quests, func(q): PPQuestUtils.track_item_collected(q, item, 1))

## Finds all objectives across active quests that track a specific entity
func find_tracking_objectives(active_quests: Array[PPRuntimeQuest], entity_id: String, objective_type: int = -1) -> Array:
	var tracking_objectives = []

	for quest in active_quests:
		if not quest.is_active():
			continue

		var objectives = quest.get_runtime_objectives()
		for i in range(objectives.size()):
			var runtime_objective = objectives[i]
			var objective_data = runtime_objective.get_quest_objective_instance()

			# Filter by type if specified
			if objective_type != -1 and objective_data.get_objective_type() != objective_type:
				continue

			# Check if target matches
			var target_ref = objective_data.get_target_reference()
			if target_ref and target_ref.get_entity():
				if target_ref.get_entity().get_entity_id() == entity_id:
					tracking_objectives.append({
						"quest": quest,
						"objective_index": i,
						"runtime_objective": runtime_objective,
						"objective_data": objective_data
					})

	return tracking_objectives

## Reward Management

## Grants all rewards from a quest
## Returns array of successfully granted reward names
func grant_quest_rewards(quest: PPQuest, inventory: PPInventory = null) -> Array[String]:
	var granted_rewards: Array[String] = []
	var quest_id = quest.get_quest_id()

	for reward in quest.get_rewards():
		if grant_reward(reward, inventory, quest_id):
			granted_rewards.append(reward.get_reward_name())

	if granted_rewards.size() > 0:
		rewards_granted.emit(quest_id, granted_rewards)

	return granted_rewards

## Grants a single reward
func grant_reward(reward: PPQuestReward, inventory: PPInventory = null, quest_id: String = "") -> bool:
	match reward.get_reward_type():
		PPQuestReward.RewardType.ITEM:
			if not inventory:
				reward_grant_failed.emit(quest_id, reward, "No inventory provided for ITEM reward")
				return false

			var item = reward.get_reward_entity() as PPItemEntity
			if not item:
				reward_grant_failed.emit(quest_id, reward, "Invalid item entity")
				return false

			# Check if inventory has space (if max_items_in_inventory is set)
			if inventory.max_items_in_inventory > -1:
				var empty_slots = inventory.all_items.filter(func(s): return s == null).size()
				var existing_stackable = inventory.all_items.filter(
					func(s: PPInventorySlot):
						return s and s.item and s.item._id == item._id and s.quantity < s.MAX_STACK_SIZE
				)
				if empty_slots == 0 and existing_stackable.is_empty():
					reward_grant_failed.emit(quest_id, reward, "Inventory full, cannot add reward")
					return false

			inventory.add_item(item, reward.get_quantity())
			return true

		PPQuestReward.RewardType.CURRENCY:
			# Currency is handled externally, just return true
			# Game should listen to rewards_granted signal and handle currency
			return true

		PPQuestReward.RewardType.EXPERIENCE:
			# Experience is handled externally
			return true

	return false

## Calculates total experience from all rewards
func calculate_total_experience(quest: PPQuest) -> int:
	var total = 0

	for reward in quest.get_rewards():
		if reward is PPQuestReward:
			if reward.get_reward_type() == PPQuestReward.RewardType.EXPERIENCE:
				total += reward.get_experience_amount()

	return total

## Calculates total currency from all rewards
func calculate_total_currency(quest: PPQuest) -> int:
	var total = 0

	for reward in quest.get_rewards():
		if reward is PPQuestReward:
			if reward.get_reward_type() == PPQuestReward.RewardType.CURRENCY:
				total += reward.get_currency_amount()

	return total

## Gets all item rewards from a quest
func get_item_rewards(quest: PPQuest) -> Array[Dictionary]:
	var items: Array[Dictionary] = []

	for reward in quest.get_rewards():
		if reward is PPQuestReward:
			if reward.get_reward_type() == PPQuestReward.RewardType.ITEM:
				var item = reward.get_reward_entity() as PPItemEntity
				if item:
					items.append({
						"item": item,
						"quantity": reward.get_quantity()
					})

	return items

## Filtering & Queries

## Gets all quests available for a player based on completed quests
func get_available_quests(all_quests: Array, completed_quest_ids: Array[String] = []) -> Array:
	var available = []

	for quest_item in all_quests:
		var quest_data: PPQuest = null

		# Handle both QuestEntity and PPQuest
		if quest_item is PPQuestEntity:
			quest_data = quest_item.get_quest_data()
		elif quest_item is PPQuest:
			quest_data = quest_item

		if quest_data and can_start_quest(quest_data, completed_quest_ids):
			available.append(quest_item)

	return available

## Filters quests by category
func get_quests_by_category(quests: Array, category: String) -> Array:
	var filtered = []

	for quest_item in quests:
		var quest_data: PPQuest = null

		if quest_item is PPQuestEntity:
			quest_data = quest_item.get_quest_data()
		elif quest_item is PPQuest:
			quest_data = quest_item
		elif quest_item is PPRuntimeQuest:
			quest_data = PPQuest.new()
			quest_data.load_data(quest_item.quest_data)

		if quest_data and quest_data.get_category() == category:
			filtered.append(quest_item)

	return filtered

## Filters quests by type
func get_quests_by_type(quests: Array, quest_type: int) -> Array:
	var filtered = []

	for quest_item in quests:
		var quest_data: PPQuest = null

		if quest_item is PPQuestEntity:
			quest_data = quest_item.get_quest_data()
		elif quest_item is PPQuest:
			quest_data = quest_item
		elif quest_item is PPRuntimeQuest:
			quest_data = PPQuest.new()
			quest_data.load_data(quest_item.quest_data)

		if quest_data and quest_data.get_quest_type() == quest_type:
			filtered.append(quest_item)

	return filtered

## Gets all active runtime quests from a collection
func get_active_quests(runtime_quests: Array[PPRuntimeQuest]) -> Array[PPRuntimeQuest]:
	var active: Array[PPRuntimeQuest] = []

	for quest in runtime_quests:
		if quest.is_active():
			active.append(quest)

	return active

## Gets all completed runtime quests from a collection
func get_completed_quests(runtime_quests: Array[PPRuntimeQuest]) -> Array[PPRuntimeQuest]:
	var completed: Array[PPRuntimeQuest] = []

	for quest in runtime_quests:
		if quest.is_completed():
			completed.append(quest)

	return completed

## Sorting

## Sorts runtime quests by various criteria
func sort_quests(quests: Array[PPRuntimeQuest], sort_by: String = "name") -> void:
	match sort_by:
		"name":
			quests.sort_custom(_sort_by_name)
		"progress":
			quests.sort_custom(_sort_by_progress)
		"type":
			quests.sort_custom(_sort_by_type)

func _sort_by_name(a: PPRuntimeQuest, b: PPRuntimeQuest) -> bool:
	return a.get_quest_name() < b.get_quest_name()

func _sort_by_progress(a: PPRuntimeQuest, b: PPRuntimeQuest) -> bool:
	return a.get_progress_percentage() > b.get_progress_percentage()

func _sort_by_type(a: PPRuntimeQuest, b: PPRuntimeQuest) -> bool:
	return a.get_quest_type() < b.get_quest_type()

## Statistics & Analytics

## Calculates various statistics about completed quests
func calculate_quest_stats(completed_quests: Array[PPRuntimeQuest]) -> Dictionary:
	var stats = {
		"total_quests": completed_quests.size(),
		"by_type": {},
		"by_category": {},
		"total_experience": 0,
		"total_currency": 0
	}

	if completed_quests.is_empty():
		return stats

	for quest in completed_quests:
		# Type distribution
		var quest_type = quest.get_quest_type()
		if not stats["by_type"].has(quest_type):
			stats["by_type"][quest_type] = 0
		stats["by_type"][quest_type] += 1

		# Category distribution
		var quest_data = PPQuest.new()
		quest_data.load_data(quest.quest_data)
		var category = quest_data.get_category()
		if category:
			if not stats["by_category"].has(category):
				stats["by_category"][category] = 0
			stats["by_category"][category] += 1

		# Experience and currency
		stats["total_experience"] += calculate_total_experience(quest_data)
		stats["total_currency"] += calculate_total_currency(quest_data)

	return stats

## Gets the most completed quest type
func get_most_completed_quest_type(completed_quests: Array[PPRuntimeQuest]) -> int:
	var type_counts = {}

	for quest in completed_quests:
		var quest_type = quest.get_quest_type()
		if not type_counts.has(quest_type):
			type_counts[quest_type] = 0
		type_counts[quest_type] += 1

	var most_type = -1
	var max_count = 0

	for type in type_counts.keys():
		if type_counts[type] > max_count:
			max_count = type_counts[type]
			most_type = type

	return most_type

## NPC Integration

## Validates that an NPC entity can give a specific quest
func validate_quest_giver(quest: PPQuestEntity, npc: PPNPCEntity) -> bool:
	if not quest or not npc:
		return false

	var quest_givers = npc.get_quest_giver_for()
	for quest_ref in quest_givers:
		if quest_ref is PandoraReference and quest_ref.get_id() == quest.get_entity_id():
			return true

	return false

## Checks if a quest can be obtained from an NPC
## Takes into account NPC state
func can_obtain_quest_from_npc(
	quest: PPQuestEntity,
	npc_runtime: PPRuntimeNPC,
	completed_quest_ids: Array[String] = []
) -> bool:
	if not quest or not npc_runtime:
		return false

	# Validate NPC is quest giver for this quest
	if not validate_quest_giver(quest, npc_runtime._npc_entity):
		return false

	# Check if NPC is alive
	if not npc_runtime.is_alive():
		return false

	# Check if player meets quest requirements
	var quest_data = quest.get_quest_data()
	if not quest_data:
		return false

	return can_start_quest(quest_data, completed_quest_ids)

## Gets all NPCs that can give a specific quest
func find_quest_givers_for_quest(npcs: Array, quest: PPQuestEntity) -> Array:
	var quest_givers: Array = []

	for npc in npcs:
		if npc is PPRuntimeNPC:
			if validate_quest_giver(quest, npc._npc_entity):
				quest_givers.append(npc)

	return quest_givers

## Debug Utilities

## Prints detailed information about a runtime quest
func debug_print_quest(runtime_quest: PPRuntimeQuest) -> void:
	print("=== Quest Debug Info ===")
	print("ID: ", runtime_quest.get_quest_id())
	print("Name: ", runtime_quest.get_quest_name())
	print("Status: ", runtime_quest.get_status_string())
	print("Progress: %.2f%%" % runtime_quest.get_progress_percentage())

	print("\nObjectives:")
	var objectives = runtime_quest.get_runtime_objectives()
	for i in range(objectives.size()):
		var obj = objectives[i]
		var obj_data = obj.get_quest_objective_instance()
		print("  [%d] %s - %s (%d/%d)" % [
			i,
			obj_data.get_description(),
			"✓" if obj.is_completed() else "○",
			obj.get_current_progress(),
			obj_data.get_target_quantity()
		])

	print("====================")

## Prints all active quests
func debug_print_active_quests(active_quests: Array[PPRuntimeQuest]) -> void:
	print("=== Active Quests (%d) ===" % active_quests.size())
	for quest in active_quests:
		print("%s - %.2f%%" % [quest.get_quest_name(), quest.get_progress_percentage()])
	print("====================")
