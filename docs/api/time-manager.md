# PPTimeManager

**✅ Core & Premium** | **Autoload Singleton**

API reference for the Time Manager singleton - manages game world time, day/night cycles, and NPC schedule coordination.

---

## Description

**PPTimeManager** is an autoload singleton that provides world time tracking and day/night cycle management for Pandora+. It maintains current hour and day, supports time scaling, and automatically updates NPC schedules when time changes.

**Key Responsibilities:**
- Track world time (total elapsed seconds)
- Manage current hour (0-23) and day (1+)
- Provide time scale for fast-forwarding
- Pause/resume time progression
- Emit signals for hour/day changes
- Integrate with NPC schedule system
- Save/load time state

**Access:** Available globally as `PPTimeManager`

---

## Constants

```gdscript
const SECONDS_PER_HOUR: float = 3600.0
const HOURS_PER_DAY: int = 24
```

**SECONDS_PER_HOUR**
- Number of real seconds in one game hour (at time_scale 1.0)

**HOURS_PER_DAY**
- Number of hours in a game day

---

## Signals

### hour_changed

```gdscript
signal hour_changed(old_hour: int, new_hour: int)
```

Emitted when the game hour changes.

**Parameters:**
- `old_hour` (int) - Previous hour (0-23)
- `new_hour` (int) - New hour (0-23)

**Example:**
```gdscript
PPTimeManager.hour_changed.connect(func(old_hour, new_hour):
    print("Hour changed: %02d:00 → %02d:00" % [old_hour, new_hour])
    update_clock_ui()
    update_lighting(new_hour)
)
```

---

### day_changed

```gdscript
signal day_changed(old_day: int, new_day: int)
```

Emitted when the game day changes.

**Parameters:**
- `old_day` (int) - Previous day (1+)
- `new_day` (int) - New day (1+)

**Example:**
```gdscript
PPTimeManager.day_changed.connect(func(old_day, new_day):
    print("Day changed: %d → %d" % [old_day, new_day])
    trigger_daily_events()
    refresh_shop_inventories()
)
```

---

### time_advanced

```gdscript
signal time_advanced(delta_seconds: float)
```

Emitted every time `advance_time()` is called.

**Parameters:**
- `delta_seconds` (float) - Amount of time advanced in seconds

**Example:**
```gdscript
PPTimeManager.time_advanced.connect(func(delta_seconds):
    total_playtime += delta_seconds
    update_sun_position()
)
```

---

### time_scale_changed

```gdscript
signal time_scale_changed(old_scale: float, new_scale: float)
```

Emitted when time scale is changed.

**Parameters:**
- `old_scale` (float) - Previous time scale
- `new_scale` (float) - New time scale

**Example:**
```gdscript
PPTimeManager.time_scale_changed.connect(func(old_scale, new_scale):
    print("Time scale: %.1fx → %.1fx" % [old_scale, new_scale])

    if new_scale > 1.0:
        show_fast_forward_icon()
    else:
        hide_fast_forward_icon()
)
```

---

## Methods

### advance_time

```gdscript
func advance_time(delta_seconds: float) -> void
```

Advances world time by the specified amount.

**Parameters:**
- `delta_seconds` (float) - Time to advance in seconds

**Notes:**
- Automatically called in `_process()` with delta * time_scale
- Emits `hour_changed` and/or `day_changed` if thresholds crossed
- Automatically updates NPC schedules when hour changes

**Example:**
```gdscript
# Advance by 1 hour manually
PPTimeManager.advance_time(3600.0)

# Advance by 30 minutes
PPTimeManager.advance_time(1800.0)
```

---

### set_world_time

```gdscript
func set_world_time(time_in_seconds: float) -> void
```

Sets world time to a specific value.

**Parameters:**
- `time_in_seconds` (float) - New world time in seconds

**Example:**
```gdscript
# Set to 2 days worth of time
PPTimeManager.set_world_time(172800.0)
```

---

### set_current_hour

```gdscript
func set_current_hour(hour: int) -> void
```

Sets the current hour directly (advances time to reach target hour).

