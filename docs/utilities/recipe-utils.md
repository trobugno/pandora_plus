# PPRecipeUtils

**Extends:** `Node`

Utility singleton for validating and executing crafting recipes with inventory integration.

---

## Description

`PPRecipeUtils` provides core functionality for the crafting system, validating if a player has the required ingredients and executing recipe crafting. It integrates seamlessly with `PPInventory` and `PPRecipe` to handle ingredient validation, removal, and result creation.

The class emits signals when crafting is attempted, making it easy to implement UI feedback and game events.

---

## Setup

Add to autoload in Project Settings:

```gdscript
# Project -> Project Settings -> Autoload
# Name: RecipeUtils
# Path: res://addons/pandora_plus/extensions/recipes/PPRecipeUtils.gd
```

---

## Signals

###### `crafting_attempted(recipe_id: String, success: bool)`

Emitted when a crafting attempt is made, whether successful or not.

**Parameters:**
- `recipe_id`: Name of the crafted item (from `recipe.get_result().get_item_name()`)
- `success`: `true` if crafting succeeded, `false` if failed

**Example:**
```gdscript
RecipeUtils.crafting_attempted.connect(_on_crafting_attempted)

func _on_crafting_attempted(recipe_id: String, success: bool):
    if success:
        show_notification("Crafted: %s" % recipe_id)
        play_sound("craft_success")
    else:
        show_notification("Missing ingredients for: %s" % recipe_id)
        play_sound("craft_fail")
```

---

## Methods

###### `can_craft(inventory: PPInventory, recipe: PPRecipe) -> bool`

Checks if an inventory contains all required ingredients for a recipe.

**Parameters:**
- `inventory`: The inventory to check
- `recipe`: The recipe to validate

**Returns:** `true` if all ingredients are present with sufficient quantities

**Logic:**
- Iterates through each ingredient in the recipe
- Searches inventory slots for matching items
- Validates quantity meets or exceeds requirement
- Returns `true` only if ALL ingredients found

**Example:**
```gdscript
var sword_recipe = PPRecipe.new(
    [
        PPIngredient.new(wood, 2),
        PPIngredient.new(iron, 3)
    ],
    sword_ref,
    5.0,
    "WEAPON"
)

if RecipeUtils.can_craft(player_inventory, sword_recipe):
    print("Can craft Iron Sword!")
    enable_craft_button()
else:
    print("Missing ingredients")
    disable_craft_button()
```

---

###### `craft_recipe(inventory: PPInventory, recipe: PPRecipe) -> bool`

Executes a recipe if ingredients are available, removing them and adding the result (plus waste if defined).

**Parameters:**
- `inventory`: The inventory to craft from
- `recipe`: The recipe to execute

**Returns:** `true` if crafting succeeded, `false` if ingredients missing

**Behavior:**
1. Validates ingredients with `can_craft()`
2. If validation fails, emits signal with `success: false` and returns `false`
3. If validation succeeds:
   - Removes all required ingredients from inventory
   - Adds crafted result to inventory
   - **Adds waste item to inventory (if defined)**
   - Emits signal with `success: true`
   - Returns `true`

> **Note:** If the recipe has a waste item defined via `set_waste()`, it will be automatically added to the inventory with the specified quantity.

**Example:**
```gdscript
func attempt_craft(recipe: PPRecipe):
    if RecipeUtils.craft_recipe(player_inventory, recipe):
        print("Successfully crafted: %s" % recipe.get_result().get_item_name())
        update_ui()
    else:
        print("Crafting failed - check ingredients")

# With crafting time
func craft_with_delay(recipe: PPRecipe):
    if not RecipeUtils.can_craft(player_inventory, recipe):
        show_error("Missing ingredients")
        return

    show_crafting_progress(recipe.get_crafting_time())
    await get_tree().create_timer(recipe.get_crafting_time()).timeout

    RecipeUtils.craft_recipe(player_inventory, recipe)
```

---

###### `get_recipes_by_type(recipes: Array[PPRecipe], recipe_type: String) -> Array[PPRecipe]`

Filters an array of recipes by their recipe type.

