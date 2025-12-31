# 💎 NPC Routine System Tutorial

**Level:** Intermediate
**Time:** ~90 minutes
**Premium Feature:** This tutorial covers the NPC Schedule & Routine system, which is only available in **Pandora+ Premium**.

---

## Overview

Learn how to create dynamic NPCs with realistic daily routines using the **PPNPCSchedule** system. NPCs will move between locations, change activities based on time of day, and provide contextual interactions.

**What You'll Build:**
- 🕐 Time-based NPC schedules (hourly routines)
- 🗺️ Location transitions and pathfinding
- 💼 Activity-based interactions (working, sleeping, eating, etc.)
- 🎯 Dynamic NPC behavior system
- 🔄 Automatic schedule updates with time progression

**Prerequisites:**
- Completed "Create Your First RPG" tutorial
- Understanding of Pandora entities and time systems
- Familiarity with PPRuntimeNPC and PPNPCEntity

---

## Part 1: Understanding NPC Schedules

### What is a Schedule?

An NPC schedule defines **where** an NPC should be and **what** they should be doing at different times of the day.

**PPNPCSchedule Components:**
- **Schedule Entries**: Time ranges with locations and activities
- **Start/End Hours**: 24-hour format (0-23)
- **Locations**: PandoraReference to location entities
- **Activities**: String identifiers ("working", "sleeping", "eating", etc.)
- **Priority**: For resolving conflicting entries

### Example Schedule

A blacksmith's daily routine:

```
06:00-12:00 → Blacksmith Shop (working)
12:00-13:00 → Tavern (eating)
13:00-18:00 → Blacksmith Shop (working)
18:00-22:00 → Home (relaxing)
22:00-06:00 → Home (sleeping)
```

---

## Part 2: Creating Location Entities

Before creating schedules, define location entities where NPCs can be.

### Create Location Entities in Pandora

**Create three location entities:**

1. **Location: Blacksmith Shop**
   - Entity ID: `location_blacksmith`
   - Properties:
     - `name` (String): "Blacksmith Shop"
     - `position` (Vector3): Your shop coordinates
     - `scene_path` (String): Path to shop scene

2. **Location: Tavern**
   - Entity ID: `location_tavern`
   - Properties:
     - `name` (String): "The Prancing Pony"
     - `position` (Vector3): Your tavern coordinates
     - `scene_path` (String): Path to tavern scene

3. **Location: Blacksmith Home**
   - Entity ID: `location_blacksmith_home`
   - Properties:
     - `name` (String): "Blacksmith's Home"
     - `position` (Vector3): Your home coordinates
     - `scene_path` (String): Path to home scene

**Why separate entities?** This allows schedules to reference reusable location data and makes it easy to update locations without touching NPC schedules.

---

## Part 3: Creating Schedule Resources

### Create PPNPCSchedule Resource

**In Pandora Editor:**

1. Open your NPC entity (e.g., `npc_blacksmith`)
2. Add a new property:
   - Name: `schedule`
   - Type: `Resource`
   - Default Value: Create new **PPNPCSchedule**

3. Add another property:
   - Name: `has_schedule`
   - Type: `Bool`
   - Default Value: `true`

### Define Schedule Entries

**Via GDScript (for dynamic creation):**

```gdscript
# Create schedule resource
var schedule = PPNPCSchedule.new()

# Create location references
var shop_ref = PandoraReference.new("location_blacksmith", PandoraReference.Type.ENTITY)
var tavern_ref = PandoraReference.new("location_tavern", PandoraReference.Type.ENTITY)
var home_ref = PandoraReference.new("location_blacksmith_home", PandoraReference.Type.ENTITY)

# Add schedule entries
schedule.add_entry(6, 12, shop_ref, "working", 0)     # 6am-12pm: Working
schedule.add_entry(12, 13, tavern_ref, "eating", 0)   # 12pm-1pm: Eating
schedule.add_entry(13, 18, shop_ref, "working", 0)    # 1pm-6pm: Working
schedule.add_entry(18, 22, home_ref, "relaxing", 0)   # 6pm-10pm: Relaxing
schedule.add_entry(22, 6, home_ref, "sleeping", 0)    # 10pm-6am: Sleeping

# Set default location (fallback)
schedule.default_location = shop_ref

# Enable schedule
schedule.enabled = true
```

