# Player Data

Centralized player state management for Pandora+ Core. Provides basic player information and integrates with the quest and save/load systems.

---

## Overview

`PPPlayerData` is a lightweight Resource class that stores basic player information. It's designed to integrate seamlessly with Pandora+'s quest system and save/load framework.

**Core Features:**
- Player name storage
- Game state tracking
- Save/load serialization
- Integration with PPGameState

---

## Quick Start

### Creating Player Data

```gdscript
# Create new player
var player_data = PPPlayerData.new()
player_data.set_player_name("Hero")

print(player_data.get_player_name())  # "Hero"
```

### Using with Save System

```gdscript
# Save player data
var game_state = PPGameState.new()
game_state.player_data = player_data

# Player data is automatically saved with quests and NPCs
```

---

## API Reference

### Properties

```gdscript
var player_name: String = ""
```

### Methods

#### set_player_name(name: String)
Sets the player's name.

```gdscript
player_data.set_player_name("Adventurer")
```

#### get_player_name() -> String
Gets the player's name.

```gdscript
var name = player_data.get_player_name()
print("Player name: ", name)
```

---

## Serialization

### Save Player Data

```gdscript
# Player data is saved as part of PPGameState
var game_state = PPGameState.new()
game_state.player_data = player_data

# Serialize to dictionary
var save_dict = {
    "player_name": player_data.get_player_name()
}

# Save to file
save_to_json(save_dict, "user://save_game.json")
```

### Load Player Data

```gdscript
# Load from file
var save_dict = load_from_json("user://save_game.json")

# Restore player data
var player_data = PPPlayerData.new()
player_data.set_player_name(save_dict.get("player_name", ""))
```

---

## Integration with Game Systems

### Quest System Integration

Player data is automatically tracked alongside quest progress:

```gdscript
# Quest system uses completed quests to determine available quests
var completed_ids = PPQuestManager.get_completed_quest_ids()

# These are saved with player_data in PPGameState
```

### NPC System Integration

NPCs can reference player state indirectly through quest completion:

```gdscript
# NPC gives quests based on player's completed quests
var completed = PPQuestManager.get_completed_quest_ids()
var quests = runtime_npc.get_available_quests(completed)
```

---

## Common Patterns

### Pattern 1: New Game Setup

```gdscript
func start_new_game(player_name: String):
    # Create player data
    var player_data = PPPlayerData.new()
    player_data.set_player_name(player_name)

    # Initialize game state
    var game_state = PPGameState.new()
    game_state.player_data = player_data

    # Clear quest history
    PPQuestManager.clear_all()

    print("Started new game as: ", player_name)
```

### Pattern 2: Save Game

```gdscript
func save_game(slot: int):
    # Gather all game data
    var game_state = PPGameState.new()

    # Player data
    game_state.player_data = global_player_data

    # Quest data
    PPQuestManager.save_state(game_state)

    # Serialize
    var save_dict = game_state.to_dict()

    # Save to file
    var file_path = "user://save_slot_%d.json" % slot
    save_to_json(save_dict, file_path)

    print("Game saved to slot %d" % slot)
```

### Pattern 3: Load Game

```gdscript
func load_game(slot: int):
    var file_path = "user://save_slot_%d.json" % slot

    # Load from file
    var save_dict = load_from_json(file_path)

    # Restore game state
    var game_state = PPGameState.from_dict(save_dict)

    # Restore player data
    global_player_data = game_state.player_data

    # Restore quest data
    PPQuestManager.load_state(game_state)

    print("Game loaded from slot %d" % slot)
    print("Welcome back, %s!" % global_player_data.get_player_name())
```

### Pattern 4: Character Selection

```gdscript
class_name CharacterCreationUI
extends Control

@onready var name_input: LineEdit = $NameInput
@onready var start_button: Button = $StartButton

func _ready():
    start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed():
    var player_name = name_input.text.strip_edges()

    if player_name.is_empty():
        show_error("Please enter a name")
        return

    # Create player data
    var player_data = PPPlayerData.new()
    player_data.set_player_name(player_name)

    # Start game
    GameManager.start_new_game(player_data)

    # Load first scene
    get_tree().change_scene_to_file("res://scenes/game_world.tscn")
```

