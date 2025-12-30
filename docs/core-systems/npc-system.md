# NPC System

Complete guide to the Pandora+ NPC System - dynamic NPC management with quest giving, combat, dialogue, and runtime state tracking.

---

## Overview

The Pandora+ NPC System provides comprehensive NPC management for creating interactive game characters. NPCs can give quests, engage in combat, have dialogues, track health, and maintain state across the game session.

**Core Components:**
- **PPNPC** - NPC data model
- **PPRuntimeNPC** - Active NPC instance with state
- **PPNPCEntity** - Pandora entity wrapper for NPCs
- **PPNPCUtils** - Utility functions for NPC operations

---

## Quick Start

### Basic NPC Setup

```gdscript
# Create NPC data
var npc = PPNPC.new()
npc.set_npc_name("Village Elder")
npc.set_faction("Village")
npc.set_is_hostile(false)
npc.set_health(100.0)

# Create NPC entity
var npc_entity = PPNPCEntity.new()
npc_entity.set_entity_id("npc_village_elder")
npc_entity.set_npc_data(npc)

# Spawn runtime NPC
var runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

# NPC is now active in the world
print(runtime_npc.get_npc_name())  # "Village Elder"
print(runtime_npc.is_alive())      # true
```

### NPC with Quest Giving

```gdscript
# Create quest entity
var quest_entity = Pandora.get_entity("quest_village_help") as PPQuestEntity

# Add quest to NPC
var quest_ref = PandoraReference.new("quest_village_help", PandoraReference.Type.ENTITY)
npc.add_quest_giver_for(quest_ref)

# Get available quests from NPC
var completed_ids = PPQuestManager.get_completed_quest_ids()
var available_quests = runtime_npc.get_available_quests(completed_ids)

if not available_quests.is_empty():
    show_quest_dialogue(available_quests)
```

---

## Architecture

### Component Relationships

```
PPRuntimeNPC (Runtime Instance)
├── NPC Data: PPNPC
├── Current Location: PandoraReference
├── Health: current_health, max_health
├── Alive Status: bool
└── Quest Givers: Array[PandoraReference]

PPNPC (Data Model)
├── Basic Info: name, faction
├── Combat: health, is_hostile
├── Quests: quest_giver_for[]
└── Dialogue: dialogue_tree_ref

PPNPCUtils (Autoload)
└── NPC operations (spawn, combat, quests)
```

---

## NPC Data Model

### Basic NPC Properties

```gdscript
var npc = PPNPC.new()

# Identity
npc.set_npc_name("Blacksmith")
npc.set_faction("Town Guard")

# Combat
npc.set_health(150.0)
npc.set_is_hostile(false)  # Friendly NPC

# Location
var town_ref = PandoraReference.new("town_square", PandoraReference.Type.ENTITY)
npc.set_current_location(town_ref)

# Dialogue (if using dialogue system)
var dialogue_ref = PandoraReference.new("blacksmith_dialogue", PandoraReference.Type.ENTITY)
npc.set_dialogue_tree(dialogue_ref)
```

### Quest Giver Configuration

```gdscript
# NPC can give multiple quests
var quest1_ref = PandoraReference.new("quest_forge_sword", PandoraReference.Type.ENTITY)
var quest2_ref = PandoraReference.new("quest_find_ore", PandoraReference.Type.ENTITY)

npc.add_quest_giver_for(quest1_ref)
npc.add_quest_giver_for(quest2_ref)

# Get all quests this NPC can give
var quests = npc.get_quest_giver_for()
print("NPC can give %d quests" % quests.size())
```

---

## Runtime NPC

### Spawning NPCs

```gdscript
# Spawn from entity
var npc_entity = Pandora.get_entity("npc_guard") as PPNPCEntity
var runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

if runtime_npc:
    print("Spawned: ", runtime_npc.get_npc_name())
    add_npc_to_scene(runtime_npc)
```

### NPC State

```gdscript
# Health management
print("Health: %d/%d" % [
    runtime_npc.get_current_health(),
    runtime_npc.get_max_health()
])

# Check alive status
if runtime_npc.is_alive():
    print("NPC is alive")

# Check if hostile
if runtime_npc.npc_data.get("is_hostile", false):
    print("Enemy NPC!")

# Get faction
var faction = runtime_npc.npc_data.get("faction", "None")
print("Faction: ", faction)
```

### Quest Giver Functionality

