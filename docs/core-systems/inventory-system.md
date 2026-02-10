# Inventory System

Complete guide to the Pandora+ inventory management system, including items, slots, utilities, and best practices.

**Availability:** ✅ Core & Premium

---

## Overview

The Pandora+ Inventory System provides a flexible, feature-rich solution for managing items in your game. It supports stackable and non-stackable items, equipment slots, weight limits, currency, and includes utilities for sorting, compacting, and transferring items.

**Core Components:**
- **PPInventory** - Main inventory container with slots and equipment
- **PPInventorySlot** - Individual slot holding item and quantity
- **PPInventoryUtils** - Utility functions for operations
- **PPItemEntity** - Item data and properties (see Item System docs)

---

## Quick Start

### Basic Setup

```gdscript
# Create inventory with 30 slots and 8 equipment slots
var inventory = PPInventory.new(30, 8)

# Connect to signals
inventory.item_added.connect(_on_item_added)
inventory.item_removed.connect(_on_item_removed)

# Set starting currency
inventory.game_currency = 100

func _on_item_added(item: PPItemEntity, quantity: int):
    print("+ %d %s" % [quantity, item.get_item_name()])

func _on_item_removed(item: PPItemEntity, quantity: int):
    print("- %d %s" % [quantity, item.get_item_name()])
```

### Adding and Removing Items

```gdscript
# Get item from Pandora
var potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity
var sword = Pandora.get_entity("IRON_SWORD") as PPItemEntity

# Add items
inventory.add_item(potion, 10)  # 10 potions (stackable)
inventory.add_item(sword)       # 1 sword

# Check if has item
if inventory.has_item(potion, 3):
    print("Has at least 3 potions")

# Remove items
inventory.remove_item(potion, 2)  # Remove 2 potions
```

---

## Architecture

### Component Relationships

```
PPInventory
├── all_items: Array[PPInventorySlot]
│   └── PPInventorySlot
│       ├── item: PPItemEntity
│       └── quantity: int
├── equipments: Array[PPInventorySlot]
│   └── PPInventorySlot
└── game_currency: int

PPInventoryUtils (singleton)
└── Operations on PPInventory instances
```

### Inventory Types

**Fixed Size Inventory:**
```gdscript
var player_inv = PPInventory.new(40, 10)
# - 40 main slots (pre-allocated with null)
# - 10 equipment slots
# - Perfect for grid-based UIs
# - Constant memory footprint
```

**Dynamic Size Inventory:**
```gdscript
var storage_inv = PPInventory.new(-1, -1)
# - Unlimited slots
# - Grows/shrinks as needed
# - Perfect for storage chests
# - Variable memory usage
```

---

## Core Features

### 1. Stack Management

Items can be stackable or non-stackable based on `PPItemEntity` properties:

```gdscript
# Stackable item (e.g., potions)
var potion = create_item("POTION")
potion.set_stackable(true)

inventory.add_item(potion, 50)  # Adds to existing stack or creates new

# Non-stackable item (e.g., unique weapons)
var legendary_sword = create_item("LEGENDARY_SWORD")
legendary_sword.set_stackable(false)

inventory.add_item(legendary_sword, 3)  # Creates 3 separate slots
```

**Stack Limits:**
- Maximum stack size: `99` (defined in `PPInventorySlot.MAX_STACK_SIZE`)
- Non-stackable items always have quantity `1`
- Attempting to set quantity > 1 on non-stackable items triggers error

---

### 2. Equipment System

Equipment slots are separate from main inventory:

```gdscript
enum EquipmentSlot { HEAD, CHEST, LEGS, FEET, WEAPON, SHIELD }

func equip_item(item: PPItemEntity, slot: int):
    # Remove from main inventory
    if inventory.has_item(item):
        inventory.remove_item(item)
        
        # Unequip old item if present
        var old_item = inventory.equipments[slot]
        if old_item and old_item.item:
            inventory.add_item(old_item.item)
        
        # Equip new item
        var new_slot = PPInventorySlot.new()
        new_slot.item = item
        new_slot.quantity = 1
        inventory.equipments[slot] = new_slot

func unequip_item(slot: int):
    var item_slot = inventory.equipments[slot]
    if item_slot and item_slot.item:
        inventory.add_item(item_slot.item)
        inventory.equipments[slot] = null
```

---

### 3. Currency Management

