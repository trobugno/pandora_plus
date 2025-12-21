@tool
extends PandoraPropertyControl

const QuestPropertyType = preload("uid://cxc47e1iefxhv")

@onready var quest_id: LineEdit = $VBoxContainer/FirstLine/QuestID/LineEdit
@onready var quest_name: LineEdit = $VBoxContainer/FirstLine/QuestName/LineEdit

@onready var description: TextEdit = $VBoxContainer/SecondLine/Description/TextEdit
@onready var quest_type: OptionButton = $VBoxContainer/ThirdLine/QuestType/OptionButton
@onready var category: LineEdit = $VBoxContainer/ThirdLine/Category/LineEdit

@onready var level_requirement: SpinBox = $VBoxContainer/FourthLine/LevelRequirement/SpinBox
@onready var time_limit: SpinBox = $VBoxContainer/FourthLine/TimeLimit/SpinBox

@onready var quest_giver: HBoxContainer = $VBoxContainer/FifthLine/QuestGiver/EntityPicker

# Container references for visibility control
@onready var quest_id_container: VBoxContainer = $VBoxContainer/FirstLine/QuestID
@onready var quest_name_container: VBoxContainer = $VBoxContainer/FirstLine/QuestName
@onready var description_container: VBoxContainer = $VBoxContainer/SecondLine/Description
@onready var quest_type_container: VBoxContainer = $VBoxContainer/ThirdLine/QuestType
@onready var category_container: VBoxContainer = $VBoxContainer/ThirdLine/Category
@onready var level_requirement_container: VBoxContainer = $VBoxContainer/FourthLine/LevelRequirement
@onready var time_limit_container: VBoxContainer = $VBoxContainer/FourthLine/TimeLimit
@onready var quest_giver_container: VBoxContainer = $VBoxContainer/FifthLine/QuestGiver

@onready var second_line: HBoxContainer = $VBoxContainer/SecondLine
@onready var third_line: HBoxContainer = $VBoxContainer/ThirdLine
@onready var fourth_line: HBoxContainer = $VBoxContainer/FourthLine
@onready var fifth_line: HBoxContainer = $VBoxContainer/FifthLine

var current_property: PPQuest = PPQuest.new()

func _ready() -> void:
	refresh()
	Pandora.update_fields_settings.connect(_on_update_fields_settings)

	if _property != null:
		_property.setting_changed.connect(_setting_changed)
		_property.setting_cleared.connect(_setting_changed)

	# Focus signals
	quest_id.focus_entered.connect(func(): focused.emit())
	quest_id.focus_exited.connect(func(): unfocused.emit())
	quest_name.focus_entered.connect(func(): focused.emit())
	quest_name.focus_exited.connect(func(): unfocused.emit())
	description.focus_entered.connect(func(): focused.emit())
	description.focus_exited.connect(func(): unfocused.emit())
	category.focus_entered.connect(func(): focused.emit())
	category.focus_exited.connect(func(): unfocused.emit())
	level_requirement.focus_entered.connect(func(): focused.emit())
	level_requirement.focus_exited.connect(func(): unfocused.emit())
	time_limit.focus_entered.connect(func(): focused.emit())
	time_limit.focus_exited.connect(func(): unfocused.emit())
	quest_giver.focus_entered.connect(func(): focused.emit())
	quest_giver.focus_exited.connect(func(): unfocused.emit())

	# Value changed signals
	quest_id.text_changed.connect(
		func(new_text: String):
			current_property.set_quest_id(new_text)
			_set_property_value())

	quest_name.text_changed.connect(
		func(new_text: String):
			current_property.set_quest_name(new_text)
			_set_property_value())

	description.text_changed.connect(
		func():
			current_property.set_description(description.text)
			_set_property_value())

	quest_type.item_selected.connect(
		func(index: int):
			current_property.set_quest_type(index)
			_set_property_value())

	category.text_changed.connect(
		func(new_text: String):
			current_property.set_category(new_text)
			_set_property_value())

	level_requirement.value_changed.connect(
		func(value: float):
			current_property.set_level_requirement(int(value))
			_set_property_value())

	time_limit.value_changed.connect(
		func(value: float):
			current_property.set_time_limit(value)
			_set_property_value())

	quest_giver.entity_selected.connect(
		func(entity: PandoraEntity):
			if entity:
				var reference = PandoraReference.new(entity.get_entity_id(), PandoraReference.Type.ENTITY)
				current_property.set_quest_giver(reference)
			else:
				current_property.set_quest_giver(null)
			_set_property_value())

