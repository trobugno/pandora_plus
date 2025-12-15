extends Node

## Player Manager (Autoload)
## Manages the current player state during gameplay
##
## Responsibilities:
## - Maintains the player's PPPlayerData singleton
## - Provides centralized API for player operations
## - Integrates with InventoryUtils, EquipmentUtils, CombatCalculator
## - Tracks unlocked content (recipes, locations, achievements)
## - Integrates with SaveManager
##
## Usage:
##   PPPlayerManager.initialize_new_player("Hero")
##   PPPlayerManager.add_item(item_entity, 5)

# ============================================================================
# SIGNALS
# ============================================================================

signal player_initialized(player_data: PPPlayerData)
signal player_cleared()

# Combat signals
signal health_changed(old_value: float, new_value: float)
signal mana_changed(old_value: float, new_value: float)
signal died()
signal respawned()

# Progress signals
signal recipe_unlocked(recipe_id: String)
signal location_discovered(location_id: String)
signal achievement_unlocked(achievement_id: String)

# Position signals
signal position_changed(old_position: Vector3, new_position: Vector3)
signal scene_changed(old_scene: String, new_scene: String)
signal checkpoint_set(position: Vector3, scene_path: String)

# Inventory signals
signal item_added(item: PPItemEntity, quantity: int)
signal item_removed(item: PPItemEntity, quantity: int)
signal currency_changed(old_amount: int, new_amount: int)

# Equipment signals
signal item_equipped(item: PPItemEntity)
signal item_unequipped(item: PPItemEntity)

# ============================================================================
# STATE
# ============================================================================

## Current player data (singleton)
var _player_data: PPPlayerData = null

## Whether player is initialized
var _is_initialized: bool = false

# ============================================================================
# CONFIGURATION (loaded from ProjectSettings)
# ============================================================================

## Starting currency for new players (loaded from settings)
var starting_currency: int = 0

## Max inventory slots (loaded from settings, -1 = unlimited)
var max_inventory_slots: int = -1

## Respawn health percentage (loaded from settings, 0.0 to 1.0)
var respawn_health_percentage: float = 1.0

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	_load_settings()
	print("PlayerManager initialized")
	print("  - Starting currency: %d" % starting_currency)
	print("  - Max inventory slots: %d" % max_inventory_slots)
	print("  - Respawn health: %.0f%%" % (respawn_health_percentage * 100))

func _load_settings() -> void:
	starting_currency = ProjectSettings.get_setting(
		PandoraPlusSettings.PLAYER_SETTING_STARTING_CURRENCY,
		PandoraPlusSettings.PLAYER_SETTING_STARTING_CURRENCY_VALUE
	)
	max_inventory_slots = ProjectSettings.get_setting(
		PandoraPlusSettings.PLAYER_SETTING_MAX_INVENTORY_SLOTS,
		PandoraPlusSettings.PLAYER_SETTING_MAX_INVENTORY_SLOTS_VALUE
	)
	respawn_health_percentage = ProjectSettings.get_setting(
		PandoraPlusSettings.PLAYER_SETTING_RESPAWN_HEALTH_PCT,
		PandoraPlusSettings.PLAYER_SETTING_RESPAWN_HEALTH_PCT_VALUE
	)

# ============================================================================
# PUBLIC API - Initialization
# ============================================================================

## Initializes a new player
## @param player_name: Player's name
## @param starting_scene: Starting scene path (optional)
func initialize_new_player(player_name: String, starting_scene: String = "") -> void:
	if _is_initialized:
		push_warning("PlayerManager: Player already initialized. Call clear() first.")
		return

	_player_data = PPPlayerData.new()
	_player_data.player_name = player_name
	_player_data.current_scene = starting_scene

	# Initialize inventory with configured settings
	_player_data.inventory = PPInventory.new(max_inventory_slots)
	_player_data.inventory.game_currency = starting_currency

	# Initialize runtime stats (placeholder - should be set by game)
	_player_data.runtime_stats = PPRuntimeStats.new()

	_is_initialized = true
	player_initialized.emit(_player_data)

	print("PlayerManager: Initialized player '%s'" % player_name)