**Via Inspector (Pandora Editor):**

In the schedule resource, manually add entries using the Godot inspector:
- Expand `schedule_entries` array
- Add new `ScheduleEntry` for each time slot
- Set `start_hour`, `end_hour`, `location`, `activity`, `priority`

---

## Part 4: Setting Up Time Management

### Create Time Manager Singleton

Create `res://scripts/game_time_manager.gd`:

```gdscript
extends Node

## Singleton for managing game time progression
## Emits signals for hour changes to update NPC schedules

signal hour_changed(new_hour: int)
signal day_changed(new_day: int)

## Current game time
var current_hour: int = 8  # Start at 8am
var current_day: int = 1

## Time scale (1.0 = 1 real second = 1 game minute)
var time_scale: float = 1.0

## Internal timer
var _accumulated_time: float = 0.0

## Minutes in a game hour (60 real seconds = 1 game hour at time_scale 1.0)
const MINUTES_PER_HOUR: int = 60

func _ready() -> void:
	# Start time progression
	set_process(true)

func _process(delta: float) -> void:
	_accumulated_time += delta * time_scale

	# Check if an hour has passed (60 seconds)
	if _accumulated_time >= MINUTES_PER_HOUR:
		_accumulated_time -= MINUTES_PER_HOUR
		_advance_hour()

func _advance_hour() -> void:
	current_hour += 1

	# Wrap around midnight
	if current_hour >= 24:
		current_hour = 0
		current_day += 1
		day_changed.emit(current_day)

	hour_changed.emit(current_hour)
	print("Time: %02d:00 - Day %d" % [current_hour, current_day])

## Get current hour (0-23)
func get_current_hour() -> int:
	return current_hour

## Set current hour manually
func set_current_hour(hour: int) -> void:
	current_hour = clampi(hour, 0, 23)
	hour_changed.emit(current_hour)

## Get current day
func get_current_day() -> int:
	return current_day
```

**Register as Autoload:**
- Project Settings → Autoload
- Add `game_time_manager.gd` as `GameTime`

---

## Part 5: Implementing NPC with Schedule

### Create Scheduled NPC Scene

**Scene Structure:**
```
ScheduledNPC (CharacterBody3D)
├── CollisionShape3D
├── MeshInstance3D (Visual representation)
├── AnimationPlayer
├── Label3D (Shows current activity)
└── NavigationAgent3D (For movement)
```

### NPC Script with Schedule

Create `res://scripts/scheduled_npc.gd`:

```gdscript
class_name ScheduledNPC
extends CharacterBody3D

## NPC with schedule-based routine behavior

@export var npc_entity_id: String = "npc_blacksmith"
@export var movement_speed: float = 3.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var activity_label: Label3D = $Label3D

var runtime_npc: PPRuntimeNPC
var npc_entity: PPNPCEntity

var current_activity: String = "idle"
var target_location: Vector3
var is_moving: bool = false

func _ready() -> void:
	# Spawn runtime NPC
	npc_entity = Pandora.get_entity(npc_entity_id) as PPNPCEntity
	runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

	# Connect to time changes
	GameTime.hour_changed.connect(_on_hour_changed)

	# Initialize schedule
	if npc_entity.has_schedule():
		_update_schedule(GameTime.get_current_hour())

	# Setup navigation
	nav_agent.target_reached.connect(_on_target_reached)

func _physics_process(delta: float) -> void:
	if is_moving and not nav_agent.is_navigation_finished():
		var next_position = nav_agent.get_next_path_position()
		var direction = (next_position - global_position).normalized()

		velocity = direction * movement_speed
		move_and_slide()

		# Rotate to face movement direction
		if direction.length() > 0.01:
			look_at(global_position + direction, Vector3.UP)

func _on_hour_changed(new_hour: int) -> void:
	print("%s: Hour changed to %d" % [runtime_npc.get_npc_name(), new_hour])
	_update_schedule(new_hour)

func _update_schedule(hour: int) -> void:
	if not npc_entity.has_schedule():
		return

	var schedule = npc_entity.get_schedule()

	# Get new activity
	var new_activity = schedule.get_activity_at_time(hour)

	# Get new location
	var location_entity = schedule.get_location_at_time(hour)

	if new_activity != current_activity:
		print("%s is now %s" % [runtime_npc.get_npc_name(), new_activity])
		current_activity = new_activity
		activity_label.text = new_activity.capitalize()

		# Trigger activity change
		_on_activity_changed(new_activity)

	# Move to new location if different
	if location_entity:
		var new_position = location_entity.get_vector3("position")
		if global_position.distance_to(new_position) > 1.0:
			_move_to_location(new_position)

func _move_to_location(position: Vector3) -> void:
	target_location = position
	nav_agent.target_position = position
	is_moving = true
	print("%s moving to new location" % runtime_npc.get_npc_name())

func _on_target_reached() -> void:
	is_moving = false
	velocity = Vector3.ZERO
	print("%s arrived at destination" % runtime_npc.get_npc_name())

func _on_activity_changed(activity: String) -> void:
	# Customize behavior based on activity
	match activity:
		"working":
			# Play working animation
			if has_node("AnimationPlayer"):
				$AnimationPlayer.play("work")

		"sleeping":
			# Play sleeping animation
			if has_node("AnimationPlayer"):
				$AnimationPlayer.play("sleep")

		"eating":
			# Play eating animation
			if has_node("AnimationPlayer"):
				$AnimationPlayer.play("eat")

		"relaxing":
			# Play idle/relaxing animation
			if has_node("AnimationPlayer"):
				$AnimationPlayer.play("relax")

## Handle player interaction
func on_player_interact() -> void:
	if not PPNPCUtils.can_interact_with_npc(runtime_npc):
		print("Cannot interact with %s" % runtime_npc.get_npc_name())
		return

	# Customize dialogue based on activity
	match current_activity:
		"working":
			show_working_dialogue()

		"sleeping":
			print("%s is sleeping. Come back later." % runtime_npc.get_npc_name())
			return

		"eating":
			show_casual_dialogue()

		_:
			show_default_dialogue()

func show_working_dialogue() -> void:
	print("[%s] Welcome! How can I help you?" % runtime_npc.get_npc_name())
	# Show merchant UI or quest dialogue

func show_casual_dialogue() -> void:
	print("[%s] Enjoying a meal. Join me?" % runtime_npc.get_npc_name())
	# Show casual conversation

func show_default_dialogue() -> void:
	print("[%s] Hello there." % runtime_npc.get_npc_name())
```

---

## Part 6: Activity-Based Interactions

### Contextual NPC Responses

Enhance interactions based on current activity:

```gdscript
func get_dialogue_for_activity(activity: String) -> String:
	var dialogues = {
		"working": [
			"Need something crafted?",
			"I'm quite busy right now, but I can help.",
			"Best prices in town!"
		],
		"sleeping": [
			"*Snore*... Come back later...",
			"It's the middle of the night!",
			"I need my rest. Come back in the morning."
		],
		"eating": [
			"Care to join me for a meal?",
			"This stew is excellent!",
			"Just taking a quick break."
		],
		"relaxing": [
			"Ah, finally some rest.",
			"Long day at the forge.",
			"How are you doing?"
		]
	}

	var options = dialogues.get(activity, ["Hello."])
	return options[randi() % options.size()]
```

### Merchant Hours

Restrict merchant access to working hours:

```gdscript
func try_open_shop() -> bool:
	if current_activity != "working":
		print("Shop is closed. Come back during working hours (6am-12pm, 1pm-6pm).")
		return false

	# Open merchant UI
	open_merchant_ui()
	return true

func open_merchant_ui() -> void:
	if not runtime_npc.is_merchant():
		return

	# Get shop inventory
	var shop_inventory = runtime_npc.get_shop_inventory()

	# Show merchant interface
	# ... (implement your merchant UI)
```

---

## Part 7: Advanced Schedule Patterns

### Pattern 1: Patrol Routes

Create NPCs that patrol multiple locations:

```gdscript
# Guard patrols town square and gates
var schedule = PPNPCSchedule.new()

var square_ref = PandoraReference.new("location_town_square", PandoraReference.Type.ENTITY)
var gate1_ref = PandoraReference.new("location_north_gate", PandoraReference.Type.ENTITY)
var gate2_ref = PandoraReference.new("location_south_gate", PandoraReference.Type.ENTITY)

# Create patrol route with 2-hour intervals
schedule.add_entry(6, 8, square_ref, "patrolling", 0)
schedule.add_entry(8, 10, gate1_ref, "patrolling", 0)
schedule.add_entry(10, 12, gate2_ref, "patrolling", 0)
schedule.add_entry(12, 14, square_ref, "patrolling", 0)
# ... continue pattern
```

