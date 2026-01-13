# PPRecipe

**Extends:** `RefCounted`

Represents a crafting recipe that defines ingredients, result, crafting time, and recipe type.

---

## Description

`PPRecipe` is the core class for the crafting system. It combines multiple `PPIngredient` objects to define what items are needed, what item is produced, how long crafting takes, what type of recipe it is (for categorization), and optionally what waste item is produced as a byproduct.

Recipes are used with `PPRecipeUtils` to validate if a player can craft and to execute the crafting process. When a recipe with a waste item is crafted, the waste is automatically added to the inventory.


---

## Constructor

###### `PPRecipe(ingredients: Array[PPIngredient], result: PandoraReference, crafting_time: float, recipe_type: String)`

Creates a new recipe with all required parameters.

**Parameters:**
- `ingredients`: Array of `PPIngredient` objects defining what's needed
- `result`: `PandoraReference` to the item that will be crafted
- `crafting_time`: Time in seconds to complete the craft
- `recipe_type`: Category/type identifier (e.g., "WEAPON", "POTION", "FOOD")

**Example:**
```gdscript
# Get items
var wood = Pandora.get_entity("WOOD") as PPItemEntity
var stone = Pandora.get_entity("STONE") as PPItemEntity
var sword = Pandora.get_entity("STONE_SWORD") as PPItemEntity

# Create ingredients
var wood_ing = PPIngredient.new(wood, 2)
var stone_ing = PPIngredient.new(stone, 3)

# Create recipe
var result_ref = PandoraReference.new(sword.get_entity_id(), PandoraReference.Type.ENTITY)
var recipe = PPRecipe.new(
    [wood_ing, stone_ing],
    result_ref,
    5.0,           # 5 seconds
    "WEAPON"
)
```

---

## Methods

###### `get_ingredients() -> Array[PPIngredient]`

Returns the array of ingredients required for this recipe.

**Returns:** Array of `PPIngredient` objects

**Example:**
```gdscript
var ingredients = recipe.get_ingredients()

for ingredient in ingredients:
    var item = ingredient.get_item_entity()
    var qty = ingredient.get_quantity()
    print("Need: %d %s" % [qty, item.get_item_name()])
```

---

###### `get_result() -> PPItemEntity`

Returns the item that will be crafted.

**Returns:** `PPItemEntity` or `null` if result not set

**Example:**
```gdscript
var result = recipe.get_result()
if result:
    print("This recipe creates: %s" % result.get_item_name())
```

---

###### `get_crafting_time() -> float`

Returns the time required to complete crafting.

**Returns:** Time in seconds as float

**Example:**
```gdscript
var time = recipe.get_crafting_time()
print("Crafting takes %.1f seconds" % time)

# Use with timer
var timer = get_tree().create_timer(time)
await timer.timeout
print("Crafting complete!")
```

---

###### `get_recipe_type() -> String`

Returns the recipe category/type.

**Returns:** Recipe type as String

**Example:**
```gdscript
var type = recipe.get_recipe_type()

match type:
    "WEAPON":
        print("Weapon crafting")
    "ARMOR":
        print("Armor crafting")
    "POTION":
        print("Alchemy")
```

**Common Types:**
- `"WEAPON"` - Weapons
- `"ARMOR"` - Armor pieces
- `"POTION"` - Potions and consumables
- `"FOOD"` - Food items
- `"TOOL"` - Tools and utilities
- `"BUILDING"` - Construction items

---

###### `add_ingredient(ingredient: PPIngredient) -> void`

Adds a new ingredient to the recipe.

**Parameters:**
- `ingredient`: The ingredient to add (must not be null)

**Example:**
```gdscript
var recipe = PPRecipe.new([], result_ref, 5.0, "WEAPON")

# Add ingredients after creation
recipe.add_ingredient(PPIngredient.new(wood, 2))
recipe.add_ingredient(PPIngredient.new(stone, 3))
```

