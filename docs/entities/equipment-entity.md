# 💎 PPEquipmentEntity

**Extends:** `PPItemEntity`

Represents an equippable item with slot assignment and stat bonuses.

---

## Description

`PPEquipmentEntity` extends `PPItemEntity` to add equipment-specific functionality. Equipment items can be assigned to specific body slots (HEAD, WEAPON, etc.) and provide stat bonuses when equipped.

All standard item properties are inherited from PPItemEntity:
- Item name, description, texture
- Value, weight, rarity
- Stackable flag (equipment is typically non-stackable)

Equipment adds:
- Equipment slot assignment
- Stat bonuses via PPStats property

---

## Equipment Slots

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

---

## Properties

Equipment entities have these Pandora properties:

| Property | Type | Description |
|----------|------|-------------|
| `equipment_slot` | `String` | Slot this equipment fits in |
| `stats_property` | `PPStats` | Stat bonuses when equipped |

Plus all inherited from PPItemEntity:
- `name` - Display name
- `description` - Item description
- `texture` - Item icon
- `value` - Gold/currency value
- `weight` - Inventory weight
- `rarity` - PPRarityEntity reference
- `stackable` - Whether item stacks (usually false for equipment)

---

## Methods

### get_equipment_slot()

Returns the equipment slot type as string.

```gdscript
func get_equipment_slot() -> String
```

**Returns:** Slot name (e.g., "HEAD", "WEAPON", "CHEST")

**Example:**
```gdscript
var helmet = Pandora.get_entity("IRON_HELMET") as PPEquipmentEntity
print("Slot: ", helmet.get_equipment_slot())  # "HEAD"

# Use for slot checking
if helmet.get_equipment_slot() == "HEAD":
    print("This is a helmet")
```

---

### get_equipment_slot_enum()

Returns the equipment slot as enum value.

```gdscript
func get_equipment_slot_enum() -> EquipmentSlot
```

**Returns:** EquipmentSlot enum value

**Example:**
```gdscript
var sword = Pandora.get_entity("IRON_SWORD") as PPEquipmentEntity
var slot = sword.get_equipment_slot_enum()

match slot:
    PPEquipmentEntity.EquipmentSlot.WEAPON:
        print("This is a weapon")
    PPEquipmentEntity.EquipmentSlot.SHIELD:
        print("This is a shield")
```

---

### get_equipment_stats()

Returns the stat bonuses this equipment provides.

```gdscript
func get_equipment_stats() -> PPStats
```

**Returns:** PPStats instance or `null` if equipment has no stat bonuses

**Example:**
```gdscript
var armor = Pandora.get_entity("STEEL_ARMOR") as PPEquipmentEntity
var stats = armor.get_equipment_stats()

if stats:
    print("Health bonus: +%d" % stats._health)
    print("Defense bonus: +%d" % stats._defense)
else:
    print("This equipment has no stat bonuses")
```

---

### has_stat_bonuses()

Checks if equipment provides stat bonuses.

```gdscript
func has_stat_bonuses() -> bool
```

**Returns:** `true` if equipment has stats_property, `false` otherwise

**Example:**
```gdscript
var ring = Pandora.get_entity("PLAIN_RING") as PPEquipmentEntity

if ring.has_stat_bonuses():
    var stats = ring.get_equipment_stats()
    print("Ring provides bonuses: ", stats)
else:
    print("This is a cosmetic item with no stat bonuses")
```

---

## Usage Examples

### Example 1: Equipment Inspector

```gdscript
func inspect_equipment(equipment: PPEquipmentEntity) -> void:
    print("=== Equipment Info ===")
    print("Name: ", equipment.get_item_name())
    print("Description: ", equipment.get_description())
    print("Slot: ", equipment.get_equipment_slot())
    print("Value: %d gold" % equipment.get_value())
    print("Weight: %.1f" % equipment.get_weight())

    var rarity = equipment.get_rarity()
    if rarity:
        print("Rarity: ", rarity.get_rarity_name())

    if equipment.has_stat_bonuses():
        print("\nStat Bonuses:")
        var stats = equipment.get_equipment_stats()

        if stats._health > 0:
            print("  Health: +%d" % stats._health)
        if stats._mana > 0:
            print("  Mana: +%d" % stats._mana)
        if stats._attack > 0:
            print("  Attack: +%d" % stats._attack)
        if stats._defense > 0:
            print("  Defense: +%d" % stats._defense)
        if stats._crit_rate > 0:
            print("  Crit Rate: +%.1f%%" % stats._crit_rate)
        if stats._crit_damage > 0:
            print("  Crit Damage: +%.1f%%" % stats._crit_damage)
```

---

### Example 2: Equipment Comparison UI

```gdscript
class_name EquipmentComparisonPanel
extends Control

@onready var current_item_panel = $CurrentItem
@onready var new_item_panel = $NewItem
@onready var stat_comparison = $StatComparison

func show_comparison(current: PPEquipmentEntity, new: PPEquipmentEntity):
    # Display current equipment
    if current:
        current_item_panel.set_item_name(current.get_item_name())
        current_item_panel.set_icon(current.get_texture())
        display_stats(current_item_panel, current.get_equipment_stats())
    else:
        current_item_panel.set_empty()

    # Display new equipment
    new_item_panel.set_item_name(new.get_item_name())
    new_item_panel.set_icon(new.get_texture())
    display_stats(new_item_panel, new.get_equipment_stats())

    # Show stat differences
    compare_stats(current, new)

func display_stats(panel: Control, stats: PPStats):
    if not stats:
        panel.hide_stats()
        return

    panel.show_stat("Health", stats._health)
    panel.show_stat("Attack", stats._attack)
    panel.show_stat("Defense", stats._defense)
    panel.show_stat("Crit Rate", stats._crit_rate)

func compare_stats(current: PPEquipmentEntity, new: PPEquipmentEntity):
    var current_stats = current.get_equipment_stats() if current else null
    var new_stats = new.get_equipment_stats()

    if not new_stats:
        return

    # Compare each stat
    var stats_to_compare = ["health", "attack", "defense", "crit_rate"]

    for stat_name in stats_to_compare:
        var current_val = get_stat_value(current_stats, stat_name)
        var new_val = get_stat_value(new_stats, stat_name)
        var diff = new_val - current_val

        if diff != 0:
            stat_comparison.add_stat_diff(stat_name, diff)

func get_stat_value(stats: PPStats, stat_name: String) -> float:
    if not stats:
        return 0.0

    match stat_name:
        "health": return stats._health
        "attack": return stats._attack
        "defense": return stats._defense
        "crit_rate": return stats._crit_rate
    return 0.0
```