```gdscript
# Check if NPC gives quests
if runtime_npc.is_quest_giver():
    var completed = PPQuestManager.get_completed_quest_ids()
    var quests = runtime_npc.get_available_quests(completed)

    for quest_entity in quests:
        var quest = quest_entity.get_quest_data()
        print("Available quest: ", quest.get_quest_name())
```

---

## NPC Combat

### Dealing Damage

```gdscript
# Apply damage to NPC
PPNPCUtils.damage_npc(runtime_npc, 25.0, "player_sword")

# NPC takes damage
# If health reaches 0, NPC dies automatically
```

### Healing NPCs

```gdscript
# Heal NPC
PPNPCUtils.heal_npc(runtime_npc, 50.0)

# Health capped at max_health
```

### Death and Revival

```gdscript
# Kill NPC instantly
PPNPCUtils.kill_npc(runtime_npc)

# Check if dead
if not runtime_npc.is_alive():
    print("NPC is dead")
    play_death_animation()

# Revive NPC
PPNPCUtils.revive_npc(runtime_npc, 1.0)  # 100% health

# Revive with partial health
PPNPCUtils.revive_npc(runtime_npc, 0.5)  # 50% health
```

### Combat Interaction Rules

```gdscript
# Can engage in combat? (only hostile NPCs)
if PPNPCUtils.can_engage_combat(runtime_npc):
    start_combat(runtime_npc)

# Can interact? (only friendly, alive NPCs)
if PPNPCUtils.can_interact_with_npc(runtime_npc):
    show_dialogue(runtime_npc)
```

---

## NPC Filtering & Sorting

### Filtering NPCs

```gdscript
var all_npcs: Array[PPRuntimeNPC] = get_all_spawned_npcs()

# Filter by faction
var guards = PPNPCUtils.filter_by_faction(all_npcs, "Town Guard")

# Get alive NPCs only
var alive = PPNPCUtils.get_alive_npcs(all_npcs)

# Get dead NPCs
var dead = PPNPCUtils.get_dead_npcs(all_npcs)

# Get hostile NPCs
var enemies = PPNPCUtils.get_hostile_npcs(all_npcs)

# Get quest givers
var quest_givers = PPNPCUtils.get_quest_givers(all_npcs)
```

### Sorting NPCs

```gdscript
# Sort by name (alphabetical)
var sorted = PPNPCUtils.sort_npcs(all_npcs, "name")

# Sort by health (highest first)
var sorted = PPNPCUtils.sort_npcs(all_npcs, "health")

# Sort by faction
var sorted = PPNPCUtils.sort_npcs(all_npcs, "faction")
```

### Location-Based Filtering

```gdscript
# Get all NPCs at a specific location
var town_ref = PandoraReference.new("town_square", PandoraReference.Type.ENTITY)
var npcs_in_town = PPNPCUtils.get_npcs_at_location(all_npcs, town_ref)

print("%d NPCs in town square" % npcs_in_town.size())
```

---

## NPC Quest Integration

### Getting Quests from NPCs

```gdscript
# Get available quests from NPC
var completed_ids = PPQuestManager.get_completed_quest_ids()
var quests = PPNPCUtils.get_available_quests_from_npc(runtime_npc, completed_ids)

for quest_entity in quests:
    var quest = quest_entity.get_quest_data()
    print("- ", quest.get_quest_name())
```

### Checking Quest Availability

```gdscript
# Check if NPC has quests for player
if PPNPCUtils.has_available_quests(runtime_npc, completed_ids):
    show_quest_indicator_above_npc()
```

### Tracking NPC Interactions for Quests

```gdscript
# When player talks to NPC, track for active quests
func on_npc_interacted(npc_entity: PPNPCEntity):
    var active_quests = PPQuestManager.get_active_quests()
    PPNPCUtils.track_npc_interaction(active_quests, npc_entity)

    # Any quest with "Talk to NPC" objective gets updated
```

### Validating Quest Givers

```gdscript
# Check if NPC can give a specific quest
var quest_entity = Pandora.get_entity("quest_id") as PPQuestEntity
var npc_entity = Pandora.get_entity("npc_id") as PPNPCEntity

if PPNPCUtils.validate_quest_giver(quest_entity, npc_entity):
    print("NPC can give this quest")
```

---

## NPC Statistics

### Calculate NPC Stats

