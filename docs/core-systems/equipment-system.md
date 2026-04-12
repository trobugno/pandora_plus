# 💎 Equipment System

Complete guide to the Pandora+ equipment management system, including equippable items, stat bonuses, and character progression.

**Availability:** 💎 Premium

---

## Overview

The Pandora+ Equipment System provides a comprehensive solution for managing character equipment, including:

- **Equipment slots** for different body parts and accessories
- **Stat bonuses** that automatically apply when equipped
- **Inventory integration** with seamless equip/unequip operations
- **Runtime stat modifiers** that update character stats dynamically

**Core Components:**
- **PPEquipmentEntity** - Equipment items with slot and stat properties
- **PPEquipmentSetEntity** - Equipment set definitions with tiered bonuses
- **PPEquipmentUtils** - Utility singleton for equip/unequip operations and set bonus management
- **PPInventory** - Manages both regular items and equipment slots
- **PPRuntimeStats** - Applies and removes equipment stat modifiers

---

## Quick Start

### Creating Equipment Items

Equipment items are created in Pandora's entity editor:

1. Create a new entity with category "Equipment"
2. Add properties:
   - `equipment_slot` (String): Slot type (e.g., "WEAPON", "CHEST")
   - `stats_property` (PPStats): Stat bonuses this equipment provides
3. Inherit all item properties from PPItemEntity (name, description, texture, value, weight, rarity)

### Basic Equipment Management

```gdscript
# Get equipment item
var iron_sword = Pandora.get_entity("IRON_SWORD") as PPEquipmentEntity

# Check if item can be equipped
if PPEquipmentUtils.can_equip(iron_sword):
    print("Equipment slot: ", iron_sword.get_equipment_slot())

    var stats = iron_sword.get_equipment_stats()
    if stats:
        print("Attack bonus: +", stats._attack)

# Equip item
if PPEquipmentUtils.equip_item(player.inventory, iron_sword, player.runtime_stats):
    print("Equipped ", iron_sword.get_item_name())
    print("New attack: ", player.runtime_stats.get_effective_stat("attack"))

# Unequip item
if PPEquipmentUtils.unequip_item(player.inventory, "WEAPON", player.runtime_stats):
    print("Unequipped weapon")
```

---

## Equipment Slots

The system supports seven equipment slots:

```gdscript
enum EquipmentSlot {
    HEAD,        # Helmets, hats
    CHEST,       # Armor, shirts
    LEGS,        # Pants, boots
    WEAPON,      # Swords, staves
    SHIELD,      # Shields, off-hand items
    ACCESSORY_1, # Rings, amulets
    ACCESSORY_2  # Additional accessories
}
```

### Equipment Slot Properties

| Slot | Type | Typical Items |
|------|------|---------------|
| `HEAD` | String: "HEAD" | Helmets, Hats, Crowns |
| `CHEST` | String: "CHEST" | Armor, Robes, Shirts |
| `LEGS` | String: "LEGS" | Pants, Boots, Greaves |
| `WEAPON` | String: "WEAPON" | Swords, Axes, Staves |
| `SHIELD` | String: "SHIELD" | Shields, Bucklers |
| `ACCESSORY_1` | String: "ACCESSORY_1" | Rings, Amulets |
| `ACCESSORY_2` | String: "ACCESSORY_2" | Belts, Trinkets |

### Accessing Equipment Slots

```gdscript
# Get slot as string
var slot_name = equipment.get_equipment_slot()  # "WEAPON"

# Get slot as enum
var slot_enum = equipment.get_equipment_slot_enum()  # EquipmentSlot.WEAPON

# Check specific slot type
if equipment.get_equipment_slot() == "WEAPON":
    print("This is a weapon")
```

---

## Stat Bonuses

Equipment can provide stat bonuses through the `stats_property` field.

### Supported Stats

Equipment can boost any stat from PPStats:

| Stat | Property | Description |
|------|----------|-------------|
| Health | `_health` | Max health increase |
| Mana | `_mana` | Max mana increase |
| Attack | `_attack` | Physical damage increase |
| Defense | `_defense` | Damage reduction increase |
| Attack Speed | `_att_speed` | Attack speed multiplier |
| Movement Speed | `_mov_speed` | Movement speed increase |
| Critical Rate | `_crit_rate` | Critical hit chance (%) |
| Critical Damage | `_crit_damage` | Critical damage multiplier (%) |