---

### Example 3: Equipment Validation

```gdscript
func validate_equipment_for_character(
    equipment: PPEquipmentEntity,
    character_level: int,
    character_class: String
) -> Dictionary:
    var result = {
        "can_equip": true,
        "reasons": []
    }

    # Check level requirement (stored in custom properties)
    var level_req = equipment.get_int("level_requirement")
    if level_req > 0 and character_level < level_req:
        result["can_equip"] = false
        result["reasons"].append("Requires level %d" % level_req)

    # Check class requirement
    var class_req = equipment.get_string("class_requirement")
    if not class_req.is_empty() and class_req != character_class:
        result["can_equip"] = false
        result["reasons"].append("Requires %s class" % class_req)

    # Check if item is actually equipment
    if not equipment is PPEquipmentEntity:
        result["can_equip"] = false
        result["reasons"].append("Not an equipment item")

    return result

# Usage:
var sword = Pandora.get_entity("LEGENDARY_SWORD") as PPEquipmentEntity
var validation = validate_equipment_for_character(sword, player.level, player.character_class)

if validation["can_equip"]:
    PPEquipmentUtils.equip_item(player.inventory, sword, player.stats)
else:
    for reason in validation["reasons"]:
        print("Cannot equip: ", reason)
```

---

### Example 4: Equipment Crafting Result

```gdscript
func craft_equipment(recipe: PPRecipe) -> PPEquipmentEntity:
    var result = recipe.get_result() as PPEquipmentEntity

    if not result:
        push_error("Recipe result is not equipment")
        return null

    print("Crafted: ", result.get_item_name())
    print("Slot: ", result.get_equipment_slot())

    if result.has_stat_bonuses():
        var stats = result.get_equipment_stats()
        print("Stats: ATK +%d, DEF +%d" % [stats._attack, stats._defense])

    # Add to inventory
    player.inventory.add_item(result, 1)

    return result
```

---

## Creating Equipment in Pandora Editor

### Step 1: Create Entity

1. Open Pandora Editor
2. Create new entity
3. Set category to "Equipment"
4. Set entity ID (e.g., "IRON_SWORD")

### Step 2: Add Item Properties

Add standard item properties:
- `name` (String): "Iron Sword"
- `description` (String): "A sturdy iron blade"
- `texture` (Texture2D): Sword icon
- `value` (float): 100.0
- `weight` (float): 5.0
- `rarity` (PPRarityEntity): Reference to rarity
- `stackable` (bool): false

### Step 3: Add Equipment Properties

Add equipment-specific properties:
- `equipment_slot` (String): "WEAPON"
- `stats_property` (PPStats):
  - Health: 0
  - Attack: 10
  - Defense: 0
  - Crit Rate: 5.0

### Step 4: Save and Use

```gdscript
# Load and use equipment
var sword = Pandora.get_entity("IRON_SWORD") as PPEquipmentEntity
PPEquipmentUtils.equip_item(player.inventory, sword, player.stats)
```

---

## Best Practices

### ✅ Set Stackable to False

```gdscript
# ✅ Good: Equipment shouldn't stack
# In Pandora Editor: stackable = false

# ❌ Bad: Stackable equipment causes issues
# Equipment with stackable = true may cause equip bugs
```

---

### ✅ Use Descriptive Entity IDs

```gdscript
# ✅ Good: Clear naming
"IRON_SWORD"
"STEEL_HELMET"
"LEATHER_BOOTS"

# ❌ Bad: Vague naming
"WEAPON_1"
"ARMOR_A"
"ITEM_42"
```

---

### ✅ Validate Before Casting

```gdscript
# ✅ Good: Type checking
var item = Pandora.get_entity(entity_id)
if item is PPEquipmentEntity:
    var equipment = item as PPEquipmentEntity
    print("Slot: ", equipment.get_equipment_slot())

# ❌ Bad: Assume type
var equipment = Pandora.get_entity(entity_id) as PPEquipmentEntity
equipment.get_equipment_slot()  # May crash if not equipment
```

---

### ✅ Check for Null Stats

```gdscript
# ✅ Good: Handle null stats
var stats = equipment.get_equipment_stats()
if stats:
    print("Attack: +%d" % stats._attack)
else:
    print("No stat bonuses")

# ❌ Bad: Assume stats exist
var stats = equipment.get_equipment_stats()
print("Attack: +%d" % stats._attack)  # Crashes if stats is null
```

---

## See Also

- [Equipment System](../core-systems/equipment-system.md) - Complete equipment guide
- [PPItemEntity](item-entity.md) - Base item class
- [PPEquipmentUtils](../utilities/equipment-utils.md) - Equipment utility functions
- [PPInventory](../api/inventory.md) - Inventory management
- [PPRuntimeStats](../api/runtime-stats.md) - Stat modifiers

---

*API Reference for Pandora+ v1.0.0*
