# PPQuestManager

**✅ Core & Premium** | **Autoload Singleton**

API reference for the Quest Manager singleton - manages quest state, lifecycle, and tracking during gameplay.

---

## Description

**PPQuestManager** is an autoload singleton that manages the runtime state of all quests in the game. It handles quest activation, completion, failure, and integrates with the save/load system.

**Key Responsibilities:**
- Maintain collection of active quests
- Track completed and failed quest IDs
- Coordinate quest lifecycle with PPQuestUtils
- 💎 **Premium:** Update timed quests automatically
- Integrate with SaveManager for persistence

**Access:** Available globally as `PPQuestManager`

---

## Signals

### quest_added

```gdscript
signal quest_added(runtime_quest: PPRuntimeQuest)
```

Emitted when a quest is added to active quests.

**Parameters:**
- `runtime_quest` (PPRuntimeQuest) - The added quest instance

**Example:**
```gdscript
PPQuestManager.quest_added.connect(func(runtime_quest):
    print("Quest started: %s" % runtime_quest.get_quest_name())
    update_quest_log_ui()
)
```

---

### quest_removed

```gdscript
signal quest_removed(quest_id: String)
```

Emitted when a quest is removed from active quests.

**Parameters:**
- `quest_id` (String) - Quest identifier

---

### quest_completed

```gdscript
signal quest_completed(quest_id: String)
```

Emitted when a quest is completed.

**Parameters:**
- `quest_id` (String) - Quest identifier

**Example:**
```gdscript
PPQuestManager.quest_completed.connect(func(quest_id):
    print("Quest completed: %s" % quest_id)
    show_quest_complete_notification()
    play_success_sound()
)
```

---

### quest_failed

```gdscript
signal quest_failed(quest_id: String)
```

Emitted when a quest is failed.

**Parameters:**
- `quest_id` (String) - Quest identifier

**Example:**
```gdscript
PPQuestManager.quest_failed.connect(func(quest_id):
    print("Quest failed: %s" % quest_id)
    show_quest_failed_notification()
)
```

---

### quest_abandoned

```gdscript
signal quest_abandoned(quest_id: String)
```

Emitted when a quest is abandoned.

**Parameters:**
- `quest_id` (String) - Quest identifier

---

### all_quests_cleared

```gdscript
signal all_quests_cleared()
```

Emitted when all quests are cleared (e.g., new game).

---

## Methods

### start_quest

```gdscript
func start_quest(quest_entity: PPQuestEntity, player_level: int = 1) -> PPRuntimeQuest
```

Starts a new quest from a quest entity.

**Parameters:**
- `quest_entity` (PPQuestEntity) - Quest entity to start
- `player_level` (int) - 💎 Premium: Current player level for level requirement validation (default 1)

**Returns:** `PPRuntimeQuest` - Created runtime quest or `null` if failed

**Notes:**
- Validates prerequisites and requirements
- 💎 Premium: Checks level requirements
- Automatically adds to active quests
- Emits `quest_added` signal

**Example:**
```gdscript
# Core
var quest_entity = Pandora.get_entity("quest_village_help") as PPQuestEntity
var quest = PPQuestManager.start_quest(quest_entity)

if quest:
    print("Quest started: %s" % quest.get_quest_name())

# 💎 Premium (with level check)
var player_level = PPPlayerManager.get_level()
var quest = PPQuestManager.start_quest(quest_entity, player_level)

if not quest:
    print("Level too low for this quest!")
```

---

### start_quest_from_data

```gdscript
func start_quest_from_data(quest_data: PPQuest, player_level: int = 1) -> PPRuntimeQuest
```

Starts a quest from PPQuest data.

**Parameters:**
- `quest_data` (PPQuest) - Quest data
- `player_level` (int) - 💎 Premium: Current player level (default 1)

**Returns:** `PPRuntimeQuest` - Created runtime quest or `null`

---

### add_existing_quest

```gdscript
func add_existing_quest(runtime_quest: PPRuntimeQuest) -> void
```

Adds an existing runtime quest (used during save/load).

**Parameters:**
- `runtime_quest` (PPRuntimeQuest) - Existing runtime quest instance

**Notes:**
- Primarily used by save/load system
- Connects quest signals automatically

---

### complete_quest

```gdscript
func complete_quest(quest_id: String) -> bool
```

Completes a quest by ID.

**Parameters:**
- `quest_id` (String) - Quest identifier

**Returns:** `bool` - `true` if quest was completed

**Notes:**
- Moves quest from active to completed list
- Quest must be active to be completed
- Emits `quest_completed` signal

**Example:**
```gdscript
# Complete quest manually
if PPQuestManager.complete_quest("quest_village_help"):
    print("Quest completed!")
    give_rewards()
```

