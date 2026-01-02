class_name PPQuestObjective extends RefCounted

## Quest Objective Property (Static)
## Represents immutable objective data, similar to PPStats or PPIngredient
## Used to define quest objectives that are then tracked at runtime

var _objective_id: String
var _objective_type: int
var _description: String
var _target_reference: PandoraReference
var _target_quantity: int
var _hidden: bool
var _custom_script: String

## Constructor
func _init(
	objective_id: String = "",
	objective_type: int = -1,
	description: String = "",
	target_reference: PandoraReference = null,
	target_quantity: int = 0,
	hidden: bool = false,
	custom_script: String = ""
) -> void:
	_objective_id = objective_id
	_objective_type = objective_type
	_description = description
	_target_reference = target_reference
	_target_quantity = target_quantity
	_hidden = hidden
	_custom_script = custom_script

## Getters

func get_objective_id() -> String:
	return _objective_id

func get_objective_type() -> int:
	return _objective_type

func get_description() -> String:
	return _description

func get_target_reference() -> PandoraReference:
	return _target_reference

func get_target_entity() -> PandoraEntity:
	return _target_reference.get_entity() if _target_reference else null

func get_target_quantity() -> int:
	return _target_quantity

func is_hidden() -> bool:
	return _hidden

func get_custom_script() -> String:
	return _custom_script

## Setters

func set_objective_id(objective_id: String) -> void:
	_objective_id = objective_id

func set_objective_type(objective_type: int) -> void:
	_objective_type = objective_type

func set_description(description: String) -> void:
	_description = description

func set_target_reference(reference: PandoraReference) -> void:
	_target_reference = reference

func set_target_quantity(quantity: int) -> void:
	_target_quantity = quantity

func set_hidden(hidden: bool) -> void:
	_hidden = hidden

func set_custom_script(script: String) -> void:
	_custom_script = script

## Serialization (follows PPStats pattern)

func load_data(data: Dictionary) -> void:
	_objective_id = data.get("objective_id", "")
	_objective_type = data.get("objective_type", -1)
	_description = data.get("description", "")
	
	if data.has("target_reference"):
		var ref_data = data["target_reference"]
		if ref_data is Dictionary and ref_data.has("_entity_id") and ref_data.has("_type"):
			_target_reference = PandoraReference.new(ref_data["_entity_id"], ref_data["_type"])
		else:
			_target_reference = null
	
	_target_quantity = data.get("target_quantity", 1)
	_hidden = data.get("hidden", false)
	#_custom_script = data.get("custom_script", "")

func save_data(fields_settings: Array[Dictionary]) -> Dictionary:
	var result := {}

	# Safe field lookup
	var id_field_array = fields_settings.filter(func(d): return d["name"] == "Objective ID")
	var type_field_array = fields_settings.filter(func(d): return d["name"] == "Objective Type")
	var desc_field_array = fields_settings.filter(func(d): return d["name"] == "Description")
	var target_field_array = fields_settings.filter(func(d): return d["name"] == "Target Entity")
	var quantity_field_array = fields_settings.filter(func(d): return d["name"] == "Target Quantity")
	var hidden_field_array = fields_settings.filter(func(d): return d["name"] == "Hidden")
	#var script_field_array = fields_settings.filter(func(d): return d["name"] == "Custom Script")

	if id_field_array.size() > 0:
		var id_field = id_field_array[0]
		if id_field["enabled"]:
			result["objective_id"] = _objective_id

	if type_field_array.size() > 0:
		var type_field = type_field_array[0]
		if type_field["enabled"]:
			result["objective_type"] = _objective_type

	if desc_field_array.size() > 0:
		var desc_field = desc_field_array[0]
		if desc_field["enabled"]:
			result["description"] = _description

	if target_field_array.size() > 0:
		var target_field = target_field_array[0]
		if target_field["enabled"] and _target_reference:
			result["target_reference"] = _target_reference.save_data()

	if quantity_field_array.size() > 0:
		var quantity_field = quantity_field_array[0]
		if quantity_field["enabled"]:
			result["target_quantity"] = _target_quantity

	if hidden_field_array.size() > 0:
		var hidden_field = hidden_field_array[0]
		if hidden_field["enabled"]:
			result["hidden"] = _hidden

	#if script_field_array.size() > 0:
		#var script_field = script_field_array[0]
		#if script_field["enabled"]:
			#result["custom_script"] = _custom_script

	return result

## Creates a deep copy of this objective
func duplicate() -> PPQuestObjective:
	var target_ref_copy: PandoraReference = null
	if _target_reference:
		target_ref_copy = PandoraReference.new(_target_reference._entity_id, PandoraReference.Type.ENTITY)

	return PPQuestObjective.new(
		_objective_id,
		_objective_type,
		_description,
		target_ref_copy,
		_target_quantity,
		_hidden,
		_custom_script
	)

func _to_string() -> String:
	return "<PPQuestObjective '%s'>" % _objective_id
