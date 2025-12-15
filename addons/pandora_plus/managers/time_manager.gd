extends Node

## Time Manager (Autoload)
## Manages game world time and day/night cycles
##
## Responsibilities:
## - Tracks world time (total elapsed seconds)
## - Manages game hour (0-23) and day progression
## - Updates NPC schedules when hour changes
## - Provides time scale for fast-forwarding
## - Integrates with SaveManager
##
## Usage:
##   PPTimeManager.advance_time(delta)
##   var hour = PPTimeManager.get_current_hour()
##   PPTimeManager.set_time_scale(2.0)  # 2x speed

# ============================================================================
# SIGNALS
# ============================================================================

signal hour_changed(old_hour: int, new_hour: int)
signal day_changed(old_day: int, new_day: int)
signal time_advanced(delta_seconds: float)
signal time_scale_changed(old_scale: float, new_scale: float)

# ============================================================================
# CONSTANTS
# ============================================================================

const SECONDS_PER_HOUR: float = 3600.0
const HOURS_PER_DAY: int = 24

# ============================================================================
# STATE
# ============================================================================

## Total world time elapsed in seconds
var _world_time: float = 0.0

## Current game hour (0-23)
var _current_hour: int = 12

## Current game day (starts at 1)
var _current_day: int = 1

## Time scale multiplier (1.0 = real-time, 2.0 = 2x speed, etc.)
var _time_scale: float = 1.0

## Whether time progression is paused
var _is_paused: bool = false

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	_load_settings()
	print("TimeManager initialized")
	print("  - Starting time: Day %d, %02d:00" % [_current_day, _current_hour])
	print("  - Time scale: %.1fx" % _time_scale)

func _load_settings() -> void:
	_current_day = ProjectSettings.get_setting(
		PandoraPlusSettings.TIME_SETTING_STARTING_DAY,
		PandoraPlusSettings.TIME_SETTING_STARTING_DAY_VALUE
	)
	_current_hour = ProjectSettings.get_setting(
		PandoraPlusSettings.TIME_SETTING_STARTING_HOUR,
		PandoraPlusSettings.TIME_SETTING_STARTING_HOUR_VALUE
	)
	_time_scale = ProjectSettings.get_setting(
		PandoraPlusSettings.TIME_SETTING_TIME_SCALE_DEFAULT,
		PandoraPlusSettings.TIME_SETTING_TIME_SCALE_DEFAULT_VALUE
	)

	# Calculate initial world time from starting day and hour
	_world_time = ((_current_day - 1) * HOURS_PER_DAY + _current_hour) * SECONDS_PER_HOUR

func _process(delta: float) -> void:
	if not _is_paused:
		advance_time(delta * _time_scale)

# ============================================================================
# PUBLIC API - Time Advancement
# ============================================================================

## Advances world time by the specified amount
## @param delta_seconds: Time to advance in seconds
func advance_time(delta_seconds: float) -> void:
	if delta_seconds <= 0:
		return

	_world_time += delta_seconds

	# Calculate hour and day from total time
	var total_hours = int(_world_time / SECONDS_PER_HOUR)
	var new_hour = total_hours % HOURS_PER_DAY
	var new_day = 1 + (total_hours / HOURS_PER_DAY)

	# Check for hour change
	if new_hour != _current_hour:
		var old_hour = _current_hour
		_current_hour = new_hour
		hour_changed.emit(old_hour, _current_hour)

		# Notify NPCManager to update schedules
		if has_node("/root/PPNPCManager"):
			PPNPCManager.update_all_schedules(_current_hour)

	# Check for day change
	if new_day != _current_day:
		var old_day = _current_day
		_current_day = new_day
		day_changed.emit(old_day, _current_day)

	time_advanced.emit(delta_seconds)

## Sets world time to a specific value
## @param time_in_seconds: New world time in seconds
func set_world_time(time_in_seconds: float) -> void:
	var delta = time_in_seconds - _world_time
	if delta > 0:
		advance_time(delta)
	else:
		# Going backwards in time
		_world_time = time_in_seconds
		_recalculate_hour_and_day()

## Sets the current hour directly
## @param hour: Hour to set (0-23)
func set_current_hour(hour: int) -> void:
	hour = clamp(hour, 0, 23)

	if hour == _current_hour:
		return

	# Calculate the time difference to reach target hour
	var hours_diff = hour - _current_hour
	if hours_diff < 0:
		# Wrap to next day
		hours_diff += HOURS_PER_DAY

	var seconds_diff = hours_diff * SECONDS_PER_HOUR
	advance_time(seconds_diff)

## Sets the current day and hour
## @param day: Day to set (1+)
## @param hour: Hour to set (0-23)
func set_time(day: int, hour: int) -> void:
	day = max(1, day)
	hour = clamp(hour, 0, 23)

	var target_seconds = ((day - 1) * HOURS_PER_DAY + hour) * SECONDS_PER_HOUR
	set_world_time(target_seconds)

## Advances time by a specific number of hours
## @param hours: Number of hours to advance
func advance_hours(hours: int) -> void:
	advance_time(hours * SECONDS_PER_HOUR)

## Advances time by a specific number of days
## @param days: Number of days to advance
func advance_days(days: int) -> void:
	advance_time(days * HOURS_PER_DAY * SECONDS_PER_HOUR)

# ============================================================================
# PUBLIC API - Time Scale & Pausing
# ============================================================================

## Sets the time scale multiplier
## @param scale: Time scale (0.0 = paused, 1.0 = normal, 2.0 = 2x speed, etc.)
func set_time_scale(scale: float) -> void:
	scale = max(0.0, scale)

	if scale == _time_scale:
		return

	var old_scale = _time_scale
	_time_scale = scale
	time_scale_changed.emit(old_scale, _time_scale)

