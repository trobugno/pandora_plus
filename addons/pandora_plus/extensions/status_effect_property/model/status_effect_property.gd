class_name PPStatusEffect extends RefCounted

var _status_ID : String
var _status_key : int
var _description : String
var _duration : float

var _value_in_percentage : bool
var _value_per_tick : float
var _ticks : int
var _tick_type : int

func _init(status_ID: String, status_key: int, description: String, duration: float, \
	value_in_percentage: bool, value_per_tick: float, ticks: int, tick_type: int) -> void:
	_status_ID = status_ID
	_status_key = status_key
	_description = description
	_duration = duration
	_value_in_percentage = value_in_percentage
	_value_per_tick = value_per_tick
	_ticks = ticks
	_tick_type = tick_type

func load_data(data: Dictionary) -> void:
	_status_ID = "" if not data.has("status_ID") else data["status_ID"]
	_status_key = -1 if not data.has("status_key") else data["status_key"]
	_description = "" if not data.has("description") else data["description"]
	_duration = 0 if not data.has("duration") else data["duration"]
	_value_in_percentage = false if not data.has("value_in_percentage") else data["value_in_percentage"]
	_value_per_tick = 0 if not data.has("value_per_tick") else data["value_per_tick"]
	_ticks = 0 if not data.has("ticks") else data["ticks"]
	_tick_type = -1 if not data.has("tick_type") else data["tick_type"]

func save_data(fields_settings: Array[Dictionary]) -> Dictionary:
	var result := {}

	# Safe field lookup
	var id_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Status ID")
	var key_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Status Key")
	var description_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Status Description")
	var duration_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Status Duration")
	var ticks_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Ticks")
	var value_per_tick_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Value per Tick")
	var tick_type_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Tick Type")

	if id_field_array.size() > 0:
		var id_field_settings := id_field_array[0] as Dictionary
		if id_field_settings["enabled"]:
			result["status_ID"] = _status_ID

	if key_field_array.size() > 0:
		var key_field_settings := key_field_array[0] as Dictionary
		if key_field_settings["enabled"]:
			result["status_key"] = _status_key

	if description_field_array.size() > 0:
		var description_field_settings := description_field_array[0] as Dictionary
		if description_field_settings["enabled"]:
			result["description"] = _description

	if duration_field_array.size() > 0:
		var duration_field_settings := duration_field_array[0] as Dictionary
		if duration_field_settings["enabled"]:
			result["duration"] = _duration

	if value_per_tick_field_array.size() > 0:
		var value_per_tick_field_settings := value_per_tick_field_array[0] as Dictionary
		if value_per_tick_field_settings["enabled"]:
			result["value_in_percentage"] = _value_in_percentage
			result["value_per_tick"] = _value_per_tick

	if ticks_field_array.size() > 0:
		var ticks_field_settings := ticks_field_array[0] as Dictionary
		if ticks_field_settings["enabled"]:
			result["ticks"] = _ticks

	if tick_type_field_array.size() > 0:
		var tick_type_field_settings := tick_type_field_array[0] as Dictionary
		if tick_type_field_settings["enabled"]:
			result["tick_type"] = _tick_type

	return result

func _to_string() -> String:
	return "<PPStatusEffect [ " + _status_ID + " ]>"
