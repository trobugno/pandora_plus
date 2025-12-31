# PPQuestUtils

Utility autoload providing comprehensive quest management functions including validation, tracking, rewards, filtering, and analytics.

---

## Overview

`PPQuestUtils` is an autoloaded singleton that provides helper functions for working with quests in Pandora+. It handles quest lifecycle, objective tracking, reward management, and quest queries.

**Access:** `PPQuestUtils` (globally available)

---

## Signals

### Validation Signals

```gdscript
signal quest_validation_failed(quest_id: String, reason: String)
signal quest_validation_passed(quest_id: String)
```

Emitted when quest validation succeeds or fails during `can_start_quest()`.

**Example:**
```gdscript
PPQuestUtils.quest_validation_failed.connect(_on_validation_failed)

func _on_validation_failed(quest_id: String, reason: String):
    print("Cannot start %s: %s" % [quest_id, reason])
```

### Quest Lifecycle Signals

```gdscript
signal quest_started(runtime_quest: PPRuntimeQuest)
signal quest_objective_progressed(quest_id: String, objective_index: int, progress: int, target: int)
signal quest_ready_to_complete(quest_id: String)
```

Emitted during quest progression.

**Example:**
```gdscript
PPQuestUtils.quest_objective_progressed.connect(_on_objective_progress)

func _on_objective_progress(quest_id: String, index: int, current: int, target: int):
    print("Quest %s objective %d: %d/%d" % [quest_id, index, current, target])
```

### Reward Signals

```gdscript
signal rewards_granted(quest_id: String, rewards: Array)
signal reward_grant_failed(quest_id: String, reward: PPQuestReward, reason: String)
```

Emitted when quest rewards are granted.

---

## Quest Lifecycle Management

### start_quest()

Starts a quest from a `PPQuestEntity`.

```gdscript
func start_quest(
    quest_entity: PPQuestEntity,
    player_level: int = 1,  # 💎 Premium parameter
    completed_quest_ids: Array[String] = []
) -> PPRuntimeQuest
```

**Parameters:**
- `quest_entity`: Quest entity to start
- 💎 `player_level`: Player's current level (Premium: used for level requirement checking, Core: defaults to 1)
- `completed_quest_ids`: Array of completed quest IDs (for prerequisite checking)

**Returns:** `PPRuntimeQuest` instance or `null` if validation fails

**Example:**
```gdscript
var quest_entity = Pandora.get_entity("quest_village_help") as PPQuestEntity
var completed_ids = PPQuestManager.get_completed_quest_ids()

# Core usage
var runtime_quest = PPQuestUtils.start_quest(quest_entity, 1, completed_ids)

# 💎 Premium: Check player level
var player_level = PPPlayerManager.get_player_data().level
var runtime_quest = PPQuestUtils.start_quest(quest_entity, player_level, completed_ids)

if runtime_quest:
    print("Quest started: ", runtime_quest.get_quest_name())
else:
    print("Failed to start quest (check level requirement)")
```

---

### start_quest_from_data()

Starts a quest from `PPQuest` data directly.

```gdscript
func start_quest_from_data(
    quest_data: PPQuest,
    player_level: int,  # 💎 Premium parameter
    completed_quest_ids: Array[String] = []
) -> PPRuntimeQuest
```

**Parameters:**
- `quest_data`: PPQuest data to start
- 💎 `player_level`: Player's current level (Premium: validates level requirement)
- `completed_quest_ids`: Array of completed quest IDs

**Example:**
```gdscript
var quest_data = PPQuest.new()
quest_data.set_quest_id("test_quest")
# ... configure quest ...

# Core usage
var runtime_quest = PPQuestUtils.start_quest_from_data(quest_data, 1, [])

# 💎 Premium usage
var player_level = PPPlayerManager.get_player_data().level
var runtime_quest = PPQuestUtils.start_quest_from_data(quest_data, player_level, [])
```

---

## Validation

### can_start_quest()

Checks if a quest can be started.

```gdscript
func can_start_quest(
    quest: PPQuest,
    player_level: int,  # 💎 Premium parameter
    completed_quest_ids: Array[String] = []
) -> bool
```

**Checks:**
- 💎 **Premium:** Player level meets requirement
- Prerequisites are met (all required quests completed)

**Parameters:**
- `quest`: Quest data to validate
- 💎 `player_level`: Player's current level
- `completed_quest_ids`: Array of completed quest IDs

