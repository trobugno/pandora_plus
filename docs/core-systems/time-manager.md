# Time Manager

**✅ Core & Premium**

Complete guide to the Pandora+ Time Manager - world time tracking, day/night cycles, time progression, and NPC schedule integration.

---

## Overview

The **PPTimeManager** provides a robust time management system for tracking game world time, managing day/night cycles, and coordinating with NPC schedules. It integrates with the save system and provides flexible time manipulation.

**Key Features:**
- ⏰ **World Time Tracking** - Precise time tracking in seconds
- 🌅 **Day/Night Cycles** - 24-hour clock with day progression
- ⚡ **Time Scale** - Speed up or slow down time (0.5x to 10x)
- ⏸️ **Pause/Resume** - Pause time during menus or cutscenes
- 📅 **Day Tracking** - Track current game day
- 🔔 **Hour/Day Signals** - React to time changes
- 🔄 **NPC Schedule Integration** - Automatically updates NPC routines
- 💾 **Save/Load Support** - Persist time state across sessions

**Core Components:**
- **PPTimeManager** - Autoload singleton managing time
- World time (total seconds elapsed)
- Current hour (0-23) and day (1+)
- Time scale and pause state

---

## Quick Start

### Basic Time Usage

```gdscript
# Get current time
var hour = PPTimeManager.get_current_hour()  # 0-23
var day = PPTimeManager.get_current_day()    # 1+

print("Day %d, %02d:00" % [day, hour])  # "Day 5, 14:00"

# Get formatted time
var time_str = PPTimeManager.get_formatted_time()  # "14:30"
var datetime_str = PPTimeManager.get_formatted_datetime()  # "Day 5, 14:30"

# Check time period
if PPTimeManager.is_daytime():
	print("It's daytime!")

var period = PPTimeManager.get_time_period()  # "Morning", "Afternoon", "Evening", "Night"
```

### Listen to Time Changes

```gdscript
func _ready():
	# Hour changed
	PPTimeManager.hour_changed.connect(_on_hour_changed)

	# Day changed
	PPTimeManager.day_changed.connect(_on_day_changed)

func _on_hour_changed(old_hour: int, new_hour: int):
	print("Time changed: %02d:00 → %02d:00" % [old_hour, new_hour])

	# Update UI
	update_clock_display()

	# Check for special hours
	if new_hour == 22:
		print("Shops are closing!")

func _on_day_changed(old_day: int, new_day: int):
	print("New day: %d → %d" % [old_day, new_day])

	# Trigger daily events
	if new_day % 7 == 0:
		trigger_weekly_event()
```

---

## Configuration

### Project Settings

Settings are in **Project Settings** → `pandora_plus/config/time_manager/`:

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `starting_day` | int | 1 | Starting day for new game |
| `starting_hour` | int | 12 | Starting hour for new game (0-23) |
| `time_scale_default` | float | 1.0 | Default time scale multiplier |

### Example Configuration

```gdscript
# Set starting time
ProjectSettings.set_setting("pandora_plus/config/time_manager/starting_day", 1)
ProjectSettings.set_setting("pandora_plus/config/time_manager/starting_hour", 8)  # Start at 8am

# Set default time scale
ProjectSettings.set_setting("pandora_plus/config/time_manager/time_scale_default", 60.0)  # 1 minute = 1 hour
```

---

## Time Advancement

### Automatic Progression

Time advances automatically via `_process`:

```gdscript
# Time progresses automatically by default
# 1 real second = 1 game second (at time_scale 1.0)

# No code needed - time progresses in background
```

### Manual Time Advancement

```gdscript
# Advance time manually (useful for turn-based games)
PPTimeManager.advance_time(3600.0)  # Advance by 1 hour (3600 seconds)

# Advance by hours
PPTimeManager.advance_hours(2)  # Advance 2 hours

# Advance by days
PPTimeManager.advance_days(1)  # Advance 1 day
```

### Set Specific Time

```gdscript
# Set to specific hour
PPTimeManager.set_current_hour(14)  # Set to 2pm

# Set to specific day and hour
PPTimeManager.set_time(5, 8)  # Day 5, 8am

# Set world time directly (in seconds)
PPTimeManager.set_world_time(172800.0)  # 2 days worth of seconds
```

---

## Time Scale

### Speed Up/Slow Down Time

```gdscript
# Normal time (1.0 = 1 real second = 1 game second)
PPTimeManager.set_time_scale(1.0)

# Fast time (60.0 = 1 real minute = 1 game hour)
PPTimeManager.set_time_scale(60.0)

# Very fast (720.0 = 1 real minute = 12 game hours)
PPTimeManager.set_time_scale(720.0)

# Slow motion (0.5 = half speed)
PPTimeManager.set_time_scale(0.5)

# Get current time scale
var scale = PPTimeManager.get_time_scale()
print("Time is running at %.1fx speed" % scale)
```

