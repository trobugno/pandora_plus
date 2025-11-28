@tool
extends PandoraPropertyControl

const RecipeType = preload("uid://c0ip5l60va1f8")

@onready var edit_button: Button = $VBoxContainer/FirstLine/EditIngredientsButton
@onready var ingredients_info: LineEdit = $VBoxContainer/FirstLine/IngredientsInfo
@onready var ingredients_window: Window = $VBoxContainer/FirstLine/IngredientsWindow
@onready var option_button: OptionButton = $VBoxContainer/SecondLine/OptionButton
@onready var result_picker: HBoxContainer = $VBoxContainer/ThirdLine/EntityPicker
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
	
	result_picker.focus_exited.connect(func(): unfocused.emit())
	result_picker.focus_entered.connect(func(): focused.emit())
	result_picker.entity_selected.connect(
		func(entity: PandoraEntity):
			current_property.set_result(entity)
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))

func refresh() -> void:
	if _property != null:
		result_picker.set_filter(_property.get_setting(RecipeType.SETTING_CATEGORY_FILTER) as String)
		if _property.get_default_value() != null:
			current_property = _property.get_default_value() as PPRecipe
			var entity = current_property.get_result()
			ingredients_info.text = str(current_property.get_ingredients().size()) + " Items"
			
			for idx in option_button.item_count:
				if option_button.get_item_text(idx) == current_property.get_recipe_type():
					option_button.select(idx)
			
			if entity != null:
				result_picker.select.call_deferred(entity)

func _setting_changed(key:String) -> void:
	if key == RecipeType.SETTING_CATEGORY_FILTER:
		refresh()

func _on_update_fields_settings(property_type: String) -> void:
	if property_type == type:
		refresh()
