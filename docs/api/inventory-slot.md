# PPInventorySlot

**Extends:** `Resource`

Represents a single inventory slot containing an item and its quantity, with stack management capabilities.

---

## Description

`PPInventorySlot` is the container class for items in the inventory system. Each slot holds one type of item and tracks its quantity, enforcing stack limits and providing merge operations for stackable items. Slots are used by `PPInventory` to organize items.

The class automatically validates stackability and prevents non-stackable items from having quantities greater than 1.

---

## Constants

###### `MAX_STACK_SIZE: int = 99`

Maximum number of items that can be stacked in a single slot.

**Default:** `99`

---

## Properties

###### `item: PPItemEntity`

The item entity stored in this slot.

**Type:** `PPItemEntity`

---

###### `quantity: int`

Number of items in this slot. Range: 1 to `MAX_STACK_SIZE`.

**Type:** `int`  
**Range:** `1` - `99`  
**Setter:** `set_quantity()`

---

## Methods

###### `set_quantity(value: int) -> void`

Sets the quantity of items in the slot, with validation for non-stackable items.

**Parameters:**
- `value`: New quantity

**Behavior:**
- If item is not stackable and value > 1, forces quantity to 1
- Pushes error when attempting to stack non-stackable items

**Example:**
```gdscript
var slot = PPInventorySlot.new()
slot.item = stackable_potion
slot.quantity = 50  # OK

var unique_slot = PPInventorySlot.new()
unique_slot.item = unique_sword  # Not stackable
unique_slot.quantity = 5  # Error: forces to 1
```

---

###### `can_merge_with(other_slot: PPInventorySlot) -> bool`

Checks if this slot can merge with another slot (may result in overflow).

**Parameters:**
- `other_slot`: The slot to check merging with

**Returns:** `true` if slots can merge

**Conditions:**
- Items must have the same ID
- Item must be stackable
- Current quantity must be less than `MAX_STACK_SIZE`

**Example:**
```gdscript
var slot1 = PPInventorySlot.new()
slot1.item = potion
slot1.quantity = 70

var slot2 = PPInventorySlot.new()
slot2.item = potion
slot2.quantity = 50

if slot1.can_merge_with(slot2):
    print("Can merge, but will overflow")
```

---

###### `can_fully_merge_with(other_slot: PPInventorySlot) -> bool`

Checks if this slot can fully merge with another without exceeding stack limit.

**Parameters:**
- `other_slot`: The slot to check merging with

**Returns:** `true` if slots can fully merge without overflow

**Conditions:**
- Items must have the same ID
- Item must be stackable
- Combined quantity must not exceed `MAX_STACK_SIZE`

**Example:**
```gdscript
var slot1 = PPInventorySlot.new()
slot1.item = potion
slot1.quantity = 30

var slot2 = PPInventorySlot.new()
slot2.item = potion
slot2.quantity = 20

if slot1.can_fully_merge_with(slot2):
    print("Can merge completely: 30 + 20 = 50 <= 99")
    slot1.fully_merge_with(slot2)
```

---

###### `fully_merge_with(other_slot: PPInventorySlot) -> void`

Merges all items from another slot into this slot without overflow check.

**Parameters:**
- `other_slot`: The slot to merge from

**Behavior:**
- Adds `other_slot.quantity` to this slot's quantity
- Does not modify or clear `other_slot`
- **Warning:** Does not validate stack limits

**Example:**
```gdscript
var slot1 = PPInventorySlot.new()
slot1.item = arrow
slot1.quantity = 40

var slot2 = PPInventorySlot.new()
slot2.item = arrow
slot2.quantity = 30

slot1.fully_merge_with(slot2)
print(slot1.quantity)  # Output: 70
print(slot2.quantity)  # Output: 30 (unchanged)
```

---

###### `merge_with(other_slot: PPInventorySlot) -> void`

Safely merges items from another slot, respecting stack limits.

**Parameters:**
- `other_slot`: The slot to merge from

**Behavior:**
- Transfers as many items as possible without exceeding `MAX_STACK_SIZE`
- Updates both slots' quantities appropriately
- If full merge possible, `other_slot.quantity` becomes 0
- If partial merge, remaining items stay in `other_slot`

**Example:**
```gdscript
var slot1 = PPInventorySlot.new()
slot1.item = potion
slot1.quantity = 80  # Close to max

var slot2 = PPInventorySlot.new()
slot2.item = potion
slot2.quantity = 30

slot1.merge_with(slot2)
print(slot1.quantity)  # Output: 99 (maxed out)
print(slot2.quantity)  # Output: 11 (remaining items)
```

---

###### `create_single_slot() -> PPInventorySlot`

Creates a new slot with quantity 1, removing one item from this slot.

**Returns:** New `PPInventorySlot` with quantity 1

**Behavior:**
- Duplicates the slot resource
- Sets new slot quantity to 1
- Decrements this slot's quantity by 1