**Example:**
```gdscript
var quest_data = quest_entity.get_quest_data()
var completed = PPQuestManager.get_completed_quest_ids()

# Core usage
if PPQuestUtils.can_start_quest(quest_data, 1, completed):
    print("Can start quest")
else:
    print("Prerequisites not met")

# 💎 Premium: Check with player level
var player_level = PPPlayerManager.get_player_data().level
if PPQuestUtils.can_start_quest(quest_data, player_level, completed):
    print("Can start quest")
else:
    print("Level too low or prerequisites not met")
```

---

### check_prerequisites()

Checks if all quest prerequisites are completed.

```gdscript
func check_prerequisites(
    quest: PPQuest,
    completed_quest_ids: Array[String]
) -> bool
```

**Example:**
```gdscript
if PPQuestUtils.check_prerequisites(quest_data, completed_ids):
    print("All prerequisites met")
```

---

### can_complete_quest()

Checks if a runtime quest can be completed.

```gdscript
func can_complete_quest(runtime_quest: PPRuntimeQuest) -> bool
```

**Example:**
```gdscript
if PPQuestUtils.can_complete_quest(runtime_quest):
    PPQuestManager.complete_quest(runtime_quest.get_quest_id())
```

---

## Objective Tracking

### track_objective_progress()

Generic method to track progress on any objective type.

```gdscript
func track_objective_progress(
    runtime_quest: PPRuntimeQuest,
    objective_type: int,
    entity_id: String,
    quantity: int = 1
) -> void
```

**Parameters:**
- `runtime_quest`: Quest to track
- `objective_type`: Objective type from `PPObjectiveEntity.ObjectiveType`
- `entity_id`: Target entity ID
- `quantity`: Amount to progress

**Example:**
```gdscript
PPQuestUtils.track_objective_progress(
    runtime_quest,
    PPObjectiveEntity.ObjectiveType.KILL,
    "goblin",
    1
)
```

---

### track_item_collected()

Tracks item collection for COLLECT objectives.

```gdscript
func track_item_collected(
    runtime_quest: PPRuntimeQuest,
    item: PPItemEntity,
    quantity: int = 1
) -> void
```

**Example:**
```gdscript
func on_item_picked_up(item: PPItemEntity, qty: int):
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_item_collected(quest, item, qty)
```

---

### track_enemy_killed()

Tracks enemy kills for KILL objectives.

```gdscript
func track_enemy_killed(
    runtime_quest: PPRuntimeQuest,
    enemy_entity: PandoraEntity
) -> void
```

**Example:**
```gdscript
func on_enemy_died(enemy: PandoraEntity):
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_enemy_killed(quest, enemy)
```

---

### track_npc_talked()

Tracks NPC dialogue for TALK objectives.

```gdscript
func track_npc_talked(
    runtime_quest: PPRuntimeQuest,
    npc: PandoraEntity
) -> void
```

**Example:**
```gdscript
func on_dialogue_started(npc: PPNPCEntity):
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_npc_talked(quest, npc)
```

---

### 💎 track_item_crafted()

Tracks item crafting for CRAFT_ITEM objectives.

**Premium Only**

```gdscript
func track_item_crafted(
    runtime_quest: PPRuntimeQuest,
    item: PPItemEntity,
    quantity: int = 1
) -> void
```

**Parameters:**
- `runtime_quest`: Quest to track
- `item`: Item that was crafted
- `quantity`: Number of items crafted (default: 1)

**Example:**
```gdscript
func on_item_crafted(item: PPItemEntity, qty: int):
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_item_crafted(quest, item, qty)
```

---

### 💎 track_item_used()

Tracks item usage for USE_ITEM objectives.

**Premium Only**

```gdscript
func track_item_used(
    runtime_quest: PPRuntimeQuest,
    item: PPItemEntity
) -> void
```

**Example:**
```gdscript
func on_item_used(item: PPItemEntity):
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_item_used(quest, item)
```

---

### 💎 track_item_delivered()

Tracks item delivery for DELIVER objectives.

**Premium Only**

```gdscript
func track_item_delivered(
    runtime_quest: PPRuntimeQuest,
    item: PPItemEntity,
    npc: PandoraEntity
) -> void
```

**Parameters:**
- `runtime_quest`: Quest to track
- `item`: Item that was delivered
- `npc`: NPC the item was delivered to

**Example:**
```gdscript
func on_item_delivered_to_npc(item: PPItemEntity, npc: PPNPCEntity):
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_item_delivered(quest, item, npc)
```

