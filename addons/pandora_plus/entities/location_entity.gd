@tool
class_name PPLocationEntity extends PandoraEntity

## Location Entity class that extends PandoraEntity
## Provides type-safe accessors for Location properties including:
## - Basic info (name, description, texture)
## - Positioning (world coordinates)
## - Area and type classification
## - Safe zone designation

## Gets the Location's display name
func get_location_name() -> String:
	return get_string("name")

## Gets the Location's description
func get_description() -> String:
	return get_string("description")

## Gets the Location's texture/icon
func get_texture() -> Texture:
	return get_resource("texture")

## Gets the Location's world position (Vector2)
func get_position() -> Vector2:
	return get_vector2("position")

## Gets the area name this location belongs to (e.g., "Forest", "Town", "Mountains")
func get_area_name() -> String:
	return get_string("area_name")

## Gets the location type (e.g., "Town", "Dungeon", "Wilderness", "Shop", "Inn")
func get_location_type() -> String:
	return get_string("location_type")

## Returns true if this is a safe zone (no combat allowed)
func is_safe_zone() -> bool:
	return get_bool("is_safe_zone")
