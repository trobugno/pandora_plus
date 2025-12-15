@tool
class_name PPObjectiveEntity extends PandoraEntity

## Objective Entity for Quest System
## Represents a single objective within a quest

## Objective Types
enum ObjectiveType {
	COLLECT,        ## Collect X items
	KILL,           ## Kill X enemies
	TALK            ## Talk to NPC
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

func is_hidden() -> bool:
	return get_bool("hidden")

func get_custom_script() -> String:
	return get_string("custom_script")
