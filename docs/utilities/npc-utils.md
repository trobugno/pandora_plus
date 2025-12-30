# PPNPCUtils

Utility autoload providing comprehensive NPC management functions including lifecycle, combat operations, quest integration, filtering, and analytics.

---

## Overview

`PPNPCUtils` is an autoloaded singleton that provides helper functions for working with NPCs in Pandora+. It handles NPC spawning, combat, quest giving, location tracking, and more.

**Access:** `PPNPCUtils` (globally available)

---

## Signals

### Combat Signals

```gdscript
signal npc_died(npc: PPRuntimeNPC)
signal npc_revived(npc: PPRuntimeNPC)
```

Emitted when NPCs die or are revived.

**Example:**
```gdscript
PPNPCUtils.npc_died.connect(_on_npc_died)

func _on_npc_died(npc: PPRuntimeNPC):
    print("%s has died!" % npc.get_npc_name())
    drop_loot(npc)
```

### Quest Signals

```gdscript
signal npc_has_quest_available(npc: PPRuntimeNPC, quest_count: int)
```

Emitted when checking if NPC has available quests.

**Example:**
```gdscript
PPNPCUtils.npc_has_quest_available.connect(_on_quest_available)

func _on_quest_available(npc: PPRuntimeNPC, count: int):
    print("%s has %d quests" % [npc.get_npc_name(), count])
    show_quest_marker(npc)
```

---

## NPC Lifecycle & Management

### spawn_npc()

Creates a runtime NPC instance from an NPC entity.

```gdscript
func spawn_npc(npc_entity: PPNPCEntity) -> PPRuntimeNPC
```

**Parameters:**
- `npc_entity`: NPC entity to spawn

**Returns:** `PPRuntimeNPC` instance or `null` if entity is invalid

**Example:**
```gdscript
var npc_entity = Pandora.get_entity("npc_village_elder") as PPNPCEntity
var runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

if runtime_npc:
    print("Spawned: ", runtime_npc.get_npc_name())
    add_npc_to_scene(runtime_npc)
```

---

### despawn_npc()

Despawns an NPC (cleanup).

```gdscript
func despawn_npc(runtime_npc: PPRuntimeNPC) -> void
```

**Note:** This is mainly for symmetry with `spawn_npc()`. Actual cleanup logic should be implemented by your game.

**Example:**
```gdscript
PPNPCUtils.despawn_npc(runtime_npc)
remove_npc_from_scene(runtime_npc)
```

---

### get_npcs_at_location()

Finds NPCs at a specific location.

```gdscript
func get_npcs_at_location(npcs: Array, location_ref: PandoraReference) -> Array
```

**Parameters:**
- `npcs`: Array of runtime NPCs
- `location_ref`: Location reference

**Returns:** Array of NPCs at that location

**Example:**
```gdscript
var all_npcs = get_all_spawned_npcs()
var town_ref = PandoraReference.new("town_square", PandoraReference.Type.ENTITY)
var npcs_in_town = PPNPCUtils.get_npcs_at_location(all_npcs, town_ref)

print("%d NPCs in town square" % npcs_in_town.size())
```

---

### find_npc_by_id()

Finds an NPC by entity ID.

```gdscript
func find_npc_by_id(npcs: Array, npc_id: String) -> PPRuntimeNPC
```

**Example:**
```gdscript
var npc = PPNPCUtils.find_npc_by_id(all_npcs, "npc_blacksmith")
if npc:
    print("Found: ", npc.get_npc_name())
```

---

### find_npc_by_name()

Finds an NPC by name.

```gdscript
func find_npc_by_name(npcs: Array, npc_name: String) -> PPRuntimeNPC
```

**Example:**
```gdscript
var elder = PPNPCUtils.find_npc_by_name(all_npcs, "Village Elder")
```

---

## Combat Operations

### damage_npc()

Applies damage to an NPC.

