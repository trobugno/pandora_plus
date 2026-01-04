@tool
extends PandoraPropertyControl

const QuestRewardType = preload("uid://ig8sh17ax6op")

@onready var reward_name: LineEdit = $VBoxContainer/FirstLine/RewardName/LineEdit
@onready var reward_type: OptionButton = $VBoxContainer/FirstLine/RewardType/OptionButton

@onready var reward_entity: HBoxContainer = $VBoxContainer/SecondLine/RewardEntity/EntityPicker
@onready var quantity: SpinBox = $VBoxContainer/SecondLine/Quantity/SpinBox

@onready var currency_amount: SpinBox = $VBoxContainer/ThirdLine/CurrencyAmount/SpinBox

# Container references for visibility control
@onready var reward_name_container: VBoxContainer = $VBoxContainer/FirstLine/RewardName
@onready var reward_type_container: VBoxContainer = $VBoxContainer/FirstLine/RewardType

@onready var second_line: HBoxContainer = $VBoxContainer/SecondLine
@onready var reward_entity_container: VBoxContainer = $VBoxContainer/SecondLine/RewardEntity
@onready var quantity_container: VBoxContainer = $VBoxContainer/SecondLine/Quantity

@onready var third_line: HBoxContainer = $VBoxContainer/ThirdLine
@onready var currency_amount_container: VBoxContainer = $VBoxContainer/ThirdLine/CurrencyAmount

var current_property: PPQuestReward = PPQuestReward.new()

func _ready() -> void:
	refresh()
	Pandora.update_fields_settings.connect(_on_update_fields_settings)

	if _property != null:
		_property.setting_changed.connect(_setting_changed)
		_property.setting_cleared.connect(_setting_changed)

	# Focus signals
	reward_name.focus_entered.connect(func(): focused.emit())
	reward_name.focus_exited.connect(func(): unfocused.emit())
	reward_entity.focus_entered.connect(func(): focused.emit())
	reward_entity.focus_exited.connect(func(): unfocused.emit())
	quantity.focus_entered.connect(func(): focused.emit())
	quantity.focus_exited.connect(func(): unfocused.emit())
	currency_amount.focus_entered.connect(func(): focused.emit())
	currency_amount.focus_exited.connect(func(): unfocused.emit())

	# Value changed signals
	reward_name.text_changed.connect(
		func(new_text: String):
			current_property.set_reward_name(new_text)
			_set_property_value())

	reward_type.item_selected.connect(
		func(index: int):
			current_property.set_reward_type(index)
			_update_fields_visibility(index)
			_set_property_value())

	reward_entity.entity_selected.connect(
		func(entity: PandoraEntity):
			if entity:
				var reference = PandoraReference.new(entity.get_entity_id(), PandoraReference.Type.ENTITY)
				current_property.set_reward_entity_reference(reference)
			else:
				current_property.set_reward_entity_reference(null)
			_set_property_value())

	quantity.value_changed.connect(
		func(value: float):
			current_property.set_quantity(int(value))
			_set_property_value())

	currency_amount.value_changed.connect(
		func(value: float):
			current_property.set_currency_amount(int(value))
			_set_property_value())

func _set_property_value() -> void:
	_property.set_default_value(current_property)
	property_value_changed.emit(current_property)

func refresh() -> void:
	if _fields_settings:
		for field_settings in _fields_settings:
			if field_settings["name"] == "Reward Name":
				reward_name_container.visible = field_settings["enabled"]
			elif field_settings["name"] == "Reward Type":
				reward_type_container.visible = field_settings["enabled"]

				reward_type.clear()
				for option_value in field_settings["settings"]["options"]:
					reward_type.add_item(option_value)
			elif field_settings["name"] == "Reward Entity":
				# Visibility handled by _update_fields_visibility
				pass
			elif field_settings["name"] == "Quantity":
				# Visibility handled by _update_fields_visibility
				if field_settings["settings"].has("min_value"):
					quantity.min_value = field_settings["settings"]["min_value"]
				if field_settings["settings"].has("max_value"):
					quantity.max_value = field_settings["settings"]["max_value"]
			elif field_settings["name"] == "Currency Amount":
				if field_settings["settings"].has("min_value"):
					currency_amount.min_value = field_settings["settings"]["min_value"]
				if field_settings["settings"].has("max_value"):
					currency_amount.max_value = field_settings["settings"]["max_value"]

	if _property != null:
		if _property.get_setting(QuestRewardType.SETTING_REWARD_ENTITY_FILTER):
			reward_entity.set_filter(_property.get_setting(QuestRewardType.SETTING_REWARD_ENTITY_FILTER) as String)
		if _property.get_setting(QuestRewardType.SETTING_MIN_QUANTITY):
			quantity.min_value = _property.get_setting(QuestRewardType.SETTING_MIN_QUANTITY) as int
		if _property.get_setting(QuestRewardType.SETTING_MAX_QUANTITY):
			quantity.max_value = _property.get_setting(QuestRewardType.SETTING_MAX_QUANTITY) as int
		if _property.get_setting(QuestRewardType.SETTING_MIN_CURRENCY):
			currency_amount.min_value = _property.get_setting(QuestRewardType.SETTING_MIN_CURRENCY) as int
		if _property.get_setting(QuestRewardType.SETTING_MAX_CURRENCY):
			currency_amount.max_value = _property.get_setting(QuestRewardType.SETTING_MAX_CURRENCY) as int

		if _property.get_default_value() != null:
			current_property = _property.get_default_value() as PPQuestReward

			reward_name.text = current_property.get_reward_name()
			reward_type.select(current_property.get_reward_type())

			var entity = current_property.get_reward_entity()
			if entity != null:
				reward_entity.select.call_deferred(entity)

			quantity.value = current_property.get_quantity()
			currency_amount.value = current_property.get_currency_amount()

			reward_name.caret_column = current_property.get_reward_name().length()

			_update_fields_visibility(current_property.get_reward_type())

func _update_fields_visibility(reward_type_index: int) -> void:
	# Hide all conditional fields first
	second_line.visible = false
	third_line.visible = false

	reward_entity_container.visible = false
	quantity_container.visible = false

	# Show fields based on reward type (CORE only: ITEM, CURRENCY)
	match reward_type_index:
		0: # ITEM
			second_line.visible = true
			reward_entity_container.visible = true
			quantity_container.visible = true
		1: # CURRENCY
			third_line.visible = true

func _setting_changed(key: String) -> void:
	if key == QuestRewardType.SETTING_MAX_QUANTITY or key == QuestRewardType.SETTING_MIN_QUANTITY or \
		key == QuestRewardType.SETTING_REWARD_ENTITY_FILTER or key == QuestRewardType.SETTING_MIN_CURRENCY or \
		key == QuestRewardType.SETTING_MAX_CURRENCY:
		refresh()

func _on_update_fields_settings(property_type: String) -> void:
	if property_type == type:
		refresh()
