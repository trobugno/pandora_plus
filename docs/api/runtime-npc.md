# PPRuntimeNPC

**Extends:** `Resource`

Runtime NPC instance that tracks dynamic state during gameplay including health, stats, location, and quest interactions.

---

## Description

`PPRuntimeNPC` is the runtime counterpart to `PPNPCEntity`. While `PPNPCEntity` defines the static blueprint of an NPC, `PPRuntimeNPC` tracks the dynamic state as the NPC exists in the game world.

This class manages:
- Combat system with health/mana tracking
- Stat modifiers (buffs/debuffs)
- Alive/dead state
- Location tracking
- Quest giver functionality
- Full serialization for save/load

---

## Signals

### Combat Signals

###### `health_changed(old_value: float, new_value: float)`

Emitted when NPC's health changes.

**Parameters:**
- `old_value`: Previous health value
- `new_value`: Current health value

**Example:**
```gdscript
npc.health_changed.connect(func(old_hp, new_hp):
    print("NPC health: %d -> %d" % [old_hp, new_hp])
    update_health_bar(new_hp, npc.get_max_health())
)
```

---

###### `mana_changed(old_value: float, new_value: float)`

Emitted when NPC's mana changes.

---

###### `died()`

Emitted when NPC dies.

**Example:**
```gdscript
npc.died.connect(func():
    play_death_animation()
    drop_loot()
    remove_from_world()
)
```

---

###### `revived()`

Emitted when NPC is revived.

---

### Location Signal

###### `location_changed(old_location: Variant, new_location: Variant)`

Emitted when NPC's location changes.

**Parameters:**
- `old_location`: Previous location reference
- `new_location`: New location reference

---

## Properties

###### `npc_data: Dictionary`

Serialized NPC entity data containing basic info (entity_id, name, faction, is_hostile).

---

## Constructor

###### `PPRuntimeNPC(p_npc_data: Variant = null)`

Creates a runtime NPC from either a `PPNPCEntity` or a Dictionary.

**Parameters:**
- `p_npc_data`: Either a `PPNPCEntity` instance or Dictionary with NPC data

**Example:**
```gdscript
# From PPNPCEntity
var npc_entity = Pandora.get_entity("VILLAGE_GUARD") as PPNPCEntity
var runtime_npc = PPRuntimeNPC.new(npc_entity)

# From dictionary (deserialization)
var saved_data = load_npc_from_file()
var runtime_npc = PPRuntimeNPC.from_dict(saved_data)
```

---

## Methods

### Combat System

###### `take_damage(amount: float, source: String = "unknown") -> void`

Applies damage to the NPC.

**Parameters:**
- `amount`: Damage amount
- `source`: Source identifier for tracking (default: "unknown")

**Behavior:**
- Reduces health by damage amount
- Emits `health_changed` signal
- Calls `die()` if health reaches 0

**Example:**
```gdscript
# Player attacks NPC
func attack_npc(npc: PPRuntimeNPC, weapon_damage: float):
    var attack = player_stats.get_effective_stat("attack")
    var total_damage = attack + weapon_damage

    npc.take_damage(total_damage, "player_attack")
```

---

###### `heal(amount: float) -> void`

Heals the NPC.

**Parameters:**
- `amount`: Healing amount

**Behavior:**
- Increases health by heal amount
- Caps at max health
- Emits `health_changed` signal

**Example:**
```gdscript
# NPC drinks health potion
npc.heal(50.0)
```

---

###### `die() -> void`

Kills the NPC.

**Behavior:**
- Sets `_is_alive` to `false`
- Emits `died` signal

**Example:**
```gdscript
# Instant kill
if boss_phase_complete:
    boss_npc.die()
```

---

###### `revive(health_percentage: float = 1.0) -> void`

Revives the NPC with specified health percentage.

**Parameters:**
- `health_percentage`: Percentage of max health to restore (0.0-1.0, default: 1.0)

