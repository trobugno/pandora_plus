extends Resource
class_name PPGameState

## Game State Container
## Aggregates all runtime game data for saving/loading
##
## Contains:
## - Player data (stats, inventory, position, etc.)
## - Active quests with progress
## - Completed quest IDs
## - Spawned NPCs with their states
## - World time and flags
## - Total playtime
##
## This class serves as the main container for all persistent game state.
## Each subsystem (quests, NPCs, etc.) should have its own serialization,
## and this class aggregates them all into a single save file.

# ============================================================================
# PLAYER DATA
# ============================================================================

## Player-specific data (stats, inventory, position, etc.)
## Type: PPPlayerData (will be implemented)
var player_data: Variant = null

# ============================================================================
# QUEST SYSTEM
# ============================================================================

## Array of active quests serialized to dictionaries
## Each entry is a PPRuntimeQuest.to_dict() result
@export var active_quests: Array = []

## Array of completed quests serialized to dictionaries
## Each entry is a PPRuntimeQuest.to_dict() result
@export var completed_quests: Array = []

## Array of failed quests serialized to dictionaries
## Each entry is a PPRuntimeQuest.to_dict() result
@export var failed_quests: Array = []

## Array of completed quest IDs
@export var completed_quest_ids: Array[String] = []

## Array of failed quest IDs
@export var failed_quest_ids: Array[String] = []

# ============================================================================
# NPC SYSTEM
# ============================================================================

## Array of spawned NPCs serialized to dictionaries
## Each entry is a PPRuntimeNPC.to_dict() result
@export var spawned_npcs: Array = []

# ============================================================================
# WORLD STATE
# ============================================================================

## Current world time in seconds (for time-based systems like NPC schedules)
@export var world_time: float = 0.0

## Current game hour (0-23, for schedule system)
@export var current_hour: int = 12

## Current game day
@export var current_day: int = 1

## Generic flags dictionary for custom events and states
## Example: {"dragon_defeated": true, "town_saved": true}
@export var world_flags: Dictionary = {}

# ============================================================================
# GAME META
# ============================================================================

## Total playtime in seconds
@export var playtime: float = 0.0

## Game difficulty setting
@export var difficulty: String = "normal"

## Custom metadata (for mod support or game-specific data)
@export var custom_data: Dictionary = {}

# ============================================================================
# INITIALIZATION
# ============================================================================

func _init() -> void:
	# Initialize with defaults
	player_data = null
	active_quests = []
	completed_quest_ids = []
	failed_quest_ids = []
	spawned_npcs = []
	world_time = 0.0
	current_hour = 12
	current_day = 1
	world_flags = {}
	playtime = 0.0
	difficulty = "normal"
	custom_data = {}

# ============================================================================
# SERIALIZATION
# ============================================================================

## Serializes the entire game state to a dictionary
## @return Dictionary: Complete game state data
func to_dict() -> Dictionary:
	var data = {
		"player_data": _serialize_player_data(player_data),
		"quests": {
			"active": active_quests,
			"completed": completed_quests,
			"failed": failed_quests,
			"completed_ids": completed_quest_ids,
			"failed_ids": failed_quest_ids
		},
		"npcs": spawned_npcs,
		"world": {
			"time": world_time,
			"current_hour": current_hour,
			"current_day": current_day,
			"flags": world_flags
		},
		"meta": {
			"playtime": playtime,
			"difficulty": difficulty,
			"custom_data": custom_data
		}
	}

	return data

## Creates a GameState instance from a dictionary
## @param data: Dictionary with game state data
## @return PPGameState: Restored game state
static func from_dict(data: Dictionary) -> PPGameState:
	var state = PPGameState.new()

	# Restore player data
	if data.has("player_data"):
		state.player_data = _deserialize_player_data(data["player_data"])

	# Restore quests
	if data.has("quests"):
		var quests_data = data["quests"]
		state.active_quests = quests_data.get("active", [])
		state.completed_quests = quests_data.get("completed", [])
		state.failed_quests = quests_data.get("failed", [])
		state.completed_quest_ids.assign(quests_data.get("completed_ids", []))
		state.failed_quest_ids.assign(quests_data.get("failed_ids", []))

	# Restore NPCs
	if data.has("npcs"):
		state.spawned_npcs = data["npcs"]

	# Restore world state
	if data.has("world"):
		var world_data = data["world"]
		state.world_time = world_data.get("time", 0.0)
		state.current_hour = world_data.get("current_hour", 12)
		state.current_day = world_data.get("current_day", 1)
		state.world_flags = world_data.get("flags", {})

	# Restore meta
	if data.has("meta"):
		var meta_data = data["meta"]
		state.playtime = meta_data.get("playtime", 0.0)
		state.difficulty = meta_data.get("difficulty", "normal")
		state.custom_data = meta_data.get("custom_data", {})

	return state

# ============================================================================
# HELPER METHODS - Quest Management
# ============================================================================

