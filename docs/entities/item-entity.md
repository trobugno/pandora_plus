# PPItemEntity

**Extends:** `PandoraEntity`

Represents an item in the game that can be stored in inventories, used in recipes, and equipped by characters.

---

## Description

`PPItemEntity` is a specialized Pandora entity for items. It provides convenient accessor methods to retrieve item properties such as name, description, texture, rarity, value, and weight.

All items in your game should be created as `PPItemEntity` in the Pandora Editor, and can then be referenced throughout your game systems (inventory, crafting, shops, etc.).

---

## Properties

Items have these standard properties (stored in Pandora):

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Display name of the item |
| `description` | `String` | Item description/lore |
| `texture` | `Texture` | Icon/sprite for the item |
| `stackable` | `bool` | Whether item can stack in inventory |
| `rarity` | `PPRarityEntity` | Reference to rarity entity |
| `value` | `float` | Gold/currency value |
| `weight` | `float` | Weight for inventory limits |

> 💡 These properties are defined in Pandora's data system and accessed via getter methods.

---

## Methods

###### `get_item_name() -> String`

Returns the display name of the item.

**Returns:** Item name as String

**Example:**
```gdscript
var potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity
print(potion.get_item_name())  # "Health Potion"
```

**Use Cases:**
- Display in inventory UI
- Show in tooltips
- Log messages

---

###### `get_description() -> String`

Returns the item's description text.

**Returns:** Description as String

**Example:**
```gdscript
var sword = Pandora.get_entity("IRON_SWORD") as PPItemEntity
print(sword.get_description())  
# "A sturdy iron blade. Perfect for beginners."
```

**Use Cases:**
- Item tooltips
- Inspect dialog
- Tutorial/help text

---

###### `get_texture() -> Texture`

Returns the item's icon/sprite texture.

**Returns:** Texture resource

**Example:**
```gdscript
var item = Pandora.get_entity("GOLD_COIN") as PPItemEntity
var icon = item.get_texture()

# Use in UI
var texture_rect = TextureRect.new()
texture_rect.texture = icon
```

**Use Cases:**
- Inventory slot icons
- Shop displays
- Loot notifications

---

###### `is_stackable() -> bool`

Checks if the item can stack in inventory.

**Returns:** `true` if stackable, `false` otherwise

**Example:**
```gdscript
var potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity
if potion.is_stackable():
    print("Can stack multiple potions")  # True
else:
    print("Each item needs its own slot")

var sword = Pandora.get_entity("UNIQUE_SWORD") as PPItemEntity
print(sword.is_stackable())  # False - unique items don't stack
```

**Use Cases:**
- Inventory add logic
- Stack splitting
- Item merging

---

###### `get_rarity() -> PPRarityEntity`

Returns the item's rarity entity.

**Returns:** `PPRarityEntity` or `null` if not set

**Example:**
```gdscript
var legendary_sword = Pandora.get_entity("EXCALIBUR") as PPItemEntity
var rarity = legendary_sword.get_rarity()

if rarity:
    print("Rarity: ", rarity.get_rarity_name())  # "Legendary"
    print("Drop rate: ", rarity.get_percentage(), "%")  # 0.1%
```

**Use Cases:**
- Color-code UI elements
- Calculate drop chances
- Filter/sort by rarity

---

###### `get_value() -> float`

Returns the item's monetary value.

**Returns:** Value as float (gold/currency)

**Example:**
```gdscript
var diamond = Pandora.get_entity("DIAMOND") as PPItemEntity
var price = diamond.get_value()
print("Price: ", price, " gold")  # 1000.0 gold

# Calculate sell price (50% of value)
var sell_price = price * 0.5
```

**Use Cases:**
- Shop buy/sell prices
- Loot value calculation
- Inventory worth display

---

###### `get_weight() -> float`

Returns the item's weight.

**Returns:** Weight as float

**Example:**
```gdscript
var armor = Pandora.get_entity("PLATE_ARMOR") as PPItemEntity
var weight = armor.get_weight()
print("Weight: ", weight, " kg")  # 25.0 kg

# Check if can carry
var current_weight = inventory.get_current_weight()
if current_weight + weight <= max_carry_weight:
    inventory.add_item(armor, 1)
```