```gdscript
func damage_npc(runtime_npc: PPRuntimeNPC, amount: float, source: String = "unknown") -> void
```

**Parameters:**
- `runtime_npc`: NPC to damage
- `amount`: Damage amount
- `source`: Damage source (for tracking)

**Example:**
```gdscript
# Player attacks NPC with sword
PPNPCUtils.damage_npc(enemy_npc, 25.0, "player_sword")

# Environmental damage
PPNPCUtils.damage_npc(npc, 10.0, "fire_trap")
```

---

### heal_npc()

Heals an NPC.

```gdscript
func heal_npc(runtime_npc: PPRuntimeNPC, amount: float) -> void
```

**Example:**
```gdscript
# Heal NPC by 50 HP
PPNPCUtils.heal_npc(friendly_npc, 50.0)
```

---

### kill_npc()

Kills an NPC immediately.

```gdscript
func kill_npc(runtime_npc: PPRuntimeNPC) -> void
```

**Note:** Emits `npc_died` signal.

**Example:**
```gdscript
# Instant death (scripted event)
PPNPCUtils.kill_npc(doomed_npc)
```

---

### revive_npc()

Revives an NPC with specified health percentage.

```gdscript
func revive_npc(runtime_npc: PPRuntimeNPC, health_percentage: float = 1.0) -> void
```

**Parameters:**
- `runtime_npc`: NPC to revive
- `health_percentage`: Health percentage (0.0 to 1.0)

**Note:** Emits `npc_revived` signal.

**Example:**
```gdscript
# Revive at full health
PPNPCUtils.revive_npc(npc, 1.0)

# Revive at 50% health
PPNPCUtils.revive_npc(npc, 0.5)
```

---

### can_engage_combat()

Checks if NPC can engage in combat (only hostile NPCs).

```gdscript
func can_engage_combat(runtime_npc: PPRuntimeNPC) -> bool
```

**Returns:** `true` if NPC is hostile and alive

**Example:**
```gdscript
if PPNPCUtils.can_engage_combat(npc):
    start_combat_with(npc)
else:
    print("Cannot fight this NPC")
```

---

### can_interact_with_npc()

Checks if player can interact with NPC.

```gdscript
func can_interact_with_npc(runtime_npc: PPRuntimeNPC) -> bool
```

**Returns:** `true` if NPC is friendly and alive

**Example:**
```gdscript
if PPNPCUtils.can_interact_with_npc(npc):
    show_dialogue_ui(npc)
else:
    print("Cannot interact (hostile or dead)")
```

---

## Quest Integration

### get_available_quests_from_npc()

Gets available quests from an NPC.

```gdscript
func get_available_quests_from_npc(
    runtime_npc: PPRuntimeNPC,
    completed_quest_ids: Array
) -> Array
```

**Returns:** Array of available `PPQuestEntity`

**Example:**
```gdscript
var completed = PPQuestManager.get_completed_quest_ids()
var quests = PPNPCUtils.get_available_quests_from_npc(runtime_npc, completed)

for quest_entity in quests:
    var quest = quest_entity.get_quest_data()
    print("- ", quest.get_quest_name())
```

---

### get_quest_givers()

Gets all quest givers from NPC list.

```gdscript
func get_quest_givers(npcs: Array) -> Array
```

**Example:**
```gdscript
var all_npcs = get_spawned_npcs()
var quest_givers = PPNPCUtils.get_quest_givers(all_npcs)

print("Found %d quest givers" % quest_givers.size())
```

---

### has_available_quests()

Checks if NPC has available quests.

```gdscript
func has_available_quests(runtime_npc: PPRuntimeNPC, completed_quest_ids: Array) -> bool
```

**Note:** Emits `npc_has_quest_available` signal if quests are found.

**Example:**
```gdscript
var completed = PPQuestManager.get_completed_quest_ids()
if PPNPCUtils.has_available_quests(npc, completed):
    show_quest_indicator(npc)
```