**Parameters:**
- `hour` (int) - Hour to set (0-23)

**Example:**
```gdscript
# Set to 2pm
PPTimeManager.set_current_hour(14)

# Set to midnight
PPTimeManager.set_current_hour(0)
```

---

### set_time

```gdscript
func set_time(day: int, hour: int) -> void
```

Sets the current day and hour.

**Parameters:**
- `day` (int) - Day to set (1+)
- `hour` (int) - Hour to set (0-23)

**Example:**
```gdscript
# Set to Day 5, 8am
PPTimeManager.set_time(5, 8)
```

---

### advance_hours

```gdscript
func advance_hours(hours: int) -> void
```

Advances time by a specific number of hours.

**Parameters:**
- `hours` (int) - Number of hours to advance

**Example:**
```gdscript
# Advance 3 hours
PPTimeManager.advance_hours(3)

# Fast travel (8 hours)
PPTimeManager.advance_hours(8)
```

---

### advance_days

```gdscript
func advance_days(days: int) -> void
```

Advances time by a specific number of days.

**Parameters:**
- `days` (int) - Number of days to advance

**Example:**
```gdscript
# Advance 1 day
PPTimeManager.advance_days(1)

# Time skip (7 days)
PPTimeManager.advance_days(7)
```

---

### set_time_scale

```gdscript
func set_time_scale(scale: float) -> void
```

Sets the time scale multiplier.

**Parameters:**
- `scale` (float) - Time scale (0.0 = paused, 1.0 = normal, 2.0 = 2x speed, etc.)

**Notes:**
- Scale is clamped to minimum 0.0
- At 1.0: 1 real second = 1 game second
- At 60.0: 1 real second = 1 game minute
- At 3600.0: 1 real second = 1 game hour

**Example:**
```gdscript
# Normal time
PPTimeManager.set_time_scale(1.0)

# Fast time (60x)
PPTimeManager.set_time_scale(60.0)

# Very fast (1 second = 1 hour)
PPTimeManager.set_time_scale(3600.0)

# Slow motion
PPTimeManager.set_time_scale(0.5)
```

---

### get_time_scale

```gdscript
func get_time_scale() -> float
```

Gets the current time scale.

**Returns:** `float` - Current time scale multiplier

**Example:**
```gdscript
var scale = PPTimeManager.get_time_scale()
print("Time is running at %.1fx speed" % scale)
```

---

### pause

```gdscript
func pause() -> void
```

Pauses time progression.

**Example:**
```gdscript
# Pause time
PPTimeManager.pause()

# Time stops advancing
```

---

### resume

```gdscript
func resume() -> void
```

Resumes time progression.

**Example:**
```gdscript
# Resume time
PPTimeManager.resume()
```

---

### toggle_pause

```gdscript
func toggle_pause() -> void
```

Toggles pause state.

**Example:**
```gdscript
# Toggle on/off
PPTimeManager.toggle_pause()
```

---

### is_paused

```gdscript
func is_paused() -> bool
```

Checks if time is paused.

**Returns:** `bool` - `true` if time is paused

**Example:**
```gdscript
if PPTimeManager.is_paused():
    print("Time is paused")
else:
    print("Time is running")
```

---

### get_world_time

```gdscript
func get_world_time() -> float
```

Gets total world time in seconds.

**Returns:** `float` - World time in seconds

**Example:**
```gdscript
var total_time = PPTimeManager.get_world_time()
print("Total game time: %.1f hours" % (total_time / 3600.0))
```

---

### get_current_hour

```gdscript
func get_current_hour() -> int
```

Gets current game hour (0-23).

**Returns:** `int` - Current hour

**Example:**
```gdscript
var hour = PPTimeManager.get_current_hour()
print("Current hour: %02d:00" % hour)
```

---

### get_current_day

```gdscript
func get_current_day() -> int
```

Gets current game day (1+).

**Returns:** `int` - Current day

**Example:**
```gdscript
var day = PPTimeManager.get_current_day()
print("Day %d" % day)
```

---

### get_formatted_time

```gdscript
func get_formatted_time(use_24h: bool = true) -> String
```

