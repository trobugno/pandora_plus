# PPPlayerData

**Extends:** `Resource`

Complete player data container for save/load systems, including inventory, stats, position, and game progress.

---

## Description

`PPPlayerData` is a centralized data structure that holds all player-specific runtime information. It's designed for easy serialization, making it perfect for save/load systems.

This class contains:
- **Basic Info**: Player name, 💎 level, 💎 experience, 💎 skill points
- **Inventory & Equipment**: Full inventory and equipped items
- **Stats & Combat**: Base stats, runtime stats, and active status effects
- **Position & Scene**: Current location and checkpoint data
- **💎 Relationships**: NPC and faction reputation tracking
- **Game Progress**: Unlocked recipes, discovered locations, achievements
- **Custom Data**: Extensible dictionary for game-specific features

---

## Properties

### Basic Info

###### `player_name: String`

Player's display name.

**Default:** `"Hero"`

---

###### 💎 `level: int`

Player's current level.

**Default:** `1`

**Premium Only**

---

###### 💎 `experience: int`

Player's current experience points.

**Default:** `0`

**Premium Only**

---

###### 💎 `skill_points: int`

Available skill points to spend.

**Default:** `0`

**Premium Only**

---

### Inventory & Equipment

###### `inventory: PPInventory`

Player's inventory instance containing all items and currency.

---

###### `equipped_stats: PPRuntimeStats`

Runtime stats derived from equipped items (separate from base stats).

---

### Stats & Combat

###### `base_stats: PPStats`

Player's base stats without equipment or modifiers.

---

###### `runtime_stats: PPRuntimeStats`

Player's runtime stats with all modifiers applied (equipment, buffs, etc.).

---

###### `active_status_effects: Array`

Array of active status effects (`PPStatusEffect` instances).

---

### Position & Scene

###### `world_position: Vector3`

Player's current world position.

**Default:** `Vector3.ZERO`

---

###### `current_scene: String`

Path to the current scene.

---

###### `checkpoint_position: Vector3`

Last checkpoint position for respawn.

**Default:** `Vector3.ZERO`

---

###### `checkpoint_scene: String`

Scene path of the last checkpoint.

---

### 💎 Relationships (Premium Only)

###### 💎 `npc_reputations: Dictionary`

NPC reputation values (npc_entity_id -> reputation int).

**Range:** `-100` (hostile) to `+100` (allied)

**Default:** `{}`

**Premium Only**

---

###### 💎 `faction_reputations: Dictionary`

Faction reputation values (faction_name -> reputation int).

**Range:** `-100` (hostile) to `+100` (allied)

**Default:** `{}`

**Premium Only**

---

### Game Progress

###### `unlocked_recipes: Array[String]`

Array of unlocked recipe entity IDs.

---

###### `discovered_locations: Array[String]`

Array of discovered location entity IDs.

---

###### `achievements: Array[String]`

Array of unlocked achievement IDs.

---

### Custom Data

###### `custom_data: Dictionary`

Dictionary for storing custom player-specific data and mod support.

---

## Constructor

###### `PPPlayerData()`

Creates a new player data instance with default values.

**Example:**
```gdscript
var player_data = PPPlayerData.new()
player_data.player_name = "Adventurer"

# Initialize with custom stats
var base = PPStats.new()
# Configure base stats...
player_data.base_stats = base
player_data.runtime_stats = PPRuntimeStats.new(base)
```

---

## Methods

### Serialization

###### `to_dict() -> Dictionary`

Serializes all player data to a dictionary for saving.

**Returns:** Dictionary containing complete player state

**Example:**
```gdscript
var save_data = player_data.to_dict()

var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
file.store_var(save_data)
file.close()
```

---

###### `from_dict(data: Dictionary) -> PPPlayerData` (static)

Deserializes player data from a dictionary.

**Parameters:**
- `data`: Dictionary created by `to_dict()`

**Returns:** New `PPPlayerData` instance

**Example:**
```gdscript
var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
var save_data = file.get_var()
file.close()

var player_data = PPPlayerData.from_dict(save_data)
```

---

### Progress Helpers

###### `unlock_recipe(recipe_id: String) -> void`

Unlocks a crafting recipe.