---

### track_npc_interaction()

Tracks NPC interaction for quest objectives.

```gdscript
func track_npc_interaction(active_quests: Array, npc_entity: PPNPCEntity) -> void
```

**Example:**
```gdscript
func on_npc_dialogue_started(npc: PPNPCEntity):
    var active_quests = PPQuestManager.get_active_quests()
    PPNPCUtils.track_npc_interaction(active_quests, npc)
    # Updates any "Talk to NPC" objectives
```

---

### validate_quest_giver()

Validates that NPC can give a specific quest.

```gdscript
func validate_quest_giver(quest: PPQuestEntity, npc: PPNPCEntity) -> bool
```

**Example:**
```gdscript
if PPNPCUtils.validate_quest_giver(quest_entity, npc_entity):
    print("NPC can give this quest")
```

---

### can_start_quest_at_time()

Checks if quest can be started at current time.

```gdscript
func can_start_quest_at_time(
    quest: PPQuestEntity,
    npc: PPRuntimeNPC,
    current_hour: int
) -> bool
```

**Checks:**
- NPC is quest giver
- NPC is alive
- NPC is not hostile

**Example:**
```gdscript
var current_hour = 14  # 2 PM
if PPNPCUtils.can_start_quest_at_time(quest, npc, current_hour):
    offer_quest(quest)
```

---

## Filtering & Sorting

### filter_by_faction()

Filters NPCs by faction.

```gdscript
func filter_by_faction(npcs: Array, faction: String) -> Array
```

**Example:**
```gdscript
var guards = PPNPCUtils.filter_by_faction(all_npcs, "Town Guard")
var bandits = PPNPCUtils.filter_by_faction(all_npcs, "Bandits")
```

---

### get_alive_npcs()

Gets alive NPCs.

```gdscript
func get_alive_npcs(npcs: Array) -> Array
```

**Example:**
```gdscript
var alive = PPNPCUtils.get_alive_npcs(all_npcs)
print("%d alive NPCs" % alive.size())
```

---

### get_dead_npcs()

Gets dead NPCs.

```gdscript
func get_dead_npcs(npcs: Array) -> Array
```

---

### get_hostile_npcs()

Gets hostile NPCs.

```gdscript
func get_hostile_npcs(npcs: Array) -> Array
```

**Example:**
```gdscript
var enemies = PPNPCUtils.get_hostile_npcs(all_npcs)
for enemy in enemies:
    add_to_combat_list(enemy)
```

---

### sort_npcs()

Sorts NPCs by various criteria.

```gdscript
func sort_npcs(npcs: Array, sort_by: String) -> Array
```

**Sort options:**
- `"name"`: Alphabetical by name
- `"health"`: By current health (highest first)
- `"faction"`: By faction name

**Example:**
```gdscript
var sorted = PPNPCUtils.sort_npcs(all_npcs, "health")
# NPCs with most health first
```

---

## Statistics & Analytics

### calculate_npc_stats()

Calculates NPC statistics.

```gdscript
func calculate_npc_stats(npcs: Array) -> Dictionary
```

**Returns:** Dictionary with keys:
- `total_npcs`: int
- `alive_count`: int
- `dead_count`: int
- `faction_distribution`: Dictionary (faction → count)
- `hostile_count`: int
- `quest_giver_count`: int

**Example:**
```gdscript
var stats = PPNPCUtils.calculate_npc_stats(all_npcs)

print("Total NPCs: %d" % stats["total_npcs"])
print("Alive: %d" % stats["alive_count"])
print("Quest Givers: %d" % stats["quest_giver_count"])

for faction in stats["faction_distribution"]:
    print("  %s: %d" % [faction, stats["faction_distribution"][faction]])
```

---

### get_most_common_faction()

Gets the most common faction.

```gdscript
func get_most_common_faction(npcs: Array) -> String
```

