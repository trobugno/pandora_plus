# PPRecipeEntity

**Extends:** `PandoraEntity`

Entity class for recipes defined in the `ItemRecipes` Pandora category.

---

## Description

`PPRecipeEntity` represents a craftable recipe in your game. It wraps a `PPRecipe` property and provides convenient accessor methods for recipe data, ingredients, and waste products.

Recipes are defined in the Pandora editor under the `ItemRecipes` category and can be organized into subcategories (e.g., "Alchemy", "Cooking", "Smithing").

---

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `description` | `String` | A text description of the recipe |
| `recipe_property` | `PPRecipe` | The recipe data containing ingredients, result, crafting time, and type |

---

## Methods

###### `get_description() -> String`

Returns the recipe's description.

**Returns:** The description string

**Example:**
```gdscript
var recipe_entity = Pandora.get_entity("IRON_SWORD_RECIPE") as PPRecipeEntity
print(recipe_entity.get_description())
# Output: "Forge an iron sword from iron ingots and leather"
```

---

###### `get_recipe_property() -> PPRecipe`

Returns the underlying `PPRecipe` object containing all recipe data.

**Returns:** The `PPRecipe` instance

**Example:**
```gdscript
var recipe_entity = Pandora.get_entity("HEALTH_POTION_RECIPE") as PPRecipeEntity
var recipe = recipe_entity.get_recipe_property()

print("Result: %s" % recipe.get_result().get_item_name())
print("Crafting time: %.1f seconds" % recipe.get_crafting_time())
print("Type: %s" % recipe.get_recipe_type())
```

---

###### `get_waste() -> PPIngredient`

Returns the waste product of the recipe, if defined.

**Returns:** The waste `PPIngredient`, or `null` if no waste is defined

**Example:**
```gdscript
var recipe_entity = Pandora.get_entity("IRON_INGOT_RECIPE") as PPRecipeEntity
var waste = recipe_entity.get_waste()

if waste:
    print("Produces waste: %d %s" % [
        waste.get_quantity(),
        waste.get_item_entity().get_item_name()
    ])
else:
    print("No waste product")
```

---

###### `get_recipe() -> Array[PPInventorySlot]`

Returns the recipe ingredients as an array of inventory slots, ready for UI display or inventory operations.

**Returns:** An array of `PPInventorySlot` containing the required items and quantities

**Example:**
```gdscript
var recipe_entity = Pandora.get_entity("STEEL_SWORD_RECIPE") as PPRecipeEntity
var ingredients = recipe_entity.get_recipe()

print("Ingredients needed:")
for slot in ingredients:
    print("  - %d x %s" % [slot.quantity, slot.item.get_item_name()])
```

---

## Usage Examples

### Example 1: Displaying Recipe in UI

```gdscript
class_name RecipeTooltip
extends Control

@onready var description_label = $DescriptionLabel
@onready var ingredients_list = $IngredientsList
@onready var result_icon = $ResultIcon
@onready var waste_label = $WasteLabel

func show_recipe(recipe_entity: PPRecipeEntity):
    # Description
    description_label.text = recipe_entity.get_description()

    # Ingredients
    ingredients_list.clear()
    for slot in recipe_entity.get_recipe():
        ingredients_list.add_item("%d x %s" % [
            slot.quantity,
            slot.item.get_item_name()
        ])

    # Result
    var recipe = recipe_entity.get_recipe_property()
    result_icon.texture = recipe.get_result().get_texture()

    # Waste (if any)
    var waste = recipe_entity.get_waste()
    if waste:
        waste_label.text = "Produces: %d %s" % [
            waste.get_quantity(),
            waste.get_item_entity().get_item_name()
        ]
        waste_label.visible = true
    else:
        waste_label.visible = false
```

---

### Example 2: Crafting with PPRecipeEntity

```gdscript
func craft_from_entity(recipe_entity: PPRecipeEntity, inventory: PPInventory) -> bool:
    var recipe = recipe_entity.get_recipe_property()

    # Check if can craft
    if not PPRecipeUtils.can_craft(inventory, recipe):
        print("Missing ingredients for: %s" % recipe_entity.get_description())
        return false

    # Execute craft
    return PPRecipeUtils.craft_recipe(inventory, recipe)
```

---

### Example 3: Recipe Browser

```gdscript
class_name RecipeBrowser
extends Control

@export var recipe_type_filter: String = ""

var displayed_recipes: Array[PPRecipeEntity] = []

func _ready():
    load_recipes()

func load_recipes():
    if recipe_type_filter.is_empty():
        # Show all recipes
        displayed_recipes = PPRecipeUtils.get_all_recipes()
    else:
        # Filter by type
        displayed_recipes = PPRecipeUtils.get_recipes_by_type(recipe_type_filter)

    populate_ui()

func populate_ui():
    for recipe_entity in displayed_recipes:
        var recipe = recipe_entity.get_recipe_property()
        var button = create_recipe_button(
            recipe_entity.get_description(),
            recipe.get_result().get_texture()
        )
        button.pressed.connect(_on_recipe_selected.bind(recipe_entity))

func _on_recipe_selected(recipe_entity: PPRecipeEntity):
    show_recipe_details(recipe_entity)
```

---

### Example 4: Checking Recipe Availability

```gdscript
func get_available_recipes(inventory: PPInventory) -> Array[PPRecipeEntity]:
    var available: Array[PPRecipeEntity] = []

    for recipe_entity in PPRecipeUtils.get_all_recipes():
        var recipe = recipe_entity.get_recipe_property()
        if PPRecipeUtils.can_craft(inventory, recipe):
            available.append(recipe_entity)

    return available

func highlight_craftable_recipes(inventory: PPInventory):
    for recipe_entity in PPRecipeUtils.get_all_recipes():
        var recipe = recipe_entity.get_recipe_property()
        var can_craft = PPRecipeUtils.can_craft(inventory, recipe)

        # Update UI based on availability
        var recipe_button = get_recipe_button(recipe_entity.get_entity_id())
        recipe_button.modulate = Color.WHITE if can_craft else Color(0.5, 0.5, 0.5)
```

---

## Pandora Setup

To create recipes in the Pandora editor:

1. Open the Pandora panel in Godot
2. Find the `ItemRecipes` category (auto-created by Pandora+)
3. Create a new entity or subcategory
4. Fill in the `description` field
5. Configure the `recipe_property` with:
   - Ingredients (items and quantities)
   - Result item
   - Crafting time
   - Recipe type
   - Waste product (optional)

### Organizing with Subcategories

```
ItemRecipes/
├── Alchemy/
│   ├── Health Potion
│   ├── Mana Potion
│   └── Antidote
├── Cooking/
│   ├── Bread
│   ├── Stew
│   └── Roasted Meat
└── Smithing/
    ├── Iron Sword
    ├── Steel Armor
    └── Iron Ingot
```

> **Note:** `PPRecipeUtils.get_all_recipes()` and `get_recipes_by_type()` automatically include recipes from all subcategories.

---

## See Also

- [PPRecipeUtils](../utilities/recipe-utils.md) - Recipe utility functions
- [PPRecipe](../properties/recipe.md) - Recipe property class
- [PPIngredient](../properties/ingredient.md) - Ingredient class
- [PPItemEntity](./item-entity.md) - Item entity class
- [PPInventorySlot](../api/inventory-slot.md) - Inventory slot class

---

*API Reference generated from source code*