**Parameters:**
- `recipe_id`: Recipe entity ID

**Example:**
```gdscript
player_data.unlock_recipe("IRON_SWORD_RECIPE")
```

---

###### `has_recipe(recipe_id: String) -> bool`

Checks if a recipe is unlocked.

**Parameters:**
- `recipe_id`: Recipe entity ID

**Returns:** `true` if recipe is unlocked

---

###### `discover_location(location_id: String) -> void`

Marks a location as discovered.

**Parameters:**
- `location_id`: Location entity ID

---

###### `is_location_discovered(location_id: String) -> bool`

Checks if a location has been discovered.

**Parameters:**
- `location_id`: Location entity ID

**Returns:** `true` if location is discovered

---

###### `unlock_achievement(achievement_id: String) -> void`

Unlocks an achievement.

**Parameters:**
- `achievement_id`: Achievement identifier

---

###### `has_achievement(achievement_id: String) -> bool`

Checks if an achievement is unlocked.

**Parameters:**
- `achievement_id`: Achievement identifier

**Returns:** `true` if achievement is unlocked

---

### 💎 Reputation Helpers (Premium Only)

###### 💎 `set_npc_reputation(npc_id: String, reputation: int) -> void`

Sets reputation with an NPC.

**Parameters:**
- `npc_id`: NPC entity ID
- `reputation`: Reputation value (-100 to 100)

**Premium Only**

**Example:**
```gdscript
player_data.set_npc_reputation("VILLAGE_ELDER", 50)
```

---

###### 💎 `get_npc_reputation(npc_id: String) -> int`

Gets reputation with an NPC.

**Parameters:**
- `npc_id`: NPC entity ID

**Returns:** Reputation value (0 if not set)

**Premium Only**

---

###### 💎 `modify_npc_reputation(npc_id: String, amount: int) -> void`

Modifies reputation with an NPC.

**Parameters:**
- `npc_id`: NPC entity ID
- `amount`: Amount to change (positive or negative)

**Premium Only**

**Example:**
```gdscript
player_data.modify_npc_reputation("VILLAGE_ELDER", 10)  # Increase by 10
player_data.modify_npc_reputation("BANDIT_LEADER", -25)  # Decrease by 25
```

---

###### 💎 `set_faction_reputation(faction_name: String, reputation: int) -> void`

Sets reputation with a faction.

**Parameters:**
- `faction_name`: Faction identifier
- `reputation`: Reputation value (-100 to 100)

**Premium Only**

---

###### 💎 `get_faction_reputation(faction_name: String) -> int`

Gets reputation with a faction.

**Parameters:**
- `faction_name`: Faction identifier

**Returns:** Reputation value (0 if not set)

**Premium Only**

---

###### 💎 `modify_faction_reputation(faction_name: String, amount: int) -> void`

Modifies reputation with a faction.

**Parameters:**
- `faction_name`: Faction identifier
- `amount`: Amount to change (positive or negative)

**Premium Only**

**Example:**
```gdscript
player_data.modify_faction_reputation("KINGDOM", 15)
player_data.modify_faction_reputation("BANDITS", -30)
```

---

### 💎 Experience & Leveling Helpers (Premium Only)

###### 💎 `add_experience(amount: int) -> bool`

Adds experience points and checks for level up.

**Parameters:**
- `amount`: Experience to add

**Returns:** `true` if player leveled up

**Premium Only**

**Example:**
```gdscript
if player_data.add_experience(500):
    print("Level up!")
    player_data.level += 1
    player_data.skill_points += ProjectSettings.get_setting("pandora_plus/config/player/skill_points_per_level")
```

---

###### 💎 `get_exp_for_next_level() -> int`

Calculates experience needed for next level.

**Returns:** Experience required for next level

**Premium Only**

**Note:** Default formula is `level * 1000`. Override for custom leveling curves.

---

###### 💎 `get_level_progress() -> float`

Calculates experience progress to next level.

**Returns:** Progress percentage (0.0 to 1.0)

**Premium Only**

**Example:**
```gdscript
var progress = player_data.get_level_progress()
$ProgressBar.value = progress * 100  # Convert to percentage
```

---

### Utility Methods

###### `get_summary() -> String`

Returns a human-readable summary of player data.

