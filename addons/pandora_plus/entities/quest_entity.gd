@tool
class_name PPQuestEntity extends PandoraEntity

## Quest Entity for Pandora+ Quest System
## Represents a quest that can be tracked and completed by the player
## Uses the PPQuest custom property type which handles objectives and rewards internally

## Get the quest data (PPQuest instance)
func get_quest_data() -> PPQuest:
	var quest_property = get_entity_property("quest_data")
	if quest_property:
		return quest_property.get_default_value() as PPQuest
	return null

## Convenience methods for accessing quest data
func get_quest_id() -> String:
	var quest = get_quest_data()
	return quest.get_quest_id() if quest else ""

func get_quest_name() -> String:
	var quest = get_quest_data()
	return quest.get_quest_name() if quest else ""

func get_description() -> String:
	var quest = get_quest_data()
	return quest.get_description() if quest else ""

func get_quest_type() -> PPQuest.QuestType:
	var quest = get_quest_data()
	return quest.get_quest_type() if quest else PPQuest.QuestType.SIDE_QUEST

func get_objectives() -> Array[PPQuestObjective]:
	var quest = get_quest_data()
	return quest.get_objectives() if quest else []

func get_rewards() -> Array[PPQuestReward]:
	var quest = get_quest_data()
	return quest.get_rewards() if quest else []

func get_prerequisites() -> Array:
	var quest = get_quest_data()
	return quest.get_prerequisites() if quest else []

func is_auto_complete() -> bool:
	var quest = get_quest_data()
	return quest.is_auto_complete() if quest else false

func get_quest_giver() -> PandoraEntity:
	var quest = get_quest_data()
	return quest.get_quest_giver_entity() if quest else null

func is_hidden() -> bool:
	var quest = get_quest_data()
	return quest.is_hidden() if quest else false

func get_quest_category() -> String:
	var quest = get_quest_data()
	return quest.get_category() if quest else ""
