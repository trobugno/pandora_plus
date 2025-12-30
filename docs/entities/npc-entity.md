# PPNPCEntity

**Extends:** `PandoraEntity`

NPC entity wrapper that provides type-safe access to NPC data including stats, faction, and quest giver functionality.

---

## Description

`PPNPCEntity` is a specialized entity class that extends Pandora's base `PandoraEntity` to provide convenient access to NPC-related data. It wraps NPC properties and exposes methods to access information without manually retrieving properties.

This class serves as the bridge between Pandora's entity system and the NPC runtime system, allowing you to define NPCs in the Pandora editor and instantiate them as `PPRuntimeNPC` instances.

---

## Properties

PPNPCEntity inherits all properties from `PandoraEntity` and typically contains:
- `name` (String): NPC display name
- `description` (String): NPC description
- `texture` (Texture): NPC portrait/sprite
- `base_stats` (PPStats): Combat stats
- `faction` (String): Faction identifier
- `is_hostile` (bool): Hostility flag
- `spawn_location` (Reference): Spawn point reference
- `quest_giver_for` (Array): Quest references this NPC can give

---

## Methods

### Basic Info

###### `get_npc_name() -> String`

Returns the NPC's display name.

**Example:**
```gdscript
var npc_entity = Pandora.get_entity("VILLAGE_GUARD") as PPNPCEntity
var name = npc_entity.get_npc_name()
print("NPC: %s" % name)
```

---

###### `get_description() -> String`

Returns the NPC's description.

**Example:**
```gdscript
var description = npc_entity.get_description()
print("Description: %s" % description)
```

---

###### `get_texture() -> Texture`

Returns the NPC's texture/portrait.

**Example:**
```gdscript
var portrait = npc_entity.get_texture()
$Portrait.texture = portrait
```

---

### Combat Stats

###### `get_base_stats() -> PPStats`

Returns the NPC's base combat stats.

**Example:**
```gdscript
var base_stats = npc_entity.get_base_stats()

if base_stats:
    var health = base_stats.get_stat_value("health")
    var attack = base_stats.get_stat_value("attack")
    print("HP: %d, ATK: %d" % [health, attack])
```

---

### Faction & Hostility

###### `get_faction() -> String`

Returns the NPC's faction name.

**Example:**
```gdscript
var faction = npc_entity.get_faction()

match faction:
    "FRIENDLY":
        display_friendly_icon()
    "ENEMY":
        display_enemy_icon()
    "NEUTRAL":
        display_neutral_icon()
```

---

###### `is_hostile() -> bool`

Returns `true` if NPC is hostile by default.

**Example:**
```gdscript
if npc_entity.is_hostile():
    enter_combat_mode()
else:
    show_dialog_option()
```

---

### Location

###### `get_spawn_location() -> PandoraReference`

Returns the spawn location reference.

**Example:**
```gdscript
var spawn_ref = npc_entity.get_spawn_location()

if spawn_ref:
    var spawn_location = spawn_ref.get_entity()
    print("Spawns at: %s" % spawn_location.get_string("name"))
```

---

### Quest Giver

###### `get_quest_giver_for() -> Array`

Returns array of quest references this NPC can give.

**Example:**
```gdscript
var quest_refs = npc_entity.get_quest_giver_for()

print("This NPC has %d quests" % quest_refs.size())

for quest_ref in quest_refs:
    var quest_entity = quest_ref.get_entity() as PPQuestEntity
    if quest_entity:
        print("  - %s" % quest_entity.get_quest_name())
```

---

## Usage Example

### Example: NPC Spawner System

```gdscript
extends Node2D

@export var npc_entity_id: String = "FOREST_BANDIT"
@export var spawn_count: int = 5

var npc_scene = preload("res://scenes/npc.tscn")
var spawned_npcs: Array[Node] = []

func _ready():
    spawn_npcs()

func spawn_npcs() -> void:
    var npc_entity = Pandora.get_entity(npc_entity_id) as PPNPCEntity

    if not npc_entity:
        push_error("NPC entity not found: %s" % npc_entity_id)
        return

    for i in spawn_count:
        var npc_instance = spawn_npc(npc_entity)
        spawned_npcs.append(npc_instance)

func spawn_npc(npc_entity: PPNPCEntity) -> Node:
    # Create runtime NPC
    var runtime_npc = PPRuntimeNPC.new(npc_entity)

    # Instantiate scene
    var npc_instance = npc_scene.instantiate()
    npc_instance.runtime_npc = runtime_npc

    # Set visual properties
    npc_instance.name = npc_entity.get_npc_name()
    npc_instance.get_node("Sprite").texture = npc_entity.get_texture()

    # Set behavior based on hostility
    if npc_entity.is_hostile():
        npc_instance.add_to_group("enemies")
        npc_instance.set_ai_mode("aggressive")
    else:
        npc_instance.add_to_group("friendly")
        npc_instance.set_ai_mode("passive")

    # Add to scene
    add_child(npc_instance)

    # Position at spawn point
    position_at_spawn(npc_instance, npc_entity)

    return npc_instance

func position_at_spawn(npc_instance: Node, npc_entity: PPNPCEntity) -> void:
    var spawn_ref = npc_entity.get_spawn_location()

    if spawn_ref:
        var spawn_location = spawn_ref.get_entity()
        var spawn_pos = spawn_location.get_vector2("position")
        npc_instance.global_position = spawn_pos
    else:
        # Random position in area
        npc_instance.global_position = global_position + Vector2(
            randf_range(-100, 100),
            randf_range(-100, 100)
        )
```

