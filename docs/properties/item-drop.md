# PPItemDrop

**Extends:** `RefCounted`

Represents a potential item drop with a quantity range, used for loot tables and enemy drops.

---

## Description

`PPItemDrop` defines an item that can drop with a randomized quantity between a minimum and maximum value. It's primarily used in loot systems to determine what items enemies drop, what treasure chests contain, or what resources can be gathered.

Unlike `PPIngredient` (which has a fixed quantity), `PPItemDrop` uses a range to add variability to loot.

---

## Constructor

###### `PPItemDrop(reference: PandoraReference, min_quantity: int, max_quantity: int)`

Creates a new item drop with quantity range.

**Parameters:**
- `reference`: `PandoraReference` to the item entity
- `min_quantity`: Minimum number of items that can drop
- `max_quantity`: Maximum number of items that can drop

**Example:**
```gdscript
# Drop 1-3 gold coins
var gold = Pandora.get_entity("GOLD_COIN") as PPItemEntity
var gold_ref = PandoraReference.new(gold.get_entity_id(), PandoraReference.Type.ENTITY)
var drop = PPItemDrop.new(gold_ref, 1, 3)

# Drop exactly 1 sword (min = max)
var sword_ref = PandoraReference.new("IRON_SWORD", PandoraReference.Type.ENTITY)
var sword_drop = PPItemDrop.new(sword_ref, 1, 1)
```

---

## Methods

###### `get_item_entity() -> PPItemEntity`

Returns the item entity referenced by this drop.

**Returns:** `PPItemEntity` instance

**Example:**
```gdscript
var drop = PPItemDrop.new(gold_ref, 5, 10)
var item = drop.get_item_entity()

print("Drop: %s" % item.get_item_name())  # "Gold Coin"
```

---

###### `get_min_quantity() -> int`

Returns the minimum quantity that can drop.

**Returns:** Minimum quantity as integer

**Example:**
```gdscript
var drop = PPItemDrop.new(gold_ref, 5, 10)
print("Min drop: %d" % drop.get_min_quantity())  # 5
```

---

###### `get_max_quantity() -> int`

Returns the maximum quantity that can drop.

**Returns:** Maximum quantity as integer

**Example:**
```gdscript
var drop = PPItemDrop.new(gold_ref, 5, 10)
print("Max drop: %d" % drop.get_max_quantity())  # 10

# Generate random quantity in range
var quantity = randi_range(drop.get_min_quantity(), drop.get_max_quantity())
print("Dropped: %d coins" % quantity)
```

---

###### `set_entity(entity: PandoraEntity) -> void`

Updates the item entity reference.

**Parameters:**
- `entity`: New item entity to reference

**Example:**
```gdscript
var drop = PPItemDrop.new(gold_ref, 1, 5)

# Change to silver coins
var silver = Pandora.get_entity("SILVER_COIN") as PPItemEntity
drop.set_entity(silver)
```

---

###### `set_min_quantity(min_quantity: int) -> void`

Updates the minimum quantity.

**Parameters:**
- `min_quantity`: New minimum value

**Example:**
```gdscript
var drop = PPItemDrop.new(gold_ref, 1, 5)

# Increase min drop
drop.set_min_quantity(3)
print("New range: %d-%d" % [drop.get_min_quantity(), drop.get_max_quantity()])
# Output: "New range: 3-5"
```

---

###### `set_max_quantity(max_quantity: int) -> void`

Updates the maximum quantity.

**Parameters:**
- `max_quantity`: New maximum value

**Example:**
```gdscript
var drop = PPItemDrop.new(gold_ref, 1, 5)

# Increase max drop
drop.set_max_quantity(10)
print("New range: %d-%d" % [drop.get_min_quantity(), drop.get_max_quantity()])
# Output: "New range: 1-10"
```

---

###### `load_data(data: Dictionary) -> void`

Loads drop data from a serialized dictionary.

