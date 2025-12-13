# Runtime Stats System

The **Runtime Stats System** provides dynamic stat calculation with support for temporary and permanent modifiers. It's the foundation for implementing buffs, debuffs, equipment bonuses, and complex stat mechanics in your RPG.

## 🎯 Overview

`PPRuntimeStats` wraps your base stats (from Pandora's `PPStats`) and applies modifiers in real-time, allowing you to:

- ✅ Apply temporary buffs and debuffs
- ✅ Stack multiple modifiers from different sources
- ✅ Automatically calculate effective stats
- ✅ Remove expired or specific modifiers
- ✅ Serialize everything for save/load

The system uses a **cached calculation** approach for optimal performance, recalculating only when modifiers change.

---

## 💡 Key Concepts

### Base Stats vs Effective Stats

```gdscript
# Base stats: the foundation values
var base_stats = {
    "health": 100.0,
    "attack": 15.0,
    "defense": 8.0
}

# Runtime stats: base + modifiers
var runtime = PPRuntimeStats.new(base_stats)

# Effective stats: calculated result
var effective_attack = runtime.get_effective_stat("attack")
# With modifiers: could be 22.5 instead of 15
```

### Available Stats

The system supports these stats:

| Stat | Description | Default |
|------|-------------|---------|
| `health` | Hit points | 100.0 |
| `mana` | Magic points | 100.0 |
| `attack` | Physical damage | 5.0 |
| `defense` | Damage reduction | 5.0 |
| `att_speed` | Attack speed multiplier | 1.0 |
| `mov_speed` | Movement speed | 10.0 |
| `crit_rate` | Critical hit chance (%) | 0.0 |
| `crit_damage` | Critical damage multiplier (%) | 0.0 |

---

## 🚀 Quick Start

### Creating Runtime Stats

<!-- tabs:start -->

#### **From Pandora PPStats**

```gdscript
# Load base stats from Pandora
var base_stats = Pandora.get_entity("player_stats") as PPStats

# Create runtime stats (automatically converts to Dictionary)
var runtime_stats = PPRuntimeStats.new(base_stats)
```

#### **From Dictionary**

```gdscript
# Create from custom dictionary
var stats_dict = {
    "health": 100.0,
    "mana": 50.0,
    "attack": 15.0,
    "defense": 8.0,
    "att_speed": 1.2,
    "mov_speed": 200.0,
    "crit_rate": 10.0,
    "crit_damage": 150.0
}

var runtime_stats = PPRuntimeStats.new(stats_dict)
```

#### **Default Stats**

```gdscript
# Create with default values
var runtime_stats = PPRuntimeStats.new()
# Uses default stats: 100 HP, 100 MP, 5 ATK, etc.
```

<!-- tabs:end -->

### Getting Effective Stats

```gdscript
# Get calculated stat (base + all modifiers)
var effective_health = runtime_stats.get_effective_stat("health")
var effective_attack = runtime_stats.get_effective_stat("attack")

print("Attack: ", effective_attack)  # e.g., 22.5 with buffs
```

---

## 🔧 Working with Modifiers

### Modifier Types

There are **three types** of modifiers, applied in this order:

1. **FLAT** - Adds a fixed value
2. **ADDITIVE** - Adds percentage of base
3. **MULTIPLICATIVE** - Multiplies the total

#### Example Calculation

```gdscript
# Base attack: 10
var runtime = PPRuntimeStats.new({"attack": 10.0})

# Add modifiers
var flat_mod = PPStatModifier.create_flat("attack", 5.0, "weapon")
var percent_mod = PPStatModifier.create_percent("attack", 50.0, "buff")
var multi_mod = PPStatModifier.create_multiplier("attack", 1.2, "rage")

runtime.add_modifier(flat_mod)
runtime.add_modifier(percent_mod)
runtime.add_modifier(multi_mod)

# Calculation:
# 1. FLAT: 10 + 5 = 15
# 2. ADDITIVE: 15 + (10 * 0.5) = 20
# 3. MULTIPLICATIVE: 20 * 1.2 = 24
var final_attack = runtime.get_effective_stat("attack")
print(final_attack)  # Output: 24.0
```

### Adding Modifiers

```gdscript
# Temporary buff (60 seconds)
var strength_buff = PPStatModifier.create_percent("attack", 50.0, "potion", 60.0)
runtime_stats.add_modifier(strength_buff)

# Permanent equipment bonus
var sword_bonus = PPStatModifier.create_flat("attack", 10.0, "iron_sword")
runtime_stats.add_modifier(sword_bonus)

# Debuff (poison reducing defense)
var poison = PPStatModifier.create_percent("defense", -30.0, "poison", 10.0)
runtime_stats.add_modifier(poison)
```

> ⚠️ **Note:** Automatic duration removal is currently commented out in the code. You'll need to manually remove expired modifiers or implement your own timer system.

### Removing Modifiers

```gdscript
# Remove specific modifier
runtime_stats.remove_modifier(strength_buff)

# Remove all modifiers from a source (e.g., when unequipping)
runtime_stats.remove_modifiers_by_source("iron_sword")

# Clear all modifiers
runtime_stats.clear_all_modifiers()
```

### Querying Modifiers

```gdscript
# Get all modifiers affecting a specific stat
var attack_mods = runtime_stats.get_modifiers_for_stat("attack")

for mod in attack_mods:
    print("Modifier: ", mod.source, " = ", mod.value)
```

---

## 💾 Serialization (Save/Load)

### Saving Runtime Stats

```gdscript
func save_player_data() -> Dictionary:
    return {
        "runtime_stats": runtime_stats.to_dict(),
        "position": position,
        "inventory": inventory.to_dict()
    }

# Save to file
var save_data = save_player_data()
var file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
file.store_var(save_data)
file.close()
```

### Loading Runtime Stats

```gdscript
func load_player_data() -> void:
    var file = FileAccess.open("user://savegame.dat", FileAccess.READ)
    var save_data = file.get_var()
    file.close()
    
    # Restore runtime stats
    runtime_stats = PPRuntimeStats.from_dict(save_data["runtime_stats"])
    position = save_data["position"]
```

> 💡 The system serializes both base stats and all active modifiers, so buffs persist across save/load!

---

## 🎨 Signals

The system emits signals for reactive programming:

```gdscript
# Connect to signals
runtime_stats.stats_changed.connect(_on_stat_changed)
runtime_stats.modifier_added.connect(_on_modifier_added)
runtime_stats.modifier_removed.connect(_on_modifier_removed)

func _on_stat_changed(stat_name: String, old_value: Variant, new_value: Variant) -> void:
    print("%s changed: %s → %s" % [stat_name, old_value, new_value])
    
    # Update UI
    if stat_name == "health":
        health_bar.value = new_value

func _on_modifier_added(modifier: PPStatModifier) -> void:
    print("Added modifier: ", modifier.source)
    
    # Show buff icon
    if modifier.tag == "buff":
        buff_ui.show_buff(modifier)

func _on_modifier_removed(modifier: PPStatModifier) -> void:
    print("Removed modifier: ", modifier.source)
    
    # Hide buff icon
    buff_ui.hide_buff(modifier)
```

> ⚠️ **Current Limitation:** The `stats_changed` signal is not automatically emitted when base stats change. You need to emit it manually if needed.

---

## ⚡ Performance Tips

### Cached Calculations

The system uses automatic caching for performance:

```gdscript
# First call: calculates all stats
var attack1 = runtime_stats.get_effective_stat("attack")

# Second call: returns cached value (fast!)
var attack2 = runtime_stats.get_effective_stat("attack")

# After adding modifier: cache invalidated, recalculates on next get
runtime_stats.add_modifier(some_modifier)
var attack3 = runtime_stats.get_effective_stat("attack")  # Recalculates
```

### Batch Modifications

```gdscript
# ❌ Inefficient: recalculates multiple times
for mod in modifiers:
    runtime_stats.add_modifier(mod)
    var attack = runtime_stats.get_effective_stat("attack")  # Recalc each time

# ✅ Efficient: add all, then get once
for mod in modifiers:
    runtime_stats.add_modifier(mod)
var attack = runtime_stats.get_effective_stat("attack")  # Recalc once
```

---

## 🐛 Common Pitfalls

### Pitfall 1: Modifying Base Stats Directly

```gdscript
# ❌ Wrong: cache not invalidated
runtime_stats.base_stats_data["health"] = 200.0

# ✅ Correct: invalidate cache
runtime_stats.base_stats_data["health"] = 200.0
runtime_stats._cache_dirty = true
```

### Pitfall 2: Duration Not Auto-Removing

```gdscript
# ⚠️ Duration is set but not automatically handled
var buff = PPStatModifier.create_percent("attack", 50.0, "buff", 60.0)
runtime_stats.add_modifier(buff)
# You need to manually remove it after 60 seconds!

# ✅ Implement your own timer
await get_tree().create_timer(buff.duration).timeout
runtime_stats.remove_modifier(buff)
```

### Pitfall 3: Case-Sensitive Stat Names

```gdscript
# ❌ Wrong: uppercase
runtime_stats.get_effective_stat("Health")  # Returns 0

# ✅ Correct: lowercase
runtime_stats.get_effective_stat("health")  # Returns actual value
```

---

## 🔗 API Reference

For detailed API documentation:

- [PPRuntimeStats API](../api/PPRuntimeStats.md)
- [PPStatModifier API](../api/PPStatModifier.md)

## 🎓 See Also

- [PPCombatCalculator](../utilities/combat-calculator.md) - Use runtime stats for damage
- [Inventory System](inventory.md) - Items that modify stats
- [Getting Started](../getting-started/getting-started.md) - Basic tutorial
