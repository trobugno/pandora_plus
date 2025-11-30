class_name PPStatusEffect extends RefCounted

var _status_ID : String
var _status_key : int
var _description : String
var _duration : float

var _damage_in_percentage : bool
var _damage_per_tick : float
var _ticks : int

func _init(status_ID: String, status_key: int, description: String, duration: float, \
	damage_in_percentage: bool, damage_per_tick: float, ticks: int) -> void:
	_status_ID = status_ID
	_status_key = status_key
	_description = description
	_duration = duration
	_damage_in_percentage = damage_in_percentage
	_damage_per_tick = damage_per_tick
	_ticks = ticks

func load_data(data: Dictionary) -> void:
	_status_ID = "" if not data.has("status_ID") else data["status_ID"]
	_status_key = "" if not data.has("status_key") else data["status_key"]
	_description = "" if not data.has("description") else data["description"]
	_duration = 0 if not data.has("duration") else data["duration"]
	_damage_in_percentage = false if not data.has("damage_in_percentage") else data["damage_in_percentage"]
	_damage_per_tick = 0 if not data.has("damage_per_tick") else data["damage_per_tick"]
	_ticks = 0 if not data.has("ticks") else data["ticks"]

func save_data(fields_settings: Array[Dictionary]) -> Dictionary:
	var result := {}
	var id_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Status ID")[0] as Dictionary
	var key_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Status Key")[0] as Dictionary
	var description_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Status Description")[0] as Dictionary
	var duration_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Status Duration")[0] as Dictionary
	var ticks_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Ticks")[0] as Dictionary
	var damage_per_tick_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Damage per Tick")[0] as Dictionary
	
	if id_field_settings["enabled"]:
		result["status_ID"] = _status_ID
	if key_field_settings["enabled"]:
		result["status_key"] = _status_key
	if description_field_settings["enabled"]:
		result["description"] = _description
	if duration_field_settings["enabled"]:
		result["duration"] = _duration
	if damage_per_tick_field_settings["enabled"]:
		result["damage_in_percentage"] = _damage_in_percentage
	if damage_per_tick_field_settings["enabled"]:
		result["damage_per_tick"] = _damage_per_tick
	if ticks_field_settings["enabled"]:
		result["ticks"] = _ticks
	
	return result

func _to_string() -> String:
	return "<PPStatusEffect [ " + _status_ID + " ]>"