**Example:**
```gdscript
var dominant = PPNPCUtils.get_most_common_faction(all_npcs)
print("Most common faction: ", dominant)
```

---

## Debug Utilities

### debug_print_npc()

Prints NPC debug info.

```gdscript
func debug_print_npc(runtime_npc: PPRuntimeNPC) -> void
```

**Example:**
```gdscript
PPNPCUtils.debug_print_npc(runtime_npc)
```

**Output:**
```
=== NPC Debug Info ===
Name: Village Elder
ID: npc_village_elder
Faction: Village
Alive: true
Health: 100/100
Hostile: false
Quest Giver: true
=====================
```

---

### debug_print_all_npcs()

Prints all NPCs.

```gdscript
func debug_print_all_npcs(npcs: Array) -> void
```

**Example:**
```gdscript
PPNPCUtils.debug_print_all_npcs(all_npcs)
```

**Output:**
```
=== All NPCs (5) ===
- Village Elder [Village] HP:100
- Guard Captain [Town Guard] HP:150
- Bandit [Bandits] HP:75
- Merchant [Neutral] HP:80
- Blacksmith [Village] HP:120
=========================
```

---

## Common Usage Patterns

### Pattern 1: Enemy Combat

```gdscript
class_name Enemy
extends CharacterBody3D

var runtime_npc: PPRuntimeNPC

func _ready():
    var npc_entity = Pandora.get_entity("npc_goblin") as PPNPCEntity
    runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

    # Ensure hostile
    runtime_npc.npc_data["is_hostile"] = true

func take_hit(damage: float):
    PPNPCUtils.damage_npc(runtime_npc, damage, "player")

    if not runtime_npc.is_alive():
        on_death()

func on_death():
    # Track for quests
    var active_quests = PPQuestManager.get_active_quests()
    for quest in active_quests:
        PPQuestUtils.track_enemy_killed(quest, runtime_npc._npc_entity)

    # Drop loot
    spawn_loot()
    queue_free()
```

---

### Pattern 2: Quest Giver NPC

```gdscript
func on_player_interact(npc: PPRuntimeNPC):
    # Can't interact with dead or hostile NPCs
    if not PPNPCUtils.can_interact_with_npc(npc):
        return

    # Check for quests
    var completed = PPQuestManager.get_completed_quest_ids()

    if PPNPCUtils.has_available_quests(npc, completed):
        var quests = PPNPCUtils.get_available_quests_from_npc(npc, completed)
        show_quest_selection_ui(quests)
    else:
        show_generic_dialogue(npc)
```

---

### Pattern 3: Faction-Based AI

```gdscript
func update_npc_relations():
    var player_faction = player.get_faction()
    var all_npcs = get_all_spawned_npcs()

    for npc in all_npcs:
        var npc_faction = npc.npc_data.get("faction", "Neutral")

        if are_factions_hostile(player_faction, npc_faction):
            npc.npc_data["is_hostile"] = true
        else:
            npc.npc_data["is_hostile"] = false
```

---

### Pattern 4: Location-Based Events

```gdscript
func trigger_ambush():
    var all_npcs = get_all_spawned_npcs()
    var forest_ref = PandoraReference.new("dark_forest", PandoraReference.Type.ENTITY)
    var npcs_in_forest = PPNPCUtils.get_npcs_at_location(all_npcs, forest_ref)

    # Make all bandits in forest hostile
    for npc in npcs_in_forest:
        if npc.npc_data.get("faction") == "Bandits":
            npc.npc_data["is_hostile"] = true
            start_combat(npc)
```

---

## See Also

- [NPC System](../core-systems/npc-system.md) - NPC system overview
- [PPRuntimeNPC](../api/runtime-npc.md) - Runtime NPC API
- [PPNPC](../api/npc.md) - NPC data model
- [Quest System](../core-systems/quest-system.md) - Quest integration

---

*API Reference for Pandora+ v1.0.0*