---

### fail_quest

```gdscript
func fail_quest(quest_id: String) -> bool
```

Fails a quest by ID.

**Parameters:**
- `quest_id` (String) - Quest identifier

**Returns:** `bool` - `true` if quest was failed

**Notes:**
- Moves quest from active to failed list
- Quest must be active to be failed
- Emits `quest_failed` signal

**Example:**
```gdscript
# 💎 Premium: Fail quest when time limit expires
if quest.is_time_expired():
    PPQuestManager.fail_quest(quest.get_quest_id())
```

---

### abandon_quest

```gdscript
func abandon_quest(quest_id: String) -> bool
```

Abandons a quest by ID.

**Parameters:**
- `quest_id` (String) - Quest identifier

**Returns:** `bool` - `true` if quest was abandoned

**Notes:**
- Removes quest from active quests (not added to completed or failed)
- Quest must be active to be abandoned
- Emits `quest_abandoned` signal

**Example:**
```gdscript
# Player abandons quest from quest log
func on_abandon_button_pressed(quest_id: String):
    var confirm = ConfirmationDialog.new()
    confirm.dialog_text = "Abandon this quest?"
    add_child(confirm)
    confirm.popup_centered()

    confirm.confirmed.connect(func():
        PPQuestManager.abandon_quest(quest_id)
        refresh_quest_log()
    )
```

---

### remove_quest

```gdscript
func remove_quest(quest_id: String) -> void
```

Removes a quest from active quests without changing its status.

**Parameters:**
- `quest_id` (String) - Quest identifier

**Notes:**
- Low-level method, prefer `abandon_quest`, `complete_quest`, or `fail_quest`

---

### get_active_quests

```gdscript
func get_active_quests() -> Array[PPRuntimeQuest]
```

Gets all active quests.

**Returns:** `Array[PPRuntimeQuest]` - Copy of active quests array

**Example:**
```gdscript
var active = PPQuestManager.get_active_quests()

for quest in active:
    print("Active: %s (%.0f%%)" % [
        quest.get_quest_name(),
        quest.get_progress_percentage()
    ])
```

---

### get_completed_quests

```gdscript
func get_completed_quests() -> Array[PPRuntimeQuest]
```

Gets all completed quests with full quest data.

**Returns:** `Array[PPRuntimeQuest]` - Copy of completed quests array

**Example:**
```gdscript
var completed = PPQuestManager.get_completed_quests()

for quest in completed:
    print("Completed: %s" % quest.get_quest_name())
    # Access rewards from completed quest
    for reward in quest.get_rewards():
        print("  Reward: %s" % reward.get_reward_name())
```

**Notes:**
- Contains full quest data including rewards
- Useful for displaying quest history with rewards
- Serialized during save/load operations

---

### get_failed_quests

```gdscript
func get_failed_quests() -> Array[PPRuntimeQuest]
```

Gets all failed quests with full quest data.

**Returns:** `Array[PPRuntimeQuest]` - Copy of failed quests array

**Example:**
```gdscript
var failed = PPQuestManager.get_failed_quests()

for quest in failed:
    print("Failed: %s" % quest.get_quest_name())
```

**Notes:**
- Contains full quest data
- Can be used for quest retry mechanics
- Serialized during save/load operations

---

### get_completed_quest_ids

```gdscript
func get_completed_quest_ids() -> Array[String]
```

Gets completed quest IDs (for backward compatibility).

**Returns:** `Array[String]` - Copy of completed quest IDs array

**Example:**
```gdscript
var completed = PPQuestManager.get_completed_quest_ids()
print("Completed %d quests" % completed.size())
```

**Notes:**
- Maintained for backward compatibility
- For full quest data, use `get_completed_quests()` instead

---

### get_failed_quest_ids

```gdscript
func get_failed_quest_ids() -> Array[String]
```

Gets failed quest IDs (for backward compatibility).

**Returns:** `Array[String]` - Copy of failed quest IDs array

**Notes:**
- Maintained for backward compatibility
- For full quest data, use `get_failed_quests()` instead

---

### find_quest

```gdscript
func find_quest(quest_id: String) -> PPRuntimeQuest
```

Finds a quest by ID in any state (active, completed, or failed).

**Parameters:**
- `quest_id` (String) - Quest identifier

**Returns:** `PPRuntimeQuest` - Quest instance or `null` if not found

**Notes:**
- Searches active quests first (most common case)
- Then searches completed quests
- Finally searches failed quests
- Use `find_active_quest()` if you only need active quests

**Example:**
```gdscript
var quest = PPQuestManager.find_quest("quest_village_help")

if quest:
    print("Quest status: %s" % quest.get_status_string())
    print("Progress: %.0f%%" % quest.get_progress_percentage())

    # Can find completed quests too
    if quest.is_completed():
        print("Quest rewards:")
        for reward in quest.get_rewards():
            print("  - %s" % reward.get_reward_name())
```