### Creating Equipment with Stats

```gdscript
# In Pandora Editor:
# 1. Create PPStats property for equipment
# 2. Set stat bonuses:
#    - Health: 50
#    - Attack: 10
#    - Defense: 5

# In code, stats are accessed:
var iron_helmet = Pandora.get_entity("IRON_HELMET") as PPEquipmentEntity
var stats = iron_helmet.get_equipment_stats()

if stats:
    print("Health bonus: +%d" % stats._health)    # +50
    print("Attack bonus: +%d" % stats._attack)    # +10
    print("Defense bonus: +%d" % stats._defense)  # +5
```

### How Stat Bonuses Work

When equipment is equipped:

1. **Stat modifiers are created** - Each non-zero stat becomes a FLAT modifier
2. **Modifiers are added to runtime stats** - Applied to PPRuntimeStats
3. **Stats recalculate automatically** - Character stats update immediately
4. **Modifiers are tracked by source** - Named `"equipment_{slot_name}"`

When equipment is unequipped:

1. **Modifiers are removed by source** - All modifiers from that slot are cleared
2. **Stats recalculate** - Character stats return to base + other equipment

```gdscript
# Equipment creates flat modifiers automatically
var helmet_stats = PPStats.new()
helmet_stats._health = 50
helmet_stats._defense = 5

# When equipped, creates these modifiers:
# - PPStatModifier(stat="health", value=50, source="equipment_HEAD")
# - PPStatModifier(stat="defense", value=5, source="equipment_HEAD")

# When unequipped, removes all modifiers with source="equipment_HEAD"
```

---

## PPEquipmentUtils API

The equipment utility singleton provides all equipment management functions.

### Setup

Add to autoload in Project Settings:

```gdscript
# Project -> Project Settings -> Autoload
# Name: EquipmentUtils
# Path: res://addons/pandora_plus/autoloads/PPEquipmentUtils.gd
```

### Signals

```gdscript
signal equipment_equipped(character_stats: PPRuntimeStats, slot_name: String, item: PPEquipmentEntity)
signal equipment_unequipped(character_stats: PPRuntimeStats, slot_name: String, item: PPEquipmentEntity)
signal set_bonus_activated(set_entity: PPEquipmentSetEntity, tier: int, bonuses: Dictionary)
signal set_bonus_deactivated(set_entity: PPEquipmentSetEntity)
signal set_bonus_changed(set_entity: PPEquipmentSetEntity, old_tier: int, new_tier: int)
```

**Example:**
```gdscript
PPEquipmentUtils.equipment_equipped.connect(_on_equipment_equipped)
PPEquipmentUtils.equipment_unequipped.connect(_on_equipment_unequipped)

func _on_equipment_equipped(stats: PPRuntimeStats, slot: String, item: PPEquipmentEntity):
    print("Equipped %s in %s slot" % [item.get_item_name(), slot])
    update_character_appearance(slot, item)

func _on_equipment_unequipped(stats: PPRuntimeStats, slot: String, item: PPEquipmentEntity):
    print("Unequipped %s" % item.get_item_name())
    clear_character_appearance(slot)
```

### Core Methods

#### can_equip()

Checks if an item can be equipped.

```gdscript
func can_equip(item: PandoraEntity) -> bool
```

**Returns:** `true` if item is PPEquipmentEntity

**Example:**
```gdscript
if PPEquipmentUtils.can_equip(item):
    print("This item can be equipped")
else:
    print("This is not equipment")
```

---

#### equip_item()

Equips an item from inventory to equipment slot.

```gdscript
func equip_item(
    inventory: PPInventory,
    item: PPEquipmentEntity,
    character_stats: PPRuntimeStats
) -> bool
```

**Parameters:**
- `inventory`: Player's inventory
- `item`: Equipment to equip
- `character_stats`: Character's runtime stats

**Returns:** `true` if successful

**Behavior:**
- Removes item from inventory
- Unequips current item in slot (if any)
- Adds item to equipment slot
- Applies stat modifiers to character_stats
- Emits `equipment_equipped` signal

