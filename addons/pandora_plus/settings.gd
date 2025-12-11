@tool
extends RefCounted
class_name PandoraPlusSettings

const CATEGORY_MAIN = "pandora_plus"
const CATEGORY_CONFIG: StringName = CATEGORY_MAIN + "/config"
const CATEGORY_CONFIG_COMBAT : StringName = CATEGORY_CONFIG + "/combat_calculator"

const COMBAT_SETTING_DEFENSE_REDUCTION_FACTOR : StringName = CATEGORY_CONFIG_COMBAT + "/defense_reduction_factor"
const COMBAT_SETTING_DEFENSE_REDUCTION_FACTOR_VALUE : float = 0.5

const COMBAT_SETTING_ARMOR_DIMINISHING_RETURNS : StringName = CATEGORY_CONFIG_COMBAT + "/armor_diminishing_returns"
const COMBAT_SETTING_ARMOR_DIMINISHING_RETURNS_VALUE: float = 100.0

const COMBAT_SETTING_CRIT_RATE_CAP : StringName = CATEGORY_CONFIG_COMBAT + "/crit_rate_cap"
const COMBAT_SETTING_CRIT_RATE_CAP_VALUE : float = 100.0

const COMBAT_SETTING_CRIT_DAMAGE_BASE : StringName = CATEGORY_CONFIG_COMBAT + "/crit_damage_base"
const COMBAT_SETTING_CRIT_DAMAGE_BASE_VALUE : float = 150.0

static func initialize() -> void:
	init_setting(
		COMBAT_SETTING_DEFENSE_REDUCTION_FACTOR,
		COMBAT_SETTING_DEFENSE_REDUCTION_FACTOR_VALUE,
		TYPE_FLOAT
	)
	init_setting(
		COMBAT_SETTING_ARMOR_DIMINISHING_RETURNS,
		COMBAT_SETTING_ARMOR_DIMINISHING_RETURNS_VALUE,
		TYPE_FLOAT
	)
	init_setting(
		COMBAT_SETTING_CRIT_RATE_CAP,
		COMBAT_SETTING_CRIT_RATE_CAP_VALUE,
		TYPE_FLOAT
	)
	init_setting(
		COMBAT_SETTING_CRIT_DAMAGE_BASE,
		COMBAT_SETTING_CRIT_DAMAGE_BASE_VALUE,
		TYPE_FLOAT
	)

static func init_setting(
	name: String,
	default: Variant,
	type := typeof(default),
	hint := PROPERTY_HINT_NONE,
	hint_string := ""
) -> void:
	if not ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, default)
	
	ProjectSettings.set_initial_value(name, default)
	
	var info = {
		"name": name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string,
	}
	ProjectSettings.add_property_info(info)