## Checks if player is initialized
## @return bool: True if initialized
func is_initialized() -> bool:
	return _is_initialized

## Gets the player data
## @return PPPlayerData: Current player data or null
func get_player_data() -> PPPlayerData:
	return _player_data

## Clears player state (for new game)
func clear() -> void:
	_player_data = null
	_is_initialized = false
	player_cleared.emit()

# ============================================================================
# PUBLIC API - Basic Info
# ============================================================================

## Gets player name
## @return String: Player name
func get_player_name() -> String:
	if not _player_data:
		return ""
	return _player_data.player_name

## Sets player name
## @param new_name: New player name
func set_player_name(new_name: String) -> void:
	if not _player_data:
		return
	_player_data.player_name = new_name

# ============================================================================
# PUBLIC API - Inventory
# ============================================================================

## Gets player inventory
## @return PPInventory: Player's inventory
func get_inventory() -> PPInventory:
	if not _player_data:
		return null
	return _player_data.inventory

## Adds item to inventory
## @param item: Item to add
## @param quantity: Quantity to add
func add_item(item: PPItemEntity, quantity: int = 1) -> void:
	if not _player_data or not _player_data.inventory:
		return

	_player_data.inventory.add_item(item, quantity)
	item_added.emit(item, quantity)

## Removes item from inventory
## @param item: Item to remove
## @param quantity: Quantity to remove
## @return bool: True if item was removed (had enough quantity)
func remove_item(item: PPItemEntity, quantity: int = 1) -> bool:
	if not _player_data or not _player_data.inventory:
		return false

	# Check if player has enough of the item
	if not _player_data.inventory.has_item(item, quantity):
		return false

	_player_data.inventory.remove_item(item, quantity)
	item_removed.emit(item, quantity)

	return true

## Checks if player has item
## @param item: Item to check
## @param quantity: Required quantity
## @return bool: True if player has enough
func has_item(item: PPItemEntity, quantity: int = 1) -> bool:
	if not _player_data or not _player_data.inventory:
		return false

	return _player_data.inventory.has_item(item, quantity)

## Gets item quantity in inventory
## @param item: Item to check
## @return int: Quantity (0 if not found)
func get_item_quantity(item: PPItemEntity) -> int:
	if not _player_data or not _player_data.inventory:
		return 0

	return _player_data.inventory.get_item_quantity(item)

## Adds currency to player
## @param amount: Currency to add
func add_currency(amount: int) -> void:
	if not _player_data or not _player_data.inventory:
		return

	var old_currency = _player_data.inventory.game_currency
	_player_data.inventory.game_currency += amount
	currency_changed.emit(old_currency, _player_data.inventory.game_currency)

## Removes currency from player
## @param amount: Currency to remove
## @return bool: True if player had enough currency
func remove_currency(amount: int) -> bool:
	if not _player_data or not _player_data.inventory:
		return false

	if _player_data.inventory.game_currency < amount:
		return false

	var old_currency = _player_data.inventory.game_currency
	_player_data.inventory.game_currency -= amount
	currency_changed.emit(old_currency, _player_data.inventory.game_currency)

	return true

## Gets player's currency
## @return int: Current currency
func get_currency() -> int:
	if not _player_data or not _player_data.inventory:
		return 0

	return _player_data.inventory.game_currency

# ============================================================================
# PUBLIC API - Equipment
# ============================================================================

## Gets all equipped items
## @return Dictionary: Dictionary of equipped items
func get_equipped_items() -> Dictionary:
	if not _player_data or not _player_data.inventory:
		return {
			"HEAD": null,
			"CHEST": null,
			"LEGS": null,
			"WEAPON": null,
			"SHIELD": null,
			"ACCESSORY_1": null,
			"ACCESSORY_2": null
		}

	return _player_data.inventory.equipped_items