### Dynamic Time Scale

```gdscript
# Speed up time during travel
func start_fast_travel():
	PPTimeManager.set_time_scale(3600.0)  # 1 second = 1 hour
	show_fast_travel_screen()

func end_fast_travel():
	PPTimeManager.set_time_scale(1.0)  # Back to normal
	hide_fast_travel_screen()

# Slow down time during combat
func enter_combat():
	PPTimeManager.set_time_scale(0.1)  # 10x slower

func exit_combat():
	PPTimeManager.set_time_scale(1.0)
```

### Listen to Time Scale Changes

```gdscript
PPTimeManager.time_scale_changed.connect(_on_time_scale_changed)

func _on_time_scale_changed(old_scale: float, new_scale: float):
	print("Time scale: %.1fx → %.1fx" % [old_scale, new_scale])

	if new_scale > 1.0:
		show_fast_forward_icon()
	else:
		hide_fast_forward_icon()
```

---

## Pause/Resume

### Pause Time

```gdscript
# Pause time progression
PPTimeManager.pause()

# Resume time progression
PPTimeManager.resume()

# Toggle pause
PPTimeManager.toggle_pause()

# Check if paused
if PPTimeManager.is_paused():
	print("Time is paused")
```

### Pause During Menus

```gdscript
# Pause time when opening menu
func _on_menu_opened():
	PPTimeManager.pause()
	get_tree().paused = true  # Pause game tree too

# Resume when closing menu
func _on_menu_closed():
	PPTimeManager.resume()
	get_tree().paused = false
```

### Selective Pause

```gdscript
# Pause time but keep UI animations running
func open_pause_menu():
	PPTimeManager.pause()  # Time stops
	# Don't pause tree - UI can still animate

func close_pause_menu():
	PPTimeManager.resume()
```

---

## Time Queries

### Get Current Time

```gdscript
# Get world time (total seconds)
var world_time = PPTimeManager.get_world_time()
print("Total time: %.1f seconds (%.1f hours)" % [
	world_time,
	world_time / 3600.0
])

# Get current hour (0-23)
var hour = PPTimeManager.get_current_hour()

# Get current day (1+)
var day = PPTimeManager.get_current_day()

# Get formatted strings
var time_24h = PPTimeManager.get_formatted_time(true)   # "14:30"
var time_12h = PPTimeManager.get_formatted_time(false)  # "2:30 PM"
var datetime = PPTimeManager.get_formatted_datetime()   # "Day 5, 14:30"
```

### Check Time Periods

```gdscript
# Check if daytime (6am - 6pm by default)
if PPTimeManager.is_daytime():
	enable_outdoor_activities()

# Check if nighttime
if PPTimeManager.is_nighttime():
	spawn_nocturnal_enemies()

# Custom dawn/dusk hours
if PPTimeManager.is_daytime(5, 20):  # 5am - 8pm
	print("Sun is up")

# Get time period name
var period = PPTimeManager.get_time_period()

match period:
	"Morning":   # 6am - 12pm
		print("Good morning!")
	"Afternoon": # 12pm - 6pm
		print("Good afternoon!")
	"Evening":   # 6pm - 10pm
		print("Good evening!")
	"Night":     # 10pm - 6am
		print("It's night time")
```

---

## Signals

### Hour Changed

```gdscript
PPTimeManager.hour_changed.connect(_on_hour_changed)

func _on_hour_changed(old_hour: int, new_hour: int):
	print("Hour: %d → %d" % [old_hour, new_hour])

	# Update clock UI
	clock_label.text = "%02d:00" % new_hour

	# Trigger hourly events
	check_shop_hours(new_hour)
	update_lighting(new_hour)
```

### Day Changed

```gdscript
PPTimeManager.day_changed.connect(_on_day_changed)

func _on_day_changed(old_day: int, new_day: int):
	print("Day: %d → %d" % [old_day, new_day])

	# Trigger daily events
	refresh_shop_inventories()
	spawn_daily_quest()

	# Check for special days
	if new_day % 7 == 0:
		trigger_market_day()
```

### Time Advanced

```gdscript
# Emitted every time advance_time is called
PPTimeManager.time_advanced.connect(_on_time_advanced)

func _on_time_advanced(delta_seconds: float):
	# Track playtime
	total_playtime += delta_seconds

	# Update animations
	update_sun_position()
```

### Time Scale Changed

