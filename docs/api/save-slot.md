# PPSaveSlot

**✅ Core & Premium** | **Resource Class**

API reference for Save Slot metadata - represents information about a save file without loading its entire contents.

---

## Description

**PPSaveSlot** is a Resource class that contains metadata about a save file for UI display purposes. It allows save/load menus to show information about saves (player name, playtime, timestamp, etc.) without having to load the entire save file.

**Purpose:**
- Display save slot information in menus
- Check if slots are empty
- Show formatted timestamps and playtimes
- Compare save slots
- Version compatibility checking

**Created by:** `PPSaveManager.get_save_slots()` and `PPSaveManager.get_save_slot()`

---

## Properties

### slot_id

```gdscript
@export var slot_id: Variant
```

Slot identifier - can be either an int (numbered slot) or String (named slot).

**Values:**
- `int`: Numbered slots (1, 2, 3, etc.)
- `String`: Named slots ("autosave", "quicksave")

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)
print(slot.slot_id)  # 1

var autosave = PPSaveManager.get_save_slot("autosave")
print(autosave.slot_id)  # "autosave"
```

---

### is_empty

```gdscript
@export var is_empty: bool
```

Whether this slot is empty (no save file exists).

**Default:** `true`

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)

if slot.is_empty:
    print("Slot 1 is empty")
else:
    print("Slot 1 has a save")
```

---

### player_name

```gdscript
@export var player_name: String
```

Player's name from the save file.

**Default:** `""`

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)

if not slot.is_empty:
    print("Player: %s" % slot.player_name)
```

---

### level

```gdscript
@export var level: int
```

**💎 Premium Only** - Player's level from the save file.

**Default:** `0`

**Example:**
```gdscript
# 💎 Premium
var slot = PPSaveManager.get_save_slot(1)

if not slot.is_empty:
    print("Level: %d" % slot.level)
```

---

### playtime

```gdscript
@export var playtime: float
```

Total playtime in seconds.

**Default:** `0.0`

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)

if not slot.is_empty:
    var hours = slot.playtime / 3600.0
    print("Playtime: %.1f hours" % hours)
```

---

### timestamp

```gdscript
@export var timestamp: float
```

Timestamp when save was created (Unix time).

**Default:** `0.0`

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)

if not slot.is_empty:
    print("Saved at: %f" % slot.timestamp)
```

---

### save_version

```gdscript
@export var save_version: String
```

Save file version string.

**Default:** `""`

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)

if not slot.is_empty:
    print("Save version: %s" % slot.save_version)
```

---

### location

```gdscript
@export var location: String
```

Last location/scene name where the game was saved.

**Default:** `""`

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)

if not slot.is_empty:
    print("Last location: %s" % slot.location)
```

---

### thumbnail

```gdscript
var thumbnail: Image = null
```

Optional screenshot of the game when saved. Can be used for visual save slot representation.

**Default:** `null`

**Note:** Currently not populated by default save system. Can be implemented for custom save UI.

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)

if slot.thumbnail:
    var texture = ImageTexture.create_from_image(slot.thumbnail)
    save_preview.texture = texture
```

---

## Methods

### _init

```gdscript
func _init(p_slot_id: Variant = null) -> void
```

Initializes a new save slot with default values.

**Parameters:**
- `p_slot_id` (Variant, optional) - Slot identifier

**Example:**
```gdscript
# Create empty slot
var slot = PPSaveSlot.new(1)
print(slot.is_empty)  # true
```

---

### get_formatted_date

```gdscript
func get_formatted_date() -> String
```

Gets formatted datetime string for the save.

**Returns:** `String` - Human-readable date/time or "Empty Slot" if empty

