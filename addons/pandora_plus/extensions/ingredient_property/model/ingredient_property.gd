class_name PPIngredient extends RefCounted

var _reference : PandoraReference
var _quantity : int

func _init(reference: PandoraReference, quantity: int) -> void:
	_reference = reference
	_quantity = quantity

func set_entity(entity: PandoraEntity) -> void:
	_reference = PandoraReference.new(entity.get_entity_id(), PandoraReference.Type.ENTITY)

func set_quantity(quantity: int) -> void:
	_quantity = quantity

func get_item_entity() -> PPItemEntity:
	return _reference.get_entity() as PPItemEntity

func get_quantity() -> int:
	return _quantity

func load_data(data: Dictionary) -> void:
	if data.has("item"):
		_reference = PandoraReference.new(data["item"]["_entity_id"], data["item"]["_type"])
	if data.has("quantity"):
		_quantity = data["quantity"]

func save_data(fields_settings: Array[Dictionary]) -> Dictionary:
	var result := {}
	var item_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Item")[0] as Dictionary
	var quantity_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Quantity")[0] as Dictionary
	if item_field_settings["enabled"]:
		result["item"] = _reference.save_data()
	if quantity_field_settings["enabled"]:
		result["quantity"] = _quantity
	return result

func _to_string() -> String:
	return "<PPIngredient " + str(get_item_entity()) + ">"
