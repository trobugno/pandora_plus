# PPInventoryUtils

**Extends:** `Node`

Utility class providing sorting, compacting, transfer, and calculation functions for inventory management.

---

## Description

`PPInventoryUtils` is a singleton utility class that provides common inventory operations such as sorting items by various criteria, compacting stacks, transferring items between inventories, and calculating total values and weights. This class is designed to be used as an autoload singleton for global access.

All methods are static-like instance methods that operate on `PPInventory` objects without modifying the utility instance itself.
---

## Setup

Add to autoload in Project Settings:

```gdscript
# Project -> Project Settings -> Autoload
# Name: InventoryUtils
# Path: res://addons/pandora_plus/extensions/inventory/PPInventoryUtils.gd
```

---

## Methods

###### `sort_inventory(inventory: PPInventory, sort_by: String = "name") -> void`

Sorts inventory slots by specified criteria.

**Parameters:**
- `inventory`: The inventory to sort
- `sort_by`: Sort criterion (default: `"name"`)

**Sort Options:**
- `"name"`: Alphabetical by item name (A-Z)
- `"value"`: By item value (highest first)
- `"weight"`: By item weight (lightest first)
- `"rarity"`: By rarity percentage (rarest first)
- `"quantity"`: By stack quantity (largest first)

**Behavior:**
- Sorts only filled slots
- Maintains null slots for fixed-size inventories

**Example:**
```gdscript
# Sort by item name
InventoryUtils.sort_inventory(player_inventory, "name")

# Sort by value (most valuable first)
InventoryUtils.sort_inventory(player_inventory, "value")

# Sort by quantity
InventoryUtils.sort_inventory(player_inventory, "quantity")
```

---

###### `compact_inventory(inventory: PPInventory) -> int`

Merges stackable items into fewer slots and removes empty slots (for unlimited inventories).

**Parameters:**
- `inventory`: The inventory to compact

**Returns:** Number of slots compacted (freed)

**Behavior:**
- Merges matching items respecting stack limits
- Removes null slots if inventory is unlimited
- Keeps null slots if inventory has fixed size

**Example:**
```gdscript
# Before: [Potion x30], [Sword x1], [Potion x20], [Potion x40]
var compacted = InventoryUtils.compact_inventory(player_inventory)
# After: [Potion x90], [Sword x1]
print("Freed %d slots" % compacted)  # Output: 2
```

---

###### `calculate_total_value(inventory: PPInventory) -> float`

Calculates the total value of all items in the inventory.

**Parameters:**
- `inventory`: The inventory to calculate

**Returns:** Total value as float

**Example:**
```gdscript
var total = InventoryUtils.calculate_total_value(player_inventory)
print("Total inventory value: %d gold" % int(total))

# Use for insurance or death penalty
func calculate_death_penalty() -> int:
    var total_value = InventoryUtils.calculate_total_value(player_inventory)
    return int(total_value * 0.1)  # Lose 10% of inventory value
```

---

###### `calculate_total_weight(inventory: PPInventory) -> float`

Calculates the total weight of all items in the inventory.

**Parameters:**
- `inventory`: The inventory to calculate

**Returns:** Total weight as float

**Example:**
```gdscript
var weight = InventoryUtils.calculate_total_weight(player_inventory)
print("Carrying: %.1f kg" % weight)

# Check if over-encumbered
if weight > player.max_carry_weight:
    player.apply_movement_penalty()
```

---

###### `transfer_items(from_inv: PPInventory, to_inv: PPInventory, item: PPItemEntity, quantity: int = 1) -> void`

Transfers a specific item from one inventory to another.

**Parameters:**
- `from_inv`: Source inventory
- `to_inv`: Destination inventory
- `item`: Item to transfer
- `quantity`: Number of items to transfer (default: 1)

**Behavior:**
- Checks if source has sufficient quantity
- Removes from source, adds to destination
- Pushes error if item not found

**Example:**
```gdscript
var potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity

# Transfer 5 potions from player to storage
InventoryUtils.transfer_items(
    player_inventory,
    storage_inventory,
    potion,
    5
)
```

---

###### `transfer_all(from_inv: PPInventory, to_inv: PPInventory) -> int`

Transfers all items from one inventory to another.

**Parameters:**
- `from_inv`: Source inventory
- `to_inv`: Destination inventory

**Returns:** Total number of items transferred

**Behavior:**
- Transfers all non-null slots
- Removes items from source
- Cleans up null slots if source is unlimited

**Example:**
```gdscript
# Loot all items from chest
var looted = InventoryUtils.transfer_all(chest_inventory, player_inventory)
print("Looted %d items" % looted)

# Transfer to storage before boss fight
InventoryUtils.transfer_all(player_inventory, storage_inventory)
```

---

## Sorting Functions

