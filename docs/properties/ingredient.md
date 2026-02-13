# PPIngredient

**Extends:** `RefCounted`

Represents a single ingredient in a crafting recipe, linking an item entity with a required quantity.

---

## Description

`PPIngredient` is a lightweight class that pairs a `PPItemEntity` with a quantity value. It's used in `PPRecipe` to define what items are needed for crafting.

Unlike `PPIngredientEntity` (which is a Pandora entity), `PPIngredient` is a runtime property class designed for recipe definitions.

---

## Constructor

###### `PPIngredient(reference: Variant, quantity: int)`

Creates a new ingredient with an item reference and quantity.

**Parameters:**
- `reference`: Either a `PandoraReference` or `PandoraEntity` (will be converted to reference)
- `quantity`: Number of items required

**Example:**
```gdscript
# From PandoraEntity
var wood = Pandora.get_entity("WOOD") as PPItemEntity
var ingredient = PPIngredient.new(wood, 5)

# From PandoraReference
var wood_ref = PandoraReference.new("WOOD", PandoraReference.Type.ENTITY)
var ingredient = PPIngredient.new(wood_ref, 5)
```

**Assertion:** The first parameter **must** be either `PandoraReference` or `PandoraEntity`, otherwise throws an assertion error.

---

## Methods

###### `get_item_entity() -> PPItemEntity`

Returns the item entity referenced by this ingredient.

**Returns:** `PPItemEntity` instance

**Example:**
```gdscript
var ingredient = PPIngredient.new(wood_entity, 5)
var item = ingredient.get_item_entity()

print("Ingredient: %s" % item.get_item_name())  # "Wood"
```

---

###### `get_quantity() -> int`

Returns the required quantity of this ingredient.

**Returns:** Quantity as integer

**Example:**
```gdscript
var ingredient = PPIngredient.new(wood_entity, 5)
print("Need %d %s" % [
    ingredient.get_quantity(),
    ingredient.get_item_entity().get_item_name()
])
# Output: "Need 5 Wood"
```

---

###### `set_entity(entity: PandoraEntity) -> void`

Updates the item entity reference.

**Parameters:**
- `entity`: New item entity to reference

**Example:**
```gdscript
var ingredient = PPIngredient.new(wood, 5)

# Change to stone
var stone = Pandora.get_entity("STONE") as PPItemEntity
ingredient.set_entity(stone)
```

---

###### `set_quantity(quantity: int) -> void`

Updates the required quantity.

**Parameters:**
- `quantity`: New quantity value

**Example:**
```gdscript
var ingredient = PPIngredient.new(wood, 5)

# Increase requirement
ingredient.set_quantity(10)
print("Now need: ", ingredient.get_quantity())  # 10
```

---

###### `load_data(data: Dictionary) -> void`

Loads ingredient data from a serialized dictionary.

**Parameters:**
- `data`: Dictionary with `"item"` and `"quantity"` keys

**Example:**
```gdscript
var saved_data = {
    "item": {
        "_entity_id": "WOOD",
        "_type": PandoraReference.Type.ENTITY
    },
    "quantity": 5
}

var ingredient = PPIngredient.new(null, 0)
ingredient.load_data(saved_data)
```

---

###### `save_data(fields_settings: Array[Dictionary]) -> Dictionary`

Serializes the ingredient to a dictionary.

**Parameters:**
- `fields_settings`: Array of field configuration dictionaries (from Pandora settings)

**Returns:** Dictionary with ingredient data

**Example:**
```gdscript
var ingredient = PPIngredient.new(wood, 5)
var data = ingredient.save_data(fields_settings)

# Result:
# {
#     "item": {"_entity_id": "WOOD", "_type": 1},
#     "quantity": 5
# }
```

---

###### `_to_string() -> String`

Returns a string representation of the ingredient.

**Returns:** String in format `"<PPIngredient [item]>"`

**Example:**
```gdscript
var ingredient = PPIngredient.new(wood, 5)
print(ingredient)
# Output: "<PPIngredient <PPItemEntity:WOOD>>"
```

---

## Usage Examples

### Example 1: Creating Recipe Ingredients

```gdscript
func create_stone_sword_recipe():
    # Get item entities
    var wood = Pandora.get_entity("WOOD") as PPItemEntity
    var stone = Pandora.get_entity("STONE") as PPItemEntity
    var sword = Pandora.get_entity("STONE_SWORD") as PPItemEntity
    
    # Create ingredients
    var wood_ingredient = PPIngredient.new(wood, 2)
    var stone_ingredient = PPIngredient.new(stone, 3)
    
    # Create recipe
    var result_ref = PandoraReference.new(sword.get_entity_id(), PandoraReference.Type.ENTITY)
    var recipe = PPRecipe.new(
        [wood_ingredient, stone_ingredient],
        result_ref,
        5.0,  # 5 seconds crafting time
        "WEAPON"
    )
    
    return recipe
```

---

### Example 2: Checking Ingredient Availability