```gdscript
var all_npcs: Array[PPRuntimeNPC] = get_all_spawned_npcs()
var stats = PPNPCUtils.calculate_npc_stats(all_npcs)

print("Total NPCs: ", stats["total_npcs"])
print("Alive: ", stats["alive_count"])
print("Dead: ", stats["dead_count"])
print("Hostile: ", stats["hostile_count"])
print("Quest Givers: ", stats["quest_giver_count"])

# Faction distribution
for faction in stats["faction_distribution"]:
    print("  %s: %d" % [faction, stats["faction_distribution"][faction]])
```

### Get Most Common Faction

```gdscript
var dominant_faction = PPNPCUtils.get_most_common_faction(all_npcs)
print("Most common faction: ", dominant_faction)
```

---

## NPC Signals

### Combat Signals

```gdscript
# NPC death
PPNPCUtils.npc_died.connect(_on_npc_died)

func _on_npc_died(npc: PPRuntimeNPC):
    print(npc.get_npc_name(), " has died!")
    drop_loot(npc)
    update_quest_kill_count(npc)

# NPC revival
PPNPCUtils.npc_revived.connect(_on_npc_revived)

func _on_npc_revived(npc: PPRuntimeNPC):
    print(npc.get_npc_name(), " revived!")
    play_revive_effect(npc)
```

### Quest Signals

```gdscript
# NPC has quests available
PPNPCUtils.npc_has_quest_available.connect(_on_quest_available)

func _on_quest_available(npc: PPRuntimeNPC, quest_count: int):
    print(npc.get_npc_name(), " has ", quest_count, " quests")
    show_quest_marker(npc)
```

---

## Common Patterns

### Pattern 1: Interactive NPC

```gdscript
class_name InteractableNPC
extends CharacterBody3D

@export var npc_entity_id: String

var runtime_npc: PPRuntimeNPC

func _ready():
    # Spawn runtime NPC
    var npc_entity = Pandora.get_entity(npc_entity_id) as PPNPCEntity
    runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

    # Connect signals
    PPNPCUtils.npc_died.connect(_on_death)

func on_player_interact():
    if not PPNPCUtils.can_interact_with_npc(runtime_npc):
        print("Cannot interact with this NPC")
        return

    # Check for quests
    var completed = PPQuestManager.get_completed_quest_ids()
    var quests = runtime_npc.get_available_quests(completed)

    if not quests.is_empty():
        show_quest_ui(quests)
    elif runtime_npc.npc_data.get("dialogue_tree"):
        show_dialogue_ui()
    else:
        show_generic_greeting()

func _on_death(npc: PPRuntimeNPC):
    if npc == runtime_npc:
        play_death_animation()
        queue_free()
```

### Pattern 2: Enemy NPC

```gdscript
class_name EnemyNPC
extends CharacterBody3D

var runtime_npc: PPRuntimeNPC
var target: Node3D = null

func _ready():
    var npc_entity = Pandora.get_entity(npc_entity_id) as PPNPCEntity
    runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

    # Ensure NPC is hostile
    runtime_npc.npc_data["is_hostile"] = true

func _physics_process(delta):
    if not runtime_npc.is_alive():
        return

    if PPNPCUtils.can_engage_combat(runtime_npc):
        if target:
            attack_target(target)

func take_damage(amount: float, source: String):
    PPNPCUtils.damage_npc(runtime_npc, amount, source)

    if not runtime_npc.is_alive():
        on_death()

func on_death():
    # Track for quests
    var enemy_id = runtime_npc.npc_data.get("entity_id", "")
    for quest in PPQuestManager.get_active_quests():
        PPQuestUtils.track_enemy_killed(quest, enemy_id)

    # Drop loot
    spawn_loot()

    # Cleanup
    queue_free()
```

### Pattern 3: NPC Quest Indicator

```gdscript
class_name NPCQuestIndicator
extends Node3D

@export var npc: InteractableNPC
@onready var indicator = $QuestMarker

func _ready():
    # Hide by default
    indicator.visible = false

    # Update when quests change
    PPQuestManager.quest_completed.connect(_update_indicator)
    _update_indicator()

func _update_indicator(_quest_id: String = ""):
    if not npc or not npc.runtime_npc:
        return

    var completed = PPQuestManager.get_completed_quest_ids()
    var has_quests = PPNPCUtils.has_available_quests(
        npc.runtime_npc,
        completed
    )

    indicator.visible = has_quests

    # Different colors for different quest states
    if has_quests:
        indicator.modulate = Color.YELLOW  # Has new quest
```