---

### 💎 track_location_reached()

Tracks location discovery for REACH_LOCATION objectives.

**Premium Only**

```gdscript
func track_location_reached(
    runtime_quest: PPRuntimeQuest,
    location_entity: PandoraEntity
) -> void
```

**Parameters:**
- `runtime_quest`: Quest to track
- `location_entity`: Location entity that was reached

**Example:**
```gdscript
func on_area_entered(area_entity: PandoraEntity):
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_location_reached(quest, area_entity)
```

---

### track_across_quests()

Tracks objectives across multiple active quests simultaneously.

```gdscript
func track_across_quests(
    active_quests: Array[PPRuntimeQuest],
    tracker_func: Callable
) -> void
```

**Example:**
```gdscript
var active_quests = PPQuestManager.get_active_quests()
var item = Pandora.get_entity("healing_herb") as PPItemEntity

PPQuestUtils.track_across_quests(
    active_quests,
    func(q): PPQuestUtils.track_item_collected(q, item, 1)
)
```

---

### find_tracking_objectives()

Finds all objectives across active quests that track a specific entity.

```gdscript
func find_tracking_objectives(
    active_quests: Array[PPRuntimeQuest],
    entity_id: String,
    objective_type: int = -1
) -> Array
```

**Returns:** Array of dictionaries with keys:
- `quest`: PPRuntimeQuest
- `objective_index`: int
- `runtime_objective`: PPRuntimeObjective
- `objective_data`: PPQuestObjective

**Example:**
```gdscript
var tracking = PPQuestUtils.find_tracking_objectives(
    active_quests,
    "goblin",
    PPObjectiveEntity.ObjectiveType.KILL
)

for obj_info in tracking:
    print("Quest %s is tracking goblin kills" % obj_info["quest"].get_quest_name())
```

---

## Reward Management

### grant_quest_rewards()

Grants all rewards from a quest.

```gdscript
func grant_quest_rewards(
    quest: PPQuest,
    inventory: PPInventory = null
) -> Array[String]
```

**Parameters:**
- `quest`: Quest with rewards
- `inventory`: Player inventory (required for ITEM rewards)

**Returns:** Array of successfully granted reward names

**Example:**
```gdscript
var quest_data = runtime_quest.get_quest_data_instance()
var inventory = player.inventory

var granted = PPQuestUtils.grant_quest_rewards(quest_data, inventory)
print("Granted %d rewards" % granted.size())
```

---

### grant_reward()

Grants a single reward.

```gdscript
func grant_reward(
    reward: PPQuestReward,
    inventory: PPInventory = null,
    quest_id: String = ""
) -> bool
```

**Returns:** `true` if reward was granted successfully

**Note:** CURRENCY and EXPERIENCE rewards return `true` but must be handled by the game (listen to `rewards_granted` signal).

---

### calculate_total_experience()

Calculates total experience from all quest rewards.

```gdscript
func calculate_total_experience(quest: PPQuest) -> int
```

**Example:**
```gdscript
var exp = PPQuestUtils.calculate_total_experience(quest_data)
player.add_experience(exp)
```

---

### calculate_total_currency()

Calculates total currency from all quest rewards.

```gdscript
func calculate_total_currency(quest: PPQuest) -> int
```

**Example:**
```gdscript
var gold = PPQuestUtils.calculate_total_currency(quest_data)
player.add_currency(gold)
```

---

### get_item_rewards()

Gets all item rewards from a quest.

```gdscript
func get_item_rewards(quest: PPQuest) -> Array[Dictionary]
```

**Returns:** Array of dictionaries with keys:
- `item`: PPItemEntity
- `quantity`: int

**Example:**
```gdscript
var items = PPQuestUtils.get_item_rewards(quest_data)
for item_info in items:
    print("Reward: %dx %s" % [
        item_info["quantity"],
        item_info["item"].get_item_name()
    ])
```

---

## Filtering & Queries

### get_available_quests()

Gets all quests available for a player based on level and completed quests.

```gdscript
func get_available_quests(
    all_quests: Array,
    player_level: int,  # 💎 Premium parameter
    completed_quest_ids: Array[String] = []
) -> Array
```

**Accepts:** Array of `PPQuestEntity` or `PPQuest`

**Parameters:**
- `all_quests`: Array of all quests to filter
- 💎 `player_level`: Player's current level (Premium: validates level requirements)
- `completed_quest_ids`: Array of completed quest IDs

