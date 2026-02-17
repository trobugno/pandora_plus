extends Node

## NPC Utilities Manager (Autoload)
## Provides comprehensive utilities for NPC management including:
## - Lifecycle management (spawn, despawn, location tracking)
## - Combat operations (damage, healing, death)
## - Quest integration (quest givers, validation)
## - Filtering, sorting, statistics, and debug tools

# ============================================================================
# SIGNALS
# ============================================================================

## Combat signals
signal npc_died(npc: PPRuntimeNPC)
signal npc_revived(npc: PPRuntimeNPC)

## Quest signals
signal npc_has_quest_available(npc: PPRuntimeNPC, quest_count: int)

# ============================================================================
# NPC LIFECYCLE & MANAGEMENT
# ============================================================================

## Creates runtime instance from entity
func spawn_npc(npc_entity: PPNPCEntity) -> PPRuntimeNPC:
	if not npc_entity:
		push_error("Cannot spawn NPC: entity is null")
		return null

	var runtime_npc = PPRuntimeNPC.new(npc_entity)
	return runtime_npc

## Despawns NPC (cleanup)
func despawn_npc(runtime_npc: PPRuntimeNPC) -> void:
	if not runtime_npc:
		return
	# Cleanup would happen here (remove from scene, etc.)
	# This is mainly for symmetry with spawn_npc

## Finds NPCs at specific location
func get_npcs_at_location(npcs: Array, location_ref: PandoraReference) -> Array:
	if not location_ref:
		return []

	return npcs.filter(func(npc: PPRuntimeNPC):
		var current_loc = npc.get_current_location()
		return current_loc and current_loc.get_id() == location_ref.get_id()
	)

## Finds NPC by entity ID
func find_npc_by_id(npcs: Array, npc_id: String) -> PPRuntimeNPC:
	for npc in npcs:
		if npc is PPRuntimeNPC and npc.npc_data.get("entity_id") == npc_id:
			return npc
	return null

## Finds NPC by name
func find_npc_by_name(npcs: Array, npc_name: String) -> PPRuntimeNPC:
	for npc in npcs:
		if npc is PPRuntimeNPC and npc.npc_data.get("name") == npc_name:
			return npc
	return null

# ============================================================================
# COMBAT OPERATIONS
# ============================================================================

## Applies damage to NPC
func damage_npc(runtime_npc: PPRuntimeNPC, amount: float, source: String = "unknown") -> void:
	if not runtime_npc:
		push_error("Cannot damage NPC: runtime_npc is null")
		return

	runtime_npc.take_damage(amount, source)

## Heals NPC
func heal_npc(runtime_npc: PPRuntimeNPC, amount: float) -> void:
	if not runtime_npc:
		push_error("Cannot heal NPC: runtime_npc is null")
		return

	runtime_npc.heal(amount)

## Kills NPC immediately
func kill_npc(runtime_npc: PPRuntimeNPC) -> void:
	if not runtime_npc:
		push_error("Cannot kill NPC: runtime_npc is null")
		return

	runtime_npc.die()
	npc_died.emit(runtime_npc)

## Revives NPC with specified health percentage
func revive_npc(runtime_npc: PPRuntimeNPC, health_percentage: float = 1.0) -> void:
	if not runtime_npc:
		push_error("Cannot revive NPC: runtime_npc is null")
		return

	runtime_npc.revive(health_percentage)
	npc_revived.emit(runtime_npc)

## Checks if NPC can engage in combat (only hostile NPCs)
func can_engage_combat(runtime_npc: PPRuntimeNPC) -> bool:
	if not runtime_npc or not runtime_npc.is_alive():
		return false

	# Only hostile NPCs can engage in combat
	return runtime_npc.npc_data.get("is_hostile", false)

## Checks if player can interact with NPC
func can_interact_with_npc(runtime_npc: PPRuntimeNPC) -> bool:
	if not runtime_npc or not runtime_npc.is_alive():
		return false

	# Can't interact with hostile NPCs (combat only)
	if runtime_npc.npc_data.get("is_hostile", false):
		return false

	return true

# ============================================================================
# QUEST INTEGRATION
# ============================================================================

## Gets available quests from NPC
func get_available_quests_from_npc(
	runtime_npc: PPRuntimeNPC,
	completed_quest_ids: Array
) -> Array:
	if not runtime_npc:
		return []

	return runtime_npc.get_available_quests(completed_quest_ids)

## Gets all quest givers from NPC list
func get_quest_givers(npcs: Array) -> Array:
	return npcs.filter(func(npc: PPRuntimeNPC):
		return npc.is_quest_giver()
	)

## Checks if NPC has available quests
func has_available_quests(runtime_npc: PPRuntimeNPC, completed_quest_ids: Array) -> bool:
	if not runtime_npc:
		return false

	var quests = get_available_quests_from_npc(runtime_npc, completed_quest_ids)
	var has_quests = not quests.is_empty()

	if has_quests:
		npc_has_quest_available.emit(runtime_npc, quests.size())

	return has_quests

## Tracks NPC interaction for quest objectives
func track_npc_interaction(active_quests: Array, npc_entity: PPNPCEntity) -> void:
	if not npc_entity:
		return

	# Delegate to PPQuestUtils for tracking
	for quest in active_quests:
		if quest is PPRuntimeQuest:
			PPQuestUtils.track_npc_talked(quest, npc_entity)