**Format:** `YYYY-MM-DD HH:MM`

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)
print(slot.get_formatted_date())  # "2024-11-03 14:32"
```

---

### get_formatted_playtime

```gdscript
func get_formatted_playtime() -> String
```

Gets formatted playtime string.

**Returns:** `String` - Human-readable playtime (e.g., "5h 23m" or "45m")

**Format:**
- Hours + minutes: `"5h 23m"`
- Minutes only: `"45m"`
- Empty slot: `"0m"`

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)
print(slot.get_formatted_playtime())  # "2h 30m"
```

---

### get_slot_name

```gdscript
func get_slot_name() -> String
```

Gets slot display name for UI.

**Returns:** `String` - Slot name

**Format:**
- Numbered slots: `"Slot 1"`, `"Slot 2"`, etc.
- Named slots: `"Autosave"`, `"Quicksave"` (capitalized)
- Unknown: `"Unknown"`

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)
print(slot.get_slot_name())  # "Slot 1"

var autosave = PPSaveManager.get_save_slot("autosave")
print(autosave.get_slot_name())  # "Autosave"
```

---

### get_summary_line

```gdscript
func get_summary_line() -> String
```

Gets a one-line summary for list display.

**Returns:** `String` - Summary line

**Format (Core):**
- Empty: `"Slot 1: Empty"`
- With save: `"Slot 1: Hero - Town Square - 2024-11-03 14:32"`

**Format (💎 Premium):**
- With save: `"Slot 1: Hero (Lv 5) - Town Square - 2024-11-03 14:32"`

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)
print(slot.get_summary_line())
# Core: "Slot 1: Hero - Town Square - 2024-11-03 14:32"
# 💎 Premium: "Slot 1: Hero (Lv 5) - Town Square - 2024-11-03 14:32"
```

---

### is_compatible

```gdscript
func is_compatible(current_version: String) -> bool
```

Checks if this save is compatible with current game version.

**Parameters:**
- `current_version` (String) - Current game version to check against

**Returns:** `bool` - `true` if compatible

**Compatibility Check:**
- Compares major version numbers (first number in "X.Y.Z" format)
- Empty slots are always compatible

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)

if slot.is_compatible("1.0.0"):
    print("Save is compatible")
else:
    print("Save version mismatch: %s" % slot.save_version)
    show_migration_warning()
```

---

### is_newer_than

```gdscript
func is_newer_than(other: PPSaveSlot) -> bool
```

Compares this slot with another by timestamp (for sorting).

**Parameters:**
- `other` (PPSaveSlot) - Another save slot to compare

**Returns:** `bool` - `true` if this slot is newer

**Logic:**
- Empty slots are always "older" than filled slots
- Compares by timestamp (Unix time)

**Example:**
```gdscript
var slot1 = PPSaveManager.get_save_slot(1)
var slot2 = PPSaveManager.get_save_slot(2)

if slot1.is_newer_than(slot2):
    print("Slot 1 is newer than Slot 2")
```

---

### to_dict

```gdscript
func to_dict() -> Dictionary
```

Serializes slot metadata to dictionary.

**Returns:** `Dictionary` - Slot metadata

**Dictionary Structure:**
```gdscript
{
    "slot_id": 1,
    "is_empty": false,
    "player_name": "Hero",
    "level": 5,  # 💎 Premium
    "playtime": 7200.0,
    "timestamp": 1699012345.0,
    "save_version": "1.0.0",
    "location": "Town Square"
}
```

**Example:**
```gdscript
var slot = PPSaveManager.get_save_slot(1)
var data = slot.to_dict()
print(data)
```

---

### from_dict

```gdscript
static func from_dict(data: Dictionary) -> PPSaveSlot
```

Creates a SaveSlot from dictionary (deserialization).

**Parameters:**
- `data` (Dictionary) - Dictionary with slot metadata

**Returns:** `PPSaveSlot` - Restored slot instance

**Example:**
```gdscript
var data = {
    "slot_id": 1,
    "is_empty": false,
    "player_name": "Hero",
    "playtime": 7200.0,
    "timestamp": 1699012345.0
}

