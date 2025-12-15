class_name PPQuest extends RefCounted

## Quest Property (Static)
## Represents immutable quest data, similar to PPStats or PPQuestObjective
## Used to define quests that are then tracked at runtime via PPRuntimeQuest

## Quest Types
enum QuestType {
	MAIN_STORY,    ## Main storyline quest
	SIDE_QUEST,    ## Optional side quest
	DAILY,         ## Daily repeatable quest
	WEEKLY,        ## Weekly repeatable quest
	REPEATABLE     ## Infinitely repeatable quest
}

var _quest_id: String
var _quest_name: String
var _description: String
var _quest_type: int
var _objectives: Array  ## Array of objective data (can be PPQuestObjective or Dictionary)
var _rewards: Array  ## Array of reward references (PandoraReference or Dictionary)
var _prerequisites: Array  ## Array of quest prerequisites (PandoraReference or Dictionary)
var _auto_complete: bool
var _quest_giver: PandoraReference
var _hidden: bool
var _category: String

## Constructor
func _init(
	quest_id: String = "",
	quest_name: String = "",
	description: String = "",
	quest_type: int = QuestType.SIDE_QUEST,
	objectives: Array = [],
	rewards: Array = [],
	prerequisites: Array = [],
	auto_complete: bool = true,
	quest_giver: PandoraReference = null,
	hidden: bool = false,
	category: String = ""
) -> void:
	_quest_id = quest_id
	_quest_name = quest_name
	_description = description
	_quest_type = quest_type
	_objectives = objectives
	_rewards = rewards
	_prerequisites = prerequisites
	_auto_complete = auto_complete
	_quest_giver = quest_giver
	_hidden = hidden
	_category = category

## Getters

func get_quest_id() -> String:
	return _quest_id

func get_quest_name() -> String:
	return _quest_name

func get_description() -> String:
	return _description

func get_quest_type() -> int:
	return _quest_type

func get_objectives() -> Array:
	return _objectives

func get_rewards() -> Array:
	return _rewards

func get_prerequisites() -> Array:
	return _prerequisites

func is_auto_complete() -> bool:
	return _auto_complete

func get_quest_giver() -> PandoraReference:
	return _quest_giver

func get_quest_giver_entity() -> PandoraEntity:
	return _quest_giver.get_entity() if _quest_giver else null

func is_hidden() -> bool:
	return _hidden

func get_category() -> String:
	return _category

## Setters

func set_quest_id(quest_id: String) -> void:
	_quest_id = quest_id

func set_quest_name(quest_name: String) -> void:
	_quest_name = quest_name

func set_description(description: String) -> void:
	_description = description

func set_quest_type(quest_type: int) -> void:
	_quest_type = quest_type

func set_objectives(objectives: Array) -> void:
	_objectives = objectives

func set_rewards(rewards: Array) -> void:
	_rewards = rewards

func set_prerequisites(prerequisites: Array) -> void:
	_prerequisites = prerequisites

func set_auto_complete(auto_complete: bool) -> void:
	_auto_complete = auto_complete

func set_quest_giver(giver: PandoraReference) -> void:
	_quest_giver = giver

func set_hidden(hidden: bool) -> void:
	_hidden = hidden

func set_category(category: String) -> void:
	_category = category

## Helper methods for array management

# Objectives management
func add_objective(objective: PPQuestObjective) -> void:
	if objective:
		_objectives.append(objective)

func remove_objective(objective: PPQuestObjective) -> void:
	_objectives.erase(objective)

func update_objective_at(idx: int, objective: PPQuestObjective) -> void:
	if _objectives.size() < idx + 1:
		_objectives.append(objective)
	else:
		_objectives[idx] = objective

# Rewards management
func add_reward(reward: PPQuestReward) -> void:
	if reward:
		_rewards.append(reward)

func remove_reward(reward: PPQuestReward) -> void:
	_rewards.erase(reward)

func update_reward_at(idx: int, reward: PPQuestReward) -> void:
	if _rewards.size() < idx + 1:
		_rewards.append(reward)
	else:
		_rewards[idx] = reward

# Prerequisites management
func add_prerequisite(prerequisite: PandoraReference) -> void:
	if prerequisite:
		_prerequisites.append(prerequisite)

func remove_prerequisite(prerequisite: PandoraReference) -> void:
	_prerequisites.erase(prerequisite)

func update_prerequisite_at(idx: int, prerequisite: PandoraReference) -> void:
	if _prerequisites.size() < idx + 1:
		_prerequisites.append(prerequisite)
	else:
		_prerequisites[idx] = prerequisite