## Equips an item
## @param item: Item to equip (must be PPEquipmentEntity)
## @return bool: True if item was equipped
func equip_item(item: PPItemEntity) -> bool:
	if not _player_data or not _player_data.inventory or not _player_data.runtime_stats:
		return false

	# Item must be PPEquipmentEntity
	if not item is PPEquipmentEntity:
		push_warning("PlayerManager: Cannot equip non-equipment item '%s'" % item.get_entity_name())
		return false

	# Use PPEquipmentUtils for validation and equipping
	var success = PPEquipmentUtils.equip_item(_player_data.inventory, item as PPEquipmentEntity, _player_data.runtime_stats)
	if success:
		item_equipped.emit(item)

	return success

## Unequips an item
## @param item: Item to unequip (must be PPEquipmentEntity)
## @return bool: True if item was unequipped
func unequip_item(item: PPItemEntity) -> bool:
	if not _player_data or not _player_data.inventory or not _player_data.runtime_stats:
		return false

	# Item must be PPEquipmentEntity
	if not item is PPEquipmentEntity:
		push_warning("PlayerManager: Cannot unequip non-equipment item '%s'" % item.get_entity_name())
		return false

	# Find which slot the item is equipped in
	var equipment_item = item as PPEquipmentEntity
	var slot_name = equipment_item.get_equipment_slot()

	# Check if item is actually equipped in that slot
	if not _player_data.inventory.has_equipment_in_slot(slot_name):
		return false

	var equipped_slot = _player_data.inventory.get_equipped_item(slot_name)
	if not equipped_slot or equipped_slot.item.get_entity_id() != item.get_entity_id():
		return false

	# Use PPEquipmentUtils for unequipping
	var success = PPEquipmentUtils.unequip_item(_player_data.inventory, slot_name, _player_data.runtime_stats)
	if success:
		item_unequipped.emit(item)

	return success

## Unequips item from a specific slot
## @param slot_name: Equipment slot name (e.g., "HEAD", "WEAPON")
## @return bool: True if item was unequipped
func unequip_slot(slot_name: String) -> bool:
	if not _player_data or not _player_data.inventory or not _player_data.runtime_stats:
		return false

	# Check if slot has equipment
	if not _player_data.inventory.has_equipment_in_slot(slot_name):
		return false

	var equipped_slot = _player_data.inventory.get_equipped_item(slot_name)
	var item = equipped_slot.item

	# Use PPEquipmentUtils for unequipping
	var success = PPEquipmentUtils.unequip_item(_player_data.inventory, slot_name, _player_data.runtime_stats)
	if success:
		item_unequipped.emit(item)

	return success

## Checks if item is equipped
## @param item: Item to check (must be PPEquipmentEntity)
## @return bool: True if equipped
func is_item_equipped(item: PPItemEntity) -> bool:
	if not _player_data or not _player_data.inventory:
		return false

	# Item must be PPEquipmentEntity
	if not item is PPEquipmentEntity:
		return false

	# Check if item is in any equipment slot
	var equipment_item = item as PPEquipmentEntity
	var slot_name = equipment_item.get_equipment_slot()

	if not _player_data.inventory.has_equipment_in_slot(slot_name):
		return false

	var equipped_slot = _player_data.inventory.get_equipped_item(slot_name)
	if not equipped_slot:
		return false

	return equipped_slot.item.get_entity_id() == item.get_entity_id()

# ============================================================================
# PUBLIC API - Stats & Combat
# ============================================================================

## Gets runtime stats
## @return PPRuntimeStats: Runtime stats or null
func get_runtime_stats() -> PPRuntimeStats:
	if not _player_data:
		return null
	return _player_data.runtime_stats

## Gets base stats
## @return PPStats: Base stats or null
func get_base_stats() -> PPStats:
	if not _player_data:
		return null
	return _player_data.base_stats

## Gets effective stat value (with modifiers)
## @param stat_name: Stat name
## @return float: Effective stat value
func get_effective_stat(stat_name: String) -> float:
	if not _player_data or not _player_data.runtime_stats:
		return 0.0

	return _player_data.runtime_stats.get_effective_stat(stat_name)

## Gets current health
## @return float: Current health
func get_current_health() -> float:
	return get_effective_stat("health")

## Gets max health
## @return float: Maximum health
func get_max_health() -> float:
	if not _player_data or not _player_data.runtime_stats:
		return 0.0

	return _player_data.runtime_stats._get_base_stat_value("health")

