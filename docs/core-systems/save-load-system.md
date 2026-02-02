# Save/Load System

**✅ Core & Premium**

Complete guide to the Pandora+ Save/Load System - robust save file management with multiple slots, autosave, quicksave, and JSON-based storage.

---

## Overview

The Pandora+ Save/Load System provides a production-ready save/load framework that handles all game state persistence. It integrates seamlessly with all Pandora managers (Player, Quest, NPC, Time) to save and restore complete game state.

**Key Features:**
- 🗂️ **Multiple Save Slots** - Configurable number of save slots (1-20)
- 💾 **Autosave System** - Automatic saves at configurable intervals
- ⚡ **Quicksave/Quickload** - Instant save/load for player convenience
- 📝 **JSON Format** - Human-readable save files for debugging
- 📊 **Save Slot Metadata** - Display save info without loading entire file
- 🔄 **Version Checking** - Compatibility checking for save migration
- 🎯 **Centralized Management** - PPSaveManager singleton handles all operations

**Core Components:**
- **PPSaveManager** - Autoload singleton for save/load operations
- **PPSaveSlot** - Metadata about individual save slots
- **PPGameState** - Container for complete game state

---

## Quick Start

### Basic Save Operation

```gdscript
# Save to slot 1
var success = PPSaveManager.save_game(1)

if success:
	print("Game saved successfully!")
else:
	print("Save failed!")

# Listen to save events
PPSaveManager.save_completed.connect(_on_save_completed)

func _on_save_completed(slot_id: Variant, success: bool):
	if success:
		show_notification("Game Saved")
```

### Basic Load Operation

```gdscript
# Load from slot 1
var success = PPSaveManager.load_and_apply(1)

if success:
	print("Game loaded successfully!")
	get_tree().change_scene_to_file("res://scenes/game.tscn")
else:
	print("Load failed!")

# Listen to load events
PPSaveManager.load_completed.connect(_on_load_completed)

func _on_load_completed(slot_id: Variant, success: bool, game_state: Variant):
	if success:
		print("Loaded save from: %s" % game_state.meta.get("timestamp", "Unknown"))
```

---

## Configuration

### Project Settings

All settings are in **Project Settings** → `pandora_plus/config/save_system/`:

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `max_save_slots` | int | 3 | Number of save slots (1-20) |
| `autosave_enabled` | bool | true | Enable autosave |
| `autosave_interval_seconds` | float | 300.0 | Autosave interval (30-3600s) |
| `save_directory` | String | "user://saves/" | Directory for save files |
| `save_file_extension` | String | ".json" | File extension for saves |

### Example Configuration

```gdscript
# In project.godot or via code
ProjectSettings.set_setting("pandora_plus/config/save_system/max_save_slots", 5)
ProjectSettings.set_setting("pandora_plus/config/save_system/autosave_interval_seconds", 600.0)  # 10 minutes
```

---

## Save Slots

### Slot Types

**Numbered Slots** (1 to max_save_slots):
```gdscript
# Save to slot 1, 2, 3, etc.
PPSaveManager.save_game(1)
PPSaveManager.save_game(2)
```

**Named Slots**:
```gdscript
# Autosave slot
PPSaveManager.autosave()  # Equivalent to save_game("autosave")

# Quicksave slot
PPSaveManager.quicksave()  # Equivalent to save_game("quicksave")
```

### Get Save Slot Metadata

```gdscript
# Get all save slots
var slots = PPSaveManager.get_save_slots()  # Array of PPSaveSlot

for slot in slots:
	if not slot.is_empty:
		print("Slot %d: %s - %s" % [
			slot.slot_id,
			slot.player_name,
			slot.get_formatted_date()
		])
```

### Check if Save Exists

```gdscript
# Check specific slot
if PPSaveManager.has_save(1):
	print("Slot 1 has a save")
else:
	print("Slot 1 is empty")
```

### Delete Save

```gdscript
# Delete save from slot 1
var deleted = PPSaveManager.delete_save(1)

if deleted:
	print("Save deleted")

# Listen to delete events
PPSaveManager.save_deleted.connect(_on_save_deleted)

func _on_save_deleted(slot_id: Variant):
	print("Save deleted from slot: %s" % slot_id)
	refresh_save_menu()
```

---

## Save Operations

### Manual Save

