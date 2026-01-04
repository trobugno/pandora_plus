class_name PPRuntimeQuest extends Resource

## Runtime Quest
## Tracks progress and state of a quest during gameplay
## Manages quest objectives, completion status, and timing

## Quest Status
enum QuestStatus {
	NOT_STARTED,  ## Quest has not been started yet
	ACTIVE,       ## Quest is currently in progress
	COMPLETED,    ## Quest has been completed successfully
	FAILED,       ## Quest has failed
	ABANDONED     ## Quest was abandoned by the player
}

signal quest_started()
signal quest_completed()
signal quest_failed()
signal quest_abandoned()
signal quest_progress_updated(completed_objectives: int, total_objectives: int, progress_percentage: float)
signal objective_completed(objective_index: int)
signal objective_activated(objective_index: int)

@export var quest_data: Dictionary = {}

var _quest_instance: PPQuest
var _runtime_objectives: Array[PPRuntimeQuestObjective] = []
var _rewards: Array[PPQuestReward] = []
var _quest_status: QuestStatus = QuestStatus.NOT_STARTED
var _start_timestamp: float = 0.0
var _completion_timestamp: float = 0.0
var _delivered_rewards: Array[String] = []  ## IDs of already delivered rewards

## Constructor
func _init(p_quest: Variant = null) -> void:
	if p_quest is PPQuest:
		var extension_configuration := PandoraSettings.find_extension_configuration_property("quest_property")
		var objective_configuration := PandoraSettings.find_extension_configuration_property("quest_objective_property")
		var reward_configuration := PandoraSettings.find_extension_configuration_property("quest_reward_property")
		if extension_configuration:
			var fields_settings : Array[Dictionary]
			var objective_fields_settings : Array[Dictionary]
			var reward_fields_settings : Array[Dictionary]
			fields_settings.assign(extension_configuration.get("fields", []) as Array)
			objective_fields_settings.assign(objective_configuration.get("fields", []) as Array)
			reward_fields_settings.assign(reward_configuration.get("fields", []) as Array)
			quest_data = p_quest.save_data(fields_settings, objective_fields_settings, reward_fields_settings)
		else:
			# Fallback if extension not configured yet
			quest_data = {
				"quest_id": p_quest.get_quest_id(),
				"quest_name": p_quest.get_quest_name(),
				"description": p_quest.get_description(),
				"quest_type": p_quest.get_quest_type(),
				"objectives": p_quest.get_objectives(),
				"rewards": p_quest.get_rewards(),
				"prerequisites": p_quest.get_prerequisites(),
				"auto_complete": p_quest.is_auto_complete(),
				"hidden": p_quest.is_hidden(),
				"category": p_quest.get_category()
			}
		_quest_instance = p_quest
		_initialize_objectives()
		_initialize_rewards()
	elif p_quest is Dictionary:
		quest_data = p_quest

## Getters

func get_quest_id() -> String:
	return quest_data.get("quest_id", "")

func get_quest_name() -> String:
	return quest_data.get("quest_name", "")

func get_description() -> String:
	return quest_data.get("description", "")

func get_quest_type() -> int:
	return quest_data.get("quest_type", 0)

func get_quest_status() -> QuestStatus:
	return _quest_status

func get_runtime_objectives() -> Array[PPRuntimeQuestObjective]:
	return _runtime_objectives

func get_rewards() -> Array[PPQuestReward]:
	return _rewards

func get_start_timestamp() -> float:
	return _start_timestamp

func get_completion_timestamp() -> float:
	return _completion_timestamp

func is_auto_complete() -> bool:
	# Prefer reading from instance if available (more reliable than serialized data)
	if _quest_instance:
		return _quest_instance.is_auto_complete()
	return quest_data.get("auto_complete", true)

func is_hidden() -> bool:
	return quest_data.get("hidden", false)

func get_delivered_rewards() -> Array[String]:
	return _delivered_rewards

## Status Checks

func is_not_started() -> bool:
	return _quest_status == QuestStatus.NOT_STARTED

func is_active() -> bool:
	return _quest_status == QuestStatus.ACTIVE

func is_completed() -> bool:
	return _quest_status == QuestStatus.COMPLETED

func is_failed() -> bool:
	return _quest_status == QuestStatus.FAILED

func is_abandoned() -> bool:
	return _quest_status == QuestStatus.ABANDONED