---

### find_active_quest

```gdscript
func find_active_quest(quest_id: String) -> PPRuntimeQuest
```

Finds an active quest by ID.

**Parameters:**
- `quest_id` (String) - Quest identifier

**Returns:** `PPRuntimeQuest` - Active quest instance or `null` if not found

**Notes:**
- Only searches in active quests
- Faster than `find_quest()` if you only need active quests
- Returns `null` if quest is completed or failed

**Example:**
```gdscript
var quest = PPQuestManager.find_active_quest("quest_village_help")

if quest:
    print("Active quest found!")
    # Track progress
    PPQuestUtils.track_item_collected(quest, item, 1)
else:
    print("Quest not active (may be completed or not started)")
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
if PPQuestManager.is_quest_active("quest_village_help"):
    show_quest_objective_marker()
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
if PPQuestManager.is_quest_completed("quest_village_help"):
    enable_village_shop()
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

---

### get_active_quest_count

```gdscript
func get_active_quest_count() -> int
```

Gets number of active quests.

**Returns:** `int` - Count of active quests

**Example:**
```gdscript
var count = PPQuestManager.get_active_quest_count()
quest_count_label.text = "Active Quests: %d" % count
```

---

### get_completed_quest_count

```gdscript
func get_completed_quest_count() -> int
```

Gets number of completed quests.

**Returns:** `int` - Count of completed quests

---

### clear_all

```gdscript
func clear_all() -> void
```

Clears all quest state (for new game).

**Notes:**
- Removes all active quests
- Clears completed quests array
- Clears failed quests array
- Clears completed and failed quest IDs
- Emits `all_quests_cleared` signal

---

### load_state

```gdscript
func load_state(game_state: PPGameState) -> void
```

Loads quest state from GameState (called by SaveManager).

**Parameters:**
- `game_state` (PPGameState) - Game state instance

**Notes:**
- Called automatically by `PPSaveManager.restore_state()`
- Clears existing quests and loads from save data
- Loads active quests with full progress
- Loads completed quests array (if available in save data)
- Loads failed quests array (if available in save data)
- Loads completed/failed IDs for backward compatibility

---

### save_state

```gdscript
func save_state(game_state: PPGameState) -> void
```

Saves quest state to GameState (called by SaveManager).

**Parameters:**
- `game_state` (PPGameState) - Game state instance to update

**Notes:**
- Called automatically by `PPSaveManager.save_game()`
- Saves active quests with full progress and rewards
- Saves completed quests array with full data
- Saves failed quests array with full data
- Saves completed/failed IDs for backward compatibility

---

### get_summary

```gdscript
func get_summary() -> String
```

Gets a debug summary of quest state.

**Returns:** `String` - Summary text including all active quests with progress

**Example:**
```gdscript
print(PPQuestManager.get_summary())

# Output:
# QuestManager State:
#   Active Quests: 3
#     - Village Help (Active, 66%)
#     - Find Sword (Active, 33%)
#     - Deliver Package (Active, 100%)
#   Completed: 12
#   Failed: 1
```

---

## Usage Examples

### Quest Lifecycle

```gdscript
extends Node

func start_game_quest():
    # Get quest entity
    var quest_entity = Pandora.get_entity("quest_village_help") as PPQuestEntity

    # Start quest
    var quest = PPQuestManager.start_quest(quest_entity)

    if quest:
        print("Quest started: %s" % quest.get_quest_name())
        show_quest_added_notification(quest)
    else:
        print("Failed to start quest (prerequisites not met)")

func track_quest_progress():
    var quest = PPQuestManager.find_quest("quest_village_help")

    if quest:
        # Track objective
        PPQuestUtils.track_item_collected(quest, "mushroom", 5)

        # Check if completed
        if quest.is_completed():
            print("Quest ready to turn in!")
            show_quest_marker_at_npc()

func complete_quest_at_npc():
    var quest_id = "quest_village_help"

    # Find the quest before completing it to access rewards
    var quest = PPQuestManager.find_active_quest(quest_id)

    if quest and PPQuestManager.complete_quest(quest_id):
        print("Quest completed!")

        # Give rewards (quest is now in completed quests, still accessible)
        var rewards = quest.get_rewards()
        for reward in rewards:
            apply_reward(reward)

        # Can also access from completed quests
        var completed_quest = PPQuestManager.find_quest(quest_id)
        if completed_quest:
            print("Quest stored in completed quests with rewards")
```

---

### Quest Log UI

```gdscript
extends Control