## Serialization (follows PPQuestObjective pattern)

func load_data(data: Dictionary) -> void:
	_quest_id = data.get("quest_id", "")
	_quest_name = data.get("quest_name", "")
	_description = data.get("description", "")
	_quest_type = data.get("quest_type", QuestType.SIDE_QUEST)
	_auto_complete = data.get("auto_complete", true)
	_hidden = data.get("hidden", false)
	_category = data.get("category", "")

	# Deserialize objectives array
	if data.has("objectives"):
		_objectives = []
		for obj_data in data["objectives"]:
			# Create with required parameters, then load data
			var objective := PPQuestObjective.new(
				"",    # objective_id - will be loaded
				-1,    # objective_type - will be loaded
				"",    # description - will be loaded
				null,  # target_reference - will be loaded
				1      # target_quantity - will be loaded
			)
			objective.load_data(obj_data)
			_objectives.append(objective)
	else:
		_objectives = []

	# Deserialize rewards array
	if data.has("rewards"):
		_rewards = []
		for reward_data in data["rewards"]:
			var reward := PPQuestReward.new()
			reward.load_data(reward_data)
			_rewards.append(reward)
	else:
		_rewards = []

	# Deserialize prerequisites array (these are PandoraReferences)
	if data.has("prerequisites"):
		_prerequisites = []
		for prereq_data in data["prerequisites"]:
			if prereq_data is Dictionary and prereq_data.has("_entity_id") and prereq_data.has("_type"):
				var prereq := PandoraReference.new(prereq_data["_entity_id"], prereq_data["_type"])
				_prerequisites.append(prereq)
	else:
		_prerequisites = []

	# Deserialize quest giver
	if data.has("quest_giver"):
		var giver_data = data["quest_giver"]
		if giver_data is Dictionary and giver_data.has("_entity_id") and giver_data.has("_type"):
			_quest_giver = PandoraReference.new(giver_data["_entity_id"], giver_data["_type"])
		else:
			_quest_giver = null

func save_data(fields_settings: Array[Dictionary], objective_fields_settings: Array[Dictionary] = [], reward_fields_settings: Array[Dictionary] = []) -> Dictionary:
	var result := {}

	# Helper function to find field setting
	var find_field = func(name: String) -> Dictionary:
		var filtered = fields_settings.filter(func(d): return d["name"] == name)
		return filtered[0] if filtered.size() > 0 else {"enabled": false}

	var quest_id_field = find_field.call("Quest ID")
	var quest_name_field = find_field.call("Quest Name")
	var description_field = find_field.call("Description")
	var quest_type_field = find_field.call("Quest Type")
	var objectives_field = find_field.call("Objectives")
	var rewards_field = find_field.call("Rewards")
	var prerequisites_field = find_field.call("Prerequisites")
	var quest_giver_field = find_field.call("Quest Giver")
	var category_field = find_field.call("Category")

	if quest_id_field["enabled"]:
		result["quest_id"] = _quest_id
	if quest_name_field["enabled"]:
		result["quest_name"] = _quest_name
	if description_field["enabled"]:
		result["description"] = _description
	if quest_type_field["enabled"]:
		result["quest_type"] = _quest_type

	# Serialize objectives array
	if objectives_field["enabled"]:
		var objectives_data = []
		for objective in _objectives:
			if objective is PPQuestObjective:
				objectives_data.append(objective.save_data(objective_fields_settings))
			elif objective is Dictionary:
				objectives_data.append(objective)
		result["objectives"] = objectives_data

	# Serialize rewards array
	if rewards_field["enabled"]:
		var rewards_data = []
		for reward in _rewards:
			if reward is PPQuestReward:
				rewards_data.append(reward.save_data(reward_fields_settings))
			elif reward is Dictionary:
				rewards_data.append(reward)
		result["rewards"] = rewards_data

	# Serialize prerequisites array (PandoraReferences)
	if prerequisites_field["enabled"]:
		var prerequisites_data = []
		for prereq in _prerequisites:
			if prereq is PandoraReference:
				prerequisites_data.append(prereq.save_data())
			elif prereq is Dictionary:
				prerequisites_data.append(prereq)
		result["prerequisites"] = prerequisites_data

	if quest_giver_field["enabled"] and _quest_giver:
		result["quest_giver"] = _quest_giver.save_data()
	if category_field["enabled"]:
		result["category"] = _category

	return result

func _to_string() -> String:
	return "<PPQuest '%s'>" % _quest_name