func is_finished() -> bool:
	return _quest_status in [QuestStatus.COMPLETED, QuestStatus.FAILED, QuestStatus.ABANDONED]

## Progress Tracking

func get_completed_objectives_count() -> int:
	var count = 0
	for objective in _runtime_objectives:
		if objective.is_completed():
			count += 1
	return count

func get_total_objectives_count() -> int:
	return _runtime_objectives.size()

func get_required_objectives_count() -> int:
	return _runtime_objectives.size()

func get_completed_required_objectives_count() -> int:
	var count = 0
	for objective in _runtime_objectives:
		if objective.is_completed():
			count += 1
	return count

func get_progress_percentage() -> float:
	var total = get_required_objectives_count()
	if total == 0:
		return 100.0
	var completed = get_completed_required_objectives_count()
	return (float(completed) / float(total)) * 100.0

func are_all_required_objectives_completed() -> bool:
	return get_completed_required_objectives_count() >= get_required_objectives_count()

## Quest Lifecycle

func start() -> void:
	if _quest_status != QuestStatus.NOT_STARTED:
		push_warning("Attempting to start quest that is not in NOT_STARTED state")
		return

	_quest_status = QuestStatus.ACTIVE
	_start_timestamp = Time.get_ticks_msec() / 1000.0

	# Activate all objectives
	for i in range(_runtime_objectives.size()):
		var objective = _runtime_objectives[i]
		objective.set_active(true)
		objective_activated.emit(i)

	quest_started.emit()

func complete() -> void:
	if _quest_status != QuestStatus.ACTIVE:
		push_warning("Attempting to complete quest that is not ACTIVE")
		return

	_quest_status = QuestStatus.COMPLETED
	_completion_timestamp = Time.get_ticks_msec() / 1000.0
	quest_completed.emit()

func fail() -> void:
	if _quest_status != QuestStatus.ACTIVE:
		push_warning("Attempting to fail quest that is not ACTIVE")
		return

	_quest_status = QuestStatus.FAILED
	_completion_timestamp = Time.get_ticks_msec() / 1000.0
	quest_failed.emit()

func abandon() -> void:
	if _quest_status != QuestStatus.ACTIVE:
		push_warning("Attempting to abandon quest that is not ACTIVE")
		return

	_quest_status = QuestStatus.ABANDONED
	_completion_timestamp = Time.get_ticks_msec() / 1000.0
	quest_abandoned.emit()

func reset() -> void:
	_quest_status = QuestStatus.NOT_STARTED
	_start_timestamp = 0.0
	_completion_timestamp = 0.0
	_delivered_rewards.clear()

	# Disconnect signal connections to prevent memory leaks
	for objective in _runtime_objectives:
		if objective.completed.is_connected(_on_objective_completed):
			objective.completed.disconnect(_on_objective_completed)
		objective.reset()

## Objective Management

func add_objective(runtime_objective: PPRuntimeQuestObjective) -> void:
	_runtime_objectives.append(runtime_objective)
	var index = _runtime_objectives.size() - 1
	# Check if already connected to avoid duplicate connections
	if not runtime_objective.completed.is_connected(_on_objective_completed):
		runtime_objective.completed.connect(_on_objective_completed.bind(index))

func get_objective(index: int) -> PPRuntimeQuestObjective:
	if index < 0 or index >= _runtime_objectives.size():
		return null
	return _runtime_objectives[index]

func find_objective_by_id(objective_id: String) -> PPRuntimeQuestObjective:
	for objective in _runtime_objectives:
		var obj_instance = objective.get_quest_objective_instance()
		if obj_instance and obj_instance.get_objective_id() == objective_id:
			return objective
	return null

## Reward Management

func mark_reward_delivered(reward_id: String) -> void:
	if reward_id not in _delivered_rewards:
		_delivered_rewards.append(reward_id)

func is_reward_delivered(reward_id: String) -> bool:
	return reward_id in _delivered_rewards

func are_all_rewards_delivered() -> bool:
	var rewards = quest_data.get("rewards", [])
	return _delivered_rewards.size() >= rewards.size()

## Serialization

