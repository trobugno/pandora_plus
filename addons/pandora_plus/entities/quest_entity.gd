@tool
class_name PPQuestEntity extends PandoraEntity

## Quest Entity for Pandora+ Quest System
## Represents a quest that can be tracked and completed by the player

## Quest Types
enum QuestType {
	MAIN_STORY,    ## Main storyline quest
	SIDE_QUEST,    ## Optional side quest
	DAILY,         ## Daily repeatable quest
	WEEKLY,        ## Weekly repeatable quest
	REPEATABLE     ## Infinitely repeatable quest
}

func get_quest_id() -> String:
	return get_string("quest_id")

func get_quest_name() -> String:
	return get_string("quest_name")

func get_description() -> String:
	return get_string("description")

func get_quest_type() -> int:
	return get_integer("quest_type")

func get_objectives() -> Array:
	return get_array("objectives")

func get_rewards() -> Array:
	return get_array("rewards")

func get_prerequisites() -> Array:
	return get_array("prerequisites")

func get_level_requirement() -> int:
	return get_integer("level_requirement")

func is_auto_complete() -> bool:
	return get_bool("auto_complete")

func get_time_limit() -> float:
	return get_float("time_limit")

func get_icon() -> Texture:
	return get_resource("icon")

func get_quest_giver() -> PandoraEntity:
	var ref = get_reference("quest_giver")
	return ref if ref else null

func is_hidden() -> bool:
	return get_bool("hidden")

func get_quest_category() -> String:
	return get_string("category")
