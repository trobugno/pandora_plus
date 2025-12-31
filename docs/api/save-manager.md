# PPSaveManager

**✅ Core & Premium** | **Autoload Singleton**

API reference for the Save/Load Manager singleton - handles all save/load operations with multiple slots, autosave, and quicksave support.

---

## Description

**PPSaveManager** is an autoload singleton that provides centralized save/load functionality for Pandora+. It manages multiple save slots, automatic saving, and integrates with all Pandora managers to persist complete game state.

**Key Responsibilities:**
- Save and load game state to/from JSON files
- Manage multiple save slots (configurable 1-20)
- Automatic saving at intervals
- Quicksave/quickload functionality
- Save slot metadata for UI display
- Version checking for compatibility

**Access:** Available globally as `PPSaveManager`

---

## Constants

```gdscript
const SAVE_VERSION = "1.0.0"
const AUTOSAVE_SLOT_NAME = "autosave"
const QUICKSAVE_SLOT_NAME = "quicksave"
```

**SAVE_VERSION**
- Current save file format version
- Used for compatibility checking

**AUTOSAVE_SLOT_NAME**
- String identifier for autosave slot
- File saved as `autosave.json`

**QUICKSAVE_SLOT_NAME**
- String identifier for quicksave slot
- File saved as `quicksave.json`

---

## Signals

### save_started

```gdscript
signal save_started(slot_id: Variant)
```

Emitted when a save operation begins.

**Parameters:**
- `slot_id` (Variant) - Slot number (int) or name (String)

**Example:**
```gdscript
PPSaveManager.save_started.connect(func(slot_id):
    print("Saving to slot %s..." % slot_id)
    show_saving_icon()
)
```

---

### save_completed

```gdscript
signal save_completed(slot_id: Variant, success: bool)
```

Emitted when a save operation completes.

**Parameters:**
- `slot_id` (Variant) - Slot number or name
- `success` (bool) - `true` if save succeeded, `false` otherwise

**Example:**
```gdscript
PPSaveManager.save_completed.connect(func(slot_id, success):
    hide_saving_icon()
    if success:
        show_notification("Game saved!")
    else:
        show_error("Save failed!")
)
```

---

### load_started

```gdscript
signal load_started(slot_id: Variant)
```

Emitted when a load operation begins.

**Parameters:**
- `slot_id` (Variant) - Slot number or name

**Example:**
```gdscript
PPSaveManager.load_started.connect(func(slot_id):
    print("Loading from slot %s..." % slot_id)
    show_loading_screen()
)
```

---

### load_completed

```gdscript
signal load_completed(slot_id: Variant, success: bool, game_state: Variant)
```

Emitted when a load operation completes.

**Parameters:**
- `slot_id` (Variant) - Slot number or name
- `success` (bool) - `true` if load succeeded, `false` otherwise
- `game_state` (Variant) - Loaded PPGameState instance (or null if failed)

**Example:**
```gdscript
PPSaveManager.load_completed.connect(func(slot_id, success, game_state):
    hide_loading_screen()
    if success:
        print("Loaded save from %s" % game_state.meta.get("save_location"))
    else:
        show_error("Load failed!")
)
```

---

### save_deleted

```gdscript
signal save_deleted(slot_id: Variant)
```

Emitted when a save file is deleted.

**Parameters:**
- `slot_id` (Variant) - Slot number or name that was deleted

**Example:**
```gdscript
PPSaveManager.save_deleted.connect(func(slot_id):
    print("Save deleted from slot %s" % slot_id)
    refresh_save_menu()
)
```

---

### autosave_triggered

```gdscript
signal autosave_triggered()
```

Emitted when autosave is triggered (before save operation).

**Example:**
```gdscript
PPSaveManager.autosave_triggered.connect(func():
    show_autosave_indicator()
    await get_tree().create_timer(2.0).timeout
    hide_autosave_indicator()
)
```

---

## Properties

### max_save_slots

```gdscript
var max_save_slots: int
```

Maximum number of save slots available (1-20).

**Default:** 3
**Configured via:** Project Settings → `pandora_plus/config/save_system/max_save_slots`

**Example:**
```gdscript
print("Available slots: %d" % PPSaveManager.max_save_slots)
```

---

### autosave_enabled

```gdscript
var autosave_enabled: bool
```

Whether autosave is currently enabled.

**Default:** `true`
**Configured via:** Project Settings → `pandora_plus/config/save_system/autosave_enabled`

**Example:**
```gdscript
# Disable autosave during combat
PPSaveManager.autosave_enabled = false

# Re-enable after combat
PPSaveManager.autosave_enabled = true
```

---

### autosave_interval

```gdscript
var autosave_interval: float
```

Time in seconds between autosaves.

**Default:** 300.0 (5 minutes)
**Range:** 30.0 - 3600.0
**Configured via:** Project Settings → `pandora_plus/config/save_system/autosave_interval_seconds`