## Applies damage to player
## @param amount: Damage amount
func take_damage(amount: float) -> void:
	if not _player_data or not _player_data.runtime_stats:
		return

	var old_health = get_current_health()

	# Create damage modifier
	var damage_mod = PPStatModifier.new()
	damage_mod.stat_name = "health"
	damage_mod.type = PPStatModifier.ModifierType.FLAT
	damage_mod.value = -amount
	damage_mod.source = "damage"

	_player_data.runtime_stats.add_modifier(damage_mod)

	var new_health = get_current_health()
	health_changed.emit(old_health, new_health)

	# Check for death
	if new_health <= 0:
		die()

## Heals the player
## @param amount: Heal amount
func heal(amount: float) -> void:
	if not _player_data or not _player_data.runtime_stats:
		return

	var old_health = get_current_health()
	var max_health = get_max_health()

	# Create heal modifier
	var heal_mod = PPStatModifier.new()
	heal_mod.stat_name = "health"
	heal_mod.type = PPStatModifier.ModifierType.FLAT
	heal_mod.value = amount
	heal_mod.source = "heal"

	_player_data.runtime_stats.add_modifier(heal_mod)

	# Cap at max health
	var new_health = min(get_current_health(), max_health)
	if new_health != get_current_health():
		var adjustment = new_health - get_current_health()
		var adjust_mod = PPStatModifier.new()
		adjust_mod.stat_name = "health"
		adjust_mod.type = PPStatModifier.ModifierType.FLAT
		adjust_mod.value = adjustment
		adjust_mod.source = "heal_cap"
		_player_data.runtime_stats.add_modifier(adjust_mod)

	health_changed.emit(old_health, new_health)

## Checks if player is alive
## @return bool: True if alive (health > 0)
func is_alive() -> bool:
	return get_current_health() > 0

## Kills the player
func die() -> void:
	if not is_alive():
		return

	died.emit()
	print("PlayerManager: Player died")

## Respawns the player at checkpoint
## @param health_percentage: Health percentage to respawn with (0.0 to 1.0), use -1.0 to use configured setting
func respawn(health_percentage: float = -1.0) -> void:
	if not _player_data or not _player_data.runtime_stats:
		return

	# Use configured setting if not specified
	if health_percentage < 0.0:
		health_percentage = respawn_health_percentage

	# Clear all modifiers
	_player_data.runtime_stats.clear_all_modifiers()

	# Set health to percentage of max
	var max_health = get_max_health()
	var target_health = max_health * clamp(health_percentage, 0.0, 1.0)

	var current = get_current_health()
	if target_health != current:
		var health_mod = PPStatModifier.new()
		health_mod.stat_name = "health"
		health_mod.type = PPStatModifier.ModifierType.FLAT
		health_mod.value = target_health - current
		health_mod.source = "respawn"
		_player_data.runtime_stats.add_modifier(health_mod)

	# Teleport to checkpoint
	if _player_data.checkpoint_position != Vector3.ZERO or _player_data.checkpoint_scene != "":
		_player_data.world_position = _player_data.checkpoint_position
		_player_data.current_scene = _player_data.checkpoint_scene

	respawned.emit()
	print("PlayerManager: Player respawned at checkpoint")

# ============================================================================
# PUBLIC API - Position & Scene
# ============================================================================

## Gets player position
## @return Vector3: Current position
func get_position() -> Vector3:
	if not _player_data:
		return Vector3.ZERO
	return _player_data.world_position

## Sets player position
## @param pos: New position
func set_position(pos: Vector3) -> void:
	if not _player_data:
		return

	var old_position = _player_data.world_position
	_player_data.world_position = pos
	position_changed.emit(old_position, pos)

## Gets current scene path
## @return String: Current scene path
func get_current_scene() -> String:
	if not _player_data:
		return ""
	return _player_data.current_scene

## Sets current scene path
## @param scene_path: New scene path
func set_current_scene(scene_path: String) -> void:
	if not _player_data:
		return

	var old_scene = _player_data.current_scene
	_player_data.current_scene = scene_path
	scene_changed.emit(old_scene, scene_path)

