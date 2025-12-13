# PPStatModifier

**Extends:** `Resource`

Represents a single modifier that can be applied to a stat in `PPRuntimeStats`.

---

## Description

`PPStatModifier` defines how a stat should be modified. Modifiers can be flat (add fixed value), additive (add percentage), or multiplicative (multiply total).

Modifiers support:
- Three types of modification (FLAT, ADDITIVE, MULTIPLICATIVE)
- Optional duration for temporary effects
- Source tracking for easy removal
- Stacking rules
- Priority system

---

## Enums

### `ModifierType`

Defines how the modifier affects the stat.

| Value | Description | Formula |
|-------|-------------|---------|
| `FLAT` | Adds a fixed value | `result = base + value` |
| `ADDITIVE` | Adds percentage of base | `result = base + (base * value / 100)` |
| `MULTIPLICATIVE` | Multiplies the result | `result = previous * value` |

**Example:**
```gdscript
# FLAT: +10 attack
var flat = PPStatModifier.new("attack", PPStatModifier.ModifierType.FLAT, 10.0)

# ADDITIVE: +20% attack
var additive = PPStatModifier.new("attack", PPStatModifier.ModifierType.ADDITIVE, 20.0)

# MULTIPLICATIVE: x1.5 attack
var multi = PPStatModifier.new("attack", PPStatModifier.ModifierType.MULTIPLICATIVE, 1.5)
```

---

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `stat_name` | `String` | `""` | Name of the stat to modify (e.g., "health", "attack") |
| `type` | `ModifierType` | `FLAT` | Type of modification to apply |
| `value` | `float` | `0.0` | Value of the modifier (interpretation depends on type) |
| `duration` | `float` | `0.0` | Duration in seconds (0 = permanent) |
| `source` | `String` | `""` | Identifier for the source (e.g., "poison_effect", "iron_sword") |
| `tag` | `String` | `""` | Optional category tag (e.g., "buff", "debuff") |
| `stackable` | `bool` | `true` | Can stack with other modifiers |
| `priority` | `int` | `0` | Application priority (higher = applied first) |

### Stat Names

The `stat_name` property is restricted to these values (via `@export_enum`):

- `health` - Hit points
- `mana` - Magic points
- `attack` - Physical damage
- `defense` - Damage reduction
- `crit_rate` - Critical hit chance
- `crit_damage` - Critical damage multiplier
- `att_speed` - Attack speed
- `mov_speed` - Movement speed

---

## Constructor

###### `PPStatModifier(p_stat_name: String = "", p_type: ModifierType = FLAT, p_value: float = 0.0, p_duration: float = 0.0, p_source: String = "", p_tag: String = "")`

Creates a new modifier.

**Parameters:**
- `p_stat_name`: Name of the stat to modify
- `p_type`: Type of modifier (FLAT, ADDITIVE, or MULTIPLICATIVE)
- `p_value`: Value of the modifier
- `p_duration`: Duration in seconds (0 = permanent)
- `p_source`: Source identifier
- `p_tag`: Optional tag for categorization

**Example:**
```gdscript
# Full constructor
var mod = PPStatModifier.new(
    "attack",                          # stat
    PPStatModifier.ModifierType.FLAT,  # type
    10.0,                              # +10
    60.0,                              # 60 seconds
    "strength_potion",                 # source
    "buff"                             # tag
)
```

---

## Factory Methods

These static methods provide convenient ways to create modifiers:

###### `create_flat(stat: String, amount: float, src: String = "", dur: float = 0.0) -> PPStatModifier`

Creates a FLAT modifier (adds fixed value).

**Parameters:**
- `stat`: Stat to modify
- `amount`: Amount to add
- `src`: Source identifier (optional)
- `dur`: Duration in seconds (optional, default 0 = permanent)

**Example:**
```gdscript
# +10 attack from weapon
var weapon_mod = PPStatModifier.create_flat("attack", 10.0, "iron_sword")

# +20 health from buff (30 seconds)
var buff = PPStatModifier.create_flat("health", 20.0, "regeneration_buff", 30.0)
```

---

###### `create_percent(stat: String, percent: float, src: String = "", dur: float = 0.0) -> PPStatModifier`

Creates an ADDITIVE modifier (adds percentage of base).

**Parameters:**
- `stat`: Stat to modify
- `percent`: Percentage to add (20.0 = +20%)
- `src`: Source identifier (optional)
- `dur`: Duration in seconds (optional)

**Example:**
```gdscript
# +50% attack from potion (60 seconds)
var potion = PPStatModifier.create_percent("attack", 50.0, "strength_potion", 60.0)

# -30% defense from debuff (10 seconds)
var debuff = PPStatModifier.create_percent("defense", -30.0, "weakness", 10.0)
```