**Example:**
```gdscript
print("Autosave every %.1f seconds" % PPSaveManager.autosave_interval)
```

---

### save_directory

```gdscript
var save_directory: String
```

Directory path where save files are stored.

**Default:** `"user://saves/"`
**Configured via:** Project Settings → `pandora_plus/config/save_system/save_directory`

**Example:**
```gdscript
print("Saves located at: %s" % PPSaveManager.save_directory)
```

---

### save_extension

```gdscript
var save_extension: String
```

File extension for save files.

**Default:** `".json"`
**Configured via:** Project Settings → `pandora_plus/config/save_system/save_file_extension`

---

## Methods

### save_game

```gdscript
func save_game(slot: Variant, game_state = null) -> bool
```

Saves game state to specified slot.

**Parameters:**
- `slot` (Variant) - Slot number (1 to max_save_slots) or string name ("autosave", "quicksave")
- `game_state` (PPGameState, optional) - Game state to save. If `null`, collects current state from managers

**Returns:** `bool` - `true` if save succeeded, `false` otherwise

**Example:**
```gdscript
# Save to slot 1 (auto-collects state)
var success = PPSaveManager.save_game(1)

# Save with custom state
var custom_state = PPGameState.new()
# ... populate state
var success = PPSaveManager.save_game(2, custom_state)
```

---

### load_game

```gdscript
func load_game(slot: Variant) -> Variant
```

Loads game state from specified slot (does NOT apply it).

**Parameters:**
- `slot` (Variant) - Slot number or string name

**Returns:** `PPGameState` instance or `null` if load failed

**Example:**
```gdscript
# Load game state
var game_state = PPSaveManager.load_game(1)

if game_state:
    print("Loaded save:")
    print("  Player: %s" % game_state.player_data.get("player_name"))
    print("  Day: %d" % game_state.current_day)

    # Manually restore state
    PPSaveManager.restore_state(game_state)
else:
    print("Load failed")
```

---

### load_and_apply

```gdscript
func load_and_apply(slot: Variant) -> bool
```

Loads game state from specified slot and immediately applies it to all managers.

**Parameters:**
- `slot` (Variant) - Slot number or string name

**Returns:** `bool` - `true` if load and restore succeeded

**Example:**
```gdscript
# Load and apply in one step
var success = PPSaveManager.load_and_apply(1)

if success:
    # State restored, change scene
    get_tree().change_scene_to_file("res://scenes/game.tscn")
else:
    show_error("Failed to load save")
```

---

### restore_state

```gdscript
func restore_state(game_state: PPGameState) -> void
```

Restores game state to all Pandora managers.

**Parameters:**
- `game_state` (PPGameState) - Game state to restore

**Restores to:**
- PPPlayerManager
- PPQuestManager
- PPNPCManager
- PPTimeManager

**Example:**
```gdscript
var game_state = PPSaveManager.load_game(1)

if game_state:
    # Restore state to all managers
    PPSaveManager.restore_state(game_state)
    print("State restored")
```

---

### delete_save

```gdscript
func delete_save(slot: Variant) -> bool
```

Deletes save file for specified slot.

**Parameters:**
- `slot` (Variant) - Slot number or string name

**Returns:** `bool` - `true` if deletion succeeded

**Example:**
```gdscript
# Delete save from slot 3
var deleted = PPSaveManager.delete_save(3)

if deleted:
    print("Save deleted")
    refresh_save_menu()
```

---

### has_save

```gdscript
func has_save(slot: Variant) -> bool
```

Checks if a save file exists for the specified slot.

**Parameters:**
- `slot` (Variant) - Slot number or string name

**Returns:** `bool` - `true` if save exists

**Example:**
```gdscript
# Check before loading
if PPSaveManager.has_save(1):
    print("Slot 1 has a save")
    enable_load_button()
else:
    print("Slot 1 is empty")
    disable_load_button()
```

---

### get_save_slots

```gdscript
func get_save_slots() -> Array
```

Gets metadata for all available save slots.

**Returns:** `Array[PPSaveSlot]` - Array of PPSaveSlot instances with metadata

**Example:**
```gdscript
var slots = PPSaveManager.get_save_slots()

for slot in slots:
    if not slot.is_empty:
        print("Slot %d: %s - %s" % [
            slot.slot_id,
            slot.player_name,
            slot.get_formatted_date()
        ])
```

---

### get_save_slot

```gdscript
func get_save_slot(slot: Variant) -> Variant
```

Gets metadata for a specific save slot.

**Parameters:**
- `slot` (Variant) - Slot number or string name

**Returns:** `PPSaveSlot` instance or `null`

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)

if slot and not slot.is_empty:
    print("Player: %s" % slot.player_name)
    print("Level: %d" % slot.level)  # 💎 Premium
    print("Playtime: %s" % slot.get_formatted_playtime())
    print("Saved: %s" % slot.get_formatted_date())
