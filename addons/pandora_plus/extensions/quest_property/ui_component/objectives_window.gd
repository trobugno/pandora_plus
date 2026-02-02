@tool
extends Window

const ArrayItem = preload("res://addons/pandora/ui/components/array_editor/array_item.tscn")
const PropertyBarScene = "res://addons/pandora/ui/components/property_bar/property_bar.tscn"

signal item_added(item: Variant)
signal item_removed(item: Variant)
signal item_updated(idx: int, new_item: Variant)

@onready var close_button: Button = %CloseButton
@onready var new_item_button: Button = %NewItemButton
@onready var items_container: VBoxContainer = %ArrayItems
@onready var main_container: VBoxContainer = %MainContainer

var property_bar: Node
var _items: Array

func _ready():
	if owner.get_parent() is SubViewport:
		return

	close_button.pressed.connect(_on_close_requested)
	new_item_button.pressed.connect(_add_new_item)

func close():
	_remove_empty_items()
	_clear()

func _add_new_item():
	var scene = property_bar.get_scene_by_type("quest_objective_property")
	var control = scene.instantiate() as PandoraPropertyControl
	var item_property = PandoraProperty.new("", "array_item", "quest_objective_property")
	_items.append(item_property.get_default_value())
	_add_property_control(control, item_property, _items.size() - 1)
	item_added.emit(_items[_items.size() - 1])

func _clear():
	_items.clear()
	for child in items_container.get_children():
		child.queue_free()
	items_container.get_children().clear()

func _add_property_control(control: PandoraPropertyControl, item_property: PandoraProperty, idx: int):
	var item = ArrayItem.instantiate()
	control.init(item_property)
	control.property_value_changed.connect(func(value: Variant): item_updated.emit(idx, value))
	item.item_removal_requested.connect(
		func(): item_removed.emit(control._property.get_default_value())
	)
	item.init(item_property, control, Pandora._entity_backend)
	items_container.add_child(item)

func _remove_empty_items():
	var indices_to_remove := []
	for index in range(_items.size()):
		if _items[index] == null:
			indices_to_remove.append(index)

	for index in range(indices_to_remove.size() - 1, -1, -1):
		var item_to_remove = _items[indices_to_remove[index]]
		_items.remove_at(indices_to_remove[index])
		item_removed.emit(item_to_remove)

func _load_items():
	var scene = property_bar.get_scene_by_type("quest_objective_property")
	for i in range(_items.size()):
		var control = scene.instantiate() as PandoraPropertyControl
		var item_property = PandoraProperty.new("", "array_item", "quest_objective_property")
		var value = _items[i]
		# PPQuestObjective is already a RefCounted object, no need to convert
		# Just handle legacy Dictionary format if present
		if value is Dictionary:
			# Create PPQuestObjective instance from dictionary data
			var objective = PPQuestObjective.new(
				"",    # objective_id - will be loaded via load_data
				-1,    # objective_type - will be loaded via load_data
				"",    # description - will be loaded via load_data
				null,  # target_reference - will be loaded via load_data
				1      # target_quantity - will be loaded via load_data
			)
			# Load actual data from dictionary
			objective.load_data(value)
			value = objective
		item_property.set_default_value(value)
		_add_property_control(control, item_property, i)

func open(original_objectives: Array):
	# Clear previous state if window is being reopened
	_clear()

	# Free previous property_bar if it exists
	if property_bar:
		property_bar.queue_free()

	popup_centered_clamped(Vector2i(800, 1000), 0.5)
	move_to_foreground()
	grab_focus()

	var property_bar_scene = load(PropertyBarScene)
	property_bar = property_bar_scene.instantiate()
	property_bar._ready()

	_items = original_objectives.duplicate()
	_load_items()

func _on_close_requested():
	close()
	hide()
	property_bar.queue_free()