func _set_property_value() -> void:
	_property.set_default_value(current_property)
	property_value_changed.emit(current_property)

func refresh() -> void:
	if _fields_settings:
		for field_settings in _fields_settings:
			if field_settings["name"] == "Quest ID":
				quest_id_container.visible = field_settings["enabled"]
			elif field_settings["name"] == "Quest Name":
				quest_name_container.visible = field_settings["enabled"]
			elif field_settings["name"] == "Description":
				description_container.visible = field_settings["enabled"]
				second_line.visible = field_settings["enabled"]
			elif field_settings["name"] == "Quest Type":
				quest_type_container.visible = field_settings["enabled"]

				quest_type.clear()
				for option_value in field_settings["settings"]["options"]:
					quest_type.add_item(option_value)
			elif field_settings["name"] == "Category":
				category_container.visible = field_settings["enabled"]
			elif field_settings["name"] == "Level Requirement":
				level_requirement_container.visible = field_settings["enabled"]
				if field_settings["settings"].has("min_value"):
					level_requirement.min_value = field_settings["settings"]["min_value"]
				if field_settings["settings"].has("max_value"):
					level_requirement.max_value = field_settings["settings"]["max_value"]
			elif field_settings["name"] == "Time Limit":
				time_limit_container.visible = field_settings["enabled"]
				if field_settings["settings"].has("min_value"):
					time_limit.min_value = field_settings["settings"]["min_value"]
				if field_settings["settings"].has("max_value"):
					time_limit.max_value = field_settings["settings"]["max_value"]
			elif field_settings["name"] == "Quest Giver":
				quest_giver_container.visible = field_settings["enabled"]
				fifth_line.visible = field_settings["enabled"]

		# Update line visibility based on visible children
		third_line.visible = quest_type_container.visible or category_container.visible
		fourth_line.visible = level_requirement_container.visible or time_limit_container.visible

	if _property != null:
		if _property.get_setting(QuestPropertyType.SETTING_QUEST_GIVER_FILTER):
			quest_giver.set_filter(_property.get_setting(QuestPropertyType.SETTING_QUEST_GIVER_FILTER) as String)
		if _property.get_setting(QuestPropertyType.SETTING_MIN_LEVEL):
			level_requirement.min_value = _property.get_setting(QuestPropertyType.SETTING_MIN_LEVEL) as int
		if _property.get_setting(QuestPropertyType.SETTING_MAX_LEVEL):
			level_requirement.max_value = _property.get_setting(QuestPropertyType.SETTING_MAX_LEVEL) as int

		if _property.get_default_value() != null:
			current_property = _property.get_default_value() as PPQuest

			quest_id.text = current_property.get_quest_id()
			quest_name.text = current_property.get_quest_name()
			description.text = current_property.get_description()
			quest_type.select(current_property.get_quest_type())
			category.text = current_property.get_category()
			level_requirement.value = current_property.get_level_requirement()
			time_limit.value = current_property.get_time_limit()

			var giver_entity = current_property.get_quest_giver_entity()
			if giver_entity != null:
				quest_giver.select.call_deferred(giver_entity)

			quest_id.caret_column = current_property.get_quest_id().length()
			quest_name.caret_column = current_property.get_quest_name().length()
			category.caret_column = current_property.get_category().length()

func _setting_changed(key: String) -> void:
	if key == QuestPropertyType.SETTING_QUEST_GIVER_FILTER or \
		key == QuestPropertyType.SETTING_MIN_LEVEL or \
		key == QuestPropertyType.SETTING_MAX_LEVEL:
		refresh()

func _on_update_fields_settings(property_type: String) -> void:
	if property_type == type:
		refresh()