## Adds an active quest to the state
## @param runtime_quest: PPRuntimeQuest instance
func add_active_quest(runtime_quest) -> void:
	active_quests.append(runtime_quest.to_dict())

## Marks a quest as completed
## @param quest_id: Quest identifier
func complete_quest(quest_id: String) -> void:
	# Remove from active quests
	active_quests = active_quests.filter(func(q): return q.get("quest_id") != quest_id)

	# Add to completed if not already there
	if quest_id not in completed_quest_ids:
		completed_quest_ids.append(quest_id)

## Marks a quest as failed
## @param quest_id: Quest identifier
func fail_quest(quest_id: String) -> void:
	# Remove from active quests
	active_quests = active_quests.filter(func(q): return q.get("quest_id") != quest_id)

	# Add to failed if not already there
	if quest_id not in failed_quest_ids:
		failed_quest_ids.append(quest_id)

## Checks if a quest is completed
## @param quest_id: Quest identifier
## @return bool: True if quest is completed
func is_quest_completed(quest_id: String) -> bool:
	return quest_id in completed_quest_ids

## Checks if a quest is failed
## @param quest_id: Quest identifier
## @return bool: True if quest is failed
func is_quest_failed(quest_id: String) -> bool:
	return quest_id in failed_quest_ids

## Checks if a quest is active
## @param quest_id: Quest identifier
## @return bool: True if quest is active
func is_quest_active(quest_id: String) -> bool:
	for quest in active_quests:
		if quest.get("quest_id") == quest_id:
			return true
	return false

# ============================================================================
# HELPER METHODS - NPC Management
# ============================================================================

## Adds a spawned NPC to the state
## @param runtime_npc: PPRuntimeNPC instance
func add_spawned_npc(runtime_npc) -> void:
	spawned_npcs.append(runtime_npc.to_dict())

## Removes a spawned NPC from the state
## @param npc_id: NPC entity identifier
func remove_spawned_npc(npc_id: String) -> void:
	spawned_npcs = spawned_npcs.filter(func(npc): return npc.get("npc_data", {}).get("entity_id") != npc_id)

## Gets NPC data by ID
## @param npc_id: NPC entity identifier
## @return Dictionary: NPC data or empty dict if not found
func get_npc_data(npc_id: String) -> Dictionary:
	for npc in spawned_npcs:
		if npc.get("npc_data", {}).get("entity_id") == npc_id:
			return npc
	return {}

# ============================================================================
# HELPER METHODS - World Flags
# ============================================================================

## Sets a world flag
## @param flag_name: Flag identifier
## @param value: Flag value (any type)
func set_flag(flag_name: String, value: Variant) -> void:
	world_flags[flag_name] = value

## Gets a world flag value
## @param flag_name: Flag identifier
## @param default_value: Default value if flag doesn't exist
## @return Variant: Flag value or default
func get_flag(flag_name: String, default_value: Variant = false) -> Variant:
	return world_flags.get(flag_name, default_value)

## Checks if a world flag exists
## @param flag_name: Flag identifier
## @return bool: True if flag exists
func has_flag(flag_name: String) -> bool:
	return flag_name in world_flags

## Removes a world flag
## @param flag_name: Flag identifier
func remove_flag(flag_name: String) -> void:
	world_flags.erase(flag_name)

# ============================================================================
# INTERNAL - Player Data Serialization
# ============================================================================

static func _serialize_player_data(player_data: Variant) -> Dictionary:
	if player_data == null:
		return {}

	if player_data is PPPlayerData:
		return player_data.to_dict()

	# Fallback for custom player data implementations
	if player_data.has_method("to_dict"):
		return player_data.to_dict()

	push_warning("Player data does not implement to_dict()")
	return {}

static func _deserialize_player_data(data: Dictionary):
	if data.is_empty():
		return null

	return PPPlayerData.from_dict(data)

# ============================================================================
# UTILITY METHODS
# ============================================================================

## Gets a human-readable summary of the game state
## @return String: Summary text
func get_summary() -> String:
	var summary = "Game State Summary:\n"
	summary += "  Playtime: %.1f hours\n" % (playtime / 3600.0)
	summary += "  Active Quests: %d\n" % active_quests.size()
	summary += "  Completed Quests: %d\n" % completed_quest_ids.size()
	summary += "  Failed Quests: %d\n" % failed_quest_ids.size()
	summary += "  Spawned NPCs: %d\n" % spawned_npcs.size()
	summary += "  World Day: %d, Hour: %d\n" % [current_day, current_hour]
	summary += "  World Flags: %d\n" % world_flags.size()
	summary += "  Difficulty: %s\n" % difficulty
	return summary

## Clears all game state (use for new game)
func clear() -> void:
	player_data = null
	active_quests.clear()
	completed_quest_ids.clear()
	failed_quest_ids.clear()
	spawned_npcs.clear()
	world_time = 0.0
	current_hour = 12
	current_day = 1
	world_flags.clear()
	playtime = 0.0
	difficulty = "normal"
	custom_data.clear()