These are internal helper functions used by `sort_inventory()`:

###### `_sort_by_name(a: PPInventorySlot, b: PPInventorySlot) -> bool`

Sorts alphabetically by item name (A-Z).

---

###### `_sort_by_value(a: PPInventorySlot, b: PPInventorySlot) -> bool`

Sorts by item value (highest to lowest).

---

###### `_sort_by_weight(a: PPInventorySlot, b: PPInventorySlot) -> bool`

Sorts by item weight (lightest to heaviest).

---

###### `_sort_by_quantity(a: PPInventorySlot, b: PPInventorySlot) -> bool`

Sorts by stack quantity (largest to smallest).

---

###### `_sort_by_rarity(a: PPInventorySlot, b: PPInventorySlot) -> bool`

Sorts by rarity percentage (rarest to most common).

---

## Best Practices

### ✅ Sort After Bulk Operations

```gdscript
# ✅ Good: sort after loading/looting
func load_saved_inventory(data: Dictionary):
    # Load items...
    InventoryUtils.compact_inventory(inventory)
    InventoryUtils.sort_inventory(inventory, "name")

# ❌ Bad: sort repeatedly
for item in loot_list:
    inventory.add_item(item)
    InventoryUtils.sort_inventory(inventory)  # Inefficient
```

---

### ✅ Compact Before Saving

```gdscript
# ✅ Good: compact before save
func save_inventory():
    InventoryUtils.compact_inventory(player_inventory)
    var data = serialize_inventory()
    save_to_file(data)

# This reduces save file size and prevents fragmentation
```

---

### ✅ Check Weight Before Adding

```gdscript
# ✅ Good: validate weight limit
func can_pickup_item(item: PPItemEntity, quantity: int) -> bool:
    var current_weight = InventoryUtils.calculate_total_weight(inventory)
    var item_weight = item.get_weight() * quantity
    return current_weight + item_weight <= max_carry_weight

func pickup_item(item: PPItemEntity, quantity: int):
    if can_pickup_item(item, quantity):
        inventory.add_item(item, quantity)
    else:
        show_message("Too heavy!")
```

---

## Common Patterns

### Pattern 1: Auto-Sort on Open

```gdscript
func open_inventory_menu():
    # Auto-sort when opening
    InventoryUtils.sort_inventory(player_inventory, user_preferences.sort_mode)
    show_inventory_ui()
```

---

### Pattern 2: Periodic Compacting

```gdscript
var compact_timer = 0.0
const COMPACT_INTERVAL = 60.0  # Every minute

func _process(delta):
    compact_timer += delta
    
    if compact_timer >= COMPACT_INTERVAL:
        InventoryUtils.compact_inventory(player_inventory)
        compact_timer = 0.0
```

---

### Pattern 3: Inventory Analysis

```gdscript
func analyze_inventory(inv: PPInventory) -> Dictionary:
    return {
        "total_slots": inv.all_items.size(),
        "used_slots": inv.all_items.filter(func(s): return s != null).size(),
        "total_items": inv.all_items.reduce(func(acc, s): return acc + (s.quantity if s else 0), 0),
        "total_value": InventoryUtils.calculate_total_value(inv),
        "total_weight": InventoryUtils.calculate_total_weight(inv),
        "most_valuable": find_most_valuable_item(inv),
        "heaviest": find_heaviest_item(inv)
    }
```

---

## Known Issues

### ⚠️ Bug in calculate_total_value() and calculate_total_weight()

The current implementation has a logical error:

```gdscript
# ❌ Current (incorrect)
if not slot.item:
    total += slot.item.get_value() * slot.quantity

# ✅ Should be
if slot and slot.item:
    total += slot.item.get_value() * slot.quantity
```

**Workaround** until fixed:
```gdscript
func safe_calculate_total_value(inventory: PPInventory) -> float:
    var total = 0.0
    
    for slot in inventory.all_items:
        if slot and slot.item:
            total += slot.item.get_value() * slot.quantity
    
    return total
```

---

## Notes

### Performance Considerations

**Sorting:**
- O(n log n) complexity
- Acceptable for <1000 items
- Consider caching sort results

**Compacting:**
- O(n²) worst case
- Most beneficial after looting many small stacks
- Run periodically, not every frame

**Transfers:**
- O(n) for `transfer_all`
- O(1) for `transfer_items`
- Minimal overhead

---

### Sort Stability

GDScript's `sort_custom()` is stable, meaning items with equal sort values maintain their relative order. This is useful when combining sort criteria.

---

## See Also

- [PPInventory](../api/inventory.md) - Inventory management
- [PPInventorySlot](../api/inventory-slot.md) - Slot management
- [PPItemEntity](../entities/item-entity.md) - Item system
- [Inventory System](../core-systems/inventory-system.md) - Complete system overview

---

*API Reference generated from source code*