### Pattern 4: NPC Manager

```gdscript
class_name NPCManager
extends Node

var spawned_npcs: Array[PPRuntimeNPC] = []

func spawn_npc_at_location(npc_entity_id: String, location: Vector3) -> PPRuntimeNPC:
    var npc_entity = Pandora.get_entity(npc_entity_id) as PPNPCEntity
    var runtime_npc = PPNPCUtils.spawn_npc(npc_entity)

    if runtime_npc:
        spawned_npcs.append(runtime_npc)

        # Create 3D representation
        var npc_scene = create_npc_scene(runtime_npc)
        npc_scene.position = location
        add_child(npc_scene)

    return runtime_npc

func get_npcs_in_radius(center: Vector3, radius: float) -> Array[PPRuntimeNPC]:
    var nearby: Array[PPRuntimeNPC] = []

    for npc in spawned_npcs:
        var npc_node = get_npc_node(npc)
        if npc_node and center.distance_to(npc_node.position) <= radius:
            nearby.append(npc)

    return nearby

func cleanup_dead_npcs():
    var dead = PPNPCUtils.get_dead_npcs(spawned_npcs)

    for npc in dead:
        var npc_node = get_npc_node(npc)
        if npc_node:
            npc_node.queue_free()

        spawned_npcs.erase(npc)
```

---

## Best Practices

### ✅ Use Faction System

```gdscript
# ✅ Good: organize NPCs by faction
const Factions = {
    TOWN_GUARD = "Town Guard",
    BANDITS = "Bandits",
    NEUTRAL = "Neutral"
}

npc.set_faction(Factions.TOWN_GUARD)

# ❌ Bad: no faction organization
npc.set_faction("")
```

### ✅ Handle Dead NPCs Gracefully

```gdscript
# ✅ Good: check alive status
if runtime_npc.is_alive():
    show_dialogue(runtime_npc)
else:
    print("NPC is dead")

# ❌ Bad: assume NPC is alive
show_dialogue(runtime_npc)  # May error if dead
```

### ✅ Connect to Signals

```gdscript
# ✅ Good: reactive to NPC events
PPNPCUtils.npc_died.connect(handle_npc_death)

# ❌ Bad: poll for changes
func _process(_delta):
    if npc_died_this_frame():
        handle_npc_death()
```

---

## Troubleshooting

### NPC Not Giving Quests

**Causes:**
- NPC not configured as quest giver
- Quest already completed
- Quest prerequisites not met

**Solution:**
```gdscript
# Check if NPC is quest giver
if not runtime_npc.is_quest_giver():
    print("NPC is not a quest giver")

# Check available quests
var quests = runtime_npc.get_available_quests(completed_ids)
if quests.is_empty():
    print("No available quests (completed or prerequisites not met)")
```

### NPC Won't Take Damage

**Cause:** NPC already dead

**Solution:**
```gdscript
if runtime_npc.is_alive():
    PPNPCUtils.damage_npc(runtime_npc, damage)
else:
    print("NPC is already dead")
```

### Can't Interact with NPC

**Cause:** NPC is hostile or dead

**Solution:**
```gdscript
if not PPNPCUtils.can_interact_with_npc(runtime_npc):
    if not runtime_npc.is_alive():
        print("NPC is dead")
    elif runtime_npc.npc_data.get("is_hostile"):
        print("NPC is hostile - combat only")
```

---

## Debug Utilities

```gdscript
# Print single NPC info
PPNPCUtils.debug_print_npc(runtime_npc)
# Output:
# === NPC Debug Info ===
# Name: Village Elder
# ID: npc_village_elder
# Faction: Village
# Alive: true
# Health: 100/100
# Hostile: false
# Quest Giver: true
# =====================

# Print all NPCs
var all_npcs = get_all_spawned_npcs()
PPNPCUtils.debug_print_all_npcs(all_npcs)
# Output:
# === All NPCs (5) ===
# - Village Elder [Village] HP:100
# - Guard Captain [Town Guard] HP:150
# - Bandit [Bandits] HP:75
# ...
```

---

## See Also

- [PPNPCUtils](../utilities/npc-utils.md) - NPC utility functions
- [PPRuntimeNPC](../api/runtime-npc.md) - Runtime NPC API
- [Quest System](quest-system.md) - Quest integration
- [Player Data](player-data.md) - Save/load integration

---

*Complete System Guide for Pandora+ v1.0.0*
