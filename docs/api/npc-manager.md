# PPNPCManager

**✅ Core & Premium** | **Autoload Singleton**

API reference for the NPC Manager singleton - manages NPC runtime state, lifecycle, and spawning during gameplay.

---

## Description

**PPNPCManager** is an autoload singleton that manages the runtime state of all spawned NPCs in the game world. It handles NPC spawning, despawning, lifecycle events, and integrates with the save/load system.

**Key Responsibilities:**
- Maintain collection of spawned NPCs
- Handle NPC lifecycle (spawn, despawn, death, revival)
- Query NPCs by location or properties
- 💎 **Premium:** Update NPC schedules automatically
- 💎 **Premium:** Manage merchant inventory restocking
- Integrate with SaveManager for persistence

**Access:** Available globally as `PPNPCManager`

---

## Signals

### npc_spawned

```gdscript
signal npc_spawned(runtime_npc: PPRuntimeNPC)
```

Emitted when an NPC is spawned into the game world.

**Parameters:**
- `runtime_npc` (PPRuntimeNPC) - The spawned NPC instance

**Example:**
```gdscript
PPNPCManager.npc_spawned.connect(func(runtime_npc):
    print("NPC spawned: %s" % runtime_npc.get_npc_name())
    create_npc_visual_in_world(runtime_npc)
)
```

---

### npc_despawned

```gdscript
signal npc_despawned(npc_id: String)
```

Emitted when an NPC is despawned from the game world.

**Parameters:**
- `npc_id` (String) - NPC entity identifier

**Example:**
```gdscript
PPNPCManager.npc_despawned.connect(func(npc_id):
    print("NPC despawned: %s" % npc_id)
    remove_npc_visual_from_world(npc_id)
)
```

---

### npc_died

```gdscript
signal npc_died(npc_id: String)
```

Emitted when an NPC dies.

**Parameters:**
- `npc_id` (String) - NPC entity identifier

**Example:**
```gdscript
PPNPCManager.npc_died.connect(func(npc_id):
    print("NPC died: %s" % npc_id)
    play_death_animation(npc_id)
    drop_loot(npc_id)
)
```

---

### npc_revived

```gdscript
signal npc_revived(npc_id: String)
```

Emitted when an NPC is revived.

**Parameters:**
- `npc_id` (String) - NPC entity identifier

**Example:**
```gdscript
PPNPCManager.npc_revived.connect(func(npc_id):
    print("NPC revived: %s" % npc_id)
    play_revival_animation(npc_id)
)
```

---

### npc_location_changed

```gdscript
signal npc_location_changed(npc_id: String, old_location: Variant, new_location: Variant)
```

Emitted when an NPC's location changes.

**Parameters:**
- `npc_id` (String) - NPC entity identifier
- `old_location` (Variant) - Previous location (PandoraReference or String)
- `new_location` (Variant) - New location (PandoraReference or String)

**Example:**
```gdscript
PPNPCManager.npc_location_changed.connect(func(npc_id, old_loc, new_loc):
    print("NPC %s moved from %s to %s" % [npc_id, old_loc, new_loc])
    move_npc_visual(npc_id, new_loc)
)
```

---

### all_npcs_cleared

```gdscript
signal all_npcs_cleared()
```

Emitted when all NPCs are cleared (e.g., starting new game).

**Example:**
```gdscript
PPNPCManager.all_npcs_cleared.connect(func():
    print("All NPCs cleared")
    clear_all_npc_visuals()
)
```

---

### npc_shop_restocked

```gdscript
signal npc_shop_restocked(npc_id: String)
```

**💎 Premium Only** - Emitted when a merchant NPC's shop inventory is restocked.

**Parameters:**
- `npc_id` (String) - NPC entity identifier

**Example:**
```gdscript
# 💎 Premium
PPNPCManager.npc_shop_restocked.connect(func(npc_id):
    print("Shop restocked: %s" % npc_id)
    refresh_merchant_ui(npc_id)
)
```

---

## Methods

### spawn_npc

```gdscript
func spawn_npc(npc_entity: PPNPCEntity, location: Variant = null) -> PPRuntimeNPC
```

Spawns an NPC from an entity into the game world.

**Parameters:**
- `npc_entity` (PPNPCEntity) - NPC entity to spawn
- `location` (Variant, optional) - Override spawn location (PandoraReference or String)

**Returns:** `PPRuntimeNPC` - Created runtime NPC instance

**Notes:**
- If NPC is already spawned, returns existing instance with warning
- Location parameter overrides entity's default spawn location
- Automatically adds NPC to spawned collection and emits signals

