# PPIngredientEntity

**Extends:** `PandoraEntity`

A Pandora entity that represents an ingredient template with item type and quantity.

---

## Description

`PPIngredientEntity` is a Pandora entity version of an ingredient. Unlike `PPIngredient` (which is a runtime `RefCounted` class), this entity is stored in Pandora's database and can be reused across multiple recipes.

**Use Case:** When you want to store ingredient templates in Pandora rather than creating them programmatically.

---

## Properties

Stored in Pandora:

| Property | Type | Description |
|----------|------|-------------|
| `item_type` | `PPItemEntity` | Reference to the item |
| `quantity` | `int` | Required quantity |

> 💡 These properties are accessed via getter methods.

---

## Methods

###### `get_item() -> PPItemEntity`

Returns the item entity referenced by this ingredient.

**Returns:** `PPItemEntity` or `null` if not set

**Example:**
```gdscript
var ingredient_entity = Pandora.get_entity("ING_WOOD_5") as PPIngredientEntity
var item = ingredient_entity.get_item()

if item:
    print("Ingredient: %s" % item.get_item_name())
```

---

###### `get_quantity() -> int`

Returns the required quantity.

**Returns:** Quantity as integer

**Example:**
```gdscript
var ingredient_entity = Pandora.get_entity("ING_WOOD_5") as PPIngredientEntity
print("Need %d %s" % [
    ingredient_entity.get_quantity(),
    ingredient_entity.get_item().get_item_name()
])
# Output: "Need 5 Wood"
```

---

## Creating Ingredient Entities

### In Pandora Editor

1. Open **Pandora Editor**
2. Go to **Ingredients** category
3. Click **Create Entity**
4. Select **PPIngredientEntity** as type
5. Fill properties:

```
Entity ID: ING_WOOD_5
Type: PPIngredientEntity

Properties:
├── item_type: [Reference to WOOD]
└── quantity: 5
```

### Via GDScript

```gdscript
# Get Ingredients category
var ingredients_category = Pandora.get_category("Ingredients")

# Create entity
var ingredient = Pandora.create_entity(ingredients_category, "ING_WOOD_5") as PPIngredientEntity

# Set properties
var wood = Pandora.get_entity("WOOD") as PPItemEntity
ingredient.set_reference("item_type", wood)
ingredient.set_integer("quantity", 5)

# Save
Pandora.save_data()
```

---

## Usage Examples

### Example 1: Using with Recipes

```gdscript
# Load ingredient entities from Pandora
var wood_5 = Pandora.get_entity("ING_WOOD_5") as PPIngredientEntity
var stone_3 = Pandora.get_entity("ING_STONE_3") as PPIngredientEntity

# Convert to PPIngredient for recipe
var wood_ingredient = PPIngredient.new(
    wood_5.get_item(),
    wood_5.get_quantity()
)

var stone_ingredient = PPIngredient.new(
    stone_3.get_item(),
    stone_3.get_quantity()
)

# Create recipe
var recipe = PPRecipe.new(
    [wood_ingredient, stone_ingredient],
    result_ref,
    5.0,
    "WEAPON"
)
```

---

### Example 2: Ingredient Library

```gdscript
class_name IngredientLibrary

# Store common ingredient entities
var WOOD_5: PPIngredientEntity
var STONE_3: PPIngredientEntity
var IRON_2: PPIngredientEntity

func _ready():
    _load_ingredients()

func _load_ingredients():
    WOOD_5 = Pandora.get_entity("ING_WOOD_5") as PPIngredientEntity
    STONE_3 = Pandora.get_entity("ING_STONE_3") as PPIngredientEntity
    IRON_2 = Pandora.get_entity("ING_IRON_2") as PPIngredientEntity

func create_basic_sword_recipe() -> PPRecipe:
    return PPRecipe.new(
        [
            to_ingredient(WOOD_5),
            to_ingredient(STONE_3)
        ],
        sword_ref,
        5.0,
        "WEAPON"
    )

func to_ingredient(entity: PPIngredientEntity) -> PPIngredient:
    return PPIngredient.new(
        entity.get_item(),
        entity.get_quantity()
    )
```

---

## Comparison: PPIngredient vs PPIngredientEntity