## Validates that NPC can give specific quest
func validate_quest_giver(quest: PPQuestEntity, npc: PPNPCEntity) -> bool:
	if not quest or not npc:
		return false

	var quest_givers = npc.get_quest_giver_for()
	for quest_ref in quest_givers:
		if quest_ref is PandoraReference and quest_ref.get_id() == quest.get_entity_id():
			return true

	return false

## Checks if quest can be started from NPC
func can_start_quest_at_time(
	quest: PPQuestEntity,
	npc: PPRuntimeNPC,
	current_hour: int
) -> bool:
	# Verify NPC is quest giver
	if not npc._npc_entity or not validate_quest_giver(quest, npc._npc_entity):
		return false

	# Can't get quests from dead NPCs
	if not npc.is_alive():
		return false

	# Hostile NPCs don't give quests
	if not can_interact_with_npc(npc):
		return false

	return true

# ============================================================================
# FILTERING & SORTING
# ============================================================================

## Filters NPCs by faction
func filter_by_faction(npcs: Array, faction: String) -> Array:
	return npcs.filter(func(npc: PPRuntimeNPC):
		return npc.npc_data.get("faction") == faction
	)

## Gets alive NPCs
func get_alive_npcs(npcs: Array) -> Array:
	return npcs.filter(func(npc: PPRuntimeNPC):
		return npc.is_alive()
	)

## Gets dead NPCs
func get_dead_npcs(npcs: Array) -> Array:
	return npcs.filter(func(npc: PPRuntimeNPC):
		return not npc.is_alive()
	)

## Gets hostile NPCs
func get_hostile_npcs(npcs: Array) -> Array:
	return npcs.filter(func(npc: PPRuntimeNPC):
		return npc.npc_data.get("is_hostile", false)
	)

## Sorts NPCs
func sort_npcs(npcs: Array, sort_by: String) -> Array:
	var sorted = npcs.duplicate()

	match sort_by:
		"name":
			sorted.sort_custom(func(a: PPRuntimeNPC, b: PPRuntimeNPC):
				return a.npc_data.get("name", "") < b.npc_data.get("name", "")
			)
		"health":
			sorted.sort_custom(func(a: PPRuntimeNPC, b: PPRuntimeNPC):
				return a.get_current_health() > b.get_current_health()
			)
		"faction":
			sorted.sort_custom(func(a: PPRuntimeNPC, b: PPRuntimeNPC):
				return a.npc_data.get("faction", "") < b.npc_data.get("faction", "")
			)

	return sorted

# ============================================================================
# STATISTICS & ANALYTICS
# ============================================================================

## Calculates NPC statistics
func calculate_npc_stats(npcs: Array) -> Dictionary:
	var stats = {
		"total_npcs": npcs.size(),
		"alive_count": 0,
		"dead_count": 0,
		"faction_distribution": {},
		"hostile_count": 0,
		"quest_giver_count": 0
	}

	if npcs.is_empty():
		return stats

	for npc in npcs:
		if npc is PPRuntimeNPC:
			# Count alive/dead
			if npc.is_alive():
				stats["alive_count"] += 1
			else:
				stats["dead_count"] += 1

			# Faction distribution
			var faction = npc.npc_data.get("faction", "None")
			if not stats["faction_distribution"].has(faction):
				stats["faction_distribution"][faction] = 0
			stats["faction_distribution"][faction] += 1

			# Hostile count
			if npc.npc_data.get("is_hostile", false):
				stats["hostile_count"] += 1

			# Quest giver count
			if npc.is_quest_giver():
				stats["quest_giver_count"] += 1

	return stats

## Gets most common faction
func get_most_common_faction(npcs: Array) -> String:
	var stats = calculate_npc_stats(npcs)
	var faction_dist = stats["faction_distribution"] as Dictionary

	if faction_dist.is_empty():
		return ""

	var max_count = 0
	var most_common = ""

	for faction in faction_dist:
		var count = faction_dist[faction]
		if count > max_count:
			max_count = count
			most_common = faction

	return most_common

# ============================================================================
# DEBUG UTILITIES
# ============================================================================

## Prints NPC debug info
func debug_print_npc(runtime_npc: PPRuntimeNPC) -> void:
	if not runtime_npc:
		print("NPC is null")
		return

	print("=== NPC Debug Info ===")
	print("Name: ", runtime_npc.npc_data.get("name", "Unknown"))
	print("ID: ", runtime_npc.npc_data.get("entity_id", "Unknown"))
	print("Faction: ", runtime_npc.npc_data.get("faction", "None"))
	print("Alive: ", runtime_npc.is_alive())
	print("Health: ", runtime_npc.get_current_health(), "/", runtime_npc.get_max_health())
	print("Hostile: ", runtime_npc.npc_data.get("is_hostile", false))
	print("Quest Giver: ", runtime_npc.is_quest_giver())
	print("=====================")

## Prints all NPCs
func debug_print_all_npcs(npcs: Array) -> void:
	print("=== All NPCs (", npcs.size(), ") ===")
	for npc in npcs:
		if npc is PPRuntimeNPC:
			print("- ", npc.npc_data.get("name", "Unknown"), " [", npc.npc_data.get("faction", "None"), "] ",
				  "HP:", int(npc.get_current_health()))
	print("=========================")
