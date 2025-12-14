class_name PPStatModifier extends Resource

enum ModifierType {
	FLAT,
	ADDITIVE,
	MULTIPLICATIVE
}

@export_enum("health", "mana", "attack", "defense", "crit_rate", "crit_damage", "att_speed", "mov_speed") var stat_name : String = ""

@export var type : ModifierType = ModifierType.FLAT

## Modifier value
## - FLAT: absolute value (10 = +10)
## - ADDITIVE: percentage (20 = +20%)
## - MULTIPLICATIVE: multiplier (1.5 = x1.5)
@export var value : float = 0.0

## Duration in seconds (-1 = permanent)
@export var duration: float = 0.0

## Es. poison_effect, etc.
@export var source: String = ""

## Optional tag to categorize
@export var tag: String = ""

## Can be overriden by other modifier with same source
@export var stackable: bool = true

## Application priority (greater = applied before others)
@export var priority: int = 0

func _init(
	p_stat_name: String = "",
	p_type: ModifierType = ModifierType.FLAT,
	p_value: float = 0.0,
	p_duration: float = 0.0,
	p_source: String = "",
	p_tag: String = ""
) -> void:
	stat_name = p_stat_name
	type = p_type
	value = p_value
	duration = p_duration
	source = p_source
	tag = p_tag

static func create_flat(stat: String, amount: float, src: String = "", dur: float = 0.0) -> PPStatModifier:
	return PPStatModifier.new(stat, ModifierType.FLAT, amount, dur, src)

static func create_percent(stat: String, percent: float, src: String = "", dur: float = 0.0) -> PPStatModifier:
	return PPStatModifier.new(stat, ModifierType.ADDITIVE, percent, dur, src)

static func create_multiplier(stat: String, multiplier: float, src: String = "", dur: float = 0.0) -> PPStatModifier:
	return PPStatModifier.new(stat, ModifierType.MULTIPLICATIVE, multiplier, dur, src)

func can_stack_with(other: PPStatModifier) -> bool:
	if not stackable or not other.stackable:
		return false
	
	if source == other.source and source != "":
		return false
	
	return true

func to_dict() -> Dictionary:
	return {
		"stat_name": stat_name,
		"type": type,
		"value": value,
		"duration": duration,
		"source": source,
		"tag": tag,
		"stackable": stackable,
		"priority": priority
	}

static func from_dict(data: Dictionary) -> PPStatModifier:
	var mod = PPStatModifier.new()
	mod.stat_name = data.get("stat_name", "")
	mod.type = data.get("type", ModifierType.FLAT)
	mod.value = data.get("value", 0.0)
	mod.duration = data.get("duration", 0.0)
	mod.source = data.get("source", "")
	mod.tag = data.get("tag", "")
	mod.stackable = data.get("stackable", true)
	mod.priority = data.get("priority", 0)
	return mod

func _to_string() -> String:
	var type_str = ["FLAT", "ADDITIVE", "MULTIPLICATIVE"][type]
	var duration_str = "permanent" if duration == 0 else str(duration) + "s"
	return "PPStatModifier(%s, %s, %s, %s, %s)" % [stat_name, type_str, value, source, duration_str]