**Example:**
```gdscript
# Spawn NPC at default location
var npc_entity = Pandora.get_entity("npc_guard") as PPNPCEntity
var runtime_npc = PPNPCManager.spawn_npc(npc_entity)

# Spawn at specific location
var location_ref = PandoraReference.new("town_square", PandoraReference.Type.ENTITY)
var runtime_npc = PPNPCManager.spawn_npc(npc_entity, location_ref)
```

---

### add_existing_npc

```gdscript
func add_existing_npc(runtime_npc: PPRuntimeNPC) -> void
```

Adds an existing runtime NPC to the manager (used during save/load).

**Parameters:**
- `runtime_npc` (PPRuntimeNPC) - Existing runtime NPC instance

**Notes:**
- Primarily used by save/load system
- Connects NPC signals automatically

**Example:**
```gdscript
# Load NPC from save data
var npc_data = save_file.get("npc_data")
var runtime_npc = PPRuntimeNPC.from_dict(npc_data)
PPNPCManager.add_existing_npc(runtime_npc)
```

---

### despawn_npc

```gdscript
func despawn_npc(npc_entity_id: String) -> bool
```

Despawns an NPC by entity ID.

**Parameters:**
- `npc_entity_id` (String) - NPC entity identifier

**Returns:** `bool` - `true` if NPC was despawned, `false` if not found

**Example:**
```gdscript
# Despawn specific NPC
var despawned = PPNPCManager.despawn_npc("npc_guard_01")

if despawned:
    print("Guard despawned")
```

---

### despawn_npcs_at_location

```gdscript
func despawn_npcs_at_location(location_id: String) -> int
```

Despawns all NPCs at a specific location.

**Parameters:**
- `location_id` (String) - Location identifier

**Returns:** `int` - Number of NPCs despawned

**Example:**
```gdscript
# Clear all NPCs from town
var count = PPNPCManager.despawn_npcs_at_location("town_square")
print("Despawned %d NPCs from town square" % count)
```

---

### get_spawned_npcs

```gdscript
func get_spawned_npcs() -> Array[PPRuntimeNPC]
```

Gets all spawned NPCs.

**Returns:** `Array[PPRuntimeNPC]` - Copy of spawned NPCs array

**Example:**
```gdscript
var all_npcs = PPNPCManager.get_spawned_npcs()

for npc in all_npcs:
    print("NPC: %s" % npc.get_npc_name())
```

---

### find_npc_by_entity_id

```gdscript
func find_npc_by_entity_id(npc_entity_id: String) -> PPRuntimeNPC
```

Finds an NPC by entity ID.

**Parameters:**
- `npc_entity_id` (String) - NPC entity identifier

**Returns:** `PPRuntimeNPC` - NPC instance or `null` if not found

**Example:**
```gdscript
var guard = PPNPCManager.find_npc_by_entity_id("npc_guard_01")

if guard:
    print("Guard health: %d/%d" % [guard.get_current_health(), guard.get_max_health()])
else:
    print("Guard not found")
```

---

### get_npcs_at_location

```gdscript
func get_npcs_at_location(location_id: String) -> Array[PPRuntimeNPC]
```

Gets all NPCs at a specific location.

**Parameters:**
- `location_id` (String) - Location identifier

**Returns:** `Array[PPRuntimeNPC]` - NPCs at the location

**Example:**
```gdscript
var npcs_in_town = PPNPCManager.get_npcs_at_location("town_square")

print("%d NPCs in town square:" % npcs_in_town.size())
for npc in npcs_in_town:
    print("  - %s" % npc.get_npc_name())
```

---

### get_all_quest_givers

```gdscript
func get_all_quest_givers() -> Array[PPRuntimeNPC]
```

Gets all quest giver NPCs.

**Returns:** `Array[PPRuntimeNPC]` - Quest giver NPCs

**Example:**
```gdscript
var quest_givers = PPNPCManager.get_all_quest_givers()

for npc in quest_givers:
    var available_quests = npc.get_available_quests(completed_ids)
    if not available_quests.is_empty():
        show_quest_marker_above(npc)
```

---

### get_all_merchants

```gdscript
func get_all_merchants() -> Array[PPRuntimeNPC]
```

**💎 Premium Only** - Gets all merchant NPCs.

**Returns:** `Array[PPRuntimeNPC]` - Merchant NPCs

**Example:**
```gdscript
# 💎 Premium
var merchants = PPNPCManager.get_all_merchants()

for merchant in merchants:
    print("Merchant: %s" % merchant.get_npc_name())
```

---

### get_alive_npc_count

```gdscript
func get_alive_npc_count() -> int
```

Gets number of alive NPCs.

**Returns:** `int` - Number of alive NPCs

**Example:**
```gdscript
var alive_count = PPNPCManager.get_alive_npc_count()
var total_count = PPNPCManager.get_spawned_npc_count()

print("Alive NPCs: %d / %d" % [alive_count, total_count])
```

---

### get_spawned_npc_count

