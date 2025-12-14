# PPCombatCalculator

**Extends:** `Node`

Singleton utility for calculating combat damage with support for defense reduction, critical hits, and configurable parameters.

---

## Description

`PPCombatCalculator` is the core calculation engine for the combat system. It handles physical damage calculations with armor reduction using diminishing returns, critical hit rolling with rate caps, and critical damage multipliers. All combat parameters are configurable through Project Settings and automatically update when settings change.

This class integrates with `PPRuntimeStats` to read combat statistics and applies mathematical formulas to determine final damage values.

---

## Setup

Add to autoload in Project Settings:

```gdscript
# Project -> Project Settings -> Autoload
# Name: CombatCalculator
# Path: res://addons/pandora_plus/extensions/combat/PPCombatCalculator.gd
```

---

## Properties

###### `DEFENSE_REDUCTION_FACTOR: float`

Factor used in defense calculations. Controls how much defense reduces incoming damage.

**Configured via:** `PandoraPlusSettings.COMBAT_SETTING_DEFENSE_REDUCTION_FACTOR`

---

###### `ARMOR_DIMINISHING_RETURNS: float`

Point at which armor provides 50% damage reduction. Higher values make armor less effective per point.

**Configured via:** `PandoraPlusSettings.COMBAT_SETTING_ARMOR_DIMINISHING_RETURNS`

**Example values:**
- `100`: 100 armor = 50% reduction, 200 armor = 66.6% reduction
- `200`: 200 armor = 50% reduction, 400 armor = 66.6% reduction

---

###### `CRIT_DAMAGE_BASE: float`

Base critical damage multiplier as percentage (e.g., `150.0` = 1.5x damage).

**Configured via:** `PandoraPlusSettings.COMBAT_SETTING_CRIT_DAMAGE_BASE`

**Default:** `150.0` (150% = 1.5x)

---

###### `CRIT_RATE_CAP: float`

Maximum critical hit rate as percentage (e.g., `75.0` = 75% max crit chance).

**Configured via:** `PandoraPlusSettings.COMBAT_SETTING_CRIT_RATE_CAP`

**Default:** `75.0` (75% cap)

---

## Methods

###### `calculate_physical_damage(attacker_stats: PPRuntimeStats, attacked_stats: PPRuntimeStats) -> float`

Calculates base physical damage before critical hits.

**Parameters:**
- `attacker_stats`: Attacker's runtime stats
- `attacked_stats`: Defender's runtime stats

**Returns:** Final damage after armor reduction (minimum 1)

**Formula:**
```
damage = attack * (1.0 - armor_reduction)
armor_reduction = defense / (defense + ARMOR_DIMINISHING_RETURNS)
```

**Example:**
```gdscript
var player_stats = player.get_runtime_stats()
var enemy_stats = enemy.get_runtime_stats()

var damage = CombatCalculator.calculate_physical_damage(player_stats, enemy_stats)
print("Base damage: %.1f" % damage)

# Example with stats:
# Attack: 100, Defense: 50, ARMOR_DIMINISHING_RETURNS: 100
# armor_reduction = 50 / (50 + 100) = 0.333 (33.3%)
# damage = 100 * (1.0 - 0.333) = 66.7
```

---

###### `roll_critical_hit(attacker_stats: PPRuntimeStats) -> bool`

Rolls for critical hit based on attacker's crit rate.

**Parameters:**
- `attacker_stats`: Attacker's runtime stats

**Returns:** `true` if critical hit occurs

**Behavior:**
- Reads `"crit_rate"` stat from attacker
- Caps rate at `CRIT_RATE_CAP`
- Rolls random number 0-100 and compares with crit rate

**Example:**
```gdscript
var attacker_stats = player.get_runtime_stats()

if CombatCalculator.roll_critical_hit(attacker_stats):
    print("CRITICAL HIT!")
    play_crit_animation()
else:
    print("Normal hit")

# If crit_rate = 25.0 (25%)
# Random roll: 0-100
# If roll <= 25.0 → Critical Hit!
```

---

###### `calculate_critical_damage(base_damage: float, attacker_stats: PPRuntimeStats) -> float`

Calculates damage with critical multiplier applied.

**Parameters:**
- `base_damage`: Base damage before crit
- `attacker_stats`: Attacker's runtime stats

