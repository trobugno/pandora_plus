extends Node

## Save/Load Manager (Autoload)
## Provides centralized save/load functionality for Pandora+
##
## Features:
## - Multiple save slots (configurable via ProjectSettings)
## - Autosave system with configurable interval
## - Quicksave/Quickload support
## - JSON-based human-readable save files
## - Save slot metadata for UI
## - Version checking for compatibility
##
## Configuration:
## All settings are available in Project Settings under pandora_plus/config/save_system/
## - max_save_slots: Number of available save slots (1-20, default 3)
## - autosave_enabled: Enable/disable autosave (default true)
## - autosave_interval_seconds: Time between autosaves (30-3600s, default 300s)
## - save_directory: Directory for save files (default "user://saves/")
## - save_file_extension: Extension for save files (default ".json")

# ============================================================================
# CONSTANTS
# ============================================================================

const SAVE_VERSION = "1.0.0"
const AUTOSAVE_SLOT_NAME = "autosave"
const QUICKSAVE_SLOT_NAME = "quicksave"

# ============================================================================
# SIGNALS
# ============================================================================

signal save_started(slot_id: Variant)
signal save_completed(slot_id: Variant, success: bool)
signal load_started(slot_id: Variant)
signal load_completed(slot_id: Variant, success: bool, game_state: Variant)
signal save_deleted(slot_id: Variant)
signal autosave_triggered()

# ============================================================================
# SETTINGS (cached from ProjectSettings)
# ============================================================================

var max_save_slots: int = 3
var autosave_enabled: bool = true
var autosave_interval: float = 300.0
var save_directory: String = "user://saves/"
var save_extension: String = ".json"

# ============================================================================
# STATE
# ============================================================================

var _autosave_timer: float = 0.0
var _is_saving: bool = false
var _is_loading: bool = false

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	_load_settings()
	_ensure_save_directory()

	print("SaveManager initialized:")
	print("  - Max slots: %d" % max_save_slots)
	print("  - Autosave: %s (every %.1fs)" % [autosave_enabled, autosave_interval])
	print("  - Directory: %s" % save_directory)

func _load_settings() -> void:
	max_save_slots = ProjectSettings.get_setting(
		PandoraPlusSettings.SAVE_SETTING_MAX_SLOTS,
		PandoraPlusSettings.SAVE_SETTING_MAX_SLOTS_VALUE
	)
	autosave_enabled = ProjectSettings.get_setting(
		PandoraPlusSettings.SAVE_SETTING_AUTOSAVE_ENABLED,
		PandoraPlusSettings.SAVE_SETTING_AUTOSAVE_ENABLED_VALUE
	)
	autosave_interval = ProjectSettings.get_setting(
		PandoraPlusSettings.SAVE_SETTING_AUTOSAVE_INTERVAL,
		PandoraPlusSettings.SAVE_SETTING_AUTOSAVE_INTERVAL_VALUE
	)
	save_directory = ProjectSettings.get_setting(
		PandoraPlusSettings.SAVE_SETTING_SAVE_DIRECTORY,
		PandoraPlusSettings.SAVE_SETTING_SAVE_DIRECTORY_VALUE
	)
	save_extension = ProjectSettings.get_setting(
		PandoraPlusSettings.SAVE_SETTING_SAVE_EXTENSION,
		PandoraPlusSettings.SAVE_SETTING_SAVE_EXTENSION_VALUE
	)

func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(save_directory):
		var error = DirAccess.make_dir_recursive_absolute(save_directory)
		if error != OK:
			push_error("Failed to create save directory: %s (Error: %d)" % [save_directory, error])

# ============================================================================
# PROCESS (Autosave)
# ============================================================================

func _process(delta: float) -> void:
	if not autosave_enabled or _is_saving:
		return

	_autosave_timer += delta
	if _autosave_timer >= autosave_interval:
		_autosave_timer = 0.0
		autosave()

# ============================================================================
# PUBLIC API - Save Operations
# ============================================================================