**Example:**
```gdscript
var original_slot = PPInventorySlot.new()
original_slot.item = potion
original_slot.quantity = 10

var single_slot = original_slot.create_single_slot()
print(original_slot.quantity)  # Output: 9
print(single_slot.quantity)    # Output: 1
```

---

## Usage Example

### Example: Basic Slot Management

```gdscript
func create_item_slot(item: PPItemEntity, qty: int) -> PPInventorySlot:
    var slot = PPInventorySlot.new()
    slot.item = item
    slot.quantity = qty
    
    if not item.is_stackable() and qty > 1:
        push_warning("Creating slot for non-stackable item with qty > 1")
    
    return slot

func display_slot_info(slot: PPInventorySlot):
    if not slot or not slot.item:
        print("Empty slot")
        return
    
    print("%s x%d" % [slot.item.get_item_name(), slot.quantity])
    
    if slot.quantity >= PPInventorySlot.MAX_STACK_SIZE:
        print("(FULL STACK)")
```

---

## Best Practices

### ✅ Always Validate Before Merging

```gdscript
# ✅ Good: check before merging
if slot1.can_fully_merge_with(slot2):
    slot1.fully_merge_with(slot2)
else:
    slot1.merge_with(slot2)  # Use safe merge

# ❌ Bad: merge without checking
slot1.fully_merge_with(slot2)  # May exceed MAX_STACK_SIZE
```

---

### ✅ Check Null Slots

```gdscript
# ✅ Good: null checking
func process_slot(slot: PPInventorySlot):
    if not slot or not slot.item:
        return
    
    print(slot.item.get_item_name())

# ❌ Bad: assume slot is valid
func process_slot(slot: PPInventorySlot):
    print(slot.item.get_item_name())  # May crash
```

---

### ✅ Respect Stackability

```gdscript
# ✅ Good: check if stackable
if item.is_stackable():
    slot.quantity = 50
else:
    slot.quantity = 1

# ❌ Bad: ignore stackability
slot.quantity = 10  # Error if item not stackable
```

---

## Common Patterns

### Pattern 1: Stack Overflow Handling

```gdscript
func add_to_slot_with_overflow(slot: PPInventorySlot, amount: int) -> int:
    var space_left = PPInventorySlot.MAX_STACK_SIZE - slot.quantity
    
    if amount <= space_left:
        slot.quantity += amount
        return 0  # No overflow
    else:
        slot.quantity = PPInventorySlot.MAX_STACK_SIZE
        return amount - space_left  # Return overflow amount
```

---

### Pattern 2: Slot Validation

```gdscript
func is_slot_valid(slot: PPInventorySlot) -> bool:
    if not slot:
        return false
    
    if not slot.item:
        return false
    
    if slot.quantity < 1:
        return false
    
    if slot.quantity > PPInventorySlot.MAX_STACK_SIZE:
        push_warning("Slot quantity exceeds max")
        return false
    
    if not slot.item.is_stackable() and slot.quantity > 1:
        push_error("Non-stackable item has quantity > 1")
        return false
    
    return true
```

---

### Pattern 3: Slot Comparison

```gdscript
func are_slots_compatible(slot1: PPInventorySlot, slot2: PPInventorySlot) -> bool:
    if not slot1 or not slot2:
        return false
    
    if not slot1.item or not slot2.item:
        return false
    
    return slot1.item._id == slot2.item._id

func get_total_quantity(slots: Array[PPInventorySlot], item: PPItemEntity) -> int:
    var total = 0
    
    for slot in slots:
        if slot and slot.item and slot.item._id == item._id:
            total += slot.quantity
    
    return total
```

---

## Notes

### MAX_STACK_SIZE Modification

If you need different stack sizes per item:

```gdscript
# Option 1: Add property to PPItemEntity
class_name PPItemEntity
var custom_stack_size: int = 99

# Option 2: Check item type in setter
func set_quantity(value: int) -> void:
    var max_size = PPInventorySlot.MAX_STACK_SIZE
    if item and item.has_method("get_max_stack_size"):
        max_size = item.get_max_stack_size()
    
    quantity = min(value, max_size)
```

---

### Resource vs RefCounted

`PPInventorySlot` extends `Resource`:
- ✅ Can be saved as `.tres` files
- ✅ Exportable in Inspector
- ✅ Can use `duplicate()` method
- ⚠️ Manual memory management (use `duplicate()` carefully)

---

### Merge Operations Safety

**fully_merge_with():**
- Fast but unsafe
- Use only when `can_fully_merge_with()` returns `true`
- No validation or overflow protection

**merge_with():**
- Safe but slightly slower
- Automatically handles overflow
- Always preserves stack limits

---

## See Also

- [PPInventory](../api/inventory.md) - Inventory management
- [PPInventoryUtils](../utilities/inventory-utils.md) - Utility functions
- [PPItemEntity](../entities/item-entity.md) - Item system
- [Inventory System](../core-systems/inventory-system.md) - Complete system overview

---

*API Reference generated from source code*