**Example:**
```gdscript
var sword = Pandora.get_entity("IRON_SWORD") as PPEquipmentEntity

if PPEquipmentUtils.equip_item(player.inventory, sword, player.runtime_stats):
    print("Equipped sword!")
    print("New attack: ", player.runtime_stats.get_effective_stat("attack"))
else:
    print("Failed to equip (check inventory)")
```

---

#### unequip_item()

Unequips an item from equipment slot.

```gdscript
func unequip_item(
    inventory: PPInventory,
    slot_name: String,
    character_stats: PPRuntimeStats
) -> bool
```

**Parameters:**
- `inventory`: Player's inventory
- `slot_name`: Slot to unequip (e.g., "WEAPON")
- `character_stats`: Character's runtime stats

**Returns:** `true` if successful

**Behavior:**
- Removes stat modifiers from character_stats
- Removes item from equipment slot
- Returns item to inventory
- Emits `equipment_unequipped` signal

**Example:**
```gdscript
if PPEquipmentUtils.unequip_item(player.inventory, "WEAPON", player.runtime_stats):
    print("Unequipped weapon")
else:
    print("No weapon equipped")
```

---

#### unequip_all()

Unequips all equipped items.

```gdscript
func unequip_all(inventory: PPInventory, character_stats: PPRuntimeStats) -> int
```

**Returns:** Number of items unequipped

**Example:**
```gdscript
var count = PPEquipmentUtils.unequip_all(player.inventory, player.runtime_stats)
print("Unequipped %d items" % count)
```

---

#### get_total_equipment_stats()

Gets total stat bonuses from all equipped items.

```gdscript
func get_total_equipment_stats(inventory: PPInventory) -> Dictionary
```

**Returns:** Dictionary with `stat_name -> total_bonus`

**Example:**
```gdscript
var totals = PPEquipmentUtils.get_total_equipment_stats(player.inventory)

print("Total equipment bonuses:")
for stat_name in totals:
    print("  %s: +%d" % [stat_name, totals[stat_name]])

# Output:
#   health: +150
#   attack: +45
#   defense: +30
#   crit_rate: +15
```

---

## Working with Inventory

The equipment system integrates seamlessly with PPInventory.

### Inventory Equipment Signals

```gdscript
signal item_equipped(slot: String, item: PPEquipmentEntity)
signal item_unequipped(slot: String, item: PPEquipmentEntity)
```

### Checking Equipment

```gdscript
# Check if slot has equipment
if player.inventory.has_equipment_in_slot("WEAPON"):
    print("Weapon is equipped")

# Get equipped item
var equipped_weapon = player.inventory.get_equipped_item("WEAPON")
if equipped_weapon:
    var weapon = equipped_weapon.item as PPEquipmentEntity
    print("Equipped: ", weapon.get_item_name())

# Get all equipped items
var all_equipment = player.inventory.get_all_equipped_items()
for slot_name in all_equipment:
    var slot = all_equipment[slot_name]
    if slot:
        print("%s: %s" % [slot_name, slot.item.get_item_name()])
```

### Equipment Slots Dictionary

Equipment is stored in `PPInventory.equipped_items`:

```gdscript
# Structure:
equipped_items = {
    "HEAD": PPInventorySlot or null,
    "CHEST": PPInventorySlot or null,
    "LEGS": PPInventorySlot or null,
    "WEAPON": PPInventorySlot or null,
    "SHIELD": PPInventorySlot or null,
    "ACCESSORY_1": PPInventorySlot or null,
    "ACCESSORY_2": PPInventorySlot or null
}
```

---

## Complete Example: Character Equipment UI