## Saves game state to specified slot
## @param slot: Slot number (1 to max_save_slots) or string name ("autosave", "quicksave")
## @param game_state: GameState instance to save (if null, will call _collect_current_state)
## @return bool: true if save succeeded, false otherwise
func save_game(slot: Variant, game_state = null) -> bool:
	if _is_saving:
		push_warning("Save already in progress, skipping")
		return false

	if not _validate_slot(slot):
		return false

	_is_saving = true
	save_started.emit(slot)

	# Collect current state if not provided
	if game_state == null:
		game_state = _collect_current_state()

	var success = _save_to_file(_get_slot_path(slot), game_state)

	_is_saving = false
	save_completed.emit(slot, success)

	return success

## Loads game state from specified slot
## @param slot: Slot number or string name
## @return GameState instance or null if load failed
func load_game(slot: Variant):
	if _is_loading:
		push_warning("Load already in progress, skipping")
		return null

	if not _validate_slot(slot):
		return null

	_is_loading = true
	load_started.emit(slot)

	var game_state = _load_from_file(_get_slot_path(slot))

	_is_loading = false
	load_completed.emit(slot, game_state != null, game_state)

	return game_state

## Loads and applies game state from specified slot
## This is a convenience method that loads AND restores state to managers
## @param slot: Slot number or string name
## @return bool: True if load and restore succeeded
func load_and_apply(slot: Variant) -> bool:
	var game_state = load_game(slot)

	if not game_state:
		return false

	restore_state(game_state)
	return true

## Restores game state to all managers
## Call this after loading a game state to apply it
## @param game_state: PPGameState to restore
func restore_state(game_state: PPGameState) -> void:
	if not game_state:
		push_error("Cannot restore state: game_state is null")
		return

	# Restore to managers
	if has_node("/root/PPPlayerManager"):
		PPPlayerManager.load_state(game_state)
	else:
		push_warning("SaveManager: PPPlayerManager not found, player data will not be restored")

	if has_node("/root/PPQuestManager"):
		PPQuestManager.load_state(game_state)

	if has_node("/root/PPNPCManager"):
		PPNPCManager.load_state(game_state)

	if has_node("/root/PPTimeManager"):
		PPTimeManager.load_state(game_state)

	print("SaveManager: State restored to all managers")

## Deletes save file for specified slot
## @param slot: Slot number or string name
## @return bool: true if deletion succeeded
func delete_save(slot: Variant) -> bool:
	if not _validate_slot(slot):
		return false

	var path = _get_slot_path(slot)

	if not FileAccess.file_exists(path):
		push_warning("Save file does not exist: %s" % path)
		return false

	var error = DirAccess.remove_absolute(path)
	if error != OK:
		push_error("Failed to delete save file: %s (Error: %d)" % [path, error])
		return false

	save_deleted.emit(slot)
	return true

## Checks if a save file exists for the specified slot
## @param slot: Slot number or string name
## @return bool: true if save exists
func has_save(slot: Variant) -> bool:
	if not _validate_slot(slot):
		return false

	return FileAccess.file_exists(_get_slot_path(slot))

## Gets metadata for all available save slots
## @return Array[SaveSlot]: Array of SaveSlot instances with metadata
func get_save_slots() -> Array:
	var slots: Array = []

	# Regular numbered slots
	for i in range(1, max_save_slots + 1):
		var slot = _load_slot_metadata(i)
		slots.append(slot)

	return slots

## Gets metadata for a specific save slot
## @param slot: Slot number or string name
## @return SaveSlot instance or null
func get_save_slot(slot: Variant):
	if not _validate_slot(slot):
		return null

	return _load_slot_metadata(slot)

# ============================================================================
# PUBLIC API - Special Saves
# ============================================================================

## Performs an autosave to the autosave slot
func autosave() -> bool:
	if not autosave_enabled:
		return false

	autosave_triggered.emit()
	var game_state = _collect_current_state()
	return save_game(AUTOSAVE_SLOT_NAME, game_state)

## Performs a quicksave to the quicksave slot
func quicksave() -> bool:
	var game_state = _collect_current_state()
	return save_game(QUICKSAVE_SLOT_NAME, game_state)

## Loads from the quicksave slot
func quickload():
	return load_game(QUICKSAVE_SLOT_NAME)

## Resets autosave timer (call after manual save to avoid immediate autosave)
func reset_autosave_timer() -> void:
	_autosave_timer = 0.0

# ============================================================================
# INTERNAL - File Operations
# ============================================================================