Gets current time formatted as string.

**Parameters:**
- `use_24h` (bool) - Use 24-hour format (default `true`)

**Returns:** `String` - Formatted time

**Example:**
```gdscript
# 24-hour format
var time_24 = PPTimeManager.get_formatted_time()
print(time_24)  # "14:30"

# 12-hour format
var time_12 = PPTimeManager.get_formatted_time(false)
print(time_12)  # "2:30 PM"
```

---

### get_formatted_datetime

```gdscript
func get_formatted_datetime() -> String
```

Gets current day and time formatted as string.

**Returns:** `String` - Formatted day and time

**Example:**
```gdscript
var datetime = PPTimeManager.get_formatted_datetime()
print(datetime)  # "Day 5, 14:30"
```

---

### is_daytime

```gdscript
func is_daytime(dawn_hour: int = 6, dusk_hour: int = 18) -> bool
```

Checks if it's currently daytime.

**Parameters:**
- `dawn_hour` (int) - Hour when day starts (default 6)
- `dusk_hour` (int) - Hour when night starts (default 18)

**Returns:** `bool` - `true` if daytime

**Example:**
```gdscript
if PPTimeManager.is_daytime():
    print("It's daytime!")

# Custom day/night hours
if PPTimeManager.is_daytime(5, 20):  # 5am - 8pm
    enable_outdoor_activities()
```

---

### is_nighttime

```gdscript
func is_nighttime(dawn_hour: int = 6, dusk_hour: int = 18) -> bool
```

Checks if it's currently nighttime.

**Parameters:**
- `dawn_hour` (int) - Hour when day starts (default 6)
- `dusk_hour` (int) - Hour when night starts (default 18)

**Returns:** `bool` - `true` if nighttime

**Example:**
```gdscript
if PPTimeManager.is_nighttime():
    spawn_nocturnal_enemies()
```

---

### get_time_period

```gdscript
func get_time_period() -> String
```

Gets time period name.

**Returns:** `String` - "Morning", "Afternoon", "Evening", or "Night"

**Time Periods:**
- Morning: 6am - 12pm
- Afternoon: 12pm - 6pm
- Evening: 6pm - 10pm
- Night: 10pm - 6am

**Example:**
```gdscript
var period = PPTimeManager.get_time_period()

match period:
    "Morning":
        print("Good morning!")
    "Afternoon":
        print("Good afternoon!")
    "Evening":
        print("Good evening!")
    "Night":
        print("It's late!")
```

---

### reset

```gdscript
func reset(starting_day: int = -1, starting_hour: int = -1) -> void
```

Clears all time state (for new game).

**Parameters:**
- `starting_day` (int) - Starting day (use -1 to use configured setting)
- `starting_hour` (int) - Starting hour (use -1 to use configured setting)

**Example:**
```gdscript
# Reset to configured defaults
PPTimeManager.reset()

# Reset to specific time
PPTimeManager.reset(1, 8)  # Day 1, 8am
```

---

### load_state

```gdscript
func load_state(game_state: PPGameState) -> void
```

Loads time state from GameState (called by SaveManager).

**Parameters:**
- `game_state` (PPGameState) - Game state instance

**Example:**
```gdscript
# Called automatically by PPSaveManager.restore_state()
# Manual usage:
var game_state = PPSaveManager.load_game(1)
if game_state:
    PPTimeManager.load_state(game_state)
```

---

### save_state

```gdscript
func save_state(game_state: PPGameState) -> void
```

Saves time state to GameState (called by SaveManager).

**Parameters:**
- `game_state` (PPGameState) - Game state instance to update

**Example:**
```gdscript
# Called automatically by PPSaveManager.save_game()
# Manual usage:
var game_state = PPGameState.new()
PPTimeManager.save_state(game_state)
```

---

### get_summary

```gdscript
func get_summary() -> String
```

Gets a debug summary of time state.

**Returns:** `String` - Summary text

**Example:**
```gdscript
print(PPTimeManager.get_summary())

# Output:
# TimeManager State:
#   Current Time: Day 5, 14:30
#   World Time: 432000.0 seconds (120.0 hours)
#   Time Period: Afternoon
#   Time Scale: 1.0x
#   Paused: No
```