```gdscript
func has_ingredients(inventory: PPInventory, ingredients: Array[PPIngredient]) -> bool:
    for ingredient in ingredients:
        var item = ingredient.get_item_entity()
        var required = ingredient.get_quantity()
        var available = inventory.count_item(item)
        
        if available < required:
            print("Missing: %s (need %d, have %d)" % [
                item.get_item_name(),
                required,
                available
            ])
            return false
    
    return true
```

---

### Example 3: Displaying Recipe Requirements

```gdscript
func display_recipe_ingredients(recipe: PPRecipe, label: Label):
    var ingredients = recipe.get_ingredients()
    var text = "Required materials:\n"
    
    for ingredient in ingredients:
        var item = ingredient.get_item_entity()
        text += "  • %dx %s\n" % [
            ingredient.get_quantity(),
            item.get_item_name()
        ]
    
    label.text = text

# Output:
# Required materials:
#   • 2x Wood
#   • 3x Stone
```

---

## Integration with PPRecipe

```gdscript
# PPIngredient is designed to work with PPRecipe
var wood_ing = PPIngredient.new(wood, 5)
var stone_ing = PPIngredient.new(stone, 3)

var recipe = PPRecipe.new(
    [wood_ing, stone_ing],  # Array of PPIngredient
    result_reference,
    10.0,
    "CRAFTING"
)

# Access ingredients from recipe
for ingredient in recipe.get_ingredients():
    var item = ingredient.get_item_entity()
    var qty = ingredient.get_quantity()
    print("Need: %d %s" % [qty, item.get_item_name()])
```

---

## Serialization

### Save Format

```json
{
    "item": {
        "_entity_id": "WOOD",
        "_type": 1
    },
    "quantity": 5
}
```

### Field Settings

The `save_data()` method respects Pandora field settings:

```gdscript
fields_settings = [
    {"name": "Item", "enabled": true},
    {"name": "Quantity", "enabled": true}
]
```

If a field is disabled (`"enabled": false`), it won't be saved.

---

## Best Practices

### ✅ Use Entity References

```gdscript
# ✅ Good: use actual entities
var wood = Pandora.get_entity("WOOD") as PPItemEntity
var ingredient = PPIngredient.new(wood, 5)

# ❌ Bad: don't try to use strings
var ingredient = PPIngredient.new("WOOD", 5)  # Won't work!
```

---

### ✅ Validate Quantities

```gdscript
# ✅ Good: ensure positive quantities
func create_ingredient(item: PPItemEntity, qty: int) -> PPIngredient:
    assert(qty > 0, "Quantity must be positive")
    return PPIngredient.new(item, qty)

# ❌ Bad: allow zero or negative
var ingredient = PPIngredient.new(wood, 0)  # Makes no sense
var ingredient = PPIngredient.new(wood, -5)  # Invalid
```

---

### ✅ Cache Ingredient Arrays

```gdscript
# ✅ Good: create once
var recipe_ingredients: Array[PPIngredient] = []

func _ready():
    recipe_ingredients = [
        PPIngredient.new(wood, 2),
        PPIngredient.new(stone, 3)
    ]

# ❌ Bad: recreate every time
func get_ingredients() -> Array[PPIngredient]:
    return [
        PPIngredient.new(Pandora.get_entity("WOOD"), 2),  # Slow!
        PPIngredient.new(Pandora.get_entity("STONE"), 3)
    ]
```

---

## Difference from PPIngredientEntity

| Aspect | PPIngredient | PPIngredientEntity |
|--------|--------------|-------------------|
| **Extends** | `RefCounted` | `PandoraEntity` |
| **Purpose** | Runtime property | Pandora data entity |
| **Storage** | In memory only | Stored in Pandora |
| **Usage** | Recipe definitions | Ingredient templates |
| **Serialization** | Via `save_data()` | Via Pandora system |

**When to use:**
- Use `PPIngredient` for recipe definitions (most common)
- Use `PPIngredientEntity` if you need to store ingredient templates in Pandora

---

## Notes

### RefCounted vs Resource

`PPIngredient` extends `RefCounted` instead of `Resource`, which means:
- ✅ Automatically garbage collected
- ✅ Lightweight (no Resource overhead)
- ❌ Cannot be saved as `.tres` file
- ❌ Cannot be exported directly in Inspector

This is intentional - ingredients are meant to be created programmatically as part of recipes.

---

### Assertion on Constructor

The constructor has an assertion:
```gdscript
assert(reference is PandoraReference or reference is PandoraEntity, 
       "First parameter must be PandoraReference or PandoraEntity")
```

This ensures type safety at creation time. In release builds, assertions are disabled, so validate inputs manually if needed.

---

## See Also

- [PPRecipe](../properties/recipe.md) - Recipe system that uses ingredients
- [PPIngredientEntity](../entities/ingredient-entity.md) - Pandora entity version
- [PPItemEntity](../entities/item-entity.md) - Item entities used in ingredients
- [PPRecipeUtils](../utilities/recipe-utils.md) - Recipe validation utilities

---

*API Reference generated from source code v1.1.1-core | v1.0.0-premium*