**Parameters:**
- `data`: Dictionary with `"item"`, `"min_quantity"`, and `"max_quantity"` keys

**Example:**
```gdscript
var saved_data = {
    "item": {
        "_entity_id": "GOLD_COIN",
        "_type": PandoraReference.Type.ENTITY
    },
    "min_quantity": 5,
    "max_quantity": 10
}

var drop = PPItemDrop.new(null, 0, 0)
drop.load_data(saved_data)
```

---

###### `save_data(fields_settings: Array[Dictionary]) -> Dictionary`

Serializes the drop to a dictionary.

**Parameters:**
- `fields_settings`: Array of field configuration dictionaries

**Returns:** Dictionary with drop data

> ⚠️ **Note:** There's a bug in the current implementation - the method always returns all fields regardless of `fields_settings`. The return statement at the end overrides the conditional logic.

**Example:**
```gdscript
var drop = PPItemDrop.new(gold_ref, 5, 10)
var data = drop.save_data(fields_settings)

# Result:
# {
#     "item": {"_entity_id": "GOLD_COIN", "_type": 1},
#     "min_quantity": 5,
#     "max_quantity": 10
# }
```

---

###### `_to_string() -> String`

Returns a string representation of the drop.

**Returns:** String in format `"<PPItemDrop[item]>"`

**Example:**
```gdscript
var drop = PPItemDrop.new(gold_ref, 1, 5)
print(drop)
# Output: "<PPItemDrop<PPItemEntity:GOLD_COIN>>"
```

---

## Usage Example

### Example 1: Treasure Chest

```gdscript
class_name TreasureChest

@export var chest_tier: String = "COMMON"  # COMMON, RARE, LEGENDARY
var contents: Array[PPItemDrop] = []

func _ready():
    _generate_contents()

func _generate_contents():
    match chest_tier:
        "COMMON":
            contents = [
                _create_drop("GOLD_COIN", 10, 25),
                _create_drop("HEALTH_POTION", 1, 3)
            ]
        
        "RARE":
            contents = [
                _create_drop("GOLD_COIN", 50, 100),
                _create_drop("HEALTH_POTION", 3, 5),
                _create_drop("IRON_SWORD", 1, 1)
            ]
        
        "LEGENDARY":
            contents = [
                _create_drop("GOLD_COIN", 200, 500),
                _create_drop("LEGENDARY_SWORD", 1, 1),
                _create_drop("RARE_GEM", 1, 3)
            ]

func _create_drop(item_id: String, min_qty: int, max_qty: int) -> PPItemDrop:
    var item = Pandora.get_entity(item_id) as PPItemEntity
    var ref = PandoraReference.new(item.get_entity_id(), PandoraReference.Type.ENTITY)
    return PPItemDrop.new(ref, min_qty, max_qty)

func open(player_inventory: PPInventory):
    print("Opening %s chest..." % chest_tier)
    
    for drop in contents:
        var item = drop.get_item_entity()
        var quantity = randi_range(drop.get_min_quantity(), drop.get_max_quantity())
        
        player_inventory.add_item(item, quantity)
        print("Found: %dx %s" % [quantity, item.get_item_name()])
```
---

## Integration with PPInventoryUtils

```gdscript
# PPInventoryUtils has helper for item drops
var drops: Array[PPItemDrop] = [
    PPItemDrop.new(gold_ref, 10, 20),
    PPItemDrop.new(potion_ref, 1, 3)
]

# Generate and add loot to inventory
var loot = PPInventoryUtils.add_loot_drops(player_inventory, drops)

print("Loot generated:")
for item_data in loot:
    print("  %dx %s" % [item_data["quantity"], item_data["item_id"]])
```

---

## Serialization

### Save Format

```json
{
    "item": {
        "_entity_id": "GOLD_COIN",
        "_type": 1
    },
    "min_quantity": 5,
    "max_quantity": 10
}
```

