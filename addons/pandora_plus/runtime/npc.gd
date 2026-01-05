class_name PPRuntimeNPC extends Resource

## Runtime NPC instance that tracks dynamic state during gameplay
## Manages combat and quest integration
##
## Features:
## - Combat system with health tracking and stat modifiers
## - Full serialization for save/load

# ============================================================================
# SIGNALS
# ============================================================================

## Combat signals
signal health_changed(old_value: float, new_value: float)
signal mana_changed(old_value: float, new_value: float)
signal died()
signal revived()

## Location signal
signal location_changed(old_location: Variant, new_location: Variant)

# ============================================================================
# CORE DATA
# ============================================================================

## Serialized NPC entity data
@export var npc_data: Dictionary = {}

## Reference to the static NPC entity
var _npc_entity: PPNPCEntity

## Runtime stats (health, mana, attack, defense, etc.)
var _runtime_stats: PPRuntimeStats

# ============================================================================
# STATE TRACKING
# ============================================================================

## Current location reference
var _current_location: Variant = null

## Whether NPC is alive
var _is_alive: bool = true

# ============================================================================
# INITIALIZATION
# ============================================================================

func _init(p_npc_data: Variant = null) -> void:
	if p_npc_data is PPNPCEntity:
		# Initialize from entity
		npc_data = _serialize_entity_data(p_npc_data)
		_npc_entity = p_npc_data

		# Initialize runtime stats
		var base_stats = p_npc_data.get_base_stats()
		if base_stats:
			_runtime_stats = PPRuntimeStats.new(base_stats)
		else:
			_runtime_stats = PPRuntimeStats.new()

		# Initialize location
		_current_location = p_npc_data.get_spawn_location()

	elif p_npc_data is Dictionary:
		# Initialize from dictionary (deserialization)
		npc_data = p_npc_data

		# Restore NPC entity reference from entity_id
		var entity_id = p_npc_data.get("entity_id")
		if entity_id:
			var entity_ref = PandoraReference.new(entity_id, PandoraReference.Type.ENTITY)
			_npc_entity = entity_ref.get_entity() as PPNPCEntity
			if not _npc_entity:
				push_error("PPRuntimeNPC: Failed to restore NPC entity with ID '%s'. Entity may have been deleted." % entity_id)

		# Initialize empty runtime stats (will be restored by from_dict if called)
		_runtime_stats = PPRuntimeStats.new()

func _serialize_entity_data(entity: PPNPCEntity) -> Dictionary:
	return {
		"entity_id": entity.get_entity_id(),
		"name": entity.get_npc_name(),
		"faction": entity.get_faction(),
		"is_hostile": entity.is_hostile()
	}

# ============================================================================
# COMBAT SYSTEM
# ============================================================================

## Applies damage to NPC
func take_damage(amount: float, source: String = "unknown") -> void:
	if not _is_alive:
		return

	var old_health = get_current_health()

	# Create damage modifier (negative flat modifier)
	var damage_modifier = PPStatModifier.new()
	damage_modifier.stat_name = "health"
	damage_modifier.type = PPStatModifier.ModifierType.FLAT
	damage_modifier.value = -amount
	damage_modifier.source = source

	_runtime_stats.add_modifier(damage_modifier)

	var new_health = get_current_health()
	health_changed.emit(old_health, new_health)

	# Check if NPC died
	if new_health <= 0:
		die()

## Heals the NPC
func heal(amount: float) -> void:
	if not _is_alive:
		return

	var old_health = get_current_health()
	var max_health = get_max_health()

	# Create heal modifier (positive flat modifier)
	var heal_modifier = PPStatModifier.new()
	heal_modifier.stat_name = "health"
	heal_modifier.type = PPStatModifier.ModifierType.FLAT
	heal_modifier.value = amount
	heal_modifier.source = "heal"

	_runtime_stats.add_modifier(heal_modifier)

	# Cap at max health
	var new_health = min(get_current_health(), max_health)
	if new_health != get_current_health():
		# Adjust if over max
		var adjustment = new_health - get_current_health()
		var adjust_mod = PPStatModifier.new()
		adjust_mod.stat_name = "health"
		adjust_mod.type = PPStatModifier.ModifierType.FLAT
		adjust_mod.value = adjustment
		adjust_mod.source = "heal_cap"
		_runtime_stats.add_modifier(adjust_mod)

	health_changed.emit(old_health, new_health)

