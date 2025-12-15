extends Node

## Quest Manager (Autoload)
## Manages quest state during gameplay
##
## Responsibilities:
## - Maintains active quests collection
## - Tracks completed and failed quest IDs
## - Coordinates quest lifecycle with PPQuestUtils
## - Updates timed quests
## - Integrates with SaveManager
##
## Usage:
##   PPQuestManager.start_quest(quest_entity)
##   PPQuestManager.complete_quest(quest_id)
##   var active = PPQuestManager.get_active_quests()

# ============================================================================
# SIGNALS
# ============================================================================

signal quest_added(runtime_quest: PPRuntimeQuest)
signal quest_removed(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_failed(quest_id: String)
signal quest_abandoned(quest_id: String)
signal all_quests_cleared()

# ============================================================================
# STATE
# ============================================================================

## Active quests (currently in progress)
var _active_quests: Array[PPRuntimeQuest] = []

## Completed quest IDs
var _completed_quest_ids: Array[String] = []

## Failed quest IDs
var _failed_quest_ids: Array[String] = []

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	print("QuestManager initialized")

# ============================================================================
# PUBLIC API - Quest Management
# ============================================================================

## Starts a new quest from a quest entity
## @param quest_entity: PPQuestEntity to start
## @return PPRuntimeQuest: Created runtime quest or null if failed
func start_quest(quest_entity: PPQuestEntity) -> PPRuntimeQuest:
	# Use PPQuestUtils for validation and creation
	var runtime_quest = PPQuestUtils.start_quest(quest_entity, _completed_quest_ids)

	if not runtime_quest:
		return null

	_add_quest(runtime_quest)
	return runtime_quest

## Starts a quest from PPQuest data
## @param quest_data: PPQuest data
## @return PPRuntimeQuest: Created runtime quest or null
func start_quest_from_data(quest_data: PPQuest) -> PPRuntimeQuest:
	var runtime_quest = PPQuestUtils.start_quest_from_data(quest_data, _completed_quest_ids)

	if not runtime_quest:
		return null

	_add_quest(runtime_quest)
	return runtime_quest

## Adds an existing runtime quest (used during load)
## @param runtime_quest: PPRuntimeQuest instance
func add_existing_quest(runtime_quest: PPRuntimeQuest) -> void:
	_add_quest(runtime_quest)

## Completes a quest by ID
## @param quest_id: Quest identifier
## @return bool: True if quest was completed
func complete_quest(quest_id: String) -> bool:
	var runtime_quest = find_quest(quest_id)
	if not runtime_quest:
		push_warning("Cannot complete quest: quest not found (%s)" % quest_id)
		return false

	if not runtime_quest.is_active():
		push_warning("Cannot complete quest: quest is not active (%s)" % quest_id)
		return false

	runtime_quest.complete()
	_move_to_completed(quest_id)
	quest_completed.emit(quest_id)

	return true

## Fails a quest by ID
## @param quest_id: Quest identifier
## @return bool: True if quest was failed
func fail_quest(quest_id: String) -> bool:
	var runtime_quest = find_quest(quest_id)
	if not runtime_quest:
		push_warning("Cannot fail quest: quest not found (%s)" % quest_id)
		return false

	if not runtime_quest.is_active():
		push_warning("Cannot fail quest: quest is not active (%s)" % quest_id)
		return false

	runtime_quest.fail()
	_move_to_failed(quest_id)
	quest_failed.emit(quest_id)

	return true

## Abandons a quest by ID
## @param quest_id: Quest identifier
## @return bool: True if quest was abandoned
func abandon_quest(quest_id: String) -> bool:
	var runtime_quest = find_quest(quest_id)
	if not runtime_quest:
		push_warning("Cannot abandon quest: quest not found (%s)" % quest_id)
		return false

	if not runtime_quest.is_active():
		push_warning("Cannot abandon quest: quest is not active (%s)" % quest_id)
		return false

	runtime_quest.abandon()
	_remove_quest(quest_id)
	quest_abandoned.emit(quest_id)

	return true

## Removes a quest from active quests without changing its status
## @param quest_id: Quest identifier
func remove_quest(quest_id: String) -> void:
	_remove_quest(quest_id)

# ============================================================================
# PUBLIC API - Queries
# ============================================================================

## Gets all active quests
## @return Array[PPRuntimeQuest]: Array of active quests
func get_active_quests() -> Array[PPRuntimeQuest]:
	return _active_quests.duplicate()

## Gets completed quest IDs
## @return Array[String]: Array of completed quest IDs
func get_completed_quest_ids() -> Array[String]:
	return _completed_quest_ids.duplicate()

## Gets failed quest IDs
## @return Array[String]: Array of failed quest IDs
func get_failed_quest_ids() -> Array[String]:
	return _failed_quest_ids.duplicate()

## Finds an active quest by ID
## @param quest_id: Quest identifier
## @return PPRuntimeQuest: Quest or null if not found
func find_quest(quest_id: String) -> PPRuntimeQuest:
	for quest in _active_quests:
		if quest.get_quest_id() == quest_id:
			return quest
	return null

## Checks if a quest is active
## @param quest_id: Quest identifier
## @return bool: True if quest is active
func is_quest_active(quest_id: String) -> bool:
	return find_quest(quest_id) != null

## Checks if a quest is completed
## @param quest_id: Quest identifier
## @return bool: True if quest is completed
func is_quest_completed(quest_id: String) -> bool:
	return quest_id in _completed_quest_ids

## Checks if a quest is failed
## @param quest_id: Quest identifier
## @return bool: True if quest is failed
func is_quest_failed(quest_id: String) -> bool:
	return quest_id in _failed_quest_ids

## Gets number of active quests
## @return int: Count of active quests
func get_active_quest_count() -> int:
	return _active_quests.size()

## Gets number of completed quests
## @return int: Count of completed quests
func get_completed_quest_count() -> int:
	return _completed_quest_ids.size()

# ============================================================================
# PUBLIC API - State Management
# ============================================================================

## Clears all quest state (for new game)
func clear_all() -> void:
	_active_quests.clear()
	_completed_quest_ids.clear()
	_failed_quest_ids.clear()
	all_quests_cleared.emit()

## Loads quest state from GameState (called by SaveManager)
## @param game_state: PPGameState instance
func load_state(game_state: PPGameState) -> void:
	clear_all()

	# Load active quests
	for quest_data in game_state.active_quests:
		var runtime_quest = PPRuntimeQuest.from_dict(quest_data)
		_add_quest(runtime_quest)

	# Load completed/failed IDs
	_completed_quest_ids.assign(game_state.completed_quest_ids)
	_failed_quest_ids.assign(game_state.failed_quest_ids)

	print("QuestManager: Loaded %d active quests, %d completed, %d failed" % [
		_active_quests.size(),
		_completed_quest_ids.size(),
		_failed_quest_ids.size()
	])

## Saves quest state to GameState (called by SaveManager)
## @param game_state: PPGameState instance to update
func save_state(game_state: PPGameState) -> void:
	# Save active quests
	game_state.active_quests.clear()
	for quest in _active_quests:
		game_state.active_quests.append(quest.to_dict())

	# Save completed/failed IDs
	game_state.completed_quest_ids.assign(_completed_quest_ids)
	game_state.failed_quest_ids.assign(_failed_quest_ids)

# ============================================================================
# INTERNAL - Quest Management
# ============================================================================

func _add_quest(runtime_quest: PPRuntimeQuest) -> void:
	if find_quest(runtime_quest.get_quest_id()):
		push_warning("Quest already active: %s" % runtime_quest.get_quest_id())
		return

	_active_quests.append(runtime_quest)

	# Connect to quest completion signal for auto-completion tracking
	if not runtime_quest.quest_completed.is_connected(_on_quest_completed):
		runtime_quest.quest_completed.connect(_on_quest_completed.bind(runtime_quest.get_quest_id()))
	if not runtime_quest.quest_failed.is_connected(_on_quest_failed):
		runtime_quest.quest_failed.connect(_on_quest_failed.bind(runtime_quest.get_quest_id()))

	quest_added.emit(runtime_quest)

func _remove_quest(quest_id: String) -> void:
	for i in range(_active_quests.size()):
		if _active_quests[i].get_quest_id() == quest_id:
			var quest = _active_quests[i]

			# Disconnect signals
			if quest.quest_completed.is_connected(_on_quest_completed):
				quest.quest_completed.disconnect(_on_quest_completed)
			if quest.quest_failed.is_connected(_on_quest_failed):
				quest.quest_failed.disconnect(_on_quest_failed)

			_active_quests.remove_at(i)
			quest_removed.emit(quest_id)
			return

func _move_to_completed(quest_id: String) -> void:
	_remove_quest(quest_id)
	if quest_id not in _completed_quest_ids:
		_completed_quest_ids.append(quest_id)

func _move_to_failed(quest_id: String) -> void:
	_remove_quest(quest_id)
	if quest_id not in _failed_quest_ids:
		_failed_quest_ids.append(quest_id)

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_quest_completed(quest_id: String) -> void:
	# Quest completed itself (via auto-complete), move to completed list
	_move_to_completed(quest_id)
	quest_completed.emit(quest_id)

func _on_quest_failed(quest_id: String) -> void:
	# Quest failed itself
	_move_to_failed(quest_id)
	quest_failed.emit(quest_id)

# ============================================================================
# UTILITY
# ============================================================================

## Gets a debug summary of quest state
## @return String: Summary text
func get_summary() -> String:
	var summary = "QuestManager State:\n"
	summary += "  Active Quests: %d\n" % _active_quests.size()
	for quest in _active_quests:
		summary += "    - %s (%s, %.0f%%)\n" % [
			quest.get_quest_name(),
			quest.get_status_string(),
			quest.get_progress_percentage()
		]
	summary += "  Completed: %d\n" % _completed_quest_ids.size()
	summary += "  Failed: %d\n" % _failed_quest_ids.size()
	return summary