**Behavior:**
- Sets `_is_alive` to `true`
- Clears all stat modifiers
- Restores health to specified percentage
- Emits `revived` signal

**Example:**
```gdscript
# Revive at half health
npc.revive(0.5)

# Revive at full health
npc.revive(1.0)
```

---

###### `is_alive() -> bool`

Returns `true` if NPC is alive.

---

### Stats Accessors

###### `get_current_health() -> float`

Returns current health (with all modifiers applied).

---

###### `get_current_mana() -> float`

Returns current mana (with all modifiers applied).

---

###### `get_max_health() -> float`

Returns maximum health (base health from stats).

---

###### `get_max_mana() -> float`

Returns maximum mana (base mana from stats).

---

###### `get_effective_stat(stat_name: String) -> float`

Returns effective value of a stat (with all modifiers applied).

**Parameters:**
- `stat_name`: Name of stat ("attack", "defense", etc.)

**Example:**
```gdscript
var attack = npc.get_effective_stat("attack")
var defense = npc.get_effective_stat("defense")
var speed = npc.get_effective_stat("mov_speed")
```

---

###### `add_stat_modifier(modifier: PPStatModifier) -> void`

Adds a stat modifier (buff/debuff) to the NPC.

**Example:**
```gdscript
# Apply poison debuff
var poison = PPStatModifier.create_flat("health", -5.0, "poison")
npc.add_stat_modifier(poison)

# Apply strength buff
var strength = PPStatModifier.create_percent("attack", 50.0, "strength_potion")
npc.add_stat_modifier(strength)
```

---

###### `remove_stat_modifier(modifier: PPStatModifier) -> void`

Removes a specific stat modifier.

---

###### `get_runtime_stats() -> PPRuntimeStats`

Returns the internal `PPRuntimeStats` instance for direct access.

---

### Location System

###### `set_location(location_reference: Variant) -> void`

Sets the NPC's current location.

**Parameters:**
- `location_reference`: Location identifier (PandoraReference, String, or custom)

**Emits:** `location_changed` signal

**Example:**
```gdscript
# Move NPC to new location
var tavern_ref = PandoraReference.new("TAVERN", PandoraReference.Type.ENTITY)
npc.set_location(tavern_ref)
```

---

###### `get_current_location() -> Variant`

Returns the NPC's current location reference.

---

### Quest Integration

###### `get_available_quests(completed_quest_ids: Array) -> Array`

Returns quests this NPC can give, filtered by completion status.

**Parameters:**
- `completed_quest_ids`: Array of quest IDs player has already completed

**Returns:** Array of `PPQuestEntity` instances

**Example:**
```gdscript
# Get quests player hasn't done yet
var player_completed = ["TUTORIAL_001", "MAIN_001"]
var available = npc.get_available_quests(player_completed)

for quest in available:
    print("Available quest: %s" % quest.get_quest_name())
```

---

###### `is_quest_giver() -> bool`

Returns `true` if this NPC can give quests.

---

### Serialization

###### `to_dict() -> Dictionary`

Serializes the runtime NPC to a dictionary for saving.

**Returns:** Dictionary containing NPC state

**Example:**
```gdscript
var save_data = runtime_npc.to_dict()
var file = FileAccess.open("user://npc_save.dat", FileAccess.WRITE)
file.store_var(save_data)
file.close()
```

---

###### `from_dict(data: Dictionary) -> PPRuntimeNPC` (static)

Deserializes a runtime NPC from a dictionary.

**Parameters:**
- `data`: Dictionary created by `to_dict()`

**Returns:** New `PPRuntimeNPC` instance

**Example:**
```gdscript
var file = FileAccess.open("user://npc_save.dat", FileAccess.READ)
var save_data = file.get_var()
file.close()

var runtime_npc = PPRuntimeNPC.from_dict(save_data)
```

---

## Usage Example

### Example: Combat NPC System

