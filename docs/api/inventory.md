# PPInventory

**Extends:** `Resource`

Manages a collection of items organized in slots, with support for equipment, currency, and inventory limits.

---

## Description

`PPInventory` is the main inventory management class in Pandora+. It provides a flexible system for storing items in slots, managing equipment, tracking currency, and enforcing capacity limits. The inventory can be configured with or without maximum slot limits and supports both stackable and non-stackable items.

The class emits signals when inventory changes occur, making it easy to update UI elements and respond to inventory modifications.

---

## Signals

###### `inventory_updated`

Emitted when the inventory state changes (items added, removed, or modified).

**Example:**
```gdscript
inventory.inventory_updated.connect(_on_inventory_updated)

func _on_inventory_updated():
    refresh_ui()
```

---

###### `item_added(item: PPItemEntity, quantity: int)`

Emitted when an item is added to the inventory.

**Parameters:**
- `item`: The item entity that was added
- `quantity`: Number of items added

**Example:**
```gdscript
inventory.item_added.connect(_on_item_added)

func _on_item_added(item: PPItemEntity, quantity: int):
    print("Added %d %s" % [quantity, item.get_item_name()])
```

---

###### `item_removed(item: PPItemEntity, quantity: int)`

Emitted when an item is removed from the inventory.

**Parameters:**
- `item`: The item entity that was removed
- `quantity`: Number of items removed

**Example:**
```gdscript
inventory.item_removed.connect(_on_item_removed)

func _on_item_removed(item: PPItemEntity, quantity: int):
    print("Removed %d %s" % [quantity, item.get_item_name()])
```

---

## Properties

###### `all_items: Array[PPInventorySlot]`

Array containing all inventory slots. Slots can be `null` when empty (if using fixed size) or contain `PPInventorySlot` instances.

---

###### `equipments: Array[PPInventorySlot]`

Array containing equipment slots, separate from the main inventory.

---

###### `game_currency: int`

Current amount of game currency (gold, coins, etc.).

**Default:** `0`

---

###### `max_items_in_inventory: int`

Maximum number of slots in the main inventory. Set to `-1` for unlimited slots.

**Default:** `-1` (unlimited)

---

###### `max_items_in_equipments: int`

Maximum number of equipment slots. Set to `-1` for unlimited slots.

**Default:** `-1` (unlimited)

---

###### `max_weight: float`

Maximum weight capacity for the inventory. Set to `-1` for unlimited weight.

**Default:** `-1` (unlimited)

---

## Constructor

###### `PPInventory(pmi_inventory: int = -1, pmi_equipments: int = -1)`

Creates a new inventory with optional capacity limits.

**Parameters:**
- `pmi_inventory`: Max inventory slots (-1 for unlimited)
- `pmi_equipments`: Max equipment slots (-1 for unlimited)

**Behavior:**
- If max slots > -1, pre-allocates slots filled with `null`
- If max slots = -1, slots are added dynamically

**Example:**
```gdscript
# Unlimited inventory
var unlimited_inv = PPInventory.new()

# Fixed size inventory: 20 slots, 10 equipment slots
var limited_inv = PPInventory.new(20, 10)

# Only main inventory limited
var inv = PPInventory.new(30, -1)
```

---

## Methods

###### `has_item(item: PPItemEntity, quantity: int = 1) -> bool`

Checks if the inventory contains a specific item with sufficient quantity.

**Parameters:**
- `item`: Item to check for
- `quantity`: Minimum quantity required (default: 1)

**Returns:** `true` if item exists with required quantity

**Example:**
```gdscript
var health_potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity

if inventory.has_item(health_potion):
    print("Has at least 1 health potion")

if inventory.has_item(health_potion, 5):
    print("Has at least 5 health potions")
```

---

###### `add_item(item: PPItemEntity, quantity: int = 1, new_slot: bool = false) -> void`

Adds an item to the inventory.

**Parameters:**
- `item`: Item to add
- `quantity`: Number of items to add (default: 1)
- `new_slot`: If `true`, forces creation of a new slot instead of stacking (default: `false`)

**Behavior:**
- Attempts to stack with existing slots if item is stackable
- Creates new slot if stacking fails or `new_slot` is `true`
- Emits `item_added` signal on success

**Example:**
```gdscript
var sword = Pandora.get_entity("IRON_SWORD") as PPItemEntity
var potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity

# Add single item
inventory.add_item(sword)

# Add multiple items (will stack if possible)
inventory.add_item(potion, 10)

# Force new slot (even if stackable)
inventory.add_item(potion, 5, true)
```

---

###### `remove_item(item: PPItemEntity, quantity: int = 1, source: Array[PPInventorySlot] = all_items) -> void`

Removes an item from the inventory.

**Parameters:**
- `item`: Item to remove
- `quantity`: Number of items to remove (default: 1)
- `source`: Array to remove from (default: `all_items`)

**Behavior:**
- Removes specified quantity from first matching slot
- Sets slot to `null` if quantity reaches zero
- Emits `item_removed` signal on success
- Pushes error if item not found

**Example:**
```gdscript
var potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity

# Remove single item
inventory.remove_item(potion)

# Remove multiple items
inventory.remove_item(potion, 3)

# Remove from equipment slots
inventory.remove_item(helmet, 1, inventory.equipments)
```