---

## Best Practices

### ✅ Store Player Data Globally

```gdscript
# ✅ Good: single source of truth
# autoload: GameManager
var player_data: PPPlayerData = PPPlayerData.new()

func get_player_data() -> PPPlayerData:
    return player_data

# ❌ Bad: multiple instances
var player_data_1 = PPPlayerData.new()
var player_data_2 = PPPlayerData.new()  # Confusion!
```

### ✅ Validate Player Name

```gdscript
# ✅ Good: validate before setting
func set_player_name_safe(name: String) -> bool:
    var clean_name = name.strip_edges()

    if clean_name.is_empty():
        push_error("Player name cannot be empty")
        return false

    if clean_name.length() > 20:
        push_error("Player name too long (max 20 characters)")
        return false

    player_data.set_player_name(clean_name)
    return true

# ❌ Bad: no validation
player_data.set_player_name("")  # Empty name!
```

### ✅ Always Save with Game State

```gdscript
# ✅ Good: coordinated save
var game_state = PPGameState.new()
game_state.player_data = player_data
PPQuestManager.save_state(game_state)
save_game_state(game_state)

# ❌ Bad: save separately
save_player_data(player_data)  # May get out of sync
save_quest_data()              # with quest data
```

---

## Extending Player Data

The Core edition provides minimal player data. For a commercial project, you may want to extend it:

### Custom Player Data

```gdscript
class_name MyPlayerData
extends PPPlayerData

# Additional properties
var level: int = 1
var experience: int = 0
var class_type: String = "Warrior"

func set_level(new_level: int) -> void:
    level = new_level

func get_level() -> int:
    return level

func add_experience(amount: int) -> void:
    experience += amount
    check_level_up()

func check_level_up() -> void:
    var required = level * 100
    if experience >= required:
        level += 1
        experience -= required
        emit_signal("level_up", level)

# Override serialization
func to_dict() -> Dictionary:
    return {
        "player_name": get_player_name(),
        "level": level,
        "experience": experience,
        "class_type": class_type
    }

static func from_dict(data: Dictionary) -> MyPlayerData:
    var player = MyPlayerData.new()
    player.set_player_name(data.get("player_name", ""))
    player.level = data.get("level", 1)
    player.experience = data.get("experience", 0)
    player.class_type = data.get("class_type", "Warrior")
    return player
```

### Usage with Extended Data

```gdscript
# Create extended player data
var player_data = MyPlayerData.new()
player_data.set_player_name("Hero")
player_data.set_level(5)
player_data.class_type = "Mage"

# Save
var save_dict = player_data.to_dict()

# Load
var loaded_player = MyPlayerData.from_dict(save_dict)
print("Level %d %s" % [loaded_player.level, loaded_player.class_type])
```

---

## 💎 Premium Features

In **Pandora+ Premium**, `PPPlayerData` is significantly expanded with RPG features:

### Leveling & Progression

**Premium only** - Full character progression system:

```gdscript
var player_data = PPPlayerData.new()

// Set level and experience
player_data.level = 1
player_data.experience = 0
player_data.skill_points = 0

# Add experience
if player_data.add_experience(500):
    print("Level up!")
    player_data.level += 1
    player_data.skill_points += ProjectSettings.get_setting(
        "pandora_plus/config/player/skill_points_per_level"
    )

# Check progression
var exp_needed = player_data.get_exp_for_next_level()
var progress = player_data.get_level_progress()  # 0.0 to 1.0
print("Level %d (%d%% to next)" % [player_data.level, progress * 100])
```

---

### Reputation System

**Premium only** - Track relationships with NPCs and factions:

