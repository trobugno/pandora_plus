# Migration from v0.2.0 to v0.3.0

This guide will help you upgrade your project from **Pandora+ v0.2.0-alpha** to **v0.3.0-beta**.

## 📊 Migration Overview

| Aspect | Effort | Breaking Changes |
|--------|--------|------------------|
| **Core APIs** | 🟡 Medium | Some renaming |
| **Stats System** | 🟢 Low | Architecture improved |
| **Inventory** | 🟢 Low | New features, backward compatible |
| **Recipes** | 🟢 Low | Minor improvements |
| **Utilities** | 🟡 Medium | Renamed and reorganized |

**Estimated migration time:** 30-60 minutes for a typical project

---

## 🎯 What's New in v0.3.0

### Major Features
- ✨ **Runtime Stats System** - Dynamic stat calculation with modifiers
- ✨ **Recipe System** - Craft or create new item combining two or more
- ✨ **Advanced Status Effects** - Coming soon (foundation in place)
- ✨ **Improved Inventory** - Better performance and features
- ✨ **Enhanced Testing** - Complete GDUnit4 test suite

### Improvements
- 🔧 Better Pandora integration (Dictionary-based)
- 🔧 Improved CombatUtils
- 🔧 Improved serialization
- 🔧 Better documentation

### Breaking Changes
- ⚠️ Utility classes renamed with `PP` prefix
- ⚠️ Some method signatures changed
- ⚠️ Stats system now uses Dictionary for Pandora compatibility

---

## 🚨 Breaking Changes

### 1. Combat Utilities

Combat-related calculations renamed to new `PPCombatCalculator` singleton:

**Before (v0.2.0):**
```gdscript
var damage = PPStatsUtils.calculate_damage(attacker, defender)
```

**After (v0.3.0):**
```gdscript
# For combat calculations
var damage = PPCombatCalculator.calculate_physical_damage(attacker_stats, defender_stats)

```

---

### 2. Runtime Stats Introduction

New `PPRuntimeStats` system for dynamic stat calculation:

**Before (v0.2.0):**
```gdscript
# Direct PPStats usage
var stats = PPStats.new()
stats.health = 100
stats.attack = 15
```

**After (v0.3.0):**
```gdscript
# Use PPRuntimeStats with base stats as Dictionary
var base_stats = {
    "health": 100.0,
    "attack": 15.0,
    "defense": 8.0
}
var runtime_stats = PPRuntimeStats.new(base_stats)

# Get effective stat (with modifiers)
var effective_attack = runtime_stats.get_effective_stat("attack")
```

**Migration:** If you need modifiers, use `PPRuntimeStats`. For static stats, continue using `PPStats` in Pandora.

---

### 3. Inventory API Updates

**Before (v0.2.0):**
```gdscript
# Old inventory (if custom implementation existed)
var inventory = CustomInventory.new()
inventory.add_item("item_id", 5)
```

**After (v0.3.0):**
```gdscript
# New PPInventory
var inventory = PPInventory.new(20)
inventory.max_weight = 50.0

# Add using Pandora entity
var item = Pandora.get_entity("ITEM_ID") as PPItemEntity
inventory.add_item(item, 5)
```

**Note:** If you weren't using a custom inventory in v0.2.0, this is new functionality.

---

### 4. Recipe System Introduction

New `PPRecipe` system and `PPRecipeUtils` for helping you crafting new items:

```gdscript
# Constructor with all parameters
var recipe = PPRecipe.new(
    [ingredient1, ingredient2],  # ingredients
    result,                      # PandoraReference to result
    1,                           # result quantity
    "CRAFTING"                   # recipe type
)
```

---

## 🔄 Step-by-Step Migration

### Step 1: Backup Your Project

```bash
# Create backup
cp -r your_project your_project_backup

# Or use Git
git commit -am "Backup before Pandora+ v0.3.0 migration"
git tag pre-pandora-plus-0.3.0
```

---

### Step 2: Update Dependencies