```gdscript
PPTimeManager.time_scale_changed.connect(_on_scale_changed)

func _on_scale_changed(old_scale: float, new_scale: float):
	print("Scale: %.1fx → %.1fx" % [old_scale, new_scale])

	# Update UI indicator
	if new_scale > 1.0:
		speed_indicator.text = ">>%.0fx" % new_scale
		speed_indicator.visible = true
	else:
		speed_indicator.visible = false
```

---

## NPC Schedule Integration

### Automatic Schedule Updates

When hour changes, PPTimeManager automatically updates all NPC schedules:

```gdscript
# This happens automatically when hour changes
func _on_hour_changed(old_hour: int, new_hour: int):
	# PPTimeManager calls PPNPCManager.update_all_schedules(new_hour)
	# All NPCs with schedules are updated
	pass
```

### Manual Schedule Update

```gdscript
# Force update all NPC schedules
if has_node("/root/PPNPCManager"):
	PPNPCManager.update_all_schedules(PPTimeManager.get_current_hour())
```

---

## Common Patterns

### Pattern 1: Day/Night Lighting

```gdscript
extends DirectionalLight3D

func _ready():
	PPTimeManager.hour_changed.connect(_update_lighting)
	_update_lighting(0, PPTimeManager.get_current_hour())

func _update_lighting(_old: int, hour: int):
	# Adjust sun angle and color based on hour
	var t = hour / 24.0

	# Rotate sun
	rotation_degrees.x = lerp(-90, 90, t)

	# Adjust color
	if hour >= 6 and hour < 8:
		# Dawn - orange
		light_color = Color(1.0, 0.6, 0.4)
		light_energy = 0.5
	elif hour >= 8 and hour < 18:
		# Day - white
		light_color = Color(1.0, 1.0, 0.9)
		light_energy = 1.0
	elif hour >= 18 and hour < 20:
		# Dusk - orange/red
		light_color = Color(1.0, 0.5, 0.3)
		light_energy = 0.5
	else:
		# Night - blue
		light_color = Color(0.3, 0.4, 0.6)
		light_energy = 0.2
```

### Pattern 2: Clock UI

```gdscript
extends Label

func _ready():
	PPTimeManager.hour_changed.connect(_update_clock)
	_update_clock(0, PPTimeManager.get_current_hour())

	# Update every second for minutes
	set_process(true)

func _process(_delta):
	_update_clock(0, PPTimeManager.get_current_hour())

func _update_clock(_old: int, _new: int):
	text = PPTimeManager.get_formatted_time()

	# Show day on separate label
	if has_node("../DayLabel"):
		$"../DayLabel".text = "Day %d" % PPTimeManager.get_current_day()
```

### Pattern 3: Shop Hours

```gdscript
class_name Shop
extends Node

@export var opening_hour: int = 8   # 8am
@export var closing_hour: int = 20  # 8pm

var is_open: bool = false

func _ready():
	PPTimeManager.hour_changed.connect(_check_hours)
	_check_hours(0, PPTimeManager.get_current_hour())

func _check_hours(_old: int, hour: int):
	var should_be_open = hour >= opening_hour and hour < closing_hour

	if should_be_open != is_open:
		is_open = should_be_open

		if is_open:
			print("Shop is now OPEN")
			open_shop()
		else:
			print("Shop is now CLOSED")
			close_shop()

func on_player_interact():
	if not is_open:
		show_message("Come back between %d:00 and %d:00" % [opening_hour, closing_hour])
	else:
		show_shop_ui()
```

### Pattern 4: Fast Travel

```gdscript
func fast_travel_to(destination: String, travel_hours: int):
	# Show fast travel screen
	show_fast_travel_screen(destination)

	# Speed up time
	PPTimeManager.set_time_scale(3600.0)  # 1 second = 1 hour

	# Wait for travel duration
	await get_tree().create_timer(travel_hours).timeout

	# Restore normal time
	PPTimeManager.set_time_scale(1.0)

	# Fade in at destination
	fade_in_at_location(destination)

# Usage
fast_travel_to("Capital City", 8)  # 8 hour journey
```

### Pattern 5: Rest/Sleep

```gdscript
func rest_until_morning():
	var current_hour = PPTimeManager.get_current_hour()

	# Calculate hours until 6am
	var hours_to_sleep = 0
	if current_hour >= 6:
		hours_to_sleep = 24 - current_hour + 6
	else:
		hours_to_sleep = 6 - current_hour

	# Show rest screen
	show_rest_screen()

	# Advance time
	PPTimeManager.advance_hours(hours_to_sleep)

	# Restore health
	restore_player_health()

	# Fade in
	fade_in_from_rest()
```