```gdscript
# NPC reputation (-100 to +100)
player_data.set_npc_reputation("VILLAGE_ELDER", 50)
player_data.modify_npc_reputation("VILLAGE_ELDER", 10)  # Increase by 10
var rep = player_data.get_npc_reputation("VILLAGE_ELDER")

# Faction reputation (-100 to +100)
player_data.set_faction_reputation("KINGDOM", 25)
player_data.modify_faction_reputation("KINGDOM", 15)  # Increase by 15
var faction_rep = player_data.get_faction_reputation("KINGDOM")

# Affects merchant prices, quest availability, dialogue options
```

---

### Full Inventory System

**Premium only** - Complete inventory management:

```gdscript
# Initialize inventory
player_data.inventory = PPInventory.new(30, 10)  # 30 slots, 10 equipped slots

# Add items
var sword = Pandora.get_entity("IRON_SWORD") as PPItemEntity
player_data.inventory.add_item(sword, 1)

# Manage currency
player_data.inventory.add_currency(100)
player_data.inventory.remove_currency(50)

# Full inventory API available
```

---

### Stats & Equipment

**Premium only** - Character statistics:

```gdscript
# Base stats (without equipment)
player_data.base_stats = PPStats.new()

# Runtime stats (with equipment and modifiers)
var stats_dict = {"health": 100, "attack": 15, "defense": 5}
player_data.runtime_stats = PPRuntimeStats.new(stats_dict)

# Equipped items stats
player_data.equipped_stats = PPRuntimeStats.new()

# Get effective stats
var effective_health = player_data.runtime_stats.get_effective_stat("health")
```

---

### Progress Tracking

**Premium only** - Game progress features:

```gdscript
# Unlock recipes
player_data.unlock_recipe("IRON_SWORD_RECIPE")
if player_data.has_recipe("IRON_SWORD_RECIPE"):
    print("Can craft Iron Sword")

# Discover locations
player_data.discover_location("ANCIENT_RUINS")
if player_data.is_location_discovered("ANCIENT_RUINS"):
    print("Fast travel unlocked")

# Achievements
player_data.unlock_achievement("FIRST_KILL")
if player_data.has_achievement("FIRST_KILL"):
    print("Achievement unlocked!")
```

---

### Position & Checkpoints

**Premium only** - World state tracking:

```gdscript
# Current position
player_data.world_position = Vector3(100, 0, 50)
player_data.current_scene = "res://scenes/world.tscn"

# Checkpoint for respawn
player_data.checkpoint_position = Vector3(0, 0, 0)
player_data.checkpoint_scene = "res://scenes/town.tscn"

# On death, respawn at checkpoint
func on_player_death():
    get_tree().change_scene_to_file(player_data.checkpoint_scene)
    player.global_position = player_data.checkpoint_position
```

---

### Custom Data

**Core & Premium** - Extensible data storage:

```gdscript
# Store custom game-specific data
player_data.custom_data["reputation_modifiers"] = {"diplomacy": 1.2}
player_data.custom_data["completed_puzzles"] = ["PUZZLE_1", "PUZZLE_2"]
player_data.custom_data["skill_tree"] = {
    "strength_1": true,
    "agility_2": false
}

# Retrieve custom data
var modifiers = player_data.custom_data.get("reputation_modifiers", {})
```

---

### Serialization

**Core & Premium** - Complete save/load support:

```gdscript
# Save player data
var save_dict = player_data.to_dict()
var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
file.store_var(save_dict)
file.close()

# Load player data
var file = FileAccess.open("user://save.dat", FileAccess.READ)
var loaded_dict = file.get_var()
file.close()
var player_data = PPPlayerData.from_dict(loaded_dict)

# Summary
print(player_data.get_summary())
# Output:
# Player Data Summary:
#   Name: Hero
#   Level: 5 (Premium)
#   Unlocked Recipes: 12
#   Discovered Locations: 8
#   Achievements: 5
```

---

**See full API reference:** [PPPlayerData](../api/player-data.md)

[See Core vs Premium comparison →](../core-vs-premium.md)

---

## See Also

- [Quest System](quest-system.md) - Quest integration
- [NPC System](npc-system.md) - NPC interaction
- [PPGameState](../api/game-state.md) - Save/load system

---

*Complete Guide for Pandora+ v1.0.0*