func to_dict() -> Dictionary:
	var objectives_data = []
	for objective in _runtime_objectives:
		objectives_data.append(objective.to_dict())

	var rewards_data = []
	for reward in _rewards:
		# Get the extension configuration for proper serialization
		var reward_configuration := PandoraSettings.find_extension_configuration_property("quest_reward_property")
		var reward_fields_settings : Array[Dictionary]
		if reward_configuration:
			reward_fields_settings.assign(reward_configuration.get("fields", []) as Array)
		else:
			# Fallback to all fields enabled
			reward_fields_settings = [
				{"name": "Reward Name", "enabled": true},
				{"name": "Reward Type", "enabled": true},
				{"name": "Reward Entity", "enabled": true},
				{"name": "Quantity", "enabled": true},
				{"name": "Currency Amount", "enabled": true}
			]
		rewards_data.append(reward.save_data(reward_fields_settings))

	return {
		"quest_data": quest_data,
		"quest_status": _quest_status,
		"start_timestamp": _start_timestamp,
		"completion_timestamp": _completion_timestamp,
		"delivered_rewards": _delivered_rewards,
		"runtime_objectives": objectives_data,
		"rewards": rewards_data
	}

static func from_dict(data: Dictionary) -> PPRuntimeQuest:
	var runtime = PPRuntimeQuest.new(data.get("quest_data", {}))
	runtime._quest_status = data.get("quest_status", QuestStatus.NOT_STARTED)
	runtime._start_timestamp = data.get("start_timestamp", 0.0)
	runtime._completion_timestamp = data.get("completion_timestamp", 0.0)
	runtime._delivered_rewards = data.get("delivered_rewards", [])

	# Load runtime objectives
	var objectives_data = data.get("runtime_objectives", [])
	for obj_data in objectives_data:
		var runtime_obj = PPRuntimeQuestObjective.from_dict(obj_data)
		runtime.add_objective(runtime_obj)

	# Load rewards
	var rewards_data = data.get("rewards", [])
	for reward_data in rewards_data:
		var reward := PPQuestReward.new()
		reward.load_data(reward_data)
		runtime._rewards.append(reward)

	return runtime

## Helper Methods

func get_display_text() -> String:
	var text = get_quest_name()

	if not is_hidden():
		var progress = get_progress_percentage()
		text += " (%d%%)" % int(progress)

	return text

func get_status_string() -> String:
	match _quest_status:
		QuestStatus.NOT_STARTED:
			return "Not Started"
		QuestStatus.ACTIVE:
			return "Active"
		QuestStatus.COMPLETED:
			return "Completed"
		QuestStatus.FAILED:
			return "Failed"
		QuestStatus.ABANDONED:
			return "Abandoned"
		_:
			return "Unknown"

## Private Methods

func _initialize_objectives() -> void:
	if not _quest_instance:
		return

	var objectives = _quest_instance.get_objectives()
	for obj_data in objectives:
		var runtime_obj: PPRuntimeQuestObjective

		# Check if it's already a PPQuestObjective or needs to be created from Dictionary
		if obj_data is PPQuestObjective:
			runtime_obj = PPRuntimeQuestObjective.new(obj_data)
		elif obj_data is Dictionary:
			# Assume it's serialized PPQuestObjective data
			runtime_obj = PPRuntimeQuestObjective.new(obj_data)
		else:
			push_warning("Unknown objective data type in quest initialization")
			continue

		add_objective(runtime_obj)

func _initialize_rewards() -> void:
	if not _quest_instance:
		return

	var rewards = _quest_instance.get_rewards()
	for reward_data in rewards:
		# Check if it's already a PPQuestReward or needs to be created from Dictionary
		if reward_data is PPQuestReward:
			_rewards.append(reward_data)
		elif reward_data is Dictionary:
			# Deserialize from Dictionary
			var reward := PPQuestReward.new()
			reward.load_data(reward_data)
			_rewards.append(reward)
		else:
			push_warning("Unknown reward data type in quest initialization")
			continue

func _on_objective_completed(objective_index: int) -> void:
	objective_completed.emit(objective_index)

	# Check if quest is completed
	if are_all_required_objectives_completed():
		if is_auto_complete():
			complete()
		else:
			quest_progress_updated.emit(
				get_completed_required_objectives_count(),
				get_required_objectives_count(),
				get_progress_percentage()
			)
	else:
		quest_progress_updated.emit(
			get_completed_required_objectives_count(),
			get_required_objectives_count(),
			get_progress_percentage()
		)
