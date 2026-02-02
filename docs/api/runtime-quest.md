# PPRuntimeQuest

**Extends:** `Resource`

Runtime quest instance that tracks player progress, objective completion, and quest state during gameplay.

---

## Description

`PPRuntimeQuest` is the runtime counterpart to `PPQuest`. While `PPQuest` defines the static blueprint of a quest, `PPRuntimeQuest` tracks the dynamic state as the player progresses through it.

This class manages:
- Quest lifecycle (not started, active, completed, failed, abandoned)
- Individual objective progress through `PPRuntimeQuestObjective` instances
- Timing (when quest was started/completed)
- Reward delivery tracking
- Auto-completion when all objectives are done

---

## Enums

### QuestStatus

Current status of the quest.

| Value | Description |
|-------|-------------|
| `NOT_STARTED` | Quest has not been started yet |
| `ACTIVE` | Quest is currently in progress |
| `COMPLETED` | Quest has been completed successfully |
| `FAILED` | Quest has failed |
| `ABANDONED` | Quest was abandoned by the player |

---

## Signals

###### `quest_started()`

Emitted when the quest is started.

**Example:**
```gdscript
runtime_quest.quest_started.connect(func():
    print("Quest '%s' started!" % runtime_quest.get_quest_name())
)
```

---

###### `quest_completed()`

Emitted when the quest is completed.

---

###### `quest_failed()`

Emitted when the quest fails.

---

###### `quest_abandoned()`

Emitted when the quest is abandoned.

---

###### 💎 `time_limit_expired()`

Emitted when a timed quest's time limit expires.

**Premium Only**

**Example:**
```gdscript
runtime_quest.time_limit_expired.connect(func():
    print("Time's up! Quest failed.")
    show_time_expired_message()
)
```

---

###### `quest_progress_updated(completed_objectives: int, total_objectives: int, progress_percentage: float)`

Emitted when quest progress changes.

**Parameters:**
- `completed_objectives`: Number of completed objectives
- `total_objectives`: Total number of objectives
- `progress_percentage`: Progress as percentage (0-100)

**Example:**
```gdscript
runtime_quest.quest_progress_updated.connect(func(completed, total, percent):
    print("Progress: %d/%d (%.1f%%)" % [completed, total, percent])
)
```

---

###### `objective_completed(objective_index: int)`

Emitted when an objective is completed.

**Parameters:**
- `objective_index`: Index of the completed objective

---

###### `objective_activated(objective_index: int)`

Emitted when an objective becomes active.

**Parameters:**
- `objective_index`: Index of the activated objective

---

## Properties

###### `quest_data: Dictionary`

Serialized quest data from the `PPQuest` instance.

---

## Constructor

###### `PPRuntimeQuest(p_quest: Variant = null)`

Creates a runtime quest from either a `PPQuest` instance or a Dictionary.

**Parameters:**
- `p_quest`: Either a `PPQuest` instance or Dictionary with quest data

**Example:**
```gdscript
# From PPQuest instance
var quest_entity = Pandora.get_entity("TUTORIAL_QUEST") as PPQuestEntity
var quest_data = quest_entity.get_quest_data()
var runtime_quest = PPRuntimeQuest.new(quest_data)

# From dictionary (deserialization)
var saved_data = load_quest_from_file()
var runtime_quest = PPRuntimeQuest.from_dict(saved_data)
```

---

## Methods

### Getters

###### `get_quest_id() -> String`

Returns the quest ID.

---

###### `get_quest_name() -> String`

Returns the quest name.

---

###### `get_description() -> String`

Returns the quest description.

---

###### `get_quest_type() -> int`

Returns the quest type.

---

###### `get_quest_status() -> QuestStatus`

Returns the current quest status.

---

###### `get_runtime_objectives() -> Array[PPRuntimeQuestObjective]`

Returns array of runtime objective instances.

---

###### `get_rewards() -> Array[PPQuestReward]`

Returns array of quest rewards as `PPQuestReward` instances.

**Returns:** Array of `PPQuestReward` objects

**Example:**
```gdscript
var rewards = runtime_quest.get_rewards()
for reward in rewards:
    match reward.get_reward_type():
        PPQuestReward.RewardType.ITEM:
            print("Item: %s x%d" % [reward.get_reward_name(), reward.get_quantity()])
        PPQuestReward.RewardType.CURRENCY:
            print("Currency: %d gold" % reward.get_currency_amount())
        PPQuestReward.RewardType.EXPERIENCE:
            print("Experience: %d XP" % reward.get_experience_amount())
```

---

###### `get_start_timestamp() -> float`

Returns the timestamp when quest was started (seconds).

---

###### `get_completion_timestamp() -> float`

Returns the timestamp when quest was completed (seconds).

---

###### `is_auto_complete() -> bool`

