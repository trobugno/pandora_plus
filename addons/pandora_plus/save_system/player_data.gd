extends Resource
class_name PPPlayerData

## Player Data Container
## Contains all player-specific runtime data
##
## Includes:
## - Basic info (name)
## - Inventory and equipment
## - Stats and modifiers
## - Position and scene
## - Active status effects
##
## This class represents the player's complete state at any point in the game.

# ============================================================================
# BASIC INFO
# ============================================================================

## Player's name
@export var player_name: String = "Hero"

# ============================================================================
# INVENTORY & EQUIPMENT
# ============================================================================

## Player's inventory (PPInventory instance)
var inventory: PPInventory = null

## Reference to equipped stats for quick access
## This is derived from inventory.equipped_items but stored separately
## for runtime calculations
var equipped_stats: PPRuntimeStats = null

# ============================================================================
# STATS & COMBAT
# ============================================================================

## Player's base stats (without equipment modifiers)
var base_stats: PPStats = null

## Player's runtime stats (with all modifiers applied)
var runtime_stats: PPRuntimeStats = null

## Active status effects on the player
var active_status_effects: Array = []  # Array of PPStatusEffect instances

# ============================================================================
# POSITION & SCENE
# ============================================================================

## Player's world position
@export var world_position: Vector3 = Vector3.ZERO

## Current scene path
@export var current_scene: String = ""

## Last checkpoint position (for respawn)
@export var checkpoint_position: Vector3 = Vector3.ZERO

## Last checkpoint scene
@export var checkpoint_scene: String = ""

# ============================================================================
# GAME PROGRESS
# ============================================================================

## Unlocked recipes (array of recipe entity IDs)
@export var unlocked_recipes: Array[String] = []

## Discovered locations (array of location entity IDs)
@export var discovered_locations: Array[String] = []

## Achievements/milestones (array of achievement IDs)
@export var achievements: Array[String] = []

# ============================================================================
# CUSTOM DATA
# ============================================================================

## Custom player-specific data for mods or game-specific features
@export var custom_data: Dictionary = {}

# ============================================================================
# INITIALIZATION
# ============================================================================

func _init() -> void:
	# Create default inventory
	inventory = PPInventory.new()

	# Initialize empty stats (will be set by game)
	base_stats = null
	runtime_stats = null
	equipped_stats = null

	# Initialize empty arrays
	active_status_effects = []
	unlocked_recipes = []
	discovered_locations = []
	achievements = []
	custom_data = {}

# ============================================================================
# SERIALIZATION
# ============================================================================

## Serializes player data to a dictionary
## @return Dictionary: Complete player data
func to_dict() -> Dictionary:
	var data = {
		"player_name": player_name,
		"inventory": inventory.to_dict() if inventory else {},
		"stats": {
			"base_stats": base_stats.save_data([]) if base_stats else {},
			"runtime_stats": runtime_stats.to_dict() if runtime_stats else {}
		},
		"status_effects": active_status_effects.map(func(e): return e.to_dict() if e and e.has_method("to_dict") else {}),
		"position": {
			"world_position": {"x": world_position.x, "y": world_position.y, "z": world_position.z},
			"current_scene": current_scene,
			"checkpoint_position": {"x": checkpoint_position.x, "y": checkpoint_position.y, "z": checkpoint_position.z},
			"checkpoint_scene": checkpoint_scene
		},
		"progress": {
			"unlocked_recipes": unlocked_recipes,
			"discovered_locations": discovered_locations,
			"achievements": achievements
		},
		"custom_data": custom_data
	}

	return data

## Creates a PlayerData instance from a dictionary
## @param data: Dictionary with player data
## @return PPPlayerData: Restored player data
static func from_dict(data: Dictionary) -> PPPlayerData:
	var player = PPPlayerData.new()

	# Restore basic info
	player.player_name = data.get("player_name", "Hero")

	# Restore inventory
	if data.has("inventory"):
		player.inventory = PPInventory.from_dict(data["inventory"])

	# Restore stats
	if data.has("stats"):
		var stats = data["stats"]

		# Base stats - TODO: Implement PPStats.from_dict or load_data
		# For now, we'll handle this when PPStats deserialization is available

		# Runtime stats
		if stats.has("runtime_stats"):
			player.runtime_stats = PPRuntimeStats.from_dict(stats["runtime_stats"])

	# Restore status effects - TODO: Implement when status effect system is finalized
	if data.has("status_effects"):
		player.active_status_effects = []
		# Will implement deserialization when status effect format is confirmed

	# Restore position
	if data.has("position"):
		var pos = data["position"]

		if pos.has("world_position"):
			var wp = pos["world_position"]
			player.world_position = Vector3(wp.get("x", 0), wp.get("y", 0), wp.get("z", 0))

		player.current_scene = pos.get("current_scene", "")

		if pos.has("checkpoint_position"):
			var cp = pos["checkpoint_position"]
			player.checkpoint_position = Vector3(cp.get("x", 0), cp.get("y", 0), cp.get("z", 0))

		player.checkpoint_scene = pos.get("checkpoint_scene", "")

	# Restore progress
	if data.has("progress"):
		var prog = data["progress"]
		player.unlocked_recipes.assign(prog.get("unlocked_recipes", []))
		player.discovered_locations.assign(prog.get("discovered_locations", []))
		player.achievements.assign(prog.get("achievements", []))

	# Restore custom data
	if data.has("custom_data"):
		player.custom_data = data["custom_data"]

	return player

# ============================================================================
# HELPER METHODS - Progress
# ============================================================================

## Unlocks a recipe
## @param recipe_id: Recipe entity ID
func unlock_recipe(recipe_id: String) -> void:
	if recipe_id not in unlocked_recipes:
		unlocked_recipes.append(recipe_id)

## Checks if a recipe is unlocked
## @param recipe_id: Recipe entity ID
## @return bool: True if unlocked
func has_recipe(recipe_id: String) -> bool:
	return recipe_id in unlocked_recipes

## Discovers a location
## @param location_id: Location entity ID
func discover_location(location_id: String) -> void:
	if location_id not in discovered_locations:
		discovered_locations.append(location_id)

## Checks if a location is discovered
## @param location_id: Location entity ID
## @return bool: True if discovered
func is_location_discovered(location_id: String) -> bool:
	return location_id in discovered_locations

## Unlocks an achievement
## @param achievement_id: Achievement identifier
func unlock_achievement(achievement_id: String) -> void:
	if achievement_id not in achievements:
		achievements.append(achievement_id)

## Checks if an achievement is unlocked
## @param achievement_id: Achievement identifier
## @return bool: True if unlocked
func has_achievement(achievement_id: String) -> bool:
	return achievement_id in achievements

# ============================================================================
# UTILITY METHODS
# ============================================================================

## Gets a human-readable summary of player data
## @return String: Summary text
func get_summary() -> String:
	var summary = "Player Data Summary:\n"
	summary += "  Name: %s\n" % player_name
	summary += "  Scene: %s\n" % current_scene
	summary += "  Unlocked Recipes: %d\n" % unlocked_recipes.size()
	summary += "  Discovered Locations: %d\n" % discovered_locations.size()
	summary += "  Achievements: %d\n" % achievements.size()
	return summary
