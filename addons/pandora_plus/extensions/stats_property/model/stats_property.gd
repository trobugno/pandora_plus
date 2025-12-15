class_name PPStats extends RefCounted

var _health: int
var _mana: int
var _defense: int
var _attack: int
var _att_speed : float
var _crit_rate: float
var _crit_damage: float
var _mov_speed: int

func _init(health: int = -1, mana: int = -1, defense: int = -1, attack: int = -1, att_speed: float = -1.0, \
	crit_rate: float = -1.0, crit_damage: float = -1.0, mov_speed: int = -1) -> void:
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

	# Safe field lookup
	var health_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Health")
	var mana_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Mana")
	var attack_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Attack")
	var defense_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Defense")
	var crit_rate_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Crit.Rate")
	var crit_damage_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Crit.Damage")
	var att_speed_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Att.Speed")
	var mov_speed_field_array := fields_settings.filter(func(dic: Dictionary): return dic["name"] == "Mov.Speed")

	if health_field_array.size() > 0:
		var health_field_settings := health_field_array[0] as Dictionary
		if health_field_settings["enabled"]:
			result["health"] = _health

	if mana_field_array.size() > 0:
		var mana_field_settings := mana_field_array[0] as Dictionary
		if mana_field_settings["enabled"]:
			result["mana"] = _mana

	if attack_field_array.size() > 0:
		var attack_field_settings := attack_field_array[0] as Dictionary
		if attack_field_settings["enabled"]:
			result["attack"] = _attack

	if defense_field_array.size() > 0:
		var defense_field_settings := defense_field_array[0] as Dictionary
		if defense_field_settings["enabled"]:
			result["defense"] = _defense

	if crit_rate_field_array.size() > 0:
		var crit_rate_field_settings := crit_rate_field_array[0] as Dictionary
		if crit_rate_field_settings["enabled"]:
			result["crit_rate"] = _crit_rate

	if crit_damage_field_array.size() > 0:
		var crit_damage_field_settings := crit_damage_field_array[0] as Dictionary
		if crit_damage_field_settings["enabled"]:
			result["crit_damage"] = _crit_damage

	if att_speed_field_array.size() > 0:
		var att_speed_field_settings := att_speed_field_array[0] as Dictionary
		if att_speed_field_settings["enabled"]:
			result["att_speed"] = _att_speed

	if mov_speed_field_array.size() > 0:
		var mov_speed_field_settings := mov_speed_field_array[0] as Dictionary
		if mov_speed_field_settings["enabled"]:
			result["mov_speed"] = _mov_speed

	return result

func _to_string() -> String:
	return "<PPStats>"