```gdscript
# Save to numbered slot
PPSaveManager.save_game(1)

# Save starts signal
PPSaveManager.save_started.connect(_on_save_started)

func _on_save_started(slot_id: Variant):
	show_saving_indicator()

# Save completes signal
PPSaveManager.save_completed.connect(_on_save_completed)

func _on_save_completed(slot_id: Variant, success: bool):
	hide_saving_indicator()

	if success:
		show_notification("Game Saved to Slot %s" % slot_id)
	else:
		show_error("Failed to save game")
```

### Autosave

Automatic saves occur at the configured interval:

```gdscript
# Autosave happens automatically, but you can trigger manually
PPSaveManager.autosave()

# Listen to autosave trigger
PPSaveManager.autosave_triggered.connect(_on_autosave)

func _on_autosave():
	print("Autosaving...")
	show_autosave_icon()
	await get_tree().create_timer(2.0).timeout
	hide_autosave_icon()

# Reset autosave timer (e.g., after manual save)
PPSaveManager.save_game(1)
PPSaveManager.reset_autosave_timer()  # Prevent immediate autosave
```

### Quicksave/Quickload

```gdscript
# Quicksave (F5 key example)
func _input(event):
	if event.is_action_pressed("quicksave"):
		PPSaveManager.quicksave()
		show_notification("Quicksaved")

	elif event.is_action_pressed("quickload"):
		var game_state = PPSaveManager.quickload()
		if game_state:
			PPSaveManager.restore_state(game_state)
			show_notification("Quickloaded")
```

---

## Load Operations

### Load Game State

```gdscript
# Load game state (doesn't apply it)
var game_state = PPSaveManager.load_game(1)

if game_state:
	print("Loaded save:")
	print("  Player: %s" % game_state.player_data.get("player_name", "Unknown"))
	print("  Playtime: %.1f hours" % (game_state.meta.get("playtime", 0.0) / 3600.0))

	# Manually restore state
	PPSaveManager.restore_state(game_state)
else:
	print("Failed to load save")
```

### Load and Apply

Convenience method that loads and immediately applies state:

```gdscript
# Load and apply in one call
var success = PPSaveManager.load_and_apply(1)

if success:
	# State has been restored to all managers
	# Change to game scene
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
else:
	show_error("Failed to load save file")
```

### Restore State to Managers

```gdscript
# Manual state restoration
var game_state = PPSaveManager.load_game(1)

if game_state:
	# Restore to all managers
	PPSaveManager.restore_state(game_state)

	# State is now applied to:
	# - PPPlayerManager (player data, inventory, stats)
	# - PPQuestManager (active quests, completed quests)
	# - PPNPCManager (NPC states)
	# - PPTimeManager (world time, day/hour)
```

---

## Save File Format

### JSON Structure

Saves are stored as human-readable JSON:

```json
{
	"version": "1.0.0",
	"timestamp": 1699012345.678,
	"game_state": {
		"player_data": {
			"basic_info": {
				"player_name": "Hero",
				"level": 5
			},
			"inventory": { ... },
			"stats": { ... }
		},
		"quest_data": {
			"active_quests": [ ... ],
			"completed_quest_ids": [ ... ]
		},
		"npc_data": {
			"spawned_npcs": [ ... ]
		},
		"time_data": {
			"world_time": 86400.0,
			"current_hour": 12,
			"current_day": 2
		},
		"meta": {
			"playtime": 7200.0,
			"save_location": "res://scenes/town.tscn"
		}
	}
}
```

### File Location

Default: `user://saves/`
- Windows: `%APPDATA%\Godot\app_userdata\[project_name]\saves\`
- Linux: `~/.local/share/godot/app_userdata/[project_name]/saves/`
- macOS: `~/Library/Application Support/Godot/app_userdata/[project_name]/saves/`

**File Names:**
- Numbered slots: `slot_1.json`, `slot_2.json`, etc.
- Autosave: `autosave.json`
- Quicksave: `quicksave.json`

---

## PPSaveSlot Metadata

### Properties

```gdscript
var slot = PPSaveManager.get_save_slot(1)

# Slot identification
print(slot.slot_id)          # 1 (int or string)
print(slot.is_empty)         # false if save exists

# Player info
print(slot.player_name)      # "Hero"
print(slot.playtime)         # 7200.0 (in seconds)