**Note:** The percentage is of the **base stat value**, not the current effective value.

---

###### `create_multiplier(stat: String, multiplier: float, src: String = "", dur: float = 0.0) -> PPStatModifier`

Creates a MULTIPLICATIVE modifier (multiplies total).

**Parameters:**
- `stat`: Stat to modify
- `multiplier`: Multiplier to apply (1.5 = x1.5 = 150%)
- `src`: Source identifier (optional)
- `dur`: Duration in seconds (optional)

**Example:**
```gdscript
# x2 damage (critical hit, instant)
var crit = PPStatModifier.create_multiplier("attack", 2.0, "critical")

# x1.5 speed (haste spell, 30 seconds)
var haste = PPStatModifier.create_multiplier("mov_speed", 1.5, "haste", 30.0)
```

---

## Methods

###### `can_stack_with(other: PPStatModifier) -> bool`

Checks if this modifier can stack with another.

**Parameters:**
- `other`: Another modifier to check against

**Returns:** `true` if can stack, `false` otherwise

**Stacking Rules:**
- Returns `false` if either modifier has `stackable = false`
- Returns `false` if both have the same non-empty `source`
- Returns `true` otherwise

**Example:**
```gdscript
var mod1 = PPStatModifier.create_flat("attack", 10.0, "sword_A")
var mod2 = PPStatModifier.create_flat("attack", 10.0, "sword_A")

if not mod1.can_stack_with(mod2):
    print("Same source - they don't stack")
    # In practice, you'd replace mod1 with mod2
```

---

###### `to_dict() -> Dictionary`

Serializes the modifier to a Dictionary.

**Returns:** Dictionary containing all properties

**Example:**
```gdscript
var mod = PPStatModifier.create_percent("attack", 50.0, "potion", 60.0)
var data = mod.to_dict()

# Save to file
var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
file.store_var(data)
file.close()
```

**Dictionary Structure:**
```gdscript
{
    "stat_name": "attack",
    "type": 1,  # ADDITIVE
    "value": 50.0,
    "duration": 60.0,
    "source": "potion",
    "tag": "",
    "stackable": true,
    "priority": 0
}
```

---

###### `from_dict(data: Dictionary) -> PPStatModifier` (static)

Deserializes a modifier from a Dictionary.

**Parameters:**
- `data`: Dictionary created by `to_dict()`

**Returns:** New `PPStatModifier` instance

**Example:**
```gdscript
# Load from file
var file = FileAccess.open("user://save.dat", FileAccess.READ)
var data = file.get_var()
file.close()

var mod = PPStatModifier.from_dict(data)
```

---

###### `_to_string() -> String`

Returns a human-readable string representation.

**Returns:** String describing the modifier

**Example:**
```gdscript
var mod = PPStatModifier.create_percent("attack", 50.0, "potion", 60.0)
print(mod)
# Output: "PPStatModifier(attack, ADDITIVE, 50.0, potion, 60s)"
```

---

## Usage Examples

### Equipment Bonus

```gdscript
# Permanent equipment bonus
var sword_damage = PPStatModifier.create_flat("attack", 15.0, "equipped_weapon")
var armor_defense = PPStatModifier.create_flat("defense", 10.0, "equipped_armor")
var boots_speed = PPStatModifier.create_percent("mov_speed", 20.0, "equipped_boots")

runtime_stats.add_modifier(sword_damage)
runtime_stats.add_modifier(armor_defense)
runtime_stats.add_modifier(boots_speed)

# When unequipping
runtime_stats.remove_modifiers_by_source("equipped_weapon")
```

---

### Temporary Buff

```gdscript
func apply_strength_buff():
    # +50% attack for 60 seconds
    var buff = PPStatModifier.create_percent("attack", 50.0, "strength_spell", 60.0)
    buff.tag = "buff"
    
    runtime_stats.add_modifier(buff)
    
    # Manual timer (since auto-removal is commented out)
    await get_tree().create_timer(60.0).timeout
    runtime_stats.remove_modifier(buff)
```

---

### Stacking Debuffs

```gdscript
func apply_poison_stack():
    # Each poison application adds a stack
    var poison = PPStatModifier.create_percent("att_speed", -10.0, "poison_stack_%d" % poison_stack_count)
    poison.tag = "debuff"
    
    runtime_stats.add_modifier(poison)
    poison_stack_count += 1
    
    # Max 5 stacks
    if poison_stack_count > 5:
        # Remove oldest stack
        runtime_stats.remove_modifiers_by_source("poison_stack_0")
```