---

### Example: Quest Giver NPC

```gdscript
extends CharacterBody2D

var npc_entity: PPNPCEntity
var runtime_npc: PPRuntimeNPC
var player_in_range: bool = false

@export var npc_entity_id: String = "VILLAGE_ELDER"

func _ready():
    # Load NPC entity
    npc_entity = Pandora.get_entity(npc_entity_id) as PPNPCEntity

    if not npc_entity:
        push_error("NPC entity not found")
        return

    # Create runtime NPC
    runtime_npc = PPRuntimeNPC.new(npc_entity)

    # Setup visuals
    $Sprite.texture = npc_entity.get_texture()
    $NameLabel.text = npc_entity.get_npc_name()

    # Setup interaction area
    $InteractionArea.body_entered.connect(_on_player_entered)
    $InteractionArea.body_exited.connect(_on_player_exited)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact") and player_in_range:
        interact_with_player()

func _on_player_entered(body: Node) -> void:
    if body.is_in_group("player"):
        player_in_range = true
        show_interaction_prompt()

func _on_player_exited(body: Node) -> void:
    if body.is_in_group("player"):
        player_in_range = false
        hide_interaction_prompt()

func interact_with_player() -> void:
    # Check if NPC is quest giver
    if runtime_npc.is_quest_giver():
        show_quest_dialog()
    else:
        show_generic_dialog()

func show_quest_dialog() -> void:
    var quest_refs = npc_entity.get_quest_giver_for()
    var player_completed = PlayerData.get_completed_quest_ids()

    var available_quests = runtime_npc.get_available_quests(player_completed)

    if available_quests.is_empty():
        show_dialog("I have no quests for you right now, traveler.")
        return

    # Show quest selection UI
    var dialog = QuestDialogUI.new()
    dialog.npc_name = npc_entity.get_npc_name()
    dialog.npc_portrait = npc_entity.get_texture()

    for quest_entity in available_quests:
        dialog.add_quest_option(quest_entity)

    dialog.quest_accepted.connect(_on_quest_accepted)
    add_child(dialog)

func _on_quest_accepted(quest_entity: PPQuestEntity) -> void:
    print("%s accepted quest: %s" % [
        PlayerData.player_name,
        quest_entity.get_quest_name()
    ])

    QuestManager.start_quest(quest_entity)
```

---

### Example: Faction-Based Combat

```gdscript
class FactionManager:
    enum Faction { PLAYER, FRIENDLY, NEUTRAL, HOSTILE }

    var faction_relations = {
        Faction.PLAYER: {
            Faction.FRIENDLY: "FRIENDLY",
            Faction.NEUTRAL: "NEUTRAL",
            Faction.HOSTILE: "HOSTILE"
        }
    }

    func get_npc_faction(npc_entity: PPNPCEntity) -> int:
        var faction_name = npc_entity.get_faction()

        match faction_name:
            "FRIENDLY":
                return Faction.FRIENDLY
            "NEUTRAL":
                return Faction.NEUTRAL
            "HOSTILE":
                return Faction.HOSTILE
            _:
                # Default based on hostility
                return Faction.HOSTILE if npc_entity.is_hostile() else Faction.NEUTRAL

    func should_attack_player(npc_entity: PPNPCEntity) -> bool:
        # Check explicit hostility
        if npc_entity.is_hostile():
            return true

        # Check faction relations
        var faction = get_npc_faction(npc_entity)
        return faction == Faction.HOSTILE

    func can_talk_to_npc(npc_entity: PPNPCEntity) -> bool:
        var faction = get_npc_faction(npc_entity)
        return faction in [Faction.FRIENDLY, Faction.NEUTRAL]
```

---

## Best Practices

### ✅ Cache NPC Entities