---

###### `remove_single_item_by(index: int) -> PPItemEntity`

Removes one item from a specific slot by index.

**Parameters:**
- `index`: Slot index

**Returns:** The removed `PPItemEntity`, or `null` if slot was empty

**Behavior:**
- Decrements quantity by 1
- Sets slot to `null` if quantity reaches 1
- Emits `inventory_updated` signal

**Example:**
```gdscript
# Remove from slot 5
var removed_item = inventory.remove_single_item_by(5)

if removed_item:
    print("Removed: %s" % removed_item.get_item_name())
else:
    print("Slot was empty")
```

---

## Usage Example

### Example: Basic Inventory Setup

```gdscript
class_name PlayerInventory
extends Node

var inventory: PPInventory

func _ready():
    # Create inventory with 30 slots and 8 equipment slots
    inventory = PPInventory.new(30, 8)
    
    # Connect signals
    inventory.item_added.connect(_on_item_added)
    inventory.item_removed.connect(_on_item_removed)
    inventory.inventory_updated.connect(_on_inventory_updated)
    
    # Set starting currency
    inventory.game_currency = 100

func _on_item_added(item: PPItemEntity, quantity: int):
    print("+ %d %s" % [quantity, item.get_item_name()])
    update_ui()

func _on_item_removed(item: PPItemEntity, quantity: int):
    print("- %d %s" % [quantity, item.get_item_name()])
    update_ui

func _on_inventory_updated():
    update_ui()

func update_ui():
    # Refresh inventory display
    pass
```

---

## Best Practices

### ✅ Always Check has_item() Before Removing

```gdscript
# ✅ Good: check before removing
if inventory.has_item(potion, 3):
    inventory.remove_item(potion, 3)
else:
    print("Not enough potions!")

# ❌ Bad: assume item exists
inventory.remove_item(potion, 3)  # Will push error if not found
```

---

### ✅ Connect to Signals for UI Updates

```gdscript
# ✅ Good: reactive UI
inventory.inventory_updated.connect(refresh_inventory_ui)
inventory.item_added.connect(show_item_notification)

# ❌ Bad: manual polling
func _process(_delta):
    check_if_inventory_changed()  # Inefficient
```

---

### ✅ Use Appropriate Inventory Size

```gdscript
# ✅ Good: based on game design
var player_inv = PPInventory.new(40, 10)   # Player has limited space
var storage_inv = PPInventory.new(-1, -1)  # Storage is unlimited
var shop_inv = PPInventory.new(-1, 0)      # Shop has no equipment

# ❌ Bad: inconsistent limits
var inv = PPInventory.new(1000, 1000)  # Unnecessarily large
```

---

## Common Patterns

### Pattern 1: Consumable Item Usage

```gdscript
func use_consumable(item: PPItemEntity) -> bool:
    if not inventory.has_item(item):
        return false
    
    # Apply item effect
    if item.has_method("apply_effect"):
        item.apply_effect(player)
    
    # Remove from inventory
    inventory.remove_item(item)
    
    return true
```

---

### Pattern 2: Currency Management

```gdscript
func add_currency(amount: int):
    inventory.game_currency += amount
    print("Gold: %d (+%d)" % [inventory.game_currency, amount])

func remove_currency(amount: int) -> bool:
    if inventory.game_currency >= amount:
        inventory.game_currency -= amount
        return true
    return false

func can_afford(cost: int) -> bool:
    return inventory.game_currency >= cost
```

---

### Pattern 3: Inventory Validation

```gdscript
func is_inventory_full() -> bool:
    if inventory.max_items_in_inventory == -1:
        return false  # Unlimited
    
    var empty_slots = inventory.all_items.filter(func(s): return s == null)
    return empty_slots.is_empty()

func get_empty_slot_count() -> int:
    if inventory.max_items_in_inventory == -1:
        return 999  # Effectively unlimited
    
    var empty = inventory.all_items.filter(func(s): return s == null)
    return empty.size()
```

---

## Notes

### Fixed vs Dynamic Size

**Fixed Size (max > -1):**
- Pre-allocates slots with `null` values
- Slots remain in array even when empty
- Better for grid-based UIs
- Memory footprint is constant

**Dynamic Size (max = -1):**
- Slots added/removed as needed
- Array only contains active slots
- Better for list-based UIs
- Memory usage scales with items

---

### Signal Timing

Signals are emitted at specific times:
- `item_added`: After item is added to slot
- `item_removed`: After item is removed from slot
- `inventory_updated`: When `remove_single_item_by()` is called

For most operations, prefer `item_added`/`item_removed` over `inventory_updated`.

---

### Equipment vs Main Inventory

The `equipments` array is separate from `all_items`:
- Use `equipments` for worn items (armor, weapons)
- Use `all_items` for carried items
- Transfer between them manually based on game logic
- Both arrays follow the same slot structure

---

## See Also

- [PPInventorySlot](../api/inventory-slot.md) - Slot management
- [PPInventoryUtils](../utilities/inventory-utils.md) - Utility functions
- [PPItemEntity](../entities/item-entity.md) - Item system
- [Inventory System](../core-systems/inventory-system.md) - Complete system overview

---

*API Reference generated from source code*