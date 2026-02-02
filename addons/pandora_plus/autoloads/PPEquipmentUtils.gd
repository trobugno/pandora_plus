extends Node

## Equipment Management Utility
## Handles equipping/unequipping items and applying stat modifiers

signal equipment_equipped(character_stats: PPRuntimeStats, slot_name: String, item: PPEquipmentEntity)
signal equipment_unequipped(character_stats: PPRuntimeStats, slot_name: String, item: PPEquipmentEntity)

## Checks if an item can be equipped
## Returns: true if item is PPEquipmentEntity, false otherwise
func can_equip(item: PandoraEntity) -> bool:
	return item is PPEquipmentEntity

## Gets the equipment slot name for an equipment item
## Returns: String slot name (e.g., "HEAD", "WEAPON") or empty string
func get_equipment_slot(item: PPEquipmentEntity) -> String:
	if not item:
		return ""
	return item.get_equipment_slot()

## Gets the stat bonuses from an equipment item
## Returns: PPStats or null if item doesn't have stats
func get_equipment_stats(item: PPEquipmentEntity) -> PPStats:
	if not item:
		return null
	return item.get_equipment_stats()

## Equips an item from inventory to equipment slot
## Applies stat modifiers to character_stats
## If slot is occupied, unequips current item first
## Returns: true if successful, false otherwise
func equip_item(
	inventory: PPInventory,
	item: PPEquipmentEntity,
	character_stats: PPRuntimeStats
) -> bool:
	if not can_equip(item):
		push_error("Item '%s' is not equippable (not PPEquipmentEntity)" % item.get_item_name())
		return false

	var slot_name = item.get_equipment_slot()

	# Check if item is in inventory
	if not inventory.has_item(item):
		push_error("Item '%s' not found in inventory" % item.get_item_name())
		return false

	# Unequip current item in slot if exists
	if inventory.has_equipment_in_slot(slot_name):
		unequip_item(inventory, slot_name, character_stats)

	# Remove from inventory
	inventory.remove_item(item, 1, inventory.all_items)

	# Create equipment slot
	var equipment_slot = PPInventorySlot.new()
	equipment_slot.item = item
	equipment_slot.quantity = 1

	# Add to equipment
	inventory.set_equipped_item(slot_name, equipment_slot)

	# Apply stat modifiers
	_apply_equipment_stats(item, slot_name, character_stats)

	inventory.item_equipped.emit(slot_name, item)
	equipment_equipped.emit(character_stats, slot_name, item)

	return true

## Unequips an item from equipment slot
## Removes stat modifiers from character_stats
## Returns item to inventory
## Returns: true if successful, false otherwise
func unequip_item(
	inventory: PPInventory,
	slot_name: String,
	character_stats: PPRuntimeStats
) -> bool:
	if not inventory.has_equipment_in_slot(slot_name):
		push_error("No equipment in slot '%s'" % slot_name)
		return false

	var equipment_slot = inventory.get_equipped_item(slot_name)
	var item = equipment_slot.item

	# Remove stat modifiers
	_remove_equipment_stats(slot_name, character_stats)

	# Remove from equipment
	inventory.set_equipped_item(slot_name, null)

	# Add back to inventory
	inventory.add_item(item, 1)

	inventory.item_unequipped.emit(slot_name, item as PPEquipmentEntity)
	equipment_unequipped.emit(character_stats, slot_name, item as PPEquipmentEntity)

	return true

## Unequips all equipped items
## Returns: number of items unequipped
func unequip_all(inventory: PPInventory, character_stats: PPRuntimeStats) -> int:
	var count = 0
	for slot_name in inventory.equipped_items.keys():
		if inventory.has_equipment_in_slot(slot_name):
			if unequip_item(inventory, slot_name, character_stats):
				count += 1
	return count

## Gets total stat bonuses from all equipped items
## Returns: Dictionary with stat_name -> total_bonus
func get_total_equipment_stats(inventory: PPInventory) -> Dictionary:
	var totals := {}

	for slot_name in inventory.equipped_items.keys():
		if inventory.has_equipment_in_slot(slot_name):
			var slot = inventory.get_equipped_item(slot_name)
			var equipment = slot.item as PPEquipmentEntity
			if equipment and equipment.has_stat_bonuses():
				var stats = equipment.get_equipment_stats()
				var bonuses = _stats_to_bonuses(stats)
				for stat_name in bonuses:
					totals[stat_name] = totals.get(stat_name, 0.0) + bonuses[stat_name]

	return totals

## PRIVATE: Applies equipment stat modifiers
func _apply_equipment_stats(item: PPEquipmentEntity, slot_name: String, character_stats: PPRuntimeStats) -> void:
	if not item.has_stat_bonuses():
		return

	var stats = item.get_equipment_stats()
	var bonuses = _stats_to_bonuses(stats)
	var source = "equipment_%s" % slot_name

	for stat_name in bonuses:
		var modifier = PPStatModifier.create_flat(
			stat_name,
			bonuses[stat_name],
			source
		)
		character_stats.add_modifier(modifier)

## PRIVATE: Removes equipment stat modifiers
func _remove_equipment_stats(slot_name: String, character_stats: PPRuntimeStats) -> void:
	var source = "equipment_%s" % slot_name
	character_stats.remove_modifiers_by_source(source)

## PRIVATE: Converts PPStats to Dictionary with only non-zero values
## Returns: Dictionary with stat_name -> value for all stats > 0
func _stats_to_bonuses(stats: PPStats) -> Dictionary:
	var bonuses := {}

	if stats._health > 0:
		bonuses["health"] = stats._health
	if stats._mana > 0:
		bonuses["mana"] = stats._mana
	if stats._attack > 0:
		bonuses["attack"] = stats._attack
	if stats._defense > 0:
		bonuses["defense"] = stats._defense
	if stats._crit_rate > 0:
		bonuses["crit_rate"] = stats._crit_rate
	if stats._crit_damage > 0:
		bonuses["crit_damage"] = stats._crit_damage
	if stats._att_speed > 0:
		bonuses["att_speed"] = stats._att_speed
	if stats._mov_speed > 0:
		bonuses["mov_speed"] = stats._mov_speed

	return bonuses
