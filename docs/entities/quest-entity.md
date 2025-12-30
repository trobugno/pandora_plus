# PPQuestEntity

**Extends:** `PandoraEntity`

Quest entity wrapper that provides type-safe access to quest data stored in Pandora's entity system.

---

## Description

`PPQuestEntity` is a specialized entity class that extends Pandora's base `PandoraEntity` to provide convenient access to quest-related data. It wraps a `PPQuest` property and exposes methods to access quest information without manually retrieving properties.

This class serves as the bridge between Pandora's entity system and the quest runtime system, allowing you to define quests in the Pandora editor and instantiate them as `PPRuntimeQuest` instances.

---

## Properties

PPQuestEntity inherits all properties from `PandoraEntity` and typically contains:
- `quest_data` (PPQuest property): The main quest definition

---

## Methods

### Core Method

###### `get_quest_data() -> PPQuest`

Returns the `PPQuest` instance containing all quest data.

**Returns:** `PPQuest` instance or `null` if property not found

**Example:**
```gdscript
var quest_entity = Pandora.get_entity("TUTORIAL_QUEST") as PPQuestEntity
var quest_data = quest_entity.get_quest_data()

if quest_data:
    print("Quest: %s" % quest_data.get_quest_name())
    print("Description: %s" % quest_data.get_description())
```

---

### Convenience Methods

These methods provide direct access to quest properties without needing to call `get_quest_data()` first.

###### `get_quest_id() -> String`

Returns the quest's unique identifier.

**Example:**
```gdscript
var quest_id = quest_entity.get_quest_id()
print("Quest ID: %s" % quest_id)
```

---

###### `get_quest_name() -> String`

Returns the quest's display name.

---

###### `get_description() -> String`

Returns the quest description.

---

###### `get_quest_type() -> PPQuest.QuestType`

Returns the quest type from the `PPQuest.QuestType` enum.

**Example:**
```gdscript
var quest_type = quest_entity.get_quest_type()

match quest_type:
    PPQuest.QuestType.MAIN_STORY:
        print("This is a main story quest")
    PPQuest.QuestType.SIDE_QUEST:
        print("This is a side quest")
```

---

###### `get_objectives() -> Array[PPQuestObjective]`

Returns array of quest objectives.

**Example:**
```gdscript
var objectives = quest_entity.get_objectives()

for objective in objectives:
    print("Objective: %s" % objective.get_description())
```

---

###### `get_rewards() -> Array[PPQuestReward]`

Returns array of quest rewards.

**Example:**
```gdscript
var rewards = quest_entity.get_rewards()

for reward in rewards:
    match reward.get_reward_type():
        PPQuestReward.RewardType.ITEM:
            print("Item reward: %s" % reward.get_reward_entity().get_item_name())
        PPQuestReward.RewardType.CURRENCY:
            print("Gold reward: %d" % reward.get_currency_amount())
```

---

###### `get_prerequisites() -> Array`

Returns array of prerequisite quest references.

---

###### `is_auto_complete() -> bool`

Returns whether the quest auto-completes when all objectives are done.

---

###### `get_quest_giver() -> PandoraEntity`

Returns the entity that gives this quest (resolves the reference).

**Example:**
```gdscript
var giver = quest_entity.get_quest_giver()

if giver is PPNPCEntity:
    print("Quest giver: %s" % giver.get_npc_name())
```

---

###### `is_hidden() -> bool`

Returns whether quest details are hidden from the player.

---

###### `get_quest_category() -> String`

Returns the quest category.

---

## Usage Example

### Example: Quest Manager Integration

