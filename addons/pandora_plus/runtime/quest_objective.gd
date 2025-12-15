class_name PPRuntimeQuestObjective extends Resource

## Runtime Quest Objective
## Tracks progress and state of a single quest objective during gameplay

signal progress_updated(old_progress: int, new_progress: int)
signal completed()

@export var quest_objective_data : Dictionary = {}

var _quest_objective_instance: PPQuestObjective
var _current_progress: int = 0
var _is_completed: bool = false
var _is_active: bool = true  # For sequential objectives

## Constructor
func _init(p_quest_objective: Variant) -> void:
	assert(p_quest_objective != null and (p_quest_objective is PPQuestObjective or p_quest_objective is Dictionary), "PPRuntimeQuestObjective requires a valid PPQuestObjective or Dictionary")
	if p_quest_objective is PPQuestObjective:
		var extension_configuration := PandoraSettings.find_extension_configuration_property("quest_objective_property")
		var fields_settings : Array[Dictionary]
		fields_settings.assign(extension_configuration.get("fields", []) as Array)
		quest_objective_data = p_quest_objective.save_data(fields_settings)
		_quest_objective_instance = p_quest_objective
	elif p_quest_objective is Dictionary:
		quest_objective_data = p_quest_objective
		# Create PPQuestObjective instance from dictionary data
		_quest_objective_instance = PPQuestObjective.new(
			"",    # objective_id - will be loaded via load_data
			-1,    # objective_type - will be loaded via load_data
			"",    # description - will be loaded via load_data
			null,  # target_reference - will be loaded via load_data
			1      # target_quantity - will be loaded via load_data
		)
		# Load actual data from dictionary
		_quest_objective_instance.load_data(p_quest_objective)

## Returns current progress
func get_current_progress() -> int:
	return _current_progress

## Returns completion percentage (0-100)
func get_progress_percentage() -> float:
	if not _quest_objective_instance:
		return 0.0
	var target = _quest_objective_instance.get_target_quantity()
	if target <= 0:
		return 0.0
	return min(100.0, (_current_progress / float(target)) * 100.0)

## Returns whether objective is completed
func is_completed() -> bool:
	return _is_completed

## Returns whether objective is active (for sequential objectives)
func is_active() -> bool:
	return _is_active

## Sets the active state (for sequential objectives)
func set_active(active: bool) -> void:
	_is_active = active

## Gets the quest objective instance
func get_quest_objective_instance() -> PPQuestObjective:
	return _quest_objective_instance

## Updates progress by adding delta amount
func add_progress(delta: int) -> void:
	if _is_completed or not _is_active or not _quest_objective_instance:
		return

	var old_progress = _current_progress
	_current_progress = min(_current_progress + delta, _quest_objective_instance.get_target_quantity())

	progress_updated.emit(old_progress, _current_progress)

	# Check if completed
	if _current_progress >= _quest_objective_instance.get_target_quantity():
		complete()

## Sets progress to a specific value
func set_progress(value: int) -> void:
	if _is_completed or not _is_active or not _quest_objective_instance:
		return

	var old_progress = _current_progress
	_current_progress = clamp(value, 0, _quest_objective_instance.get_target_quantity())

	if old_progress != _current_progress:
		progress_updated.emit(old_progress, _current_progress)

		# Check if completed
		if _current_progress >= _quest_objective_instance.get_target_quantity():
			complete()

## Marks objective as completed
func complete() -> void:
	if _is_completed or not _quest_objective_instance:
		return

	_is_completed = true
	_current_progress = _quest_objective_instance.get_target_quantity()
	completed.emit()

## Resets objective to initial state
func reset() -> void:
	_current_progress = 0
	_is_completed = false
	_is_active = true

## Serializes objective state to dictionary
func to_dict() -> Dictionary:
	return {
		"quest_objective_data": quest_objective_data,
		"current_progress": _current_progress,
		"is_completed": _is_completed,
		"is_active": _is_active
	}

## Loads objective state from dictionary
static func from_dict(data: Dictionary) -> PPRuntimeQuestObjective:
	var runtime = PPRuntimeQuestObjective.new(data.get("quest_objective_data", {}))
	runtime._current_progress = data.get("current_progress", 0)
	runtime._is_completed = data.get("is_completed", false)
	runtime._is_active = data.get("is_active", true)
	return runtime

## Returns a display string for UI
func get_display_text() -> String:
	if not _quest_objective_instance:
		return "Unknown Objective"

	var text = _quest_objective_instance.get_description()

	if not _quest_objective_instance.is_hidden() and not _is_completed:
		text += " (%d/%d)" % [_current_progress, _quest_objective_instance.get_target_quantity()]

	return text

## Returns whether this objective can currently be progressed
func can_progress() -> bool:
	return _is_active and not _is_completed
