@tool
extends PandoraPropertyControl

const QuestObjectiveType = preload("uid://cggb2hnqs58cy")

@onready var objective_id: LineEdit = $VBoxContainer/FirstLine/ObjectiveID/LineEdit
@onready var objective_type: OptionButton = $VBoxContainer/FirstLine/ObjectiveType/OptionButton
@onready var hidden_check: CheckButton = $VBoxContainer/FirstLine/HiddenCheck/CheckButton
@onready var objective_target: HBoxContainer = $VBoxContainer/SecondLine/ObjectiveTarget/EntityPicker
@onready var objective_target_quantity: SpinBox = $VBoxContainer/SecondLine/ObjectiveTargetQuantity/SpinBox
@onready var objective_description: TextEdit = $VBoxContainer/ThirdLine/ObjectiveDescription/TextEdit

@onready var objective_id_container: VBoxContainer = $VBoxContainer/FirstLine/ObjectiveID
@onready var objective_type_container: VBoxContainer = $VBoxContainer/FirstLine/ObjectiveType
@onready var hidden_check_container: VBoxContainer = $VBoxContainer/FirstLine/HiddenCheck
@onready var objective_target_container: VBoxContainer = $VBoxContainer/SecondLine/ObjectiveTarget
@onready var objective_target_quantity_container: VBoxContainer = $VBoxContainer/SecondLine/ObjectiveTargetQuantity
@onready var objective_description_container: VBoxContainer = $VBoxContainer/ThirdLine/ObjectiveDescription

var current_property : PPQuestObjective = PPQuestObjective.new("", -1, "", null, 0, false, "")

func _ready() -> void:
	refresh()
	Pandora.update_fields_settings.connect(_on_update_fields_settings)

	if _property != null:
		_property.setting_changed.connect(_setting_changed)
		_property.setting_cleared.connect(_setting_changed)

	# Focus signals
	objective_id.focus_entered.connect(func(): focused.emit())
	objective_id.focus_exited.connect(func(): unfocused.emit())
	objective_description.focus_entered.connect(func(): focused.emit())
	objective_description.focus_exited.connect(func(): unfocused.emit())
	objective_target.focus_entered.connect(func(): focused.emit())
	objective_target.focus_exited.connect(func(): unfocused.emit())
	objective_target_quantity.focus_entered.connect(func(): focused.emit())
	objective_target_quantity.focus_exited.connect(func(): unfocused.emit())

	# Value changed signals
	objective_id.text_changed.connect(
		func(new_text: String):
			current_property.set_objective_id(new_text)
			_set_property_value())

	objective_description.text_changed.connect(
		func():
			current_property.set_description(objective_description.text))

	objective_description.focus_exited.connect(
		func():
			_set_property_value())

	objective_type.item_selected.connect(
		func(index: int):
			current_property.set_objective_type(index)
			_set_property_value())

	objective_target.entity_selected.connect(
		func(entity: PandoraEntity):
			if entity:
				var reference = PandoraReference.new(entity._id, PandoraReference.Type.ENTITY)
				current_property.set_target_reference(reference)
			else:
				current_property.set_target_reference(null)
			_set_property_value())

	objective_target_quantity.value_changed.connect(
		func(value: float):
			current_property.set_target_quantity(int(value))
			_set_property_value())

	hidden_check.toggled.connect(
		func(toggled_on: bool):
			_on_check_button_toggled(toggled_on, hidden_check)
			current_property.set_hidden(toggled_on)
			_set_property_value())

func _set_property_value() -> void:
	_property.set_default_value(current_property)
	property_value_changed.emit(current_property)

func refresh() -> void:
	if _fields_settings:
		for field_settings in _fields_settings:
			if field_settings["name"] == "Objective ID":
				objective_id_container.visible = field_settings["enabled"]
			elif field_settings["name"] == "Objective Type":
				objective_type_container.visible = field_settings["enabled"]

				objective_type.clear()
				for option_value in field_settings["settings"]["options"]:
					objective_type.add_item(option_value)
			elif field_settings["name"] == "Description":
				objective_description_container.visible = field_settings["enabled"]
			elif field_settings["name"] == "Target Entity":
				objective_target_container.visible = field_settings["enabled"]
			elif field_settings["name"] == "Target Quantity":
				objective_target_quantity_container.visible = field_settings["enabled"]
	
	if _property != null:
		if _property.get_setting(QuestObjectiveType.SETTING_CATEGORY_FILTER):
			objective_target.set_filter(_property.get_setting(QuestObjectiveType.SETTING_CATEGORY_FILTER) as String)
		if _property.get_setting(QuestObjectiveType.SETTING_MIN_VALUE):
			objective_target_quantity.min_value = _property.get_setting(QuestObjectiveType.SETTING_MIN_VALUE) as int
		if _property.get_setting(QuestObjectiveType.SETTING_MAX_VALUE):
			objective_target_quantity.max_value = _property.get_setting(QuestObjectiveType.SETTING_MAX_VALUE) as int
		
		if _property.get_default_value() != null:
			current_property = _property.get_default_value() as PPQuestObjective
			var entity = current_property.get_target_entity()
			if entity != null:
				objective_target.select.call_deferred(entity)
				objective_target_quantity.value = current_property.get_target_quantity()
			
			objective_id.text = current_property.get_objective_id()
			objective_description.text = current_property.get_description()
			objective_type.select(current_property.get_objective_type())
			hidden_check.button_pressed = current_property.is_hidden()
			hidden_check.text = "Yes" if current_property.is_hidden() else "No"
			objective_id.caret_column = current_property.get_objective_id().length()

func _setting_changed(key:String) -> void:
	if key == QuestObjectiveType.SETTING_MAX_VALUE or key == QuestObjectiveType.SETTING_MIN_VALUE or \
		key == QuestObjectiveType.SETTING_CATEGORY_FILTER:
		refresh()

func _on_update_fields_settings(property_type: String) -> void:
	if property_type == type:
		refresh()

func _on_check_button_toggled(toggled_on: bool, check_button: CheckButton) -> void:
	check_button.text = "Yes" if toggled_on else "No"
