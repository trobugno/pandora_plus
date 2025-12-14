# Getting Started

Welcome to **Pandora+**! This guide will walk you through your first steps with Pandora+ and help you create your first RPG system in minutes.

## 📚 What You'll Learn

By the end of this guide, you'll know how to:

- ✅ Set up a player with runtime stats
- ✅ Create and manage an inventory
- ✅ Use the crafting system

**Estimated time:** 10-15 minutes

---

## 🎯 Prerequisites Check

Before starting, make sure you have:

- ✅ **Godot Engine 4.5+** installed
- ✅ **Pandora 1.0-alpha9+** installed and enabled
- ✅ **Pandora+ 0.3.0-beta** installed and enabled
- ✅ Basic understanding of GDScript

> **Haven't installed Pandora+ yet?** Go to [Installation Guide](getting-started/install.md) first.

---

## 🚀 Quick Start: Your First RPG Character

Let's create a complete player character with stats, inventory, and crafting abilities.

### Step 1: Create Player Scene

1. Create a new scene with **CharacterBody2D** as root
2. Add a **Sprite2D** (or use your own sprite)
3. Add a **CollisionShape2D**
4. Save as `player.tscn`

### Step 2: Setup Pandora Entities

First, let's define some items in Pandora:

1. Open **Pandora Editor** (usually in bottom panel or as dock)
2. Go to **Items** category
3. Create these entities:

**Health Potion:**
```
Entity ID: HEALTH_POTION
Name: Health Potion
Type: PPItemEntity
Properties:
  - weight: 0.5
  - value: 50
  - consumable: true
```

**Wood:**
```
Entity ID: WOOD
Name: Wood
Type: PPItemEntity
Properties:
  - weight: 1.0
  - value: 5
  - stackable: true
```

**Stone:**
```
Entity ID: STONE
Name: Stone
Type: PPItemEntity
Properties:
  - weight: 2.0
  - value: 10
  - stackable: true
```

**Stone Sword:**
```
Entity ID: STONE_SWORD
Name: Stone Sword
Type: PPItemEntity
Properties:
  - weight: 5.0
  - value: 100
  - equippable: true
```

### Step 3: Create Player Script

Attach a script to your player (`player.gd`):

```gdscript
extends CharacterBody2D

## Player's runtime stats
var runtime_stats: PPRuntimeStats

## Player's inventory
var inventory: PPInventory

## Base stats definition
const BASE_STATS = {
	"health": 100.0,
	"mana": 50.0,
	"attack": 15.0,
	"defense": 8.0,
	"att_speed": 1.0,
	"mov_speed": 200.0,
	"crit_rate": 5.0,
	"crit_damage": 150.0
}


func _ready() -> void:
	_initialize_stats()
	_initialize_inventory()
	_add_starting_items()
	_print_character_info()


func _initialize_stats() -> void:
	# Create runtime stats from base
	runtime_stats = PPRuntimeStats.new(BASE_STATS)
	
	print("✅ Stats initialized successfully")


func _initialize_inventory() -> void:
	# Create inventory: 20 slots, 6 slots for equipment
	inventory = PPInventory.new(20, 6)
    inventory.max_weight = 50.0
	
	# Connect signals
	inventory.item_added.connect(_on_item_added)
	inventory.item_removed.connect(_on_item_removed)
	
	print("✅ Inventory initialized: %d slots, %d equipment slots, %.1f max weight" % [
		inventory.max_items_in_inventory,
        inventory.max_items_in_equipments
		inventory.max_weight
	])


func _add_starting_items() -> void:
	# Add starting items from Pandora
	var health_potion = Pandora.get_entity("HEALTH_POTION") as PPItemEntity
	var wood = Pandora.get_entity("WOOD") as PPItemEntity
	var stone = Pandora.get_entity("STONE") as PPItemEntity
	
	inventory.add_item(health_potion, 3)
	inventory.add_item(wood, 10)
	inventory.add_item(stone, 5)


func _print_character_info() -> void:
	print("\n=== CHARACTER INFO ===")
	print("Health: %.0f" % runtime_stats.get_effective_stat("health"))
	print("Attack: %.0f" % runtime_stats.get_effective_stat("attack"))
	print("Defense: %.0f" % runtime_stats.get_effective_stat("defense"))
	print("Inventory: %d/%d slots used" % [
		inventory.get_occupied_slots(),
		inventory.max_items_in_inventory
	])
	print("Total weight: %.1f/%.1f" % [
		inventory.get_current_weight(),
		inventory.max_weight
	])


func _on_item_added(item_entity: PPItemEntity, quantity: int, slot_index: int) -> void:
	print("➕ Added: %s x%d" % [item_entity.get_entity_name(), quantity])


func _on_item_removed(item_entity: PPItemEntity, quantity: int, slot_index: int) -> void:
	print("➖ Removed: %s x%d" % [item_entity.get_entity_name(), quantity])
```