### Pattern 2: Dynamic Schedules

Modify schedules at runtime based on events:

```gdscript
func change_schedule_on_event(event_name: String) -> void:
	match event_name:
		"festival_started":
			# Everyone goes to town square
			change_all_activities_to("celebrating", "location_town_square")

		"attack_alert":
			# Guards go to walls, civilians go home
			if npc_entity.get_faction() == "Town Guard":
				change_activity_to("defending", "location_town_walls")
			else:
				change_activity_to("hiding", "location_blacksmith_home")

func change_activity_to(activity: String, location_id: String) -> void:
	var schedule = npc_entity.get_schedule()

	# Clear current entries
	schedule.clear_entries()

	# Add new single entry for entire day
	var location_ref = PandoraReference.new(location_id, PandoraReference.Type.ENTITY)
	schedule.add_entry(0, 24, location_ref, activity, 100)  # High priority

	# Force update
	_update_schedule(GameTime.get_current_hour())
```

### Pattern 3: Conditional Schedules

Different schedules for different days:

```gdscript
func _update_schedule(hour: int) -> void:
	var schedule = npc_entity.get_schedule()
	var day = GameTime.get_current_day()

	# Different schedule on Sundays (day 7, 14, 21, etc.)
	if day % 7 == 0:
		# Sunday: Rest day, stay home
		var home_ref = PandoraReference.new("location_blacksmith_home", PandoraReference.Type.ENTITY)
		var location = home_ref.get_entity()
		var position = location.get_vector3("position")
		_move_to_location(position)
		current_activity = "resting"
	else:
		# Weekday: Normal schedule
		var new_activity = schedule.get_activity_at_time(hour)
		var location_entity = schedule.get_location_at_time(hour)
		# ... normal schedule logic
```

---

## Part 8: Schedule Manager System

Create a centralized manager for all scheduled NPCs:

```gdscript
extends Node
class_name NPCScheduleManager

## Manages all NPCs with schedules

var scheduled_npcs: Array[ScheduledNPC] = []

func _ready() -> void:
	GameTime.hour_changed.connect(_on_hour_changed)

func register_npc(npc: ScheduledNPC) -> void:
	if npc not in scheduled_npcs:
		scheduled_npcs.append(npc)
		print("Registered %s for schedule management" % npc.runtime_npc.get_npc_name())

func unregister_npc(npc: ScheduledNPC) -> void:
	scheduled_npcs.erase(npc)

func _on_hour_changed(new_hour: int) -> void:
	print("=== Hour %d: Updating %d NPCs ===" % [new_hour, scheduled_npcs.size()])

	for npc in scheduled_npcs:
		if npc and is_instance_valid(npc):
			npc._update_schedule(new_hour)

## Get all NPCs currently doing a specific activity
func get_npcs_by_activity(activity: String) -> Array[ScheduledNPC]:
	var result: Array[ScheduledNPC] = []

	for npc in scheduled_npcs:
		if npc.current_activity == activity:
			result.append(npc)

	return result

## Get all NPCs at a specific location
func get_npcs_at_location(location_id: String) -> Array[ScheduledNPC]:
	var result: Array[ScheduledNPC] = []
	var target_entity = Pandora.get_entity(location_id)

	if not target_entity:
		return result

	var target_pos = target_entity.get_vector3("position")

	for npc in scheduled_npcs:
		if npc.global_position.distance_to(target_pos) < 5.0:  # Within 5 meters
			result.append(npc)

	return result

## Debug: Print all NPC activities
func debug_print_activities() -> void:
	print("=== Current NPC Activities ===")
	for npc in scheduled_npcs:
		print("- %s: %s" % [npc.runtime_npc.get_npc_name(), npc.current_activity])
```

---

## Part 9: Visual Feedback & Debugging

### Schedule Debugger UI

Create a debug panel to view NPC schedules:

```gdscript
extends PanelContainer

@onready var schedule_list: ItemList = $VBox/ScheduleList
@onready var current_time: Label = $VBox/TimeLabel

func _ready() -> void:
	GameTime.hour_changed.connect(_update_display)
	_update_display(GameTime.get_current_hour())

func _update_display(hour: int) -> void:
	current_time.text = "Current Time: %02d:00" % hour

	schedule_list.clear()

	# Get all NPCs from manager
	var npcs = NPCScheduleManager.scheduled_npcs

	for npc in npcs:
		var text = "%s - %s @ %s" % [
			npc.runtime_npc.get_npc_name(),
			npc.current_activity,
			_get_location_name(npc)
		]
		schedule_list.add_item(text)

func _get_location_name(npc: ScheduledNPC) -> String:
	if npc.npc_entity.has_schedule():
		var schedule = npc.npc_entity.get_schedule()
		var location = schedule.get_location_at_time(GameTime.get_current_hour())
		if location:
			return location.get_string("name")
	return "Unknown"
```

### In-World Activity Indicators

Show activity above NPCs:

```gdscript
# In ScheduledNPC script
func _update_activity_indicator() -> void:
	var color: Color

	match current_activity:
		"working":
			color = Color.YELLOW
			activity_label.text = "💼 Working"
		"sleeping":
			color = Color.BLUE
			activity_label.text = "😴 Sleeping"
		"eating":
			color = Color.GREEN
			activity_label.text = "🍽️ Eating"
		"relaxing":
			color = Color.ORANGE
			activity_label.text = "🛋️ Relaxing"
		_:
			color = Color.WHITE
			activity_label.text = current_activity.capitalize()

	activity_label.modulate = color
```

---

## Part 10: Complete Example - Village Life

### Creating a Living Village

Set up multiple NPCs with coordinated schedules:

**NPCs:**
1. **Blacksmith** - Works at forge, eats at tavern
2. **Innkeeper** - Always at tavern
3. **Guard** - Patrols town
4. **Farmer** - Works at farm, sells at market

```gdscript
extends Node3D

func _ready() -> void:
	create_blacksmith_schedule()
	create_innkeeper_schedule()
	create_guard_schedule()
	create_farmer_schedule()

func create_blacksmith_schedule() -> void:
	var entity = Pandora.get_entity("npc_blacksmith") as PPNPCEntity
	var schedule = entity.get_schedule()

	var forge = PandoraReference.new("location_forge", PandoraReference.Type.ENTITY)
	var tavern = PandoraReference.new("location_tavern", PandoraReference.Type.ENTITY)
	var home = PandoraReference.new("location_blacksmith_home", PandoraReference.Type.ENTITY)

	schedule.add_entry(6, 12, forge, "working", 0)
	schedule.add_entry(12, 13, tavern, "eating", 0)
	schedule.add_entry(13, 18, forge, "working", 0)
	schedule.add_entry(18, 22, home, "relaxing", 0)
	schedule.add_entry(22, 6, home, "sleeping", 0)

func create_guard_schedule() -> void:
	var entity = Pandora.get_entity("npc_guard") as PPNPCEntity
	var schedule = entity.get_schedule()

	var square = PandoraReference.new("location_square", PandoraReference.Type.ENTITY)
	var gate_n = PandoraReference.new("location_north_gate", PandoraReference.Type.ENTITY)
	var gate_s = PandoraReference.new("location_south_gate", PandoraReference.Type.ENTITY)
	var barracks = PandoraReference.new("location_barracks", PandoraReference.Type.ENTITY)

	# 4-hour patrol shifts
	schedule.add_entry(6, 10, square, "patrolling", 0)
	schedule.add_entry(10, 14, gate_n, "patrolling", 0)
	schedule.add_entry(14, 18, gate_s, "patrolling", 0)
	schedule.add_entry(18, 22, square, "patrolling", 0)
	schedule.add_entry(22, 6, barracks, "sleeping", 0)

func create_farmer_schedule() -> void:
	var entity = Pandora.get_entity("npc_farmer") as PPNPCEntity
	var schedule = entity.get_schedule()

	var farm = PandoraReference.new("location_farm", PandoraReference.Type.ENTITY)
	var market = PandoraReference.new("location_market", PandoraReference.Type.ENTITY)
	var home = PandoraReference.new("location_farmer_home", PandoraReference.Type.ENTITY)

	schedule.add_entry(5, 8, farm, "farming", 0)      # Early morning farming
	schedule.add_entry(8, 12, market, "selling", 0)   # Morning market
	schedule.add_entry(12, 13, home, "eating", 0)
	schedule.add_entry(13, 17, farm, "farming", 0)    # Afternoon farming
	schedule.add_entry(17, 20, home, "relaxing", 0)
	schedule.add_entry(20, 5, home, "sleeping", 0)
```