var slot = PPSaveSlot.from_dict(data)
print(slot.player_name)  # "Hero"
```

---

## Usage Examples

### Display Save Slots in Menu

```gdscript
extends ItemList

func _ready():
    refresh_slots()

func refresh_slots():
    clear()

    var slots = PPSaveManager.get_save_slots()

    for slot in slots:
        if slot.is_empty:
            add_item("%s: Empty" % slot.get_slot_name())
            set_item_disabled(get_item_count() - 1, true)
        else:
            # Core version
            var text = "%s\n%s\n%s\n%s" % [
                slot.get_slot_name(),
                slot.player_name,
                slot.location,
                slot.get_formatted_date()
            ]

            # 💎 Premium version (with level)
            # var text = "%s\n%s - Level %d\n%s\n%s" % [
            #     slot.get_slot_name(),
            #     slot.player_name,
            #     slot.level,
            #     slot.location,
            #     slot.get_formatted_date()
            # ]

            add_item(text)
```

### Sort Slots by Date

```gdscript
func get_sorted_slots() -> Array:
    var slots = PPSaveManager.get_save_slots()

    # Sort by timestamp (newest first)
    slots.sort_custom(func(a, b):
        return a.is_newer_than(b)
    )

    return slots
```

### Show Detailed Save Info

```gdscript
func show_save_details(slot_id: int):
    var slot = PPSaveManager.get_save_slot(slot_id)

    if slot.is_empty:
        detail_label.text = "Empty Slot"
        return

    var text = """
    Player: %s
    Level: %d
    Location: %s
    Playtime: %s
    Saved: %s
    Version: %s
    """ % [
        slot.player_name,
        slot.level,  # 💎 Premium
        slot.location,
        slot.get_formatted_playtime(),
        slot.get_formatted_date(),
        slot.save_version
    ]

    detail_label.text = text
```

### Version Compatibility Warning

```gdscript
func try_load_save(slot_id: int):
    var slot = PPSaveManager.get_save_slot(slot_id)

    if slot.is_empty:
        show_error("Slot is empty")
        return

    # Check version compatibility
    if not slot.is_compatible("1.0.0"):
        var confirm = ConfirmationDialog.new()
        confirm.dialog_text = "Save is from version %s. Loading may cause issues. Continue?" % slot.save_version
        add_child(confirm)
        confirm.popup_centered()

        confirm.confirmed.connect(func():
            load_save(slot_id)
        )
    else:
        load_save(slot_id)

func load_save(slot_id: int):
    PPSaveManager.load_and_apply(slot_id)
```

### Save Slot Card UI

```gdscript
extends PanelContainer

@export var slot_id: int = 1

@onready var slot_name_label: Label = $VBox/SlotName
@onready var player_label: Label = $VBox/PlayerName
@onready var details_label: Label = $VBox/Details
@onready var thumbnail_rect: TextureRect = $VBox/Thumbnail

func _ready():
    refresh()

func refresh():
    var slot = PPSaveManager.get_save_slot(slot_id)

    slot_name_label.text = slot.get_slot_name()

    if slot.is_empty:
        player_label.text = "Empty"
        details_label.text = ""
        thumbnail_rect.visible = false
    else:
        # 💎 Premium version
        player_label.text = "%s (Level %d)" % [slot.player_name, slot.level]

        details_label.text = "%s\n%s\n%s" % [
            slot.location,
            slot.get_formatted_playtime(),
            slot.get_formatted_date()
        ]

        # Show thumbnail if available
        if slot.thumbnail:
            var texture = ImageTexture.create_from_image(slot.thumbnail)
            thumbnail_rect.texture = texture
            thumbnail_rect.visible = true
        else:
            thumbnail_rect.visible = false
```

---

## See Also

- [PPSaveManager](save-manager.md) - Save/load operations
- [PPGameState](game-state.md) - Complete game state container
- [Save/Load System](../core-systems/save-load-system.md) - System guide

---

*API Reference for Pandora+ v1.0.0*
