@tool
extends RefCounted
class_name PPUpdateConfig
## Manages persistent update preferences stored in user:// config files.
##
## Settings are stored outside project.godot to avoid VCS issues:
## - user://pandora_plus_update.cfg  — update check state (timestamps, skipped versions)
## - user://pandora_plus_auth.cfg    — OAuth token for Premium (sensitive)


const UPDATE_CONFIG_PATH: String = "user://pandora_plus_update.cfg"
const AUTH_CONFIG_PATH: String = "user://pandora_plus_auth.cfg"

# Config file sections and keys
const SECTION_UPDATE: String = "update"
const KEY_LAST_CHECK: String = "last_check_timestamp"
const KEY_SKIPPED_VERSION: String = "skipped_version"
const KEY_REMIND_LATER: String = "remind_later_timestamp"

const SECTION_AUTH: String = "auth"
const KEY_ITCHIO_TOKEN: String = "itchio_token"

# Remind me later = postpone for 24 hours
const REMIND_LATER_DELAY_SECONDS: int = 86400


# ---- Update State ----

## Returns true if enough time has elapsed since the last check (based on ProjectSettings interval).
static func should_check_now() -> bool:
	var interval_hours: int = ProjectSettings.get_setting(
		PandoraPlusSettings.UPDATE_SETTING_CHECK_INTERVAL,
		PandoraPlusSettings.UPDATE_SETTING_CHECK_INTERVAL_VALUE
	)
	var auto_check: bool = ProjectSettings.get_setting(
		PandoraPlusSettings.UPDATE_SETTING_AUTO_CHECK,
		PandoraPlusSettings.UPDATE_SETTING_AUTO_CHECK_VALUE
	)
	if not auto_check:
		return false

	var last_check := _get_int(SECTION_UPDATE, KEY_LAST_CHECK, 0)
	var now := int(Time.get_unix_time_from_system())
	var interval_seconds := interval_hours * 3600

	return (now - last_check) >= interval_seconds


## Records the current time as the last check timestamp.
static func mark_checked() -> void:
	var now := int(Time.get_unix_time_from_system())
	_set_value(UPDATE_CONFIG_PATH, SECTION_UPDATE, KEY_LAST_CHECK, now)


## Marks a version as skipped (user chose "Skip This Version").
static func skip_version(version: String) -> void:
	_set_value(UPDATE_CONFIG_PATH, SECTION_UPDATE, KEY_SKIPPED_VERSION, version)


## Returns true if the given version was previously skipped by the user.
static func is_version_skipped(version: String) -> bool:
	var skipped := _get_string(SECTION_UPDATE, KEY_SKIPPED_VERSION, "")
	return skipped == version


## Records a "Remind Me Later" timestamp.
static func remind_later() -> void:
	var now := int(Time.get_unix_time_from_system())
	_set_value(UPDATE_CONFIG_PATH, SECTION_UPDATE, KEY_REMIND_LATER, now)


## Returns true if the remind-later delay has expired (or was never set).
static func should_remind() -> bool:
	var remind_time := _get_int(SECTION_UPDATE, KEY_REMIND_LATER, 0)
	if remind_time == 0:
		return true
	var now := int(Time.get_unix_time_from_system())
	return (now - remind_time) >= REMIND_LATER_DELAY_SECONDS


# ---- OAuth Token ----

## Returns the stored itch.io OAuth token, or "" if none.
static func get_oauth_token() -> String:
	var config := ConfigFile.new()
	if config.load(AUTH_CONFIG_PATH) == OK:
		return config.get_value(SECTION_AUTH, KEY_ITCHIO_TOKEN, "")
	return ""


## Stores the itch.io OAuth token.
static func set_oauth_token(token: String) -> void:
	_set_value(AUTH_CONFIG_PATH, SECTION_AUTH, KEY_ITCHIO_TOKEN, token)


## Clears the stored itch.io OAuth token.
static func clear_oauth_token() -> void:
	_set_value(AUTH_CONFIG_PATH, SECTION_AUTH, KEY_ITCHIO_TOKEN, "")


## Returns true if an OAuth token is stored.
static func has_oauth_token() -> bool:
	return get_oauth_token() != ""


# ---- Private Helpers ----

static func _get_int(section: String, key: String, default_value: int) -> int:
	var config := ConfigFile.new()
	if config.load(UPDATE_CONFIG_PATH) == OK:
		return config.get_value(section, key, default_value)
	return default_value


static func _get_string(section: String, key: String, default_value: String) -> String:
	var config := ConfigFile.new()
	if config.load(UPDATE_CONFIG_PATH) == OK:
		return config.get_value(section, key, default_value)
	return default_value


static func _set_value(path: String, section: String, key: String, value: Variant) -> void:
	var config := ConfigFile.new()
	config.load(path) # OK if file doesn't exist yet
	config.set_value(section, key, value)
	var err := config.save(path)
	if err != OK:
		push_warning("PPUpdateConfig: Could not save config to %s" % path)