---

## Best Practices

### ✅ Validate Quantity Range

```gdscript
# ✅ Good: ensure min <= max
func create_drop_safe(item: PPItemEntity, min_qty: int, max_qty: int) -> PPItemDrop:
    assert(min_qty >= 0, "Min quantity must be >= 0")
    assert(max_qty >= min_qty, "Max quantity must be >= min quantity")
    
    var ref = PandoraReference.new(item.get_entity_id(), PandoraReference.Type.ENTITY)
    return PPItemDrop.new(ref, min_qty, max_qty)

# ❌ Bad: invalid ranges
var drop = PPItemDrop.new(ref, 10, 5)  # Max < Min!
var drop = PPItemDrop.new(ref, -5, 10) # Negative min!
```

---

### ✅ Use Min=0 for Optional Drops

```gdscript
# ✅ Good: may drop 0-2 items
var optional_drop = PPItemDrop.new(rare_item_ref, 0, 2)

var quantity = randi_range(optional_drop.get_min_quantity(), optional_drop.get_max_quantity())
if quantity > 0:
    inventory.add_item(item, quantity)
else:
    print("No rare item this time")
```

---

### ✅ Fixed Quantities (Min = Max)

```gdscript
# ✅ Good: guaranteed exact quantity
var guaranteed_drop = PPItemDrop.new(quest_item_ref, 1, 1)  # Always 1

# This is different from PPIngredient:
# - PPItemDrop: for loot with potential variance
# - PPIngredient: for recipes with fixed requirements
```

---

### ✅ Reasonable Ranges

```gdscript
# ✅ Good: reasonable variance
PPItemDrop.new(gold_ref, 10, 15)      # ±25% variance
PPItemDrop.new(arrow_ref, 5, 10)      # 2x variance
PPItemDrop.new(potion_ref, 1, 3)      # 3x variance

# ⚠️ Questionable: extreme variance
PPItemDrop.new(gold_ref, 1, 1000)     # 1000x variance - feels random
```

---

## Known Issues

### Bug in save_data()

The current implementation has a bug:

```gdscript
func save_data(fields_settings: Array[Dictionary]) -> Dictionary:
    var result := {}
    # ... conditional logic based on fields_settings ...
    
    # ⚠️ BUG: This line overrides everything above
    return { "item": _reference.save_data(), "min_quantity": _min_quantity, "max_quantity": _max_quantity }
```

**Impact:** The `fields_settings` parameter is ignored, and all fields are always saved.

**Workaround:** None needed unless you specifically need conditional serialization.

---

## Difference from PPIngredient

| Aspect | PPItemDrop | PPIngredient |
|--------|-----------|--------------|
| **Purpose** | Loot generation | Recipe requirements |
| **Quantity** | Range (min-max) | Fixed amount |
| **Variability** | Random in range | Always same |
| **Use Case** | Enemy drops, chests | Crafting recipes |
| **Typical Use** | `randi_range(min, max)` | Direct quantity usage |

---

## Notes

### RefCounted Class

Like other property classes, `PPItemDrop` extends `RefCounted`:
- ✅ Automatic garbage collection
- ✅ Lightweight
- ❌ Not exportable in Inspector
- ❌ Cannot save as `.tres` file

---

### Zero Quantities

Setting `min_quantity = 0` is valid and useful for optional drops:
```gdscript
var rare_drop = PPItemDrop.new(item_ref, 0, 1)
# 50% chance to drop 0 items, 50% chance to drop 1 item
```

---

## See Also

- [PPIngredient](../properties/ingredient.md) - Similar class for recipes
- [PPItemEntity](../entities/item-entity.md) - Item entities
- [PPInventoryUtils](../utilities/inventory-utils.md) - Loot generation helpers
- [Inventory System](../core-systems/inventory-system.md) - Inventory system

---

*API Reference generated from source code v1.0.0-core | v1.0.0-premium*