## Gets the current time scale
## @return float: Time scale multiplier
func get_time_scale() -> float:
	return _time_scale

## Pauses time progression
func pause() -> void:
	_is_paused = true

## Resumes time progression
func resume() -> void:
	_is_paused = false

## Toggles pause state
func toggle_pause() -> void:
	_is_paused = not _is_paused

## Checks if time is paused
## @return bool: True if paused
func is_paused() -> bool:
	return _is_paused

# ============================================================================
# PUBLIC API - Time Queries
# ============================================================================

## Gets total world time in seconds
## @return float: World time in seconds
func get_world_time() -> float:
	return _world_time

## Gets current game hour (0-23)
## @return int: Current hour
func get_current_hour() -> int:
	return _current_hour

## Gets current game day (1+)
## @return int: Current day
func get_current_day() -> int:
	return _current_day

## Gets current time formatted as string
## @param use_24h: Use 24-hour format (default true)
## @return String: Formatted time (e.g., "14:30" or "2:30 PM")
func get_formatted_time(use_24h: bool = true) -> String:
	var minutes = int(fmod(_world_time, SECONDS_PER_HOUR) / 60.0)

	if use_24h:
		return "%02d:%02d" % [_current_hour, minutes]
	else:
		var hour_12 = _current_hour % 12
		if hour_12 == 0:
			hour_12 = 12
		var period = "AM" if _current_hour < 12 else "PM"
		return "%d:%02d %s" % [hour_12, minutes, period]

## Gets current day and time formatted as string
## @return String: Formatted day and time (e.g., "Day 5, 14:30")
func get_formatted_datetime() -> String:
	return "Day %d, %s" % [_current_day, get_formatted_time()]

## Checks if it's currently daytime
## @param dawn_hour: Hour when day starts (default 6)
## @param dusk_hour: Hour when night starts (default 18)
## @return bool: True if daytime
func is_daytime(dawn_hour: int = 6, dusk_hour: int = 18) -> bool:
	return _current_hour >= dawn_hour and _current_hour < dusk_hour

## Checks if it's currently nighttime
## @param dawn_hour: Hour when day starts (default 6)
## @param dusk_hour: Hour when night starts (default 18)
## @return bool: True if nighttime
func is_nighttime(dawn_hour: int = 6, dusk_hour: int = 18) -> bool:
	return not is_daytime(dawn_hour, dusk_hour)

## Gets time period name
## @return String: "Morning", "Afternoon", "Evening", or "Night"
func get_time_period() -> String:
	if _current_hour >= 6 and _current_hour < 12:
		return "Morning"
	elif _current_hour >= 12 and _current_hour < 18:
		return "Afternoon"
	elif _current_hour >= 18 and _current_hour < 22:
		return "Evening"
	else:
		return "Night"

# ============================================================================
# PUBLIC API - State Management
# ============================================================================

## Clears all time state (for new game)
## @param starting_day: Starting day (use -1 to use configured setting)
## @param starting_hour: Starting hour (use -1 to use configured setting)
func reset(starting_day: int = -1, starting_hour: int = -1) -> void:
	# Use configured settings if not specified
	if starting_day < 0:
		starting_day = ProjectSettings.get_setting(
			PandoraPlusSettings.TIME_SETTING_STARTING_DAY,
			PandoraPlusSettings.TIME_SETTING_STARTING_DAY_VALUE
		)
	if starting_hour < 0:
		starting_hour = ProjectSettings.get_setting(
			PandoraPlusSettings.TIME_SETTING_STARTING_HOUR,
			PandoraPlusSettings.TIME_SETTING_STARTING_HOUR_VALUE
		)

	_world_time = 0.0
	_current_day = max(1, starting_day)
	_current_hour = clamp(starting_hour, 0, 23)
	_time_scale = ProjectSettings.get_setting(
		PandoraPlusSettings.TIME_SETTING_TIME_SCALE_DEFAULT,
		PandoraPlusSettings.TIME_SETTING_TIME_SCALE_DEFAULT_VALUE
	)
	_is_paused = false

	# Recalculate world time from day/hour
	_world_time = ((_current_day - 1) * HOURS_PER_DAY + _current_hour) * SECONDS_PER_HOUR

## Loads time state from GameState (called by SaveManager)
## @param game_state: PPGameState instance
func load_state(game_state: PPGameState) -> void:
	_world_time = game_state.world_time
	_current_hour = game_state.current_hour
	_current_day = game_state.current_day

	print("TimeManager: Loaded time state - Day %d, %02d:00 (%.1f total seconds)" % [
		_current_day,
		_current_hour,
		_world_time
	])

## Saves time state to GameState (called by SaveManager)
## @param game_state: PPGameState instance to update
func save_state(game_state: PPGameState) -> void:
	game_state.world_time = _world_time
	game_state.current_hour = _current_hour
	game_state.current_day = _current_day

# ============================================================================
# INTERNAL
# ============================================================================

func _recalculate_hour_and_day() -> void:
	var total_hours = int(_world_time / SECONDS_PER_HOUR)
	_current_hour = total_hours % HOURS_PER_DAY
	_current_day = 1 + (total_hours / HOURS_PER_DAY)

# ============================================================================
# UTILITY
# ============================================================================

## Gets a debug summary of time state
## @return String: Summary text
func get_summary() -> String:
	var summary = "TimeManager State:\n"
	summary += "  Current Time: %s\n" % get_formatted_datetime()
	summary += "  World Time: %.1f seconds (%.1f hours)\n" % [_world_time, _world_time / SECONDS_PER_HOUR]
	summary += "  Time Period: %s\n" % get_time_period()
	summary += "  Time Scale: %.1fx\n" % _time_scale
	summary += "  Paused: %s\n" % ("Yes" if _is_paused else "No")
	return summary
