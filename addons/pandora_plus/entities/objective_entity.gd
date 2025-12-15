@tool
class_name PPObjectiveEntity extends PandoraEntity

## Objective Entity for Quest System
## Represents a single objective within a quest

## Objective Types
enum ObjectiveType {
	COLLECT,        ## Collect X items
	KILL,           ## Kill X enemies
	TALK,           ## Talk to NPC
	REACH_LOCATION, ## Reach a specific location
	USE_ITEM,       ## Use a specific item
	CRAFT_ITEM,     ## Craft X items
	DELIVER,        ## Deliver item to NPC
	ESCORT,         ## Escort NPC to location
	CUSTOM          ## Custom objective with script
}

func get_objective_id() -> String:
	return get_string("objective_id")

func get_objective_type() -> int:
	return get_integer("objective_type")

func get_description() -> String:
	return get_string("description")

func get_target_entity() -> PandoraEntity:
	var ref = get_reference("target_entity")
	return ref if ref else null

func get_target_quantity() -> int:
	return get_integer("target_quantity")

func is_optional() -> bool:
	return get_bool("optional")

func is_hidden() -> bool:
	return get_bool("hidden")

func get_custom_script() -> String:
	return get_string("custom_script")

func get_order_index() -> int:
	return get_integer("order_index")

func is_sequential() -> bool:
	return get_bool("sequential")
