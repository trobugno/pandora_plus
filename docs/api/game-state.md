# PPGameState

**✅ Core & Premium** | **Resource Class**

API reference for Game State container - aggregates all runtime game data for saving and loading.

---

## Description

**PPGameState** is a Resource class that serves as the main container for all persistent game state. It aggregates data from all game systems (player, quests, NPCs, world, etc.) into a single structure that can be saved to and loaded from disk.

**Purpose:**
- Aggregate all game state data
- Serialize/deserialize complete game state
- Provide helper methods for state management
- Support custom game-specific data

**Used by:** `PPSaveManager` for save/load operations

---

## Properties

### player_data

```gdscript
var player_data: Variant = null
```

Player-specific data (stats, inventory, position, etc.).

**Type:** `PPPlayerData` (serialized to/from Dictionary)

**Example:**
```gdscript
var game_state = PPGameState.new()
game_state.player_data = PPPlayerManager.get_player_data()
```

---

### active_quests

```gdscript
@export var active_quests: Array = []
```

Array of active quests serialized to dictionaries.

**Type:** `Array[Dictionary]` - Each entry is `PPRuntimeQuest.to_dict()` result

**Example:**
```gdscript
var game_state = PPGameState.new()
print("Active quests: %d" % game_state.active_quests.size())
```

---

### completed_quest_ids

```gdscript
@export var completed_quest_ids: Array[String] = []
```

Array of completed quest IDs.

**Type:** `Array[String]`

**Example:**
```gdscript
var game_state = PPGameState.new()
if "quest_save_village" in game_state.completed_quest_ids:
    print("Player saved the village")
```

---

### failed_quest_ids

```gdscript
@export var failed_quest_ids: Array[String] = []
```

Array of failed quest IDs.

**Type:** `Array[String]`

**Example:**
```gdscript
var game_state = PPGameState.new()
if "quest_timed_delivery" in game_state.failed_quest_ids:
    print("Player failed the timed delivery quest")
```

---

### spawned_npcs

```gdscript
@export var spawned_npcs: Array = []
```

Array of spawned NPCs serialized to dictionaries.

**Type:** `Array[Dictionary]` - Each entry is `PPRuntimeNPC.to_dict()` result

**Example:**
```gdscript
var game_state = PPGameState.new()
print("Spawned NPCs: %d" % game_state.spawned_npcs.size())
```

---

### world_time

```gdscript
@export var world_time: float = 0.0
```

Current world time in seconds.

**Default:** `0.0`

**Example:**
```gdscript
var game_state = PPGameState.new()
print("Total game time: %.1f hours" % (game_state.world_time / 3600.0))
```

---

### current_hour

```gdscript
@export var current_hour: int = 12
```

Current game hour (0-23) for schedule system.

**Default:** `12`

**Example:**
```gdscript
var game_state = PPGameState.new()
print("Current hour: %02d:00" % game_state.current_hour)
```

---

### current_day

```gdscript
@export var current_day: int = 1
```

Current game day.

**Default:** `1`

**Example:**
```gdscript
var game_state = PPGameState.new()
print("Day %d" % game_state.current_day)
```

---

### world_flags

```gdscript
@export var world_flags: Dictionary = {}
```

Generic flags dictionary for custom events and states.

**Type:** `Dictionary`

**Example:**
```gdscript
var game_state = PPGameState.new()
game_state.set_flag("dragon_defeated", true)
game_state.set_flag("reputation_heroes_guild", 75)

if game_state.get_flag("dragon_defeated"):
    print("Dragon was defeated!")
```

---

### playtime

```gdscript
@export var playtime: float = 0.0
```

Total playtime in seconds.

**Default:** `0.0`

**Example:**
```gdscript
var game_state = PPGameState.new()
print("Playtime: %.1f hours" % (game_state.playtime / 3600.0))
```

---

### difficulty

```gdscript
@export var difficulty: String = "normal"
```

Game difficulty setting.

**Default:** `"normal"`

**Example:**
```gdscript
var game_state = PPGameState.new()
game_state.difficulty = "hard"
```

---

### custom_data

```gdscript
@export var custom_data: Dictionary = {}
```

Custom metadata for mod support or game-specific data.

**Type:** `Dictionary`

**Example:**
```gdscript
var game_state = PPGameState.new()
game_state.custom_data["mod_version"] = "2.1.0"
game_state.custom_data["custom_setting"] = true
```

---

## Methods

### _init

```gdscript
func _init() -> void
```

Initializes game state with default values.

**Example:**
```gdscript
var game_state = PPGameState.new()
# All properties initialized to defaults
```

---

### to_dict

```gdscript
func to_dict() -> Dictionary
```

Serializes the entire game state to a dictionary.

**Returns:** `Dictionary` - Complete game state data

**Dictionary Structure:**
```gdscript
{
    "player_data": { ... },
    "quests": {
        "active": [ ... ],
        "completed_ids": [ ... ],
        "failed_ids": [ ... ]
    },
    "npcs": [ ... ],
    "world": {
        "time": 0.0,
        "current_hour": 12,
        "current_day": 1,
        "flags": { ... }
    },
    "meta": {
        "playtime": 0.0,
        "difficulty": "normal",
        "custom_data": { ... }
    }
}
```