---

## Testing Checklist

**Schedule Setup:**
- [ ] NPCs have schedule resources defined
- [ ] Location entities exist and have positions
- [ ] Schedule entries cover full 24-hour day
- [ ] Default location is set for fallback

**Time System:**
- [ ] GameTime manager is registered as autoload
- [ ] Hour changes emit signals correctly
- [ ] NPCs respond to time changes
- [ ] Time scale can be adjusted for testing

**NPC Behavior:**
- [ ] NPCs move to correct locations at scheduled times
- [ ] Activities change according to schedule
- [ ] Animations play for different activities
- [ ] Navigation works without errors

**Interactions:**
- [ ] Contextual dialogue based on activity
- [ ] Cannot interact during "sleeping" activity
- [ ] Merchant only available during "working" hours
- [ ] Quest availability considers schedule

**Advanced Features:**
- [ ] Multiple NPCs with different schedules
- [ ] Patrol routes work correctly
- [ ] Dynamic schedule changes work
- [ ] Schedule manager tracks all NPCs

---

## Best Practices

### ✅ Use Meaningful Activity Names

```gdscript
# ✅ Good: descriptive activities
"working", "sleeping", "eating", "patrolling", "praying"

# ❌ Bad: vague activities
"activity1", "doing_stuff", "idle"
```

### ✅ Handle Midnight Wraparound

```gdscript
# ✅ Good: correctly handle overnight schedules
schedule.add_entry(22, 6, home, "sleeping", 0)  # 10pm to 6am

# The ScheduleEntry.is_active_at_time() handles wraparound automatically
```

### ✅ Set Appropriate Priorities

```gdscript
# ✅ Good: use priority for special events
schedule.add_entry(0, 24, festival, "celebrating", 100)  # Override normal schedule

# ❌ Bad: all entries same priority with overlaps
schedule.add_entry(12, 14, location1, "activity1", 0)
schedule.add_entry(13, 15, location2, "activity2", 0)  # Conflict at hour 13!
```

### ✅ Provide Visual Feedback

```gdscript
# ✅ Good: show current activity to player
activity_label.text = current_activity.capitalize()
activity_label.visible = true

# ❌ Bad: no indication of NPC state
# (Player confused why merchant won't trade)
```

---

## Troubleshooting

### NPC Not Moving to Scheduled Location

**Causes:**
- Navigation mesh not baked
- Location position is invalid
- NavigationAgent3D not configured

**Solution:**
```gdscript
# Check if navigation is ready
if not nav_agent.is_navigation_finished():
	print("Navigation in progress")

# Verify location has valid position
var location = schedule.get_location_at_time(hour)
if location:
	print("Target location: ", location.get_vector3("position"))
else:
	print("ERROR: No location entity found!")
```

### Schedule Not Updating

**Cause:** Not connected to time signals

**Solution:**
```gdscript
func _ready():
	# Ensure connection to time manager
	if not GameTime.hour_changed.is_connected(_on_hour_changed):
		GameTime.hour_changed.connect(_on_hour_changed)
```

### Activity Conflicts

**Cause:** Overlapping schedule entries without priorities

**Solution:**
```gdscript
# Use priorities to resolve conflicts
schedule.add_entry(12, 14, tavern, "eating", 10)      # Higher priority
schedule.add_entry(12, 18, shop, "working", 0)        # Lower priority

# At hour 12-14, NPC will be eating (priority 10 > 0)
```

---

## Next Steps

**Enhance Your System:**
- Add weather-based schedule changes
- Implement NPC conversations at shared locations
- Create quest objectives that require specific times/activities
- Add reputation bonuses for catching NPCs at work vs rest

**See Also:**
- [NPC System](../core-systems/npc-system.md) - Core NPC features
- [PPNPCUtils](../utilities/npc-utils.md) - Schedule utilities
- [Player Data](../core-systems/player-data.md) - Save/load schedules
- [Quest System](../core-systems/quest-system.md) - Time-based quests

---

*Tutorial for Pandora+ Premium v1.0.0*