**Use Cases:**
- Inventory weight limits
- Encumbrance calculations
- Movement speed penalties

---

## Creating Items in Pandora

### In Pandora Editor

1. Open **Pandora Editor** (usually in bottom panel)
2. Go to **Items** category
3. Click **Create Entity**
4. Select **PPItemEntity** as type
5. Fill in properties:

```
Entity ID: HEALTH_POTION
Type: PPItemEntity

Properties:
├── name: "Health Potion"
├── description: "Restores 50 HP"
├── texture: [load texture from resources]
├── stackable: true
├── rarity: [reference to Common rarity]
├── value: 50.0
└── weight: 0.5
```

### Via GDScript (Runtime)

```gdscript
# Get Items category
var items_category = Pandora.get_category(PandoraCategories.ITEMS)

# Create new item entity
var new_item = Pandora.create_entity(items_category, "MAGIC_SCROLL") as PPItemEntity

# Set properties using Pandora's API
new_item.set_string("name", "Magic Scroll")
new_item.set_string("description", "A mysterious scroll")
new_item.set_bool("stackable", true)
new_item.set_float("value", 100.0)
new_item.set_float("weight", 0.2)

# Save to Pandora
Pandora.save_data()
```

---

## Usage Examples

### Example 1: Inventory Display

```gdscript
func display_item_in_slot(slot_ui: Control, item: PPItemEntity):
    # Set icon
    var icon = slot_ui.get_node("Icon") as TextureRect
    icon.texture = item.get_texture()
    
    # Set name
    var label = slot_ui.get_node("Label") as Label
    label.text = item.get_item_name()
    
    # Color by rarity
    var rarity = item.get_rarity()
    if rarity:
        match rarity.get_rarity_name():
            "Common": label.modulate = Color.WHITE
            "Uncommon": label.modulate = Color.GREEN
            "Rare": label.modulate = Color.BLUE
            "Epic": label.modulate = Color.PURPLE
            "Legendary": label.modulate = Color.ORANGE
```

---

### Example 2: Item Tooltip

```gdscript
func show_tooltip(item: PPItemEntity):
    var tooltip = $Tooltip
    
    # Basic info
    tooltip.get_node("Name").text = item.get_item_name()
    tooltip.get_node("Description").text = item.get_description()
    tooltip.get_node("Icon").texture = item.get_texture()
    
    # Stats
    var stats_text = ""
    stats_text += "Value: %d gold\n" % item.get_value()
    stats_text += "Weight: %.1f kg\n" % item.get_weight()
    
    # Rarity
    var rarity = item.get_rarity()
    if rarity:
        stats_text += "Rarity: %s (%.2f%%)\n" % [
            rarity.get_rarity_name(),
            rarity.get_percentage()
        ]
    
    tooltip.get_node("Stats").text = stats_text
    tooltip.visible = true
```

---

### Example 3: Crafting Integration

```gdscript
func craft_item(recipe: PPRecipe, inventory: PPInventory) -> bool:
    # Check ingredients
    for ingredient in recipe.ingredients:
        var item = ingredient.item_entity as PPItemEntity
        var required = ingredient.quantity
        var has = inventory.count_item(item)
        
        if has < required:
            print("Missing: %s (need %d, have %d)" % [
                item.get_item_name(),
                required,
                has
            ])
            return false
    
    # Check weight
    var result_item = recipe.result_item as PPItemEntity
    var result_weight = result_item.get_weight() * recipe.result_quantity
    
    if not inventory.can_add_weight(result_weight):
        print("Result too heavy!")
        return false
    
    # Craft
    print("Crafted: %s" % result_item.get_item_name())
    return true
```

---

## Integration with Other Systems

### With PPInventory

```gdscript
var inventory = PPInventory.new(20, PPInventory.LimitType.BOTH)
inventory.max_weight = 50.0

var potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity

# Add item
if inventory.add_item(potion, 5):
    print("Added 5x %s" % potion.get_item_name())
    print("Total weight: %.1f / %.1f" % [
        inventory.get_current_weight(),
        inventory.max_weight
    ])
```

