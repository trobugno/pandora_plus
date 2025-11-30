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
	_health = 0 if not data.has("health") else data["health"]
	_mana = 0 if not data.has("mana") else data["mana"]
	_defense = 0 if not data.has("defense") else data["defense"]
	_attack = 0 if not data.has("attack") else data["attack"]
	_att_speed = 0 if not data.has("att_speed") else data["att_speed"]
	_crit_rate = 0 if not data.has("crit_rate") else data["crit_rate"]
	_crit_damage = 0 if not data.has("crit_damage") else data["crit_damage"]
	_mov_speed = 0 if not data.has("mov_speed") else data["mov_speed"]

func save_data(fields_settings: Array[Dictionary]) -> Dictionary:
	var result := {}
	var health_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Health")[0] as Dictionary
	var mana_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Mana")[0] as Dictionary
	var attack_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Attack")[0] as Dictionary
	var defense_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Defense")[0] as Dictionary
	var crit_rate_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Crit.Rate")[0] as Dictionary
	var crit_damage_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Crit.Damage")[0] as Dictionary
	var att_speed_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Att.Speed")[0] as Dictionary
	var mov_speed_field_settings := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Mov.Speed")[0] as Dictionary
	
	if health_field_settings["enabled"]:
		result["health"] = _health
	if mana_field_settings["enabled"]:
		result["mana"] = _mana
	if defense_field_settings["enabled"]:
		result["defense"] = _defense
	if attack_field_settings["enabled"]:
		result["attack"] = _attack
	if att_speed_field_settings["enabled"]:
		result["att_speed"] = _att_speed
	if crit_rate_field_settings["enabled"]:
		result["crit_rate"] = _crit_rate
	if crit_damage_field_settings["enabled"]:
		result["crit_damage"] = _crit_damage
	if mov_speed_field_settings["enabled"]:
		result["mov_speed"] = _mov_speed
	
	return result

func _to_string() -> String:
	return "<PPStats>"