```gdscript
# Add currency
inventory.game_currency += 100
print("Gold: %d" % inventory.game_currency)

# Remove currency
func purchase_item(cost: int) -> bool:
    if inventory.game_currency >= cost:
        inventory.game_currency -= cost
        return true
    return false

# Check affordability
func can_afford(price: int) -> bool:
    return inventory.game_currency >= price
```

---

### 4. Weight and Value Tracking

```gdscript
# Calculate total weight
var weight = InventoryUtils.calculate_total_weight(inventory)

# Check if over-encumbered
if weight > player.max_carry_weight:
    player.movement_speed *= 0.5
    show_warning("Over-encumbered!")

# Calculate total value
var value = InventoryUtils.calculate_total_value(inventory)
print("Net worth: %d gold" % int(value))

# Use for death penalty
func on_player_death():
    var loss = int(value * 0.1)  # Lose 10%
    inventory.game_currency -= loss
```

---

### 5. Sorting and Organization

```gdscript
# Sort by different criteria
InventoryUtils.sort_inventory(inventory, "name")     # A-Z
InventoryUtils.sort_inventory(inventory, "value")    # Most valuable first
InventoryUtils.sort_inventory(inventory, "weight")   # Lightest first
InventoryUtils.sort_inventory(inventory, "rarity")   # Rarest first
InventoryUtils.sort_inventory(inventory, "quantity") # Largest stacks first

# Compact stacks (merge stackable items)
var freed = InventoryUtils.compact_inventory(inventory)
print("Freed %d slots" % freed)
```

---

### 6. Item Transfer

```gdscript
# Transfer specific item
var potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity
InventoryUtils.transfer_items(
    player_inventory,
    storage_inventory,
    potion,
    5  # quantity
)

# Transfer all items
var transferred = InventoryUtils.transfer_all(
    chest_inventory,
    player_inventory
)
print("Looted %d items" % transferred)
```

---

## Signal System

The inventory emits signals for reactive UI updates:

### Signal Flow

```
User Action → Inventory Method → Signal Emitted → UI Updates
```

### Signal Examples

```gdscript
class_name InventoryUI

func _ready():
    # General updates
    inventory.inventory_updated.connect(refresh_all)
    
    # Specific events
    inventory.item_added.connect(_on_item_added)
    inventory.item_removed.connect(_on_item_removed)

func _on_item_added(item: PPItemEntity, quantity: int):
    # Show notification
    show_popup("+ %d %s" % [quantity, item.get_item_name()])
    
    # Play sound
    audio_player.play("item_pickup")
    
    # Update specific slot UI
    refresh_item_slot(item)

func _on_item_removed(item: PPItemEntity, quantity: int):
    show_popup("- %d %s" % [quantity, item.get_item_name()])
    refresh_item_slot(item)

func refresh_all():
    # Full UI refresh
    for i in inventory.all_items.size():
        update_slot_display(i)
```

---

## Common Patterns

### Pattern 1: Loot System

```gdscript
class_name LootContainer
extends Area3D

var loot_inventory: PPInventory

func _ready():
    loot_inventory = PPInventory.new(-1, 0)
    generate_loot()

func generate_loot():
    var loot_table = [
        {"item": "GOLD_COIN", "quantity": randi_range(10, 50)},
        {"item": "HEALTH_POTION", "quantity": randi_range(1, 3)},
        {"item": "IRON_SWORD", "quantity": 1}
    ]
    
    for entry in loot_table:
        var item = Pandora.get_entity(entry["item"]) as PPItemEntity
        if item:
            loot_inventory.add_item(item, entry["quantity"])

func loot_all(player_inv: PPInventory):
    var count = InventoryUtils.transfer_all(loot_inventory, player_inv)
    
    if count > 0:
        print("Looted %d items" % count)
        queue_free()
```

---

### Pattern 2: Consumable System

```gdscript
class_name ConsumableManager

func use_consumable(inventory: PPInventory, item: PPItemEntity, target: Node):
    if not inventory.has_item(item):
        show_error("Item not in inventory")
        return false
    
    # Apply effect
    if item.has_method("apply_effect"):
        item.apply_effect(target)
    
    # Remove from inventory
    inventory.remove_item(item)
    
    # Visual feedback
    show_item_used_effect(item)
    
    return true

func use_item_from_hotbar(slot_index: int):
    var slot = hotbar_slots[slot_index]
    if slot and slot.item:
        use_consumable(player_inventory, slot.item, player)
```