```gdscript
extends Control

@onready var equipment_slots = {
    "HEAD": $EquipmentPanel/HeadSlot,
    "CHEST": $EquipmentPanel/ChestSlot,
    "LEGS": $EquipmentPanel/LegsSlot,
    "WEAPON": $EquipmentPanel/WeaponSlot,
    "SHIELD": $EquipmentPanel/ShieldSlot,
    "ACCESSORY_1": $EquipmentPanel/Accessory1Slot,
    "ACCESSORY_2": $EquipmentPanel/Accessory2Slot
}

@onready var stat_labels = {
    "health": $StatsPanel/HealthLabel,
    "attack": $StatsPanel/AttackLabel,
    "defense": $StatsPanel/DefenseLabel
}

var player: Node  # Reference to player
var selected_item: PPEquipmentEntity = null

func _ready():
    # Connect signals
    PPEquipmentUtils.equipment_equipped.connect(_on_equipment_changed)
    PPEquipmentUtils.equipment_unequipped.connect(_on_equipment_changed)

    # Connect inventory item clicks
    for slot_ui in equipment_slots.values():
        slot_ui.pressed.connect(_on_equipment_slot_clicked.bind(slot_ui))

    refresh_ui()

func refresh_ui():
    # Update equipment slots
    for slot_name in equipment_slots:
        var slot_ui = equipment_slots[slot_name]

        if player.inventory.has_equipment_in_slot(slot_name):
            var equipped = player.inventory.get_equipped_item(slot_name)
            var item = equipped.item as PPEquipmentEntity
            slot_ui.set_item(item)
        else:
            slot_ui.clear()

    # Update stat display
    update_stats_display()

func update_stats_display():
    var stats = player.runtime_stats

    stat_labels["health"].text = "HP: %d" % stats.get_effective_stat("health")
    stat_labels["attack"].text = "ATK: %d" % stats.get_effective_stat("attack")
    stat_labels["defense"].text = "DEF: %d" % stats.get_effective_stat("defense")

    # Show equipment bonuses
    var equipment_bonuses = PPEquipmentUtils.get_total_equipment_stats(player.inventory)

    if equipment_bonuses.has("health"):
        stat_labels["health"].text += " (+%d)" % equipment_bonuses["health"]
    if equipment_bonuses.has("attack"):
        stat_labels["attack"].text += " (+%d)" % equipment_bonuses["attack"]
    if equipment_bonuses.has("defense"):
        stat_labels["defense"].text += " (+%d)" % equipment_bonuses["defense"]

func _on_equipment_slot_clicked(slot_ui):
    var slot_name = _get_slot_name_from_ui(slot_ui)

    # Unequip if slot has item
    if player.inventory.has_equipment_in_slot(slot_name):
        PPEquipmentUtils.unequip_item(player.inventory, slot_name, player.runtime_stats)

func on_inventory_item_clicked(item: PPEquipmentEntity):
    # Called when player clicks item in inventory
    if PPEquipmentUtils.can_equip(item):
        PPEquipmentUtils.equip_item(player.inventory, item, player.runtime_stats)

func _on_equipment_changed(_stats, _slot, _item):
    refresh_ui()

func _get_slot_name_from_ui(slot_ui) -> String:
    for slot_name in equipment_slots:
        if equipment_slots[slot_name] == slot_ui:
            return slot_name
    return ""
```

---

## Best Practices

### ✅ Always Pass Runtime Stats

```gdscript
# ✅ Good: Pass runtime stats to apply modifiers
PPEquipmentUtils.equip_item(inventory, sword, player.runtime_stats)

# ❌ Bad: Equipment without stat application has no effect
inventory.set_equipped_item("WEAPON", sword)  # Stats don't apply!
```

---

### ✅ Connect to Signals for UI Updates

```gdscript
# ✅ Good: Reactive UI updates
PPEquipmentUtils.equipment_equipped.connect(func(stats, slot, item):
    update_character_model(slot, item)
    refresh_stats_ui()
)

# ❌ Bad: Manual polling
func _process(delta):
    check_if_equipment_changed()  # Inefficient
```

---

### ✅ Use Unequip Before Re-equip

```gdscript
# ✅ Good: equip_item handles this automatically
PPEquipmentUtils.equip_item(inventory, new_sword, stats)
# Old weapon is automatically unequipped

# ⚠️ Manual approach (not needed):
if inventory.has_equipment_in_slot("WEAPON"):
    PPEquipmentUtils.unequip_item(inventory, "WEAPON", stats)
PPEquipmentUtils.equip_item(inventory, new_sword, stats)
```

---

### ✅ Check Inventory Before Equipping

