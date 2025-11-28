class_name PPStats extends RefCounted

var _health: int
var _mana: int
var _defense: int
var _attack: int
var _att_speed : float
var _crit_rate: float
var _crit_damage: int
var _mov_speed: int

func _init(health: int, mana: int, defense: int, attack: int, att_speed: float, \
	crit_rate: float, crit_damage: int, mov_speed: int) -> void:
	_health = health
	_mana = mana
	_defense = defense
	_attack = attack
	_att_speed = att_speed
	_crit_rate = crit_rate
	_crit_damage = crit_damage
	_mov_speed = mov_speed

func load_data(data: Dictionary) -> void:
	_health = data["health"]
	_mana = data["mana"]
	_defense = data["defense"]
	_attack = data["attack"]
	_att_speed = data["att_speed"]
	_crit_rate = data["crit_rate"]
	_crit_damage = data["crit_damage"]
	_mov_speed = data["mov_speed"]

func save_data() -> Dictionary:
	return { 
		"health": _health, 
		"mana": _mana, 
		"defense": _defense,
		"attack": _attack,
		"att_speed": _att_speed, 
		"crit_rate": _crit_rate, 
		"crit_damage": _crit_damage, 
		"mov_speed": _mov_speed, 
	}

func _to_string() -> String:
	return "<PPStatus>"
