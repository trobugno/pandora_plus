@tool
extends RefCounted
class_name PPVersionUtils
## Utility class for version parsing, comparison, and edition detection.
##
## Reads the local plugin.cfg to determine the installed version and edition
## (core or premium). Compares version strings for update checking.


const PLUGIN_CFG_PATH: String = "res://addons/pandora_plus/plugin.cfg"


## Returns the local version string from plugin.cfg (e.g. "1.0.0-premium").
static func get_local_version() -> String:
	var config := ConfigFile.new()
	var err := config.load(PLUGIN_CFG_PATH)
	if err != OK:
		push_warning("PPVersionUtils: Could not load plugin.cfg at %s" % PLUGIN_CFG_PATH)
		return ""
	return config.get_value("plugin", "version", "")


## Returns true if the installed version is Premium.
static func is_premium() -> bool:
	return get_local_version().ends_with("-premium")


## Returns "core" or "premium" based on the installed version.
static func get_edition() -> String:
	return "premium" if is_premium() else "core"


## Strips the edition suffix (-core or -premium) from a version string.
## "1.0.0-premium" -> "1.0.0"
static func strip_suffix(version: String) -> String:
	if version.ends_with("-core"):
		return version.substr(0, version.length() - 5)
	elif version.ends_with("-premium"):
		return version.substr(0, version.length() - 8)
	return version


## Converts a semantic version string to a comparable integer.
## "1.2.3" -> 10203, "2.0.0" -> 20000
## Only handles the numeric portion (MAJOR.MINOR.PATCH).
static func version_to_number(version: String) -> int:
	var clean := strip_suffix(version).strip_edges()
	var parts := clean.split(".")
	var value := 0

	if parts.size() >= 1 and parts[0].is_valid_int():
		value += parts[0].to_int() * 10000
	if parts.size() >= 2 and parts[1].is_valid_int():
		value += parts[1].to_int() * 100
	if parts.size() >= 3 and parts[2].is_valid_int():
		value += parts[2].to_int()

	return value


## Compares two version strings.
## Returns:
##   -1 if local < remote (update available)
##    0 if local == remote (up to date)
##    1 if local > remote (local is newer)
static func compare_versions(local: String, remote: String) -> int:
	var local_num := version_to_number(local)
	var remote_num := version_to_number(remote)

	if local_num < remote_num:
		return -1
	elif local_num > remote_num:
		return 1
	return 0


## Returns true if remote_version is newer than local_version.
static func is_update_available(local_version: String, remote_version: String) -> bool:
	return compare_versions(local_version, remote_version) < 0