---

###### `remove_ingredient(ingredient: PPIngredient) -> void`

Removes an ingredient from the recipe.

**Parameters:**
- `ingredient`: The exact ingredient instance to remove

**Example:**
```gdscript
var wood_ing = PPIngredient.new(wood, 2)
recipe.add_ingredient(wood_ing)

# Later, remove it
recipe.remove_ingredient(wood_ing)
```

---

###### `update_ingredient_at(idx: int, ingredient: PPIngredient) -> void`

Updates or adds an ingredient at a specific index.

**Parameters:**
- `idx`: Index position
- `ingredient`: New ingredient

**Behavior:**
- If index exists: replaces ingredient
- If index doesn't exist: appends ingredient

**Example:**
```gdscript
# Update first ingredient
recipe.update_ingredient_at(0, PPIngredient.new(iron, 5))

# Add to end if index out of bounds
recipe.update_ingredient_at(10, PPIngredient.new(gold, 1))
```

---

###### `set_result(entity: PandoraEntity) -> void`

Updates the result item entity.

**Parameters:**
- `entity`: New result item entity

**Example:**
```gdscript
var diamond_sword = Pandora.get_entity("DIAMOND_SWORD") as PPItemEntity
recipe.set_result(diamond_sword)
```

---

###### `set_crafting_time(crafting_time: float) -> void`

Updates the crafting time.

**Parameters:**
- `crafting_time`: New time in seconds

**Example:**
```gdscript
# Make recipe faster
recipe.set_crafting_time(2.5)
```

---

###### `set_recipe_type(recipe_type: String) -> void`

Updates the recipe type.

**Parameters:**
- `recipe_type`: New type identifier

**Example:**
```gdscript
recipe.set_recipe_type("LEGENDARY_WEAPON")
```

---

###### `set_waste(waste: PPIngredient) -> void`

Sets the waste item produced as a byproduct when crafting this recipe.

**Parameters:**
- `waste`: A `PPIngredient` containing the waste item and quantity, or `null` to remove waste

**Example:**
```gdscript
# Add slag as waste when smithing
var slag = Pandora.get_entity("SLAG") as PPItemEntity
recipe.set_waste(PPIngredient.new(slag, 2))

# Remove waste
recipe.set_waste(null)
```

---

###### `get_waste() -> PPIngredient`

Returns the waste item produced by this recipe, if any.

**Returns:** `PPIngredient` or `null` if no waste defined

**Example:**
```gdscript
var waste = recipe.get_waste()
if waste:
    var waste_item = waste.get_item_entity()
    var waste_qty = waste.get_quantity()
    print("Produces %d %s as waste" % [waste_qty, waste_item.get_item_name()])
else:
    print("No waste produced")
```

---

###### `load_data(data: Dictionary) -> void`

Loads recipe data from a serialized dictionary.

**Parameters:**
- `data`: Dictionary with recipe data

**Example:**
```gdscript
var saved_recipe = {
    "result": {"_entity_id": "SWORD", "_type": 1},
    "crafting_time": 5.0,
    "recipe_type": "WEAPON",
    "ingredients": [
        {"item": {"_entity_id": "WOOD", "_type": 1}, "quantity": 2},
        {"item": {"_entity_id": "STONE", "_type": 1}, "quantity": 3}
    ]
}

var recipe = PPRecipe.new([], null, 0.0, "")
recipe.load_data(saved_recipe)
```

---

###### `save_data(fields_settings: Array[Dictionary], ingredient_fields_settings: Array[Dictionary]) -> Dictionary`

Serializes the recipe to a dictionary.

**Parameters:**
- `fields_settings`: Recipe field configuration
- `ingredient_fields_settings`: Ingredient field configuration

**Returns:** Dictionary with recipe data

**Example:**
```gdscript
var data = recipe.save_data(recipe_fields, ingredient_fields)
# Save to file or database
```

