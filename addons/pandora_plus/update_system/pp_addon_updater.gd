@tool
extends RefCounted
class_name PPAddonUpdater
## Handles downloading, extracting, and installing Pandora+ updates.
##
## Preserves configuration.json during the update process by backing it up
## in memory before extraction and restoring it afterwards.


signal progress_updated(status: String)
signal update_completed(success: bool, message: String)

const ADDON_PATH: String = "res://addons/pandora_plus"
const CONFIG_JSON_PATH: String = "res://addons/pandora_plus/extensions/configuration.json"
const TEMP_ZIP_PATH: String = "user://pp_update_temp.zip"

var _http_request: HTTPRequest
var _parent_node: Node


## Starts the download of the update ZIP from the given URL.
## parent_node is needed to add the HTTPRequest as a child.
func download_update(url: String, parent_node: Node, headers: PackedStringArray = []) -> void:
	_parent_node = parent_node

	_http_request = HTTPRequest.new()
	_http_request.name = "PPUpdateDownloadRequest"
	_http_request.download_chunk_size = 65536
	_http_request.request_completed.connect(_on_download_completed)
	_parent_node.add_child(_http_request)

	progress_updated.emit("Downloading update...")

	var err := _http_request.request(url, headers)
	if err != OK:
		_cleanup()
		update_completed.emit(false, "Failed to start download (error %d)" % err)


func _on_download_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		_cleanup()
		update_completed.emit(false, "Download failed (result: %d)" % result)
		return

	if response_code != 200:
		_cleanup()
		update_completed.emit(false, "Download failed (HTTP %d)" % response_code)
		return

	progress_updated.emit("Installing update...")

	var success := _extract_and_install(body)
	_cleanup()

	if success:
		update_completed.emit(true, "Update installed successfully! Please restart the editor.")
	else:
		update_completed.emit(false, "Failed to extract and install update.")


func _extract_and_install(zip_data: PackedByteArray) -> bool:
	# Step 1: Backup configuration.json
	var config_backup: String = ""
	if FileAccess.file_exists(CONFIG_JSON_PATH):
		var config_file := FileAccess.open(CONFIG_JSON_PATH, FileAccess.READ)
		if config_file:
			config_backup = config_file.get_as_text()
			config_file.close()
			progress_updated.emit("Configuration backed up.")

	# Step 2: Save temp ZIP
	var zip_file := FileAccess.open(TEMP_ZIP_PATH, FileAccess.WRITE)
	if not zip_file:
		push_error("PPAddonUpdater: Could not create temp ZIP file")
		return false
	zip_file.store_buffer(zip_data)
	zip_file.close()

	# Step 3: Remove old addon (move to trash for safety)
	if DirAccess.dir_exists_absolute(ADDON_PATH):
		var global_path := ProjectSettings.globalize_path(ADDON_PATH)
		OS.move_to_trash(global_path)
		progress_updated.emit("Old version moved to trash.")

	# Step 4: Extract new files
	var zip_reader := ZIPReader.new()
	var err := zip_reader.open(TEMP_ZIP_PATH)
	if err != OK:
		push_error("PPAddonUpdater: Could not open downloaded ZIP (error %d)" % err)
		# Try to recover by undoing the trash move
		return false

	var files := zip_reader.get_files()
	if files.is_empty():
		zip_reader.close()
		push_error("PPAddonUpdater: Downloaded ZIP is empty")
		return false

	# Find the base prefix (ZIP from GitHub has format: user-repo-hash/...)
	var base_path := _find_base_path(files)
	progress_updated.emit("Extracting files...")

	for path in files:
		var relative_path: String = path.replace(base_path, "")
		if relative_path.is_empty():
			continue

		var target := "res://addons/pandora_plus/%s" % relative_path
		if path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(target)
		else:
			# Ensure parent directory exists
			var parent_dir := target.get_base_dir()
			if not DirAccess.dir_exists_absolute(parent_dir):
				DirAccess.make_dir_recursive_absolute(parent_dir)

			var file := FileAccess.open(target, FileAccess.WRITE)
			if file:
				file.store_buffer(zip_reader.read_file(path))
				file.close()

	zip_reader.close()
	DirAccess.remove_absolute(TEMP_ZIP_PATH)
	progress_updated.emit("Files extracted.")

	# Step 5: Restore configuration.json
	if not config_backup.is_empty():
		# Ensure the extensions directory exists
		var ext_dir := CONFIG_JSON_PATH.get_base_dir()
		if not DirAccess.dir_exists_absolute(ext_dir):
			DirAccess.make_dir_recursive_absolute(ext_dir)

		var config_file := FileAccess.open(CONFIG_JSON_PATH, FileAccess.WRITE)
		if config_file:
			config_file.store_string(config_backup)
			config_file.close()
			progress_updated.emit("Configuration restored.")
		else:
			push_error("PPAddonUpdater: Could not restore configuration.json!")

	return true


## Requests the editor to restart. Call after a successful update.
func request_editor_restart(editor_plugin: EditorPlugin) -> void:
	if editor_plugin:
		editor_plugin.get_editor_interface().restart_editor(true)


## Find the base path prefix in the ZIP (e.g. "username-repo-hash/" or "pandora_plus/").
func _find_base_path(files: PackedStringArray) -> String:
	# Look for the first directory entry, or derive from the first file
	for path in files:
		if path.ends_with("/"):
			# Check if this looks like a root-level directory
			var parts := path.trim_suffix("/").split("/")
			if parts.size() == 1:
				return path
	# Fallback: use everything before the first "/" in the first file
	if files.size() > 0:
		var first := files[0]
		var slash_idx := first.find("/")
		if slash_idx > 0:
			return first.substr(0, slash_idx + 1)
	return ""


func _cleanup() -> void:
	if _http_request and is_instance_valid(_http_request):
		_http_request.queue_free()
		_http_request = null