Returns whether the quest auto-completes when all objectives are done.

---

###### `is_hidden() -> bool`

Returns whether quest details are hidden from player.

---

###### `get_delivered_rewards() -> Array[String]`

Returns array of reward IDs that have been delivered.

---

### Status Checks

###### `is_not_started() -> bool`

Returns `true` if quest hasn't been started.

---

###### `is_active() -> bool`

Returns `true` if quest is currently active.

---

###### `is_completed() -> bool`

Returns `true` if quest is completed.

---

###### `is_failed() -> bool`

Returns `true` if quest has failed.

---

###### `is_abandoned() -> bool`

Returns `true` if quest was abandoned.

---

###### `is_finished() -> bool`

Returns `true` if quest is in any finished state (completed, failed, or abandoned).

---

### 💎 Premium Features

###### 💎 `get_level_requirement() -> int`

Returns the minimum player level requirement for this quest.

**Premium Only**

**Returns:** Level requirement (default: 1)

**Example:**
```gdscript
var level_req = runtime_quest.get_level_requirement()
var player_level = PPPlayerManager.get_player_data().level

if player_level >= level_req:
    print("Quest available!")
else:
    print("Requires level %d (you are level %d)" % [level_req, player_level])
```

---

###### 💎 `get_time_limit() -> float`

Returns the time limit in seconds for completing the quest.

**Premium Only**

**Returns:** Time limit in seconds (0.0 = no time limit)

**Example:**
```gdscript
var time_limit = runtime_quest.get_time_limit()

if time_limit > 0:
    print("Complete within %.0f seconds" % time_limit)
```

---

###### 💎 `get_time_elapsed() -> float`

Returns the time elapsed since quest was started.

**Premium Only**

**Returns:** Elapsed time in seconds

**Example:**
```gdscript
var elapsed = runtime_quest.get_time_elapsed()
print("Time spent: %.1f seconds" % elapsed)
```

---

###### 💎 `get_time_remaining() -> float`

Returns the remaining time before time limit expires.

**Premium Only**

**Returns:** Remaining time in seconds, or `-1.0` if no time limit

**Example:**
```gdscript
var remaining = runtime_quest.get_time_remaining()

if remaining > 0:
    print("%.0f seconds left!" % remaining)
    update_timer_ui(remaining)
elif remaining == -1.0:
    print("No time limit")
```

---

###### 💎 `is_timed() -> bool`

Returns whether this quest has a time limit.

**Premium Only**

**Returns:** `true` if quest has time limit, `false` otherwise

**Example:**
```gdscript
if runtime_quest.is_timed():
    # Show timer UI
    timer_label.show()
    timer_label.text = "Time: %.0fs" % runtime_quest.get_time_remaining()
```

---

###### 💎 `update(delta: float) -> void`

Updates the quest timer. Must be called from game loop for timed quests.

**Premium Only**

**Parameters:**
- `delta`: Time elapsed since last frame (in seconds)

**Example:**
```gdscript
# In your quest manager's _process function
func _process(delta: float) -> void:
    for quest in active_quests:
        if quest.is_timed() and quest.is_active():
            quest.update(delta)

# Or connect to a timer
func _ready():
    var timer = Timer.new()
    add_child(timer)
    timer.timeout.connect(func():
        runtime_quest.update(timer.wait_time)
    )
    timer.start(1.0)  # Update every second
```

> ⚠️ **Important:** Timed quests will automatically fail when `time_limit_expired` signal is emitted. The `update()` method handles this internally.

---

### Progress Tracking

###### `get_completed_objectives_count() -> int`

Returns number of completed objectives.

💎 **Premium:** Excludes optional objectives from the count.

---

###### `get_total_objectives_count() -> int`

Returns total number of objectives.

💎 **Premium:** Excludes optional objectives from the count.

---

###### `get_required_objectives_count() -> int`

Returns number of required objectives (currently same as total).

---

###### `get_completed_required_objectives_count() -> int`

Returns number of completed required objectives.

---

###### `get_progress_percentage() -> float`

Returns quest completion percentage (0-100).

**Example:**
```gdscript
var progress = runtime_quest.get_progress_percentage()
progress_bar.value = progress
```

---

###### `are_all_required_objectives_completed() -> bool`

Returns `true` if all required objectives are completed.

---

### Quest Lifecycle

###### `start() -> void`

Starts the quest. Changes status to `ACTIVE` and activates all objectives.

**Example:**
```gdscript
if runtime_quest.is_not_started():
    runtime_quest.start()
    print("Quest started: %s" % runtime_quest.get_quest_name())
```

---

###### `complete() -> void`

Completes the quest. Changes status to `COMPLETED`.

**Example:**
```gdscript
if runtime_quest.are_all_required_objectives_completed():
    runtime_quest.complete()
    grant_quest_rewards(runtime_quest)
```