---

###### `_to_string() -> String`

Returns a string representation of the recipe.

**Returns:** String in format `"<PPRecipe [result]>"`

**Example:**
```gdscript
print(recipe)
# Output: "<PPRecipe <PPItemEntity:STONE_SWORD>>"
```

---

## Usage Examples

### Example 1: Complete Crafting System

```gdscript
class_name CraftingStation

var available_recipes: Array[PPRecipe] = []
var player_inventory: PPInventory

func _ready():
    _load_recipes()

func _load_recipes():
    # Stone Sword Recipe
    var wood = Pandora.get_entity("WOOD") as PPItemEntity
    var stone = Pandora.get_entity("STONE") as PPItemEntity
    var sword = Pandora.get_entity("STONE_SWORD") as PPItemEntity
    
    var sword_recipe = PPRecipe.new(
        [
            PPIngredient.new(wood, 2),
            PPIngredient.new(stone, 3)
        ],
        PandoraReference.new(sword.get_entity_id(), PandoraReference.Type.ENTITY),
        5.0,
        "WEAPON"
    )
    
    available_recipes.append(sword_recipe)

func craft_recipe(recipe: PPRecipe) -> bool:
    # Check if can craft
    if not PPRecipeUtils.can_craft(player_inventory, recipe):
        print("Missing ingredients!")
        return false
    
    # Start crafting
    print("Crafting %s..." % recipe.get_result().get_item_name())
    
    # Wait for crafting time
    await get_tree().create_timer(recipe.get_crafting_time()).timeout
    
    # Execute craft
    if PPRecipeUtils.craft_recipe(player_inventory, recipe):
        print("Crafted successfully!")
        return true
    
    return false
```

---

### Example 2: Recipe Display UI

```gdscript
func display_recipe(recipe: PPRecipe, container: Control):
    # Result item
    var result = recipe.get_result()
    container.get_node("ResultIcon").texture = result.get_texture()
    container.get_node("ResultName").text = result.get_item_name()
    
    # Ingredients list
    var ingredients_label = container.get_node("Ingredients") as Label
    var text = "Required:\n"
    
    for ingredient in recipe.get_ingredients():
        var item = ingredient.get_item_entity()
        var has = player_inventory.count_item(item)
        var need = ingredient.get_quantity()
        
        var status = "✓" if has >= need else "✗"
        text += "%s %d/%d %s\n" % [status, has, need, item.get_item_name()]
    
    ingredients_label.text = text
    
    # Crafting info
    var info = container.get_node("Info") as Label
    info.text = "Time: %.1fs | Type: %s" % [
        recipe.get_crafting_time(),
        recipe.get_recipe_type()
    ]
```

---

### Example 3: Recipe Filtering

```gdscript
func filter_recipes_by_type(type: String) -> Array[PPRecipe]:
    var filtered: Array[PPRecipe] = []
    
    for recipe in all_recipes:
        if recipe.get_recipe_type() == type:
            filtered.append(recipe)
    
    return filtered

func get_craftable_recipes(inventory: PPInventory) -> Array[PPRecipe]:
    var craftable: Array[PPRecipe] = []
    
    for recipe in all_recipes:
        if PPRecipeUtils.can_craft(inventory, recipe):
            craftable.append(recipe)
    
    return craftable

# Usage
var weapon_recipes = filter_recipes_by_type("WEAPON")
var can_craft_now = get_craftable_recipes(player_inventory)
```

---

### Example 4: Recipe with Waste