**Parameters:**
- `recipes`: The array of PPRecipe to filter
- `recipe_type`: The recipe type string to match (e.g., "Alchemy", "Cooking", "Smithing")

**Returns:** A new array containing only recipes matching the specified type

**Example:**
```gdscript
var all_recipes: Array[PPRecipe] = load_all_recipes()

# Filter by type
var alchemy_recipes = RecipeUtils.get_recipes_by_type(all_recipes, "Alchemy")
var cooking_recipes = RecipeUtils.get_recipes_by_type(all_recipes, "Cooking")
var smithing_recipes = RecipeUtils.get_recipes_by_type(all_recipes, "Smithing")

print("Found %d alchemy recipes" % alchemy_recipes.size())
```

**Use Cases:**
- Displaying recipes in categorized tabs (Alchemy Station, Cooking Pot, Forge)
- Filtering available recipes based on current crafting station
- Showing only relevant recipes to the player

```gdscript
# Example: Crafting station that only shows relevant recipes
class_name CraftingStation
extends Node

@export var station_type: String = "Alchemy"  # Set in editor

var available_recipes: Array[PPRecipe] = []

func _ready():
    var all_recipes = load_all_game_recipes()
    available_recipes = RecipeUtils.get_recipes_by_type(all_recipes, station_type)
    populate_recipe_ui(available_recipes)
```

---

## Usage Examples

### Example 1: Basic Crafting Station

```gdscript
class_name CraftingStation
extends Node

var available_recipes: Array[PPRecipe] = []
var player_inventory: PPInventory

func _ready():
    RecipeUtils.crafting_attempted.connect(_on_crafting_attempted)
    load_recipes()

func load_recipes():
    # Wood Sword Recipe
    var wood = Pandora.get_entity("WOOD") as PPItemEntity
    var sword = Pandora.get_entity("WOOD_SWORD") as PPItemEntity
    
    var wood_sword_recipe = PPRecipe.new(
        [PPIngredient.new(wood, 5)],
        PandoraReference.new(sword.get_entity_id(), PandoraReference.Type.ENTITY),
        3.0,
        "WEAPON"
    )
    
    available_recipes.append(wood_sword_recipe)

func try_craft_recipe(recipe: PPRecipe):
    # Check if can craft
    if not RecipeUtils.can_craft(player_inventory, recipe):
        show_missing_ingredients(recipe)
        return
    
    # Show crafting animation
    show_crafting_ui(recipe)
    
    # Wait for crafting time
    await get_tree().create_timer(recipe.get_crafting_time()).timeout
    
    # Execute craft
    RecipeUtils.craft_recipe(player_inventory, recipe)

func _on_crafting_attempted(recipe_id: String, success: bool):
    if success:
        show_success_animation(recipe_id)
    else:
        show_failure_animation()
```

---

### Example 2: Recipe Display with Validation

```gdscript
class_name RecipeUI
extends Control

@onready var recipe_list = $RecipeList
@onready var craft_button = $CraftButton

var selected_recipe: PPRecipe

func refresh_recipe_list():
    recipe_list.clear()
    
    for recipe in available_recipes:
        var can_craft = RecipeUtils.can_craft(player_inventory, recipe)
        var recipe_name = recipe.get_result().get_item_name()
        
        # Color code based on availability
        var color = Color.GREEN if can_craft else Color.RED
        recipe_list.add_item(recipe_name)
        recipe_list.set_item_custom_fg_color(-1, color)

func _on_recipe_selected(index: int):
    selected_recipe = available_recipes[index]
    update_recipe_details(selected_recipe)
    
    # Enable/disable craft button
    craft_button.disabled = not RecipeUtils.can_craft(
        player_inventory, 
        selected_recipe
    )

func update_recipe_details(recipe: PPRecipe):
    # Show ingredients with availability
    for ingredient in recipe.get_ingredients():
        var item = ingredient.get_item_entity()
        var required = ingredient.get_quantity()
        var available = count_item_in_inventory(item)
        
        var status = "✓" if available >= required else "✗"
        var text = "%s %d/%d %s" % [
            status,
            available,
            required,
            item.get_item_name()
        ]
        
        add_ingredient_label(text)

func count_item_in_inventory(item: PPItemEntity) -> int:
    var count = 0
    for slot in player_inventory.all_items:
        if slot and slot.item and slot.item.get_entity_id() == item.get_entity_id():
            count += slot.quantity
    return count
```