```gdscript
func get_spawned_npc_count() -> int
```

Gets total number of spawned NPCs.

**Returns:** `int` - Total spawned NPCs

**Example:**
```gdscript
var count = PPNPCManager.get_spawned_npc_count()
print("Total spawned NPCs: %d" % count)
```

---

### revive_npc

```gdscript
func revive_npc(npc_entity_id: String, health_percentage: float = 1.0) -> bool
```

Revives an NPC by entity ID.

**Parameters:**
- `npc_entity_id` (String) - NPC entity identifier
- `health_percentage` (float) - Health percentage to revive with (0.0 to 1.0, default 1.0)

**Returns:** `bool` - `true` if NPC was revived

**Example:**
```gdscript
# Revive at full health
PPNPCManager.revive_npc("npc_companion", 1.0)

# Revive at 50% health
PPNPCManager.revive_npc("npc_companion", 0.5)
```

---

### force_restock

```gdscript
func force_restock(npc_entity_id: String) -> bool
```

**💎 Premium Only** - Forces a merchant NPC to restock their inventory.

**Parameters:**
- `npc_entity_id` (String) - NPC entity identifier

**Returns:** `bool` - `true` if restock was performed

**Example:**
```gdscript
# 💎 Premium
# Force merchant restock
var restocked = PPNPCManager.force_restock("npc_merchant_general")

if restocked:
    print("Merchant inventory refreshed")
```

---

### update_all_schedules

```gdscript
func update_all_schedules(current_game_hour: int) -> void
```

**💎 Premium Only** - Updates all NPC schedules based on current game hour.

**Parameters:**
- `current_game_hour` (int) - Current hour (0-23)

**Notes:**
- Called automatically by PPTimeManager when hour changes
- Updates location and activity for all NPCs with schedules

**Example:**
```gdscript
# 💎 Premium
# Manually update schedules
var current_hour = PPTimeManager.get_current_hour()
PPNPCManager.update_all_schedules(current_hour)
```

---

### clear_all

```gdscript
func clear_all() -> void
```

Clears all NPC state (for new game).

**Notes:**
- Removes all spawned NPCs
- Emits `all_npcs_cleared` signal

**Example:**
```gdscript
# Start new game
PPNPCManager.clear_all()
```

---

### load_state

```gdscript
func load_state(game_state: PPGameState) -> void
```

Loads NPC state from GameState (called by SaveManager).

**Parameters:**
- `game_state` (PPGameState) - Game state instance

**Notes:**
- Called automatically by `PPSaveManager.restore_state()`
- Clears existing NPCs and loads from save data

**Example:**
```gdscript
# Called automatically by save system
# Manual usage:
var game_state = PPSaveManager.load_game(1)
if game_state:
    PPNPCManager.load_state(game_state)
```

---

### save_state

```gdscript
func save_state(game_state: PPGameState) -> void
```

Saves NPC state to GameState (called by SaveManager).

**Parameters:**
- `game_state` (PPGameState) - Game state instance to update

**Notes:**
- Called automatically by `PPSaveManager.save_game()`

**Example:**
```gdscript
# Called automatically by save system
# Manual usage:
var game_state = PPGameState.new()
PPNPCManager.save_state(game_state)
```

---

### get_summary

```gdscript
func get_summary() -> String
```

Gets a debug summary of NPC state.

**Returns:** `String` - Summary text

**Example:**
```gdscript
print(PPNPCManager.get_summary())

# Output:
# NPCManager State:
#   Spawned NPCs: 12
#   Alive NPCs: 10
#   Quest Givers: 5
#   Merchants: 3 (💎 Premium)
#
#   NPCs by location:
#     town_square: 5 NPCs
#     market: 3 NPCs
#     tavern: 2 NPCs
#     blacksmith: 2 NPCs
```

---

## Usage Examples

### NPC Spawning System

```gdscript
extends Node

func spawn_town_npcs():
    # Spawn guards
    var guard_entity = Pandora.get_entity("npc_guard") as PPNPCEntity
    PPNPCManager.spawn_npc(guard_entity, "town_gate_north")
    PPNPCManager.spawn_npc(guard_entity, "town_gate_south")

    # Spawn merchants
    var merchant_entity = Pandora.get_entity("npc_merchant") as PPNPCEntity
    PPNPCManager.spawn_npc(merchant_entity, "market_square")

    # Spawn quest givers
    var elder_entity = Pandora.get_entity("npc_village_elder") as PPNPCEntity
    PPNPCManager.spawn_npc(elder_entity, "town_hall")

    print("Spawned %d NPCs" % PPNPCManager.get_spawned_npc_count())
```

---

### Location-Based NPC Management

