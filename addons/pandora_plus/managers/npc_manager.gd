extends Node

## NPC Manager (Autoload)
## Manages NPC runtime state during gameplay
##
## Responsibilities:
## - Maintains spawned NPCs collection
## - Handles NPC lifecycle (spawn, despawn, death)
## - Integrates with SaveManager
##
## Usage:
##   PPNPCManager.spawn_npc(npc_entity, location)
##   PPNPCManager.find_npc_by_id(entity_id)
##   var npcs_at_location = PPNPCManager.get_npcs_at_location(location_id)

# ============================================================================
# SIGNALS
# ============================================================================

signal npc_spawned(runtime_npc: PPRuntimeNPC)
signal npc_despawned(npc_id: String)
signal npc_died(npc_id: String)
signal npc_revived(npc_id: String)
signal npc_location_changed(npc_id: String, old_location: Variant, new_location: Variant)
signal all_npcs_cleared()

# ============================================================================
# STATE
# ============================================================================

## Spawned NPCs (currently active in the game world)
var _spawned_npcs: Array[PPRuntimeNPC] = []

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	print("NPCManager initialized")

# ============================================================================
# PUBLIC API - NPC Spawning
# ============================================================================

## Spawns an NPC from an entity
## @param npc_entity: PPNPCEntity to spawn
## @param location: Optional spawn location (overrides entity default)
## @return PPRuntimeNPC: Created runtime NPC
func spawn_npc(npc_entity: PPNPCEntity, location: Variant = null) -> PPRuntimeNPC:
	# Check if NPC is already spawned
	var existing = find_npc_by_entity_id(npc_entity.get_entity_id())
	if existing:
		push_warning("NPC already spawned: %s" % npc_entity.get_npc_name())
		return existing

	# Create runtime NPC
	var runtime_npc = PPRuntimeNPC.new(npc_entity)

	# Override location if provided
	if location:
		runtime_npc.set_location(location)

	_add_npc(runtime_npc)
	return runtime_npc

## Adds an existing runtime NPC (used during load)
## @param runtime_npc: PPRuntimeNPC instance
func add_existing_npc(runtime_npc: PPRuntimeNPC) -> void:
	_add_npc(runtime_npc)

## Despawns an NPC by entity ID
## @param npc_entity_id: NPC entity identifier
## @return bool: True if NPC was despawned
func despawn_npc(npc_entity_id: String) -> bool:
	for i in range(_spawned_npcs.size()):
		var npc = _spawned_npcs[i]
		if npc.npc_data.get("entity_id") == npc_entity_id:
			_remove_npc(i)
			npc_despawned.emit(npc_entity_id)
			return true

	push_warning("Cannot despawn NPC: not found (%s)" % npc_entity_id)
	return false

## Despawns all NPCs at a specific location
## @param location_id: Location identifier
## @return int: Number of NPCs despawned
func despawn_npcs_at_location(location_id: String) -> int:
	var count = 0
	var i = _spawned_npcs.size() - 1

	while i >= 0:
		var npc = _spawned_npcs[i]
		var npc_location = npc.get_current_location()

		var matches = false
		if npc_location is PandoraReference:
			matches = npc_location.get_id() == location_id
		elif npc_location is String:
			matches = npc_location == location_id

		if matches:
			var entity_id = npc.npc_data.get("entity_id", "")
			_remove_npc(i)
			npc_despawned.emit(entity_id)
			count += 1

		i -= 1

	return count

# ============================================================================
# PUBLIC API - Queries
# ============================================================================

## Gets all spawned NPCs
## @return Array[PPRuntimeNPC]: Array of spawned NPCs
func get_spawned_npcs() -> Array[PPRuntimeNPC]:
	return _spawned_npcs.duplicate()

## Finds an NPC by entity ID
## @param npc_entity_id: NPC entity identifier
## @return PPRuntimeNPC: NPC or null if not found
func find_npc_by_entity_id(npc_entity_id: String) -> PPRuntimeNPC:
	for npc in _spawned_npcs:
		if npc.npc_data.get("entity_id") == npc_entity_id:
			return npc
	return null

## Gets all NPCs at a specific location
## @param location_id: Location identifier
## @return Array[PPRuntimeNPC]: NPCs at location
func get_npcs_at_location(location_id: String) -> Array[PPRuntimeNPC]:
	var result: Array[PPRuntimeNPC] = []

	for npc in _spawned_npcs:
		var npc_location = npc.get_current_location()

		var matches = false
		if npc_location is PandoraReference:
			matches = npc_location.get_id() == location_id
		elif npc_location is String:
			matches = npc_location == location_id

		if matches:
			result.append(npc)

	return result

## Gets all quest giver NPCs
## @return Array[PPRuntimeNPC]: Quest giver NPCs
func get_all_quest_givers() -> Array[PPRuntimeNPC]:
	var quest_givers: Array[PPRuntimeNPC] = []

	for npc in _spawned_npcs:
		if npc.is_quest_giver():
			quest_givers.append(npc)

	return quest_givers