---

## Usage Examples

### Day/Night Lighting System

```gdscript
extends DirectionalLight3D

func _ready():
    PPTimeManager.hour_changed.connect(_update_lighting)
    _update_lighting(0, PPTimeManager.get_current_hour())

func _update_lighting(_old: int, hour: int):
    # Rotate sun based on hour
    rotation_degrees.x = lerp(-90.0, 90.0, hour / 24.0)

    # Adjust lighting based on time period
    match PPTimeManager.get_time_period():
        "Morning":
            light_color = Color(1.0, 0.6, 0.4)  # Orange dawn
            light_energy = 0.7
        "Afternoon":
            light_color = Color(1.0, 1.0, 0.9)  # Bright day
            light_energy = 1.0
        "Evening":
            light_color = Color(1.0, 0.5, 0.3)  # Red dusk
            light_energy = 0.5
        "Night":
            light_color = Color(0.3, 0.4, 0.6)  # Blue moon
            light_energy = 0.2
```

### Clock UI Widget

```gdscript
extends Control

@onready var time_label: Label = $TimeLabel
@onready var day_label: Label = $DayLabel

func _ready():
    PPTimeManager.hour_changed.connect(_update_display)
    _update_display(0, PPTimeManager.get_current_hour())

    set_process(true)

func _process(_delta):
    # Update every frame for smooth seconds/minutes
    time_label.text = PPTimeManager.get_formatted_time()
    day_label.text = "Day %d" % PPTimeManager.get_current_day()
```

### Fast Travel System

```gdscript
func fast_travel_to(destination: String, hours: int):
    # Show travel screen
    show_fast_travel_screen(destination)

    # Speed up time dramatically
    var old_scale = PPTimeManager.get_time_scale()
    PPTimeManager.set_time_scale(3600.0)  # 1 second = 1 hour

    # Wait for travel duration
    await get_tree().create_timer(hours).timeout

    # Restore original time scale
    PPTimeManager.set_time_scale(old_scale)

    # Teleport and fade in
    teleport_to_location(destination)
    fade_in_from_black()

# Usage
fast_travel_to("Capital City", 8)  # 8-hour journey
```

### Rest Until Morning

```gdscript
func rest_at_inn():
    var current_hour = PPTimeManager.get_current_hour()

    # Calculate hours until 6am
    var hours_to_rest = 0
    if current_hour >= 6:
        hours_to_rest = 24 - current_hour + 6
    else:
        hours_to_rest = 6 - current_hour

    # Show resting screen
    show_rest_screen()

    # Advance time
    PPTimeManager.advance_hours(hours_to_rest)

    # Restore player health
    restore_player_health()

    # Wake up
    fade_in_from_rest()
```

### Shop Hours System

```gdscript
extends Node

@export var opening_hour: int = 8
@export var closing_hour: int = 20

var is_open: bool = false

func _ready():
    PPTimeManager.hour_changed.connect(_check_hours)
    _check_hours(0, PPTimeManager.get_current_hour())

func _check_hours(_old: int, hour: int):
    var should_open = hour >= opening_hour and hour < closing_hour

    if should_open != is_open:
        is_open = should_open

        if is_open:
            print("Shop opened!")
            update_shop_sign("OPEN")
        else:
            print("Shop closed!")
            update_shop_sign("CLOSED")
            kick_out_customers()

func on_player_interact():
    if not is_open:
        var msg = "Come back between %d:00 and %d:00" % [opening_hour, closing_hour]
        show_message(msg)
    else:
        show_shop_menu()
```

---

## See Also

- [Time Manager System](../core-systems/time-manager.md) - Complete system guide
- [Save/Load System](../core-systems/save-load-system.md) - Time persistence
- [NPC System](../core-systems/npc-system.md) - NPC schedule integration
- [💎 NPC Routine Tutorial](../tutorials/npc-routine.md) - Using time with NPC schedules

---

*API Reference for Pandora+ v1.0.0*
