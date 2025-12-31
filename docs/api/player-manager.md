# PPPlayerManager

**✅ Core & Premium** | **Autoload Singleton**

API reference for the Player Manager singleton - manages the current player state, inventory, stats, progression, and reputation during gameplay.

---

## Description

**PPPlayerManager** is an autoload singleton that manages the current player's PPPlayerData and provides a centralized API for all player-related operations. It handles inventory, equipment, stats, combat, progression, and integrates with the save/load system.

**Key Responsibilities:**
- Maintain player's PPPlayerData singleton
- Manage inventory and equipment
- Handle stats and combat
- Track position and checkpoints
- 💎 **Premium:** Manage leveling, experience, skill points
- 💎 **Premium:** Handle reputation with NPCs and factions
- Track unlocked content (recipes, locations, achievements)
- Integrate with SaveManager

**Access:** Available globally as `PPPlayerManager`

---

## Configuration Properties

### starting_currency

```gdscript
var starting_currency: int
```

Starting currency for new players.

**Default:** 0
**Configured via:** Project Settings → `pandora_plus/config/player/starting_currency`

---

### max_inventory_slots

```gdscript
var max_inventory_slots: int
```

Maximum inventory slots (-1 = unlimited).

**Default:** -1
**Configured via:** Project Settings → `pandora_plus/config/player/max_inventory_slots`

---

### respawn_health_percentage

```gdscript
var respawn_health_percentage: float
```

Health percentage when respawning (0.0 to 1.0).

**Default:** 1.0
**Configured via:** Project Settings → `pandora_plus/config/player/respawn_health_percentage`

---

### skill_points_per_level

```gdscript
var skill_points_per_level: int
```

**💎 Premium Only** - Skill points gained per level.

**Default:** 1
**Configured via:** Project Settings → `pandora_plus/config/player/skill_points_per_level`

---

### experience_curve

```gdscript
var experience_curve: Callable
```

**💎 Premium Only** - Function that calculates experience required for a level.

**Default:**
```gdscript
func(level: int) -> int:
    return level * 1000
```

**Example:**
```gdscript
# Custom experience curve
PPPlayerManager.experience_curve = func(level: int) -> int:
    return int(pow(level, 2) * 500)  # Quadratic growth
```

---

## Signals

### Initialization Signals

```gdscript
signal player_initialized(player_data: PPPlayerData)
signal player_cleared()
```

---

### Combat Signals

```gdscript
signal health_changed(old_value: float, new_value: float)
signal mana_changed(old_value: float, new_value: float)
signal died()
signal respawned()
```

---

### 💎 Premium: Progression Signals

```gdscript
signal leveled_up(old_level: int, new_level: int)
signal experience_gained(amount: int, total: int)
signal skill_points_gained(amount: int)
```

---

### Progress Signals

```gdscript
signal recipe_unlocked(recipe_id: String)
signal location_discovered(location_id: String)
signal achievement_unlocked(achievement_id: String)
```

---

### Position Signals

```gdscript
signal position_changed(old_position: Vector3, new_position: Vector3)
signal scene_changed(old_scene: String, new_scene: String)
signal checkpoint_set(position: Vector3, scene_path: String)
```

---

### Inventory Signals

```gdscript
signal item_added(item: PPItemEntity, quantity: int)
signal item_removed(item: PPItemEntity, quantity: int)
signal currency_changed(old_amount: int, new_amount: int)
```

---

### Equipment Signals

```gdscript
signal item_equipped(item: PPItemEntity)
signal item_unequipped(item: PPItemEntity)
```

---

### 💎 Premium: Reputation Signals

```gdscript
signal npc_reputation_changed(npc_id: String, old_value: int, new_value: int)
signal faction_reputation_changed(faction: String, old_value: int, new_value: int)
```

---

## Methods - Initialization

### initialize_new_player

```gdscript
func initialize_new_player(player_name: String, starting_level: int = 1, starting_scene: String = "") -> void
```

Initializes a new player.

**Parameters:**
- `player_name` (String) - Player's name
- `starting_level` (int) - 💎 Premium: Starting level (default 1)
- `starting_scene` (String) - Starting scene path (optional)

**Example:**
```gdscript
# Core
PPPlayerManager.initialize_new_player("Hero", 1, "res://scenes/village.tscn")

# 💎 Premium
PPPlayerManager.initialize_new_player("Veteran", 5, "res://scenes/city.tscn")
```

---

### is_initialized

```gdscript
func is_initialized() -> bool
```

Checks if player is initialized.

**Returns:** `bool` - `true` if initialized

---

### get_player_data

```gdscript
func get_player_data() -> PPPlayerData
```

Gets the player data.

**Returns:** `PPPlayerData` - Current player data or `null`

---

### clear

```gdscript
func clear() -> void
```

Clears player state (for new game).

---

## Methods - Basic Info

