extends Resource
class_name PPInventory

signal inventory_updated
signal item_added(item: PPItemEntity, quantity: int)
signal item_removed(item: PPItemEntity, quantity: int)
signal equipment_changed(slot_name: String, item: PPEquipmentEntity)
signal item_equipped(slot_name: String, item: PPEquipmentEntity)
signal item_unequipped(slot_name: String, item: PPEquipmentEntity)

@export var all_items : Array[PPInventorySlot] = []
@export var equipped_items : Dictionary = {}
@export var game_currency: int = 0

var max_items_in_inventory : int = -1
var max_weight : float = -1

func _init(pmi_inventory: int = -1, pmi_equipments: int = -1) -> void:
	max_items_in_inventory = pmi_inventory

	if max_items_in_inventory > -1:
		for i in max_items_in_inventory:
			all_items.append(null)

	_initialize_equipment_slots()

func has_item(item: PPItemEntity, quantity : int = 1) -> bool:
	if not item:
		return false
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
			elif index == -1 and max_items_in_inventory == -1:
				all_items.append(inventory_slot)
	else:
		var index = all_items.find(null)
		if index > -1:
			all_items[index] = inventory_slot
		elif index == -1 and max_items_in_inventory == -1:
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

## Equipment Management Methods

func _initialize_equipment_slots() -> void:
	equipped_items = {
		"HEAD": null,
		"CHEST": null,
		"LEGS": null,
		"WEAPON": null,
		"SHIELD": null,
		"ACCESSORY_1": null,
		"ACCESSORY_2": null
	}

func get_equipped_item(slot_name: String) -> PPInventorySlot:
	return equipped_items.get(slot_name, null)

func set_equipped_item(slot_name: String, slot: PPInventorySlot) -> void:
	equipped_items[slot_name] = slot
	if slot:
		equipment_changed.emit(slot_name, slot.item as PPEquipmentEntity)

func get_all_equipped_items() -> Dictionary:
	return equipped_items.duplicate()

func has_equipment_in_slot(slot_name: String) -> bool:
	return equipped_items.get(slot_name) != null

## Serialization Methods

func to_dict() -> Dictionary:
	var equipped_dict := {}
	for slot_name in equipped_items.keys():
		var slot = equipped_items[slot_name]
		if slot and slot.item:
			equipped_dict[slot_name] = {
				"item_id": slot.item.get_entity_id(),
				"quantity": slot.quantity
			}
		else:
			equipped_dict[slot_name] = null

	return {
		"all_items": all_items.map(func(s): return _slot_to_dict(s)),
		"equipped_items": equipped_dict,
		"game_currency": game_currency
	}

static func from_dict(data: Dictionary) -> PPInventory:
	var inventory = PPInventory.new()

	# Restore all_items
	if data.has("all_items"):
		inventory.all_items.clear()
		for slot_data in data["all_items"]:
			inventory.all_items.append(_slot_from_dict(slot_data))

	# Restore equipped_items
	if data.has("equipped_items"):
		for slot_name in data["equipped_items"].keys():
			var slot_data = data["equipped_items"][slot_name]
			inventory.equipped_items[slot_name] = _slot_from_dict(slot_data)

	# Restore currency
	if data.has("game_currency"):
		inventory.game_currency = data["game_currency"]

	return inventory

static func _slot_to_dict(slot: PPInventorySlot) -> Variant:
	if not slot or not slot.item:
		return null
	return {
		"item_id": slot.item.get_entity_id(),
		"quantity": slot.quantity
	}

static func _slot_from_dict(slot_data: Variant) -> PPInventorySlot:
	if slot_data == null:
		return null
	var slot = PPInventorySlot.new()
	slot.item = Pandora.get_entity(slot_data["item_id"]) as PPItemEntity
	slot.quantity = slot_data.get("quantity", 1)
	return slot