# 💎 Premium only
print(slot.level)            # 5 (player level)

# Save info
print(slot.timestamp)        # 1699012345.678 (Unix timestamp)
print(slot.save_version)     # "1.0.0"
print(slot.location)         # "Town Square"
```

### Display Methods

```gdscript
var slot = PPSaveManager.get_save_slot(1)

# Formatted display strings
print(slot.get_slot_name())           # "Slot 1"
print(slot.get_formatted_date())      # "2024-11-03 14:32"
print(slot.get_formatted_playtime())  # "2h 0m"
print(slot.get_summary_line())        # "Slot 1: Hero - Town Square - 2024-11-03 14:32"

# Version compatibility
if slot.is_compatible("1.0.0"):
	print("Save is compatible with current version")
```

---

## Signals

### Save Signals

```gdscript
# Save operation started
PPSaveManager.save_started.connect(func(slot_id):
	print("Saving to slot %s..." % slot_id)
)

# Save operation completed
PPSaveManager.save_completed.connect(func(slot_id, success):
	if success:
		print("Saved to slot %s" % slot_id)
	else:
		print("Save failed for slot %s" % slot_id)
)

# Autosave triggered
PPSaveManager.autosave_triggered.connect(func():
	print("Autosaving...")
)

# Save deleted
PPSaveManager.save_deleted.connect(func(slot_id):
	print("Deleted save from slot %s" % slot_id)
)
```

### Load Signals

```gdscript
# Load operation started
PPSaveManager.load_started.connect(func(slot_id):
	print("Loading from slot %s..." % slot_id)
	show_loading_screen()
)

# Load operation completed
PPSaveManager.load_completed.connect(func(slot_id, success, game_state):
	hide_loading_screen()

	if success:
		print("Loaded from slot %s" % slot_id)
		# game_state is available here
	else:
		print("Load failed for slot %s" % slot_id)
)
```

---

## Common Patterns

### Pattern 1: Save Menu UI

```gdscript
extends Control

@onready var save_list: ItemList = $SaveList

func _ready():
	refresh_save_slots()

	# Connect to updates
	PPSaveManager.save_completed.connect(_on_save_completed)
	PPSaveManager.save_deleted.connect(_on_save_deleted)

func refresh_save_slots():
	save_list.clear()

	var slots = PPSaveManager.get_save_slots()

	for slot in slots:
		var text = ""

		if slot.is_empty:
			text = "%s: Empty" % slot.get_slot_name()
		else:
			text = "%s\n  %s - Level %d\n  %s - %s" % [
				slot.get_slot_name(),
				slot.player_name,
				slot.level,  # 💎 Premium
				slot.location,
				slot.get_formatted_date()
			]

		save_list.add_item(text)

func _on_save_button_pressed():
	var selected = save_list.get_selected_items()
	if selected.is_empty():
		return

	var slot_number = selected[0] + 1
	PPSaveManager.save_game(slot_number)

func _on_save_completed(slot_id, success):
	if success:
		refresh_save_slots()

func _on_save_deleted(slot_id):
	refresh_save_slots()
```

### Pattern 2: Load Menu UI

```gdscript
extends Control

@onready var load_list: ItemList = $LoadList

func _ready():
	refresh_save_slots()

func refresh_save_slots():
	load_list.clear()

	var slots = PPSaveManager.get_save_slots()

	for slot in slots:
		if slot.is_empty:
			load_list.add_item("%s: Empty" % slot.get_slot_name())
			load_list.set_item_disabled(load_list.get_item_count() - 1, true)
		else:
			load_list.add_item(slot.get_summary_line())

func _on_load_button_pressed():
	var selected = load_list.get_selected_items()
	if selected.is_empty():
		return

	var slot_number = selected[0] + 1

	# Show confirmation
	var slot = PPSaveManager.get_save_slot(slot_number)
	if slot.is_empty:
		return

	# Load and apply
	var success = PPSaveManager.load_and_apply(slot_number)

	if success:
		# Transition to game
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_delete_button_pressed():
	var selected = load_list.get_selected_items()
	if selected.is_empty():
		return

	var slot_number = selected[0] + 1

	# Show confirmation dialog
	var confirm = ConfirmationDialog.new()
	confirm.dialog_text = "Delete this save?"
	add_child(confirm)
	confirm.popup_centered()

	confirm.confirmed.connect(func():
		PPSaveManager.delete_save(slot_number)
		refresh_save_slots()
	)