```gdscript
extends CharacterBody2D

var runtime_npc: PPRuntimeNPC

func _ready():
    # Initialize NPC
    var npc_entity = Pandora.get_entity("FOREST_BANDIT") as PPNPCEntity
    runtime_npc = PPRuntimeNPC.new(npc_entity)

    # Connect signals
    runtime_npc.health_changed.connect(_on_health_changed)
    runtime_npc.died.connect(_on_died)

    # Display health bar
    update_health_bar()

func attack_player(player: Node) -> void:
    if not runtime_npc.is_alive():
        return

    var attack_power = runtime_npc.get_effective_stat("attack")
    var crit_rate = runtime_npc.get_effective_stat("crit_rate")

    # Check for critical hit
    var is_crit = randf() * 100.0 < crit_rate
    var damage = attack_power

    if is_crit:
        var crit_multiplier = runtime_npc.get_effective_stat("crit_damage") / 100.0
        damage *= crit_multiplier

    player.take_damage(damage, "npc_attack")

func receive_player_attack(damage: float) -> void:
    var defense = runtime_npc.get_effective_stat("defense")
    var damage_reduction = defense * 0.5

    var final_damage = max(1.0, damage - damage_reduction)

    runtime_npc.take_damage(final_damage, "player_attack")

func _on_health_changed(old_hp: float, new_hp: float) -> void:
    update_health_bar()

    # Play hurt animation
    if new_hp < old_hp:
        play_hurt_animation()

func _on_died() -> void:
    # Death sequence
    play_death_animation()

    # Drop loot
    drop_loot_items()

    # Grant experience
    grant_exp_to_player()

    # Remove from world after delay
    await get_tree().create_timer(2.0).timeout
    queue_free()

func update_health_bar() -> void:
    var current = runtime_npc.get_current_health()
    var maximum = runtime_npc.get_max_health()

    $HealthBar.max_value = maximum
    $HealthBar.value = current
```

---

### Example: Quest Giver NPC

```gdscript
extends Area2D

var runtime_npc: PPRuntimeNPC
var player_completed_quests: Array[String] = []

func _ready():
    var npc_entity = Pandora.get_entity("VILLAGE_ELDER") as PPNPCEntity
    runtime_npc = PPRuntimeNPC.new(npc_entity)

    body_entered.connect(_on_player_interact)

func _on_player_interact(body: Node) -> void:
    if not body.is_in_group("player"):
        return

    if runtime_npc.is_quest_giver():
        show_quest_dialog()

func show_quest_dialog() -> void:
    var available_quests = runtime_npc.get_available_quests(player_completed_quests)

    if available_quests.is_empty():
        show_dialog("I have no quests for you right now.")
        return

    # Show quest selection UI
    for quest_entity in available_quests:
        var quest_data = quest_entity.get_quest_data()
        add_quest_option(quest_data.get_quest_name(), quest_data.get_description())

func accept_quest(quest_entity: PPQuestEntity) -> void:
    var runtime_quest = PPRuntimeQuest.new(quest_entity.get_quest_data())
    runtime_quest.start()

    QuestManager.add_active_quest(runtime_quest)
    show_dialog("Good luck with your quest!")
```

---

## Best Practices

### ✅ Connect Combat Signals for Visual Feedback

```gdscript
# ✅ Good: Visual feedback on health changes
npc.health_changed.connect(func(old, new):
    show_damage_number(old - new)
    update_health_bar()
    if new < old:
        play_hurt_sound()
)

# ❌ Bad: No feedback
npc.take_damage(50.0)
```

---

### ✅ Check Alive Status Before Actions

```gdscript
# ✅ Good: Verify NPC is alive
if npc.is_alive():
    npc.attack_player(player)

# ❌ Bad: Assume alive (can cause issues)
npc.attack_player(player)
```

---

### ✅ Use Proper Source Tracking for Damage