**Returns:** Damage with critical multiplier

**Behavior:**
- Reads `"crit_damage"` stat from attacker
- Falls back to `CRIT_DAMAGE_BASE` if stat <= 0
- Applies multiplier as percentage

**Formula:**
```
crit_damage = base_damage * (crit_damage_multiplier / 100.0)
```

**Example:**
```gdscript
var base_damage = 50.0
var attacker_stats = player.get_runtime_stats()

var crit_damage = CombatCalculator.calculate_critical_damage(base_damage, attacker_stats)
print("Critical damage: %.1f" % crit_damage)

# If crit_damage stat = 200.0 (200%)
# crit_damage = 50.0 * (200.0 / 100.0) = 100.0

# If crit_damage stat = 0 (uses CRIT_DAMAGE_BASE = 150)
# crit_damage = 50.0 * (150.0 / 100.0) = 75.0
```

---

###### `calculate_damage(attacker_stats: PPRuntimeStats, attacked_stats: PPRuntimeStats) -> float`

Complete damage calculation including base damage and critical hits.

**Parameters:**
- `attacker_stats`: Attacker's runtime stats
- `attacked_stats`: Defender's runtime stats

**Returns:** Final damage value

**Process:**
1. Calculate base physical damage
2. Roll for critical hit
3. Apply critical multiplier if crit occurred
4. Return final damage

**Example:**
```gdscript
var attacker = player.get_runtime_stats()
var defender = enemy.get_runtime_stats()

var damage = CombatCalculator.calculate_damage(attacker, defender)
enemy.take_damage(damage)

print("Dealt %.1f damage" % damage)
```

---

## Usage Example

### Example: Basic Combat System

```gdscript
class_name CombatManager
extends Node

func process_attack(attacker: Node, defender: Node):
    var attacker_stats = attacker.get_runtime_stats()
    var defender_stats = defender.get_runtime_stats()
    
    # Calculate damage
    var damage = CombatCalculator.calculate_damage(attacker_stats, defender_stats)
    
    # Check if was critical
    var base_damage = CombatCalculator.calculate_physical_damage(attacker_stats, defender_stats)
    var was_crit = damage > base_damage
    
    # Apply damage
    defender.take_damage(damage)
    
    # Show damage number
    if was_crit:
        show_damage_number(damage, true, defender.global_position)
        play_crit_sound()
    else:
        show_damage_number(damage, false, defender.global_position)

func show_damage_number(damage: float, is_crit: bool, position: Vector3):
    var label = preload("res://ui/damage_number.tscn").instantiate()
    label.text = str(int(damage))
    label.modulate = Color.RED if is_crit else Color.WHITE
    label.scale = Vector3(1.5, 1.5, 1.5) if is_crit else Vector3.ONE
    label.global_position = position
    get_tree().current_scene.add_child(label)
```
---

## Armor Diminishing Returns Explained

### Formula

```
damage_reduction = defense / (defense + ARMOR_DIMINISHING_RETURNS)
```

### Effectiveness Curve

With `ARMOR_DIMINISHING_RETURNS = 100`:

| Defense | Reduction | Effective HP Multiplier |
|---------|-----------|------------------------|
| 0 | 0% | 1.0x |
| 50 | 33.3% | 1.5x |
| 100 | 50% | 2.0x |
| 200 | 66.6% | 3.0x |
| 300 | 75% | 4.0x |
| 400 | 80% | 5.0x |

**Key Points:**
- Never reaches 100% reduction
- Each point of armor has decreasing value
- Balanced for both low and high armor values

### Tuning ARMOR_DIMINISHING_RETURNS

```gdscript
# Low value (50): Armor very effective
# 50 defense = 50% reduction
# High armor builds are very strong

# Medium value (100): Balanced
# 100 defense = 50% reduction
# Good middle ground

# High value (200): Armor less effective
# 200 defense = 50% reduction
# High armor builds less dominant
```

---

## Critical Hit System

### Critical Rate

- **Base stat:** `"crit_rate"` (percentage 0-100)
- **Hard cap:** `CRIT_RATE_CAP` (default: 75%)
- **Roll:** Random 0-100 compared with crit rate

### Critical Damage

