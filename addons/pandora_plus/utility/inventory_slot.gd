extends Resource
class_name PPInventorySlot

const MAX_STACK_SIZE : int = 99

## The item entity (used when runtime_item is null)
@export var item: PPItemEntity

## Runtime item instance with per-instance data (optional)
## When set, this takes precedence over 'item'
@export var runtime_item: PPRuntimeItem

@export_range(1, MAX_STACK_SIZE) var quantity : int = 1: set = set_quantity


func set_quantity(value: int) -> void:
	quantity = value
	var item_ref = get_item()
	if quantity > 1 and item_ref and not _is_stackable():
		quantity = 1
		push_error("%s is not stackable, setting quantity to 1" % _get_item_name())

# ============================================================================
# ITEM ACCESS
# ============================================================================

## Gets the item entity (from runtime_item if available, otherwise direct item)
func get_item() -> PPItemEntity:
	if runtime_item:
		return runtime_item.get_item_entity()
	return item


## Gets the runtime item (may be null if using legacy mode)
func get_runtime_item() -> PPRuntimeItem:
	return runtime_item


## Returns true if this slot uses a runtime item
func has_runtime_item() -> bool:
	return runtime_item != null


## Sets the item from either PPItemEntity or PPRuntimeItem
func set_item_from(item_or_runtime: Variant) -> void:
	if item_or_runtime is PPRuntimeItem:
		runtime_item = item_or_runtime
		item = item_or_runtime.get_item_entity()
	elif item_or_runtime is PPItemEntity:
		item = item_or_runtime
		runtime_item = null
	else:
		push_error("PPInventorySlot.set_item_from: Expected PPItemEntity or PPRuntimeItem")

# ============================================================================
# HELPER METHODS
# ============================================================================

func _is_stackable() -> bool:
	if runtime_item:
		return runtime_item.is_stackable()
	elif item:
		return item.is_stackable()
	return false


func _get_item_name() -> String:
	if runtime_item:
		return runtime_item.get_display_name()
	elif item:
		return item.get_item_name()
	return "Unknown"


func _get_entity_id() -> String:
	if runtime_item:
		return runtime_item.get_entity_id()
	elif item:
		return item.get_entity_id()
	return ""

# ============================================================================
# MERGE OPERATIONS
# ============================================================================

func can_merge_with(other_slot: PPInventorySlot) -> bool:
	var this_item = get_item()
	var other_item = other_slot.get_item() if other_slot else null

	if not this_item or not other_item:
		return false

	# Check basic stackability
	if not _is_stackable():
		return false

	if quantity >= MAX_STACK_SIZE:
		return false

	# If either slot has runtime items, use runtime comparison
	if runtime_item or other_slot.runtime_item:
		return _can_runtime_merge_with(other_slot)

	# Legacy mode: compare entity IDs
	return this_item._id == other_item._id


func _can_runtime_merge_with(other_slot: PPInventorySlot) -> bool:
	# Both must be same entity type
	if _get_entity_id() != other_slot._get_entity_id():
		return false

	# If both have runtime items, check if they can stack
	if runtime_item and other_slot.runtime_item:
		return runtime_item.can_stack_with(other_slot.runtime_item)

	# If only one has runtime item, can only merge if runtime has no custom data
	if runtime_item:
		return not runtime_item.has_custom_name()
	if other_slot.runtime_item:
		return not other_slot.runtime_item.has_custom_name()

	return true


func can_fully_merge_with(other_slot: PPInventorySlot) -> bool:
	if not can_merge_with(other_slot):
		return false
	return quantity + other_slot.quantity <= MAX_STACK_SIZE


func fully_merge_with(other_slot: PPInventorySlot) -> void:
	quantity += other_slot.quantity


func merge_with(other_slot: PPInventorySlot) -> void:
	var max_quantity_left = MAX_STACK_SIZE - quantity
	if other_slot.quantity <= max_quantity_left:
		quantity += other_slot.quantity
		other_slot.quantity = 0
	else:
		var transfered_quantity = max_quantity_left
		quantity += transfered_quantity
		other_slot.quantity -= transfered_quantity


func create_single_slot() -> PPInventorySlot:
	var new_slot_resource = PPInventorySlot.new()
	new_slot_resource.item = item

	# If we have a runtime item, create a new instance for the split
	if runtime_item:
		# For non-stackable items, the new slot gets the runtime item
		# For stackable items, we don't typically have runtime items
		new_slot_resource.runtime_item = runtime_item
		runtime_item = null

	new_slot_resource.quantity = 1
	quantity -= 1
	return new_slot_resource

# ============================================================================
# SERIALIZATION
# ============================================================================

## Converts slot to dictionary for saving
func to_dict() -> Dictionary:
	var data: Dictionary = {
		"quantity": quantity
	}

	if runtime_item:
		data["runtime_item"] = runtime_item.to_dict()
		data["item_id"] = runtime_item.get_entity_id()
	elif item:
		data["item_id"] = item.get_entity_id()

	return data


## Creates slot from dictionary (deserialization)
static func from_dict(data: Dictionary) -> PPInventorySlot:
	if data.is_empty():
		return null

	var slot = PPInventorySlot.new()
	slot.quantity = data.get("quantity", 1)

	# Check if we have runtime item data
	if data.has("runtime_item"):
		slot.runtime_item = PPRuntimeItem.from_dict(data["runtime_item"])
		slot.item = slot.runtime_item.get_item_entity()
	elif data.has("item_id"):
		# Legacy mode: just entity ID
		slot.item = Pandora.get_entity(data["item_id"]) as PPItemEntity

	return slot