**Returns:** Formatted summary string

**Example:**
```gdscript
print(player_data.get_summary())
# Output:
# Player Data Summary:
#   Name: Hero
#   Scene: res://scenes/world.tscn
#   Unlocked Recipes: 12
#   Discovered Locations: 8
#   Achievements: 5
```

---

## Usage Example

### Example: Complete Save/Load System

```gdscript
extends Node

const SAVE_PATH = "user://save_game.dat"

var player_data: PPPlayerData

func _ready():
    # Initialize new game
    player_data = PPPlayerData.new()
    player_data.player_name = "Hero"

    # Setup inventory
    player_data.inventory = PPInventory.new(30, 10)

    # Setup stats
    var base_stats_dict = {
        "health": 100.0,
        "mana": 50.0,
        "attack": 10.0,
        "defense": 5.0
    }
    player_data.runtime_stats = PPRuntimeStats.new(base_stats_dict)

func save_game() -> bool:
    var save_data = player_data.to_dict()

    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if not file:
        push_error("Failed to open save file for writing")
        return false

    file.store_var(save_data)
    file.close()

    print("Game saved successfully")
    return true

func load_game() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        push_warning("Save file does not exist")
        return false

    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not file:
        push_error("Failed to open save file for reading")
        return false

    var save_data = file.get_var()
    file.close()

    player_data = PPPlayerData.from_dict(save_data)

    print("Game loaded successfully")
    print(player_data.get_summary())

    return true

func apply_player_data_to_scene(player: CharacterBody2D) -> void:
    # Apply position
    player.global_position = Vector2(
        player_data.world_position.x,
        player_data.world_position.y
    )

    # Apply inventory
    player.inventory = player_data.inventory

    # Apply stats
    player.runtime_stats = player_data.runtime_stats

func capture_player_data_from_scene(player: CharacterBody2D) -> void:
    # Capture position
    var pos = player.global_position
    player_data.world_position = Vector3(pos.x, pos.y, 0)

    # Capture current scene
    player_data.current_scene = get_tree().current_scene.scene_file_path

    # References are already synced
```

---

### Example: Achievement System

```gdscript
extends Node

signal achievement_unlocked(achievement_id: String)

var player_data: PPPlayerData

var achievement_definitions = {
    "FIRST_KILL": {"name": "First Blood", "desc": "Defeat your first enemy"},
    "TREASURE_HUNTER": {"name": "Treasure Hunter", "desc": "Open 10 chests"},
    "MASTER_CHEF": {"name": "Master Chef", "desc": "Craft 50 recipes"}
}

func check_achievement(achievement_id: String) -> void:
    if player_data.has_achievement(achievement_id):
        return  # Already unlocked

    var condition_met = false

    match achievement_id:
        "FIRST_KILL":
            condition_met = check_first_kill_condition()
        "TREASURE_HUNTER":
            condition_met = check_treasure_condition()
        "MASTER_CHEF":
            condition_met = check_crafting_condition()

    if condition_met:
        unlock_achievement(achievement_id)

func unlock_achievement(achievement_id: String) -> void:
    player_data.unlock_achievement(achievement_id)

    var achievement = achievement_definitions.get(achievement_id)
    if achievement:
        print("Achievement Unlocked: %s" % achievement["name"])
        show_achievement_notification(achievement)

    achievement_unlocked.emit(achievement_id)
```

---

### Example: Recipe Discovery

```gdscript
extends Node

var player_data: PPPlayerData

func discover_recipe(recipe_id: String) -> void:
    if player_data.has_recipe(recipe_id):
        print("Recipe already known")
        return

    player_data.unlock_recipe(recipe_id)

    var recipe_entity = Pandora.get_entity(recipe_id) as PandoraEntity
    print("New recipe discovered: %s" % recipe_entity.get_string("name"))

    show_recipe_notification(recipe_entity)

func can_craft_recipe(recipe_id: String) -> bool:
    # Check if recipe is unlocked
    if not player_data.has_recipe(recipe_id):
        return false

    # Check if player has ingredients
    var recipe_entity = Pandora.get_entity(recipe_id)
    var recipe_property = recipe_entity.get_entity_property("recipe_data")
    var recipe = recipe_property.get_default_value() as PPRecipe

    for ingredient in recipe.get_ingredients():
        var item = ingredient.get_item_entity()
        var qty = ingredient.get_quantity()

        if not player_data.inventory.has_item(item, qty):
            return false

    return true

func get_unlocked_recipes() -> Array:
    var recipes = []
    for recipe_id in player_data.unlocked_recipes:
        var recipe_entity = Pandora.get_entity(recipe_id)
        if recipe_entity:
            recipes.append(recipe_entity)
    return recipes
```