- **Base stat:** `"crit_damage"` (percentage multiplier)
- **Fallback:** `CRIT_DAMAGE_BASE` if stat <= 0
- **Common values:**
  - `150%` = 1.5x damage (modest)
  - `200%` = 2.0x damage (standard)
  - `300%` = 3.0x damage (high crit builds)

### Example Builds

```gdscript
# Balanced Fighter
attack: 100
crit_rate: 25%
crit_damage: 150%
# Average DPS: 106.25

# Crit Specialist
attack: 80
crit_rate: 50%
crit_damage: 250%
# Average DPS: 100 (more variance)

# Tank
attack: 60
defense: 200
crit_rate: 5%
# Survives longer, consistent damage
```

---

## Configuration

### Project Settings Setup

```gdscript
# In plugin initialization or project settings
ProjectSettings.set_setting(
    PandoraPlusSettings.COMBAT_SETTING_ARMOR_DIMINISHING_RETURNS,
    100.0
)

ProjectSettings.set_setting(
    PandoraPlusSettings.COMBAT_SETTING_CRIT_RATE_CAP,
    75.0
)

ProjectSettings.set_setting(
    PandoraPlusSettings.COMBAT_SETTING_CRIT_DAMAGE_BASE,
    150.0
)

ProjectSettings.set_setting(
    PandoraPlusSettings.COMBAT_SETTING_DEFENSE_REDUCTION_FACTOR,
    1.0
)

# Save settings
ProjectSettings.save()
```

### Runtime Configuration

Settings automatically reload when changed:

```gdscript
# Settings changed in editor or at runtime
ProjectSettings.set_setting(
    PandoraPlusSettings.COMBAT_SETTING_CRIT_RATE_CAP,
    90.0  # Increase cap to 90%
)

# CombatCalculator automatically updates via signal
# No need to manually reload
```

---

## Best Practices

### ✅ Use calculate_damage() for Complete Calculation

```gdscript
# ✅ Good: all-in-one calculation
var damage = CombatCalculator.calculate_damage(attacker_stats, defender_stats)
enemy.take_damage(damage)

# ❌ Bad: manual calculation (error-prone)
var base = CombatCalculator.calculate_physical_damage(attacker_stats, defender_stats)
var is_crit = randf() < 0.25  # Wrong: doesn't use crit_rate stat
var damage = base * 1.5  # Wrong: doesn't use crit_damage stat
```

---

### ✅ Cache Stats for Multiple Calculations

```gdscript
# ✅ Good: cache stats
var attacker_stats = attacker.get_runtime_stats()
var defender_stats = defender.get_runtime_stats()

for i in 10:
    var damage = CombatCalculator.calculate_damage(attacker_stats, defender_stats)
    process_hit(damage)

# ❌ Bad: repeated calls
for i in 10:
    var damage = CombatCalculator.calculate_damage(
        attacker.get_runtime_stats(),  # Called 10 times!
        defender.get_runtime_stats()   # Called 10 times!
    )
```

---

### ✅ Provide Feedback for Critical Hits

```gdscript
# ✅ Good: distinct feedback
var base = CombatCalculator.calculate_physical_damage(attacker_stats, defender_stats)
var final = CombatCalculator.calculate_damage(attacker_stats, defender_stats)

if final > base:  # Was critical
    show_damage(final, Color.ORANGE, 2.0)
    play_sound("crit_hit")
else:
    show_damage(final, Color.WHITE, 1.0)
    play_sound("normal_hit")
```

---

## Common Patterns

### Pattern 1: Damage Range Display

```gdscript
func get_damage_range(attacker: PPRuntimeStats, defender: PPRuntimeStats) -> Dictionary:
    var min_dmg = CombatCalculator.calculate_physical_damage(attacker, defender)
    var max_dmg = CombatCalculator.calculate_critical_damage(min_dmg, attacker)
    var crit_rate = attacker.get_effective_stat("crit_rate")
    var avg_dmg = min_dmg * (1.0 - crit_rate/100.0) + max_dmg * (crit_rate/100.0)
    
    return {
        "min": min_dmg,
        "max": max_dmg,
        "average": avg_dmg,
        "crit_rate": crit_rate
    }
```

---

### Pattern 2: Damage Simulation