```gdscript
# Smithing recipe that produces slag as waste
func create_smithing_recipe() -> PPRecipe:
    var iron_ore = Pandora.get_entity("IRON_ORE") as PPItemEntity
    var coal = Pandora.get_entity("COAL") as PPItemEntity
    var iron_ingot = Pandora.get_entity("IRON_INGOT") as PPItemEntity
    var slag = Pandora.get_entity("SLAG") as PPItemEntity

    var recipe = PPRecipe.new(
        [
            PPIngredient.new(iron_ore, 2),
            PPIngredient.new(coal, 1)
        ],
        PandoraReference.new(iron_ingot.get_entity_id(), PandoraReference.Type.ENTITY),
        8.0,
        "SMITHING"
    )

    # Add waste: 1 slag per crafting
    recipe.set_waste(PPIngredient.new(slag, 1))

    return recipe

# Alchemy recipe with empty bottle as waste
func create_potion_recipe() -> PPRecipe:
    var herbs = Pandora.get_entity("HERBS") as PPItemEntity
    var water_bottle = Pandora.get_entity("WATER_BOTTLE") as PPItemEntity
    var health_potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity
    var empty_bottle = Pandora.get_entity("EMPTY_BOTTLE") as PPItemEntity

    var recipe = PPRecipe.new(
        [
            PPIngredient.new(herbs, 3),
            PPIngredient.new(water_bottle, 1)
        ],
        PandoraReference.new(health_potion.get_entity_id(), PandoraReference.Type.ENTITY),
        5.0,
        "ALCHEMY"
    )

    # Empty bottle is returned as waste (recycling)
    recipe.set_waste(PPIngredient.new(empty_bottle, 1))

    return recipe
```

---

## Integration with PPRecipeUtils

```gdscript
# PPRecipe works with PPRecipeUtils for validation and execution

# Check if can craft
if PPRecipeUtils.can_craft(inventory, recipe):
    print("Can craft!")

    # Show missing ingredients if can't craft
    for ingredient in recipe.get_ingredients():
        var item = ingredient.get_item_entity()
        var need = ingredient.get_quantity()
        var have = inventory.count_item(item)

        if have < need:
            print("Missing: %d %s" % [need - have, item.get_item_name()])

# Execute craft (removes ingredients, adds result and waste if defined)
if PPRecipeUtils.craft_recipe(inventory, recipe):
    print("Crafted: %s" % recipe.get_result().get_item_name())

    var waste = recipe.get_waste()
    if waste:
        print("Also produced: %d %s" % [waste.get_quantity(), waste.get_item_entity().get_item_name()])
```

---

## Serialization

### Save Format

```json
{
    "result": {
        "_entity_id": "STONE_SWORD",
        "_type": 1
    },
    "crafting_time": 5.0,
    "recipe_type": "WEAPON",
    "ingredients": [
        {
            "item": {"_entity_id": "WOOD", "_type": 1},
            "quantity": 2
        },
        {
            "item": {"_entity_id": "STONE", "_type": 1},
            "quantity": 3
        }
    ],
    "waste": {
        "item": {"_entity_id": "SLAG", "_type": 1},
        "quantity": 1
    }
}
```

> **Note:** The `waste` field is optional and only present when a waste item is defined.

### Field Settings

The `save_data()` method respects Pandora field settings to control what gets saved:

```gdscript
recipe_fields_settings = [
    {"name": "Result", "enabled": true},
    {"name": "Recipe types", "enabled": true},
    {"name": "Ingredients", "enabled": true},
    {"name": "Crafting Time", "enabled": true},
    {"name": "Waste Item", "enabled": true}
]
```

> **Note:** When "Waste Item" is disabled, waste data is not saved or loaded.

---

## Best Practices

### ✅ Validate Ingredients

```gdscript
# ✅ Good: check ingredients exist
func create_recipe_safe(ingredients: Array[PPIngredient]) -> PPRecipe:
    for ing in ingredients:
        assert(ing.get_item_entity() != null, "Invalid ingredient")
    
    return PPRecipe.new(ingredients, result_ref, 5.0, "WEAPON")
```

---

### ✅ Use Meaningful Recipe Types

