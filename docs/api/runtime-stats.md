# PPRuntimeStats

**Extends:** `Resource`

Dynamic stat calculation system with support for modifiers and caching.

---

## Description

`PPRuntimeStats` wraps base stats (from Pandora's `PPStats` or a Dictionary) and applies modifiers in real-time. It uses a cached calculation approach for performance, recalculating only when modifiers change.

---

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `base_stats_data` | `Dictionary` | `{}` | Base stats stored as key-value pairs (e.g., `{"health": 100.0, "attack": 15.0}`) |

---

## Signals

###### `stats_changed(stat_name: String, old_value: Variant, new_value: Variant)`

Emitted when a stat value changes.

**Parameters:**
- `stat_name`: Name of the stat that changed
- `old_value`: Previous value
- `new_value`: New value

> ⚠️ **Note:** Currently not automatically emitted. You may need to emit it manually when modifying base stats.

---

###### `modifier_added(modifier: PPStatModifier)`

Emitted when a modifier is added to the system.

**Parameters:**
- `modifier`: The modifier that was added

**Example:**
```gdscript
runtime_stats.modifier_added.connect(func(mod):
    print("Added buff: ", mod.source)
)
```

---

###### `modifier_removed(modifier: PPStatModifier)`

Emitted when a modifier is removed from the system.

**Parameters:**
- `modifier`: The modifier that was removed

**Example:**
```gdscript
runtime_stats.modifier_removed.connect(func(mod):
    print("Removed buff: ", mod.source)
)
```

---

## Constructor

###### `PPRuntimeStats(p_base_stats: Variant = null)`

Creates a new runtime stats instance.

**Parameters:**
- `p_base_stats` (optional): Can be one of:
  - `PPStats` - Pandora stats entity (automatically converted to Dictionary)
  - `Dictionary` - Custom stats dictionary
  - `null` - Uses default stats

**Examples:**

<!-- tabs:start -->

#### **From PPStats**

```gdscript
var pandora_stats = Pandora.get_entity("player_stats") as PPStats
var runtime = PPRuntimeStats.new(pandora_stats)
```

#### **From Dictionary**

```gdscript
var stats = {
    "health": 100.0,
    "attack": 15.0,
    "defense": 8.0
}
var runtime = PPRuntimeStats.new(stats)
```

#### **Default Stats**

```gdscript
var runtime = PPRuntimeStats.new()
# Uses: health=100, mana=100, attack=5, defense=5, etc.
```

<!-- tabs:end -->

---

## Methods

###### `get_effective_stat(stat_name: String) -> float`

Returns the effective value of a stat after applying all modifiers.

**Parameters:**
- `stat_name`: Name of the stat (e.g., "health", "attack")

**Returns:** The calculated stat value

**Example:**
```gdscript
var effective_attack = runtime_stats.get_effective_stat("attack")
print("Attack with buffs: ", effective_attack)
```

**Calculation Order:**
1. Start with base value
2. Apply FLAT modifiers (sum)
3. Apply ADDITIVE modifiers (percentage of base)
4. Apply MULTIPLICATIVE modifiers (multiply result)

---

###### `add_modifier(modifier: PPStatModifier) -> void`

Adds a modifier to the stat system.

**Parameters:**
- `modifier`: The modifier to add

**Example:**
```gdscript
# Temporary buff
var buff = PPStatModifier.create_percent("attack", 50.0, "potion", 60.0)
runtime_stats.add_modifier(buff)

# Permanent equipment
var sword = PPStatModifier.create_flat("attack", 10.0, "iron_sword")
runtime_stats.add_modifier(sword)
```

**Notes:**
- Emits `modifier_added` signal
- Invalidates cache (triggers recalculation on next `get_effective_stat`)
- Duration handling is currently manual (auto-removal is commented out)

---

###### `remove_modifier(modifier: PPStatModifier) -> void`

Removes a specific modifier instance.

**Parameters:**
- `modifier`: The exact modifier to remove

**Example:**
```gdscript
var buff = PPStatModifier.create_flat("attack", 5.0, "buff")
runtime_stats.add_modifier(buff)

# Later, remove it
runtime_stats.remove_modifier(buff)
```

**Notes:**
- Emits `modifier_removed` signal
- Does nothing if modifier not found

---

###### `remove_modifiers_by_source(source: String) -> void`

Removes all modifiers with a specific source.

**Parameters:**
- `source`: The source string to match

**Example:**
```gdscript
# Add equipment bonuses
var sword = PPStatModifier.create_flat("attack", 10.0, "equipped_weapon")
var helmet = PPStatModifier.create_flat("defense", 5.0, "equipped_helmet")
runtime_stats.add_modifier(sword)
runtime_stats.add_modifier(helmet)

# Unequip weapon (removes only weapon modifier)
runtime_stats.remove_modifiers_by_source("equipped_weapon")
```

**Use Cases:**
- Unequipping items
- Removing all buffs from a spell
- Clearing temporary effects

---

###### `get_modifiers_for_stat(stat_name: String) -> Array[PPStatModifier]`

Returns all modifiers affecting a specific stat.

**Parameters:**
- `stat_name`: Name of the stat

**Returns:** Array of modifiers

**Example:**
```gdscript
var attack_mods = runtime_stats.get_modifiers_for_stat("attack")

print("Modifiers affecting attack:")
for mod in attack_mods:
    print("  - %s: %+.1f (%s)" % [mod.source, mod.value, mod.type])
```

---

###### `clear_all_modifiers() -> void`

Removes all modifiers from the system.

**Example:**
```gdscript
# Remove all buffs/debuffs
runtime_stats.clear_all_modifiers()
```

**Use Cases:**
- Resetting character state
- Death penalty
- Dispel all effects

---

###### `to_dict() -> Dictionary`

Serializes the runtime stats to a Dictionary for saving.

**Returns:** Dictionary containing:
- `base_stats_data`: Base stats
- `active_modifiers`: Array of modifier dictionaries

**Example:**
```gdscript
# Save
var save_data = runtime_stats.to_dict()
var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
file.store_var(save_data)
file.close()
```

---

###### `from_dict(data: Dictionary) -> PPRuntimeStats` (static)

Deserializes runtime stats from a Dictionary.

**Parameters:**
- `data`: Dictionary created by `to_dict()`

**Returns:** New `PPRuntimeStats` instance

**Example:**
```gdscript
# Load
var file = FileAccess.open("user://save.dat", FileAccess.READ)
var save_data = file.get_var()
file.close()

var runtime = PPRuntimeStats.from_dict(save_data)
```

---

## Default Stats

When created without parameters, these default values are used:

| Stat | Default Value |
|------|---------------|
| `health` | 100.0 |
| `mana` | 100.0 |
| `attack` | 5.0 |
| `defense` | 5.0 |
| `att_speed` | 1.0 |
| `mov_speed` | 10.0 |
| `crit_rate` | 0.0 |
| `crit_damage` | 0.0 |

---

## Supported Stats

The system automatically calculates these stats:

- `health` - Hit points
- `mana` - Magic points
- `attack` - Physical damage
- `defense` - Damage reduction
- `att_speed` - Attack speed multiplier
- `mov_speed` - Movement speed
- `crit_rate` - Critical hit chance (percentage)
- `crit_damage` - Critical damage multiplier (percentage)

---

## Performance Notes

### Caching System

The class uses automatic caching to avoid unnecessary recalculations:

```gdscript
# First call: calculates
var hp1 = runtime.get_effective_stat("health")  # Calculates

# Second call: uses cache
var hp2 = runtime.get_effective_stat("health")  # Cached (fast)

# After modifier change: cache invalidated
runtime.add_modifier(some_modifier)
var hp3 = runtime.get_effective_stat("health")  # Recalculates
```

### Best Practices

```gdscript
# ❌ Inefficient: multiple recalculations
for mod in modifiers:
    runtime.add_modifier(mod)
    print(runtime.get_effective_stat("attack"))  # Recalc each time

# ✅ Efficient: add all, get once
for mod in modifiers:
    runtime.add_modifier(mod)
print(runtime.get_effective_stat("attack"))  # Recalc once
```

---

## Example: Complete Player Stats

```gdscript
extends CharacterBody2D

var runtime_stats: PPRuntimeStats
const MAX_HEALTH := 100.0

func _ready():
    # Initialize
    var base = {
        "health": MAX_HEALTH,
        "mana": 50.0,
        "attack": 15.0,
        "defense": 8.0,
        "att_speed": 1.2,
        "mov_speed": 200.0,
        "crit_rate": 10.0,
        "crit_damage": 150.0
    }
    runtime_stats = PPRuntimeStats.new(base)
    
    # Connect signals
    runtime_stats.modifier_added.connect(_on_buff_applied)
    runtime_stats.modifier_removed.connect(_on_buff_removed)

func equip_weapon(attack_bonus: float):
    runtime_stats.remove_modifiers_by_source("weapon")
    var mod = PPStatModifier.create_flat("attack", attack_bonus, "weapon")
    runtime_stats.add_modifier(mod)

func use_strength_potion():
    var buff = PPStatModifier.create_percent("attack", 50.0, "potion", 60.0)
    runtime_stats.add_modifier(buff)
    
    # Manual timer (auto-removal commented out in source)
    await get_tree().create_timer(60.0).timeout
    runtime_stats.remove_modifiers_by_source("potion")

func take_damage(amount: float):
    var defense = runtime_stats.get_effective_stat("defense")
    var reduction = defense * 0.5  # 50% of defense reduces damage
    var actual_damage = max(1, amount - reduction)
    
    var current = runtime_stats.get_effective_stat("health")
    var new_health = max(0, current - actual_damage)
    
    runtime_stats.base_stats_data["health"] = new_health
    runtime_stats._cache_dirty = true
    
    if new_health <= 0:
        die()

func _on_buff_applied(modifier: PPStatModifier):
    print("Buff applied: ", modifier.source)

func _on_buff_removed(modifier: PPStatModifier):
    print("Buff removed: ", modifier.source)
```

---

## See Also

- [PPStatModifier](../api/stat-modifier.md) - Modifier class
- [Runtime Stats System](../core-systems/runtime-stats.md) - Core documentation
- [PPCombatCalculator](../utilities/combat-calculator.md) - Using stats for damage

---

## Notes

### Current Limitations

1. **Duration Not Auto-Handled**: The automatic timer for modifier duration is commented out in the source. You need to implement your own timer system:
   ```gdscript
   # Manual duration handling
   if modifier.duration > 0:
       await get_tree().create_timer(modifier.duration).timeout
       runtime_stats.remove_modifier(modifier)
   ```

2. **stats_changed Signal**: Not automatically emitted when base stats change. Emit manually if needed:
   ```gdscript
   runtime_stats.base_stats_data["health"] = new_value
   runtime_stats.stats_changed.emit("health", old_value, new_value)
   ```

3. **Case Sensitivity**: Stat names are case-sensitive. Use lowercase: `"health"` not `"Health"`

---

*API Reference generated from source code version 0.3.0-beta*