---

### Pattern 3: Crafting Integration

```gdscript
func can_craft_recipe(inventory: PPInventory, recipe: PPRecipe) -> bool:
    for ingredient in recipe.get_ingredients():
        var item = ingredient.get_item_entity()
        var required = ingredient.get_quantity()
        
        if not inventory.has_item(item, required):
            return false
    
    return true

func craft_item(inventory: PPInventory, recipe: PPRecipe):
    if not can_craft_recipe(inventory, recipe):
        show_error("Missing ingredients")
        return
    
    # Remove ingredients
    for ingredient in recipe.get_ingredients():
        inventory.remove_item(
            ingredient.get_item_entity(),
            ingredient.get_quantity()
        )
    
    # Add result
    var result = recipe.get_result()
    inventory.add_item(result)
    
    show_success("Crafted: %s" % result.get_item_name())
```

---

### Pattern 4: Save/Load System

```gdscript
func save_inventory(inventory: PPInventory) -> Dictionary:
    var data = {
        "currency": inventory.game_currency,
        "items": [],
        "equipments": []
    }
    
    # Save main items
    for slot in inventory.all_items:
        if slot and slot.item:
            data["items"].append({
                "item_id": slot.item.get_entity_id(),
                "quantity": slot.quantity
            })
    
    # Save equipment
    for slot in inventory.equipments:
        if slot and slot.item:
            data["equipments"].append({
                "item_id": slot.item.get_entity_id(),
                "quantity": slot.quantity
            })
    
    return data

func load_inventory(data: Dictionary) -> PPInventory:
    var inventory = PPInventory.new(
        data.get("max_slots", -1),
        data.get("max_equipment", -1)
    )
    
    inventory.game_currency = data.get("currency", 0)
    
    # Load items
    for item_data in data.get("items", []):
        var item = Pandora.get_entity(item_data["item_id"]) as PPItemEntity
        if item:
            inventory.add_item(item, item_data["quantity"])
    
    # Load equipment
    for i in range(data.get("equipments", []).size()):
        var eq_data = data["equipments"][i]
        var item = Pandora.get_entity(eq_data["item_id"]) as PPItemEntity
        if item:
            var slot = PPInventorySlot.new()
            slot.item = item
            slot.quantity = eq_data["quantity"]
            inventory.equipments[i] = slot
    
    return inventory
```

---

## UI Integration

### Grid-Based Inventory UI

```gdscript
class_name GridInventoryUI
extends GridContainer

@export var slot_scene: PackedScene
var inventory: PPInventory

func _ready():
    inventory.inventory_updated.connect(refresh_grid)
    refresh_grid()

func refresh_grid():
    # Clear existing
    for child in get_children():
        child.queue_free()
    
    # Create slot UI elements
    for i in inventory.all_items.size():
        var slot_ui = slot_scene.instantiate()
        add_child(slot_ui)
        
        var slot = inventory.all_items[i]
        if slot and slot.item:
            slot_ui.set_item(slot.item, slot.quantity)
        else:
            slot_ui.set_empty()
        
        slot_ui.slot_clicked.connect(_on_slot_clicked.bind(i))

func _on_slot_clicked(slot_index: int):
    # Handle slot interaction (drag, use, etc.)
    pass
```

---

### List-Based Inventory UI

```gdscript
class_name ListInventoryUI
extends ScrollContainer

@onready var item_list = $VBoxContainer

func refresh_list():
    # Clear list
    for child in item_list.get_children():
        child.queue_free()
    
    # Get all non-null slots
    var filled_slots = inventory.all_items.filter(func(s): return s != null)
    
    # Create entry for each item
    for slot in filled_slots:
        var entry = create_list_entry(slot)
        item_list.add_child(entry)

func create_list_entry(slot: PPInventorySlot) -> Control:
    var entry = HBoxContainer.new()
    
    # Icon
    var icon = TextureRect.new()
    icon.texture = slot.item.get_texture()
    entry.add_child(icon)
    
    # Name and quantity
    var label = Label.new()
    label.text = "%s x%d" % [slot.item.get_item_name(), slot.quantity]
    entry.add_child(label)
    
    # Weight and value
    var info = Label.new()
    info.text = "%.1fkg | %dg" % [
        slot.item.get_weight() * slot.quantity,
        slot.item.get_value() * slot.quantity
    ]
    entry.add_child(info)
    
    return entry
```