---

### Example 3: Crafting with Waste Handling

```gdscript
class_name SmithingStation
extends Node

var player_inventory: PPInventory

func create_iron_ingot_recipe() -> PPRecipe:
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

    # Smithing produces slag as waste
    recipe.set_waste(PPIngredient.new(slag, 1))
    return recipe

func smelt_ore(recipe: PPRecipe):
    if not RecipeUtils.can_craft(player_inventory, recipe):
        show_error("Missing ingredients")
        return

    # Show smelting animation
    show_smelting_ui(recipe)
    await get_tree().create_timer(recipe.get_crafting_time()).timeout

    # Execute craft - result AND waste are added automatically
    if RecipeUtils.craft_recipe(player_inventory, recipe):
        var result = recipe.get_result()
        var waste = recipe.get_waste()

        print("Smelted: %s" % result.get_item_name())
        if waste:
            print("Produced waste: %d %s" % [
                waste.get_quantity(),
                waste.get_item_entity().get_item_name()
            ])
```

---

### Example 4: Batch Crafting System

```gdscript
class_name BatchCraftingSystem

func craft_multiple(inventory: PPInventory, recipe: PPRecipe, count: int) -> int:
    var crafted = 0
    
    for i in count:
        if RecipeUtils.craft_recipe(inventory, recipe):
            crafted += 1
        else:
            break  # Stop if ingredients run out
    
    return crafted

func craft_max_possible(inventory: PPInventory, recipe: PPRecipe) -> int:
    var max_craftable = calculate_max_craftable(inventory, recipe)
    return craft_multiple(inventory, recipe, max_craftable)

func calculate_max_craftable(inventory: PPInventory, recipe: PPRecipe) -> int:
    if not RecipeUtils.can_craft(inventory, recipe):
        return 0
    
    var max_possible = 999999
    
    for ingredient in recipe.get_ingredients():
        var item = ingredient.get_item_entity()
        var required = ingredient.get_quantity()
        var available = 0
        
        # Count available in inventory
        for slot in inventory.all_items:
            if slot and slot.item and slot.item.get_entity_id() == item.get_entity_id():
                available += slot.quantity
        
        # Calculate how many times we can craft with this ingredient
        var possible = int(available / required)
        max_possible = min(max_possible, possible)
    
    return max_possible

# Usage
func _on_craft_all_pressed():
    var crafted = craft_max_possible(player_inventory, selected_recipe)
    print("Crafted %d items" % crafted)
```

---

## Best Practices

### ✅ Always Check can_craft() First

```gdscript
# ✅ Good: validate before attempting
if RecipeUtils.can_craft(inventory, recipe):
    show_crafting_ui(recipe)
    RecipeUtils.craft_recipe(inventory, recipe)
else:
    show_error("Missing ingredients")

# ❌ Bad: attempt without checking
RecipeUtils.craft_recipe(inventory, recipe)  # Will fail silently
```

---

### ✅ Use Signals for Feedback

```gdscript
# ✅ Good: reactive feedback
RecipeUtils.crafting_attempted.connect(_on_crafting_attempted)

func _on_crafting_attempted(recipe_id: String, success: bool):
    update_ui(recipe_id, success)

# ❌ Bad: manual checking
func craft():
    var result = RecipeUtils.craft_recipe(inventory, recipe)
    if result:
        manually_update_ui()  # Less maintainable
```

---

### ✅ Separate Validation from Execution

```gdscript
# ✅ Good: check before time investment
func start_crafting(recipe: PPRecipe):
    if not RecipeUtils.can_craft(inventory, recipe):
        return
    
    # Player commits to crafting
    await wait_for_crafting_time(recipe)
    RecipeUtils.craft_recipe(inventory, recipe)

# ❌ Bad: check after time investment
func start_crafting(recipe: PPRecipe):
    await wait_for_crafting_time(recipe)
    
    # Ingredients might be used elsewhere by now!
    RecipeUtils.craft_recipe(inventory, recipe)
```