**Example:**
```gdscript
var game_state = PPGameState.new()
var data = game_state.to_dict()

# Save to JSON
var json_string = JSON.stringify(data)
```

---

### from_dict

```gdscript
static func from_dict(data: Dictionary) -> PPGameState
```

Creates a GameState instance from a dictionary (deserialization).

**Parameters:**
- `data` (Dictionary) - Dictionary with game state data

**Returns:** `PPGameState` - Restored game state instance

**Example:**
```gdscript
# Load from JSON
var json = JSON.new()
json.parse(json_string)
var data = json.get_data()

# Deserialize
var game_state = PPGameState.from_dict(data)
print(game_state.get_summary())
```

---

### add_active_quest

```gdscript
func add_active_quest(runtime_quest) -> void
```

Adds an active quest to the state.

**Parameters:**
- `runtime_quest` (PPRuntimeQuest) - Runtime quest instance

**Example:**
```gdscript
var quest = PPQuestManager.start_quest(quest_entity)
game_state.add_active_quest(quest)
```

---

### complete_quest

```gdscript
func complete_quest(quest_id: String) -> void
```

Marks a quest as completed.

**Parameters:**
- `quest_id` (String) - Quest identifier

**Actions:**
- Removes quest from `active_quests`
- Adds to `completed_quest_ids` (if not already present)

**Example:**
```gdscript
game_state.complete_quest("quest_save_village")
```

---

### fail_quest

```gdscript
func fail_quest(quest_id: String) -> void
```

Marks a quest as failed.

**Parameters:**
- `quest_id` (String) - Quest identifier

**Actions:**
- Removes quest from `active_quests`
- Adds to `failed_quest_ids` (if not already present)

**Example:**
```gdscript
game_state.fail_quest("quest_timed_delivery")
```

---

### is_quest_completed

```gdscript
func is_quest_completed(quest_id: String) -> bool
```

Checks if a quest is completed.

**Parameters:**
- `quest_id` (String) - Quest identifier

**Returns:** `bool` - `true` if quest is completed

**Example:**
```gdscript
if game_state.is_quest_completed("quest_save_village"):
    print("Village was saved!")
```

---

### is_quest_failed

```gdscript
func is_quest_failed(quest_id: String) -> bool
```

Checks if a quest is failed.

**Parameters:**
- `quest_id` (String) - Quest identifier

**Returns:** `bool` - `true` if quest is failed

**Example:**
```gdscript
if game_state.is_quest_failed("quest_timed_delivery"):
    print("Failed the delivery quest")
```

---

### is_quest_active

```gdscript
func is_quest_active(quest_id: String) -> bool
```

Checks if a quest is active.

**Parameters:**
- `quest_id` (String) - Quest identifier

**Returns:** `bool` - `true` if quest is active

**Example:**
```gdscript
if game_state.is_quest_active("quest_find_artifact"):
    print("Currently searching for the artifact")
```

---

### add_spawned_npc

```gdscript
func add_spawned_npc(runtime_npc) -> void
```

Adds a spawned NPC to the state.

**Parameters:**
- `runtime_npc` (PPRuntimeNPC) - Runtime NPC instance

**Example:**
```gdscript
var npc = PPNPCUtils.spawn_npc(npc_entity)
game_state.add_spawned_npc(npc)
```

---

### remove_spawned_npc

```gdscript
func remove_spawned_npc(npc_id: String) -> void
```

Removes a spawned NPC from the state.

**Parameters:**
- `npc_id` (String) - NPC entity identifier

**Example:**
```gdscript
# NPC died permanently
game_state.remove_spawned_npc("npc_bandit_leader")
```

---

### get_npc_data

```gdscript
func get_npc_data(npc_id: String) -> Dictionary
```

Gets NPC data by ID.

**Parameters:**
- `npc_id` (String) - NPC entity identifier

**Returns:** `Dictionary` - NPC data or empty dict if not found

**Example:**
```gdscript
var npc_data = game_state.get_npc_data("npc_merchant")

if not npc_data.is_empty():
    print("Merchant is spawned")
```

---

### set_flag

```gdscript
func set_flag(flag_name: String, value: Variant) -> void
```

Sets a world flag.

**Parameters:**
- `flag_name` (String) - Flag identifier
- `value` (Variant) - Flag value (any type)

**Example:**
```gdscript
game_state.set_flag("dragon_defeated", true)
game_state.set_flag("reputation_kingdom", 75)
game_state.set_flag("story_chapter", 5)
```

---

### get_flag

```gdscript
func get_flag(flag_name: String, default_value: Variant = false) -> Variant
```

Gets a world flag value.

**Parameters:**
- `flag_name` (String) - Flag identifier
- `default_value` (Variant) - Default value if flag doesn't exist (default: `false`)

**Returns:** `Variant` - Flag value or default

**Example:**
```gdscript
if game_state.get_flag("dragon_defeated"):
    print("Dragon was defeated")

var reputation = game_state.get_flag("reputation_kingdom", 0)
print("Kingdom reputation: %d" % reputation)
```