## Sets checkpoint (for respawn)
## @param position: Checkpoint position
## @param scene_path: Checkpoint scene
func set_checkpoint(position: Vector3, scene_path: String) -> void:
	if not _player_data:
		return

	_player_data.checkpoint_position = position
	_player_data.checkpoint_scene = scene_path
	checkpoint_set.emit(position, scene_path)

## Gets checkpoint position
## @return Vector3: Checkpoint position
func get_checkpoint_position() -> Vector3:
	if not _player_data:
		return Vector3.ZERO
	return _player_data.checkpoint_position

## Gets checkpoint scene
## @return String: Checkpoint scene path
func get_checkpoint_scene() -> String:
	if not _player_data:
		return ""
	return _player_data.checkpoint_scene

# ============================================================================
# PUBLIC API - Progress (Recipes, Locations, Achievements)
# ============================================================================

## Unlocks a recipe
## @param recipe_id: Recipe entity ID
func unlock_recipe(recipe_id: String) -> void:
	if not _player_data:
		return

	if _player_data.has_recipe(recipe_id):
		return

	_player_data.unlock_recipe(recipe_id)
	recipe_unlocked.emit(recipe_id)

## Checks if recipe is unlocked
## @param recipe_id: Recipe entity ID
## @return bool: True if unlocked
func has_recipe(recipe_id: String) -> bool:
	if not _player_data:
		return false
	return _player_data.has_recipe(recipe_id)

## Gets all unlocked recipes
## @return Array[String]: Recipe IDs
func get_unlocked_recipes() -> Array[String]:
	if not _player_data:
		return []
	return _player_data.unlocked_recipes.duplicate()

## Discovers a location
## @param location_id: Location entity ID
func discover_location(location_id: String) -> void:
	if not _player_data:
		return

	if _player_data.is_location_discovered(location_id):
		return

	_player_data.discover_location(location_id)
	location_discovered.emit(location_id)

## Checks if location is discovered
## @param location_id: Location entity ID
## @return bool: True if discovered
func is_location_discovered(location_id: String) -> bool:
	if not _player_data:
		return false
	return _player_data.is_location_discovered(location_id)

## Gets all discovered locations
## @return Array[String]: Location IDs
func get_discovered_locations() -> Array[String]:
	if not _player_data:
		return []
	return _player_data.discovered_locations.duplicate()

## Unlocks an achievement
## @param achievement_id: Achievement identifier
func unlock_achievement(achievement_id: String) -> void:
	if not _player_data:
		return

	if _player_data.has_achievement(achievement_id):
		return

	_player_data.unlock_achievement(achievement_id)
	achievement_unlocked.emit(achievement_id)

## Checks if achievement is unlocked
## @param achievement_id: Achievement identifier
## @return bool: True if unlocked
func has_achievement(achievement_id: String) -> bool:
	if not _player_data:
		return false
	return _player_data.has_achievement(achievement_id)

## Gets all achievements
## @return Array[String]: Achievement IDs
func get_achievements() -> Array[String]:
	if not _player_data:
		return []
	return _player_data.achievements.duplicate()

# ============================================================================
# PUBLIC API - State Management
# ============================================================================

## Saves player state to GameState (called by SaveManager)
## @param game_state: PPGameState instance to update
func save_state(game_state: PPGameState) -> void:
	if not _player_data:
		push_warning("PlayerManager: Cannot save state - player not initialized")
		return

	game_state.player_data = _player_data

## Loads player state from GameState (called by SaveManager)
## @param game_state: PPGameState instance
func load_state(game_state: PPGameState) -> void:
	if not game_state.player_data:
		push_warning("PlayerManager: Cannot load state - no player data in save")
		return

	_player_data = game_state.player_data
	_is_initialized = true

	print("PlayerManager: Loaded player '%s'" % _player_data.player_name)

# ============================================================================
# UTILITY
# ============================================================================

## Gets a debug summary of player state
## @return String: Summary text
func get_summary() -> String:
	if not _player_data:
		return "PlayerManager: No player initialized"

	return _player_data.get_summary()
