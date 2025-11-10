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
	_reference = PandoraReference.new(data["item"]["_entity_id"], data["item"]["_type"])
	_min_quantity = data["min_quantity"]
	_max_quantity = data["max_quantity"]

func save_data() -> Dictionary:
	return { "item": _reference.save_data(), "min_quantity": _min_quantity, "max_quantity": _max_quantity }

func _to_string() -> String:
	return "<PPItemDrop" + str(get_item_entity()) + ">"