```gdscript
func enter_location(location_id: String):
    # Get NPCs at this location
    var npcs = PPNPCManager.get_npcs_at_location(location_id)

    print("Entering %s with %d NPCs" % [location_id, npcs.size()])

    for npc in npcs:
        # Create visual representation
        create_npc_visual(npc)

        # Check for quest markers
        if npc.is_quest_giver():
            var completed = PPQuestManager.get_completed_quest_ids()
            if npc.has_available_quests(completed):
                show_quest_marker(npc)

func exit_location(location_id: String):
    # Optionally despawn NPCs when leaving location
    var count = PPNPCManager.despawn_npcs_at_location(location_id)
    print("Despawned %d NPCs from %s" % [count, location_id])
```

---

### Quest Giver Integration

```gdscript
func update_quest_markers():
    var quest_givers = PPNPCManager.get_all_quest_givers()
    var completed_ids = PPQuestManager.get_completed_quest_ids()

    for npc in quest_givers:
        var available = npc.get_available_quests(completed_ids)

        if not available.is_empty():
            # Show yellow marker (new quest)
            show_marker_above_npc(npc, Color.YELLOW)
        elif has_quest_to_turn_in(npc):
            # Show green marker (quest complete)
            show_marker_above_npc(npc, Color.GREEN)
        else:
            hide_marker_above_npc(npc)

func has_quest_to_turn_in(npc: PPRuntimeNPC) -> bool:
    var active_quests = PPQuestManager.get_active_quests()

    for quest in active_quests:
        if quest.is_completed() and quest.get_quest_giver_id() == npc.get_entity_id():
            return true

    return false
```

---

### NPC Death and Revival

```gdscript
extends Node

func _ready():
    # Listen to NPC death
    PPNPCManager.npc_died.connect(_on_npc_died)
    PPNPCManager.npc_revived.connect(_on_npc_revived)

func _on_npc_died(npc_id: String):
    print("NPC died: %s" % npc_id)

    # Track for quests
    var active_quests = PPQuestManager.get_active_quests()
    for quest in active_quests:
        PPQuestUtils.track_enemy_killed(quest, npc_id)

    # Drop loot
    spawn_loot_for_npc(npc_id)

    # Update UI
    remove_npc_from_minimap(npc_id)

func _on_npc_revived(npc_id: String):
    print("NPC revived: %s" % npc_id)

    # Update UI
    add_npc_to_minimap(npc_id)

func revive_companion():
    var companion_id = "npc_companion"

    if PPNPCManager.revive_npc(companion_id, 0.5):
        print("Companion revived at 50% health")
        play_revival_cutscene()
```

---

### 💎 Premium: Merchant Management

```gdscript
# 💎 Premium
extends Node

func _ready():
    # Listen to merchant restocks
    PPNPCManager.npc_shop_restocked.connect(_on_shop_restocked)

func _on_shop_restocked(npc_id: String):
    print("Shop restocked: %s" % npc_id)

    # Notify player if currently viewing this merchant
    if current_merchant_ui_id == npc_id:
        refresh_merchant_inventory()
        show_notification("Shop inventory refreshed!")

func force_all_merchants_restock():
    var merchants = PPNPCManager.get_all_merchants()

    for merchant in merchants:
        var npc_id = merchant.npc_data.get("entity_id")
        PPNPCManager.force_restock(npc_id)

    print("All %d merchants restocked" % merchants.size())
```

---

### 💎 Premium: NPC Schedule Integration

```gdscript
# 💎 Premium
extends Node

func _ready():
    # Listen to time changes
    PPTimeManager.hour_changed.connect(_on_hour_changed)

    # Listen to location changes
    PPNPCManager.npc_location_changed.connect(_on_npc_location_changed)

func _on_hour_changed(old_hour: int, new_hour: int):
    print("Hour changed: %d → %d" % [old_hour, new_hour])

    # Schedules are updated automatically by PPTimeManager
    # But we can react to the changes here

    # Update NPC visuals based on new locations
    update_npc_positions()

func _on_npc_location_changed(npc_id: String, old_loc: Variant, new_loc: Variant):
    print("NPC %s moved: %s → %s" % [npc_id, old_loc, new_loc])

    # Move NPC visual in world
    var npc = PPNPCManager.find_npc_by_entity_id(npc_id)
    if npc:
        move_npc_visual_to_location(npc, new_loc)
```

---

## See Also

- [NPC System](../core-systems/npc-system.md) - Complete NPC system guide
- [PPRuntimeNPC](runtime-npc.md) - Runtime NPC API
- [PPNPCEntity](../entities/npc-entity.md) - NPC entity API
- [PPNPCUtils](../utilities/npc-utils.md) - NPC utility functions
- [💎 NPC Routine Tutorial](../tutorials/npc-routine.md) - NPC schedule tutorial

---

*API Reference for Pandora+ v1.0.0*