### With PPRecipe

```gdscript
var wood = Pandora.get_entity("WOOD") as PPItemEntity
var stone = Pandora.get_entity("STONE") as PPItemEntity
var sword = Pandora.get_entity("STONE_SWORD") as PPItemEntity

var recipe = PPRecipe.new()
recipe.ingredients = [
    PPIngredient.new(wood, 2),
    PPIngredient.new(stone, 3)
]
recipe.result_item = sword
recipe.result_quantity = 1

print("Recipe: %s" % sword.get_item_name())
print("Requires: 2x %s, 3x %s" % [
    wood.get_item_name(),
    stone.get_item_name()
])
```

---

## Common Patterns

### Pattern 1: Item Comparison

```gdscript
func compare_items(item_a: PPItemEntity, item_b: PPItemEntity) -> String:
    var value_diff = item_b.get_value() - item_a.get_value()
    var weight_diff = item_b.get_weight() - item_a.get_weight()
    
    var comparison = "%s vs %s:\n" % [item_a.get_item_name(), item_b.get_item_name()]
    comparison += "  Value: %+.0f gold\n" % value_diff
    comparison += "  Weight: %+.1f kg" % weight_diff
    
    return comparison
```

---

### Pattern 2: Item Filtering

```gdscript
func filter_by_rarity(items: Array[PPItemEntity], rarity_name: String) -> Array[PPItemEntity]:
    var filtered: Array[PPItemEntity] = []
    
    for item in items:
        var rarity = item.get_rarity()
        if rarity and rarity.get_rarity_name() == rarity_name:
            filtered.append(item)
    
    return filtered

# Usage
var legendary_items = filter_by_rarity(all_items, "Legendary")
```

---

### Pattern 3: Inventory Value

```gdscript
func calculate_inventory_value(inventory: PPInventory) -> float:
    var total_value = 0.0
    
    for slot in inventory.slots:
        if not slot.is_empty():
            var item = slot.item_entity as PPItemEntity
            total_value += item.get_value() * slot.quantity
    
    return total_value
```

---

## Best Practices

### ✅ Always Check for Null

```gdscript
# ✅ Good
var item = Pandora.get_entity("ITEM_ID") as PPItemEntity
if item:
    print(item.get_item_name())
else:
    push_error("Item not found!")

# ❌ Bad
var item = Pandora.get_entity("ITEM_ID") as PPItemEntity
print(item.get_item_name())  # Crash if item doesn't exist!
```

---

### ✅ Use Rarity for Visual Feedback

```gdscript
# ✅ Good: color-code by rarity
var rarity = item.get_rarity()
if rarity:
    var color = get_rarity_color(rarity.get_rarity_name())
    item_label.modulate = color
```

---

### ✅ Cache Item References

```gdscript
# ✅ Good: load once
var HEALTH_POTION: PPItemEntity
var MANA_POTION: PPItemEntity

func _ready():
    HEALTH_POTION = Pandora.get_entity("HEALTH_POTION") as PPItemEntity
    MANA_POTION = Pandora.get_entity("MANA_POTION") as PPItemEntity

# ❌ Bad: load every time
func use_potion():
    var potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity  # Slow!
```

---

## Notes

### Pandora Integration

`PPItemEntity` extends `PandoraEntity`, which means:

- All properties are stored in Pandora's data system
- Changes are automatically saved when calling `Pandora.save_data()`
- Items are serialized/deserialized by Pandora
- Items can be referenced across multiple systems

### @tool Annotation

The `@tool` annotation allows the script to run in the editor, enabling:
- Preview items in Pandora Editor
- Edit properties visually
- See changes in real-time

---

## See Also

- [PPRarityEntity](rarity-entity.md) - Rarity system
- [Inventory System](../core-systems/inventory-system.md) - Inventory system
- [PPRecipe](../properties/recipe.md) - Crafting system
- [Pandora Documentation](https://bitbra.in/pandora) - Base entity system

---

*API Reference generated from source code v1.1.1-core | v1.0.0-premium*