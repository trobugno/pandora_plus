# PPQuestObjective

**Extends:** `RefCounted`

Static quest objective definition containing immutable objective data including targets, quantities, and conditions.

---

## Description

`PPQuestObjective` is a property class that defines a single objective within a quest. It represents the static blueprint for what the player must accomplish, which is then tracked at runtime through `PPRuntimeQuestObjective`.

Objectives can target specific entities (enemies, items, locations) and track progress toward a target quantity. They can be hidden from the player or include custom scripts for complex logic.

---

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `_objective_id` | `String` | Unique identifier for the objective |
| `_objective_type` | `int` | Type of objective (game-defined) |
| `_description` | `String` | Description shown to player |
| `_target_reference` | `PandoraReference` | Reference to target entity (enemy, item, location, etc.) |
| `_target_quantity` | `int` | Number required to complete objective |
| 💎 `_optional` | `bool` | Whether objective is optional (Premium only) |
| `_hidden` | `bool` | Whether objective progress is hidden from player |
| 💎 `_sequential` | `bool` | Whether objective must be completed in order (Premium only) |
| 💎 `_order_index` | `int` | Position in sequential order, starts at 0 (Premium only) |
| `_custom_script` | `String` | Path to custom script for complex logic |

---

## Constructor

###### Core: `PPQuestObjective(objective_id, objective_type, description, target_reference, target_quantity, hidden, custom_script)`

###### 💎 Premium: `PPQuestObjective(objective_id, objective_type, description, target_reference, target_quantity, optional, hidden, sequential, order_index, custom_script)`

Creates a new quest objective with specified parameters.

**Parameters:**
- `objective_id`: Unique identifier (default: `""`)
- `objective_type`: Type identifier (game-defined enum) (default: `-1`)
- `description`: Player-facing description (default: `""`)
- `target_reference`: Target entity reference (can be `null`) (default: `null`)
- `target_quantity`: Required quantity (default: `0`)
- 💎 `optional`: Whether objective is optional **(Premium only)** (default: `false`)
- `hidden`: Hide progress from player (default: `false`)
- 💎 `sequential`: Must complete in order **(Premium only)** (default: `false`)
- 💎 `order_index`: Position in sequential order **(Premium only)** (default: `0`)
- `custom_script`: Custom script path (default: `""`)

**Example:**
```gdscript
# Kill objective
var kill_obj = PPQuestObjective.new(
    "KILL_GOBLINS",
    ObjectiveType.KILL,
    "Defeat 10 goblins",
    goblin_entity_reference,
    10,
    false
)

# Collection objective
var collect_obj = PPQuestObjective.new(
    "COLLECT_HERBS",
    ObjectiveType.COLLECT,
    "Gather 5 healing herbs",
    herb_entity_reference,
    5,
    false
)

# Hidden discovery objective
var secret_obj = PPQuestObjective.new(
    "FIND_SECRET",
    ObjectiveType.DISCOVER,
    "Find the hidden treasure",
    treasure_location_reference,
    1,
    true  # Hidden
)
```

---

## Methods

### Getters

###### `get_objective_id() -> String`

Returns the objective's unique identifier.

---

###### `get_objective_type() -> int`

Returns the objective type identifier.

---

###### `get_description() -> String`

Returns the objective description shown to players.

---

###### `get_target_reference() -> PandoraReference`

Returns the reference to the target entity.

---

###### `get_target_entity() -> PandoraEntity`

Returns the actual target entity (resolves the reference).

**Example:**
```gdscript
var target = objective.get_target_entity()
if target is PPItemEntity:
    print("Collect: %s" % target.get_item_name())
```

---

###### `get_target_quantity() -> int`

Returns the required quantity to complete the objective.

---

###### 💎 `is_optional() -> bool`

Returns whether the objective is optional.

**Premium Only**

**Example:**
```gdscript
if not objective.is_optional():
    print("This is a required objective")
```

---

###### `is_hidden() -> bool`

Returns whether the objective progress is hidden from the player.

---

###### 💎 `is_sequential() -> bool`

Returns whether the objective must be completed in sequential order.

**Premium Only**

**Note:** Sequential objectives activate only after the previous objective is completed.

**Example:**
```gdscript
if objective.is_sequential():
    print("Complete objectives in order: %d" % objective.get_order_index())
```

---

###### 💎 `get_order_index() -> int`

Returns the position of this objective in the sequential order.

**Returns:** Order index (0 = first objective)

**Premium Only**

---

###### `get_custom_script() -> String`

Returns the path to the custom script.

---

### Setters

All properties have corresponding setter methods:
- `set_objective_id(objective_id: String)`
- `set_objective_type(objective_type: int)`
- `set_description(description: String)`
- `set_target_reference(reference: PandoraReference)`
- `set_target_quantity(quantity: int)`
- 💎 `set_optional(optional: bool)` **(Premium only)**
- `set_hidden(hidden: bool)`
- 💎 `set_sequential(sequential: bool)` **(Premium only)**
- 💎 `set_order_index(index: int)` **(Premium only)**
- `set_custom_script(script: String)`

---

### Serialization

###### `load_data(data: Dictionary) -> void`

Loads objective data from a dictionary.

**Parameters:**
- `data`: Dictionary containing serialized objective data

---

###### `save_data(fields_settings: Array[Dictionary]) -> Dictionary`

Serializes objective data to a dictionary.

**Parameters:**
- `fields_settings`: Field configuration array

**Returns:** Dictionary with objective data

---

## Usage Example

### Example: Creating Different Objective Types