### Pattern 6: Time-Based Quest

```gdscript
# Quest: Deliver package before 6pm

var quest_deadline_hour: int = 18  # 6pm

func _ready():
	PPTimeManager.hour_changed.connect(_check_deadline)

func _check_deadline(_old: int, hour: int):
	if hour >= quest_deadline_hour and not quest_completed:
		# Too late!
		fail_quest()
		show_message("You missed the deadline!")

func complete_delivery():
	var current_hour = PPTimeManager.get_current_hour()

	if current_hour < quest_deadline_hour:
		quest_completed = true
		show_message("Package delivered on time!")
	else:
		show_message("Too late! The deadline has passed.")
```

---

## State Management

### Reset Time (New Game)

```gdscript
# Reset to configured starting time
PPTimeManager.reset()

# Reset to specific time
PPTimeManager.reset(1, 8)  # Day 1, 8am
```

### Save/Load Integration

Time state is automatically saved/loaded by PPSaveManager:

```gdscript
# When saving
PPSaveManager.save_game(1)
# PPTimeManager.save_state() is called automatically

# When loading
PPSaveManager.load_and_apply(1)
# PPTimeManager.load_state() is called automatically

# Time is restored to saved state
print("Loaded time: %s" % PPTimeManager.get_formatted_datetime())
```

---

## Best Practices

### ✅ Use Signals for Time Events

```gdscript
# ✅ Good: reactive to time changes
PPTimeManager.hour_changed.connect(_on_hour_changed)

# ❌ Bad: polling every frame
func _process(_delta):
	var hour = PPTimeManager.get_current_hour()
	if hour != last_hour:
		_on_hour_changed(last_hour, hour)
		last_hour = hour
```

### ✅ Pause During Cutscenes

```gdscript
# ✅ Good: pause time during story moments
func play_cutscene():
	PPTimeManager.pause()
	await cutscene_player.finished
	PPTimeManager.resume()

# ❌ Bad: time keeps running during cutscene
func play_cutscene():
	cutscene_player.play()
```

### ✅ Restore Time Scale

```gdscript
# ✅ Good: save and restore time scale
var old_scale = PPTimeManager.get_time_scale()
PPTimeManager.set_time_scale(10.0)
# ... do something fast
PPTimeManager.set_time_scale(old_scale)

# ❌ Bad: assume time scale is 1.0
PPTimeManager.set_time_scale(10.0)
# ... do something
PPTimeManager.set_time_scale(1.0)  # May not be correct
```

---

## Debug Utilities

```gdscript
# Print time summary
var summary = PPTimeManager.get_summary()
print(summary)

# Output:
# TimeManager State:
#   Current Time: Day 5, 14:30
#   World Time: 432000.0 seconds (120.0 hours)
#   Time Period: Afternoon
#   Time Scale: 1.0x
#   Paused: No

# Manual time controls (for debugging)
func _input(event):
	if OS.is_debug_build():
		if event.is_action_pressed("debug_advance_hour"):
			PPTimeManager.advance_hours(1)

		if event.is_action_pressed("debug_advance_day"):
			PPTimeManager.advance_days(1)

		if event.is_action_pressed("debug_fast_time"):
			PPTimeManager.set_time_scale(60.0)

		if event.is_action_pressed("debug_normal_time"):
			PPTimeManager.set_time_scale(1.0)
```

---

## Troubleshooting

### Time Not Advancing

**Cause:** Time is paused

**Solution:**
```gdscript
if PPTimeManager.is_paused():
	print("Time is paused!")
	PPTimeManager.resume()
```

### Hour Not Changing

**Cause:** Time scale too slow

**Solution:**
```gdscript
var scale = PPTimeManager.get_time_scale()
print("Time scale: %.1fx" % scale)

# Increase for testing
PPTimeManager.set_time_scale(60.0)  # 1 minute = 1 hour
```

### NPC Schedules Not Updating

**Cause:** PPNPCManager not found or NPCs don't have schedules

**Solution:**
```gdscript
# Check if NPC manager exists
if not has_node("/root/PPNPCManager"):
	print("ERROR: PPNPCManager not found!")

# Check if NPCs have schedules
var npc_entity = Pandora.get_entity("npc_id") as PPNPCEntity
if not npc_entity.has_schedule():
	print("NPC has no schedule defined")
```

---

## See Also

- [Save/Load System](save-load-system.md) - Time persistence
- [NPC System](npc-system.md) - NPC schedule integration
- [💎 NPC Routine Tutorial](../tutorials/npc-routine.md) - NPC schedule setup

---

*Complete System Guide for Pandora+ v1.0.0*
