@tool
class_name PPEquipmentEntity extends PPItemEntity

## Equipment Entity class
## Extends PPItemEntity with equipment-specific functionality
## Inherits: name, description, texture, stackable, value, weight, rarity
## Adds: equipment_slot property and stats_property access

## Equipment slot types
enum EquipmentSlot {
	HEAD,
	CHEST,
	LEGS,
	WEAPON,
	SHIELD,
	ACCESSORY_1,
	ACCESSORY_2
}

## Gets the equipment slot type as string (e.g., "HEAD", "WEAPON")
func get_equipment_slot() -> String:
	return get_string("equipment_slot")

## Gets the equipment slot type as enum value
func get_equipment_slot_enum() -> EquipmentSlot:
	var slot_name = get_equipment_slot()
	return EquipmentSlot.get(slot_name)

## Gets the stat bonuses from this equipment (PPStats)
## Returns null if equipment has no stats_property
func get_equipment_stats() -> PPStats:
	if not has_entity_property("stats_property"):
		return null
	return get_entity_property("stats_property").get_default_value() as PPStats

## Checks if equipment has stat bonuses
func has_stat_bonuses() -> bool:
	return has_entity_property("stats_property")