```gdscript
extends Node

enum ObjectiveType {
    KILL,
    COLLECT,
    TALK,
    DISCOVER,
    DELIVER,
    ESCORT
}

func create_kill_objective() -> PPQuestObjective:
    var slime_ref = PandoraReference.new("SLIME", PandoraReference.Type.ENTITY)

    return PPQuestObjective.new(
        "KILL_SLIMES",
        ObjectiveType.KILL,
        "Defeat 5 slimes in the forest",
        slime_ref,
        5,
        false
    )

func create_collection_objective() -> PPQuestObjective:
    var potion_ref = PandoraReference.new("HEALTH_POTION", PandoraReference.Type.ENTITY)

    return PPQuestObjective.new(
        "COLLECT_POTIONS",
        ObjectiveType.COLLECT,
        "Gather 3 health potions",
        potion_ref,
        3,
        false
    )

func create_talk_objective() -> PPQuestObjective:
    var elder_ref = PandoraReference.new("VILLAGE_ELDER", PandoraReference.Type.ENTITY)

    return PPQuestObjective.new(
        "TALK_TO_ELDER",
        ObjectiveType.TALK,
        "Speak with the village elder",
        elder_ref,
        1,
        false
    )

func create_hidden_objective() -> PPQuestObjective:
    var secret_ref = PandoraReference.new("SECRET_ROOM", PandoraReference.Type.ENTITY)

    return PPQuestObjective.new(
        "FIND_SECRET",
        ObjectiveType.DISCOVER,
        "Discover the secret room",
        secret_ref,
        1,
        true  # Hidden from player
    )
```

---

## Best Practices

### ✅ Write Clear, Actionable Descriptions

```gdscript
# ✅ Good: Specific and actionable
var obj1 = PPQuestObjective.new(
    "KILL_BANDITS",
    ObjectiveType.KILL,
    "Defeat 8 bandits at the crossroads",
    bandit_ref,
    8
)

# ❌ Bad: Vague
var obj2 = PPQuestObjective.new(
    "DO_THING",
    ObjectiveType.KILL,
    "Do the thing",
    bandit_ref,
    8
)
```

---

### ✅ Use Hidden Objectives for Secrets

```gdscript
# ✅ Good: Secret discovery
var secret = PPQuestObjective.new(
    "SECRET_PATH",
    ObjectiveType.DISCOVER,
    "Find the hidden path",
    path_ref,
    1,
    true  # Hidden - creates surprise
)

# ✅ Good: Normal objective
var normal = PPQuestObjective.new(
    "MAIN_ROAD",
    ObjectiveType.DISCOVER,
    "Follow the main road (0/1)",
    road_ref,
    1,
    false  # Visible progress
)
```

---

### ✅ Set Appropriate Target Quantities

```gdscript
# ✅ Good: Reasonable quantities
var easy = PPQuestObjective.new("RATS", 0, "Kill 5 rats", rat_ref, 5)
var medium = PPQuestObjective.new("HERBS", 1, "Gather 10 herbs", herb_ref, 10)
var hard = PPQuestObjective.new("BOSSES", 0, "Defeat 3 champions", boss_ref, 3)

# ❌ Bad: Excessive grinding
var tedious = PPQuestObjective.new("GRIND", 0, "Kill 1000 slimes", slime_ref, 1000)
```

---

## Common Patterns

### Pattern 1: Multi-Stage Objectives

```gdscript
# Create sequential objectives for a quest
var objectives = [
    PPQuestObjective.new(
        "STAGE_1",
        ObjectiveType.TALK,
        "Speak with the blacksmith",
        blacksmith_ref,
        1
    ),
    PPQuestObjective.new(
        "STAGE_2",
        ObjectiveType.COLLECT,
        "Gather 5 iron ore",
        ore_ref,
        5
    ),
    PPQuestObjective.new(
        "STAGE_3",
        ObjectiveType.DELIVER,
        "Return to the blacksmith",
        blacksmith_ref,
        1
    )
]

for obj in objectives:
    quest.add_objective(obj)
```

---

### Pattern 2: Optional vs Required Objectives

```gdscript
# Main objective (required)
var main_obj = PPQuestObjective.new(
    "MAIN",
    ObjectiveType.KILL,
    "Defeat the bandit leader",
    leader_ref,
    1,
    false
)

# Bonus objectives (can mark as hidden or separate)
var bonus_obj = PPQuestObjective.new(
    "BONUS",
    ObjectiveType.KILL,
    "Defeat all bandits (Optional)",
    bandit_ref,
    10,
    false
)
```

---

### Pattern 3: Location-Based Objectives

```gdscript
# Discovery objective without a specific entity
var explore_obj = PPQuestObjective.new(
    "EXPLORE_CAVE",
    ObjectiveType.DISCOVER,
    "Explore the dark cave",
    cave_location_ref,
    1,
    false
)

# Track progress when player enters the area
func _on_area_entered(area):
    if area.name == "DarkCave":
        runtime_objective.add_progress(1)
```

---

## Notes

### Objective Types

Objective types are game-defined. Common patterns include:
- **KILL**: Defeat enemies
- **COLLECT**: Gather items
- **TALK**: Speak with NPCs
- **DISCOVER**: Find locations
- **DELIVER**: Bring items to NPCs
- **ESCORT**: Protect/guide NPCs

Define your own enum to match your game's needs.

### Target Reference

- Can be `null` for objectives that don't target specific entities
- Must be a valid `PandoraReference` pointing to an entity
- Used by the runtime system to match player actions with objectives

### Custom Scripts

The `custom_script` field allows for complex objective logic beyond simple counting. This is useful for:
- Conditional objectives
- Time-based challenges
- Complex triggers

---

## See Also

- [PPQuest](../api/quest.md) - Quest container
- [PPRuntimeQuest](../api/runtime-quest.md) - Runtime quest tracking
- [Quest System](../core-systems/quest-system.md) - Complete system overview

---

*API Reference generated from source code*
