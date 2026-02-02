class_name PPIngredient extends RefCounted

var _reference : PandoraReference
var _quantity : int

func _init(reference: Variant, quantity: int) -> void:
	assert(reference == null or reference is PandoraReference or reference is PandoraEntity, "First parameter must be null, PandoraReference or PandoraEntity")
	if reference is PandoraReference:
		_reference = reference
	elif reference is PandoraEntity:
		_reference = PandoraReference.new(reference.get_entity_id(), PandoraReference.Type.ENTITY)
	else:
		_reference = null
	_quantity = quantity

func set_entity(entity: PandoraEntity) -> void:
	_reference = PandoraReference.new(entity.get_entity_id(), PandoraReference.Type.ENTITY)

func set_quantity(quantity: int) -> void:
	_quantity = quantity

func get_item_entity() -> PPItemEntity:
	if _reference != null:
		return _reference.get_entity() as PPItemEntity
	return null

func get_quantity() -> int:
	return _quantity

func load_data(data: Dictionary) -> void:
	if data.has("item") and data["item"] is Dictionary:
		var item_data = data["item"] as Dictionary
		if item_data.has("_entity_id") and item_data.has("_type"):
			_reference = PandoraReference.new(item_data["_entity_id"], item_data["_type"])
	if data.has("quantity"):
		_quantity = data["quantity"]

func save_data(fields_settings: Array[Dictionary]) -> Dictionary:
	var result := {}
	var item_field_settings_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Item")
	var quantity_field_settings_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Quantity")

	if item_field_settings_array.size() > 0:
		var item_field_settings := item_field_settings_array[0] as Dictionary
		if item_field_settings["enabled"] and _reference != null:
			result["item"] = _reference.save_data()

	if quantity_field_settings_array.size() > 0:
		var quantity_field_settings := quantity_field_settings_array[0] as Dictionary
		if quantity_field_settings["enabled"]:
			result["quantity"] = _quantity

	return result

func duplicate() -> PPIngredient:
	var ref_copy: PandoraReference = null
	if _reference != null:
		ref_copy = PandoraReference.new(_reference._entity_id, _reference._type)
	return PPIngredient.new(ref_copy, _quantity)

func _to_string() -> String:
	var entity = get_item_entity()
	if entity != null:
		return "<PPIngredient " + str(entity) + ">"
	return "<PPIngredient (empty)>"