```gdscript
extends Node

var available_quests: Array[PPQuestEntity] = []
var active_quests: Array[PPRuntimeQuest] = []

func _ready():
    # Load all quest entities
    load_quest_entities()

func load_quest_entities() -> void:
    # Get all quest entities from Pandora
    var quest_ids = ["TUTORIAL_001", "MAIN_001", "SIDE_001"]

    for quest_id in quest_ids:
        var quest_entity = Pandora.get_entity(quest_id) as PPQuestEntity
        if quest_entity:
            available_quests.append(quest_entity)

func display_available_quests() -> void:
    print("=== Available Quests ===")

    for quest_entity in available_quests:
        print("\n%s" % quest_entity.get_quest_name())
        print("  Type: %s" % get_quest_type_name(quest_entity.get_quest_type()))
        print("  Description: %s" % quest_entity.get_description())
        print("  Objectives: %d" % quest_entity.get_objectives().size())
        print("  Rewards: %d" % quest_entity.get_rewards().size())

        var giver = quest_entity.get_quest_giver()
        if giver:
            print("  Quest Giver: %s" % giver.get_string("name"))

func start_quest(quest_entity: PPQuestEntity) -> void:
    # Create runtime instance
    var quest_data = quest_entity.get_quest_data()
    var runtime_quest = PPRuntimeQuest.new(quest_data)

    # Connect signals
    runtime_quest.quest_completed.connect(_on_quest_completed)

    # Start quest
    runtime_quest.start()
    active_quests.append(runtime_quest)

    print("Started quest: %s" % quest_entity.get_quest_name())

func _on_quest_completed() -> void:
    print("Quest completed!")

func get_quest_type_name(quest_type: int) -> String:
    match quest_type:
        PPQuest.QuestType.MAIN_STORY:
            return "Main Story"
        PPQuest.QuestType.SIDE_QUEST:
            return "Side Quest"
        PPQuest.QuestType.DAILY:
            return "Daily"
        PPQuest.QuestType.WEEKLY:
            return "Weekly"
        PPQuest.QuestType.REPEATABLE:
            return "Repeatable"
        _:
            return "Unknown"
```

---

### Example: NPC Quest Interaction

```gdscript
extends Area2D

@export var npc_entity_id: String = "VILLAGE_ELDER"

var npc_entity: PPNPCEntity
var available_quests: Array[PPQuestEntity] = []

func _ready():
    npc_entity = Pandora.get_entity(npc_entity_id) as PPNPCEntity

    # Get quests this NPC can give
    load_npc_quests()

    body_entered.connect(_on_player_interact)

func load_npc_quests() -> void:
    var quest_refs = npc_entity.get_quest_giver_for()

    for quest_ref in quest_refs:
        var quest_entity = quest_ref.get_entity() as PPQuestEntity
        if quest_entity:
            available_quests.append(quest_entity)

func _on_player_interact(body: Node) -> void:
    if not body.is_in_group("player"):
        return

    show_quest_dialog()

func show_quest_dialog() -> void:
    if available_quests.is_empty():
        show_dialog("I have nothing for you right now.")
        return

    print("=== %s has quests for you ===" % npc_entity.get_npc_name())

    for quest_entity in available_quests:
        print("\n[%s]" % quest_entity.get_quest_name())
        print("%s" % quest_entity.get_description())

        # Show objectives
        var objectives = quest_entity.get_objectives()
        print("\nObjectives:")
        for obj in objectives:
            if not obj.is_hidden():
                print("  - %s" % obj.get_description())

        # Show rewards
        var rewards = quest_entity.get_rewards()
        print("\nRewards:")
        for reward in rewards:
            print("  - %s" % reward.get_reward_name())
```

---

## Best Practices

### ✅ Cache Quest Entities

```gdscript
# ✅ Good: Cache quest entities
var quest_cache: Dictionary = {}

func get_quest(quest_id: String) -> PPQuestEntity:
    if not quest_cache.has(quest_id):
        quest_cache[quest_id] = Pandora.get_entity(quest_id) as PPQuestEntity
    return quest_cache[quest_id]

# ❌ Bad: Fetch repeatedly
func get_quest_name(quest_id: String) -> String:
    var quest = Pandora.get_entity(quest_id) as PPQuestEntity
    return quest.get_quest_name()
```

---

### ✅ Check Null Values

```gdscript
# ✅ Good: Verify entity exists
var quest_entity = Pandora.get_entity(quest_id) as PPQuestEntity

if not quest_entity:
    push_error("Quest entity not found: %s" % quest_id)
    return

var quest_data = quest_entity.get_quest_data()

# ❌ Bad: Assume entity exists
var quest_data = Pandora.get_entity(quest_id).get_quest_data()  # Can crash
```

