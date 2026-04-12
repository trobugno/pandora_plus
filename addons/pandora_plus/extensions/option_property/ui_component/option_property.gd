@tool
extends PandoraPropertyControl

const OptionType = preload("res://addons/pandora_plus/extensions/option_property/model/types/option_property.gd")

@onready var option_button: OptionButton = $HBoxContainer/OptionButton


func _ready() -> void:
	refresh()

	if _property != null:
		_property.setting_changed.connect(_setting_changed)
		_property.setting_cleared.connect(_setting_changed)

	option_button.focus_exited.connect(func(): unfocused.emit())
	option_button.focus_entered.connect(func(): focused.emit())
	option_button.item_selected.connect(
		func(idx: int):
			var selected_text = option_button.get_item_text(idx)
			_property.set_default_value(selected_text)
			property_value_changed.emit(selected_text))


func refresh() -> void:
	if _property != null:
		# Read options from per-instance property settings (lateral panel)
		var options_str = _property.get_setting(OptionType.SETTING_OPTIONS)
		if options_str is String and not options_str.is_empty():
			option_button.clear()
			var options = options_str.split(",")
			for option_value in options:
				var trimmed = option_value.strip_edges()
				if not trimmed.is_empty():
					option_button.add_item(trimmed)

		# Select current value
		var current_value = _property.get_default_value()
		if current_value is String and not current_value.is_empty():
			for idx in option_button.item_count:
				if option_button.get_item_text(idx) == current_value:
					option_button.select(idx)
					return
			# Value not found in options — add it temporarily to preserve data
			option_button.add_item(current_value)
			option_button.select(option_button.item_count - 1)


func _setting_changed(key: String) -> void:
	if key == OptionType.SETTING_OPTIONS:
		refresh.call_deferred()
