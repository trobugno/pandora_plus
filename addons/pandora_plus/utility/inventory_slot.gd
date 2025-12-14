extends Resource
class_name PPInventorySlot

const MAX_STACK_SIZE : int = 99

@export var item: PPItemEntity
@export_range(1, MAX_STACK_SIZE) var quantity : int = 1: set = set_quantity

func set_quantity(value: int) -> void:
	quantity = value
	if quantity > 1 and item and not item.is_stackable():
		quantity = 1
		push_error("%s is not stackable, setting quantity to 1" % item.get_item_name())

func can_merge_with(other_slot: PPInventorySlot) -> bool:
	return item._id == other_slot.item._id \
			and item.is_stackable() \
			and quantity < MAX_STACK_SIZE

func can_fully_merge_with(other_slot: PPInventorySlot) -> bool:
	return item._id == other_slot.item._id \
			and item.is_stackable() \
			and quantity + other_slot.quantity < MAX_STACK_SIZE

func fully_merge_with(other_slot: PPInventorySlot) -> void:
	quantity += other_slot.quantity

func merge_with(other_slot: PPInventorySlot) -> void:
	var max_quantity_left = MAX_STACK_SIZE - quantity
	if other_slot.quantity < max_quantity_left:
		quantity += other_slot.quantity
		other_slot.quantity = 0
	else:
		var transfered_quantity = max_quantity_left - other_slot.quantity
		quantity += transfered_quantity
		other_slot.quantity -= transfered_quantity 

func create_single_slot() -> PPInventorySlot:
	var new_slot_resource = duplicate()
	new_slot_resource.quantity = 1
	quantity -= 1
	return new_slot_resource
