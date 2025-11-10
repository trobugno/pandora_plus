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
	_reference = PandoraReference.new(data["item"]["_entity_id"], data["item"]["_type"])
	_quantity = data["quantity"]

func save_data() -> Dictionary:
	return { "item": _reference.save_data(), "quantity": _quantity }

func _to_string() -> String:
	return "<PPIngredient " + str(get_item_entity()) + ">"