### get_player_name / set_player_name

```gdscript
func get_player_name() -> String
func set_player_name(new_name: String) -> void
```

Gets or sets player name.

---

### get_level / get_experience / get_skill_points

```gdscript
func get_level() -> int
func get_experience() -> int
func get_skill_points() -> int
```

**💎 Premium Only** - Gets player level, experience, or skill points.

**Example:**
```gdscript
# 💎 Premium
var level = PPPlayerManager.get_level()
var exp = PPPlayerManager.get_experience()
var sp = PPPlayerManager.get_skill_points()

print("Level %d - %d XP - %d SP" % [level, exp, sp])
```

---

## Methods - Experience & Leveling

### add_experience

```gdscript
func add_experience(amount: int) -> bool
```

**💎 Premium Only** - Adds experience to the player.

**Parameters:**
- `amount` (int) - Experience to add

**Returns:** `bool` - `true` if player leveled up

**Example:**
```gdscript
# 💎 Premium
# Give XP for killing enemy
var leveled_up = PPPlayerManager.add_experience(100)

if leveled_up:
    show_level_up_screen()
```

---

### set_experience

```gdscript
func set_experience(amount: int) -> void
```

**💎 Premium Only** - Sets experience directly.

---

### can_level_up

```gdscript
func can_level_up() -> bool
```

**💎 Premium Only** - Checks if player has enough experience to level up.

**Returns:** `bool` - `true` if can level up

---

### level_up

```gdscript
func level_up() -> void
```

**💎 Premium Only** - Levels up the player.

**Notes:**
- Awards skill points based on `skill_points_per_level`
- Emits `leveled_up` and `skill_points_gained` signals

---

### spend_skill_point

```gdscript
func spend_skill_point() -> bool
```

**💎 Premium Only** - Spends one skill point.

**Returns:** `bool` - `true` if skill point was spent

**Example:**
```gdscript
# 💎 Premium
if PPPlayerManager.spend_skill_point():
    unlock_skill("fireball")
else:
    show_error("Not enough skill points")
```

---

### get_experience_for_next_level

```gdscript
func get_experience_for_next_level() -> int
```

**💎 Premium Only** - Gets experience required for next level.

**Returns:** `int` - Experience needed

---

### get_level_progress

```gdscript
func get_level_progress() -> float
```

**💎 Premium Only** - Gets experience progress to next level.

**Returns:** `float` - Progress (0.0 to 1.0)

**Example:**
```gdscript
# 💎 Premium
var progress = PPPlayerManager.get_level_progress()
exp_bar.value = progress * 100.0
```

---

## Methods - Inventory

### get_inventory

```gdscript
func get_inventory() -> PPInventory
```

Gets player inventory.

**Returns:** `PPInventory` - Player's inventory

---

### add_item

```gdscript
func add_item(item: PPItemEntity, quantity: int = 1) -> void
```

Adds item to inventory.

**Example:**
```gdscript
var sword = Pandora.get_entity("iron_sword") as PPItemEntity
PPPlayerManager.add_item(sword, 1)
```

---

### remove_item

```gdscript
func remove_item(item: PPItemEntity, quantity: int = 1) -> bool
```

Removes item from inventory.

**Returns:** `bool` - `true` if item was removed

---

### has_item

```gdscript
func has_item(item: PPItemEntity, quantity: int = 1) -> bool
```

Checks if player has item.

**Returns:** `bool` - `true` if has enough

---

### get_item_quantity

```gdscript
func get_item_quantity(item: PPItemEntity) -> int
```

Gets item quantity in inventory.

**Returns:** `int` - Quantity (0 if not found)

---

### add_currency / remove_currency / get_currency

```gdscript
func add_currency(amount: int) -> void
func remove_currency(amount: int) -> bool
func get_currency() -> int
```

Manages player currency (gold).

**Example:**
```gdscript
# Add gold
PPPlayerManager.add_currency(100)

# Remove gold
if PPPlayerManager.remove_currency(50):
    print("Purchased item")
else:
    print("Not enough gold")
```

---

## Methods - Equipment

### get_equipped_items

```gdscript
func get_equipped_items() -> Dictionary
```

Gets all equipped items.

**Returns:** `Dictionary` - Equipped items by slot

---

### equip_item / unequip_item

```gdscript
func equip_item(item: PPItemEntity) -> bool
func unequip_item(item: PPItemEntity) -> bool
```

Equips or unequips an item.

**Returns:** `bool` - `true` if successful

---

### unequip_slot

```gdscript
func unequip_slot(slot_name: String) -> bool
```

Unequips item from specific slot.

**Parameters:**
- `slot_name` (String) - Slot name ("HEAD", "WEAPON", etc.)

---

### is_item_equipped

```gdscript
func is_item_equipped(item: PPItemEntity) -> bool
```

Checks if item is equipped.

**Returns:** `bool` - `true` if equipped

