# PPQuest

**Extends:** `RefCounted`

Static quest definition containing immutable quest data including objectives, rewards, and prerequisites.

---

## Description

`PPQuest` is a property class that defines the static data for a quest. It represents the blueprint of a quest that can be instantiated at runtime through `PPRuntimeQuest` for tracking player progress. This class stores all quest configuration including objectives, rewards, prerequisites, and metadata.

Quests defined with `PPQuest` are typically stored in `PPQuestEntity` and then instantiated into `PPRuntimeQuest` when the player starts the quest.

---

## Enums

### QuestType

Defines the type and repeatability of a quest.

| Value | Description |
|-------|-------------|
| `MAIN_STORY` | Main storyline quest |
| `SIDE_QUEST` | Optional side quest |
| `DAILY` | Daily repeatable quest |
| `WEEKLY` | Weekly repeatable quest |
| `REPEATABLE` | Infinitely repeatable quest |

---

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `_quest_id` | `String` | Unique identifier for the quest |
| `_quest_name` | `String` | Display name of the quest |
| `_description` | `String` | Quest description shown to player |
| `_quest_type` | `int` | Quest type from `QuestType` enum |
| `_objectives` | `Array` | Array of `PPQuestObjective` instances |
| `_rewards` | `Array` | Array of `PPQuestReward` instances |
| `_prerequisites` | `Array` | Array of quest prerequisites (PandoraReference) |
| `_auto_complete` | `bool` | Whether quest completes automatically when all objectives are done |
| `_quest_giver` | `PandoraReference` | Reference to NPC or entity that gives this quest |
| `_hidden` | `bool` | Whether quest details are hidden from player |
| `_category` | `String` | Quest category for organization |
| 💎 `_level_requirement` | `int` | Minimum player level requirement (Premium only) |
| 💎 `_time_limit` | `float` | Time limit in seconds to complete quest (Premium only, 0 = no limit) |

---

## Constructor

###### `PPQuest(quest_id: String = "", quest_name: String = "", description: String = "", quest_type: int = QuestType.SIDE_QUEST, objectives: Array = [], rewards: Array = [], prerequisites: Array = [], auto_complete: bool = true, quest_giver: PandoraReference = null, hidden: bool = false, category: String = "")`

Creates a new quest definition with specified parameters.

**Parameters:**
- `quest_id`: Unique identifier
- `quest_name`: Display name
- `description`: Quest description
- `quest_type`: Quest type from enum (default: `SIDE_QUEST`)
- `objectives`: Array of objectives
- `rewards`: Array of rewards
- `prerequisites`: Array of prerequisite quests
- `auto_complete`: Auto-complete on objective completion (default: `true`)
- `quest_giver`: NPC or entity reference
- `hidden`: Hide quest details (default: `false`)
- `category`: Quest category

**Example:**
```gdscript
var main_quest = PPQuest.new(
    "MAIN_001",
    "The Beginning",
    "Start your adventure by talking to the elder.",
    PPQuest.QuestType.MAIN_STORY,
    [],  # Objectives added later
    [],  # Rewards added later
    [],  # No prerequisites
    true,
    elder_npc_reference,
    false,
    "Tutorial"
)
```

---

## Methods

### Getters

###### `get_quest_id() -> String`

Returns the quest's unique identifier.

---

###### `get_quest_name() -> String`

Returns the quest's display name.

---

###### `get_description() -> String`

Returns the quest description.

---

###### `get_quest_type() -> int`

Returns the quest type from `QuestType` enum.

---

###### `get_objectives() -> Array`

Returns array of quest objectives (`PPQuestObjective` instances).

---

###### `get_rewards() -> Array`

Returns array of quest rewards (`PPQuestReward` instances).

---

###### `get_prerequisites() -> Array`

Returns array of prerequisite quest references.

---

###### `is_auto_complete() -> bool`

Returns whether quest auto-completes when all objectives are finished.

---

###### `get_quest_giver() -> PandoraReference`