---

###### `fail() -> void`

Fails the quest. Changes status to `FAILED`.

---

###### `abandon() -> void`

Abandons the quest. Changes status to `ABANDONED`.

---

###### `reset() -> void`

Resets the quest to initial state. Clears all progress and delivered rewards.

---

### Objective Management

###### `add_objective(runtime_objective: PPRuntimeQuestObjective) -> void`

Adds a runtime objective to the quest.

---

###### `get_objective(index: int) -> PPRuntimeQuestObjective`

Returns the objective at specified index, or `null` if invalid.

**Example:**
```gdscript
var objective = runtime_quest.get_objective(0)
if objective:
    print("Objective progress: %d/%d" % [
        objective.get_current_progress(),
        objective.get_quest_objective_instance().get_target_quantity()
    ])
```

---

###### `find_objective_by_id(objective_id: String) -> PPRuntimeQuestObjective`

Finds an objective by its ID.

**Example:**
```gdscript
var obj = runtime_quest.find_objective_by_id("KILL_SLIMES")
if obj:
    obj.add_progress(1)
```

---

### Reward Management

###### `mark_reward_delivered(reward_id: String) -> void`

Marks a reward as delivered to prevent duplicate rewards.

---

###### `is_reward_delivered(reward_id: String) -> bool`

Checks if a reward has been delivered.

---

###### `are_all_rewards_delivered() -> bool`

Returns `true` if all rewards have been delivered.

---

### Serialization

###### `to_dict() -> Dictionary`

Serializes the runtime quest to a dictionary for saving.

**Returns:** Dictionary containing quest state

**Example:**
```gdscript
var save_data = runtime_quest.to_dict()
var file = FileAccess.open("user://quest_save.dat", FileAccess.WRITE)
file.store_var(save_data)
file.close()
```

---

###### `from_dict(data: Dictionary) -> PPRuntimeQuest` (static)

Deserializes a runtime quest from a dictionary.

**Parameters:**
- `data`: Dictionary created by `to_dict()`

**Returns:** New `PPRuntimeQuest` instance

**Example:**
```gdscript
var file = FileAccess.open("user://quest_save.dat", FileAccess.READ)
var save_data = file.get_var()
file.close()

var runtime_quest = PPRuntimeQuest.from_dict(save_data)
```

---

### Helper Methods

###### `get_display_text() -> String`

Returns formatted quest text with progress if not hidden.

**Example:**
```gdscript
var display = runtime_quest.get_display_text()
# Returns: "Tutorial Quest (75%)"
```

---

###### `get_status_string() -> String`

Returns human-readable status string.

**Example:**
```gdscript
var status = runtime_quest.get_status_string()
# Returns: "Active", "Completed", etc.
```

---

## Usage Example

### Example: Complete Quest System

```gdscript
extends Node

var active_quests: Array[PPRuntimeQuest] = []

func start_quest(quest_entity: PPQuestEntity) -> void:
    var quest_data = quest_entity.get_quest_data()
    var runtime_quest = PPRuntimeQuest.new(quest_data)

    # Connect signals
    runtime_quest.quest_started.connect(_on_quest_started.bind(runtime_quest))
    runtime_quest.quest_completed.connect(_on_quest_completed.bind(runtime_quest))
    runtime_quest.quest_progress_updated.connect(_on_quest_progress_updated.bind(runtime_quest))
    runtime_quest.objective_completed.connect(_on_objective_completed.bind(runtime_quest))

    # Start quest
    runtime_quest.start()
    active_quests.append(runtime_quest)

func _on_quest_started(quest: PPRuntimeQuest) -> void:
    print("Quest started: %s" % quest.get_quest_name())

    # Show quest UI
    show_quest_notification(quest.get_quest_name(), quest.get_description())

func _on_quest_completed(quest: PPRuntimeQuest) -> void:
    print("Quest completed: %s" % quest.get_quest_name())

    # Grant rewards
    grant_rewards(quest)

    # Remove from active quests
    active_quests.erase(quest)

    # Show completion UI
    show_quest_completion_screen(quest)

func _on_quest_progress_updated(completed: int, total: int, percent: float, quest: PPRuntimeQuest) -> void:
    print("Quest progress: %d/%d (%.1f%%)" % [completed, total, percent])
    update_quest_ui(quest)

func _on_objective_completed(obj_index: int, quest: PPRuntimeQuest) -> void:
    var objective = quest.get_objective(obj_index)
    print("Objective completed: %s" % objective.get_display_text())

func grant_rewards(quest: PPRuntimeQuest) -> void:
    var rewards = quest.get_rewards()

    for reward in rewards:
        if quest.is_reward_delivered(reward.get_reward_name()):
            continue

        match reward.get_reward_type():
            PPQuestReward.RewardType.ITEM:
                var item = reward.get_reward_entity()
                player.inventory.add_item(item, reward.get_quantity())

            PPQuestReward.RewardType.CURRENCY:
                player.inventory.game_currency += reward.get_currency_amount()

            PPQuestReward.RewardType.EXPERIENCE:
                player.add_experience(reward.get_experience_amount())

        quest.mark_reward_delivered(reward.get_reward_name())

func update_objective_progress(objective_id: String, delta: int) -> void:
    for quest in active_quests:
        var objective = quest.find_objective_by_id(objective_id)
        if objective:
            objective.add_progress(delta)
```

