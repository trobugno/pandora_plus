@tool
extends Node
class_name PPUpdateChecker
## Orchestrates the update check flow for Pandora+.
##
## On _ready(), checks if an update is available by fetching a remote
## version manifest JSON. If a newer version exists, shows the update dialog.
## Respects user preferences (auto-check, interval, skipped versions).


const VERSION_MANIFEST_URL: String = "https://trobugno.github.io/pandora_plus/version.json"

var _http_request: HTTPRequest
var _update_dialog: Window


func _ready() -> void:
	if not PPUpdateConfig.should_check_now():
		return
	if not PPUpdateConfig.should_remind():
		return

	_start_version_check()


func _start_version_check() -> void:
	_http_request = HTTPRequest.new()
	_http_request.name = "PPVersionCheckRequest"
	_http_request.request_completed.connect(_on_version_check_completed)
	add_child(_http_request)

	var err := _http_request.request(VERSION_MANIFEST_URL)
	if err != OK:
		push_warning("PPUpdateChecker: Failed to start version check request (error %d)" % err)
		_cleanup_http()


func _on_version_check_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	PPUpdateConfig.mark_checked()

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		_cleanup_http()
		return

	var json_text := body.get_string_from_utf8()
	var manifest = JSON.parse_string(json_text)
	if manifest == null or typeof(manifest) != TYPE_DICTIONARY:
		push_warning("PPUpdateChecker: Invalid version manifest JSON")
		_cleanup_http()
		return

	var edition := PPVersionUtils.get_edition()
	if not manifest.has(edition):
		push_warning("PPUpdateChecker: Edition '%s' not found in manifest" % edition)
		_cleanup_http()
		return

	var edition_data: Dictionary = manifest[edition]
	var remote_version: String = edition_data.get("version", "")
	var local_version := PPVersionUtils.get_local_version()

	if remote_version.is_empty() or local_version.is_empty():
		_cleanup_http()
		return

	if not PPVersionUtils.is_update_available(local_version, remote_version):
		_cleanup_http()
		return

	if PPUpdateConfig.is_version_skipped(remote_version):
		_cleanup_http()
		return

	# Update is available — show the dialog
	_show_update_dialog(local_version, remote_version, edition_data)
	_cleanup_http()


func _show_update_dialog(
	local_version: String, remote_version: String, edition_data: Dictionary
) -> void:
	var dialog_scene := load("res://addons/pandora_plus/update_system/pp_update_dialog.tscn")
	if dialog_scene == null:
		push_warning("PPUpdateChecker: Could not load update dialog scene")
		return

	_update_dialog = dialog_scene.instantiate()
	_update_dialog.setup(local_version, remote_version, edition_data)
	_update_dialog.skip_requested.connect(_on_skip_requested)
	_update_dialog.remind_later_requested.connect(_on_remind_later)
	_update_dialog.tree_exiting.connect(_on_dialog_closed)

	# Add to editor base control for proper parenting
	var editor_plugin: EditorPlugin = get_meta("editor_plugin", null)
	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(_update_dialog)
	else:
		add_child(_update_dialog)

	_update_dialog.popup_centered()


func _on_skip_requested(version: String) -> void:
	PPUpdateConfig.skip_version(version)
	_close_dialog()


func _on_remind_later() -> void:
	PPUpdateConfig.remind_later()
	_close_dialog()


func _on_dialog_closed() -> void:
	_update_dialog = null


func _close_dialog() -> void:
	if _update_dialog and is_instance_valid(_update_dialog):
		_update_dialog.hide()
		_update_dialog.queue_free()
		_update_dialog = null


func _cleanup_http() -> void:
	if _http_request and is_instance_valid(_http_request):
		_http_request.queue_free()
		_http_request = null