Returns reference to the quest giver entity.

---

###### `get_quest_giver_entity() -> PandoraEntity`

Returns the actual quest giver entity (resolves the reference).

**Example:**
```gdscript
var giver = quest.get_quest_giver_entity()
if giver is PPNPCEntity:
    print("Quest given by: %s" % giver.get_npc_name())
```

---

###### `is_hidden() -> bool`

Returns whether quest details are hidden from the player.

---

###### `get_category() -> String`

Returns the quest category.

---

###### 💎 `get_level_requirement() -> int`

Returns the minimum player level requirement.

**Returns:** Minimum level (default: 1)

**Premium Only**

**Example:**
```gdscript
if player_level >= quest.get_level_requirement():
    print("Quest available!")
else:
    print("You need level %d" % quest.get_level_requirement())
```

---

###### 💎 `get_time_limit() -> float`

Returns the time limit in seconds for completing the quest.

**Returns:** Time limit in seconds (0 = no time limit)

**Premium Only**

**Note:** Timed quests will fail automatically if not completed within the limit. Tracked by `PPRuntimeQuest`.

**Example:**
```gdscript
if quest.get_time_limit() > 0:
    var minutes = quest.get_time_limit() / 60.0
    print("Complete within %.1f minutes" % minutes)
```

---

### Setters

All properties have corresponding setter methods:
- `set_quest_id(quest_id: String)`
- `set_quest_name(quest_name: String)`
- `set_description(description: String)`
- `set_quest_type(quest_type: int)`
- `set_objectives(objectives: Array)`
- `set_rewards(rewards: Array)`
- `set_prerequisites(prerequisites: Array)`
- `set_auto_complete(auto_complete: bool)`
- `set_quest_giver(giver: PandoraReference)`
- `set_hidden(hidden: bool)`
- `set_category(category: String)`
- 💎 `set_level_requirement(level: int)` **(Premium only)**
- 💎 `set_time_limit(seconds: float)` **(Premium only)**

---

### Array Management

###### `add_objective(objective: PPQuestObjective) -> void`

Adds an objective to the quest.

**Example:**
```gdscript
var objective = PPQuestObjective.new(
    "KILL_SLIMES",
    0,  # Objective type
    "Defeat 5 slimes",
    slime_entity_reference,
    5
)
quest.add_objective(objective)
```

---

###### `remove_objective(objective: PPQuestObjective) -> void`

Removes an objective from the quest.

---

###### `update_objective_at(idx: int, objective: PPQuestObjective) -> void`

Updates or adds an objective at specific index.

---

###### `add_reward(reward: PPQuestReward) -> void`

Adds a reward to the quest.

**Example:**
```gdscript
var reward = PPQuestReward.new(
    "Gold Reward",
    PPQuestReward.RewardType.CURRENCY,
    null,
    0,
    100,  # 100 gold
    0
)
quest.add_reward(reward)
```

---

###### `remove_reward(reward: PPQuestReward) -> void`

Removes a reward from the quest.

---

###### `update_reward_at(idx: int, reward: PPQuestReward) -> void`

Updates or adds a reward at specific index.

---

###### `add_prerequisite(prerequisite: PandoraReference) -> void`

Adds a prerequisite quest.

---

###### `remove_prerequisite(prerequisite: PandoraReference) -> void`

Removes a prerequisite quest.

---

###### `update_prerequisite_at(idx: int, prerequisite: PandoraReference) -> void`

Updates or adds a prerequisite at specific index.

---

### Serialization

###### `load_data(data: Dictionary) -> void`

Loads quest data from a dictionary.

---

###### `save_data(fields_settings: Array[Dictionary], objective_fields_settings: Array[Dictionary] = [], reward_fields_settings: Array[Dictionary] = []) -> Dictionary`

Serializes quest data to a dictionary for saving.

**Parameters:**
- `fields_settings`: Field configuration for quest properties
- `objective_fields_settings`: Field configuration for objectives
- `reward_fields_settings`: Field configuration for rewards