**Example:**
```gdscript
var all_quests = get_all_quest_entities()
var completed = PPQuestManager.get_completed_quest_ids()

# Core usage
var available = PPQuestUtils.get_available_quests(all_quests, 1, completed)

# 💎 Premium: Filter by player level
var player_level = PPPlayerManager.get_player_data().level
var available = PPQuestUtils.get_available_quests(all_quests, player_level, completed)

print("Available quests: %d" % available.size())
```

---

### get_quests_by_category()

Filters quests by category.

```gdscript
func get_quests_by_category(quests: Array, category: String) -> Array
```

**Example:**
```gdscript
var main_quests = PPQuestUtils.get_quests_by_category(all_quests, "Main Quest")
```

---

### get_quests_by_type()

Filters quests by type.

```gdscript
func get_quests_by_type(quests: Array, quest_type: int) -> Array
```

**Example:**
```gdscript
var daily_quests = PPQuestUtils.get_quests_by_type(all_quests, QUEST_TYPE_DAILY)
```

---

### get_active_quests()

Gets all active runtime quests from a collection.

```gdscript
func get_active_quests(runtime_quests: Array[PPRuntimeQuest]) -> Array[PPRuntimeQuest]
```

---

### get_completed_quests()

Gets all completed runtime quests from a collection.

```gdscript
func get_completed_quests(runtime_quests: Array[PPRuntimeQuest]) -> Array[PPRuntimeQuest]
```

---

## Sorting

### sort_quests()

Sorts runtime quests by various criteria.

```gdscript
func sort_quests(quests: Array[PPRuntimeQuest], sort_by: String = "name") -> void
```

**Sort options:**
- `"name"`: Alphabetical by quest name
- `"progress"`: By completion percentage (highest first)
- `"type"`: By quest type
- 💎 `"level"`: By level requirement (lowest first) - **Premium Only**
- 💎 `"time_remaining"`: By time remaining (least time first, non-timed last) - **Premium Only**

**Example:**
```gdscript
var active_quests = PPQuestManager.get_active_quests()
PPQuestUtils.sort_quests(active_quests, "progress")

for quest in active_quests:
    print("%s: %.0f%%" % [quest.get_quest_name(), quest.get_progress_percentage()])

# 💎 Premium: Sort by urgency (time remaining)
PPQuestUtils.sort_quests(active_quests, "time_remaining")
for quest in active_quests:
    if quest.is_timed():
        print("%s: %.0fs left" % [quest.get_quest_name(), quest.get_time_remaining()])
```

---

## Statistics & Analytics

### calculate_quest_stats()

Calculates various statistics about completed quests.

```gdscript
func calculate_quest_stats(completed_quests: Array[PPRuntimeQuest]) -> Dictionary
```

**Returns:** Dictionary with keys:
- `total_quests`: int
- `by_type`: Dictionary (type → count)
- `by_category`: Dictionary (category → count)
- `total_experience`: int
- `total_currency`: int
- 💎 `average_completion_time`: float - **Premium Only**
- 💎 `fastest_completion`: float - **Premium Only**
- 💎 `slowest_completion`: float - **Premium Only**

**Example:**
```gdscript
var completed = PPQuestManager.get_completed_quests()
var stats = PPQuestUtils.calculate_quest_stats(completed)

print("Completed %d quests" % stats["total_quests"])
print("Earned %d XP total" % stats["total_experience"])

# 💎 Premium: Completion time analytics
print("Average time: %.1f seconds" % stats["average_completion_time"])
print("Fastest: %.1f seconds" % stats["fastest_completion"])
print("Slowest: %.1f seconds" % stats["slowest_completion"])
```

---

### get_most_completed_quest_type()

Gets the most completed quest type.

```gdscript
func get_most_completed_quest_type(completed_quests: Array[PPRuntimeQuest]) -> int
```

**Returns:** Quest type ID or `-1` if none

---

## 💎 Time Management

**Premium Only**

### update_timed_quests()

Updates all timed quests and returns quests that have expired.

```gdscript
func update_timed_quests(
    active_quests: Array[PPRuntimeQuest],
    delta: float
) -> Array[PPRuntimeQuest]
```

**Parameters:**
- `active_quests`: Array of active quests to update
- `delta`: Time elapsed since last update (in seconds)

**Returns:** Array of quests that expired during this update