## Gets alive NPCs count
## @return int: Number of alive NPCs
func get_alive_npc_count() -> int:
	var count = 0
	for npc in _spawned_npcs:
		if npc.is_alive():
			count += 1
	return count

## Gets spawned NPC count
## @return int: Total number of spawned NPCs
func get_spawned_npc_count() -> int:
	return _spawned_npcs.size()

# ============================================================================
# PUBLIC API - NPC Actions
# ============================================================================

## Revives an NPC by entity ID
## @param npc_entity_id: NPC entity identifier
## @param health_percentage: Health percentage to revive with (0.0 to 1.0)
## @return bool: True if NPC was revived
func revive_npc(npc_entity_id: String, health_percentage: float = 1.0) -> bool:
	var npc = find_npc_by_entity_id(npc_entity_id)
	if not npc:
		push_warning("Cannot revive NPC: not found (%s)" % npc_entity_id)
		return false

	if npc.is_alive():
		push_warning("Cannot revive NPC: already alive (%s)" % npc_entity_id)
		return false

	npc.revive(health_percentage)
	npc_revived.emit(npc_entity_id)
	return true

# ============================================================================
# PUBLIC API - State Management
# ============================================================================

## Clears all NPC state (for new game)
func clear_all() -> void:
	_spawned_npcs.clear()
	all_npcs_cleared.emit()

## Loads NPC state from GameState (called by SaveManager)
## @param game_state: PPGameState instance
func load_state(game_state: PPGameState) -> void:
	clear_all()

	# Load spawned NPCs
	for npc_data in game_state.spawned_npcs:
		var runtime_npc = PPRuntimeNPC.from_dict(npc_data)
		_add_npc(runtime_npc)

	print("NPCManager: Loaded %d spawned NPCs" % _spawned_npcs.size())

## Saves NPC state to GameState (called by SaveManager)
## @param game_state: PPGameState instance to update
func save_state(game_state: PPGameState) -> void:
	# Save spawned NPCs
	game_state.spawned_npcs.clear()
	for npc in _spawned_npcs:
		game_state.spawned_npcs.append(npc.to_dict())

# ============================================================================
# INTERNAL - NPC Management
# ============================================================================

func _add_npc(runtime_npc: PPRuntimeNPC) -> void:
	var entity_id = runtime_npc.npc_data.get("entity_id", "")

	# Check for duplicates
	if find_npc_by_entity_id(entity_id):
		push_warning("NPC already spawned: %s" % entity_id)
		return

	_spawned_npcs.append(runtime_npc)

	# Connect to NPC signals
	if not runtime_npc.died.is_connected(_on_npc_died):
		runtime_npc.died.connect(_on_npc_died.bind(entity_id))
	if not runtime_npc.revived.is_connected(_on_npc_revived):
		runtime_npc.revived.connect(_on_npc_revived.bind(entity_id))
	if not runtime_npc.location_changed.is_connected(_on_npc_location_changed):
		runtime_npc.location_changed.connect(_on_npc_location_changed.bind(entity_id))

	npc_spawned.emit(runtime_npc)

func _remove_npc(index: int) -> void:
	if index < 0 or index >= _spawned_npcs.size():
		return

	var npc = _spawned_npcs[index]

	# Disconnect signals
	if npc.died.is_connected(_on_npc_died):
		npc.died.disconnect(_on_npc_died)
	if npc.revived.is_connected(_on_npc_revived):
		npc.revived.disconnect(_on_npc_revived)
	if npc.location_changed.is_connected(_on_npc_location_changed):
		npc.location_changed.disconnect(_on_npc_location_changed)

	_spawned_npcs.remove_at(index)

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_npc_died(npc_id: String) -> void:
	npc_died.emit(npc_id)

func _on_npc_revived(npc_id: String) -> void:
	npc_revived.emit(npc_id)

func _on_npc_location_changed(old_location: Variant, new_location: Variant, npc_id: String) -> void:
	npc_location_changed.emit(npc_id, old_location, new_location)

# ============================================================================
# UTILITY
# ============================================================================

## Gets a debug summary of NPC state
## @return String: Summary text
func get_summary() -> String:
	var summary = "NPCManager State:\n"
	summary += "  Spawned NPCs: %d\n" % _spawned_npcs.size()
	summary += "  Alive NPCs: %d\n" % get_alive_npc_count()
	summary += "  Quest Givers: %d\n" % get_all_quest_givers().size()

	summary += "\n  NPCs by location:\n"
	var locations: Dictionary = {}
	for npc in _spawned_npcs:
		var loc = npc.get_current_location()
		var loc_id = "Unknown"

		if loc is PandoraReference:
			loc_id = loc.get_id()
		elif loc is String:
			loc_id = loc

		if not locations.has(loc_id):
			locations[loc_id] = 0
		locations[loc_id] += 1

	for loc_id in locations:
		summary += "    %s: %d NPCs\n" % [loc_id, locations[loc_id]]

	return summary