```gdscript
# ✅ Good: Verify item is in inventory
if inventory.has_item(sword):
    PPEquipmentUtils.equip_item(inventory, sword, stats)
else:
    print("Item not in inventory")

# ❌ Bad: Assume item exists
PPEquipmentUtils.equip_item(inventory, sword, stats)  # May fail
```

---

### ✅ Store Equipment References Properly

```gdscript
# ✅ Good: Store entity ID or reference
var equipped_weapon_id: String = "IRON_SWORD"
# Then load when needed:
var weapon = Pandora.get_entity(equipped_weapon_id) as PPEquipmentEntity

# ❌ Bad: Store direct reference (won't serialize)
var equipped_weapon: PPEquipmentEntity = sword  # Lost on save/load
```

---

## Common Patterns

### Pattern 1: Equipment Comparison

```gdscript
func compare_equipment(current: PPEquipmentEntity, new: PPEquipmentEntity) -> Dictionary:
    var comparison = {
        "current_stats": {},
        "new_stats": {},
        "difference": {}
    }

    if current and current.has_stat_bonuses():
        var stats = current.get_equipment_stats()
        comparison["current_stats"] = _stats_to_dict(stats)

    if new and new.has_stat_bonuses():
        var stats = new.get_equipment_stats()
        comparison["new_stats"] = _stats_to_dict(stats)

    # Calculate difference
    for stat_name in comparison["new_stats"]:
        var current_val = comparison["current_stats"].get(stat_name, 0)
        var new_val = comparison["new_stats"][stat_name]
        comparison["difference"][stat_name] = new_val - current_val

    return comparison

func _stats_to_dict(stats: PPStats) -> Dictionary:
    return {
        "health": stats._health,
        "attack": stats._attack,
        "defense": stats._defense,
        # ... other stats
    }

# Usage:
var current_helmet = inventory.get_equipped_item("HEAD").item if inventory.has_equipment_in_slot("HEAD") else null
var new_helmet = Pandora.get_entity("STEEL_HELMET") as PPEquipmentEntity
var comparison = compare_equipment(current_helmet, new_helmet)

print("Attack difference: %+d" % comparison["difference"].get("attack", 0))
```

---

### Pattern 2: Equipment Set Bonuses

Equipment sets are defined in Pandora's entity editor under the "EquipmentSets" category. Set bonuses are automatically managed by PPEquipmentUtils — they activate/deactivate when equipment is equipped or unequipped.

#### Creating Equipment Sets in Pandora Editor

1. Open Pandora Editor
2. Navigate to the "EquipmentSets" category
3. Create a new entity with:
   - `set_name` (String): Display name (e.g., "Knight's Honor")
   - `set_description` (String): Set description
   - `set_pieces` (Array[Reference]): References to PPEquipmentEntity pieces
   - `set_bonuses` (PPSetBonus): Tiered bonuses with pieces required + stat bonuses

#### Set Bonus Tiers

Each set can have multiple bonus tiers. The best applicable tier activates based on equipped piece count:

```gdscript
# Example: Knight's Honor set (3 pieces)
# Tier 1: 2 pieces → +10 defense
# Tier 2: 3 pieces → +25 defense, +50 health

# Equip 2 knight pieces → Tier 1 activates (+10 defense)
# Equip 3 knight pieces → Tier 2 activates (+25 defense, +50 health)
# Unequip 1 piece → Falls back to Tier 1
# Unequip another → No tier active
```

#### Using Set Bonuses in Code