```gdscript
func simulate_combat(attacker: PPRuntimeStats, defender: PPRuntimeStats, iterations: int = 1000) -> Dictionary:
    var total_damage = 0.0
    var crit_count = 0
    
    for i in iterations:
        var damage = CombatCalculator.calculate_damage(attacker, defender)
        var base = CombatCalculator.calculate_physical_damage(attacker, defender)
        
        total_damage += damage
        if damage > base:
            crit_count += 1
    
    return {
        "average_damage": total_damage / iterations,
        "crit_rate": (crit_count / float(iterations)) * 100.0,
        "total_iterations": iterations
    }
```

---

### Pattern 3: Defense Value Calculator

```gdscript
func calculate_defense_value(defense: float) -> Dictionary:
    var reduction = defense / (defense + CombatCalculator.ARMOR_DIMINISHING_RETURNS)
    var effective_hp_mult = 1.0 / (1.0 - reduction)
    var points_for_next_percent = calculate_points_for_percent(defense, reduction + 0.01)
    
    return {
        "defense": defense,
        "reduction_percent": reduction * 100,
        "effective_hp_multiplier": effective_hp_mult,
        "points_for_next_1_percent": points_for_next_percent
    }

func calculate_points_for_percent(current_def: float, target_reduction: float) -> float:
    # Solve: target_reduction = defense / (defense + K)
    # defense = target_reduction * K / (1 - target_reduction)
    var K = CombatCalculator.ARMOR_DIMINISHING_RETURNS
    var required_defense = target_reduction * K / (1.0 - target_reduction)
    return required_defense - current_def
```

---

## Integration with Stats System

### Required Stats

The calculator expects these stats to be available:

```gdscript
# Attacker stats
"attack": float        # Base damage output
"crit_rate": float     # Critical hit chance (0-100)
"crit_damage": float   # Critical damage multiplier (percentage)

# Defender stats
"defense": float       # Damage reduction stat
```

### Setup Example

```gdscript
# Create character with combat stats
var stats = PPRuntimeStats.new()

# Attacker setup
stats.set_base_stat("attack", 100)
stats.set_base_stat("crit_rate", 25)
stats.set_base_stat("crit_damage", 200)

# Defender setup
stats.set_base_stat("defense", 50)
```

---

## Performance Considerations

### Benchmarks (Approximate)

| Operation | Time | Notes |
|-----------|------|-------|
| calculate_physical_damage() | ~0.01ms | Simple math |
| roll_critical_hit() | ~0.005ms | Single random |
| calculate_critical_damage() | ~0.008ms | Simple multiplication |
| calculate_damage() | ~0.025ms | All combined |

### Optimization Tips

1. **Cache PPRuntimeStats**: Don't recreate stats objects per calculation
2. **Batch Damage**: Calculate once, apply to multiple targets if needed
3. **Pre-roll Crits**: For UI predictions, calculate both outcomes
4. **Pool Damage Numbers**: Reuse damage number nodes

---

## Troubleshooting

### Issue: Damage Always 1

**Cause:** Armor reduction >= 100% (impossible but check for bugs)  
**Solution:** Verify `ARMOR_DIMINISHING_RETURNS` is set correctly

---

### Issue: No Critical Hits

**Causes:**
1. `crit_rate` stat not set or 0
2. `CRIT_RATE_CAP` set to 0

**Solution:** Check stat values and project settings

---

### Issue: Critical Damage Same as Normal

**Cause:** `crit_damage` stat <= 0 AND `CRIT_DAMAGE_BASE` not set  
**Solution:** Set either stat or base value

---

## Notes

### Minimum Damage

`calculate_physical_damage()` always returns minimum 1 damage:

```gdscript
return max(1, final_damage)
```

This prevents armor from completely negating damage.

---

### Settings Auto-Update

The calculator automatically reloads settings when they change:

```gdscript
ProjectSettings.settings_changed.connect(_on_settings_changed)
```

No manual refresh needed after configuration changes.

---

### Unused Property

`DEFENSE_REDUCTION_FACTOR` is loaded but not currently used in calculations. It may be reserved for future features or different damage types.

---

## See Also

- [PPRuntimeStats](../core-systems/runtime-stats.md) - Runtime stats system
- [PPStatusEffect](../properties/status-effect.md) - Status effects

---

*API Reference generated from source code*