---

## Best Practices

### ✅ Initialize Inventory Early

```gdscript
# ✅ Good: initialize in _ready or _init
func _ready():
    inventory = PPInventory.new(30, 8)
    connect_signals()
    load_starting_items()

# ❌ Bad: lazy initialization
func get_inventory():
    if not inventory:
        inventory = PPInventory.new()  # May cause issues
    return inventory
```

---

### ✅ Use Signals for UI Updates

```gdscript
# ✅ Good: reactive updates
inventory.item_added.connect(refresh_ui)

# ❌ Bad: manual polling
func _process(_delta):
    if inventory_changed:
        refresh_ui()
```

---

### ✅ Compact Regularly

```gdscript
# ✅ Good: compact after bulk operations
func loot_multiple_containers():
    for container in containers:
        InventoryUtils.transfer_all(container.inventory, player_inventory)
    
    InventoryUtils.compact_inventory(player_inventory)

# ❌ Bad: never compact
# Results in fragmented inventory with many small stacks
```

---

### ✅ Validate Before Operations

```gdscript
# ✅ Good: check before removing
if inventory.has_item(item, required_qty):
    inventory.remove_item(item, required_qty)
else:
    show_error("Insufficient items")

# ❌ Bad: assume success
inventory.remove_item(item, required_qty)  # May error
```

---

## Performance Considerations

### Optimization Tips

1. **Batch Operations**: Group multiple adds/removes before updating UI
2. **Compact Periodically**: Run `compact_inventory()` after bulk looting
3. **Cache Calculations**: Store weight/value if accessed frequently
4. **Limit Sort Frequency**: Sort on open/demand, not every frame
5. **Use Appropriate Size**: Fixed size for players, unlimited for storage

### Benchmarks (Approximate)

| Operation | Time (1000 items) | Frequency |
|-----------|-------------------|-----------|
| Add item | ~0.01ms | High |
| Remove item | ~0.01ms | High |
| Sort | ~5ms | Low |
| Compact | ~10ms | Medium |
| Calculate weight | ~2ms | Medium |

---

## Troubleshooting

### Issue: Items Not Stacking

**Cause**: Item marked as non-stackable  
**Solution**: Check `item.is_stackable()` returns `true`

```gdscript
if not item.is_stackable():
    print("Item cannot stack")
```

---

### Issue: Inventory Full

**Cause**: No empty slots available  
**Solution**: Check slot availability or use unlimited inventory

```gdscript
func is_inventory_full() -> bool:
    if inventory.max_items_in_inventory == -1:
        return false
    
    return inventory.all_items.filter(func(s): return s == null).is_empty()
```

---

### Issue: Weight/Value Returns 0

**Cause**: Bug in utility functions (checks `not slot.item` instead of `slot and slot.item`)  
**Solution**: Use custom calculation functions

```gdscript
func safe_calculate_weight(inv: PPInventory) -> float:
    var total = 0.0
    for slot in inv.all_items:
        if slot and slot.item:
            total += slot.item.get_weight() * slot.quantity
    return total
```

---

## Migration Guide

### From Array-Based System

```gdscript
# Old system
var items: Array[PPItemEntity] = []

func add_item_old(item: PPItemEntity):
    items.append(item)

# New system
var inventory = PPInventory.new()

func add_item_new(item: PPItemEntity):
    inventory.add_item(item)
```

**Benefits:**
- ✅ Stack management
- ✅ Quantity tracking
- ✅ Slot-based organization
- ✅ Built-in signals
- ✅ Equipment separation

---

## See Also

- [PPInventory](../api/inventory.md) - Main inventory class
- [PPInventorySlot](../api/inventory-slot.md) - Slot management
- [PPInventoryUtils](../utilities/inventory-utils.md) - Utility functions
- [PPItemEntity](../entities/item-entity.md) - Item system
- [PPRecipe](../properties/recipe.md) - Crafting integration

---

## Examples Repository

Find complete working examples at:
[github.com/trobugno/pandora_plus/examples/inventory](https://github.com/trobugno/pandora_plus/tree/main/examples/inventory)

---

*Complete System Guide for Pandora+ v1.1.0-core | v1.0.0-premium*