@onready var quest_list: ItemList = $QuestList
@onready var abandon_button: Button = $AbandonButton

func _ready():
    # Listen to quest events
    PPQuestManager.quest_added.connect(_on_quest_added)
    PPQuestManager.quest_removed.connect(_on_quest_removed)
    PPQuestManager.quest_completed.connect(_on_quest_completed)

    # Initial refresh
    refresh_quest_list()

func refresh_quest_list():
    quest_list.clear()

    var active = PPQuestManager.get_active_quests()

    for quest in active:
        var text = "%s\n  Progress: %.0f%%\n  Status: %s" % [
            quest.get_quest_name(),
            quest.get_progress_percentage(),
            quest.get_status_string()
        ]

        quest_list.add_item(text)
        quest_list.set_item_metadata(quest_list.get_item_count() - 1, quest.get_quest_id())

func _on_abandon_button_pressed():
    var selected = quest_list.get_selected_items()
    if selected.is_empty():
        return

    var quest_id = quest_list.get_item_metadata(selected[0])

    # Show confirmation
    var confirm = ConfirmationDialog.new()
    confirm.dialog_text = "Abandon this quest?"
    add_child(confirm)
    confirm.popup_centered()

    confirm.confirmed.connect(func():
        PPQuestManager.abandon_quest(quest_id)
    )

func _on_quest_added(runtime_quest):
    refresh_quest_list()

func _on_quest_removed(quest_id):
    refresh_quest_list()

func _on_quest_completed(quest_id):
    show_notification("Quest Completed!")
    refresh_quest_list()
```

---

### 💎 Premium: Level-Gated Quests

```gdscript
# 💎 Premium
extends Node

func try_start_quest(quest_entity: PPQuestEntity):
    # Get player level
    var player_level = PPPlayerManager.get_level()

    # Try to start quest with level check
    var quest = PPQuestManager.start_quest(quest_entity, player_level)

    if not quest:
        # Check why it failed
        var level_req = quest_entity.get_level_requirement()

        if level_req > 0 and player_level < level_req:
            show_error("Level %d required for this quest (you are level %d)" % [
                level_req,
                player_level
            ])
        else:
            show_error("Prerequisites not met")
    else:
        show_notification("Quest started: %s" % quest.get_quest_name())
```

---

### 💎 Premium: Timed Quest Tracking

```gdscript
# 💎 Premium
extends Control

@onready var timer_label: Label = $TimerLabel

var current_timed_quest: PPRuntimeQuest = null

func _ready():
    PPQuestManager.quest_added.connect(_on_quest_added)
    PPQuestManager.quest_failed.connect(_on_quest_failed)

func _on_quest_added(runtime_quest: PPRuntimeQuest):
    if runtime_quest.is_timed():
        current_timed_quest = runtime_quest
        set_process(true)

func _process(_delta):
    if not current_timed_quest:
        set_process(false)
        return

    if not current_timed_quest.is_active():
        current_timed_quest = null
        timer_label.visible = false
        return

    # Update timer display
    var remaining = current_timed_quest.get_time_remaining()
    timer_label.text = "Time: %02d:%02d" % [int(remaining / 60), int(remaining) % 60]
    timer_label.visible = true

    # Check expiration
    if current_timed_quest.is_time_expired():
        print("Quest time expired!")
        current_timed_quest = null

func _on_quest_failed(quest_id: String):
    if current_timed_quest and current_timed_quest.get_quest_id() == quest_id:
        show_notification("Quest failed: Time expired!")
        current_timed_quest = null
        timer_label.visible = false
```

---

### Quest Statistics

```gdscript
extends Control

func show_quest_statistics():
    var active_count = PPQuestManager.get_active_quest_count()
    var completed_count = PPQuestManager.get_completed_quest_count()
    var failed_count = PPQuestManager.get_failed_quest_ids().size()

    var total = active_count + completed_count + failed_count
    var completion_rate = 0.0

    if total > 0:
        completion_rate = (float(completed_count) / float(total)) * 100.0

    var stats_text = """
    Quest Statistics:
      Active: %d
      Completed: %d
      Failed: %d
      Total: %d
      Completion Rate: %.1f%%
    """ % [
        active_count,
        completed_count,
        failed_count,
        total,
        completion_rate
    ]

    print(stats_text)
```

---

## See Also

- [Quest System](../core-systems/quest-system.md) - Complete quest system guide
- [PPRuntimeQuest](runtime-quest.md) - Runtime quest API
- [PPQuestEntity](../entities/quest-entity.md) - Quest entity API
- [PPQuestUtils](../utilities/quest-utils.md) - Quest utility functions
- [Building a Quest Tutorial](../tutorials/building-quest.md) - Quest tutorial

---

*API Reference for Pandora+ v1.0.0*
