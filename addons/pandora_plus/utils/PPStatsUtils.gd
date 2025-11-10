extends Node

func calculate_physical_damage(attacker_stats: Dictionary, attacked_stats: Dictionary) -> void:
	var attack = attacker_stats.get("attack", 0)
	var defense = attacked_stats.get("defense", 0)
	return max(1, attack - defense)