## Kills the NPC
func die() -> void:
	if not _is_alive:
		return

	_is_alive = false
	died.emit()

## Revives the NPC with specified health percentage
func revive(health_percentage: float = 1.0) -> void:
	if _is_alive:
		return

	_is_alive = true

	# Clear all modifiers and reset to base stats
	_runtime_stats.clear_all_modifiers()

	# Set health to percentage of max
	var max_health = get_max_health()
	var target_health = max_health * clamp(health_percentage, 0.0, 1.0)

	# Since we cleared modifiers, current health is base health
	# Add modifier to reach target
	var current = get_current_health()
	if target_health != current:
		var health_mod = PPStatModifier.new()
		health_mod.stat_name = "health"
		health_mod.type = PPStatModifier.ModifierType.FLAT
		health_mod.value = target_health - current
		health_mod.source = "revive"
		_runtime_stats.add_modifier(health_mod)

	revived.emit()

## Returns true if NPC is alive
func is_alive() -> bool:
	return _is_alive

# ============================================================================
# STATS ACCESSORS
# ============================================================================

## Gets current health
func get_current_health() -> float:
	return _runtime_stats.get_effective_stat("health")

## Gets current mana
func get_current_mana() -> float:
	return _runtime_stats.get_effective_stat("mana")

## Gets max health (base health from stats)
func get_max_health() -> float:
	return _runtime_stats._get_base_stat_value("health")

## Gets max mana
func get_max_mana() -> float:
	return _runtime_stats._get_base_stat_value("mana")

## Gets effective stat value (with all modifiers applied)
func get_effective_stat(stat_name: String) -> float:
	return _runtime_stats.get_effective_stat(stat_name)

## Adds a stat modifier
func add_stat_modifier(modifier: PPStatModifier) -> void:
	_runtime_stats.add_modifier(modifier)

## Removes a stat modifier
func remove_stat_modifier(modifier: PPStatModifier) -> void:
	_runtime_stats.remove_modifier(modifier)

## Gets runtime stats reference
func get_runtime_stats() -> PPRuntimeStats:
	return _runtime_stats

# ============================================================================
# LOCATION SYSTEM
# ============================================================================

## Sets current location
func set_location(location_reference: Variant) -> void:
	var old_location = _current_location
	_current_location = location_reference
	location_changed.emit(old_location, _current_location)

## Gets current location
func get_current_location() -> Variant:
	return _current_location

# ============================================================================
# QUEST INTEGRATION
# ============================================================================

## Gets quests this NPC can give, filtered by completion
func get_available_quests(completed_quest_ids: Array) -> Array:
	if not _npc_entity:
		return []

	var quest_refs = _npc_entity.get_quest_giver_for()
	var available_quests: Array = []

	for quest_ref in quest_refs:
		if quest_ref is PandoraReference:
			var quest_entity = quest_ref.get_entity() as PPQuestEntity
			if quest_entity:
				# Check if already completed
				if quest_entity.get_entity_id() in completed_quest_ids:
					continue

				available_quests.append(quest_entity)

	return available_quests

## Returns true if this NPC is a quest giver
func is_quest_giver() -> bool:
	if not _npc_entity:
		return false
	return not _npc_entity.get_quest_giver_for().is_empty()

# ============================================================================
# SERIALIZATION
# ============================================================================

## Converts runtime NPC to dictionary for saving
func to_dict() -> Dictionary:
	var location_id = null
	if _current_location:
		if _current_location is PandoraReference:
			location_id = _current_location._entity_id
		elif _current_location is String:
			location_id = _current_location

	var result = {
		"npc_data": npc_data,
		"runtime_stats": _runtime_stats.to_dict() if _runtime_stats else {},
		"current_location": location_id,
		"is_alive": _is_alive
	}

	return result

## Creates runtime NPC from dictionary (deserialization)
static func from_dict(data: Dictionary) -> PPRuntimeNPC:
	var runtime = PPRuntimeNPC.new(data.get("npc_data", {}))

	# Restore runtime stats
	var stats_data = data.get("runtime_stats", {})
	if not stats_data.is_empty():
		runtime._runtime_stats = PPRuntimeStats.from_dict(stats_data)

	# Restore state
	runtime._is_alive = data.get("is_alive", true)

	# Restore location
	var loc_id = data.get("current_location")
	if loc_id:
		runtime._current_location = PandoraReference.new(loc_id, PandoraReference.Type.ENTITY)

	return runtime