---

### has_flag

```gdscript
func has_flag(flag_name: String) -> bool
```

Checks if a world flag exists.

**Parameters:**
- `flag_name` (String) - Flag identifier

**Returns:** `bool` - `true` if flag exists

**Example:**
```gdscript
if game_state.has_flag("met_king"):
    print("Player has met the king")
```

---

### remove_flag

```gdscript
func remove_flag(flag_name: String) -> void
```

Removes a world flag.

**Parameters:**
- `flag_name` (String) - Flag identifier

**Example:**
```gdscript
# Remove temporary flag
game_state.remove_flag("in_tutorial")
```

---

### get_summary

```gdscript
func get_summary() -> String
```

Gets a human-readable summary of the game state.

**Returns:** `String` - Summary text

**Example:**
```gdscript
var game_state = PPGameState.new()
print(game_state.get_summary())

# Output:
# Game State Summary:
#   Playtime: 2.5 hours
#   Active Quests: 3
#   Completed Quests: 12
#   Failed Quests: 1
#   Spawned NPCs: 5
#   World Day: 5, Hour: 14
#   World Flags: 8
#   Difficulty: normal
```

---

### clear

```gdscript
func clear() -> void
```

Clears all game state (use for new game).

**Example:**
```gdscript
# Start new game
var game_state = PPGameState.new()
game_state.clear()  # Reset to defaults
```

---

## Usage Examples

### Create Game State for Saving

```gdscript
func create_game_state() -> PPGameState:
    var state = PPGameState.new()

    # Collect player data
    state.player_data = PPPlayerManager.get_player_data()

    # Collect active quests
    var active_quests = PPQuestManager.get_active_quests()
    for quest in active_quests:
        state.add_active_quest(quest)

    # Collect completed quests
    state.completed_quest_ids = PPQuestManager.get_completed_quest_ids()

    # Collect spawned NPCs
    var npcs = get_all_spawned_npcs()
    for npc in npcs:
        state.add_spawned_npc(npc)

    # World state
    state.world_time = PPTimeManager.get_world_time()
    state.current_hour = PPTimeManager.get_current_hour()
    state.current_day = PPTimeManager.get_current_day()

    # Meta
    state.playtime = get_total_playtime()
    state.difficulty = current_difficulty

    return state
```

### Restore Game State After Loading

```gdscript
func restore_game_state(state: PPGameState):
    # Restore player
    if state.player_data:
        PPPlayerManager.set_player_data(state.player_data)

    # Restore quests
    PPQuestManager.clear_all_quests()
    for quest_dict in state.active_quests:
        var quest = PPRuntimeQuest.from_dict(quest_dict)
        PPQuestManager.add_active_quest(quest)

    PPQuestManager.set_completed_quest_ids(state.completed_quest_ids)

    # Restore NPCs
    clear_all_npcs()
    for npc_dict in state.spawned_npcs:
        var npc = PPRuntimeNPC.from_dict(npc_dict)
        spawn_npc_in_world(npc)

    # Restore time
    PPTimeManager.set_world_time(state.world_time)

    # Restore flags
    for flag_name in state.world_flags:
        apply_world_flag(flag_name, state.world_flags[flag_name])
```

### Track Story Progress with Flags

```gdscript
# Set story flags
game_state.set_flag("story_chapter", 3)
game_state.set_flag("met_wizard", true)
game_state.set_flag("alliance_formed", "elves")

# Check story flags
if game_state.get_flag("story_chapter", 0) >= 5:
    unlock_endgame_content()

if game_state.get_flag("met_wizard"):
    show_wizard_dialogue()

var alliance = game_state.get_flag("alliance_formed", "none")
match alliance:
    "elves":
        enable_elf_abilities()
    "dwarves":
        enable_dwarf_abilities()
```

### Quest State Management

```gdscript
# Add quest
var quest = PPQuestManager.start_quest(quest_entity)
game_state.add_active_quest(quest)

# Complete quest
game_state.complete_quest("quest_rescue_princess")

# Fail quest
game_state.fail_quest("quest_timed_escort")

# Check quest status
if game_state.is_quest_completed("quest_rescue_princess"):
    unlock_castle_area()

if game_state.is_quest_failed("quest_timed_escort"):
    spawn_enemy_ambush()

if game_state.is_quest_active("quest_find_artifact"):
    show_quest_marker()
```

### Dynamic World State

```gdscript
# Track world events
game_state.set_flag("town_under_attack", true)
game_state.set_flag("market_day", current_day % 7 == 0)
game_state.set_flag("weather", "rain")

# React to world state
if game_state.get_flag("town_under_attack"):
    spawn_defenders()
    close_shops()

if game_state.get_flag("market_day"):
    spawn_extra_merchants()

var weather = game_state.get_flag("weather", "clear")
apply_weather_effects(weather)
```

---

## See Also

- [PPSaveManager](save-manager.md) - Save/load operations
- [PPSaveSlot](save-slot.md) - Save slot metadata
- [Save/Load System](../core-systems/save-load-system.md) - System guide
- [PPPlayerData](player-data.md) - Player data structure

---

*API Reference for Pandora+ v1.0.0*
