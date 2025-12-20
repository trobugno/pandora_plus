class_name PPQuestObjective extends RefCounted

## Quest Objective Property (Static)
## Represents immutable objective data, similar to PPStats or PPIngredient
## Used to define quest objectives that are then tracked at runtime

var _objective_id: String
var _objective_type: int
var _description: String
var _target_reference: PandoraReference
var _target_quantity: int
var _optional: bool
var _hidden: bool
var _sequential: bool
var _order_index: int
var _custom_script: String

## Constructor
func _init(
	objective_id: String,
	objective_type: int,
	description: String,
	target_reference: PandoraReference,
	target_quantity: int,
	optional: bool = false,
	hidden: bool = false,
	sequential: bool = false,
	order_index: int = 0,
	custom_script: String = ""
) -> void:
	_objective_id = objective_id
	_objective_type = objective_type
	_description = description
	_target_reference = target_reference
	_target_quantity = target_quantity
	_optional = optional
	_hidden = hidden
	_sequential = sequential
	_order_index = order_index
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

func is_optional() -> bool:
	return _optional

func is_hidden() -> bool:
	return _hidden

func is_sequential() -> bool:
	return _sequential

func get_order_index() -> int:
	return _order_index

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

func set_optional(optional: bool) -> void:
	_optional = optional

func set_hidden(hidden: bool) -> void:
	_hidden = hidden

func set_sequential(sequential: bool) -> void:
	_sequential = sequential

func set_order_index(index: int) -> void:
	_order_index = index

func set_custom_script(script: String) -> void:
	_custom_script = script

## Serialization (follows PPStats pattern)

func load_data(data: Dictionary) -> void:
	_objective_id = data.get("objective_id", "")
	_objective_type = data.get("objective_type", -1)
	_description = data.get("description", "")
	
	if data.has("target_reference"):
		var ref_data = data["target_reference"]
		_target_reference = PandoraReference.new(ref_data["_entity_id"], ref_data["_type"])
	
	_target_quantity = data.get("target_quantity", 1)
	_optional = data.get("optional", false)
	_hidden = data.get("hidden", false)
	_sequential = data.get("sequential", false)
	_order_index = data.get("order_index", 0)
	#_custom_script = data.get("custom_script", "")

func save_data(fields_settings: Array[Dictionary]) -> Dictionary:
	var result := {}
	
	var id_field = fields_settings.filter(func(d): return d["name"] == "Objective ID")[0]
	var type_field = fields_settings.filter(func(d): return d["name"] == "Objective Type")[0]
	var desc_field = fields_settings.filter(func(d): return d["name"] == "Description")[0]
	var target_field = fields_settings.filter(func(d): return d["name"] == "Target Entity")[0]
	var quantity_field = fields_settings.filter(func(d): return d["name"] == "Target Quantity")[0]
	var optional_field = fields_settings.filter(func(d): return d["name"] == "Optional")[0]
	var hidden_field = fields_settings.filter(func(d): return d["name"] == "Hidden")[0]
	var sequential_field = fields_settings.filter(func(d): return d["name"] == "Sequential")[0]
	var order_field = fields_settings.filter(func(d): return d["name"] == "Order Index")[0]
	#var script_field = fields_settings.filter(func(d): return d["name"] == "Custom Script")[0]
	
	if id_field["enabled"]:
		result["objective_id"] = _objective_id
	if type_field["enabled"]:
		result["objective_type"] = _objective_type
	if desc_field["enabled"]:
		result["description"] = _description
	if target_field["enabled"] and _target_reference:
		result["target_reference"] = _target_reference.save_data()
	if quantity_field["enabled"]:
		result["target_quantity"] = _target_quantity
	if optional_field["enabled"]:
		result["optional"] = _optional
	if hidden_field["enabled"]:
		result["hidden"] = _hidden
	if sequential_field["enabled"]:
		result["sequential"] = _sequential
	if order_field["enabled"]:
		result["order_index"] = _order_index
	#if script_field["enabled"]:
		#result["custom_script"] = _custom_script
	
	return result

func _to_string() -> String:
	return "<PPQuestObjective '%s'>" % _objective_id