---

## Best Practices

### ✅ Save Regularly

```gdscript
# ✅ Good: Auto-save on significant events
func _on_quest_completed(quest: PPRuntimeQuest):
    save_game()

func _on_checkpoint_reached():
    player_data.checkpoint_position = player.global_position
    player_data.checkpoint_scene = get_tree().current_scene.scene_file_path
    save_game()

# ✅ Good: Periodic auto-save
var autosave_timer = Timer.new()
autosave_timer.wait_time = 300.0  # 5 minutes
autosave_timer.timeout.connect(save_game)
```

---

### ✅ Validate Data After Loading

```gdscript
# ✅ Good: Validate loaded data
func load_game() -> bool:
    var player_data = PPPlayerData.from_dict(save_data)

    # Validate critical data
    if not player_data.inventory:
        push_error("Invalid save: No inventory data")
        return false

    if not player_data.runtime_stats:
        push_warning("Invalid stats, creating defaults")
        player_data.runtime_stats = PPRuntimeStats.new()

    return true
```

---

### ✅ Use Custom Data for Extensions

```gdscript
# ✅ Good: Store mod/custom data
player_data.custom_data["reputation"] = {
    "village_A": 50,
    "village_B": -20
}

player_data.custom_data["skill_tree"] = {
    "strength_1": true,
    "agility_2": false
}

# Retrieve later
var reputation = player_data.custom_data.get("reputation", {})
```

---

## Common Patterns

### Pattern 1: Checkpoint System

```gdscript
class CheckpointManager:
    var player_data: PPPlayerData

    func save_checkpoint(player: Node) -> void:
        player_data.checkpoint_position = player.global_position
        player_data.checkpoint_scene = get_tree().current_scene.scene_file_path

        print("Checkpoint saved")

    func respawn_at_checkpoint(player: Node) -> void:
        # Load checkpoint scene if different
        if player_data.checkpoint_scene != get_tree().current_scene.scene_file_path:
            get_tree().change_scene_to_file(player_data.checkpoint_scene)

        # Set player position
        player.global_position = player_data.checkpoint_position

        # Restore health
        if player_data.runtime_stats:
            player_data.runtime_stats.base_stats_data["health"] = player_data.runtime_stats._get_base_stat_value("health")
```

---

### Pattern 2: Location Discovery

```gdscript
class LocationManager:
    var player_data: PPPlayerData

    func discover_location(location_id: String) -> void:
        if player_data.is_location_discovered(location_id):
            return

        player_data.discover_location(location_id)

        var location = Pandora.get_entity(location_id)
        show_discovery_message(location.get_string("name"))

        # Unlock fast travel
        unlock_fast_travel_point(location_id)

    func get_discovered_locations() -> Array:
        var locations = []
        for loc_id in player_data.discovered_locations:
            locations.append(Pandora.get_entity(loc_id))
        return locations
```

---

## Notes

### Serialization

The `to_dict()` method serializes all player data including:
- Inventory (via `PPInventory.to_dict()`)
- Stats (via `PPRuntimeStats.to_dict()`)
- Status effects (when implemented)
- All progress arrays
- Custom data

### Vector3 for 2D Games

Even in 2D games, positions use `Vector3` for consistency. Use `Vector3(x, y, 0)` for 2D positions.

### Current Limitations

From the source code:
- `base_stats` deserialization is TODO (waiting for PPStats implementation)
- `active_status_effects` deserialization is TODO (waiting for status effect finalization)

---

## See Also

- [PPInventory](../api/inventory.md) - Inventory system
- [PPRuntimeStats](../api/runtime-stats.md) - Stat system
- [Player Data System](../core-systems/player-data.md) - Complete system overview

---

*API Reference generated from source code*