func _save_to_file(path: String, game_state) -> bool:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		var error = FileAccess.get_open_error()
		push_error("Failed to open save file for writing: %s (Error: %d)" % [path, error])
		return false

	# Create save data structure
	var save_data = {
		"version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"game_state": game_state.to_dict() if game_state else {}
	}

	# Serialize to JSON
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()

	return true

func _load_from_file(path: String):
	if not FileAccess.file_exists(path):
		push_warning("Save file does not exist: %s" % path)
		return null

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		var error = FileAccess.get_open_error()
		push_error("Failed to open save file for reading: %s (Error: %d)" % [path, error])
		return null

	var json_string = file.get_as_text()
	file.close()

	# Parse JSON
	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		push_error("Failed to parse save file: %s (Error at line %d: %s)" % [path, json.get_error_line(), json.get_error_message()])
		return null

	var save_data = json.get_data()

	# Version check
	var file_version = save_data.get("version", "unknown")
	if file_version != SAVE_VERSION:
		push_warning("Save file version mismatch. File: %s, Current: %s. Migration may be needed." % [file_version, SAVE_VERSION])

	# Deserialize game state
	var game_state_data = save_data.get("game_state", {})
	var game_state = PPGameState.from_dict(game_state_data)

	return game_state

func _load_slot_metadata(slot: Variant) -> PPSaveSlot:
	var path = _get_slot_path(slot)
	var save_slot = PPSaveSlot.new(slot)

	if not FileAccess.file_exists(path):
		return save_slot

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return save_slot

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		return save_slot

	var save_data = json.get_data()
	var game_state = save_data.get("game_state", {})
	var player_data = game_state.get("player_data", {})
	var meta = game_state.get("meta", {})

	# Extract metadata
	save_slot.is_empty = false
	save_slot.timestamp = save_data.get("timestamp", 0.0)
	save_slot.save_version = save_data.get("version", "unknown")

	# Extract player info from nested structure
	if player_data.has("basic_info"):
		var basic = player_data["basic_info"]
		save_slot.player_name = basic.get("player_name", "Unknown")
	elif player_data.has("player_name"):
		# Fallback for simplified structure
		save_slot.player_name = player_data.get("player_name", "Unknown")

	save_slot.playtime = meta.get("playtime", 0.0)

	# Extract location from position structure
	if player_data.has("position"):
		save_slot.location = player_data["position"].get("current_scene", "Unknown")
	elif player_data.has("current_scene"):
		# Fallback for simplified structure
		save_slot.location = player_data.get("current_scene", "Unknown")

	return save_slot

# ============================================================================
# INTERNAL - Path & Validation
# ============================================================================

func _get_slot_path(slot: Variant) -> String:
	var filename: String

	if slot is int:
		filename = "slot_%d%s" % [slot, save_extension]
	elif slot is String:
		filename = "%s%s" % [slot, save_extension]
	else:
		push_error("Invalid slot type: %s" % typeof(slot))
		return ""

	return save_directory + filename

func _validate_slot(slot: Variant) -> bool:
	if slot is int:
		if slot < 1 or slot > max_save_slots:
			push_error("Slot number out of range: %d (valid range: 1-%d)" % [slot, max_save_slots])
			return false
		return true
	elif slot is String:
		if slot == AUTOSAVE_SLOT_NAME or slot == QUICKSAVE_SLOT_NAME:
			return true
		push_error("Invalid slot name: %s (valid names: %s, %s)" % [slot, AUTOSAVE_SLOT_NAME, QUICKSAVE_SLOT_NAME])
		return false
	else:
		push_error("Invalid slot type: %s (expected int or String)" % typeof(slot))
		return false

# ============================================================================
# INTERNAL - State Collection (Override Point)
# ============================================================================

## Collects current game state from all managers
## This is called when save_game is called without a game_state parameter
## Override this method in your game if you need custom behavior
func _collect_current_state() -> PPGameState:
	var game_state = PPGameState.new()

	# Collect state from managers
	if has_node("/root/PPPlayerManager"):
		PPPlayerManager.save_state(game_state)
	else:
		push_warning("SaveManager: PPPlayerManager not found, player data will not be saved")

	if has_node("/root/PPQuestManager"):
		PPQuestManager.save_state(game_state)

	if has_node("/root/PPNPCManager"):
		PPNPCManager.save_state(game_state)

	if has_node("/root/PPTimeManager"):
		PPTimeManager.save_state(game_state)

	return game_state
