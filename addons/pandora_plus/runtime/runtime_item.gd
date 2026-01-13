class_name PPRuntimeItem extends Resource

## Runtime item instance that tracks dynamic state during gameplay
## Base class providing core functionality for per-instance item data
##
## Features:
## - Per-instance identification with unique instance_id
## - Custom naming support
## - Full serialization for save/load
## - Delegate pattern to underlying PPItemEntity

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when the custom name changes
signal custom_name_changed(old_name: String, new_name: String)

# ============================================================================
# CORE DATA
# ============================================================================

## Serialized item entity data (cached for quick access)
@export var item_data: Dictionary = {}

## Unique instance identifier
var _instance_id: String = ""

## Reference to the static item entity template
var _item_entity: PPItemEntity

## Custom display name (empty = use entity name)
var _custom_name: String = ""

# ============================================================================
# INITIALIZATION
# ============================================================================

func _init(p_item_data: Variant = null) -> void:
	if p_item_data is PPItemEntity:
		# Initialize from entity
		_item_entity = p_item_data
		item_data = _serialize_entity_data(p_item_data)
		_instance_id = _generate_instance_id()
	elif p_item_data is Dictionary:
		# Initialize from dictionary (deserialization)
		item_data = p_item_data
		_restore_from_dict(p_item_data)


func _serialize_entity_data(entity: PPItemEntity) -> Dictionary:
	return {
		"entity_id": entity.get_entity_id(),
		"name": entity.get_item_name(),
		"stackable": entity.is_stackable(),
		"value": entity.get_value(),
		"weight": entity.get_weight()
	}


func _restore_from_dict(data: Dictionary) -> void:
	# Restore instance ID
	_instance_id = data.get("instance_id", _generate_instance_id())

	# Restore entity reference
	var entity_id = data.get("entity_id", item_data.get("entity_id", ""))
	if entity_id:
		var entity_ref = PandoraReference.new(entity_id, PandoraReference.Type.ENTITY)
		_item_entity = entity_ref.get_entity() as PPItemEntity
		if not _item_entity:
			push_error("PPRuntimeItem: Failed to restore item entity with ID '%s'. Entity may have been deleted." % entity_id)

	# Restore custom name
	_custom_name = data.get("custom_name", "")


func _generate_instance_id() -> String:
	return str(Time.get_unix_time_from_system()) + "_" + str(randi())

# ============================================================================
# INSTANCE IDENTIFICATION
# ============================================================================

## Returns the unique instance ID
func get_instance_id() -> String:
	return _instance_id


## Returns true if this is a valid runtime item with an entity
func is_valid() -> bool:
	return _item_entity != null

# ============================================================================
# CUSTOM NAME
# ============================================================================

## Sets a custom display name for this item instance
func set_custom_name(new_name: String) -> void:
	var old_name = _custom_name
	_custom_name = new_name
	custom_name_changed.emit(old_name, new_name)


## Gets the custom name (empty if not set)
func get_custom_name() -> String:
	return _custom_name


## Returns true if this item has a custom name
func has_custom_name() -> bool:
	return not _custom_name.is_empty()


## Gets the display name (custom name if set, otherwise entity name)
func get_display_name() -> String:
	if has_custom_name():
		return _custom_name
	return get_item_name()

# ============================================================================
# ENTITY ACCESSORS (Delegate to _item_entity)
# ============================================================================

## Gets the underlying item entity
func get_item_entity() -> PPItemEntity:
	return _item_entity


## Gets the entity ID
func get_entity_id() -> String:
	if _item_entity:
		return _item_entity.get_entity_id()
	return item_data.get("entity_id", "")


## Gets the item name from entity
func get_item_name() -> String:
	if _item_entity:
		return _item_entity.get_item_name()
	return item_data.get("name", "Unknown Item")


## Gets the item description
func get_description() -> String:
	if _item_entity:
		return _item_entity.get_description()
	return ""


## Gets the item texture
func get_texture() -> Texture:
	if _item_entity:
		return _item_entity.get_texture()
	return null


## Returns true if the item is stackable
func is_stackable() -> bool:
	if _item_entity:
		return _item_entity.is_stackable()
	return item_data.get("stackable", false)


## Gets the item value
func get_value() -> float:
	if _item_entity:
		return _item_entity.get_value()
	return item_data.get("value", 0.0)


## Gets the item weight
func get_weight() -> float:
	if _item_entity:
		return _item_entity.get_weight()
	return item_data.get("weight", 0.0)


## Gets the item rarity
func get_rarity() -> PPRarityEntity:
	if _item_entity:
		return _item_entity.get_rarity()
	return null

# ============================================================================
# COMPARISON
# ============================================================================

## Returns true if two runtime items are the same instance
func is_same_instance(other: PPRuntimeItem) -> bool:
	if not other:
		return false
	return _instance_id == other._instance_id


## Returns true if two runtime items reference the same entity type
func is_same_item_type(other: PPRuntimeItem) -> bool:
	if not other:
		return false
	return get_entity_id() == other.get_entity_id()


## Returns true if this item can stack with another
## Override in subclass to add additional conditions (e.g., same enchantments)
func can_stack_with(other: PPRuntimeItem) -> bool:
	if not other:
		return false
	if not is_stackable():
		return false
	if not is_same_item_type(other):
		return false
	# Base implementation: same type and no custom names
	return not has_custom_name() and not other.has_custom_name()

# ============================================================================
# SERIALIZATION
# ============================================================================

## Converts runtime item to dictionary for saving
func to_dict() -> Dictionary:
	return {
		"entity_id": get_entity_id(),
		"instance_id": _instance_id,
		"custom_name": _custom_name,
		"item_data": item_data
	}


## Creates runtime item from dictionary (deserialization)
static func from_dict(data: Dictionary) -> PPRuntimeItem:
	var runtime = PPRuntimeItem.new(data)
	return runtime

# ============================================================================
# STRING REPRESENTATION
# ============================================================================

func _to_string() -> String:
	var name = get_display_name()
	return "<PPRuntimeItem:%s [%s]>" % [name, _instance_id.substr(0, 8)]
