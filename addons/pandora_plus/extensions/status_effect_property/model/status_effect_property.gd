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
	_status_ID = data["status_ID"]
	_status_key = data["status_key"]
	_description = data["description"]
	_duration = data["duration"]
	_damage_in_percentage = data["damage_in_percentage"]
	_damage_per_tick = data["damage_per_tick"]
	_ticks = data["ticks"]

func save_data() -> Dictionary:
	return { 
		"status_ID": _status_ID, 
		"status_key": _status_key, 
		"description": _description, 
		"duration": _duration,
		"damage_in_percentage": _damage_in_percentage, 
		"damage_per_tick": _damage_per_tick,
		"ticks": _ticks
	}

func _to_string() -> String:
	return "<PPStatusEffect [ " + _status_ID + " ]>"