1. **Update Pandora** to version **1.0-alpha9** or higher
   - Download from [Pandora Releases](https://github.com/bitbrain/pandora/releases)
   - Replace `addons/pandora/` folder
   - Restart Godot

2. **Update Pandora+** to version **0.3.0-beta**
   - Download from [Pandora+ Releases](https://github.com/trobugno/pandora_plus/releases)
   - Replace `addons/pandora_plus/` folder
   - Restart Godot

---

### Step 3: Update Autoload References

Check `Project → Project Settings → Autoload`:

**New autoloads in v0.3.0:**
- ✅ `PPCombatCalculator` (new)
- ✅ `PPRecipeUtils` (renamed from RecipeUtils)
- ✅ `PPInventoryUtils` (new)

These should be registered automatically when you enable the plugin.

---

### Step 4: Update Your Code

Run these find-and-replace operations across your project:

#### Global Replacements

| Find | Replace | Notes |
|------|---------|-------|
| `PPStatsUtils.calculate_physical_damage` | `PPCombatCalculator.calculate_physical_damage` | Utility renamed |

#### Example: Update Combat Code

**Before:**
```gdscript
extends Enemy

func attack_player(player):
    var damage = PPStatsUtils.calculate_physical_damage(self.stats, player.stats)
    player.take_damage(damage)
```

**After:**
```gdscript
extends Enemy

func attack_player(player):
    # Use PPCombatCalculator for damage
    var damage = PPCombatCalculator.calculate_physical_damage(
        self.runtime_stats,
        player.runtime_stats
    )
    player.take_damage(damage)
```

---

### Step 5: Migrate to Runtime Stats (Optional)

If you want to use the new modifier system:

**Before:**
```gdscript
extends Player

var stats: PPStats

func _ready():
    stats = PPStats.new()
    stats.health = 100
    stats.attack = 15
```

**After:**
```gdscript
extends Player

var runtime_stats: PPRuntimeStats

func _ready():
    var base_stats = {
        "health": 100.0,
        "attack": 15.0,
        "defense": 8.0
    }
    runtime_stats = PPRuntimeStats.new(base_stats)

func apply_strength_buff():
    # Now you can use modifiers!
    var buff = PPStatModifier.create_percent("attack", 50.0, "potion", 60.0)
    runtime_stats.add_modifier(buff)
```

**Note:** This is optional. You can continue using `PPStats` without `PPRuntimeStats` if you don't need modifiers.

---

### Step 6: Update Inventory Implementation (If Applicable)

If you had a custom inventory:

**Before (custom implementation):**
```gdscript
class_name CustomInventory

var items: Array = []
var max_size: int = 20

func add_item(item_id: String, quantity: int):
    # Your custom logic
    pass
```

**After (use PPInventory):**
```gdscript
extends Node

var inventory: PPInventory

func _ready():
    inventory = PPInventory.new(20)
    
    # Connect signals
    inventory.item_added.connect(_on_item_added)
    inventory.item_removed.connect(_on_item_removed)

func add_item(item_entity: PPItemEntity, quantity: int):
    inventory.add_item(item_entity, quantity)

func _on_item_added(item: PPItemEntity, qty: int, slot: int):
    print("Added: ", item.get_entity_name())
```

---

### Step 7: Update Tests

If you have tests, update them:

**Before:**
```gdscript
func test_damage_calculation():
    var attacker = create_test_stats(10, 5)
    var defender = create_test_stats(8, 3)
    
    var damage = PPStatsUtils.calculate_physical_damage(attacker, defender)
    assert_true(damage > 0)
```

**After:**
```gdscript
func test_damage_calculation():
    var attacker_stats = PPRuntimeStats.new({"attack": 10, "defense": 5})
    var defender_stats = PPRuntimeStats.new({"attack": 8, "defense": 3})
    
    var damage = PPCombatCalculator.calculate_physical_damage(
        attacker_stats,
        defender_stats
    )
    assert_true(damage > 0)
```

---

## 🧪 Testing Your Migration

After migration, test these critical features:

### Checklist

- [ ] **Stats System**
  - [ ] Character stats load correctly
  - [ ] Damage calculation works
  - [ ] Modifiers apply correctly (if using PPRuntimeStats)

- [ ] **Inventory**
  - [ ] Add items to inventory
  - [ ] Remove items from inventory
  - [ ] Weight/slot limits work

- [ ] **Crafting**
  - [ ] Recipes can be checked with `PPRecipeUtils.can_craft()`
  - [ ] Crafting consumes ingredients
  - [ ] Crafting produces results

- [ ] **Combat**
  - [ ] Damage calculations are correct
  - [ ] Critical hits work (if implemented)
  - [ ] Buffs/debuffs apply

---

## 📋 Migration Checklist

Use this checklist to track your migration progress:

- [ ] ✅ Backup created
- [ ] ✅ Dependencies updated (Pandora 1.0-alpha9+)
- [ ] ✅ Pandora+ v0.3.0 installed
- [ ] ✅ Autoloads verified
- [ ] ✅ Code updated (find-and-replace)
- [ ] ✅ Stats system migrated
- [ ] ✅ Inventory updated (if applicable)
- [ ] ✅ Tests updated and passing
- [ ] ✅ Manual testing completed
- [ ] ✅ No errors in Output panel
- [ ] ✅ Game plays correctly

---

## 🎉 Migration Complete!

**Congratulations!** You've successfully migrated to Pandora+ v0.3.0.

### What's Next?

Explore new features:

- 🔧 [Runtime Stats with Modifiers](../core-systems/runtime-stats.md)
- ⚔️ [New Combat Calculator](../utilities/combat-calculator.md)
- 🎒 [Improved Inventory](../core-systems/inventory-system.md)

---

*Last updated: December 2025 for Pandora+ v0.3.0-beta*