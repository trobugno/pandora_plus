@tool
extends PandoraPropertyControl

const RecipeType = preload("uid://c0ip5l60va1f8")

@onready var edit_button: Button = $VBoxContainer/FirstLine/EditIngredientsButton
@onready var ingredients_info: LineEdit = $VBoxContainer/FirstLine/IngredientsInfo
@onready var ingredients_window: Window = $IngredientsWindow
@onready var option_button: OptionButton = $VBoxContainer/SecondLine/OptionButton
@onready var result_picker: HBoxContainer = $VBoxContainer/FourthLine/EntityPicker
@onready var spin_box: SpinBox = $VBoxContainer/ThirdLine/SpinBox
@onready var waste_picker: HBoxContainer = $VBoxContainer/FifthLine/HBoxContainer/WasteEntityPicker
@onready var waste_quantity_spin_box: SpinBox = $VBoxContainer/FifthLine/HBoxContainer/WasteQuantitySpinBox

@onready var first_line: HBoxContainer = $VBoxContainer/FirstLine
@onready var second_line: HBoxContainer = $VBoxContainer/SecondLine
@onready var third_line: HBoxContainer = $VBoxContainer/ThirdLine
@onready var fourth_line: VBoxContainer = $VBoxContainer/FourthLine
@onready var fifth_line: VBoxContainer = $VBoxContainer/FifthLine

var current_property : PPRecipe = PPRecipe.new([], null, 0, "")

func _ready() -> void:
	refresh()
	Pandora.update_fields_settings.connect(_on_update_fields_settings)
	
	if _property != null:
		_property.setting_changed.connect(_setting_changed)
		_property.setting_cleared.connect(_setting_changed)
	
	edit_button.pressed.connect(func(): ingredients_window.open(current_property.get_ingredients()))
	
	ingredients_window.item_added.connect(func(item: Variant): 
		current_property.add_ingredient(item)
		_property.set_default_value(current_property)
		property_value_changed.emit(current_property)
		refresh.call_deferred()
	)
	ingredients_window.item_removed.connect(func(item: Variant): 
		current_property.remove_ingredient(item)
		_property.set_default_value(current_property)
		property_value_changed.emit(current_property)
		refresh.call_deferred()
	)
	ingredients_window.item_updated.connect(func(idx: int, item: Variant):
		current_property.update_ingredient_at(idx, item)
		_property.set_default_value(current_property)
		property_value_changed.emit(current_property)
		refresh.call_deferred()
	)
	option_button.focus_exited.connect(func(): unfocused.emit())
	option_button.focus_entered.connect(func(): focused.emit())
	option_button.item_selected.connect(
		func(idx: int):
			current_property.set_recipe_type(option_button.get_item_text(idx))
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))
	
	spin_box.focus_entered.connect(func(): focused.emit())
	spin_box.focus_exited.connect(func(): unfocused.emit())
	spin_box.value_changed.connect(
		func(value: float):
			current_property.set_crafting_time(value)
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))
	
	result_picker.focus_exited.connect(func(): unfocused.emit())
	result_picker.focus_entered.connect(func(): focused.emit())
	result_picker.entity_selected.connect(
		func(entity: PandoraEntity):
			current_property.set_result(entity)
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))

	waste_picker.focus_exited.connect(func(): unfocused.emit())
	waste_picker.focus_entered.connect(func(): focused.emit())
	waste_picker.entity_selected.connect(_on_waste_entity_selected)
	waste_picker.entity_cleared.connect(_on_waste_entity_cleared)

	waste_quantity_spin_box.focus_entered.connect(func(): focused.emit())
	waste_quantity_spin_box.focus_exited.connect(func(): unfocused.emit())
	waste_quantity_spin_box.value_changed.connect(_on_waste_quantity_changed)

func _on_waste_entity_selected(entity: PandoraEntity) -> void:
	var quantity = int(waste_quantity_spin_box.value)
	current_property.set_waste(PPIngredient.new(entity, quantity))
	_property.set_default_value(current_property)
	property_value_changed.emit(current_property)

func _on_waste_entity_cleared() -> void:
	current_property.set_waste(null)
	_property.set_default_value(current_property)
	property_value_changed.emit(current_property)

func _on_waste_quantity_changed(value: float) -> void:
	var waste = current_property.get_waste()
	if waste != null:
		waste.set_quantity(int(value))
		_property.set_default_value(current_property)
		property_value_changed.emit(current_property)

func refresh() -> void:
	if _fields_settings:
		for field_settings in _fields_settings:
			if field_settings["name"] == "Result":
				fourth_line.visible = field_settings["enabled"]
			elif field_settings["name"] == "Ingredients":
				first_line.visible = field_settings["enabled"]
			elif field_settings["name"] == "Recipe Type":
				second_line.visible = field_settings["enabled"]
				option_button.clear()
				for option_value in field_settings["settings"]["options"]:
					option_button.add_item(option_value)
			elif field_settings["name"] == "Crafting Time":
				third_line.visible = field_settings["enabled"]
			elif field_settings["name"] == "Waste Item":
				fifth_line.visible = field_settings["enabled"]

	if _property != null:
		if _property.get_setting(RecipeType.SETTING_RESULT_FILTER):
			result_picker.set_filter(_property.get_setting(RecipeType.SETTING_RESULT_FILTER) as String)
		if _property.get_setting(RecipeType.SETTING_INGREDIENTS_FILTER):
			waste_picker.set_filter(_property.get_setting(RecipeType.SETTING_INGREDIENTS_FILTER) as String)
		if _property.get_setting(RecipeType.SETTING_MIN_VALUE):
			spin_box.min_value = _property.get_setting(RecipeType.SETTING_MIN_VALUE) as float
		if _property.get_setting(RecipeType.SETTING_MAX_VALUE):
			spin_box.max_value = _property.get_setting(RecipeType.SETTING_MAX_VALUE) as float

		if _property.get_default_value() != null:
			current_property = _property.get_default_value() as PPRecipe
			var entity = current_property.get_result()
			ingredients_info.text = str(current_property.get_ingredients().size()) + " Items"
			spin_box.value = current_property.get_crafting_time()

			for idx in option_button.item_count:
				if option_button.get_item_text(idx) == current_property.get_recipe_type():
					option_button.select(idx)

			if entity != null:
				result_picker.select.call_deferred(entity)

			# Refresh waste UI
			var waste = current_property.get_waste()
			if waste != null:
				var waste_entity = waste.get_item_entity()
				if waste_entity != null:
					waste_picker.select.call_deferred(waste_entity)
				waste_quantity_spin_box.value = waste.get_quantity()
			else:
				waste_picker.clear.call_deferred()
				waste_quantity_spin_box.value = 1

func _setting_changed(key:String) -> void:
	if key == RecipeType.SETTING_RESULT_FILTER || key == RecipeType.SETTING_INGREDIENTS_FILTER || key == RecipeType.SETTING_MAX_VALUE || key == RecipeType.SETTING_MIN_VALUE:
		refresh()

func _on_update_fields_settings(property_type: String) -> void:
	if property_type == type:
		refresh()