---

## Methods - Stats & Combat

### get_runtime_stats / get_base_stats

```gdscript
func get_runtime_stats() -> PPRuntimeStats
func get_base_stats() -> PPStats
```

Gets runtime or base stats.

---

### get_effective_stat

```gdscript
func get_effective_stat(stat_name: String) -> float
```

Gets effective stat value (with modifiers).

---

### get_current_health / get_max_health

```gdscript
func get_current_health() -> float
func get_max_health() -> float
```

Gets current or maximum health.

---

### take_damage

```gdscript
func take_damage(amount: float) -> void
```

Applies damage to player.

**Example:**
```gdscript
PPPlayerManager.take_damage(25.0)
```

---

### heal

```gdscript
func heal(amount: float) -> void
```

Heals the player.

**Example:**
```gdscript
PPPlayerManager.heal(50.0)
```

---

### is_alive

```gdscript
func is_alive() -> bool
```

Checks if player is alive.

**Returns:** `bool` - `true` if health > 0

---

### die

```gdscript
func die() -> void
```

Kills the player.

---

### respawn

```gdscript
func respawn(health_percentage: float = -1.0) -> void
```

Respawns the player at checkpoint.

**Parameters:**
- `health_percentage` (float) - Health percentage (0.0-1.0), -1.0 uses config setting

---

## Methods - Position & Scene

### get_position / set_position

```gdscript
func get_position() -> Vector3
func set_position(pos: Vector3) -> void
```

Gets or sets player position.

---

### get_current_scene / set_current_scene

```gdscript
func get_current_scene() -> String
func set_current_scene(scene_path: String) -> void
```

Gets or sets current scene path.

---

### set_checkpoint

```gdscript
func set_checkpoint(position: Vector3, scene_path: String) -> void
```

Sets checkpoint for respawn.

---

### get_checkpoint_position / get_checkpoint_scene

```gdscript
func get_checkpoint_position() -> Vector3
func get_checkpoint_scene() -> String
```

Gets checkpoint data.

---

## Methods - Progress

### unlock_recipe / has_recipe / get_unlocked_recipes

```gdscript
func unlock_recipe(recipe_id: String) -> void
func has_recipe(recipe_id: String) -> bool
func get_unlocked_recipes() -> Array[String]
```

Manages unlocked recipes.

---

### discover_location / is_location_discovered / get_discovered_locations

```gdscript
func discover_location(location_id: String) -> void
func is_location_discovered(location_id: String) -> bool
func get_discovered_locations() -> Array[String]
```

Manages discovered locations.

---

### unlock_achievement / has_achievement / get_achievements

```gdscript
func unlock_achievement(achievement_id: String) -> void
func has_achievement(achievement_id: String) -> bool
func get_achievements() -> Array[String]
```

Manages achievements.

---

## Methods - 💎 Premium: Reputation

### modify_npc_reputation

```gdscript
func modify_npc_reputation(npc_id: String, amount: int) -> void
```

**💎 Premium Only** - Modifies reputation with an NPC.

**Parameters:**
- `npc_id` (String) - NPC entity ID
- `amount` (int) - Change amount (positive or negative)

**Example:**
```gdscript
# 💎 Premium
# Help NPC, gain reputation
PPPlayerManager.modify_npc_reputation("npc_blacksmith", 10)
```

---

### set_npc_reputation / get_npc_reputation

```gdscript
func set_npc_reputation(npc_id: String, value: int) -> void
func get_npc_reputation(npc_id: String) -> int
```

**💎 Premium Only** - Sets or gets NPC reputation (-100 to 100).

---

### modify_faction_reputation

```gdscript
func modify_faction_reputation(faction: String, amount: int) -> void
```

**💎 Premium Only** - Modifies reputation with a faction.

---

### set_faction_reputation / get_faction_reputation

```gdscript
func set_faction_reputation(faction: String, value: int) -> void
func get_faction_reputation(faction: String) -> int
```

**💎 Premium Only** - Sets or gets faction reputation (-100 to 100).

---

## Methods - State Management

### save_state / load_state

```gdscript
func save_state(game_state: PPGameState) -> void
func load_state(game_state: PPGameState) -> void
```

Saves or loads player state (called by SaveManager).

---

### get_summary

```gdscript
func get_summary() -> String
```

Gets debug summary of player state.

---

## Usage Examples

See the full documentation file for complete usage examples including:
- Player initialization
- Combat system
- 💎 Premium: Experience and leveling
- Inventory management
- Equipment system
- 💎 Premium: Reputation system

---

## See Also

- [Player Data System](../core-systems/player-data.md) - Complete player system guide
- [PPPlayerData](player-data.md) - Player data API
- [PPInventory](inventory.md) - Inventory API
- [PPRuntimeStats](runtime-stats.md) - Stats API

---

*API Reference for Pandora+ v1.0.0*
