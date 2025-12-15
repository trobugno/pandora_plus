class_name PPRuntimeStats extends Resource

signal stats_changed(stat_name: String, old_value: Variant, new_value: Variant)
signal modifier_added(modifier: PPStatModifier)
signal modifier_removed(modifier: PPStatModifier)

@export var base_stats_data : Dictionary = {}

var _active_modifiers: Array[PPStatModifier] = []
var _cached_stats: Dictionary = {}
var _cache_dirty: bool = true
var _base_stats_instance: PPStats = null

func _init(p_base_stats: Variant = null) -> void:
	if p_base_stats is PPStats:
		var extension_configuration := PandoraSettings.find_extension_configuration_property("stats_property")
		var fields_settings : Array[Dictionary]
		fields_settings.assign(extension_configuration["fields"] as Array)
		base_stats_data = p_base_stats.save_data(fields_settings)
		_base_stats_instance = p_base_stats
	elif p_base_stats is Dictionary:
		base_stats_data = p_base_stats
	else:
		_create_default_stats_data()

func get_effective_stat(stat_name: String) -> float:
	if _cache_dirty:
		_recalculate_all_stats()
	
	return _cached_stats.get(stat_name, _get_base_stat_value(stat_name))

func add_modifier(modifier: PPStatModifier) -> void:
	if not modifier:
		push_error("Attempt to add a null modifier")
		return
	
	_active_modifiers.append(modifier)
	_cache_dirty = true
	modifier_added.emit(modifier)
	
	#if modifier.duration > 0:
		#await get_tree().create_timer(modifier.duration).timeout
		#remove_modifier(modifier)

func remove_modifier(modifier: PPStatModifier) -> void:
	var index = _active_modifiers.find(modifier)
	if index >= 0:
		_active_modifiers.remove_at(index)
		_cache_dirty = true
		modifier_removed.emit(modifier)

func remove_modifiers_by_source(source: String) -> void:
	var to_remove: Array[PPStatModifier] = []
	
	for mod in _active_modifiers:
		if mod.source == source:
			to_remove.append(mod)
	
	for mod in to_remove:
		remove_modifier(mod)

func get_modifiers_for_stat(stat_name: String) -> Array[PPStatModifier]:
	var result: Array[PPStatModifier] = []
	
	for mod in _active_modifiers:
		if mod.stat_name == stat_name:
			result.append(mod)
	
	return result

func clear_all_modifiers() -> void:
	_active_modifiers.clear()
	_cache_dirty = true

func _recalculate_all_stats() -> void:
	_cached_stats.clear()
	
	var stats_to_calc = ["health", "mana", "defense", "attack", "att_speed", "crit_rate", "crit_damage", "mov_speed"]
	
	for stat_name in stats_to_calc:
		_cached_stats[stat_name] = _calculate_stat(stat_name)
	
	_cache_dirty = false

func _calculate_stat(stat_name: String) -> float:
	var base_value = _get_base_stat_value(stat_name)
	
	var flat_mods: Array[PPStatModifier] = []
	var additive_mods: Array[PPStatModifier] = []
	var multiplicative_mods: Array[PPStatModifier] = []
	
	for mod in get_modifiers_for_stat(stat_name):
		match mod.type:
			PPStatModifier.ModifierType.FLAT:
				flat_mods.append(mod)
			PPStatModifier.ModifierType.ADDITIVE:
				additive_mods.append(mod)
			PPStatModifier.ModifierType.MULTIPLICATIVE:
				multiplicative_mods.append(mod)
	
	var result = base_value
	
	for mod in flat_mods:
		result += mod.value
	
	var additive_sum = 0.0
	for mod in additive_mods:
		additive_sum += mod.value
	result += base_value * (additive_sum / 100.0)
	
	for mod in multiplicative_mods:
		result *= mod.value
	
	return max(0, result)


func _get_base_stat_value(stat_name: String) -> float:
	return base_stats_data.get(stat_name, 0.0)


func _set_base_stat_value(stat_name: String, value: float) -> void:
	base_stats_data[stat_name] = value
	# Aggiorna anche l'istanza se presente
	if _base_stats_instance and _base_stats_instance.has(stat_name):
		_base_stats_instance.set(stat_name, value)

func _create_default_stats_data() -> Dictionary:
	return {
		"health": 100.0,
		"mana": 100.0,
		"defense": 5.0,
		"attack": 5.0,
		"att_speed": 1.0,
		"crit_rate": 0.0,
		"crit_damage": 0.0,
		"mov_speed": 10.0
	}

func to_dict() -> Dictionary:
	return {
		"base_stats_data": base_stats_data,
		"active_modifiers": _active_modifiers.map(func(m): return m.to_dict())
	}

static func from_dict(data: Dictionary) -> PPRuntimeStats:
	var runtime = PPRuntimeStats.new(data.get("base_stats_data", {}))
	
	for mod_data in data.get("active_modifiers", []):
		runtime._active_modifiers.append(PPStatModifier.from_dict(mod_data))
	
	runtime._cache_dirty = true
	return runtime