```

---

### autosave

```gdscript
func autosave() -> bool
```

Performs an autosave to the autosave slot.

**Returns:** `bool` - `true` if autosave succeeded

**Example:**
```gdscript
# Manual autosave trigger
if PPSaveManager.autosave():
    print("Autosaved successfully")

# Autosave happens automatically based on autosave_interval
```

---

### quicksave

```gdscript
func quicksave() -> bool
```

Performs a quicksave to the quicksave slot.

**Returns:** `bool` - `true` if quicksave succeeded

**Example:**
```gdscript
# Bind to F5 key
func _input(event):
    if event.is_action_pressed("quicksave"):
        if PPSaveManager.quicksave():
            show_notification("Quicksaved")
```

---

### quickload

```gdscript
func quickload() -> Variant
```

Loads from the quicksave slot (does NOT apply state).

**Returns:** `PPGameState` instance or `null`

**Example:**
```gdscript
# Bind to F9 key
func _input(event):
    if event.is_action_pressed("quickload"):
        var game_state = PPSaveManager.quickload()
        if game_state:
            PPSaveManager.restore_state(game_state)
            show_notification("Quickloaded")
```

---

### reset_autosave_timer

```gdscript
func reset_autosave_timer() -> void
```

Resets the autosave timer. Call after manual save to prevent immediate autosave.

**Example:**
```gdscript
# Save manually
PPSaveManager.save_game(1)

# Reset timer so autosave doesn't trigger right away
PPSaveManager.reset_autosave_timer()
```

---

## Usage Examples

### Complete Save Menu

```gdscript
extends Control

@onready var slot_list: ItemList = $SlotList
@onready var save_button: Button = $SaveButton
@onready var load_button: Button = $LoadButton
@onready var delete_button: Button = $DeleteButton

func _ready():
    refresh_slots()

    save_button.pressed.connect(_on_save_pressed)
    load_button.pressed.connect(_on_load_pressed)
    delete_button.pressed.connect(_on_delete_pressed)

    PPSaveManager.save_completed.connect(_on_save_completed)
    PPSaveManager.save_deleted.connect(_on_save_deleted)

func refresh_slots():
    slot_list.clear()

    var slots = PPSaveManager.get_save_slots()

    for slot in slots:
        var text = ""
        if slot.is_empty:
            text = "Slot %d: Empty" % slot.slot_id
        else:
            text = "Slot %d\n  %s - Level %d\n  %s\n  %s" % [
                slot.slot_id,
                slot.player_name,
                slot.level,  # 💎 Premium
                slot.location,
                slot.get_formatted_date()
            ]

        slot_list.add_item(text)

func _on_save_pressed():
    var selected = slot_list.get_selected_items()
    if selected.is_empty():
        return

    var slot_num = selected[0] + 1
    PPSaveManager.save_game(slot_num)

func _on_load_pressed():
    var selected = slot_list.get_selected_items()
    if selected.is_empty():
        return

    var slot_num = selected[0] + 1

    if not PPSaveManager.has_save(slot_num):
        show_error("Slot is empty")
        return

    if PPSaveManager.load_and_apply(slot_num):
        get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_delete_pressed():
    var selected = slot_list.get_selected_items()
    if selected.is_empty():
        return

    var slot_num = selected[0] + 1

    # Show confirmation
    var confirm = ConfirmationDialog.new()
    confirm.dialog_text = "Delete this save?"
    add_child(confirm)
    confirm.popup_centered()

    confirm.confirmed.connect(func():
        PPSaveManager.delete_save(slot_num)
    )

func _on_save_completed(slot_id, success):
    if success:
        refresh_slots()
        show_notification("Game saved to slot %s" % slot_id)

func _on_save_deleted(slot_id):
    refresh_slots()
```

### Auto-Save on Scene Change

```gdscript
extends Node

func _ready():
    # Auto-save when changing scenes
    get_tree().node_removed.connect(_on_node_removed)

func _on_node_removed(node):
    # Check if main scene is being removed
    if node.is_in_group("main_scene"):
        print("Saving game...")
        PPSaveManager.autosave()
```

### Save Before Quit

```gdscript
extends Node

func _notification(what):
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        # Save before quitting
        print("Saving before quit...")
        PPSaveManager.autosave()

        # Wait for save to complete
        await PPSaveManager.save_completed

        get_tree().quit()
```

---

## See Also

- [Save/Load System](../core-systems/save-load-system.md) - Complete system guide
- [PPSaveSlot](save-slot.md) - Save slot metadata
- [PPGameState](game-state.md) - Game state container
- [Player Data](../core-systems/player-data.md) - Player state persistence
- [Quest System](../core-systems/quest-system.md) - Quest progress persistence

---

*API Reference for Pandora+ v1.0.0*