---

## Common Patterns

### Pattern 1: Recipe Unlocking System

```gdscript
var unlocked_recipes: Array[PPRecipe] = []
var all_recipes: Array[PPRecipe] = []

func check_recipe_unlock(recipe: PPRecipe) -> bool:
    if recipe in unlocked_recipes:
        return false
    
    # Unlock if player has discovered all ingredients
    var has_all_ingredients = true
    for ingredient in recipe.get_ingredients():
        var found = false
        for slot in player_inventory.all_items:
            if slot and slot.item:
                if slot.item.get_entity_id() == ingredient.get_item_entity().get_entity_id():
                    found = true
                    break
        
        if not found:
            has_all_ingredients = false
            break
    
    if has_all_ingredients:
        unlocked_recipes.append(recipe)
        show_notification("New recipe unlocked: %s" % recipe.get_result().get_item_name())
        return true
    
    return false
```

---

### Pattern 2: Crafting Queue

```gdscript
class_name CraftingQueue

var queue: Array[Dictionary] = []
var is_crafting: bool = false

func add_to_queue(recipe: PPRecipe, count: int = 1):
    if not RecipeUtils.can_craft(player_inventory, recipe):
        show_error("Cannot craft: missing ingredients")
        return
    
    queue.append({
        "recipe": recipe,
        "count": count,
        "time_remaining": recipe.get_crafting_time()
    })
    
    if not is_crafting:
        process_queue()

func process_queue():
    if queue.is_empty():
        is_crafting = false
        return
    
    is_crafting = true
    var entry = queue[0]
    
    # Wait for crafting time
    await get_tree().create_timer(entry["time_remaining"]).timeout
    
    # Craft item
    if RecipeUtils.craft_recipe(player_inventory, entry["recipe"]):
        entry["count"] -= 1
        
        if entry["count"] <= 0:
            queue.remove_at(0)
        else:
            entry["time_remaining"] = entry["recipe"].get_crafting_time()
    else:
        # Failed, remove from queue
        queue.remove_at(0)
        show_error("Crafting failed: missing ingredients")
    
    # Process next
    process_queue()
```

---

### Pattern 3: Ingredient Highlighting

```gdscript
func highlight_missing_ingredients(recipe: PPRecipe):
    for ingredient in recipe.get_ingredients():
        var item = ingredient.get_item_entity()
        var required = ingredient.get_quantity()
        var available = 0
        
        for slot in player_inventory.all_items:
            if slot and slot.item and slot.item.get_entity_id() == item.get_entity_id():
                available += slot.quantity
        
        if available < required:
            highlight_inventory_item(item, Color.RED)
            show_tooltip("Need %d more %s" % [
                required - available,
                item.get_item_name()
            ])
        else:
            highlight_inventory_item(item, Color.GREEN)
```

---

## Known Issues

### ⚠️ Null Safety in can_craft()

The current implementation doesn't check for null slots:

```gdscript
# Current code
for slot in inventory.all_items:
    var item = slot.item  # May crash if slot is null
```

**Workaround:**
```gdscript
func safe_can_craft(inventory: PPInventory, recipe: PPRecipe) -> bool:
    var ingredients_found = 0
    
    for ingredient in recipe.get_ingredients():
        for slot in inventory.all_items:
            if not slot or not slot.item:  # Add null check
                continue
            
            var item = slot.item
            var quantity = slot.quantity
            var instance = ingredient.get_item_entity() as PPItemEntity
            
            if instance.get_entity_id() == item.get_entity_id() and quantity >= ingredient.get_quantity():
                ingredients_found += 1
                break  # Found this ingredient, move to next
    
    return ingredients_found == recipe.get_ingredients().size()
```

---

### ⚠️ Multiple Stack Detection

The current `can_craft()` checks each slot individually but doesn't aggregate quantities across multiple stacks:

```gdscript
# Scenario:
# - Recipe needs: 10 Wood
# - Inventory has: Slot 1: Wood x7, Slot 2: Wood x5
# - Current implementation: FAILS (no single slot has 10)
# - Expected: SHOULD PASS (total is 12)
```

**Workaround:**
```gdscript
func improved_can_craft(inventory: PPInventory, recipe: PPRecipe) -> bool:
    for ingredient in recipe.get_ingredients():
        var total_quantity = 0
        var target_item = ingredient.get_item_entity()
        
        # Sum quantities across all slots
        for slot in inventory.all_items:
            if not slot or not slot.item:
                continue
            
            if slot.item.get_entity_id() == target_item.get_entity_id():
                total_quantity += slot.quantity
        
        # Check if total meets requirement
        if total_quantity < ingredient.get_quantity():
            return false
    
    return true
```

---

## Integration with Other Systems

### With PPInventory

```gdscript
# Crafting consumes ingredients automatically
inventory.item_removed.connect(_on_ingredient_used)

func _on_ingredient_used(item: PPItemEntity, quantity: int):
    print("Used: %d %s for crafting" % [quantity, item.get_item_name()])
```

---

### With PPRecipe

```gdscript
# Validate recipe before showing in UI
func should_show_recipe(recipe: PPRecipe) -> bool:
    # Only show if unlocked
    if recipe not in unlocked_recipes:
        return false
    
    # Optional: hide if player never had ingredients
    return has_seen_ingredients(recipe)
```

---

### With Save System

```gdscript
func save_crafting_data() -> Dictionary:
    return {
        "unlocked_recipes": unlocked_recipes.map(
            func(r): return r.get_result().get_entity_id()
        ),
        "crafting_stats": {
            "total_crafted": total_items_crafted,
            "recipes_used": recipes_used.size()
        }
    }
```

---

## Performance Considerations

### Optimization Tips

1. **Cache can_craft() Results**: Don't call repeatedly in _process()
2. **Use Signals**: React to inventory changes instead of polling
3. **Limit Recipe Count**: Filter visible recipes before checking
4. **Aggregate Checks**: Validate all recipes once, not individually

### Benchmark (Approximate)

| Operation | Time (100 recipes) | Notes |
|-----------|-------------------|-------|
| can_craft() | ~0.1ms | Per recipe |
| craft_recipe() | ~0.5ms | Includes inventory operations |
| Bulk validation | ~10ms | All recipes |

---

## Troubleshooting

### Issue: Crafting Fails Despite Having Ingredients

**Causes:**
1. Ingredients spread across multiple stacks (see Known Issues)
2. Null slots not handled properly
3. Item ID mismatch (case sensitive)

**Solution:** Use improved `can_craft()` implementation from Known Issues section

---

### Issue: Signal Not Firing

**Cause:** RecipeUtils not in autoload  
**Solution:** Add to Project Settings → Autoload

---

### Issue: Wrong Recipe ID in Signal

**Cause:** Signal uses `get_item_name()` not recipe ID  
**Solution:** Store recipe ID separately or use `get_entity_id()`

---

## Notes

### Signal Parameter Naming

The signal parameter is named `recipe_id` but actually contains the item name:

```gdscript
crafting_attempted.emit(recipe.get_result().get_item_name(), true)
#                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#                       This is item NAME, not ID
```

For actual recipe ID, use:
```gdscript
recipe.get_result().get_entity_id()
```

---

### Crafting Time Not Enforced

`craft_recipe()` executes instantly. Implement time delays separately:

```gdscript
func craft_with_time(inventory: PPInventory, recipe: PPRecipe):
    if not RecipeUtils.can_craft(inventory, recipe):
        return
    
    await get_tree().create_timer(recipe.get_crafting_time()).timeout
    RecipeUtils.craft_recipe(inventory, recipe)
```

---

## See Also

- [PPRecipe](../properties/recipe.md) - Recipe class
- [PPIngredient](../properties/ingredient.md) - Ingredient class
- [PPInventory](../api/inventory.md) - Inventory system
- [PPItemEntity](../entities/item-entity.md) - Item entities

---

*API Reference generated from source code*