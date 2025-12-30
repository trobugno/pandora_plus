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

In **Pandora+ Premium**, player data is significantly expanded with:

- **Player Stats** - Health, mana, strength, agility, etc.
- **Player Level & Experience** - Progression system
- **Player Class** - Character classes and specializations
- **Player Inventory** - Full inventory integration
- **Player Equipment** - Equipped items and slots
- **Player Skills** - Learned skills and abilities

[See Core vs Premium comparison →](../core-vs-premium.md)

---

## See Also

- [Quest System](quest-system.md) - Quest integration
- [NPC System](npc-system.md) - NPC interaction
- [PPGameState](../api/game-state.md) - Save/load system

---

*Complete Guide for Pandora+ v1.0.0*
