extends Resource
class_name PPInventory

signal inventory_updated
signal item_added(item: PPItemEntity, quantity: int)
signal item_removed(item: PPItemEntity, quantity: int)

@export var all_items : Array[PPInventorySlot] = []
@export var equipments : Array[PPInventorySlot] = []
@export var game_currency: int = 0

var _max_items_in_inventory : int = -1
var _max_items_in_equipments : int = -1

func _init(pmi_inventory: int = -1, pmi_equipments: int = -1) -> void:
	_max_items_in_inventory = pmi_inventory
	_max_items_in_equipments = pmi_equipments
	
	if _max_items_in_inventory > -1:
		for i in _max_items_in_inventory:
			all_items.append(null)
	
	if _max_items_in_equipments > -1:
		for i in _max_items_in_equipments:
			equipments.append(null)

func has_item(item: PPItemEntity, quantity : int = 1) -> bool:
	var inventory_slots = all_items.filter(func(s: PPInventorySlot): return s and s.item and s.item._id == item._id) \
		.filter(func(s: PPInventorySlot): return s.quantity >= quantity)
	if inventory_slots:
		return true
	return false
	
func add_item(item: PPItemEntity, quantity: int = 1, new_slot: bool = false) -> void:
	var inventory_slots = all_items.filter(func(s: PPInventorySlot): return s and s.item and s.item._id == item._id) \
		.filter(func(s: PPInventorySlot): return s.quantity < s.MAX_STACK_SIZE)
	var inventory_slot = PPInventorySlot.new()
	inventory_slot.item = item
	inventory_slot.quantity = quantity
	
	if inventory_slots:
		if inventory_slots[0].can_fully_merge_with(inventory_slot) and not new_slot:
			inventory_slots[0].fully_merge_with(inventory_slot)
		else:
			var index = all_items.find(null)
			if index > -1:
				all_items[index] = inventory_slot
			elif index == -1 and _max_items_in_inventory == -1:
				all_items.append(inventory_slot)
	else:
		var index = all_items.find(null)
		if index > -1:
			all_items[index] = inventory_slot
		elif index == -1 and _max_items_in_inventory == -1:
			all_items.append(inventory_slot)
	
	item_added.emit(item, quantity)

func remove_item(item: PPItemEntity, quantity: int = 1, source: Array[PPInventorySlot] = all_items) -> void:
	for index in source.size():
		if source[index]:
			if source[index].item.get_entity_id() == item.get_entity_id():
				if source[index].quantity > quantity:
					source[index].quantity -= quantity
					item_removed.emit(item, quantity)
					return
				elif source[index].quantity == quantity:
					source[index] = null
					item_removed.emit(item, quantity)
					return
	push_error("Impossible to remove item.")

func remove_single_item_by(index: int) -> PPItemEntity:
	var inventory_slot = all_items[index]
	
	if inventory_slot:
		if inventory_slot.quantity == 1:
			all_items[index] = null
			inventory_updated.emit()
			return inventory_slot.item
		else:
			inventory_slot.quantity -= 1
			inventory_updated.emit()
			return inventory_slot.item
	return null