---

## Best Practices

### ✅ Connect to Signals for Reactive UI

```gdscript
# ✅ Good: React to quest events
runtime_quest.quest_progress_updated.connect(_update_quest_log)
runtime_quest.objective_completed.connect(_show_objective_notification)

# ❌ Bad: Poll for changes
func _process(_delta):
    check_quest_progress()  # Inefficient
```

---

### ✅ Check Status Before State Changes

```gdscript
# ✅ Good: Verify state before changing
if runtime_quest.is_active():
    runtime_quest.complete()

# ❌ Bad: Assume state (will push warning)
runtime_quest.complete()  # Might not be active
```

---

### ✅ Save Quest State Regularly

```gdscript
# ✅ Good: Save on significant events
func _on_objective_completed(idx: int, quest: PPRuntimeQuest):
    save_quest_state(quest)

# ✅ Good: Auto-save periodically
func _on_autosave_timer_timeout():
    for quest in active_quests:
        save_quest_state(quest)
```

---

## Common Patterns

### Pattern 1: Quest Journal

```gdscript
class QuestJournal:
    var active_quests: Array[PPRuntimeQuest] = []
    var completed_quests: Array[PPRuntimeQuest] = []

    func add_quest(quest: PPRuntimeQuest) -> void:
        quest.quest_completed.connect(_on_quest_completed.bind(quest))
        quest.start()
        active_quests.append(quest)

    func _on_quest_completed(quest: PPRuntimeQuest) -> void:
        active_quests.erase(quest)
        completed_quests.append(quest)

    func get_active_quest_list() -> Array[String]:
        var list: Array[String] = []
        for quest in active_quests:
            list.append(quest.get_display_text())
        return list
```

---

### Pattern 2: Objective Progress Tracking

```gdscript
# Track enemy kills for objectives
func _on_enemy_killed(enemy_id: String) -> void:
    for quest in active_quests:
        for objective in quest.get_runtime_objectives():
            var obj_data = objective.get_quest_objective_instance()
            var target = obj_data.get_target_entity()

            if target and target.get_entity_id() == enemy_id:
                objective.add_progress(1)

# Track item collection
func _on_item_collected(item_id: String, quantity: int) -> void:
    for quest in active_quests:
        var objective = quest.find_objective_by_id("COLLECT_" + item_id)
        if objective:
            objective.add_progress(quantity)
```

---

### Pattern 3: Quest Chain

```gdscript
# Sequential quest chain
var quest_chain = [
    "TUTORIAL_01",
    "TUTORIAL_02",
    "TUTORIAL_03"
]
var current_quest_index = 0

func start_next_quest_in_chain() -> void:
    if current_quest_index >= quest_chain.size():
        print("Quest chain completed!")
        return

    var quest_id = quest_chain[current_quest_index]
    var quest_entity = Pandora.get_entity(quest_id) as PPQuestEntity
    var runtime_quest = PPRuntimeQuest.new(quest_entity.get_quest_data())

    runtime_quest.quest_completed.connect(func():
        current_quest_index += 1
        start_next_quest_in_chain()
    )

    runtime_quest.start()
```

---

## Notes

### Auto-Complete Behavior

When `auto_complete` is `true`, the quest automatically calls `complete()` when all objectives are finished. Set to `false` for quests that require manual turn-in to an NPC.

### Objective Activation

All objectives are activated when `start()` is called. For sequential objectives, you can manually set `objective.set_active(false)` and activate them as needed.

### Reward Delivery

Use `mark_reward_delivered()` to track which rewards have been given. This prevents duplicate rewards if the player reloads the game or if rewards are granted in multiple steps.

---

## See Also

- [PPQuest](../api/quest.md) - Quest definition
- [PPRuntimeQuestObjective](../core-systems/quest-system.md#ppruntimequestobjective) - Runtime objective tracking
- [PPQuestEntity](../entities/quest-entity.md) - Quest entity wrapper
- [Quest System](../core-systems/quest-system.md) - Complete system overview
- [PPQuestUtils](../utilities/quest-utils.md) - Quest utility functions

---

*API Reference generated from source code*