```gdscript
# ✅ Good: Cache frequently used NPCs
var npc_cache: Dictionary = {}

func get_npc(npc_id: String) -> PPNPCEntity:
    if not npc_cache.has(npc_id):
        npc_cache[npc_id] = Pandora.get_entity(npc_id) as PPNPCEntity
    return npc_cache[npc_id]

# ❌ Bad: Fetch every time
func spawn_npc(npc_id: String):
    var npc = Pandora.get_entity(npc_id) as PPNPCEntity
    # ...
```

---

### ✅ Check Hostility Before Interaction

```gdscript
# ✅ Good: Check hostility
if npc_entity.is_hostile():
    enter_combat(npc_entity)
else:
    attempt_dialog(npc_entity)

# ❌ Bad: Assume all NPCs are friendly
show_dialog_ui(npc_entity)  # Hostile NPC shouldn't talk
```

---

### ✅ Separate Entity from Runtime Instance

```gdscript
# ✅ Good: Clear separation
var npc_entity = Pandora.get_entity("GUARD") as PPNPCEntity  # Static data
var runtime_npc = PPRuntimeNPC.new(npc_entity)  # Runtime state

# Use entity for: name, texture, base stats
# Use runtime for: current health, location, combat

# ❌ Bad: Confuse the two
var npc = Pandora.get_entity("GUARD")
npc.take_damage(50)  # Wrong! Entities are static
```

---

## Common Patterns

### Pattern 1: NPC Pool System

```gdscript
class NPCPool:
    var npc_definitions: Dictionary = {}  # id -> PPNPCEntity
    var active_npcs: Array[PPRuntimeNPC] = []

    func register_npc_type(npc_id: String) -> void:
        var npc_entity = Pandora.get_entity(npc_id) as PPNPCEntity
        if npc_entity:
            npc_definitions[npc_id] = npc_entity

    func spawn_npc(npc_id: String) -> PPRuntimeNPC:
        var npc_entity = npc_definitions.get(npc_id)
        if not npc_entity:
            return null

        var runtime_npc = PPRuntimeNPC.new(npc_entity)
        active_npcs.append(runtime_npc)

        return runtime_npc

    func despawn_npc(runtime_npc: PPRuntimeNPC) -> void:
        active_npcs.erase(runtime_npc)
```

---

### Pattern 2: Faction System

```gdscript
var faction_definitions = {
    "KINGDOM": {
        "allies": ["CHURCH", "MERCHANTS"],
        "enemies": ["BANDITS", "UNDEAD"]
    },
    "BANDITS": {
        "allies": [],
        "enemies": ["KINGDOM", "CHURCH", "MERCHANTS"]
    }
}

func are_factions_hostile(faction_a: String, faction_b: String) -> bool:
    var faction_data = faction_definitions.get(faction_a, {})
    var enemies = faction_data.get("enemies", [])
    return faction_b in enemies

func should_npcs_fight(npc_a: PPNPCEntity, npc_b: PPNPCEntity) -> bool:
    return are_factions_hostile(npc_a.get_faction(), npc_b.get_faction())
```

---

### Pattern 3: Dynamic Quest Giver Assignment

```gdscript
# Assign quests to NPCs at runtime based on player level
func update_quest_givers_for_player_level(player_level: int) -> void:
    var all_quests = get_quests_for_level(player_level)

    for quest_entity in all_quests:
        var quest_giver_ref = quest_entity.get_quest_giver()

        if quest_giver_ref:
            var npc_entity = quest_giver_ref.get_entity() as PPNPCEntity

            if npc_entity:
                # Mark this NPC as having this quest available
                mark_npc_has_quest(npc_entity.get_entity_id(), quest_entity.get_quest_id())
```

---

## Notes

### Creating NPCs in Pandora

1. Open Pandora editor
2. Create new entity with category "NPC"
3. Add properties:
   - `name` (String): NPC name
   - `description` (String): Description
   - `texture` (Resource): Portrait/sprite
   - `base_stats` (PPStats property): Combat stats
   - `faction` (String): Faction ID
   - `is_hostile` (Bool): Hostility flag
   - `quest_giver_for` (Array): Quest references
4. Save entity

### Entity vs Runtime

- **PPNPCEntity**: Static NPC definition (immutable)
- **PPRuntimeNPC**: Dynamic NPC instance (health, position, etc.)

Always create a `PPRuntimeNPC` from a `PPNPCEntity` to track runtime state.

### Quest Giver Integration

NPCs can reference quests through the `quest_giver_for` array. Use `PPRuntimeNPC.get_available_quests()` to filter by completed quests.

---

## See Also

- [PPRuntimeNPC](../api/runtime-npc.md) - Runtime NPC instance
- [PPQuestEntity](../entities/quest-entity.md) - Quest entities
- [NPC System](../core-systems/npc-system.md) - Complete system overview
- [PPNPCUtils](../utilities/npc-utils.md) - NPC utility functions

---

*API Reference generated from source code*