---

### Critical Hit Multiplier

```gdscript
func apply_critical_damage():
    # x2 damage for this attack only
    var crit = PPStatModifier.create_multiplier("attack", 2.0, "critical_hit")
    
    runtime_stats.add_modifier(crit)
    
    # Calculate damage with crit
    var damage = calculate_damage()
    
    # Remove immediately after
    runtime_stats.remove_modifier(crit)
    
    return damage
```
---

## Calculation Examples

### Example 1: Single Modifier

```gdscript
# Base attack: 10
var runtime = PPRuntimeStats.new({"attack": 10.0})

# Add flat modifier: +5
var mod = PPStatModifier.create_flat("attack", 5.0)
runtime.add_modifier(mod)

var result = runtime.get_effective_stat("attack")
# Result: 10 + 5 = 15
```

---

### Example 2: Multiple Modifiers (Same Type)

```gdscript
# Base attack: 10
var runtime = PPRuntimeStats.new({"attack": 10.0})

# Add two flat modifiers
runtime.add_modifier(PPStatModifier.create_flat("attack", 5.0, "source_a"))
runtime.add_modifier(PPStatModifier.create_flat("attack", 3.0, "source_b"))

var result = runtime.get_effective_stat("attack")
# Result: 10 + 5 + 3 = 18
```

---

### Example 3: Mixed Modifier Types

```gdscript
# Base attack: 10
var runtime = PPRuntimeStats.new({"attack": 10.0})

# FLAT: +5
runtime.add_modifier(PPStatModifier.create_flat("attack", 5.0))

# ADDITIVE: +50% (of base)
runtime.add_modifier(PPStatModifier.create_percent("attack", 50.0))

# MULTIPLICATIVE: x1.2
runtime.add_modifier(PPStatModifier.create_multiplier("attack", 1.2))

# Calculation:
# 1. FLAT: 10 + 5 = 15
# 2. ADDITIVE: 15 + (10 * 0.5) = 20
# 3. MULTIPLICATIVE: 20 * 1.2 = 24

var result = runtime.get_effective_stat("attack")
# Result: 24.0
```

---

### Example 4: Negative Modifiers (Debuffs)

```gdscript
# Base defense: 20
var runtime = PPRuntimeStats.new({"defense": 20.0})

# Armor broken: -10 flat
runtime.add_modifier(PPStatModifier.create_flat("defense", -10.0, "armor_break"))

# Weakness: -30% (of base)
runtime.add_modifier(PPStatModifier.create_percent("defense", -30.0, "weakness"))

# Calculation:
# 1. FLAT: 20 - 10 = 10
# 2. ADDITIVE: 10 + (20 * -0.3) = 4

var result = runtime.get_effective_stat("defense")
# Result: 4.0
```

---

## Best Practices

### Use Source for Grouping

```gdscript
# ✅ Good: use source to identify modifier group
var mod1 = PPStatModifier.create_flat("attack", 10.0, "equipped_weapon")
var mod2 = PPStatModifier.create_percent("crit_rate", 15.0, "equipped_weapon")

# Easy to remove all weapon bonuses
runtime_stats.remove_modifiers_by_source("equipped_weapon")

# ❌ Bad: no source
var mod = PPStatModifier.create_flat("attack", 10.0)
# Can't remove by source later!
```

---

### Use Tags for Categories

```gdscript
# Create modifiers with tags
var buff = PPStatModifier.create_percent("attack", 50.0, "spell_buff")
buff.tag = "buff"

var debuff = PPStatModifier.create_percent("defense", -30.0, "poison")
debuff.tag = "debuff"

# Filter by tag
func get_active_buffs() -> Array[PPStatModifier]:
    var buffs: Array[PPStatModifier] = []
    for mod in runtime_stats._active_modifiers:
        if mod.tag == "buff":
            buffs.append(mod)
    return buffs
```

---

### Duration Management

```gdscript
# ⚠️ Duration is NOT auto-handled in current implementation
var buff = PPStatModifier.create_percent("attack", 50.0, "potion", 60.0)
runtime_stats.add_modifier(buff)

# You MUST implement your own timer
if buff.duration > 0:
    await get_tree().create_timer(buff.duration).timeout
    runtime_stats.remove_modifier(buff)
```

---

## See Also

- [PPRuntimeStats](PPRuntimeStats.md) - Runtime stats system
- [Runtime Stats System](../core-systems/runtime-stats.md) - Core documentation
- [PPCombatCalculator](../utilities/combat-calculator.md) - Using modifiers in combat

---

*API Reference generated from source code version 0.3.0-beta*