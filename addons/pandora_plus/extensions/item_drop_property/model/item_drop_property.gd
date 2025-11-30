class_name PPItemDrop extends RefCounted

var _reference : PandoraReference
var _min_quantity : int
var _max_quantity : int

func _init(reference: PandoraReference, min_quantity: int, max_quantity: int) -> void:
	_reference = reference
	_min_quantity = min_quantity
	_max_quantity = max_quantity

func set_entity(entity: PandoraEntity) -> void:
	_reference = PandoraReference.new(entity.get_entity_id(), PandoraReference.Type.ENTITY)

func get_item_entity() -> PPItemEntity:
	return _reference.get_entity() as PPItemEntity

func set_min_quantity(min_quantity: int) -> void:
	_min_quantity = min_quantity

func get_min_quantity() -> int:
	return _min_quantity

func set_max_quantity(max_quantity: int) -> void:
	_max_quantity = max_quantity

func get_max_quantity() -> int:
	return _max_quantity

func load_data(data: Dictionary) -> void:
	if data.has("item"):
		_reference = PandoraReference.new(data["item"]["_entity_id"], data["item"]["_type"])
	if data.has("min_quantity"):
		_min_quantity = data["min_quantity"]
	if data.has("max_quantity"):
		_max_quantity = data["max_quantity"]

func save_data(fields_settings: Array[Dictionary]) -> Dictionary:
	var result := {}
	var item_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Item")[0] as Dictionary
	var min_quantity_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Min Quantity")[0] as Dictionary
	var max_quantity_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Max Quantity")[0] as Dictionary
	if item_field_settings["enabled"]:
		result["item"] = _reference.save_data()
	if max_quantity_field_settings["enabled"]:
		result["max_quantity"] = _max_quantity
	if min_quantity_field_settings["enabled"]:
		result["min_quantity"] = _min_quantity
	return { "item": _reference.save_data(), "min_quantity": _min_quantity, "max_quantity": _max_quantity }

func _to_string() -> String:
	return "<PPItemDrop" + str(get_item_entity()) + ">"