```

### Pattern 3: Auto-Save Before Quit

```gdscript
extends Node

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Auto-save before quitting
		print("Saving before quit...")
		PPSaveManager.autosave()

		# Wait for save to complete
		await PPSaveManager.save_completed

		get_tree().quit()
```

### Pattern 4: New Game Initialization

```gdscript
func start_new_game():
	# Clear all managers (reset to default state)
	PPPlayerManager.reset()
	PPQuestManager.reset()
	PPNPCManager.reset()
	PPTimeManager.reset()

	# Initialize player
	var player_data = PPPlayerData.new()
	player_data.set_player_name("Hero")
	PPPlayerManager.set_player_data(player_data)

	# Start game
	get_tree().change_scene_to_file("res://scenes/game_intro.tscn")

	# Optional: Auto-save to slot 1 after intro
	await get_tree().create_timer(5.0).timeout
	PPSaveManager.save_game(1)
```

---

## Best Practices

### ✅ Reset Autosave Timer After Manual Save

```gdscript
# ✅ Good: prevent autosave immediately after manual save
PPSaveManager.save_game(1)
PPSaveManager.reset_autosave_timer()

# ❌ Bad: autosave might trigger right after manual save
PPSaveManager.save_game(1)
```

### ✅ Use Signals for UI Feedback

```gdscript
# ✅ Good: responsive UI
PPSaveManager.save_started.connect(_show_saving_icon)
PPSaveManager.save_completed.connect(_hide_saving_icon)

# ❌ Bad: no feedback to player
PPSaveManager.save_game(1)  # Player doesn't know if save succeeded
```

### ✅ Validate Before Load

```gdscript
# ✅ Good: check save exists
if PPSaveManager.has_save(slot_number):
	PPSaveManager.load_and_apply(slot_number)
else:
	show_error("Save slot is empty")

# ❌ Bad: no validation
PPSaveManager.load_and_apply(slot_number)  # May fail silently
```

### ✅ Handle Load Failures Gracefully

```gdscript
# ✅ Good: fallback on failure
var success = PPSaveManager.load_and_apply(1)

if not success:
	print("Load failed, starting new game")
	start_new_game()

# ❌ Bad: no fallback
PPSaveManager.load_and_apply(1)  # Game in broken state if fails
```

---

## Troubleshooting

### Save Not Working

**Cause:** Save directory doesn't exist or is not writable

**Solution:**
```gdscript
# Check if directory exists
var save_dir = PPSaveManager.save_directory
if not DirAccess.dir_exists_absolute(save_dir):
	print("ERROR: Save directory doesn't exist: %s" % save_dir)

# The SaveManager should create it automatically on _ready()
# Check console for errors
```

### Load Fails with Version Mismatch

**Cause:** Save file from different game version

**Solution:**
```gdscript
# Check save version before loading
var slot = PPSaveManager.get_save_slot(1)

if not slot.is_compatible("1.0.0"):
	print("Save is from version %s, current is 1.0.0" % slot.save_version)
	show_migration_warning()
```

### Autosave Not Triggering

**Cause:** Autosave disabled or in combat/cutscene

**Solution:**
```gdscript
# Check if autosave is enabled
if not PPSaveManager.autosave_enabled:
	print("Autosave is disabled")

# Temporarily disable autosave during combat
func enter_combat():
	PPSaveManager.autosave_enabled = false

func exit_combat():
	PPSaveManager.autosave_enabled = true
```

---

## 💎 Premium Differences

In **Pandora+ Premium**, the save slot metadata includes additional player information:

```gdscript
var slot = PPSaveManager.get_save_slot(1)

# 💎 Premium only: Player level
print("Player Level: %d" % slot.level)

# Display in save menu
var text = "%s - Level %d - %s" % [
	slot.player_name,
	slot.level,
	slot.location
]
```

This is automatically populated from `PPPlayerData.level` in Premium edition.

---

## See Also

- [Player Data System](player-data.md) - Player state saved/loaded
- [Quest System](quest-system.md) - Quest progress saved/loaded
- [NPC System](npc-system.md) - NPC states saved/loaded
- [Time Manager](time-manager.md) - World time saved/loaded

---

*Complete System Guide for Pandora+ v1.0.0*
