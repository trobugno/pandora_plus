extends Resource
class_name PPSaveSlot

## Save Slot Metadata
## Contains metadata about a save file for UI display
##
## This class represents the information shown in save/load menus
## without loading the entire save file.

# ============================================================================
# SLOT IDENTIFICATION
# ============================================================================

## Slot identifier (number or string name like "autosave", "quicksave")
@export var slot_id: Variant

## Whether this slot is empty
@export var is_empty: bool = true

# ============================================================================
# PLAYER INFO (for display)
# ============================================================================

## Player's name
@export var player_name: String = ""

## Total playtime in seconds
@export var playtime: float = 0.0

# ============================================================================
# SAVE INFO
# ============================================================================

## Timestamp when save was created (Unix time)
@export var timestamp: float = 0.0

## Save file version
@export var save_version: String = ""

## Last location/scene name
@export var location: String = ""

# ============================================================================
# OPTIONAL - Screenshot (for fancy UI)
# ============================================================================

## Optional screenshot of the game when saved
## Can be used for visual save slot representation
var thumbnail: Image = null

# ============================================================================
# INITIALIZATION
# ============================================================================

func _init(p_slot_id: Variant = null) -> void:
	slot_id = p_slot_id
	is_empty = true
	player_name = ""
	playtime = 0.0
	timestamp = 0.0
	save_version = ""
	location = ""
	thumbnail = null

# ============================================================================
# DISPLAY HELPERS
# ============================================================================

## Gets formatted datetime string for the save
## @return String: Human-readable date/time
func get_formatted_date() -> String:
	if is_empty:
		return "Empty Slot"

	var datetime = Time.get_datetime_dict_from_unix_time(int(timestamp))

	return "%04d-%02d-%02d %02d:%02d" % [
		datetime.year,
		datetime.month,
		datetime.day,
		datetime.hour,
		datetime.minute
	]

## Gets formatted playtime string
## @return String: Human-readable playtime (e.g., "5h 23m")
func get_formatted_playtime() -> String:
	if is_empty:
		return "0m"

	var hours = int(playtime / 3600.0)
	var minutes = int((playtime - hours * 3600) / 60.0)

	if hours > 0:
		return "%dh %dm" % [hours, minutes]
	else:
		return "%dm" % minutes

## Gets slot display name
## @return String: Slot name for UI (e.g., "Slot 1", "Autosave", "Quicksave")
func get_slot_name() -> String:
	if slot_id is int:
		return "Slot %d" % slot_id
	elif slot_id is String:
		return slot_id.capitalize()
	else:
		return "Unknown"

## Gets a one-line summary for list display
## @return String: Summary line
func get_summary_line() -> String:
	if is_empty:
		return "%s: Empty" % get_slot_name()

	return "%s: %s - %s - %s" % [
		get_slot_name(),
		player_name,
		location,
		get_formatted_date()
	]

## Checks if this save is compatible with current game version
## @param current_version: Current game version string
## @return bool: True if compatible
func is_compatible(current_version: String) -> bool:
	if is_empty:
		return true

	# Simple version check (major version must match)
	var save_major = save_version.split(".")[0] if save_version.contains(".") else save_version
	var current_major = current_version.split(".")[0] if current_version.contains(".") else current_version

	return save_major == current_major

# ============================================================================
# COMPARISON (for sorting)
# ============================================================================

## Compares this slot with another by timestamp (newest first)
## @param other: Another PPSaveSlot
## @return bool: True if this slot is newer
func is_newer_than(other: PPSaveSlot) -> bool:
	if is_empty and other.is_empty:
		return false
	if is_empty:
		return false
	if other.is_empty:
		return true

	return timestamp > other.timestamp

# ============================================================================
# SERIALIZATION (for caching)
# ============================================================================

## Serializes slot metadata to dictionary
## @return Dictionary: Slot metadata
func to_dict() -> Dictionary:
	return {
		"slot_id": slot_id,
		"is_empty": is_empty,
		"player_name": player_name,
		"playtime": playtime,
		"timestamp": timestamp,
		"save_version": save_version,
		"location": location
	}

## Creates a SaveSlot from dictionary
## @param data: Dictionary with slot metadata
## @return PPSaveSlot: Restored slot
static func from_dict(data: Dictionary) -> PPSaveSlot:
	var slot = PPSaveSlot.new(data.get("slot_id"))

	slot.is_empty = data.get("is_empty", true)
	slot.player_name = data.get("player_name", "")
	slot.playtime = data.get("playtime", 0.0)
	slot.timestamp = data.get("timestamp", 0.0)
	slot.save_version = data.get("save_version", "")
	slot.location = data.get("location", "")

	return slot