**Returns:** Dictionary with quest data

---

## Usage Example

### Example: Creating a Complete Quest

```gdscript
extends Node

func create_tutorial_quest() -> PPQuest:
    # Create quest
    var quest = PPQuest.new()
    quest.set_quest_id("TUTORIAL_001")
    quest.set_quest_name("Welcome to the Village")
    quest.set_description("Meet the villagers and explore the area.")
    quest.set_quest_type(PPQuest.QuestType.MAIN_STORY)
    quest.set_auto_complete(true)
    quest.set_category("Tutorial")

    # Add objectives
    var talk_objective = PPQuestObjective.new(
        "TALK_TO_ELDER",
        0,
        "Talk to the village elder",
        elder_reference,
        1
    )
    quest.add_objective(talk_objective)

    var explore_objective = PPQuestObjective.new(
        "EXPLORE_VILLAGE",
        1,
        "Explore 3 locations",
        null,
        3
    )
    quest.add_objective(explore_objective)

    # Add rewards
    var gold_reward = PPQuestReward.new(
        "Tutorial Reward",
        PPQuestReward.RewardType.CURRENCY,
        null,
        0,
        50,  # Gold
        0
    )
    quest.add_reward(gold_reward)

    var xp_reward = PPQuestReward.new(
        "Tutorial XP",
        PPQuestReward.RewardType.EXPERIENCE,
        null,
        0,
        0,
        100  # XP
    )
    quest.add_reward(xp_reward)

    return quest
```

---

## Best Practices

### ✅ Use Quest Types Appropriately

```gdscript
# ✅ Good: Clear quest categorization
var main = PPQuest.new("M001", "Save the Kingdom", "", PPQuest.QuestType.MAIN_STORY)
var side = PPQuest.new("S001", "Find Lost Cat", "", PPQuest.QuestType.SIDE_QUEST)
var daily = PPQuest.new("D001", "Daily Bounty", "", PPQuest.QuestType.DAILY)

# ❌ Bad: Everything is MAIN_STORY
var quest = PPQuest.new("Q001", "Collect 5 Mushrooms", "", PPQuest.QuestType.MAIN_STORY)
```

---

### ✅ Set Quest Giver for Better Integration

```gdscript
# ✅ Good: Quest has a giver
var elder_ref = PandoraReference.new("VILLAGE_ELDER", PandoraReference.Type.ENTITY)
quest.set_quest_giver(elder_ref)

# ❌ Bad: No quest giver (makes NPC interaction harder)
quest.set_quest_giver(null)
```

---

### ✅ Use Auto-Complete Wisely

```gdscript
# ✅ Good: Simple quests auto-complete
fetch_quest.set_auto_complete(true)

# ✅ Good: Story quests require manual completion
boss_quest.set_auto_complete(false)  # Player must return to NPC

# ❌ Bad: All quests auto-complete (less engaging)
```

---

## Notes

### Quest ID Conventions

Use consistent naming conventions for quest IDs:
- Main quests: `MAIN_001`, `MAIN_002`, etc.
- Side quests: `SIDE_001`, `SIDE_002`, etc.
- Daily quests: `DAILY_001`, `DAILY_002`, etc.

### Prerequisites

Prerequisites are checked before offering the quest to the player. The quest system should verify all prerequisite quests are completed before making this quest available.

### Hidden Quests

Hidden quests don't show progress details to the player. Useful for:
- Secret objectives
- Discovery-based progression
- Surprise rewards

---

## See Also

- [PPQuestObjective](../api/quest-objective.md) - Quest objectives
- [PPQuestReward](../api/quest-reward.md) - Quest rewards
- [PPRuntimeQuest](../api/runtime-quest.md) - Runtime quest tracking
- [PPQuestEntity](../entities/quest-entity.md) - Quest entity wrapper
- [Quest System](../core-systems/quest-system.md) - Complete system overview

---

*API Reference generated from source code*
