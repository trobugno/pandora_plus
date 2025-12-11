extends Node

var DEFENSE_REDUCTION_FACTOR : float
var ARMOR_DIMINISHING_RETURNS : float
var CRIT_DAMAGE_BASE : float
var CRIT_RATE_CAP : float

func _ready() -> void:
	ProjectSettings.settings_changed.connect(_on_settings_changed)
	_on_settings_changed()

func _on_settings_changed() -> void:
	if ProjectSettings.has_setting(PandoraPlusSettings.COMBAT_SETTING_DEFENSE_REDUCTION_FACTOR):
		DEFENSE_REDUCTION_FACTOR = ProjectSettings.get_setting(PandoraPlusSettings.COMBAT_SETTING_DEFENSE_REDUCTION_FACTOR)
	if ProjectSettings.has_setting(PandoraPlusSettings.COMBAT_SETTING_ARMOR_DIMINISHING_RETURNS):
		ARMOR_DIMINISHING_RETURNS = ProjectSettings.get_setting(PandoraPlusSettings.COMBAT_SETTING_ARMOR_DIMINISHING_RETURNS)
	if ProjectSettings.has_setting(PandoraPlusSettings.COMBAT_SETTING_CRIT_DAMAGE_BASE):
		CRIT_DAMAGE_BASE = ProjectSettings.get_setting(PandoraPlusSettings.COMBAT_SETTING_CRIT_DAMAGE_BASE)
	if ProjectSettings.has_setting(PandoraPlusSettings.COMBAT_SETTING_CRIT_RATE_CAP):
		CRIT_RATE_CAP = ProjectSettings.get_setting(PandoraPlusSettings.COMBAT_SETTING_CRIT_RATE_CAP)

func calculate_physical_damage(attacker_stats: PPRuntimeStats, attacked_stats: PPRuntimeStats) -> float:
	var attack = attacker_stats.get_effective_stat("attack")
	var defense = attacked_stats.get_effective_stat("defense")
	var damage_reduction = _calculate_armor_reduction(defense)
	var final_damage = attack * (1.0 - damage_reduction)
	return max(1, final_damage)

func _calculate_armor_reduction(defense: float) -> float:
	# Example if ARMOR_DIMINISHING_RETURNS is 100
	# 0 defense: 0% reduction
	# 100 defense: 50% reduction
	# 200 defense: 66.6% reduction
	# 400 defense: 80% reduction
	return defense / (defense + ARMOR_DIMINISHING_RETURNS)

func roll_critical_hit(attacker_stats: PPRuntimeStats) -> bool:
	var crit_rate = attacker_stats.get_effective_stat("crit_rate")
	crit_rate = min(crit_rate, CRIT_RATE_CAP)
	return randf() * 100.0 <= crit_rate

func calculate_critical_damage(base_damage: float, attacker_stats: PPRuntimeStats) -> float:
	var crit_damage_multiplier = attacker_stats.get_effective_stat("crit_damage")
	
	if crit_damage_multiplier <= 0:
		crit_damage_multiplier = CRIT_DAMAGE_BASE
	
	return base_damage * (crit_damage_multiplier / 100.0)

func calculate_damage(attacker_stats: PPRuntimeStats, attacked_stats: PPRuntimeStats) -> float:
	var base_damage := calculate_physical_damage(attacker_stats, attacked_stats)
	var is_crit = roll_critical_hit(attacker_stats)
	
	if is_crit:
		return calculate_critical_damage(base_damage, attacker_stats)
	return base_damage