**Example:**
```gdscript
# In your game loop (_process or timer)
func _process(delta: float) -> void:
    var expired = PPQuestUtils.update_timed_quests(
        PPQuestManager.get_active_quests(),
        delta
    )

    for quest in expired:
        print("Quest '%s' failed due to time limit" % quest.get_quest_name())
        show_notification("Quest Failed: Time's Up!")
```

---

### get_expired_quests()

Gets all quests that have expired (time limit reached).

```gdscript
func get_expired_quests(active_quests: Array[PPRuntimeQuest]) -> Array[PPRuntimeQuest]
```

**Returns:** Array of expired quests

**Example:**
```gdscript
var expired = PPQuestUtils.get_expired_quests(PPQuestManager.get_active_quests())

if not expired.is_empty():
    print("Warning: %d quests have expired!" % expired.size())
    for quest in expired:
        print("  - %s" % quest.get_quest_name())
```

---

## NPC Integration

### validate_quest_giver()

Validates that an NPC can give a specific quest.

```gdscript
func validate_quest_giver(quest: PPQuestEntity, npc: PPNPCEntity) -> bool
```

**Example:**
```gdscript
if PPQuestUtils.validate_quest_giver(quest_entity, npc_entity):
    print("NPC can give this quest")
```

---

### can_obtain_quest_from_npc()

Checks if a quest can be obtained from an NPC at the current time.

```gdscript
func can_obtain_quest_from_npc(
    quest: PPQuestEntity,
    npc_runtime: PPRuntimeNPC,
    player_level: int,  # 💎 Premium parameter
    completed_quest_ids: Array[String] = []
) -> bool
```

**Checks:**
- NPC is quest giver for this quest
- NPC is alive
- 💎 **Premium:** NPC is not sleeping (respects schedule)
- 💎 **Premium:** NPC is not hostile (reputation check)
- 💎 **Premium:** Player level meets requirement
- Player meets quest prerequisites

**Parameters:**
- `quest`: Quest entity to check
- `npc_runtime`: Runtime NPC instance
- 💎 `player_level`: Player's current level
- `completed_quest_ids`: Array of completed quest IDs

**Example:**
```gdscript
# Core usage
if PPQuestUtils.can_obtain_quest_from_npc(quest, runtime_npc, 1, completed_ids):
    show_quest_dialogue()

# 💎 Premium: Full validation with level check
var player_level = PPPlayerManager.get_player_data().level
if PPQuestUtils.can_obtain_quest_from_npc(quest, runtime_npc, player_level, completed_ids):
    show_quest_dialogue()
else:
    print("Cannot get quest (check level, reputation, or NPC schedule)")
```

---

### find_quest_givers_for_quest()

Gets all NPCs that can give a specific quest.

```gdscript
func find_quest_givers_for_quest(npcs: Array, quest: PPQuestEntity) -> Array
```

**Example:**
```gdscript
var all_npcs = get_spawned_npcs()
var givers = PPQuestUtils.find_quest_givers_for_quest(all_npcs, quest_entity)

for npc in givers:
    print("%s can give this quest" % npc.get_npc_name())
```

---

## Debug Utilities

### debug_print_quest()

Prints detailed information about a runtime quest.

```gdscript
func debug_print_quest(runtime_quest: PPRuntimeQuest) -> void
```

**Example:**
```gdscript
PPQuestUtils.debug_print_quest(runtime_quest)
```

**Output:**
```
=== Quest Debug Info ===
ID: village_rescue
Name: Village in Danger
Status: Active
Progress: 60.00%

Objectives:
  [0] Kill 5 goblins - ○ (3/5)
  [1] Collect 3 healing herbs - ✓ (3/3)
====================
```

---

### debug_print_active_quests()

Prints all active quests.

```gdscript
func debug_print_active_quests(active_quests: Array[PPRuntimeQuest]) -> void
```

**Example:**
```gdscript
var active = PPQuestManager.get_active_quests()
PPQuestUtils.debug_print_active_quests(active)
```

**Output:**
```
=== Active Quests (2) ===
Village in Danger - 60.00%
Find the Lost Sword - 25.00%
====================
```

---

## See Also

- [Quest System](../core-systems/quest-system.md) - Quest system overview
- [PPQuestManager](../api/quest-manager.md) - Quest manager
- [PPRuntimeQuest](../api/runtime-quest.md) - Runtime quest API
- [PPQuest](../api/quest.md) - Quest data model

---

*API Reference for Pandora+ v1.0.0*