```gdscript
# Set bonuses are automatic! Just equip/unequip normally:
PPEquipmentUtils.equip_item(player.inventory, knight_helmet, player.runtime_stats)
# → Set bonus automatically recalculated

# Listen for set bonus changes
PPEquipmentUtils.set_bonus_activated.connect(func(set_entity, tier, bonuses):
    print("Set '%s' tier %d activated!" % [set_entity.get_set_name(), tier])
    for stat in bonuses:
        print("  +%d %s" % [bonuses[stat], stat])
)

PPEquipmentUtils.set_bonus_changed.connect(func(set_entity, old_tier, new_tier):
    print("Set '%s' changed: tier %d → %d" % [set_entity.get_set_name(), old_tier, new_tier])
)

# Query active set bonuses
var active = PPEquipmentUtils.get_active_set_bonuses(player.inventory)
for set_id in active:
    print("Set %s: tier %d active" % [set_id, active[set_id]])

# Get detailed set status
var knight_set = Pandora.get_entity("KNIGHT_SET") as PPEquipmentSetEntity
var status = PPEquipmentUtils.get_set_status(knight_set, player.inventory)
print("Equipped: %d/%d" % [status.equipped_count, status.total_pieces])
print("Active tier: %d" % status.active_tier)
print("Next tier at: %d pieces" % status.next_tier)

# Find which sets an equipment piece belongs to
var helmet = Pandora.get_entity("KNIGHT_HELMET") as PPEquipmentEntity
var sets = helmet.get_equipment_sets()
for s in sets:
    print("Part of set: %s" % s.get_set_name())
```

#### How Set Bonuses Work Internally

1. **On equip/unequip**: `update_set_bonuses()` is called automatically
2. **For each defined set**: Counts how many pieces are currently equipped
3. **Determines best tier**: Highest tier where `equipped_count >= pieces_required`
4. **Applies stat modifiers**: Creates FLAT modifiers with source `"set_bonus_{set_id}"`
5. **Emits signals**: `set_bonus_activated`, `set_bonus_deactivated`, or `set_bonus_changed`

---

### Pattern 3: Durability System

```gdscript
# Store durability in equipment custom data
func equip_with_durability(
    inventory: PPInventory,
    item: PPEquipmentEntity,
    stats: PPRuntimeStats,
    current_durability: float = 100.0
) -> bool:
    if not PPEquipmentUtils.equip_item(inventory, item, stats):
        return false

    # Store durability metadata
    var slot = item.get_equipment_slot()
    _equipment_durability[slot] = current_durability

    return true

func damage_equipment(slot: String, damage: float):
    if not _equipment_durability.has(slot):
        return

    _equipment_durability[slot] -= damage

    if _equipment_durability[slot] <= 0:
        print("Equipment broken!")
        PPEquipmentUtils.unequip_item(player.inventory, slot, player.runtime_stats)
        _equipment_durability.erase(slot)

func repair_equipment(slot: String, amount: float):
    if _equipment_durability.has(slot):
        _equipment_durability[slot] = min(_equipment_durability[slot] + amount, 100.0)
```

---

## Serialization (Save/Load)

Equipment state is saved as part of inventory serialization.

### Save Equipment

```gdscript
func save_game():
    var save_data = {
        "inventory": player.inventory.to_dict(),
        "runtime_stats": player.runtime_stats.to_dict()
    }

    # Inventory.to_dict() includes equipped_items
    var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
    file.store_var(save_data)
    file.close()
```

### Load Equipment

```gdscript
func load_game():
    var file = FileAccess.open("user://save.dat", FileAccess.READ)
    var save_data = file.get_var()
    file.close()

    # Restore inventory (includes equipment)
    player.inventory = PPInventory.from_dict(save_data["inventory"])
    player.runtime_stats = PPRuntimeStats.from_dict(save_data["runtime_stats"])

    # Re-apply equipment stat modifiers
    reapply_equipment_stats()

func reapply_equipment_stats():
    # Clear existing equipment modifiers
    for slot in player.inventory.equipped_items.keys():
        var source = "equipment_%s" % slot
        player.runtime_stats.remove_modifiers_by_source(source)

    # Reapply from equipped items
    for slot_name in player.inventory.equipped_items.keys():
        if player.inventory.has_equipment_in_slot(slot_name):
            var equipped = player.inventory.get_equipped_item(slot_name)
            var item = equipped.item as PPEquipmentEntity

            if item and item.has_stat_bonuses():
                var stats = item.get_equipment_stats()
                # Apply stat modifiers...
                # (This is handled automatically by PPEquipmentUtils when loading)
```

---

## See Also

- [Inventory System](inventory-system.md) - Inventory management
- [Runtime Stats System](runtime-stats.md) - Stat modifiers and calculations
- [PPInventory API](../api/inventory.md) - Inventory API reference
- [PPRuntimeStats API](../api/runtime-stats.md) - Runtime stats API

---

*Complete Guide for Pandora+ v1.0.1-premium*