| Aspect | PPIngredient | PPIngredientEntity |
|--------|--------------|-------------------|
| **Base Class** | `RefCounted` | `PandoraEntity` |
| **Storage** | Runtime only | Stored in Pandora |
| **Creation** | Programmatic | Pandora Editor or code |
| **Reusability** | Single use | Reusable template |
| **Use Case** | Direct recipe creation | Ingredient library |
| **Serialization** | Manual (save_data) | Automatic (Pandora) |

---

## When to Use

### Use PPIngredientEntity when:
- ✅ You want to manage ingredients in Pandora Editor
- ✅ You need reusable ingredient templates
- ✅ You want to reference the same ingredient in multiple recipes
- ✅ You need to edit ingredients without touching code

### Use PPIngredient when:
- ✅ Creating recipes programmatically
- ✅ You don't need persistence
- ✅ Ingredients are unique to a recipe
- ✅ You want lightweight runtime objects

---

## Best Practices

### ✅ Naming Convention

```gdscript
# ✅ Good: descriptive IDs
"ING_WOOD_5"      # 5x Wood
"ING_STONE_10"    # 10x Stone
"ING_IRON_BAR_3"  # 3x Iron Bar

# ❌ Bad: unclear IDs
"INGREDIENT_1"
"ING_A"
"WOOD_THING"
```

---

### ✅ Consistent Quantities

```gdscript
# ✅ Good: standard quantities
ING_WOOD_1   # 1x Wood
ING_WOOD_5   # 5x Wood
ING_WOOD_10  # 10x Wood

# ❌ Bad: random quantities
ING_WOOD_7
ING_WOOD_13
ING_WOOD_47
```

---

### ✅ Validate Before Use

```gdscript
# ✅ Good: check for null
var ing_entity = Pandora.get_entity("ING_WOOD_5") as PPIngredientEntity
if ing_entity and ing_entity.get_item():
    var ingredient = PPIngredient.new(
        ing_entity.get_item(),
        ing_entity.get_quantity()
    )
```

---

## Integration Pattern

```gdscript
class_name RecipeManager

# Cache ingredient entities
var ingredient_entities: Dictionary = {}

func _ready():
    _load_ingredient_entities()

func _load_ingredient_entities():
    var category = Pandora.get_category("Ingredients")
    var all_ingredients = Pandora.get_all_entities(category)
    
    for entity in all_ingredients:
        var ing = entity as PPIngredientEntity
        if ing:
            ingredient_entities[entity.get_entity_id()] = ing

func create_recipe_from_entities(
    ingredient_ids: Array[String],
    result_id: String,
    time: float,
    type: String
) -> PPRecipe:
    var ingredients: Array[PPIngredient] = []
    
    for id in ingredient_ids:
        var entity = ingredient_entities.get(id) as PPIngredientEntity
        if entity:
            ingredients.append(PPIngredient.new(
                entity.get_item(),
                entity.get_quantity()
            ))
    
    var result = Pandora.get_entity(result_id) as PPItemEntity
    var result_ref = PandoraReference.new(result.get_entity_id(), PandoraReference.Type.ENTITY)
    
    return PPRecipe.new(ingredients, result_ref, time, type)

# Usage
func _example():
    var sword_recipe = create_recipe_from_entities(
        ["ING_WOOD_5", "ING_STONE_3"],
        "STONE_SWORD",
        5.0,
        "WEAPON"
    )
```

---

## Notes

### @tool Annotation

The `@tool` annotation allows:
- Preview in Pandora Editor
- Edit properties visually
- Real-time validation

---

### Storage Location

Ingredient entities are stored in Pandora's data system, typically in a category named "Ingredients" or similar.

---

### Performance Consideration

If using many `PPIngredientEntity` objects, cache them on startup rather than calling `Pandora.get_entity()` repeatedly.

---

## See Also

- [PPIngredient](../properties/ingredient.md) - Runtime ingredient class
- [PPRecipe](../properties/recipe.md) - Recipe system
- [PPItemEntity](../entities/item-entity.md) - Item entities
- [Pandora Documentation](https://bitbra.in/pandora) - Entity system

---

*API Reference generated from source code v1.1.0-core | v1.0.0-premium*