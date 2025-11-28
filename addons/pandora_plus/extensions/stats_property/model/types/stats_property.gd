extends PandoraPropertyType

func _init() -> void:
	super("stats_property", {}, null, "res://addons/pandora_plus/assets/icons/icon_star.png")

func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var health = variant["health"]
		var mana = variant["mana"]
		var defense = variant["defense"]
		var attack = variant["attack"]
		var att_speed = variant["att_speed"]
		var crit_rate = variant["crit_rate"]
		var crit_damage = variant["crit_damage"]
		var mov_speed = variant["mov_speed"]
		return PPStats.new(health, mana, defense, attack, att_speed, crit_rate, crit_damage, mov_speed)
	return variant

func write_value(variant: Variant) -> Variant:
	if variant is PPStats:
		return variant.save_data()
	return variant

func is_valid(variant: Variant) -> bool:
	return variant is PPStats