```gdscript
# ✅ Good: clear categorization
"WEAPON_MELEE"
"WEAPON_RANGED"
"ARMOR_HEAVY"
"POTION_HEALING"

# ❌ Bad: vague types
"STUFF"
"THINGS"
"ITEM"
```

---

### ✅ Reasonable Crafting Times

```gdscript
# ✅ Good: balanced times
"POTION" -> 2-5 seconds
"WEAPON" -> 5-10 seconds
"ARMOR" -> 10-20 seconds
"LEGENDARY" -> 30-60 seconds

# ❌ Bad: extreme times
0.1 seconds  # Too fast, no anticipation
300 seconds  # Too slow, boring
```

---

### ✅ Group Related Recipes

```gdscript
# ✅ Good: organize by type
class RecipeDatabase:
    var weapon_recipes: Array[PPRecipe] = []
    var armor_recipes: Array[PPRecipe] = []
    var potion_recipes: Array[PPRecipe] = []
    
    func get_recipes_for_station(station_type: String) -> Array[PPRecipe]:
        match station_type:
            "FORGE": return weapon_recipes + armor_recipes
            "ALCHEMY": return potion_recipes
            _: return []
```

---

## Common Patterns

### Pattern 1: Recipe Unlocking

```gdscript
var unlocked_recipes: Array[PPRecipe] = []

func unlock_recipe(recipe: PPRecipe):
    if recipe not in unlocked_recipes:
        unlocked_recipes.append(recipe)
        print("Unlocked recipe: %s" % recipe.get_result().get_item_name())

func is_recipe_unlocked(recipe: PPRecipe) -> bool:
    return recipe in unlocked_recipes
```

---

### Pattern 2: Crafting Queue

```gdscript
var crafting_queue: Array[Dictionary] = []
var is_crafting: bool = false

func queue_recipe(recipe: PPRecipe):
    crafting_queue.append({
        "recipe": recipe,
        "time_remaining": recipe.get_crafting_time()
    })
    
    if not is_crafting:
        _process_queue()

func _process_queue():
    if crafting_queue.is_empty():
        is_crafting = false
        return
    
    is_crafting = true
    var entry = crafting_queue[0]
    
    await get_tree().create_timer(entry["time_remaining"]).timeout
    
    PPRecipeUtils.craft_recipe(inventory, entry["recipe"])
    crafting_queue.remove_at(0)
    
    _process_queue()
```

---

### Pattern 3: Recipe Discovery

```gdscript
func discover_recipe_by_ingredients(inventory: PPInventory) -> PPRecipe:
    for recipe in all_recipes:
        if recipe in unlocked_recipes:
            continue
        
        # Check if player has all ingredients at least once
        var has_all = true
        for ingredient in recipe.get_ingredients():
            if inventory.count_item(ingredient.get_item_entity()) == 0:
                has_all = false
                break
        
        if has_all:
            unlock_recipe(recipe)
            return recipe
    
    return null
```

---

## Notes

### RefCounted vs Resource

Like `PPIngredient`, `PPRecipe` extends `RefCounted`:
- ✅ Automatic garbage collection
- ✅ Lightweight
- ❌ Cannot be saved as `.tres`
- ❌ Not exportable in Inspector

This is intentional - recipes are created programmatically or loaded from Pandora.

---

### Result Quantity

Currently, `PPRecipe` doesn't have a `result_quantity` field in the code shown. The recipe always produces **one** result item. If you need multiple results, you'd need to:

1. Modify the class to add `_result_quantity`
2. Update `PPRecipeUtils.craft_recipe()` to use it
3. Or craft the recipe multiple times

---

## See Also

- [PPIngredient](../properties/ingredient.md) - Ingredient class
- [PPRecipeUtils](../utilities/recipe-utils.md) - Recipe utilities
- [PPItemEntity](../entities/item-entity.md) - Item system
- [Inventory System](../core-systems/inventory-system.md) - Inventory system

---

*API Reference generated from source code v1.0.0-core | v1.0.0-premium*