```gdscript
# ✅ Good: Track damage sources
npc.take_damage(fire_damage, "fire_spell")
npc.take_damage(sword_damage, "player_sword")
npc.take_damage(poison_damage, "poison_effect")

# ❌ Bad: No source tracking
npc.take_damage(damage)  # Hard to debug
```

---

## Common Patterns

### Pattern 1: NPC Manager

```gdscript
class NPCManager:
    var active_npcs: Dictionary = {}  # entity_id -> PPRuntimeNPC

    func spawn_npc(entity_id: String, position: Vector2) -> Node:
        var npc_entity = Pandora.get_entity(entity_id) as PPNPCEntity
        var runtime_npc = PPRuntimeNPC.new(npc_entity)

        # Create scene instance
        var npc_scene = load("res://scenes/npc.tscn").instantiate()
        npc_scene.runtime_npc = runtime_npc
        npc_scene.global_position = position

        runtime_npc.died.connect(func():
            _on_npc_died(entity_id)
        )

        active_npcs[entity_id] = runtime_npc
        return npc_scene

    func _on_npc_died(entity_id: String) -> void:
        active_npcs.erase(entity_id)

    func save_all_npcs() -> Dictionary:
        var save_data = {}
        for id in active_npcs:
            save_data[id] = active_npcs[id].to_dict()
        return save_data
```

---

### Pattern 2: Buff/Debuff System

```gdscript
func apply_poison(npc: PPRuntimeNPC, duration: float) -> void:
    var poison_mod = PPStatModifier.create_flat("health", -2.0, "poison")
    npc.add_stat_modifier(poison_mod)

    # Remove after duration
    await get_tree().create_timer(duration).timeout
    npc.remove_stat_modifier(poison_mod)

func apply_strength_buff(npc: PPRuntimeNPC, percent: float, duration: float) -> void:
    var buff = PPStatModifier.create_percent("attack", percent, "strength_buff")
    npc.add_stat_modifier(buff)

    await get_tree().create_timer(duration).timeout
    npc.remove_stat_modifier(buff)
```

---

### Pattern 3: Location-Based NPC Spawning

```gdscript
var npc_locations = {
    "TAVERN": ["BARTENDER", "PATRON_1", "PATRON_2"],
    "FOREST": ["BANDIT", "WOLF"],
    "CASTLE": ["GUARD", "KING"]
}

func spawn_npcs_for_location(location_id: String) -> void:
    var npc_ids = npc_locations.get(location_id, [])

    for npc_id in npc_ids:
        var npc_entity = Pandora.get_entity(npc_id) as PPNPCEntity
        var runtime_npc = PPRuntimeNPC.new(npc_entity)

        # Set location
        var location_ref = PandoraReference.new(location_id, PandoraReference.Type.ENTITY)
        runtime_npc.set_location(location_ref)

        # Spawn in world
        spawn_npc_at_spawn_point(runtime_npc)
```

---

## Notes

### Health and Damage System

Damage is applied through stat modifiers. When `take_damage()` is called:
1. A negative FLAT modifier is added to the "health" stat
2. Effective health is recalculated
3. If health ≤ 0, `die()` is called

### Stat Modifiers

The NPC uses `PPRuntimeStats` internally, which supports FLAT, ADDITIVE, and MULTIPLICATIVE modifiers. See [PPRuntimeStats](../api/runtime-stats.md) for details.

### Persistence

Use `to_dict()` and `from_dict()` to save/load NPC state. This preserves:
- Health and mana
- All stat modifiers
- Alive/dead state
- Current location

---

## See Also

- [PPNPCEntity](../entities/npc-entity.md) - NPC entity definition
- [PPRuntimeStats](../api/runtime-stats.md) - Stat system
- [PPStatModifier](../api/stat-modifier.md) - Stat modifiers
- [NPC System](../core-systems/npc-system.md) - Complete system overview
- [PPNPCUtils](../utilities/npc-utils.md) - NPC utility functions

---

*API Reference generated from source code*
