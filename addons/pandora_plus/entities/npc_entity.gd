@tool
class_name PPNPCEntity extends PandoraEntity

## NPC Entity class that extends PandoraEntity
## Provides type-safe accessors for NPC properties including:
## - Basic info (name, description, texture)
## - Combat stats (via stats_property)
## - Faction and hostility
## - Quest giver functionality

## Gets the NPC's display name
func get_npc_name() -> String:
	return get_string("name")

## Gets the NPC's description
func get_description() -> String:
	return get_string("description")

## Gets the NPC's texture/portrait
func get_texture() -> Texture:
	return get_resource("texture")

## Gets the NPC's base combat stats (PPStats)
func get_base_stats() -> PPStats:
	return get_entity_property("base_stats").get_default_value() as PPStats

## Gets the NPC's faction name
func get_faction() -> String:
	return get_string("faction")

## Returns true if NPC is hostile by default
func is_hostile() -> bool:
	return get_bool("is_hostile")

## Gets the spawn location reference
func get_spawn_location() -> PandoraReference:
	var location_ref = get_reference("spawn_location")
	if location_ref:
		return PandoraReference.new(location_ref.get_entity_id(), PandoraReference.Type.ENTITY)
	return null

## Gets array of quest references this NPC can give
func get_quest_giver_for() -> Array:
	var refs = get_array("quest_giver_for")
	return refs if refs else []