---

### ✅ Use Convenience Methods

```gdscript
# ✅ Good: Use convenience methods
var quest_name = quest_entity.get_quest_name()
var objectives = quest_entity.get_objectives()

# ❌ Bad: Access quest_data unnecessarily
var quest_data = quest_entity.get_quest_data()
var quest_name = quest_data.get_quest_name()
var objectives = quest_data.get_objectives()
```

---

## Common Patterns

### Pattern 1: Quest Board System

```gdscript
class QuestBoard:
    var available_quests: Array[PPQuestEntity] = []
    var quest_filters: Dictionary = {}

    func add_quest(quest_entity: PPQuestEntity) -> void:
        available_quests.append(quest_entity)

    func filter_by_type(quest_type: PPQuest.QuestType) -> Array[PPQuestEntity]:
        return available_quests.filter(func(q):
            return q.get_quest_type() == quest_type
        )

    func filter_by_category(category: String) -> Array[PPQuestEntity]:
        return available_quests.filter(func(q):
            return q.get_quest_category() == category
        )

    func get_quest_by_id(quest_id: String) -> PPQuestEntity:
        for quest in available_quests:
            if quest.get_quest_id() == quest_id:
                return quest
        return null
```

---

### Pattern 2: Prerequisites Check

```gdscript
func can_start_quest(quest_entity: PPQuestEntity, completed_quests: Array[String]) -> bool:
    var prerequisites = quest_entity.get_prerequisites()

    for prereq_ref in prerequisites:
        var prereq_entity = prereq_ref.get_entity() as PPQuestEntity
        if not prereq_entity:
            continue

        var prereq_id = prereq_entity.get_quest_id()
        if prereq_id not in completed_quests:
            return false

    return true

func get_missing_prerequisites(quest_entity: PPQuestEntity, completed_quests: Array[String]) -> Array[PPQuestEntity]:
    var missing: Array[PPQuestEntity] = []
    var prerequisites = quest_entity.get_prerequisites()

    for prereq_ref in prerequisites:
        var prereq_entity = prereq_ref.get_entity() as PPQuestEntity
        if not prereq_entity:
            continue

        if prereq_entity.get_quest_id() not in completed_quests:
            missing.append(prereq_entity)

    return missing
```

---

### Pattern 3: Quest Chain Builder

```gdscript
func build_quest_chain(starting_quest_id: String) -> Array[PPQuestEntity]:
    var chain: Array[PPQuestEntity] = []
    var current_id = starting_quest_id

    while current_id:
        var quest_entity = Pandora.get_entity(current_id) as PPQuestEntity
        if not quest_entity:
            break

        chain.append(quest_entity)

        # Find next quest in chain (stored in custom data)
        var quest_data = quest_entity.get_quest_data()
        current_id = quest_data.get("next_quest_id", "")

    return chain
```

---

## Notes

### Entity vs Property

- **PPQuestEntity**: Pandora entity that stores quest data in the editor
- **PPQuest**: Property class containing the actual quest configuration
- **PPRuntimeQuest**: Runtime instance that tracks player progress

### Creating Quests in Pandora

1. Open Pandora editor
2. Create new entity with category "Quest"
3. Add `quest_data` property of type `PPQuest`
4. Configure objectives, rewards, and other settings
5. Save entity

### Integration with Quest System

Quest entities are designed to be loaded and converted to runtime instances:

```gdscript
var quest_entity = Pandora.get_entity("MY_QUEST") as PPQuestEntity
var quest_data = quest_entity.get_quest_data()
var runtime_quest = PPRuntimeQuest.new(quest_data)
runtime_quest.start()
```

---

## See Also

- [PPQuest](../api/quest.md) - Quest property definition
- [PPRuntimeQuest](../api/runtime-quest.md) - Runtime quest tracking
- [Quest System](../core-systems/quest-system.md) - Complete system overview
- [PPQuestUtils](../utilities/quest-utils.md) - Quest utility functions

---

*API Reference generated from source code*
