extends Node

func sort_inventory(inventory: PPInventory, sort_by: String = "name") -> void:
	var filled_slots: Array[PPInventorySlot] = []
	var empty_slots: Array[PPInventorySlot] = []
	
	for slot in inventory.all_items:
		filled_slots.append(slot)
	
	match sort_by:
		"name":
			filled_slots.sort_custom(_sort_by_name)
		"value":
			filled_slots.sort_custom(_sort_by_value)
		"weight":
			filled_slots.sort_custom(_sort_by_weight)
		"rarity":
			filled_slots.sort_custom(_sort_by_rarity)
		"quantity":
			filled_slots.sort_custom(_sort_by_quantity)
	
	inventory.all_items.clear()
	inventory.all_items.append_array(filled_slots)

func compact_inventory(inventory: PPInventory) -> int:
	var compacted_count = 0
	
	for i in range(inventory.all_items.size()):
		var slot = inventory.all_items[i]
		if not slot or not slot.item:
			continue
		
		for j in range(i + 1, inventory.all_items.size()):
			var other_slot = inventory.all_items[j]
			
			if other_slot and other_slot.item._id == slot.item._id and slot.can_merge_with(other_slot):
				slot.merge_with(other_slot)
				
				if other_slot.quantity <= 0:
					other_slot = null
					inventory.all_items[j] = null
					compacted_count += 1
	
	if inventory._max_items_in_inventory == -1:
		inventory.all_items = inventory.all_items.filter(func(i): return i != null)
	
	return compacted_count

func calculate_total_value(inventory: PPInventory) -> float:
	var total = 0
	
	for slot in inventory.all_items:
		if not slot.item:
			total += slot.item.get_value() * slot.quantity
	
	return total

func calculate_total_weight(inventory: PPInventory) -> float:
	var total = 0
	
	for slot in inventory.all_items:
		if not slot.item:
			total += slot.item.get_weight() * slot.quantity
	
	return total

func transfer_items(from_inv: PPInventory, to_inv: PPInventory, item: PPItemEntity, quantity: int = 1) -> void:
	if not from_inv.has_item(item, quantity):
		push_error("Item not found")
	else:
		to_inv.add_item(item, quantity)
		from_inv.remove_item(item, quantity)

func transfer_all(from_inv: PPInventory, to_inv: PPInventory) -> int:
	var transferred_count = 0
	
	for slot in from_inv.all_items:
		if slot and slot.item:
			to_inv.add_item(slot.item, slot.quantity)
			from_inv.remove_item(slot.item, slot.quantity)
			transferred_count += slot.quantity
	
	if from_inv._max_items_in_inventory == -1:
		from_inv.all_items = from_inv.all_items.filter(func(i): return i != null)
	
	return transferred_count

## Sorting functions
func _sort_by_name(a: PPInventorySlot, b: PPInventorySlot) -> bool:
	return a.item.get_item_name() < b.item.get_item_name()

func _sort_by_value(a: PPInventorySlot, b: PPInventorySlot) -> bool:
	return a.item.get_value() > b.item.get_value()

func _sort_by_weight(a: PPInventorySlot, b: PPInventorySlot) -> bool:
	return a.item.get_weight() < b.item.get_weight()

func _sort_by_quantity(a: PPInventorySlot, b: PPInventorySlot) -> bool:
	return a.quantity > b.quantity

func _sort_by_rarity(a: PPInventorySlot, b: PPInventorySlot) -> bool:
	var a_rarity = a.item.get_rarity()
	var b_rarity = b.item.get_rarity()
	return a_rarity.get_percentage() < b_rarity.get_percentage()