### Step 4: Test Your Character

1. Run the scene (F6)
2. Check the **Output** panel
3. You should see:

```
✅ Stats initialized successfully
✅ Inventory initialized: 20 slots, 6 equipment slots, 50.0 max weight
➕ Added: HEALTH_POTION x3
➕ Added: WOOD x10
➕ Added: STONE x5

=== CHARACTER INFO ===
Health: 100
Attack: 15
Defense: 8
Inventory: 3/20 slots used
Total weight: 26.5/50.0
```

**Congratulations!** 🎉 You've created your first character with Pandora+!

---

## 🔨 Crafting System Example

Now let's add crafting! Add this method:

```gdscript
func craft_stone_sword() -> void:
	# Get entities
	var wood = Pandora.get_entity("WOOD") as PPItemEntity
	var stone = Pandora.get_entity("STONE") as PPItemEntity
	var sword = Pandora.get_entity("STONE_SWORD") as PPItemEntity
	
	# Create recipe
	var wood_ingredient = PPIngredient.new(wood, 2)
	var stone_ingredient = PPIngredient.new(stone, 3)
	var sword_result = PandoraReference.new(sword)
	
	var ingredients = [wood_ingredient, stone_ingredient]
	var recipe = PPRecipe.new(ingredients, sword_result, 1, "CRAFTING")
	
	# Try to craft
	if PPRecipeUtils.can_craft(inventory, recipe):
		PPRecipeUtils.craft_recipe(inventory, recipe)
		print("✅ Crafted Stone Sword!")
	else:
		print("❌ Not enough materials to craft Stone Sword")
		print("   Need: 2 Wood, 3 Stone")
		print("   Have: %d Wood, %d Stone" % [
			inventory.count_item(wood),
			inventory.count_item(stone)
		])
```

---

## 🎓 What's Next?

Now that you have the basics, explore more:

### Core Systems
- [Runtime Stats System](core-systems/runtime-stats.md) - Deep dive into stats
- [Inventory System](core-systems/inventory.md) - Advanced inventory features
- [Recipe System](core-systems/recipe.md) - Recipes

### Utilities
- [CombatCalculator](utilities/combat-calculator.md) - Damage calculation
- [RecipeUtils](utilities/recipe-utils.md) - Complex crafting recipes

---

## 💡 Tips & Best Practices

### Performance
- 🚀 Use `PPRuntimeStats` cache - it recalculates only when modifiers change
- 🚀 Batch inventory operations when possible

### Architecture
- 📦 Store base stats in Pandora entities
- 📦 Use `PPRuntimeStats` for runtime calculations
- 📦 Separate UI from logic (use signals)

---

## 🤝 Need Help?

- 🐛 [Report an issue](https://github.com/trobugno/pandora_plus/issues)
- 💬 [Ask in Discussions](https://github.com/trobugno/pandora_plus/discussions)
